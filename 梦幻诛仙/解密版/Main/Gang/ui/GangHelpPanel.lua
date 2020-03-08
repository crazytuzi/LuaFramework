local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GangHelpPanel = Lplus.Extend(ECPanelBase, "GangHelpPanel")
local def = GangHelpPanel.define
local instance
local GangUtility = require("Main.Gang.GangUtility")
local GangData = require("Main.Gang.data.GangData")
local GangHelp = require("netio.protocol.mzm.gsp.gang.GangHelp")
local GangModule = require("Main.Gang.GangModule")
def.field("function").callback = nil
def.field("table").tag = nil
def.static("=>", GangHelpPanel).Instance = function(self)
  if nil == instance then
    instance = GangHelpPanel()
  end
  return instance
end
def.static("function", "table").ShowGangHelpPanel = function(callback, tag)
  GangHelpPanel.Instance().callback = callback
  GangHelpPanel.Instance().tag = tag
  GangHelpPanel.Instance():SetModal(true)
  GangHelpPanel.Instance():CreatePanel(RESPATH.PREFAB_GANG_HELP_PANEL, 0)
end
def.override().OnCreate = function(self)
  self:UpdateInfo()
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_HelpChaned, GangHelpPanel.OnHelpInfoChanged)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, GangHelpPanel.OnGangChange)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberInfoChange, GangHelpPanel.OnMemberInfoChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_HelpChaned, GangHelpPanel.OnHelpInfoChanged)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, GangHelpPanel.OnGangChange)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberInfoChange, GangHelpPanel.OnMemberInfoChange)
end
def.static("table", "table").OnHelpInfoChanged = function(params, context)
  local self = instance
  if self.m_panel and self.m_panel:get_activeInHierarchy() then
    self:UpdateInfo()
  end
end
def.static("table", "table").OnGangChange = function(params, context)
  local self = instance
  if self and self.m_panel and not GangModule.Instance():HasGang() then
    self:Hide()
  end
end
def.static("table", "table").OnMemberInfoChange = function(params, context)
  local self = instance
  if self.m_panel and self.m_panel:get_activeInHierarchy() then
    self:UpdateInfo()
  end
end
def.method("=>", "table").GetHuanHunHelp = function(self)
  local helpList = {}
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local activityInterface = ActivityInterface.Instance()
  local huanhunGangHelp = activityInterface:GetHuanhunGangHelpInfo()
  if huanhunGangHelp then
    for roleId, helpData in pairs(huanhunGangHelp) do
      local roleId64 = Int64.new(roleId)
      for boxKey, boxData in pairs(helpData) do
        local help = {
          activityId = constant.HuanHunMiShuConsts.HUANHUN_ACTIVITYID,
          roleId = roleId64,
          caoWei = boxKey,
          itemId = boxData.itemId,
          itemNum = boxData.num
        }
        table.insert(helpList, help)
      end
    end
  end
  return helpList
end
def.method().UpdateInfo = function(self)
  local helpList = self:GetHuanHunHelp()
  local helpAmount = #helpList
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local ScrollView = Img_Bg:FindDirect("Scroll View")
  local ImgNoHelp = Img_Bg:FindDirect("Group_NoHelp")
  if helpAmount == 0 then
    ScrollView:SetActive(false)
    ImgNoHelp:SetActive(true)
    return
  else
    ScrollView:SetActive(true)
    ImgNoHelp:SetActive(false)
  end
  local List_Member = ScrollView:FindDirect("List_Member"):GetComponent("UIList")
  List_Member:set_itemCount(helpAmount)
  List_Member:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not List_Member.isnil then
      List_Member:Reposition()
    end
  end)
  local helps = List_Member:get_children()
  for i = 1, helpAmount do
    local helpUI = helps[i]
    local helpInfo = helpList[i]
    self:FillHelpInfo(helpUI, i, helpInfo)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  ScrollView:GetComponent("UIScrollView"):ResetPosition()
