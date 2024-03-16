;Projekt JA SSI
;��czenie bitmap pomijaj�c niepo��dane t�o
;Opis algorytmu:
; 1. Inicjalizacja:
; (algorytm powinien operowa� tylko na cz�ci wsp�lnej obu zdj��)
; -jako licznik p�tli zewn�trznej wybieramy wysoko�� ni�szego zdj�cia
; -jako licznik p�tli wewn�trznej wybieramy szeroko�� w�szego zdj�cia
; 2.G��wna p�tla programu ->
; -> p�tla zewn�trzna iteruj�ca po wierszach obrazu ->
; -> p�tla wewn�trzna iteruj�ca po kolejnych pikselach w wierszu ->
; -> w miar� mo�liwo�ci wykonanie operacji wektorowych na pi�ciu kolejnych pikselach ->
; -> obr�bka pozosta�ych pojedynczych pikseli 
; - instrukcja warunkowa - wszystkie sk�adowe piksela maj� warto�� mniejsz� od 20
; tak - skopiuj piksel zdj�cia wstawianego do zdj�cia bazowego
; nie - przejd� do nast�pnego piksela
;06.01.2024 semestr V AEI INF
;Konrad Kobielus
;wersja v1.0
.data							;dyrektywa cz�ci danych programu
;deklaracja zmiennych globalnych 

piksel_granica		db 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20		;maska koloru pikseli do pomini�cia
piksel_pusty	    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0						;maska pustych pikseli
destination			db 0, 1, 1, 1, 4, 4, 4, 7, 7, 7, 10, 10, 10, 13, 13, 13					;maska instrukcji shufle

.code												;dyrektywa cz�ci kodu programu
MyProc1 proc										;deklaracja procedury MyProc1
;deklaracja zmiennych lokalnych
LOCAL widthCounter:dq           					;licznik wewn�trznej p�tli - iteruj�cy po kolumnach obrazu
LOCAL heightCounter:dq          					;licznik zewn�trznej p�tli - iteruj�cy po wierszach obrazu
LOCAL currentWidth:dq           					;szeroko�� w�szego zdj�cia - zakres obszaru do edycji
LOCAL currentHeight:dq          					;liczba wierszy mniejszego obrazu przewidzianych do edycji w danym w�tku
LOCAL heightPhoto1:dq           					;liczba wiersz obrazu nr 1 przewidziany do edycji w danym w�tku  
LOCAL heightPhoto2:dq           					;liczba wiersz obrazu nr 2 przewidziany do edycji w danym w�tku  
LOCAL start1:dq                 					;adres pierwszego piksela w pierwszym wierszu edytowanego obszaru nr1
LOCAL start2:dq                 					;adres pierwszego piksela w pierwszym wierszu edytowanego obszaru nr2
LOCAL end1:dq                   					;adres pierwszego piksela w ostatnim wierszu edytowanego obszaru nr1
LOCAL end2:dq                   					;adres pierwszego piksela w ostatnim wierszu edytowanego obszaru nr2
LOCAL endPhoto1:dq              					;adres pierwszego piksela w ostatnim wierszu edytowanego obrazu nr1
LOCAL endPhoto2:dq              					;adres pierwszego piksela w ostatnim wierszu edytowanego obrazu nr2
LOCAL width1:dq                 					;liczba pikseli obrazu nr 1
LOCAL width2:dq                 					;liczba pikseli obrazu nr 2
LOCAL width_1:dq                					;liczba kolumn obrazu nr 1
LOCAL width_2:dq                					;liczba kolumn obrazu nr 2
LOCAL wartosc_graniczna:dq      					;maska koloru pikseli do pomini�cia

;pobranie przekazanych parametr�w
mov R10, [RSP+40+18*8]          					;start2
mov R11, [RSP+48+18*8]          					;end2
mov R12, [RSP+56+18*8]          					;endPhoto2
mov R13, [RSP+64+18*8]          					;width2
mov start1, RCX                 					;start1
mov end1, RDX                   					;end1
mov endPhoto1, R8               					;endPhoto1
mov width_1, R9                 					;width1

;zapisanie zawarto�ci rejestr�w na stosie
push rbx											
push rdi
push rsi
push rax
push R10
push R11

;zapis pobranych parametr�w do zmiennych lokalnych
mov start2, R10                 					;start2
mov end2, R11                   					;end2
mov endPhoto2, R12              					;endPhoto2
mov width_2, R13                					;width2

;interpretacja i przygotowanie pobranych danych
mov heightCounter, 0            					;wyzerowanie licznika wierszy
mov widthCounter, 0             					;wyzerowanie licznika kolumn
mov wartosc_graniczna, 20       					;ustawienie granicznego koloru piksela na warto�� 20

