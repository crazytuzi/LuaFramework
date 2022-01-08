--[[
******争霸赛管理类*******

	-- 2015/11/16
]]


local ZhengbaManager = class("ZhengbaManager")


local OpenTime = "10:00:00"
local OpenDate = "6"


ZhengbaManager.UPADTECHAMPIONSSTATUS			= "ZhengbaManager.upadteChampionsStatus" --
ZhengbaManager.GAINCHAMPIONSINFO				= "ZhengbaManager.gainChampionsInfo" --
ZhengbaManager.CHAMPIONSRANK					= "ZhengbaManager.championsRank" --
ZhengbaManager.UPDATEFORMATIONSUCESS			= "ZhengbaManager.updateFormationSucess" --
ZhengbaManager.GETGRAND							= "ZhengbaManager.getGrand" --
ZhengbaManager.ENCOURAGINGSUCESS				= "ZhengbaManager.encouragingSucess" --
ZhengbaManager.OPENBOXSUCESS					= "ZhengbaManager.openBoxSucess" --

ZhengbaManager.sortByQuality = 1
ZhengbaManager.sortByPower = 2

function ZhengbaManager:ctor()
	self.activityStatus = 1
	self.isJoin = false
	self:registerEvents()
	self.tempBoxIndex = 0
	self.personGrandList = TFArray:new()
	self.publicGrandList = TFArray:new()
	self.boxes = {}
	self.inspireNum = 0
	self.matchTime = 0
	self.matchCount = 0
	self.hosting = false

	self.StrategyMulitData = {}
end

function ZhengbaManager:restart()
	self.activityStatus = 1
	self.isJoin = false
	self.matchCount = 0
	self:registerEvents()
	self.tempBoxIndex = 0
	self.personGrandList:clear()
	self.publicGrandList:clear()
	self.tempFormations = nil
	self.inspireNum = 0
	self.championsInfo = nil
	self.championsRankInfo = nil
	self.matchTime = 0
	self.score_add = 0
	self.boxes = {}
	self.StrategyMulitData = {}
end

function ZhengbaManager:registerEvents()
	TFDirector:addProto(s2c.UPDATE_FORMATION_SUCESS , self, self.updateFormationSucess)
	TFDirector:addProto(s2c.GAIN_CHAMPIONS_INFO, self, self.gainChampionsInfo)
	TFDirector:addProto(s2c.ENCOURAGING_SUCESS, self, self.encouragingSucess)
	TFDirector:addProto(s2c.GRAND, self, self.grand)
	TFDirector:addProto(s2c.UPADTE_CHAMPIONS_STATUS, self, self.upadteChampionsStatus)
	TFDirector:addProto(s2c.OPEN_BOX_SUCESS, self, self.openBoxSucess)
	TFDirector:addProto(s2c.CHAMPIONS_RANK, self, self.championsRank)
	TFDirector:addProto(s2c.NOT_JOIN, self, self.notJoin)
	TFDirector:addProto(s2c.UPDATE_HOSTING_SUCESS, self, self.updateHostingSucess)
end


function ZhengbaManager:updateFormationSucess(event)
	hideLoading()
	if self.tempFormations then
		-- if self.tempFormations[1] == EnumFightStrategyType.StrategyType_CHAMPIONS_ATK then
		-- 	self.championsInfo.atkFormation = self.tempFormations[2]
		-- elseif self.tempFormations[1] == EnumFightStrategyType.StrategyType_CHAMPIONS_DEF then
		-- 	self.championsInfo.defFormation = self.tempFormations[2]

		-- elseif self.tempFormations[1] == EnumFightStrategyType.StrategyType_AREAN then
		-- 	--quanhuan 添加群豪谱防守
		-- 	self.championsInfo.qunHaoDefFormation = self.tempFormations[2]

		-- elseif self.tempFormations[1] == EnumFightStrategyType.StrategyType_MINE1_DEF then
		-- 	self.championsInfo.MineDefFormation1 = self.tempFormations[2]
		-- elseif self.tempFormations[1] == EnumFightStrategyType.StrategyType_MINE2_DEF then
		-- 	self.championsInfo.MineDefFormation2 = self.tempFormations[2]
		-- end

		local StrategyType = self.tempFormations[1]
		self.StrategyMulitData[StrategyType] = self.tempFormations[2]

		TFDirector:dispatchGlobalEventWith(ZhengbaManager.UPDATEFORMATIONSUCESS)
	end
	self.tempFormations = nil
end

