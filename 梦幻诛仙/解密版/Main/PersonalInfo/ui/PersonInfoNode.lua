local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local PersonInfoNode = Lplus.Extend(TabNode, "PersonInfoNode")
local GUIUtils = require("GUI.GUIUtils")
local FieldType = require("consts.mzm.gsp.personal.confbean.FieldType")
local PersonalInfoInterface = require("Main.PersonalInfo.PersonalInfoInterface")
local personalInfoInterface = PersonalInfoInterface.Instance()
local Vector = require("Types.Vector")
local Vector3 = require("Types.Vector3").Vector3
local ECLuaString = require("Utility.ECFilter")
local def = PersonInfoNode.define
def.field("table").uiTbl = nil
def.field("userdata").roleId = nil
def.field("table").editInfo = nil
def.field("table").curMenuList = nil
def.field("number").curFieldType = 0
local BtnType = {
  Btn_ChooseSex = FieldType.GENDER,
  Btn_ChooseMonth = FieldType.BORN_MONTH,
  Btn_ChooseDay = FieldType.BORN_DAY,
  Btn_ChooseZodiac = FieldType.CONSTELLATION,
  Btn_ChooseWork = FieldType.OCCUPATION,
  Btn_Symbolic = FieldType.ANIMAL_SIGN,
  Btn_BloodType = FieldType.BLOOD_TYPE,
  Btn_ChooseCountry = FieldType.COUNTRY,
  Btn_ChooseProvince = FieldType.PROVINCE,
  Btn_ChooseCity = FieldType.CITY,
  Btn_AddHobby = FieldType.HOBBY
}
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self.roleId = base.roleId
end
def.override().OnShow = function(self)
  self:InitUI()
  self:setPrizeInfo()
  self:setShowStatus(false)
