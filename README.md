# soal-shift-sisop-modul-1-E03-2021

## Soal 1
### Penjelasan soal
Ryujin baru saja diterima sebagai IT support di perusahaan Bukapedia. Dia diberikan tugas untuk membuat laporan harian untuk aplikasi internal perusahaan, ticky. Terdapat 2 laporan yang harus dia buat, yaitu laporan daftar peringkat pesan error terbanyak yang dibuat oleh ticky dan laporan penggunaan user pada aplikasi ticky. Untuk membuat laporan tersebut, Ryujin harus melakukan beberapa hal berikut:
1. Mengumpulkan informasi dari log aplikasi yang terdapat pada file syslog.log. Informasi yang diperlukan antara lain: jenis log (ERROR/INFO), pesan log, dan username pada setiap baris lognya. Karena Ryujin merasa kesulitan jika harus memeriksa satu per satu baris secara manual, dia menggunakan regex untuk mempermudah pekerjaannya. Bantulah Ryujin membuat regex tersebut.
1. Kemudian, Ryujin harus menampilkan semua pesan error yang muncul beserta jumlah kemunculannya.
1. Ryujin juga harus dapat menampilkan jumlah kemunculan log ERROR dan INFO untuk setiap user-nya. Setelah semua informasi yang diperlukan telah disiapkan, kini saatnya Ryujin menuliskan semua informasi tersebut ke dalam laporan dengan format file csv.
1. Semua informasi yang didapatkan pada poin b dituliskan ke dalam file error_message.csv dengan header Error,Count yang kemudian diikuti oleh daftar pesan error dan jumlah kemunculannya diurutkan berdasarkan jumlah kemunculan pesan error dari yang terbanyak.
1. Semua informasi yang didapatkan pada poin c dituliskan ke dalam file user_statistic.csv dengan header Username,INFO,ERROR diurutkan berdasarkan username secara ascending.

#### Penyelesaian
```bash
file="./syslog.log"
```
Pertama, path dari `syslog.log` disimpan ke sebuah variable bernama `file`.

```bash
regex='.+: (INFO|ERROR) (.+) \((.+)\)'
```
Regex yang dipakai juga disimpan ke variable bernama `regex`. Regex ini akan melakukan capture 3 hal, yaitu tipe log, pesan, dan usernamenya.

```bash
declare -A errors
declare -A userErrors
declare -A userInfo
```
Kemudian 3 buah associative array dideklarasikan. 3 array ini akan menyimpan jumlah error per jenisnya, jumlah error per username, dan jumlah info per username.

```bash
while read -r line
do
	...
done < "$file"
```
While loop ini akan membaca `$file` baris per baris dan disimpan ke variable `$line`.

```bash
[[ $line =~ $regex ]]
```
String di variable `$line` kemudian diperiksa terhadap `$regex`. Bila sesuai, string tersebut kemudian akan tersimpan di array `BASH_REMATCH` bersama dengan string yang ter-capture.

```bash
if [[ ${BASH_REMATCH[1]} == "ERROR" ]]
	then
		((errors['${BASH_REMATCH[2]}']++))
		((userErrors['${BASH_REMATCH[3]}']++))
	else
		((userInfo['${BASH_REMATCH[3]}']++))
	fi
```
Kemudian tipe log yang tersimpan di index kedua `BASH_REMATCH` akan diperiksa. Bila nilainya `ERROR`, maka nilai elemen array `errors` yang mempunyai key pesan error yang tersimpan di index ketiga `BASH_REMATCH` dan nilai elemen array `userErrors` yang mempunyai key username yang tersimpan di index keempat juga akan di-increment. Bila nilainya bukan `ERROR` atau berarti bertipe `INFO`, maka nilai elemen array `userInfo` yang mempunyai key username di-increment. Variable yang unset akan bernilai 0, sehingga tidak perlu mengecek apakah key tersebut sudah ada di array.

```bash
echo "Error,Count" > error_message.csv
```
Baris ini akan membuat file `error_message.csv` bila belum ada atau menimpa file tersebut bila sudah ada. Kemudian akan menulis `Error,Count` di file tersebut.

```bash
for key in "${!errors[@]}"
do
	printf "%s,%d\n" "$key" "${errors[$key]}" 
done | sort -rn -t , -k 2 >> error_message.csv
```
Kode ini akan melakukan loop untuk setiap key di array `errors`. Di setiap loopnya, akan menuliskan nilai dari `$key` dan `${errors[$key]}`. Jika sudah selesai, maka akan dilakukan sort dan akan ditambahkan ke file `error_message.csv`. Option `-rn` akan melakukan sort secara descending dan numerik, `-t ,` akan mengganti field separator menjadi koma dan `-k 2` berarti sort dilakukan berdasarkan field kedua.