function ZhengbaManager:gainChampionsInfo(event)
	hideLoading()
	local data = event.data
	print("gainChampionsInfo = ",data)
	self.isJoin = true
	self.championsInfo = data.info
	self.matchCount = data.matchCount
	self.boxes = data.boxes or {0,0}
	self.hosting = data.hosting
	TFDirector:dispatchGlobalEventWith(ZhengbaManager.GAINCHAMPIONSINFO)
	self:gainRankInfo()

	self:qunHaoDefFormationSet(EnumFightStrategyType.StrategyType_CHAMPIONS_ATK, self.championsInfo.atkFormation)
	self:qunHaoDefFormationSet(EnumFightStrategyType.StrategyType_CHAMPIONS_DEF, self.championsInfo.defFormation)
end
function ZhengbaManager:updateChampionsInfo(info)
	self.score_add = self.championsInfo.score - info.score
	self.championsInfo = info
	self.matchCount = self.matchCount + 1
	TFDirector:dispatchGlobalEventWith(ZhengbaManager.GAINCHAMPIONSINFO)
	self:gainRankInfo()
end

function ZhengbaManager:encouragingSucess(event)
	hideLoading()
	-- toastMessage("鼓舞成功")
	toastMessage(localizable.bloodBattleMainLayer_up_success)
	self.inspireNum = 1
	TFDirector:dispatchGlobalEventWith(ZhengbaManager.ENCOURAGINGSUCESS)
end

--[[
enum GrandType{
	YOU_BEAT =1;//你击败了谁 玩家名,连胜,积分
	CHALLENGE_FAILURE=2;//挑战失败 玩家名
	BEAT_YOU = 3;//击败了你 name
	CHALLENGE_YOUR_FAILURE = 4;//挑战你失败  name,积分
	ATT_WIN_STREAK = 5;//进攻连胜 名称,连胜数
	DEF_WIN_STREAK = 6;//防守连胜 名称,连胜数
}
]]
function ZhengbaManager:grand(event)
	local data = event.data
	print("grand data , ==",data)
	local message = {}
	if data.type == 1 then
		message = self:getYouBeatGrand( data.msg )
		self.personGrandList:pushBack(message)
	elseif data.type == 2 then
		message = self:getYouFailGrand( data.msg )
		self.personGrandList:pushBack(message)
	elseif data.type == 3 then
		message = self:getBeatYouGrand( data.msg )
		self.personGrandList:pushBack(message)
	elseif data.type == 4 then
		message = self:getFailYouGrand( data.msg )
		self.personGrandList:pushBack(message)
	elseif data.type == 5 then
		message = self:getAttWinStreakGrand( data.msg )
		self.publicGrandList:pushBack(message)
	elseif data.type == 6 then
		message = self:getDefWinStreakGrand( data.msg )
		self.publicGrandList:pushBack(message)
	end
	TFDirector:dispatchGlobalEventWith(ZhengbaManager.GETGRAND,{message})
end

function ZhengbaManager:upadteChampionsStatus(event)
	hideLoading()
	local data = event.data
	self.activityStatus = data.status
	if self.activityStatus == 1 then
		self:restart()
	elseif self.activityStatus == 5 then
		WeekRaceManager:startPlayNotice()
	end
	TFDirector:dispatchGlobalEventWith(ZhengbaManager.UPADTECHAMPIONSSTATUS)
end

function ZhengbaManager:openBoxSucess(event)
	hideLoading()
	if self.tempBoxIndex ~= 0 then
		self.boxes[self.tempBoxIndex] = self.boxes[self.tempBoxIndex] + 1
		self.tempBoxIndex = 0
		TFDirector:dispatchGlobalEventWith(ZhengbaManager.OPENBOXSUCESS)
	end
end

function ZhengbaManager:championsRank(event)
	hideLoading()
	local data = event.data
	print("championsRank = ",data)
	self.championsRankInfo = data.infos
	self.myRank = data.myRank
	TFDirector:dispatchGlobalEventWith(ZhengbaManager.CHAMPIONSRANK)
end
function ZhengbaManager:notJoin(event)
	hideLoading()
	self.isJoin = false
	self:gainRankInfo()
end

function ZhengbaManager:openZhengbaMainLayer()

	if self.activityStatus == 5 then
		WeekRaceManager:requestRaceInfo(true)
		return
	end

	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.zhengba.ZhengbaLayer",AlertManager.BLOCK_AND_GRAY)
	AlertManager:show();
	self:checkJoin()
	-- if self.activityStatus == 3 or self.activityStatus == 4 then
	-- 	self:gainRankInfo()
	-- end
end

function ZhengbaManager:getActivityStatus()
	print("self.activityStatus =",self.activityStatus)
	return self.activityStatus
end
function ZhengbaManager:isJoinActivity()
	return self.isJoin
end


