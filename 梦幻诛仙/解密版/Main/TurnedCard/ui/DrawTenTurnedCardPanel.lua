local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DrawTenTurnedCardPanel = Lplus.Extend(ECPanelBase, "DrawTenTurnedCardPanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local Vector = require("Types.Vector")
local TurnedCardInterface = require("Main.TurnedCard.TurnedCardInterface")
local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = DrawTenTurnedCardPanel.define
local instance
def.field("table").itemInfoList = nil
def.static("=>", DrawTenTurnedCardPanel).Instance = function()
  if instance == nil then
    instance = DrawTenTurnedCardPanel()
  end
  return instance
end
def.method("table").ShowPanel = function(self, itemInfoList)
  if self:IsShow() then
    return
  end
  self.itemInfoList = itemInfoList
  self:CreatePanel(RESPATH.PREFAB_SHAPESHIFT_TEN_CARD, 0)
  self:SetModal(true)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:setItemList()
  else
  end
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("--------DrawTenTurnedCardPanel onClick:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Conform" then
    self:Hide()
  elseif string.find(id, "Img_BgIcon") then
    local idx = tonumber(string.sub(id, #"Img_BgIcon" + 1))
    if idx then
      local info = self.itemInfoList[idx]
      if info then
        ItemTipsMgr.Instance():ShowBasicTipsWithGO(info.item_cfg_id, clickObj, 0, false)
      end
    end
  elseif id == "Btn_Again" then
    self:Hide()
    gmodule.moduleMgr:GetModule(ModuleId.TURNED_CARD):playEffectAndLottery(10)
  end
end
def.method().setItemList = function(self)
  local Group_Items = self.m_panel:FindDirect("Img_Bg0/Group_Ten/Group_Items")
  local turnedCardInterface = TurnedCardInterface.Instance()
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  for i, v in ipairs(self.itemInfoList) do
    local Img_BgIcon = Group_Items:FindDirect("Img_BgIcon" .. i)
    local Texture_Icon = Img_BgIcon:FindDirect("Texture_Icon")
    local Label_Name = Img_BgIcon:FindDirect("Label_Name")
    local Img_New = Img_BgIcon:FindDirect("Img_New")
    local Img_Tpye = Img_BgIcon:FindDirect("Img_Tpye")
    if Img_BgIcon then
      local itemBase = ItemUtils.GetItemBase(v.item_cfg_id)
      if itemBase then
        local cardItemCfg = TurnedCardUtils.GetChangeModelCardItemCfg(v.item_cfg_id)
        if cardItemCfg then
          Img_New:SetActive(false)
          local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(cardItemCfg.cardCfgId)
          local classCfg = TurnedCardUtils.GetCardClassCfg(cardCfg.classType)
          GUIUtils.FillIcon(Img_Tpye:GetComponent("UITexture"), classCfg.smallIconId)
        else
          Img_Tpye:SetActive(false)
          Img_New:SetActive(false)
        end
        GUIUtils.SetSprite(Img_BgIcon, string.format("Cell_%02d", itemBase.namecolor))
        GUIUtils.FillIcon(Texture_Icon:GetComponent("UITexture"), itemBase.icon)
        local itemColor = HtmlHelper.NameColor[itemBase.namecolor]
        local nameText = string.format("[%s]%s[-]", itemColor, itemBase.name)
        Label_Name:GetComponent("UILabel"):set_text(nameText)
      end
    end
  end
  local Label_Num = self.m_panel:FindDirect("Img_Bg0/Group_Out/Btn_Again/Label_Num")
  Label_Num:GetComponent("UILabel"):set_text(constant.CChangeModelCardConsts.TEN_LOTTERY_COST)
end
DrawTenTurnedCardPanel.Commit()
return DrawTenTurnedCardPanel
