
ladderVoApi={
	
	ifNeedSendRequest=true,
	season=1,--第几赛季
	personLadderList=nil,--个人天梯排行榜
	allianceLadderList=nil,--军团天梯排行榜
	serverWarVsList1=nil,--个人跨服战对阵表
	serverWarVsList2=nil,--军团跨服战对阵表
	serverWarVsList3=nil,--世界争霸对阵表
	serverWarVsList5=nil,--区域跨服战对阵表
	personHOFList=nil,--个人名人堂
	allianceHOFList=nil,--军团名人堂
	personScoreDetailList=nil,--个人积分明细
	allianceScoreDetailList=nil,--军团积分明细
	warlist={},--所有大战列表
	ladderEndTime=0,--天梯结算时间
	maxPageNum=20,--每次最多请求多少条数据
	myselfInfo=nil,--我个人的天梯信息
	myselfAllianceInfo=nil,--我的军团的天梯信息
	championName="",--冠军名字
	championSid=0,--冠军服务器
	championSeason=1,--第几赛季的冠军
	lastRequestTime1=0,--个人排行榜上次请求数据的时间戳
	lastRequestTime2=0,--军团排行榜上次请求数据的时间戳
	lastRequestTime3=0,--个人明细上次请求数据的时间戳
	lastRequestTime4=0,--军团明细上次请求数据的时间戳
	requestTimeGap=10,--300,--每次请求时间间隔
	ifHasEndWar=false,--是否有已经结束的大战
	rversion=1,--个人排行榜奖励物品版本
	showWarIdList={},--需要显示的大战id
	curPage=1,--当前名人堂是第几页
	hofcount=0,--名人堂当前拥有的总条数
	isNewHofData=false,--是否有新的名人堂数据
	ifHasNextHofData=false,--是否拥有下一页数据
	ifHasBattle=false,--今天是否有战斗结算
	countTime=60,--积分计算时长
}

function ladderVoApi:clear()
	self.ifNeedSendRequest=true
	self.season=1
	self.personLadderList=nil
	self.allianceLadderList=nil
	self.serverWarVsList1=nil
	self.serverWarVsList2=nil
	self.serverWarVsList3=nil
	self.serverWarVsList5=nil
	self.personHOFList=nil
	self.allianceHOFList=nil
	self.personScoreDetailList=nil
	self.allianceScoreDetailList=nil
	self.warlist={}
	self.ladderEndTime=0
	self.myselfInfo=nil
	self.myselfAllianceInfo=nil
	self.championName=""
	self.championSid=0
	self.championSeason=1
	self.lastRequestTime1=0
	self.lastRequestTime2=0
	self.lastRequestTime3=0
	self.lastRequestTime4=0
	self.ifHasEndWar=false
	self.rversion=1
	self.showWarIdList={}
	self.curPage=1
	self.hofcount=0
	self.isNewHofData=false
	self.ifHasNextHofData=false
	self.ifHasBattle=false
