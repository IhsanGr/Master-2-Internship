clear all
%Use the function written below
main_path = 'C:/Users/gricih01/OneDrive - Université du Québec en Outaouais/Documents/MI BCI Database and scripts/BCI_Database/Signals/DATA A/*';
baseline = true;
acquisition = true;
MI = true;

% Create the folder where we would store everything
if ~exist('C:/Users/gricih01/OneDrive - Université du Québec en Outaouais/Documents/MI BCI Database and scripts/BCI_Database_Processed/.Antichambre', 'dir')
    mkdir('../BCI_Database_Processed/.Antichambre');
end

% Separating baseline files and acquisition/MI files because we will have inputs parameters for both file types
if ~exist('C:/Users/gricih01/OneDrive - Université du Québec en Outaouais/Documents/MI BCI Database and scripts/BCI_Database_Processed/.Antichambre/Baseline', 'dir')
    mkdir('C:/Users/gricih01/OneDrive - Université du Québec en Outaouais/Documents/MI BCI Database and scripts/BCI_Database_Processed/.Antichambre/Baseline');
end

if ~exist('C:/Users/gricih01/OneDrive - Université du Québec en Outaouais/Documents/MI BCI Database and scripts/BCI_Database_Processed/.Antichambre/BCI', 'dir')
    mkdir('C:/Users/gricih01/OneDrive - Université du Québec en Outaouais/Documents/MI BCI Database and scripts/BCI_Database_Processed/.Antichambre/BCI');
end

rejected = {'A2', 'A5', 'A6', 'A9', 'A11', 'A13', 'A17', 'A21', 'A29', 'A31', 'A32', 'A36', 'A38', 'A39', 'A40', 'A46', 'A47', 'A55', 'A59', 'A60'}; %Reject subject in the python file

% Enter your path to the data
path = 'C:\Users\gricih01\OneDrive - Université du Québec en Outaouais\Documents\MI BCI Database and scripts\BCI_Database\Signals\DATA A';

L = files(main_path, baseline, acquisition, MI, rejected);

% Adding the eeglab path to matlab
addpath('C:\Users\gricih01\OneDrive - Université du Québec en Outaouais\Documents\HAPPE-master\packages\eeglab2022.0')

% Open eeglab
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

% Explorer les données dans l'interface EEGLAB
%pop_eegplot(EEG, 1, 1, 1);

% Enregistrer les résultats (par exemple, les données filtrées ou les composantes indépendantes)
% pop_saveset(EEG, 'filename', '/chemin/vers/resultats.eeg');

for i = 1:numel(L)
    for j = 1:numel(L{i})

        match = regexp(L{i}{j}, 'A\d+', 'match');
        match = char(match{1});

        filename = sprintf('%s\\%s\\%s', path, match, L{i}{j});
        fprintf('Fichier : \n%s\n', filename);
        
        % Loading .gdf file in EEGLAB
        EEG = pop_biosig(filename);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'gui','off');

        % Saving data in .set format
        %pop_saveset(EEG, 'filename', 'nom_du_fichier.set', 'filepath', 'chemin_vers_votre_dossier_de_destination');
        EEG = eeg_checkset( EEG );
        
        % Extraire le nom du fichier et son extension
        [chemin, nomFichier, extension] = fileparts(filename);
        fprintf('Fichier : \n%s\n', nomFichier);

        name_save = sprintf('%s.set', nomFichier);
        fprintf('Fichier : \n%s\n', name_save);

        if contains(filename, 'baseline')
            EEG = pop_saveset( EEG, 'filename', name_save,'filepath','C:\\Users\\gricih01\\OneDrive - Université du Québec en Outaouais\\Documents\\MI BCI Database and scripts\\BCI_Database_Processed\\.Antichambre\\Baseline');
        else
            EEG = pop_saveset( EEG, 'filename', name_save,'filepath','C:\\Users\\gricih01\\OneDrive - Université du Québec en Outaouais\\Documents\\MI BCI Database and scripts\\BCI_Database_Processed\\.Antichambre\\BCI');
        end
    end
end

function L = files(main_path, baseline, acquisition, MI, rejected)
    % Initializing list of files
    L = {};
    
    % Copying rejected list since we will modify some elements
    reject = rejected;
    
    % Filter one digit subject
    single_digit = {};
    for i = 1:numel(rejected)
        if numel(rejected{i}) == 2
            single_digit{end+1} = rejected{i};
            reject(strcmp(reject, rejected{i})) = [];
        else
            break; %win some time since single digit are above two digits
        end
    end
    
    % Storing every file on the main_path
    all_file_path = dir(main_path);
    all_file_path = all_file_path(3:62);
    
    fprintf('Nombre de participants : %d\n\n', numel(all_file_path));
    
    % Filter files depending on reject
    for i = 1:numel(reject)
        all_file_path = all_file_path(~contains({all_file_path.name}, reject{i}));
    end
    
    % Suppress A1 because of the first acquisition file which is shorter
    all_file_path(strcmp({all_file_path.name}, 'A1')) = [];
    

    % Suppress one digit number (problems in removing them)
    for i = 1:numel(single_digit)
        all_file_path(strcmp({all_file_path.name}, single_digit{i})) = [];
    end
    
    fprintf('Nombre de participants retenus : %d\n', numel(all_file_path));
    
    % treating files depending on the inputs
    if baseline
        all_baseline_path = {};
        for i = 1:numel(all_file_path)
            path = dir(fullfile(all_file_path(i).folder, all_file_path(i).name, '*baseline*'));
            all_baseline_path{i} = {path.name};
        end
    end
    
    if acquisition
        all_acquisition_path = {};
        for i = 1:numel(all_file_path)
            path = dir(fullfile(all_file_path(i).folder, all_file_path(i).name, '*acquisition*'));
            all_acquisition_path{i} = {path.name};
        end
    end
    
    if MI
        all_MI_path = {};
        for i = 1:numel(all_file_path)
            path = dir(fullfile(all_file_path(i).folder, all_file_path(i).name, '*online*'));
            all_MI_path{i} = {path.name};
        end
    end
    
    % Fusion of all paths
    n = numel(all_file_path);
    L = cell(1, n);
    for i = 1:n
        L{i} = {};
        if baseline
            L{i} = [L{i} all_baseline_path{i}];
        end
        
        if acquisition
            L{i} = [L{i} all_acquisition_path{i}];
        end
        
        if MI
            L{i} = [L{i} all_MI_path{i}];
        end
    end
end