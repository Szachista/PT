% Zadanie 6 - modulacja QPSK i QAM
% Proszę zmienić nazwę funkcji na postać Lab6_Imię_Nazwisko

function Lab6
	clc
	close all

	data = [0 0 1 0 0 1 1 1];
	Tb = 0.125;
	Fs = 1024;
	t = 1/Fs:1/Fs:length(data)*Tb;
	f = 2/Tb;
	data2 = repmat(data, Tb*Fs, 1);

	[di, dq] = decompose_data(data, Tb, Fs);
	qpsk_signal = qpsk_modulator(t, di, dq, f);
	noisy_qpsk_signal = qpsk_signal + 2.0*randn(size(t));
	[detected, det_i, det_q] = qpsk_demodulator(t, noisy_qpsk_signal, f, Tb, Fs);
	figure('Name', 'QPSK')
	subplot(5, 1, 1)
	plot(t, qpsk_signal)
	title(num2str(data))
	subplot(5, 1, 2)
	stairs(t, noisy_qpsk_signal)
	subplot(5, 1, 3)
	stairs(t, det_i)
	subplot(5, 1, 4)
	stairs(t, det_q)
	subplot(5, 1, 5)
	stairs(t, detected, 'Color', 'r')
	hold on
	stairs(t, 2*data2(:)'-1, 'Color', 'g', 'LineStyle', '--')
	hold off

	data = [0 0 0 0 1 0 0 0 0 1 0 0 1 1 0 0 0 0 1 0 1 0 1 0 0 1 1 0 1 1 1 0 0 0 0 1 1 0 0 1 0 1 0 1 1 1 0 1 0 0 1 1 1 0 1 1 0 1 1 1 1 1 1 1];
	t = 1/Fs:1/Fs:length(data)*Tb;
	data2 = repmat(data, Tb*Fs, 1);
	qam_signal = qam16_modulator(t, data, f, Tb, Fs);
	noisy_qam_signal = qam_signal + 4.0*randn(size(t));
	[detected, det_i, det_q] = qam16_demodulator(t, noisy_qam_signal, f, Tb, Fs);
	figure('Name', '16-QAM')
	subplot(5, 1, 1)
	plot(t, qam_signal)
	title(num2str(data))
	subplot(5, 1, 2)
	stairs(t, noisy_qam_signal)
	subplot(5, 1, 3)
	stairs(t, det_i)
	subplot(5, 1, 4)
	stairs(t, det_q)
	subplot(5, 1, 5)
	stairs(t, detected, 'Color', 'r')
	hold on
	stairs(t, 2*data2(:)'-1, 'Color', 'g', 'LineStyle', '--')
	hold off
end

function y = ode(dy, y0, h)
	y = [y0, y0 + dy(1)*h, y0 + dy(1)*h + 0.5*h*cumsum(3*dy(2:end-1) - dy(1:end-2))];
end

function [data_i, data_q] = decompose_data(data, Tb, Fs)
	% obliczyć liczbę próbek (na podstawie Tb i Fs)
	% przypadającą na pojedynczy bit
	N = 0;

	data_i = zeros(1, N * length(data));
	data_q = zeros(1, N * length(data));

	for i = 2:2:length(data)
		data_i((i - 2) * N + 1:i * N) = 2 * data(i - 1) - 1;
		data_q((i - 2) * N + 1:i * N) = 2 * data(i) - 1;
	end
end

function s = qpsk_modulator(t, data_i, data_q, f)
	% obliczyć sygnał zmodulowany
	s = [];
end

function [detected, detected_i, detected_q] = qpsk_demodulator(t, data, f, Tb, Fs)
	% obliczyć liczbę próbek (na podstawie Tb i Fs)
	% przypadającą na pojedynczy bit
	N = 0;

	detected = zeros(size(data));
	detected_i = zeros(size(data));
	detected_q = zeros(size(data));

	% przemnożyć sygnał wejściowy przez odpowiednie nośne
	i_component = [];
	q_component = [];

	i = 1;
	h = t(2)-t(1);
	while i < length(data)
		integrated_i = ode(i_component(i:i+2*N-1), 0, h) * 0.5*f;
		integrated_q = ode(q_component(i:i+2*N-1), 0, h) * 0.5*f;

		detected_i(i:i+2*N-1) = integrated_i;
		detected_q(i:i+2*N-1) = integrated_q;

		% zliczyć liczbę próbek większych od 0 w scałkowanych sygnałach
		% i porównać z N
		detected(i:i+N-1) = 0;
		detected(i+N:i+2*N-1) = 0;

		i = i + 2*N;
	end
	detected = 2*detected-1;
end

function s = qam16_modulator(t, data, f, Tb, Fs)
	% obliczyć liczbę próbek (na podstawie Tb i Fs)
	% przypadającą na pojedynczy bit
	N = 0;

	i_component = zeros(1, length(data) * N);
	q_component = zeros(1, length(data) * N);

	% wypełnić tablice odpowiednimi wartościami amplitud
	I = [];
	Q = [];

	LUT = [I; Q];
	m = 1;
	for i = 1:4:length(data)
		idx = data(i:i+3) * [1; 2; 4; 8] + 1;
		i_component(m:(m+4*N-1)) = LUT(1, idx)*cos(2*pi*f*t(m:(m+4*N-1)));
		q_component(m:(m+4*N-1)) = LUT(2, idx)*sin(2*pi*f*t(m:(m+4*N-1)));
		m = m + 4*N;
	end

	% obliczyć sygnał zmodulowany
	s = [];
end

function [detected, detected_i, detected_q] = qam16_demodulator(t, data, f, Tb, Fs)
	% obliczyć liczbę próbek (na podstawie Tb i Fs)
	% przypadającą na pojedynczy bit
	N = 0;

	% wypełnić tablice odpowiednimi wartościami amplitud (jak w poprzedniej
	% funkcji)
	I = [];
	Q = [];

	LUT = [I; Q];

	% wypełnić macierz, tak aby w kolejnych wierszach znajdowały się
	% kolejne liczby naturalne w systemie dwójkowym; pierwsza kolumna
	% powinna zawierać najmniej znaczący bit, natomiast czwarta kolumna
	% powinna zawierać najbardziej znaczący bit
	% hexit = [0 0 0 0
	%     1 0 0 0 itd.
	hexit = [];

	detected = zeros(size(data));
	detected_i = zeros(size(data));
	detected_q = zeros(size(data));

	% przemnożyć sygnał wejściowy przez odpowiednie nośne
	i_component = [];
	q_component = [];

	i = 1;
	h = t(2)-t(1);
	while i < length(data)
		integrated_i = ode(i_component(i:i+4*N-1), 0, h) * 0.25*f;
		integrated_q = ode(q_component(i:i+4*N-1), 0, h) * 0.25*f;

		detected_i(i:i+4*N-1) = integrated_i;
		detected_q(i:i+4*N-1) = integrated_q;

		% obliczyć wartości składowych jako sumę najmniejszej i największej
		% próbki w scałkowanych sygnałach
		i_detected = 0;
		q_detected = 0;

		% znaleźć indeks punktu konstelacji, który znajduje się najbliżej
		% wyliczonego punktu
		n = 1;

		digit = repmat(hexit(n, :), N, 1);
		detected(i:i+4*N-1) = 2*digit(:)'-1;

		i = i + 4*N;
	end
end
