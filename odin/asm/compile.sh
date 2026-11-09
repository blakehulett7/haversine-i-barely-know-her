NAME=$1

clang -c src/$NAME.asm -o obj/$NAME.o &&
    ar rcs lib/$NAME.a obj/$NAME.o
