acSendGeneralVoApi={}

function acSendGeneralVoApi:getAcVo( )
	return activityVoApi:getActivityVo("songjiangling")
end

function acSendGeneralVoApi:canReward( )---
	local vo = self:getAcVo()
	local curDay =self:getCurrentDay()
	local curRechar = self:getAllReward()
	if  curRechar[curDay] ~= 0 then
		return false
	end
	return true
end

function acSendGeneralVoApi:getValue( )
	local vo = self:getAcVo()
	if vo and vo.value then
		return vo.value
	end
	return nil
end

-- 获得第day天修改记录需要的充值数
function acSendGeneralVoApi:getReviseNeedMoneyByDay()
	local acVo = self:getAcVo()
	if acVo and acVo.retro then
		return acVo.retro
	end
	return 999999
end

function acSendGeneralVoApi:getBigReward( )
	local vo = self:getAcVo()
	if vo and vo.bigReward then
		return vo.bigReward
	end
	return nil
end
function acSendGeneralVoApi:getBigRewardKeyValue( )
	local bigReward = self:getBigReward()
	if bigReward ==nil then
		print("=======It's none of bigReward======")
		return nil
	end
	local pBig,pIndex,pBigNum,pId
	for k,v in pairs(bigReward) do
		if k == "p" and v then
			for i,j in pairs(v) do
				if j then
					for m,n in pairs(j) do
						if m =="index" then
							pIndex =n
						else
							print("pBig.......",m,n)
							pBig= m
							pBigNum = n
							pId = tonumber(RemoveFirstChar(m))
						end
					end
				end
			end
		end
	end
	return pBig,pBigNum,pIndex,pId
end
function acSendGeneralVoApi:formatHeroList()
	local pBig,pBigNum = self:getBigRewardKeyValue()
	local prop = propCfg[pBig]
	local name ,key,quality,index,type,num,etype
	--local award = {}
	local formatTab={}
	if prop.useGetHero then
		for k,v in pairs(prop.useGetHero) do
			if k then
		        name = k
		        key = k 
		        type= string.sub(k,1,1)
		        etype = string.sub(k,1,1)
		        quality = v
		        index = tonumber(RemoveFirstChar(k))
		        num = tonumber(RemoveFirstChar(k))
		        if name and name ~= "" then
		        	local award = {name=name,key=key,type=type,index=index}
		            local function sortAsc(a, b)
		                if a and b and a.index and b.index and tonumber(a.index) and tonumber(b.index) then
		                    return a.index < b.index
		                end
		            end
		            table.sort(award,sortAsc)
		        	table.insert(formatTab,{name=name,quality=quality,index=index,award=award})
		        end	
	        end		
		end
		if formatTab and SizeOfTable(formatTab)>0 then
			local function sortAsc(a, b)
				if a.index and b.index and tonumber(a.index) and tonumber(b.index) then
					return a.index < b.index
				end
		    end
			table.sort(formatTab,sortAsc)
		end
	end
	if formatTab and SizeOfTable(formatTab)>0 then
		return formatTab
	end
	return nil
end

function acSendGeneralVoApi:getHeroNameList( )
	local heroList = self:formatHeroList()
	local heroName  --heroListCfg[]
	local msgContent={}
	for k,v in pairs(heroList) do
		local heroId=heroListCfg[v.name]
		heroName =heroId["heroName"] 
		local realHeroName = getlocal(heroName)
		local showStr1=getlocal("item_number",{realHeroName,1})
  		table.insert(msgContent,{showStr1,G_ColorYellowPro})
	end
return msgContent

end

function acSendGeneralVoApi:getDailyReward( )
	local vo = self:getAcVo()
	if vo and vo.dailyReward then
		return vo.dailyReward
	end
	return nil
end

function acSendGeneralVoApi:mustGetHero(idx)
	-- local dailyReward = self:getDailyReward()
	-- if dailyReward then
	-- 	return dailyReward[idx]
	-- end
	local x = {}
	x["hero_h26"]=2
	return x
end

-- 得到当前时间是第几天
function acSendGeneralVoApi:getCurrentDay()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		local day = math.floor((G_getWeeTs(base.serverTime) - G_getWeeTs(acVo.st))/86400) + 1 -- 当前是活动的第几天
		return day
	end
	return 0
end
function acSendGeneralVoApi:reFreAllday( )--当天充值完改变当天的判断值
	local acVo = self:getAcVo()
	local day = self:getCurrentDay()
	if acVo and day >0 then
		self:setWhichDay(day)
	end
end
function acSendGeneralVoApi:setSuppleDay( day )--设置补签后的 判断值(未领取状态)
	local allRe = self:getAllReward()
	local acVo = self:getAcVo()
	if acVo then
		if acVo.sevenRe==nil then
			acVo.sevenRe = {}
		end 
		acVo.sevenRe[day]=1
	end
end
function acSendGeneralVoApi:afterSuppleSet(suppleDay)--补签后，修改判断值
	local acVo = self:getAcVo()
	if acVo and suppleDay >0 then
		self:setSuppleDay(suppleDay)
	end
end


function acSendGeneralVoApi:setDefaulSevenReward( ) --设置7天默认判断值
	local vo = self:getAcVo()
	if vo then
		if vo.sevenRe ==nil then
			vo.sevenRe={0,0,0,0,0,0,0}
		end
	end
end

function acSendGeneralVoApi:getAllReward( )--拿到7天充值的判断（table)
	local vo = self:getAcVo()
	self:setDefaulSevenReward()
	if vo and vo.sevenRe then
		return vo.sevenRe
	end
	return {}
end
function acSendGeneralVoApi:getAllValue( )
	local sevenRe = self:getAllReward()
	for k,v in pairs(sevenRe) do
		if v ==0 then
			return false
		end
	end
	return true
end
function acSendGeneralVoApi:isAllReward( )--后端第一次给得7天数据，判断是否达到领取大奖的条件
	local sevenRe = self:getAllReward()
	local isAll = false
	for k,v in pairs(sevenRe) do
		if v ==0 then
			isAll = false
			do return end
		end
		isAll = true
	end
	return isAll
end

function acSendGeneralVoApi:setWhichDay(day) ----改变当天是否充值的判断，需强制刷新
	local allRe = self:getAllReward()
	local acVo = self:getAcVo()
	if acVo then 
		if acVo.sevenRe==nil then
			acVo.sevenRe = {}
		end
		acVo.sevenRe[day]=1
	end
end
-- 得到活动总天数
function acSendGeneralVoApi:getTotalDays()
	-- return 7 -- todo 测试使用
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return math.floor((acVo.et - acVo.st)/86400) + 1
	end
	return 0
end

function acSendGeneralVoApi:setBigRewardHad( )
	local acVo = self:getAcVo()
	if acVo ~=nil then
		if acVo.bigRewardHad ==nil then
			acVo.bigRewardHad = 4 
		end
	end
end
function acSendGeneralVoApi:getBigRewardHad( )
	local acVo = self:getAcVo()
	if acVo then
		return acVo.bigRewardHad
	end
	return nil
end