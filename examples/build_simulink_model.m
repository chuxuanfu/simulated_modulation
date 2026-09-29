function modelPath = build_simulink_model()
% Optional offline playback model. Run setup and this function in MATLAB.
sm.require({'new_system','sim'},'Simulink');
p=sm.defaultConfig('basic'); w=sm.generate(p);
model='sm_iq_playback'; modelPath=fullfile(sm.root(),'generated',[model '.slx']);
assert(~bdIsLoaded(model) && ~isfile(modelPath),'Model already exists/open; rename or close it first.');
new_system(model); cleanup=onCleanup(@() close_system(model,0)); %#ok<NASGU>
add_block('simulink/Sources/From Workspace',[model '/IQ'],'VariableName','iqInput','Interpolate','off','Position',[40 80 170 110]);
add_block('simulink/Math Operations/Complex to Real-Imag',[model '/Split IQ'],'Position',[220 75 275 115]);
add_block('simulink/Sinks/Scope',[model '/Scope'],'NumInputPorts','2','Position',[340 65 390 125]);
add_block('simulink/Sinks/To Workspace',[model '/Capture'],'VariableName','iqOutput','SaveFormat','Timeseries','Position',[220 170 340 200]);
add_line(model,'IQ/1','Split IQ/1'); add_line(model,'Split IQ/1','Scope/1'); add_line(model,'Split IQ/2','Scope/2'); add_line(model,'IQ/1','Capture/1');
ws=get_param(model,'ModelWorkspace'); assignin(ws,'iqInput',timeseries(w.iq,(0:size(w.iq,1)-1).'/w.fs));
set_param(model,'SolverType','Fixed-step','Solver','FixedStepDiscrete','FixedStep',num2str(1/w.fs,17), ...
    'StopTime',num2str((size(w.iq,1)-1)/w.fs,17));
save_system(model,modelPath); sim(model); fprintf('Saved and simulated: %s\n',modelPath);
end
