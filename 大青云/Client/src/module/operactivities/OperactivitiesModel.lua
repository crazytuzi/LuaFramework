--[[
OperactivitiesModel Model
2015-10-12 11:44:42
liyuan
]]
------------------------------------------------------------

_G.OperactivitiesModel = Module:new()

OperactivitiesModel.groupList = {}
OperactivitiesModel.groupSortArr = {}
OperactivitiesModel.iconStateList = {}--是否有奖励(1-有，0-没有, -1不显示)
---由于上线禁止反复申请首充团购充值  这里干脆就加个CD
OperactivitiesModel.firstTeamCharge = {}

-- OperactivitiesModel.maxPriority = 0

OperactivitiesModel.powerRankFirst = {}
OperactivitiesModel.powerRankList = {}
OperactivitiesModel.versionList = {}

OperactivitiesModel.isClickIconList = {}

OperactivitiesModel.IsCharge = false
local ONE_DAY = 24*60*60
local ONE_HOUR = 60*60

function OperactivitiesModel:init()
	self.iconStateList = {}
	for i = 1,9 do
		self.iconStateList[i] = {reward = -1, imageTxt = "", cnt = 0, new = 0}
	end
	TimerManager:RegisterTimer(function() Notifier:sendNotification(NotifyConsts.UpdateOperActBtnIconState) end,1000,0)
end

function OperactivitiesModel:SetIsCharge(value)
	self.IsCharge = value == 1;
	Notifier:sendNotification(NotifyConsts.UpdataShouChong);
end

function OperactivitiesModel:GetIsCharge()
	return self.IsCharge
end

-- 活动的6个按钮的状态
function OperactivitiesModel:UpdateOperActBtnState(msgObj)	
	self.iconStateList = {}
	for i = 1,9 do
		self.iconStateList[i] = {reward = -1, imageTxt = ""}
	end

	for k,v in pairs (msgObj.list) do
		if self.iconStateList[v.btnid] then
			self.iconStateList[v.btnid].reward = v.reward
			self.iconStateList[v.btnid].imageTxt = v.imageTxt
			self.iconStateList[v.btnid].cnt = v.cnt
			self.iconStateList[v.btnid].new = v.new
		end
	end
	UIMainYunYingFunc:DrawLayout()
	Notifier:sendNotification(NotifyConsts.UpdateOperActBtnIconState);
end

-- 运营活动的信息
function OperactivitiesModel:InitOperactivities(msgObj)
	FPrint('创建运营活动的信息')
	self.groupSortArr = {}
	local btn = 0
	for k,v in pairs (msgObj.list) do
		if not self.groupList[v.group] then
			self.groupList[v.group] = {}
		end
		
		if not self.versionList[v.group] then
			self.versionList[v.group] = 0
		end
		
		if v.btn == 2 then
			self:UpdateDaly(v.group, v)	
		else
			self:UpdateActInGroup(v.group, v)			
		end
		self:UpdateCurrentGroupList(v.group)	
		
		if btn == 0 then
			btn = v.btn
		end
	end
		
	table.sort(self.groupSortArr)	
	for k,v in pairs (self.groupList) do
		table.sort(v,function(A,B)
					if A.sort < B.sort then
						return true					
					else
						return false
					end		
				end)
	end
	
	Notifier:sendNotification(NotifyConsts.OperActivityInitInfo, {btn = btn});
	
end

function OperactivitiesModel:UpdateDaly(groupId, objAct)
	local actVO = self:GetFirstChargeActVO(2)
	
	if actVO then
		actVO:UpdateInfo(objAct)
	else
		local actVO = OperActVO:new(objAct)
		table.push(self.groupList[groupId], actVO)
	end
end

-- 往数据表里更新或插入数据
function OperactivitiesModel:UpdateActInGroup(groupId, objAct)	
	local actVO = nil
	local groupVO = self.groupList[groupId]
	for k,v in pairs(groupVO) do
		if v.id == objAct.id then
			actVO = v
			break
		end
	end	
	
	if actVO then
		actVO:UpdateInfo(objAct)
	else
		local actVO = OperActVO:new(objAct)
		table.push(self.groupList[groupId], actVO)
	end
end

-- 当前要显示的页签
function OperactivitiesModel:UpdateCurrentGroupList(groupId)
	for k, n in pairs(self.groupSortArr) do
		if n == groupId then
			return
		end
	end
	table.push(self.groupSortArr, groupId)	
