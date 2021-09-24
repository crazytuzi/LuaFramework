--2017四周年周年庆典活动
--author: Liang Qi
acAnniversaryFourVoApi={}

function acAnniversaryFourVoApi:getAcVo()
	return activityVoApi:getActivityVo("znqd2017")
end

function acAnniversaryFourVoApi:setActiveName(name)
	self.name=name
end

function acAnniversaryFourVoApi:getActiveName()
	return self.name
end


function acAnniversaryFourVoApi:canReward()
	local acVo=self:getAcVo()
	if(acVo==nil)then
		return false
	end
	local allAchievements=acAnniversaryFourVoApi:getAllAchievements()
	for k,v in pairs(allAchievements) do
		if(acAnniversaryFourVoApi:checkCanGetAchievementReward(v)==1)then
			return true
		end
	end
	local allRecharge=acAnniversaryFourVoApi:getRechargeCfg()
	for k,v in pairs(allRecharge) do
		if(acAnniversaryFourVoApi:checkCanGetRechargeReward(k)==1)then
			return true
		end
	end
	return false
end

--领奖
--param action: 1 领取历程奖励;2 领取成就奖励;3 领取累计充值奖励
--param type: 领的是哪一档
function acAnniversaryFourVoApi:getReward(action,type,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.znqd2017 then
				local acVo=self:getAcVo()
				if(acVo)then
					acVo:updateSpecialData(sData.data.znqd2017)
					local rewardCfg
					if(action==1)then
						rewardCfg=acVo.experienceRewardCfg[type][2]
					elseif(action==2)then
						rewardCfg=acVo.achieveCfg[type][2]
					else
						rewardCfg=acVo.rechargeCfg[type][2]
					end
					if(rewardCfg)then
						local award=FormatItem(rewardCfg) or {}
						for k,v in pairs(award) do
							G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
						end
						G_showRewardTip(award,true)
					end
					activityVoApi:updateShowState(acVo)
				end
				if(callback)then
					callback()
				end
			end
		end
	end
	socketHelper:acAnniversaryFourReward(action,type,onRequestEnd)
end

--获取所有的历程模块
--1:配件, 2:将领, 3:军徽,4:战机, 5:战斗力，根据线上实际开关情况展示
function acAnniversaryFourVoApi:getAllExperience()
	local resultTb={}
	if(base.ifAccessoryOpen==1)then
		table.insert(resultTb,1)
	end
	if(base.heroSwitch==1)then
		table.insert(resultTb,2)
	end
	if(base.emblemSwitch==1)then
		table.insert(resultTb,3)
	end
	if(base.plane==1)then
		table.insert(resultTb,4)
	end
	table.insert(resultTb,5)
	return resultTb
end

--获取并初始化历程中不同模块的数据
--type: 1~5, 要获取哪个模块, 1:配件, 2:将领, 3:军徽, 4:战机, 5:战斗力
--callback: 回调函数，结果(百分比和具体数值)将作为回调函数的两个参数回传
function acAnniversaryFourVoApi:checkGetExperienceData(type,callback)
	local acVo=self:getAcVo()
	if(acVo==nil)then
		callback(0,0)
	end
	if(acVo.experienceData and acVo.experienceData[type] and acVo.experienceData[type][1] and acVo.experienceData[type][2])then
		callback(acVo.experienceData[type][1],acVo.experienceData[type][2])
	else
		if(type==5)then
			local totalCount=acVo.totalPeople
			local function onGetRankCallback()
				totalCount=acVo.totalPeople
				local rankData=rankVoApi:getRank(0)
				if rankData.selfRank==nil or SizeOfTable(rankData.selfRank)==0 then
					local function onRequestEnd(fn,data)
						local ret,sData=base:checkServerData(data)
						if ret==true then
							local selfRankData=rankVoApi:getRank(0).selfRank
							if(selfRankData.rank=="100+")then
								callback(0.1,playerVoApi:getPlayerPower())
							else
								if(tonumber(selfRankData.rank)>totalCount)then
									callback(0.1,playerVoApi:getPlayerPower())
								else
									callback(G_keepNumber((1 - tonumber(selfRankData.rank)/totalCount)*100,1),playerVoApi:getPlayerPower())
								end								
							end
						end
					end
					socketHelper:ranking(1,1,onRequestEnd)
				else
					local selfRankData=rankData.selfRank
					if(selfRankData.rank=="100+")then
						callback(0.1,playerVoApi:getPlayerPower())
					else
						if(tonumber(selfRankData.rank)>totalCount)then
							callback(0.1,playerVoApi:getPlayerPower())
						else
							callback(G_keepNumber((1 - tonumber(selfRankData.rank)/totalCount)*100,1),playerVoApi:getPlayerPower())
						end								
					end
				end
			end
			if(totalCount==nil or totalCount==0)then
				acAnniversaryFourVoApi:getRank(onGetRankCallback)
			else
				onGetRankCallback()
			end
		else
			local function requestCallback()
				local percent,strength
				local acVo=self:getAcVo()
				if(acVo and acVo.experienceData and acVo.experienceData[type])then
					percent,strength=acVo.experienceData[type][1],acVo.experienceData[type][2]
				else
					percent,strength=0,0
				end
				if(callback)then
					callback(percent,strength)
				end
			end
			acAnniversaryFourVoApi:getRank(requestCallback)
		end
	end
end

--向后台请求排行榜数据
function acAnniversaryFourVoApi:getRank(callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.znqd2017 then
				local acVo=self:getAcVo()
				if(acVo)then
					acVo:updateSpecialData(sData.data.znqd2017)
				end
				if(callback)then
					callback()
				end
			end
		end
	end
	socketHelper:acAnniversaryFourRank(onRequestEnd)
end

--获取历程奖励的配置
function acAnniversaryFourVoApi:getExperienceRewardCfg(type)
	local acVo=self:getAcVo()
	if(acVo==nil)then
		return {}
	end
	if(acVo.experienceRewardCfg and acVo.experienceRewardCfg[type] and acVo.experienceRewardCfg[type][1])then
		return acVo.experienceRewardCfg[type][2]
	else
		return {}
	end
end

--获取成就奖励的配置
function acAnniversaryFourVoApi:getAchievementRewardCfg(type)
	local acVo=self:getAcVo()
	if(acVo==nil)then
		return {}
	end
	if(acVo.achieveCfg and acVo.achieveCfg[type] and acVo.achieveCfg[type][2])then
		return acVo.achieveCfg[type][2]
	else
		return {}
	end
end

--获取不同历程的描述
--param type: 1~5
--return: a string
function acAnniversaryFourVoApi:getExperienceStr(type,strength,percent)
	local acVo=self:getAcVo()
	if(acVo==nil)then
		return getlocal("world_war_landType_unknow")
	end
	local percentStr=percent.."%%"
	local moduleName
	if(type==1)then
		moduleName=getlocal("accessory")
		return getlocal("activity_znqd2017_experienceDesc1",{getlocal("you"),moduleName,FormatNumber(strength),percentStr})
	elseif(type==2)then
		moduleName=getlocal("heroTitle")
		return getlocal("activity_znqd2017_experienceDesc2",{getlocal("you"),moduleName,FormatNumber(strength),percentStr})
	elseif(type==3)then
		moduleName=getlocal("emblem_title")
		return getlocal("activity_znqd2017_experienceDesc3",{getlocal("you"),moduleName,FormatNumber(strength),percentStr})
	elseif(type==4)then
		moduleName=getlocal("sample_build_name_106")
		return getlocal("activity_znqd2017_experienceDesc4",{getlocal("you"),moduleName,FormatNumber(strength),percentStr})
	else
		return getlocal("activity_znqd2017_experienceDesc5",{getlocal("you"),FormatNumber(strength),percentStr})
	end
end

--获取不同历程要发送的聊天消息
--param type: 1~5
--return: a string
function acAnniversaryFourVoApi:getChatMessage(type,strength,percent)
	local acVo=self:getAcVo()
	if(acVo==nil)then
		return getlocal("world_war_landType_unknow")
	end
	local percentStr=percent.."%%"
	local moduleName
	if(type==1)then
		moduleName=getlocal("accessory")
		return getlocal("activity_znqd2017_experienceDesc1",{playerVoApi:getPlayerName(),moduleName,FormatNumber(strength),percentStr})
	elseif(type==2)then
		moduleName=getlocal("heroTitle")
		return getlocal("activity_znqd2017_experienceDesc2",{playerVoApi:getPlayerName(),moduleName,FormatNumber(strength),percentStr})
	elseif(type==3)then
		moduleName=getlocal("emblem_title")
		return getlocal("activity_znqd2017_experienceDesc3",{playerVoApi:getPlayerName(),moduleName,FormatNumber(strength),percentStr})
	elseif(type==4)then
		moduleName=getlocal("sample_build_name_106")
		return getlocal("activity_znqd2017_experienceDesc4",{playerVoApi:getPlayerName(),moduleName,FormatNumber(strength),percentStr})
	else
		return getlocal("activity_znqd2017_experienceDesc5",{playerVoApi:getPlayerName(),FormatNumber(strength),percentStr})
	end
end

--获取所有的成就模块
--1: 萌新玩家, 2: 元老玩家, 3: 高战力玩家, 4: 高VIP玩家
function acAnniversaryFourVoApi:getAllAchievements()
	local acVo=self:getAcVo()
	if(acVo==nil or acVo.achieveCfg==nil)then
		return {}
	end
	--萌新玩家和元老玩家以一年为限, 计算的时间点以活动结束时间为准
	local et=acVo.et
	local days = math.ceil((G_getWeeTs(et)+86400-G_getWeeTs(tonumber(playerVoApi:getRegdate())))/86400)
	local cfg=acVo.achieveCfg[2]
	local oldUserLimit=tonumber(cfg[1][1])
	if(days>=oldUserLimit)then
		return {2,3,4}
	else
		return {1,3,4}
	end
end

--获取成就的描述
function acAnniversaryFourVoApi:getAchievementDesc(type)
	local acVo=self:getAcVo()
	if(acVo==nil)then
		return getlocal("world_war_landType_unknow")
	end
	local cfg=acVo.achieveCfg[type]
	if(cfg==nil)then
		return getlocal("world_war_landType_unknow")
	end
	if(type==1)then
		return getlocal("activity_znqd2017_achieveDesc1",{getlocal("fightLevel",{acVo.limitLv})})
	elseif(type==2)then
		return getlocal("activity_znqd2017_achieveDesc2")
	elseif(type==3)then
		return getlocal("activity_znqd2017_achieveDesc3",{FormatNumber(cfg[1])})
	else
		return getlocal("activity_znqd2017_achieveDesc4",{getlocal("VIPStr1",{cfg[1]})})
	end
end

--获取玩家的充值额度
function acAnniversaryFourVoApi:getRechargeNum()
	local acVo=self:getAcVo()
	if(acVo==nil)then
		return 0
	end
	return acVo.rechargeNum
end

--获取充值的奖励
--return: 一个table，table中的每个子元素代表一个档位配置。子元素下的第一个子元素是充值档位所需金币，第二个子元素是奖励配置
function acAnniversaryFourVoApi:getRechargeCfg()
	local acVo=self:getAcVo()
	if(acVo==nil or acVo.rechargeCfg==nil)then
		return {}
	end
	return acVo.rechargeCfg
end

--检查某个历程奖励是否可以领取
--param type: 要领取哪个历程
--return: true or false
function acAnniversaryFourVoApi:checkCanGetExperienceReward(type)
	local acVo=self:getAcVo()
	if(acVo==nil)then
		return false
	end	
	if(playerVoApi:getPlayerLevel()<acVo.limitLv)then
		return false
	end
	if(acVo.experienceReward and acVo.experienceReward["r"..type]==1)then
		return false
	end
	return true
end

--检查某个成就奖励是否可以领取
--param type: 要领取哪个成就，1~4, 1: 萌新玩家, 2: 元老玩家, 3: 高战力玩家, 4: 高VIP玩家
--return: 0表示不能领取，1表示可领取，2表示已领取
function acAnniversaryFourVoApi:checkCanGetAchievementReward(type)
	local acVo=self:getAcVo()
	if(acVo==nil)then
		return 0
	end
	if(acVo.achievementReward and acVo.achievementReward["r"..type]==1)then
		return 2
	end
	if(acVo.achieveCfg==nil or acVo.achieveCfg[type]==nil)then
		return 0
	end
	local cfg=acVo.achieveCfg[type]
	if(type==1)then
		local et=acVo.et
		local regdate=tonumber(playerVoApi:getRegdate())
		local oldUserLimit=tonumber(cfg[1][2])
		local newUserLimit=tonumber(cfg[1][1])
		if(playerVoApi:getPlayerLevel()>=acVo.limitLv)then
			return 1
		else
			return 0
		end
	elseif(type==2)then
		local et=acVo.et
		local days = math.ceil((G_getWeeTs(et)+86400-G_getWeeTs(tonumber(playerVoApi:getRegdate())))/86400)
		local cfg=acVo.achieveCfg[2]
		local oldUserLimit=tonumber(cfg[1][1])
		if(days>=oldUserLimit)then
			return 1
		else
			return 0
		end
	elseif(type==3)then
		if(playerVoApi:getPlayerPower()>=tonumber(cfg[1]))then
			return 1
		else
			return 0
		end
	elseif(type==4)then
		if(playerVoApi:getVipLevel()>=tonumber(cfg[1]))then
			return 1
		else
			return 0
		end
	end
end

--检查充值奖励是否可领取
--param index: 要领取的档次
--return 0表示不能领取，1表示可领取，2表示已领取
function acAnniversaryFourVoApi:checkCanGetRechargeReward(index)
	local acVo=self:getAcVo()
	if(acVo==nil)then
		return 0
	end
	local needRecharge=acVo.rechargeCfg[index][1]
	if(needRecharge==nil)then
		return 0
	end
	local rechargeNum=acVo.rechargeNum or 0
	if(rechargeNum<needRecharge)then
		return 0
	end
	if(acVo.rechargeReward and acVo.rechargeReward["r"..index]==1)then
		return 2
	end
	return 1
end

function acAnniversaryFourVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
	spriteController:addTexture("public/activeCommonImage1.png")
end

function acAnniversaryFourVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
	spriteController:removeTexture("public/activeCommonImage1.png")
end

function acAnniversaryFourVoApi:clearAll()
	local acVo=self:getAcVo()
	if(acVo and acVo.clear)then
		acVo:clear()
	end
end