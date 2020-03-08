local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SpacePanelNodeBase = import(".SpacePanelNodeBase")
local SpaceInfoNode = Lplus.Extend(SpacePanelNodeBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local def = SpaceInfoNode.define
local SocialSpaceUtils = import("..SocialSpaceUtils")
local HeroInterface = require("Main.Hero.Interface")
local ECUIModel = require("Model.ECUIModel")
local ECSpaceMsgs = require("Main.SocialSpace.ECSpaceMsgs")
local ECSocialSpaceMan = require("Main.SocialSpace.ECSocialSpaceMan")
local ECSocialSpaceCosMan = require("Main.SocialSpace.ECSocialSpaceCosMan")
local ECSocialSpaceConfig = require("Main.SocialSpace.ECSocialSpaceConfig")
local DecorationNotificationMan = require("Main.SocialSpace.DecorationNotificationMan")
local SocialSpaceFocusMan = require("Main.SocialSpace.SocialSpaceFocusMan")
local SocialSpaceModule = require("Main.SocialSpace.SocialSpaceModule")
local PersonalInfoInterface = require("Main.PersonalInfo.PersonalInfoInterface")
local FriendModule = Lplus.ForwardDeclare("FriendModule")
local cos_cfg = ECSocialSpaceCosMan.Instance():GetCosCfg()
def.field(ECSocialSpaceMan).m_spaceMan = nil
def.field(ECSpaceMsgs.ECSpaceBaseInfo).m_spaceBase = nil
def.field("table").m_UIGOs = nil
def.field("boolean").m_showModel = true
def.field(ECUIModel).model = nil
def.field("string").m_tmpPhotoPath = ""
def.override().OnCreate = function(self)
  self.m_spaceMan = ECSocialSpaceMan.Instance()
  self.m_spaceBase = self.m_base.m_baseInfo
  self.m_showModel = not self:HasPhoto() and self:CanShowModel()
end
def.override().OnDestroy = function(self)
  self:DeleteTmpPhoto()
end
def.override().OnShow = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEventWithContext(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.EDIT_SUCCESS, SpaceInfoNode.OnPersonalInfoEditSuccess, self)
  Event.RegisterEventWithContext(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.NewDecoNotificationChanged, SpaceInfoNode.OnNewDecoNotificationChanged, self)
  Event.RegisterEventWithContext(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.FocusListInited, self.OnFocusBtnChanged, self)
  Event.RegisterEventWithContext(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.FocusListChanged, self.OnFocusBtnChanged, self)
  Event.RegisterEventWithContext(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.FocusFeatureChanged, self.OnFocusBtnChanged, self)
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendChanged, self.OnFriendChanged, self)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendChanged, self.OnFriendChanged)
  Event.UnregisterEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.FocusListInited, self.OnFocusBtnChanged)
  Event.UnregisterEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.FocusListChanged, self.OnFocusBtnChanged)
  Event.UnregisterEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.FocusFeatureChanged, self.OnFocusBtnChanged)
  Event.UnregisterEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.NewDecoNotificationChanged, SpaceInfoNode.OnNewDecoNotificationChanged)
  Event.UnregisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.EDIT_SUCCESS, SpaceInfoNode.OnPersonalInfoEditSuccess)
  self:DestroyModel()
  self.m_UIGOs = nil
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Group_Left = self.m_node:FindDirect("Group_Left")
  self.m_UIGOs.Grid_Btn = self.m_UIGOs.Group_Left:FindDirect("Grid_Btn")
  self.m_UIGOs.Btn_FollowSpace = self.m_UIGOs.Grid_Btn:FindDirect("Btn_FollowSpace")
  local Btn_ChangeModel = self.m_UIGOs.Group_Left:FindDirect("Btn_ChangeModel")
  local canShowModel = self:CanShowModel()
  GUIUtils.SetActive(Btn_ChangeModel, canShowModel)
