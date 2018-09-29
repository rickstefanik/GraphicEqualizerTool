function EqualizerF(handles)



% Clear out the text box that shows errors whenever
% this function is called.  If an error is encontered,
% this textbox will be updated later in the function.
handles.errorText.String = '';


% Boolean variable that is based on whether or not
% the function is given a valid audio file.
isValid = true;



% This condition is met if the user has typed
% something into the audio text box.
if (length(handles.audioText.String) ~= 0)
    
    % Attempt to read in user's file
    try
        [x, fs] = audioread(handles.audioText.String);

        N = length(x);
        
        % Nyquist Frequency
        fN = fs/2;
        
        % Sampling Period
        Ts = 1/fs;
        
        % Time of clip
        T = N * Ts;
        
        % Time array
        t = 0:Ts:(N-1)*Ts;
        
        % If invalid filename, tell the user via the error text box.
        % isValid is set to false, meaning the rest of the fucntion 
        % will not run.
    catch
        handles.errorText.String = 'Invalid File Name';
        isValid = false;
    end
    
    % If the user does not type anythig into the audio textbox,
    % use a generic singal.
else
    % Time
    T = .1;
    
    % First tone
    f1 = 100;
    
   % Sampling Frequency
    fs = 18000;
    
    % Nyquist Frequency
    fN = fs/2;
    
    % Sampling Period
    Ts = 1/fs;
    
    N = T/Ts;
    
    % Time Array
    t = 0:Ts:(N-1)*Ts;
    
    % First tone
    x = cos(2*pi*f1*t);
    
    % Generates 237 more tones, each 100 Hz higher than the last
    for i=2:88
        x = x + cos(2*pi*(f1 * i) * t);
    end
    
end

% isValid == false when the user enters an invalid file name.
if (isValid == true)
    
    % Number of Tap Coefficients - 1
    M = 300;
    
    % Frequency Array
    f = [0, .05, .06, .1, .11, .2, .21, .3, .31, .4, .41, .60, .61, .8, .81, 1];

    % Frequencies are not even spaced out.  By recommendation from
    % Professor Fuja, since humans hear lower frequencies better, this
    % graphic equalizer allows for finer control for lower frequencies, but
    % in doing so, means not as fine control for higher frequencies.  The
    % "Don't Care" regions are always .01 * fN.
    
    
    % Displays the frequencies of each band for the user
    handles.hz1Text.String = [num2str(round(f(1) * fN)), ' Hz'];
    handles.hz2Text.String = [num2str(round(f(3) * fN)), ' Hz'];
    handles.hz3Text.String = [num2str(round(f(5) * fN)), ' Hz'];
    handles.hz4Text.String = [num2str(round(f(7) * fN)), ' Hz'];
    handles.hz5Text.String = [num2str(round(f(9) * fN)), ' Hz'];
    handles.hz6Text.String = [num2str(round(f(11) * fN)), ' Hz'];
    handles.hz7Text.String = [num2str(round(f(13) * fN)), ' Hz'];
    handles.hz8Text.String = [num2str(round(f(15) * fN)), ' Hz'];
    handles.hz9Text.String = [num2str(fN), ' Hz'];
    
    % Amplitude array
    a = [handles.slider1.Value, handles.slider1.Value, handles.slider2.Value, handles.slider2.Value,...
        handles.slider3.Value, handles.slider3.Value handles.slider4.Value, handles.slider4.Value...
        handles.slider5.Value,handles.slider5.Value,  handles.slider6.Value,...
        handles.slider6.Value,  handles.slider7.Value, handles.slider7.Value, ...
        handles.slider8.Value, handles.slider8.Value];
    
    % Create the filter
    b = firpm(M, f, a);
    
    % Pass the tone through the filter and store it in y
    for n =1:length(x)
        y(n) = 0;
        for k = 0: min(M, n-1)
            y(n) = y(n) + b(k+1)*x(n-k);
            
        end        
    end
    
    % Create fft's and magnitudes
    magx = abs(fft(x));
    magy = abs(fft(y));
    
    freq = [0 : 1/T : (N/2 - 1)/T];
    
    % Based on whether or not the user selects time or frequency domain.
    switch handles.domainMenu.Value
        
        % Frequency Domain
        case 1
            % Plot original tone
            plot(freq, magx(1:N/2), 'Parent', handles.originalAxes);
            title('Original Signal', 'Parent', handles.originalAxes);
            axis(handles.originalAxes, [0, fN, 0, 2.2*max(magx)]);
            xlabel('f (Hz)', 'Parent', handles.originalAxes);
            
            % Plot filtered tone
            plot(freq, magy(1:N/2), 'Parent', handles.filterAxes);
            title('Flitered Signal', 'Parent', handles.filterAxes);
            if (max(magy) > 2.2 * max(magx))
                axis(handles.filterAxes, [0, fN, 0, 2.2*max(magy)]);
            else
                
                axis(handles.filterAxes, [0, fN, 0, 2.2*max(magx)]);
            end
            xlabel('f (Hz)', 'Parent', handles.filterAxes);
            
            % Time Domain
        case 2
            % Plot original tone
            plot(t, x, 'Parent', handles.originalAxes);
            title('Original Signal', 'Parent', handles.originalAxes);
            axis(handles.originalAxes, [0, T, -2*max(x), 2*max(x)]);
            xlabel('t (sec)', 'Parent', handles.originalAxes);
            
            % Plot filtered tone
            plot(t, y, 'Parent', handles.filterAxes);
            title('Flitered Signal', 'Parent', handles.filterAxes);
            if (max(y) > 2 * max(x))
                axis(handles.filterAxes, [0, T, -2*max(y), 2*max(y)]);
            else
                
                axis(handles.filterAxes, [0, T, -2*max(x), 2*max(x)]);
            end
            xlabel('t (sec)', 'Parent', handles.filterAxes);
    end
    
    
    % If play button is hit, play filtered tone.
    if (handles.playButton.Value == 1)
        sound(y, fs);
    end
    
    % If save button is hit, write the filtered file with
    % a name given by the user.
    if (handles.saveButton.Value == 1)
        if (length(handles.saveText.String) ~= 0)
            str1 = handles.saveText.String;
            str2 = char(handles.saveMenu.String(handles.saveMenu.Value));
            name = [str1, str2];
            audiowrite(name, y, fs);
        else
            handles.errorText.String = 'Invalid File Name';
        end
        
    end
end
end