end
def.override().OnHide = function(self)
end
def.method().InitUI = function(self)
  if not self.m_node or self.m_node.isnil then
    return
  end
  self.uiTbl = {}
  local qqInfo = personalInfoInterface:getQQOrWechatInfo(self.roleId)
  local Img_ZL = self.m_panel:FindDirect("Img _Bg0/Img_ZL")
  local Label_WechatName = Img_ZL:FindDirect("Label_WechatName")
  local Img_QQ = Img_ZL:FindDirect("Img_QQ")
  local Img_Wechat = Img_ZL:FindDirect("Img_Wechat")
  if qqInfo then
    local nickname = qqInfo.nickName
    if nickname then
      local strLen, aNum, hNum = ECLuaString.Len(nickname)
      if aNum + hNum * 2 > 12 then
        local len = aNum / 2 + hNum > 6 and 6 or aNum / 2 + hNum
        nickname = ECLuaString.SubStr(nickname, 1, len) .. "..."
      end
      Label_WechatName:GetComponent("UILabel"):set_text(nickname)
      if _G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
        Img_QQ:SetActive(false)
        Img_Wechat:SetActive(true)
      elseif _G.LoginPlatform == MSDK_LOGIN_PLATFORM.QQ then
        Img_QQ:SetActive(true)
        Img_Wechat:SetActive(false)
      end
    else
      Label_WechatName:GetComponent("UILabel"):set_text("")
    end
  else
    Label_WechatName:GetComponent("UILabel"):set_text("")
  end
  local Btn_Space = self.m_node:FindDirect("Btn_Space")
  GUIUtils.SetActive(Btn_Space, gmodule.moduleMgr:GetModule(ModuleId.SOCIAL_SPACE):IsOpen())
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  local Group_SmallSelected = self.m_node:FindDirect("Group_ValueChange/Group_SmallSelected")
  if Group_SmallSelected == nil then
    Group_SmallSelected = self.m_node:FindDirect("Group_ValueShow/Group_SmallSelected")
  end
  if self.curFieldType ~= FieldType.HOBBY or id ~= "Btn_Item2" then
    local Img_Bg2 = Group_SmallSelected:FindDirect("Img_Bg2")
    Group_SmallSelected:SetActive(false)
    local Group_HobbyList = self.m_panel:FindDirect("Img _Bg0/Group_HobbyList")
    Group_HobbyList:SetActive(false)
  end
  if id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Btn_Edit" then
    self:setShowStatus(true)
  elseif id == "Btn_Save" then
    self:SaveEditInfo()
  elseif id == "Btn_AddFriend" then
    require("Main.friend.FriendModule").Instance():RequestAddFriendToServer(self.roleId)
  elseif id == "Btn_ChooseSex" then
    self:setMenuPanel(clickObj)
  elseif id == "Btn_ChooseMonth" then
    self:setMenuPanel(clickObj)
  elseif id == "Btn_ChooseDay" then
    if self.editInfo.birthday.month == 0 then
      Toast(textRes.Personal[1])
    else
      self:setMenuPanel(clickObj)
    end
  elseif id == "Btn_ChooseZodiac" then
    self:setMenuPanel(clickObj)
  elseif id == "Btn_ChooseWork" then
    self:setMenuPanel(clickObj)
  elseif id == "Btn_Symbolic" then
    self:setMenuPanel(clickObj)
  elseif id == "Btn_BloodType" then
    self:setMenuPanel(clickObj)
  elseif id == "Btn_ChooseCountry" then
  elseif id == "Btn_ChooseProvince" then
    self:setMenuPanel(clickObj)
  elseif id == "Btn_ChooseCity" then
    if self.editInfo.location.province == 0 then
      Toast(textRes.Personal[2])
    else
      self:setMenuPanel(clickObj)
    end
  elseif id == "Btn_AddHobby" then
    self:setHobbyList()
  elseif id == "Btn_Like" then
    self:sendPrize()
  elseif id == "Btn_Share" then
    self:setMenuPanel(clickObj)
  elseif id == "Btn_Item2" then
    local parent = clickObj.parent
    local strs = string.split(parent.name, "_")
    self:selectedMenu(tonumber(strs[2]), clickObj)
  elseif id == "Btn_Exchange" then
    local function endCallback(imgId)
      if imgId ~= 0 then
        self.editInfo.headImage = imgId
        self:setHeadImg(true)
      end
    end
    require("Main.PersonalInfo.ui.PersonalSelectHeadImg").Instance():ShowPanel(self.roleId, endCallback)
  elseif id == "Btn_Cancel" then
    self.editInfo = {}
    self:setShowStatus(false)
  elseif id == "Btn_Space" then
    gmodule.moduleMgr:GetModule(ModuleId.SOCIAL_SPACE):EnterSpace(self.roleId)
  else
    if id == "Btn_Tips" then
      self:OnClickBtnSpaceTips()
    else
    end
  end
end
def.method().OnClickBtnSpaceTips = function(self)
  local tipContent = textRes.Personal[240]
  local CommonDescDlg = require("GUI.CommonUITipsDlg")
  CommonDescDlg.ShowCommonTip(tipContent, {x = 0, y = 0})
end
def.method("table", "table").OnEditSuccess = function(self, p1, p2)
  self:setShowStatus(false)
end
def.method("table", "table").OnPriaseSuccess = function(self, p1, p2)
  self:setPrizeInfo()
end
def.method().sendPrize = function(self)
  local myHero = require("Main.Hero.HeroModule").Instance()
  local heroProp = myHero:GetHeroProp()
  local myRoleId = heroProp.id
  if myRoleId == self.roleId then
    Toast(textRes.Personal[5])
    return
  end
  local personalInfo = personalInfoInterface:getPersonalInfo(self.roleId)
  local praiseNum = personalInfo:getDailyPraiseNum()
  if praiseNum >= constant.PersonalConsts.DAYLIY_PRAISE_ROLE_MAX then
    Toast(textRes.Personal[19])
    return
  end
  local req = require("netio.protocol.mzm.gsp.personal.CPraisePersonal").new(self.roleId)
  gmodule.network.sendProtocol(req)
