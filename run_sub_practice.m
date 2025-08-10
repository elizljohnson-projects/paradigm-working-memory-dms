function acc = run_sub_practice
% RUN_SUB_PRACTICE - subfunction of run_wm_dms to run the task with only a 
% set of 8 practice trials, no event markers.
% 
% Ensure Psychtoolbox-3 is correcty added to the MATLAB path:
%   addpath <path to psychtoolbox home directory>
%   PsychDefaultSetup(2)
%
% Peripherals:
% mouse
% photodiode sensor attached to the lower left of the screen
%
% Outputs:
% acc = mean proportion correct
% 
% Copyright (c) 2017
% EL Johnson, PhD

% set directories
stimdir = fullfile(pwd, 'stimuli');

% set stimulus, trial, block, counts; timeout
nstim = 3;
ntrials = 8; % trials/block
nblocks = 1;
timeout = 30; % response screen timeout in s

% initialize behavior logs
acc_log = zeros(ntrials, 1);

% 8 trial types: odd = star, even = no star; 1, 2 = match;
% 3, 4 = mismatch identity; 5, 6 = mismatch spatial; 7, 8 = mismatch temporal
trltypes = repmat(1:8, [1 ntrials/8]);

% set trial timing
rate = 4; % stimulus presentation rate = 1/rate (stimulus, ISI)
iti = 1/2:0.001:1; % jittered ITI before preparation
tprep = 1; % preparation
tstim = 1/rate; % stimulus presentation rate (stimulus, ISI)
tdelay = 2-tstim; % delay = 2 sec at stim presentation rate
tping = 0.1; % 100-ms star on screen
jitter = 1-tstim:0.001:1-tping; % present star during cycle 1 of sec 2

% set messages
inst = ['PRACTICE INSTRUCTIONS \n\n' ...
    'On each trial, you will see a set of ' num2str(nstim) ' colored shapes. \n' ...
    'Pay attention to the shapes and how they appear. \n\n' ...
    'After a second, you will see another set of ' num2str(nstim) ' colored shapes. \n' ...
    'Use the mouse to show whether the 2nd set matches the 1st set. \n\n' ...
    'MATCH = sets are exactly the same \n' ...
    'MIS-MATCH = sets are different in any way, including order or position \n\n' ...
    'If you see a big flashing star, ignore it. \n\n' ...
    'Click the mouse to begin.'];

% compute color values in RGB space, from internal CLUT index
white = WhiteIndex(0);
black = BlackIndex(0);

