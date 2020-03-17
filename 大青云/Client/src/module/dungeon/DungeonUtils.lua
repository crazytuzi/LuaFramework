--[[
副本 工具类
郝户
2014年11月19日10:47:09
]]

_G.DungeonUtils = {};

-- 获取副本组相关配置信息
function DungeonUtils:GetGroupCfgInfo(group)
	for id, cfg in pairs( _G.t_dungeons ) do
		-- 只取得最小进入等级的数据
		if cfg.group == group and cfg.id % 100 == 1 then   -- cfg.difficulty == DungeonConsts.Normal
			local config = {}
			config.name         = cfg.name
			config.img          = cfg.img
			config.name_img     = cfg.name_img
			config.des_bg       = cfg.des_bg
			config.des_img      = cfg.des_img
			config.unlock_level = cfg.unlock_level
			config.show_type    = cfg.show_type
			config.reward_type  = cfg.reward_type
			config.min_level    = cfg.min_level  -- 最小等级每个难度不一样，取最简单难度的
			config.max_level    = cfg.max_level
			config.type         = cfg.type
			config.free_times   = cfg.free_times
			config.pay_times    = cfg.pay_times
			config.pay_item     = cfg.pay_item
			config.pay_itemdaiti= cfg.pay_itemdaiti
			config.output       = cfg.output
			config.output_img   = cfg.output_img
			config.funcID       = cfg.funcID
			return config
		end
	end
	return nil
end

-- 根据副本组与难度获取副本id (组1难度1 id=101)
function DungeonUtils:GetDungeonId( group, difficulty )
	return 100 * group + difficulty; 
end

-- 获取通关时间
function DungeonUtils:GetPassTime( group, difficulty )
	local dungeonId = self:GetDungeonId( group, difficulty );
	local dungeonGroup = DungeonModel:GetDungeonGroup( group );
	return dungeonGroup:GetMyTimeOfDifficulty( group )
end

-- 进入条件是否已达成
function DungeonUtils:CheckCanEnter( group, difficulty )
	local dungeonGroup = DungeonModel:GetDungeonGroup( group )
	return dungeonGroup:GetCurrentCanEnterDifficulty() >= difficulty
end

-- 获取进入条件描述文本
function DungeonUtils:GetConditionDes( dungeonId )
	local des = "";
	local cfg = t_dungeons[dungeonId];
	if not cfg then return end
	local group = cfg.group
	local difficulty = cfg.difficulty
	local canEnter = DungeonUtils:CheckCanEnter( group, difficulty )
	if canEnter then
		des = StrConfig["dungeon237"];
	else
		local cfg = t_dungeons[dungeonId];
		if not cfg then return end
		local needLvl = cfg.min_level;
		local playerLvl = MainPlayerModel.humanDetailInfo.eaLevel;
		if playerLvl < needLvl then
			des = string.format( StrConfig['dungeon236'], needLvl );
		else
			if difficulty == DungeonConsts.Normal then
				des = string.format(StrConfig['dungeon227'], "#00FF00", needLvl);
			else
				local preDiff = difficulty - 1;
				local preTime = DungeonUtils:GetPassTime( group, preDiff );
				local prePassColor = "#FF0000";
				if preTime and preTime > 0 then
					prePassColor = "#00FF00";
				end
				des = string.format( StrConfig['dungeon229'], prePassColor, DungeonConsts:GetDifficultyName(preDiff) );
			end
		end
	end
	return des;
end

-- 将秒转为00:00:00或00:00格式
function DungeonUtils:ParseTime(time, alwaysShowHour)
	local timeStr = "";
	if not time then time = 0 end
	local hour, min, sec = CTimeFormat:sec2format(time);
	if alwaysShowHour or hour > 0 then
		timeStr = string.format("%02d:%02d:%02d", hour, min, sec);
	else
		timeStr = string.format("%02d:%02d", min, sec);
	end
	return timeStr;
end

--该副本ID是否是最大难度
function DungeonUtils:GetDungeonIsMaxDiff(id)
	local cfg = t_dungeons[id]
	if not cfg then return end
	local dungeonGroup = math.floor(id / 100);
	for i , v in pairs(t_dungeons) do
		if math.floor(v.id / 100) == dungeonGroup then
			if v.id > id then return false end
		end
	end
	return true
