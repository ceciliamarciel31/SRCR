% Caracterização das funções ---------------------------------------------------------------------------------------------------

% utente: Nome, Serviço, Profissional, Instituição -> {V, F}
% servico: Designação, Instituição -> {V, F}
% profissional: Nome, Serviço, Instituição -> {V, F}
% instituicao: Nome -> {V, F}
% negate: Questão -> {V, F}
% pertence: Elemento, Lista -> {V, F}
% concatenar: Lista 1, Lista 2, Resultado -> {V, F}
% apagar: Elemento, Lista, Resultado -> {V, F}
% remover: Lista 1, Lista 2, Resultado -> {V, F}
% tira_repetidos: Lista, Resultado -> {V, F}
% inserir: Questão -> {V, F}
% retirar: Questão -> {V, F}
% testar: Lista -> {V, F}

% servicos_instituicao: Instituição, Lista de Serviços -> {V, F}
% utentes_instituicao: Instituição, Lista de Utentes -> {V, F}
% utentes_servico: Serviço, Lista de Utentes -> {V, F}
% utentes_servico: Serviço, Instituição, Lista de Utentes -> {V, F}
% instituicoes_servico: Serviço, Lista de Instituições -> {V, F}
% instituicoes_servicos: Lista de Serviços, Lista de Instituições -> {V, F}
% nao_servicos_instituicao: Instituição, Lista de Serviços -> {V, F}
% instituicoes_profissional: Profissional, Lista de Instituições -> {V, F}
% info_utente: Utente, Tipo, Lista -> {V, F}
% registar: Questão -> {V, F}
% remover: Questão -> {V, F}
% profissionais_instituicao: Instituição, Lista de Profissionais -> {V,F}


% Declarações iniciais ---------------------------------------------------------------------------------------------------------

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- set_prolog_flag( unknown,fail ).


% Definições iniciais ----------------------------------------------------------------------------------------------------------

:- op(900, xfy, '::').
:- dynamic utente/4.
:- dynamic servico/2.
:- dynamic profissional/3.
:- dynamic instituicao/1.


% Base de Conhecimento sobre Utentes -------------------------------------------------------------------------------------------

utente(jose_esteves, oncologia, antonio_abreu, ipo_porto).
utente(miguel_silva, clinica_geral, manuel_pereira, hospital_braga).
utente(carlos_sousa, cirurgia, pedro_soares, hospital_lisboa).
utente(samuel_cunha, cirurgia, joao_pereira, hospital_braga).
utente(janeiro_fevereiro, psiquiatria, gru_maldisposto, hospital_braga).


% Base de Conhecimento sobre Serviços ------------------------------------------------------------------------------------------

servico(oncologia, ipo_porto).
servico(cirurgia, hospital_braga).
servico(clinica_geral, hospital_braga).
servico(cirurgia, hospital_lisboa).
servico(psiquiatria, hospital_braga).


% Base de Conhecimento sobre Profissionais -------------------------------------------------------------------------------------

profissional(antonio_abreu, oncologia, ipo_porto).
profissional(manuel_pereira, clinica_geral, hospital_braga).
profissional(pedro_soares, cirurgia, hospital_lisboa).
profissional(joao_pereira, cirurgia, hospital_braga).
profissional(gru_maldisposto, psiquiatria, hospital_braga).


% Base de Conhecimento sobre Instituições --------------------------------------------------------------------------------------

instituicao(hospital_braga).
instituicao(hospital_lisboa).
instituicao(ipo_porto).


% Funções Auxiliares -----------------------------------------------------------------------------------------------------------

% Nega uma função
negate(A) :- A, !, fail.
negate(A).

% Verifica se um elemento pertence a uma lista
pertence(X, [X | T]).
pertence(X, [H | T]) :- pertence(X, T).

