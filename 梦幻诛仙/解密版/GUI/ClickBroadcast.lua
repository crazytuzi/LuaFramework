local Lplus = require("Lplus")
local NotifyClick = require("Event.NotifyClick")
local ClickBroadcast = Lplus.Class("GUI.ClickBroadcast")
do
  local l_noBroadcastList = {panel_guide = true}
  local def = ClickBroadcast.define
  def.static(NotifyClick, "=>", "boolean").CanBroadcast = function(event)
    return not l_noBroadcastList[event.who]
  end
end
ClickBroadcast.Commit()
return ClickBroadcast