function ZhengbaManager:match()
	print("ZhengbaManager:Match")
	self.matchTime = self.matchTime or 0
	local nowTime = MainPlayer:getNowtime()
	local tempTime = 45 - (nowTime - self.matchTime)
	if  tempTime > 0 then
		-- toastMessage("对战冷却时间剩余："..tempTime .."秒")
		toastMessage(stringUtils.format(localizable.ZhengbaManager_cd_time, tempTime))
		return
	end
	
	OtherPlayerManager:ZhengbaMatch()
	self.inspireNum = 0
	-- showLoading()
	-- TFDirector:send(c2s.MATCH, {})
end

function ZhengbaManager:checkJoin()
	print("ZhengbaManager:checkJoin")
	showLoading()
	TFDirector:send(c2s.CHECK_JOIN, {})
end

function ZhengbaManager:gainRankInfo()
	showLoading()
	TFDirector:send(c2s.GAIN_RANK_INFO, {})
end
function ZhengbaManager:Encouraging()
	if self.inspireNum > 0 then
		-- toastMessage("你已经鼓舞了")
		toastMessage(localizable.ZhengbaManager_insprie_time)
		return
	end
	showLoading()
	TFDirector:send(c2s.ENCOURAGING, {})
end

function ZhengbaManager:joinChampions()
	showLoading()
	TFDirector:send(c2s.GAIN_CHAMPIONS, {})
end
function ZhengbaManager:beginFight()
	self.matchTime = self.matchTime or 0
	local nowTime = MainPlayer:getNowtime()
	local tempTime = 45 - (nowTime - self.matchTime)
	if  tempTime > 0 then
		-- toastMessage("对战冷却时间剩余："..tempTime .."秒")
		toastMessage(stringUtils.format(localizable.ZhengbaManager_cd_time, tempTime))
		return
	end

	self.matchTime = nowTime
	showLoading()
	TFDirector:send(c2s.CHALLENGE_CHAMPIONS, {})
	-- self.matchTime = 0
end
function ZhengbaManager:updateFormation(fight_type ,formations)
	showLoading()
	local msg =  {
		-- fight_type - 1,
		fight_type,
		formations
	}
	print("updateFormation = ",msg)
	self.tempFormations = msg
	TFDirector:send(c2s.UPDATE_FORMATION, msg)
end
function ZhengbaManager:openBox(index)
	local box_id = self.boxes[index] or 0
	local boxInfo = ChampionsBoxData:objectByID(index*1000 + box_id)
	if boxInfo == nil then
		-- toastMessage("你已领取所有宝箱")
		toastMessage(localizable.ZhengbaManager_get_all_box)
		return
	end
	if index == 1 then
		if self.championsInfo == nil or self.championsInfo.atkMaxWinStreak < boxInfo.value then
			-- toastMessage("对不起，您还没有取得"..boxInfo.value.."连胜")
			-- self:openBoxInfo( boxInfo ,"取得进攻"..boxInfo.value.."连胜可领取")
			self:openBoxInfo(boxInfo, stringUtils.format(localizable.ZhengbaManager_liansheng_ing, boxInfo.value))
			return
		end
	else
		if self.matchCount < boxInfo.value then
			-- toastMessage("对不起，您还没有取得"..boxInfo.value.."连胜")
			-- self:openBoxInfo( boxInfo ,"进行"..boxInfo.value.."次对战可领取")
			self:openBoxInfo(boxInfo, stringUtils.format(localizable.ZhengbaManager_liansheng_ed, boxInfo.value))
			return
		end
	end

	showLoading()
	self.tempBoxIndex = index
	TFDirector:send(c2s.OPEN_BOX, {index})
end

function ZhengbaManager:openBoxInfo( boxInfo ,message)
	local calculateRewardList = self:calculateReward(boxInfo.drop_id)
	if calculateRewardList == nil then
		return
	end
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.zhengba.ZhengbasaiBox",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);
    layer:loadData(calculateRewardList, message);
    AlertManager:show();
end

function ZhengbaManager:calculateReward(rewardid)

    local calculateRewardList = TFArray:new();
    local rewardConfigure = RewardConfigureData:objectByID(rewardid)
    if rewardConfigure == nil then
		print("找不到奖励配置 id == ",rewardid)
		return nil
    end
    local rewardItems = rewardConfigure:getReward()


    for k,v in pairs(rewardItems.m_list) do
        local rewardInfo = {}
        rewardInfo.type = v.type
        rewardInfo.itemId = v.itemid
        rewardInfo.number = v.number
        local _rewardInfo = BaseDataManager:getReward(rewardInfo)
        calculateRewardList:push(_rewardInfo);
    end

    return calculateRewardList
