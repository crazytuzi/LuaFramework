--[[
跨服擂台赛
liyuan

]]

_G.InterContestModel = Module:new();
--预选赛追踪
InterContestModel.preRemainsec = 0
InterContestModel.preScore = 0
--预选赛第一名
InterContestModel.firstName = ''--人物名称
InterContestModel.firstScore = 0--积分
InterContestModel.firstProf = 0--职业
--预选赛奖励范围
InterContestModel.maxReward = 20
--预选赛结果
InterContestModel.preResultScore = 0
InterContestModel.preResultIsFirst = 0

--淘汰赛对阵
InterContestModel.seasonid = -1
InterContestModel.currSeasonid = -1
InterContestModel.maxCnt = 5
InterContestModel.cnt = 0 
InterContestModel.rankList = {}
--淘汰赛追踪
InterContestModel.name = ''
InterContestModel.prof = 0
InterContestModel.power = 0
InterContestModel.time = 0
InterContestModel.guwucnt = 0
--淘汰赛结果
InterContestModel.resultRank = 0
InterContestModel.resultResult = 0
InterContestModel.jieList = {}
--鼓舞
InterContestModel.xiazhuRankList = {}
InterContestModel.myOpponentProf = 0
InterContestModel.myOpponentFight = 0
InterContestModel.myOpponentRoleName = ''
InterContestModel.myguwucnt = 0
--跨服擂台赛资格
InterContestModel.zigeList = {}
--是否在跨服擂台赛
InterContestModel.isInContest = false

function InterContestModel:init()
	InterContestModel.maxReward = 0	
	for k,v in pairs (t_kuafusaireward) do
		InterContestModel.maxReward = InterContestModel.maxReward + 1
	end
end

function InterContestModel:initPreArenaInfo(msgObj)
	if msgObj.remain and msgObj.remain > 0 then
		InterContestModel.preRemainsec = msgObj.remain	-- remain 剩余时间		
	end
	InterContestModel.preScore = msgObj.score		-- score  积分
	FPrint('InterContestModel:initPreArenaInfo')
	if UIInterContestPreStory:IsShow() then
		UIInterContestPreStory:ResetCountDownTime()
	else
		UIInterContestPreStory:Show()
	end
end

function InterContestModel:PreArenaRank(msgObj)
	InterContestModel.firstName = msgObj.name--人物名称
	InterContestModel.firstScore = msgObj.score--积分
	InterContestModel.firstProf = msgObj.prof--职业
	if UIInterContestScoreFirst:IsShow() then
		UIInterContestScoreFirst:UpdateInfo()
	else
		UIInterContestScoreFirst:Show()
	end
end

function InterContestModel:CrossPreArenaResult(msgObj)
	InterContestModel.preResultScore = msgObj.score
	InterContestModel.preResultIsFirst = msgObj.isFirst
	
	if UIInterContestPreResult:IsShow() then
		UIInterContestPreResult:UpdateInfo()
	else
		UIInterContestPreResult:Show()
	end
end

function InterContestModel:initArenaInfo(msgObj)
	InterContestModel.name = msgObj.name	
	InterContestModel.prof = msgObj.prof		
	InterContestModel.power = msgObj.power
	InterContestModel.time = msgObj.time	
	InterContestModel.guwucnt = msgObj.guwucnt	
	
	if UIInterContestStory:IsShow() then
		UIInterContestStory:ResetCountDownTime()
	else
		UIInterContestStory:Show()
	end
end

function InterContestModel:CrossArenaResult(msgObj)
	InterContestModel.resultRank = msgObj.rank
	InterContestModel.resultResult = msgObj.result
	
	if UIInterContestResult:IsShow() then
		UIInterContestResult:ResetCountDownTime()
	else
		UIInterContestResult:Show()
	end
end

function InterContestModel:GetRankListItem(msgObj, posIndex)
	for k,v in pairs (msgObj.rankList) do
		if v.id and v.id > 0 then
			local pos = v.id%1000
			if pos == posIndex then
				return v			
			end
		end
	end
	
	return nil	
end

function InterContestModel:SetCrossArenaRankInfo(msgObj)
	--淘汰赛对阵
	-- msgObj.cnt = 5
	InterContestModel.currSeasonid = msgObj.cnt
	InterContestModel.cnt = msgObj.cnt + 1
	
	-- if InterContestModel.currSeasonid == -1 then
		-- InterContestModel.currSeasonid = msgObj.seasonid
		-- InterContestModel.cnt = msgObj.seasonid + 1
	-- end
	
	InterContestModel.seasonid = msgObj.seasonid
	if InterContestModel.cnt > InterContestModel.maxCnt then 
		InterContestModel.cnt = InterContestModel.maxCnt 
	end
	if InterContestModel.cnt <= 0 then 
		InterContestModel.cnt = 1
	end
	
	InterContestModel.myguwucnt = msgObj.guwucnt or 0	
	InterContestModel.guwuflag = msgObj.guwuflag or 0
	InterContestModel.enterflag = msgObj.enterflag or 0
	InterContestModel.rankList = {}
	for i = 1,64 do
		local itemVO = self:GetRankListItem(msgObj, i)
	
		local rankVO = {}
		if itemVO then
			rankVO.id = itemVO.id
			rankVO.pos = i
			rankVO.prof = itemVO.prof
			rankVO.roleName = itemVO.roleName
		else
			rankVO.id = 0
			rankVO.pos = i
			rankVO.prof = 0
			rankVO.roleName = ''
		end	
		table.push(InterContestModel.rankList, rankVO)		
	end	
	
	table.sort(InterContestModel.rankList,function(A,B)
		if A.pos < B.pos then
			return true;
		else
			return false;
		end
	end);
	InterContestModel.seasonList = {}
	InterContestModel.seasonListId = {}
	
	for i = self.currSeasonid - self.cnt + 1, self.currSeasonid do
		if i >= 0 then
			table.push(InterContestModel.seasonList, string.format(StrConfig['interServiceDungeon63'], i+1))
			table.push(InterContestModel.seasonListId,i)		
		end
	end
	
	self:sendNotification(NotifyConsts.ISKuafuArenaRankInfo);
