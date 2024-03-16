//Projekt JA SSI
//Temat: Łączenie bitmap pomijając niepożądane tło
//Opis algorytmu:
// 1. Inicjalizacja:
// (algorytm powinien operować tylko na częśći wspólnej obu zdjęć)
// -jako licznik pętli zewnętrznej wybieramy wysokość niższego zdjęcia
// -jako licznik pętli wewnętrznej wybieramy szerokość węższego zdjęcia
// 2.Główna pętla programu ->
// -> pętla zewnętrzna iterująca po wierszach obrazu ->
// -> pętla wewnętrzna iterująca po kolejnych pikselach w wierszu ->
// - instrukcja warunkowa - wszystkie składowe piksela mają wartość mniejszą od 20
// tak - skopiuj piksel zdjęcia wstawianego do zdjęcia bazowego
// nie - przejdź do następnego piksela
//06.01.2024 semestr V AEI INF
//Konrad Kobielus
//werja v1.0

#include "pch.h"
#include <iostream>

#define EXPORTED_METHOD extern "C" __declspec(dllexport)

EXPORTED_METHOD
void editPhoto(char* start1, char* end1, char* endPhoto1, int width_1, char* start2, char* end2, char* endPhoto2, int width_2) {
    int widthCounter = 0; //licznik wewnętrznej pętli - iterujący po kolumnach obrazu
    int heightCounter = 0; //licznik zewnęrznej pętli - iterujący po wierszach obrazu
    int currentWidth; 
    int currentHeight; 
    int heightPhoto1; 
    int heightPhoto2;  
    int width1 = width_1 * 3; //liczba kolumn zdjęcia nr 1 
    int width2 = width_2 * 3; //liczba kolumn zdjęcia nr 2

    if (start1 < endPhoto1 && start2 < endPhoto2) {
        currentWidth = min(width1, width2);//szerokość węższego zdjęcia - zakres obszaru do edycji
        heightPhoto1 = min(((endPhoto1 - start1) / width1), ((end1 - start1) / width1));//liczba wiersz obrazu nr 1 przwidziany do edycji w danym wątku 
        heightPhoto2 = min(((endPhoto2 - start2) / width2), ((end2 - start2) / width2));//liczba wiersz obrazu nr 2 przwidziany do edycji w danym wątku 
        currentHeight = min(heightPhoto1, heightPhoto2);//liczba wierszy mniejszego obrazu przwidzianych do edycji w danym wątku

        while (heightCounter < currentHeight) {//pętla przechodząca po wierszach obszaru
            while (widthCounter < currentWidth) {//pętla przechodząca po kolumnach wiersza - kolejnych pikselach
                if (((static_cast<unsigned char>(*(start2 + heightCounter * width2 + widthCounter + 0)) >20) ||//warunek że chociaż jedna składowa piksela ma wartość więszką od dwudziestu
                     (static_cast<unsigned char>(*(start2 + heightCounter * width2 + widthCounter + 1)) > 20) ||
                     (static_cast<unsigned char>(*(start2 + heightCounter * width2 + widthCounter + 2)) > 20))) {
                    *(start1 + heightCounter * width1 + widthCounter) = *(start2 + heightCounter * width2 + widthCounter);
                    *(start1 + heightCounter * width1 + widthCounter + 1) = *(start2 + heightCounter * width2 + widthCounter + 1);
                    *(start1 + heightCounter * width1 + widthCounter + 2) = *(start2 + heightCounter * width2 + widthCounter + 2);
                }
                else
                {
                    int tmp;
                    tmp = widthCounter;
                }
                widthCounter += 3;//inkrementacja o jeden piksel (kolumna R, G, B)
            }
            widthCounter = 0;
            heightCounter++;//inkrementacja o jeden wiersz
        }
    }
}

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
    switch (ul_reason_for_call) {
    case DLL_PROCESS_ATTACH:
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}
