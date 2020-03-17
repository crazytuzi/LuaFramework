--[[
任务断档推荐 base class
2015年6月10日16:52:13
haohu
]]
-------------------------------------------------------------

--主线断档推荐
_G.QuestBreakRecommend = {}

function QuestBreakRecommend:new()
	local obj = setmetatable( {}, {__index = self} )
	return obj
end

function QuestBreakRecommend:Init(param)
	-- override
end

-- 类型
function QuestBreakRecommend:GetType()
	-- override
end

-- 主界面追踪树节点Label
function QuestBreakRecommend:GetLabel()
	-- override
end

-- 执行推荐内容
function QuestBreakRecommend:DoRecommend()
	-- override
end

-- 主界面追踪树节点tips
function QuestBreakRecommend:GetTipsTxt()
	-- override
end

-- 是否可用，判断在主界面追踪树显示
function QuestBreakRecommend:IsAvailable()
	return true
end

function QuestBreakRecommend:ListNotificationInterests()
	return nil;
end

-----------------------------------------final method--------------------------------------------

function QuestBreakRecommend:OnAdded()
	self:RegisterNotification()
end

function QuestBreakRecommend:UpdateView()
	Notifier:sendNotification( NotifyConsts.QuestBreakRecommendChange )
end

function QuestBreakRecommend:Dispose()
	self:UnRegisterNotification()
end

function QuestBreakRecommend:HandleNotification(name, body)
	self:UpdateView()
end

--消息处理
function QuestBreakRecommend:RegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then
		self.notifierCallBack = function(name,body)
			self:HandleNotification(name, body);
		end
	end
	for i,name in pairs(setNotificatioin) do
		Notifier:registerNotification(name, self.notifierCallBack)
	end
end

--取消消息注册
function QuestBreakRecommend:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end


--------------------------------------任务传送接口 -----------begin---------------------------------

-- 是否可传送
function QuestBreakRecommend:CanTeleport()
	return false
end

function QuestBreakRecommend:GetGoalPos()

end

function QuestBreakRecommend:GetTeleportPos()
	return self:GetGoalPos()
end

-- 传送
function QuestBreakRecommend:Teleport(auto)
	if not self:CanTeleport() then return false end
	local point = self:GetTeleportPos()
	if not point then
		Debug("cannot find teleport terminal")
		return false
	end
	if auto then
		-- 判断vip 和 剩余免费次数
		local _, _, freeVip = MapConsts:GetTeleportCostInfo()
		local isVipFree = false
		if freeVip and freeVip == 1 then
			isVipFree = true
		end
		local hasFreeTime = MapModel:GetFreeTeleportTime() > 0
		if (not isVipFree) and (not hasFreeTime) then
			return false
		end
	end
	self:SendTeleportTo( point )
	return true
end

function QuestBreakRecommend:GetTeleportType()
	-- override
end

-- 传送
function QuestBreakRecommend:SendTeleportTo(point)
	local teleportType = self:GetTeleportType()
	local onfoot = function()
		self:DoRecommend()
	end
	MapController:Teleport( teleportType, onfoot, point.mapId, point.x, point.y )
end

-- 传送完成
function QuestBreakRecommend:OnTeleportDone()
	local point = self:GetTeleportPos()
	if not point then return end
	if point.mapId ~= CPlayerMap:GetCurMapID() then
		QuestController:SetSceneChangeCallBack( function()
			self:DoRecommend()
		end )
	else
		self:DoRecommend()
	end
end