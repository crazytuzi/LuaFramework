local Lplus = require("Lplus")
local json = require("Utility.json")
local malut = require("Utility.malut")
local LRUCache = require("Common.ECLRUCache")
local ECDebugOption = require("Main.ECDebugOption")
local ECSocialSpaceConfig = require("Main.SocialSpace.ECSocialSpaceConfig")
local ECSocialSpaceMan = Lplus.ForwardDeclare("ECSocialSpaceMan")
local ECGame = Lplus.ForwardDeclare("ECGame")
local cos_cfg = dofile("Configs/cos_cfg.lua")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local DeviceUtility = require("Utility.DeviceUtility")
local DynamicText = require("Utility.DynamicText")
local HTTPMETHOD = {Get = 1, Post = 2}
local HTTP_TIMEOUT_TIME = 60
local app_id, bucket_name
local secret_id = cos_cfg.secret_id or ""
local secret_key = cos_cfg.secret_key or ""
local cosapi_cgi_url = cos_cfg.cosapi_cgi_url
local detectionnapi_cgi_url = cos_cfg.detectionnapi_cgi_url
local slice_upload_file_size = cos_cfg.slice_upload_file_size
local sign_expired = cos_cfg.sign_expired
local root_folder = cos_cfg.root_folder
local portrait_folder = cos_cfg.portrait_folder
local picture_folder = cos_cfg.picture_folder
local video_folder = cos_cfg.video_folder
local cache_folder = cos_cfg.cache_folder
local pic_suffix = cos_cfg.pic_suffix
local video_suffix = cos_cfg.video_suffix
local cos_tag = cos_cfg.cos_tag
local pic_tag = cos_cfg.pic_tag
local pic_processing = cos_cfg.pic_processing
local cache_count_limit = cos_cfg.cache_count_limit
local upload_image_size_limit = cos_cfg.upload_image_size_limit
local upload_portrait_size_limit = cos_cfg.upload_portrait_size_limit
local ECSocialSpaceCosMan = Lplus.Class("ECSocialSpaceCosMan")
local def = ECSocialSpaceCosMan.define
local m_Instance
def.static("=>", ECSocialSpaceCosMan).Instance = function()
  if m_Instance == nil then
    m_Instance = ECSocialSpaceCosMan()
    m_Instance:OnInit()
  end
  return m_Instance
end
def.const("number").NONE_CUT = 0
def.const("number").CUT = 1
def.const("number").FROM_CAMERA = 0
def.const("number").FROM_ALBUM = 1
def.field("userdata").mCos = nil
def.field(LRUCache).mCosCache = nil
def.method().OnInit = function(self)
  if CosCloud then
    self:InitCosCloud(nil)
  end
  self.mCosCache = LRUCache.new("CosCache", cache_count_limit)
end
def.method("function").InitCosCloud = function(self, onInited)
  ECSocialSpaceMan.Instance():Req_GetCosConfig(function(config)
    if config == nil then
      if onInited then
        onInited(nil)
      end
      return
    end
    app_id = config.appId
    bucket_name = config.bucket
    cosapi_cgi_url = DynamicText.compile(cosapi_cgi_url, {
      region = config.region
    })()
    self.mCos = CosCloud.CosCloud(app_id, secret_id, secret_key, HTTP_TIMEOUT_TIME)
    self.mCos.COSAPI_CGI_URL = cosapi_cgi_url
    self.mCos.DETECTIONAPI_CGI_URL = detectionnapi_cgi_url
    self.mCos.SLICE_UPLOAD_FILE_SIZE = slice_upload_file_size
    self.mCos.SIGN_EXPIRED_TIME = sign_expired
    print("CosCloud inited")
    if onInited then
      onInited(self.mCos)
    end
  end)
end
def.method("=>", "number").GetExpireTime = function(self)
  return _G.GetServerTime() + (self.mCos and self.mCos.SIGN_EXPIRED_TIME or sign_expired)
end
def.method("function").GetSignature = function(self, callback)
  ECSocialSpaceMan.Instance():Req_GetUploadFileSign("", function(sign)
    if callback then
      callback(sign)
    end
  end)
end
def.method("string", "function").GetSignatureOnce = function(self, remotePath, callback)
  ECSocialSpaceMan.Instance():Req_GetUploadFileSign(remotePath, function(sign)
    if callback then
      callback(sign)
    end
  end)
end
def.method("string", "=>", "string").GetDetectionSignature = function(self)
  return ""
