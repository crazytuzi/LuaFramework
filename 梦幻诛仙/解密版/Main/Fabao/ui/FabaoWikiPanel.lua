local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local FabaoMgr = require("Main.Fabao.FabaoMgr")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local EquipModule = require("Main.Equip.EquipModule")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local FabaoWikiPanel = Lplus.Extend(ECPanelBase, "FabaoWikiPanel")
local def = FabaoWikiPanel.define
def.field("table").m_ListData = nil
local instance
def.static("=>", FabaoWikiPanel).Instance = function()
  if not instance then
    instance = FabaoWikiPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_FABAO_WIKI_PANEL, GUILEVEL.DEPENDEND)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:Update()
end
def.override().OnDestroy = function(self)
  self.m_ListData = nil
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  end
end
def.method().UpdateListData = function(self)
  self.m_ListData = FabaoMgr.GetAllCombineData()
end
def.method().UpdataMainView = function(self)
  local uiListGO = self.m_panel:FindDirect("Img _Bg0/Scroll_View/List_Rank")
  local itemCount = #self.m_ListData
  local listItems = GUIUtils.InitUIList(uiListGO, itemCount)
  self.m_msgHandler:Touch(uiListGO)
  for i = 1, itemCount do
    local itemGO = listItems[i]
    local itemData = self.m_ListData[i]
    local label1GO = itemGO:FindDirect(("Label_1_%d"):format(i))
    local label2GO = itemGO:FindDirect(("Label_2_%d"):format(i))
    GUIUtils.SetText(label1GO, itemData.name)
    GUIUtils.SetText(label2GO, itemData.desc)
  end
end
def.method().Update = function(self)
  self:UpdateListData()
  self:UpdataMainView()
end
return FabaoWikiPanel.Commit()