end

-- 更新每组的数据
function OperactivitiesModel:UpdateOperactGroupInfo(msgObj)
	local groupId = msgObj.groupid
	if not self.groupList[groupId] then
		self.groupList[groupId] = {}
		for k, v in pairs(msgObj.list) do
			local actVO = OperActVO:new(v)
			actVO:UpdateInfo(v)
			table.push(self.groupList[groupId], actVO)
		end
	else
		for k,v in pairs (msgObj.list) do
			local bHave = false
			for groupk,groupv in pairs (self.groupList) do
				for actK, actV in pairs (groupv) do
					if actV.id == v.id then
						actV:UpdateInfo(v)	
						bHave = true
					end
				end			
			end
			if not bHave then
				local actVO = OperActVO:new(v)
				actVO:UpdateInfo(v)
				table.push(self.groupList[groupId], actVO)
			end
		end
	end
	
	self.versionList[groupId] = msgObj.version
	
	FPrint('更新每组的数据')
	-- FTrace(self.groupList)
	Notifier:sendNotification(NotifyConsts.UpdateGroupInfo, {groupId = groupId});
end

-- 运营活动的状态
function OperactivitiesModel:UpdateOperActState(msgObj)
	for k,v in pairs (msgObj.list) do
		for groupk,groupv in pairs (self.groupList) do
			for actK, actV in pairs (groupv) do
				if actV.id == v.id then
					actV:UpdateState(v)					
				end
			end			
		end
	end
	
	Notifier:sendNotification(NotifyConsts.OperActivityInitState);
end

-- 更新领奖状态
function OperactivitiesModel:UpdateOperActAwardState(msgObj)
	local actVO = self:GetActVOById(msgObj.id)
	-- if msgObj.ret == 0 then --领奖成功
		actVO.isAward = msgObj.ret
		actVO.count = msgObj.count
		if UIOperactivitesFirstRecharge.actId then
			if UIOperactivitesFirstRecharge.actId == msgObj.id then
				UIMainYunYingFunc:DrawLayout()
			end
		end		
		
		Notifier:sendNotification(NotifyConsts.UpdateOperActAwardState, {actId = msgObj.id, isAward = msgObj.ret});
	-- end	
end

-- 战力排行
function OperactivitiesModel:UpdatePowerRanking(msgObj)
	self.powerRankFirst = {}
	self.powerRankList = {}
	local firstVO = nil
	for k,v in pairs (msgObj) do
		if k == 'list' then	
			for listK, listV in pairs (msgObj.list) do
				if listV.rank == 1 then
					firstVO = {}					
					firstVO.name = listV.name
					firstVO.rank = listV.rank
					firstVO.val = listV.val
					table.push(self.powerRankList, firstVO)
				else
					local listVO = {}
					listVO.name = listV.name
					listVO.rank = listV.rank
					listVO.val = listV.val
					table.push(self.powerRankList, listVO)				
				end
			end
		else
			self.powerRankFirst[k] = v
		end
	end
	
	if not firstVO then
		firstVO = {}					
		firstVO.name = StrConfig['operactivites9']
		firstVO.rank = 1
		firstVO.val = 0
		table.push(self.powerRankList, firstVO)
	end
	
	if #self.powerRankList > 1 then
		table.sort(self.powerRankList,function(A,B)
						if A.rank < B.rank then
							return true					
						else
							return false
						end		
					end)
	end
	
	Notifier:sendNotification(NotifyConsts.UpdateOperActPowerList);
end

-- 更新团购信息
function OperactivitiesModel:UpdateTeamBuyInfo(msgObj)	
	for k,v in pairs (msgObj.list) do
		for groupk,groupv in pairs (self.groupList) do
			for actK, actV in pairs (groupv) do
				if actV.id == v.id then
					actV:UpdateTeamBuyState(v)					
				end
			end			
		end
	end
	Notifier:sendNotification(NotifyConsts.UpdateTeamBuyInfo);	
end

-- 更新首冲团购信息
function OperactivitiesModel:UpdateTeamBuyFirstInfo(msgObj)	
	-- local actVO = self:GetActVOByGroupId(msgObj.id)
	-- actVO.chargenum = msgObj.chargenum or 0
	
	local groupVO = self.groupList[msgObj.id]	
	for k, v in pairs (groupVO) do
		v.chargenum = msgObj.chargenum or 0
		v.chargerealnum = msgObj.chargerealnum or 0
	end	
	
	Notifier:sendNotification(NotifyConsts.UpdateTeamBuyFirstInfo);	