end
def.method("string", "string", "function", "function").UploadFile = function(self, localPath, filename, cb, onProgress)
  if not cb then
    warn("UploadFile: cb is nil!")
    return
  end
  if not self.mCos then
    warn("UploadFile: mCos is nil!")
    self:InitCosCloud(function(coscloud)
      if coscloud then
        self:UploadFile(localPath, filename, cb, onProgress)
      else
        local ret = {
          message = "UploadFile: Download COS Config Failed"
        }
        warn(ret.message)
        cb(ret)
      end
    end)
    return
  end
  local heroProp = _G.GetHeroProp()
  if not heroProp then
    return
  end
  local roleid = heroProp.id:tostring()
  local remotePath = "/" .. root_folder .. "/" .. roleid .. "/" .. filename
  local attr = {}
  attr.insertOnly = "0"
  local function OnUpload(erroCode, result, cb)
    if ECDebugOption.Instance().showSSlog then
      warn("ECSocialSpaceCosMan bucket_name, localPath, filename, erroCode, result:", bucket_name, localPath, filename, erroCode, result)
    end
    if not result or #result <= 1 then
      warn("coscloud uploadfile request failed")
      cb({
        message = "UploadFile Request Failed"
      })
      return
    end
    local jsonData = self:TryJsonDecode(result)
    if ECDebugOption.Instance().showSSlog then
      malut.printTable(jsonData)
    end
    if erroCode ~= 0 or type(jsonData) ~= "table" then
      warn("coscloud uploadfile result : ", result)
      cb({message = result})
      return
    end
    cb(jsonData)
  end
  local noneFunc = function(a, b)
  end
  local function OnGetSign(sign)
    self.mCos:UploadFileWithSign(bucket_name, remotePath, localPath, sign, function(erroCode, result)
      OnUpload(erroCode, result, cb)
    end, onProgress or noneFunc, attr)
  end
  _G.SafeCallback(onProgress, 0, 0)
  self:GetSignatureOnce(remotePath, OnGetSign)
end
def.method("string", "string", "function").DownloadFile = function(self, url, filename, callback)
  local function onDownloadFile(success, url, filename, data)
    if success then
      if callback then
        callback(filename)
      end
    else
      warn(string.format("ECSocialSpaceCosMan::Failed to download url = %s", url))
    end
  end
  GameUtil.downLoadUrl(url, filename, onDownloadFile)
end
def.method("string", "=>", "table").Detection = function(self, url)
  if not self.mCos then
    warn("ECSocialSpaceCosMan mCos is nil")
    return {}
  end
  if CUR_CODE_VERSION < _G.COS_EX_CODE_VERSION then
    return {}
  end
  local sign = self:GetDetectionSignature()
  local result = self.mCos:DetectionWithSign(bucket_name, url, sign)
  if not result or #result <= 1 then
    warn("coscloud Detection request faild")
    return {}
  end
  local jsonData = self:TryJsonDecode(result)
  if ECDebugOption.Instance().showSSlog then
    malut.printTable(jsonData)
  end
  return jsonData
end
def.method("string", "function", "function").UploadPortrait = function(self, localPath, cb, onProgress)
  local filename = portrait_folder .. "/" .. _G.GetServerTime() .. pic_suffix
  self:UploadFile(localPath, filename, function(result)
    if result and result.ret == 0 then
      self:DeleteTmpDir()
    end
    if cb then
      cb(result)
    end
  end, onProgress)
end
def.method("string", "number", "number", "function", "function").UploadPicture = function(self, localPath, timestamp, idx, cb, onProgress)
  local filename = picture_folder .. "/" .. tostring(timestamp) .. "_" .. tostring(idx) .. pic_suffix
  self:UploadFile(localPath, filename, function(result)
    if cb then
      cb(result)
    end
  end, onProgress)
end
def.method("table", "number", "function", "function").UploadPictureList = function(self, localPathList, timestamp, cb, onProgress)
  if not cb then
    warn("UploadPictureList: cb is nil!")
    return
  end
  local resultList = {}
  local curUploadedCount = 0
  for idx = 1, #localPathList do
    do
      local localPath = localPathList[idx]
      local filename = picture_folder .. "/" .. tostring(timestamp) .. "_" .. tostring(idx) .. pic_suffix
      self:UploadFile(localPath, filename, function(result)
        resultList[idx] = result
        curUploadedCount = curUploadedCount + 1
        if curUploadedCount >= #localPathList then
          cb(resultList)
        end
      end, function(uploadProgress, progress)
        _G.SafeCallback(onProgress, idx, uploadProgress, progress)
      end)
    end
  end
