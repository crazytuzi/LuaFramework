--[[
跨服pvp
liyuan

]]

_G.InterServicePvpModel = Module:new();
InterServicePvpModel.Allrawardlist = {};
InterServicePvpModel.myRoleInfo = {}; --  我的信息
InterServicePvpModel.myWardItemStr = ''
InterServicePvpModel.otherRoleInfo = {}; --我的信息
InterServicePvpModel.lastSeasonid = -1
InterServicePvpModel.nextSeasonid = -1
InterServicePvpModel.seasonid = 0
InterServicePvpModel.benfuBZNum = 5--白银钻石段位玩家数量

InterServicePvpModel.versionList = {}
InterServicePvpModel.MostLevel = 0
InterServicePvpModel.allReward = {}

-- 跨服boss
InterServicePvpModel.bossRank = {}
InterServicePvpModel.countDownTimeId = nil
InterServicePvpModel.isInCrossBoss = false
InterServicePvpModel.mainViewLevel = 1
InterServicePvpModel.bossJiesuan = false--结算状态

function InterServicePvpModel:GetIsInCrossBoss()
	return self.isInCrossBoss
end

function InterServicePvpModel:SetIsInCrossBoss(value)
	self.isInCrossBoss = value
end

function InterServicePvpModel:init()
	-- 1=段位，2=荣耀
	for i = 1,2 do
		self.versionList[i] = 0
	end
	
	self.bossStoryUI = {}
	self.bossStoryUI['bossUI0'] = UIInterServiceBossStory1
	self.bossStoryUI['bossUI1'] = UIInterServiceBossStory2
	self.bossStoryUI['bossUI2'] = UIInterServiceBossStory2
	self.bossStoryUI['bossUI3'] = UIInterServiceBossStory4	
	
	self:SetMaxLevel()
end

function InterServicePvpModel:GetInterServicePvpVersion(versionType)
	return self.versionList[versionType]
end

function InterServicePvpModel:SetInterServicePvpVersion(versionType, version)
	self.versionList[versionType] = version
end

function InterServicePvpModel:SetInterServiceRankList(list, ret)
	if ret == 1 then
		self.atServerlvlList = {};
		self:Aboutlvllist(list,self.atServerlvlList);	
	end
	self:sendNotification(NotifyConsts.InterServerPvpListUpdata);
end

function InterServicePvpModel:GetInterServiceRankList()
	return self.atServerlvlList	or {}
end

function InterServicePvpModel:SetInterServiceRongyaoList(list, ret)
	if ret == 1 then
		self.atServerRongyaoList = {};
		self:Aboutlvllist(list,self.atServerRongyaoList);	
	end	
	self:sendNotification(NotifyConsts.InterServerPvpRongyaoUpdata);
end

function InterServicePvpModel:GetInterServiceRongyaoList()	
	return self.atServerRongyaoList	or {}
end

-- 等级
function InterServicePvpModel:Aboutlvllist(list,listvo)
	for i,info in ipairs(list) do 
		local vo = {};
		vo.roleid = info.roleID;
		vo.rank = info.rank;
		vo.roleName = info.roleName;
		vo.lvl = info.rankvlue;
		vo.role = info.roletype;
		vo.vipLvl = info.vipLvl;
		vo.vflag = info.vflag;
		vo.rankvlue = info.rankvlue;
		vo.fight = info.fight;
		table.push(listvo,vo)
	end;
end;

