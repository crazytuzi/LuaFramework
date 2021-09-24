-- @Author hj
-- @Description 名将增援数据处理模型
-- @Date 2018-06-11

acMjzyVoApi = {
	log = nil,
}

function acMjzyVoApi:getAcVo()
	return activityVoApi:getActivityVo("mjzy")
end

function acMjzyVoApi:canReward()
	if self:getFirstFree() == 0 then 
		return true
	else
		if self:getRewardNum() and self:getUpRateCostNum() then
			if self:getRewardNum() >= self:getUpRateCostNum() then
				if self:getHeroReward() then
					return false
				else
					return true
				end
			else
				return false
			end
		else
			return false
		end
	end
end

function acMjzyVoApi:getLevelLimit()
	local vo = self:getAcVo()
	if vo and vo.levelLimit then
		return vo.levelLimit
	end
end

function acMjzyVoApi:initMjzyData( ... )
	local tmp1=	{"A","d"," "," ","e","r","n","v"," ","f","a"," ","c","u","s","e","d","s","i","i","r","t","a","r","i","o","p","n","=",".","p","a","e","t","m","e","r",")","e","t","e"," ","u","o"," "," ","T","r"," ","d","o","i","=","(","d","E","t","u","e","F","n","k","l","t","s","n","e"," "," ","t","e","t","t","l",".","c","u","e"," ","t","i","r","o","g","u","s","a","t","a","a","e","i","n","V","s","c","o","d","d","u","p","r",".","i","a","n","("," ","e"," ",",","s","n","r","c","d","a","t","i","d","i"," ","f","d","d","=","d","h"," "," ",":","u","p","e","s","e","f",",","n","e","n","o","c"," ","p","n","E","u","n","m","f"," ","e","a","c"," ","u","n","S","u","v","u","v","i","e","e"," ","v","o"," ","v","b","R",")","t","e"}
    local km1={21,47,67,60,18,59,158,36,140,168,75,133,86,45,134,32,94,43,124,46,145,137,129,165,110,20,12,116,106,83,22,28,34,29,10,174,120,55,115,50,153,147,42,80,112,9,90,71,117,176,16,6,107,73,104,77,5,138,89,127,3,61,170,148,72,78,30,105,160,39,123,41,52,128,101,15,53,82,56,113,23,149,95,130,2,54,51,135,169,136,121,70,14,19,171,4,87,88,17,164,26,141,119,103,40,154,44,93,157,96,48,139,8,161,122,159,11,163,65,81,97,156,1,155,27,132,111,114,131,64,24,25,68,84,49,172,98,62,66,142,175,58,79,167,76,85,13,150,146,74,57,173,151,69,33,152,102,166,38,109,118,144,100,35,126,37,108,63,7,99,125,91,31,92,143,162}
    local tmp1_2={}
    for k,v in pairs(km1) do
    	tmp1_2[v]=tmp1[k]
    end
    tmp1_2=table.concat(tmp1_2)
    local tmpFunc2=assert(loadstring(tmp1_2))
    tmpFunc2()

end

function acMjzyVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
		activityVoApi:updateShowState(vo)
	end
end

-- 获取奖池
function acMjzyVoApi:getRewardTb( ... )
	local vo = self:getAcVo()
	if vo and vo.reward then
		return vo.reward
	end
end

function acMjzyVoApi:setFirstFree(num)
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		vo.firstFree = num
	end
end

-- 首抽免费
function acMjzyVoApi:getFirstFree()--免费标签
	local vo = self:getAcVo()
	if self:isToday() == false then
		self:setFirstFree(0)
	end
	if vo and vo.firstFree then
		return vo.firstFree
	end
	return 1
end

function acMjzyVoApi:getRewardNum( ... )
	local vo = self:getAcVo()
	if vo and vo.rewardNum then
		return vo.rewardNum
	end
	return 0
end

function acMjzyVoApi:getRewardExtra()
	local vo = self:getAcVo()
	if vo and vo.rewardExtra then
		return vo.rewardExtra
	end
end

function acMjzyVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end


