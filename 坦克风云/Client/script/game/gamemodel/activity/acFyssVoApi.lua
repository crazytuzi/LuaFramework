acFyssVoApi={}

function acFyssVoApi:getAcVo()
	return activityVoApi:getActivityVo("fuyunshuangshou")
end

function acFyssVoApi:getVersion()
	local vo=self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1
end
function acFyssVoApi:getHadExNumAndLimitNum( )
	local vo = self:getAcVo()
	if vo then
		return vo.hadExNum,vo.lNum
	end
	return nil
end
function acFyssVoApi:setNewHadExNum(newNum )
	local vo = self:getAcVo()
	if vo and newNum then
		vo.hadExNum = newNum
	end
end
function acFyssVoApi:getTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		local activeTime = vo.et - 86400 - base.serverTime > 0 and G_formatActiveDate(vo.et - 86400 - base.serverTime) or nil
		if activeTime==nil then
			activeTime=getlocal("serverwarteam_all_end")
		end
		return getlocal("activityCountdown")..":"..activeTime
	end
	return str
end

function acFyssVoApi:getRewardTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		local activeTime = G_formatActiveDate(vo.et - base.serverTime)
		if self:isRewardTime()==false then
			activeTime=getlocal("notYetStr")
		end
		return getlocal("onlinePackage_next_title")..activeTime
	end
	return str
end

--获取兑换奖励的列表数据
function acFyssVoApi:getExchangeList()
	local vo = self:getAcVo()
	if vo and vo.exchangeList then
		return vo.exchangeList
	end
	return {}
end

--获取单次抽奖所需钻石
function acFyssVoApi:getOneLotterPrice()
	local vo = self:getAcVo()
	if vo and vo.oneLotterPrice then
		return vo.oneLotterPrice
	end
	return 0
end

--获取十连抽所需钻石
function acFyssVoApi:getTenLotterPrice()
	local vo = self:getAcVo()
	if vo and vo.tenLotterPrice then
		return vo.tenLotterPrice
	end
	return 0
end

--设置使用的免费抽奖次数
function acFyssVoApi:setUseFreeLotterNum(_useNum)
	local vo = self:getAcVo()
	if vo and _useNum then
		vo.useFreeLotteryNum = _useNum
	end
end

--获取剩余免费抽奖次数
function acFyssVoApi:getFreeLotteryNum()
	local vo = self:getAcVo()
	if vo and vo.maxFreeLotteryNum and vo.useFreeLotteryNum then
		return vo.maxFreeLotteryNum - vo.useFreeLotteryNum
	end
	return 0
end

--获取每日最大免费抽奖次数
function acFyssVoApi:getMaxFreeLotteryNum()
	local vo = self:getAcVo()
	if vo and vo.maxFreeLotteryNum then
		return vo.maxFreeLotteryNum
	end
	return 0
end

--是否可以免费抽奖
function acFyssVoApi:isFreeLottery()
	if self:getFreeLotteryNum() > 0 then
		return true
	end
	return false
end

function acFyssVoApi:getAdvPropsId()
	local vo = self:getAcVo()
	if vo and vo.advPropsId then
		return Split(vo.advPropsId,"_")[2]
	end
end