--123名
function InterServicePvpModel : SetFrist(list)
	self.fristList = {};
		
	for i,info in  ipairs(list) do 
		local vo = {};
		if info.prof == 0 then
			vo.id = 1;
			vo.xuweiyidai = false
			vo.roleName = '';
			vo.fight = 0;
			if i == 1 then
				vo.prof = 3;
			elseif i == 2 then
				vo.prof = 2;
			else
				vo.prof = 4;
			end
			vo.rank = i;
			
			vo.arms = 0;
			vo.dress = 0;
			vo.shoulder = 0;
			vo.fashionshead = 0
			vo.fashionsarms = 0
			vo.fashionsdress = 0
			vo.wing = 0
			vo.suitflag = 0
			vo.wuhunId = 0
		else
			vo.id = info.roleId;
			vo.xuweiyidai = true
			vo.roleName = info.roleName;
			vo.fight = info.fight;
			vo.rank = info.rank;
			vo.prof = info.prof;
			vo.arms = info.arms;
			vo.dress = info.dress;
			vo.shoulder = info.shoulder;
			
			vo.fashionshead = info.fashionshead
			vo.fashionsarms = info.fashionsarms
			vo.fashionsdress = info.fashionsdress
			vo.wing = info.wing
			vo.suitflag = info.suitflag
			vo.wuhunId = 0;--info.wuhunId;	
		end
		table.push(self.fristList,vo)
	end;
	--发送消息 返回fristrank
	Notifier:sendNotification(NotifyConsts.KuafuPvpUpFirstRank);
end;

function InterServicePvpModel : GetFristList()
	return self.fristList;
end;

---我的属性
function InterServicePvpModel : SetMyroleInfo(msg)
	self.myRoleInfo.remaintimes = msg.remaintimes   -- 剩余匹配次数
	self.myRoleInfo.contwin = msg.contwin; 			-- 连胜场数
	self.myRoleInfo.totalcnt = msg.totalcnt; 		-- 总挑战次数
	self.myRoleInfo.totalwin = msg.totalwin ; 		-- 总胜利场数
	self.myRoleInfo.rank = msg.rank; 				-- 名次
	self.myRoleInfo.rewardflag = msg.rewardflag; 	-- 领奖标记(0 - 已领奖， 1 - 未领奖)
	self.seasonid = msg.seasonid or 0
	self.lastSeasonid = msg.lastSeasonid or -1
	self.nextSeasonid = msg.nextSeasonid or -1
	self:SetFrist(msg.CrossRankList)
	local score = MainPlayerModel.humanDetailInfo.eaCrossScore; 		--积分
	local gongxun = MainPlayerModel.humanDetailInfo.eaCrossExploit; 	--功勋
	local duanwei = MainPlayerModel.humanDetailInfo.eaCrossDuanwei or 5; --段位
	--计算我自己的奖励
	self:setWradInfo();
	Notifier:sendNotification(NotifyConsts.KuafuPvpInfoUpdate);
end;

---历届跨服信息
function InterServicePvpModel : SetCrossSeason(msg)
	self.seasonid = msg.seasonid or 0
	self.lastSeasonid = msg.lastSeasonid or -1
	self.nextSeasonid = msg.nextSeasonid or -1
	self:SetFrist(msg.CrossRankList)
end;

--计算我自己的奖励
function InterServicePvpModel : setWradInfo()	
	local mylvl = MainPlayerModel.humanDetailInfo.eaLevel;--等级
	local duanwei = MainPlayerModel.humanDetailInfo.eaCrossDuanwei or 5; --段位
	local cfg = t_kuafuranking[mylvl]
	if cfg and cfg['ranking'..duanwei] then
		self.myWardItemStr = cfg['ranking'..duanwei]
	end
	
	self.Allrawardlist = {};
	local cfg = t_kuafuranking[mylvl]
	if not cfg then return end
	for i=1, 5 do 
		local vo = {};
		vo.duanwei = i
		vo.ranking = cfg['ranking'..i]
		table.push(self.Allrawardlist,vo)
	end;
end;

--得到奖励list
function InterServicePvpModel : GetAllReward() 
	return self.Allrawardlist;
end;

--
function InterServicePvpModel : GetMyroleInfo()
	return self.myRoleInfo;
end;
-- 得到我的奖励
function InterServicePvpModel : GetMyReward()
	return self.myWardItemStr;
end;

