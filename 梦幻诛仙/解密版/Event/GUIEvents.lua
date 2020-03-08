local Lplus = require("Lplus")
local ECPanelBase = Lplus.ForwardDeclare("ECPanelBase")
local CreatePanelEvent = Lplus.Class("GUIEvents.CreatePanelEvent")
do
  local def = CreatePanelEvent.define
  def.field("string").name = ""
  def.field(ECPanelBase).panel = nil
  def.static("string", ECPanelBase, "=>", CreatePanelEvent).new = function(name, panel)
    local obj = CreatePanelEvent()
    obj.name = name
    obj.panel = panel
    return obj
  end
end
CreatePanelEvent.Commit()
local PreCreatePanelEvent = Lplus.Class("GUIEvents.PreCreatePanelEvent")
do
  local def = PreCreatePanelEvent.define
  def.field("string").name = ""
  def.field(ECPanelBase).panel = nil
  def.static("string", ECPanelBase, "=>", PreCreatePanelEvent).new = function(name, panel)
    local obj = PreCreatePanelEvent()
    obj.name = name
    obj.panel = panel
    return obj
  end
end
PreCreatePanelEvent.Commit()
local DestroyPanelEvent = Lplus.Class("GUIEvents.DestroyPanelEvent")
do
  local def = DestroyPanelEvent.define
  def.field("string").name = ""
  def.field(ECPanelBase).panel = nil
  def.static("string", ECPanelBase, "=>", DestroyPanelEvent).new = function(name, panel)
    local obj = DestroyPanelEvent()
    obj.name = name
    obj.panel = panel
    return obj
  end
end
DestroyPanelEvent.Commit()
local GUIEvents = {
  CreatePanelEvent = CreatePanelEvent,
  PreCreatePanelEvent = PreCreatePanelEvent,
  DestroyPanelEvent = DestroyPanelEvent
}
return GUIEvents
