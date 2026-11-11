NAME=$1

clang -c src/$NAME.asm -march=armv9.2-a+sme -o obj/$NAME.o &&
    ar rcs lib/$NAME.a obj/$NAME.o
