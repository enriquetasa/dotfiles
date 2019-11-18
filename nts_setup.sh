cd /

if [ ! -d /nts ]; then
  git clone https://github.com/enriquetasa/nts.git
fi

sh /nts/setup.sh
