string="firstname banuka"
file=./test.txt

grep -qwi "$string$" "$file" && \
sed -i "s,\(^[^[:alnum:]]*\)\($string$\),\2,i" "$file" || \
sudo echo "$string" >> "$file"