end
-- 
function ladderVoApi:formatData(data)
	if data and data.warlist then
		self.warlist=data.warlist
		self.ifNeedSendRequest=false
	end
	if data and data.rversion then
		self.rversion=data.rversion
	end
	if data and data.isBattle and data.isBattle==1 then
		self.ifHasBattle=true
	end
	if data and data.counttime then
		self.countTime=data.counttime
	end
	if data and data.season then
		self.season=data.season
	end
	if data and data.hofcount then
		if tonumber(data.hofcount)>tonumber(self.hofcount) then
			self.isNewHofData=true
		end
		
		self.hofcount=data.hofcount
	end
	if data and data.overtime then
		self.ladderEndTime=data.overtime
	end
	-- data.id 具体某个大战的id
	if data and data.group and data.id then
		self["serverWarVsList"..data.id]=data.group
	end
	if data and data.champion then
		self.championName=data.champion.name
		self.championSid=data.champion.sid
		self.championSeason=data.champion.season
	end
	if data and data.list then
		if data.list.p and SizeOfTable(data.list.p)>0 then
			if self.isNewHofData==true then
				self.personHOFList=nil
			end
			if self.personHOFList==nil then
				self.personHOFList={}
			end
			for kk,vv in pairs(data.list.p) do
				local hofVo1 = ladderHofVo:new()
				hofVo1:initWithData(vv)
				table.insert(self.personHOFList,hofVo1)
			end
		end

		if data.list.a  and SizeOfTable(data.list.a)>0 then
			if self.isNewHofData==true then
				self.allianceHOFList=nil
			end
			if self.allianceHOFList==nil then
				self.allianceHOFList={}
			end
			for k,v in pairs(data.list.a) do
				local hofVo = ladderHofVo2:new()
				hofVo:initWithData(v)
				table.insert(self.allianceHOFList,hofVo)
			end
		end
		
	end

	if data and data.rankList then
		if data.action==1 then
			self.personLadderList=nil
			self.personLadderList={}
		else
			self.allianceLadderList=nil
			self.allianceLadderList={}
		end
		for k,v in pairs(data.rankList) do
			local rankVo = ladderRankVo:new()
			rankVo:initWithData(v,k)
			if data.action==1 then--个人排行榜
				table.insert(self.personLadderList,rankVo)
			else--军团排行榜
				table.insert(self.allianceLadderList,rankVo)
			end
		end
	end

	if data and data.myrank then
		if data.action==1 then
			self.myselfInfo=data.myrank
		else
			self.myselfAllianceInfo=data.myrank
		end
		
	end
	if data and data.pointdetail then
		local function sortA(a,b)
			if a and b and a.st and b.st then
				return a.st>b.st
			end
		end
		if data.action==1 then
			self.personScoreDetailList=nil
			self.personScoreDetailList={}
			for k,v in pairs(data.pointdetail) do
				local scoreVo=ladderScoreVo:new()
				scoreVo:initWithData(v)
				table.insert(self.personScoreDetailList,scoreVo)
			end
			table.sort(self.personScoreDetailList,sortA)
		else
			self.allianceScoreDetailList=nil
			self.allianceScoreDetailList={}
			for k,v in pairs(data.pointdetail) do
				local scoreVo=ladderScoreVo:new()
				scoreVo:initWithData(v)
				table.insert(self.allianceScoreDetailList,scoreVo)
			end
			table.sort(self.allianceScoreDetailList,sortA)
		end
	end
end

-- 是否正在结算积分
function ladderVoApi:ifCountingScore()
	if self.ifHasBattle==true and (G_getWeeTs(base.serverTime)+24*60*60)<(base.serverTime+self.countTime) then
		return true,G_getWeeTs(base.serverTime)+24*60*60-base.serverTime
	end
	return false,0
end

-- 是否还有下一页名人堂数据
function ladderVoApi:getIfHasNextHofData(curPage)
	if tonumber(self.hofcount)/self.maxPageNum>curPage then
		self.ifHasNextHofData=true
	else
		self.ifHasNextHofData=false
	end
	return self.ifHasNextHofData
end

-- 检测是否在没有数据的前提下，每次都去发送请求,目前设置，在天梯榜结算前，小于10分钟后，每次都请求数据
function ladderVoApi:checkIfNeedRequestByNoData()
	if tonumber(self.ladderEndTime)>0 and self.ladderEndTime-base.serverTime<=600 then
		return true
	end
	if self.ifHasEndWar==true then
		return true
	end
	return false
end