% Concatena duas listas, sem que haja repetidos
concatenar(L, [], L).
concatenar([], L, L).
concatenar([H | T], L, R) :- pertence(H, L), concatenar(T, L, R).
concatenar([H | T], L, [H | R]) :- negate(pertence(H, L)), concatenar(T, L, R).

% Apaga um elemento de uma lista
apagar(X, [], []).
apagar(X, [X | T], T1) :- apagar(X, T, T1).
apagar(X, [H | T], [H | R]) :- apagar(X, T, R).

% Remove todos os elementos de uma lista, de uma outra
remover([], S, S).
remover([X | L], S, R) :- apagar(X, S, R1), remover(L, R1, R).

% Elimina os repetidos de uma lista
tira_repetidos([], []).
tira_repetidos([H | T], [H | R]) :- negate(pertence(H, T)), tira_repetidos(T, R).
tira_repetidos([H | T], R) :- pertence(H, T), tira_repetidos(T, R).

% Insere informação na base de conhecimento
inserir(T) :- assert(T).
inserir(T) :- retract(T), !, fail.

% Remove informação da base de conhecimento
retirar(T) :- retract(T).
retirar(T) :- assert(T), !, fail.

% Testa se todos os invariantes são verificados
testar([]).
testar([I | L]) :- I, testar(L).


% Queries ----------------------------------------------------------------------------------------------------------------------

% Identificar os serviços existentes numa instituição
servicos_instituicao(I, S) :- findall(X, servico(X, I), S).

% Identificar os utentes de uma instituição
utentes_instituicao(I, U) :- findall(N, utente(N, S, P, I), U).

% Identificar os utentes de um determinado serviço
utentes_servico(S, U) :- findall(N, utente(N, S, P, I), U).

% Identificar os utentes de um determinado serviço numa instituição
utentes_servico(S, I, U) :- findall(N, utente(N, S, P, I), U).

% Identificar as instituições onde seja prestado um serviço
instituicoes_servico(S, I) :- findall(N, servico(S, N), I).

% Identificar as instituições onde seja prestado um conjunto de serviços
instituicoes_servicos([], []).
instituicoes_servicos([S | T], I) :- findall(N, servico(S, N), Li), instituicoes_servicos(T, Lt), concatenar(Li, Lt, I).

% Identificar os serviços que não se podem encontrar numa instituição
nao_servicos_instituicao(I, S) :- findall(X, servico(X, Y), L1), findall(X, servico(X, I), L2), remover(L2, L1, R), tira_repetidos(R, S).

% Determinar as instituições onde um profissional presta serviço
instituicoes_profissional(P, I) :- findall(N, profissional(P, S, N), R), tira_repetidos(R, I).

% Determinar todas as instituições, serviços ou profissionais a que um utente já recorreu
info_utente(U, instituicoes, L) :- findall(I, utente(U, S, P, I), L).
info_utente(U, servicos, L) :- findall(S, utente(U, S, P, I), L).
info_utente(U, profissionais, L) :- findall(P, utente(U, S, P, I), L).

% Registar utentes, profissionais, serviços ou instituições
registar(T) :- findall(I, +T :: I, L), inserir(T), testar(L).

% Remover utentes, profissionais, serviços ou instituições dos registos
remover(Q) :- findall(I, -Q :: I, L), retirar(Q), testar(L).


% Queries Extra -------------------------------------------------------------------------------------------------------------------

% Determinar os profissionais que prestam serviços numa instituicao sem repetidos 
profissionais_instituicao(I, P) :- (findall(N, profissional(N, S, I), L), tira_repetidos(L, P)).

% Determinar o número de utentes inscritos em cada uma das instituições
num_utentes([], [(Ni, Num) | T]) :- findall(I, instituicao(I), [Ni | Ti]), utentes_instituicao(Ni, Lu), length(Lu, Num), num_utentes(Ti, T).
num_utentes([Ni | Ti], [(Ni, Num) | T]) :- utentes_instituicao(Ni, Lu), length(Lu, Num), num_utentes(Ti, T). 


