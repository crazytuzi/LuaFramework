--[[神兽model
liyuan
2014年9月28日10:33:06
]]

_G.LinshouModel = Module:new();

LinshouModel.selectedWuhunId = 0
LinshouModel.wuhunList = {}
LinshouModel.fushenWuhunId = 0
LinshouModel.isAutoLevelUp = false
LinshouModel.isAutoBuy = false

LinshouModel.shenshouList = {};

--添加神兽
function LinshouModel:AddShenShouVO(vo)
	self.shenshouList[vo.wuhunId] = vo;
end
--得到神兽信息
function LinshouModel:GetShenShouList()
	return self.shenshouList;
end

--更新神兽信息
function LinshouModel:UpdateShenShouVO(vo)
	self.shenshouList[vo.wuhunId] = vo;
end

--添加武魂
function LinshouModel:AddWuhun(spiritsVO)
	local oldVO = self:isWuhunExist(spiritsVO)
	if oldVO == nil then
		FPrint("wuhunchushihua1")
		self.wuhunList[spiritsVO.wuhunId] = spiritsVO
	else
		FPrint("wuhunchushihua2")
		self:updateWuhun(oldVO.wuhunId, spiritsVO)
	end
	-- trace(self.wuhunList)
end

-- 获取武魂等级
function LinshouModel:GetLevel()
	return 1
end

function LinshouModel:GetActWuhunList()
	local actList = {}

	for i, wVo in pairs(self.shenshouList) do
		if wVo.time ~= 0 then
			table.insert(actList, wVo.wuhunId)
		end
	end
	
	table.sort(actList,function(A,B)
		if A < B then
			return true;
		else
			return false;
		end
	end);
	
	return actList
end

function LinshouModel:getWuhuVO(wuhunId)
	return self.shenshouList[wuhunId]
end

-- update武魂
function LinshouModel:updateWuhun(oldId, newVO)
	-- Debug("wuhunupdate")
	self:deleteWuhun(oldId)
	self.shenshouList[newVO.wuhunId] = newVO
end

-- 删除武魂
function LinshouModel:deleteWuhun(spiritsId)
	self.shenshouList[spiritsId] = nil;
end

-- 武魂是否已经存在
function LinshouModel:isWuhunExist(spiritsVO)
	FPrint(spiritsVO.shenshouList)
	for i, sVO in pairs (self.shenshouList) do
		local oldCfg = t_wuhunachieve[sVO.wuhunId]
		local newCfg = t_wuhunachieve[spiritsVO.wuhunId]
		-- Debug("wuhunid"..oldCfg.id.."wuhunzuming"..oldCfg.group)
		if oldCfg and newCfg and oldCfg.id == newCfg.id then
			return sVO
		end
	end
	
	return nil
end

-- 当前附身的武魂的主动技能列表
function LinshouModel:GetWuhunActiveSkillList()
	local wuhunSkills = {}
	FPrint(self.fushenWuhunId)
	if self.fushenWuhunId and self.fushenWuhunId ~= 0 then
		if t_wuhunachieve[self.fushenWuhunId] then
			local wuhunSkill = t_wuhunachieve[self.fushenWuhunId].active_skill
			--神兽的第一个主动技能依然是灵兽的
			wuhunSkills[1] = t_wuhun[SpiritsModel:getWuhuVO().wuhunId].active_skill[1]
			wuhunSkills[2] = wuhunSkill[2] + t_wuhun[SpiritsModel:getWuhuVO().wuhunId].order - 1
		end
	end
	
	return wuhunSkills
end

-- 武魂是否被激活
function LinshouModel:IsActive(wuhunId)
	local wuhunVO = self.shenshouList[wuhunId]
	if not wuhunVO then return false end
	trace(self.shenshouList)
	if wuhunVO.wuhunState == nil or wuhunVO.wuhunState == 0 then
		return false
	else
		return true
	end
end

-- 武魂状态
function LinshouModel:GetWuhunState(wuhunId)
	return self.shenshouList[wuhunId].wuhunState
end
-- 武魂状态
function LinshouModel:SetWuhunState(wuhunId,wuhunState)
	if self.shenshouList[wuhunId] then
		self.shenshouList[wuhunId].wuhunState = wuhunState;
	end
	self.fushenWuhunId = 0;
	if wuhunState == 1 then
		self.fushenWuhunId = wuhunId;
	end
end

-- 当前魂珠
function LinshouModel:GetCurrentHunzhu(wuhunId)
	return self.wuhunList[wuhunId].hunzhu
end

-- 武魂被激活
function LinshouModel:ActiveWuhun(wuhunId)
	self.wuhunList[wuhunId].wuhunState = 1
	
	Notifier:sendNotification(NotifyConsts.WuhunListUpdate);
end

-- 武魂喂养进度
function LinshouModel:FeedWuHun(wuhunId, hunzhu, feedNum, hunzhuProgress)
	self.wuhunList[wuhunId].wuhunId = wuhunId
	self.wuhunList[wuhunId].hunzhu = hunzhu
	self.wuhunList[wuhunId].feedNum = feedNum
	self.wuhunList[wuhunId].hunzhuProgress = hunzhuProgress
	
	Notifier:sendNotification(NotifyConsts.WuhunUpdateFeed, {isShowFeedEffect=true});
end

-- 得到武魂在列表中的index
function LinshouModel:GetWuhunIndex(wuhunId)
	local index = 0

	for i, wVo in pairs(self.wuhunList) do
		if wVo.wuhunId == wuhunId then
			return index
		end
		
		index = index + 1
	end
	
	return -1
end

-- 神兽是否被激活
function LinshouModel:IsShenShouActive(wuhunId)
	local shenshouVO = self.shenshouList[wuhunId]
	if not shenshouVO then return false end
	if shenshouVO.time ~= 0 then
		return true
	else
		return false
	end
end




