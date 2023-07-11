#!/bin/bash

if [[ $# -eq 2 ]]; then
    totalMemSize=$1
    blockSize=$2
elif [[ $# -eq 1 ]]; then
    if [[ $1 == "help" ]]; then
        echo "sim-cache.sh TAM_MEMORIA TAM_BLOCO"
    fi
    exit 0
else
    echo -n "Informe o tamanho da cache em KB: "
    read totalMemSize
    echo -n "Informe o tamanho dos blocos (em B): "
    read blockSize
fi

((nsets=$totalMemSize/$blockSize))
((nsets=$nsets*1024))

echo -n "Associatividade: "
read assoc

if [[ $assoc == "t" ]]; then
    assoc=$nsets
    nsets=1
else
    ((nsets=$nsets/$assoc))
fi

echo -n "Política de substituição: "
read repl

echo "Benchmark: "
echo "1 - GO_1"
echo "2 - LI_2"

read c

case $c in
    1)
bench="Benchmarks/go/go.ss 50 9 Benchmarks/go/2stone9.in" ;;
    2)
bench="Benchmarks/li/li.ss Benchmarks/li/queen6.lsp" ;;
    *)
echo "Invalido!" ;;
esac

# Executa o benchmark e salva num arquivo o output
./sim-cache -cache:il1 il1:$nsets:$blockSize:$assoc:$repl -cache:il2 none -cache:dl1 dl1:$nsets:$blockSize:$assoc:$repl -cache:dl2 none -tlb:itlb none -tlb:dtlb none $bench 2> ../benchData.txt

grep "sim_num_insn" ../benchData.txt > ../benchProcessed.txt
grep "sim_num_refs" ../benchData.txt >> ../benchProcessed.txt
grep "il1.misses" ../benchData.txt >> ../benchProcessed.txt
grep "il1.miss_rate" ../benchData.txt >> ../benchProcessed.txt
grep "dl1.misses" ../benchData.txt >> ../benchProcessed.txt
grep "dl1.miss_rate" ../benchData.txt >> ../benchProcessed.txt

echo -e "\nTam: $1 KB \nsets: $nsets \nblockSize: $blockSize \nassociatividade: $assoc \npol. subs: $repl" >> ../benchProcessed.txt

echo
cat ../benchProcessed.txt