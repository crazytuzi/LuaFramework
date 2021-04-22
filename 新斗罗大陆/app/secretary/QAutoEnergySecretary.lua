-- @Author: xurui
-- @Date:   2019-08-07 14:53:58
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-08-07 15:21:47
local QBaseSecretary = import(".QBaseSecretary")
local QAutoEnergySecretary = class("QAutoEnergySecretary", QBaseSecretary)

function QAutoEnergySecretary:ctor(options)
	QAutoEnergySecretary.super.ctor(self, options)
end

return QAutoEnergySecretary