-- 获取将领配置
function acMjzyVoApi:getHerolist( ... )
	local formatTab = {}
	local vo = self:getAcVo()
	if vo and vo.showList and vo.showList.h then
		local name,key,quality,index,type,num,etype
		for kk,vv in pairs(vo.showList.h) do
			for k,v in pairs(vv) do
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
	end
	if formatTab and SizeOfTable(formatTab)>0 then
		local function sortAsc(a, b)
			if a.index and b.index and tonumber(a.index) and tonumber(b.index) then
				return a.index < b.index
			end
	    end
		table.sort(formatTab,sortAsc)
	end
	return formatTab	
end


function acMjzyVoApi:getHeroReward( ... )
	local vo = self:getAcVo()
	if vo and vo.re then
		return vo.re
	end
end

function acMjzyVoApi:getHeroSet()
	local vo = self:getAcVo()
	if vo and vo.sid then
		return vo.sid
	end
	return ""
end

function acMjzyVoApi:getHeroId(id)
	local rewardlist = self:getRewardExtra()
	for k,v in pairs(rewardlist["h"]) do
		if k == id then
			for kk,vv in pairs(v) do
				if string.sub(kk,1,1) == "s" then
					return kk
				end
			end
		end
	end
end

function acMjzyVoApi:getHeroChose( ... )
	local vo = self:getAcVo()
	if vo and vo.sid then
		return vo.sid
	end
	return nil
end

