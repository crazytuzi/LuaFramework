local Lplus = require("Lplus")
local TurnedCard = Lplus.Class("TurnedCard")
local def = TurnedCard.define
def.field("table").cardInfo = nil
def.field("userdata").uuid = nil
def.static("table", "=>", TurnedCard).New = function(cardInfo)
  local instance = TurnedCard()
  instance.cardInfo = cardInfo
  return instance
end
def.method("userdata").setUUID = function(self, uuid)
  self.uuid = uuid
end
def.method("=>", "userdata").getUUID = function(self)
  return self.uuid
end
def.method("=>", "table").getCardInfo = function(self)
  return self.cardInfo
end
def.method("=>", "number").getCardCfgId = function(self)
  if self.cardInfo then
    return self.cardInfo.card_cfg_id
  end
  return 0
end
def.method("number").setCardLevel = function(self, level)
  if self.cardInfo then
    self.cardInfo.level = level
  end
end
def.method("=>", "number").getCardLevel = function(self)
  if self.cardInfo then
    return self.cardInfo.level
  else
    warn("!!!!!!!getCardLevel cardInfo is nil")
  end
  return 1
end
def.method("number").setCardUseCount = function(self, count)
  if self.cardInfo then
    self.cardInfo.use_count = count
  end
end
def.method("=>", "number").getCardUseCount = function(self)
  if self.cardInfo then
    return self.cardInfo.use_count
  end
  return 0
end
def.method("number").setExp = function(self, exp)
  if self.cardInfo then
    self.cardInfo.exp = exp
  end
end
def.method("=>", "number").getExp = function(self)
  if self.cardInfo then
    return self.cardInfo.exp
  end
  return 0
end
return TurnedCard.Commit()
