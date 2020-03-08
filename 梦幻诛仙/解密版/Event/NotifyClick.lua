local Lplus = require("Lplus")
local ECPanelBase = Lplus.ForwardDeclare("ECPanelBase")
local NotifyClick = Lplus.Class("NotifyClick")
local def = NotifyClick.define
def.field("string").who = ""
def.field(ECPanelBase).panel = nil
def.field("string").id = ""
def.method("string", "=>", "boolean").isPanelName = function(self, panelName)
  return self.who == panelName and true or false
end
def.method("userdata", "=>", "boolean").isPanelNameEx = function(self, panel)
  return panel and not panel.isnil and self.who == panel.name and true or false
end
def.method("string", "=>", "boolean").isObjID = function(self, id)
  return self.id == id and false
end
def.method("userdata", "=>", "boolean").isObjIDEx = function(self, obj)
  return obj and not obj.isnil and self.id == obj.name and false
end
def.method("=>", "string").info = function(self)
  local str = ""
  str = str .. "onclick panel:" .. self.who
  str = str .. ",id:" .. self.id
  if self.panel then
    str = str .. "," .. tostring(self.panel)
  end
  return str
end
NotifyClick.Commit()
return NotifyClick
