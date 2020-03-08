local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local FriendUtils = require("Main.friend.FriendUtils")
local FriendData = Lplus.ForwardDeclare("FriendData")
local SocialPanel = Lplus.ForwardDeclare("SocialPanel")
local FriendShieldShow = Lplus.Class("FriendShieldShow")
local def = FriendShieldShow.define
local instance
def.field(FriendData)._friendData = nil
def.field("userdata")._panel = nil
def.field(SocialPanel)._base = nil
def.static("=>", FriendShieldShow).Instance = function(self)
  if nil == instance then
    instance = FriendShieldShow()
    instance._friendData = FriendData.Instance()
  end
  return instance
end
def.method("userdata", SocialPanel).SetPanelAndBase = function(self, panel, base)
  self._panel = panel
  self._base = base
end
def.method().Clear = function(self)
  local WidgetFriend = self._panel:FindDirect("Img_BgFriend/Widget_Friend")
  local gridTemplate = WidgetFriend:FindDirect("Img_BgBlock"):FindDirect("Scroll View_Block/Grid_Block")
  local haveCount = gridTemplate:get_childCount()
  for i = 1, haveCount do
    local template = gridTemplate:GetChild(i - 1)
    if i == 1 then
      template:SetActive(false)
    else
      Object.Destroy(template)
      template = nil
    end
  end
end
def.method().ShowShieldList = function(self)
  local WidgetFriend = self._panel:FindDirect("Img_BgFriend/Widget_Friend")
  local BlockImg = WidgetFriend:FindDirect("Img_BgBlock")
  local scrollView = BlockImg:FindDirect("Scroll View_Block")
  local gridTemplate = scrollView:FindDirect("Grid_Block")
  BlockImg:SetActive(true)
  WidgetFriend:FindDirect("Img_BgApply"):SetActive(false)
  WidgetFriend:FindDirect("Img_FriendList"):SetActive(false)
  local shieldList = self._friendData:GetShieldList()
  local strShield = textRes.Friend[18] .. #shieldList
  BlockImg:FindDirect("Img_BgBlockTitle/Btn_BackToFriend02/Label_BackToFriend02"):GetComponent("UILabel"):set_text(strShield)
  self:FillList(shieldList, gridTemplate)
  self._base:TouchGameObject(self._base.m_panel, self._base.m_parent)
  GameUtil.AddGlobalTimer(0.05, true, function()
    if self._base.m_panel and false == self._base.m_panel.isnil then
      scrollView:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
end
def.method("table", "userdata").FillList = function(self, list, gridTemplate)
  local listNum = #list
  local uiList = gridTemplate:GetComponent("UIList")
  uiList:set_itemCount(listNum)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  local shieldsUI = uiList:get_children()
  for i = 1, #shieldsUI do
    local shieldUI = shieldsUI[i]
    local shieldInfo = list[i]
    self:FillShieldInfo(shieldUI, i, shieldInfo)
  end
  self._base:TouchGameObject(self._base.m_panel, self._base.m_parent)
end
def.method("userdata", "number", "table").FillShieldInfo = function(self, shieldNew, index, shieldInfo)
  local tbl = {
    level = string.format("Label_NumFriendBlock_%d", index),
    name = string.format("Label_BlockName_%d", index),
    icon = string.format("Img_IconHeadBlock_%d", index),
    occupation = string.format("Img_SchoolFriendApply_%d", index),
    cover = string.format("Img_CoverFriendApply_%d", index)
  }
  local bOnline = require("netio.protocol.mzm.gsp.blacklist.BlackRole").ST_ONLINE == shieldInfo.onlineStatus
  FriendUtils.FillBasicInfo(shieldNew, tbl, shieldInfo, bOnline)
end
def.static("userdata").RequireToAddShield = function(roleId)
  if roleId ~= nil then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.blacklist.CAddBlackRoleReq").new(roleId))
  end
end
def.static("userdata").RequireToRemoveShield = function(roleId)
  if roleId ~= nil then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.blacklist.CDelBlackRoleReq").new(roleId))
  end
end
def.static("userdata").AddShield = function(roleId)
  local shieldList = FriendData.Instance():GetShieldList()
  if #shieldList >= FriendUtils.GetShieldListMax() then
    Toast(textRes.Friend[50])
    return
  end
  if nil == FriendData.Instance():GetFriendInfo(roleId) then
    FriendShieldShow.RequireToAddShield(roleId)
    local FriendModule = require("Main.friend.FriendModule")
    local data = FriendModule.Instance()._data
    local applicantName = data:GetApplicantNameById(roleId)
    if applicantName ~= "" then
      local FriendApplyShow = require("Main.friend.ui.FriendApplyShow")
      FriendApplyShow.Refuse(roleId)
    end
  else
    Toast(textRes.Friend[11])
  end
end
def.static("string").RemoveShield = function(shieldName)
  local shieldInfo = FriendData.Instance():GetShieldInfoByName(shieldName)
  FriendShieldShow.RequireToRemoveShield(shieldInfo.roleId)
end
FriendShieldShow.Commit()
return FriendShieldShow
