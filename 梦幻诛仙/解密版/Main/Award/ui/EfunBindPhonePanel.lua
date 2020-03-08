local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local EfunBindPhonePanel = Lplus.Extend(ECPanelBase, "EfunBindPhonePanel")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GUIUtils = require("GUI.GUIUtils")
local ECUniSDK = require("ProxySDK.ECUniSDK")
local ItemUtils = require("Main.Item.ItemUtils")
local def = EfunBindPhonePanel.define
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
def.field("table").m_UIGO = nil
def.field("table").m_DataInfo = nil
local instance
def.static("=>", EfunBindPhonePanel).Instance = function()
  if not instance then
    instance = EfunBindPhonePanel()
  end
  return instance
end
def.static("table", "table").OnBindPhone = function(p1, p2)
  if instance.m_panel and not instance.m_panel.isnil then
    instance:UpdateUI()
  end
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_EFUN_ATTACH_PHONE, 0)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.EFUN_BIND_PHONE_AWARD, EfunBindPhonePanel.OnBindPhone)
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_DataInfo = {}
  self.m_UIGO.List_Items = self.m_panel:FindDirect("Group_TuiSongPrize/Bg_Items/List_Items")
  self.m_UIGO.Btn_Attached = self.m_panel:FindDirect("Group_TuiSongPrize/Btn_Attached")
  self.m_UIGO.Img_Attached = self.m_panel:FindDirect("Group_TuiSongPrize/Img_Attached")
  local uiListGO = self.m_UIGO.List_Items
  local awardId = constant.PushAwardConst.phoneBindAwardId
  local awardcfg = ItemUtils.GetGiftAwardCfgByAwardId(awardId)
  if not awardcfg.itemList then
    return
  end
  local itemLists = GUIUtils.InitUIList(uiListGO, #awardcfg.itemList)
  self.m_msgHandler:Touch(uiListGO)
  for i = 1, #awardcfg.itemList do
    local itemList = itemLists[i]
    local itemData = awardcfg.itemList[i]
    if itemData and itemData.itemId then
      local itemBase = ItemUtils.GetItemBase(itemData.itemId)
      local labelGO = itemList:FindDirect(("Label_Num_%d"):format(i))
      local nameGO = itemList:FindDirect(("Label_Name2_%d"):format(i))
      local textureGO = itemList:FindDirect(("Texture_Icon_%d"):format(i))
      GUIUtils.SetText(labelGO, ("%d"):format(itemData.num))
      GUIUtils.SetText(nameGO, itemBase.name)
      GUIUtils.SetTexture(textureGO, itemBase.icon)
      self.m_DataInfo[i] = {
        itemId = itemData.itemId,
        btnGO = itemList
      }
    end
  end
  GUIUtils.Reposition(uiListGO, GUIUtils.COTYPE.LIST, 0)
end
def.method().UpdateUI = function(self)
  GUIUtils.SetActive(self.m_UIGO.Btn_Attached, not ECUniSDK.Instance():IsBindPhone())
  GUIUtils.SetActive(self.m_UIGO.Img_Attached, ECUniSDK.Instance():IsBindPhone())
end
def.override().OnDestroy = function(self)
  self.m_UIGO = nil
  self.m_DataInfo = nil
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.EFUN_BIND_PHONE_AWARD, EfunBindPhonePanel.OnBindPhone)
end
def.method().Bind = function(self)
  ECUniSDK.Instance():BindPhone({})
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Attached" then
    self:Bind()
  elseif id:find("Img_BgIcon") == 1 then
    local _, lastIndex = id:find("Img_BgIcon_")
    local index = tonumber(id:sub(lastIndex + 1, -1))
    local btnGO = self.m_DataInfo[index].btnGO
    local itemId = self.m_DataInfo[index].itemId
    if btnGO and itemId then
      ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, btnGO, 1, true)
    end
  end
end
return EfunBindPhonePanel.Commit()