-- 根据积分得到段位
local sPvpDuanwei = {'钻石段位','白金段位','黄金段位','白银段位','青铜段位'}
function InterServicePvpModel:GetMyDuanwei(duanwei)
	
	return sPvpDuanwei[duanwei] or '无'
end

function InterServicePvpModel:SetOtherInfo(msg)
	self.otherRoleInfo.roleId = msg.roleId
	self.otherRoleInfo.groupid = msg.groupid
	self.otherRoleInfo.name = msg.name
	self.otherRoleInfo.prof = msg.prof
	self.otherRoleInfo.level = msg.level
	self.otherRoleInfo.score = msg.score
	self.otherRoleInfo.power = msg.power
	self.otherRoleInfo.countDownTime = msg.time
	self.otherRoleInfo.pvplv = msg.pvplv
end

function InterServicePvpModel:SetMaxLevel()
	self.MostLevel = 0 
	for k,v in pairs(t_kuafubenfu) do
		self.MostLevel = self.MostLevel + 1
	end
end

function InterServicePvpModel:GetMaxLevel()
	return self.MostLevel
end

------------------------------------跨服boss--------------------------

function InterServicePvpModel:SetBossInitInfo(msgObj)
	self.mainViewLevel = msgObj.level
	
	self.bossRankList = {}
	local playerLevel = self.mainViewLevel or 1
	if playerLevel <= 0 then playerLevel = 1 end
	
	local bossCfg = t_kuafuboss[playerLevel]
	if not bossCfg then return end
	for i = 1,5 do 
		local bossVO = msgObj.rankList[i]
		self.bossRankList[i] = {}	
		local bossId = 0		
		if i < 5 then
			bossId = bossCfg['monster'..i]
			self.bossRankList[i].bossid = bossId
			local monsterCfg = t_monster[bossId]
			if monsterCfg then
				self.bossRankList[i].monsterName = monsterCfg.name
			end		
		else
			bossId = bossCfg['boss']
			self.bossRankList[i].bossid = bossId
			local monsterCfg = t_monster[bossId]
			if monsterCfg then
				self.bossRankList[i].monsterName = monsterCfg.name
			end	
		end
	
		if bossVO then			
			self.bossRankList[i].firstroleName = bossVO.firstroleName
			self.bossRankList[i].roleName = bossVO.roleName		
		end
	end
	
	Notifier:sendNotification(NotifyConsts.ISKuafuMianRank);
end

-- 状态
function InterServicePvpModel:SetBossListInfo(msgObj)
	self.bossStatus = {}
	self.bossStatus.remainsec = msgObj.remainsec or 0
	self.bossStatus.status = msgObj.status
	self.bossStatus.baoxiangremainsec = msgObj.baoxiangremainsec or 0
	self.bossStatus.level = msgObj.level or 1
	
	self.statusList = {}
	local i = 1
	for k,v in ipairs(msgObj.statusList) do
		self.statusList[i] = {}
		self.statusList[i].status = v.status
		-- self.statusList[i].level = v.level
		self.statusList[i].roleID = v.roleID
		i = i + 1
	end
	
	self.statueList = {}
	i = 1
	for k,v in ipairs(msgObj.statueList) do
		self.statueList[i] = {}
		-- self.statueList[i].status = v.status
		self.statueList[i].groupid = v.groupid
		i = i + 1
	end
	
	if self.countDownTimeId then
		TimerManager:UnRegisterTimer(self.countDownTimeId)
		self.countDownTimeId = nil
	end
	self.countDownTimeId = TimerManager:RegisterTimer(function()
					if self.bossStatus.remainsec <= 0 then 
						TimerManager:UnRegisterTimer(self.countDownTimeId)
						self.countDownTimeId = nil
						return 
					end
					self.bossStatus.remainsec = self.bossStatus.remainsec - 1					
				end,1000,0)
	
	Notifier:sendNotification(NotifyConsts.ISKuafuBossInfoRefresh);
end