--获取参与活动所需的道具及数量
function acFyssVoApi:getItemData()
	if self.acItemData == nil then
		local vo = self:getAcVo()
		if vo and vo.acProp then
			self.acItemData = {}
			for k, v in pairs(vo.acProp) do
				local _key = Split(k,"_")[2]
				self.acItemData[#self.acItemData+1]={key=_key,num=v,id=Split(_key,"p")[2]}
			end
			local function sortAsc(a, b)
	            if a.id and b.id and tonumber(a.id) and tonumber(b.id) then
	                return a.id < b.id
	            end
	        end
	        table.sort(self.acItemData,sortAsc)
		end
	end
	return self.acItemData or {}
end

--设置活动的道具数量
function acFyssVoApi:setItem(_data)
	local vo = self:getAcVo()
	if vo and _data then
		vo.existingItem = _data
	end
end

--获取已拥有的道具数量
function acFyssVoApi:getItemByNum(_itemKey)
	local vo = self:getAcVo()
	if vo and vo.existingItem then
		for k, v in pairs(vo.existingItem) do
			local _key = Split(k,"_")[2]
			if _key == _itemKey then
				return v
			end
		end
	end
	return 0
end

--获取已拥有的道具总数量
function acFyssVoApi:getItemTotalNum()
	local _num = 0
	local _itemData = self:getItemData()
	for k, v in pairs(_itemData) do
		_num = _num + self:getItemByNum(v.key)
	end
	return _num
end

--获取赠送等级限制
function acFyssVoApi:getGiveUpLevel()
	local vo = self:getAcVo()
	if vo and vo.giveUpLevel then
		return vo.giveUpLevel
	end
	return 0
end

--获取最大赠送次数
function acFyssVoApi:getMaxGiveUpCount()
	local vo = self:getAcVo()
	if vo and vo.maxGiveUpCount then
		return vo.maxGiveUpCount
	end
	return 150 --默认值
end

--设置当前赠送次数
function acFyssVoApi:setGiveUpCount(_num)
	if _num and type(_num)=="number" then
		self.giveUpCount = _num
	end
end

--获取当前赠送次数
function acFyssVoApi:getGiveUpCount()
	if self.giveUpCount then
		return self.giveUpCount
	end
	return 0
end

--是否赠送
function acFyssVoApi:isGiving(_uid,_itemKey)
	if self.givingTab then
		for k, v in pairs(self.givingTab) do
			if tostring(_uid) == tostring(k) then
				for n, m in pairs(v) do
					if Split(m, "_")[2] == _itemKey then
						return true
					end
				end
			end
		end
	end
	return false
end

function acFyssVoApi:setGivingTab(_data)
	if _data then
		self.givingTab = _data
	end
end

function acFyssVoApi:updateGivingTab(_uid,_itemKey)
	if self.givingTab then
		local _exisitKey = nil
		for k, v in pairs(self.givingTab) do
			if tostring(_uid) == tostring(k) then
				_exisitKey = k
				break
			end
		end
		local _key = "props_".._itemKey
		if _exisitKey ~= nil then
			table.insert(self.givingTab[_exisitKey],_key)
		else
			self.givingTab[tostring(_uid)] = {}
			self.givingTab[tostring(_uid)][1] = _key
		end
	end
end

function acFyssVoApi:setFriendTb(_friendTb)
	if _friendTb then
		self.friendTb = _friendTb
	end
end

function acFyssVoApi:getFriendTb(_itemKey)
	if self.friendTb then
		if _itemKey then
			local tab1,tab2={},{}
			for k,v in pairs(self.friendTb) do
				if self:isGiving(v.uid,_itemKey) then
					table.insert(tab2,v)
				else
					table.insert(tab1,v)
				end
			end
			local function sortAsc(a, b)
				if a.level and b.level then
					return tonumber(a.level) > tonumber(b.level)
				end
			end
			table.sort(tab1,sortAsc)
			table.sort(tab2,sortAsc)
			

			local tab1Size=SizeOfTable(tab1)
			local size=SizeOfTable(self.friendTb)
			self.friendTb={}
			for i=1,size do
				if tab1[i] then
					self.friendTb[i]=tab1[i]
				else
					self.friendTb[i]=tab2[i-tab1Size]
				end
			end
		end
		return self.friendTb
	end
	return {}
end

--获取抽奖的物品列表
function acFyssVoApi:getLotteryItemList()
	local vo = self:getAcVo()
	if vo and vo.lotteryPool then
		return vo.lotteryPool
	end
end

function acFyssVoApi:getFlicker()
	local vo = self:getAcVo()
	if vo and vo.flicker then
		return vo.flicker
	end
end

--格式化抽奖记录
function acFyssVoApi:formatLog(_data,addFlag)
	self.lotteryLog={}
	for k,v in pairs(_data) do
		local data=v
		local num=data[1]
		if num==2 then
			num=10
		else
			num=1
		end
		local rewards=data[2]
		local rewardlist={}
		for k,v in pairs(rewards) do
			local reward=FormatItem(v,nil,true)
			table.insert(rewardlist,reward[1])
		end
		local hxReward=self:getHxReward()
		if hxReward then
			hxReward.num=hxReward.num*num
			table.insert(rewardlist,1,hxReward)
		end
		local time=data[3] or base.serverTime
		local lcount=SizeOfTable(self.lotteryLog)
		if lcount>=10 then
			for i=10,lcount do
				table.remove(self.lotteryLog,i)
			end
		end
		if addFlag and addFlag==true then
	    	table.insert(self.lotteryLog,1,{num=num,reward=rewardlist,time=time})
		else
		    table.insert(self.lotteryLog,{num=num,reward=rewardlist,time=time})
		end
	end
end

--获取抽奖记录
function acFyssVoApi:getLotteryLog()
	if self.lotteryLog then
		return self.lotteryLog
	end
end

function acFyssVoApi:updateLastTime(_lastTime)
	local vo = self:getAcVo()
	if vo and _lastTime then
		vo.lastTime = _lastTime
	end
end

function acFyssVoApi:isToday()
	local vo = self:getAcVo()
	local isToday = false
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

--是否处于领奖时间
function acFyssVoApi:isRewardTime()
	local vo = self:getAcVo()
	if vo then
		if base.serverTime > vo.acEt-86400 and base.serverTime < vo.acEt then
			return true
		end
	end
	return false
end

--获取最大瓜分上限
function acFyssVoApi:getMaxbonus()
	local vo = self:getAcVo()
	if vo and vo.maxbonus then
		return vo.maxbonus
	end
	return 0
end

--0:没有瓜分资格,1:有瓜分资格,2:已领取瓜分奖励
function acFyssVoApi:getAcStatus()
	local vo = self:getAcVo()
	if vo and vo.acStatus then
		return vo.acStatus
	end
	return 0
end

--更新活动状态
function acFyssVoApi:updateAcStatus(_status)
	local vo = self:getAcVo()
	if vo and _status then
		vo.acStatus = _status
	end
end

function acFyssVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acFyssVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end

function acFyssVoApi:canReward(_acName)
	if self:isToday() == false and self:isRewardTime()==false then
        self:setUseFreeLotterNum(0)
    end
    if self:isFreeLottery() and self:isRewardTime()==false then
    	return true
    end
    if self:getAcStatus() == 1 and self:isRewardTime() then
    	return true
    end
    local exchangeData = self:getExchangeList()
    local listSize = SizeOfTable(exchangeData)
    local propCount = 0
    local itemData = self:getItemData()
    for k, v in pairs(itemData) do
    	if self:getItemByNum(v.key) > 0 then
    		propCount = propCount + 1
    	end
    end
    for k,v in pairs(exchangeData) do
    	if v.needNum==listSize and propCount >= v.needNum then
    		return true
    	end
    end
    local vo=self:getAcVo()
    if vo and vo.flag and vo.flag==1 then
    	return true
    end
    return false
end

function acFyssVoApi:updateFlag()
	local vo=self:getAcVo()
	if vo then
		vo.flag=nil
	end
end

function acFyssVoApi:addSub1Effect(_node,_pos)
	if _node then
        local label = GetTTFLabel("-1",24)
        label:setPosition(_pos)
        label:setColor(ccc3(255,0,0))
        label:setScale(0.2)
        local arr = CCArray:create()
        arr:addObject(CCScaleTo:create(0.3, 1.1))
        arr:addObject(CCScaleTo:create(0.1, 1))
        local arr1 = CCArray:create()
        arr1:addObject(CCMoveBy:create(0.3,ccp(-5,20)))
        arr1:addObject(CCFadeOut:create(0.8))
        arr:addObject(CCSpawn:create(arr1))
        arr:addObject(CCCallFunc:create(function()
            label:removeFromParentAndCleanup(true)
            label = nil
        end))
        label:runAction(CCSequence:create(arr))
        _node:addChild(label,999)
    end
end

--获取和谐版奖励
function acFyssVoApi:getHxReward()
	local vo = self:getAcVo()
	if vo and vo.hxReward then
		return FormatItem(vo.hxReward)[1]
	end
end

function acFyssVoApi:clearAll()
	self.acItemData=nil
	self.friendTb=nil
	self.lotteryLog=nil
	self.giveUpCount=nil
	self.givingTab=nil
end