;Pomn� width_1 * 3 i zapisz do width1
mov rax, width_1
imul rax, 3 
mov width1, rax 

;Pomn� width_2 * 3 i zapisz do width1
mov rax, width_2
imul rax, 3
mov width2, rax

;sprawdzenie czy przekazany zakres obraz�w jest prawid�owy
;(start1 < endPhoto1 && start2 < endPhoto2)
mov rax, start1
mov rbx, endPhoto1
cmp rax, rbx					
jae out_of_range                					;wykonaj skok je�eli pierwsza cz�� warunku jest nie spe�niona
mov rax, start2
mov rbx, endPhoto2
cmp rax, rbx
jae out_of_range                					;wykonaj skok je�eli druga cz�� warunku jest nie spe�niona 

;wyb�r w�szego zdj�cia i zapis szeroko�ci do zmiennej currentWidth
;currentWidth = min(width1, width2)
mov rax, width1
mov rbx, width2
cmp rax, rbx										;za�aduj do akumulatora width1
cmovg rax, rbx										;je�elili pierwsze zdj�cie jest szersze, przenie� width2 do akumulatora
mov currentWidth, rax								;zapisz szeroko�� w�szego zdj�cia (zawarto�� akumulatora) do zmiennej currentWidth
;sub currentWidth, 6

;wyznaczenie obszaru do edycji obrazu nr1
;heightPhoto1 = min(((endPhoto1 - start1) / width1), ((end1 - start1) / width1))
;obliczenie pierwszej cz�ci zakresu
mov rax, endPhoto1
sub rax, start1
mov rbx, width1
mov rdx, 0 
div rbx												;rax = (endPhoto1 - start1) / width1 
mov rcx, rax										;zapisz wynik w rejestrze rcx
;obliczenie drugiej cz�ci zakres
mov rax, end1
sub rax, start1
mov rbx, width1
mov rdx, 0 
div rbx												;rax = (end1 - start1) / width1
cmp rax, rcx										;por�wnanie wyznaczonych zakres�w
cmovg rax, rcx										;je�eli pierwszy zakres jest wi�kszy skopiuj zawarto�� rejestru rcx do akumulatora
mov heightPhoto1, rax								;zapisz obliczony zakres w zmiennej heightPhoto1

;wyznaczenie obszaru do edycji obrazu nr2
;heightPhoto2 = min(((endPhoto2 - start2) / width2), ((end2 - start2) / width2))
;obliczenie pierwszej cz�ci zakresu
mov rax, endPhoto2
sub rax, start2
mov rbx, width2
mov rdx, 0 
div rbx												;rax = (endPhoto2 - start2) / width2
mov rcx, rax										;zapisz wynik w rejestrze rcx
;obliczenie drugiej cz�ci zakres
mov rax, end2
sub rax, start2
mov rbx, width2
mov rdx, 0 
div rbx												;rcx = (end2 - start2) / width2
cmp rax, rcx										;por�wnanie wyznaczonych zakres�w
cmovg rax, rcx										;je�eli pierwszy zakres jest wi�kszy skopiuj zawarto�� rejestru rcx do akumulatora
mov heightPhoto2, rax								;zapisz obliczony zakres w zmiennej heightPhoto2

;wyb�r ni�szego obrazu
;currentHeight = min(heightPhoto1, heightPhoto2)
mov rax, heightPhoto1
mov rbx, heightPhoto2
cmp rax, rbx										;por�wnaj obliczone obszary
cmovg rax, rbx										;je�eli obszar nr 1 jest wi�kszy, przenie� warto�� zmiennej heightPhoto2 do akumulatora
mov currentHeight, rax								;zapisz mniejszy obszar w zmiennej currentHeight