function InterServicePvpModel:ClearBossTime()
	if self.countDownTimeId then
		TimerManager:UnRegisterTimer(self.countDownTimeId)
		self.countDownTimeId = nil
	end
	self.groupId = 0
	self.treasurenum = 0 	
	self.bossRank = {}
	self.bossResult = {}
	self.bossJiesuan = false
end

-- 战斗中排行
function InterServicePvpModel:SetBossRankList(msgObj)
	if not self.bossRank then
		self.bossRank = {}	
	end
	self.bossType = msgObj.type	
	
	self.bossRank[msgObj.type] = {}
	local i = 1
	for k,v in ipairs(msgObj.rankList) do
		local rankVO = {}
		rankVO.rank = i
		rankVO.name = v.name
		rankVO.damage = v.damage
		table.push(self.bossRank[msgObj.type], rankVO)
		i = i + 1
	end
	
	Notifier:sendNotification(NotifyConsts.ISKuafuBossRankList);
end

-- 跨服BOSS资格信息排行
function InterServicePvpModel:SetBossMemList(msgObj)
	self.bossMemList = {}	
	for k,v in ipairs(msgObj.rankList) do
		local rankVO = {}
		rankVO.roleID = v.roleID
		rankVO.roleName = v.roleName		
		table.push(self.bossMemList, rankVO)		
	end
	
	Notifier:sendNotification(NotifyConsts.ISKuafuBossMemInfo);
end

-- 跨服boss结算
function InterServicePvpModel:SetBossResult(msgObj)
	self.bossResult = {}	
	self.bossResult.treasurenum = msgObj.treasurenum	
	self.bossResult.rankList = {}
	local i = 1
	for k,v in ipairs(msgObj.rankList) do
		local rankVO = {}
		rankVO.rank = v.rank
		rankVO.result = v.result		
		table.push(self.bossResult.rankList, rankVO)
		i = i + 1
	end
	
	Notifier:sendNotification(NotifyConsts.ISKuafuBossResultRankList);
end

function InterServicePvpModel:SetTreasurenum(msgObj)
	self.treasurenum = msgObj.treasurenum	
	
	Notifier:sendNotification(NotifyConsts.ISKuafuBossBaoxiang);	
end

function InterServicePvpModel:SetServiceInfo(msgObj)
	self.groupId = msgObj.groupId
end

function InterServicePvpModel:GetGroupId()
	return self.groupId or 0
end

function InterServicePvpModel:GetRoleItemUIdata(info)
	if not info then return end;	
	local vo = {};	
	vo.roleName = info.name;	
	vo.rankNum = info.rank;	
	
	if info.rank == 3 then 
		vo.rank = "c";		
	elseif info.rank == 2 then 
		vo.rank = "b";		
	elseif info.rank == 1 then 
		vo.rank = "a";		
	else 
		vo.rank = info.rank;		
	end;
	vo.head = ''
	vo.rankvlue = info.damage	
	vo.fight = info.damage	
	
	return UIData.encode(vo)
end;

function InterServicePvpModel:GetRankRewardByLevel(level, curSelected)
	if not self.bossStatus then return end
	local playerLevel = self.bossStatus.level
	local bossCfg = t_kuafuboss[playerLevel]
	if curSelected == 5 then
		return bossCfg.libao2[level]	
	else
		return bossCfg.libao4[level]
	end	
end

function InterServicePvpModel:AddAwardToAllRankList(itemId, itemNum)
	if not itemId then return end
	itemId = toint(itemId)
	for k, v in pairs (self.allRankReward) do
		if v.itemId == itemId then
			v.itemNum = v.itemNum + 1
			return
		end
	end	
	
	local itemVO = {}
	itemVO.itemId = itemId
	itemVO.itemNum = itemNum or 1
	table.push(self.allRankReward, itemVO)	
end

function InterServicePvpModel:AddAwardToAllBaoxiangList(itemId, itemNum)
	if not itemId then return end
	itemId = toint(itemId)
	for k, v in pairs (self.allBaoxiangReward) do
		if v.itemId == itemId then
			v.itemNum = v.itemNum + 1
			return
		end
	end	
	
	local itemVO = {}
	itemVO.itemId = itemId
	itemVO.itemNum = itemNum or 1
	table.push(self.allBaoxiangReward, itemVO)	
