local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CommonChooseRoleList = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Cls = CommonChooseRoleList
local def = Cls.define
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local FriendData = require("Main.friend.FriendData")
def.field("table").m_uiObjs = nil
def.field("string").m_title = ""
def.field("table").m_roleList = nil
def.field("string").m_emptyDesc = ""
def.field("string").m_selectBtnText = ""
def.field("string").m_tipsText = ""
def.field("function").m_onChoose = nil
def.field("table").m_context = nil
local RoleInfo = Lplus.Class(MODULE_NAME .. ".RoleInfo")
do
  local def = RoleInfo.define
  def.field("userdata").roleId = nil
  def.field("string").name = ""
  def.field("number").level = 0
  def.field("number").occupationId = 0
  def.field("number").gender = 0
  def.field("number").avatarId = 0
  def.field("number").avatarFrameId = 0
  RoleInfo.Commit()
end
def.const("table").RoleInfo = RoleInfo
def.static("string", "table", "string", "function", "table", "=>", CommonChooseRoleList).ShowPanel = function(title, roleList, emptyDesc, onChoose, context)
  local panel = CommonChooseRoleList()
  panel.m_title = title
  panel.m_roleList = roleList
  panel.m_emptyDesc = emptyDesc
  panel.m_onChoose = onChoose
  panel.m_context = context
  panel:_ShowPanel()
  return panel
end
def.static("string", "table", "string", "string", "function", "table", "=>", CommonChooseRoleList).ShowPanelEx = function(title, roleList, emptyDesc, selectBtnText, onChoose, context)
  local panel = CommonChooseRoleList()
  panel.m_title = title
  panel.m_roleList = roleList
  panel.m_emptyDesc = emptyDesc
  panel.m_selectBtnText = selectBtnText
  panel.m_onChoose = onChoose
  panel.m_context = context
  panel:_ShowPanel()
  return panel
end
def.static("table", "=>", RoleInfo).ConvertFriendRoleInfo = function(friendInfo)
  local roleInfo = RoleInfo()
  roleInfo.roleId = friendInfo.roleId
  roleInfo.name = friendInfo.roleName
  roleInfo.level = friendInfo.roleLevel
  roleInfo.occupationId = friendInfo.occupationId
  roleInfo.gender = friendInfo.sex
  roleInfo.avatarId = friendInfo.avatarId
  roleInfo.avatarFrameId = friendInfo.avatarFrameId
  return roleInfo
end
def.method("string").SetTips = function(self, tips)
  self.m_tipsText = tips
  if self:IsLoaded() then
    self:UpdateTips()
  end
end
def.method()._ShowPanel = function(self)
  if self:IsLoaded() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_COMMON_CHOOSE_ROLE_LIST_PANEL, 2)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.m_uiObjs = nil
  self.m_title = ""
  self.m_roleList = nil
  self.m_emptyDesc = ""
  self.m_selectBtnText = ""
  self.m_tipsText = ""
  self.m_onChoose = nil
  self.m_context = nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Img_Head" then
    local index = tonumber(obj.parent.parent.name:split("_")[2])
    if index then
      self:OnClickRoleHead(obj, index)
    end
  elseif id == "Btn_Select" then
    local index = tonumber(obj.parent.name:split("_")[2])
    if index then
      self:OnChooseRole(index)
    end
  end
end
def.method().InitUI = function(self)
  self.m_uiObjs = {}
  local Img_Bg = self.m_panel:FindDirect("Img_Bg/Group_List/Img_Bg")
  if Img_Bg then
    local uiWidget = Img_Bg:GetComponent("UIWidget")
    if uiWidget then
      uiWidget:set_depth(1)
    end
  end
end
def.method().UpdateUI = function(self)
  self:UpdateTitle()
  self:UpdateRoleList()
  self:UpdateTips()
end
def.method().UpdateTitle = function(self)
  local Label_Title = self.m_panel:FindDirect("Img_Bg/Img_Title/Label_Title")
  GUIUtils.SetText(Label_Title, self.m_title)
