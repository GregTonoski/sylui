#!/usr/bin/env sh

# EXAMPLES:
# sh sylui.sh duboli kufuzu naleqy lyfety dohihy rutoqa rageli kilyly vetyka himujy teluzi fuoda va
# sh sylui.sh 0xC85AFBACCF3E1EE40BDCD721A9AD1341344775D51840EFC0511E0182AE92F78E
# sh sylui.sh -f sylui duboli kufuzu naleqy lyfety dohihy rutoqa rageli kilyly vetyka himujy teluzi fuoda va
# sh sylui.sh -f hex C85AFBACCF3E1EE40BDCD721A9AD1341344775D51840EFC0511E0182AE92F78E

#default radix is 126, because of latin script
VOWEL0=A
VOWEL1=E
VOWEL2=I
VOWEL3=O
VOWEL4=U
VOWEL5=Y

CONSONANT0=B
CONSONANT1=C
CONSONANT2=D
CONSONANT3=F
CONSONANT4=G
CONSONANT5=H
CONSONANT6=J
CONSONANT7=K
CONSONANT8=L
CONSONANT9=M
CONSONANT10=N
CONSONANT11=P
CONSONANT12=Q
CONSONANT13=R
CONSONANT14=S
CONSONANT15=T
CONSONANT16=V
CONSONANT17=W
CONSONANT18=X
CONSONANT19=Z

# RADIX126_DIGIT0="A"
# RADIX126_DIGIT1="B"
# ...
# RADIX126_DIGIT125="ZY"

i=0
v=0
letter=""
vowels_set=""

# Building an array of numerical digits of the radix (digits map) - part 1: single vowels
while eval [ \"\${VOWEL$v}\" ] ; do
  eval radix126_digit${i}=\"\${VOWEL${v}}\" # e.g. radix126_digit0="${VOWEL0}" where VOWEL0 is defined as A above
  eval letter=\"\${VOWEL${v}}\" # letter="$(VOWEL0}
  eval VOWEL_"${letter}"="${v}" # e.g. VOWEL_A=0
  vowels_set="${vowels_set}""${letter}"
  v=$(( ${v} + 1 ))
  i=$(( ${i} + 1 ))
done
vowels_count=${v}

c=0
v=0
consonants_set=""

# Building an array of numerical digits of the radix (digits map) - part 2: pair of consonants and vowels
while eval [ \"\${CONSONANT$c}\" ] ; do
  while eval [ \$VOWEL$v ] ; do
    eval radix126_digit${i}=\"\${CONSONANT${c}}\"\"\${VOWEL${v}}\"
    i=$(( ${i} + 1 ))
    v=$(( ${v} + 1 ))
  done
  eval letter=\"\${CONSONANT${c}}\" # letter="$(CONSONANT0}
  eval CONSONANT_"${letter}"'=$(( '"${c}"' + 1 ))' # CONSONANT_B=1
  consonants_set="${consonants_set}""${letter}"
  v=0
  c=$(( ${c} + 1 ))
done
radix_of_sylui=${i}

fn_purge_of_whitespaces () {
  line_of_text="${*}"
  line_of_text="${line_of_text#${line_of_text%%[![:space:]]*}}" line_of_text="${line_of_text%${line_of_text##*[![:space:]]}}"
  while [ "${line_of_text#*[[:space:]]}" != "${line_of_text}" ] ; do
    line_of_text="${line_of_text%%[[:space:]]*}""${line_of_text#*[[:space:]]}"
  done
  printf "%s" "${line_of_text}"
}

fn_validate_user_input () {
  input_string="${*}"
  case "${input_string}" in
#    --help | -h ) fn_show_helptext ; exit 0 ;;
#    --version | -v ) fn_show_version ; exit 0 ;;
    *[![:xdigit:][:alpha:][:space:]-=]* ) echo "ERROR. There was a non-alphanumeric character entered." >&2 ; exit 1;;
    *-?*-* ) echo "ERROR. There were more than one options (dash character \"-\") entered." >&2 ; exit 1;;
    "${input_string##*[![:space:]]*}" | - ) return 0 ;;
    "--from=hex"* | "-f hex"* ) opt_from="hex" priv_key="${input_string#*-f*[[:space:]=]*hex}" ;;
    *"--from=hex" | *"-f hex" ) opt_from="hex" priv_key="${input_string%[[:space:]]-f*[[:space:]=]*hex}" ;;
    "--from=sylui"* | "-f sylui"* ) opt_from="sylui" priv_key="${input_string#*-f*[[:space:]=]*sylui}" ;;
    *"--from=sylui" | *"-f sylui" ) opt_from="sylui" priv_key="${input_string%[[:space:]]-f*[[:space:]=]*sylui}" ;;
    "--from=dec"* | "-f dec"* ) opt_from="dec" priv_key="${input_string#*-f*[[:space:]=]*dec}" ;;
    *"--from=dec" | *"-f dec" ) opt_from="dec" priv_key="${input_string%[[:space:]]-f*[[:space:]=]*dec}" ;;
    *-[![:space:]]* ) echo "ERROR. Unrecognized or misplaced option was entered." >&2 ; exit 1 ;;
    0[xX]?* ) opt_from="hex" priv_key="${input_string#0[xX]}" ;;
    0?* ) echo "ERROR. Octal numerals not supported in this version." >&2 ; exit 1 ;;
    "${input_string##*[![:digit:][:space:]]*}" ) opt_from="dec" priv_key="${input_string}" ;;
    "${input_string##*[![:alpha:][:space:]]*}" ) opt_from="sylui" priv_key="${input_string}" ;;
    * ) echo "ERROR. Invalid format of user input. An option may have not been entered." >&2 ; exit 1 ;;
  esac
  if [ "${opt_from:-hex}" = "hex" ] ; then
    priv_key="${priv_key#${priv_key%%[![:space:]]*}}"
    priv_key="${priv_key#0[xX]}"
    case "${priv_key}" in
      *[![:xdigit:][:space:]]* ) echo "ERROR. There was a non-hexadecimal digit character entered." >&2 ; exit 1;;
      * ) ;;
    esac
  elif [ "${opt_from}" = "dec" ] ; then
    case "${priv_key}" in
      *[![:digit:][:space:]]* ) echo "ERROR. There was a non-decimal digit character entered." >&2 ; exit 1;;
      * ) ;;
    esac
  elif [ "${opt_from}" = "sylui" ] ; then
    case "${priv_key}" in
      *[![:alpha:][:space:]]* ) echo "ERROR. There was a non-latin letter entered." >&2 ; exit 1;;
      * ) ;;
    esac
  fi
}

