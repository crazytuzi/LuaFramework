--LogSetting.lua


local LogSetting = {}


LogSetting.TAG = {
	CROSS_PVP 		= "cross_pvp",
	CHAT 			= "chat",
}

LogSetting.initDebugSetting = function ( ... )
	-- for example 
	-- DebugHelper.setDefaultTag(LogSetting.TAG.CROSS_PVP) or 
	-- DebugHelper.setDefaultTag({LogSetting.TAG.CROSS_PVP, LogSetting.TAG.CHAT})
	DebugHelper.setDefaultTag(LogSetting.TAG.CROSS_PVP)
end

function __Dump( tag, cls, ... )
  local tagName = tag
  if type(tagName) ~= "string" then
    tagName = DebugHelper._defaultTag
  end

  local validTag = false
  for i, value in pairs(DebugHelper._tagTable) do 
    if value == tagName then 
      validTag = true
      break
    end
  end

  if not validTag then 
    return 
  end 

  dump(cls, ...)
end

return LogSetting

