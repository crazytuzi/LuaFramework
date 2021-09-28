DCEvent = { };

--[[用户登陆前自定义事件接口，用户登陆后调用无效
	eventId:事件ID，String类型
	map:事件属性字典，table类型（键值对）
	duration:事件时长
]]
function DCEvent.onEventBeforeLogin(eventId, map, duration)
	if i3k_game_data_eye_valid() then
		DCLuaEvent:onEventBeforeLogin(eventId, map, duration);
	end
end

--[[高频自定义事件接口
	eventId:事件ID，String类型
]]
function DCEvent.onEventCount(eventId, count)
	if i3k_game_data_eye_valid() then
		DCLuaEvent:onEventCount(eventId, count);
	end
end

--[[自定义事件接口，有一个参数、两个参数、三个参数等情形
	一个参数：eventId
	二个参数：eventId, label或者map
	eventID:事件ID String类型
	label:事件发生时的一个属性值，String类型
	map:事件发生时的多个属性值，table类型 key-value String键值对
]]
function DCEvent.onEvent(...)
	if i3k_game_data_eye_valid() then
		DCLuaEvent:onEvent(...);
	end
end

--[[自定义时长事件接口，有二参数，三参数等情形
	二参数：eventId, duration
	三参数：eventId, label或者map duration
	eventID:事件ID String类型
	label:事件发生时的一个属性值，String类型
	map:事件发生时的多个属性值，table类型 key-value String键值对
	duration:事件发生时长
]]
function DCEvent.onEventDuration(...)
	if i3k_game_data_eye_valid() then
		DCLuaEvent:onEventDuration(...);
	end
end

--[[自定义事件开始，有一参数，二参数，三参数三种情形，需要配合对应的onEventEnd使用
	一参数：eventId
	二参数：eventId, map
	三参数：eventId, map, flag
	eventId:事件ID String类型
	map:事件发生时的多个属性值，table类型 key-value String键值对
	flag:与eventId配合使用，共同标识一个事件，此参数不会上报
]]
function DCEvent.onEventBegin(...)
	if i3k_game_data_eye_valid() then
		DCLuaEvent:onEventBegin(...);
	end
end

--[[自定义事件结束，有一参数，二参数等情形，需要与onEventBegin配合使用
	一参数：eventId
	二参数：eventId,flag
	eventId:事件ID String类型
	flag:与eventId配合使用，共同标识一个事件，此参数不会上报
]]
function DCEvent.onEventEnd(...)
	if i3k_game_data_eye_valid() then
		DCLuaEvent:onEventEnd(...);
	end
end

return DCEvent;