end

function ZhengbaManager:getYouBeatGrand( _message )
	local info = stringToTable(_message,",")
	local message = {}
	message.message = stringUtils.format(localizable.ZhengbaManager_jibai_xxx, info[1]) --"你击败了"..info[1].."，"
	message.score = stringUtils.format(localizable.ZhengbaManager_jifen_add, info[3]) --"积分+"..info[3]
	if self.championsInfo then
		self.championsInfo.atkWinStreak = tonumber(info[2])
	end
	-- if self.championsInfo.atkWinStreak > self.championsInfo.atkMaxWinStreak then
	-- 	self.championsInfo.atkMaxWinStreak = self.championsInfo.atkWinStreak
	-- end
	return message
end

function ZhengbaManager:getYouFailGrand( _message )
	local info = stringToTable(_message,",")
	local message = {}
	message.message = stringUtils.format(localizable.ZhengbaManager_tiaozhanshibai, info[1]) --"你挑战"..info[1].."失败"
	-- self.championsInfo.atkWinStreak = 0
	return message
end

function ZhengbaManager:getBeatYouGrand( _message )
	local info = stringToTable(_message,",")
	local message = {}
	message.message = stringUtils.format(localizable.ZhengbaManager_xxx_jibai, info[1])  --info[1].."击败了你"
	if self.championsInfo ~= nil then
		self.championsInfo.defWinStreak = 0
		self.championsInfo.defLostCount = self.championsInfo.defLostCount + 1
	end
	return message
end

function ZhengbaManager:getFailYouGrand( _message )
	local info = stringToTable(_message,",")
	local message = {}
	message.message =  stringUtils.format(localizable.ZhengbaManager_xxx_tiaozhan, info[1]) --info[1].."挑战你失败，"
	message.score = stringUtils.format(localizable.ZhengbaManager_jifen_add, info[2]) -- "积分+"..info[2]
	if self.championsInfo == nil then
		return message
	end
	self.championsInfo.defWinStreak = self.championsInfo.defWinStreak + 1
	if self.championsInfo.defWinStreak > self.championsInfo.defMaxWinSteak then
		self.championsInfo.defMaxWinSteak = self.championsInfo.defWinStreak
	end
	self.championsInfo.score = self.championsInfo.score + tonumber(info[2])
	self.championsInfo.defWinCount = self.championsInfo.defWinCount + 1
	return message
end

function ZhengbaManager:getAttWinStreakGrand( _message )
	local info = stringToTable(_message,",")
	local message = {}
	local times = tonumber(info[2])

	-- if times == 5 then
	-- 	message.message = info[1].."取得了进攻"..times.."连胜，正在暴走状态！"
	-- elseif times == 6 then
	-- 	message.message = info[1].."取得了进攻"..times.."连胜，已经技压群雄！"
	-- elseif times == 7 then
	-- 	message.message = info[1].."取得了进攻"..times.."连胜，已经无人能挡！"
	-- elseif times == 8 then
	-- 	message.message = info[1].."取得了进攻"..times.."连胜，已经主宰大会！"
	-- elseif times >= 9 then
	-- 	message.message = info[1].."取得了进攻"..times.."连胜，犹如天神下凡！"
	-- end

	local descIndex = times
	if times >= 9 then
		descIndex = 9
	end
	message.message = stringUtils.format(localizable.ZhengbaManager_fight_desc[descIndex], info[1], times)

	if times >= 10 then
		message.showEffect = true
	end
	return message
end

function ZhengbaManager:getDefWinStreakGrand( _message )
	local info = stringToTable(_message,",")
	local message = {}
	-- message.message = info[1].."取得了防守"..info[2].."连胜，已经无人能破！"
	message.message = stringUtils.format(localizable.ZhengbaManager_fight_desc2, info[1], info[2])
	if tonumber(info[2]) >= 10 then
		message.showEffect = true
	end
	return message
end



function ZhengbaManager:getReport( message_type )
	if message_type == 1 then
		return self.personGrandList
	else
		return self.publicGrandList
	end
end

function ZhengbaManager:getFightList( fight_type )
	-- if fight_type == EnumFightStrategyType.StrategyType_CHAMPIONS_ATK then
	-- 	return self.championsInfo.atkFormation

	-- elseif fight_type == EnumFightStrategyType.StrategyType_CHAMPIONS_DEF then
	-- 	return self.championsInfo.defFormation

	-- elseif fight_type == EnumFightStrategyType.StrategyType_AREAN then
	-- 	--quanhuan 添加群豪谱防守
	-- 	return self.championsInfo.qunHaoDefFormation

	-- elseif fight_type == EnumFightStrategyType.StrategyType_MINE1_DEF then
	-- 	return self.championsInfo.MineDefFormation1
	-- elseif fight_type == EnumFightStrategyType.StrategyType_MINE2_DEF then
	-- 	return self.championsInfo.MineDefFormation2

	-- else
	-- 	return self.championsInfo.defFormation
	-- end
	if fight_type == EnumFightStrategyType.StrategyType_PVE then
		return StrategyManager:getList()

	elseif fight_type == EnumFightStrategyType.StrategyType_BLOOY then
		return BloodFightManager:getList()
	end
	return self.StrategyMulitData[fight_type] or {}
