redo-ifchange ../neobem.md template.tex ../../idf-plus/kde-syntax/neobem.xml ../out.ps
pandoc -V theme=metropolis -V themeoptions:subsectionpage=progressbar -V themeoptions:progressbar=foot  -o "$3" --standalone --syntax-definition=../../idf-plus/kde-syntax/neobem.xml --incremental -t beamer --template=template.tex ../neobem.md
