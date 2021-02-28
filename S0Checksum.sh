#!/bin/sh
echo Perform S0 Checksum

sum=0
bitsize=1
checksumUnitSize=2   #units are 2 digits
checksumDataOffset=3 #S0<data>. Remember, shell script indexing first element from 1
hexFormat="0x"       #Specify hex value
checksumBitlength=8  #Checksum is the 2 LSB of Ca1 addition
checksumBytelength=2
digitBytelength=1

read -r S0Record<$1
S0Length=${#S0Record}

echo "S0 Record is: $S0Record"
echo "Digit length is $S0Length"

pos=$checksumDataOffset
while [ $pos -le $S0Length ]
do
   sDigit="$hexFormat$(expr substr "$S0Record" $pos $checksumUnitSize)"
   #echo "<$sDigit>"
   sum=$((sum + sDigit))
   pos=$((pos + checksumUnitSize))
done

binSum=$(echo "obase=2;$sum" | bc)

echo "Data addition is $sum"
echo "In binary, thats $binSum"

#Ca1, so negate the addition
#TODO: Handle if binSum leq than 8. Or demonstrate that is imposible
binSumLength=${#binSum}
pos=$((binSumLength-checksumBitlength + 1))

while [ $pos -le $binSumLength ]
do
   sBit=$(expr substr "$binSum" $pos $bitsize)
   sBitNot=0
   if [ $sBit -eq 0 ]
   then
      sBitNot=1
   fi

   binSumNot="$binSumNot$sBitNot"
   pos=$((pos + bitsize))
done
 
echo "Ca1 data addition in binary is $binSumNot"

fullChecksum=$(echo "obase=16;ibase=2;$binSumNot" | bc)

fullChecksumLength=${#fullChecksum}
pos=$((fullChecksumLength-checksumBytelength + 1))

while [ $pos -le $fullChecksumLength ]
do
   fullChecksumDigit="$(expr substr "$fullChecksum" $pos $digitBytelength)"
   checksum="$checksum$fullChecksumDigit"
   pos=$((pos + digitBytelength))
done

echo "S0 checksum is $checksum"

#Write checksum at the end of S0 record on file, first line
newS0Record="$S0Record$checksum"

sed '1d' $1 > tmp.txt
mv tmp.txt $1
sed -i "1i\\$newS0Record" $1

echo "End S0Checksum.sh"

