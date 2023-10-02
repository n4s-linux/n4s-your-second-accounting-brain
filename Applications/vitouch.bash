f=$(bash /svn/svnroot/Applications/findwindow.bash "$1")
if [ "$f" == "found" ]; then
	# der er allerede et åbent vindue - vi quitter 
	echo "found already open"
	exit
fi

if [ "$tpath" == "" ]; then
	tpath=~/regnskaber/stuff
fi

function update_title {                                                                                                                                                                                                                              
export TMUX_PANE_TITLE="$1"
echo "$1" > ~/tmp/oldtitle
 printf "\033]2;%s\033\\" "${1:-$TMUX_PANE_TITLE}"; }

update_title "vitouch"

start=$(date +%s)
mkdir -p ~/tmp
source /svn/svnroot/Applications/difffile.bash
tmux set-option status-right "#[fg=black,bg=white] %Y-%d-%m #[fg=colour233,bg=colour8] $1 $2 $3 $hjerter"
function getbg() {
	if [[ "$tpath" == *"crm"* ]]; then
	echo "red"
	elif [[ "$tpath" == *"login"* ]]; then
	echo "purple"
	else
	echo "green"
	fi
}
function vitouch() {
        bn="$(basename "$1")"
	update_title "$bn"
	if [ "$notitle" == "" ]; then
		shortbn="${bn:0:6}" #credits #chatgpt
		bg=$(getbg $shortbn)
		tmux rename-window "#[fg=$bg]$shortbn"
	fi
	bnt="$(basename "$tpath")"
	lockfile="$tpath/.tags/.$bn"".lock"
	if  [ -f "$lockfile" ]; then
		openedby=$(cat "$lockfile")
		if [ "$openedby" == "$(whoami)" ]; then
			cut=$(echo "$bn"|cut -c1-4)
			tmux run-shell bash /svn/svnroot/Applications/findwindow.bash "$cut"
			whiptail --msgbox "$openedby har åbnet denne fil, tryk enter for at afslutte" 10 40
		else
			whiptail --msgbox "$openedby har åbnet denne fil, tryk enter for at afslutte" 10 40
		fi
		echo exitexit
		exit
	fi
	cmd="fn="$1" bn="$bn" tpath="$tpath" vitouch "$1" "$2" "$3" "$4""
	mkdir -p ~/tmp/vitouch/
	fn="$bnt"_"$bn"
	(
	echo "#/bin/bash"
	echo "source /svn/svnroot/Applications/vitouch.bash"
	echo "$cmd" ) > ~/tmp/vitouch/"$fn"
	uuid=$(uuidgen|cut -c1-5)
        tmpf="$tpath/.tmpdiff_$uuid"
        touch "$1"
        bn=$(basename "$1")
	echo -e "\t$(date +'%Y-%m-%d %H:%m'):\tOpened" >> "$1.diff"
        cp "$1" "$tpath/.$bn.bak.$uuid"
	whoami > "$lockfile"
	time=$(date +%Y-%m-%dT%H%M)
	if [ "$DISPLAY" == "" ]; then
		cmd=vim
	else
		cmd="gvim -f" # - er lidt forvirrende når man blander gui og console
	fi
	cmd=vim
	sf="$1.scrabble"
	if [ -f "$sf" ]; then
		cat "$1" > ~/tmp/scrabblemerge_$uuid
		cat "$sf"|while read i
		do
			echo -ne "\t$i #scrabble\n">> ~/tmp/scrabblemerge_$uuid
		done
		cp ~/tmp/scrabblemerge_$uuid "$1"
		mkdir -p $tpath/.scrabbles
		mv "$sf" $tpath/.scrabbles/$uuid
	fi
       	$cmd "$1" "$2" "$3"  -c "set ft=md"
	rm "$tpath/.tags/.$bn"".lock"
	if=~/tmp/if.md
	cat $tpath/.tags/header "$1" $tpath/.tags/footer > $if




	print=yes	
	jn=$(echo -e "Nej\nJa"|fzf --header="Vil du printe")
	if [ "$jn" != "Ja" ]; then
		print=no
	fi
	if [ "$print" == "yes" ]; then
	jn=$(echo -e "Nej\nJa"|fzf --header="Skal vi fjerne færdige opgaver ?")
	if [ "$jn" == "Ja" ]; then
		grep -v "✔" $if > "$if.notdone"
		grep "✔" $if|awk -F✔ '{print $1}'|awk -F '\t' '{$1=""}1'|cut -c 23- |sed 's/?//g' |sed 's/^ *//;s/ *$//'> "$if.done"
	fi
	fi
	cp "$if.notdone" $if
	rm "$if.notdone"
	runpath="$1" php "$if" > "$if.parsed"
	cp "$if.parsed" "$if"
	rm "$if.parsed"
	cp "$if" ~/tmp/if.tmp # 2023-04-05T18:21 joo	can we remove this ? #isitbeingused ?
# Diffile
        difffile "$tpath/.$bn.bak.$uuid" "$1"  >> "$tmpf" #vigtigt det her skal ske før fzf
	cat "$tmpf"
	echo "tmpf=$tmpf"
	rm "$tpath/.$bn.bak.$uuid" 2>/dev/null
        cat "$tmpf" >> "$1.diff"
	echo -n $(whoami) $(date)" " >> /data/regnskaber/.log
	cat "$tmpf"|while read line
	do
		echo -n $(whoami) $(date) "( $bnt -  $bn) " >> /data/regnskaber/.log
		echo $line >> /data/regnskaber/.log
	done
# Fzf udskrift 
	if [ "$print" != "yes" ]; then
		echo exiting no print
		exit
	fi
	bash /svn/svnroot/Applications/mkd.bash "$if" select > ~/tmp/if.selected.$uuid; 
	cp ~/tmp/if.selected.$uuid "$if"
	rm ~/tmp/if.selected.$uuid
	template=/svn/svnroot/Applications/github.html5
	jn=j
	if [ "$jn" == "j" ]; then
		toc=j
		if [ "$toc" == "j" ]; then
			toc="--toc"
		else
			toc=""
		fi
		num=Nummeret
		date=$(date +%Y-%m-%d)
		cp "$if" ~/n4s-export/current.md

		#(clear;glow ~/n4s-export/current.md -p)
		if [ "$print" == "yes" ]; then
			pandoc -H /svn/svnroot/Applications/listing.tex --listings -s -o ~/n4s-export/"$bn"-$date.pdf "$if" -f markdown+hard_line_breaks -V geometry:landscape -V papersize:a4  -V geometry:margin=.8in -V toc-title:"$bn"  -N $toc --pdf-engine=xelatex --wrap=auto +RTS -K100000000
			pandoc -s -o ~/n4s-export/"$bn"-$date.html "$if" -f markdown+hard_line_breaks -V geometry:landscape -V papersize:a4  -V geometry:margin=.8in -V toc-title:"$bn"  -N $toc --pdf-engine=xelatex --wrap=auto +RTS -K100000000
		fi
		#(clear;glow ~/n4s-export/current.md -p)
		# if it is not crm
		if [[ ":$fn:" == *"crm"* ]]; then
			suffix=_crm
		else
			suffix=
		fi
		end=$(date +%s)
		min=$(echo "scale=2;($end-$start)/60/60"|bc -l)
		ts=$(date "+%Y-%m-%dT%H:%M")
		mkdir -p /data/regnskaber
		echo -e "$ts\t#$bn\t$min" >> /data/regnskaber/stats/$(whoami)$suffix.stats
	else
		exit
	fi
	mkdir -p ~/n4s-export/
	cd ~/n4s-export
	
	date=$(date +%Y-%m-%d)
	update_title "$(cat ~/tmp/oldtitle)"
	lynx -dump ~/n4s-export/"$bn"-$date.html
	exit

}
