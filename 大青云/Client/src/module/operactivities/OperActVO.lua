--[[
运营活动基类
2015-10-12 11:44:42
liyuan
]]
------------------------------------------------------------
_G.OperActVO = {};

-- OperActVO.id = nil --ID
-- OperActVO.open = nil --活动开启
-- OperActVO.btn = nil --活动按钮图标
-- OperActVO.group  = nil --组id
-- OperActVO.priority = nil --优先级ID
-- OperActVO.needActivity = nil --前置活动
-- OperActVO.sort = nil --UI内排序
-- OperActVO.absolutePriority = nil --绝对优先
-- OperActVO.openTimeAb  = nil --绝对开启时间
-- OperActVO.openTimeStart = nil --相对开启时间
-- OperActVO.lastTime = nil --持续时间
-- OperActVO.rewardTime = nil --结算时间
-- OperActVO.mainType = nil --活动类型
-- OperActVO.subType = nil --活动子类型
-- OperActVO.param = nil --参数
-- OperActVO.reward = nil --奖励内容
-- OperActVO.receiveTime = nil --领取次数
-- OperActVO.imageTxt = nil --美术字标题
-- OperActVO.consumeList = str   --兑换消耗{ID=1}
-- OperActVO.modelList = str --3D模型展示{ID=1}

-- OperActVO.isAward = nil--是否有奖励(1-有，0-没有)
-- OperActVO.progress = nil--当前进度
-- OperActVO.count = nil--当前次数

-- OperActVO.mypurchase 我的购买次数
-- OperActVO.totalpurchase 总的购买

function OperActVO:new(operActObj)
	local obj = setmetatable({},{__index=self});
	
	obj.id = operActObj.id or 0 --comment=ID
	obj.open = operActObj.open or 0 --comment=活动开启
	obj.btn = operActObj.btn or 0 --comment=活动按钮图标
	obj.group = operActObj.group or 0 --comment=组id
	obj.priority = operActObj.priority or 0 --comment=优先级ID
	obj.needActivity = operActObj.needActivity or 0 --comment="前置活动"/>
	obj.sort = operActObj.sort or 0 --comment="UI内排序"/>
	obj.absolutePriority = operActObj.absolutePriority or 0 --comment="绝对优先"/>
	obj.groupName = operActObj.groupName or '' -- comment="活动名称"/>
	obj.openTimeAb = operActObj.openTimeAb or '' -- comment="绝对开启时间"/>
	obj.openTimeStart = operActObj.openTimeStart or 0 --comment="相对开启时间"/>
	obj.mergeTimeStart = operActObj.mergeTimeStart or 0 --comment="相对合服开启时间"/>
	obj.lastTime = operActObj.lastTime or 0 --comment="持续时间"/>
	obj.rewardTime = operActObj.rewardTime or 0 --comment="结算时间"/>
	obj.mainType = operActObj.mainType or 0 --comment="活动类型"/>
	obj.subType = operActObj.subType or 0 --comment="活动子类型"/>
	
	-- obj.chargenum = 0
	-- obj.param = '' --comment="参数"/>
	-- obj.reward = '' --comment="奖励内容"/>
	-- obj.receiveTime = 0 --comment="领取次数"/>
	-- obj.groupbuyPrice = 0 --comment="团购售价"/>
	-- obj.groupTxt = '' --comment="活动描述"/>
	-- obj.eachTxt = '' --comment="奖励描述"/>
	-- obj.imageTxt = '' --comment="美术字标题"/>
	-- obj.imagePic = '' --comment="美术图片"/>
	-- obj.consume = '' --comment="兑换消耗"/>
	-- obj.groupbuyRequire = '' --comment="团购额外需求"/>
	-- obj.showModel = '' --comment="3D模型展示"/>
	-- obj.groupbuyItem = {}
	-- obj.mypurchase = 0 --comment="我的购买次数" />
	-- obj.totalpurchase = 0 --comment="总的购买"/>
	-- obj.isAward = 0 --comment="是否已领取，(0 - 没有， 1 - 可领， 2 - 已领)团购（1,首冲，2，一次购买， 4， 二次购买 8，三次购买）"/>
	-- obj.progress = 0 --comment="当前进度，总进度在param里"/>
	-- obj.count = 0 --comment="已领次数，总次数在receiveTime(团购的是否达成首冲1达成0未达成)"/>
	
	return obj
