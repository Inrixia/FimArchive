#! /bin/bash

#       Get the first page that lists your favorite stories
curl --cookie "view_mature=true" "https://www.fimfiction.net/bookshelf/913771/moving-shorts" 2>/dev/null 1>./Favorites-003.html;

#       use a sequence of commands to extrapolate how many pages are used to
#               list all your favorite stories. Then set this value to a variable.
MAX=$(cat Favorites-003.html | grep -E -o "&amp;page=[0-9]+" | sed -r -e 's/&amp;page=(.*)/\1/g' | sort -n | tail -n 1);

#       Prepare Loop Variable
let iteration=1;

#       Prepare First script by adding the 'shebang             interpreter' line
echo -e "#!\t/bin/bash" >> gen_story_script3.sh;

#       This loop creates the gen_story_script3, which itself creates the story_script3,
#               which downloads all the stories
while [ "$iteration" -le  "$MAX" ]; do
        echo "curl --cookie \"view_mature=true\" \"https://www.fimfiction.net/bookshelf/913771/moving-shorts?order=date_added&page=$iteration\" 2>/dev/null | grep -E -o \"story_[0-9]+\" | sed -r -e 's/story_(.*)/cd txt \&\& wget --content-disposition \"http:\/\/www.fimfiction.net\/download_story.php?story=\1\" \&\& cd ..\/\ncd epub \&\& wget --content-disposition \"http:\/\/www.fimfiction.net\/download_epub.php?story=\1\" \&\& cd ..\//g' >> story_script3.sh" >> gen_story_script3.sh;
        let iteration=$iteration+1;
done

#       Prepare Second script by adding the 'shebang    interpreter' line
echo -e "#!\t/bin/bash" >> story_script3.sh;

#       Make First script executable
chmod 755 gen_story_script3.sh;

#       Execute it
./gen_story_script3.sh;

#       Make Second script executable
chmod 755 story_script3.sh;

#       Make and change directory so we don't litter the current working directory
#               with stories
mkdir MovingShorts;
mkdir MovingShorts/epub;
mkdir MovingShorts/txt;
cd MovingShorts;

#       Execute the final script
../story_script3.sh;

rm ../story_script3.sh
rm ../gen_story_script3.sh
rm ../Favorites-003.html
#       I always put the "wait" at the end of all my scripts, because it forces bash
#               to execute the steps of this script in order. If you don't put the "wait"
#               then bash may try to do things in parallel to be more efficient, which can
#               really fuck shit up if your script has steps that need to be run IN ORDER
wait;
