local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GetNewItem = Lplus.Extend(ECPanelBase, "GetNewItem")
local def = GetNewItem.define
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Vector = require("Types.Vector")
def.const("string").SOUNDEFFECT = RESPATH.SOUND_ITEM
def.const("string").MONEYEFFECT = RESPATH.SOUND_MONEY
def.field("table").queue = nil
def.field("boolean").isPlaying = false
def.field("number").destroyTimer = 0
def.field("boolean").block = false
def.method("number").GetItem = function(self, itemId)
  local itemBase = ItemUtils.GetItemBase(itemId)
  table.insert(self.queue, {
    itemBase.icon
  })
  self:Play()
  local ECSoundMan = require("Sound.ECSoundMan")
  ECSoundMan.Instance():Play2DInterruptSound(GetNewItem.SOUNDEFFECT)
end
def.method("number").GetFabao = function(self, itemId)
  local itemBase = ItemUtils.GetItemBase(itemId)
  table.insert(self.queue, {
    itemBase.icon,
    "Fabao"
  })
  self:Play()
  local ECSoundMan = require("Sound.ECSoundMan")
  ECSoundMan.Instance():Play2DInterruptSound(GetNewItem.SOUNDEFFECT)
end
def.method("number").GetCard = function(self, itemId)
  local itemBase = ItemUtils.GetItemBase(itemId)
  table.insert(self.queue, {
    itemBase.icon,
    "Card"
  })
  self:Play()
  local ECSoundMan = require("Sound.ECSoundMan")
  ECSoundMan.Instance():Play2DInterruptSound(GetNewItem.SOUNDEFFECT)
end
def.method("number").GetMoney = function(self, moneyType)
  local icon = ItemUtils.GetMoneyIcon(moneyType)
  table.insert(self.queue, {icon})
  self:Play()
  local ECSoundMan = require("Sound.ECSoundMan")
  ECSoundMan.Instance():Play2DInterruptSound(GetNewItem.MONEYEFFECT)
end
def.method("number").GetPetMark = function(self, itemId)
  local itemBase = ItemUtils.GetItemBase(itemId)
  table.insert(self.queue, {
    itemBase.icon,
    "PetMark"
  })
  self:Play()
  local ECSoundMan = require("Sound.ECSoundMan")
  ECSoundMan.Instance():Play2DInterruptSound(GetNewItem.SOUNDEFFECT)
end
def.method("boolean").SetVisible = function(self, v)
  if not v then
    self:SetLayer(ClientDef_Layer.Invisible)
  else
    self:SetLayer(ClientDef_Layer.UI)
  end
end
def.method("boolean").Block = function(self, block)
  self.block = block
  if not self.block then
    self:Play()
  end
end
def.override().OnCreate = function(self)
  self:SetDepth(5)
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow then
    self:Play()
  end
end
def.method().Play = function(self)
  if self.block then
    return
  end
  if self.m_panel == nil then
    self:CreatePanel(RESPATH.PREFAB_GETITEM, -1)
  elseif self.isPlaying then
    return
  elseif #self.queue > 0 then
    self.isPlaying = true
    do
      local templateName = self.queue[1][2] or "Item"
      local template = self.m_panel:FindDirect(templateName)
      if template then
        local item = Object.Instantiate(template)
        item.parent = self.m_panel
        item:set_localScale(Vector.Vector3.one)
        local uiTexture = item:GetComponent("UITexture")
        local icon = self.queue[1][1]
        GUIUtils.FillIcon(uiTexture, icon)
        item:SetActive(true)
      end
      GameUtil.AddGlobalTimer(1.3, true, function()
        if templateName == "Item" then
          if PlayerIsInFight() then
            require("Main.Fight.ui.DlgFight").Instance():ShakeBag()
          else
            require("Main.MainUI.ui.MainUIMainMenu").Instance():ShakeBag()
          end
        elseif templateName == "Fabao" then
          require("Main.MainUI.ui.MainUIMainMenu").Instance():ShakeFabao()
        end
      end)
      table.remove(self.queue, 1)
      GameUtil.AddGlobalTimer(0.2, true, function()
        self.isPlaying = false
        self:Play()
      end)
      if self.destroyTimer ~= 0 then
        GameUtil.RemoveGlobalTimer(self.destroyTimer)
        self.destroyTimer = 0
      end
    end
  else
    self.destroyTimer = GameUtil.AddGlobalTimer(5, true, function()
      self:DestroyPanel()
    end)
  end
end
GetNewItem.Commit()
return GetNewItem