end

function OperActVO:UpdateState(stateObj)
	self.isAward = stateObj.isAward
	self.progress = stateObj.progress
	self.progress1 = stateObj.progress2
	self.param1 = stateObj.param1
	self.param2 = stateObj.param2
	self.param3 = stateObj.param3
	self.count = stateObj.count	
end

function OperActVO:UpdateTeamBuyState(stateObj)
	self.mypurchase = stateObj.mypurchase
	self.totalpurchase = stateObj.totalpurchase
end

function OperActVO:UpdateInfo(stateObj)
	for k, v in pairs(stateObj) do		
		self[k] = v		
	end	
end

function OperActVO:GetIsArawdState()
	if not self.isAward then return 0 end
	
	if self.mainType == 101 then--团购
		local isAward1 = self:GetTeamBuyIsAward(1)
		local isAward2 = self:GetTeamBuyIsAward(2)
		local isAward3 = self:GetTeamBuyIsAward(3)
		local isAward4 = self:GetTeamBuyIsAward(4)
		return isAward1,isAward2,isAward3,isAward4
	elseif self.mainType == 104 then
		local isAward1 = self:GetTeamBuyFirstIsAward()
		--这个104的逻辑被改掉了
		return isAward1
	elseif self.mainType == 3 then--兑换
		if not self.count then return 0 end
		if not self.receiveTime then return 0 end
		
		local getcount = self.count or 0
		local num = self.receiveTime - getcount
		if not num or num <= 0 then return 2 end
	
		-- FPrint('兑换')
		if self.consume and self.consume ~= '' then
			local consumeList = split(self.consume, '#')
			-- FPrint('兑换'..self.consume)
			local awardState = 1
			for k,v in pairs (consumeList) do
				local itemList = split(v, ',')
				local itemId = toint(itemList[1])
				local itemNum = toint(itemList[2])
				
				if self:CheckItemNum(itemId, itemNum) == 0 then
					awardState = 0
				end
			end	
			
			return awardState
		end		
	end
	
	return self.isAward	
end

function OperActVO:CheckItemNum(itemId, itemNum)	
	local hasNum = 0
	local playerInfo = MainPlayerModel.humanDetailInfo
	if itemId == 13 then
		hasNum = playerInfo.eaBindMoney					
		--绑元 绑定银两eaBindMoney    = 13
	elseif itemId == 10 then
		--银两 
		--eaBindGold     = 10,    --绑定金币          
		--eaUnBindGold   = 11,    --非绑定金币
		hasNum = playerInfo.eaBindGold+playerInfo.eaUnBindGold						
	elseif itemId == 11 then
		--eaUnBindGold   = 11,    --非绑定金币
		hasNum = playerInfo.eaUnBindGold
	elseif itemId == 12 then
		--eaUnBindMoney  = 12,    --元宝
		hasNum = playerInfo.eaUnBindMoney	
	elseif itemId == 14 then
		--eaZhenQi       = 14,    --灵力
		hasNum = playerInfo.eaZhenQi	
	else
		--背包中的数量
		hasNum = BagModel:GetItemNumInBag(itemId) or 0 
	end
	if hasNum < itemNum then
		return 0
	else 
		return 1
	end
end

function OperActVO:GetConsumeItemIdList()
	local resList = nil	
	if self.mainType == 3 then--兑换
		--if not self.consume then return nil end
		if self.consume and self.consume ~= '' then
			resList = {}
			local consumeList = split(self.consume, '#')
			for k,v in pairs (consumeList) do
				local itemList = split(v, ',')
				local itemId = toint(itemList[1])
				table.push(resList, itemId)
			end		
		end				
	end
	
	return resList
