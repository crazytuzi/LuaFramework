local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local FabaoUtils = require("Main.Fabao.FabaoUtils")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local EquipModule = require("Main.Equip.EquipModule")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local LongJingGetPanel = Lplus.Extend(ECPanelBase, "LongJingGetPanel")
local def = LongJingGetPanel.define
def.field("table").m_ClickGO = nil
def.field("table").m_ListData = nil
local instance
def.static("=>", LongJingGetPanel).Instance = function()
  if not instance then
    instance = LongJingGetPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_LONGJING_GET_PANEL, GUILEVEL.DEPENDEND)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:Update()
end
def.override().OnDestroy = function(self)
  self.m_ClickGO = nil
  self.m_ListData = nil
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id:find("Img_BgItem_") == 1 then
    local _, lastIndex = id:find("Img_BgItem_")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    local itemId = self.m_ListData[index]
    local btnGO = self.m_ClickGO[index]
    if not itemId or not btnGO then
      return
    end
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, btnGO, -1, true)
  end
end
def.method().UpdateListData = function(self)
  self.m_ClickGO = {}
  self.m_ListData = FabaoUtils.GetAllLongJingItems()
end
def.method().UpdataMainView = function(self)
  local uiListGO = self.m_panel:FindDirect("Img_Bg0/Group_Items/Scroll View_Items/List_Items")
  local itemCount = #self.m_ListData
  local listItems = GUIUtils.InitUIList(uiListGO, itemCount)
  self.m_msgHandler:Touch(uiListGO)
  for i = 1, itemCount do
    local itemGO = listItems[i]
    local id = self.m_ListData[i]
    local iconGO = itemGO:FindDirect(("Texture_Icon_%d"):format(i))
    local nameGO = itemGO:FindDirect(("Label_Name_%d"):format(i))
    local itemBase = ItemUtils.GetItemBase(id)
    if not self.m_ClickGO[i] then
      self.m_ClickGO[i] = itemGO
    end
    GUIUtils.SetTexture(iconGO, itemBase.icon)
    GUIUtils.SetText(nameGO, itemBase.name)
  end
end
def.method().Update = function(self)
  self:UpdateListData()
  self:UpdataMainView()
end
return LongJingGetPanel.Commit()
