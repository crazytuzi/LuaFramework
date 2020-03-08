local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local BackHomeNode = Lplus.Extend(TabNode, "BackHomeNode")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local BTGBackHome = require("Main.BackToGame.mgr.BTGBackHome")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local def = BackHomeNode.define
def.field("table").m_items = nil
def.field("string").m_buff1Desc = ""
def.field("string").m_buff2Desc = ""
def.field("number").m_buffIcon1 = 0
def.field("number").m_buffIcon2 = 0
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  Event.RegisterEventWithContext(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.BackHomeUpdate, BackHomeNode.OnUpdate, self)
  local items, buff1, buff2, icon1, icon2 = BTGBackHome.Instance():GetBackHomeData()
  self.m_items = items
  self.m_buff1Desc = buff1
  self.m_buff2Desc = buff2
  self.m_buffIcon1 = icon1
  self.m_buffIcon2 = icon2
  self:UpdateItems()
  self:UpdateBuff()
  self:UpdateButton()
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.BackHomeUpdate, BackHomeNode.OnUpdate)
  self.m_items = nil
  self.m_buff1Desc = ""
  self.m_buff2Desc = ""
  self.m_buffIcon1 = 0
  self.m_buffIcon2 = 0
end
def.method("table").OnUpdate = function(self, param)
  self:UpdateButton()
end
def.override("string").onClick = function(self, id)
  if id == "Btn_Get" then
    BTGBackHome.Instance():GetBackHomeGift()
  elseif string.sub(id, 1, 11) == "Img_BgIcon_" then
    local index = tonumber(string.sub(id, 12))
    if index then
      local info = self.m_items[index]
      if info then
        local icon = self.m_node:FindDirect("Group_Item/" .. id)
        if icon then
          ItemTipsMgr.Instance():ShowBasicTipsWithGO(info.itemId, icon, 0, false)
        end
      end
    end
  end
end
def.method().UpdateItems = function(self)
  local list = self.m_node:FindDirect("Group_Item")
  local listCmp = list:GetComponent("UIList")
  local count = #self.m_items
  listCmp:set_itemCount(count)
  listCmp:Resize()
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local info = self.m_items[i]
    self:FillItem(uiGo, info, i)
    self.m_base.m_msgHandler:Touch(uiGo)
  end
end
def.method("userdata", "table", "number").FillItem = function(self, uiGo, item, index)
  local itemBase = ItemUtils.GetItemBase(item.itemId)
  local tex = uiGo:FindDirect(string.format("Texture_Icon_%d", index))
  GUIUtils.FillIcon(tex:GetComponent("UITexture"), item.iconId)
  local lbl = uiGo:FindDirect(string.format("Label_Num_%d", index))
  lbl:GetComponent("UILabel"):set_text(item.num)
end
def.method().UpdateBuff = function(self)
  local buffUI1 = self.m_node:FindDirect("Group_Single")
  local buffUI2 = self.m_node:FindDirect("Group_Team")
  self:FillBuff(buffUI1, self.m_buff1Desc, self.m_buffIcon1)
  self:FillBuff(buffUI2, self.m_buff2Desc, self.m_buffIcon2)
end
def.method("userdata", "string", "number").FillBuff = function(self, uiGO, buffDesc, icon)
  local tex = uiGO:FindDirect("Img_BgIcon/Texture_Icon")
  GUIUtils.FillIcon(tex:GetComponent("UITexture"), icon)
  local desc = uiGO:FindDirect("Label_Plus")
  desc:GetComponent("UILabel"):set_text(buffDesc)
end
def.method().UpdateButton = function(self)
  local btn = self.m_node:FindDirect("Btn_Get")
  local get = btn:FindDirect("Label_Get")
  local gotten = self.m_node:FindDirect("Img_Finish")
  local can = BTGBackHome.Instance():GetCanDraw()
  if can then
    get:SetActive(true)
    btn:SetActive(true)
    gotten:SetActive(false)
  else
    get:SetActive(false)
    btn:SetActive(false)
    gotten:SetActive(true)
  end
end
def.method("=>", "boolean").IsOpen = function(self)
  local open = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_AWARD)
  return open
end
BackHomeNode.Commit()
return BackHomeNode
