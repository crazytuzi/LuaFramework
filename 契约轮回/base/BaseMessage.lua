-- 
-- @Author: LaoY
-- @Date:   2018-08-02 16:47:41
-- 用protobuf生成的lua table 初始化类
-- 用法是用 cls:create(tab)生成

BaseMessage = BaseMessage or class("BaseMessage",BaseData)
local BaseMessage = BaseMessage
function BaseMessage:ctor()
end

function BaseMessage:dctor()
end

--[[
	@author LaoY
	@des	生成实例，相当于new
	@param1 message  table 初始表
	@return cls  class 生成的实例
--]]
function BaseMessage:create(message,...)
	message = clone(message)
	return self.new(message,...)
end

--[[
	@author LaoY
	@des	用新的表的数据替换（没有会新加）原有数据
			如果需要触发数值改变事件，派生类需要重载并调用父类方法 BaseMessage.ChangeMessage(self,message)
	@param1 message table
--]]
function BaseMessage:ChangeMessage(message,isThorough)
	table.RecursionMerge(self,message,isThorough)
end