end

--adder:houxudong   date:2016/8/3 22:45:20
-- /**致终于来到这里的勇敢的人：你是被上帝选中的人，英勇的人，不辞劳苦的，不眠不休的来修改
-- 我们是最棘手地代码编程骑士。你，我们的救世主，人中之龙，
-- 我要对你说：永远不要放弃，永远不要对自己失望，永远不要逃走，辜负了自己，
-- 永远不要啼哭，永远不要说再见。永远不要说谎来伤害自己**/
-------------------------------判断各个副本是否进入的条件满足---------------------

--获取单人副本进入条件
function DungeonUtils:CheckSingeDungen(  )
	local group = 0;
	local restFreeTimes = 0;     --剩余的免费进入次数
	local totalFreeTimes = 0;    --免费的总进入次数
	local timesList = {};
	local cfg = t_funcOpen[13]
	if not cfg then return false,0; end
	local openLevel = cfg.open_level
	if not openLevel then return false,0; end
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel
	if curRoleLvl < openLevel then
		 return false,0;
	end
	for id, cfg in pairs(t_dungeons) do
		if group ~= cfg.group then
			group = cfg.group;
			if not group or group == 0 then return false,0; end
			DungeonGroup:SetGroup(group)
			local dungeonGroup  = DungeonModel:GetDungeonGroup( group )
			restFreeTimes,totalFreeTimes = dungeonGroup:GetRestFreeTimes()
			local vo = {}
			vo.group = group
			vo.times = restFreeTimes;
			table.push(timesList,vo)
		end
	end
	for i=1,#timesList do
		for j=1,i - 1 do
			if timesList[i].group == timesList[j].group then
				timesList[j].times = 0
			end
		end
	end
	local CanEnterTimes = 0;
	for i,v in ipairs(timesList) do
		if group ~= cfg.group then

		end
		local cfg = t_dungeons[v.group * 100 + 1]
		if not cfg then return false, 0 end
		local groupOpenLv = cfg.unlock_level
		local minLevel = cfg.min_level
		local isShow = cfg.hide
		if curRoleLvl >= groupOpenLv and curRoleLvl >= minLevel and isShow == 1 then
			CanEnterTimes = CanEnterTimes + v.times
		end
	end
	--[[
	-- 不包括vip次数
	local godVipTimes = DungeonModel:GetVipEnterNum( ) or 0
	local isGodVip = DungeonModel:CheckVip( )
	if isGodVip then
		CanEnterTimes = CanEnterTimes + godVipTimes
	end
	--]]
	if curRoleLvl >= openLevel then
		if CanEnterTimes and CanEnterTimes >0 then
			return true,CanEnterTimes
		end
	end
	return false,0
end

-- 单人副本如果有免费次数则返回免费次数，负责返回付费次数
function DungeonUtils:GetSingleDungeonFreeTimes(groupId)
	local timesList = {};
	local group = groupId;
	for id, cfg in pairs(t_dungeons) do
		if group == cfg.group then
			local dungeonGroup  = DungeonModel:GetDungeonGroup( group )
			local restFreeTimes = dungeonGroup:GetRestFreeTimes()
			local restPayTimes  = dungeonGroup:GetRestPayTimes()
			local vo = {}
			vo.group = group
			vo.freeTimes = restFreeTimes
			vo.payTimes  = restPayTimes
			table.push(timesList,vo)
			break;
		end
	end
	for i,v in ipairs(timesList) do
		for j = 1,i - 1 do
			if v.group == timesList[j].group then
				table.remove(timesList,i)
			end
		end
	end
	local totalLeftFreeTime = 0   --剩余的免费总次数
	local totalLeftPayTime  = 0   --剩余的付费总次数
	for i,v in ipairs(timesList) do
		totalLeftFreeTime = totalLeftFreeTime + v.freeTimes
		totalLeftPayTime = totalLeftPayTime + v.payTimes
	end
	-- 如果有免费次数则返回免费次数
--	if totalLeftFreeTime > 0 then
		return totalLeftFreeTime
