# autogarbo
 
A KoLmafia script that runs my daily [garbo](https://github.com/loathers/garbage-collector) turns and then the realms: CyberRealm, FantasyRealm, LT&T and PirateRealm. Garbo leaves enough turns unspent for whichever realms you pick.
 
## Usage
 
```
autogarbo <args>
```
 
| Argument | What it does |
| --- | --- |
| `full` | Normal run with all realms (also the default with no arguments) |
| `ascend` | Runs garbo in ascend mode |
| `realms=ltt,fr,pr,cr` | Runs only the selected realms |
| `ltt=0\|1000\|10000` | Meat to spend on LT&T telegrams (saved to `ltt_maxSpend`) |
| `returnstash` | Only returns borrowed clan stash items |
| `help` | Shows the help list |
 
Examples:
 
```
autogarbo
autogarbo realms=fr,pr
autogarbo ltt=1000 full
```
 
## What it does
 
1. Runs breakfast plus a few extra dailies
2. Borrows items from the clan stash
3. Runs ChibiBuddy
4. Runs garbo, leaving turns for the selected realms
5. Runs each selected realm
6. Returns the stash items and prints a report

## Requirements - DO NOT RUN THIS OTB, currently not meant for public use, use at your own risk etc etc
 
- [garbo](https://github.com/loathers/garbage-collector)
- All of the following needs to be accounted for in some way:
- I have modified versions of all of the Ezandora realm scripts, though the originals might work. You just won't use your turns to their fullest potential
- I also call the telegram script for LT&T, and store_mall_data which are public scripts
- interjector and skelestore are my scripts, a version of interjector is available on github but so far skelestore is not
- I have an outfit called `Cyberrealm`, and two custom combat scripts called `cyberrealm` and `dumpturns`
- The clan names are hardcoded at the top of `autogarbo.ash` and use fuzzy matching. Change them to your own

 
```ash
string stash_clan = "free";
string social_clan = "cool";
```
 
