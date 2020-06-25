  clc;clear all;close all;


Datasetpath=fullfile('C:\Users\TEST\Desktop\matlab works\LUNG_cancer_final')

Data=imageDatastore(Datasetpath,'IncludeSubfolders',true, ...
      'LabelSource','foldernames');
layers=[imageInputLayer([512 512 1])
        convolution2dLayer(5,20)
        reluLayer
        maxPooling2dLayer(2,'stride',2)
        convolution2dLayer(5,20)
        reluLayer
        maxPooling2dLayer(2,'stride',2)
        fullyConnectedLayer(2)
        softmaxLayer
        classificationLayer()]
    
options=trainingOptions('sgdm','MaxEpochs',15,'initialLearnRate',0.0001);
convnet=trainNetwork(Data,layers,options)
