import pandas as pd

data = pd.read_csv("input/Tweets.csv")
data.columns = [col.replace(":", "_") for col in data.columns]

columns_to_keep = ["tweet_id"] + [col for col in data.columns if col[0]!="_" and col!="tweet_id"]

data = data[columns_to_keep]

conversion = {
    "object": "TEXT",
    "float64": "NUMERIC",
    "int64": "INTEGER"
}

sql = """.separator ","

CREATE TABLE Tweets (
%s);

.import "working/noHeader/Tweets.csv" Tweets
""" % ",\n".join(["    %s %s%s" % (key,
                                   conversion[str(data.dtypes[key])],
                                   " PRIMARY KEY" if key=="tweet_id" else "")
                  for key in data.dtypes.keys()])

data.to_csv("output/Tweets.csv", index=False)

open("working/import.sql", "w").write(sql)