end

-- 更新团购购买结果
function OperactivitiesModel:UpdateTeamBuyResult(msgObj)	

	for groupk,groupv in pairs (self.groupList) do
		for actK, actV in pairs (groupv) do
			if actV.id == msgObj.id then
				actV.mypurchase = msgObj.mypurchase	
				actV.totalpurchase = msgObj.totalpurchase
			end
		end			
	end

	Notifier:sendNotification(NotifyConsts.UpdateTeamBuyInfo);	
end

----------------------------对外接口---------------------------------------------------------

-- 运营活动的版本号
function OperactivitiesModel:GetOperActIndex(groupId)
	return self.versionList[groupId] or 0
end

-- 活动时间是否符合条件
function OperactivitiesModel:GetOperActGroupIsShow(groupId)
	local actVO = self:GetActVOByGroupId(groupId)
	-- FTrace(actVO)	
	local startTime = 0
	if actVO.openTimeStart ~= -1 then
		-- 相对开服时间		
		startTime = _G.GetZeroTime(_G.serverSTime) + actVO.openTimeStart*ONE_HOUR		
		FPrint('相对开服时间')
	elseif actVO.mergeTimeStart ~= -1 then
		-- 相对和服时间
		startTime = _G.GetZeroTime(_G.mergeSTime) + actVO.mergeTimeStart*ONE_HOUR
		FPrint('相对和服时间')
	else
		-- 绝对开启时间
		local dateList = split(actVO.openTimeAb, '-')
		startTime = _G.GetTimeByDate(dateList[1], dateList[2], dateList[3], dateList[4], dateList[5], dateList[6])
		FPrint('绝对开启时间')
	end
	local endTime = startTime + actVO.lastTime*ONE_HOUR
	
	local serverTime = GetServerTime()	
	FPrint(startTime..':'..serverTime..':'..endTime)
	if serverTime >= startTime and serverTime <= endTime then
		return true
	end
	FPrint('开服时间：'.. _G.serverSTime)
	FPrint('开服零点'.._G.GetZeroTime(_G.serverSTime))
	FPrint('不符合活动时间条件')
	-- debug.debug()
	return false
end
-- 活动优先级是否符合条件
function OperactivitiesModel:GetPriorityIsShow(groupId)
	local actVO = self:GetActVOByGroupId(groupId)
	if actVO.absolutePriority then 
		return true 
	end
	if actVO.priority == self.maxPriority then 
		return true 
	end
	FPrint('不符合活动优先级条件')
	-- debug.debug()
	return false
end

-- 前置活动是否符合条件
function OperactivitiesModel:GetNeedActivityIsShow(groupId)
	local groupVO = self.groupList[groupId]
	
	for k, v in pairs (groupVO) do
		if v.needActivity and v.needActivity ~= 0 then
			local preGroupVO = self.groupList[v.needActivity]
			for preK, preV in pairs (preGroupVO) do
				if preV.isAward ~= 2 then
					FPrint('不符合前置活动条件')
					return false
				end
			end
		end
	end
	
	-- debug.debug()
	return true
end

-- 设置活动最高优先级
function OperactivitiesModel:SetPriorityMax(actList)
	local maxLv = 0
	for k,v in pairs (actList) do
		maxLv = math.max(v.priority, maxLv)
	end
	
	self.maxPriority = maxLv
end

-- 4个按钮的状态
function OperactivitiesModel:GetOperBtnState(iconType)
	-- FPrint(iconType..':'..self.iconStateList[iconType].reward)
	if not self.iconStateList then
		return {reward = -1}
	end
	
	if not self.iconStateList[iconType] then 
		return {reward = -1}
	end
	
	return self.iconStateList[iconType]
end

-- 根据groupId获得运营活动类型
function OperactivitiesModel:GetOperActType(groupId)
	local groupVO = self.groupList[groupId]
	
	if not groupVO or #groupVO <= 0 then FPrint('error:没有找到属于groupId:'..groupId..'的运营活动') return nil end
	
	local actVO = groupVO[1]
	
	if not actVO then FPrint('error:没有找到属于groupId:'..groupId..'的运营活动') return nil end
	
	-- FPrint('根据groupId获得运营活动类型'..actVO.id)
	return actVO.mainType, actVO.subType
end

