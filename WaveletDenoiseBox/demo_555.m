function varargout = demo_555(varargin)
% DEMO_555 MATLAB code for demo_555.fig
%      DEMO_555, by itself, creates a new DEMO_555 or raises the existing
%      singleton*.
%
%      H = DEMO_555 returns the handle to a new DEMO_555 or the handle to
%      the existing singleton*.
%
%      DEMO_555('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DEMO_555.M with the given input arguments.
%
%      DEMO_555('Property','Value',...) creates a new DEMO_555 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before demo_555_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to demo_555_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Last Modified by GUIDE v2.5 28-Apr-2015 22:36:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @demo_555_OpeningFcn, ...
    'gui_OutputFcn',  @demo_555_OutputFcn, ...
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
function varargout = demo_555_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

% ==================================== %
%                       DEFAULT VALUES                             %
% ==================================== %
function demo_555_OpeningFcn(hObject, eventdata, handles, varargin)
%------------------------------------------------------- %
%          1                        LAWML                       %
%          2                        LAWMAP                    %
% Choose default command line output for demo_555
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
imshow(handles.original_image); % plot image

handles.record_image = contents{get(hObject,'Value')};

handles.MLed = false;
handles.image_loaded = true;
handles.noise_added = false;
handles.wavelet_done = false;
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
    imshow(uint8(handles.noisy_image));   % plot the noisy image
    handles.noise_added = true;
    handles.denoised_done = false;
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
%                               11 LAWW                     %
%            -------------------------------------         %
%               3              HARD                            %
%               4              SOFT                              %
%            -------------------------------------         %
%               5              BAYESSHRINK            %
%               6              SURESHRINK               %
%               7              VISUSHRINK                %
%               8              NEIGH SHRINK            %
%                               81 Neigh Shrink Modified       %
%            -------------------------------------         %
%
%               0              WIENER                       %
if handles.wavelet_done && handles.image_loaded &&  handles.noise_added && handles.mode_selected
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
        [a, h, v, d] = HARD_THRESHOLD(handles.A, handles.H, handles.V, handles.D, handles.level_num, handles.threshold);
        % hard thresholding method
        denoised_image = image_denois(a, h, v, d, size(handles.noisy_image),handles.wavelet_type);
        handles.record_para = ['T=',num2str(handles.threshold)];
        handles.denoised_done = true;              % denoise finished flag
        %------------------------------------------------------------------------------------------------
    elseif handles.denoise_mode == 4
        [a, h, v, d] = SOFT_THRESHOLD(handles.A, handles.H, handles.V, handles.D, handles.level_num, handles.threshold);
        % soft thresholding method
        denoised_image = image_denois(a, h, v, d, size(handles.noisy_image),handles.wavelet_type);
        handles.record_para = ['T=',num2str(handles.threshold)];
        handles.denoised_done = true;              % denoise finished flag
        %------------------------------------------------------------------------------------------------
    elseif handles.denoise_mode == 5
        [a,h,v,d] = BAYES_SHRIK (handles.A, handles.H, handles.V, handles.D, handles.level_num, handles.threshold_mode);
        % bayes shrink method  % threshold_mode: 1 = soft; 0 = hard
        denoised_image = image_denois(a, h, v, d, size(handles.noisy_image),handles.wavelet_type);
        handles.record_para = ['S/H=',num2str(handles.threshold_mode)];
        handles.denoised_done = true;              % denoise finished flag
        %------------------------------------------------------------------------------------------------
    elseif handles.denoise_mode == 6
        [a,h,v,d] = SURE_SHRINK (handles.A,handles.H,handles.V,handles.D,handles.level_num, handles.sigman, handles.threshold_mode);
        % SURE shrink method  % threshold_mode: 1 = soft; 0 = hard
        denoised_image = image_denois(a, h, v, d, size(handles.noisy_image),handles.wavelet_type);
        handles.record_para = ['S/H=',num2str(handles.threshold_mode)];
        handles.denoised_done = true;              % denoise finished flag
        %------------------------------------------------------------------------------------------------
    elseif handles.denoise_mode == 7
        [a,h,v,d] = VISU_SHRINK (handles.A,handles.H, handles.V, handles.D, handles.level_num,handles.sigman, handles.reduce_factor, handles.threshold_mode);
        % Visu shrink method  % threshold_mode: 1 = soft; 0 = hard
        denoised_image = image_denois(a, h, v, d, size(handles.noisy_image),handles.wavelet_type);
        handles.record_para = ['S/H=', num2str(handles.threshold_mode),'/ F=',num2str(handles.reduce_factor)];
        handles.denoised_done = true;              % denoise finished flag
        %------------------------------------------------------------------------------------------------
    elseif handles.denoise_mode == 8
        [a,h,v,d] = NEIGH_SHRINK (handles.A, handles.H, handles.V, handles.D, numel(handles.noisy_image),handles.window_size, handles.sigman);
        % Neigh Shrink with window size and the total coefficients number, also the noise information
        denoised_image = image_denois(a, h, v, d, size(handles.noisy_image),handles.wavelet_type);
        handles.record_para = ['WinSize=', num2str(handles.window_size)];
        handles.denoised_done = true;              % denoise finished flag
        %------------------------------------------------------------------------------------------------
    elseif handles.denoise_mode == 11
        % handles.windows
        [a, h, v, d] = ADAPTIVE_MMSE(handles.A, handles.H, handles.V, handles.D, handles.level_num, handles.sigman, handles.windows,200); % the MLE will also return the lambda value
        denoised_image = image_denois(a, h, v, d, size(handles.noisy_image),handles.wavelet_type);
        handles.record_para = ['Wins=[', num2str(handles.windows),']'];
        handles.denoised_done = true;              % denoise finished flag
        %------------------------------------------------------------------------------------------------
    elseif handles.denoise_mode == 81
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
    end
end
%------------------------------------------------------------------------------------------------
if handles.image_loaded &&  handles.noise_added && handles.mode_selected && handles.denoise_mode == 0
    denoised_image = wiener2(handles.noisy_image,[handles.window_size handles.window_size]);
    % Wiener Filter @ MATLAB build in function with local estimation
    handles.record_para = ['WinSize=',num2str(handles.window_size)];
    handles.denoised_done = true;              % denoise finished flag
    
end

if handles.denoised_done
    % ready to plot results
    axes(handles.axes3);
    imshow(denoised_image,[0,255]);
    % plot defference
    axes(handles.axes4);
    % class(denoised_image)             % debug handles
    % class(handles.original_image)  % debug handles
    imshow(uint8(wcodemat(wcodemat(denoised_image,255) - double(handles.original_image),255)));
    handles.psnr = PSNR(handles.original_image, denoised_image);
    handles.denoised_image_passing =  denoised_image;
    set(handles.PSNR_display,'String',['PSNR = ', num2str(handles.psnr)]);
    
    handles.record_sigman = num2str(handles.sigman);
    handles.record_waveletlevel = num2str(handles.level_num);
    handles.record_wavelettype = num2str(handles.wavelet_type);
    handles.record_mode = num2str(handles.denoise_mode);
    handles.record_psnr = num2str(handles.psnr);
    
    handles.record = [handles.record_image,'   ', ...
        'Sigman=',handles.record_sigman,'   ',...
        'WaveletLevel=',handles.record_waveletlevel,'   ',...
        'Wavelet=',handles.record_wavelettype,'   ',...
        'ModeCode=',handles.record_mode,'   ',...
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
handles.mode_selected = true;
handles.denoised_done = false;
set(handles.mode_display,'Visible','On');
guidata(hObject, handles);                              % update the handles

% ---------------------mode code = 1--------------------------
function LAWML_Callback(hObject, eventdata, handles)
% MLE_MMSE(A,H,V,D, level_num, sigman,window_size);
% the MLE will also return the lambda value
handles.denoise_mode = 1;
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

% ------------------------mode code = 3---------------------
function HARD_Callback(hObject, eventdata, handles)
handles.denoise_mode = 3;
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
set(handles.parameter_display,'String',num2str(handles.threshold));      % threshold default display
set(handles.msg,'Visible','off');                              % hide warning message
guidata(hObject, handles)                              % update the handles

% ------------------------mode code = 4-----------------------
function SOFT_Callback(hObject, eventdata, handles)
handles.denoise_mode = 4;
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
set(handles.parameter_display,'String',num2str(handles.threshold));      % threshold default display
set(handles.msg,'Visible','off');                           % hide warning message
guidata(hObject, handles)                                  % update the handles

% ---------------------------mode code = 5------------------------
function BAYES_SHRIK_Callback(hObject, eventdata, handles)
handles.denoise_mode = 5;
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

% -----------------------------mode code = 6--------------------
function SURE_SHRINK_Callback(hObject, eventdata, handles)
handles.denoise_mode = 6;
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

% ----------------------------mode code = 7----------------------
function VISU_SHRINK_Callback(hObject, eventdata, handles)
handles.denoise_mode = 7;
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

% ----------------------------mode code = 8----------------------
function NEIGH_SHRINK_Callback(hObject, eventdata, handles)
handles.denoise_mode = 8;
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

% ----------------------------mode code = 81----------------------
function NEIGH_SHRINK_NEW_Callback(hObject, eventdata, handles)
handles.denoise_mode = 81;
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

% ---------------------mode code = TBA-----------------------
function BWN_Callback(hObject, eventdata, handles)
handles.denoise_mode = 99;
set(handles.mode_display,'String','BWN');   % mode name display

set(handles.image_panel,'Visible','On');           % show image panel
set(handles.wavelet_panel,'Visible','On');         % show wavelet panel
set(handles.mode_display,'Visible','on');          % show mode name
set(handles.parameter_slider, 'Visible', 'On');  % show size bar
set(handles.parameter_name,'Visible','On');    % show size label
set(handles.parameter_display,'Visible','On');  % parameter display
set(handles.windows_panel,'Visible','Off');                 % hide windows panel

set(handles.msg,'Visible','off');
set(handles.parameter_name,'String','Node Size');

guidata(hObject, handles)                              % update the handles

% ---------------------mode code = 0------------------------
function WIENER_Callback(hObject, eventdata, handles)
handles.denoise_mode = 0;
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

% ----------------------mode code = 11--------------------------
function LAWW_Callback(hObject, eventdata, handles)
handles.denoise_mode = 11;
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


%------------------------------------------------------------------%
%                              PARAMETERS                                %
%------------------------------------------------------------------%
% ---------------SPECIAL PARAMETER--------------------
function parameter_slider_Callback(hObject, eventdata, handles)
handles.parameter = get(hObject,'Value');  % get the parameter from the slide
if handles.denoise_mode == 1  ||  handles.denoise_mode == 0 ||  handles.denoise_mode == 8 % W ~ 3:10
    handles.window_size = round(handles.parameter);
    if handles.window_size <=3
        handles.window_size = 3;
    end
    set(handles.parameter_display,'String',num2str(handles.window_size));
elseif handles.denoise_mode ==3 || handles.denoise_mode ==4
    handles.threshold = handles.parameter*10;  % T~10:150
    set(handles.parameter_display,'String',num2str(handles.threshold));
elseif handles.denoise_mode == 7
    handles.reduce_factor = handles.parameter*0.1;  % T~0.1:1
    set(handles.parameter_display,'String',num2str(handles.reduce_factor));
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
imshow(handles.denoised_image_passing,[0,255]),title(['Denoised image. ModeCode=',handles.record_mode],'FontSize',15);

% ------------------Show Different Image---------------------------
function SHOW_DIFF_Callback(hObject, eventdata, handles)
figure();
imshow(uint8(wcodemat(wcodemat(handles.denoised_image_passing,255) - double(handles.original_image),255))),...
    title(['Difference Between Denoised Image and Original Image. ModeCode=',handles.record_mode],'FontSize',15);

% ------------------Show ALL Results---------------------------
function SHOW_ALL_Callback(hObject, eventdata, handles)
figure();
imshow(handles.original_image),title('Original Image','FontSize',15);
figure();
imshow(handles.noisy_image,[0,255]),title(['Noisy image with sigman=', num2str(handles.sigman)],'FontSize',15);
figure();
imshow(handles.denoised_image_passing,[0,255]),title(['Denoised image. ModeCode=',handles.record_mode],'FontSize',15);
figure();
imshow(uint8(wcodemat(wcodemat(handles.denoised_image_passing,255) - double(handles.original_image),255))),...
    title(['Difference Between Denoised Image and Original Image. ModeCode=',handles.record_mode],'FontSize',15);


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