--	end
--	return totalLeftPayTime
end

--获取经验副本进入条件
function DungeonUtils:CheckWaterDungen(  )

	local freeTimes = WaterDungeonModel:GetDayFreeTime()   --免费进入次数
	local payTiems  = WaterDungeonModel:GetDayPayTime()    --付费进入次数
	local cdTimes   = WaterDungeonModel:GetLeftTime()      --CD剩余时间
	local timeAvailable = freeTimes;
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel 
	local cfg = t_funcOpen[39];  
	if not cfg then return false,0 end
	local openLevel = cfg.open_level
	if curRoleLvl >= openLevel then
		if timeAvailable and timeAvailable > 0 and cdTimes <= 0 then
			return true,timeAvailable
		end
	end
	
	return false,0
 
end

-- 经验副本进入条件2,后期使用
-- condition:免费次数进入，cd进入，消耗物品和钻石VIp等级限制
function DungeonUtils:CheckWaterDungenNew( )
	local freeTimes       = WaterDungeonModel:GetDayFreeTime()     --免费进入次数
	local payTiems        = WaterDungeonModel:GetDayPayTimeNew()   --付费进入次数
	local cdTimes         = WaterDungeonModel:GetLeftTime()        --CD剩余时间
	local vipType         = VipController:GetVipType()             --vip类型
	local vipgrade        = VipController:GetVipLevel()            --vip等级
	local playerRoleLvl   = MainPlayerModel.humanDetailInfo.eaLevel
	local itemId, itemNum = WaterDungeonConsts:GetEnterItem()    --消耗的物品
	local times = 0;
	local payTiemNeedCd   = true                                   --消耗物品时同时需要消耗CD
	for i=1,toint(payTiems) do
		if i * itemNum <= BagModel:GetItemNumInBag( itemId ) and vipType == VipConsts.TYPE_DIAMOND then
			times = times + 1
		end
	end
 	local timeAvailable = freeTimes + times
	local cfg = t_funcOpen[39];  
	if not cfg then return false,0 end
	local openLevel = cfg.open_level
	if playerRoleLvl >= openLevel then
		if payTiemNeedCd then
			if timeAvailable and timeAvailable > 0 and cdTimes <= 0 then
				return true,timeAvailable
			end
		else
			local num = 0
			if freeTimes > 0 and cdTimes <= 0 and times > 0 then
				return true,timeAvailable
			end
			if freeTimes <= 0 and times > 0 then
				return true,times
			end
		end
	end
	return false,0
end

--获取通天之路副本进入条件
function DungeonUtils:CheckPataDungen(  )
	local babelData = BabelModel.babelData;
	local enterNum =  babelData.daikyNum or 0
	local cfg = t_funcOpen[19]
	if not cfg then return false,0; end
	local openLevel = cfg.open_level
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel
	if not openLevel then return false,0; end
	if curRoleLvl >= openLevel then
		if enterNum > 0 then
			return true,enterNum
		end
	end
	return false,0
end

--获取妖域幻界副本进入条件
function DungeonUtils:CheckTimeDungen( )
	local enterNum = TimeDungeonModel:GetEnterNum()
	local cfg = t_funcOpen[20]
	if not cfg then return false; end
	local openLevel = cfg.open_level
	if not openLevel then return false,0; end
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel
	if curRoleLvl >= openLevel then
		if enterNum and enterNum > 0 then
			return true,enterNum
		end
	end
	return false,0
end

--获取封妖试炼副本进入条件
function DungeonUtils:CheckQizhanDungen(  )
	local enterNum = QiZhanDungeonUtil:GetNowEnterNum(); 
	local cfg = t_funcOpen[74]
	if not cfg then return false; end
	local openLevel = cfg.open_level
	if not openLevel then return false; end
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel
	if curRoleLvl >= openLevel then
		if enterNum and enterNum > 0 then
			return true,enterNum
		end
	end
	return false,0
end

