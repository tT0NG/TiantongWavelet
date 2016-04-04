function varargout = iPAL_denoiseBox(varargin)
% IPAL_DENOISEBOX MATLAB code for iPAL_denoiseBox.fig
%      IPAL_DENOISEBOX, by itself, creates a new IPAL_DENOISEBOX or raises the existing
%      singleton*.
%
%      H = IPAL_DENOISEBOX returns the handle to a new IPAL_DENOISEBOX or the handle to
%      the existing singleton*.
%
%      IPAL_DENOISEBOX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IPAL_DENOISEBOX.M with the given input arguments.
%
%      IPAL_DENOISEBOX('Property','Value',...) creates a new IPAL_DENOISEBOX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before iPAL_denoiseBox_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to iPAL_denoiseBox_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Last Modified by GUIDE v2.5 03-Apr-2016 20:10:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @iPAL_denoiseBox_OpeningFcn, ...
    'gui_OutputFcn',  @iPAL_denoiseBox_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% -----------------UNSED    OUTPUT---------------------- %
function varargout = iPAL_denoiseBox_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

% ==================================== %
%                       DEFAULT VALUES                             %
% ==================================== %
function iPAL_denoiseBox_OpeningFcn(hObject, eventdata, handles, varargin)
%------------------------------------------------------- %
%          1                        LAWML                       %
%          2                        LAWMAP                    %
% Choose default command line output for iPAL_denoiseBox
handles.output = hObject;
handles.wavelet_type = 'db1';  % default wavelet db1
handles.level_num = 3;            % default wavelet level 3
handles.window_size = 3;        % default window size 3
handles.threshold = 30;            % default threshold 30
handles.reduce_factor = 0.25;  % default reduce factor 1/4
handles.lambda = 0;                 % default lambda value 0
handles.image_loaded = false;            % image loaded False
handles.noise_added = false;              % noise add false
handles.MLed = false;              % LAWML flag False
handles.denoised_done = false;               % finish flag False
handles.wavelet_done = false;                  % finish wavelet flag False
handles.mode_selected = false;
handles.threshold_mode = 1 ;                   % default threshold mode 1 = soft
handles.windows = [];                               % default windows set empty []
handles.record_book = {};             % initial record book
handles.record_image = '';
handles.record_sigman = '';
handles.record_waveletlevel = '';
handles.record_wavelettype = '';
handles.record_mode = '';
handles.record_para = '';
handles.record_psnr = '';
handles.denoise_mode = -1;

handles.methodsBook = [{'LAWML'}; {'LAWMAP'}; {'LAWW'};...
                       {'HARD'}; {'SOFT'}; {'VISU SHRINK'};...
                       {'BAYES SHRINK'}; {'SURE SHRINK'}; ...
                       {'NEIGH SHRINK'}; {'NEIGH SHRINK modified'};...
                       {'WIENER'}; {'FourierThreshold'}];

set(handles.parameter_slider, 'Visible', 'On');                     % show size bar
set(handles.parameter_name,'Visible','On');          % show size label
set(handles.image_panel,'Visible','On');        % show image panel
set(handles.wavelet_panel,'Visible','On');      % show wavelet panel
set(handles.msg,'Visible','off');                        % hide warning message
set(handles.parameter_slider, 'Visible', 'off');                     % hide size bar
set(handles.parameter_name,'Visible','off');          % hide size label
set(handles.mode_display,'Visible','off');
set(handles.parameter_display,'Visible','off');          % hide size label
set(handles.soft_mode,'Visible','Off');
set(handles.soft_mode,'Value',1);
set(handles.hard_mode,'Visible','Off');
set(handles.hard_mode,'Value',0);
set(handles.windows_panel,'Visible','Off');                 % hide windows panel

axes(handles.axes5);
pa = get(gca, 'Position');
logo = imread('iPAL_long.png');
% logo2 = imresize(logo,0.4);
size(logo)
imshow(logo);

guidata(hObject, handles);                            % Update handles structure

% ==================================== %
%                               LODA IMAGE                              %
% ==================================== %
function load_image_Callback(hObject, eventdata, handles)
% hObject    handle to load_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
contents = cellstr(get(hObject,'String'));
handles.original_image = imread(contents{get(hObject,'Value')});
if size(handles.original_image,3) == 3
    handles.original_image = rgb2gray(handles.original_image); % rgb to gray for color image
end
oim = imshow(handles.original_image);
% imshow(handles.original_image); % plot image

handles.record_image = contents{get(hObject,'Value')};

handles.MLed = false;
handles.image_loaded = true;
handles.noise_added = false;
handles.wavelet_done = false;
set(handles.WaveletFlag, 'String', ' Wavelet NOT DONE');
set(handles.WaveletFlag, 'BackgroundColor', [1 0.694 0.392]);
set(oim,'uicontextmenu',handles.Show);
set(oim,'Tag','O');
guidata(hObject, handles);  % updatet the handles

% ==================================== %
%                                    AWGN                                      %
% ==================================== %
function add_noise_Callback(hObject, eventdata, handles)
% [noisy_image] = addingNoise (original_image, sigman,plot_option)
handles.sigman = get(handles.AWGN_sigman,'Value')*50;
% get sigman from the slider bar
set(handles.sigman_display,'String',['Sigman = ', num2str(handles.sigman)]);
% display the sigman
if handles.image_loaded
    handles.noisy_image = addingNoise (handles.original_image, handles.sigman, false);
    % self defined adding AWGN with the sigman
    axes(handles.axes2);                               % take the axes handle
    nim = imshow(uint8(handles.noisy_image));   % plot the noisy image
    set(nim,'uicontextmenu',handles.Show);
    set(nim,'Tag','N');
    handles.noise_added = true;
    handles.denoised_done = false;
    set(handles.WaveletFlag, 'String', ' Wavelet NOT DONE');
    set(handles.WaveletFlag, 'BackgroundColor', [1 0.694 0.392]);
