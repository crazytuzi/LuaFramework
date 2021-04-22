-- @Author: xurui
-- @Date:   2019-08-07 15:47:31
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-08-07 15:48:57
local QBaseSecretary = import(".QBaseSecretary")
local QEliteThunderSecretary = class("QEliteThunderSecretary", QBaseSecretary)

function QEliteThunderSecretary:ctor(options)
	QEliteThunderSecretary.super.ctor(self, options)
end

return QEliteThunderSecretary
