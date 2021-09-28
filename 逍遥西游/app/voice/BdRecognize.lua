Baidu_Voice_Appkey = "jgfVO8vnljvsjG7cveXP1ph2"
Baidu_Voice_Secretkey = "NsbxIHps87DbQLFFux5cjw00tKUIjczB"
Baidu_Voice_SampleRateInHz = 8000
local AccessToken_URL = "https://192.168.1.102/oauth/2.0/token"
local Recognize_URL = "http://192.168.1.102/server_api"
local OpenUDID = device.getOpenUDID()
local BdRecognize = class("BdRecognize")
function BdRecognize:ctor(...)
  self.m_TokenData = nil
  self.m_IsRecognizing = false
  self.m_RecognizString = nil
  self.m_RecognizDataLen = 0
  self.m_RecognizListener = nil
  self.m_RequestTokenInOneRecognize = false
end
function BdRecognize:getAccessToken(listener)
  function onRequestFinished(event)
    if event.name ~= "inprogress" then
      local ok = event.name == "completed"
      local request = event.request
      if not ok then
        print(request:getErrorCode(), request:getErrorMessage())
        if listener then
          listener(false)
        end
        return
      end
      local code = request:getResponseStatusCode()
      if code ~= 200 then
        print(code)
        return
      end
      local response = request:getResponseString()
      print(response)
      local data = json.decode(response)
      self.m_TokenData = data
      dump(data, "data")
      if listener then
        listener(true)
      end
    end
  end
  local url = string.format("%s?grant_type=client_credentials&client_id=%s&client_secret=%s", AccessToken_URL, Baidu_Voice_Appkey, Baidu_Voice_Secretkey)
  print("url=", url)
  local request = network.createHTTPRequest(onRequestFinished, url, kCCHTTPRequestMethodPOST)
  request:addRequestHeader("Content-Type:application/json")
  request:start()
end
function BdRecognize:startRecognize(listener)
  if self.m_IsRecognizing == true then
    if listener then
      listener(false)
    end
    return
  end
  self.m_IsRecognizing = true
  self.m_RecognizString = recognizeStr
  self.m_RecognizDataLen = dataLen
  self.m_RecognizListener = listener
  self.m_RequestTokenInOneRecognize = false
  self:_recognize()
end
function BdRecognize:_recognizeFinish(isSucceed, resultStr)
  self.m_IsRecognizing = false
  local listener = self.m_RecognizListener
  self.m_RecognizListener = nil
  if listener then
    listener(isSucceed, resultStr)
  end
end
function BdRecognize:_recognize()
  if self.m_TokenData == nil then
    self.m_RequestTokenInOneRecognize = true
    self:getAccessToken(handler(self, self._HadGetToken))
  else
    self:_HadGetToken()
  end
end
function BdRecognize:_HadGetToken()
  print("---->> _HadGetToken")
  if self.m_TokenData == nil then
    self:_recognizeFinish(false)
    return
  end
  VoiceInter.startRecord(Baidu_Voice_SampleRateInHz, Recognize_URL, OpenUDID, self.m_TokenData.access_token)
end