function OperactivitiesModel:GetOperActType1(groupId)
	local mainType, subType
	local groupVO = self.groupList[groupId]
	for k, v in pairs(groupVO) do
		if not mainType then
			mainType = v.mainType
			subType = v.subType
		elseif mainType ~= v.mainType then
			return v.mainType, v.subType
		end
	end
end

-- 得到首冲的运营活动
function OperactivitiesModel:GetFirstChargeActVO(iconType)
	FPrint('得到首冲的运营活动, btn:'..iconType)
	for k, n in pairs(OperactivitiesModel.groupList) do
		for i, v in pairs(n) do
			if iconType == v.btn then
				FPrint('得到首冲的运营活动, actId'..v.id)
				return v
			end
		end
	end
	
	return nil
end

--得到一组的一个运营活动
function OperactivitiesModel:GetGroupVo(iconType)
	for k, n in pairs(OperactivitiesModel.groupList) do
		for i, v in pairs(n) do
			if iconType == v.btn then
				return v, k
			end
		end
	end
end


--获取按钮下的兑换的可操作数
function OperactivitiesModel:GetExchangeNumByBtn(iconType)
	local count = 0
	for k, v in pairs(self.groupList) do
		for k1, v1 in pairs(v) do
			local time = self:GetAcRemainTime(v1)
			if time > 0 then
				if iconType == v1.btn and (v1.mainType == 3 or v1.mainType == 104) then
					local num = v1:GetIsArawdState()
					if num == 1 then
						count = count + 1
					end
				else
					break
				end
			end
		end
	end
	return count
end

-- 拿抽奖的活动
function OperactivitiesModel:GetAwardGroup()
	return self.groupSortArr[1]
end

-- 得到一个组的groupTxt
function OperactivitiesModel:GetGroupTxtByGroupId(groupId)
	local actVO = self:GetActVOByGroupId(groupId)
	
	return actVO.groupTxt or 'groupTxt'
end

-- 得到一个组的广告图
function OperactivitiesModel:GetGroupImageByGroupId(groupId)
	local actVO = self:GetActVOByGroupId(groupId)
	
	return actVO.imagePic or ''
end

-- 得到一个组的可领奖励数
function OperactivitiesModel:GetGroupAwardNumById(groupId)
	local groupVO = self.groupList[groupId]
	local num = 0
	for i, v in pairs(groupVO) do
		if self:GetAcRemainTime(v) > 0 then
			local reward1,reward2,reward3,reward4 = v:GetIsArawdState()
			if reward1 == 1 then
				num = num + 1
			end
			if reward2 == 1 then
				num = num + 1
			end
			if reward3 == 1 then
				num = num + 1
			end
			if reward4 == 1 then
				num = num + 1
			end
		end
	end
	
	return num
end

-- 得到一个组的开始时间 秒（是否是第一天）
function OperactivitiesModel:GetStartIsFirstDay(groupId)
	local actVO = self:GetActVOByGroupId(groupId)
	local startTime = 0
	if actVO.openTimeStart ~= -1 then
		-- 相对开服时间
		startTime = _G.GetZeroTime(_G.serverSTime) + actVO.openTimeStart*ONE_HOUR		
	elseif actVO.mergeTimeStart ~= -1 then
		-- 相对和服时间
		startTime = _G.GetZeroTime(_G.mergeSTime) + actVO.mergeTimeStart*ONE_HOUR
	else
		-- 绝对开启时间
		local dateList = split(actVO.openTimeAb, '-')
		startTime = _G.GetTimeByDate(dateList[1], dateList[2], dateList[3], dateList[4], dateList[5], dateList[6])
	end
	
	local diff = startTime - _G.GetZeroTime(_G.serverSTime)
	FPrint('是否是第一天'..math.ceil(diff/ONE_DAY))
	if diff > ONE_DAY then
		return false
	end

	return true
end

