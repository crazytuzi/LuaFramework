acCzhkVoApi={
	name=nil,
	totalRewardTb = nil,
	dailyRewardTb = nil,
}
function acCzhkVoApi:clearAll()
	self.dailyRewardTb = nil
	self.totalRewardTb = nil
	self.name = nil
end
function acCzhkVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acCzhkVoApi:setActiveName(name)
	self.name=name
end

function acCzhkVoApi:getActiveName()
	return self.name or "czhk"
end

function acCzhkVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acCzhkVoApi:getTimer( )--倒计时 需要时时显示
	local vo=self:getAcVo()
	local str=""
	if vo then
		str=getlocal("activityCountdown")..":"..G_formatActiveDate(vo.et - base.serverTime)
	end
	return str
end

function acCzhkVoApi:canReward( )
	return false
end

function acCzhkVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end
function acCzhkVoApi:getFirstFree()--免费标签
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		return vo.firstFree
	end
	return 1
end
function acCzhkVoApi:setFirstFree(newfree)
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		vo.firstFree = newfree
	end
end
function acCzhkVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage2.plist")
    spriteController:addTexture("public/activeCommonImage2.png")
end
function acCzhkVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage2.plist")
    spriteController:removeTexture("public/activeCommonImage2.png")
end

function acCzhkVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end

function acCzhkVoApi:showInfoTipTb(layerNum)
	local tabStr = {}
	for i=1,3 do
        table.insert(tabStr,getlocal("activity_czhk_tip"..i))
    end
    local titleStr=getlocal("activity_baseLeveling_ruleTitle")
    require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
    tipShowSmallDialog:showStrInfo(layerNum,true,true,nil,titleStr,tabStr,nil,25)
end

function acCzhkVoApi:getGiftimg(i)
	local str 
	if i == 1 then
		str = "packs4.png"
	elseif i == 2 then
		str = "packs6.png"
	else
		str = "gold_pack.png"
	end
	return str
end

function acCzhkVoApi:getTotalRewardData( )
	local vo = self:getAcVo()
	if self.totalR then
		return self.totalR,SizeOfTable(self.totalR)
	elseif vo and vo.totalR then
		self.totalR = {}
		for k,v in pairs(vo.totalR) do
			local reward = FormatItem(v.r,nil,true)
			self.totalR[k] = G_clone(v)
			-- print("reward[1].name--->>>",reward[1].name)
			self.totalR[k].reward = G_clone(reward)
		end
		return self.totalR,SizeOfTable(self.totalR)
	end
end

function acCzhkVoApi:getThisDayRewardData( )
	local vo = self:getAcVo()
	if self.dailyRewardTb then
		return self.dailyRewardTb
	elseif vo and vo.dailyR then
		self.dailyRewardTb = {}
		for k,v in pairs(vo.dailyR) do
			local reward = FormatItem(v.r,nil,true)
			self.dailyRewardTb[k] = G_clone(v)
			self.dailyRewardTb[k].reward = G_clone(reward)
		end
		return self.dailyRewardTb
	end
end

function acCzhkVoApi:getRechargeDays(idx)
	local vo = self:getAcVo()
	if vo and vo.rechargeDaysTb then
		return (vo.rechargeDaysTb[idx] and vo.rechargeDaysTb[idx][1]) and vo.rechargeDaysTb[idx][1] or 0
	end
	return 0
end
function acCzhkVoApi:getCurRecharge( )
	local vo = self:getAcVo()
	if not self:isToday() then
		return 0
	end
	if vo and vo.curDayRecharge then
		return vo.curDayRecharge
	end
	return 0
end

function acCzhkVoApi:isOverCurRecharge(idx,limitNum)-- 是否显示当日充值按钮 （下面俩按钮）
	local vo = self:getAcVo()
	if not self:isToday() then
		return false
	end
	if vo and vo.curDayRecharge then
		if vo.curDayRecharge >= limitNum then
			return true
		end
	end
	return false-- 未达到充值要求
end