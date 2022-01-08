--
-- Author: david.dai
-- Date: 2014-07-09 15:28:29
--

local RedPointManager = class("RedPointManager")

function RedPointManager:ctor()
	self:RegisterEvents()
	self:restart()
end

function RedPointManager:restart()
	self.stateList = {}
	self.updateList = {}
	TFDirector:removeTimer(self.nTimerId)
    self.nTimerId = nil
    self:createAutoFlushTimer()
end

function RedPointManager:RegisterEvents()
	TFDirector:addProto(s2c.ALL_FUNCTION_STATE, self, self.receiveAllFunctionsState)
end

function RedPointManager:receiveAllFunctionsState(event)
	--print("receiveAllFunctionsState : ", event.data)
	if not event.data.stateList then
		self.stateList = {}
		return
	end

	self.stateList = event.data.stateList
end

function RedPointManager:isRedPointEnabled(type)
	if not self.stateList then
		return
	end

	for i=1,#self.stateList do
		local funcState = self.stateList[i]
		if funcState and funcState.functionId == type then
			return funcState.newMark
		end
	end
	return false
end

 function RedPointManager:setRedPointEnabled(type,enabled)
 	--print("RedPointManager:setRedPointEnabled(type,enabled) : ",type,enabled)
 	assert(type ~= nil)
 	if not self.stateList then
		self.stateList = {}
	end

	local length = #self.stateList
	local exist = nil
	for i=1,length do
		local funcState = self.stateList[i]
		if funcState and funcState.functionId == type then
			funcState.newMark = enabled
			exist = funcState
			break;
		end
	end
	
	if not exist then
		exist = {functionId = type,newMark = enabled}
		self.stateList[length + 1] = exist
	end

	if self.updateList and #self.updateList then
		for i = 1,#self.updateList do
			local element = self.updateList[i]
			if element[1] == type then
				element[2] = enabled
				return
			end
		end
	end

	self.updateList = self.updateList or {}
	local element = {}
	element[1] = type
	element[2] = enabled
	self.updateList[#self.updateList + 1] = element
end

function RedPointManager:flushToServer()
	if self.updateList and #self.updateList > 0 then
		--print("flushToServer() : ",self.updateList)
		local msg = {
			self.updateList
		}
		TFDirector:send(c2s.REQUEST_SET_FUNC_STATE ,msg)
		self.updateList = {}
	end
end

function RedPointManager:createAutoFlushTimer()
	if not self.nTimerId then
        self.nTimerId = TFDirector:addTimer(60000, -1, nil, function(event)
        	--print("RedPointManager:flushTimer : ")
			self:flushToServer()
		end, "autoFlushRedPointStateTimer"); 
    end
end

return RedPointManager:new()