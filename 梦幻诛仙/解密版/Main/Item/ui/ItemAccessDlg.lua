local Lplus = require("Lplus")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local ECPanelBase = require("GUI.ECPanelBase")
local ItemAccessDlg = Lplus.Extend(ECPanelBase, "ItemAccessDlg")
local def = ItemAccessDlg.define
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
local AccessType = require("consts.mzm.gsp.item.confbean.ItemAccessType")
local MapInterface = require("Main.Map.Interface")
local ActivityInterface = require("Main.activity.ActivityInterface")
local NpcInterface = require("Main.npc.NPCInterface")
local MathHelper = require("Common.MathHelper")
def.static("table", "table").ShowItemSource = function(source, position)
  local itemAccessDlg = ItemAccessDlg()
  itemAccessDlg.source = source
  itemAccessDlg.position = position
  itemAccessDlg.itemidsCache = {}
  itemAccessDlg:CreatePanel(RESPATH.PREFAB_ITEMACCESS_PAENL, 2)
  itemAccessDlg:SetOutTouchDisappear()
end
def.field("table").source = nil
def.field("table").position = nil
def.field("table").itemidsCache = nil
def.override().OnCreate = function(self)
  self:UpdateInfo()
  self:UpdatePosition()
end
def.method().UpdateInfo = function(self)
  local grid = self.m_panel:FindDirect("Img_Bg/Scroll View_Item/Grid_Item")
  local template = grid:FindDirect("Item_001")
  template:SetActive(false)
  for k, v in pairs(self.source) do
    local itemNew = Object.Instantiate(template)
    itemNew:set_name("Item_" .. k)
    itemNew.parent = grid
    itemNew:set_localScale(Vector.Vector3.one)
    self:SetItem(itemNew, v)
  end
  local uiGrid = grid:GetComponent("UIGrid")
  uiGrid:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().UpdatePosition = function(self)
  local bg = self.m_panel:FindDirect("Img_Bg"):GetComponent("UISprite")
  local x, y = MathHelper.ComputeTipsAutoPosition(self.position.sourceX, self.position.sourceY, self.position.sourceW, self.position.sourceH, bg:get_width(), bg:get_height(), self.position.prefer)
  self.m_panel:FindDirect("Img_Bg"):set_localPosition(Vector.Vector3.new(x, y, 0))
