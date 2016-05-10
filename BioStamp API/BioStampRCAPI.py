from BioStampRCDecorators import retry
import json
import time
import requests
from requests.auth import HTTPBasicAuth
import getpass

class BioStampRCAPI(object):
    '''A master class for holding BioStampRC API Calls.
    '''
    #TODO: flesh out the notes above to form a readme - about, installation, examples, some documentation of how to parse the responses from the API
    #TODO: document the order of operations (get study, get subjects, etc)
    def __init__(self, master, brcGlobals):
        self.master = master
        self.globals = brcGlobals

    class UsernamePasswordDialog():
        # TODO: incorporate this into the GUI
        def __init__(self, parent):
            self.parent = parent
            self.parent.tempUsername = input("Username: ")
            self.parent.tempPassword = getpass.getpass()

    @retry(tries=2, delay=0, backoff=2)
    def BioStampRCAPILogin(self):
        '''API Login process. Returns True if login successful, False if unsuccessful. Will cache login info so
        it can be safely called before any API access call.
        '''
        # If we already have a valid login, just return
        if self.globals.getAccessToken() is not None and self.globals.getExpireTimestamp() > time.time() + 30:
            return True
        url = self.globals.getLoginURL() % self.globals.getHost()
        if self.globals.getUsername() is None or self.globals.getPassword() is None:
            self.UsernamePasswordDialog(self)
        else:
            self.tempUsername = self.globals.getUsername()
            self.tempPassword = self.globals.getPassword()
        data = {'email': self.tempUsername, 'password': self.tempPassword}
        resp = requests.post(url, data=data)
        if resp.status_code == 200:
            resp_obj = json.loads(resp.text)
            self.globals.setUser(resp_obj['user'])
            self.globals.setUserID(self.globals.getUser()['id'])
            self.globals.setAccountID(self.globals.getUser()['accountId'])
            self.globals.setAccessToken(resp_obj['accessToken'])
            self.globals.setExpireTimestamp(int(resp_obj['expiration']))
            self.globals.setUsername(self.tempUsername)
            self.globals.setPassword(self.tempPassword)
            self.globals.setAuth(HTTPBasicAuth(self.globals.getUserID(), self.globals.getAccessToken()))
            return True
        else:
            return False

    def BioStampRCAPILogout(self):
        url = self.globals.getLogoutURL() % self.globals.getHost()
        resp = requests.post(url, auth=self.globals.getAuth())
        if resp.status_code == 204:
            return True
        else:
            return False

    def BioStampRCGetStudies(self):
        if self.BioStampRCAPILogin() is True:
            url = self.globals.getStudiesURL() % (self.globals.getHost(), self.globals.getAccountID())
            resp = requests.get(url, auth=self.globals.getAuth())
            if resp.status_code == 200:
                studies = json.loads(resp.text)
                studies_dict = {}
                for study in studies:
                    _id = study['id']
                    studies_dict[_id] = study
                return studies_dict
            else:
                return None
        else:
            return False
        
    def BioStampRCGetStudy(self, studyId):
        if self.BioStampRCAPILogin() is True:
            url = self.globals.getStudyURL() % (self.globals.getHost(), self.globals.getAccountID(), studyId)
            resp = requests.get(url, auth=self.globals.getAuth())
            if resp.status_code == 200:
                return json.loads(resp.text)
            else:
                return None
        else:
            return False

    def BioStampRCDictFromURL(self, url, auth):
            resp = requests.get(url, auth=self.globals.getAuth())
            if resp.status_code == 200:
                response = json.loads(resp.text)
                items = response['items']
                items_dict = {}
                for item in items:
                    _id = item['id']
                    items_dict[_id] = item
                return items_dict
            else:
                return None

    def BioStampRCGetSubjects(self, studyID):
        if self.BioStampRCAPILogin() is True:
            url = self.globals.getSubjectsURL() % (self.globals.getHost(), studyID)
            return self.BioStampRCDictFromURL(url, self.globals.getAuth())
        else:
            return False
        
    def BioStampRCGetSubject(self, studyID, subjectID):
        if self.BioStampRCAPILogin() is True:
            url = self.globals.getSubjectURL() % (self.globals.getHost(), studyID, subjectID)
            resp = requests.get(url, auth=self.globals.getAuth())
            return json.loads(resp.text)
        else:
            return False

    def BioStampRCGetRecordingList(self, studyID, subjectID):
        if self.BioStampRCAPILogin() is True:
            url = self.globals.getRecordingsURL() % (self.globals.getHost(), studyID, subjectID)
            return self.BioStampRCDictFromURL(url, self.globals.getAuth())
        else:
            return False
        
    def BioStampRCGetAnnotationsList(self, studyID, subjectID):
        if self.BioStampRCAPILogin() is True:
            url = self.globals.getAnnotationsURL() % (self.globals.getHost(), studyID, subjectID)
            return self.BioStampRCDictFromURL(url, self.globals.getAuth())
        else:
            return False
        
    def BioStampRCGetDeviceName(self, studyID, subjectID, deviceID):
        if self.BioStampRCAPILogin() is True:
            url = self.globals.getDeviceURL() % (self.globals.getHost(), studyID, subjectID, deviceID)
            resp = requests.get(url, auth=self.globals.getAuth())
            if resp.status_code == 200:
                response = json.loads(resp.text)
                return response['items'][0]['displayName']
            else:
                return None
        else:
            return False
        
        
    def BioStampRCGetData(self, studyID, subjectID, deviceID, startTs, endTs):
        if self.BioStampRCAPILogin() is True:
            url = self.globals.getDataURL() % (self.globals.getHost(), studyID, subjectID, deviceID, startTs, endTs)
            resp= requests.get(url, auth= self.globals.getAuth())
            if resp.status_code == 200:
                response= json.loads(resp.text)
                recordings= response['channels']
                while 'links' in response:
                    if self.BioStampRCAPILogin() is True:
                        resp= requests.get("{}{}".format(self.globals.getHost(), response['links'][-1]['href']), auth=self.globals.getAuth())
                        if resp.status_code == 200:
                            response= json.loads(resp.text)
                            for recording in response['channels']:
                                recordings.append(recording)
                        else:
                            print("Response status code: {} {}".format(resp.status_code, resp))
                return recordings
            else:
                return []
        else:
            return False

    def BioStampRCGetAnnotationData(self, studyID, annoID):
        if self.BioStampRCAPILogin() is True:
            url = self.globals.getAnnotationDataURL() % (self.globals.getHost(), studyID, annoID)
            resp= requests.get(url, auth= self.globals.getAuth())
            if resp.status_code == 200:
                response= json.loads(resp.text)
                #print("Anno response: {}".format(response))
                recordings= response['channels']
                while 'links' in response:
                    if self.BioStampRCAPILogin() is True:
                        resp= requests.get("{}{}".format(self.globals.getHost(), response['links'][-1]['href']), auth=self.globals.getAuth())
                        if resp.status_code == 200:
                            response= json.loads(resp.text)
                            for recording in response['channels']:
                                recordings.append(recording)
                        else:
                            print("Response status code: {} {}".format(resp.status_code, resp))
                return recordings
            else:
                return []
        else:
            return False
        