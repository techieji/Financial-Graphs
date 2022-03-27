import requests

# Blue Alliance simple API
class Session:
    def __init__(self, key):
        self.key = key
    
    def get_endpoint(self, endpoint):
        return requests.get("https://www.thebluealliance.com/api/v3" + endpoint, {'X-TBA-Auth-Key': self.key}).json()

def filtermean(f):
    l = 0
    s = 0
    for x in f:
        l += 1
        s += x
    return s / l
