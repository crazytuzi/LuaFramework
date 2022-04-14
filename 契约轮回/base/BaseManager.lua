--
-- Author: LaoY
-- Date: 2018-07-02 10:11:27
--
BaseManager = BaseManager or class("BaseManager")

function BaseManager:ctor()
	local function call_back()
		if self.Reset then
			self:Reset()
		end
	end
	GlobalEvent:AddListener(EventName.GameReset, call_back)
end

function BaseManager:dctor()
end