fn_to_uppercase () {
  ascii_value=0
  substring_of_non_lowercase_chars="${1%%${1#[![:lower:]]}}"
  substring_with_lowercase_chars="${1#${substring_of_non_lowercase_chars}}"
  chars_separated_with_spaces=""
  while [ "${substring_with_lowercase_chars}" ] ; do
    chars_separated_with_spaces="${chars_separated_with_spaces}""\'""${substring_with_lowercase_chars%%${substring_with_lowercase_chars#?}} "
    substring_with_lowercase_chars="${substring_with_lowercase_chars#?}"
  done
  eval set -- ${chars_separated_with_spaces}
  set -- $(printf "%d " "${@}" )
  while [ "${1}" ] ; do
    if [ "${1}" -ge 97 ] && [ "${1}" -le 122 ] ; then # if lower case then change to upper case
      string_dec="${string_dec}"" "$(( ${1} - 32 ))
    else
      string_dec="${string_dec}"" ""${1}"
    fi
  shift 1
  done
  eval set -- ${string_dec}
  set -- $( printf "\\%03o" "${@}" )
  printf "%s" "${substring_of_non_lowercase_chars}"
  printf "${*}"
}

fn_hex_to_dec_factors_separated_by_space () { # parameter: continuous/non-separated string of hex digits/nibbles; output example: 255 51 1 0 16
  string="${*}"
  while [ "${string}" ] ; do
    string_delimited=" ""0x""${string##${string%?}}""${string_delimited}"
    string="${string%?}"
  done
  eval set -- ${string_delimited}
  printf "%d " "${@}"
}

fn_dec_to_dec_factors_separated_by_space() { # parameters: continuous/non-separated string of decimal digits; output example: 255 51 1 0 16
  string="${*}"
  while [ "${string}" ] ; do
    string_delimited=" ""${string##${string%?}}""${string_delimited}"
    string="${string%?}"
  done
  set -- ${string_delimited}
  printf "%d " "${@}"
}

