redo-ifchange neobem.md
pandoc --syntax-definition=../idf-plus/kde-syntax/neobem.xml --incremental -t revealjs neobem.md