```bash
echo "Username,INFO,ERROR" > user_statistic.csv
```
Mirip seperti sebelumnya, baris ini akan membuat atau menimpa file `user_statistic.csv` dan menuliskan `Username,INFO,ERROR`.

```bash
for key in "${!userErrors[@]}" "${!userInfo[@]}"
do
	printf "%s,%d,%d\n" "$key" "${userInfo[$key]}" "${userErrors[$key]}" 
done | sort -u >> user_statistic.csv
```
Juga mirip seperti sebelumnya tetapi di kode ini akan melakukan loop untuk setiap key di 2 array, yaitu `userErrors` dan `userInfo`, dan menuliskan nilai dari `$key`, `${userInfo[$key]}`, `${userErrors[$key]}`. Hal ini dilakukan agar bila ada username yang hanya mempunyai log bertipe INFO atau ERROR saja tetap akan tertulis. Kemudian hasil dari loop akan di-sort dan ditambahkan ke file `user_statistic.csv`. Karena username bisa saja mempunyai log INFO dan ERROR dan menghasilkan baris yang sama, maka perlu menambah option `-u` di sort untuk menghapus baris yang duplikat.

## Soal 2
### Penjelasan soal
Steven dan Manis mendirikan sebuah startup bernama “TokoShiSop”. Sedangkan kamu dan Clemong adalah karyawan pertama dari TokoShiSop. Setelah tiga tahun bekerja, Clemong diangkat menjadi manajer penjualan TokoShiSop, sedangkan kamu menjadi kepala gudang yang mengatur keluar masuknya barang.

Tiap tahunnya, TokoShiSop mengadakan Rapat Kerja yang membahas bagaimana hasil penjualan dan strategi kedepannya yang akan diterapkan. Kamu sudah sangat menyiapkan sangat matang untuk raker tahun ini. Tetapi tiba-tiba, Steven, Manis, dan Clemong meminta kamu untuk mencari beberapa kesimpulan dari data penjualan “Laporan-TokoShiSop.tsv”.
1. Steven ingin mengapresiasi kinerja karyawannya selama ini dengan mengetahui Row ID dan profit percentage terbesar (jika hasil profit percentage terbesar lebih dari 1, maka ambil Row ID yang paling besar). Karena kamu bingung, Clemong memberikan definisi dari profit percentage, yaitu:
**Profit Percentage = (Profit Cost Price) 100.**
Cost Price didapatkan dari pengurangan Sales dengan Profit. (Quantity diabaikan).
1. Clemong memiliki rencana promosi di Albuquerque menggunakan metode MLM. Oleh karena itu, Clemong membutuhkan daftar nama customer pada transaksi tahun 2017 di Albuquerque.
1. TokoShiSop berfokus tiga segment customer, antara lain: Home Office, Customer, dan Corporate. Clemong ingin meningkatkan penjualan pada segmen customer yang paling sedikit. Oleh karena itu, Clemong membutuhkan segment customer dan jumlah transaksinya yang paling sedikit.
1. TokoShiSop membagi wilayah bagian (region) penjualan menjadi empat bagian, antara lain: Central, East, South, dan West. Manis ingin mencari wilayah bagian (region) yang memiliki total keuntungan (profit) paling sedikit dan total keuntungan wilayah tersebut.
1. kamu diharapkan bisa membuat sebuah script yang akan menghasilkan file “hasil.txt” yang memiliki format sebagai berikut:

### Penyelesaian
```bash
#!/bin/bash

awk -F $'\t' '
BEGIN {
	max_percentage=0;
} 
NR > 1{
	percentage=$21/($18-$21)*100; 
	if (max_percentage<=percentage) {
		max_percentage=percentage; 
		order_id=$2;
	}
} 
END {
	print "Transaksi terakhir dengan profit percentage terbesar yaitu", order_id, "dengan persentase", max_percentage"%"
}
' Laporan-TokoShiSop.tsv >> hasil.txt

echo '' >> hasil.txt

awk -F $'\t' '
BEGIN {
	print("Daftar nama customer di Albuquerque pada tahun 2017 antara lain: ")
}
/2017/ {
	if ($10=="Albuquerque") print $7
}
' Laporan-TokoShiSop.tsv | uniq >> hasil.txt

echo '' >> hasil.txt

awk -F $'\t' '
BEGIN {
	min=1000000; 
	min_segment='null'
} 
NR > 1 {
	arr[$8]+=$19;
} 
END {
	for(a in arr) {
		if (arr[a]<min) { 
			min=arr[a]; 
			min_segment=a
		}
	} 
	print "Tipe segment customer yang penjualannya paling sedikit adalah", min_segment, "dengan",  min, "transaksi"
}
' Laporan-TokoShiSop.tsv >> hasil.txt

echo '' >> hasil.txt

awk -F $'\t' '
BEGIN {
	min_profit=99999999; 
} 
NR > 1{
	arr[$13]+=$21;
} 
END {
	for(a in arr) {
		if (arr[a]<min_profit) { 

			min_profit=arr[a]; 
			min_region=a;
		}
	} 
	print "Wilayah bagian (region) yang memiliki total keuntungan (profit) yang paling sedikit adalah",  min_region, "dengan total keuntungan ", min_profit
}
' Laporan-TokoShiSop.tsv >> hasil.txt
```
## Soal 3
Kuuhaku adalah orang yang sangat suka mengoleksi foto-foto digital, namun Kuuhaku juga merupakan seorang yang pemalas sehingga ia tidak ingin repot-repot mencari foto, selain itu ia juga seorang pemalu, sehingga ia tidak ingin ada orang yang melihat koleksinya tersebut, sayangnya ia memiliki teman bernama Steven yang memiliki rasa kepo yang luar biasa. Kuuhaku pun memiliki ide agar Steven tidak bisa melihat koleksinya, serta untuk mempermudah hidupnya, yaitu dengan meminta bantuan kalian. Idenya adalah :
1. Membuat script untuk mengunduh 23 gambar dari "https://loremflickr.com/320/240/kitten" serta menyimpan log-nya ke file "Foto.log". Karena gambar yang diunduh acak, ada kemungkinan gambar yang sama terunduh lebih dari sekali, oleh karena itu kalian harus menghapus gambar yang sama (tidak perlu mengunduh gambar lagi untuk menggantinya). Kemudian menyimpan gambar-gambar tersebut dengan nama "Koleksi_XX" dengan nomor yang berurutan tanpa ada nomor yang hilang (contoh : Koleksi_01, Koleksi_02, ...)
1. Karena Kuuhaku malas untuk menjalankan script tersebut secara manual, ia juga meminta kalian untuk menjalankan script tersebut sehari sekali pada jam 8 malam untuk tanggal-tanggal tertentu setiap bulan, yaitu dari tanggal 1 tujuh hari sekali (1,8,...), serta dari tanggal 2 empat hari sekali(2,6,...). Supaya lebih rapi, gambar yang telah diunduh beserta log-nya, dipindahkan ke folder dengan nama tanggal unduhnya dengan format "DD-MM-YYYY" (contoh : "13-03-2023").
1. Agar kuuhaku tidak bosan dengan gambar anak kucing, ia juga memintamu untuk mengunduh gambar kelinci dari "https://loremflickr.com/320/240/bunny". Kuuhaku memintamu mengunduh gambar kucing dan kelinci secara bergantian (yang pertama bebas. contoh : tanggal 30 kucing > tanggal 31 kelinci > tanggal 1 kucing > ... ). Untuk membedakan folder yang berisi gambar kucing dan gambar kelinci, nama folder diberi awalan "Kucing_" atau "Kelinci_" (contoh : "Kucing_13-03-2023").
1. Untuk mengamankan koleksi Foto dari Steven, Kuuhaku memintamu untuk membuat script yang akan memindahkan seluruh folder ke zip yang diberi nama “Koleksi.zip” dan mengunci zip tersebut dengan password berupa tanggal saat ini dengan format "MMDDYYYY" (contoh : “03032003”).
1. Karena kuuhaku hanya bertemu Steven pada saat kuliah saja, yaitu setiap hari kecuali sabtu dan minggu, dari jam 7 pagi sampai 6 sore, ia memintamu untuk membuat koleksinya ter-zip saat kuliah saja, selain dari waktu yang disebutkan, ia ingin koleksinya ter-unzip dan tidak ada file zip sama sekali.

### Penyelesaian
**1. soal 3a**
```bash
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
```
pertama membuat file dengan nama Foto.log yang nantinya akan menyimpan log dari mengunduh 23 gambar.