;zewn�trzna p�tla programu 
;wywo�uje si� dla ka�dego wiersza obrazu o mniejszej wysoko�ci
;while (heightCounter < currentHeight)
while_loop:										;etykieta rozpoczynaj�ca p�tl� zewn�trzn�
mov rax, heightCounter
mov rbx, currentHeight
cmp rax, rbx										;por�wnanie warunku p�tli
jge end_while_loop									;je�eli warunek nie jest spe�niony nast�puje skok do end_while_loop 

	;cia�o zewn�trznej p�tli

	;wyznaczenie adresu pierwszego piksela danego wiersza w obrazie nr 1
	mov rdi, start1									;pobranie adresu pierwszego piksela w przekazanym obszarze
	mov rcx, heightCounter        
	mov rdx, width1               
	mov rax, widthCounter         
	imul rcx, rdx                   				;pomn� numer aktualnego wiersza razy liczba kolumn w wiersza
	add rax, rcx                    				;dodaj przesuni�cie w kolumnach
	add rdi, rax                    				;dodanie obliczonego przesuni�cia do adresu pocz�tkowego

	;wyznaczenie adresu pierwszego piksela danego wiersza w obrazie nr 2
	mov rsi, start2									;pobranie adresu pierwszego piksela w przekazanym obszarze
	mov rcx, heightCounter        
	mov rdx, width2               
	mov rax, widthCounter         
	imul rcx, rdx									;pomn� numer aktualnego wiersza razy liczba kolumn w wiersza 
	add rax, rcx                    				;dodaj przesuni�cie w kolumnach
	add rsi, rax                    				;dodanie obliczonego przesuni�cia do adresu pocz�tkowego
	
	movdqu xmm1, xmmword ptr [piksel_granica]		;maska zawieraj�ca minimaln� warto�� sk�adowych piksela
	sub R10, R10									;wyczyszczenie rejestru R10

	;pierwsza p�tla wewn�trzna
	Loop1:
		;sprawdzenie warunku p�tli
		mov rax, widthCounter
		add rax, 16									;warunek dost�pnych kolejnych 16 sk�adowych pikseli
		cmp rax, currentWidth
		jge Loop1End								;je�eli wyszli�my poza adres wiersza skocz na koniec p�tli

		mov R10b, byte ptr [rdi+15]					;kopia sk�adowej B sz�stego piksela

		;stworzenie maski pikseli przeznaczonych do skopiowania
		movdqu xmm0, xmmword ptr [rsi]				;pobieramy 5 pikseli + 1 sk�adow� kolejnego pikselach kt�rych nie edytujemy 
		pslldq xmm0, 1								;przesuwamy rejestr xmm0 o jeden bajt w lewo (b�dziemy edytowali tylko pe�ne piksele)
													;operacja ta jest konieczna ze wzgl�du na trzykrotne wykonywanie operacji shuffle
		movdqu xmm2, xmmword ptr [piksel_pusty]		;pobranie maski piksela z zerowymi warto�ciami sk�adowych R, G, B
		pcmpgtb xmm2, xmm0							;wyb�r sk�adowych pikseli o warto�ci wi�kszej od 128 i nie wi�kszej od 256
		pcmpgtb xmm0, xmm1							;wyb�r sk�adowych pikseli o warto�ci wi�kszej od 20 i nie wi�kszej od 128
		por xmm0, xmm2								;wyb�r sk�adowych pikseli o warto�ci wi�kszej od 20 i nie wi�kszej od 256
		movdqu xmm2, xmm0							;skopiowanie maski sk�adowych pikseli przeznaczonych do przeniesienia 
		psrldq xmm2, 1								;przesuni�cie rejestru xmm2 o jeden bajt w prawo
		movdqu xmm4, xmm0							;skopiowanie maski sk�adowych pikseli przeznaczonych do przeniesienia 
		psrldq xmm4, 2								;przesuni�cie rejestru xmm4 o dwa bajty w prawo
		vpor xmm0, xmm2, xmm4						;znalezienie pikseli kt�re maj� jedn� ze sk�adowych R, B, G wi�ksz� ni� 20
		pshufb xmm0, xmm5							;roz�o�enie w rejestrze informacji kt�re pikseli maj� by� przeniesione (bajt = 255)

		;przygotowanie pikseli do skopiowania
		movdqu xmm4, xmmword ptr [rsi]				;pobranie pi�ciu kolejnych pikseli z obrazu wstawianego
		pslldq xmm4, 1								;przesuni�cie rejestru xmm4 o jeden bajt w prawo
		movdqu xmm2, xmmword ptr [rdi]				;pobranie pi�ciu kolejnych pikseli z obrazu bazowego
		pslldq xmm2, 1								;przesuni�cie rejestru xmm4 o jeden bajt w prawo
		VPBLENDVB xmm0, xmm2, xmm4, xmm0			;wyb�r piksela z odpowiedniego zdj�cia 
													;rejestr bazowy, �r�d�owy1, �r�d�owy2, decyzyjny
													;je�eli bajt w rejestrze decyzyjnym:
													;	-ma warto�� 255 kopiujemy warto�� z �r�d�a nr2
													;	-ma warto�� 0 kopiujemy warto�� z �r�d�a nr1 
		;zapis pikseli w zdj�ciu bazowym
		psrldq xmm0, 1								;przesuni�cie rejestru xmm0 o jeden bajt w prawo (powr�t na miejsce bazowe)
		movdqu xmmword ptr [rdi], xmm0				;zapis pi�ci pikseli w zdj�ciu bazowym
		mov byte ptr [rdi+15],  R10b				;przywr�cenie sk�adowej B sz�stego piksela

		add rsi, 15									;inkrementacja adresu zdj�cia bazowego
		add rdi, 15									;inkrementacja adresu zdj�cia wstawianego
		add widthCounter, 15						;inkrementacja licznika p�tli wewn�trznej
		jmp Loop1									;powr�t na pocz�tek pierwszej p�tli wewn�trznej
	Loop1End:




	mov rbx, currentWidth							;pobranie warunku granicznego p�tli wewn�trznej
	mov R10, widthCounter							;pobranie licznika p�tli wewn�trznej
	Loop2:											;etykieta rozpoczynaj�ca drug� p�tl� wewn�trzn� edytuj�ca pozosta�e nieprzetworzone piksele
		cmp R10, rbx								;por�wnanie warunku p�tli
		jge Loop2End								;skok na koniec p�tli je�eli warunek nie jest spe�niony (wszystkie piksele w rz�dzie s� przetworzone)

		;sprawdzenie warunku skopiowania piksela
		mov al, byte ptr [rsi]						;pobranie sk�adowej B wstawianego zdj�cia i zapisanie jej najm�odszym bajcie akumulatora
		cmp rax, wartosc_graniczna					;warunek sk�adowej B edycji piksela
		jb skok										;je�eli warunek edycji nie jest spe�niony nast�puje skok do etykiety skok

		add rsi, 1									;inkrementacja adresu wstawianego zdj�cia
		mov al, byte ptr [rsi]						;pobranie sk�adowej G wstawianego zdj�cia i zapisanie jej najm�odszym bajcie akumulatora
		sub rsi, 1									;przywr�cenie adresu wstawianego zdj�cia
		cmp rax, wartosc_graniczna                  ;warunek sk�adowej G edycji piksela
		jb skok										;je�eli warunek edycji nie jest spe�niony nast�puje skok do etykiety skok

		add rsi, 2									;inkrementacja adresu wstawianego zdj�cia
		mov al, byte ptr [rsi]						;pobranie sk�adowej R wstawianego zdj�cia i zapisanie jej najm�odszym bajcie akumulatora
		sub rsi, 2									;przywr�cenie adresu wstawianego zdj�cia
		cmp al, byte ptr wartosc_graniczna          ;warunek sk�adowej R edycji piksela
		jb skok										;je�eli warunek edycji nie jest spe�niony nast�puje skok do etykiety skok

		;skopiowanie piksela do zdj�cia bazowego
		mov al, byte ptr [rsi]						;pobranie do akumulatora sk�adowej B wstawianego zdj�cia
		mov byte ptr [rdi], al						;zapisanie sk�adowej B z akumulatora w zdj�ciu bazowym
		add rsi, 1									;inkrementacja adresu wstawianego zdj�cia
		add rdi, 1									;inkrementacja adresu bazowego zdj�cia
		mov al, byte ptr [rsi]						;pobranie do akumulatora sk�adowej G wstawianego zdj�cia
		mov byte ptr [rdi], al						;zapisanie sk�adowej G z akumulatora w zdj�ciu bazowym
		add rsi, 1									;inkrementacja adresu wstawianego zdj�cia
		add rdi, 1									;inkrementacja adresu bazowego zdj�cia
		mov al, byte ptr [rsi]						;pobranie do akumulatora sk�adowej R wstawianego zdj�cia
		mov byte ptr [rdi], al						;zapisanie sk�adowej R z akumulatora w zdj�ciu bazowym
		sub rsi, 2									;przywr�cenie adresu wstawianego zdj�cia
		sub rdi, 2									;przywr�cenie adresu bazowego zdj�cia

		skok:										;etykieta nie spe�nionego warunku edycji piksela
		add rsi, 3									;zwi�kszenie adresu zdj�cia wstawianego
		add rdi, 3									;zwi�kszenie adresu zdj�cia bazowego
		add R10, 3									;inkrementacja licznika edytowanego piksela
		jmp loop2									;powr�t na pocz�tek drugiej p�tli wewn�trznej
	Loop2End:										;etykieta ko�ca drugiej p�tli wewn�trznej


	mov widthCounter, 0								;zerowanie licznika bie��cego piksela w rz�dzie
	add heightCounter, 1							;inkrementacja licznika p�tli zewn�trznej 

	jmp while_loop									;powr�t na pocz�tek p�tli zewn�trznej
end_while_loop:										;etykieta ko�ca p�tli zewn�trznej

out_of_range:										;etykieta b��dnego adresu przekazanego obrazu

;przywr�cenie zawarto�ci rejestr�w ze stosu
pop R11
pop R10
pop rax
pop rsi
pop rdi
pop rbx

;koniec programu
ret													;koniec wywo�ania funkcji
MyProc1 endp										;koniec procedury MyProc1
end													;koniec program