-- 是否需要发送请求
function ladderVoApi:checkIfNeedRequestData(rtype)
	if rtype==1 then
		if self.lastRequestTime1==0 or G_isToday(self.lastRequestTime1)==false then -- (base.serverTime-self.lastRequestTime1)>self.requestTimeGap then
			return true
		end
	elseif rtype==2 then
		if self.lastRequestTime2==0 or G_isToday(self.lastRequestTime2)==false then-- (base.serverTime-self.lastRequestTime2)>self.requestTimeGap then
			return true
		end
	elseif rtype==3 then
		if self.lastRequestTime3==0 or G_isToday(self.lastRequestTime3)==false then-- (base.serverTime-self.lastRequestTime3)>self.requestTimeGap then
			return true
		end
	elseif rtype==4 then
		if self.lastRequestTime4==0 or G_isToday(self.lastRequestTime4)==false then-- (base.serverTime-self.lastRequestTime4)>self.requestTimeGap then
			return true
		end	
	end
	
	return false
end
-- 第几赛季标题
function ladderVoApi:getServerWarSeasonTitle()
	return getlocal("serverWarLadderSeasonTitle",{self.season})
end

function ladderVoApi:getChampionName()
	return self.championName,GetServerNameByID(self.championSid)
end

function ladderVoApi:getAllServerWarList()
	local list = {}
	local flag = 1--0:该赛季不会开，1:已经结束，2：进行中，3：10.2开启，4：即将开启
	local title=""
	local state = ""
	local pic = ""
	local stateColor = G_ColorWhite
	local stStr=""
	local iconPic = ""
	local needShowList = {}
	local sort = 1
	local vsState = ""--vs面板的状态
	for k,v in pairs(self.warlist) do
		flag=tonumber(v.flag)
		title = self:getWarNameById(tonumber(v.id))
		sort=tonumber(v.id)
		pic="public/ladder/ladder_poker_"..v.id..".jpg"
		iconPic=self:getWarIconPicById(tonumber(v.id))
		if flag==0 then
			title = getlocal("funcWillOpen")
			sort=10*sort
		elseif flag==1 then
			state = getlocal("serverwarteam_all_end")
			stateColor = G_ColorRed
			self.ifHasEndWar=true
			vsState = state
		elseif flag==2 then
			state = getlocal("serverwar_ongoing")..getlocal("serverwar_dot")
			stateColor = G_ColorYellowPro
			if base.serverTime>=v.et then
				flag=1
				state = getlocal("serverwarteam_all_end")
				stateColor = G_ColorRed
			end
			vsState = state
		elseif flag==3 then
			if base.serverTime<v.st then
				state = getlocal("willOpenTime",{G_getDataTimeStr(v.st)})
				stateColor = G_ColorWhite
				vsState = getlocal("not_open")
			else
				-- 说明时间过了，但是还没更新最新的数据
				flag=2
				state = getlocal("serverwar_ongoing")..getlocal("serverwar_dot")
				stateColor = G_ColorYellowPro
				vsState = state
			end
		elseif flag==4 then
			if v.st and base.serverTime<v.st then--说明已经配置了开启时间，状态设置为3
				state = getlocal("willOpenTime",{G_getDataTimeStr(v.st)})
				stateColor = G_ColorWhite
				vsState = state
				flag=3
			else
				state = getlocal("funcWillOpen")
				stateColor = G_ColorWhite
				vsState = state
			end
		end
		if v.st==nil or v.st==0 then
			stStr=getlocal("funcWillOpen")
		else
			stStr=G_getDataTimeStr(v.st)	
		end
		
		etStr=G_getDataTimeStr(v.et)
		if flag~=0 and self.showWarIdList[id]==nil then
			self.showWarIdList[tostring(v.id)]=1
			-- table.insert(needShowList,{title=title,flag=flag,state=state,pic=pic,stateColor=stateColor,id=v.id,stStr=stStr,etStr=etStr,iconPic=iconPic})	
		end
		table.insert(list,{title=title,flag=flag,state=state,pic=pic,stateColor=stateColor,id=v.id,stStr=stStr,etStr=etStr,iconPic=iconPic,sort=sort,vsState=vsState})
	end
	local function sortA(a,b)
		if a.sort and b.sort then
		-- 	return tonumber(a.id)<tonumber(b.id)
		-- else
			return a.sort<b.sort
		end
	end
	table.sort(list,sortA)
	return list
end