```> Foto.log
for((i=1;i<24;i++))
        do wget https://loremflickr.com/320/240/kitten -O Koleksi_$i -a Foto.log
done
```
loop ini  untuk mengunduhh gambar dari link sebanyak 23 kali dan memberi nama Koleksi_i. i disini sesuai urutan pengunduhan dan menyimpan lognya ke file Foto.log

```for ((i=1;i<24;i++))
	do for ((j=i+1;j<24;j++))
		do if cmp Koleksi_$i Koleksi_$j &> /dev/null
		then rm Koleksi_$j
fi
done
done
```
loop kedua ini untuk mengecek apakah ada gambar yang sama saat kita mengunduh, disini saya menggunakan cmp. Jika ada yang sama maka gambar yang urutannya paling besar akan dihapus

```for ((i=1;i<24;i++))
do if [ ! -f Koleksi_$i ]
	then for ((j=23;i<j;j--))
		do if [ -f Koleksi_$j ] 
			then mv Koleksi_$j Koleksi_$i
break
fi done
fi done
```
loop ini  mengecek adakah urutan yang hilang lalu mereplace urutan angka yang hilang tersebut. jadi jika ada urutan yang hilang, urutan setelahnya akan menggantikan begitu seterusnya.

```for ((i=1;i<10;i++))
do mv Koleksi_$i Koleksi_0$i
done
```
ini berfungsi untuk mengubah nama file yang urutan 1 sampai sembilan dengan menambahkan 0 didepan urutannya

**2. soal 3b**
```bash
#!/bin/bash

mkdir $(date +%d-%m-%Y)
 > Foto.log
for((i=1;i<24;i++))
        do wget https://loremflickr.com/320/240/kitten -O Koleksi_$i -a Foto.log
done
mv Foto.log $(date +%d-%m-%Y)

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

mv Koleksi* $(date +%d-%m-%Y)
```
***Penjelasan***
```mkdir $(date +%d-%m-%Y)
 > Foto.log
 ```
pertama membuat file dengan nama Foto.log yang nantinya akan menyimpan log dari mengunduh 23 gambar dan membuat folder untuk menyimpan foto.log dan gambar unduhan

```> Foto.log
for((i=1;i<24;i++))
        do wget https://loremflickr.com/320/240/kitten -O Koleksi_$i -a Foto.log
done
mv Foto.log $(date +%d-%m-%Y)
```
loop ini  untuk mengunduhh gambar dari link sebanyak 23 kali dan memberi nama Koleksi_i. i disini sesuai urutan pengunduhan dan menyimpan lognya ke file Foto.log
file Foto.log lalu dipindahkan ke folder berfromat sesuai tanggal

```for ((i=1;i<24;i++))
	do for ((j=i+1;j<24;j++))
		do if cmp Koleksi_$i Koleksi_$j &> /dev/null
		then rm Koleksi_$j
fi
done
done
```
loop kedua ini untuk mengecek apakah ada gambar yang sama saat kita mengunduh, disini saya menggunakan cmp. Jika ada yang sama maka gambar yang urutannya paling besar akan dihapus

```for ((i=1;i<24;i++))
do if [ ! -f Koleksi_$i ]
	then for ((j=23;i<j;j--))
		do if [ -f Koleksi_$j ] 
			then mv Koleksi_$j Koleksi_$i
break
fi done
fi done
```
loop ini  mengecek adakah urutan yang hilang lalu mereplace urutan angka yang hilang tersebut. jadi jika ada urutan yang hilang, urutan setelahnya akan menggantikan begitu seterusnya.

```for ((i=1;i<10;i++))
do mv Koleksi_$i Koleksi_0$i
done

mv Koleksi* $(date +%d-%m-%Y)
```
ini berfungsi untuk mengubah nama file yang urutan 1 sampai sembilan dengan menambahkan 0 didepan urutannya. dan meindahkan gambar unduhan yang memilki kata Koleksi ke folder yang berformat tanggal