-- 得到一个组的剩余时间 秒 1剩余时间 2剩余结算时间 2剩余领奖时间
function OperactivitiesModel:GetGroupRemainTimeByGroupId(groupId)
	local actVO = self:GetActVOByGroupId(groupId)
	local startTime = 0
	local timeType = 1
	if actVO.openTimeStart ~= -1 then
		-- 相对开服时间
		startTime = _G.GetZeroTime(_G.serverSTime) + actVO.openTimeStart*ONE_HOUR		
	elseif actVO.mergeTimeStart ~= -1 then
		-- 相对和服时间
		startTime = _G.GetZeroTime(_G.mergeSTime) + actVO.mergeTimeStart*ONE_HOUR
	else
		-- 绝对开启时间
		local dateList = split(actVO.openTimeAb, '-')
		startTime = _G.GetTimeByDate(dateList[1], dateList[2], dateList[3], dateList[4], dateList[5], dateList[6])
	end
	FPrint('开服时间'.._G.GetZeroTime(_G.serverSTime))
	local endTime = 0
	endTime = startTime + actVO.lastTime*ONE_HOUR
	local serverTime = GetServerTime()
	local remainTime = endTime - serverTime	
	
	if actVO.mainType == 4 then
		endTime = startTime + actVO.rewardTime*ONE_HOUR
		remainTime = endTime - serverTime
		timeType = 2
		
		if remainTime <= 0 then
			endTime = startTime + actVO.lastTime*ONE_HOUR
			remainTime = endTime - serverTime
			timeType = 3
		end
	end	
		
	if remainTime <= 0 then remainTime = 0 end
	
	return remainTime, timeType
end

-- 根据活动获取活动时间
function OperactivitiesModel:GetAcRemainTime(actVO)
	local startTime = 0
	local timeType = 1
	if actVO.openTimeStart ~= -1 then
		-- 相对开服时间
		startTime = _G.GetZeroTime(_G.serverSTime) + actVO.openTimeStart*ONE_HOUR		
	elseif actVO.mergeTimeStart ~= -1 then
		-- 相对和服时间
		startTime = _G.GetZeroTime(_G.mergeSTime) + actVO.mergeTimeStart*ONE_HOUR
	else
		-- 绝对开启时间
		local dateList = split(actVO.openTimeAb, '-')
		startTime = _G.GetTimeByDate(dateList[1], dateList[2], dateList[3], dateList[4], dateList[5], dateList[6])
	end
	FPrint('开服时间'.._G.GetZeroTime(_G.serverSTime))
	local endTime = 0
	endTime = startTime + actVO.lastTime*ONE_HOUR
	local serverTime = GetServerTime()
	local remainTime = endTime - serverTime	
	
	if actVO.mainType == 4 then
		endTime = startTime + actVO.rewardTime*ONE_HOUR
		remainTime = endTime - serverTime
		timeType = 2
		
		if remainTime <= 0 then
			endTime = startTime + actVO.lastTime*ONE_HOUR
			remainTime = endTime - serverTime
			timeType = 3
		end
	end	
		
	if remainTime <= 0 then remainTime = 0 end
	
	return remainTime, timeType
end

-- 得到一个组的开启了多长时间 秒
function OperactivitiesModel:GetGroupStartTimeByGroupId(groupId)
	local actVO = self:GetActVOByGroupId(groupId)
	local startTime = 0
	if actVO.openTimeStart ~= -1 then
		-- 相对开服时间
		startTime = _G.GetZeroTime(_G.serverSTime) + actVO.openTimeStart*ONE_HOUR		
	elseif actVO.mergeTimeStart ~= -1 then
		-- 相对和服时间
		startTime = _G.GetZeroTime(_G.mergeSTime) + actVO.mergeTimeStart*ONE_HOUR
	else
		-- 绝对开启时间
		local dateList = split(actVO.openTimeAb, '-')
		startTime = _G.GetTimeByDate(dateList[1], dateList[2], dateList[3], dateList[4], dateList[5], dateList[6])
	end
	
	local serverTime = GetServerTime()
	local startTime = serverTime - startTime
	
	return startTime
end

-- 得到一个组的第一个运营活动
function OperactivitiesModel:GetActVOByGroupId(groupId)
	local groupVO = OperactivitiesModel.groupList[groupId]
	local actVO = groupVO[1]
	
	return actVO
end