end
def.method().UpdateUI = function(self)
  local baseInfo = self.m_spaceBase
  local Img_Head = self.m_UIGOs.Group_Left:FindDirect("Img_Head")
  local Label_Lv = Img_Head:FindDirect("Label_Lv")
  _G.SetAvatarIcon(Img_Head, baseInfo.idphoto)
  GUIUtils.SetText(Label_Lv, baseInfo.level)
  local Group_Name = self.m_UIGOs.Group_Left:FindDirect("Group_Name")
  local Img_School = Group_Name:FindDirect("Img_School")
  local Img_Sex = Group_Name:FindDirect("Img_Sex")
  local Label_Name = Group_Name:FindDirect("Label_Name")
  GUIUtils.SetText(Label_Name, baseInfo.playerName)
  GUIUtils.SetSprite(Img_School, GUIUtils.GetOccupationSmallIcon(baseInfo.prof))
  GUIUtils.SetSprite(Img_Sex, GUIUtils.GetGenderSprite(baseInfo.gender))
  local Group_ID = self.m_UIGOs.Group_Left:FindDirect("Group_ID")
  local Label_ID_Name = Group_ID:FindDirect("Label_Name")
  local Label_ID_Info = Group_ID:FindDirect("Label_Info")
  local displayRoleId = HeroInterface.RoleIDToDisplayID(baseInfo.roleId)
  GUIUtils.SetText(Label_ID_Info, tostring(displayRoleId))
  self:UpdatePortrait()
  self:UpdateLocation()
  self:UpdateSignature()
  self:UpdateGridBtn()
  self:UpdateThemeBtn()
end
def.method().UpdateThemeBtn = function(self)
  local Btn_Theme = self.m_UIGOs.Group_Left:FindDirect("Btn_Theme")
  local isMySpace = self.m_base:IsMySpace()
  Btn_Theme:SetActive(isMySpace)
  if isMySpace then
    local Img_RedNew = Btn_Theme:FindDirect("Img_RedNew")
    local hasNotification = DecorationNotificationMan.Instance():HasNewDecoNotification()
    GUIUtils.SetActive(Img_RedNew, hasNotification)
  end
end
def.method().UpdateGridBtn = function(self)
  local Grid_Btn = self.m_UIGOs.Grid_Btn
  local isMySpace = self.m_base:IsMySpace()
  Grid_Btn:SetActive(not isMySpace)
  if isMySpace then
    return
  end
  self:UpdateFocusBtn()
  local uiGrid = Grid_Btn:GetComponent("UIGrid")
  uiGrid:Reposition()
end
def.method().UpdateFocusBtn = function(self)
  local canShow = self:CanShowFocusBtn()
  GUIUtils.SetActive(self.m_UIGOs.Btn_FollowSpace, canShow)
  if not canShow then
    return
  end
  local Label_Name = self.m_UIGOs.Btn_FollowSpace:FindDirect("Label_Name")
  local text
  if SocialSpaceFocusMan.Instance():HasFocusOnRole(self.m_ownerId) then
    text = textRes.SocialSpace[119]
  else
    text = textRes.SocialSpace[113]
  end
  GUIUtils.SetText(Label_Name, text)
end
def.method("=>", "boolean").CanShowFocusBtn = function(self)
  local isMyFriend = FriendModule.Instance():GetFriendInfo(self.m_ownerId)
  if not isMyFriend and SocialSpaceModule.Instance():IsFocusAvailable() then
    return true
  end
  return false
end
def.method().UpdateSignature = function(self)
  local Group_Sign = self.m_UIGOs.Group_Left:FindDirect("Group_Sign")
  local Label_Info = Group_Sign:FindDirect("Label_Info")
  local signature = self.m_spaceMan:FilterSensitiveWords(self.m_spaceBase.signature)
  GUIUtils.SetText(Label_Info, signature)
end
def.method().UpdateLocation = function(self)
  local Group_Local = self.m_UIGOs.Group_Left:FindDirect("Group_Local")
  local Label_Info = Group_Local:FindDirect("Label_Info")
  local location
  if self.m_base:IsMySpace() then
    local personalInfo = PersonalInfoInterface.Instance():getPersonalInfo(_G.GetMyRoleID())
    if personalInfo and personalInfo.info then
      location = personalInfo.info.location
    end
  end
  if location == nil then
    location = self.m_spaceBase.location
  end
  local locationText = PersonalInfoInterface.Instance():getLocaltionText(location)
  GUIUtils.SetText(Label_Info, locationText)
  local Btn_Friends = self.m_UIGOs.Group_Left:FindDirect("Btn_Friends")
  local isTheSameServer = self.m_spaceMan:IsTheSameServerWithHost(self.m_ownerServerId)
  GUIUtils.SetActive(Btn_Friends, isTheSameServer)
end
def.method().UpdatePortrait = function(self)
  if self.m_showModel then
    self:UpdateModelPortrait()
  else
    self:UpdatePhotoPortrait(nil)
  end