end
def.method().SaveEditInfo = function(self)
  local Img_ZL = self.m_panel:FindDirect("Img _Bg0/Img_ZL")
  local Img_BgSign = Img_ZL:FindDirect("Group_ValueChange/Label_Sign/Img_BgSign")
  local sign_input = Img_BgSign:GetComponent("UIInput")
  local signStr = sign_input:get_value()
  local Img_AgeBg = Img_ZL:FindDirect("Group_ValueChange/Label_Age/Img_AgeBg")
  local age_input = Img_AgeBg:GetComponent("UIInput")
  local ageStr = age_input:get_value()
  local age = tonumber(ageStr)
  local Img_SchoolBg = Img_ZL:FindDirect("Group_ValueChange/Label_School/Img_SchoolBg")
  local school_input = Img_SchoolBg:GetComponent("UIInput")
  local schoolStr = school_input:get_value()
  local Octets = require("netio.Octets")
  if signStr ~= "" then
    local signOctet = Octets.rawFromString(signStr)
    self.editInfo.sign = signOctet
  end
  if schoolStr ~= "" then
    local schoolOctet = Octets.rawFromString(schoolStr)
    self.editInfo.school = schoolOctet
  end
  if ageStr ~= "" then
    if age then
      if age >= constant.PersonalConsts.MAX_AGE or age < 0 then
        Toast(textRes.Personal[6])
        return
      end
      self.editInfo.age = age
    else
      Toast(textRes.Personal[6])
      return
    end
  end
  local function confirmCallback(id)
    if id == 1 then
      local EditPersonalInfo = require("netio.protocol.mzm.gsp.personal.EditPersonalInfo")
      local info = EditPersonalInfo.new()
      for i, v in pairs(self.editInfo) do
        info[i] = v
      end
      local req = require("netio.protocol.mzm.gsp.personal.CEditPersonalInfo").new(info)
      gmodule.network.sendProtocol(req)
    else
      self:setShowStatus(false)
    end
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirmCoundDown("", textRes.Personal[12], textRes.Personal[13], textRes.Personal[14], 0, 0, confirmCallback, {})
end
def.method("boolean").setShowStatus = function(self, isEdit)
  local Img_ZL = self.m_panel:FindDirect("Img _Bg0/Img_ZL")
  local Group_ValueShow = Img_ZL:FindDirect("Group_ValueShow")
  local Group_ValueChange = Img_ZL:FindDirect("Group_ValueChange")
  local Btn_Cancel = Img_ZL:FindDirect("Btn_Cancel")
  local Btn_Share = Img_ZL:FindDirect("Btn_Share")
  local WZD = Img_ZL:FindDirect("WZD")
  if isEdit then
    Group_ValueChange:SetActive(true)
    Group_ValueShow:SetActive(false)
    Btn_Cancel:SetActive(true)
    Btn_Share:SetActive(false)
    WZD:SetActive(true)
    self:setEditInfo()
  else
    Group_ValueChange:SetActive(false)
    Group_ValueShow:SetActive(true)
    Btn_Cancel:SetActive(false)
    local myHero = require("Main.Hero.HeroModule").Instance()
    local heroProp = myHero:GetHeroProp()
    local myRoleId = heroProp.id
    if myRoleId == self.roleId then
      Btn_Share:SetActive(true)
    else
      Btn_Share:SetActive(false)
    end
    WZD:SetActive(false)
    self:setDisplayInfo()
  end
  local personalInfo = personalInfoInterface:getPersonalInfo(self.roleId)
  local percentNum = personalInfo:getInfoPercent() / 100
  local Label_WZDNumber = Img_ZL:FindDirect("WZD/Label_WZDNumber")
  Label_WZDNumber:GetComponent("UILabel"):set_text(percentNum .. "%")
end
def.method("number", "=>", "boolean").isOwnHobby = function(self, id)
  local list = self.editInfo.hobbies
  for i, v in pairs(list) do
    if v == id then
      return true
    end
  end
  return false
end
def.method().setHobbyList = function(self)
  local cfgList = PersonalInfoInterface.GetOperationList(FieldType.HOBBY)
  local Group_HobbyList = self.m_panel:FindDirect("Img _Bg0/Group_HobbyList")
  Group_HobbyList:SetActive(true)
  local List_Item = Group_HobbyList:FindDirect("Img_Bg2/Scroll View/List_Item2")
  local uilist = List_Item:GetComponent("UIList")
  uilist.itemCount = #cfgList
  uilist:Resize()
  uilist:Reposition()
  self.curFieldType = FieldType.HOBBY
  self.curMenuList = cfgList
  for i, v in ipairs(cfgList) do
    local item_bg = List_Item:FindDirect("item_" .. i)
    local Btn_Item = item_bg:FindDirect("Btn_Item2")
    local isOwnHobby = self:isOwnHobby(v.id)
    Btn_Item:GetComponent("UIToggle").value = isOwnHobby
    local Label_Name2 = item_bg:FindDirect("Btn_Item2/Label_Name2")
    Label_Name2:GetComponent("UILabel"):set_text(v.content)
  end