-- 天梯榜最后结算时间
function ladderVoApi:getLadderEndTime()
	if self.ladderEndTime==nil or tonumber(self.ladderEndTime)==0 then
		return 0,false
	end
	local result=false
	if self.ladderEndTime and tonumber(self.ladderEndTime)>0 and base.serverTime>tonumber(self.ladderEndTime) then
		result = true
	end
	return G_getDataTimeStr(self.ladderEndTime),result
end

-- 获取大战的名字：id,1：个人跨服战，2：军团跨服战，3：世界大战，4：跨平台大战，5：跨区域战
function ladderVoApi:getWarIconPicById(id)
	local iconPic = ""
	if id==1 then
		iconPic = "serverWarPIcon.png"
	elseif id==2 then
		iconPic = "serverWarTIcon.png"
	elseif id==3 then
		iconPic = "ww_icon.png"
	elseif id==5 then
		iconPic = "serverWarLocalIcon.png"
	end
	return iconPic
end
-- 获取大战的名字：id,1：个人跨服战，2：军团跨服战，3：世界大战，4：跨平台大战，5：跨区域战
function ladderVoApi:getWarNameById(id)
	local name = ""
	id = tonumber(id)
	if id==1 then
		name = getlocal("serverwar_title")
	elseif id==2 then
		name = getlocal("serverwarteam_title")
	elseif id==3 then
		name = getlocal("world_war_title")
	elseif id==5 then
		name = getlocal("serverWarLocal_title")
	end
	return name
end

-- 我的天梯信息
function ladderVoApi:getMyselfInfo()
	local totalScore,score1,score2,score3,score5,myRank = 0,0,0,0,0,0
	if self.myselfInfo then
		if self.myselfInfo.detail and SizeOfTable(self.myselfInfo.detail)>0 then
			score1,score2,score3,score5=self.myselfInfo.detail["1"],self.myselfInfo.detail["2"],self.myselfInfo.detail["3"],self.myselfInfo.detail["5"]
		end
		
		totalScore,myRank=self.myselfInfo.score,self.myselfInfo.rank
	end
	return totalScore,score1,score2,score3,score5,myRank
end

function ladderVoApi:getMyselfTotalScore()
	local totalScore = -1
	if self.myselfInfo then
		totalScore=self.myselfInfo.score
	end
	return totalScore
end
-- 获取各个不同大战的积分，sid是大战id
function ladderVoApi:getMyselfInfoBySid(sid)
	if self.myselfInfo and self.myselfInfo.detail and self.myselfInfo.detail[tostring(sid)] then
		return self.myselfInfo.detail[tostring(sid)]
	end
	return 0
end

-- 我的军团天梯信息
function ladderVoApi:getMyAllianceInfo()
	local totalScore,score1,score2,score3,score5,myRank = 0,0,0,0,0,0
	if self.myselfAllianceInfo then
		if self.myselfAllianceInfo.detail and SizeOfTable(self.myselfAllianceInfo.detail)>0 then
			score1,score2,score3,score5=self.myselfAllianceInfo.detail["1"],self.myselfAllianceInfo.detail["2"],self.myselfAllianceInfo.detail["3"],self.myselfAllianceInfo.detail["5"]
		end
		totalScore,myRank=self.myselfAllianceInfo.score,self.myselfAllianceInfo.rank
	end
	return totalScore,score1,score2,score3,score5,myRank
end

function ladderVoApi:getMyAllianceTotalScore()
	local totalScore = -1
	if self.myselfAllianceInfo then
		totalScore=self.myselfAllianceInfo.score
	end
	return totalScore
end

-- 获取各个不同大战的积分，sid是大战id
function ladderVoApi:getMyAllianceInfoBySid(sid)
	if self.myselfAllianceInfo and self.myselfAllianceInfo.detail and self.myselfAllianceInfo.detail[tostring(sid)] then
		return self.myselfAllianceInfo.detail[tostring(sid)]
	end
	return 0
end

