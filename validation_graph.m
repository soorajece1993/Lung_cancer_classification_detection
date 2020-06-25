clc;clear all;close all;

[XTrain,YTrain] = digitTrain4DArrayData;
whos YTrain
Datasetpath=fullfile('C:\Users\TEST\Desktop\matlab works\LUNG_cancer_final')

Data=imageDatastore(Datasetpath,'IncludeSubfolders',true, ...
      'LabelSource','foldernames');
layers = [
    imageInputLayer([512 512 1])
    
    convolution2dLayer(5,20,'Padding','same')
    batchNormalizationLayer
    reluLayer  
    maxPooling2dLayer(2,'stride',2)
    convolution2dLayer(5,20,'Padding','same','Stride',2)
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'stride',2)
    convolution2dLayer(5,20,'Padding','same','Stride',2)
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];
    
%options=trainingOptions('sgdm','MaxEpochs',15,'initialLearnRate',0.0001);
options = trainingOptions('sgdm',...
    'MaxEpochs',10,...
    'Verbose',false,...
    'Plots','training-progress');
convnet=trainNetwork(Data,layers,options)

net = trainNetwork(XTrain,YTrain,layers,options);
[XTest,YTest] = digitTest4DArrayData;
YPredicted = classify(net,XTest);

plotconfusion(YTest,YPredicted)

rng default
[XTrain,YTrain] = cancer_dataset;
YTrain(:,1:10)

net = patternnet(10);
net = train(net,XTrain,YTrain);

YPredicted = net(XTrain);
YPredicted(:,1:10)

plotconfusion(YTrain,YPredicted)