end
def.method("function").UpdatePhotoPortrait = function(self, onReady)
  if self.m_showModel then
    return
  end
  local Model = self.m_UIGOs.Group_Left:FindDirect("Model")
  local Texture = self.m_UIGOs.Group_Left:FindDirect("Texture")
  Model:SetActive(false)
  Texture:SetActive(true)
  self:DestroyModel()
  local Label_Upon = Texture:FindDirect("Label_Upon")
  local hasPhoto = self:HasPhoto()
  GUIUtils.SetActive(Label_Upon, not hasPhoto)
  if hasPhoto then
    do
      local function onTextureFilled()
        if onReady then
          onReady(Texture)
        end
      end
      if self.m_tmpPhotoPath ~= "" then
        self:FillTextureFromLocalPath(Texture, self.m_tmpPhotoPath, onTextureFilled)
      else
        local photoUrl = self.m_spaceBase.urlphoto
        photoUrl = ECSocialSpaceCosMan.PicProcessing(photoUrl, cos_cfg.portrait_processing_params)
        ECSocialSpaceCosMan.Instance():LoadFile(photoUrl, function(filePath)
          if _G.IsNil(Texture) then
            return
          end
          self:FillTextureFromLocalPath(Texture, filePath, onTextureFilled)
        end)
      end
    end
  else
    self:FillTextureFromLocalPath(Texture, "", onReady)
  end
end
def.method().UpdateModelPortrait = function(self)
  local Model = self.m_UIGOs.Group_Left:FindDirect("Model")
  local Texture = self.m_UIGOs.Group_Left:FindDirect("Texture")
  Model:SetActive(true)
  Texture:SetActive(false)
  local uiModel = Model:GetComponent("UIModel")
  local roleId = self.m_spaceBase.roleId
  gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetServerRoleModelInfo(roleId, function(modelInfo)
    if self:IsNodeReady() == false then
      return
    end
    if modelInfo == nil then
      return
    end
    if self.model ~= nil then
      self.model:Destroy()
    end
    local modelId = modelInfo.modelid
    self.model = ECUIModel.new(modelId)
    _G.LoadModelWithCallBack(self.model, modelInfo, false, false, function()
      if self:IsNodeReady() == false then
        self:DestroyModel()
        return
      end
      if self.model == nil or _G.IsNil(self.model.m_model) or _G.IsNil(uiModel) then
        return
      end
      self.model:SetDir(180)
      self.model:Play(ActionName.Stand)
      uiModel.modelGameObject = self.model:GetMainModel()
      uiModel.mCanOverflow = true
      local camera = uiModel:get_modelCamera()
      if camera then
        camera:set_orthographic(true)
      end
    end)
  end)
end
def.method().DestroyModel = function(self)
  if self.model then
    self.model:Destroy()
    self.model = nil
  end
end
def.method("=>", "boolean").IsNodeReady = function(self)
  if self.m_base == nil or self.m_base:IsLoaded() == false then
    return false
  end
  if self.m_UIGOs == nil then
    return false
  end
  return true
end
def.override("string", "number", "number").onDrag = function(self, id, dx, dy)
  if id == "Model" and self.model and self.model:IsDestroyed() == false then
    self.model:SetDir(self.model.m_ang - dx / 2)
  end
