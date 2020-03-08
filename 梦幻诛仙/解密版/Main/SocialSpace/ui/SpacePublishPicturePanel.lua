local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SpacePublishPicturePanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local def = SpacePublishPicturePanel.define
local SpaceInputCtrl = import(".SpaceInputCtrl")
local SocialSpaceUtils = import("..SocialSpaceUtils")
local ECSocialSpaceMan = require("Main.SocialSpace.ECSocialSpaceMan")
local ECDebugOption = require("Main.ECDebugOption")
local ECSpaceMsgs = require("Main.SocialSpace.ECSpaceMsgs")
local ECSocialSpaceConfig = require("Main.SocialSpace.ECSocialSpaceConfig")
local ECSocialSpaceCosMan = require("Main.SocialSpace.ECSocialSpaceCosMan")
local cos_cfg = ECSocialSpaceCosMan.Instance():GetCosCfg()
local PictureState = {
  NotUpload = 1,
  Uploading = 2,
  Uploaded = 3,
  UploadFailed = 4
}
def.field("table").m_UIGOs = nil
def.field(SpaceInputCtrl).m_msgInputCtrl = nil
def.field("table").m_picInfos = nil
def.field("function").m_onFinish = nil
def.field("number").m_charLimit = 0
def.field("number").m_lastCharNum = 0
def.field("boolean").m_uploading = false
def.field("boolean").m_publishing = false
def.field("table").m_picMapPath = nil
local instance
def.static("=>", SpacePublishPicturePanel).Instance = function()
  if instance == nil then
    instance = SpacePublishPicturePanel()
  end
  return instance
end
def.override("=>", "boolean").IsAliveInReconnect = function(self)
  if _G.IsCrossingServer() then
    return false
  end
  return true
