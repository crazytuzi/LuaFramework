local ClickBroadcast = require("GUI.ClickBroadcast")
local EventTable = {}
local function onClickEvent(sender, id, param1, param2, param3)
  local ECGame = require("Main.ECGame")
  local NotifyClick = require("Event.NotifyClick")
  local event = NotifyClick()
  if sender.m_panel and not sender.m_panel.isnil then
    event.who = sender.m_panel.name
  end
  event.panel = sender
  event.id = id
  if ClickBroadcast.CanBroadcast(event) then
    ECGame.EventManager:raiseEvent(nil, event)
  end
end
EventTable.onClick = onClickEvent
local function onClickEvent2(sender, id, param1, param2, param3)
  local ECGame = require("Main.ECGame")
  local NotifyClick = require("Event.NotifyClick")
  local event = NotifyClick()
  if sender.m_panel and not sender.m_panel.isnil then
    event.who = sender.m_panel.name
  end
  event.panel = sender
  event.id = id.name
  if ClickBroadcast.CanBroadcast(event) then
    ECGame.EventManager:raiseEvent(nil, event)
  end
end
EventTable.onClickObj = onClickEvent2
local onPressEvent = function(sender, id, param1, param2, param3)
end
EventTable.onPress = onPressEvent
local onPressEvent2 = function(sender, id, param1, param2, param3)
end
EventTable.onPressObj = onPressEvent2
local function onScrollEvent(sender, id, param1, param2, param3)
  onClickEvent(sender, id, param1, param2, param3)
end
EventTable.onScroll = onScrollEvent
local function onDragEvent(sender, id, param1, param2, param3)
  onClickEvent(sender, id, param1, param2, param3)
end
EventTable.onDrag = onDragEvent
return EventTable
