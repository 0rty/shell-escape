# Challenge 01 - Command Chaining

## Contexte
An admin built a little tool to ping IP address from his server.
He blocked some command like `|` and `&` to avoid injection, but did he forget something ?

## Goal

Read the content of `/flag.txt`.

## Start the challenge

```bash
docker build -t chall01 .
docker run -it --rm chall01
```

## Hint 1

<details>
<summary>Hint</summary>
Find other way to chain commands
</details>

## Hint 2

<details>
<summary>Hint</summary>
What does the char `;` or `\n` ?
</details>

## Flag format

`HackUTT{...}`
