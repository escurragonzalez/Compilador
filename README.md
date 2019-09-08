# UNLaM TP Lenguajes y Compiladores
#### Building 

```sh
$ cd "Compilador/Compilador"
$ bison -dyv -t Sintactico.y
$ flex Lexico.l
$ gcc y.tab.c lex.yy.c -o Primera
$ Primera Prueba.txt 
```