end
def.method("userdata", "table").SetItem = function(self, item, source)
  item:SetActive(true)
  local icon = self:GetSourceIcon(source.type)
  local uiTexture = item:FindDirect("Img_Icon"):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, icon)
  local box = item:FindDirect("Img_Bg")
  local nameLabel = item:FindDirect("Label_Name1"):GetComponent("UILabel")
  table.insert(self.itemidsCache, source.itemIds)
  if source.type == AccessType.MAP then
    box.name = "MAP_" .. source.id
    local mapcfg = MapInterface.GetMapCfg(source.id)
    local mapName = mapcfg.mapName
    nameLabel:set_text(mapName)
  elseif source.type == AccessType.ACTIVITY then
    box.name = "ACTIVITY_" .. source.id
    local actCfg = ActivityInterface.GetActivityCfgById(source.id)
    local actName = actCfg.activityName
    nameLabel:set_text(actName)
  elseif source.type == AccessType.NPC_SHOP then
    box.name = "NPCSHOP_" .. source.id .. "_" .. source.service
    box.name = box.name .. "_" .. #self.itemidsCache
    local npcCfg = NpcInterface.GetNPCCfg(source.id)
    local mapCfg = require("Main.Map.MapUtility").GetMapCfg(npcCfg.mapId)
    local npcName = string.format("%s%s", mapCfg.mapName, npcCfg.npcTitle)
    nameLabel:set_text(npcName)
  elseif source.type == AccessType.SHANGHUI_BIGTYPE then
    box.name = "MARKET_" .. source.id
    box.name = box.name .. "_" .. #self.itemidsCache
    nameLabel:set_text(textRes.Item[8117])
  elseif source.type == AccessType.SHANGHUI_SUBTYPE then
    box.name = "MARKETSUB_" .. source.id
    box.name = box.name .. "_" .. #self.itemidsCache
    nameLabel:set_text(textRes.Item[8117])
  elseif source.type == AccessType.BAITANG_BIG then
    box.name = "BAITANG_" .. source.id
    box.name = box.name .. "_" .. #self.itemidsCache
    nameLabel:set_text(textRes.Item[8113])
  elseif source.type == AccessType.BAITANG_SUB then
    box.name = "BAITANGSUB_" .. source.id
    box.name = box.name .. "_" .. #self.itemidsCache
    nameLabel:set_text(textRes.Item[8113])
  elseif source.type == AccessType.MALL then
    box.name = "MALL_" .. source.id
    box.name = box.name .. "_" .. #self.itemidsCache
    nameLabel:set_text(textRes.Item[8123])
  elseif source.type == AccessType.JIFEN then
    box.name = "JIFEN_" .. source.id
    nameLabel:set_text(textRes.Item[8124])
  elseif source.type == AccessType.LIFESKILL then
    box.name = "LIFESKILL_" .. source.id
    nameLabel:set_text(textRes.Item[8125])
  elseif source.type == AccessType.GAGN_DRUG_SHOP then
    warn("\229\184\174\230\180\190\232\141\175\229\186\151")
    box.name = "GANGDRUG_"
    nameLabel:set_text(textRes.Item[8129])
  elseif source.type == AccessType.BAOTU then
    box.name = "BAOTU_" .. source.id
    local baotuBase = ItemUtils.GetItemBase(source.id)
    local name = baotuBase and baotuBase.name or textRes.Item[8130]
    nameLabel:set_text(name)
    GUIUtils.FillIcon(uiTexture, baotuBase.icon)
  elseif source.type == AccessType.VITALITY_EXCHANGE then
    box.name = "HUOYUE_"
    nameLabel:set_text(textRes.Item[210])
  elseif source.type == AccessType.FURNITURE_SHOP then
    box.name = "FURNITURESHOP_" .. #self.itemidsCache
    nameLabel:set_text(textRes.Homeland[67])
  elseif source.type == AccessType.CHANGE_MODEL_CARD_LOTTERY then
    box.name = "TURNEDCARDLOTTERY_"
    nameLabel:set_text(textRes.TurnedCard[29])
  end
end
def.method("number", "=>", "number").GetSourceIcon = function(self, sourceType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ITEMSOURCE_CFG, sourceType)
  local icon = record:GetIntValue("icon")
  return icon