**3. soal 3c**
```bash
#!/bin/bash

kel=$(find /home/vika -type d -name 'Kelinci_*' | wc -l)
kuc=$(find /home/vika -type d -name 'Kucing_*' | wc -l)

> Foto.log

if [ $kuc == $kel ]
then
mkdir Kucing_$(date +%d-%m-%Y)
	for ((i=1;i<24;i++))
	do wget https://loremflickr.com/320/240/kitten -O Koleksi_$i -a Foto.log;done
	mv Foto.log Kucing_$(date +%d-%m-%Y)

elif [ $kuc > $kel ]
then
mkdir Kelinci_$(date +%d-%m-%Y)
	for ((i=1;i<24;i++))
	do wget https://loremflickr.com/320/240/bunny -O Koleksi_$i -a Foto.log;done
	mv Foto.log Kelinci_$(date +%d-%m-%Y)
fi

for ((i=1;i<24;i++))
	do for ((j=i+1;j<24;j++))
		do if cmp Koleksi_$i Koleksi_$j &> /dev/null;
		then rm Koleksi_$j
fi;done;done

for ((i=1;i<24;i++))
	do if [ ! -f Koleksi_$i ]
	then for ((j=23;i<j;j--))
		do if [ -f Koleksi_$j ]
		then mv Koleksi_$j Koleksi_$i
break;fi;done;fi;done

for ((i=1;i<10;i++))
	do mv Koleksi_$i Koleksi_0$i
done

if [ $kuc == $kel ]
	then mv Koleksi_* Kucing_$(date +%d-%m-%Y)
elif [ $kuc > $kel ]
	then mv Koleksi_* Kelinci_$(date +%d-%m-%Y)
fi
```
***Penjelasan***

```kel=$(find /home/vika -type d -name 'Kelinci_*' | wc -l)
kuc=$(find /home/vika -type d -name 'Kucing_*' | wc -l)
> Foto.log
```
mengecek jumlah folder  yang mengandung nama kelinci ataupun kucing di home. serta membuat file foto.log

```
if [ $kuc == $kel ]
then
mkdir Kucing_$(date +%d-%m-%Y)
	for ((i=1;i<24;i++))
	do wget https://loremflickr.com/320/240/kitten -O Koleksi_$i -a Foto.log;done
	mv Foto.log Kucing_$(date +%d-%m-%Y)

elif [ $kuc > $kel ]
then
mkdir Kelinci_$(date +%d-%m-%Y)
	for ((i=1;i<24;i++))
	do wget https://loremflickr.com/320/240/bunny -O Koleksi_$i -a Foto.log;done
	mv Foto.log Kelinci_$(date +%d-%m-%Y)
fi
```
jika banyaknya folder kucing sama dengan kelinci maka akan membuat folder kucing_tanggal dan mendownload gambar (seperti no 3a--3b), jika banyaknya kucing lebih besar dari pada banyaknya folder kelinci mmaka akan membuat folder kelinci_tanggal dan mendownload gambar (seperti no 3a--3b)

```for ((i=1;i<24;i++))
	do for ((j=i+1;j<24;j++))
		do if cmp Koleksi_$i Koleksi_$j &> /dev/null
		then rm Koleksi_$j
fi
done
done
```
loop kedua ini untuk mengecek apakah ada gambar yang sama saat kita mengunduh, disini saya menggunakan cmp. Jika ada yang sama maka gambar yang urutannya paling besar akan dihapus

```for ((i=1;i<24;i++))
do if [ ! -f Koleksi_$i ]
	then for ((j=23;i<j;j--))
		do if [ -f Koleksi_$j ] 
			then mv Koleksi_$j Koleksi_$i
break
fi done
fi done
```
loop ini  mengecek adakah urutan yang hilang lalu mereplace urutan angka yang hilang tersebut. jadi jika ada urutan yang hilang, urutan setelahnya akan menggantikan begitu seterusnya.

```for ((i=1;i<10;i++))
	do mv Koleksi_$i Koleksi_0$i
done
```
untuk mengganti nama gambar urutan 1--9 dengan memnambahkan 0 sebelum angka urutannya

```if [ $kuc == $kel ]
	then mv Koleksi_* Kucing_$(date +%d-%m-%Y)
elif [ $kuc > $kel ]
	then mv Koleksi_* Kelinci_$(date +%d-%m-%Y)
fi
```
jika jumlah folder kucing = folder kelinci maka gambar yang diunduh dipindahkan di kelinci, jika jumlah folder kucing lebih banyak maka file gambar akan dipindahkan di folder kelinci

**4. soal 3d**
```bash
#!/bin/bash

pass=$(date +"%m%d%Y")

for folder in K*_*
do zip -q -r -P $pass Koleksi.zip $folder
rm -r $folder
done
```
***Penjelasan***
membuat password dengan format MMDDYYYY, lalu untuk folder-folder yang berformat K dan _ akan dizip dengan password tanggal saat ini dan menghapus foldernya