end
handles.MLed = false;
handles.wavelet_done = false;
guidata(hObject, handles)                       % update the handles

function AWGN_sigman_Callback(hObject, eventdata, handles)
% hObject    handle to AWGN_sigman (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ==================================== %
%                               DWT PART                                   %
% ==================================== %
function level_select_Callback(hObject, eventdata, handles)
contents = cellstr(get(hObject,'String'));
handles.level_num = str2double(contents{get(hObject,'Value')});
% select thelevel number from the list
% level = {3,4,5,6,7}
if handles.image_loaded && handles.noise_added
    set(handles.Level_Type_display,'String',['Levels = ', num2str(handles.level_num), ' Wavelet = ', handles.wavelet_type]);
    [handles.A,handles.H,handles.V,handles.D] = multiLevelDWT(handles.noisy_image,handles.level_num, handles.wavelet_type);
    % display the level numbers
    handles.wavelet_done = true;     % wavelet flag
    set(handles.WaveletFlag, 'String','Wavelet DONE');
    set(handles.WaveletFlag, 'BackgroundColor',[0 0.6 0.8]);
end
handles.MLed = false;
handles.denoised_done = false;
guidata(hObject, handles)                              % update the handles

% ------------------type & level display-----------------%
function wavelet_type_list_Callback(hObject, eventdata, handles)
%  get(hObject,'Value') returns position of slider
%  get(hObject,'Min') and get(hObject,'Max') to determine range of slider
contents = cellstr(get(hObject,'String'));
handles.wavelet_type = contents{get(hObject,'Value')};
if handles.image_loaded && handles.noise_added
    set(handles.Level_Type_display,'String',['Levels = ',num2str(handles.level_num), ' Wavelet = ', handles.wavelet_type]);
    [handles.A,handles.H,handles.V,handles.D] = multiLevelDWT(handles.noisy_image,handles.level_num, handles.wavelet_type);
    handles.wavelet_done = true;             % wavelet flag
    set(handles.WaveletFlag, 'String','Wavelet DONE');
    set(handles.WaveletFlag, 'BackgroundColor',[0 0.6 0.8]);
end
handles.MLed = false;
handles.denoised_done = false;
guidata(hObject, handles)                              % update the handles

% ==================================== %
%                               CORE PART                                 %
% ==================================== %
function de_noise_Callback(hObject, eventdata, handles)
% denoise image according to the MODECODE
% --------------------------------------------------- %
%               1              LAWML                        %
%               2              LAWMAP                      %
%               3              LAWW                     %
%            -------------------------------------         %
%               4              HARD                            %
%               5              SOFT                              %
%            -------------------------------------         %
%               6              BAYESSHRINK            %
%               7              SURESHRINK               %
%               8              VISUSHRINK                %
%               9              NEIGH SHRINK            %
%               10             Neigh Shrink Modified       %
%            -------------------------------------         %
%
%               11              WIENER                       %
%            -------------------------------------
%               12              Fourier Trans Threshold
if (handles.wavelet_done || handles.denoise_mode == 12) && handles.image_loaded &&  handles.noise_added && handles.mode_selected
    % after the image loaded -> nose added -> wavelet transform done ->
    % mode selected done
    % ready for denoising task according the denoise mode
    %----------------------------------------------------------------------------------------------------
    if handles.denoise_mode == 1
        handles.MLed = true;
        [a, h, v, d, handles.lambda] = MLE_MMSE(handles.A,handles.H,handles.V,handles.D, handles.level_num, handles.sigman,handles.window_size); % the MLE will also return the lambda value
        % LAWML defualt method
        denoised_image = image_denois(a, h, v, d, size(handles.noisy_image),handles.wavelet_type);
        handles.record_para = ['WinSize=',num2str(handles.window_size)];
        handles.denoised_done = true;              % denoise finished flag
        %------------------------------------------------------------------------------------------------
    elseif handles.denoise_mode == 2 && handles.MLed % special method % need LAWML results
        [a, h, v, d] = MAP_MMSE(handles.A, handles.H, handles.V, handles.D, handles.level_num, handles.sigman,handles.window_size, handles.lambda);
        % LAWMAP need the results from LAWML, using LAWMAP with the same parameters as the LAWML
        denoised_image = image_denois(a, h, v, d, size(handles.noisy_image),handles.wavelet_type);
        handles.record_para = ['WinSize=',num2str(handles.window_size)];
        handles.denoised_done = true;              % denoise finished flag
        %------------------------------------------------------------------------------------------------
    elseif handles.denoise_mode == 3
        % LAWW
        [a, h, v, d] = ADAPTIVE_MMSE(handles.A, handles.H, handles.V, handles.D, handles.level_num, handles.sigman, handles.windows,200); % the MLE will also return the lambda value
        denoised_image = image_denois(a, h, v, d, size(handles.noisy_image),handles.wavelet_type);
        handles.record_para = ['Wins=[', num2str(handles.windows),']'];
        handles.denoised_done = true;              % denoise finished flag
        %------------------------------------------------------------------------------------------------
    elseif handles.denoise_mode == 4
        [a, h, v, d] = HARD_THRESHOLD(handles.A, handles.H, handles.V, handles.D, handles.level_num, handles.threshold);
        % hard thresholding method
        denoised_image = image_denois(a, h, v, d, size(handles.noisy_image),handles.wavelet_type);
        handles.record_para = ['T=',num2str(handles.threshold)];
        handles.denoised_done = true;              % denoise finished flag
        %------------------------------------------------------------------------------------------------
    elseif handles.denoise_mode == 5
        [a, h, v, d] = SOFT_THRESHOLD(handles.A, handles.H, handles.V, handles.D, handles.level_num, handles.threshold);
        % soft thresholding method
        denoised_image = image_denois(a, h, v, d, size(handles.noisy_image),handles.wavelet_type);
        handles.record_para = ['T=',num2str(handles.threshold)];
        handles.denoised_done = true;              % denoise finished flag
        %------------------------------------------------------------------------------------------------
    elseif handles.denoise_mode == 6
        [a,h,v,d] = VISU_SHRINK (handles.A,handles.H, handles.V, handles.D, handles.level_num,handles.sigman, handles.reduce_factor, handles.threshold_mode);
        % Visu shrink method  % threshold_mode: 1 = soft; 0 = hard
        denoised_image = image_denois(a, h, v, d, size(handles.noisy_image),handles.wavelet_type);
        handles.record_para = ['S/H=', num2str(handles.threshold_mode),'/ F=',num2str(handles.reduce_factor)];
        handles.denoised_done = true;              % denoise finished flag
        %------------------------------------------------------------------------------------------------
    elseif handles.denoise_mode == 7
        [a,h,v,d] = BAYES_SHRIK (handles.A, handles.H, handles.V, handles.D, handles.level_num, handles.threshold_mode);
        % bayes shrink method  % threshold_mode: 1 = soft; 0 = hard
        denoised_image = image_denois(a, h, v, d, size(handles.noisy_image),handles.wavelet_type);
        handles.record_para = ['S/H=',num2str(handles.threshold_mode)];
        handles.denoised_done = true;              % denoise finished flag
        %------------------------------------------------------------------------------------------------
    elseif handles.denoise_mode == 8
        [a,h,v,d] = SURE_SHRINK (handles.A,handles.H,handles.V,handles.D,handles.level_num, handles.sigman, handles.threshold_mode);
        % SURE shrink method  % threshold_mode: 1 = soft; 0 = hard
        denoised_image = image_denois(a, h, v, d, size(handles.noisy_image),handles.wavelet_type);
        handles.record_para = ['S/H=',num2str(handles.threshold_mode)];
        handles.denoised_done = true;              % denoise finished flag
        %------------------------------------------------------------------------------------------------
    elseif handles.denoise_mode == 9
        [a,h,v,d] = NEIGH_SHRINK (handles.A, handles.H, handles.V, handles.D, numel(handles.noisy_image),handles.window_size, handles.sigman);
        % Neigh Shrink with window size and the total coefficients number, also the noise information
        denoised_image = image_denois(a, h, v, d, size(handles.noisy_image),handles.wavelet_type);
        handles.record_para = ['WinSize=', num2str(handles.window_size)];
        handles.denoised_done = true;              % denoise finished flag
        %------------------------------------------------------------------------------------------------
    elseif handles.denoise_mode == 10
        if size(handles.windows,2) == 0
            handles.windows = [3];
            % default window
        end
        % handles.windows
        [a,h,v,d,~] = NEIGH_SHRINK_ADAPTIVE (handles.A, handles.H, handles.V, handles.D,numel(handles.noisy_image),handles.windows,handles.sigman);
        % modefied Neigh Shrink
        denoised_image = image_denois(a, h, v, d, size(handles.noisy_image),handles.wavelet_type);
        handles.record_para = ['Wins=[', num2str(handles.windows),']'];
        handles.denoised_done = true;              % denoise finished flag
    elseif handles.denoise_mode == 12
        denoised_image = FOURIER_DENOISE(handles.noisy_image, handles.threshold);
        handles.record_para = ['T=[', num2str(handles.threshold),']'];
        handles.denoised_done = true;              % denoise finished flag
    end
end
%------------------------------------------------------------------------------------------------
if handles.image_loaded &&  handles.noise_added && handles.mode_selected && handles.denoise_mode == 11
    denoised_image = wiener2(handles.noisy_image,[handles.window_size handles.window_size]);
    % Wiener Filter @ MATLAB build in function with local estimation
    handles.record_para = ['WinSize=',num2str(handles.window_size)];
    handles.denoised_done = true;              % denoise finished flag
    
end

if handles.denoised_done
    % ready to plot results
    axes(handles.axes3);
    dim = imshow(denoised_image,[0,255]);
    % plot defference
    axes(handles.axes4);
    % class(denoised_image)             % debug handles
    % class(handles.original_image)  % debug handles
    eim = imshow(uint8(wcodemat(wcodemat(denoised_image,255) - double(handles.original_image),255)));
    handles.psnr = PSNR(handles.original_image, denoised_image);
    handles.denoised_image_passing =  denoised_image;
    set(handles.PSNR_display,'String',['PSNR = ', num2str(handles.psnr)]);
    set(dim,'uicontextmenu',handles.Show);
    set(dim,'Tag','D');
    set(eim,'uicontextmenu',handles.Show);
    set(eim,'Tag','E');
    handles.record_sigman = num2str(handles.sigman);
    handles.record_waveletlevel = num2str(handles.level_num);
    handles.record_wavelettype = num2str(handles.wavelet_type);
    handles.record_mode = num2str(handles.denoise_mode);
    handles.record_psnr = num2str(handles.psnr);
    handles.record = [handles.record_image,'   ', ...
        'Sigman=',handles.record_sigman,'   ',...
        'WaveletLevel=',handles.record_waveletlevel,'   ',...
        'Wavelet=',handles.record_wavelettype,'   ',...
        'Mode=',handles.methodsBook{handles.denoise_mode},'   ',...
        'Parameter:',handles.record_para,'   ',...
        'PSNR=', handles.record_psnr];
    
    handles.record_book = [handles.record_book; handles.record];
    % record this denoise task in the record book
end
% handles.denoised_done = false;       % waitingfor next denoise task
guidata(hObject, handles);                              % update the handles

% -------------------MODE SELECT---------------------------
function METHODS_Callback(hObject, eventdata, handles)
% hObject    handle to METHODS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.denoised_done = false;
set(handles.mode_display,'Visible','On');
guidata(hObject, handles);                              % update the handles

% ---------------------mode code = 1--------------------------
function LAWML_Callback(hObject, eventdata, handles)
% MLE_MMSE(A,H,V,D, level_num, sigman,window_size);
% the MLE will also return the lambda value
handles.denoise_mode = 1;
handles.mode_selected = true;

set(handles.mode_display,'String','LAWML');     % mode name display

set(handles.image_panel,'Visible','On');           % show image panel
set(handles.wavelet_panel,'Visible','On');         % show wavelet panel
set(handles.mode_display,'Visible','on');          % show mode name
set(handles.parameter_slider, 'Visible', 'On');  % show size bar
set(handles.parameter_name,'Visible','On');    % show size label
set(handles.parameter_display,'Visible','On');  % parameter display
set(handles.soft_mode,'Visible','Off');
set(handles.hard_mode,'Visible', 'Off');            % hide threhold mode
set(handles.windows_panel,'Visible','Off');                 % hide windows panel

set(handles.parameter_name,'String','Window Size'); % special parameter name
set(handles.parameter_display,'String',num2str(handles.window_size));      % threshold default display
set(handles.msg,'Visible','off');                              % hide warning message



guidata(hObject, handles)                              % update the handles

% ---------------------mode code = 2--------------------------
function LAWMAP_Callback(hObject, eventdata, handles)
% MAP_MMSE(A,H,V,D, level_num, sigman,window_size, lambda);
handles.denoise_mode = 2;
handles.mode_selected = true;

set(handles.mode_display,'String','LAWMAP');   % mode name display

set(handles.parameter_slider, 'Visible', 'off');        % hide size bar
set(handles.parameter_name,'Visible','off');          % hide size label
set(handles.image_panel,'Visible','off');                 % hide image panel
set(handles.wavelet_panel,'Visible','off');               % hide wavelet panel
set(handles.parameter_display,'Visible','off');       % parameter display
set(handles.soft_mode,'Visible','Off');
set(handles.hard_mode,'Visible', 'Off');                 % hide threhold mode
set(handles.windows_panel,'Visible','Off');                 % hide windows panel

if ~handles.MLed
    set(handles.msg,'Visible','on');                       % info user the LAWMAP need LAWML first
else
    set(handles.msg,'Visible','off');
end
guidata(hObject, handles)                              % update the handles

% ----------------------mode code = 3--------------------------
function LAWW_Callback(hObject, eventdata, handles)
handles.denoise_mode = 3;
handles.mode_selected = true;

set(handles.mode_display,'String','LAW Window');     % mode name display

set(handles.image_panel,'Visible','On');           % show image panel
set(handles.wavelet_panel,'Visible','On');         % show wavelet panel
set(handles.mode_display,'Visible','on');          % show mode name
set(handles.parameter_slider, 'Visible', 'On');  % show size bar
set(handles.parameter_name,'Visible','On');    % show size label
set(handles.parameter_display,'Visible','On');  % parameter display
set(handles.soft_mode,'Visible','Off');
set(handles.hard_mode,'Visible', 'Off');            % hide threhold mode
set(handles.parameter_slider, 'Visible', 'off');        % hide size bar
set(handles.parameter_name,'Visible','off');          % hide size label
set(handles.parameter_display,'Visible','off');       % parameter display
set(handles.windows_panel,'Visible','On');                  % show windows panel

set(handles.parameter_name,'String','Window Size'); % special parameter name
set(handles.parameter_display,'String',num2str(handles.window_size));      % threshold default display
set(handles.msg,'Visible','off');                              % hide warning message

guidata(hObject, handles)                              % update the handles

% ------------------------mode code = 4---------------------
function HARD_Callback(hObject, eventdata, handles)
handles.denoise_mode = 4;
handles.mode_selected = true;

set(handles.mode_display,'String','HARD Threshold');     % mode name display

set(handles.image_panel,'Visible','On');           % show image panel
set(handles.wavelet_panel,'Visible','On');         % show wavelet panel
set(handles.mode_display,'Visible','on');          % show mode name
set(handles.parameter_slider, 'Visible', 'On');  % show size bar
set(handles.parameter_name,'Visible','On');    % show size label
set(handles.parameter_display,'Visible','On');  % parameter display
set(handles.soft_mode,'Visible','Off');
set(handles.hard_mode,'Visible', 'Off');             % hide threhold mode
set(handles.windows_panel,'Visible','Off');                 % hide windows panel

set(handles.parameter_name,'String','Threshold'); % special parameter name
handles.threshold = 10;
set(handles.parameter_display,'String',num2str(handles.threshold));      % threshold default display
set(handles.msg,'Visible','off');                              % hide warning message
guidata(hObject, handles)                              % update the handles

% ------------------------mode code = 5-----------------------
function SOFT_Callback(hObject, eventdata, handles)
handles.denoise_mode = 5;
handles.mode_selected = true;

set(handles.mode_display,'String','SOFT Threshold');     % mode name display

set(handles.image_panel,'Visible','On');             % show image panel
set(handles.wavelet_panel,'Visible','On');          % show wavelet panel
set(handles.mode_display,'Visible','on');            % show mode name
set(handles.parameter_slider, 'Visible', 'On');    % show size bar
set(handles.parameter_name,'Visible','On');      % show size label
set(handles.parameter_display,'Visible','On');    % parameter display
set(handles.soft_mode,'Visible','Off');
set(handles.hard_mode,'Visible', 'Off');             % hide threhold mode
set(handles.windows_panel,'Visible','Off');                 % hide windows panel

set(handles.parameter_name,'String','Threshold'); % special parameter name
handles.threshold = 10;
set(handles.parameter_display,'String',num2str(handles.threshold));      % threshold default display
set(handles.msg,'Visible','off');                           % hide warning message
guidata(hObject, handles)                                  % update the handles

% ----------------------------mode code = 6----------------------
function VISU_SHRINK_Callback(hObject, eventdata, handles)
handles.denoise_mode = 6;
handles.mode_selected = true;

set(handles.mode_display,'String','Visu Shrink');     % mode name display

set(handles.image_panel,'Visible','On');           % show image panel
set(handles.wavelet_panel,'Visible','On');         % show wavelet panel
set(handles.mode_display,'Visible','on');          % show mode name
set(handles.parameter_slider, 'Visible', 'On');  % hide size bar
set(handles.parameter_name,'Visible','On');    % hide size label
set(handles.parameter_display,'Visible','On');  % hide parameter display
set(handles.soft_mode,'Visible','On');
set(handles.hard_mode,'Visible', 'On');             % threhold mode
set(handles.windows_panel,'Visible','Off');                 % hide windows panel

set(handles.parameter_name,'String','Factor'); % special parameter name
set(handles.parameter_display,'String',num2str(handles.reduce_factor));      % threshold default display
set(handles.msg,'Visible','off');                              % hide warning message
guidata(hObject, handles)                              % update the handles

% ---------------------------mode code = 7------------------------
function BAYES_SHRIK_Callback(hObject, eventdata, handles)
handles.denoise_mode = 7;
handles.mode_selected = true;

set(handles.mode_display,'String','Bayes Shrink');     % mode name display

set(handles.image_panel,'Visible','On');           % show image panel
set(handles.wavelet_panel,'Visible','On');         % show wavelet panel
set(handles.mode_display,'Visible','on');          % show mode name
set(handles.parameter_slider, 'Visible', 'Off');  % hide size bar
set(handles.parameter_name,'Visible','Off');    % hide size label
set(handles.parameter_display,'Visible','Off');  % hide parameter display
set(handles.soft_mode,'Visible','On');
set(handles.hard_mode,'Visible', 'On');             % threhold mode
set(handles.windows_panel,'Visible','Off');                 % hide windows panel

set(handles.msg,'Visible','off');                         % hide warning message
guidata(hObject, handles)                                % update the handles

% -----------------------------mode code = 8--------------------
function SURE_SHRINK_Callback(hObject, eventdata, handles)
handles.denoise_mode = 8;
handles.mode_selected = true;

set(handles.mode_display,'String','SURE Shrink');     % mode name display

set(handles.image_panel,'Visible','On');           % show image panel
set(handles.wavelet_panel,'Visible','On');         % show wavelet panel
set(handles.mode_display,'Visible','on');          % show mode name
set(handles.parameter_slider, 'Visible', 'Off');  % hide size bar
set(handles.parameter_name,'Visible','Off');    % hide size label
set(handles.parameter_display,'Visible','Off');  % hide parameter display
set(handles.soft_mode,'Visible','On');
set(handles.hard_mode,'Visible', 'On');             % threhold mode
set(handles.windows_panel,'Visible','Off');                 % hide windows panel

set(handles.msg,'Visible','off');                          % hide warning message
guidata(hObject, handles)                                 % update the handles

% ----------------------------mode code = 9----------------------
function NEIGH_SHRINK_Callback(hObject, eventdata, handles)
handles.denoise_mode = 9;
handles.mode_selected = true;

set(handles.mode_display,'String','Neigh Shrink');     % mode name display

set(handles.image_panel,'Visible','On');           % show image panel
set(handles.wavelet_panel,'Visible','On');         % show wavelet panel
set(handles.mode_display,'Visible','on');          % show mode name
set(handles.parameter_slider, 'Visible', 'On');  % show size bar
set(handles.parameter_name,'Visible','On');    % show size label
set(handles.parameter_display,'Visible','On');  % parameter display
set(handles.soft_mode,'Visible','Off');
set(handles.hard_mode,'Visible', 'Off');            % hide threhold mode
set(handles.windows_panel,'Visible','Off');                 % hide windows panel

set(handles.parameter_name,'String','Window Size'); % special parameter name
set(handles.parameter_display,'String',num2str(handles.window_size));      % threshold default display
set(handles.msg,'Visible','off');                              % hide warning message
guidata(hObject, handles)                              % update the handles

% ----------------------------mode code = 10----------------------
function NEIGH_SHRINK_NEW_Callback(hObject, eventdata, handles)
handles.denoise_mode = 10;
handles.mode_selected = true;

set(handles.mode_display,'String','Adaptive Neigh Shrink');     % mode name display

set(handles.image_panel,'Visible','On');           % show image panel
set(handles.wavelet_panel,'Visible','On');         % show wavelet panel
set(handles.mode_display,'Visible','on');          % show mode name
set(handles.parameter_slider, 'Visible', 'On');  % show size bar
set(handles.parameter_name,'Visible','On');    % show size label
set(handles.parameter_display,'Visible','On');  % parameter display
set(handles.soft_mode,'Visible','Off');
set(handles.hard_mode,'Visible', 'Off');            % hide threhold mode
set(handles.parameter_slider, 'Visible', 'off');        % hide size bar
set(handles.parameter_name,'Visible','off');          % hide size label
set(handles.parameter_display,'Visible','off');       % parameter display
set(handles.windows_panel,'Visible','On');                  % show windows panel

set(handles.parameter_name,'String','Window Size'); % special parameter name
set(handles.parameter_display,'String',num2str(handles.window_size));      % threshold default display
set(handles.msg,'Visible','off');                              % hide warning message

guidata(hObject, handles)                              % update the handles

% ---------------------mode code = 11------------------------
function WIENER_Callback(hObject, eventdata, handles)
handles.denoise_mode = 11;
handles.mode_selected = true;

set(handles.mode_display,'String','Wiener Filter');   % mode name display

set(handles.parameter_slider, 'Visible', 'On');        % size bar
set(handles.parameter_name,'Visible','On');          % size label
set(handles.image_panel,'Visible','On');                 % image panel
set(handles.wavelet_panel,'Visible','off');              % hide wavelet panel
set(handles.parameter_display,'Visible','On');        % parameter display
set(handles.soft_mode,'Visible','Off');                    % hide threhold mode
set(handles.hard_mode,'Visible', 'Off');
set(handles.windows_panel,'Visible','Off');                 % hide windows panel

set(handles.parameter_name,'String','Window Size'); % special parameter name
set(handles.parameter_display,'String',num2str(handles.window_size));      % threshold default display
set(handles.msg,'Visible','off');                              % hide warning message

guidata(hObject, handles)                              % update the handles


% --------------------------------------------------------------------
function FMETHODS_Callback(hObject, eventdata, handles)
% hObject    handle to FMETHODS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.denoised_done = false;
set(handles.mode_display,'Visible','On');
guidata(hObject, handles)                              % update the handles


% -------------------Mode Code = 12---------------------------
function FTHRESHOLD_Callback(hObject, eventdata, handles)
handles.denoise_mode = 12;
handles.mode_selected = true;
% handles.wavelet_done = false; % skip the wavelet methods

set(handles.mode_display,'String','Fourier Threshold');     % mode name display

set(handles.image_panel,'Visible','On');             % show image panel
set(handles.wavelet_panel,'Visible','Off');          % hide wavelet panel
set(handles.mode_display,'Visible','on');            % show mode name
set(handles.parameter_slider, 'Visible', 'On');    % show size bar
set(handles.parameter_name,'Visible','On');      % show size label
set(handles.parameter_display,'Visible','On');    % parameter display
set(handles.soft_mode,'Visible','Off');
set(handles.hard_mode,'Visible', 'Off');             % hide threhold mode
set(handles.windows_panel,'Visible','Off');                 % hide windows panel

set(handles.parameter_name,'String','Threshold'); % special parameter name
handles.threshold = 1000;
set(handles.parameter_display,'String',num2str(handles.threshold));      % threshold default display
set(handles.msg,'Visible','off');                           % hide warning message
guidata(hObject, handles)                                  % update the handles


%------------------------------------------------------------------%
%                              PARAMETERS                                %
%------------------------------------------------------------------%
% ---------------SPECIAL PARAMETER--------------------
function parameter_slider_Callback(hObject, eventdata, handles)
handles.parameter = get(hObject,'Value');  % get the parameter from the slide
if handles.denoise_mode == 1  ||  handles.denoise_mode == 11 ||  handles.denoise_mode == 9 % W ~ 3:10
    handles.window_size = round(handles.parameter);
    if handles.window_size <=3
        handles.window_size = 3;
    end
    set(handles.parameter_display,'String',num2str(handles.window_size));
elseif handles.denoise_mode ==4 || handles.denoise_mode ==5
    handles.threshold = handles.parameter*10;  % T~10:150
    set(handles.parameter_display,'String',num2str(handles.threshold));
elseif handles.denoise_mode == 6
    handles.reduce_factor = handles.parameter*0.1;  % T~0.1:1
    set(handles.parameter_display,'String',num2str(handles.reduce_factor));
elseif handles.denoise_mode == 12
    handles.threshold = handles.parameter*5000;
    set(handles.parameter_display, 'String', num2str(handles.threshold));
end
guidata(hObject, handles)                              % update the handles

% ---------------------SOFT MODE---------------------------%
function soft_mode_Callback(hObject, eventdata, handles)
% threshold_mode: 1 = soft; 0 = hard
if get(hObject,'Value')
    handles.threshold_mode = 1;
    set(handles.hard_mode,'Value',0);
    % only keep one choice
end
guidata(hObject, handles)                              % update the handles


% ---------------------HARD MODE---------------------------%
function hard_mode_Callback(hObject, eventdata, handles)
% threshold_mode: 1 = soft; 0 = hard
if get(hObject,'Value')
    handles.threshold_mode = 0;
    set(handles.soft_mode,'Value',0);
    % only keep one choice
end
guidata(hObject, handles)                              % update the handles

% --------------------------------------------------------------------
function save_denoised_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to save_denoised (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function zoom_in_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to zoom_in (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ----------------add window 3---------------------
function windows_3_Callback(hObject, eventdata, handles)
handles.windows = unique(handles.windows);
if get(hObject,'Value')
    handles.windows = [handles.windows 3];
    handles.windows = unique(handles.windows);
else
    handles.windows = setdiff(handles.windows,3);
end
handles.windows = unique(handles.windows);
guidata(hObject, handles)

% ----------------add window 5---------------------
function windows_5_Callback(hObject, eventdata, handles)
handles.windows = unique(handles.windows);
if get(hObject,'Value')
    handles.windows = [handles.windows 5];
    handles.windows = unique(handles.windows);
else
    handles.windows = setdiff(handles.windows,5);
end
handles.windows = unique(handles.windows);
guidata(hObject, handles)

% ----------------add window 7---------------------
function windows_7_Callback(hObject, eventdata, handles)
handles.windows = unique(handles.windows);
if get(hObject,'Value')
    handles.windows = [handles.windows 7];
    handles.windows = unique(handles.windows);
else
    handles.windows = setdiff(handles.windows,7);
end
handles.windows = unique(handles.windows);
guidata(hObject, handles)

% ----------------add window 9---------------------
function windows_9_Callback(hObject, eventdata, handles)
handles.windows = unique(handles.windows);
if get(hObject,'Value')
    handles.windows = [handles.windows 9];
    handles.windows = unique(handles.windows);
else
    handles.windows = setdiff(handles.windows,9);
end
handles.windows = unique(handles.windows);
guidata(hObject, handles)


% -------------------WAVELET TAB----------------------------------
function WAVELET_Callback(hObject, eventdata, handles)
if handles.wavelet_done && handles.image_loaded
    set(handles.SHOW_WAVELET,'Enable','On');
    % if the wavele transform is ready, enable this function
else
    set(handles.SHOW_WAVELET,'Enable','Off');
    % if the wavelet transform is not ready, disable this function
end
guidata(hObject, handles)  % update handles


% --------------------SHOW WAVELET-------------------------
function SHOW_WAVELET_Callback(hObject, eventdata, handles)
if handles.wavelet_done && handles.image_loaded
    set(handles.SHOW_WAVELET,'Enable','On');
    % if the wavele transform is ready, enable this function
    decomposition = [wcodemat(handles.A{handles.level_num},255) wcodemat(handles.V{handles.level_num},255);
        wcodemat(handles.H{handles.level_num},255) wcodemat(handles.D{handles.level_num},255) ];
    for i = (handles.level_num-1) : -1: 1
        decomposition = decomposition(1:size(handles.H{i},1), 1:size(handles.H{i},2));
        decomposition = [decomposition                          wcodemat(handles.V{i},255);
            wcodemat(handles.H{i},255)  wcodemat(handles.D{i},255)];
    end
    figure(); % show the wavelet transform
    imshow(decomposition,[0,255]),title(['the wavelet transform of ', handles.wavelet_type, ' with ', num2str(handles.level_num),' levels']);
else
    set(handles.SHOW_WAVELET,'Enable','Off');
    % if the wavelet transform is not ready, disable this function
end
guidata(hObject, handles)   % update handles


% --------------------RESULTS TAB-------------------------------
function RESULTS_Callback(hObject, eventdata, handles)
% results bar control the function enable or disable
if handles.image_loaded && handles.noise_added
    set(handles.SHOW_NOISY,'Enable','On');
    % if the image is loaded and the noise is added
    % enable the show noisy image function
    if handles.denoised_done
        % enable show denoise results
        set(handles.SHOW_DENOISED,'Enable','On');
        set(handles.SHOW_DIFF,'Enable','On');
        set(handles.SHOW_ALL,'Enable','On');
    else
        % disable show function
        set(handles.SHOW_DENOISED,'Enable','Off');
        set(handles.SHOW_DIFF,'Enable','Off');
        set(handles.SHOW_ALL,'Enable','Off');
    end
else
    % else disable the show functions
    set(handles.SHOW_NOISY,'Enable','Off');
    set(handles.SHOW_DENOISED,'Enable','Off');
    set(handles.SHOW_DIFF,'Enable','Off');
    set(handles.SHOW_ALL,'Enable','Off');
end
guidata(hObject, handles)   % update handles

% ------------------Show Noisy Image---------------------------
function SHOW_NOISY_Callback(hObject, eventdata, handles)
figure();
imshow(handles.noisy_image,[0,255]),title(['Noisy image with sigman = ', num2str(handles.sigman)],'FontSize',15);

% ------------------Show Denosied Image---------------------------
function SHOW_DENOISED_Callback(hObject, eventdata, handles)
figure();
imshow(handles.denoised_image_passing,[0,255]),title(['Denoised image. Mode=',handles.methodsBook{handles.denoise_mode}],'FontSize',15);

% ------------------Show Different Image---------------------------
function SHOW_DIFF_Callback(hObject, eventdata, handles)
figure();
imshow(uint8(wcodemat(wcodemat(handles.denoised_image_passing,255) - double(handles.original_image),255))),...
    title(['Difference Between Denoised Image and Original Image. Mode=',handles.methodsBook{handles.denoise_mode}],'FontSize',15);

% ------------------Show ALL Results---------------------------
function SHOW_ALL_Callback(hObject, eventdata, handles)
figure();
imshow(handles.original_image),title('Original Image','FontSize',15);
figure();
imshow(handles.noisy_image,[0,255]),title(['Noisy image with sigman=', num2str(handles.sigman)],'FontSize',15);
figure();
imshow(handles.denoised_image_passing,[0,255]),title(['Denoised image. Mode=',handles.methodsBook{handles.denoise_mode}],'FontSize',15);
figure();
imshow(uint8(wcodemat(wcodemat(handles.denoised_image_passing,255) - double(handles.original_image),255))),...
    title(['Difference Between Denoised Image and Original Image. Mode=',handles.methodsBook{handles.denoise_mode}],'FontSize',15);


% ------------------SHOW RECORD----------------------
function RECORD_Callback(hObject, eventdata, handles)
% hObject    handle to RECORD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function SHOW_LAST_RECORD_Callback(hObject, eventdata, handles)
if isempty(handles.record_book)
    disp('Sorry, there is no record');
else
    disp(handles.record_book{end});
end


% --------------------------------------------------------------------
function SHOW_ALL_RECORD_Callback(hObject, eventdata, handles)
if isempty(handles.record_book)
    disp('Sorry, there is no record');
else
    for i = 1:size(handles.record_book,1)
        disp([num2str(i),': ', handles.record_book{i}]);
    end
end


% --------------------------------------------------------------------
function Show_Callback(hObject, eventdata, handles)
% hObject    handle to Show (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
obj = get(handles.figure1,'CurrentObject');
currentTag = get(obj,'Tag');
if strcmp(currentTag,'axes1') || strcmp(currentTag,'axes2') || strcmp(currentTag,'axes3') || strcmp(currentTag,'axes4')
    set(handles.show2ddft,'Enable','Off');
    set(handles.show2ddft3d,'Enable','Off');
    set(handles.showWavelet,'Enable','Off');
    set(handles.enlarge,'Enable','Off');
elseif strcmp(currentTag,'O') || strcmp(currentTag,'N')||strcmp(currentTag,'D')
    set(handles.show2ddft,'Enable','On');
    set(handles.show2ddft3d,'Enable','On');
    set(handles.enlarge,'Enable','On');
    if ~handles.wavelet_done
        set(handles.showWavelet,'Enable','Off');
    else
        set(handles.showWavelet,'Enable','On');
    end
elseif strcmp(currentTag,'E')
    set(handles.show2ddft,'Enable','Off');
    set(handles.show2ddft3d,'Enable','On');
    set(handles.showWavelet,'Enable','Off');
    set(handles.enlarge,'Enable','On');
end
handles.passingShowIndex = currentTag;
guidata(hObject, handles)   % update handles




% --------------------------------------------------------------------
function showWavelet_Callback(hObject, eventdata, handles)
% hObject    handle to showWavelet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(handles.passingShowIndex,'O')
    [A,H,V,D] = multiLevelDWT(handles.original_image,handles.level_num, handles.wavelet_type);
    decomposition = [wcodemat(A{handles.level_num},255) wcodemat(V{handles.level_num},255);
        wcodemat(H{handles.level_num},255) wcodemat(D{handles.level_num},255) ];
    for i = (handles.level_num-1) : -1: 1
        decomposition = decomposition(1:size(H{i},1), 1:size(H{i},2));
        decomposition = [decomposition                          wcodemat(V{i},255);
            wcodemat(H{i},255)  wcodemat(D{i},255)];
    end
    figure('Name','Original Image Wavelet'); % show the wavelet transform
    imshow(decomposition,[0,255]),title(['Original Image wavelet transform of ', handles.wavelet_type, ' with ', num2str(handles.level_num),' levels'],'FontSize',15);
elseif strcmp(handles.passingShowIndex,'N')
    decomposition = [wcodemat(handles.A{handles.level_num},255) wcodemat(handles.V{handles.level_num},255);
        wcodemat(handles.H{handles.level_num},255) wcodemat(handles.D{handles.level_num},255) ];
    for i = (handles.level_num-1) : -1: 1
        decomposition = decomposition(1:size(handles.H{i},1), 1:size(handles.H{i},2));
        decomposition = [decomposition                          wcodemat(handles.V{i},255);
            wcodemat(handles.H{i},255)  wcodemat(handles.D{i},255)];
    end
    figure('Name','Noisy Image Wavelet'); % show the wavelet transform
    imshow(decomposition,[0,255]),title(['Noisy Image wavelet transform of ', handles.wavelet_type, ' with ', num2str(handles.level_num),' levels'],'FontSize',15);
elseif strcmp(handles.passingShowIndex,'D')
    [A,H,V,D] = multiLevelDWT(handles.denoised_image_passing,handles.level_num, handles.wavelet_type);
    decomposition = [wcodemat(A{handles.level_num},255) wcodemat(V{handles.level_num},255);
        wcodemat(H{handles.level_num},255) wcodemat(D{handles.level_num},255) ];
    for i = (handles.level_num-1) : -1: 1
        decomposition = decomposition(1:size(H{i},1), 1:size(H{i},2));
        decomposition = [decomposition                          wcodemat(V{i},255);
            wcodemat(H{i},255)  wcodemat(D{i},255)];
    end
    figure('Name','Denoised Image Wavelet'); % show the wavelet transform
    imshow(decomposition,[0,255]),title(['Denoised Image wavelet transform of ', handles.wavelet_type, ' with ', num2str(handles.level_num),' levels Mode=',handles.methodsBook{handles.denoise_mode}],'FontSize',15);
end





% --------------------------------------------------------------------
function show2ddft_Callback(hObject, eventdata, handles)
% hObject    handle to show2ddft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(handles.passingShowIndex,'O')
    F = fft2(handles.original_image);
    F2=log(1+fftshift(abs(F)));
    figure('Name','Original Image 2D DFT');
    imshow(F2,[]),title('Original Image 2D DFT','FontSize',15);
elseif strcmp(handles.passingShowIndex,'N')
    F = fft2(handles.noisy_image);
    F2=log(1+fftshift(abs(F)));
    figure('Name','Noisy Image 2D DFT');
    imshow(F2,[]),title('Noisy Image 2D DFT','FontSize',15);
elseif strcmp(handles.passingShowIndex,'D')
    F = fft2(handles.denoised_image_passing);
    F2=log(1+fftshift(abs(F)));
    figure('Name','Denoised Image 2D DFT');
    imshow(F2,[]),title(['Denoised Image 2D DFT with Mode=',handles.methodsBook{handles.denoise_mode}],'FontSize',15);
end

function show2ddft3d_Callback(hObject, eventdata, handles)
% hObject    handle to show2ddft3d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(handles.passingShowIndex,'O')
    F = fft2(handles.original_image);
    F2=log(1+fftshift(abs(F)));
    figure('Name','Original Image 2D DFT');
    mesh(F2),title('Original Image 2D DFT','FontSize',15);
elseif strcmp(handles.passingShowIndex,'N')
    F = fft2(handles.noisy_image);
    F2=log(1+fftshift(abs(F)));
    figure('Name','Noisy Image 2D DFT');
    mesh(F2),title('Noisy Image 2D DFT','FontSize',15);
elseif strcmp(handles.passingShowIndex,'D')
    F = fft2(handles.denoised_image_passing);
    F2=log(1+fftshift(abs(F)));
    figure('Name','Denoised Image 2D DFT');
    mesh(F2),title(['Denoised Image 2D DFT with Mode=',handles.methodsBook{handles.denoise_mode}],'FontSize',15);
end



% --------------------------------------------------------------------
function enlarge_Callback(hObject, eventdata, handles)
% hObject    handle to enlarge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(handles.passingShowIndex,'O')
    figure('Name','Original Image'),imshow(handles.original_image),title('Original Image','FontSize',15);
elseif strcmp(handles.passingShowIndex,'N')
    figure('Name','Noisy Image'),imshow(handles.noisy_image,[0,255]),title(['Noisy image with sigman=', num2str(handles.sigman)],'FontSize',15);
elseif strcmp(handles.passingShowIndex,'D')
    figure('Name','Denoised Image'),imshow(handles.denoised_image_passing,[0,255]),title(['Denoised image. Mode=',handles.methodsBook{handles.denoise_mode}],'FontSize',15);
elseif strcmp(handles.passingShowIndex,'E')
    figure('Name','Difference Image');
    imshow(uint8(wcodemat(wcodemat(handles.denoised_image_passing,255) - double(handles.original_image),255))),...
        title(['Difference Between Denoised Image and Original Image. Mode=',handles.methodsBook{handles.denoise_mode}],'FontSize',15);
end


% --------------------------------------------------------------------