fn_convert_base_of_numeral () { # parameters: ibase, obase, dividend in space separated string of decimal values format
  ibase="${1}"
  obase="${2}"
  shift 2
  eval set -- "${@}"
  while [ "${1}" ] ; do
    quotient=""
    remainder=0
    while [ "${1}" ] ; do
      quotient_digit=$(( ( ${remainder} * ${ibase} + ${1} ) / ${obase} ))
      quotient="${quotient}"" ""${quotient_digit}"
      remainder=$(( ( ${remainder} * ${ibase} + ${1} ) % ${obase} ))
      shift 1
    done
    result="${remainder}"" ""${result}"
    while [ "${quotient#[[:space:]]0}" != "${quotient}" ] ; do # delete leading zeros
        quotient="${quotient#[[:space:]]0}"
      done
    eval set -- ${quotient}
  done
  set -- $( printf "%s " ${result} )
  printf "%d " "${@}" # e.g. 111 55 1 0 99
}


### Beginning of execution

input_string=""

if fn_validate_user_input "${*}" ; then
  if [ -z "${priv_key}" ] ; then
    printf "Enter a number in decimal, hexadecimal or sylui numeral:\n"
    read user_input_string
    fn_validate_user_input "${user_input_string}"
    if [ -z "${priv_key}" ] ; then
      printf "ERROR. There wasn't anything read from user input.\n" >&2
      exit 1
    fi
  fi
fi
priv_key=$( fn_purge_of_whitespaces "${priv_key}" )
if ! [ "${priv_key##*[[:lower:]]*}" ] ; then
  priv_key=$( fn_to_uppercase ${priv_key} )
fi

dec_factors_separated_by_space=""
if [ "${opt_from}" = "sylui" ] ; then
  set -- ${priv_key}
  prev_elem=0
  character=""
  dec_factors_separated_by_space=""
  augend=""
  while [ "${1}" ] ; do
    character="${1%%${1#?}}"
    case "${character}" in
      ["${vowels_set}"] ) eval dec_factors_separated_by_space=\"\${dec_factors_separated_by_space}\"\" \"'$(( ( ${augend} + ${VOWEL_'"${character}"'} ) ))' ; augend="" ;; # e.g. dec_factors_separated_by_space="${dec_factors_separated_by_space}"" "$(( ${augend} + "${VOWEL_A}" ))
      ["${consonants_set}"]) if [ ! "${augend}" ] ; then
          eval 'augend=$(( ( ${CONSONANT_'"${character}"'} ) * '"${vowels_count}"' ))' # e.g. augend=$(( ( "${CONSONANT_B} ) * "${vowels_count}"
        else
          echo "ERROR. There was incorrect SylUI code entered." >&2 ; return 1
        fi
      ;;
      *) echo "ERROR." >&2 ; return 2 ;;
    esac
    set -- "${1#?}"
  done
  if [ "${augend}" ] ; then echo "ERROR. There was incorrect SylUI code entered." >&2 ; return 1 ; fi
  set -- $( fn_convert_base_of_numeral ${radix_of_sylui} 16 ${dec_factors_separated_by_space} )
elif [ "${opt_from}" = "hex" ] ; then
  dec_factors_separated_by_space=$( fn_hex_to_dec_factors_separated_by_space "${priv_key}" )
  set -- $( fn_convert_base_of_numeral 16 ${radix_of_sylui} ${dec_factors_separated_by_space} )
elif [ "${opt_from}" = "dec" ] ; then
  dec_factors_separated_by_space=$( fn_dec_to_dec_factors_separated_by_space "${priv_key}" )
  set -- $( fn_convert_base_of_numeral 10 ${radix_of_sylui} ${dec_factors_separated_by_space} )
fi

### Format output text of the result number and display it to user/stdout
chars_count=0
sylui_code=""
if [ "${opt_from}" = "sylui" ] ; then
  printf "0x"
  printf "%X" "${@}"
elif [ "${opt_from}" = "hex" ] || [ "${opt_from}" = "dec" ] ; then # e.g. 125 0 15 33
  while [ "${1}" ] ; do
    eval sylui_code=\"\${sylui_code}\"\" \"\"\${radix126_digit"${1}"}\" # e.g. sylui_code="${sylui_code}"" ""${radix126_digit93}"
    eval chars_count='$(( ${chars_count} + ${#radix126_digit'"${1}"'} ))'
    shift 1
  done
  set -- ${sylui_code}
  printf "%s%s%s " "${@}"
  printf "\t (%d printable characters)." ${chars_count}
fi
printf "\n"
