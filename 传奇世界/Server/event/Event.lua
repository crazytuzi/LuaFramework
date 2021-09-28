--Event.lua
--/*-----------------------------------------------------------------
 --* Module:   Event.lua
 --* Author:   Yang ChangGao
 --* Modified: 2012年10月18日 16:07:08
 --* Purpose:  事件消息的基类.用于定义事件的ID,事件的分组类别,事件源对象
 -------------------------------------------------------------------*/

Event = class()
local prop = Property(Event)
prop:reader("ID") --事件的ID
prop:reader("group") --事件的分组类别
prop:reader("source") --事件源对象
prop:reader("params") --事件参数

--------------------------------------------------------
--Event 初始化
--------------------------------------------------------
function Event:__init(id, group, source, params)
	local this = prop[self]
	this.ID = id
	this.group = group
	this.source = source
	this.params = params
end

--------------------------------------------------------
--Event 注销
--------------------------------------------------------
function Event:__release()
	local this = prop[self]
	this.ID = nil
	this.group = nil
	this.source = nil
	this.params = nil
end

--------------------------------------------------------
--Event 获取参数个数
--------------------------------------------------------
function Event:getParamCount()
	return #(prop[self].params)
end

--------------------------------------------------------
--Event  序列化
--------------------------------------------------------
function Event:writeObject()
	local data={}
	data.ID=string.format("0x%x",toString(self:getID()))
	data.params = self:getParams()
	return data
end

--------------------------------------------------------
--Event  转化成字符串
--------------------------------------------------------
function Event:toString()
	return toString(self:writeObject())
end