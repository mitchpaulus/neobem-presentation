redo-ifchange neobem.tex
mkdir -p build
xelatex -halt-on-error -output-directory=build neobem.tex >&2
cp build/neobem.pdf "$3"