end
def.method().UpdateRoleList = function(self)
  local List = self.m_panel:FindDirect("Img_Bg/Group_List/Group_List/Scrolllist/List")
  local uiList = List:GetComponent("UIList")
  local roleNum = #self.m_roleList
  uiList:set_itemCount(roleNum)
  uiList:Resize()
  if roleNum == 0 then
    self:ShowEmptyDesc()
    return
  end
  local Group_NoData = self.m_panel:FindDirect("Img_Bg/Group_List/Group_NoData")
  local Group_List = self.m_panel:FindDirect("Img_Bg/Group_List/Group_List")
  Group_NoData:SetActive(false)
  Group_List:SetActive(true)
  local itemObjs = uiList:get_children()
  for i, itemObj in ipairs(itemObjs) do
    local roleInfo = self.m_roleList[i]
    self:SetItemRoleInfo(itemObj, roleInfo)
  end
end
def.method("userdata", "table").SetItemRoleInfo = function(self, itemObj, roleInfo)
  local Group_Head = itemObj:FindDirect("Group_Head")
  local Img_Head = Group_Head:FindDirect("Img_Head")
  local Label_Lv = Img_Head:FindDirect("Label_Lv")
  local Label_Name = Img_Head:FindDirect("Label_Name")
  local Img_MenPai = Img_Head:FindDirect("Img_MenPai")
  local Img_Sex = Img_Head:FindDirect("Img_Sex")
  local Img_Friend = Img_Head:FindDirect("Img_Friend")
  local Img_Sign = Img_Head:FindDirect("Img_Sign")
  GUIUtils.SetText(Label_Name, roleInfo.name)
  GUIUtils.SetText(Label_Lv, roleInfo.level)
  GUIUtils.SetSprite(Img_MenPai, GUIUtils.GetOccupationSmallIcon(roleInfo.occupationId))
  GUIUtils.SetSprite(Img_Sex, GUIUtils.GetGenderSprite(roleInfo.gender))
  GUIUtils.SetActive(Img_Friend, FriendData.Instance():GetFriendInfo(roleInfo.roleId) ~= nil)
  GUIUtils.SetActive(Img_Sign, not _G.IsInIhisServer(roleInfo.roleId))
  _G.SetAvatarIcon(Img_Head, roleInfo.avatarId, roleInfo.avatarFrameId)
  if self.m_selectBtnText ~= "" then
    local Label_Select = itemObj:FindDirect("Btn_Select/Label_Select")
    GUIUtils.SetText(Label_Select, self.m_selectBtnText)
  end
end
def.method().ShowEmptyDesc = function(self)
  local Group_NoData = self.m_panel:FindDirect("Img_Bg/Group_List/Group_NoData")
  local Group_List = self.m_panel:FindDirect("Img_Bg/Group_List/Group_List")
  Group_NoData:SetActive(true)
  Group_List:SetActive(false)
  if self.m_emptyDesc ~= "" then
    local Label = Group_NoData:FindDirect("Img_Talk/Label")
    GUIUtils.SetText(Label, self.m_emptyDesc)
  end
end
def.method().UpdateTips = function(self)
  local Label_Tips = self.m_panel:FindDirect("Img_Bg/Label_Tips")
  if self.m_tipsText ~= "" then
    GUIUtils.SetActive(Label_Tips, true)
    GUIUtils.SetText(Label_Tips, self.m_tipsText)
  else
    GUIUtils.SetActive(Label_Tips, false)
  end
end
def.method("userdata", "number").OnClickRoleHead = function(self, baseObj, index)
  local sourceObj = baseObj
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  local simpleRoleInfo = self.m_roleList[index]
  local roleId = simpleRoleInfo.roleId
  gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ReqRoleInfo(roleId, function(roleInfo)
    if _G.IsNil(sourceObj) then
      return
    end
    require("Main.Pubrole.PubroleTipsMgr").Instance():ShowTip(roleInfo, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), -1, {inMap = true})
  end)
end
def.method("number").OnChooseRole = function(self, index)
  local roleInfo = self.m_roleList[index]
  if self.m_onChoose then
    local needDestroyPanel = self.m_onChoose(self.m_context, self, index, roleInfo.roleId)
    if needDestroyPanel or needDestroyPanel == nil then
      self:DestroyPanel()
    end
  end
end
return Cls.Commit()