end
def.method("number", "userdata").selectedMenu = function(self, index, go)
  local Group_ValueChange = self.m_panel:FindDirect("Img _Bg0/Img_ZL/Group_ValueChange")
  local curType = self.curFieldType
  if curType == FieldType.GENDER then
    local cfg = self.curMenuList[index]
    self.editInfo.gender = cfg.id
    local Label_Sex = Group_ValueChange:FindDirect("Label_Sex")
    Label_Sex:GetComponent("UILabel"):set_text(cfg.content)
  elseif curType == FieldType.BORN_MONTH then
    local cfg = self.curMenuList[index]
    self.editInfo.birthday.month = cfg.id
    local Label_BirthdayMonth = Group_ValueChange:FindDirect("Label_BirthdayMonth")
    Label_BirthdayMonth:GetComponent("UILabel"):set_text(cfg.content)
    local birthdayCfgList = self:getBirthdayDayCfgList()
    cfg = birthdayCfgList[1]
    self.editInfo.birthday.day = cfg.id
    local Label_BirthdayDay = Group_ValueChange:FindDirect("Label_BirthdayDay")
    Label_BirthdayDay:GetComponent("UILabel"):set_text(cfg.content)
  elseif curType == FieldType.BORN_DAY then
    local cfg = self.curMenuList[index]
    self.editInfo.birthday.day = cfg.id
    local Label_BirthdayDay = Group_ValueChange:FindDirect("Label_BirthdayDay")
    Label_BirthdayDay:GetComponent("UILabel"):set_text(cfg.content)
  elseif curType == FieldType.CONSTELLATION then
    local cfg = self.curMenuList[index]
    self.editInfo.constellation = cfg.id
    local Label_zodiac = Group_ValueChange:FindDirect("Label_Zodiac")
    Label_zodiac:GetComponent("UILabel"):set_text(cfg.content)
  elseif curType == FieldType.OCCUPATION then
    local cfg = self.curMenuList[index]
    self.editInfo.occupation = cfg.id
    local Label_Work = Group_ValueChange:FindDirect("Label_Work")
    Label_Work:GetComponent("UILabel"):set_text(cfg.content)
  elseif curType == FieldType.ANIMAL_SIGN then
    local cfg = self.curMenuList[index]
    self.editInfo.animalSign = cfg.id
    local Label_Symbolic = Group_ValueChange:FindDirect("Label_Symbolic")
    Label_Symbolic:GetComponent("UILabel"):set_text(cfg.content)
  elseif curType == FieldType.BLOOD_TYPE then
    local cfg = self.curMenuList[index]
    self.editInfo.bloodType = cfg.id
    local Label_BloodType = Group_ValueChange:FindDirect("Label_BloodType")
    Label_BloodType:GetComponent("UILabel"):set_text(cfg.content)
  elseif curType == FieldType.PROVINCE then
    local cfg = self.curMenuList[index]
    self.editInfo.location.province = cfg.id
    local Label_Province = Group_ValueChange:FindDirect("Label_Province")
    Label_Province:GetComponent("UILabel"):set_text(cfg.content)
    local optionCfg = PersonalInfoInterface.GetPersonalOptionCfg(self.editInfo.location.province)
    local cfgList = PersonalInfoInterface.GetPersonalLocationList(optionCfg.linkOptionId)
    self.editInfo.location.city = cfgList[1].id
    local Label_City = Group_ValueChange:FindDirect("Label_City")
    Label_City:GetComponent("UILabel"):set_text(cfgList[1].content)
  elseif curType == FieldType.CITY then
    local cfg = self.curMenuList[index]
    self.editInfo.location.city = cfg.id
    local Label_City = Group_ValueChange:FindDirect("Label_City")
    Label_City:GetComponent("UILabel"):set_text(cfg.content)
  elseif curType == FieldType.HOBBY then
    local cfg = self.curMenuList[index]
    local list = self.editInfo.hobbies
    local idx
    for i, v in pairs(list) do
      if v == cfg.id then
        idx = i
        break
      end
    end
    if idx == nil then
      if #list >= constant.PersonalConsts.MAX_HOBBY then
        Toast(textRes.Personal[23])
        local btn_toggle = go:GetComponent("UIToggle")
        btn_toggle.value = false
        return
      end
      table.insert(list, cfg.id)
    else
      table.remove(list, idx)
    end
    local hobbyStr = ""
    for i, v in pairs(list) do
      local optionCfg = PersonalInfoInterface.GetPersonalOptionCfg(v)
      hobbyStr = hobbyStr .. " " .. optionCfg.content
    end
    local Label_Hobby = Group_ValueChange:FindDirect("Label_Hobby")
    Label_Hobby:GetComponent("UILabel"):set_text(hobbyStr)
  elseif curType == -1 then
    local cfg = self.curMenuList[index]
    local url = personalInfoInterface:getHeadImgUrl(self.roleId)
    require("Main.Chat.ChatModule").Instance():ShareMyPersonalInfoToChannel(cfg.id, url)
  end