end

function ZhengbaManager:getMaxNum()
	return StrategyManager:getMaxNum()
end

function ZhengbaManager:canAddFightRole(fight_type)
	local num = self:getFightRoleNum(fight_type);
	if self:getMaxNum() > num then
		return true;
	else
		return false;
	end
end
function ZhengbaManager:getFightRoleNum( fight_type )
	local list = {}

	-- if fight_type == EnumFightStrategyType.StrategyType_CHAMPIONS_ATK  then
	-- 	list = self.championsInfo.atkFormation
	
	-- elseif fight_type == EnumFightStrategyType.StrategyType_CHAMPIONS_DEF then
	-- 	list = self.championsInfo.defFormation

	-- elseif fight_type == EnumFightStrategyType.StrategyType_AREAN  then
	-- 	--quanhuan 添加群豪谱防守
	-- 	list = self.championsInfo.qunHaoDefFormation
	
	-- elseif fight_type == EnumFightStrategyType.StrategyType_MINE1_DEF then
	-- 	list = self.championsInfo.MineDefFormation1
	-- elseif fight_type == EnumFightStrategyType.StrategyType_MINE1_DEF then
	-- 	list = self.championsInfo.MineDefFormation2
	-- else
	-- 	list = self.championsInfo.defFormation
	-- end

	list = self.StrategyMulitData[fight_type] or {}

	local num = 0;
	for i=1,10 do
		if list[i] and list[i] ~= 0 then
			local role = CardRoleManager:getRoleByGmid(list[i])
			if role then
				num = num + 1;
			else
				local mercenary = EmployManager:getMercenaryInAllEmployRole( list[i] )
				if mercenary then
					num = num + 1;
				else
					mercenary = EmployManager:getEmploySingleRoleByGmId( list[i] ,fight_type)
					if mercenary then
						num = num + 1;
					end
				end
			end
		end
	end
	return num;
end
function ZhengbaManager:getIndexByRole(fight_type,gmid )
	local list = self:getFightList(fight_type)
	for i=1,9 do
		if list[i] and list[i] == gmid then
			return i
		end
	end
	return 0
end
function ZhengbaManager:getPower(fight_type)

	if 1 then
		-- local figtType = LineUpType.LineUp_Attack

		-- if fight_type == EnumFightStrategyType.StrategyType_CHAMPIONS_DEF then
		-- 	figtType = LineUpType.LineUp_Defense

		-- elseif fight_type == EnumFightStrategyType.StrategyType_AREAN then
		-- 	figtType = LineUpType.LineUp_QunhaoDef
		
		-- elseif fight_type == EnumFightStrategyType.StrategyType_MINE1_DEF then
		-- 	figtType = LineUpType.LineUp_Mine1_Defense
		-- elseif fight_type == EnumFightStrategyType.StrategyType_MINE1_DEF then
		-- 	figtType = LineUpType.LineUp_Mine2_Defense

		-- end
		
		return AssistFightManager:getStrategyPower(fight_type)
	end

	local list = self:getFightList(fight_type)
	local allPower = 0;
	for i=1,10 do
		if list[i] and list[i] ~= 0 then
			local role = CardRoleManager:getRoleByGmid(list[i]);
			if role then
				allPower = allPower + role:getPowerByList(list,fight_type);
			else
				local mercenary = EmployManager:getMercenaryInAllEmployRole( list[i] )
				print("mercenary =",mercenary)
				if mercenary then
					allPower = allPower + mercenary.power
				else
					mercenary = EmployManager:getEmploySingleRoleByGmId( list[i] ,fight_type)
					if mercenary then
						allPower = allPower + mercenary.power
					end
				end
            end
		end
	end
	return allPower;
