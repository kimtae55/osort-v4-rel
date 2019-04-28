% generate simulated spiketrains of different lengths / kinds
%
%


load('allMeans.mat');

indsSimilar = find( allMeans(:,94) > 500 & allMeans(:,94)<600 );
indsSimilar=indsSimilar(1:5);
figure(20);
plot(1:256, allMeans(indsSimilar,:) );


noiseStd=0.05;
nrSamples=500*100000;  %x sec, at 100kHz

%realWaveformsInd = indsSimilar;

%% pick the waveforms to be used for the simulated units.

realWaveformsInd=[24 16 80];

figure(21);
plot(1:256, allMeans(realWaveformsInd,:), 'linewidth',2);

legend( num2cellStr(realWaveformsInd) );

xlim([1 256]);

%% for single-wire simulations

%noiseStds = noiseStd.*[1 2 3 4];
%[spiketrains, realWaveformsInd, noiseWaveformsInd,spiketimes,waveformsOrigAll,scalingFactorSpikes] = generateSpiketrain(allMeans, realWaveformsInd, nrSamples, noiseStds);

%save('/fs2/simulated/simulatedNew_sim4.mat','noiseStds','nrSamples','realWaveformsInd','spiketimes','spiketrains','allMeans');


%% for tetrode simulations
firingRate = [5 3 4];
refractory = 3/1000; %3ms
Fs = 25000; %sampling rate in Hz of spiketrain
noiseStds = noiseStd.*[1 2 3 4];

[spiketrains_tetrode, spiketimes, scalingFactors] = generateSpiketrain_tetrode( noiseStds, nrSamples, firingRate, refractory, Fs,  realWaveformsInd, allMeans );


%files with all channels in one are too big for windows to load later.
%split up into one file for each channel


for k=1:length(spiketrains_tetrode)
    spiketrains_tetrode_chs=spiketrains_tetrode{k};
    save( ['/fs2/simulated/simulatedTetrode_sim2_Ch' num2str(k) '.mat'], 'spiketimes', 'spiketrains_tetrode_chs', 'realWaveformsInd', 'scalingFactors' );
end

save( ['/fs2/simulated/simulatedTetrode_sim2' '.mat'], 'spiketimes', 'spiketrains_tetrode', 'realWaveformsInd', 'scalingFactors' );

%% convert sampling rate of simulated spiketrains to the sampling rate
% generated by the real recording system

for k=1:length(spiketrains_tetrode)
    spiketrains_tetrode_chs=spiketrains_tetrode{k};
    
    spiketrains_tetrode_chs_res=[];
    FsConv=32556;
    for jj=1:length(spiketrains_tetrode_chs)
        disp(['ch=' num2str(k) ' noiseLevel=' num2str(jj)]);
        
        data = spiketrains_tetrode_chs{jj};
        
        [dataResampled,t,fact] = resample_ASRC( data, Fs, FsConv ); %resample accuratly to get exactly 32556 !
        spiketrains_tetrode_chs_res{jj}=dataResampled;
    end
    
    save( ['/fs2/simulated/simulatedTetrode_sim2_conv_Ch' num2str(k) '.mat'], 'spiketimes', 'spiketrains_tetrode_chs_res', 'realWaveformsInd', 'scalingFactors','FsConv' );
end