-- 诛仙青云志副本进入条件
function DungeonUtils:CheckGodDynastyDungen( )
	local dailyCanEnterNum = #t_zhuxianzhen
	local curLayer = GodDynastyDungeonModel:GetMyHistoryMaxLayer() - 1
	local cfg = t_funcOpen[121]
	if not cfg then return false; end
	local openLevel = cfg.open_level
	if not openLevel then return false; end
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel
	local times = dailyCanEnterNum - curLayer
	if times == dailyCanEnterNum then   --说明今天他一次也没有打，或者第一层挑战失败,或者中场退出
		times = 1
	else
		times = 0
	end
	if not curRoleLvl then
		Debug("发生未知异常，玩家等级获取不到")
		return false, 0
	end
	if curRoleLvl >= openLevel then
		if times == 1 then
			return true , times
		end
	end
	return false, 0
end

-- 牧野之战副本进入条件
function DungeonUtils:CheckMakinoBattleDungen( )
	local enterNum,totalNum = MakinoBattleDungeonUtil:GetNowCanEnterNum()
	local cfg = t_funcOpen[123]
	if not cfg then return false; end
	local openLevel = cfg.open_level
	if not openLevel then return false; end
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel
	if curRoleLvl >= openLevel then
		if enterNum > 0 then
			return true, enterNum
		end
	end
	return false, 0
end

--检测总副本进入条件
function DungeonUtils:GetDungeonCanCome( )
	local singleDungeonCanEnter,num1 = self:CheckSingeDungen()
	local timeExperDungeonCanEnter,num3 = self:CheckTimeDungen()
	-- local waterDungeonCanEnter,num2 = self:CheckWaterDungenNew()
	local timeDungeonCanEnter,num4 = self:CheckQizhanDungen()
	local godDynastyCanEnter,num5 = self:CheckGodDynastyDungen()
	local makinoBattleCanEnter,num6 = self:CheckMakinoBattleDungen( )
	local num = (num1 + num3 + num4 + num5 + num6) or 0
	if singleDungeonCanEnter or timeExperDungeonCanEnter or timeDungeonCanEnter  or godDynastyCanEnter or makinoBattleCanEnter then
		return true,num;
	end
	return false,num;
end

function DungeonUtils:CheckWaterDungeonEnterLevel()
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel
	local cfg = t_funcOpen[39];   --策划39不要动
	if not cfg then return false end
	local openLevel = cfg.open_level
	if curRoleLvl >= openLevel then
		return true;
	end
end

-- 检测副本功能是否开启
function DungeonUtils:CheckDungeonOpenFunc(id)
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel
	local cfg = t_funcOpen[id];
	if not cfg then return false; end
	local openLevel = cfg.open_level
	if not openLevel then return false end
	if curRoleLvl >= toint(openLevel) then
		return true,openLevel
	end
	return false,openLevel
end

-- 获得副本功能页签文本
function DungeonUtils:GetTitleName(openId)
	local cfg = t_consts[330]
	if not cfg then return '' end
	local name = ''
	local param = split(cfg.param,'#')
	for i,v in pairs(param) do
		local deatil = split(v,',')
		if openId == toint(deatil[1]) then
			name = deatil[2]
		end
	end
	return name
end

--对功能页签根据开启等级进行排序
--@param1  功能按钮list
--@param2  初始按钮X坐标
--@param3  初始按钮Y坐标
--@param4  按钮宽度
--@param5  按钮之间的间隙
function DungeonUtils:GetBtnData(tabButtonList,x,y,width,gap)
	local list = {}
	local btnList = {}
	local num = 0
	local originaX,orignalY,btnWidth,btnGaps = x,y,width,gap
	for id,btn in pairs(tabButtonList) do
		local vo = {}
		vo.lv = toint(t_funcOpen[id].open_level)
		vo.id = id
		table.push(list,vo)
	end
	table.sort( list, function(A,B)
		return A.lv < B.lv
	end )
	for i,v in ipairs(list) do
		local vo = {}
		num = num + 1
		vo.id = v.id
		vo.lv = v.lv
		vo.x = originaX + (btnWidth + btnGaps) * ((num-1) >= 0 and num-1 or 0)
		vo.y = orignalY
		table.push(btnList,vo)
	end
	return btnList
end

