# Logical Balatro (Prolog)

Este projeto é uma implementação lógica do jogo Balatro, desenvolvida em Prolog. O jogo desafia o jogador a criar mãos de poker, gerenciar coringas (Jokers) e superar pontuações crescentes em um estilo roguelike.

## Pré-requisitos

Para executar este projeto, você precisa ter o SWI-Prolog instalado.
- [Instalar SWI-Prolog](https://www.swi-prolog.org/)

## Como executar
Com o SWI-Prolog aberto, execute
`consult(['CAMINHO/ABSOLUTO/PARA/main.pro']).`

## Mecânicas do Jogo
O objetivo é vencer as "Blinds" (pontuações alvo) que aumentam a cada rodada.

## A Mão
  * O jogador recebe 8 cartas do baralho.
  * É possível selecionar ou desselecionar até 5 cartas para jogar ou descartar.
  * A seleção é feita digitando o número correspondente à carta (1 a 8).

## Coringas (Jokers)
  * O jogo possui um sistema de Slots de Coringas, onde você pode equipar até 5 coringas simultaneamente.
  * Os coringas modificam a pontuação ou dão bônus especiais.
  * Caso os slots estejam cheios, é possível substituir um coringa antigo por um novo adquirido.

## Progressão e Loja
Ao vencer uma rodada (atingir a pontuação necessária), o jogador tem a oportunidade de melhorar seu deck. Você poderá escolher entre:
 1. Um Coringa Aleatório: Para adicionar novos efeitos.
 2. Melhoria de Mão: Aumenta o nível (multiplicador e fichas base) de um tipo específico de mão de poker.

## Controles

| Tecla   | Ação |
| :--------------- | :------------: |
| 1-8         |    Selecionar / Desselecionar cartas (pelo índice)       |
| q           |      Jogar mão (Confirma as cartas selecionadas)         |
| w           |     Descartar (Troca as cartas selecionadas por novas)   |
| e           |     Ordenar mão por Naipe                                |
| r           |    Ordenar mão por Valor                                 |


## Tabela de Pontuação
Cada mão possui um valor base de Fichas x Multiplicador. Estes valores podem ser aumentados durante a campanha. Abaixo, a tabela de valores iniciais:

| Mão de Poker     | Pontuação Base |
| :--------------- | :------------: |
| Straight Flush   |    100 x 8     |
| Quadra           |     60 x 7     |
| Full House       |     40 x 4     |
| Flush            |     35 x 4     |
| Sequência        |     30 x 4     |
| Trinca           |     30 x 3     |
| Dois Pares       |     20 x 2     |
| Par              |     10 x 2     |
| Carta Alta       |     5 x 1      |