-- 个人天梯排行榜列表
function ladderVoApi:getPersonLadderList()
	-- if #self.personLadderList<=0 then
	-- 	for i=1,70 do
	-- 		table.insert(self.personLadderList,{rank=i,name="player name "..i*10,servername="servername No."..i,score=i*10000})
	-- 	end
	-- end
	return self.personLadderList
end

-- 军团天梯排行榜列表
function ladderVoApi:getAllianceLadderList()
	-- if #self.allianceLadderList<=0 then
	-- 	for i=1,100 do
	-- 		table.insert(self.allianceLadderList,{rank=i,name="allianceName"..i,servername="servername No."..i,score=i*20000})
	-- 	end
	-- end
	return self.allianceLadderList
end


-- 通过排名来获取奖励区间
function ladderVoApi:getRankDistrict(rank,subType)
	rank=tonumber(rank)
	-- todo通过配置来取值
	local desc = getlocal("ladderRank_noRank")
	local reward = {}
	local rewardCfg = nil
	if subType==10 then
		rewardCfg=skyladderCfg.personRankReward[self.rversion]
	elseif subType==11 then
		rewardCfg=skyladderCfg.allianceRankReward
	end
	for k,v in pairs(rewardCfg) do
		local range = v.range
		if rank>=range[1] and rank<=range[2] then
			if range[1]==range[2] then
				desc=range[1]
			else
				desc="("..range[1].."-"..range[2]..")"
			end
			reward=v.reward
			break
		end
	end
	
	return desc,reward
end

-- 通过索引来获取奖励区间
function ladderVoApi:getRankDistrickByIndix(index,subType)
	local desc = ""
	local rewardCfg = nil
	if subType==10 then
		rewardCfg=skyladderCfg.personRankReward[self.rversion]
	elseif subType==11 then
		rewardCfg=skyladderCfg.allianceRankReward
	end
	if rewardCfg and rewardCfg[index] and rewardCfg[index].range then
		if tonumber(rewardCfg[index].range[1])==tonumber(rewardCfg[index].range[2]) then
			desc=tostring(rewardCfg[index].range[1])
		else
			desc="("..rewardCfg[index].range[1].."-"..rewardCfg[index].range[2]..")"
		end

	end
	return desc
end

-- 获取天梯排行榜奖励配置
function ladderVoApi:getRankRewardCfg(subType)
	local rewardCfg = nil
	if subType==10 then
		rewardCfg=skyladderCfg.personRankReward[self.rversion]
	elseif subType==11 then
		rewardCfg=skyladderCfg.allianceRankReward
	end
	return rewardCfg
end

-- 获取各个大战服务器对阵表，返回nil时，需要请求数据
function ladderVoApi:getServerWarVsListByIndex(id)
	if id and self["serverWarVsList"..id] then
		return self["serverWarVsList"..id]
	end
	return nil
end

-- 个人名人堂列表，season：第几赛季，rank：排名，pic:玩家头像，name:玩家名称，sid:服务器id,et:赛季结束时间，fight:战斗力
function ladderVoApi:getPersonHOFList()
	if self.personHOFList==nil then
		return {}
	end
	return self.personHOFList
end
-- 军团名人堂列表，season：第几赛季，rank：排名，name:军团名称，sid:服务器id,et:赛季结束时间，fight:战斗力
function ladderVoApi:getAllianceHOFList()
	if self.allianceHOFList==nil then
		return {}
	end
	return self.allianceHOFList
end
-- 个人天梯积分明细，warname:大战名称，name1:我的名称，name2:对方名称，score1:我的天梯分，score2:他的天梯积分，addscore1:我变更的积分，addscore2:对方变更的积分，st:时间
function ladderVoApi:getPersonScoreDetailList()
	-- if #self.personScoreDetailList<=0 then
	-- 	for i=1,10 do
	-- 		table.insert(self.personScoreDetailList,{warname="跨服战名称",name1="myname",name2="othername",score1=1600,score2=2000,addscore1=300,addscore2=-300,st=1445965156})
	-- 	end
	-- end
	return self.personScoreDetailList
