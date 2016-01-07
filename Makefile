input/Tweets.csv:
	mkdir -p input
	curl http://cdn2.hubspot.net/hub/346378/file-2545951097-csv/DFE_CSVs/Airline-Sentiment-2-w-AA.csv -o input/Tweets.csv
input: input/Tweets.csv

output/Tweets.csv: input/Tweets.csv
	mkdir -p working
	mkdir -p output
	python src/process.py
csv: output/Tweets.csv

working/noHeader/Tweets.csv: output/Tweets.csv
	mkdir -p working/noHeader
	tail +2 $^ > $@

output/database.sqlite: working/noHeader/Tweets.csv
	-rm output/database.sqlite
	sqlite3 -echo $@ < working/import.sql
db: output/database.sqlite

output/hashes.txt: output/database.sqlite
	-rm output/hashes.txt
	echo "Current git commit:" >> output/hashes.txt
	git rev-parse HEAD >> output/hashes.txt
	echo "\nCurrent input/ouput md5 hashes:" >> output/hashes.txt
	md5 output/*.csv >> output/hashes.txt
	md5 output/*.sqlite >> output/hashes.txt
	md5 input/*.csv >> output/hashes.txt
hashes: output/hashes.txt

release: output/database.sqlite output/hashes.txt
	zip -r -X output/airline-twitter-sentiment-release-`date -u +'%Y-%m-%d-%H-%M-%S'` output/*

all: csv db hashes release

clean:
	rm -rf working
	rm -rf output