end
def.method("userdata", "number", "table").FillHelpInfo = function(self, helpUI, index, helpInfo)
  local roleId = helpInfo.roleId
  local data = GangData.Instance()
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local activityCfg = ActivityInterface.GetActivityCfgById(helpInfo.activityId)
  helpUI:FindDirect(string.format("Label_ActivityName_%d", index)):GetComponent("UILabel"):set_text(activityCfg.activityName)
  helpUI:FindDirect(string.format("Label_ActivityId_%d", index)):GetComponent("UILabel"):set_text(helpInfo.activityId)
  helpUI:FindDirect(string.format("Label_ActivityId_%d", index)):SetActive(false)
  helpUI:FindDirect(string.format("Label_RoleId_%d", index)):GetComponent("UILabel"):set_text(helpInfo.roleId:tostring())
  helpUI:FindDirect(string.format("Label_RoleId_%d", index)):SetActive(false)
  helpUI:FindDirect(string.format("Label_CaoId_%d", index)):GetComponent("UILabel"):set_text(helpInfo.caoWei)
  helpUI:FindDirect(string.format("Label_CaoId_%d", index)):SetActive(false)
  local itemID = helpInfo.itemId
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemBase = ItemUtils.GetItemBase2(itemID)
  if itemBase ~= nil then
    helpUI:FindDirect(string.format("Label_ItemName_%d", index)):GetComponent("UILabel"):set_text(string.format("%s*%d", itemBase.name, helpInfo.itemNum))
  else
    local filterCfg = ItemUtils.GetItemFilterCfg(itemID)
    helpUI:FindDirect(string.format("Label_ItemName_%d", index)):GetComponent("UILabel"):set_text(string.format("%s*%d", filterCfg.name, helpInfo.itemNum))
  end
  local memberInfo = data:GetMemberInfoByRoleId(roleId)
  if memberInfo == nil then
    return
  end
  local FriendUtils = require("Main.friend.FriendUtils")
  local occupationIconId = FriendUtils.GetOccupationIconId(memberInfo.occupationId)
  local occupationSprite = helpUI:FindDirect(string.format("Img_MenPai_%d", index)):GetComponent("UISprite")
  FriendUtils.FillIcon(occupationIconId, occupationSprite, 3)
  warn("[GangHelpPanel:FillHelpInfo] memberInfo.avatarId:", memberInfo.avatarId)
  local iconSprite = helpUI:FindDirect(string.format("Icon_Frame_%d", index)):FindDirect(string.format("Icon_Head_%d", index))
  _G.SetAvatarIcon(iconSprite, memberInfo.avatarId, memberInfo.avatar_frame or 0)
  local GUIUtils = require("GUI.GUIUtils")
  local genderIcon = helpUI:FindDirect("Img_Sex_" .. index)
  GUIUtils.SetSprite(genderIcon, GUIUtils.GetSexIcon(memberInfo.gender))
  helpUI:FindDirect(string.format("Label_UserName_%d", index)):GetComponent("UILabel"):set_text(memberInfo.name)
  helpUI:FindDirect(string.format("Label_Level_%d", index)):GetComponent("UILabel"):set_text(memberInfo.level)
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self = nil
end
def.method("userdata").OnHelpBtnClick = function(self, clickobj)
  local id = clickobj.name
  local index = tonumber(string.sub(id, #"Btn_Help_" + 1, -1))
  local Label_ActivityId = clickobj.parent:FindDirect(string.format("Label_ActivityId_%d", index)):GetComponent("UILabel"):get_text()
  local Label_RoleId = clickobj.parent:FindDirect(string.format("Label_RoleId_%d", index)):GetComponent("UILabel"):get_text()
  local Label_CaoId = clickobj.parent:FindDirect(string.format("Label_CaoId_%d", index)):GetComponent("UILabel"):get_text()
  local activityId = tonumber(Label_ActivityId)
  local roleId = Int64.new(Label_RoleId)
  local caoId = tonumber(Label_CaoId)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_HelpBtn, {
    activityId,
    roleId,
    caoId
  })
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Close" == id then
    self:Hide()
  elseif string.sub(id, 1, #"Btn_Help_") == "Btn_Help_" then
    self:OnHelpBtnClick(clickobj)
  elseif "Modal" == id then
    self:Hide()
  end
end
return GangHelpPanel.Commit()