end
def.method("=>", "table").getBirthdayDayCfgList = function(self)
  local list = {}
  local month = self.editInfo.birthday.month
  if month == 0 then
    return list
  end
  local curTime = GetServerTime()
  local cfgList = PersonalInfoInterface.GetOperationList(FieldType.BORN_DAY)
  local dayNum = os.date("%d", os.time({
    year = os.date("%Y", curTime),
    month = month + 1,
    day = 0
  }))
  for i = 1, dayNum do
    local cfg = cfgList[i]
    cfg.id = i
    table.insert(list, cfg)
  end
  return list
end
def.method("userdata").setMenuPanel = function(self, go)
  local pos = go.parent.transform.localPosition
  local Group_ValueChange = self.m_panel:FindDirect("Img _Bg0/Img_ZL/Group_ValueChange")
  local Group_ValueShow = self.m_panel:FindDirect("Img _Bg0/Img_ZL/Group_ValueShow")
  local Group_SmallSelected = Group_ValueChange:FindDirect("Group_SmallSelected")
  if Group_SmallSelected == nil then
    Group_SmallSelected = Group_ValueShow:FindDirect("Group_SmallSelected")
  end
  local Img_Bg2 = Group_SmallSelected:FindDirect("Img_Bg2")
  local widget = Img_Bg2:GetComponent("UIWidget")
  Group_SmallSelected:SetActive(true)
  local optionId = BtnType[go.name]
  if Group_ValueChange.activeSelf then
    Group_SmallSelected.parent = Group_ValueChange
    local parentWidget = go.parent:GetComponent("UIWidget")
    local posx = pos.x + parentWidget.width / 2 + 100
    if go.name ~= "Btn_ChooseMonth" and go.name ~= "Btn_ChooseProvince" and go.name ~= "Btn_ChooseCity" and go.name ~= "Btn_ChooseDay" then
      posx = posx + 30
    end
    Group_SmallSelected:set_localPosition(Vector3.new(posx, pos.y + 50, 0))
  else
    Group_SmallSelected.parent = Group_ValueShow
  end
  if go.name == "Btn_Share" then
    optionId = -1
    Group_SmallSelected:set_localPosition(Vector3.new(-77, -238, 0))
  end
  if optionId then
    local cfgList = PersonalInfoInterface.GetOperationList(optionId)
    if optionId == FieldType.BORN_MONTH then
      for i, v in ipairs(cfgList) do
        v.id = i
      end
    elseif optionId == FieldType.BORN_DAY then
      cfgList = self:getBirthdayDayCfgList()
    elseif optionId == FieldType.CITY then
      local optionCfg = PersonalInfoInterface.GetPersonalOptionCfg(self.editInfo.location.province)
      cfgList = PersonalInfoInterface.GetPersonalLocationList(optionCfg.linkOptionId)
    elseif optionId == -1 then
      cfgList = PersonalInfoInterface.GetShareCfgList()
    end
    self.curFieldType = optionId
    self.curMenuList = cfgList
    local List_Item2 = Img_Bg2:FindDirect("Scroll View/List_Item2")
    local uilist = List_Item2:GetComponent("UIList")
    uilist.itemCount = #cfgList
    uilist:Resize()
    uilist:Reposition()
    for i, v in ipairs(cfgList) do
      local item_bg = List_Item2:FindDirect("item_" .. i)
      local Label_Name = item_bg:FindDirect("Btn_Item2/Label_Name2")
      Label_Name:GetComponent("UILabel"):set_text(v.content)
    end
    GameUtil.AddGlobalTimer(0.1, true, function()
      Img_Bg2:FindDirect("Scroll View"):GetComponent("UIScrollView"):ResetPosition()
    end)
  end
