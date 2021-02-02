# Filtro-Digital-FIR-IIR

Essa é uma seção para apresentar dois programas.

Você pode escolher tanto um filtro do tipo FIR "FIR.m" que vai ser um filtro com mais custo computacional, porém mais simples de ser projetado.

Você pode escolher também um filtro do tipo IIR "IIR.m" que vai ser um filtro com menor custo computacional, porém mais dificil de ser projetado.

Aqui ambos os códigos estão prontos e vão projetar os coeficientes do seu filtro. Eles vem configurado para funcionar como um passa baixa, mas pode ser trocado a qualquer instante.

Há um arquivo PDF "Projeto.pdf" com 5 páginas explicando todos os processo de filtragem de um áudio especifico, além de explicar melhor o que é um filtro.


## O que é um filtro?

Filtros digitais são equações que operam digitalmete em um sinal amostrado para atenuar as frequências indesejadas de tal forma que o sinal resultante seja apenas o desejado. Para implementar um filtro ideal, é necessário aplicar uma frequência de corte que será o mediador entre as frequência que vão ou não ser atenuadas. Um filtro real diferente de um um filtro ideal, não filtra o sinal de entrada no instante exata da frequência de corte, há uma frequência de transição (𝑓𝑡) nos intervalos do filtros. A frequência de transição é definida pelo pela diferença da frequência de passagem (𝑓𝑝) e a frequência de parada (𝑓𝑠). A divisão da soma da frequência de parada com a frequência de passagem, resulta na frequência de corte (𝑓𝑐) do filtro real. Outros fatores a serem considerados em um filtro real são os ripples da faixa de passagem (𝑅𝑝) e os ripples da faixa de parada (As).

![Modelo representativo da Resposta de um filtro](https://github.com/Arthurmgwork/Filtro-Digital-FIR-IIR/blob/main/Filtro.JPG)

Os diversos filtros digitais existentes, produzem uma resposta diferente para cada uma das variaveis apresentadas. Os filtros digitais podem ser divididos em FIR e IIR.

Abaixo será explicado de forma resumida o que é um filtro FIR e um Filtro IIR, caso queira mais detalhes, consultar o PDF "Projeto.pdf" anexado nesse repositório. Nele possui gráficos, equações e tabelas ilustrativas para facilitar o entendimento.


## Filtro FIR

Os filtros duração finita ao impulso (FIR), são filtros apenas digitais de fácil implementação, entretanto necessitam de um considerável custo computacional para filtrar as características desejadas do sinal com uma faixa de transição ideal. Para criar um filtro FIR real, é necessário seguir os passos abaixo.

![Organograma do Processo de um Filtro FIR](https://github.com/Arthurmgwork/Filtro-Digital-FIR-IIR/blob/main/Processo%20de%20um%20filtro%20FIR.JPG)

A resposta ao impulso dos filtros ideais possui uma duração infinita e não causal. As janelas são um artifício utilizado para “janelar” a resposta ao impulso do filtro ideal com o viés obter um filtro de resposta finita e causal ao impulso. Cada janela possui uma reposta diferente em decibéis para a atenuação do ruído, e um custo computacional diferente para executar a atenuação. Os filtros mais comuns a serem implementados são: Retangular, Bartlett, Hann, Hamming, Blackman.

A atenuação mínima da faixa de parada (As) é determinando na escolha de uma janela.


## Filtro IIR

Os filtros duração infinito ao impulso (IIR), são filtros projetados para como filtros reais, mas implementados de forma digital, estes filtros são um pouco mais complexo em sua implementação, porém oferecem um bom desempenho em conjunto de um baixo custo computacional. Para projetar o filtro IIR, é necessário seguir os passos apresentados a seguir.

![Organograma do Processo de um Filtro IIR](https://github.com/Arthurmgwork/Filtro-Digital-FIR-IIR/blob/main/Processo%20de%20um%20filtro%20IIR.JPG)

Existem diversos filtros IIR de alto desempenho com funções de transferência já catalogados, o filtro Butterworth é um exemplo clássico deste tipo de filtros. Este filtro possui um ripple quase desprezível na faixa de passagem e na faixa de parada. As frequências definidas são normalizadas na metade da frequência de amostragem.




