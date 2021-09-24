require "luascript/script/game/gamemodel/newGifts/newGiftsVo"

newGiftsVoApi={
	allGiftsVo={},
}

function newGiftsVoApi:clear()
	if self.allGiftsVo then
		for k,v in pairs(self.allGiftsVo) do
			self.allGiftsVo[k]=nil
		end
	end
	self.allGiftsVo={}
end
function newGiftsVoApi:formatData(data)
    local tmpTb=playerCfg.newGifts
    if platCfg.platCfgNewGifts~=nil and platCfg.platCfgNewGifts[G_curPlatName()]~=nil then
        tmpTb=platCfg.platCfgNewGifts[G_curPlatName()]
    end
	
    for k,v in pairs(tmpTb) do
		if v.award then
			local awardCfg=v.award
			local num=1
			if data and data[k] then
				num=tonumber(data[k])
			end
			local award=FormatItem(awardCfg,nil,true)
			--[[
			local award
			for m,n in pairs(awardCfg) do
				awardCfg[m]
			end
			]]
	        local vo = newGiftsVo:new()
	        vo:initWithData(k,num,award)
	        table.insert(self.allGiftsVo,k,vo)
		end
    end
end
function newGiftsVoApi:getAllGiftsVo()
    if self.allGiftsVo==nil then
        self.allGiftsVo={}
    end
    return self.allGiftsVo
end

function newGiftsVoApi:getNewGiftsVo(id)
    local gifts=self:getAllGiftsVo()
	for k,v in pairs(gifts) do
		if tostring(v.id)==tostring(id) then
			return v
		end
	end
	return {}
end

function newGiftsVoApi:getNewGiftsNum()
    local gifts=self:getAllGiftsVo()
	return SizeOfTable(gifts)
end

function newGiftsVoApi:getLoginDay()
	--[[
	print("base.serverTime",base.serverTime)
	print("playerVoApi:getRegdate()",1386227862)
	print("G_getWeeTs(base.serverTime)",G_getWeeTs(base.serverTime))
	print("G_getWeeTs(1386227862)",G_getWeeTs(1386227862))
	local dayNum=(G_getWeeTs(base.serverTime)-G_getWeeTs(1386227862))/30+1
	]]
	local dayNum=(G_getWeeTs(base.serverTime)-G_getWeeTs(playerVoApi:getRegdate()))/86400+1
	return dayNum
end

function newGiftsVoApi:hasReward()
	local flag=0
	local hasFlag=0
	local removeFlag=1
	local gifts=self:getAllGiftsVo()
	local loginDay=self:getLoginDay()
	if gifts then
		for k,v in pairs(gifts) do
			if v and v.num<=0 then
				removeFlag=0
				if loginDay>=k then
					hasFlag=1
				end
			end
		end
		if removeFlag==1 then
			flag=-1
		elseif hasFlag==1 then
			flag=1
		end
		return flag
	else
		return -1
	end
end

function newGiftsVoApi:getAwardStr(id)
	local newGiftsVo = self:getNewGiftsVo(id)
	local awardTab = newGiftsVo.award
	local str = getlocal("daily_lotto_tip_10")

    local playerHonors =playerVoApi:getHonors() --用户当前的总声望值
    local maxLevel =playerVoApi:getMaxLvByKey("roleMaxLevel") --当前服 最大等级
    local honTb =Split(playerCfg.honors,",")
    local maxHonors =honTb[maxLevel] --当前服 最大声望值
	if awardTab then
		for k,v in pairs(awardTab) do
			if k==SizeOfTable(awardTab) then
				if v.name == getlocal("honor") and base.isConvertGems==1 and tonumber(playerHonors) >=tonumber(maxHonors) and k==1 then
					local gems = playerVoApi:convertGems(2,v.num) 
					local name = getlocal("money")
					str = str .. name .. " x" .. gems
				else
					str = str .. v.name .. " x" .. v.num
				end
			else
				if v.name == getlocal("honor") and base.isConvertGems==1 and tonumber(playerHonors) >=tonumber(maxHonors) then
					local gems = playerVoApi:convertGems(2,v.num)
					local name = getlocal("money")
					str = str .. name .. " x" .. gems .. ","
				else
					str = str .. v.name .. " x" .. v.num .. ","
				end
			end
		end
	end
	return str,awardTab
end

--[[
function newGiftsVoApi:getDailyGem()
	return self.dailyGemNum
end

function newGiftsVoApi:isReward(id)
	local rewardNum=0
	local vo=self:getNewGiftsVo(id)
	--local udTime=self:getUpdateTime()
	if vo~=nil and SizeOfTable(vo)>0 then
		--if vo.time>0 and vo.time>udTime then
		if vo.time>0 and G_isToday(vo.time) then
			rewardNum=vo.num
		end
		if vo.maxNum>0 and rewardNum>=vo.maxNum then
			return true
		end
	end
	return false
end

function newGiftsVoApi:hasReward()
    local hasReward=true
    if self:isReward(1)==true and self:isReward(2)==true then
        hasReward=false
    end
    return hasReward
end
function newGiftsVoApi:gemTaskNum(id)
    local vo=self:getNewGiftsVo(id)
    return vo.cost
end
function newGiftsVoApi:gemLessNum(id)
	local vo=self:getNewGiftsVo(id)
	if vo.cost>playerVoApi:getGems() then
		return (vo.cost-playerVoApi:getGems())
	end
	return -1
end

function newGiftsVoApi:updateRewardNum()
	local tbb=self:getAllGiftsVo()
	--local udTime=self:getUpdateTime()
	if tbb then
		for k,v in pairs(tbb) do
			if k~=4 then
				--if self.allGiftsVo[k].time>0 and udTime>self.allGiftsVo[k].time then
				if self.allGiftsVo[k].time>0 and G_isToday(self.allGiftsVo[k].time)==false then
					if self.allGiftsVo[k].num~=0 then
						self.allGiftsVo[k].num=0
						return true
					end
				end
			end
		end
	end
	return false
end
]]