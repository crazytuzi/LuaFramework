--
-- Author: Stephen
-- Date: 2015-09-02 17:09:29
--

local NiuBilityManager = class("NiuBilityManager")

NiuBilityManager.PRAISE_SUCCESS = "NiuBilityManager.PRAISE_SUCCESS"
function NiuBilityManager:ctor()
	self.niuBilityList = TFArray:new()
	self:restart()
	self:registerEvents()
end

function NiuBilityManager:restart()
	self.totalCount = 0;							--总使用次数
	self.todayCount = 0;							--今日使用次数
	local configure = PlayerResConfigure:objectByID(8)
	if configure == nil then
		print("排行榜点赞 找不到配置  ")
	end
	self.remaining = configure.max;					--今日剩余使用次数
	self.niuBilityList:clear()
end

function NiuBilityManager:registerEvents()
	TFDirector:addProto(s2c.MY_PRAISE_INFO , self, self.myPraiseInfoMsgHandle)
	TFDirector:addProto(s2c.PRAISE_SUCCESS, self, self.praiseSuccessMsgHandle)
end

--获取点赞的次数及列表
function NiuBilityManager:myPraiseInfoMsgHandle(event)
	local data = event.data
	self.totalCount = data.totalCount
	self.todayCount = data.todayCount
	self.remaining = data.remaining
	if data.targetId ~= nil then
		for i=1,#data.targetId do
			self.niuBilityList:push(data.targetId[i])
		end
	end
end

-- 点赞回调
function NiuBilityManager:praiseSuccessMsgHandle(event)
	hideAllLoading()
	-- self.totalCount = self.totalCount + 1
	-- self.todayCount = self.todayCount + 1
	-- self.remaining = self.remaining - 1
	--print("praiseSuccessMsgHandle = "..self.remaining)
	--self.niuBilityList:push(event.data.targetId)
	TFDirector:dispatchGlobalEventWith(NiuBilityManager.PRAISE_SUCCESS,{event.data.targetId})
end
-- 是否可以赞某人
function NiuBilityManager:isCanPraise( playerId )
	if self.niuBilityList:indexOf(playerId) == -1 then
		return true
	end
	return false
end
--对某人点赞
function NiuBilityManager:praisePerson(playerId )
	if self:isCanPraise(playerId) then
		TFDirector:send(c2s.REQUEST_PRAISE , {playerId})
		showLoading();
		return
	end
	-- toastMessage("你已经赞过他了");
	toastMessage(localizable.NiuBilityManager_dianzan)
end
return NiuBilityManager:new()