end

-- 军团天梯积分明细，warname:大战名称，name1:我的名称，name2:对方名称，score1:我的天梯分，score2:他的天梯积分，addscore1:我变更的积分，addscore2:对方变更的积分，st:时间
function ladderVoApi:getAllianceScoreDetailList()
	-- if #self.allianceScoreDetailList<=0 then
	-- 	for i=1,10 do
	-- 		table.insert(self.allianceScoreDetailList,{warname="跨服战名称",name1="myname",name2="othername",score1=1600,score2=2000,addscore1=300,addscore2=-300,st=1445965156})
	-- 	end
	-- end
	return self.allianceScoreDetailList
end

-- 帮助文字
function ladderVoApi:getHelpContentList()
	local list = {}
	local colorList = {}
	local temNum = 20
	for titleIndex=1,temNum do
		local title=getlocal("ladder_help_title_"..titleIndex)
		-- print("---dmj-----title:"..title)
		if string.find(title,"ladder_help")==nil then
			local tb = {}
			tb.title=title
			for subtitleIndex=1,temNum do
				local function addContent()
					local subtitle = getlocal("ladder_help_subtitle_"..titleIndex.."_"..subtitleIndex)
					if string.find(subtitle,"ladder_help")==nil then
						tb["subtitle"..subtitleIndex]=subtitle
						-- print("---dmj-----su:".."subtitle"..subtitleIndex.."---titleIndex:"..titleIndex)
						for contentIndex=1,temNum do

							local content = getlocal("ladder_help_content_"..titleIndex.."_"..subtitleIndex.."_"..contentIndex)
							if string.find(content,"ladder_help")==nil then
								-- print("---dmj-----su:".."titleIndex"..titleIndex.."---subtitleIndex:"..subtitleIndex.."---contentIndex"..contentIndex)
								tb["content"..subtitleIndex.."_"..contentIndex]=content
							end
						end
					end
				end
				if titleIndex==2 and subtitleIndex==2 then
					if self.showWarIdList["1"] and self.showWarIdList["1"]==1 then
						addContent()
					end
				elseif titleIndex==2 and subtitleIndex==3 then
					if self.showWarIdList["2"] and self.showWarIdList["2"]==1 then
						addContent()
					end
				elseif titleIndex==2 and subtitleIndex==4 then
					if self.showWarIdList["3"] and self.showWarIdList["3"]==1 then
						addContent()
					end
				elseif titleIndex==2 and subtitleIndex==5 then
					
					if self.showWarIdList["5"] and tonumber(self.showWarIdList["5"])==1 then
						addContent()
					end
				else
					addContent()
				end
				
			end
			table.insert(list,tb)
		end
	end
	colorList["content_color_2_1_2"]=G_ColorRed
	colorList["content_color_2_2_2"]=G_ColorRed
	colorList["content_color_2_4_2"]=G_ColorRed
	return list,colorList
end

--------------------以上是数据--------------------



--------------------以下是面板--------------------

