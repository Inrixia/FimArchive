#! /bin/bash


#       User & Pass variables inserted & formated to POST-data variable
POSTDATA_ONE="referrer=http%3A%2F%2Fwww.fimfiction.net%2F&username=Inrix&password=Everyth!ng@sSp#nn$ng&keep_logged_in=1";


#       Login to fimfiction.net to authenticate (using our POST-data variable)
#               and create the cookie file that will hold our session information
#curl -c "./cookiejar.txt" -d "username=Inrix&password=Everyth%21ng%40sSp%23nn%24ng&view_mature=true" "http://www.fimfiction.net/ajax/login" 2>/dev/null 1>./ajax_return.txt;


#       Edit session information so fimfiction will show us the "mature" stories too
#               To-do: Create a conditional that prompts for user input, to make this step optional
#tail -n 1 "./cookiejar.txt"  | sed -r -e 's/session_token.*/view_mature\true/g' >> "./cookiejar.txt";


#       Get the first page that lists your favorite stories
curl --cookie "view_mature=true" "https://www.fimfiction.net/bookshelf/45185/true-favourites" 2>/dev/null 1>./Favorites-001.html;


#       use a sequence of commands to extrapolate how many pages are used to 
#               list all your favorite stories. Then set this value to a variable.
MAX=$(cat Favorites-001.html | grep -E -o "&amp;page=[0-9]+" | sed -r -e 's/&amp;page=(.*)/\1/g' | sort -n | tail -n 1);


#       Prepare Loop Variable
let iteration=1;


#       Prepare First script by adding the 'shebang             interpreter' line
echo -e "#!\t/bin/bash" >> gen_story_script.sh;


#       This loop creates the gen_story_script, which itself creates the story_script,
#               which downloads all the stories
while [ "$iteration" -le  "$MAX" ]; do 
        echo "curl --cookie \"view_mature=true\" \"https://www.fimfiction.net/bookshelf/45185/true-favourites?order=date_added&page=$iteration\" 2>/dev/null | grep -E -o \"story_[0-9]+\" | sed -r -e 's/story_(.*)/cd txt \&\& wget --content-disposition \"http:\/\/www.fimfiction.net\/download_story.php?story=\1\" \&\& cd ..\/\ncd html \&\& wget --content-disposition \"http:\/\/www.fimfiction.net\/download_story.php?story=\1\&html\" \&\& cd ..\/\ncd epub \&\& wget --content-disposition \"http:\/\/www.fimfiction.net\/download_epub.php?story=\1\" \&\& cd ..\//g' >> story_script.sh" >> gen_story_script.sh;
        let iteration=$iteration+1;
done


#       Prepare Second script by adding the 'shebang    interpreter' line
echo -e "#!\t/bin/bash" >> story_script.sh;


#       Make First script executable
chmod 755 gen_story_script.sh;


#       Execute it
./gen_story_script.sh;


#       Make Second script executable
chmod 755 story_script.sh;


#       Make and change directory so we don't litter the current working directory
#               with stories
mkdir stories;
mkdir stories/html;
mkdir stories/epub;
mkdir stories/txt;
cd stories;


#       Execute the final script
../story_script.sh;


#       I always put the "wait" at the end of all my scripts, because it forces bash
#               to execute the steps of this script in order. If you don't put the "wait"
#               then bash may try to do things in parallel to be more efficient, which can
#               really fuck shit up if your script has steps that need to be run IN ORDER
wait;