local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local CommonRoleOperateMenu = Lplus.Extend(ECPanelBase, "CommonRoleOperateMenu")
local Vector = require("Types.Vector")
local Vector3 = require("Types.Vector3").Vector3
local GUIUtils = require("GUI.GUIUtils")
local def = CommonRoleOperateMenu.define
def.const("number").TEAM_MEMBER_LIMIT = 5
def.field("function").callback = nil
def.field("table").tag = nil
def.field("string").name = ""
def.field("number").level = 0
def.field("number").occupationId = 0
def.field("number").gender = 0
def.field("number").teamMenberNum = 0
def.field("boolean").isOnline = false
def.field("userdata").roleId = nil
def.field("string").appellation = ""
def.field("string").gangName = ""
def.field("number").closeness = 0
def.field("string").closenessTips = ""
def.field("dynamic").avatarId = nil
def.field("dynamic").avatarFrameId = nil
def.field("string").remarkName = ""
def.field("boolean").isFriend = false
def.field("table").operateItemList = nil
def.field("number").ITEM_PER_PAGE_LIMIT = 6
def.field("number").playerInfoHeight = 0
def.field("number").btnHeight = 0
def.field("number").btnPaddingY = 0
def.field("number").otherPaddingY = 0
def.field("number").currentPage = 1
def.field("boolean").haveMore = false
def.field("table").pos = nil
def.field("userdata").btnTemplate = nil
def.field("table").uiObjs = nil
local instance
def.static("=>", CommonRoleOperateMenu).Instance = function()
  if instance == nil then
    instance = CommonRoleOperateMenu()
    instance:SetDefaultValue()
  end
  return instance
end
def.method("function", "table").ShowPanel = function(self, callback, tag)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.callback = callback
  self.tag = tag
  self:CreatePanel(RESPATH.PREFAB_ROLE_OPERATE_MENU_RES, 2)
  self:SetOutTouchDisappear()
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  self:Init()
  self:UpdatePanel()
  GameUtil.AddGlobalLateTimer(0, true, function()
    GameUtil.AddGlobalLateTimer(0, true, function()
      if not self.m_panel then
        return
      end
      self:UpdatePos()
    end)
  end)
end
def.override().OnDestroy = function(self)
  self.callback = nil
  self:SetDefaultValue()
  self.uiObjs = nil
end
def.method("table").SetPos = function(self, pos)
  if not self:IsShow() then
    self.pos = pos
    return
  end
  self:UpdatePos()
end
def.method().UpdatePos = function(self)
  self.m_panel:set_localPosition(Vector.Vector3.new(0, 0, 0))
  local Img_BgMenu = self.m_panel:FindDirect("Img_BgMenu")
  if self.pos.auto then
    local tipFrame = self.m_panel:FindDirect("Img_BgMenu")
    local tipWidth = tipFrame:GetComponent("UISprite"):get_width()
    local tipHeight = tipFrame:GetComponent("UISprite"):get_height()
    local targetX, targetY = require("Common.MathHelper").ComputeTipsAutoPosition(self.pos.sourceX, self.pos.sourceY, self.pos.sourceW, self.pos.sourceH, tipWidth, tipHeight, self.pos.prefer)
    targetY = targetY + tipHeight / 2
    Img_BgMenu:set_localPosition(Vector.Vector3.new(targetX, targetY, 0))
  else
    Img_BgMenu:set_localPosition(Vector.Vector3.new(self.pos.x, self.pos.y, 0))
    GUIUtils.RestrictUIWidgetInScreen(Img_BgMenu)
  end
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    self:HidePanel()
  elseif string.sub(id, 1, 8) == "Btn_Info" then
    self:OnItemButtonClick(id)
  elseif id == "Btn_Tips" then
    self:ShowClosenessTip()
  elseif id == "Btn_Edit" then
    self:ShowEdit()
  end
end
def.method("number").DoCallback = function(self, index)
  if self.callback == nil then
    return
  end
  local isClosePanel = self.callback(index, self.tag)
  if isClosePanel then
    self:HidePanel()
  end
end
def.method().Init = function(self)
  self.btnTemplate = self.m_panel:FindDirect("Img_BgMenu/Grid_Btn/Btn_Info")
  self.btnTemplate.name = "Btn_Info_0"
  self.btnTemplate:SetActive(false)
  self.uiObjs = {}
  self.uiObjs.Img_BgMenu = self.m_panel:FindDirect("Img_BgMenu")
  self.uiObjs.Group_PlayerInfo = self.uiObjs.Img_BgMenu:FindDirect("Group_PlayerInfo")
  self.uiObjs.Grid_Btn = self.uiObjs.Img_BgMenu:FindDirect("Grid_Btn")
  self.uiObjs.Group_RelationShip = self.uiObjs.Img_BgMenu:FindDirect("Group_RelationShip")
