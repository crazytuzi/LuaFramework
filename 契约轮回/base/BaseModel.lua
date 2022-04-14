--
-- Author: LaoY
-- Date: 2018-06-29 21:23:16
-- model基类 数据处理

BaseModel = BaseModel or class("BaseModel",BaseData)

function BaseModel:ctor()
	self:Clear()

	local function call_back()
		if self.Reset then
			self:Reset()
		end
	end
	GlobalEvent:AddListener(EventName.GameReset, call_back)
end

function BaseModel:dctor()
	
end

function BaseModel:Clear()

end