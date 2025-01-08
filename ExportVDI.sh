#!/bin/bash

target_dir="/var/lib/libvirt/images"
source_dir="/home/quentin/Téléchargements/ISOs/Vbox"

# Vérification des répertoires
if [[ ! -d "$source_dir" ]]; then
  echo "Erreur : Le répertoire source $source_dir n'existe pas."
  exit 1
fi

if [[ ! -d "$target_dir" ]]; then
  echo "Erreur : Le répertoire cible $target_dir n'existe pas."
  exit 1
fi

# Parcourir tous les fichiers VDI dans le répertoire source
for source_file in "$source_dir"/*.vdi; do
  # Vérifier qu'il y a bien des fichiers à traiter
  if [[ ! -e "$source_file" ]]; then
    echo "Aucun fichier VDI trouvé dans $source_dir."
    exit 0
  fi

  # Extraire le nom de la VM (sans extension)
  vm_name=$(basename "$source_file" .vdi)
  target_file="$target_dir/$vm_name.qcow2"

  echo "Traitement de $vm_name..."

  # Conversion de l'image
  sudo qemu-img convert -f vdi -O qcow2 "$source_file" "$target_file"
  if [[ $? -ne 0 ]]; then
    echo "Erreur : La conversion de $source_file vers $target_file a échoué."
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
