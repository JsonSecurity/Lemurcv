# LemurAI
Lemurcv is a script that converts image recognition with the resolution forms. Lemur checks the pictures in a certain folder and then processes them (extracts the questions and solves them).

<img src="https://github.com/JsonSecurity/Images/blob/main/scripts/lemur.png" />

### Video

1h of Shell programming:

[![Youtube](https://img.shields.io/badge/▶-Lemurcv-red)](https://youtu.be/jcQ3SISpnVE?si=zpNbMNryTcdibZq8)
![shell](https://img.shields.io/badge/shell-green)

### Install

It is only necessary to clone the repository and get the api.

```
git clone https://github.com/jsonsecurity/Lemurcv.git
```

```
cd Lemurcv
```

### Api

- Generate your api in [google.dev](https://ai.google.dev/)
- Save your apikey in the `.APIKEY` file in the same folder as the script.

```
nano .APIKEY
```

### Test

```
./lemurcv.sh
```

```
[!] Usage:

 ./lemurcv.sh -p <text>     # promt opticai *
 ./lemurcv.sh -g <text>     # promt gemini

 ./lemurcv.sh -d <path>     # dir images *
 ./lemurcv.sh -l            # loop mode
```
