cd /

if [ ! -d /nts ]; then
  git clone https://github.com/enriquetasa/nts.git
fi

chmod -R 777 nts 
cat /nts/nts.sh >> ~/.bashrc