end
def.method("string", "number", "function").UploadVideo = function(self, localPath, timestamp, cb)
  local filename = video_folder .. "/" .. timestamp .. video_suffix
  self:UploadFile(localPath, filename, function(result)
    if cb then
      cb(result)
    end
  end)
end
def.method("string", "function").LoadFile = function(self, url, callback)
  if platform == Platform.win and not cos_cfg.open_upload then
    if cos_cfg.test_image and #cos_cfg.test_image > 1 and callback then
      callback(GameUtil.GetAssetsPath() .. "/" .. cos_cfg.test_image)
    end
  else
    local pathStr = self:GenFilePath(url)
    if 1 >= string.len(pathStr) then
      return
    end
    local filename = GameUtil.GetAssetsPath() .. "/" .. pathStr
    local function onDownloadFile(filename)
      if callback then
        callback(filename)
        self:AddCosCache(filename, true)
        if _G.CUR_CODE_VERSION >= _G.COS_EX_CODE_VERSION then
          GameUtil.SetFileLastAccessTime(filename, _G.GetServerTime())
        end
      end
    end
    if not _G.FileExists(filename) then
      GameUtil.CreateDirectoryForFile(filename)
      self:DownloadFile(url, filename, onDownloadFile)
    else
      onDownloadFile(filename)
    end
  end
end
def.method("string", "=>", "string").GenFilePath = function(self, url)
  if string.len(url) < 1 then
    return ""
  end
  local _, _, str = string.find(url, root_folder .. "/(.+)")
  if not str then
    _, _, str = string.find(url, "com/(.+)")
  end
  if not str then
    return ""
  end
  local pathStr = str
  local idx = string.find(pathStr, "?")
  if idx then
    local paramsStr = string.sub(pathStr, idx + 1, -1)
    paramsStr = string.gsub(paramsStr, pic_processing, "")
    paramsStr = string.gsub(paramsStr, "/", "_")
    pathStr = string.sub(pathStr, 1, idx - 1)
    local _, _, name = string.find(pathStr, "(.+)%.")
    pathStr = string.gsub(pathStr, name, name .. paramsStr)
  end
  pathStr = string.gsub(pathStr, "/", "_")
  pathStr = cache_folder .. "/" .. pathStr
  return pathStr
end
def.static("string", "table", "=>", "string").PicProcessing = function(url, params)
  local pic_url = string.gsub(url, cos_tag, pic_tag)
  pic_url = pic_url .. "?" .. pic_processing
  if params.cuttype then
    pic_url = pic_url .. "/" .. params.cuttype
  end
  if params.w then
    pic_url = pic_url .. "/w/" .. params.w
  end
  if params.h then
    pic_url = pic_url .. "/h/" .. params.h
  end
  if params.q then
    pic_url = pic_url .. "/q/" .. params.q
  end
  if params.format then
    pic_url = pic_url .. "/format/" .. params.format
  end
  return pic_url
end
def.method("string", "string", "number", "number", "=>", "boolean", "string").CutImage = function(self, localPath, outputPath, quality, limit)
  if _G.CUR_CODE_VERSION < _G.COS_EX_CODE_VERSION then
    return false, localPath
  end
  if not _G.FileExists(outputPath) then
    GameUtil.CreateDirectoryForFile(outputPath)
  end
  GameUtil.LuaCutImage(0, 0, limit, localPath, outputPath, quality)
  return true, outputPath
end
def.method("number", "function", "table").DoGetImagePath = function(self, fromType, callback, exParams)
  local function onGetImagePath(photoPath, cropResult)
    if photoPath == "" or photoPath == nil then
      Toast(textRes.SocialSpace[82])
    end
    if callback then
      callback(photoPath, cropResult)
    end
  end
  if platform == Platform.win then
    local localPath = cos_cfg.test_image and GameUtil.GetAssetsPath() .. "/" .. cos_cfg.test_image or ""
    onGetImagePath(localPath, DeviceUtility.Constants.CROP_FAILED)
  else
    if not ECSocialSpaceMan.Instance():CheckIsUploadPictureSupported() then
      return
    end
    if fromType == ECSocialSpaceCosMan.FROM_CAMERA then
      DeviceUtility.TakePhoto(onGetImagePath, exParams)
    elseif fromType == ECSocialSpaceCosMan.FROM_ALBUM then
      DeviceUtility.PickPhoto(onGetImagePath, exParams)
    else
      error(string.format("Not supported fromType(%d)!", fromType), 2)
    end
  end