end



function InterContestModel:SetCrossArenaXiaZhuInfo(msgObj)
	--返回跨服擂台赛下注信息
	InterContestModel.xiazhuRankList = {}
	for k,v in pairs(msgObj.rankList) do
		if v.id ~= '0_0' then
			local rankVO = {}
			rankVO.prof = v.prof
			rankVO.id = v.id
			rankVO.fight = v.fight
			rankVO.guwucnt = v.guwucnt
			rankVO.xiazhucnt = v.xiazhucnt
			rankVO.roleName = v.roleName
			if v.prof and v.prof >= 1 and v.prof <= 4 then
				rankVO.iconUrl = ResUtil:GetHeadIcon(v.prof)
			else
				rankVO.iconUrl = ''				
			end
			table.push(InterContestModel.xiazhuRankList, rankVO)
		end
	end
	
	self.xiazhuID = msgObj.id;
	-- table.sort(InterContestModel.xiazhuRankList,function(A,B)
		-- if A.id < B.id then
			-- return true;
		-- else
			-- return false;
		-- end
	-- end);
	
	local totalItemNum = #self.xiazhuRankList or 0	
	UIInterContestGuwu.totalPage = math.ceil(totalItemNum/UIInterContestGuwu.showNum)	
	
	if UIInterContestGuwu:IsShow() then
		UIInterContestGuwu:UpdateInfo()
		UIInterContestGuwu:Top();
	else
		UIInterContestGuwu:Show()
	end
end

function InterContestModel:SetCrossArenaGuWu(playerId)
	if self.myguwucnt then 
		self.myguwucnt = self.myguwucnt + 1 
	else
		self.myguwucnt = 0
	end
	
	if UIInterContestGuwu:IsShow() then
		UIInterContestGuwu:UpdateInfo()	
	end
	if UIInterContestGuwuDialog:IsShow() then
		UIInterContestGuwuDialog:UpdateInfo()	
	end
end

function InterContestModel:SetCrossArenaXiaZhu(playerId, xiazhuNum)
	local guwuVO = self:GetGuwuData(playerId)
	if not guwuVO then return end
	guwuVO.xiazhucnt = guwuVO.xiazhucnt + xiazhuNum	
	self.xiazhuID = playerId;
	if UIInterContestGuwu:IsShow() then
		UIInterContestGuwu:UpdateInfo()	
	end
	if UIInterContestXiazhuDialog:IsShow() then
		UIInterContestXiazhuDialog:Hide()
		FloatManager:AddNormal( StrConfig["interServiceDungeon205"]);
	end
end


function InterContestModel:GetGuwuCount()
	if not self.myguwucnt then return 0 end
	return self.myguwucnt
end

function InterContestModel:GetGuwuData(playerId)
	local guwulist = InterContestModel.xiazhuRankList
	if not guwulist then return nil end
	if #guwulist <= 0 then return nil end
	for k,v in pairs(guwulist) do
		if v.id == playerId then
			return v
		end	
	end
	return nil
end

function InterContestModel:OnCrossArenaXiaZhu(msgObj)
	
end

function InterContestModel:OnCrossArenaGuWu(msgObj)

end

function InterContestModel:SetCrossArenaDuiShou(msgObj)
	InterContestModel.myOpponentProf = msgObj.prof
	InterContestModel.myOpponentFight = msgObj.fight
	InterContestModel.myOpponentRoleName = msgObj.roleName

	if InterContestMyOpponent:IsShow() then
		InterContestMyOpponent:UpdateInfo()
	else
		InterContestMyOpponent:Show()
	end
end

function InterContestModel:SetCrossArenaRemaind(msgObj)

end

function InterContestModel:SetCrossArenaZige(msgObj)
	InterContestModel.zigeList = {}
	local i = 1
	for k,v in pairs(msgObj.rankList) do
		local rankVO = {}
		rankVO.power = v.power
		rankVO.rank = i
		rankVO.labPower = StrConfig['interServiceDungeon68']
		rankVO.roleName = v.roleName
		table.push(InterContestModel.zigeList, UIData.encode(rankVO))
		i = i + 1
	end
	
	if UIInterContestZige:IsShow() then
		UIInterContestZige:UpdateInfo()
	else
		UIInterContestZige:Show()
	end
end

function InterContestModel:GetPreAwardByScore(score)
	if not score then return '' end

	for i = 1, InterContestModel.maxReward do
		if t_kuafusaireward[i] then
			local rankArr = split(t_kuafusaireward[i].rank, ',')
			if score >= toint(rankArr[1]) and score <= toint(rankArr[2]) then
				return t_kuafusaireward[i].reward
			end			
		end
	end
	return ""
end

function InterContestModel:GetIsInContest()
	return self.isInContest
end

function InterContestModel:SetIsInContest(value)
	self.isInContest = value
end
