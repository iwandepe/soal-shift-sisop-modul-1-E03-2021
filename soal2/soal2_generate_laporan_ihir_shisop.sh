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
	print "Transaksi terakhir dengan profit percentage terbesar yaitu", order_id, "dengan persentase", max_percentage
}
' Laporan-TokoShiSop.tsv

echo ''

awk -F $'\t' '
BEGIN {
	print("Daftar nama customer di Albuquerque pada tahun 2017 antara lain: ")
}
/2017/ {
	if ($10=="Albuquerque") print $7
}
' Laporan-TokoShiSop.tsv | uniq

echo ''

awk -F $'\t' '
BEGIN {
	min=1000000; 
	min_segment='null'
} 
NR>1{
	arr[$8]++;
} 
END {
	for(a in arr) {
		if (arr[a]<min) { 
			min=arr[a]; 
			min_segment=a
		}
	} 
	print "Tipe segment customer yang penjualannya paling sedikit adalah ", min_segment, "dengan",  min, "transaksi"
}
' Laporan-TokoShiSop.tsv

echo ''

awk -F $'\t' '
BEGIN {
	min_profit=99999999; 
	min_region='null'
} 
NR>1 {
	arr[$11]+=$21
} 
END {
	for(a in arr) {
		if (arr[a]<min) { 
			min_profit=arr[a]; 
			min_region=a;
		}
	} 
	print "Wilayah bagian (region) yang memiliki total keuntungan (profit) yang paling sedikit adalah",  min_region, "dengan total keuntungan ", min_profit
}
' Laporan-TokoShiSop.tsv