-- 对副本中奖励进行位置调优
-- @param1 奖励信息
-- @param2 中心点位置X坐标(最后一个item的位置加上自己的宽度除以2)
-- @param3 中心点位置Y坐标
-- @param4 奖励之间的间隙
-- @param5 奖励的item的宽度
function DungeonUtils:AdjustRewardPos(rewardList,mindlePosX,mindlePosY,rewardGap,ItemWidth)
	if not rewardList then return '' end
	local rewardSize = #rewardList
	local itemList = {}
	if not rewardGap then
		rewardGap = 2
	end
	if not ItemWidth then
		ItemWidth = 52
	end
	local totalWidth = mindlePosX - (ItemWidth * rewardSize + rewardGap*(rewardSize-1))/2
	for i=1,rewardSize do
		local vo = {}
		vo.x = math.floor(totalWidth + (ItemWidth + rewardGap) * (i - 1))
		vo.y = math.floor(mindlePosY)
		table.push(itemList,vo)
	end
	return itemList
end

-- 判断玩家身上是否有经验buff
-- true表示有经验buff,false表示没有经验buff
function DungeonUtils:TestIsHaveExpBuff( )
	local AllBuffList = BuffModel:GetAllBuff()
	for k,v in pairs(AllBuffList) do
		for i,vo in ipairs(ExpBuffList) do
			if vo == v.tid then
				return true
			end
		end
	end
	return false
end

-- 组队升级副本里面使用经验丹
-- @param1 物品id
-- @param2 是否使用全部的物品
function DungeonUtils:UseItemId( itemId,isUseAll)
	if not itemId then return end
	local count = 1
	if isUseAll then
		count = BagModel:GetItemNumInBag(itemId)
	end
	local itemCount = BagModel:GetItemNumInBag(itemId)
	if itemCount <= 0 then
		return 0
	end
	-- 根据tid从背包中检索物品，检索到使用
	BagController:UseItemByTid(BagConsts.BagType_Bag,itemId,count)
	return BagModel:GetItemNumInBag(itemId)
	--[[
	-- 根据物品位置来使用物品
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return end
	local bagItem = BagModel:GetItemInBag(itemId)
	if not bagItem then return end
	local pos = bagItem:GetPos()
	BagController:UseItem(BagConsts.BagType_Bag,pos,count)
	--]]
end

-- 副本延迟5秒打开结算界面(通用)
-- @param1 回调函数
-- @param2 延迟显示时间
function DungeonUtils:OnDealyTime(callBackOne,dealyShowNum)
	local num = dealyShowNum or 5
	local func = function ( )
		if num == 0 then
			TimerManager:UnRegisterTimer(self.timeKey)
			self.timeKey = nil
			callBackOne()
		end
		if num == dealyShowNum or 5 then
			UITimeTopSec:Open(2)
		end
		num = num - 1
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey)
		self.timeKey = nil
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000)
end

-- condition1：有剩余次数
-- condition2: 未加锁
-- condition3: 战力符合要求
function DungeonUtils:CheckShowEffect(roomNum,att,isLock)
	if toint(roomNum) >= 4 then
		return false
	end
	if isLock == 0 then
		return false
	end
	local selfFight = MainPlayerModel.humanDetailInfo.eaFight
	if selfFight and att then
		if selfFight < toint(att) then
			return false
		end
	end
	return true
end

-- 服务于单人副本
-- 根据副本等级读取奖励预览
function DungeonUtils:GetPreViewReward( dungeonId )
	local groupId = math.floor(dungeonId / 100)
	local rewardList = {}
	for k,v in pairs(t_dungeons) do
		if v.id then
			if math.floor(v.id / 100) == groupId then
				if math.floor(v.id % 100) >= math.floor(dungeonId % 100) and v.hide == 1 then
					local vo = {}
					vo.dungeonLv = v.id % 100   --副本等级
					vo.roleMinLv = v.min_level  --进入最低等级
					vo.roleMaxLv = v.max_level  --进入最大等级	
 					vo.rewardOne = v.rewards    --副本奖励
 					table.push(rewardList,vo)
				end
			end
		end
	end
	table.sort( rewardList, function(A,B )
		return A.dungeonLv < B.dungeonLv
	end )
	return rewardList
end
