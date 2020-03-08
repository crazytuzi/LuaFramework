local Lplus = require("Lplus")
local PetBaseProp = Lplus.Class("PetBaseProp")
local def = PetBaseProp.define
def.field("number").str = 0
def.field("number").dex = 0
def.field("number").con = 0
def.field("number").sta = 0
def.field("number").spi = 0
def.method("table").RawSet = function(self, data)
  local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
  self.str = data[PropertyType.STR] or 0
  self.dex = data[PropertyType.DEX] or 0
  self.con = data[PropertyType.CON] or 0
  self.sta = data[PropertyType.STA] or 0
  self.spi = data[PropertyType.SPR] or 0
end
def.method(PetBaseProp).Add = function(self, oprand)
  if oprand == nil then
    return
  end
  self.str = self.str + oprand.str
  self.dex = self.dex + oprand.dex
  self.con = self.con + oprand.con
  self.sta = self.sta + oprand.sta
  self.spi = self.spi + oprand.spi
end
def.method(PetBaseProp).Sub = function(self, oprand)
  if oprand == nil then
    return
  end
  self.str = self.str - oprand.str
  self.dex = self.dex - oprand.dex
  self.con = self.con - oprand.con
  self.sta = self.sta - oprand.sta
  self.spi = self.spi - oprand.spi
end
PetBaseProp.Commit()
return PetBaseProp
