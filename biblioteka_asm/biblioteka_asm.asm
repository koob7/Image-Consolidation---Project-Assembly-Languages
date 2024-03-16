;Projekt JA SSI
;£¹czenie bitmap pomijaj¹c niepo¿¹dane t³o
;Opis algorytmu:
; 1. Inicjalizacja:
; (algorytm powinien operowaæ tylko na czêœci wspólnej obu zdjêæ)
; -jako licznik pêtli zewnêtrznej wybieramy wysokoœæ ni¿szego zdjêcia
; -jako licznik pêtli wewnêtrznej wybieramy szerokoœæ wê¿szego zdjêcia
; 2.G³ówna pêtla programu ->
; -> pêtla zewnêtrzna iteruj¹ca po wierszach obrazu ->
; -> pêtla wewnêtrzna iteruj¹ca po kolejnych pikselach w wierszu ->
; -> w miarê mo¿liwoœci wykonanie operacji wektorowych na piêciu kolejnych pikselach ->
; -> obróbka pozosta³ych pojedynczych pikseli 
; - instrukcja warunkowa - wszystkie sk³adowe piksela maj¹ wartoœæ mniejsz¹ od 20
; tak - skopiuj piksel zdjêcia wstawianego do zdjêcia bazowego
; nie - przejdŸ do nastêpnego piksela
;06.01.2024 semestr V AEI INF
;Konrad Kobielus
;wersja v1.0
.data							;dyrektywa czêœci danych programu
;deklaracja zmiennych globalnych 

piksel_granica		db 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20		;maska koloru pikseli do pominiêcia
piksel_pusty	    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0						;maska pustych pikseli
destination			db 0, 1, 1, 1, 4, 4, 4, 7, 7, 7, 10, 10, 10, 13, 13, 13					;maska instrukcji shufle

.code												;dyrektywa czêœci kodu programu
MyProc1 proc										;deklaracja procedury MyProc1
;deklaracja zmiennych lokalnych
LOCAL widthCounter:dq           					;licznik wewnêtrznej pêtli - iteruj¹cy po kolumnach obrazu
LOCAL heightCounter:dq          					;licznik zewnêtrznej pêtli - iteruj¹cy po wierszach obrazu
LOCAL currentWidth:dq           					;szerokoœæ wê¿szego zdjêcia - zakres obszaru do edycji
LOCAL currentHeight:dq          					;liczba wierszy mniejszego obrazu przewidzianych do edycji w danym w¹tku
LOCAL heightPhoto1:dq           					;liczba wiersz obrazu nr 1 przewidziany do edycji w danym w¹tku  
LOCAL heightPhoto2:dq           					;liczba wiersz obrazu nr 2 przewidziany do edycji w danym w¹tku  
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
LOCAL wartosc_graniczna:dq      					;maska koloru pikseli do pominiêcia

;pobranie przekazanych parametrów
mov R10, [RSP+40+18*8]          					;start2
mov R11, [RSP+48+18*8]          					;end2
mov R12, [RSP+56+18*8]          					;endPhoto2
mov R13, [RSP+64+18*8]          					;width2
mov start1, RCX                 					;start1
mov end1, RDX                   					;end1
mov endPhoto1, R8               					;endPhoto1
mov width_1, R9                 					;width1

;zapisanie zawartoœci rejestrów na stosie
push rbx											
push rdi
push rsi
push rax
push R10
push R11

;zapis pobranych parametrów do zmiennych lokalnych
mov start2, R10                 					;start2
mov end2, R11                   					;end2
mov endPhoto2, R12              					;endPhoto2
mov width_2, R13                					;width2

;interpretacja i przygotowanie pobranych danych
mov heightCounter, 0            					;wyzerowanie licznika wierszy
mov widthCounter, 0             					;wyzerowanie licznika kolumn
mov wartosc_graniczna, 20       					;ustawienie granicznego koloru piksela na wartoœæ 20

;Pomnó¿ width_1 * 3 i zapisz do width1
mov rax, width_1
imul rax, 3 
mov width1, rax 

;Pomnó¿ width_2 * 3 i zapisz do width1
mov rax, width_2
imul rax, 3
mov width2, rax

;sprawdzenie czy przekazany zakres obrazów jest prawid³owy
;(start1 < endPhoto1 && start2 < endPhoto2)
mov rax, start1
mov rbx, endPhoto1
cmp rax, rbx					
jae out_of_range                					;wykonaj skok je¿eli pierwsza czêœæ warunku jest nie spe³niona
mov rax, start2
mov rbx, endPhoto2
cmp rax, rbx
jae out_of_range                					;wykonaj skok je¿eli druga czêœæ warunku jest nie spe³niona 