% Invariantes para Utentes --------------------------------------------------------------------------------------------------------

% Não podem existir utentes repetidos na mesma instituição com serviços e profissionais repetidos
+utente(U, S, P, I) :: (findall((U, S, P, I), utente(U, S, P, I), L), length(L, R), R == 1).

% Só pode inserir um utente se existir a instituição
+utente(U, S, P, I) :: (findall(I, instituicao(I), L), length(L, R), R == 1).

% Só pode inserir um utente se existir o serviço na dada instituição
+utente(U, S, P, I) :: (findall((S, I), servico(S, I), L), length(L, R), R == 1).

% Só pode inserir um utente se existir o profissional do serviço na instituição
+utente(U, S, P, I) :: (findall((P, S, I), profissional(P, S, I), L), length(L, R), R == 1).

% Para se remover um utente, é preciso que ele exista na base de conhecimento
-utente(U, S, P, I) :: (findall((U, S, P, I), utente(U, S, P, I), L), length(L, R), R == 0).


% Invariantes para Serviços -------------------------------------------------------------------------------------------------------

% Não podem existir serviços repetidos na mesma instituição
+servico(S, I) :: (findall((S, I), servico(S, I), L), length(L, R), R == 1).

% Só pode inserir um serviço numa instituição se esta existir
+servico(S, I) :: (findall(I, instituicao(I), L), length(L, R), R == 1).

% Para se remover um serviço, é preciso que este exista na base de conhecimento
-servico(S, I) :: (findall((S, I), servico(S, I), L), length(L, R), R == 0).

% Só pode remover um servico se não tiver utentes associados ao mesmo e na mesma instituição
-servico(S, I) :: (findall((U, S, I), utente(U, S, P, I), L), length(L, R), R == 0).

% Só pode remover um servico se não tiver profissionais associados ao mesmo e na mesma instituição
-servico(S, I) :: (findall((P, S, I), profissional(P, S, I), L), length(L, R), R == 0).


% Invariantes para Profissionais --------------------------------------------------------------------------------------------------

% Não podem existir profissionais repetidos na mesma instituição com o mesmo serviço
+profissional(P, S, I) :: (findall((P, S, I), profissional(P, S, I), L), length(L, R), R == 1).

% Só pode inserir um profissional numa instituição se esta existir
+profissional(P, S, I) :: (findall(I, instituicao(I), L), length(L, R), R == 1).

% Só pode inserir um profissional de um determinado serviço numa instituição se esse serviço existir na mesma
+profissional(P, S, I) :: (findall((S, I), servico(S, I), L), length(L, R), R == 1).

% Para se remover um profissional, é preciso que este exista na base de conhecimento
-profissional(P, S, I) :: (findall((P, S, I), profissional(P, S, I), L), length(L, R), R == 0).

% Só pode remover um profissional se este não tiver utentes associados
-profissional(P, S, I) :: (findall((U, S, P, I), utente(U, S, P, I), L), length(L, R), R == 0).


% Invariantes para Instituições ---------------------------------------------------------------------------------------------------

% Não podem existir instituições repetidas
+instituicao(I) :: (findall(I, instituicao(I), L), length(L, R), R == 1).

% Para se remover uma instituição, é preciso que esta exista na base de conhecimento
-instituicao(I) :: (findall(I, instituicao(I), L), length(L, R), R == 0).

% Para se remover uma instituição, não podem existir utentes associados à mesma
-instituicao(I) :: (utentes_instituicao(I, U) , length(U, L), L == 0).

% Para se remover uma instituição, não podem existir serviços associados à mesma
-instituicao(I) :: (servicos_instituicao(I, S), length(S, L), L == 0).

% Para se remover uma instituição, não podem existir profissionais associados à mesma
-instituicao(I) :: (profissionais_instituicao(I, P), length(P, L), L == 0).
