#!/bin/bash

source_dir="/var/lib/libvirt/images"
target_dir="/home/quentin/Téléchargements/ISOs/Vbox"

# Vérification des répertoires
if [[ ! -d "$source_dir" ]]; then
  echo "Erreur : Le répertoire source $source_dir n'existe pas."
  exit 1
fi

if [[ ! -d "$target_dir" ]]; then
  echo "Erreur : Le répertoire cible $target_dir n'existe pas."
  exit 1
fi

# Parcourir tous les fichiers QCOW2 dans le répertoire source
for source_file in "$source_dir"/*.qcow2; do
  # Vérifier qu'il y a bien des fichiers à traiter
  if [[ ! -e "$source_file" ]]; then
    echo "Aucun fichier QCOW2 trouvé dans $source_dir."
    exit 0
  fi

  # Extraire le nom de la VM (sans extension)
  vm_name=$(basename "$source_file" .qcow2)
  target_file="$target_dir/$vm_name.vdi"

  echo "Traitement de $vm_name..."

  # Conversion de l'image
  sudo qemu-img convert -f qcow2 -O vdi "$source_file" "$target_file"
  if [[ $? -ne 0 ]]; then
    echo "Erreur : La conversion de $source_file vers $target_file a échoué."
    continue
  fi

  # Création de la VM dans VirtualBox
  VBoxManage createvm --name "$vm_name" --register
  if [[ $? -ne 0 ]]; then
    echo "Erreur : La création de la VM $vm_name dans VirtualBox a échoué."
    continue
  fi

  # Ajout d'un contrôleur SATA
  VBoxManage storagectl "$vm_name" --name "SATA Controller" --add sata --controller IntelAhci
  if [[ $? -ne 0 ]]; then
    echo "Erreur : L'ajout du contrôleur SATA pour $vm_name a échoué."
    continue
  fi

  # Attachement du disque à la VM
  VBoxManage storageattach "$vm_name" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$target_file"
  if [[ $? -ne 0 ]]; then
    echo "Erreur : L'attachement du disque $target_file à la VM $vm_name a échoué."
    continue
  fi

  # Changer le propriétaire du fichier cible
  sudo chown quentin:quentin "$target_file"
  if [[ $? -ne 0 ]]; then
    echo "Erreur : Impossible de changer les permissions de $target_file."
    continue
  fi

  # Suppression du fichier source si tout s'est bien passé
  sudo rm "$source_file"
  if [[ $? -ne 0 ]]; then
    echo "Erreur : Impossible de supprimer le fichier source $source_file."
    continue
  fi

  echo "Traitement de $vm_name terminé avec succès."
done

echo "Tous les fichiers ont été traités."
