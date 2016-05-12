#!/usr/bin/env python3
import BioStampRCAPI
import BioStampRCGlobals
import BioStampRCIO

class BioStampRC(object):
    '''The main application class for BioStampRC
    '''
    def __init__(self):
        self.globals = BioStampRCGlobals.BioStampRCGlobals(self)
        self.api = BioStampRCAPI.BioStampRCAPI(self, self.globals)
        self.io= BioStampRCIO.BioStampRCIO(self, self.globals, self.api)
        studies = self.api.BioStampRCGetStudies()
        studyList= []
        subjectList= []
        annotationList= []
        recordingList= []
        if studies is False:
            print("Error logging in, sorry.")
        elif studies is not None:
            response= True
            while response is True:
                # Choose a Study from the list of Studies
                for studyKey in studies.keys():
                    print("{}. Study {} : {} {}".format(len(studyList), studies[studyKey]['displayName'], studies[studyKey]['title'], self.io.prettyTime(studies[studyKey]['createdTs'])))
                    studyList.append(studies[studyKey])
                studyNumber= -1
                while not 0 <= studyNumber < len(studyList):
                    try: 
                        studyNumber= int(input("Choose a study Number: "))
                    except:
                        studyNumber= -1
                # Get the list of Subjects for the chosen Study and choose one
                subjects = self.api.BioStampRCGetSubjects(studyList[studyNumber]['id'])
                for subjectKey in subjects.keys():
                    print("  {}. Subject {}".format(len(subjectList), subjects[subjectKey]['displayName']))
                    subjectList.append(subjects[subjectKey])
                if len(subjectList) == 0:
                    resp= input("No subjects! Choose another Study? (Y/N): ")
                    response= True if "Y" in resp or "y" in resp else False
                else:
                    subjectNumber= -1
                    while not 0 <= subjectNumber < len(subjectList):
                        try:
                            subjectNumber= int(input("Choose a subject Number: "))
                        except:
                            subjectNumber= -1
                    annoVsRec= -1
                    while not 0 <= annoVsRec <= 1:
                        try:
                            annoVsRec= int(input("Download Activity/Diary Data (0) or Full Recording (1)? "))
                        except:
                            annoVsRec= -1
                    if annoVsRec == 0:
                        annotations= self.api.BioStampRCGetAnnotationsList(studyList[studyNumber]['id'], subjectList[subjectNumber]['id'])
                        for annotationKey in annotations.keys():
                            if "event" in annotations[annotationKey]:
                                annoType= annotations[annotationKey]["event"]["type"]
                                if annoType == "activity" or annoType == "diary":
                                    sa= self.io.stringifyAnnotation(annotations[annotationKey])
                                    print("    {}. {}: {} {} - {}".format(len(annotationList), sa[0], sa[1], sa[2], sa[3]))
                                    annotationList.append(annotations[annotationKey])
                        if len(annotationList) == 0:
                            resp= input("No annotations for that subject! Start over? (Y/N): ")
                            response= True if "Y" in resp or "y" in resp else False
                        else:
                            annotationNumber= -1
                            while not 0 <= annotationNumber < len(annotationList):
                                try:
                                    annotationNumber= int(input("Choose an annotation Number: "))
                                except:
                                    annotationNumber= -1
                            outputName= input("Output folder: ")
                            for val in range(0,annotationNumber):
                                anno= annotationList[val]
                                #print(anno.keys())
                                sa= self.io.stringifyAnnotation(anno)
                                data= self.api.BioStampRCGetAnnotationData(anno["studyId"], anno["id"])
                                #print("Annotation Data: {}".format(data))
                                # Get list of other annotations that are associated, e.g. questions
                                annoRelations= []
                                for annotationKey in annotations.keys():
                                    if "event" in annotations[annotationKey] and "relationship" in annotations[annotationKey]["event"]:
                                        if annotations[annotationKey]["event"]["relationship"]["id"] == anno["event"]["id"]:
                                            if annotations[annotationKey]["stopTs"]==anno["stopTs"]:
                                                annoRelations.append(annotations[annotationKey]) 
                                self.io.annotationToCSV(data, outputName, annoRelations, subjectList[subjectNumber]['displayName'],sa[1],sa[2])
                            
                    else:
                        # Get the list of Recordings for the chosen Study and Subject and choose one
                        recordings = self.api.BioStampRCGetRecordingList(studyList[studyNumber]['id'], subjectList[subjectNumber]['id'])
                        for recordingKey in recordings.keys():
                            recording= recordings[recordingKey]
                            sr = self.io.stringifyRecording(recordings[recordingKey])
                            print("    {}. {} {} {} {} - {}".format(len(recordingList), sr[0], sr[1], sr[2], sr[3], sr[4]))
                            #print("   {} {} {} {}".format(recording['studyId'], recording['subjectId'], recording['id'], recording['udid']))
                            recordingList.append(recordings[recordingKey])
                        if len(recordingList) == 0:
                            resp= input("No recordings for that subject! Start over? (Y/N): ")
                            response= True if "Y" in resp or "y" in resp else False
                        else:
                            recordingNumber= -1
                            while not 0 <= recordingNumber < len(recordingList):
                                try:
                                    recordingNumber= int(input("Choose a recording Number: "))
                                except:
                                    recordingNumber= -1
                            outputName= input("Output filename: ")
                            rec= recordingList[recordingNumber]
                            data= self.api.BioStampRCGetData(rec['studyId'], rec['subjectId'], rec['udid'], rec['recordingStartTs'], rec['recordingStopTs'])
                            self.io.recordingToCSV(data, outputName)
                    resp= input("Download another? (Y/N): ")
                    response= True if "Y" in resp or "y" in resp else False
                # Clear the lists so numbers start at 0 again
                studyList= []
                subjectList= []
                annotationList= []
                recordingList= []
        if self.globals.getAccessToken() is not None:
            self.api.BioStampRCAPILogout()


if __name__ == "__main__":
    app = BioStampRC()
