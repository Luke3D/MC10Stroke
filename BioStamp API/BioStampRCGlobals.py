class BioStampRCGlobals(object):
    '''Class used to store variables that are accessed globally by BioStampRC.
    '''
    def __init__(self, master):
        self.master= master
        self.HOST= 'https://mc10cloud.com/api'
        self.LOGIN_URL= "%s/v1/user/login/email" # Deprecated, use */users/*
        self.LOGOUT_URL= "%s/v1/user/logout"
        self.STUDIES_URL= "%s/v1/accounts/%s/studies"
        self.STUDY_URL= "%s/v1/accounts/%s/studies/%s"
        self.SUBJECTS_URL= "%s/v1/studies/%s/subjects"
        self.SUBJECT_URL= "%s/v1/studies/%s/subjects/%s"
        self.RECORDINGS_URL= "%s/v1/studies/%s/subjects/%s/recordings"
        self.DEVICE_URL= "%s/v1/studies/%s/subjects/%s/devices/%s"
        self.DATA_URL= "%s/v1/studies/%s/subjects/%s/data?deviceId=%s&from=%s&to=%s"
        self.ANNOTATIONS_URL= "%s/v1/studies/%s/subjects/%s/annotations"
        self.ANNOTATIONDATA_URL= "%s/v1/studies/%s/annotations/%s/data"
        self.user= ''
        self.user_id= 0
        self.account_id= None
        self.access_token= None
        self.expire_ts= 0
        self.username= None
        self.password= None
        self.auth= None

    def setHost(self, Host):
        self.HOST= Host

    def getHost(self):
        return self.HOST

    def getLoginURL(self):
        return self.LOGIN_URL

    def getLogoutURL(self):
        return self.LOGOUT_URL

    def getStudiesURL(self):
        return self.STUDIES_URL
    
    def getStudyURL(self):
        return self.STUDY_URL

    def getSubjectsURL(self):
        return self.SUBJECTS_URL
    
    def getSubjectURL(self):
        return self.SUBJECT_URL

    def getRecordingsURL(self):
        return self.RECORDINGS_URL
    
    def getDeviceURL(self):
        return self.DEVICE_URL

    def getDataURL(self):
        return self.DATA_URL
    
    def getAnnotationsURL(self):
        return self.ANNOTATIONS_URL
    
    def getAnnotationDataURL(self):
        return self.ANNOTATIONDATA_URL

    def setUser(self, user):
        self.user= user

    def getUser(self):
        return self.user

    def setUserID(self, user_id):
        self.user_id= user_id

    def getUserID(self):
        return self.user_id

    def setAccountID(self, account_id):
        self.account_id= account_id

    def getAccountID(self):
        return self.account_id

    def setAccessToken(self, access_token):
        self.access_token= access_token

    def getAccessToken(self):
        return self.access_token

    def setExpireTimestamp(self, expire_ts):
        self.expire_ts= expire_ts

    def getExpireTimestamp(self):
        return self.expire_ts

    def setUsername(self, username):
        self.username= username

    def getUsername(self):
        return self.username

    def setPassword(self, password):
        self.password= password

    def getPassword(self):
        return self.password

    def setAuth(self, auth):
        self.auth= auth

    def getAuth(self):
        return self.auth
