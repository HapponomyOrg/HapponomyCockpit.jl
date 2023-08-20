module Overshoot

using Mongoc

pw = ""
uri = "mongodb+srv://stef:" * pw * "@happonomycluster.rftavk7.mongodb.net/?retryWrites=true&w=majority"
suffix = "&tlsCAFile=/usr/local/etc/openssl/cert.pem" # Probably needs to change when deployed on a server.

client = Mongoc.Client(uri * suffix)
db = client["overshoot_data"]
collection = db["_world_data"]

function add_overshoot_date(date)

end

end