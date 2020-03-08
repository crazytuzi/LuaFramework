local Lplus = require("Lplus")
local EnterGameStageEvent = Lplus.Class("GUIManEvents.EnterGameStageEvent").Commit()
local LeaveGameStageEvent = Lplus.Class("GUIManEvents.LeaveGameStageEvent").Commit()
return {EnterGameStageEvent = EnterGameStageEvent, LeaveGameStageEvent = LeaveGameStageEvent}
