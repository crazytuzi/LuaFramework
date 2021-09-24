require "luascript/script/config/gameconfig/dailyAnswerCfg"

dailyAnswerVoApi = {
	trueAnswerNum={0,0,0,0,0,0,0,0,0,0},
	falseAnswerNum={0,0,0,0,0,0,0,0,0,0},
	numberOfQuestion=0,
	trueRankList = {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},},
	falseRankList = {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},},
	questionList = {},
	score = 0,
	flag=nil,
	rank=nil,
	nowrank=nil,
	dtype=0,
	time=0,
	choice=nil,
	isChatTip=nil, --是否发送过答题提示公告
}

function dailyAnswerVoApi:setAnswerNum(data)
	
	if self.trueAnswerNum[self.numberOfQuestion]==nil or self.trueAnswerNum[self.numberOfQuestion]<=data[1][1] then
		self.trueAnswerNum[self.numberOfQuestion]=data[1][1]
	end

	if self.falseAnswerNum[self.numberOfQuestion]==nil or self.falseAnswerNum[self.numberOfQuestion]<=data[1][1] then
		self.falseAnswerNum[self.numberOfQuestion]=data[1][2]
	end

end

function dailyAnswerVoApi:getTrueAnswerNum(id)
	if self.trueAnswerNum[id] then
		return self.trueAnswerNum[id]
	end

	return 0
end

function dailyAnswerVoApi:getFalseAnswerNum(id)
	if self.falseAnswerNum[id] then
		return self.falseAnswerNum[id]
	end
	return 0
end

function dailyAnswerVoApi:setNumberOfQuestion(number)
	self.numberOfQuestion=number

end

function dailyAnswerVoApi:getNumberOfQuestion()
	return self.numberOfQuestion
end

function dailyAnswerVoApi:setRankList(data)
	if data==nil then 
		return
	end

	if self.trueRankList==nil then
		self.trueRankList = {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},}
	end

	if self.falseRankList==nil then
		self.falseRankList= {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},}
	end

	if data[2]==1 then

		for k,v in pairs(self.trueRankList) do
			if k== tonumber(data[3]) then
				if data[1]~=nil and SizeOfTable(data[1])>=SizeOfTable(self.trueRankList[k]) then
					self.trueRankList[k]=data[1]
					return
				end
			end
		end
	else
		for k,v in pairs(self.falseRankList) do
			if k== tonumber(data[3]) then
				if data[1]~=nil and SizeOfTable(data[1])>=SizeOfTable(self.falseRankList[k]) then
					self.falseRankList[k]=data[1]
					return
				end
			end
		end
	end

end

function dailyAnswerVoApi:getTrueRankList(id)
	if self.trueRankList then
		return self.trueRankList[id]
	else
		return {}
	end
end

function dailyAnswerVoApi:getFalseRankList(id)
	if self.falseRankList then
		return self.falseRankList[id]
	else
		return {}
	end
end

function dailyAnswerVoApi:getTime()
	return self.time
end

function dailyAnswerVoApi:setTime(ts)
	self.time = ts
end

function dailyAnswerVoApi:setQuestionList(list)
	if list~=nil then 
		self.questionList = list
	end

end

function dailyAnswerVoApi:getQuestionById(id)
	if SizeOfTable(self.questionList)==0 or id==0 then
		return
	end
	return self.questionList[id][1]

end

function dailyAnswerVoApi:getAnswerLeftById(id)
	if SizeOfTable(self.questionList)==0 or id==0 or id==nil then
		return
	end

	return self.questionList[id][2][1]
end

function dailyAnswerVoApi:getAnswerRightById(id)
	if SizeOfTable(self.questionList)==0 or id==0 or id==nil then
		return
	end

	return self.questionList[id][2][2]
end

function dailyAnswerVoApi:setFlag(flag)
	self.flag = flag
end

function dailyAnswerVoApi:getFlag()
	return self.flag
end

function dailyAnswerVoApi:setRank(rank)
	self.rank = rank
end

function dailyAnswerVoApi:getRank()
	return self.rank
end

function dailyAnswerVoApi:setDtype(dtype)
	self.dtype = dtype