end
def.method().SetDefaultValue = function(self)
  self.currentPage = 1
  self.appellation = textRes.Common[1]
  self.gangName = textRes.Common[1]
end
def.method().UpdatePanel = function(self)
  if not self:IsShow() then
    return
  end
  self:UpdateHead()
  self:UpdateBody()
  self:UpdateBottom()
end
def.method().UpdateHead = function(self)
  self:UpdateName()
  self:UpdateLv()
  self:UpdateOccupation()
  self:UpdateTeamInfo()
  self:UpdateRoleID()
  self:UpdateRoleHeadIcon()
  self:UpdateRoleGender()
end
def.method().UpdateBody = function(self)
  self:UpdateAppellation()
  self:UpdateGangName()
  self:UpdateFriendlyPoint()
  self:UpdatePlayerRelation()
  self:UpdateRemark()
end
def.method().UpdateBottom = function(self)
  self:UpdateOperateItemList()
end
def.method().UpdateRemark = function(self)
  local remark = self.uiObjs.Img_BgMenu:FindDirect("Group_Remark")
  local remarkNameOpen = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_FRIEND_REMARK_NAME)
  if remarkNameOpen and self.isFriend then
    remark:SetActive(true)
    local name = (self.remarkName == nil or self.remarkName == "") and textRes.Common[1] or self.remarkName
    GUIUtils.SetText(remark:FindDirect("Label_Remark"), textRes.Common[48] .. name)
  else
    remark:SetActive(false)
  end
end
def.method().UpdateAppellation = function(self)
  GUIUtils.SetText(self.uiObjs.Img_BgMenu:FindDirect("Group_OtherName/Label_OtherName"), textRes.Common[4] .. self.appellation)
end
def.method().UpdateGangName = function(self)
  GUIUtils.SetText(self.uiObjs.Img_BgMenu:FindDirect("Group_Faction/Label_Faction"), textRes.Common[5] .. self.gangName)
end
def.method().UpdateFriendlyPoint = function(self)
  GUIUtils.SetText(self.uiObjs.Img_BgMenu:FindDirect("Group_FriendlyPoint/Label_FriendlyPoint"), textRes.Common[6] .. self.closeness)
end
def.method().UpdateName = function(self)
  local obj_playerInfo = self.uiObjs.Group_PlayerInfo
  GUIUtils.SetText(obj_playerInfo:FindDirect("Label_Name"), self.name)
end
def.method().UpdateLv = function(self)
  local obj_playerInfo = self.uiObjs.Group_PlayerInfo
  GUIUtils.SetText(obj_playerInfo:FindDirect("Label_Lv"), self.level)
end
def.method().UpdateOccupation = function(self)
  local Img_School = self.uiObjs.Group_PlayerInfo:FindDirect("Img_School")
  local occupationSprite = GUIUtils.GetOccupationSmallIcon(self.occupationId)
  GUIUtils.SetSprite(Img_School, occupationSprite)
end
def.method().UpdateRoleGender = function(self)
  local Img_Sex = self.uiObjs.Group_PlayerInfo:FindDirect("Img_Sex")
  local genderSprite = GUIUtils.GetSexIcon(self.gender)
  GUIUtils.SetSprite(Img_Sex, genderSprite)
end
def.method().UpdatePlayerRelation = function(self)
  local relation = {}
  local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
  if mateInfo ~= nil and mateInfo.mateId == self.roleId then
    table.insert(relation, textRes.Common[222])
  end
  local swornMgr = require("Main.Sworn.SwornMgr")
  if swornMgr.IsSwornMember(self.roleId) then
    table.insert(relation, textRes.Common[223])
  end
  local shituData = require("Main.Shitu.ShituData").Instance()
  if shituData:IsShituRelationWithPlayer(self.roleId) then
    table.insert(relation, textRes.Common[224])
  end
  if #relation == 0 then
    self.uiObjs.Group_RelationShip:SetActive(false)
  else
    GUIUtils.SetText(self.uiObjs.Group_RelationShip:FindDirect("Label_RelationShip"), textRes.Common[220] .. table.concat(relation, "\227\128\129"))
  end
end
def.method().UpdateRoleID = function(self)
  local obj_playerInfo = self.uiObjs.Group_PlayerInfo
  local displayId = require("Main.Hero.Interface").RoleIDToDisplayID(self.roleId)
  local text = string.format(textRes.Hero[2], tostring(displayId))
  GUIUtils.SetText(obj_playerInfo:FindDirect("Label_ID"), text)
