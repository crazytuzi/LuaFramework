acShengdanbaozangVoApi = {
	rewardList = {}
}

function acShengdanbaozangVoApi:getAcVo()
	return activityVoApi:getActivityVo("shengdanbaozang")
end
function acShengdanbaozangVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end
function acShengdanbaozangVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end
function acShengdanbaozangVoApi:getVersion( )
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return nil
end

function acShengdanbaozangVoApi:getShowListCfg()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.showList then
		return acVo.showList
	end
	return {}
end

function acShengdanbaozangVoApi:getLotteryLimit( ... )
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.allowNum then
		return acVo.allowNum
	end
	return 4
end

function acShengdanbaozangVoApi:getHadLotteryNUm()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.allowNum then
		return acVo.hadLottery
	end
	return 0
end
function acShengdanbaozangVoApi:addHadLotteryNum()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		if acVo.hadLottery ==nil then
			acVo.hadLottery = 0 
		end
		acVo.hadLottery = acVo.hadLottery + 1
	end
end
function acShengdanbaozangVoApi:getLeftLotteryNum()
	local acVo = self:getAcVo()
	local max = self:getLotteryLimit()
	local hadLottery = self:getHadLotteryNUm()
	local leftLotteryNum = tonumber(max-hadLottery)
	if leftLotteryNum<=0 then
		leftLotteryNum = 0 
	end

	return leftLotteryNum
end
function acShengdanbaozangVoApi:refreshData()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.hadLottery = 0
	end
	self.rewardList = {}
end



function acShengdanbaozangVoApi:getIsCanClick()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.canClick then
		return acVo.canClick
	end
	return 0
end

function acShengdanbaozangVoApi:addCanClick(num)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		if acVo.canClick ==nil then
			acVo.canClick = 0 
		end
		acVo.canClick = acVo.canClick+num
		if acVo.canClick<= 0 then
			acVo.canClick = 0 
		end
	end
end

function acShengdanbaozangVoApi:getIsCanFreeClick()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.freeClick then
		return acVo.freeClick
	end
	return 0
end

function acShengdanbaozangVoApi:updateCanFreeClick(num)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.freeClick = num
	end
end


function acShengdanbaozangVoApi:getTokenCfgForShow()
	return activityCfg.singles
end

function acShengdanbaozangVoApi:getTokenCfgForShowByPid(pid)
	local cfg = self:getTokenCfgForShow()
	for k,v in pairs(cfg) do
		if k == pid then
			return v
		end
	end
	return nil
end

function acShengdanbaozangVoApi:getSelfTokens()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.token then
		return acVo.token
	end
	return {}
end

function acShengdanbaozangVoApi:getTokenNumByID(mtype)
	local Tokens = self:getSelfTokens()
	if Tokens ~= nil and type(Tokens)=="table" then
		for k,v in pairs(Tokens) do
			if k == mtype and v then
				return tonumber(v)
			end
		end
	end
	return 0
end

function acShengdanbaozangVoApi:updateSelfTokens(mtype,num)
	local acVo = self:getAcVo()
	if acVo ~= nil  then
		if acVo.token==nil then
			acVo.token = {}
		end
		local add = false
		for k,v in pairs(acVo.token) do
			if k == mtype and v then
				acVo.token[mtype] = tonumber(v + num)
				add = true
			end
		end
		if add == false then
			acVo.token[mtype] = tonumber(num)
		end
	end
end

function acShengdanbaozangVoApi:getLotteryCost()
	local vo=self:getAcVo()
	if vo and vo.cost then
		return vo.cost
	end
	return 0
end
function acShengdanbaozangVoApi:getLotteryAllCost()
	local vo=self:getAcVo()
	if vo and vo.allCost then
		return vo.allCost
	end
	return 0
end


function acShengdanbaozangVoApi:getShopCfg()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.shopItem then
		return acVo.shopItem
	end
	return {}
end

function acShengdanbaozangVoApi:getHasBuyNumByID(id)
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.hasBuy and type(acVo.hasBuy)=="table" then
		for k,v in pairs(acVo.hasBuy) do
			if k and v and k == id then
				return tonumber(v)
			end 
		end
	end
	return tonumber(0)
end

function acShengdanbaozangVoApi:updateHasBuyNumByID(id,num)
	local acVo = self:getAcVo()
	if num ==nil then
		num = 1 
	end
	if acVo ~= nil then
		if acVo.hasBuy == nil then
			acVo.hasBuy = {}
		end
		local isBuy = false
		for k,v in pairs(acVo.hasBuy) do
			if k and v and k == id then
				acVo.hasBuy[id]=num+v
				isBuy = true
			end 
		end
		if isBuy == false then
			acVo.hasBuy[id]=num
		end

	end
end

function acShengdanbaozangVoApi:getGoodsCfg( )
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.goods then
		return acVo.goods
	end
	return {}
end

function acShengdanbaozangVoApi:getIsChatByID(id)
	local goodsCfg = self:getGoodsCfg()
	if goodsCfg then
		for k,v in pairs(goodsCfg) do
			if v and v == id then
				return true
			end
		end
	end
	return false
end

function acShengdanbaozangVoApi:clearAll()
    self.rewardList=nil
end

function acShengdanbaozangVoApi:setRewardList(list)
	if list == nil then
		list = {}
	end
	self.rewardList = list
end
function acShengdanbaozangVoApi:getRewardList()
	local version = self:getVersion()
	local list = {}
	if self.rewardList then
		for k,v in pairs(self.rewardList) do
			local pos
			local pid
			local pType
			local pNum
			local name,pic,desc,id,noUseIdx,eType,equipId
			if v and type(v)=="table" then
				for m,n in pairs(v) do
					if n and type(n)=="table" then
						pType=n[1]
						pid=n[2]
						pNum=n[3]
					elseif n then
						pos = n

					end
				end
			end
			if pType =="mm" then
				if version ==1 or version ==2 or version ==nil then
					name = getlocal("activity_shengdanbaozang_CandyBarName")
					desc = "activity_shengdanbaozang_CandyBarDesc"
					pic = "CandyBar.png"
				elseif version ==3 or version ==4 then
					name =getlocal("activity_mysteriousArms_bullet")
					desc ="activity_mysteriousArms_bulletDesc"
					pic = "mysteriousArmsIcon.png"
				end
				table.insert(list,{name=name,num=pNum,pic=pic,desc=desc,id=id,type=pType,index=index,key=pid,eType=eType,equipId=equipId,pos=pos})
			else
				name,pic,desc,id,noUseIdx,eType,equipId=getItem(pid,pType)
				table.insert(list,{name=name,num=pNum,pic=pic,desc=desc,id=id,type=pType,index=index,key=pid,eType=eType,equipId=equipId,pos=pos})
			end
		end
	end
	return list
end

function acShengdanbaozangVoApi:checkIsCanLotteryAll()
	local reward = self:getRewardList()
	if reward and SizeOfTable(reward)>0 then
		for k,v in pairs(reward) do
			if v and v.pos then
				return true
			end
		end
	end
	return false
end

function acShengdanbaozangVoApi:checkIsChat(item)
	local chatGoods = self:getShowListCfg()
	local showList= FormatItem(chatGoods,nil,true)
	if showList then
		for k,v in pairs(showList) do
			if v and v.type == item.type and v.key == item.key and v.num == item.num then
				return true
			end

		end
	end
	return false

end

function acShengdanbaozangVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = G_getWeeTs(base.serverTime)
	end
end

function acShengdanbaozangVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acShengdanbaozangVoApi:canReward()
	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	return isfree
end