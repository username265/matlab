function Y = dsp32221004_conv_full(a, b)
    % 두 입력 벡터의 길이 구함
    Nx = length(a);
    Nh = length(b);
    
    % full convolution 결과 벡터의 길이 계산 (N + M - 1)
    Ny = Nx + Nh - 1; 
    
    % 결과를 저장할 벡터를 0으로 초기화
    Y = zeros(1, Ny); 
    
    % 중첩 반복문을 이용한 Convolution 연산 수행
    for i = 1:Nx
        for j = 1:Nh
            Y(i+j-1) = Y(i+j-1) + a(i)*b(j);
        end
    end
end