end
def.method("string").onClick = function(self, id)
  if string.find(id, "MAP_") then
    if PlayerIsInFight() then
      Toast(textRes.Item[104])
      return
    end
    local str = string.sub(id, 5)
    local id = tonumber(str)
    local OnHookModule = require("Main.OnHook.OnHookModule")
    OnHookModule.EnterOneMapToOnHook(mapId)
  elseif string.find(id, "ACTIVITY_") then
    if PlayerIsInFight() then
      Toast(textRes.Item[104])
      return
    end
    local str = string.sub(id, 10)
    local id = tonumber(str)
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, {id})
  elseif string.find(id, "NPCSHOP_") then
    if PlayerIsInFight() then
      Toast(textRes.Item[104])
      return
    end
    local strTbl = string.split(id, "_")
    local npcId = tonumber(strTbl[2])
    local serviceId = tonumber(strTbl[3])
    local itemIds = self.itemidsCache[tonumber(strTbl[4])] or {}
    local itemId = itemIds[1]
    ECGUIMan.Instance():DestroyUIAtLevel(1)
    Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.GO_TO_NPC_SHOP_BUY_ITEM, {
      serviceId,
      npcId,
      itemId
    })
  elseif string.find(id, "MARKET_") then
    local strTbl = string.split(id, "_")
    local id = tonumber(strTbl[2])
    local itemIds = self.itemidsCache[tonumber(strTbl[3])] or {}
    local itemId = itemIds[1]
    local CommercePitchModule = require("Main.CommerceAndPitch.CommercePitchModule")
    CommercePitchModule.Instance():CommerceBuyItemByBigGroup(id, itemId)
  elseif string.find(id, "MARKETSUB_") then
    local strTbl = string.split(id, "_")
    local id = tonumber(strTbl[2])
    local itemIds = self.itemidsCache[tonumber(strTbl[3])] or {}
    local itemId = itemIds[1]
    local CommercePitchModule = require("Main.CommerceAndPitch.CommercePitchModule")
    CommercePitchModule.Instance():CommerceBuyItemBySmallGroup(id, itemId)
  elseif string.find(id, "BAITANG_") then
    local strTbl = string.split(id, "_")
    local id = tonumber(strTbl[2])
    local itemIds = self.itemidsCache[tonumber(strTbl[3])] or {}
    local itemId = itemIds[1]
    local CommercePitchModule = require("Main.CommerceAndPitch.CommercePitchModule")
    CommercePitchModule.Instance():PitchBuyItemBigGroupWithIdList(id, itemIds)
  elseif string.find(id, "BAITANGSUB_") then
    local strTbl = string.split(id, "_")
    local id = tonumber(strTbl[2])
    local itemIds = self.itemidsCache[tonumber(strTbl[3])] or {}
    local itemId = itemIds[1]
    local CommercePitchModule = require("Main.CommerceAndPitch.CommercePitchModule")
    CommercePitchModule.Instance():PitchBuyItemSmallGroupWithIdList(id, itemIds)
  elseif string.find(id, "MALL_") then
    local strTbl = string.split(id, "_")
    local id = tonumber(strTbl[2])
    local itemIds = self.itemidsCache[tonumber(strTbl[3])] or {}
    local itemId = itemIds[1]
    local MallPanel = require("Main.Mall.ui.MallPanel")
    local MallUtility = require("Main.Mall.MallUtility")
    local pageType = MallUtility.GetPageTypeByMallType(id)
    if pageType ~= 0 then
      require("Main.Mall.MallModule").RequireToShowMallPanel(pageType, itemId, id)
    end
  elseif string.find(id, "JIFEN_") then
    local str = string.sub(id, 7)
    local id = tonumber(str)
    Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.CREDITS_SHOP, {id})
  elseif string.find(id, "LIFESKILL_") then
    local str = string.sub(id, 11)
    local id = tonumber(str)
    Event.DispatchEvent(ModuleId.SKILL, gmodule.notifyId.Skill.LIVING_SKILL_ACCESS, {id})
  elseif string.find(id, "GANGDRUG_") then
    local gangId = require("Main.Gang.GangModule").Instance().data:GetGangId()
    if not gangId then
      Toast(textRes.Item[209])
      return
    end
    require("Main.Gang.ui.GangDrugShopPanel").ShowGangDrugPanel()
  elseif string.find(id, "HUOYUE_") then
    local ActivityModule = require("Main.activity.ActivityModule")
    ActivityModule.Instance():jumpActivity()
  elseif string.find(id, "BAOTU_") then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, {
      constant.BaoTuActivityCfgConsts.BAOTU_ACTIVITY_ID
    })
  elseif string.find(id, "BAOTUSUPER_") then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, {
      constant.BaoTuActivityCfgConsts.BAOTU_ACTIVITY_ID
    })
  elseif string.find(id, "FURNITURESHOP_") then
    local strTbl = string.split(id, "_")
    local itemIds = self.itemidsCache[tonumber(strTbl[2])] or {}
    local itemId = itemIds[1] or 0
    require("Main.Homeland.ui.FurnitureShopPanel").ShowPanelWithItemId(itemId)
  elseif string.find(id, "TURNEDCARDLOTTERY_") then
    local DrawTurnedCardPanel = require("Main.TurnedCard.ui.DrawTurnedCardPanel")
    DrawTurnedCardPanel.Instance():ShowPanel()
  end
  self:DestroyPanel()
  self = nil
end
ItemAccessDlg.Commit()
return ItemAccessDlg
