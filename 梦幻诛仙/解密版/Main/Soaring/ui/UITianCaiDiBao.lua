local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UITianCaiDiBao = Lplus.Extend(ECPanelBase, "UITianCaiDiBao")
local TaskTianCaiDiBao = require("Main.Soaring.proxy.TaskTianCaiDiBao")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local itemData = require("Main.Item.ItemData").Instance()
local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
local def = UITianCaiDiBao.define
local instance
local itemNum = 8
def.static("=>", UITianCaiDiBao).Instance = function()
  if instance == nil then
    instance = UITianCaiDiBao()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_UI_TIANCAIDIBAO, 1)
  self:SetModal(true)
end
def.method().PlayEffect = function(self)
  if self:IsShow() then
    local Fx = self.m_panel:FindDirect("Img_Bg/Fx")
    Fx:SetActive(true)
    GameUtil.AddGlobalTimer(2.2, true, function()
      if self.m_panel then
        self:HidePanel()
      end
    end)
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, UITianCaiDiBao.OnBagInfoSyncronized)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, UITianCaiDiBao.OnBagInfoSyncronized)
  TaskTianCaiDiBao.Instance():Release()
end
def.static("table", "table").OnBagInfoSyncronized = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setItemInfo()
  end
end
def.override("boolean").OnShow = function(self, b)
  if b then
    self:setItemInfo()
  else
  end
end
def.method().HidePanel = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Btn_Make" then
    local cfgData = TaskTianCaiDiBao.Instance():GetCfgData()._cfgData
    for i, v in ipairs(cfgData.need_items) do
      local count = itemData:GetNumberByItemId(BagInfo.BAG, v.item_cfg_id)
      if count < v.item_num then
        Toast(textRes.Soaring.TianCaiDiBao[1])
        return
      end
    end
    local p = require("netio.protocol.mzm.gsp.feisheng.CAttendCommitItemActivityReq").new(TaskTianCaiDiBao.ACTIVITY_ID)
    gmodule.network.sendProtocol(p)
    warn("------send:", TaskTianCaiDiBao.ACTIVITY_ID)
  elseif string.find(id, "Texture_Prize") == 1 then
    local idx = tonumber(string.sub(id, 14, 14))
    local itemId = 0
    local cfgData = TaskTianCaiDiBao.Instance():GetCfgData()._cfgData
    if idx <= itemNum then
      local itemInfo = cfgData.need_items[idx]
      if itemInfo then
        itemId = itemInfo.item_cfg_id
      end
    else
      itemId = cfgData.display_item_cfg_id
    end
    if itemId > 0 then
      local position = obj:get_position()
      local screenPos = WorldPosToScreen(position.x, position.y)
      local com = obj:GetComponent("UIWidget")
      if com == nil then
        return
      end
      ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, com:get_width(), com:get_height(), 0, idx <= itemNum)
    end
  end
end
def.method().setItemInfo = function(self)
  local cfgData = TaskTianCaiDiBao.Instance():GetCfgData()._cfgData
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  for i = 1, itemNum do
    local Img_Item = Img_Bg:FindDirect("Img_Item" .. i)
    local itemInfo = cfgData.need_items[i]
    if itemInfo then
      local Texture_Prize = Img_Item:FindDirect("Texture_Prize" .. i)
      local Label = Img_Item:FindDirect("Label" .. i)
      local uiTexture = Texture_Prize:GetComponent("UITexture")
      local count = itemData:GetNumberByItemId(BagInfo.BAG, itemInfo.item_cfg_id)
      local Label_num = Label:GetComponent("UILabel")
      Label_num:set_text(count .. "/" .. itemInfo.item_num)
      if count >= itemInfo.item_num then
        Label_num:set_textColor(Color.green)
      else
        Label_num:set_textColor(Color.red)
      end
      local itemBase = ItemUtils.GetItemBase(itemInfo.item_cfg_id)
      if itemBase then
        GUIUtils.FillIcon(uiTexture, itemBase.icon)
      else
        warn("!!!!!itemBase is nil:", itemInfo.item_cfg_id)
      end
    end
  end
  local Img_Item = Img_Bg:FindDirect("Img_Item9")
  local itemBase = ItemUtils.GetItemBase(cfgData.display_item_cfg_id)
  if itemBase then
    local Texture_Prize = Img_Item:FindDirect("Texture_Prize9")
    local uiTexture = Texture_Prize:GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, itemBase.icon)
  end
end
return UITianCaiDiBao.Commit()