-- 打开天梯面板
function ladderVoApi:openLadderDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/ladder/ladderDialog"
	local function openLadderHandler()
		local td=ladderDialog:new()
        local tbArr={}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("serverWarLadderRank"),true,layerNum)
        sceneGame:addChild(dialog,layerNum)
	end
    local function callbackHandler(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.ladder then
                -- self:formatData(sData.data.ladder)
            end
            openLadderHandler()
        end
    end
 --    if self.ifNeedSendRequest==true or self:checkIfNeedRequestData()==true then
		socketHelper:getLadderInfo(callbackHandler)
	-- else
		-- openLadderHandler()
	-- end
end

-- 打开天梯排行榜面板
function ladderVoApi:openLadderRankDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/ladder/ladderRankDialog"
	local function openLadderRankHandler()
		local td=ladderRankDialog:new()
        local tbArr={getlocal("ladderRank_title1"),getlocal("ladderRank_title2")}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,self:getServerWarSeasonTitle(),true,layerNum)
        sceneGame:addChild(dialog,layerNum)
	end
    local function callbackHandler(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.ladder then
                self.lastRequestTime1=base.serverTime
            end
            openLadderRankHandler()
        end
    end
    if (self:getPersonLadderList()==nil and self:checkIfNeedRequestByNoData()==true) or self:checkIfNeedRequestData(1)==true then
		local isCountScore=self:ifCountingScore()
		if isCountScore==false then
			socketHelper:getLadderRank(1,callbackHandler)
		else
			openLadderRankHandler()
		end
	else
		openLadderRankHandler()
	end
end
-- 打开天梯商店
function ladderVoApi:openLadderShopDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/ladder/ladderShopDialog"
	local td=ladderShopDialog:new()
    local tbArr={}
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("ladder_shop_title"),true,layerNum)
    sceneGame:addChild(dialog,layerNum)
end

-- 打开天梯帮助和奖励面板
function ladderVoApi:openLadderRewardDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/ladder/ladderRewardDialog"
    local function openRewardDialog( ... )
		local td=ladderRewardDialog:new()
	    local tbArr={getlocal("help"),getlocal("serverwar_help_title5")}
	    local tbSubArr={getlocal("alliance_war_personal"),getlocal("alliance_list_scene_name")}
	    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,tbSubArr,nil,getlocal("ladder_shop_title"),true,layerNum)
	    sceneGame:addChild(dialog,layerNum)
    end
    local function callbackHandler(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.ladder then
                
                self.lastRequestTime1=base.serverTime
            end
            openRewardDialog()
        end
    end
    if (self:getPersonLadderList()==nil and self:checkIfNeedRequestByNoData()) or self:checkIfNeedRequestData(1)==true then
		local isCountScore=self:ifCountingScore()
		if isCountScore==false then
			socketHelper:getLadderRank(1,callbackHandler)
		else
			openRewardDialog()	
		end
	else
		openRewardDialog()
	end
end

-- 打开各个跨服战对阵表
function ladderVoApi:openVsDialog(id,index,layerNum)
	require "luascript/script/game/scene/gamedialog/ladder/ladderServerWarVsDialog"
	local function openVsDialogHandler()
		local td=ladderServerWarVsDialog:new(id,index)
        local dialog=td:init(layerNum)
	end
    local function callbackHandler(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            -- if sData and sData.data and sData.data.ladder then
            --     self:formatData(sData.data.ladder,id)
            -- end
            openVsDialogHandler()
        end
    end
    if self:getServerWarVsListByIndex(id)==nil then
		socketHelper:getLadderGroup(id,callbackHandler)
	else
		openVsDialogHandler()
	end
end

-- 打开名人堂面板
function ladderVoApi:openHOFDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/ladder/ladderHOFDialog"
	local function openHOFDialogHandler()
		local td=ladderHOFDialog:new()
        local tbArr={getlocal("alliance_war_personal"),getlocal("alliance_list_scene_name")}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("loadder_hallOfFame"),true,layerNum)
        sceneGame:addChild(dialog,layerNum)
	end
    local function callbackHandler(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            openHOFDialogHandler()
            self.isNewHofData=false
        end
    end
    if self.isNewHofData==true then
		socketHelper:getLadderHistory(1,callbackHandler)
	else
		openHOFDialogHandler()
	end
end

-- 打开天梯明细面板
function ladderVoApi:openScoreDialog(tabType,layerNum)
	require "luascript/script/game/scene/gamedialog/ladder/ladderScoreDialog"
	local function openScoreDialogHandler()
		local td=ladderScoreDialog:new(tabType)
        local tbArr={getlocal("ladder_score_title2"),getlocal("ladder_score_title3")}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("ladder_score_title1"),true,layerNum)
        sceneGame:addChild(dialog,layerNum)
	end
	openScoreDialogHandler()
end