end
def.method().setPrizeInfo = function(self)
  local personalInfo = personalInfoInterface:getPersonalInfo(self.roleId)
  local info = personalInfo.info
  local Label_LikeNumber = self.m_panel:FindDirect("Img _Bg0/Img_ZL/Img_InputBg/Label_LikeNumber")
  Label_LikeNumber:GetComponent("UILabel"):set_text(info.praiseNum)
end
def.method().setModifyEditInfo = function(self)
  local Birthday = require("netio.protocol.mzm.gsp.personal.Birthday")
  local Location = require("netio.protocol.mzm.gsp.personal.Location")
  local editInfo = {}
  local personalInfo = personalInfoInterface:getPersonalInfo(self.roleId)
  local info = personalInfo.info
  editInfo.sign = info.sign
  editInfo.gender = info.gender
  editInfo.age = info.age
  editInfo.birthday = Birthday.new()
  editInfo.birthday.month = info.birthday.month
  editInfo.birthday.day = info.birthday.day
  editInfo.animalSign = info.animalSign
  editInfo.constellation = info.constellation
  editInfo.bloodType = info.bloodType
  editInfo.occupation = info.occupation
  editInfo.school = info.school
  editInfo.location = Location.new()
  editInfo.location.province = info.location.province
  editInfo.location.city = info.location.city
  local hobbies = {}
  for i, v in ipairs(info.hobbies) do
    hobbies[i] = v
  end
  editInfo.hobbies = hobbies
  editInfo.headImage = info.headImage
  editInfo.photos = info.photos
  self.editInfo = editInfo
end
def.method("boolean").setHeadImg = function(self, isEdit)
  local personalInfo = personalInfoInterface:getPersonalInfo(self.roleId)
  local imgId = 0
  local icon_texture, icon_frame
  if isEdit then
    imgId = self.editInfo.headImage
    local imgCfg = PersonalInfoInterface.GetPersonalHeadImageCfg(self.editInfo.headImage)
    if imgCfg then
      imgId = imgCfg.imageId
    end
    local Group_ValueChange = self.m_panel:FindDirect("Img _Bg0/Img_ZL/Group_ValueChange")
    local Img_TouxiangIcon = Group_ValueChange:FindDirect("Img_TouXiang/Img_TouxiangIcon")
    icon_texture = Img_TouxiangIcon:GetComponent("UITexture")
    icon_frame = Group_ValueChange:FindDirect("Img_TouXiang")
  else
    imgId = personalInfo:getHeadImgId()
    local Group_ValueShow = self.m_panel:FindDirect("Img _Bg0/Img_ZL/Group_ValueShow")
    local Img_CurrentPlayerIcon = Group_ValueShow:FindDirect("Img_CurrentIcon/Img_CurrentPlayerIcon")
    icon_texture = Img_CurrentPlayerIcon:GetComponent("UITexture")
    icon_frame = Group_ValueShow:FindDirect("Img_CurrentIcon")
  end
  _G.SetAvatarFrameIcon(icon_frame, personalInfo:getAvatarFrameId())
  local url = personalInfoInterface:getHeadImgUrl(self.roleId)
  warn("----------personalInfo node:", url)
  if url and url ~= "" and url ~= "local" then
    GUIUtils.FillTextureFromURL(icon_texture, url, function(tex2d)
    end)
  else
    imgId = personalInfo:getHeadImgId()
    GUIUtils.FillIcon(icon_texture, imgId)
  end