end
def.method("number", "function").DoGetVideoPath = function(self, fromType, callback)
  if platform == Platform.win then
    local videoPath = cos_cfg.test_video and GameUtil.GetAssetsPath() .. "/" .. cos_cfg.test_video or ""
    local coverPath = cos_cfg.test_video_cover and GameUtil.GetAssetsPath() .. "/" .. cos_cfg.test_video_cover or ""
    if callback then
      callback(videoPath, coverPath)
    end
  else
    TODO("DoGetVideoPath")
  end
end
def.method("string", "boolean").AddCosCache = function(self, filename, b)
  local _, delFilename = self.mCosCache:Set(filename, b)
  if delFilename then
    self:DeleteFile(delFilename)
  end
end
def.method().InitCache = function(self)
  local cacheFolderPath = GameUtil.GetAssetsPath() .. "/" .. cache_folder
  if _G.CUR_CODE_VERSION >= _G.COS_EX_CODE_VERSION then
    if not Directory.Exists(cacheFolderPath) then
      return
    end
    local fileNames = Directory.GetFiles(cacheFolderPath, "", 1)
    local files = {}
    for i, fileName in ipairs(fileNames) do
      files[i] = {
        name = fileName,
        lastAccessTime = GameUtil.GetFileLastAccessTime(fileName)
      }
    end
    local sortFile = function(left, right)
      return left.lastAccessTime < right.lastAccessTime
    end
    table.sort(files, sortFile)
    for i, file in ipairs(files) do
      self:AddCosCache(file.name, true)
    end
  else
    local curTimestamp = os.time()
    if LuaPlayerPrefs.HasGlobalKey("CosCacheClearTime") then
      local lastTimestamp = LuaPlayerPrefs.GetGlobalNumber("CosCacheClearTime")
      if math.abs(curTimestamp - lastTimestamp) > _G.ONE_DAY_SECONDS then
        GameUtil.RemoveDirectory(cacheFolderPath, true)
        LuaPlayerPrefs.SetGlobalNumber("CosCacheClearTime", curTimestamp)
      end
    else
      LuaPlayerPrefs.SetGlobalNumber("CosCacheClearTime", curTimestamp)
    end
    LuaPlayerPrefs.Save()
  end
end
def.method("string", "=>", "dynamic").TryJsonDecode = function(self, str)
  local isSuccess, jsonData = pcall(json.decode, str)
  if isSuccess then
    return jsonData
  else
    return str
  end
end
def.method("=>", "table").GetCosCfg = function(self)
  return cos_cfg
end
def.method("=>", "string").GetPortraitPictureTempPath = function(self)
  return GameUtil.GetAssetsPath() .. "/" .. cos_cfg.tmp_folder .. "/portrait.png"
end
def.method("=>", "string").GetCutPortraitOutputTempPath = function(self)
  return GameUtil.GetAssetsPath() .. "/" .. cos_cfg.tmp_folder .. "/cutted_portrait.png"
end
def.method("number", "=>", "string").GetMsgPictureTempPath = function(self, index)
  return GameUtil.GetAssetsPath() .. "/" .. cos_cfg.tmp_folder .. "/pic_" .. index .. ".png"
end
def.method("=>", "string").GetPictureTempPath = function(self, index)
  local path = string.format("%s/%s/pic_clock_%s.png", GameUtil.GetAssetsPath(), cos_cfg.tmp_folder, os.clock())
  return path
end
def.method("=>", "table").GetCreatePortraitExtraParams = function(self)
  local extras = {
    isCrop = true,
    cropWidth = cos_cfg.upload_portrait_size_limit,
    cropHeight = cos_cfg.upload_portrait_size_limit
  }
  return extras
end
def.method("=>", "table").GetCreateMsgPictureExtraParams = function(self)
  local extras = {
    maxWidth = cos_cfg.upload_image_size_limit,
    maxHeight = cos_cfg.upload_image_size_limit
  }
  return extras
end
def.method("string").DeleteFile = function(self, filePath)
  if filePath == nil or filePath == "" then
    return
  end
  if _G.FileExists(filePath) then
    os.remove(filePath)
  end
end
def.method().DeleteTmpDir = function(self)
  local dirPath = GameUtil.GetAssetsPath() .. "/" .. cos_cfg.tmp_folder
  GameUtil.RemoveDirectory(dirPath, true)
end
ECSocialSpaceCosMan.Commit()
return ECSocialSpaceCosMan