end
def.method().UpdateTeamInfo = function(self)
  local obj_playerInfo = self.uiObjs.Group_PlayerInfo
  obj_playerInfo:FindDirect("Img_Team"):SetActive(false)
  if self.isOnline then
    local teamInfo
    if self.teamMenberNum > 0 then
      obj_playerInfo:FindDirect("Img_Team"):SetActive(true)
      teamInfo = string.format("%d/%d", self.teamMenberNum, CommonRoleOperateMenu.TEAM_MEMBER_LIMIT)
    else
      teamInfo = ""
    end
    GUIUtils.SetText(obj_playerInfo:FindDirect("Label_TeamNum"), teamInfo)
  else
    GUIUtils.SetText(obj_playerInfo:FindDirect("Label_TeamNum"), textRes.Common[7])
  end
end
def.method().UpdateRoleHeadIcon = function(self)
  local Icon_Head = self.uiObjs.Group_PlayerInfo:FindDirect("Img_BgTitle/Icon_Head")
  _G.SetAvatarIcon(Icon_Head, self.avatarId, self.avatarFrameId)
end
def.method().UpdateOperateItemList = function(self)
  if self.operateItemList == nil or #self.operateItemList == 0 then
    local i = 1
    while true do
      local itemObj = self.uiObjs.Grid_Btn:FindDirect("Btn_Info_" .. i)
      if itemObj == nil then
        break
      end
      GameObject.Destroy(itemObj)
      i = i + 1
    end
    self.uiObjs.Grid_Btn:GetComponent("UIGrid"):Reposition()
    self.uiObjs.Img_BgMenu:GetComponent("UITableResizeBackground"):Reposition()
    return
  end
  local itemObjParent = self.uiObjs.Grid_Btn
  local uiGrid = itemObjParent:GetComponent("UIGrid")
  local template = self.btnTemplate
  local itemCount = #self.operateItemList
  for i = 1, itemCount do
    local itemObj = itemObjParent:FindDirect("Btn_Info_" .. i)
    if itemObj == nil then
      itemObj = GameObject.Instantiate(template)
      itemObj:SetActive(true)
      itemObj.name = "Btn_Info_" .. i
      uiGrid:AddChild(itemObj.transform)
      itemObj.transform.localScale = Vector3.one
    end
    itemObj:FindDirect("Label_Info"):GetComponent("UILabel"):set_text(self.operateItemList[i])
  end
  local unuseIdx = itemCount + 1
  while true do
    local itemObj = itemObjParent:FindDirect("Btn_Info_" .. unuseIdx)
    if itemObj == nil then
      break
    end
    GameObject.Destroy(itemObj)
    unuseIdx = unuseIdx + 1
  end
  GameUtil.AddGlobalLateTimer(0, true, function(...)
    if itemObjParent.isnil then
      return
    end
    self.uiObjs.Grid_Btn:GetComponent("UIGrid"):Reposition()
    self.uiObjs.Img_BgMenu:GetComponent("UITableResizeBackground"):Reposition()
  end)
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("string").OnItemButtonClick = function(self, id)
  local id = tonumber(string.sub(id, 10, -1))
  if id == 1 then
    if self.currentPage == 1 then
      self:ClickItem(1)
    else
      self.currentPage = self.currentPage - 1
      self:UpdateOperateItemList()
    end
  elseif id == self.ITEM_PER_PAGE_LIMIT then
    if self.haveMore == false then
      local index = 0
      if self.currentPage == 1 then
        index = self.ITEM_PER_PAGE_LIMIT
      else
        index = self.ITEM_PER_PAGE_LIMIT - 1 + (self.currentPage - 1) * (self.ITEM_PER_PAGE_LIMIT - 2) + 1
      end
      self:ClickItem(index)
    else
      self.currentPage = self.currentPage + 1
      self:UpdateOperateItemList()
    end
  else
    local index = 0
    if self.currentPage == 1 then
      index = id
    else
      index = self.ITEM_PER_PAGE_LIMIT - 1 + (self.currentPage - 2) * (self.ITEM_PER_PAGE_LIMIT - 2) + id - 1
    end
    self:ClickItem(index)
  end
end
def.method("number").ClickItem = function(self, index)
  self:DoCallback(index)
end
def.method().ShowClosenessTip = function(self)
  require("GUI.CommonUITipsDlg").Instance():ShowDlg(self.closenessTips, {x = 0, y = 60})
end
def.method().ShowEdit = function(self)
  require("Main.friend.FriendModule").Instance():ChangeRemark(self.roleId)
end
return CommonRoleOperateMenu.Commit()