end
function ZhengbaManager:getRoleByIndex( fight_type,index )
	local role_id = 0

	-- if fight_type == EnumFightStrategyType.StrategyType_CHAMPIONS_ATK then
	-- 	role_id = self.championsInfo.atkFormation[index] or 0
		
	-- elseif fight_type == EnumFightStrategyType.StrategyType_CHAMPIONS_DEF then
	-- 	role_id = self.championsInfo.defFormation[index] or 0

	-- elseif fight_type == EnumFightStrategyType.StrategyType_AREAN then
	-- 	--quanhuan 添加群豪谱防守
	-- 	role_id = self.championsInfo.qunHaoDefFormation[index] or 0

	-- elseif fight_type == EnumFightStrategyType.StrategyType_MINE1_DEF then
	-- 	role_id = self.championsInfo.MineDefFormation1[index] or 0
	-- elseif fight_type == EnumFightStrategyType.StrategyType_MINE1_DEF then
	-- 	role_id = self.championsInfo.MineDefFormation2[index] or 0

	-- else
	-- 	role_id = self.championsInfo.defFormation[index] or 0
	-- end

	local roleList = self.StrategyMulitData[fight_type] or {}
	role_id = roleList[index] or 0

	local role = CardRoleManager:getRoleByGmid(role_id)
	return role
end

function ZhengbaManager:getMercenaryByIndex( fight_type,index )
	local role_id = 0
	if self.StrategyMulitData[fight_type] == nil then
		return nil
	end
	local roleList = self.StrategyMulitData[fight_type]
	role_id = roleList[index]
	if role_id == nil or role_id == 0 then
		return nil
	end

	role = EmployManager:getEmploySingleRoleByGmId( role_id,fight_type)
	return role
end
function ZhengbaManager:getMercenaryGmIdByIndex( fight_type,index )
	local role_id = 0
	if self.StrategyMulitData[fight_type] == nil then
		return 0
	end
	local roleList = self.StrategyMulitData[fight_type]
	role_id = roleList[index]
	if role_id == nil or role_id == 0 then
		return 0
	end

	return role_id
end

function ZhengbaManager:getMercenaryIndexByGmId( fight_type,gmId )
	local role_id = 0
	if self.StrategyMulitData[fight_type] == nil then
		return 0
	end
	local roleList = self.StrategyMulitData[fight_type]
	for i=1,9 do
		if roleList[i] and  roleList[i] == gmId then
			return i
		end
	end
	return 0
end

function ZhengbaManager:getMercenaryInArmy( fight_type )
	local roleList = self.StrategyMulitData[fight_type] or {}
	for i=1,9 do
		local role_id = roleList[i] or 0
		if role_id ~= 0 then
			local role = CardRoleManager:getRoleByGmid(role_id)
			if role == nil then
				local employInfo = EmployManager:getMercenaryInAllEmployRole( role_id )
				if employInfo == nil then
					roleList[i] = 0
				else
					return role_id , i
				end
			end
		end
	end
	return 0 ,0

end

function ZhengbaManager:getNowState()
	local date = os.date("*t", MainPlayer:getNowtime())
	if self:isDateOpen(date) == false then
		return 1
	end
	local open_timeDate = self:getTime()
	date.hour = open_timeDate.hour
	date.min  = open_timeDate.min
	date.sec  = open_timeDate.sec

	local open_time	= os.time(date)
	if MainPlayer:getNowtime() < open_time then
		return 1
	end
	local waitTime = ConstantData:getValue( "Zhengba.Time.Wait" )
	local fightTime = ConstantData:getValue( "Zhengba.Time.Fight" )

	if MainPlayer:getNowtime() > open_time + waitTime + fightTime then
		return 1
	end
	if MainPlayer:getNowtime() > open_time and MainPlayer:getNowtime() < open_time + waitTime then
		return 2 , open_time + waitTime - MainPlayer:getNowtime()
	end
	if MainPlayer:getNowtime() > open_time + waitTime and MainPlayer:getNowtime() < open_time + waitTime + fightTime then
		return 3 , open_time + waitTime + fightTime - MainPlayer:getNowtime()
	end
	return 1
end

function ZhengbaManager:isOpen()
	local date = os.date("*t", MainPlayer:getNowtime())
	if self:isDateOpen(date) == false then
		return false
	end
	local open_timeDate = self:getTime()
	date.hour = open_timeDate.hour
	date.min  = open_timeDate.min
	date.sec  = open_timeDate.sec

	local open_time	= os.time(open_timeDate)
	if MainPlayer:getNowtime() < open_time then
		return false
	end
	local waitTime = ConstantData:getValue( "Zhengba.Time.Wait" )
	local fightTime = ConstantData:getValue( "Zhengba.Time.Fight" )

	if MainPlayer:getNowtime() > open_time + waitTime + fightTime then
		return false
	end
	return true
end

function ZhengbaManager:getTime()
	if self.open_time ==nil then
		local tbl = split(OpenTime, ":")
		self.open_time = {hour=tbl[1], min=tbl[2], setbl=tbl[3]}
	end
	return self.open_time
