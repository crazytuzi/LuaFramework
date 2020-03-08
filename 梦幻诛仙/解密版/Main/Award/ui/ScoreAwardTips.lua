local Lplus = require("Lplus")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local ECGUIMan = require("GUI.ECGUIMan")
local ECPanelBase = require("GUI.ECPanelBase")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local ScoreAwardTips = Lplus.Extend(ECPanelBase, "ScoreAwardTips")
local def = ScoreAwardTips.define
local instance
def.field("string").title = ""
def.field("number").awardId = 0
def.field("userdata").go = nil
def.static("=>", ScoreAwardTips).Instance = function()
  if instance == nil then
    instance = ScoreAwardTips()
    instance:Init()
  end
  return instance
end
def.method("string", "number", "userdata").ShowAwardTip = function(self, title, awardId, go)
  self.title = title
  self.awardId = awardId
  self.go = go
  if self:IsShow() then
    self:setAwardInfo()
  else
    self:CreatePanel(RESPATH.PREFEB_GIFT_TIPS, 2)
    self:SetOutTouchDisappear()
  end
end
def.method().Init = function(self)
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, b)
  if b then
    self:setAwardInfo()
  else
    self.title = ""
    self.awardId = 0
    self.go = nil
  end
end
def.method().setAwardInfo = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg0")
  local position = self.go.position
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = self.go:GetComponent("UIWidget")
  Img_Bg:set_localPosition(Vector.Vector3.new(screenPos.x - 50, screenPos.y + widget.height * 1.5, 0))
  local Title_Label = Img_Bg:FindDirect("Label")
  Title_Label:GetComponent("UILabel"):set_text(self.title)
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local key = string.format("%d_%d_%d", self.awardId, occupation.ALL, gender.ALL)
  local awardCfg = ItemUtils.GetGiftAwardCfg(key)
  local Grid = Img_Bg:FindDirect("Grid")
  for i = 1, 4 do
    local Img_Item = Grid:FindDirect("Img_Item_" .. i)
    local itemInfo = awardCfg.itemList[i]
    if itemInfo then
      Img_Item:SetActive(true)
      local itemBaseCfg = ItemUtils.GetItemBase(itemInfo.itemId)
      local Item_Icon = Img_Item:FindDirect("Img_ItemIcon1")
      local icon_texture = Item_Icon:GetComponent("UITexture")
      GUIUtils.FillIcon(icon_texture, itemBaseCfg.icon)
    else
      Img_Item:SetActive(false)
    end
  end
end
return ScoreAwardTips.Commit()