-- 得到抽奖的当前子活动
function OperactivitiesModel:GetAwardVo(groupId)
	local groupVO = self.groupList[groupId]
	if not groupVO then return end
	for k, v in ipairs(groupVO) do
		if v.isAward ~= 2 then
			return v, k
		end
	end
	return groupVO[#groupVO], #groupVO
end

-- 得到一个运营活动byid
function OperactivitiesModel:GetActVOById(actId)
	for k, n in pairs(OperactivitiesModel.groupList) do
		for i, v in pairs(n) do
			if actId == v.id then
				return v
			end
		end
	end
	
	return nil
end

-- 区一个活动的进度
function OperactivitiesModel:GetActPrecess(actId)
	local actVO = self:GetActVOById(actId)
	local progress = actVO.progress or 0
	local total = 0
	if actVO.mainType == 1 and actVO.subType == 0 then--累积充值
		total = actVO.param	
	elseif actVO.mainType == 2 and actVO.subType == 0 then --连续充值
		local paramList = split(actVO.param, ',')
		total = paramList[2]
	elseif actVO.mainType == 5 then 
		total = actVO.param	
	elseif actVO.mainType == 7  then 
		total = actVO.param	
	elseif actVO.mainType == 8 then --连续充值
		if actVO.subType == 2 then
			total = actVO.param	
		elseif  actVO.subType == 3 then
			return progress..'/11'
		elseif  actVO.subType == 4 then
			total = actVO.param	
		elseif  actVO.subType == 5 then
			return progress..'/11'
		elseif  actVO.subType == 6 then
			return progress..'/11'
		elseif  actVO.subType == 8 then
			total = actVO.param	
		elseif  actVO.subType == 9 then
			total = actVO.param	
		elseif  actVO.subType == 10 then
			total = actVO.param	
		elseif  actVO.subType == 11 then
			total = actVO.param	
		end		
	elseif actVO.mainType == 9  then 
		total = actVO.param	
	elseif actVO.mainType == 102  then 
		total = actVO.param	
	end
	
	if not total then return "" end
	
	if toint(total) == 0 then
		return ""
	end
	
	if progress > toint(total) then
		progress = total
	end
	return progress..'/'..total		
end

-- 取团购的获奖字段
function OperactivitiesModel:GetTeamAwardStateByFlag(vipflag, index)
	local temp = vipflag
	temp = bit.rshift(bit.lshift(temp,32-index),31)
	return temp
end

-- 团购是否可以领奖 
function OperactivitiesModel:GetTeamBuyIsAward(actVO, index)
	if not actVO.isAward then return 0,'' end
	local resType = 1
	local resStr = ""
	if not actVO or not actVO.isAward then return 0, "" end
	if self:GetTeamAwardStateByFlag(actVO.isAward, index) == 1 then
		return 2, StrConfig['operactivites15']
	end
	if not actVO.param then return 0,'' end	
	local paramList = split(actVO.param, ',')
	if not actVO.totalpurchase then return 0,'' end	
	FPrint('全服总购买次数'..actVO.totalpurchase..','..paramList[index])
	if actVO.totalpurchase < toint(paramList[index]) then-- 全服总购买次数 > param里的值 return false
		resType = 0
		resStr = resStr .. string.format(StrConfig['operactivites11'], toint(paramList[index])) .. '<br/>'
	end
	
	if not actVO.groupbuyRequire then return 0,'' end
	local buyRequire = split(actVO.groupbuyRequire, '#')
	local v = buyRequire[index]
	
	local itemReq = split(v, ',')
	local reqType = toint(itemReq[1])
	local reqValue = toint(itemReq[2])
	if reqType == 1 then --是否充值
		if not self:GetIsCharge() then
			resType = 0
			resStr = resStr .. StrConfig['operactivites12']
		end
	elseif reqType == 2 then--自己的购买次数
		if not actVO.mypurchase then return 0,',' end
		if actVO.mypurchase < reqValue then
			resType = 0
			resStr = resStr .. string.format(StrConfig['operactivites13'], reqValue)
		end	
	end
	
	return resType, resStr
end

-- 首冲团购是否可以领奖 
function OperactivitiesModel:GetTeamBuyFirstIsAward(actVO, index)
	if not actVO.isAward then return 0,'' end
	FPrint('首冲团购是否可以领奖1')
	local resType = 1
	local resStr = "" 
	if not actVO or not actVO.isAward then return 0, "" end
	FPrint('首冲团购是否可以领奖2')
	if self:GetTeamAwardStateByFlag(actVO.isAward, index) == 1 then
		return 2, StrConfig['operactivites15']
	end
	FPrint('首冲团购是否可以领奖3')
	if not actVO.param then return 0,'' end	
	FPrint('首冲团购是否可以领奖4')
	local paramList = split(actVO.param, ',')
	if index > #paramList then return 0,'' end
	FPrint('首冲团购是否可以领奖5')
	if not actVO.chargenum then return 0,'' end
	FPrint('首冲团购是否可以领奖6')
	FPrint('首冲团购总购买次数'..actVO.chargenum..','..paramList[index])
	if actVO.chargenum < toint(paramList[index]) then-- 首冲团购总购买次数 > param里的值 return false
		resType = 0
		resStr = resStr .. string.format(StrConfig['operactivites11'], toint(paramList[index])) .. '<br/>'
	end
	
	if not actVO.groupbuyRequire then return 0,'' end
	FPrint('首冲团购是否可以领奖7')
	local buyRequire = split(actVO.groupbuyRequire, '#')
	local v = buyRequire[index]
	
	local itemReq = split(v, ',')
	local reqType = toint(itemReq[1])
	local reqValue = toint(itemReq[2])
	FPrint('首冲团购是否可以领奖'..reqType..','..reqValue)
	if reqType == 1 then --是否充值
		if not self:GetIsCharge() then
			FPrint('首冲团购是否可以领奖8')
			resType = 0
			resStr = resStr .. StrConfig['operactivites12']
		end
	elseif reqType == 2 then--vip类型		
		if not VipController:GetPowerByType(reqValue) then
			resType = 0
			local vipName = VipConsts.TYPE_NAME[reqValue] or ''
			resStr = resStr .. StrConfig['operactivites37'].. vipName ..'vip'
		end
	elseif reqType == 3 then--vip等级
		local vipLevel = VipController:GetVipLevel()
		if vipLevel < reqValue then
			resType = 0
			resStr = resStr .. StrConfig['operactivites36'].. reqValue ..StrConfig['operactivites25']
		end	
	end
	
	return resType, resStr
end

-- 累计充值
function OperactivitiesModel:GetTotalMoney(groupId)
	local groupVO = self.groupList[groupId]
	local minMoney = 0

	for k, v in pairs (groupVO) do	
		if not v.param then v.param = 0 end
		if not v.receiveTime then v.receiveTime = 0 end
		if not v.count then v.count = 0 end		
		if not v.progress then v.progress = 0 end
		if not v.progress1 then v.progress1 = 0 end
		if v.receiveTime <= 1 then	
			minMoney = math.max(minMoney, v.progress)		
		end
	end

	return minMoney
end

-- 累计充值
function OperactivitiesModel:GetTotalMoney1(groupId)
	local groupVO = self.groupList[groupId]
	local minMoney = 0

	for k, v in pairs (groupVO) do	
		if not v.param then v.param = 0 end
		if not v.receiveTime then v.receiveTime = 0 end
		if not v.count then v.count = 0 end		
		if not v.progress then v.progress = 0 end
		if not v.progress1 then v.progress1 = 0 end
		if v.receiveTime <= 1 then	
			minMoney = math.max(minMoney, v.progress1)		
		end
	end

	return minMoney
end

--获取首冲团购人数
function OperactivitiesModel:GetTotalPeople(groupId)
	local groupVO = self.groupList[groupId]
	if not groupVO then return 0 end
	for k, v in pairs(groupVO) do
		if not v.chargenum then return 0 end
		return v.chargenum
	end
end

-- 3d场景
function OperactivitiesModel:GetModelScene(showModelStr)
	FPrint('OperactivitiesModel:GetModelScene'..showModelStr)
	local modelStr = showModelStr
	local showModel = ''
	if modelStr and modelStr ~= "" then
		local modelProfList = split(modelStr, ',')
		if modelProfList and #modelProfList == 4 then
			local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
			showModel = modelProfList[prof]
		else
			showModel = modelStr
		end
	end
	FPrint(showModel)
	return showModel
end

-- 兑换的道具id
function OperactivitiesModel:GetExchangeItemList(groupId)
	local resItemList = {}
	local groupVO = self.groupList[groupId]
	
	for k, v in pairs (groupVO) do
		local itemList = v:GetConsumeItemIdList()
		if itemList then
			for i, n in pairs (itemList) do
				table.push(resItemList, n)
			end
		end
	end
	
	return resItemList
end

function OperactivitiesModel:GoRewardfun(vipbtn, rewardList)
	local startPos = UIManager:PosLtoG(vipbtn,0,0);
	--奖励
	-- local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
	local rewardList = RewardManager:ParseToVO(rewardList);
	local startPos = UIManager:PosLtoG(vipbtn,0,0);
	RewardManager:FlyIcon(rewardList,startPos,5,true,60);
	SoundManager:PlaySfx(2041);
end;