end

function InterServicePvpModel:GetTotalRankReward()
	local playName = MainPlayerModel.humanDetailInfo.eaName;
	local playerLevel = InterServicePvpModel.bossStatus.level
	local bossCfg = t_kuafuboss[playerLevel]
	if not bossCfg then return end
	
	local mainRoleID = MainPlayerModel.mainRoleID
	for i = 1,5 do 
		local statusVO = InterServicePvpModel.statusList[i]
		if statusVO.status == 2 and mainRoleID == statusVO.roleID then
			if i == 5 then				
				self:AddAwardToAllRankList(bossCfg.libao3)				
			else
				self:AddAwardToAllRankList(bossCfg.libao5)		
			end
		end
		
		if not InterServicePvpModel.bossRank then return end
		local rankList = InterServicePvpModel.bossRank[i]
		if rankList then		
			-- FTrace(rankList, '排行状态')
			for k,info in ipairs(rankList) do
				if info.name == playName then 					
					if i == 5 then
						self:AddAwardToAllRankList(bossCfg.libao2[info.rank])
					else
						self:AddAwardToAllRankList(bossCfg.libao4[info.rank])
					end
				end
			end;		
		end				
	end
end

function InterServicePvpModel:GetTotalBaoxiangReward()
	local playName = MainPlayerModel.humanDetailInfo.eaName;
	local playerLevel = InterServicePvpModel.bossStatus.level
	local bossCfg = t_kuafuboss[playerLevel]
	if not bossCfg then return end

	if InterServicePvpModel.treasurenum and InterServicePvpModel.treasurenum > 0 then
		local baoxiangList = split(bossCfg.libao6, '#')
		for k,v in pairs(baoxiangList) do
			local vList = split(v, ',')
			local baoID = vList[1]
			local baoNum = toint(vList[2])
			baoNum = baoNum*InterServicePvpModel.treasurenum			
			self:AddAwardToAllBaoxiangList(baoID, baoNum)
		end
	end
end

-- 所有累计奖励
function InterServicePvpModel:GetTotalReward()
	self.allRankReward = {}
	self.allBaoxiangReward = {}
	
	if not self.bossStatus then return "" end
	-- FTrace(InterServicePvpModel.bossStatus, 'boss状态')
	
	self:GetTotalRankReward()
	self:GetTotalBaoxiangReward()
	
	local strList = {}	
	for k,v in pairs (self.allRankReward) do
		table.push(strList, v.itemId..','..v.itemNum)
	end
	for k,v in pairs (self.allBaoxiangReward) do
		table.push(strList, v.itemId..','..v.itemNum)
	end
	local allRewardStr = table.concat(strList,'#')
	return allRewardStr
end

-- 排行累计奖励
function InterServicePvpModel:GetRankReward()
	self.allRankReward = {}
	
	if not self.bossStatus then return "" end
	-- FTrace(InterServicePvpModel.bossStatus, 'boss状态')
	
	self:GetTotalRankReward()	
	
	local strList = {}	
	for k,v in pairs (self.allRankReward) do
		table.push(strList, v.itemId..','..v.itemNum)
	end
	
	local allRewardStr = table.concat(strList,'#')
	return allRewardStr
end

-- 宝箱累计奖励
function InterServicePvpModel:GetBaoxiangReward()
	self.allBaoxiangReward = {}
	
	if not self.bossStatus then return "" end
	-- FTrace(InterServicePvpModel.bossStatus, 'boss状态')	

	self:GetTotalBaoxiangReward()
	
	local strList = {}		
	for k,v in pairs (self.allBaoxiangReward) do
		table.push(strList, v.itemId..','..v.itemNum)
	end
	local allRewardStr = table.concat(strList,'#')
	return allRewardStr
end
