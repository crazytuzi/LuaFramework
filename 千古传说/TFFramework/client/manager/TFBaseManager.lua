--[[--
	管理器的基类:

	--By: yun.bo
	--2013/7/8
]]
local TFBaseManager = class('TFBaseManager')

function TFBaseManager:ctor()

end

function TFBaseManager:init()

end

function TFBaseManager:update()

end

function TFBaseManager:reset()

end

--[[--
	Refuse user to modify Manager
]]
TFBaseManager.__newindex = function ( ... )
	print('ERROR[Manager]:Can not modify Manager.')
end

return TFBaseManager