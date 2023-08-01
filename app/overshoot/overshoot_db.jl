module Overshoot

using Mongoc

pw = "M2fBeDJwHkJ0Uv4r"
uri = "mongodb+srv://stef:M2fBeDJwHkJ0Uv4r@happonomycluster.rftavk7.mongodb.net/?retryWrites=true&w=majority"
suffix = "&tlsCAFile=/usr/local/etc/openssl/cert.pem" # Probably needs to change when deployed on a server.

client = MongoClient(uri * suffix)
db = client["overshoot_data"]
collection = db["_world_data"]

function add_overshoot_date(date)

end

end