end
def.method("table", "function").ShowPanel = function(self, picLocalPaths, onFinish)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self.m_picInfos = {}
  if picLocalPaths then
    for i, v in ipairs(picLocalPaths) do
      local picInfo = {
        localPath = v,
        state = PictureState.NotUpload
      }
      table.insert(self.m_picInfos, picInfo)
    end
  end
  self.m_onFinish = onFinish
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_SOCIAL_SPACE_PUB_PICTURE_PANEL, 0)
end
def.override().OnCreate = function(self)
  self:InitData()
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  if self.m_msgInputCtrl then
    self.m_msgInputCtrl:Destroy()
    self.m_msgInputCtrl = nil
  end
  self.m_onFinish = nil
  self.m_charLimit = 0
  self.m_lastCharNum = 0
  self.m_uploading = false
  self.m_publishing = false
  self.m_picMapPath = nil
  if self.m_picInfos then
    for i, picInfo in ipairs(self.m_picInfos) do
      local localPath = picInfo.localPath
      if localPath then
        self:DeleteFile(localPath)
      end
    end
  end
  self.m_picInfos = nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Add" then
    self.m_msgInputCtrl:ShowInputDlg()
  elseif id == "Btn_Push" then
    self:OnClickSendBtn()
  elseif id:sub(1, #"Img_BgChild") == "Img_BgChild" then
    self:OnClickImgBgChild(obj)
  end
end
def.method().InitData = function(self)
  self.m_charLimit = ECSocialSpaceConfig.getMsgCharLimit()
  self.m_picMapPath = {}
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.m_UIGOs.Group_Child = self.m_UIGOs.Img_Bg0:FindDirect("Group_Child")
  self.m_UIGOs.Img_BgInput = self.m_UIGOs.Img_Bg0:FindDirect("Img_BgInput")
  local uiInput = self.m_UIGOs.Img_BgInput:GetComponent("UIInput")
  self.m_UIGOs.uiInput = uiInput
  self.m_msgInputCtrl = SpaceInputCtrl.New(self, uiInput)
  self.m_UIGOs.uiInput:set_characterLimit(self.m_charLimit)
end
def.method().UpdateUI = function(self)
  self:UpdatePictures()
end
def.method().OnClickSendBtn = function(self)
  local uiInput = self.m_UIGOs.uiInput
  local inputValue = uiInput:get_value()
  self:OnSendContent(inputValue)
end
def.method("string", "=>", "boolean").OnSendContent = function(self, inputValue)
  if self.m_publishing then
    Toast(textRes.SocialSpace[88])
    return false
  end
  if self.m_uploading then
    Toast(textRes.SocialSpace[87])
    return false
  end
  if #self.m_picInfos == 0 then
    Toast(textRes.SocialSpace[64])
    return false
  end
  local picList = {}
  local picRemotePaths = {}
  for i, v in ipairs(self.m_picInfos) do
    if v.remotePath == nil then
      table.insert(picList, v)
      v.state = PictureState.Uploading
    else
      picRemotePaths[i] = v.remotePath
    end
  end
  if #picList == 0 then
    self:SendContent(inputValue, picRemotePaths)
    return false
  end
  self:UploadPictures(picList, function(picRemotePaths)
    local sendPicPaths = {}
    for i, v in ipairs(self.m_picInfos) do
      if v.remotePath then
        table.insert(sendPicPaths, v.remotePath)
      end
    end
    self:SendContent(inputValue, sendPicPaths)
  end)
  return true
end
def.method("table", "function").UploadPictures = function(self, picList, onAllUploaded)
  self.m_uploading = true
  self:CutImages(picList, function(cuttedPathList)
    if platform == Platform.win and not cos_cfg.open_upload then
      self:FakeUpload(cuttedPathList, picList, onAllUploaded)
    else
      local timestamp = _G.GetServerTime()
      ECSocialSpaceCosMan.Instance():UploadPictureList(cuttedPathList, timestamp, function(resultList)
        self:ProcessUploadResult(picList, resultList, onAllUploaded)
      end, function(index, uploadProgress, progress)
        if self:IsLoaded() then
          self:SetPictureUploadProgress(index, uploadProgress)
        end
      end)
    end
  end)
end
def.method("table", "function").CutImages = function(self, picList, onFinished)
  if platform ~= Platform.win then
    local localPathList = {}
    for i, picInfo in ipairs(picList) do
      localPathList[i] = picInfo.localPath
    end
    if onFinished then
      onFinished(localPathList)
    end
    return
  end
  local localPathList = {}
  local co = coroutine.create(function()
    for i, picInfo in ipairs(picList) do
      local idx = self:FindPicIdx(picInfo)
      self:SetPictureUploadState(idx, textRes.SocialSpace[89])
      coroutine.yield(0.1)
      local localPath = picInfo.localPath
      local tempPath = ECSocialSpaceCosMan.Instance():GetMsgPictureTempPath(idx)
      local _, outputPath = ECSocialSpaceCosMan.Instance():CutImage(localPath, tempPath, cos_cfg.upload_quality, cos_cfg.upload_image_size_limit)
      localPathList[i] = outputPath
      self:SetPictureUploadState(idx, textRes.SocialSpace[90])
    end
  end)
  local function runCutImageCoroutine(delay)
    delay = delay or 0
    GameUtil.AddGlobalLateTimer(delay, true, function()
      if not self:IsLoaded() then
        return
      end
      if coroutine.status(co) ~= "dead" then
        local ret = {
          coroutine.resume(co)
        }
        if ret[1] then
          local delay = ret[2]
          runCutImageCoroutine(delay)
        else
          local traceback = debug.traceback(co)
          warn(string.format([[
[Error] %s
%s]], ret[2], traceback))
        end
      elseif onFinished then
        onFinished(localPathList)
      end
    end)
  end
  runCutImageCoroutine()
end
def.method("table", "table", "function").ProcessUploadResult = function(self, picList, resultList, onSuccessUploadAll)
  if not self:IsLoaded() then
    return
  end
  self.m_uploading = false
  local errorMsg
  local picRemotePaths = {}
  for i, result in ipairs(resultList) do
    local picInfo = picList[i]
    local idx = self:FindPicIdx(picInfo)
    if result and result.code == 0 then
      picRemotePaths[i] = result.data.source_url
      if picInfo then
        picInfo.remotePath = picRemotePaths[i]
        picInfo.state = PictureState.Uploaded
        self:SetPictureUploadProgress(idx, 1)
      end
    else
      if result.code then
        errorMsg = string.format("[%s] %s", result.code, result.message or "")
      else
        errorMsg = result.message
      end
      if picInfo then
        picInfo.remotePath = nil
        picInfo.state = PictureState.UploadFailed
        self:SetPictureUploadState(idx, textRes.SocialSpace[86])
      end
    end
  end
  if errorMsg then
    Toast(errorMsg)
    return
  end
  onSuccessUploadAll(picRemotePaths)
end
def.method("table", "table", "function").FakeUpload = function(self, localPathList, picList, onAllUploaded)
  local function onUploadingFinished()
    local testUrl = cos_cfg.test_url and #cos_cfg.test_url > 1 and cos_cfg.test_url or nil
    local resultList = {}
    for i, v in ipairs(self.m_picInfos) do
      local result
      if testUrl then
        result = {
          code = 0,
          data = {source_url = testUrl}
        }
      else
        result = {code = -1, message = "No testUrl"}
      end
      table.insert(resultList, result)
    end
    self:ProcessUploadResult(picList, resultList, onAllUploaded)
  end
  local function fakeUploading(uploadProgress, onUploadingFinished)
    GameUtil.AddGlobalTimer(0, true, function()
      if not self:IsLoaded() then
        return
      end
      for i, v in ipairs(self.m_picInfos) do
        v.state = PictureState.Uploading
        self:SetPictureUploadProgress(i, uploadProgress)
      end
      if uploadProgress < 1 then
        fakeUploading(uploadProgress + 0.1, onUploadingFinished)
      else
        onUploadingFinished()
      end
    end)
  end
  fakeUploading(0, onUploadingFinished)
end
def.method("string", "table").SendContent = function(self, inputValue, picRemotePaths)
  if not self:IsLoaded() then
    return
  end
  self.m_uploading = false
  local plainMsg = self.m_msgInputCtrl:GetContent(inputValue)
  local msg = ECSpaceMsgs.ECSpaceMsg()
  msg.strPlainMsg = plainMsg
  msg.pics = picRemotePaths
  self.m_publishing = true
  local WaitingTip = require("GUI.WaitingTip")
  WaitingTip.ShowTip(textRes.SocialSpace[108])
  ECSocialSpaceMan.Instance():Req_PublishNewStatus(msg, function(data)
    WaitingTip.HideTip()
    self.m_publishing = false
    if data.retcode == 0 then
      _G.SafeCallback(self.m_onFinish, 1)
      Toast(textRes.SocialSpace[83])
      self:DestroyPanel()
    end
  end, true)
end
def.method().UpdatePictures = function(self)
  local childCount = self.m_UIGOs.Group_Child:get_childCount()
  for i = 0, childCount - 1 do
    local groupGO = self.m_UIGOs.Group_Child:GetChild(i)
    local picInfo = self.m_picInfos[i + 1]
    self:SetPictureInfo(i, groupGO, picInfo)
  end
end
def.method("number", "userdata", "table").SetPictureInfo = function(self, idx, groupGO, picInfo)
  local Texture = groupGO:FindDirect("Texture")
  local Group_Prograss = groupGO:FindDirect("Group_Prograss")
  local Img_Verify = groupGO:FindDirect("Img_Verify")
  local Img_Add = groupGO:FindDirect("Img_Add")
  local textureInstanceId = Texture:GetInstanceID()
  GUIUtils.SetActive(Img_Add, picInfo == nil)
  if picInfo == nil then
    GUIUtils.SetTexture(Texture, 0)
    GUIUtils.SetActive(Group_Prograss, false)
    GUIUtils.SetActive(Img_Verify, false)
    self.m_picMapPath[textureInstanceId] = nil
    return
  end
  local Group_Prograss = groupGO:FindDirect("Group_Prograss")
  if picInfo.state == PictureState.NotUpload then
    Group_Prograss:SetActive(false)
  end
  if self.m_picMapPath[textureInstanceId] ~= picInfo.localPath then
    do
      local localPath = picInfo.localPath
      self.m_picMapPath[textureInstanceId] = localPath
      local groupWidget = groupGO:GetComponent("UIWidget")
      GUIUtils.FillTextureFromLocalPath(Texture, localPath, function()
        if _G.IsNil(groupWidget) then
          return
        end
        local uiTexture = Texture:GetComponent("UITexture")
        uiTexture.width = groupWidget.width - 2
        uiTexture.height = groupWidget.height - 2
      end)
    end
  end
end
def.method("number", "number").SetPictureUploadProgress = function(self, index, progress)
  local childCount = self.m_UIGOs.Group_Child:get_childCount()
  if index > childCount then
    return
  end
  local groupGO = self.m_UIGOs.Group_Child:GetChild(index - 1)
  local picInfo = self.m_picInfos[index]
  local Group_Prograss = groupGO:FindDirect("Group_Prograss")
  Group_Prograss:SetActive(true)
  local Slider_Prograss = Group_Prograss:FindDirect("Slider_Prograss")
  local uiSlider = Slider_Prograss:GetComponent("UISlider")
  uiSlider:set_value(progress)
  local Label_Slider = Group_Prograss:FindDirect("Label_Slider")
  if progress < 1 then
    GUIUtils.SetText(Label_Slider, textRes.SocialSpace[84])
  else
    GUIUtils.SetText(Label_Slider, textRes.SocialSpace[85])
  end
end
def.method("number", "string").SetPictureUploadState = function(self, index, stateText)
  local childCount = self.m_UIGOs.Group_Child:get_childCount()
  if index > childCount then
    return
  end
  local groupGO = self.m_UIGOs.Group_Child:GetChild(index - 1)
  local picInfo = self.m_picInfos[index]
  local Group_Prograss = groupGO:FindDirect("Group_Prograss")
  Group_Prograss:SetActive(true)
  local Label_Slider = Group_Prograss:FindDirect("Label_Slider")
  GUIUtils.SetText(Label_Slider, stateText)
end
def.method("userdata").OnClickImgBgChild = function(self, obj)
-- fail 41
null
8
  local index = tonumber(obj.name:sub(#"Img_BgChild" + 1, -1))
  if index == nil then
    return
  end
  if self.m_uploading then
    Toast(textRes.SocialSpace[87])
    return
  end
  local picInfo = self.m_picInfos[index]
  local needDeleteOption = picInfo ~= nil
  local extras = ECSocialSpaceCosMan.Instance():GetCreateMsgPictureExtraParams()
  SocialSpaceUtils.ShowPhotoOptions({
    sourceObj = obj,
    onDelete = function()
      self:DeletePhoto(index)
    end,
    onGetImagePath = function(localPath, fromType)
      self:OnGetImagePath(index, localPath)
    end,
    extras = extras
  })
end
def.method("number").DeletePhoto = function(self, index)
  local picInfo = self.m_picInfos[index]
  if picInfo == nil then
    return
  end
  table.remove(self.m_picInfos, index)
  self:DeletePhotoByPath(picInfo.localPath)
  self:UpdatePictures()
end
def.method("string").DeletePhotoByPath = function(self, localPath)
  local fileCanDelete = true
  for i, v in ipairs(self.m_picInfos) do
    if v.localPath == localPath then
      fileCanDelete = false
      break
    end
  end
  if fileCanDelete then
    self:DeleteFile(localPath)
  end
end
def.method("number", "string").OnGetImagePath = function(self, index, localPath)
  if localPath == "" then
    return
  end
  local picInfo = {
    localPath = localPath,
    state = PictureState.NotUpload
  }
  local curCount = #self.m_picInfos
  if index > curCount then
    table.insert(self.m_picInfos, picInfo)
  else
    local lastPicInfo = self.m_picInfos[index]
    self.m_picInfos[index] = picInfo
    if lastPicInfo then
      self:DeletePhotoByPath(lastPicInfo.localPath)
    end
  end
  self:UpdatePictures()
end
def.method("string", "string").onTextChange = function(self, id, text)
  if id == "Img_BgInput" then
    local charNum = _G.Strlen(text)
    if self.m_charLimit ~= 0 and charNum == self.m_charLimit and self.m_lastCharNum == self.m_charLimit then
      Toast(textRes.Common[82]:format(self.m_charLimit))
    end
    self.m_lastCharNum = charNum
  end
end
def.method("table", "=>", "number").FindPicIdx = function(self, picInfo)
  for i, v in ipairs(self.m_picInfos) do
    if v == picInfo then
      return i
    end
  end
  return 0
end
def.method("string").DeleteFile = function(self, filePath)
  if _G.platform == Platform.win then
    return
  end
  ECSocialSpaceCosMan.Instance():DeleteFile(filePath)
end
return SpacePublishPicturePanel.Commit()