% embed in a try-catch statement to recover screen if an error occurs
try
    % display a blank screen
    [w, scrsize] = Screen('OpenWindow', 0, white); % 0 for 1 screen
    HideCursor;
    WaitSecs(1)
    
    % set up screen center points
    wcenter = scrsize(3)/2;
    hcenter = scrsize(4)/2;
    
    % set spatial positions for stimuli (#1-4 left-top-right-bottom)
    pos_w = [wcenter/2; wcenter; wcenter+wcenter/2; wcenter];
    pos_h = [hcenter; hcenter/2; hcenter; hcenter+hcenter/2];
    
    % set priority for script execution to realtime priority
    priorityLevel = MaxPriority(w);
    Priority(priorityLevel);

    % set up display
    fontsize = Screen('Preference', 'DefaultFontSize');
    Screen('TextSize', w, round(fontsize*1.5));
    Screen('TextFont', w, 'Arial');
    Screen('ColorRange', w, 1);
    clear fontsize
    
    % set up star ping/distractor
    currfile = fullfile(stimdir, 'star');
    currimage = imread([currfile '.jpg']);
    currsize = size(currimage);
    q = (0.75*scrsize(4))/currsize(2); % resize to screen
    currimage = imresize(currimage, q); clear q
    currsize = size(currimage);
    imdims = [0 0 currsize(1:2)]; % width and height in pixels
    startex = Screen('MakeTexture', w, currimage);
    starrec = CenterRectOnPoint(imdims, wcenter, hcenter);
    clear curr* imdims

    % set up response scale
    currfile = fullfile(stimdir, 'response_text');
    currimage = imread([currfile '.jpg']);
    currsize = size(currimage);
    q = (0.75*scrsize(4))/currsize(2); % resize to screen
    currimage = imresize(currimage, q); clear q
    currsize = size(currimage);
    imdims = [0 0 currsize(1:2)]; % width and height in pixels
    resptex = Screen('MakeTexture', w, currimage);
    resprec = CenterRectOnPoint(imdims, wcenter, hcenter);
    x_bound = [resprec(1) resprec(3)]; % response boundaries
    y_bound = [hcenter-(imdims(4)*(2/10.5)/2) hcenter+(imdims(4)*(2/10.5)/2)];
    unsure = [wcenter-(imdims(3)*(0.6/10.5)/2) wcenter+(imdims(3)*(0.6/10.5)/2)];
    clear curr* imdims

    % run experiment
    c = 0; % trial counter
    
    for b = 1:nblocks                
        % randomize order of trials
        randorder = randperm(ntrials);
        trials = trltypes(randorder);
        clear randorder
        
        if b == 1            
            % display task instructions and wait for mouse click to continue
            DrawFormattedText(w, inst, 'center', 'center', black);
            Screen('Flip', w);
            SetMouse(wcenter, hcenter+hcenter/2);
            ShowCursor('Hand');
            GetClicks(0);
            HideCursor;
            WaitSecs(0.25)
            clear inst
        end
        
        for r = 1:ntrials
            c = c + 1; % trial counter
            
            % set up study stimuli (2 extra for mismatch identity)
            shapes = randsample(16, nstim + 2); % 16 possible shapes
            colors = randsample(11, nstim + 2); % 11 possible colors
            trlpos = randsample(4, nstim); % 4 possible spatial positions
            
            % set up mismatch
            swap = randsample(nstim, 2); % randomly choose 2 spots
                        
            imtex = zeros(nstim, 1); % initialize image presentation variables
            imrec = zeros(4, nstim);
            for i = 1:nstim
                currfile = fullfile(stimdir, ['Color' num2str(colors(i))], ...
                    ['Slide' num2str(shapes(i))]); % stim image file
                currimage = imread([currfile '.JPG']);
                currsize = size(currimage);
                q = (0.2*scrsize(4))/currsize(2); % resize to screen
                currimage = imresize(currimage, q); clear q
                currsize = size(currimage);
                imdims = [0 0 currsize(1:2)]; % width and height in pixels
                imtex(i) = Screen('MakeTexture', w, currimage);
                imrec(:, i) = CenterRectOnPoint(imdims, pos_w(trlpos(i)), pos_h(trlpos(i)));
                clear curr* imdims
            end

            % set up test stimuli by trial type
            imtex2 = imtex;
            imrec2 = imrec;
            
            if trials(r) < 3 % match
                % keep as is
                
            elseif trials(r) == 3 || trials(r) == 4
                % mismatch identity: stim 4/5 --> stim 2/3
                currfile = fullfile(stimdir, ['Color' num2str(colors(nstim+1))], ...
                    ['Slide' num2str(shapes(nstim+1))]); % stim 4 image file
                currimage = imread([currfile '.JPG']);
                currsize = size(currimage);
                q = (0.2*scrsize(4))/currsize(2); % resize to screen
                currimage = imresize(currimage, q); clear q
                currsize = size(currimage);
                imdims = [0 0 currsize(1:2)]; % width and height in pixels
                imtex2(swap(1)) = Screen('MakeTexture', w, currimage);
                imrec2(:, swap(1)) = CenterRectOnPoint(imdims, ...
                    pos_w(trlpos(swap(1))), pos_h(trlpos(swap(1)))); % replace stim 2
                clear curr* imdims
                
                currfile = fullfile(stimdir, ['Color' num2str(colors(nstim+2))], ...
                    ['Slide' num2str(shapes(nstim+2))]); % stim 5 image file
                currimage = imread([currfile '.JPG']);
                currsize = size(currimage);
                q = (0.2*scrsize(4))/currsize(2); % resize to screen
                currimage = imresize(currimage, q); clear q
                currsize = size(currimage);
                imdims = [0 0 currsize(1:2)]; % width and height in pixels
                imtex2(swap(2)) = Screen('MakeTexture', w, currimage);
                imrec2(:, swap(2)) = CenterRectOnPoint(imdims, ...
                    pos_w(trlpos(swap(2))), pos_h(trlpos(swap(2)))); % replace stim 3
                clear curr* imdims
                
            elseif trials(r) == 5 || trials(r) == 6
                % mismatch spatial: swap stim 2/3 positions
                currfile = fullfile(stimdir, ['Color' num2str(colors(swap(1)))], ...
                    ['Slide' num2str(shapes(swap(1)))]); % stim 2 image file
                currimage = imread([currfile '.JPG']);
                currsize = size(currimage);
                q = (0.2*scrsize(4))/currsize(2); % resize to screen
                currimage = imresize(currimage, q); clear q
                currsize = size(currimage);
                imdims = [0 0 currsize(1:2)]; % width and height in pixels
                imrec2(:, swap(1)) = CenterRectOnPoint(imdims, pos_w(trlpos(swap(2))), ...
                    pos_h(trlpos(swap(2)))); % stim 3 position
                clear curr* imdims
            
                currfile = fullfile(stimdir, ['Color' num2str(colors(swap(2)))], ...
                    ['Slide' num2str(shapes(swap(2)))]); % stim 3 image file
                currimage = imread([currfile '.JPG']);
                currsize = size(currimage);
                q = (0.2*scrsize(4))/currsize(2); % resize to screen
                currimage = imresize(currimage, q); clear q
                currsize = size(currimage);
                imdims = [0 0 currsize(1:2)]; % width and height in pixels
                imrec2(:, swap(2)) = CenterRectOnPoint(imdims, pos_w(trlpos(swap(1))), ...
                    pos_h(trlpos(swap(1)))); % stim 2 position
                clear curr* imdims
            
            elseif trials(r) == 7 || trials(r) == 8
                % mismatch temporal: swap stim 2/3 order
                imtex2(swap(1)) = imtex(swap(2));
                imtex2(swap(2)) = imtex(swap(1));
                imrec2(:, swap(1)) = imrec(:, swap(2));
                imrec2(:, swap(2)) = imrec(:, swap(1));
                                
            end
            clear shapes colors trlpos
            
            % ITI fixation (jittered)
            ititime = randsample(length(iti), 1);
            ititime = iti(ititime); % note ITI time 
            DrawFormattedText(w, '+', 'center', 'center', black); % fixation
            Screen('Flip', w);
            WaitSecs(ititime);
            
            % preparation fixation
            DrawFormattedText(w, '+', 'center', 'center', black); % fixation
            Screen('Flip', w);
            WaitSecs(tprep);
            
            % present study stimuli
            for s = 1:nstim
                % stimulus
                DrawFormattedText(w, '+', 'center', 'center', black); % fixation
                Screen('DrawTexture', w, imtex(s), [], imrec(:, s), [], 0); % stim
                Screen('Flip', w);
                WaitSecs(tstim);            

                % ISI
                DrawFormattedText(w, '+', 'center', 'center', black); % fixation
                Screen('Flip', w);
                WaitSecs(tstim);
            end
            clear imtex imrec
            
            % maintenance delay
            DrawFormattedText(w, '+', 'center', 'center', black); % fixation
            Screen('Flip', w);

            % show star during delay if ping/distractor trial (odd-numbered)
            if mod(trials(r), 2) == 0
                WaitSecs(tdelay);
                
            elseif mod(trials(r), 2) == 1
                % jitter star presentation time
                tstart = randsample(length(jitter), 1);
                tstart = jitter(tstart);
                tstop = tdelay-tping-tstart;
                WaitSecs(tstart);
                
                % present star
                Screen('DrawTexture', w, startex, [], starrec, [], 0); % stim
                Screen('Flip', w);
                WaitSecs(tping);
                
                % finish delay
                DrawFormattedText(w, '+', 'center', 'center', black); % fixation
                Screen('Flip', w);
                WaitSecs(tstop);
            end
            
            % present test stimuli
            for s = 1:nstim
                % stimulus
                DrawFormattedText(w, '+', 'center', 'center', black); % fixation
                Screen('DrawTexture', w, imtex2(s), [], imrec2(:, s), [], 0); % stim
                Screen('Flip', w);
                WaitSecs(tstim);            

                % ISI
                DrawFormattedText(w, '+', 'center', 'center', black); % fixation
                Screen('Flip', w);
                WaitSecs(tstim);
            end
            clear imtex2 imrec2
            
            % test delay
            DrawFormattedText(w, '+', 'center', 'center', black); % fixation
            Screen('Flip', w);
            
            % show star during delay if ping/distractor trial (odd-numbered), 
            % same timing as in maintenance delay
            if mod(trials(r), 2) == 0
                WaitSecs(tdelay);
                
            elseif mod(trials(r), 2) == 1
                WaitSecs(tstart);
                
                % present star
                Screen('DrawTexture', w, startex, [], starrec, [], 0); % stim
                Screen('Flip', w);
                WaitSecs(tping);
                
                % finish delay
                DrawFormattedText(w, '+', 'center', 'center', black); % fixation
                Screen('Flip', w);
                WaitSecs(tstop);
                clear tstart tstop
            end
            
            % response: until mouse click on gradient or timeout
            Screen('DrawTexture', w, resptex, [], resprec, [], 0); % stim
            Screen('Flip', w);
                        
            % show cursor + note start time
            SetMouse(wcenter, hcenter+hcenter/2);
            ShowCursor('Hand');
            resp_start = GetSecs;
            
            % wait for click up to timeout and record location on screen
            while (GetSecs - resp_start <= timeout)
                [~, x, y] = GetClicks(0);
                if x > x_bound(1) && x < x_bound(2) && y > y_bound(1) && y < y_bound(2)
                    break
                else
                    x = wcenter; % unsure
                    continue
                end
            end
            HideCursor;
            WaitSecs(0.1)
            
            % code response type and set feedback message
            if x < unsure(1) && trials(r) < 3
                % response: match; correct: match
                resp_acc = 1;
                fback = 'Correct!';
            elseif x > unsure(2) && trials(r) < 3
                % response: mismatch; correct: match
                resp_acc = 0;
                fback = 'Incorrect. \n\n Correct response: MATCH.';
            elseif x > unsure(2) && trials(r) > 2
                % response: mismatch; correct: mismatch
                resp_acc = 1;
                fback = 'Correct!';
            elseif x < unsure(1) && trials(r) > 2
                % response: match; correct: mismatch
                resp_acc = 0;
                if trials(r) == 3 || trials(r) == 4
                    fback = ['Incorrect \n\n Correct response: MIS-MATCH \n\n' ...
                        'Shapes were different.'];
                elseif trials(r) == 5 || trials(r) == 6
                    fback = ['Incorrect \n\n Correct response: MIS-MATCH \n\n' ...
                        'Shape locations were swapped.'];
                elseif trials(r) == 7 || trials(r) == 8
                    fback = ['Incorrect \n\n Correct response: MIS-MATCH \n\n' ...
                        'Shapes were out of order.'];
                end
            else
                % response: unsure
                resp_acc = 0;
                if trials(r) < 3
                    fback = 'Correct response: MATCH';
                elseif trials(r) == 3 || trials(r) == 4
                    fback = 'Correct response: MIS-MATCH \n\n Shapes were different.';
                elseif trials(r) == 5 || trials(r) == 6
                    fback = 'Correct response: MIS-MATCH \n\n Shape locations were swapped.';
                elseif trials(r) == 7 || trials(r) == 8
                    fback = 'Correct response: MIS-MATCH \n\n Shapes were out of order.';
                end
            end
            clear x y
            
            % display feedback
            ftime = 1;
            if resp_acc == 0 && trials(r) > 2
                ftime = ftime*3;
            end
            DrawFormattedText(w, fback, 'center', 'center', black);
            Screen('Flip', w);
            WaitSecs(ftime)
            clear fback ftime
            
            % record accuracy
            acc_log(r) = resp_acc;
            
            clear resp_* rt *time trial_start swap
            
        end
        clear trials
        
        % compute block accuracy
        acc = mean(acc_log);
        
        % reset for next block
        acc_log = zeros(size(acc_log));
        
    end
        
    % present task complete message
    complete_message = 'End of practice block.';
    DrawFormattedText(w, complete_message, 'center', 'center', black);
    Screen('Flip', w);
    WaitSecs(2);

    % do final cleanup of screen and close output file
    Screen('CloseAll');
    ShowCursor;
    Priority(0);
    
catch
    % catch error: this is executed in case something goes wrong in the
    % 'try' part due to programming error etc.
    
    % do same cleanup as at the end of a regular session
    Screen('CloseAll');
    ShowCursor;
    Priority(0);
    
    % output the error message
    psychrethrow(psychlasterror);
    
end

clearvars -except acc

end

