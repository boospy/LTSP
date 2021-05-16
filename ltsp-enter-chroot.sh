BASE=/opt/ltsp;
FILES=(`ls -I images $BASE/`);
ARCH="";

while :
do
        echo -e "\nThe following chroots were found:\n------------------------------------\n";
        X=0;
        for f in `ls -I images $BASE`
        do
                X=$(($X+1));
                echo -e "$X)\t$f"
        done

        echo -en "\nPlease select a chroot [1-$X]: ";
        read ARCH_NUM;

        if [[ $ARCH_NUM =~ ^[0-9]+$ && $ARCH_NUM -gt 0 && $ARCH_NUM -le $X ]]; then
                ARCH=${FILES[$(($ARCH_NUM-1))]}
                echo -e "Selected: $ARCH\n ";
                break;
        else
                echo -e "Invalid selection.\n";
        fi
done

ROOT="$BASE/$ARCH"
chroot "$ROOT" mount -t proc proc /proc || die "Not a valid chroot: $ROOT"
mount --bind /var/cache/apt/archives "$ROOT/var/cache/apt/archives"
cp /etc/resolv.conf "$ROOT/etc/"
export LTSP_HANDLE_DAEMONS=false
echo "Entering chroot $ROOT, type 'exit' to exit."
chroot "$ROOT" || true
unset LTSP_HANDLE_DAEMONS
umount "$ROOT/var/cache/apt/archives"    

if ! umount "$ROOT/proc"; then
        echo "$ROOT/proc is in use, forcing unmount!"
        umount -l "$ROOT/proc"
fi   