;wybór wê¿szego zdjêcia i zapis szerokoœci do zmiennej currentWidth
;currentWidth = min(width1, width2)
mov rax, width1
mov rbx, width2
cmp rax, rbx										;za³aduj do akumulatora width1
cmovg rax, rbx										;je¿elili pierwsze zdjêcie jest szersze, przenieœ width2 do akumulatora
mov currentWidth, rax								;zapisz szerokoœæ wê¿szego zdjêcia (zawartoœæ akumulatora) do zmiennej currentWidth
;sub currentWidth, 6

;wyznaczenie obszaru do edycji obrazu nr1
;heightPhoto1 = min(((endPhoto1 - start1) / width1), ((end1 - start1) / width1))
;obliczenie pierwszej czêœci zakresu
mov rax, endPhoto1
sub rax, start1
mov rbx, width1
mov rdx, 0 
div rbx												;rax = (endPhoto1 - start1) / width1 
mov rcx, rax										;zapisz wynik w rejestrze rcx
;obliczenie drugiej czêœci zakres
mov rax, end1
sub rax, start1
mov rbx, width1
mov rdx, 0 
div rbx												;rax = (end1 - start1) / width1
cmp rax, rcx										;porównanie wyznaczonych zakresów
cmovg rax, rcx										;je¿eli pierwszy zakres jest wiêkszy skopiuj zawartoœæ rejestru rcx do akumulatora
mov heightPhoto1, rax								;zapisz obliczony zakres w zmiennej heightPhoto1

;wyznaczenie obszaru do edycji obrazu nr2
;heightPhoto2 = min(((endPhoto2 - start2) / width2), ((end2 - start2) / width2))
;obliczenie pierwszej czêœci zakresu
mov rax, endPhoto2
sub rax, start2
mov rbx, width2
mov rdx, 0 
div rbx												;rax = (endPhoto2 - start2) / width2
mov rcx, rax										;zapisz wynik w rejestrze rcx
;obliczenie drugiej czêœci zakres
mov rax, end2
sub rax, start2
mov rbx, width2
mov rdx, 0 
div rbx												;rcx = (end2 - start2) / width2
cmp rax, rcx										;porównanie wyznaczonych zakresów
cmovg rax, rcx										;je¿eli pierwszy zakres jest wiêkszy skopiuj zawartoœæ rejestru rcx do akumulatora
mov heightPhoto2, rax								;zapisz obliczony zakres w zmiennej heightPhoto2

;wybór ni¿szego obrazu
;currentHeight = min(heightPhoto1, heightPhoto2)
mov rax, heightPhoto1
mov rbx, heightPhoto2
cmp rax, rbx										;porównaj obliczone obszary
cmovg rax, rbx										;je¿eli obszar nr 1 jest wiêkszy, przenieœ wartoœæ zmiennej heightPhoto2 do akumulatora
mov currentHeight, rax								;zapisz mniejszy obszar w zmiennej currentHeight

