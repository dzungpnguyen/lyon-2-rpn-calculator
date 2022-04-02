formatChain()
{
  mot=$1
  longueur=$2
  symboleDebut=$3
  resu=$mot
  longueurMot=${#mot}
  dif=$((longueur-longueurMot))
  for ((i=0; i<dif; i++)){
    resu=" $resu"
  }
  echo -e "\033[47m \033[0m $3$resu \033[47m \033[0m"
}

affichePile()
{
    set -- $maPile
    echo -e  "\033[47m                            \033[0m" 
    formatChain   "${5-"--"}"  22 "5:"
    formatChain   "${4-"--"}"  22 "4:"
    formatChain   "${3-"--"}"  22 "3:" 
    formatChain   "${2-"--"}"  22 "2:" 
    formatChain   "${1-"--"}"  22 "1:" 
    echo -e  "\033[47m                            \033[0m"
}

empile()
{
  maPile="$1 ${maPile}"
}

depile(){
  last=""
  set -- $maPile
  last="$last ${1-}"
  shift $((!!$#))
  maPile="$@"
}

realNum(){
  if [[ $v =~ ^[+-]?[0-9]+([.][0-9]+)?$ ]]
  then
    return 0
  else
    return 1
  fi
}

operateur(){
  if [[ $v == "+" ]] || [[ $v == "-" ]] || [[ $v == "*" ]] || [[ $v == "/" ]]
  then
    depile; var2=$last; depile; var1=$last
    echo "var1 $var1 var2 $var2"
    case $v in
      +) empile $(php -r "echo $var1+$var2;");;
      -) empile $(php -r "echo $var1-$var2;");;
      *) empile $(php -r "echo $var1*$var2;");;
      /) empile $(php -r "echo $var1/$var2;");;
    esac
  elif [[ $v == "cos" ]] || [[ $v == "sin" ]] || [[ $v == "tan" ]] || [[ $v == "sqrt" ]]
  then
    depile
    echo "var3 $last"
    case $v in
      cos) empile $(php -r "echo cos($last);");;
      sin) empile $(php -r "echo sin($last);");;
      tan) empile $(php -r "echo tan($last);");;
      sqrt) empile $(php -r "echo sqrt($last);");;
    esac
  elif [[ $v == "sup" ]]
  then
    depile; memo=$last
  elif [[ $v == "back" ]] ||  [[ -z "$memo" ]]
  then
    empile $memo
    memo=""
  else
    echo "nombre/operateur non traité..."
  fi
}


# ------ PRINCIPAL ------ #
maPile=""
test=0
while [[ $test -eq 0 ]]
do
  echo -n "> "
  read v
  if [[ $v != "stop" ]]
  then
    realNum
    if [[ $? -eq 0 ]]
    then
      empile $v
    else
      operateur
    fi
    affichePile
  else
    test=1
  fi
done