end

-- 团购
function OperActVO:GetTeamBuyIsAward(index)	
	if not self.isAward then return 0 end	
	
	if self:GetTeamAwardStateByFlag(self.isAward, index) == 1 then
		-- FPrint('团购1')
		return 2
	end
	
	if not self.param then return 0 end	
	
	local paramList = split(self.param, ',')
	if not self.totalpurchase then return 0 end	
	if self.totalpurchase < toint(paramList[index]) then-- 全服总购买次数 < param里的值 return false
		-- FPrint('团购3')
		return 0	
	end
	
	if not self.groupbuyRequire then return 0 end
	local buyRequire = split(self.groupbuyRequire, '#')
	local v = buyRequire[index]
	
	local itemReq = split(v, ',')
	local reqType = toint(itemReq[1])
	local reqValue = toint(itemReq[2])
	if reqType == 1 then --是否充值
		if not OperactivitiesModel:GetIsCharge() then
			-- FPrint('团购4')
			return 0
		end
	elseif reqType == 2 then--自己的购买次数
		if not self.mypurchase then return 0 end
		if self.mypurchase < reqValue then
			-- FPrint('团购5')
			return 0
		end
	end
	-- FPrint('团购6')
	return 1
end

--首冲团购人数是否够
function OperActVO:GetFirstChargePeopleIsDacheng()
	if self.mainType ~= 104 then
		return false
	else
		if not self.param then return false end
		local paramList = split(self.param, ',')
		if #paramList == 0 then return false end
		local chargenum = self.chargenum
		if not chargenum then return 0 end
		if chargenum < toint(paramList[1]) then
			return false
		end
		return true
	end
end

-- 团购
function OperActVO:GetTeamBuyFirstIsAward()	
	if not self.isAward then return 0 end	
	
	if self:GetTeamAwardStateByFlag(self.isAward, 1) == 1 then
		--print('团购1')
		return 2
	end
	if not self.param then return 0 end	
	local paramList = split(self.param, ',')
	if #paramList == 0 then return 0 end
	local chargenum = self.chargenum
	-- if self.mainType == 104 then
	-- 	chargenum = self.chargerealnum
	-- end	
	if not chargenum then
		local curTime = GetCurTime(1)
		if not OperactivitiesModel.firstTeamCharge[self.group] then
			OperactivitiesModel.firstTeamCharge[self.group] = curTime
		end
		if curTime - OperactivitiesModel.firstTeamCharge[self.group] > 3 then
			OperactivitiesController:ReqPartyGroupPurchaseFirst(self.group)
		end
		return 0 
	end
	if chargenum < toint(paramList[1]) then-- 全服总购买次数 < param里的值 return false
		-- print('团购3')
		return 0	
	end
	if not self.groupbuyRequire then return 0 end
	local buyRequire = split(self.groupbuyRequire, '#')
	local v = buyRequire[1]

	local itemReq = split(v, ',')
	local reqType = toint(itemReq[1])
	local reqValue = toint(itemReq[2])
	if reqType == 1 then --是否充值
		if not OperactivitiesModel:GetIsCharge() then
			-- print('团购4')
			return 0
		end
	elseif reqType == 2 then--vip类型		
		if not VipController:GetPowerByType(reqValue) then
			return 0
		end
	elseif reqType == 3 then--vip等级
		local vipLevel = VipController:GetVipLevel()
		if vipLevel < reqValue then
			return 0
		end
	end
	-- print('团购6')
	return 1
end

-- 取团购的获奖字段
function OperActVO:GetTeamAwardStateByFlag(vipflag, index)
	local temp = vipflag
	temp = bit.rshift(bit.lshift(temp,32-index),31)
	return temp
end