;zewnêtrzna pêtla programu 
;wywo³uje siê dla ka¿dego wiersza obrazu o mniejszej wysokoœci
;while (heightCounter < currentHeight)
while_loop:										;etykieta rozpoczynaj¹ca pêtlê zewnêtrzn¹
mov rax, heightCounter
mov rbx, currentHeight
cmp rax, rbx										;porównanie warunku pêtli
jge end_while_loop									;je¿eli warunek nie jest spe³niony nastêpuje skok do end_while_loop 

	;cia³o zewnêtrznej pêtli

	;wyznaczenie adresu pierwszego piksela danego wiersza w obrazie nr 1
	mov rdi, start1									;pobranie adresu pierwszego piksela w przekazanym obszarze
	mov rcx, heightCounter        
	mov rdx, width1               
	mov rax, widthCounter         
	imul rcx, rdx                   				;pomnó¿ numer aktualnego wiersza razy liczba kolumn w wiersza
	add rax, rcx                    				;dodaj przesuniêcie w kolumnach
	add rdi, rax                    				;dodanie obliczonego przesuniêcia do adresu pocz¹tkowego

	;wyznaczenie adresu pierwszego piksela danego wiersza w obrazie nr 2
	mov rsi, start2									;pobranie adresu pierwszego piksela w przekazanym obszarze
	mov rcx, heightCounter        
	mov rdx, width2               
	mov rax, widthCounter         
	imul rcx, rdx									;pomnó¿ numer aktualnego wiersza razy liczba kolumn w wiersza 
	add rax, rcx                    				;dodaj przesuniêcie w kolumnach
	add rsi, rax                    				;dodanie obliczonego przesuniêcia do adresu pocz¹tkowego
	
	movdqu xmm1, xmmword ptr [piksel_granica]		;maska zawieraj¹ca minimaln¹ wartoœæ sk³adowych piksela
	sub R10, R10									;wyczyszczenie rejestru R10

	;pierwsza pêtla wewnêtrzna
	Loop1:
		;sprawdzenie warunku pêtli
		mov rax, widthCounter
		add rax, 16									;warunek dostêpnych kolejnych 16 sk³adowych pikseli
		cmp rax, currentWidth
		jge Loop1End								;je¿eli wyszliœmy poza adres wiersza skocz na koniec pêtli

		mov R10b, byte ptr [rdi+15]					;kopia sk³adowej B szóstego piksela

		;stworzenie maski pikseli przeznaczonych do skopiowania
		movdqu xmm0, xmmword ptr [rsi]				;pobieramy 5 pikseli + 1 sk³adow¹ kolejnego pikselach których nie edytujemy 
		pslldq xmm0, 1								;przesuwamy rejestr xmm0 o jeden bajt w lewo (bêdziemy edytowali tylko pe³ne piksele)
													;operacja ta jest konieczna ze wzglêdu na trzykrotne wykonywanie operacji shuffle
		movdqu xmm2, xmmword ptr [piksel_pusty]		;pobranie maski piksela z zerowymi wartoœciami sk³adowych R, G, B
		pcmpgtb xmm2, xmm0							;wybór sk³adowych pikseli o wartoœci wiêkszej od 128 i nie wiêkszej od 256
		pcmpgtb xmm0, xmm1							;wybór sk³adowych pikseli o wartoœci wiêkszej od 20 i nie wiêkszej od 128
		por xmm0, xmm2								;wybór sk³adowych pikseli o wartoœci wiêkszej od 20 i nie wiêkszej od 256
		movdqu xmm2, xmm0							;skopiowanie maski sk³adowych pikseli przeznaczonych do przeniesienia 
		psrldq xmm2, 1								;przesuniêcie rejestru xmm2 o jeden bajt w prawo
		movdqu xmm4, xmm0							;skopiowanie maski sk³adowych pikseli przeznaczonych do przeniesienia 
		psrldq xmm4, 2								;przesuniêcie rejestru xmm4 o dwa bajty w prawo
		vpor xmm0, xmm2, xmm4						;znalezienie pikseli które maj¹ jedn¹ ze sk³adowych R, B, G wiêksz¹ ni¿ 20
		pshufb xmm0, xmm5							;roz³o¿enie w rejestrze informacji które pikseli maj¹ byæ przeniesione (bajt = 255)

		;przygotowanie pikseli do skopiowania
		movdqu xmm4, xmmword ptr [rsi]				;pobranie piêciu kolejnych pikseli z obrazu wstawianego
		pslldq xmm4, 1								;przesuniêcie rejestru xmm4 o jeden bajt w prawo
		movdqu xmm2, xmmword ptr [rdi]				;pobranie piêciu kolejnych pikseli z obrazu bazowego
		pslldq xmm2, 1								;przesuniêcie rejestru xmm4 o jeden bajt w prawo
		VPBLENDVB xmm0, xmm2, xmm4, xmm0			;wybór piksela z odpowiedniego zdjêcia 
													;rejestr bazowy, Ÿród³owy1, Ÿród³owy2, decyzyjny
													;je¿eli bajt w rejestrze decyzyjnym:
													;	-ma wartoœæ 255 kopiujemy wartoœæ z Ÿród³a nr2
													;	-ma wartoœæ 0 kopiujemy wartoœæ z Ÿród³a nr1 
		;zapis pikseli w zdjêciu bazowym
		psrldq xmm0, 1								;przesuniêcie rejestru xmm0 o jeden bajt w prawo (powrót na miejsce bazowe)
		movdqu xmmword ptr [rdi], xmm0				;zapis piêci pikseli w zdjêciu bazowym
		mov byte ptr [rdi+15],  R10b				;przywrócenie sk³adowej B szóstego piksela

		add rsi, 15									;inkrementacja adresu zdjêcia bazowego
		add rdi, 15									;inkrementacja adresu zdjêcia wstawianego
		add widthCounter, 15						;inkrementacja licznika pêtli wewnêtrznej
		jmp Loop1									;powrót na pocz¹tek pierwszej pêtli wewnêtrznej
	Loop1End:




	mov rbx, currentWidth							;pobranie warunku granicznego pêtli wewnêtrznej
	mov R10, widthCounter							;pobranie licznika pêtli wewnêtrznej
	Loop2:											;etykieta rozpoczynaj¹ca drug¹ pêtlê wewnêtrzn¹ edytuj¹ca pozosta³e nieprzetworzone piksele
		cmp R10, rbx								;porównanie warunku pêtli
		jge Loop2End								;skok na koniec pêtli je¿eli warunek nie jest spe³niony (wszystkie piksele w rzêdzie s¹ przetworzone)

		;sprawdzenie warunku skopiowania piksela
		mov al, byte ptr [rsi]						;pobranie sk³adowej B wstawianego zdjêcia i zapisanie jej najm³odszym bajcie akumulatora
		cmp rax, wartosc_graniczna					;warunek sk³adowej B edycji piksela
		jb skok										;je¿eli warunek edycji nie jest spe³niony nastêpuje skok do etykiety skok

		add rsi, 1									;inkrementacja adresu wstawianego zdjêcia
		mov al, byte ptr [rsi]						;pobranie sk³adowej G wstawianego zdjêcia i zapisanie jej najm³odszym bajcie akumulatora
		sub rsi, 1									;przywrócenie adresu wstawianego zdjêcia
		cmp rax, wartosc_graniczna                  ;warunek sk³adowej G edycji piksela
		jb skok										;je¿eli warunek edycji nie jest spe³niony nastêpuje skok do etykiety skok

		add rsi, 2									;inkrementacja adresu wstawianego zdjêcia
		mov al, byte ptr [rsi]						;pobranie sk³adowej R wstawianego zdjêcia i zapisanie jej najm³odszym bajcie akumulatora
		sub rsi, 2									;przywrócenie adresu wstawianego zdjêcia
		cmp al, byte ptr wartosc_graniczna          ;warunek sk³adowej R edycji piksela
		jb skok										;je¿eli warunek edycji nie jest spe³niony nastêpuje skok do etykiety skok

		;skopiowanie piksela do zdjêcia bazowego
		mov al, byte ptr [rsi]						;pobranie do akumulatora sk³adowej B wstawianego zdjêcia
		mov byte ptr [rdi], al						;zapisanie sk³adowej B z akumulatora w zdjêciu bazowym
		add rsi, 1									;inkrementacja adresu wstawianego zdjêcia
		add rdi, 1									;inkrementacja adresu bazowego zdjêcia
		mov al, byte ptr [rsi]						;pobranie do akumulatora sk³adowej G wstawianego zdjêcia
		mov byte ptr [rdi], al						;zapisanie sk³adowej G z akumulatora w zdjêciu bazowym
		add rsi, 1									;inkrementacja adresu wstawianego zdjêcia
		add rdi, 1									;inkrementacja adresu bazowego zdjêcia
		mov al, byte ptr [rsi]						;pobranie do akumulatora sk³adowej R wstawianego zdjêcia
		mov byte ptr [rdi], al						;zapisanie sk³adowej R z akumulatora w zdjêciu bazowym
		sub rsi, 2									;przywrócenie adresu wstawianego zdjêcia
		sub rdi, 2									;przywrócenie adresu bazowego zdjêcia

		skok:										;etykieta nie spe³nionego warunku edycji piksela
		add rsi, 3									;zwiêkszenie adresu zdjêcia wstawianego
		add rdi, 3									;zwiêkszenie adresu zdjêcia bazowego
		add R10, 3									;inkrementacja licznika edytowanego piksela
		jmp loop2									;powrót na pocz¹tek drugiej pêtli wewnêtrznej
	Loop2End:										;etykieta koñca drugiej pêtli wewnêtrznej


	mov widthCounter, 0								;zerowanie licznika bie¿¹cego piksela w rzêdzie
	add heightCounter, 1							;inkrementacja licznika pêtli zewnêtrznej 

	jmp while_loop									;powrót na pocz¹tek pêtli zewnêtrznej
end_while_loop:										;etykieta koñca pêtli zewnêtrznej

out_of_range:										;etykieta b³êdnego adresu przekazanego obrazu

;przywrócenie zawartoœci rejestrów ze stosu
pop R11
pop R10
pop rax
pop rsi
pop rdi
pop rbx

;koniec programu
ret													;koniec wywo³ania funkcji
MyProc1 endp										;koniec procedury MyProc1
end													;koniec program
