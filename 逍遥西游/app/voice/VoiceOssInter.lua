local lfs = require("lfs")
local VoiceOssInter = class("VoiceOssInter")
local AppID = "mKcuaMiSAMfc8TO9"
local AppSecret = "7VZzAsy6yh4wNorKEBg6iKzg3q45Fx"
local OssUrlPre = "https://%s.oss-cn-b.a.com"
function VoiceOssInter:ctor()
  self.m_UploadBucket = "syvoicep"
  self.m_UploadNeedSign = false
  if cryptext ~= nil and cryptext.hmacsh1 ~= nil then
    self.m_UploadBucket = "syvoice"
    self.m_UploadNeedSign = true
  end
  self.m_isExist = true
  self.M_UploadList = {}
  self.m_VoiceDataPath = device.writablePath .. "recordvoicedata/"
  lfs.mkdir(self.m_VoiceDataPath)
  self.m_DownloadVoiceData = {}
end
function VoiceOssInter:getUrl(bucket)
  return string.format(OssUrlPre, bucket)
end
function VoiceOssInter:DownlaodVoiceData(bucket, savePathAndName, md5String, listener)
  local data = self.m_DownloadVoiceData[md5String]
  if data then
    if data.isRequesting == 1 then
      if data.listener == nil then
        data.listener = {}
      else
        data.listener[#data.listener + 1] = listener
      end
      print("正在获取，返回")
      return
    elseif data.pcmString then
      if listener then
        print("已经获取过")
        listener(true, data.pcmString, md5String)
      end
      return
    end
  else
    print("第一次获取该md5对应的数据")
    self.m_DownloadVoiceData[md5String] = {
      isRequesting = 1,
      listener = {listener}
    }
  end
  local tryTimes = 1
  local cblistener
  function cblistener(isSucceed, getDataString)
    if isSucceed then
      self:_DownVoiceDataResult(true, getDataString, md5String)
    elseif tryTimes < 3 then
      tryTimes = tryTimes + 1
      scheduler.performWithDelayGlobal(function()
        self:_DownlaodVoiceData(bucket, savePathAndName, md5String, cblistener)
      end, 2)
    else
      self:_DownVoiceDataResult(false, nil, md5String)
    end
  end
  self:_DownlaodVoiceData(bucket, savePathAndName, md5String, cblistener)
end
function VoiceOssInter:_DownVoiceDataResult(isSucceed, pcmData, md5String)
  local data = self.m_DownloadVoiceData[md5String]
  if data == nil then
    return
  end
  local listener = data.listener or {}
  for i, _listener in ipairs(listener) do
    _listener(isSucceed, pcmData, md5String)
  end
  data.listener = {}
  data.isRequesting = 0
  if isSucceed then
    data.pcmString = pcmData
  else
    data.pcmString = nil
  end
end
function VoiceOssInter:_DownlaodVoiceData(bucket, savePathAndName, md5String, cblistener)
  local url = string.format("%s/xiyou/%s", self:getUrl(bucket), savePathAndName)
  print([[


]])
  print("DownlaodVoiceData------>", url, cblistener)
  local lastRecordTime = cc.net.SocketTCP.getTime()
  local lastRecordProc = 0
  local isCancel = false
  local handler, request
  local function cancelScheduler()
    if handler then
      scheduler.unscheduleGlobal(handler)
      handler = nil
    end
  end
  handler = scheduler.scheduleGlobal(function()
    local ct = cc.net.SocketTCP.getTime()
    print("ct - lastRecordTime:", ct, lastRecordTime, ct - lastRecordTime, lastRecordProc)
    if ct - lastRecordTime >= 15 then
      cancelScheduler()
      if request then
        print("--->> request cancel")
        request:cancel()
      end
      isCancel = true
      if cblistener then
        cblistener(false)
      end
    end
  end, 1)
  local function callback(event)
    if isCancel or self.m_isExist ~= true then
      return
    end
    if event.name == "inprogress" or event.name == "progress" then
      local dlnow = event.dlnow
      if dlnow == nil then
        dlnow = event.dltotal
      end
      print("receving inprogress ===>>>", dlnow)
      if lastRecordProc ~= dlnow then
        lastRecordProc = dlnow
        lastRecordTime = cc.net.SocketTCP.getTime()
      end
    else
      cancelScheduler()
      local ok = event.name == "completed"
      local request = event.request
      if not ok then
        print("DownlaodVoiceData Error:", request:getErrorCode(), request:getErrorMessage())
        if cblistener then
          cblistener(false)
        end
        return
      end
      local code = request:getResponseStatusCode()
      if code ~= 200 then
        print("DownLoadFile Error:", code)
        if cblistener then
          cblistener(false)
        end
        return
      end
      local getDataString = request:getResponseString()
      local getMd5 = crypto.md5(getDataString, false)
      if md5String ~= getMd5 then
        print("获取的数据验证MD5失败:", getMd5, md5String)
        if cblistener then
          cblistener(false)
        end
      else
        print("获取的数据验证MD5通过:", getMd5, md5String)
        if cblistener then
          cblistener(true, getDataString)
        end
      end
    end
  end
  print(string.format([[

requestUserIcon:
url=%s
]], url))
  request = network.createHTTPRequest(callback, url, "GET")
  request:setTimeout(1001)
  request:start()
end
function VoiceOssInter:UploadVoiceData(voiceData, listener)
  local md5String = crypto.md5(voiceData, false)
  self.m_DownloadVoiceData[md5String] = {
    isRequesting = 0,
    listener = {},
    pcmString = voiceData
  }
  local pid, serverId
  if g_LocalPlayer then
    pid = g_LocalPlayer:getPlayerId()
  end
  if g_DataMgr then
    local d = g_DataMgr:getCacheServerData()
    if d then
      serverId = d.m_ChoosedLoginServerId
    end
  end
  if pid == nil or serverId == nil then
    if listener then
      listener(false)
    end
    return false
  end
  local curTime = g_DataMgr:getServerTime()
  if curTime == -1 then
    curTime = os.time()
  end
  local fileName = string.format("%s%s%s%s", serverId, pid, tostring(checkint(curTime)), tostring(math.random(1000, 9999)))
  print("fileName:", fileName)
  local year = os.date("%Y", curTime)
  local month = os.date("%m", curTime)
  local day = os.date("%d", curTime)
  local folder = string.format("%s_%s_%s", year, month, day)
  local savePath = self.m_VoiceDataPath .. fileName
  io.writefile(savePath, voiceData)
  local savePathAndName = string.format("%s/%s", folder, fileName)
  local url = self:getUrl(self.m_UploadBucket, "")
  print("url=", url)
  self:_addUploadList(url, savePath, fileName, savePathAndName, listener)
  return true, savePathAndName, self.m_UploadBucket, md5String
end
function VoiceOssInter:_addUploadList(url, filePath, fileName, savePathAndName, listener)
  local tryTimes = 1
  local onRequestFinished
  local function uploadFunc()
    print([[



]])
    print("-------->>VoiceOssInter:_addUploadList")
    print("tryTimes:", tryTimes)
    print("url:", url)
    print("filePath:", filePath)
    print("fileName:", fileName)
    print("savePathAndName:", savePathAndName)
    print("self.m_UploadNeedSign:", self.m_UploadNeedSign)
    print("self.m_UploadBucket:", self.m_UploadBucket)
    local otTime = g_DataMgr:getServerTime()
    if curTime == -1 then
      otTime = os.time()
    end
    otTime = os.time() + 28800 + 840
    local success_action_status = "200"
    local request = network.createHTTPRequest(onRequestFinished, url, kCCHTTPRequestMethodPOST)
    if self.m_UploadNeedSign then
      request:addFormContents("OSSAccessKeyId", tostring(AppID))
      local CONTENT_MD5 = ""
      local CONTENT_TYPE = ""
      local expireTimeStr = os.date("%Y-%m-%dT%H:%M:%S.000Z", otTime)
      local policy = {
        expiration = expireTimeStr,
        conditions = {
          {
            bucket = self.m_UploadBucket
          }
        }
      }
      local policyJson = json.encode(policy)
      print("policyJson:", policyJson)
      local policyJsonBase64 = crypto.encodeBase64(policyJson)
      local policyJsonData = cryptext.hmacsh1(AppSecret, policyJsonBase64)
      print("policyJsonData:", string.len(policyJsonData), policyJsonData)
      local policyJsonDataEn = crypto.encodeBase64(policyJsonData)
      print("policyJsonDataEn:", string.len(policyJsonDataEn), policyJsonDataEn)
      request:addFormContents("policy", policyJsonBase64)
      request:addFormContents("Signature", policyJsonDataEn)
    end
    request:addFormContents("Cache-control", "200")
    request:addFormContents("Content-Disposition", string.format("attachment;filename=%s", fileName))
    request:addFormContents("Content-Encoding", "UTF-8")
    request:addFormContents("Expires", string.format("%d", otTime))
    request:addFormContents("success_action_status", "200")
    request:addFormContents("key", string.format("xiyou/%s", savePathAndName))
    request:addFormContents("submit", "Upload to OSS")
    request:addFormFile("file", filePath, "text/plain")
    request:setTimeout(20)
    request:start()
  end
  local function uploadResult(isSucceed)
    local delFile = true
    if isSucceed then
      if listener then
        listener(true)
      end
    elseif tryTimes <= 3 then
      delFile = false
      tryTimes = tryTimes + 1
      scheduler.performWithDelayGlobal(function()
        uploadFunc()
      end, 2)
    elseif listener then
      listener(false)
    end
    if delFile then
      os.remove(filePath)
    end
  end
  function onRequestFinished(event)
    if event.name ~= "inprogress" and event.name ~= "progress" then
      print([[


]])
      print("onRequestFinished")
      local ok = event.name == "completed"
      local request = event.request
      if not ok then
        print(request:getErrorCode(), request:getErrorMessage())
        if uploadResult then
          uploadResult(false)
        end
        return
      end
      local code = request:getResponseStatusCode()
      if code ~= 200 and code ~= 204 and code ~= 201 then
        print("code:", code)
        local response = request:getResponseString()
        print(response)
        if uploadResult then
          uploadResult(false)
        end
        return
      end
      local response = request:getResponseString()
      print(response)
      local data = json.decode(response)
      dump(data, "data")
      if uploadResult then
        uploadResult(true)
      end
    end
  end
  uploadFunc()
end
function VoiceOssInter:test()
  local voiceData = "IyFBTVIKPJEXFr5meeHgAeev8AAAAIAAAAAAAAAAAAAAAAAAAAA8SHcklmZ54eAB57rwAAAAwAAAAAAAAAAAAAAAAAAAADxVAIi2Znnh4AHnz/AAAACAAAAAAAAAAAAAAAAAAAAAPEj5H5ZmeeHgAeeK8AAAAMAAAAAAAAAAAAAAAAAAAAA8VP0ftmZ54eAB58/wAAAAgAAAAAAAAAAAAAAAAAAAADxI9R+WZnnh4AHnivAAAADAAAAAAAAAAAAAAAAAAAAAPFT9H7ZmeeHgAefP8AAAAIAAAAAAAAAAAAAAAAAAAAA8SPUflmZ54eAB54rwAAAAwAAAAAAAAAAAAAAAAAAAADxU/R+2Znnh4AHnz/AAAACAAAAAAAAAAAAAAAAAAAAAPEj1H5ZmeeHgAeeK8AAAAMAAAAAAAAAAAAAAAAAAAAA8VP0ftmZ54eAB58/wAAAAgAAAAAAAAAAAAAAAAAAAADxI9R+WZnnh4AHnivAAAADAAAAAAAAAAAAAAAAAAAAAPFT9H7ZmeeHgAefP8AAAAIAAAAAAAAAAAAAAAAAAAAA8SPUflmZ54eAB54rwAAAAwAAAAAAAAAAAAAAAAAAAADxU/R+2Znnh4AHnz/AAAACAAAAAAAAAAAAAAAAAAAAAPEj1H5ZmeeHgAeeK8AAAAMAAAAAAAAAAAAAAAAAAAAA8VP0ftmZ54eAB58/wAAAAgAAAAAAAAAAAAAAAAAAAADxI9R+WZnnh4AHnivAAAADAAAAAAAAAAAAAAAAAAAAAPFT9H7ZmeeHgAefP8AAAAIAAAAAAAAAAAAAAAAAAAAA8SPUflmZ54eAB54rwAAAAwAAAAAAAAAAAAAAAAAAAADxU/R+2Znnh4AHnz/AAAACAAAAAAAAAAAAAAAAAAAAAPEj1H5ZmeeHgAeeK8AAAAMAAAAAAAAAAAAAAAAAAAAA8VP0ftmZ54eAB58/wAAAAgAAAAAAAAAAAAAAAAAAAADxI9R+WZnnh4AHnivAAAADAAAAAAAAAAAAAAAAAAAAAPFT9H7ZmeeHgAefP8AAAAIAAAAAAAAAAAAAAAAAAAAA8SPUflmZ54eAB54rwAAAAwAAAAAAAAAAAAAAAAAAAADxU/R+2Znnh4AHnz/AAAACAAAAAAAAAAAAAAAAAAAAAPEj1H5ZmeeHgAeeK8AAAAMAAAAAAAAAAAAAAAAAAAAA8VP0ftmZ54eAB58/wAAAAgAAAAAAAAAAAAAAAAAAAADxI9R+WZnnh4AHnivAAAADAAAAAAAAAAAAAAAAAAAAAPFT9H7ZmeeHgAefP8AAAAIAAAAAAAAAAAAAAAAAAAAA8SPUflmZ54eAB54rwAAAAwAAAAAAAAAAAAAAAAAAAADxU/R+2Znnh4AHnz/AAAACAAAAAAAAAAAAAAAAAAAAAPEj1H5ZmeeHgAeeK8AAAAMAAAAAAAAAAAAAAAAAAAAA8VP0ftmZ54eAB58/wAAAAgAAAAAAAAAAAAAAAAAAAADxI9R+WZnnh4AHnivAAAADAAAAAAAAAAAAAAAAAAAAAPFT9H7ZmeeHgAefP8AAAAIAAAAAAAAAAAAAAAAAAAAA8SPUflmZ54eAB54rwAAAAwAAAAAAAAAAAAAAAAAAAADxU/R+2Znnh4AHnz/AAAACAAAAAAAAAAAAAAAAAAAAAPEj1H5ZmeeHgAeeK8AAAAMAAAAAAAAAAAAAAAAAAAAA8VP0ftmZ54eAB58/wAAAAgAAAAAAAAAAAAAAAAAAAADxI9R+WZnnh4AHnivAAAADAAAAAAAAAAAAAAAAAAAAAPFT9H7ZmeeHgAefP8AAAAIAAAAAAAAAAAAAAAAAAAAA8SPUflmZ54eAB54rwAAAAwAAAAAAAAAAAAAAAAAAAADxU/R+2Znnh4AHnz/AAAACAAAAAAAAAAAAAAAAAAAAAPEj1H5ZmeeHgAeeK8AAAAMAAAAAAAAAAAAAAAAAAAAA8VP0ftmZ54eAB58/wAAAAgAAAAAAAAAAAAAAAAAAAADxI9R+WZnnh4AHnivAAAADAAAAAAAAAAAAAAAAAAAAAPFT9H7ZmeeHgAefP8AAAAIAAAAAAAAAAAAAAAAAAAAA8SPUflmZ54eAB54rwAAAAwAAAAAAAAAAAAAAAAAAAADxU/R+2Znnh4AHnz/AAAACAAAAAAAAAAAAAAAAAAAAAPEj1H5ZmeeHgAeeK8AAAAMAAAAAAAAAAAAAAAAAAAAA8VP0ftmZ54eAB58/wAAAAgAAAAAAAAAAAAAAAAAAAADxI9R+WZnnh4AHnivAAAADAAAAAAAAAAAAAAAAAAAAAPFT9H7ZmeeHgAefP8AAAAIAAAAAAAAAAAAAAAAAAAAA8SPUflmZ54eAB54rwAAAAwAAAAAAAAAAAAAAAAAAAADxU/R+2Znnh4AHnz/AAAACAAAAAAAAAAAAAAAAAAAAAPEj1H5ZmeeHgAeeK8AAAAMAAAAAAAAAAAAAAAAAAAAA8VP0ftmZ54eAB58/wAAAAgAAAAAAAAAAAAAAAAAAAADxI9R+WZnnh4AHnivAAAADAAAAAAAAAAAAAAAAAAAAAPFT9H7ZmeeHgAefP8AAAAIAAAAAAAAAAAAAAAAAAAAA8SPUflmZ54eAB54rwAAAAwAAAAAAAAAAAAAAAAAAAADxU/R+2Znnh4AHnz/AAAACAAAAAAAAAAAAAAAAAAAAAPEj1H5ZmeeHgAeeK8AAAAMAAAAAAAAAAAAAAAAAAAAA8VP0ftmZ54eAB58/wAAAAgAAAAAAAAAAAAAAAAAAAADxI9R+WZnnh4AHnivAAAADAAAAAAAAAAAAAAAAAAAAAPFT9H7ZmeeHgAefP8AAAAIAAAAAAAAAAAAAAAAAAAAA8SPUflmZ54eAB54rwAAAAwAAAAAAAAAAAAAAAAAAAADxU/R+2Znnh4AHnz/AAAACAAAAAAAAAAAAAAAAAAAAAPEj1H5ZmeeHgAeeK8AAAAMAAAAAAAAAAAAAAAAAAAAA8VP0ftmZ54eAB58/wAAAAgAAAAAAAAAAAAAAAAAAAADxI9R+WZnnh4AHnivAAAADAAAAAAAAAAAAAAAAAAAAAPFT9H7ZmeeHgAefP8AAAAIAAAAAAAAAAAAAAAAAAAAA8SPUflmZ54eAB54rwAAAAwAAAAAAAAAAAAAAAAAAAADxU/R+2Znnh4AHnz/AAAACAAAAAAAAAAAAAAAAAAAAAPEj1H5ZmeeHgAeeK8AAAAMAAAAAAAAAAAAAAAAAAAAA="
  local canUpload, savePathAndName, bucket, md5Str
  local function uploadFunc(isSucceed)
    print("UploadVoiceData-------->>")
    print("isSucceed:", isSucceed)
    if isSucceed and canUpload then
      g_VoiceOssInter:DownlaodVoiceData(bucket, savePathAndName, md5Str, function(isSucceed, data)
        print([[



]])
        print("DownlaodVoiceData-------->> 1111")
        print("isSucceed:", isSucceed)
        print("data:", data)
        print([[



]])
      end)
      g_VoiceOssInter:DownlaodVoiceData(bucket, savePathAndName, md5Str, function(isSucceed, data)
        print([[



]])
        print("DownlaodVoiceData-------->>2222")
        print("isSucceed:", isSucceed)
        print("data:", data)
        print([[



]])
      end)
      scheduler.performWithDelayGlobal(function()
        g_VoiceOssInter:DownlaodVoiceData(bucket, savePathAndName, md5Str, function(isSucceed, data)
          print([[



]])
          print("DownlaodVoiceData-------->>3333")
          print("isSucceed:", isSucceed)
          print("data:", data)
          print([[



]])
        end)
      end, 5)
    end
  end
  canUpload, savePathAndName, bucket, md5Str = self:UploadVoiceData(voiceData, uploadFunc)
end
function VoiceOssInter:Clean()
  self.m_isExist = nil
end
if g_VoiceOssInter then
  g_VoiceOssInter:Clean()
end
g_VoiceOssInter = VoiceOssInter.new()
