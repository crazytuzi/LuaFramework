local Lplus = require("Lplus")
local ConsumeEnergy = Lplus.Class("ConsumeEnergy")
local def = ConsumeEnergy.define
def.field("number").selectedIndex = 1
def.field("table").itemList = function(...)
  return {}
end
def.field("function").onClick = nil
def.field("string").opName = ""
def.field("boolean").produceItem = true
def.field("number").order = 0
def.method("number", "number", "string", "number").AddItem = function(self, iconId, consume, name, level)
  local item = {
    iconId = iconId,
    consume = consume,
    name = name,
    level = level
  }
  table.insert(self.itemList, item)
end
def.method().Call = function(self)
  if self.produceItem then
    local ItemModule = require("Main.Item.ItemModule")
    local bBagFull = ItemModule.Instance():IsBagFull(ItemModule.BAG)
    if bBagFull then
      Toast(textRes.Skill.LivingSkillMakeRes[1])
      return
    end
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local item = self.itemList[self.selectedIndex]
  if item.consume > heroProp.energy then
    Toast(textRes.Hero[26])
  else
    self:OnClick(self.selectedIndex)
  end
end
def.virtual("number").OnClick = function(self, selectedIndex)
end
def.virtual("=>", "boolean").IsUnlock = function(self)
  return false
end
ConsumeEnergy.Commit()
return ConsumeEnergy
