local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BlackListDlg = Lplus.Extend(ECPanelBase, "BlackListDlg")
local Vector = require("Types.Vector")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local FriendUtils = require("Main.friend.FriendUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local MailContent = require("netio.protocol.mzm.gsp.mail.MailContent")
local def = BlackListDlg.define
local instance
def.static("=>", BlackListDlg).Instance = function(self)
  if nil == instance then
    instance = BlackListDlg()
  end
  return instance
end
def.static().ShowBlockList = function()
  local dlg = BlackListDlg.Instance()
  if dlg:IsShow() then
  else
    dlg:CreatePanel(RESPATH.PREFAB_BLOCK_LIST, 2)
  end
end
def.field("table").blackList = nil
def.override().OnCreate = function(self)
  self:UpdateList()
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_SucceedShield, BlackListDlg.OnBlockListChange, self)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_SucceedShield, BlackListDlg.OnBlockListChange)
end
def.method("table").OnBlockListChange = function(self, params)
  self:UpdateList()
end
def.method().UpdateList = function(self)
  local friendData = require("Main.friend.FriendData").Instance()
  self.blackList = friendData:GetShieldList()
  local num = #self.blackList
  self:SetTitleNum(num)
  local list = self.m_panel:FindDirect("Img_Bg/Img_BgBlock/Scroll View_Block/Grid_Block")
  local listCmp = list:GetComponent("UIList")
  listCmp:set_itemCount(num)
  listCmp:Resize()
  local blockListUI = listCmp:get_children()
  for i = 1, #blockListUI do
    local blockUI = blockListUI[i]
    local blockInfo = self.blackList[i]
    self:FillBlockInfo(blockUI, blockInfo, i)
    self.m_msgHandler:Touch(blockUI)
  end
end
def.method("number").SetTitleNum = function(self, num)
  local fullNum = FriendUtils.GetShieldListMax()
  local numShow = self.m_panel:FindDirect("Img_Bg/Img_BgBlock/Img_BgBlockTitle/Label_BlockTitle/Label_Limit")
  numShow:SetActive(true)
  numShow:GetComponent("UILabel"):set_text(string.format("(%d/%d)", num, fullNum))
end
def.method("userdata", "table", "number").FillBlockInfo = function(self, blockUI, blockInfo, index)
  local tbl = {
    level = string.format("Label_NumFriendBlock_%d", index),
    name = string.format("Label_BlockName_%d", index),
    icon = string.format("Img_IconHeadBlock_%d", index),
    occupation = string.format("Img_SchoolFriendApply_%d", index),
    cover = string.format("Img_CoverFriendApply_%d", index)
  }
  local icon = blockUI:FindDirect(string.format("Img_IconHeadBlock_%d", index))
  SetAvatarIcon(icon, blockInfo.avatarId)
  local frame = icon:FindDirect(string.format("Img_BgBlock_%d", index))
  SetAvatarFrameIcon(frame, blockInfo.avatarFrameId)
  icon:FindDirect(string.format("Label_NumFriendBlock_%d", index)):GetComponent("UILabel"):set_text(blockInfo.roleLevel)
  blockUI:FindDirect(string.format("Label_BlockName_%d", index)):GetComponent("UILabel"):set_text(blockInfo.roleName)
  local occupationIconId = FriendUtils.GetOccupationIconId(blockInfo.occupationId)
  local occupationSprite = blockUI:FindDirect(string.format("Img_SchoolFriendApply_%d", index)):GetComponent("UISprite")
  FriendUtils.FillIcon(occupationIconId, occupationSprite, 3)
  local genderSprite = blockUI:FindDirect("Img_SexFriendApply_" .. index):GetComponent("UISprite")
  warn("GUIUtils.GetGenderSprite(blockInfo.gender)")
  genderSprite:set_spriteName(GUIUtils.GetGenderSprite(blockInfo.sex))
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.sub(id, 1, 16) == "Btn_BlockCancel_" then
    local index = tonumber(string.sub(id, 17))
    local blockInfo = self.blackList[index]
    if blockInfo then
      require("Main.friend.FriendModule").Instance():CRemoveShield(blockInfo.roleId)
    end
  end
end
BlackListDlg.Commit()
return BlackListDlg
