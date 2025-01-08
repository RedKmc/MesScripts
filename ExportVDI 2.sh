#!/bin/bash

# Dossiers source et destination
SOURCE_DIR="/home/quentin/VirtualBox VMs"
DEST_DIR="/var/lib/libvirt/images"

# Vérifie que le dossier de destination existe
if [ ! -d "$DEST_DIR" ]; then
    echo "Le dossier de destination $DEST_DIR n'existe pas. Création en cours..."
    mkdir -p "$DEST_DIR"
    if [ $? -ne 0 ]; then
        echo "Échec de la création du dossier de destination."
        exit 1
    fi
fi

# Parcourt chaque sous-dossier dans le dossier source
for VM_DIR in "$SOURCE_DIR"/*; do
    if [ -d "$VM_DIR" ]; then
        VM_NAME=$(basename "$VM_DIR")
        echo "Traitement de la machine virtuelle : $VM_NAME"

        # Recherche un fichier VDI dans le sous-dossier
        VDI_FILE=$(find "$VM_DIR" -type f -name "*.vdi" | head -n 1)
        if [ -z "$VDI_FILE" ]; then
            echo "Aucun fichier VDI trouvé pour $VM_NAME. Ignoré."
            continue
        fi

        # Définir le fichier de destination QCOW2
        QCOW2_FILE="$DEST_DIR/${VM_NAME}.qcow2"

        # Convertit le fichier VDI en QCOW2
        echo "Conversion de $VDI_FILE vers $QCOW2_FILE..."
        sudo qemu-img convert -f vdi -O qcow2 "$VDI_FILE" "$QCOW2_FILE"

        if [ $? -eq 0 ]; then
            echo "Conversion réussie pour $VM_NAME."
        else
            echo "Erreur lors de la conversion pour $VM_NAME."
        fi
    fi
done

echo "Conversion terminée."
