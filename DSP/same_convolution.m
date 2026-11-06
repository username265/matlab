function Y = dsp32221004_conv_same(a, b)

    % 전에 직접 만든 full convolution 함수 호출
    full_conv = dsp32221004_conv_full(a, b);
    
    Nx = length(a);
    Nh = length(b);
    
    % 'same' 옵션은 첫 번째 배열과 크기가 같음 > 중앙부를 추출
    % 중앙부 추출하기 위해서 시작 인덱스 계산
    start_idx = floor(Nh / 2) + 1;
    
    % 시작 인덱스부터 Nx 길이만큼 추출
    Y = full_conv(start_idx : start_idx + Nx - 1);
end
