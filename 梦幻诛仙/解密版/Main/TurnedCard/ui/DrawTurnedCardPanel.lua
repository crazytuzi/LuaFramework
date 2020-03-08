local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DrawTurnedCardPanel = Lplus.Extend(ECPanelBase, "DrawTurnedCardPanel")
local ItemData = require("Main.Item.ItemData")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local Vector = require("Types.Vector")
local TurnedCardInterface = require("Main.TurnedCard.TurnedCardInterface")
local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local FilterTypeEnum = require("consts.mzm.gsp.changemodelcard.confbean.FilterTypeEnum")
local def = DrawTurnedCardPanel.define
local instance
def.static("=>", DrawTurnedCardPanel).Instance = function()
  if instance == nil then
    instance = DrawTurnedCardPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_SHAPESHIFT_CARD, 1)
  self:SetModal(true)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:setScoreInfo()
  else
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, DrawTurnedCardPanel.OnCreditChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, DrawTurnedCardPanel.OnCreditChange)
end
def.static("table", "table").OnCreditChange = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setScoreInfo()
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("--------DrawTurnedCardPanel onClick:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:Hide()
  elseif id == "Btn_One" then
    gmodule.moduleMgr:GetModule(ModuleId.TURNED_CARD):playEffectAndLottery(1)
  elseif id == "Btn_Ten" then
    gmodule.moduleMgr:GetModule(ModuleId.TURNED_CARD):playEffectAndLottery(10)
  elseif id == "Btn_AddJing" then
    local itemFilterCfg = TurnedCardUtils.GetChangeModelCardItemFilterCfg(FilterTypeEnum.CARD_SCORE_ITEM)
    if itemFilterCfg then
      do
        local ItemModule = require("Main.Item.ItemModule")
        local itemModule = ItemModule.Instance()
        local ids = {}
        for i, v in ipairs(itemFilterCfg.itemCfgIds) do
          ids[v] = v
        end
        local function filterFunc(item)
          if ids[item.id] then
            return true
          end
          return false
        end
        local itemList = {}
        local items = itemModule:GetItemsByItemIds(ItemModule.BAG, ids)
        for i, v in pairs(items) do
          table.insert(itemList, v)
        end
        if #itemList > 0 then
          local CommonUsePanel = require("GUI.CommonUsePanel")
          CommonUsePanel.Instance():ShowPanelWithItems(filterFunc, nil, CommonUsePanel.Source.Bag, itemList, nil)
          return
        end
      end
    end
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(constant.CChangeModelCardConsts.SCORE_SOURCE_ITEM_CFG_ID, clickObj, 0, true)
  end
end
def.method().setScoreInfo = function(self)
  local scoreNum = ItemModule.Instance():GetCredits(TokenType.CHANGE_MODEL_CARD_SCORE) or Int64.new(0)
  local Label_Num = self.m_panel:FindDirect("Img_Bg/Group_Ji/Label_Num")
  Label_Num:GetComponent("UILabel"):set_text(tostring(scoreNum))
  local Label_Cost1 = self.m_panel:FindDirect("Img_Bg/Group_Cost_1/Label_Num")
  Label_Cost1:GetComponent("UILabel"):set_text(constant.CChangeModelCardConsts.LOTTERY_COST)
  local Label_Cost10 = self.m_panel:FindDirect("Img_Bg/Group_Cost_10/Label_Num")
  Label_Cost10:GetComponent("UILabel"):set_text(constant.CChangeModelCardConsts.TEN_LOTTERY_COST)
end
def.method("number").playEffectAndLottery = function(self, num)
  local effres = _G.GetEffectRes(constant.CChangeModelCardConsts.LOTTERY_EFFECT_ID)
  if effres then
    require("Fx.GUIFxMan").Instance():Play(effres.path, "lotteryEffect", 0, 0, 3, false)
  else
    warn("!!!!!!!!!invalid effectId:", constant.CChangeModelCardConsts.LOTTERY_EFFECT_ID)
  end
  GameUtil.AddGlobalLateTimer(3, true, function()
    local p = require("netio.protocol.mzm.gsp.changemodelcard.CCardLotteryDrawReq").new(num)
    if num == 1 then
      local DrawOneTurnedCardPanel = require("Main.TurnedCard.ui.DrawOneTurnedCardPanel")
      DrawOneTurnedCardPanel.Instance():ShowPanel({item_cfg_id = 210108020, count = 1})
    elseif num == 10 then
      local list = {}
      for i = 1, 10 do
        local t = {item_cfg_id = 210108021, count = 1}
        table.insert(list, t)
      end
      local DrawTenTurnedCardPanel = require("Main.TurnedCard.ui.DrawTenTurnedCardPanel")
      DrawTenTurnedCardPanel.Instance():ShowPanel(list)
    end
  end)
end
DrawTurnedCardPanel.Commit()
return DrawTurnedCardPanel
