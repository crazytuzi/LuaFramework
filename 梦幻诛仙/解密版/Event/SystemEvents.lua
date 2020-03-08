local Lplus = require("Lplus")
local UnityLogEvent = Lplus.Class("SystemEvents.UnityLogEvent")
UnityLogEvent.define.const("table").LogType = {
  Error = 0,
  Assert = 1,
  Warning = 2,
  Log = 3,
  Exception = 4
}
UnityLogEvent.define.field("number").logType = 0
UnityLogEvent.define.field("string").str = ""
UnityLogEvent.Commit()
return {UnityLogEvent = UnityLogEvent}
