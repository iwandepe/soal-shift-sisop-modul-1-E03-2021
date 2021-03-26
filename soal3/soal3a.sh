#!/bin/bash

 > Foto.log
for((i=1;i<24;i++))
        do wget https://loremflickr.com/320/240/kitten -O Koleksi_$i -a Foto.log
done

for ((i=1;i<24;i++))
	do for ((j=i+1;j<24;j++))
		do if cmp Koleksi_$i Koleksi_$j &> /dev/null
		then rm Koleksi_$j
fi
done
done

for ((i=1;i<24;i++))
do if [ ! -f Koleksi_$i ]
	then for ((j=23;i<j;j--))
		do if [ -f Koleksi_$j ] 
			then mv Koleksi_$j Koleksi_$i
break
fi done
fi done

for ((i=1;i<10;i++))
do mv Koleksi_$i Koleksi_0$i
done