end
def.method().setEditInfo = function(self)
  self:setModifyEditInfo()
  local personalInfo = personalInfoInterface:getPersonalInfo(self.roleId)
  local info = personalInfo.info
  local myHero = require("Main.Hero.HeroModule").Instance()
  local heroProp = myHero:GetHeroProp()
  local myRoleId = heroProp.id
  local Img_ZL = self.m_panel:FindDirect("Img _Bg0/Img_ZL")
  local Btn_AddFriend = Img_ZL:FindDirect("Btn_AddFriend")
  local Btn_Edit = Img_ZL:FindDirect("Btn_Edit")
  local Btn_Save = Img_ZL:FindDirect("Btn_Save")
  if myRoleId == self.roleId then
    Btn_Edit:SetActive(false)
    Btn_Save:SetActive(true)
    Btn_AddFriend:SetActive(false)
  else
    Btn_Edit:SetActive(false)
    Btn_Save:SetActive(false)
    Btn_AddFriend:SetActive(true)
  end
  local Group_ValueChange = self.m_panel:FindDirect("Img _Bg0/Img_ZL/Group_ValueChange")
  local Img_TouxiangIcon = Group_ValueChange:FindDirect("Img_TouXiang/Img_TouxiangIcon")
  self:setHeadImg(true)
  local Label_Sign = Group_ValueChange:FindDirect("Label_Sign")
  local Label_ID = Group_ValueChange:FindDirect("Label_ID")
  local Label_Sex = Group_ValueChange:FindDirect("Label_Sex")
  local Label_BirthdayMonth = Group_ValueChange:FindDirect("Label_BirthdayMonth")
  local Label_BirthdayDay = Group_ValueChange:FindDirect("Label_BirthdayDay")
  local Label_zodiac = Group_ValueChange:FindDirect("Label_Zodiac")
  local Label_Work = Group_ValueChange:FindDirect("Label_Work")
  local Label_Age = Group_ValueChange:FindDirect("Label_Age")
  local Label_Symbolic = Group_ValueChange:FindDirect("Label_Symbolic")
  local Label_BloodType = Group_ValueChange:FindDirect("Label_BloodType")
  local Label_School = Group_ValueChange:FindDirect("Label_School")
  local Label_Country = Group_ValueChange:FindDirect("Label_Country")
  local Label_Province = Group_ValueChange:FindDirect("Label_Province")
  local Label_City = Group_ValueChange:FindDirect("Label_City")
  local Label_Hobby = Group_ValueChange:FindDirect("Label_Hobby")
  local Label_TotalGameTime = Group_ValueChange:FindDirect("Label_TotalGameTime")
  Label_Sign:GetComponent("UILabel"):set_text(personalInfo:getSign())
  Label_ID:GetComponent("UILabel"):set_text(personalInfo:getDisplayId())
  Label_Sex:GetComponent("UILabel"):set_text(personalInfo:getSex())
  Label_BirthdayMonth:GetComponent("UILabel"):set_text(personalInfo:getBirthdayMonth())
  Label_BirthdayDay:GetComponent("UILabel"):set_text(personalInfo:getBirthdayDay())
  Label_zodiac:GetComponent("UILabel"):set_text(personalInfo:getConstellation())
  Label_Work:GetComponent("UILabel"):set_text(personalInfo:getWork())
  Label_Age:GetComponent("UILabel"):set_text(info.age)
  Label_Symbolic:GetComponent("UILabel"):set_text(personalInfo:getShengxiao())
  Label_BloodType:GetComponent("UILabel"):set_text(personalInfo:getBloodType())
  Label_School:GetComponent("UILabel"):set_text(personalInfo:getSchool())
  Label_Hobby:GetComponent("UILabel"):set_text(personalInfo:getHobby())
  local hour = math.floor(info.onlineSeconds:ToNumber() / 3600)
  Label_TotalGameTime:GetComponent("UILabel"):set_text(string.format(textRes.Personal[7], hour))
  Label_Province:GetComponent("UILabel"):set_text(personalInfo:getProvince())
  Label_City:GetComponent("UILabel"):set_text(personalInfo:getCity())
