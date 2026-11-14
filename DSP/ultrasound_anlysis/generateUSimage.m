function [usImage, referenceAmplitude] = generateUSimage(usRFdata, referenceAmplitude, dynamicRange)
% Envelope detection and log compression along the first (depth) dimension.
% Use the SAME referenceAmplitude for fair comparisons between images.
% generateUSimage(usRFdata) remains valid and normalizes by its own peak.

    if nargin < 2, referenceAmplitude = []; end
    if nargin < 3 || isempty(dynamicRange), dynamicRange = 60; end
    validateattributes(usRFdata, {'numeric'}, ...
        {'2d', 'real', 'finite', 'nonempty'});
    validateattributes(dynamicRange, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'positive'});

    % MATLAB hilbert returns the analytic signal, not just its imaginary part.
    assert(size(usRFdata,1) >= 2, 'At least two depth samples are required.');
    envelope = abs(hilbert(double(usRFdata)));
    if isempty(referenceAmplitude)
        referenceAmplitude = max(envelope(:));
        if referenceAmplitude == 0, referenceAmplitude = 1; end
    end
    validateattributes(referenceAmplitude, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'positive'});

    % Positive floor prevents log10(0), -Inf, and undefined zero/zero values.
    amplitudeFloor = 10^(-dynamicRange/20);
    usImage = 20*log10(max(envelope/referenceAmplitude, amplitudeFloor));
    % Do not clip positive values here; display color limits are set by caller.
end