end

function dailyAnswerVoApi:getDtype()
	return self.dtype
end

function dailyAnswerVoApi:setChoice(choice)
	self.choice = choice
end

function dailyAnswerVoApi:getChoice()
	return self.choice
end

function dailyAnswerVoApi:setScore(score)
	self.score = score
end

function dailyAnswerVoApi:getScore()
	return self.score
end

function dailyAnswerVoApi:clear(deepClearFlag)
	
	self.trueAnswerNum={}
	self.falseAnswerNum={}
	self.numberOfQuestion=nil
	self.trueRankList = nil
	self.falseRankList = nil
	self.questionList = {}
	if deepClearFlag==true then
		self.score = nil
	end
	self.flag=nil
	self.rank=nil
	self.nowrank=nil
	self.dtype=nil
	self.time=nil
	self.choice=nil
	self.isChatTip=nil
end

function dailyAnswerVoApi:setNowRank(nowrank)
	self.nowrank = nowrank
end

function dailyAnswerVoApi:getNowRank()
	return self.nowrank
end

function dailyAnswerVoApi:checkShopOpen()
	local vo =dailyActivityVoApi:getActivityVo("dailychoice")
	local openTime = vo.st[1]*60*60+vo.st[2]*60
	if base.serverTime-(G_getWeeTs(base.serverTime)+openTime-meiridatiCfg.lastTime)>=0 then
		return true
	else
		return false
	end


end


function dailyAnswerVoApi:showShop(layerNum)
	local vo =dailyActivityVoApi:getActivityVo("dailychoice")
	if(self:checkShopOpen())then
		require "luascript/script/game/scene/gamedialog/dailyAnswer/dailyAnswerDialog"
	    local td = dailyAnswerDialog:new()
	    local tabTb = {getlocal("dailyAnswer_title_tab1"), getlocal("mainRank")}
	    local dialog = td:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("dailyAnswer_title"),true,layerNum + 1)
	    sceneGame:addChild(dialog,layerNum)
		return td
	else
		-- local time1 = string.format("%02d:%02d",vo.st[1],vo.st[2])
		-- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dailyAnswer_tab1_nostart_tip",{time1}),28)
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("not_to_time"),28)
		do return end
	end
end

function dailyAnswerVoApi:tick()
	if base.dailychoice==1 and meiridatiCfg and self.isChatTip==nil then
		local dayTime=base.serverTime-G_getWeeTs(base.serverTime)
		local openTime=meiridatiCfg.openTime[1][1]*60*60+meiridatiCfg.openTime[1][2]*60
		if dayTime>=openTime-meiridatiCfg.lastTime and dayTime<openTime then
			self.isChatTip=true
			local function sendAnswerStartChat()
				local message={key="dailyAnswer_prepare_tip",param={}}
	         	local selfUid=playerVoApi:getUid()
				local selfName=playerVoApi:getPlayerName()
				local language=G_getCurChoseLanguage()
				local content={subType=4,contentType=3,message=message,ts=base.serverTime,language=language,paramTab={}}
	         	chatVoApi:addChat(1,selfUid,selfName,0,"",content,base.serverTime)
			end
			if chatVoApi:getChatNum(1)>0 then
	         	sendAnswerStartChat()
	         else
	         	local function sendChat()
					sendAnswerStartChat()
				end
				local callFunc=CCCallFunc:create(sendChat)
				local delay=CCDelayTime:create(2)
				local acArr=CCArray:create()
				acArr:addObject(delay)
				acArr:addObject(callFunc)
				local seq=CCSequence:create(acArr)
				sceneGame:runAction(seq)
	         end
	    end
	end
end

--判断是否上榜
function dailyAnswerVoApi:isRank(score)
	if tonumber(meiridatiCfg.rankNeedPoint)<=tonumber(score or 0) then
		return true
	end
	return false
end

--是否可以领奖
function dailyAnswerVoApi:isCanReward(rank)
	if tonumber(rank) and tonumber(rank)~=0 and tonumber(rank)<=meiridatiCfg.rewardlimit then
		return true
	end
	return false
end
