/*
 * Proszę zmienić nazwę pliku do postaci Lab7_Imię_Nazwisko.cpp
 */

#include <iostream>
#include <fstream>
#include <vector>
#include <cstdlib>
#include <cstring>
#include <ctime>
using namespace std;

/*
 * Napisać funkcję zwracającą najmniej znaczący półbajt
 * (4 mniej znaczące bity). Innymi słowy dla liczby
 * 01101001_2 (105_10) powinna zwrócić wartość 00001001_2 (9_10).
 */
inline unsigned char lo(unsigned char byte)
{
	return 0;
}

/*
 * Napisać funkcję zwracającą najbardziej znaczący półbajt
 * (4 bardziej znaczące bity). Innymi słowy dla liczby
 * 01101001_2 (105_10) powinna zwrócić wartość 00000110_2 (6_10).
 */
inline unsigned char hi(unsigned char byte)
{
	return 0;
}

/*
 * Napisać funkcję, która koduje półbajt z wykorzystaniem kodu Hamminga.
 * Innymi słowy dla liczby 00001011_2 (11_10) należy zwrócić
 * wartość 01010101_2 (85_10).
 */
unsigned char encode_hamming(unsigned char nibble)
{
	return 0;
}

/*
 * Napisać funkcję, która dekoduje liczbę, dokonując w razie potrzeby
 * korekcji bitu. Innymi słowy zarówno dla liczby 01010101_2 (85_10)
 * jak i 01000101_2 (69_10) funkcja powinna zwrócić wartość
 * 00001011_2 (11_10).
 */
unsigned char decode_hamming(unsigned char byte)
{
	return 0;
}

int main()
{
	// zmienić nazwę pliku (tak jak na początku) bądź wskazać inny plik
	ifstream in("Lab7.cpp", ios::in | ios::binary);
	vector<unsigned char> data, hamming, decoded;

	if (!in)
	{
		cout << "Niepowodzenie przy otwieraniu pliku!" << endl;
		return 1;
	}

	srand(time(NULL));

	in.seekg(0, ios::end);
	data.resize(in.tellg());
	hamming.resize(2*data.size());
	decoded.resize(data.size());
	in.seekg(0, ios::beg);

	in.read((char*)&data.front(), data.size());
	in.close();

	for (int i = 0; i < data.size(); i++)
	{
		hamming[2*i] = encode_hamming(lo(data[i]));
		hamming[2*i+1] = encode_hamming(hi(data[i]));
	}

	for (int i = 0; i < hamming.size(); i++)
		hamming[i] ^= 1 << (rand() % 7);

	for (int i = 0; i < hamming.size(); i+= 2)
		decoded[i/2] = decode_hamming(hamming[i]) + 16*decode_hamming(hamming[i+1]);

	if (memcmp(&data.front(), &decoded.front(), data.size()) != 0)
		cout << "Niepowodzenie!" << endl;
	else
		cout << "Sukces!" << endl;

	return 0;
}
