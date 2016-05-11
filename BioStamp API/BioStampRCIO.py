'''
Created on Mar 7, 2016

@author: aaranyosi
'''

import time
import os

class BioStampRCIO(object):
    '''
    classdocs
    '''


    def __init__(self, master, globalInstance, api):
        '''
        Constructor
        '''
        self.master= master
        self.globals= globalInstance
        self.api= api

    def prettyTime(self, timestamp):
        return time.asctime(time.gmtime(int(timestamp / 1000)))

    def stringifyRecording(self, recording):
        pc = recording['physicalConfig']
        sc = recording['sensorConfig']
        deviceName= self.api.BioStampRCGetDeviceName(recording['studyId'], recording['subjectId'], recording['udid'])
        location = "{}, {}".format(pc['location'], pc['side'])
        sensingType = sc['sensingType']
#        print("Sensing Type: {}".format(sensingType))
        if sensingType == "MPU":
            if sc['gyro']['mode'] == "ACCEL_GYRO":
                mode = "Accel+Gyro"
                dynamicRange = "{} G, {} deg/sec".format(sc['gyro']['accelRange'], sc['gyro']['gyroRange'])
            else:
                mode = "Accel"
                dynamicRange = "{} G".format(sc['gyro']['accelRange'])
            rate = 1000 / int(sc['gyro']['periodMs'])
            senseCfg = "{}, {} Hz, {}".format(mode, rate, dynamicRange)
        elif sensingType == "ACCEL_ANALOG":
            mode= "Accel+{}".format(pc['signal'])
            dynamicRangeAccel= "{} G".format(sc['accel']['range'])
            rateAccel= "{} Hz".format(sc['accel']['rate'])
            rateAFE= "{} Hz".format(sc['afe']['rate'])
            senseCfg= "{}, {}, {}, {}, 0.2 V".format(mode, rateAccel, dynamicRangeAccel, rateAFE)
        elif sensingType == "ACCEL":
            mode = "Accel"
            dynamicRange = "{} G".format(sc['accel']['range'])
            rate = sc['accel']['rate']
            senseCfg = "{}, {} Hz, {}".format(mode, rate, dynamicRange)
        elif sensingType == "ANALOG":
            mode = pc['signal']
            rate = sc['afe']['rate']
            senseCfg = "{}, {} Hz, +/-0.2V".format(mode, rate)
        startTime = self.prettyTime(recording['recordingStartTs'])
        endTime = self.prettyTime(recording['recordingStopTs'])
        return([deviceName, location, senseCfg, startTime, endTime])
    
    def stringifyAnnotation(self, annotation):
        if annotation["event"]["type"] == "activity":
            annoType= "Activity"
        else:
            annoType= "Diary"
        annoName= annotation["event"]["displayName"]
        annoStartTime= self.prettyTime(annotation["startTs"])
        annoStopTime= self.prettyTime(annotation["stopTs"])
        return([annoType, annoName, annoStartTime, annoStopTime])
    
    def getMode(self, recData):
        mode= None
        pc= recData['physicalConfig']
        sc= recData['sensorConfig']
        sensingType= sc['sensingType']
        if sensingType == "MPU":
            if sc['gyro']['mode'] == "ACCEL_GYRO":
                mode = "Accel+Gyro"
            else:
                mode = "Accel"
        elif sensingType == "ACCEL_ANALOG":
            mode= "Accel+{}".format(pc['signal'])
        elif sensingType == "ACCEL":
            mode = "Accel"
        elif sensingType == "AFE":
            mode = pc['signal']
        return mode
     
    def writeMetadata(self, filenameHeader, recording, annoRelations= None):
        if filenameHeader[-4:] == ".csv":
            filenameHeader= filenameHeader[:-4]
        recData= recording[0]['recording']
        studyData= self.api.BioStampRCGetStudy(recData['studyId'])
        subjectData= self.api.BioStampRCGetSubject(recData['studyId'], recData['subjectId'])
        f="{}_metadata.csv".format(filenameHeader)
        d = os.path.dirname(f)
        if not os.path.exists(d):
            os.makedirs(d)
        metadataFile= open(f, "w")
        metadataFile.write("Study,{},{}\n".format(studyData['displayName'], studyData['title']))
        metadataFile.write("Subject ID,{},Age,{}".format(subjectData['displayName'],subjectData['age']))
        # The gender and dominantHand attributes are not set if they aren't specified when the Subject is created,
        # so we only print them if they exist.
        if 'gender' in subjectData:
            metadataFile.write(",Gender,{}".format(subjectData['gender']))
        metadataFile.write(",Height,{},Weight,{}".format(subjectData['height'],subjectData['weight']))
        if 'dominantHand' in subjectData:
            metadataFile.write(",Dominant Hand,{}".format(subjectData['dominantHand']))
        metadataFile.write("\n")
        sensorsSeen= [] # Only print data for each Sensor once. We need to check for multiple Sensors in case we're exporting Activity data 
        for rec in recording:
            recData= rec['recording']
            sensorName= self.api.BioStampRCGetDeviceName(recData['studyId'], recData['subjectId'], recData['udid'])
            if not recData['udid'] in sensorsSeen:
                sensorsSeen.append(recData['udid'])
                pc= recData['physicalConfig']
                sc= recData['sensorConfig']
                mode= self.getMode(recData)
                # Write metadata
                metadataFile.write("Sensor,{},Location,{},Side,{}\n".format(sensorName, pc['location'], pc['side']))
                metadataFile.write("Sensing Mode,{}\n".format(mode))
                if "ECG" in mode or "EMG" in mode:
                    metadataFile.write("{} Gain,{}\n{} Rate,{} Hz\n".format(pc['signal'], sc['afe']['gain'], pc['signal'], sc['afe']['rate']))
                if "Accel" in mode:
                    rate= 1000 / int(sc['gyro']['periodMs']) if "gyro" in sc else sc['accel']['rate']
                    accelRange= sc['gyro']['accelRange'] if "gyro" in sc else sc['accel']['range']
                    metadataFile.write("Accel Range,{} G\nAccel Rate,{} Hz\n".format(accelRange, rate))
                if "Gyro" in mode:
                    metadataFile.write("Gyro Range,{} deg/sec\nGyro Rate,{} Hz\n".format(sc['gyro']['gyroRange'], 1000 / int(sc['gyro']['periodMs'])))
                metadataFile.write("Start Date/Time,{},Timestamp (Epoch msec),{}\nStop Date/Time,{},Timestamp (Epoch msec),{}\n".format(self.prettyTime(recData['recordingStartTs']), recData['recordingStartTs'], self.prettyTime(recData['recordingStopTs']), recData['recordingStopTs']))
        if annoRelations is not None:
            for annoRelation in annoRelations:
                try:
                    if annoRelation["event"]["type"] == "question":
                        question= annoRelation["event"]["displayName"]
                        answer= annoRelation["value"]
                        annoTimestamp= annoRelation["startTs"]
                        metadataFile.write("Activity Annotation,{},Answer,{},Date/Time,{},Timestamp (Epoch msec),{}\n".format(question, answer, self.prettyTime(annoTimestamp), annoTimestamp))
                except:
                    pass
        metadataFile.close()
        return mode
    
    def writeExGData(self, filenameHeader, mode, recordings):
        trueMode= "ECG" if "ECG" in mode else "EMG"
        f="{}_{}.csv".format(filenameHeader, trueMode)
        d = os.path.dirname(f)
        if not os.path.exists(d):
            os.makedirs(d)
        outFile= open(f, "w")
        outFile.write("Date/Time,Epoch Time (msec),{} Signal (Volts)\n".format(trueMode))
        for recording in recordings:
            if recording['type'] == trueMode:
                for sample in zip(recording['times'], recording['values']['v']):
                    outFile.write("{},{},{}\n".format(self.prettyTime(sample[0]), sample[0], sample[1]))
        outFile.close()
                    
    def writeAccelData(self, filenameHeader, mode, recordings):
        f="{}_Gyro.csv".format(filenameHeader)
        d = os.path.dirname(f)
        if not os.path.exists(d):
            os.makedirs(d)
        outFile= open(f, "w")
        outFile.write("Date/Time,Epoch Time (msec),X Accel (G),Y Accel (G),Z Accel (G)\n")
        for recording in recordings:
            if recording['type'] == "ACCEL":
                for sample in zip(recording['times'], recording['values']['x'], recording['values']['y'], recording['values']['z']):
                    outFile.write("{},{},{},{},{}\n".format(self.prettyTime(sample[0]), sample[0], sample[1], sample[2], sample[3]))
        outFile.close()
                    
    def writeGyroData(self, filenameHeader, mode, recordings):
        f="{}_Gyro.csv".format(filenameHeader)
        d = os.path.dirname(f)
        if not os.path.exists(d):
            os.makedirs(d)
        outFile= open(f, "w")
        outFile.write("Date/Time,Epoch Time (msec),X Rotation (deg/sec),Y Rotation (deg/sec),Z Rotation (deg/sec)\n")
        for recording in recordings:
            if recording['type'] == "GYRO":
                for sample in zip(recording['times'], recording['values']['x'], recording['values']['y'], recording['values']['z']):
                    outFile.write("{},{},{},{},{}\n".format(self.prettyTime(sample[0]), sample[0], sample[1], sample[2], sample[3]))
        outFile.close()
                    
    def writeData(self, filenameHeader, mode, recording):
        if "ECG" in mode or "EMG" in mode:
            self.writeExGData(filenameHeader, mode, recording)
        if "Accel" in mode:
            self.writeAccelData(filenameHeader, mode, recording)
        if "Gyro" in mode:
            self.writeGyroData(filenameHeader, mode, recording)
    
    def recordingToCSV(self, recording, filenameHeader):
        if filenameHeader[-4:] == ".csv":
            filenameHeader= filenameHeader[:-4]
        mode= self.writeMetadata(filenameHeader, recording)
        self.writeData(filenameHeader, mode, recording)
        return True

    def annotationToCSV(self, recording, filenameHeader, annoRelations, selSubject, selAct, selTime):
        if filenameHeader[-4:] == ".csv":
            filenameHeader= filenameHeader[:-4]
        if len(recording) > 0:
            t=self.prettyTime(recording[1]['times'][1])
            d=filenameHeader+"\\"+selSubject+"\\"+t[4:10]+"\\"
            mode= self.writeMetadata("{}{}_{}-{}-{}".format(d,selAct,selTime[11:13],selTime[14:16],selTime[17:19]), recording, annoRelations)
            sensorsSeen= [] # Only print data for each Sensor once. We need to check for multiple Sensors in case we're exporting Activity data
            if not os.path.exists(d):
                os.makedirs(d)
            for rec in recording:
                recData= rec['recording']
                # Get mode separately for each recording
                mode= self.getMode(recData)
                sensorName= self.api.BioStampRCGetDeviceName(recData['studyId'], recData['subjectId'], recData['udid'])
                if not recData['udid'] in sensorsSeen:
                    sensorsSeen.append(recData['udid'])
                    sensorRec= []
                    for reco in recording:
                        if reco['recording']['udid'] == sensorsSeen[-1]:
                            sensorRec.append(reco)
                    if len(sensorRec) > 0:
                        self.writeData("{}{}\\{}_{}-{}-{}".format(d, sensorName, selAct,selTime[11:13],selTime[14:16],selTime[17:19]), mode, sensorRec)
            return True
        else:
            return False
    