end
def.method().setDisplayInfo = function(self)
  local personalInfo = personalInfoInterface:getPersonalInfo(self.roleId)
  local info = personalInfo.info
  local Group_ValueShow = self.m_panel:FindDirect("Img _Bg0/Img_ZL/Group_ValueShow")
  local myHero = require("Main.Hero.HeroModule").Instance()
  local heroProp = myHero:GetHeroProp()
  local myRoleId = heroProp.id
  local Img_ZL = self.m_panel:FindDirect("Img _Bg0/Img_ZL")
  local Btn_AddFriend = Img_ZL:FindDirect("Btn_AddFriend")
  local Btn_Edit = Img_ZL:FindDirect("Btn_Edit")
  local Btn_Save = Img_ZL:FindDirect("Btn_Save")
  if myRoleId == self.roleId then
    Btn_Edit:SetActive(true)
    Btn_Save:SetActive(false)
    Btn_AddFriend:SetActive(false)
  else
    Btn_Edit:SetActive(false)
    Btn_Save:SetActive(false)
    Btn_AddFriend:SetActive(true)
  end
  local Img_CurrentPlayerIcon = Group_ValueShow:FindDirect("Img_CurrentIcon/Img_CurrentPlayerIcon")
  local Label_PlayerName = self.m_panel:FindDirect("Img _Bg0/Img_ZL/Label_PlayerName")
  local Label_Sign = Group_ValueShow:FindDirect("Label_Sign")
  local Label_ID = Group_ValueShow:FindDirect("Label_ID")
  local Label_Sex = Group_ValueShow:FindDirect("Label_Sex")
  local Label_BirthdayMonth = Group_ValueShow:FindDirect("Label_BirthdayMonth")
  local Label_BirthdayDay = Group_ValueShow:FindDirect("Label_BirthdayDay")
  local Label_zodiac = Group_ValueShow:FindDirect("Label_zodiac")
  local Label_Work = Group_ValueShow:FindDirect("Label_Work")
  local Label_Age = Group_ValueShow:FindDirect("Label_Age")
  local Label_Symbolic = Group_ValueShow:FindDirect("Label_Symbolic")
  local Label_BloodType = Group_ValueShow:FindDirect("Label_BloodType")
  local Label_School = Group_ValueShow:FindDirect("Label_School")
  local Label_Location = Group_ValueShow:FindDirect("Label_Location")
  local Label_Hobby = Group_ValueShow:FindDirect("Label_Hobby")
  local Label_TotalGameTime = Group_ValueShow:FindDirect("Label_TotalGameTime")
  Label_Sign:GetComponent("UILabel"):set_text(personalInfo:getSign())
  Label_ID:GetComponent("UILabel"):set_text(personalInfo:getDisplayId())
  Label_Sex:GetComponent("UILabel"):set_text(personalInfo:getSex())
  Label_BirthdayMonth:GetComponent("UILabel"):set_text(personalInfo:getBirthdayMonth())
  Label_BirthdayDay:GetComponent("UILabel"):set_text(personalInfo:getBirthdayDay())
  Label_zodiac:GetComponent("UILabel"):set_text(personalInfo:getConstellation())
  Label_Work:GetComponent("UILabel"):set_text(personalInfo:getWork())
  Label_Age:GetComponent("UILabel"):set_text(info.age)
  Label_Symbolic:GetComponent("UILabel"):set_text(personalInfo:getShengxiao())
  Label_BloodType:GetComponent("UILabel"):set_text(personalInfo:getBloodType())
  Label_School:GetComponent("UILabel"):set_text(personalInfo:getSchool())
  Label_Location:GetComponent("UILabel"):set_text(personalInfo:getLocaltion())
  Label_Hobby:GetComponent("UILabel"):set_text(personalInfo:getHobby())
  local hour = math.floor(info.onlineSeconds:ToNumber() / 3600)
  Label_TotalGameTime:GetComponent("UILabel"):set_text(string.format(textRes.Personal[7], hour))
  Label_PlayerName:GetComponent("UILabel"):set_text(GetStringFromOcts(info.roleName))
  self:setHeadImg(false)
end
PersonInfoNode.Commit()
return PersonInfoNode
