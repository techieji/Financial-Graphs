import matplotlib.pyplot as plt
from lib import *
import itertools as it

s = Session("***********")

def extract_teams(e):
  return e["alliances"]['blue']['team_keys'] + e['alliances']['red']['team_keys']

# DC326
d = s.get_endpoint('/event/2022dc326/matches')

## Win rate
def didxwin(t):
    def inner(e):
        if t in e['alliances']['blue']['team_keys']:
            return e['winning_alliance'] == 'blue'
        elif t in e['alliances']['red']['team_keys']:
            return e['winning_alliance'] == 'red'
        return 2
    return inner
  
def analyze(t):
    return filtermean(filter(lambda x: x != 2, map(didxwin(t), d)))

teams = set(it.chain.from_iterable(map(extract_teams, d)))
newteams = sorted(teams, key = dict(zip(teams, map(analyze, teams))).get)

plt.bar(newteams, list(map(analyze, newteams)), color = ['r' if x == 'frc5549' else 'b' for x in newteams])
plt.xticks(rotation=90)
plt.title("Comparison of Win Rate at DC326")
plt.xlabel("Team")
plt.ylabel("Win Rate (%)")
plt.savefig("D:\\Documents\\Pradhyum\\Academics\\robotics\\win-rate.png")
plt.show()
