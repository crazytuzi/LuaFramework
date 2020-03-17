--[[灵兽model
liyuan
2014年9月28日10:33:06
]]

_G.SpiritsModel = Module:new();

SpiritsModel.isAutoLevelUp = false
SpiritsModel.isAutoBuy = false

SpiritsModel.currentWuhun = nil
--属性丹喂养数量
SpiritsModel.pillNum = 0;
--当前使用武魂id
SpiritsModel.selectedWuhunId = 0;

-- 获取武魂等级
function SpiritsModel:GetLevel()
	if not self.currentWuhun then
		return 0
	end

	if t_wuhun[self.currentWuhun.wuhunId] then
		return t_wuhun[self.currentWuhun.wuhunId].order
	end

	return 0
end


local lingshouMaxLvl
function SpiritsModel:GetMaxLevel()
	local maxLvl = 0
	if not lingshouMaxLvl then
		for level, cfg in pairs( _G.t_wuhun ) do
			maxLvl = math.max( cfg.order, maxLvl )
		end
		lingshouMaxLvl = maxLvl
	end
	FPrint('-------------------------------'..lingshouMaxLvl)
	return lingshouMaxLvl
end

-- 1灵兽2神兽0无
function SpiritsModel:GetFushenType()
	if LinshouModel.fushenWuhunId and LinshouModel.fushenWuhunId ~= 0 then
		return 2
	end	
	if not self.currentWuhun then
		return 0
	end
	if self.currentWuhun.wuhunState == 1 then
		return 1
	end
	return 0
end

function SpiritsModel:GetFushenWuhunId()
	if LinshouModel.fushenWuhunId and LinshouModel.fushenWuhunId ~= 0 then
		return LinshouModel.fushenWuhunId
	end	
	--"状态，0,未附身，1,俯身"
	if not self.currentWuhun then
		return 0
	end
	
	if self.currentWuhun.wuhunState == 1 then--取消附身
		return self.currentWuhun.wuhunId
	end
	
	return 0
end

function SpiritsModel:getWuhuVO()
	return self.currentWuhun
end

function SpiritsModel:GetWuhunId()
	if self.currentWuhun and self.currentWuhun.wuhunId and self.currentWuhun.wuhunId ~= 0 then
		return self.currentWuhun.wuhunId
	end
	
	return nil
end

-- 当前附身的武魂的主动技能列表
function SpiritsModel:GetWuhunActiveSkillList()
	local shenshou = LinshouModel:GetWuhunActiveSkillList() 
	if shenshou and #shenshou > 0 then
		-- FTrace(shenshou)
		return shenshou
	end

	local wuhunSkills = {}
	if self:GetWuhunState() == 1 then
		if t_wuhun[self.currentWuhun.wuhunId] then
			wuhunSkills = t_wuhun[self.currentWuhun.wuhunId].active_skill
		end
	end
	-- FTrace(wuhunSkills)
	return wuhunSkills
end

-- 武魂状态
--"状态，0,未附身，1,俯身"
function SpiritsModel:GetWuhunState()
	return self.currentWuhun.wuhunState
end

-- 当前魂珠
function SpiritsModel:GetCurrentHunzhu(wuhunId)
	-- FTrace(self.currentWuhun)
	return self.currentWuhun.hunzhu
end

-- 武魂被激活
function SpiritsModel:ActiveWuhun(wuhunId)
	self.currentWuhun.wuhunState = 1
	
	Notifier:sendNotification(NotifyConsts.WuhunListUpdate);
end

-- 武魂喂养进度
function SpiritsModel:FeedWuHun(wuhunId, hunzhu, feedNum, hunzhuProgress)
	self.currentWuhun.wuhunId = wuhunId
	self.currentWuhun.hunzhu = hunzhu
	self.currentWuhun.feedNum = feedNum
	self.currentWuhun.hunzhuProgress = hunzhuProgress
	WarPrintModel:SetOpenState()
	Notifier:sendNotification(NotifyConsts.WuhunUpdateFeed, {isShowFeedEffect=true});
end

-- 武魂被附身
function SpiritsModel:FushenWuhun(wuhunId, flag)
	local wList = LinshouModel.shenshouList
	if wuhunId > 0 then
		SpiritsModel.selectedWuhunId = wuhunId;
	end
	LinshouModel.fushenWuhunId = 0
	for index,wVo in pairs(wList) do
		if wVo.wuhunState == 1 then
			wVo.wuhunState = 0
		end
	end
	if self.currentWuhun.wuhunState == 1 then
		self.currentWuhun.wuhunState = 0
	end
	
	if self.currentWuhun.wuhunId  < SpiritsConsts.SpiritsDownId then
		LinshouModel.selectedWuhunId = wuhunId;
	end
	
	if flag == 1 then--附身
		if LinshouModel:getWuhuVO(wuhunId) then
			LinshouModel:getWuhuVO(wuhunId).wuhunState = 1--附身
		else
			if wuhunId > SpiritsConsts.SpiritsDownId then
				self.currentWuhun.wuhunState = 1--附身
			end
		end
		LinshouModel.fushenWuhunId = wuhunId
	elseif flag == 2 then--取消附身
		if LinshouModel:getWuhuVO(wuhunId) then
			LinshouModel:getWuhuVO(wuhunId).wuhunState = 0--已激活
		else
			if wuhunId > SpiritsConsts.SpiritsDownId then
				self.currentWuhun.wuhunState = 0--未附身
			end
		end
		LinshouModel.fushenWuhunId = 0
	end

	Notifier:sendNotification(NotifyConsts.WuhunFushenChanged)
	Notifier:sendNotification(NotifyConsts.WuhunListUpdate,{ischange=true});
	Notifier:sendNotification(NotifyConsts.ChangeZhanShouModel);
	SkillController:OnWuhunSkillChange();
end

-- 武魂进阶
function SpiritsModel:WuhuLevelUp(wuhunId, wuhunWish, proceState, proceId)
	self.currentWuhun.wuhunWish = wuhunWish
	local succ = false
	if proceState == 1 then --进阶成功
		succ = true
		self.isAutoLevelUp = false
		LinshouModel.fushenWuhunId = 0;
		SpiritsModel.selectedWuhunId = proceId;
		
		local wuhuVO = SpiritsVO:new()
		wuhuVO.wuhunId = proceId
		wuhuVO.wuhunState = self.currentWuhun.wuhunState
		wuhuVO.wuhunWish = wuhunWish
		
		local wList = LinshouModel.shenshouList
		for index,wVo in pairs(wList) do
			if wVo.wuhunState == 1 then
				wVo.wuhunState = 0
				wuhuVO.wuhunState = 1;
			end
		end
		
		local cfg = t_wuhun[wuhuVO.wuhunId]
		if cfg then 
			local feedTable = cfg.feed_consume
			wuhuVO.feedItem = feedTable[1]
		else
			wuhuVO.feedItem = nil
		end
		
		self.currentWuhun = wuhuVO
		UIzhanshou.isShowAni = true
		Notifier:sendNotification(NotifyConsts.WuhunListUpdate)
		SkillController:OnWuhunSkillChange();
		WarPrintModel:SetOpenState()
	end
	Notifier:sendNotification(NotifyConsts.WuhunLevelUpUpdate, {isSucc=succ})
end

function SpiritsModel:SetPillNum(num)
	self.pillNum = num;
	self:sendNotification(NotifyConsts.LingShouSXDChanged);
end

function SpiritsModel:GetPillNum()
	return self.pillNum;
end