end
function ZhengbaManager:getDate()
	if self.open_date ==nil then
		self.open_date , self.open_date_length = stringToNumberTable(OpenDate,',')
	end
	return self.open_date , self.open_date_length
end

function ZhengbaManager:isDateOpen(date)
	self:getDate()
	--没有设置开放时间，则每天都开放
	if not self.open_date_length or self.open_date_length < 1 then
		return true
	end

	local weekDay = date.wday - 1		--获得当前时间的table表存储格式

	if weekDay == 0 then
		weekDay = 7
	end

	for k,v in ipairs(self.open_date) do
		if weekDay == v then
			return true
		end
	end
	return false
end

function ZhengbaManager:openGuizheLayer()
	local layer = AlertManager:addLayerByFile("lua.logic.zhengba.ZhenbashaiRuleLayer", AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
	AlertManager:show()
end
function ZhengbaManager:openZhangBaoLayer()
	local layer = AlertManager:addLayerByFile("lua.logic.zhengba.ZhenbashaiBattlefieldLayer", AlertManager.BLOCK_AND_GRAY)
	AlertManager:show()
end
function ZhengbaManager:openArmyLayer(index, canOpenInfo)
	print("===  ZhengbaManager:openArmyLayer index = ", index)
    local layer = require("lua.logic.zhengba.ZhengbaArmyLayer"):new(index)
    AlertManager:addLayer(layer)
    layer:setOpenInfo(canOpenInfo)
    AlertManager:show()
end

function ZhengbaManager:delRoleByGmid( gmid )
	if self.championsInfo == nil then
		return
	end
	for i=1,9 do
		-- if self.championsInfo.atkFormation and self.championsInfo.atkFormation[i] == gmid then
		-- 	self.championsInfo.atkFormation[i] = 0
		-- end
		-- if self.championsInfo.defFormation and self.championsInfo.defFormation[i] == gmid then
		-- 	self.championsInfo.defFormation[i] = 0
		-- end
		-- --quanhuan 添加群豪谱防守
		-- if self.championsInfo.qunHaoDefFormation and self.championsInfo.qunHaoDefFormation[i] == gmid then
		-- 	self.championsInfo.qunHaoDefFormation[i] = 0
		-- end

		-- if self.championsInfo.MineDefFormation1 and self.championsInfo.MineDefFormation1[i] == gmid then
		-- 	self.championsInfo.MineDefFormation1[i] = 0
		-- end

		-- if self.championsInfo.MineDefFormation2 and self.championsInfo.MineDefFormation2[i] == gmid then
		-- 	self.championsInfo.MineDefFormation2[i] = 0
		-- end
		for j,v in pairs(self.StrategyMulitData) do
			if v and v[i] == gmid then
				v[i] = 0
			end
		end
	end
end

-- 上阵
function ZhengbaManager:OnBattle(fight_type,gmid, posIndex)
    local role = CardRoleManager:getRoleByGmid(gmid)
    if role == nil then
        -- toastMessage("没有该英雄")
	toastMessage(localizable.ZhengbaManager_no_this_hero)
        return
    end

    local list = clone(self:getFightList(fight_type))
    list[posIndex] = gmid
    self:updateFormation(fight_type ,list)
end

-- 下阵
function ZhengbaManager:OutBattle(fight_type,gmid)
    local list = clone(self:getFightList(fight_type))
    for i=1,10 do
        if list[i] and list[i] == gmid then
            list[i] = 0
        end
    end
    for i=1,10 do
		if list[i] and list[i] ~= 0 then
			self:updateFormation(fight_type ,list)
			return
        end
    end
    -- toastMessage("必须有一人在阵上")
    toastMessage(localizable.BloodFightManager_zhishaoshangzhenyiren)
    
end

-- 换位置
function ZhengbaManager:ChangePos(fight_type,oldPos, newPos)
    local list = clone(self:getFightList(fight_type))
    local temp = list[oldPos]
    list[oldPos] = list[newPos]
    list[newPos] = temp
    self:updateFormation(fight_type ,list)
end


function ZhengbaManager:reSortStrategy(fight_type, cardlistDefault, currSortType)
	local cardList = CardRoleManager.cardRoleList
	if cardlistDefault ~= nil then
		cardList = cardlistDefault
	end

	--EnumFightStrategyType.StrategyType_DOUBLE_1
	local function getRolePos(fight_type, gmId)
		local pos = self:getIndexByRole(fight_type,gmId)
		if pos == 0 then
			if fight_type == EnumFightStrategyType.StrategyType_DOUBLE_1 then
				pos = self:getIndexByRole(EnumFightStrategyType.StrategyType_DOUBLE_2,gmId)
			else
				pos = self:getIndexByRole(EnumFightStrategyType.StrategyType_DOUBLE_1,gmId)
			end
		end
		return pos		
	end

	local function cmpFunByPower(cardRole1, cardRole2)
		local pos_1 = cardRole1:getPosByFightType( fight_type )--getRolePos(fight_type,cardRole1.gmId);
		local pos_2 = cardRole2:getPosByFightType( fight_type )--getRolePos(fight_type,cardRole2.gmId);

		-- if fight_type == EnumFightStrategyType.StrategyType_DOUBLE_1

		if pos_1 > pos_2  and pos_2  == 0  then
			return true;
		elseif  (pos_1 > 0 and  pos_2 > 0) or pos_1 == pos_2 then
			if cardRole1.power > cardRole2.power then
				return true;
			elseif cardRole1.power == cardRole2.power then
				if cardRole1.quality > cardRole2.quality then
						return true;
				elseif cardRole1.quality == cardRole2.quality then
					if cardRole1.starlevel > cardRole2.starlevel then
						return true;
					elseif cardRole1.starlevel == cardRole2.starlevel then
						if cardRole1.gmId > cardRole2.gmId then
							return true;
						end
					end
				end
			end
		end
		return false;
	end

	local function cmpFunByQuality(cardRole1, cardRole2)
		local pos_1 = cardRole1:getPosByFightType( fight_type )--getRolePos(fight_type,cardRole1.gmId);
		local pos_2 = cardRole2:getPosByFightType( fight_type )--getRolePos(fight_type,cardRole2.gmId);

		-- if fight_type == EnumFightStrategyType.StrategyType_DOUBLE_1

		if pos_1 > pos_2  and pos_2  == 0  then
			return true;
		elseif  (pos_1 > 0 and  pos_2 > 0) or pos_1 == pos_2 then
			if cardRole1.quality > cardRole2.quality then
				return true;
			elseif cardRole1.quality == cardRole2.quality then
				if cardRole1.power > cardRole2.power then
						return true;
				elseif cardRole1.power == cardRole2.power then
					if cardRole1.starlevel > cardRole2.starlevel then
						return true;
					elseif cardRole1.starlevel == cardRole2.starlevel then
						if cardRole1.gmId > cardRole2.gmId then
							return true;
						end
					end
				end
			end
		end
		return false;
	end

	if currSortType == ZhengbaManager.sortByPower then
		cardList:sort(cmpFunByPower);
	else
		cardList:sort(cmpFunByQuality);
	end
end


function ZhengbaManager:qunHaoDefFormationSet(infoType, heroList )
	--quanhuan 2015/12/2
	-- if infoType == EnumFightStrategyType.StrategyType_CHAMPIONS_ATK then
	-- 	self.championsInfo = self.championsInfo or {}
	-- 	self.championsInfo.atkFormation = heroList

	-- elseif infoType == EnumFightStrategyType.StrategyType_AREAN then
	-- 	self.championsInfo = self.championsInfo or {}
	-- 	self.championsInfo.qunHaoDefFormation = heroList

	-- elseif infoType == EnumFightStrategyType.StrategyType_MINE1_DEF then
	-- 	self.championsInfo = self.championsInfo or {}
	-- 	self.championsInfo.MineDefFormation1 = heroList

	-- elseif infoType == EnumFightStrategyType.StrategyType_MINE1_DEF then
	-- 	self.championsInfo = self.championsInfo or {}
	-- 	self.championsInfo.MineDefFormation2 = heroList
	-- end
	
	self.StrategyMulitData[infoType] = heroList
end

function ZhengbaManager:getRoleList(infoType)
	if infoType == EnumFightStrategyType.StrategyType_MERCENARY_TEAM then
		return EmployManager:getTeamRoleList()
	end
	return CardRoleManager.cardRoleList
end


function ZhengbaManager:getRoleIndexByGmidAndFightType( gmId , fight_type )
	local list = AssistFightManager:getStrategyList( fight_type )
	for i=1,9 do
		if list[i] and list[i] ~= 0 and gmId == list[i] then
			return i
		end
	end
	return 0
end


function ZhengbaManager:updateHostingSucess( event)
	hideLoading()
	self.hosting = not self.hosting
	TFDirector:dispatchGlobalEventWith(ZhengbaManager.UPADTECHAMPIONSSTATUS)
end

function ZhengbaManager:updateHosting(value)
	if value == nil then
		value = not self.hosting
	end
	showLoading()
	TFDirector:send(c2s.UPDATE_HOSTING ,{value})
end

return ZhengbaManager:new();
