local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local SignNode = Lplus.Extend(TabNode, "SignNode")
local ItemUtils = require("Main.Item.ItemUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local BTGDailySign = require("Main.BackToGame.mgr.BTGDailySign")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local def = SignNode.define
def.field("table").m_signData = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  Event.RegisterEventWithContext(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.DailySignUpdate, SignNode.OnUpdate, self)
  self:UpdateSignList()
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.DailySignUpdate, SignNode.OnUpdate)
  self.m_signData = nil
end
def.override("string").onClick = function(self, id)
  if string.sub(id, 1, 11) == "Group_Date_" then
    local index = tonumber(string.sub(id, 12))
    if index then
      local info = self.m_signData[index]
      if info then
        if info.canSign then
          BTGDailySign.Instance():Sign(index)
        else
          local icon = self.m_node:FindDirect("Group_QianDao/Group_Items/Scroll View/List/" .. id)
          if icon then
            ItemTipsMgr.Instance():ShowBasicTipsWithGO(info.item.itemId, icon, 0, false)
          end
        end
      end
    end
  end
end
def.method().UpdateSignList = function(self)
  self.m_signData = BTGDailySign.Instance():GetSignData()
  local scroll = self.m_node:FindDirect("Group_QianDao/Group_Items/Scroll View")
  local list = scroll:FindDirect("List")
  local listCmp = list:GetComponent("UIList")
  local count = #self.m_signData
  listCmp:set_itemCount(count)
  listCmp:Resize()
  local canSignUI
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local info = self.m_signData[i]
    self:FillItem(uiGo, info, i)
    if info.canSign then
      canSignUI = uiGo
    end
    self.m_base.m_msgHandler:Touch(uiGo)
  end
  GameUtil.AddGlobalTimer(1, true, function()
    if not scroll.isnil and canSignUI and not canSignUI.isnil then
      scroll:GetComponent("UIScrollView"):DragToMakeVisible(canSignUI.transform, 32)
    end
  end)
end
def.method("userdata", "table", "number").FillItem = function(self, uiGo, info, index)
  local icon = uiGo:FindDirect(string.format("Img_BgIcon_%d", index))
  local texture = icon:FindDirect(string.format("Texture_Icon_%d", index))
  local numLbl = icon:FindDirect(string.format("Label_Num_%d", index))
  local signed = uiGo:FindDirect(string.format("Img_YiLing_%d", index))
  local nameLbl = uiGo:FindDirect(string.format("Label_Name_%d", index))
  local dayLbl = uiGo:FindDirect(string.format("Label_Day_%d", index))
  dayLbl:GetComponent("UILabel"):set_text(tostring(index) .. textRes.Common.Day)
  signed:SetActive(info.signed)
  if info.signed then
    GUIUtils.SetTextureEffect(texture:GetComponent("UITexture"), GUIUtils.Effect.Gray)
  else
    GUIUtils.SetTextureEffect(texture:GetComponent("UITexture"), GUIUtils.Effect.Normal)
  end
  if info.item then
    local itemBase = ItemUtils.GetItemBase(info.item.itemId)
    if info.signed then
      icon:GetComponent("UISprite"):set_spriteName("Cell_07")
    else
      icon:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", itemBase.namecolor))
    end
    GUIUtils.FillIcon(texture:GetComponent("UITexture"), info.item.iconId)
    numLbl:GetComponent("UILabel"):set_text(tostring(info.item.num))
    nameLbl:GetComponent("UILabel"):set_text(itemBase.name)
  else
    icon:GetComponent("UISprite"):set_spriteName("Cell_00")
    GUIUtils.FillIcon(texture:GetComponent("UITexture"), 0)
    numLbl:GetComponent("UILabel"):set_text("")
    nameLbl:GetComponent("UILabel"):set_text("")
  end
  if info.canSign then
    GUIUtils.SetLightEffect(icon, GUIUtils.Light.Square)
  else
    GUIUtils.SetLightEffect(icon, GUIUtils.Light.None)
  end
end
def.method("table").OnUpdate = function(self, param)
  self:UpdateSignList()
end
def.method("=>", "boolean").IsOpen = function(self)
  local open = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_SIGN)
  return open
end
SignNode.Commit()
return SignNode