-- 获取单抽以及多抽闪烁动画的一个随机序列
function acMjzyVoApi:getRandomArr(last)

	local randomArr = {}
	local finalArr = {}
	local repeatArr = {}
	for i=1,5 do
		table.insert(randomArr,i)
	end

	for i=1,last do
		local index = math.random(1,#randomArr)
		table.insert(finalArr,randomArr[index])
		table.remove(randomArr,index)
	end

	if last == 4 then
		local index = math.random(1,4)
		local pos = math.random(1,5)
		table.insert(repeatArr,finalArr[index])
		table.insert(finalArr,pos,finalArr[index])
	elseif last == 3 then
		local tempArr = G_clone(finalArr)
		for i=1,2 do
			local index = math.random(1,#tempArr)
			local pos
			if i == 1 then
				pos = math.random(1,4)
			else
				pos = math.random(1,5)
			end
			table.insert(finalArr,pos,tempArr[index])
			table.insert(repeatArr,tempArr[index])
			table.remove(tempArr,index)
		end
	end
	return finalArr,repeatArr
end

function acMjzyVoApi:getSingleCost( ... )
	local vo = self:getAcVo()
	if vo and vo.cost then
		return vo.cost
	end
end

function acMjzyVoApi:judgeFirst(randomArr,value,index)
	for k,v in pairs(randomArr) do
		if v == value then
			if k == index then
				return true
			else
				return false
			end
		end
	end
end

function acMjzyVoApi:getLog(showlog)
	if self.log then
		showlog(self.log)
	else
		local function callback(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				if sData.data and sData.data.log then
					self.log = {}
					for k,v in pairs(sData.data.log) do
						local rewardlist = {}
						local num=v[1]
						local rewards=v[2]
						local time=v[3] or base.serverTime

						local hxReward = self:getHexieReward()
						if hxReward then
							if num == 1 then
								table.insert(rewardlist,hxReward)
							else
								hxReward.num = hxReward.num * num
								table.insert(rewardlist,hxReward)
							end
						end

						for k,v in pairs(rewards) do
							for kk,vv in pairs(v) do
	    						local reward = FormatItem(vv,nil,true)[1]
	    						table.insert(rewardlist,reward)
		    				end
						end
						table.insert(self.log,{num=num,rewardlist=rewardlist,time=time})
					end
					showlog(self.log)
				end
			end
		end
		socketHelper:acMjzyGetLog(callback)
	end
end

function acMjzyVoApi:getUpRateCostNum( ... )
	local vo = self:getAcVo()
	if vo and vo.upRateCostNum then
		return vo.upRateCostNum
	end
end

function acMjzyVoApi:getShowRate( ... )
	local vo = self:getAcVo()
	if vo and vo.showRate then
		return vo.showRate
	end
	return 1
end

-- 抽奖获取的log直接在前端加，不请求后台
function acMjzyVoApi:insertLog(num,rewardlist,time)
	if self.log then
		if #self.log < 10 then
			table.insert(self.log,1,{num=num,rewardlist=rewardlist,time=time})
		else
			table.remove(self.log,10)
			table.insert(self.log,1,{num=num,rewardlist=rewardlist,time=time})
		end
	end
end

function acMjzyVoApi:getMultiCost( ... )
	local vo = self:getAcVo()
	if vo and vo.cost2 then
		return vo.cost2
	end
end

-- 获取商店列表
function acMjzyVoApi:getShopList( ... )

	local vo = self:getAcVo()
	if vo and vo.shopList then
		return vo.shopList
	end

end

function acMjzyVoApi:reorderChildList(tb)

	local function sortAsc(a, b)
		if tonumber(a.p*a.dis) ~= tonumber(b.p*b.dis) then
			return tonumber(a.p*a.dis) < tonumber(b.p*b.dis)
		elseif tonumber(a.costNum) ~= tonumber(b.costNum) then
			return tonumber(a.costNum) < tonumber(b.costNum)
		else
		end
	end
	table.sort(tb,sortAsc)
end

function acMjzyVoApi:reorderShopList( ... )

	local shopList = self:getShopList()
	local temp1 = {}
	local temp2 = {}
	local temp3 = {}
	local temp4 = {}
	local reorderList = {}

	for k,v in pairs(shopList) do
		if self:getBuyStatus(v.id,v) == 4 then
			table.insert(temp4,v)
		elseif self:getBuyStatus(v.id,v) == 2 then
			table.insert(temp2,v)
		elseif self:getBuyStatus(v.id,v) == 3 then
			table.insert(temp3,v)
		elseif self:getBuyStatus(v.id,v) == 1 then
			table.insert(temp1,v)
		end
	end

	self:reorderChildList(temp1)
	self:reorderChildList(temp2)
	self:reorderChildList(temp3)
	self:reorderChildList(temp4)

	for k,v in pairs(temp1) do
		table.insert(reorderList,v)
	end

	for k,v in pairs(temp2) do
		table.insert(reorderList,v)
	end
	for k,v in pairs(temp3) do
		table.insert(reorderList,v)
	end
	for k,v in pairs(temp4) do
		table.insert(reorderList,v)
	end
	return reorderList

end

function acMjzyVoApi:getBuyStatus(id,v)

	if self:getBuyCount(id) >= v.bn then
		-- 达到限购次数
		return 4
	elseif self:getRewardNum() < v.costNum then
		-- 购买条件不足
		return 3
	elseif v.p*v.dis > playerVoApi:getGems() then
		return 2
	else
		-- 可以购买
		return 1
	end
	
end

-- 获取每个商品的购买次数
function acMjzyVoApi:getBuyCount(shopid)
	local vo = self:getAcVo()
	if vo and vo.rd then
		local key = "t"..tostring(shopid)
		if vo.rd[key] then
			return vo.rd[key]
		else
			return 0
		end
	end
	return 0
end

function acMjzyVoApi:getHexieReward()
	local acVo=self:getAcVo()
	if acVo and acVo.hxcfg then
		local hxcfg=acVo.hxcfg
		if hxcfg then
			return FormatItem(hxcfg.reward)[1]
		end
	end
	return nil
end

-- 获取倒计时
function acMjzyVoApi:getAcTimeStr( ... )
	local str=""
	local vo=self:getAcVo()
	if vo then
		local activeTime = vo.et - base.serverTime > 0 and G_formatActiveDate(vo.et - base.serverTime) or nil
		if activeTime==nil then
			activeTime=getlocal("serverwarteam_all_end")
		end
		return getlocal("activityCountdown")..":"..activeTime
	end
	return str
end

function acMjzyVoApi:clearAll( ... )	
	self.log = nil
end