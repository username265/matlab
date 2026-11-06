function [usImage, referenceAmplitude] = generateUSimage(usRFdata, referenceAmplitude)
% Ultrasound Envelope Imaging
% 힐버트 변환으로 포락선을 추출하고 정규화 및 로그 압축으로 영상을 생성합니다.
%   imageDB = generateUSimage(rfData)
%   [imageDB, ref] = generateUSimage(rfData)
%   imageDB = generateUSimage(otherRFData, ref)
% Rows: depth samples; columns: sensors. Requires Signal Processing Toolbox.

validateattributes(usRFdata, {'double', 'single'}, ...
    {'2d', 'real', 'finite', 'nonempty'}, mfilename, 'usRFdata');
assert(size(usRFdata, 1) >= 2, 'At least two depth samples are required.');

% 행 방향(깊이 방향)으로 각 센서의 해석 신호와 포락선을 계산합니다.
usBBdata = abs(hilbert(usRFdata));

if nargin < 2 || isempty(referenceAmplitude)
    referenceAmplitude = max(usBBdata(:));
    if referenceAmplitude == 0
        referenceAmplitude = 1;     % 전체가 0인 입력에서 0/0 방지
    end
else
    validateattributes(referenceAmplitude, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'positive'}, mfilename, 'referenceAmplitude');
end

normalizedEnvelope = usBBdata / referenceAmplitude;
% log10(0)으로 -Inf가 생기지 않도록 양의 하한을 적용합니다.
usImage = 20 * log10(max(normalizedEnvelope, eps(class(usBBdata))));
end