end
def.override("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_ChangeModel" then
    self:SwitchPortrait()
  elseif id == "Img_Bg" and obj.parent.name == "Group_Sign" then
    self:OnClickSignBgImg()
  elseif id == "Btn_Interactive" then
    self:OnClickInteractiveBtn(obj)
  elseif id == "Btn_Theme" then
    self:OnClickThemeBtn()
  elseif id == "Btn_Friends" then
    self:OnClickFriendsBtn(obj)
  elseif id == "Texture" and obj.parent.name == "Group_Left" then
    self:OnClickPhoto(obj)
  elseif id == "Img_Head" and obj.parent.name == "Group_Left" then
    self:OnClickRoleHead(obj)
  elseif id == "Btn_FollowSpace" then
    self:OnClickFocusBtn()
  end
end
def.method().SwitchPortrait = function(self)
  if self.m_showModel then
    local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
    if not _G.IsFeatureOpen(Feature.TYPE_UPLOAD_PICTURE) then
      SocialSpaceUtils.ShowFeatureNotOpenPrompt()
      return
    end
  end
  self.m_showModel = not self.m_showModel
  self:UpdatePortrait()
end
def.method().OnClickSignBgImg = function(self)
  if not self.m_base:IsMySpace() then
    return
  end
  self:ShowModifySignPanel()
end
def.method("userdata").OnClickInteractiveBtn = function(self, sender)
  self:ShowPlayerMenu(sender)
end
def.method("userdata").ShowPlayerMenu = function(self, obj)
  local roleId = self.m_ownerId
  local roleName = self.m_ownerName
  local serverId = self.m_ownerServerId
  local idPhoto = self.m_spaceBase.idphoto
  self.m_spaceMan:ShowPlayerMenu(obj, roleId, roleName, idPhoto, serverId)
end
def.method("userdata").OnClickFriendsBtn = function(self, sender)
  local roleId = self.m_ownerId
  PersonalInfoInterface.Instance():CheckPersonalInfo(roleId, "")
end
def.method().ShowModifySignPanel = function(self)
  local charLimit = ECSocialSpaceConfig.getSignatureCharLimit()
  local desc = textRes.SocialSpace[58]:format(charLimit)
  local SpaceSignInputPanel = require("Main.SocialSpace.ui.SpaceSignInputPanel")
  SpaceSignInputPanel.Instance():ShowPanel(desc, charLimit, function(value)
    self.m_spaceMan:Req_UpdateSignature(value, function()
      if not self:IsNodeShow() then
        return
      end
      self:UpdateSignature()
      Toast(textRes.SocialSpace[34])
    end, true)
    return true
  end)
end
def.method("table").OnPersonalInfoEditSuccess = function(self)
  self:UpdateLocation()
end
def.method("table").OnNewDecoNotificationChanged = function(self)
  self:UpdateThemeBtn()
end
def.method().OnClickThemeBtn = function(self)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if not _G.IsFeatureOpen(Feature.TYPE_FRIENDS_CIRCLE_ORNAMENT) then
    Toast(textRes.SocialSpace[45])
    return
  end
  require("Main.SocialSpace.ui.SpaceDecorationPanel").Instance():ShowPanel(self.m_base, nil)
end
def.method("=>", "boolean").CanShowModel = function(self)
  if _G.IsCrossingServer() then
    return false
  end
  if not self.m_spaceMan:IsTheSameServerWithHost(self.m_ownerServerId) then
    return false
  end
  return true
end
def.method("=>", "boolean").HasPhoto = function(self)
  if self.m_tmpPhotoPath ~= "" then
    return true
  end
  if self.m_spaceBase.urlphoto ~= "" then
    return true
  end
  return false
end
def.method("userdata").OnClickPhoto = function(self, obj)
  if not self.m_base:IsMySpace() then
    return
  end
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if not _G.IsFeatureOpen(Feature.TYPE_UPLOAD_PICTURE) then
    SocialSpaceUtils.ShowFeatureNotOpenPrompt()
    return
  end
  local pos = self:CalcBtnGroupPos(obj)
  if self.m_tmpPhotoPath == "" then
    self:ShowPhotoOptions(pos)
  else
    self:ShowTmpPhotoOptions(pos)
  end
end
def.method("userdata").OnClickRoleHead = function(self, obj)
  if self.m_base:IsMySpace() then
    return
  end
  self:ShowPlayerMenu(obj)
end
def.method().OnClickFocusBtn = function(self)
  SocialSpaceFocusMan.Instance():ReqChangeFocusOnRole(self.m_ownerId)
end
def.method("userdata", "=>", "table").CalcBtnGroupPos = function(self, obj)
  local position = obj.position
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = obj:GetComponent("UIWidget")
  local pos = {
    auto = true,
    prefer = 1,
    preferY = 1
  }
  pos.sourceX = screenPos.x
  pos.sourceY = screenPos.y - widget.height / 2
  pos.sourceW = widget.width
  pos.sourceH = widget.height
  return pos
end
def.method("table").ShowPhotoOptions = function(self, pos)
-- fail 19
null
6
  local needDeleteOption = self.m_spaceBase.urlphoto ~= ""
  local extras = ECSocialSpaceCosMan.Instance():GetCreatePortraitExtraParams()
  SocialSpaceUtils.ShowPhotoOptions({
    pos = pos,
    onDelete = function()
      self:DeletePhoto()
    end,
    onGetImagePath = function(localPath, fromType, cropResult)
      self:OnGetImagePath(localPath, fromType, cropResult)
    end,
    extras = extras
  })
end
def.method("string", "number", "dynamic").OnGetImagePath = function(self, localPath, fromType, cropResult)
  if not self:IsNodeShow() then
    return
  end
  if localPath == "" then
    return
  end
  local DeviceUtility = require("Utility.DeviceUtility")
  if cropResult == DeviceUtility.Constants.CROP_FAILED and _G.CUR_CODE_VERSION >= _G.COS_EX_CODE_VERSION then
    do
      local CommonCutPhotoPanel = require("GUI.CommonCutPhotoPanel")
      local displayType
      if fromType == ECSocialSpaceCosMan.FROM_CAMERA then
        displayType = CommonCutPhotoPanel.DisplayType.TakePhoto
      else
        displayType = CommonCutPhotoPanel.DisplayType.PickPhoto
      end
      local curLocalPath = localPath
      local function onRePick(panel)
        ECSocialSpaceCosMan.Instance():DoGetImagePath(fromType, function(newLocalPath)
          if newLocalPath ~= "" then
            panel:ResetWithPhoto(newLocalPath)
            if curLocalPath ~= newLocalPath then
              self:DeleteFile(curLocalPath)
            end
            curLocalPath = newLocalPath
          end
        end, nil)
      end
      local function onFinish(status, outputPath)
        self:DeleteFile(curLocalPath)
        if not self:IsNodeShow() then
          return
        end
        if status == 1 then
          self:ShowTmpPortrait(outputPath)
        end
      end
      local outputPath = ECSocialSpaceCosMan.Instance():GetCutPortraitOutputTempPath()
      CommonCutPhotoPanel.Instance():ShowPanel(displayType, localPath, outputPath, onRePick, onFinish, {
        cutLimit = cos_cfg.upload_quality
      })
    end
  elseif cropResult == DeviceUtility.Constants.CROP_DONE then
    self:ShowTmpPortrait(localPath)
  end
end
def.method("string").ShowTmpPortrait = function(self, outputPath)
  if self.m_tmpPhotoPath ~= outputPath then
    self:DeleteFile(self.m_tmpPhotoPath)
  end
  self.m_tmpPhotoPath = outputPath
  self:UpdatePhotoPortrait(function(Texture)
    if _G.IsNil(Texture) then
      return
    end
    local pos = self:CalcBtnGroupPos(Texture)
    self:ShowTmpPhotoOptions(pos)
  end)
end
def.method("table").ShowTmpPhotoOptions = function(self, pos)
  local btns = {}
  local btn = {
    name = textRes.SocialSpace[77]
  }
  table.insert(btns, btn)
  local btn = {
    name = textRes.SocialSpace[76]
  }
  table.insert(btns, btn)
  require("GUI.ButtonGroupPanel").ShowPanel(btns, pos, function(index)
    if index == 1 then
      self:RemoveTmpAndRefreshPhoto()
    elseif index == 2 then
      if self.m_tmpPhotoPath == "" then
        return
      end
      do
        local function uploadPortratiPhotoHandler(data)
          self:RemoveTmpAndRefreshPhoto()
          if data.retcode == 0 then
            Toast(textRes.SocialSpace[81])
          end
        end
        local outputPath = self.m_tmpPhotoPath
        if platform == Platform.win and not cos_cfg.open_upload then
          local url = cos_cfg.test_url
          if url and #url > 1 then
            ECSocialSpaceMan.Instance():Req_UploadPortratiPhoto(url, uploadPortratiPhotoHandler, true)
          end
        else
          ECSocialSpaceCosMan.Instance():UploadPortrait(outputPath, function(ret)
            if ret.code and ret.code == 0 then
              if self:IsNodeShow() then
                url = ret.data.source_url
                if url and #url > 1 then
                  ECSocialSpaceMan.Instance():Req_UploadPortratiPhoto(url, uploadPortratiPhotoHandler, true)
                end
              end
            else
              local errorMsg
              if ret.code then
                errorMsg = string.format("[%s] %s", ret.code, ret.message)
              else
                errorMsg = ret.message
              end
              Toast(errorMsg)
              self:RemoveTmpAndRefreshPhoto()
            end
          end, nil)
        end
      end
    end
    return true
  end)
end
def.method().RemoveTmpAndRefreshPhoto = function(self)
  self:DeleteTmpPhoto()
  self:UpdatePhotoPortrait(nil)
end
def.method().DeletePhoto = function(self)
  ECSocialSpaceMan.Instance():Req_UploadPortratiPhoto("", function(ret)
    self:RemoveTmpAndRefreshPhoto()
    if ret == 0 then
      Toast(textRes.SocialSpace[80])
    end
  end, true)
end
def.method().DeleteTmpPhoto = function(self)
  self:DeleteFile(self.m_tmpPhotoPath)
  self.m_tmpPhotoPath = ""
end
def.method("string").DeleteFile = function(self, filePath)
  if _G.platform == Platform.win then
    return
  end
  ECSocialSpaceCosMan.Instance():DeleteFile(filePath)
end
def.method("table").OnFocusBtnChanged = function(self, params)
  self:UpdateGridBtn()
end
def.method("table").OnFriendChanged = function(self, params)
  self:UpdateGridBtn()
end
return SpaceInfoNode.Commit()
