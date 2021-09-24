-- 战斗前的数据处理展示
ltzdzVoApi={
	clancrossinfo=nil, -- 初始化信息
	openTime=nil, -- 战场时间
	friendList=nil, -- 好友列表
	ltzdzOpenDialog=nil, -- 结算时需要关闭的板子
	layerNum=0, --功能板子的层级
	rankExpireTime={0,0,0,0}, --请求排行信息过期时间
	rankList={{},{},{},{}}, --四种排行的数据
	seasonst=nil, --赛季开始时间
	playerRefreshTime=0, --刷新玩家势力信息页面的过期时间
}

function ltzdzVoApi:clear()
	require "luascript/script/game/gamemodel/ltzdz/ltzdzFightApi"
	require "luascript/script/game/gamemodel/ltzdz/ltzdzReportVoApi"
	require "luascript/script/game/gamemodel/ltzdz/ltzdzCityVoApi"
	self.clancrossinfo=nil
	self.openTime=nil
	self.friendList=nil
	self.ltzdzOpenDialog=nil
	self.layerNum=0
	self.rankExpireTime={0,0,0,0} --请求排行信息过期时间
	self.rankList={{},{},{},{}} --四种排行的数据
	self.playerRefreshTime=0
	ltzdzFightApi:clear()
	ltzdzReportVoApi:clear()
	ltzdzCityVoApi:clear()
	ltzdzChatVoApi:clear()
end

function ltzdzVoApi:getWarCfg()
	require "luascript/script/config/gameconfig/ltzdz/ltzdzWarCfg"
	return ltzdzWarCfg

end
function ltzdzVoApi:getBuildingCfg()
	require "luascript/script/config/gameconfig/ltzdz/ltzdzBuildingCfg"
	return ltzdzBuildingCfg
end
function ltzdzVoApi:getMapCfg()
	require "luascript/script/config/gameconfig/ltzdz/ltzdzMapCfg"
	return ltzdzMapCfg
end
function ltzdzVoApi:getFightCfg()
	require "luascript/script/config/gameconfig/ltzdz/ltzdzMaxFightCfg"
	return ltzdzMaxFightCfg
end


function ltzdzVoApi:isOpen()
	if base.ltzdz~=0 and base.ltzdzTb and base.ltzdzTb.st and base.ltzdzTb.st~=0 and base.ltzdzTb.round and base.ltzdzTb.round~=0 then
		return true
	else
		return false
	end
end

-- 是否在时间范围内(天)
function ltzdzVoApi:checkIsActive()
	local week = G_getFormatWeekDay(base.serverTime)
    local openTime = G_clone(self:getWarCfg().openDay)
    if openTime[2] == 0 then
      openTime[2] = 7
    end
    if openTime[1] == 0 then
      openTime[1] = 7
    end
    if (week == openTime[1] or week == openTime[2]) then
        return true
    else
    	local time = 0
    	if week < openTime[1] then
    		time = (openTime[1] - week) * 86400 - (base.serverTime - base.curZeroTime)
    	elseif week > openTime[1] then
    		time = ((7 - week) + openTime[1]) * 86400 - (base.serverTime - base.curZeroTime)
    	end
        return false, time
    end
end

--获取组队剩余次数
function ltzdzVoApi:getTeamNum()
	local useTeamNum = 0
	if self.clancrossinfo and self.clancrossinfo.useTeamNum then
		useTeamNum = self.clancrossinfo.useTeamNum
	end
	return (self:getWarCfg().teamLimit - useTeamNum)
end

-- 改为取配置
function ltzdzVoApi:getOpenLv()
	local cfg=self:getWarCfg()
	return cfg.openLevel or 60
end

-- 领土争夺战 主界面
function ltzdzVoApi:showTotalDialog(layerNum)
	local function openFunc()
		require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzTotalDialog"
		require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzTab1"
		require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzTab2"
		require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzTab3"
		local td=ltzdzTotalDialog:new(layerNum)
		local tbArr={getlocal("serverwar_schedule"),getlocal("ltzdz_shop"),getlocal("ltzdz_rank")}
		local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("ltzdz_title"),true,layerNum)
		sceneGame:addChild(dialog,layerNum)
	end
	self:crossInit(openFunc,layerNum+1)
end

function ltzdzVoApi:crossInit(callback,layerNum)
	local function serverFunc(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			-- if not self.clancrossinfo then
			-- 	-- 初始化信息
			-- 	require "luascript/script/game/gamemodel/ltzdz/ltzdzVo"
			-- 	self.clancrossinfo=ltzdzVo:new()
			-- end
			-- if sData and sData.data and sData.data.clancrossinfo then
			-- 	self.clancrossinfo:initWithData(sData.data.clancrossinfo)
			-- end
			-- if sData and sData.data and sData.data.invite then
			-- 	self.clancrossinfo:initWithData(sData.data)
			-- end
			-- if sData and sData.data and sData.data.invitelist then
			-- 	self.clancrossinfo:initWithData(sData.data)
			-- end
			-- if sData and sData.data and sData.data.openTime then
			-- 	self.openTime=sData.data.openTime
			-- end
			if sData and sData.data then
				self:updateCrossInit(sData.data)
			end
			
			if callback then
				callback(sData.data)
			end

			local isDelay,time =ltzdzVoApi:isDelaySettlement()
			if isDelay then
				eventDispatcher:dispatchEvent("ltzdz.mainRefresh",{})
				do return end
			end

			-- 赛季结算
			local seasonFunc = function() end
			if sData and sData.data and sData.data.ssend and sData.data.ssend.lastrp then
				local function showSeasonFunc()
					self:showSeasonSettle(layerNum,true,true,nil,sData.data.ssend,1)
				end
				seasonFunc=showSeasonFunc
				self:ltzdzGuildeFinished() --结束教学引导
			end

			-- 结算
			if sData and sData.data and sData.data.btdata then
				local retgems=sData.data.retgems or 0
				playerVoApi:setGems(retgems+playerVoApi:getGems())
				local costgems=sData.data.costgems or 0
				if costgems<=0 then
					costgems=0
				end
				local function nilCost()
					if seasonFunc then
						seasonFunc()
					end
				end
				local costFunc = nilCost
				if retgems~=0 or costgems~=0 then
					local costStr=getlocal("ltzdz_cost_settle",{costgems,retgems})
					local function costRetFunc()
						G_showNewSureSmallDialog(layerNum+1,true,true,getlocal("dialog_title_prompt"),costStr,seasonFunc)
					end
					costFunc=costRetFunc
				end

				local btdata=sData.data.btdata or {}
				local state=tonumber(sData.data.state or 4)
				local function taskFunc()
					if btdata.t and SizeOfTable(btdata.t)>0 then
	    				self:showTaskCompleteDialog(btdata.t,layerNum,costFunc)
	    			else
	    				if costFunc then
	    					costFunc()
	    				end
					end
				end
				self:showBattleEnd(layerNum,true,true,taskFunc,btdata,state)

				eventDispatcher:dispatchEvent("ltzdz.mainRefresh",{})
				self:ltzdzGuildeFinished() --结束教学引导
			else
				if seasonFunc then
					seasonFunc()
				end
			end
			
		end
	end
	socketHelper:ltzdzCrossInit(serverFunc)
end

function ltzdzVoApi:updateCrossInit(data)
	if not self.clancrossinfo then
		-- 初始化信息
		require "luascript/script/game/gamemodel/ltzdz/ltzdzVo"
		self.clancrossinfo=ltzdzVo:new()
	end
	if data and data.clancrossinfo then
		self.clancrossinfo:initWithData(data.clancrossinfo)
	end
	if data and data.invite then
		self.clancrossinfo:initWithData(data)
	end
	if data and data.invitelist then
		self.clancrossinfo:initWithData(data)
	end
	if data and data.openTime then
		self.openTime=data.openTime
	end
	if data and data.seasonst then -- 赛季开始时间
		self.seasonst=data.seasonst
	end
end


-- 组团和征战界面 sFlag 1:组团 2:征战
function ltzdzVoApi:showCampaign(layerNum,sFlag)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzCampaignDialog"
	local td=ltzdzCampaignDialog:new(layerNum,sFlag)
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("ltzdz_campaign"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

-- 邀请界面
function ltzdzVoApi:showInviteDialog(layerNum,istouch,isuseami,callBack,titleStr,inviteInfo)

	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzInviteSmallDialog"
	local dialog=ltzdzInviteSmallDialog:showInviteInfo(layerNum,istouch,isuseami,callBack,titleStr,inviteInfo)
	return dialog
end

-- 被邀请界面
function ltzdzVoApi:showBeInvitedDialog(layerNum,istouch,isuseami,callBack,titleStr,inviteInfo)
	-- local pic=playerVoApi:getPic()
 --    local iconPic=playerVoApi:getPersonPhotoName(pic)
 --    local inviteInfo={icon=iconPic,iconBg="icon_bg_gray.png",fight=88888,name=playerVoApi:getPlayerName() or ""}
 --    ltzdzVoApi:showBeInvitedDialog(self.layerNum+1,true,true,nil,getlocal("dialog_title_prompt"),inviteInfo)

	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzBeInvitedSmallDialog"
	local dialog=ltzdzBeInvitedSmallDialog:showBeInvitedInfo(layerNum,istouch,isuseami,callBack,titleStr,inviteInfo)
	return dialog
end

-- 激活部队选择页面
function ltzdzVoApi:showActiveTankDialog(layerNum,istouch,isuseami,callBack,titleStr,usedTroopTb)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzActiveTankSmallDialog"
	ltzdzActiveTankSmallDialog:showTankList(layerNum,istouch,isuseami,callBack,titleStr,usedTroopTb)
end

-- 好友或者其他玩家信息页面(小板子)
function ltzdzVoApi:showPlayerInfoSmallDialog(layerNum,istouch,isuseami,callBack,titleStr,infoTb)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzPlayerInfoSmallDialog"
	ltzdzPlayerInfoSmallDialog:showInfo(layerNum,istouch,isuseami,callBack,titleStr,infoTb)
end

-- 自己的信息页面（打板子）
function ltzdzVoApi:showPlayerInfoDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzPlayerInfoDialog"
	local td=ltzdzPlayerInfoDialog:new(layerNum)
	local tbArr={}
	local season=ltzdzVoApi.clancrossinfo.season
    local seasonStr=getlocal("ltzdz_season",{season})
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,seasonStr,true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

-- 段位详情面板
function ltzdzVoApi:showSegmentInfoDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzSegmentInfoDialog"
	ltzdzSegmentInfoDialog:showSegmentInfoDialog(layerNum)
end

-- 部队种类解锁数量
function ltzdzVoApi:getUnLockNum()
	local rpoint=self.clancrossinfo.rpoint or 0
	-- rpoint=2646
	local warCfg=self:getWarCfg()
	local placeNum=warCfg.placeNum
	local unLockNum=#placeNum
	for k,v in pairs(placeNum) do
		if rpoint<v then
			unLockNum=k-1
			break
		end
	end
	return unLockNum
end


function ltzdzVoApi:getTheaterDes(idx)
	local des=""
	if idx<6 then
		des=getlocal("ltzdz_segment_condition1",{getlocal("ltzdz_segment" .. idx)})
	else
		des=getlocal("ltzdz_segment_condition1",{getlocal("ltzdz_segment" .. 6)})
	end
	return des
end

-- 1:未设置 2：邀请好友 3：已经进入战斗 
function ltzdzVoApi:stepState()
	local state=1
	-- 不用判断（暂定）
	-- if self.clancrossinfo==nil or self.clancrossinfo.troops==nil or SizeOfTable(self.clancrossinfo.troops)==0 then
	-- 	flag=1
	-- end

	-- 先判断是否已经进入战斗
	if self.clancrossinfo and self.clancrossinfo.ally and self.clancrossinfo.ally~=0 then
		return 3
	end
	if self.clancrossinfo and self.clancrossinfo.troops and SizeOfTable(self.clancrossinfo.troops)~=0 then
		return 2
	end
	return state
end

-- 1:没报名 2：已报名 3：战斗
function ltzdzVoApi:getWarState()
	if not self.clancrossinfo then -- 没有数据就当没开始（从后台切前台要用）
		return 1
	end
	if not self.clancrossinfo.st then
		return 1
	end
	-- if not self.clancrossinfo.et then
	-- 	return 1
	-- end
	-- if self.clancrossinfo.st==0 or self.clancrossinfo.et==0 then
	-- 	return 1
	-- end
	if self.clancrossinfo.st==0 then
		return 1
	end

	-- if base.serverTime>=self.clancrossinfo.et then
	-- 	return 1
	-- end
	if base.serverTime<self.clancrossinfo.st then
		return 2 -- 能打野城
	end
	return 3 -- 真正战斗
end

-- 激活部队
function ltzdzVoApi:socketSetTroop(troopTb,gems,pCallback)

	local function serverFunc(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.clancrossinfo then
				self.clancrossinfo:initWithData(sData.data.clancrossinfo)
			end
			-- 防止进入战斗是上一场的老数据
			ltzdzFightApi:clear()

			if pCallback then
				pCallback()
			end
		end
	end
	socketHelper:ltzdzActiveTroop(serverFunc,troopTb,gems)
end

-- 好友列表
function ltzdzVoApi:socketFriend(pCallback)
	local function socketFunc(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then

        	if sData and sData.data and sData.data.friends then
        		self.friendList=sData.data.friends
	        end
            if pCallback then
            	pCallback()
            end
        end
        
    end
    socketHelper:ltzdzFriend(socketFunc)
end

-- 朋友列表排序  邀请 被邀请 段位 战斗力 uid(一次递减)
function ltzdzVoApi:getTrueFriendList()
	if not self.friendList then
		self.friendList = {}
	end

	local friendList=G_clone(self.friendList)

	for k,v in pairs(friendList) do -- 未被邀请的index全部是1
		v.index=1
	end

	local function isHave(uid)
		for k,v in pairs(friendList) do
			if v then
				if tonumber(uid)==tonumber(v.uid) then
					return k
				end
			end
		end
		return nil
	end

	local invite=self.clancrossinfo.invite
	if invite and invite.uid then
		local id=isHave(invite.uid)
		if id then
			friendList[id].index=friendList[id].index+10000
		else
			invite.index=10001
			table.insert(friendList,invite)
		end
	end

	local invitelist=self.clancrossinfo.invitelist 
	if invitelist then
		for k,v in pairs(invitelist) do
			if v then
				local id=isHave(v.uid)
				if id then
					friendList[id].index=id+1000
				else
					v.index=1000+k
					table.insert(friendList,v)
				end
			end
		end
	end

	local function sortFunc(a,b)
		return self:sortFriendList(a,b)
	end
	table.sort(friendList,sortFunc)

	-- for k,v in pairs(friendList) do
	-- 	print(k,v.nickname,v.index)
	-- end
	return friendList

end

function ltzdzVoApi:sortFriendList(a,b)

	if a and b then
		if tonumber(a.index)==tonumber(b.index) then
			if tonumber(a.rpoint)==tonumber(b.rpoint) then
				if tonumber(a.fc)==tonumber(b.fc) then
					return tonumber(a.uid)<tonumber(b.uid)
				else
					return tonumber(a.fc)>tonumber(b.fc)
				end
			else
				return tonumber(a.rpoint)>tonumber(b.rpoint)
			end
		else
			return tonumber(a.index)>tonumber(b.index)
		end
		
	end
end

-- action action 1 邀请，2 接受邀请，3 拒绝邀请 4:取消邀请
function ltzdzVoApi:socketOperateFriend(pCallback,uid,action)
	local function serverFunc(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			-- if sData and sData.data and sData.data.invite then
			-- 	self.clancrossinfo.invite=sData.data.invite
			-- end
			-- if sData and sData.data and sData.data.invitelist then
			-- 	self.clancrossinfo.invitelist=sData.data.invitelist
			-- end
			if sData and sData.data then
				self:updateInviteOrBeinvite(sData.data,action)
			end
		
			if pCallback then
				pCallback(action)
			end
		end
	end
	socketHelper:ltzdzOperateFriend(serverFunc,uid,action)
end

--获取本场战斗报名截止时间戳
-- curEt=0(不能邀请好友)
function ltzdzVoApi:getSignEndTime()
	local cwCfg=self:getWarCfg()
	local standTime=cwCfg.standTime
	local notEnter=cwCfg.notEnter
	local lastTime = standTime - notEnter
	local weets=G_getWeeTs(base.serverTime) -- 当天零点时间戳

	local curEt = 0
	for k,v in pairs(self.openTime) do

		local daySt = v[1] * 3600 + v[2] * 60
        local st = weets + daySt
        local et = st + lastTime
        if base.serverTime>=st and base.serverTime <= et then
        	curEt = et
        	break
        end
		local lastSt = weets - 86400 + daySt
		local lastEt = lastSt + lastTime
		if base.serverTime>=lastSt and base.serverTime<=lastSt then
			curEt = lastEt
            break
		end

	end
	return  curEt
end

-- return flag:0未在报名期 1：在报名期
function ltzdzVoApi:canSignTime()
	local weets=G_getWeeTs(base.serverTime) -- 当天零点时间戳
	local cwCfg=self:getWarCfg()
	local standTime=cwCfg.standTime
	local notEnter=cwCfg.notEnter
	local lastTime = standTime - notEnter
	local flag=0
	local curDuan=0
	local curEndTime=0
	for k,v in pairs(self.openTime) do
		local daySt = v[1] * 3600 + v[2] * 60
		local oT=daySt+weets
		if base.serverTime<oT then
			flag=0
			curDuan=k
			break
		elseif base.serverTime>=oT and base.serverTime<oT+lastTime then
			flag=1
			curDuan=k
			curEndTime=oT+lastTime
			break
		end
	end

	return flag,curDuan,curEndTime,lastTime
end

function ltzdzVoApi:isPopBeInviteDialog()
	-- 在邀请别人
	if self.clancrossinfo and self.clancrossinfo.invite and self.clancrossinfo.invite.uid then
		return false
	end
	if self.clancrossinfo and self.clancrossinfo.invitelist and SizeOfTable(self.clancrossinfo.invitelist)~=0 then
		return true
	end
	return false
end

-- 根据等级得到段位
function ltzdzVoApi:getSegByLevel(level)
	-- 两个组合 青铜1
	local seg=1 -- 段位
	local smallLevel=1 -- 等级
	
	local cwCfg=self:getWarCfg()
	local rankTitle=cwCfg.rankTitle
	local everySeg=self:getEverySeg()

	local totalNum=#rankTitle
	-- print("totalNum,level",totalNum,level,rankTitle[totalNum])
	if level>rankTitle[totalNum] then
		seg=self:cfgSegNum()
		smallLevel=nil
		return seg,smallLevel,totalNum+1
	end

	local totalSeg=0
	for k,v in pairs(rankTitle) do
		if level<=v then
			totalSeg=k
			seg=math.ceil(totalSeg/everySeg)
			smallLevel=totalSeg-(seg-1)*everySeg
			break
		end
	end
	return seg,smallLevel,totalSeg
end

function ltzdzVoApi:getTotalSeg(seg,slv)
	if seg==6 then --如果是顶级段位，只有一个子段位
		local warCfg=self:getWarCfg()
		return #warCfg.rankTitle+1
	else
		local everySeg=self:getEverySeg()
		return (seg-1)*everySeg+(slv or 0)
	end
end

function ltzdzVoApi:getEverySeg(seg)
	local everySeg=3 -- 每个段位三级 （写死），完后要改记得改啊
	if seg==6 then
		everySeg=1
	end
	return everySeg
end


function ltzdzVoApi:segIsFull(rpoint)
	local cwCfg=self:getWarCfg()
	local rankTitle=cwCfg.rankTitle
	if rpoint > rankTitle[#rankTitle] then
		return true,rankTitle[#rankTitle]
	else
		return false
	end
end

function ltzdzVoApi:getSegment(rpoint)
   	local clancrossinfo=self.clancrossinfo or {}
   	if not rpoint then
   		rpoint=tonumber(clancrossinfo.rpoint or 0)
   	end
    local seg,smallLevel,totalSeg=self:getSegByLevel(rpoint)

    return seg,smallLevel,totalSeg
end

function ltzdzVoApi:getNextSegInfo(rpoint)
	local per=0
	local proStr=""
	local upLimit,downLimit=0,0
	if rpoint==nil then
		rpoint=self.clancrossinfo.rpoint
	end
	local seg,smallLevel,totalSeg=self:getSegByLevel(rpoint)
	if smallLevel==nil then -- 已到最高段位
		local fullFlag2,setLimitNum=self:segIsFull(rpoint)
		per=100
		proStr=rpoint-setLimitNum
		-- local warCfg=self:getWarCfg()
		-- rpoint=warCfg.rankTitle[#warCfg.rankTitle]
		-- upLimit=rpoint
	else
		upLimit,downLimit=self:getNextSmallSeg(totalSeg)
		local molecular=rpoint-downLimit -- 分子
		local Denominator=upLimit-downLimit -- 分母
		proStr=molecular .. "/" .. Denominator
		per=molecular/Denominator*100
	end

	return per,proStr
end


function ltzdzVoApi:getSegName(seg,smallLevel)
	local segName=""
	if smallLevel and seg<6 then
        segName=getlocal("ltzdz_segment" .. seg) .. getlocal("ltzdz_roman_num"..(4-smallLevel))
    else
        segName=getlocal("ltzdz_segment" .. seg)
    end
    return segName
end

-- 配置一共有几个段位（大）
function ltzdzVoApi:cfgSegNum()
	local cwCfg=self:getWarCfg()
	local rankTitle=cwCfg.rankTitle
	local titleNum=#rankTitle+1
	local everySeg=ltzdzVoApi:getEverySeg()
	return math.ceil(titleNum/everySeg)
end

function ltzdzVoApi:getNextSmallSeg(nowSmallSeg)
	local cwCfg=self:getWarCfg()
	local rankTitle=cwCfg.rankTitle
	local upLimit=rankTitle[nowSmallSeg]
	local downLimit=rankTitle[nowSmallSeg-1] or 0
	return upLimit,downLimit
end

--itype:图标的类型（1：小图标，2：大图标，3：大图标（但是突出小段位的数字显示））当seg是荣耀段位的话，smallLevel可以传超过该段位的分数
--段位1、3 ：  255 206 187
--段位2、6：默认白色
--段位4 : 222 255 193
--段位5 : 255 206 187
function ltzdzVoApi:getSegIcon(seg,smallLevel,callback,itype,effcFlag,noEffect)
	itype=itype or 2
	local segPic="ltzdz_seg_"..seg..".png"
	if itype==1 then
		segPic="ltzdz_smallseg_"..seg..".png"
	end
	local function touchHandler(object,event,tag)
		if callback then
			callback(object,event,tag)
		end
	end
	local segSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchHandler)
	segSp:setOpacity(0)
	local iconSp=CCSprite:createWithSpriteFrameName(segPic)
	segSp:setContentSize(iconSp:getContentSize())
	iconSp:setPosition(getCenterPoint(segSp))
	iconSp:setTag(101)
	segSp:addChild(iconSp,1)
	if smallLevel and smallLevel>0 then
		local smallSp
		if seg~=6 then
			local smallPic="ltzdz_segnum_"..(4-smallLevel)..".png"
			smallSp=CCSprite:createWithSpriteFrameName(smallPic)
		else
			smallSp=GetTTFLabel(smallLevel,22,true)
		end
		smallSp:setTag(103)
		if itype==1 and seg~=6 then
			smallSp:setScale(0.8)
			smallSp:setPosition(getCenterPoint(iconSp))
			iconSp:addChild(smallSp)
		else
			local caidaiPosYCfg={43,43,40,40,30,30}
			local caidaiPic="ltzdz_dai_"..seg..".png"
			local caidaiSp=CCSprite:createWithSpriteFrameName(caidaiPic)
			caidaiSp:setAnchorPoint(ccp(0.5,1))
			caidaiSp:setPosition(iconSp:getContentSize().width/2,caidaiPosYCfg[seg])
			caidaiSp:setTag(102)
			iconSp:addChild(caidaiSp)

			smallSp:setPosition(caidaiSp:getContentSize().width/2,caidaiSp:getContentSize().height/2+6)
			smallSp:setTag(103)
			caidaiSp:addChild(smallSp)
			if itype==3 then
				caidaiSp:setScale(1.5)
				caidaiSp:setPosition(iconSp:getContentSize().width/2,caidaiPosYCfg[seg]+6)
			end
		end
	end
	if itype~=1 and (noEffect==nil or noEffect==false) then
		local function playFrameAction(parent,pos,frc,frameName,frtime,dt,zorder,turnFlag)
			zorder=zorder or 0
		  	local frameSp=CCSprite:createWithSpriteFrameName(frameName.."_1"..".png")
				local frameArr=CCArray:create()
			for k=1,frc do
				local nameStr=frameName.."_"..k..".png"
				local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
				frameArr:addObject(frame)
			end
			local animation=CCAnimation:createWithSpriteFrames(frameArr)
			animation:setDelayPerUnit(frtime)
			local animate=CCAnimate:create(animation)
			frameSp:setAnchorPoint(ccp(0.5,0.5))
			frameSp:setPosition(pos)
			frameSp:setOpacity(0)
			parent:addChild(frameSp,zorder)
			local blendFunc=ccBlendFunc:new()
			blendFunc.src=GL_ONE
			blendFunc.dst=GL_ONE
			frameSp:setBlendFunc(blendFunc)
			if turnFlag and turnFlag==true then
				frameSp:setFlipX(true)
			end
			local delayAction=CCDelayTime:create(dt)
			local function showSp()
				frameSp:setOpacity(255)
			end
			local function removeSp()
				frameSp:setOpacity(0)
			end
			local showCallFunc=CCCallFuncN:create(showSp)
			local removeCallFunc=CCCallFuncN:create(removeSp)
			local acArr=CCArray:create()
			acArr:addObject(showCallFunc)
			acArr:addObject(animate)
			acArr:addObject(removeCallFunc)
			acArr:addObject(delayAction)
			local seq=CCSequence:create(acArr)
			local repeatForever=CCRepeatForever:create(seq)
			frameSp:runAction(repeatForever)
		end
		if seg==6 then
			playFrameAction(iconSp,ccp(iconSp:getContentSize().width/2,iconSp:getContentSize().height/2+20),8,"segxhsg",0.06,0,2)
			playFrameAction(iconSp,ccp(iconSp:getContentSize().width/2-43,iconSp:getContentSize().height/2+23),12,"segsg",0.1,0,1)
			playFrameAction(iconSp,ccp(iconSp:getContentSize().width/2+43,iconSp:getContentSize().height/2+23),12,"segsg",0.1,0,1,true)
			local guangSp=CCSprite:createWithSpriteFrameName("segguang_1.png")
			guangSp:setPosition(getCenterPoint(segSp))
			guangSp:setOpacity(0)
			segSp:addChild(guangSp)
			local acArr=CCArray:create()
			local fadeIn=CCFadeIn:create(0.6)
			local fadeOut=CCFadeOut:create(0.6)
			acArr:addObject(fadeIn)
			acArr:addObject(fadeOut)
			local seq=CCSequence:create(acArr)
			guangSp:runAction(CCRepeatForever:create(seq))
		elseif (seg~=1 and seg~=2) then
			local xingPosCfg={
				ccp(iconSp:getContentSize().width/2,iconSp:getContentSize().height/2+20),
				ccp(iconSp:getContentSize().width/2,iconSp:getContentSize().height/2+23),
				ccp(iconSp:getContentSize().width/2,iconSp:getContentSize().height/2+22),
				ccp(iconSp:getContentSize().width/2,iconSp:getContentSize().height/2+25),
				ccp(iconSp:getContentSize().width/2,iconSp:getContentSize().height/2+28),
			}
			playFrameAction(iconSp,xingPosCfg[seg],7,"segxxsao",0.1,1,1)
		end
		if seg>1 then
			local xingRandomCfg={
				{ccp(126,27),ccp(69,50),ccp(187,93),ccp(129,154)},
				{ccp(124,22),ccp(67,56),ccp(187,92),ccp(127,152)},
				{ccp(129,153),ccp(187,90),ccp(70,58),ccp(126,23)},
				{ccp(128,148),ccp(188,81),ccp(67,58),ccp(127,18)},
				{ccp(128,143),ccp(184,94),ccp(69,64),ccp(127,11)},
				{ccp(185,83),ccp(67,57),ccp(127,139),ccp(127,16)},
			}
			local xingColorCfg={
				ccc3(255,255,255),
				ccc3(255,206,187),
				ccc3(222,255,193),
				ccc3(255,255,187),
				ccc3(255,255,255),
				ccc3(255,255,187),
			}
			local acArr=CCArray:create()
			local function playxingxing()
				local cfg=G_clone(xingRandomCfg[seg])
				local timeCfg={0.3,0.6,1,1.5}
				for i=1,3 do
					local idx=math.random(1,SizeOfTable(cfg))
					local pos=cfg[idx]
					table.remove(cfg,idx)
					local dt=timeCfg[math.random(1,SizeOfTable(timeCfg))]
					local xingSp=CCSprite:createWithSpriteFrameName("segxing.png")
					xingSp:setPosition(pos.x,segSp:getContentSize().height-pos.y)
					xingSp:setColor(xingColorCfg[seg])
					xingSp:setScale(0)
					local blendFunc=ccBlendFunc:new()
					blendFunc.src=GL_ONE
					blendFunc.dst=GL_ONE_MINUS_SRC_COLOR
					xingSp:setBlendFunc(blendFunc)
					iconSp:addChild(xingSp)

					local acArr=CCArray:create()
					local delayAc=CCDelayTime:create(dt)
					acArr:addObject(delayAc)

					local spawnArr1=CCArray:create()
					local rotateAC1=CCRotateBy:create(0.5,30)
					local scaleTo1=CCScaleTo:create(0.5,1)
					spawnArr1:addObject(rotateAC1)
					spawnArr1:addObject(scaleTo1)
					local spawnAc1=CCSpawn:create(spawnArr1)
					acArr:addObject(spawnAc1)

					local spawnArr2=CCArray:create()
					local rotateAC2=CCRotateBy:create(0.5,30)
					local scaleTo2=CCScaleTo:create(0.5,0)
					spawnArr2:addObject(rotateAC2)
					spawnArr2:addObject(scaleTo2)
					local spawnAc2=CCSpawn:create(spawnArr2)
					acArr:addObject(spawnAc2)

					local function removeSp()
						xingSp:removeFromParentAndCleanup(true)
					end
					local callFunc=CCCallFuncN:create(removeSp)
					acArr:addObject(callFunc)
					local seq=CCSequence:create(acArr)
					xingSp:runAction(seq)
				end
			end
			local callFunc=CCCallFuncN:create(playxingxing)
			acArr:addObject(callFunc)
			local delayAc=CCDelayTime:create(2.5)
			acArr:addObject(delayAc)
			local seq=CCSequence:create(acArr)
			segSp:runAction(CCRepeatForever:create(seq))
		end
	end

	return segSp
end

-- 最短路劲（迪杰斯特拉算法）
function ltzdzVoApi:shortPath_Dijkstra(startCity,endCity,havaCityTb)
	-- local havaCityTb={"a1","a2","a3","a4","a5","a6","a7","a8"}
	local newCityTb=G_clone(havaCityTb)
	table.insert(newCityTb,endCity)

	local mapCfg=self:getMapCfg()
	local citycfg=mapCfg.citycfg

	local maxValue=65535


	local final={}
	local disTb={}
	local pTb={}
	for k,v in pairs(newCityTb) do
		final[v]=0
		if startCity==v then
			disTb[v]=0
			final[v]=1
			pTb[v]=startCity
		else
			disTb[v]=citycfg[startCity].adjoin[v] or maxValue
			pTb[v]=startCity
		end
	end

	local minId
	for k,v in pairs(newCityTb) do
		if v~=startCity then
			local min=maxValue
			for kk,vv in pairs(newCityTb) do
				if final[vv]~=1 and disTb[vv]<min then
					minId=vv
					min=disTb[vv]
				end
			end
			final[minId]=1

			for kk,vv in pairs(newCityTb) do
				if final[vv]~=1 and (min+(citycfg[minId].adjoin[vv] or maxValue)<disTb[vv]) then
					disTb[vv]=min+citycfg[minId].adjoin[vv] or maxValue
					pTb[vv]=minId
				end
			end
		end
	end

	local pathTb={endCity}
	local function creatPathTb(path)
		table.insert(pathTb,1,path)
		if path~=startCity then
			creatPathTb(pTb[path])
		end
	end
	creatPathTb(pTb[endCity])

	-- for k,v in pairs(pathTb) do
	-- 	print(k,v)
	-- end
	return pathTb
end

-- flag 1:自己返回的数据更新  >100：后台推送的数据更新
function ltzdzVoApi:updateInviteOrBeinvite(data,flag)
	if self.clancrossinfo then
		-- self.clancrossinfo:initWithData(data)
		self:updateCrossInit(data)
		if data and data.clancrossinfo and data.clancrossinfo.ally and data.clancrossinfo.ally~="" and tonumber(data.clancrossinfo.ally)~=0 then -- (别人同意邀请，给自己推消息)
			-- self:updateCrossInit(data)
			-- print("+++++++++++同意")
			ltzdzFightApi:initData(data)
			eventDispatcher:dispatchEvent("ltzdz.ally",{})
		else
			eventDispatcher:dispatchEvent("ltzdz.friend",{flag})
		end
		
	end
end


-- 部队选择页面
function ltzdzVoApi:showSelectTankDialog(layerNum,istouch,isuseami,callBack,titleStr,limitNum)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzSelectTankSmallDialog"
	ltzdzSelectTankSmallDialog:showTankList(layerNum,istouch,isuseami,callBack,titleStr,limitNum)
end

-- 计策页面
function ltzdzVoApi:showStratagemDialog(layerNum,tid)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzStratagemDialog"
	local td=ltzdzStratagemDialog:new(tid)
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("ltzdz_jice_bag"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

--显示个人信息
function ltzdzVoApi:showPlayerDialog(layerNum,parent)
	local function realShow()
		require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzPlayerDialog"
		local td=ltzdzPlayerDialog:new(parent)
		local tbArr={}
		local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("ltzdz_player_info"),true,layerNum)
		sceneGame:addChild(dialog,layerNum)
	end
	if base.serverTime>=self.playerRefreshTime then
        ltzdzCityVoApi:syncCity(nil,realShow,1)
		self.playerRefreshTime=base.serverTime+300
	else
		realShow()
	end
end

--显示计策背包
function ltzdzVoApi:showStratagemBagDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzStratagemBagDialog"
	local td=ltzdzStratagemBagDialog:new(layerNum)
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("bundle"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

--显示任务面板
function ltzdzVoApi:showTaskSmallDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzTaskSmallDialog"
	ltzdzTaskSmallDialog:showTaskSmallDialog(layerNum,true,true)
end

--显示外交页面
function ltzdzVoApi:showForeignDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzForeignDialog"
	local td=ltzdzForeignDialog:new(layerNum)
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("ltzdz_diplomacy"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

--显示段位提升的面板
function ltzdzVoApi:showSegUpgradeSmallDialog(seg,smallLv,callBack,layerNum,lastSeg,lastSmallLv)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzSegUpgradeSmallDialog"
	ltzdzSegUpgradeSmallDialog:showSegUpgradeDialog(lastSeg,lastSmallLv,seg,smallLv,callBack,layerNum)
end

function ltzdzVoApi:showBattleEnd(layerNum,istouch,isuseami,callBack,endInfo,state)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzBattleEndSmallDialog"
	ltzdzBattleEndSmallDialog:showEnd(layerNum,istouch,isuseami,callBack,endInfo,state)
end

function ltzdzVoApi:showTaskCompleteDialog(tasklist,layerNum,callback)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzTaskSmallDialog"
	ltzdzTaskSmallDialog:showTaskCompleteDialog(tasklist,layerNum,callback)
end

function ltzdzVoApi:showSeasonSettle(layerNum,istouch,isuseami,callBack,seaInfo,state)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzSeasonSmallDialog"
	ltzdzSeasonSmallDialog:showSeason(layerNum,istouch,isuseami,callBack,seaInfo,state)
end

function ltzdzVoApi:showHelpDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzHelpDialog"
	local td=ltzdzHelpDialog:new(layerNum)
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("ltzdz_help_title"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

--获取我本次战斗所激活的部队
function ltzdzVoApi:getMyActiveTroops()
	return self.clancrossinfo.troops
end

--根据段位获取相应的赛季结束的奖励（小段位）
function ltzdzVoApi:getFinalRewards(totalSeg)
	local rewardlist={}
    local warCfg=self:getWarCfg()
    local rewardCfg=warCfg.reward[totalSeg]
    if rewardCfg and rewardCfg.reward then
    	rewardlist=FormatItem(rewardCfg.reward,nil,true)
    end
    return rewardlist
end

function ltzdzVoApi:getPlayerTotalData()
    require "luascript/script/game/gamemodel/ltzdz/ltzdzFightApi"
    require "luascript/script/game/gamemodel/ltzdz/ltzdzCityVoApi"
    local rc,oc,mec=0,0,0 --预备役,石油，金钱的总产量
    local trbNum,tobNum,tmetalbNum=0,0,0 --总的坦克工厂，油井，市场的总数
    local tReserveNum,cityNum,bigNum,smallNum=0,0,0,0 --总的预备役数量，城市总数，大城数，小城数
	local mapVo=ltzdzFightApi:getMapVo()
	local citylist=mapVo.city
	for cityId,city in pairs(citylist) do
		local uid=playerVoApi:getUid()
		if city.oid and (tonumber(uid)==tonumber(city.oid)) then
	    	local reserve,oil,metal,rbNum,obNum,mebNum,rnum=ltzdzCityVoApi:getCityCapacity(cityId)
			rc=rc+reserve
			oc=oc+oil
			mec=mec+metal
			trbNum=trbNum+rbNum
			tobNum=tobNum+obNum
			tmetalbNum=tmetalbNum+mebNum
			tReserveNum=tReserveNum+rnum
			if city.b and city.b[1] then
				local btype=city.b[1]
				if btype==1 then
					bigNum=bigNum+1
				elseif btype==2 then
					smallNum=smallNum+1
				end
			end
			cityNum=cityNum+1
		end
	end
	local metal,oil,gems=ltzdzFightApi:getMyRes()
	return rc,oc,mec,trbNum,tobNum,tmetalbNum,tReserveNum,metal,oil,cityNum,bigNum,smallNum
end

function ltzdzVoApi:getMyCityList()
    require "luascript/script/game/gamemodel/ltzdz/ltzdzFightApi"
    require "luascript/script/game/gamemodel/ltzdz/ltzdzCityVoApi"
	local mapVo=ltzdzFightApi:getMapVo()
	local citylist=mapVo.city
	local mycitys={}
	for k,v in pairs(citylist) do
		local uid=playerVoApi:getUid()
		if v.oid and (tonumber(uid)==tonumber(v.oid)) then
			local city=ltzdzCityVoApi:getCity(k)
			table.insert(mycitys,city)
		end
	end
	return mycitys
end

function ltzdzVoApi:ltzdzExploitShopBuy(seg,pid,callback)
	local function buyHandler(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data and sData.data.clancrossinfo and self.clancrossinfo then
				self.clancrossinfo:initWithData(sData.data.clancrossinfo)	
			end
			if callback then
				callback()
			end
		end
	end
	socketHelper:ltzdzExploitShopBuy(seg,pid,buyHandler)
end

function ltzdzVoApi:getMyPoint()
	local tpoint=self.clancrossinfo.point or 0 --总的功勋值
	local cpoint=self.clancrossinfo.cpoint or 0 --已经消耗的功勋值
	return tonumber(tpoint-cpoint)
end

--获取功勋值商店
function ltzdzVoApi:getShop(segment)
	local warCfg=self:getWarCfg()
    local shopCfg=warCfg.taskShop[segment] or {}
    
    return shopCfg
end

function ltzdzVoApi:getBuyBlog(segment)
	if self.clancrossinfo and self.clancrossinfo.buynum then
		local rid="r"..segment
		return self.clancrossinfo.buynum[rid] or {}
	end
	return {}
end

--经过排序的功勋值商店
function ltzdzVoApi:getSortShop(segment)
	local trueShop={}
	local shop=self:getShop(segment)
	local buyLog=self:getBuyBlog(segment)
	local myPoint=self:getMyPoint()
	for k,v in pairs(shop) do
		local index=tonumber(RemoveFirstChar(k))
		local limit=v.bn
		local buyNum=buyLog[k] or 0
		if buyNum>=limit then
			index=index+10000
		elseif myPoint<v.p then
			index=index+1000
		end
		local subTb={index=index,id=k}
		table.insert(trueShop,subTb)
	end
	local function sortFunc(a,b)
		return a.index<b.index
	end
	table.sort(trueShop,sortFunc)
	return trueShop
end

function ltzdzVoApi:getHttphostUrl()
	if self.clancrossinfo and self.clancrossinfo.cwhost then
		return "http://" .. self.clancrossinfo.cwhost .. "/tank-server/public/index.php/api/mapwar/"
	end
end

-- 势力战外 邀请好友私聊
function ltzdzVoApi:invitySendPrivateChat(reciverName,reciver)
	local senderName=tostring(playerVoApi:getPlayerName())
    local level=playerVoApi:getPlayerLevel()
    local rank=playerVoApi:getRank()
    local power=playerVoApi:getPlayerPower()
    local contentType=1
    local allianceName
    local allianceRole
    if allianceVoApi:isHasAlliance() then
        local allianceVo=allianceVoApi:getSelfAlliance()
        allianceName=allianceVo.name
        allianceRole=allianceVo.role
    end
    local content=getlocal("ltzdz_chat_invite")
    local language=G_getCurChoseLanguage()
    local params={subType=2,contentType=contentType,message=content,level=level,rank=rank,power=power,uid=playerVoApi:getUid(),name=tostring(playerVoApi:getPlayerName()),pic=playerVoApi:getPic(),ts=base.serverTime,allianceName=allianceName,allianceRole=allianceRole,vip=playerVoApi:getVipLevel(),language=language,wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),title=playerVoApi:getTitle(),ltzdz=base.serverTime+3600}
    -- local reciver=chatVoApi:getReciverIdByName(reciverName)
    chatVoApi:sendChatMessage(0,sender,senderName,reciver,reciverName,params)
    chatVoApi:addChat(0,sender,senderName,reciver,reciverName,params)
end

function ltzdzVoApi:addOrRemoveOpenDialog(flag,dStr,dialog)
	if flag==1 then
		if not self.ltzdzOpenDialog then
			self.ltzdzOpenDialog={}
		end
		self.ltzdzOpenDialog[dStr]=dialog
	else
		if self.ltzdzOpenDialog then
			self.ltzdzOpenDialog[dStr]=nil
		end
	end

end
function ltzdzVoApi:clearOpenDialog()
	if self.ltzdzOpenDialog then
		for k,v in pairs(self.ltzdzOpenDialog) do
			if v and v.close then
				v:close()
			end
		end
	end
end

--计策冷却时间
function ltzdzVoApi:isStratagemCooling()
    local myinfo=ltzdzFightApi:getUserInfo()
    local coolingTime=ltzdzVoApi:getWarCfg().tacTimeLimit
    local et=myinfo.tmoney[1] or 0
    if et<base.serverTime then
    	return false,0
    end
    local lefttime=et-base.serverTime
    if lefttime>=coolingTime then
        return true,lefttime
    end
    return false,lefttime
end

--是否需要消除计策商店冷却时间
function ltzdzVoApi:isClearCooling()
    local myinfo=ltzdzFightApi:getUserInfo()
    local et=myinfo.tmoney[1] or 0
    if et<=base.serverTime then
    	return false
    end
    return true
end

function ltzdzVoApi:getResetCoolingTimeCost()
    local myinfo=ltzdzFightApi:getUserInfo()
    local num=math.ceil((myinfo.tmoney[1]-base.serverTime)/1800)
    local warCfg=self:getWarCfg()
    local cost=warCfg.resetCost or 0
    return num*cost
end

function ltzdzVoApi:resetRankExpireTime()
	self.rankExpireTime={0,0,0,0}
end

function ltzdzVoApi:formatRankList(rtype,callback)
	local function ranklistCallBack(sData)
		if sData and sData.ranklist then
			self.rankList[rtype]=sData.ranklist
			self.rankExpireTime[rtype]=self.rankExpireTime[rtype]+300
		end
		if callback then
			callback()
		end 
	end
	local httphost=ltzdzVoApi:getHttphostUrl()
	if httphost then
		if base.serverTime>self.rankExpireTime[rtype] then
			local httpUrl=httphost.."ranklist"
			local season=ltzdzVoApi.clancrossinfo.season
			local reqStr="season="..season.."&type="..rtype
			-- deviceHelper:luaPrint(httpUrl)
			-- deviceHelper:luaPrint(reqStr)
			local retStr=G_sendHttpRequestPost(httpUrl,reqStr)
			-- deviceHelper:luaPrint(retStr)
			if(retStr~="")then
				local retData=G_Json.decode(retStr)
				if (retData["ret"]==0 or retData["ret"]=="0") and retData.data then
					ranklistCallBack(retData)
				end
			end
		else
			if callback then
				callback()
			end
		end
	end
end

function ltzdzVoApi:getRankListByType(rtype)
	return self.rankList[rtype]
end

function ltzdzVoApi:getResPicByType(resType)
	local resPicCfg={"IconGold.png","ltzdzOilIcon.png","ltzdzMetalIcon.png","ltzdzReserveIcon.png"}
	return resPicCfg[tonumber(resType)]
end

-- 是否是定级赛
function ltzdzVoApi:isQualifying()
	local bnum=self.clancrossinfo.bnum or 0
	if bnum==0 then
		return true
	else
		return false
	end
end

function ltzdzVoApi:getStratagemInfoById(sid)
	local nameStr,descStr="",""
	local tactics=self:getWarCfg().tactics
	local cfg=tactics[sid]
	if cfg then
		local valueStr
		if sid=="t2" then --行军加速
			valueStr=cfg.effc*100
		elseif sid=="t1" or sid=="t3" or sid=="t4" then
			valueStr=cfg.effc	
		end
		nameStr=getlocal("slz_tac_name_"..sid)
		descStr=getlocal("slz_tac_des_"..sid,{valueStr})
	end
	return nameStr,descStr,"slz_tac_icon_"..sid..".png"
end

function ltzdzVoApi:getNeedPointByTotalSeg(totalSeg)
	if totalSeg==0 then
		return 0
	end
	local warCfg=self:getWarCfg()
	if warCfg.rankTitle and warCfg.rankTitle[totalSeg] then
		return warCfg.rankTitle[totalSeg]
	end
	return 0
end

function ltzdzVoApi:getSeasonEt()
	local warCfg=self:getWarCfg()
	local lastTime=warCfg.rankLast*24*3600
	local seasonEt=self.seasonst+self.clancrossinfo.season*lastTime
	-- print("seasonst,seasonEt-------->",self.seasonst,seasonEt)
	return (seasonEt-base.serverTime),seasonEt
end

function ltzdzVoApi:getWarTime()
	local warCfg=self:getWarCfg()
	local openTimeCfg=self.openTime
	local lastTime=warCfg.standTime+warCfg.warTime
	local notEnter=warCfg.standTime-warCfg.notEnter
	local weets=G_getWeeTs(base.serverTime) --当天零点时间戳
	local timeCfg={}
	for k,v in pairs(openTimeCfg) do
		local st=weets+v[1]*3600+v[2]*60
		local et=st+lastTime
		local nt=st+notEnter
		timeCfg[k]={st,et,nt}
	end
	return lastTime,warCfg.standTime,warCfg.warTime,timeCfg
end

-- 改版新加 (当前段位所有的Tank)
function ltzdzVoApi:getCanActiveTankBySeg(seg)
	local warCfg=self:getWarCfg()
	local troopLimit=warCfg.troopLimit
	local tankTb={}
	if seg==nil then
		seg=ltzdzVoApi:getSegment()
	end

	local limitLv=troopLimit[seg][2] or 0
	for k,v in pairs(tankCfg) do
		if v.tankLevel<=limitLv then
			local key=tonumber(k) or tonumber(RemoveFirstChar(k))
			table.insert(tankTb,{key=key,sortId=tonumber(v.sortId)})
		end
	end
	
	local function sortFunc(a,b)
		local fight1=a.sortId or 0
		local fight2=b.sortId or 0
		return fight1>fight2
	end
	table.sort(tankTb,sortFunc)
	return tankTb
end

-- (当前段位新增的Tank)
function ltzdzVoApi:getAddCanActiveTankBySeg(seg)
	if seg==nil then
		seg=ltzdzVoApi:getSegment()
	end

	local showTankTb={}

	local warCfg=self:getWarCfg()
	local troopLimit=warCfg.troopLimit

	local limitLv=troopLimit[seg][2] or 0
	local lastLv=0
	if seg~=1 then
		lastLv=troopLimit[seg-1][2] or 0
	end
	if lastLv==limitLv then
		return showTankTb
	end

	for k,v in pairs(tankCfg) do
		if v.tankLevel<=limitLv and v.tankLevel>lastLv then
			local key=tonumber(k) or tonumber(RemoveFirstChar(k))
			table.insert(showTankTb,{key=key,sortId=tonumber(v.sortId)})
		end
	end

	
	local function sortFunc(a,b)
		local fight1=a.sortId or 0
		local fight2=b.sortId or 0
		return fight1>fight2
	end
	table.sort(showTankTb,sortFunc)
	
	return showTankTb
end

-- function ltzdzVoApi:tick()
-- 	if ltzdzFightApi and ltzdzFightApi.getMapVo then
-- 		local mapVo=ltzdzFightApi:getMapVo()
-- 		mapVo.ts=mapVo.ts+1
-- 	end
-- end

function ltzdzVoApi:showCheckTankActiveDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzCheckTankActiveDialog"
	ltzdzCheckTankActiveDialog:showTankActiveDialog(layerNum)
end

--显示赛季任务奖励面板
function ltzdzVoApi:showSeasonTaskRewardDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzSeasonTaskRewardDialog"
	ltzdzSeasonTaskRewardDialog:showSeasonTaskRewardDialog(layerNum)
end

--是否是本赛季
-- function ltzdzVoApi:isThisSeason()
-- 	local cfg=self:getWarCfg()
-- 	local st=base.ltzdzTb.st --赛季开始时间
-- 	local et=G_getWeeTs(st+(cfg.rankLast+1)*86400)+cfg.seasonTime[1]*3600 --赛季结束时间
-- 	if base.serverTime>et then
-- 		return false
-- 	end
-- 	return true
-- end

--获取赛季任务数据
function ltzdzVoApi:getSeasonTaskState(tid)
	local cfg=self:getWarCfg()
	local cur,max,state=0,cfg.seasonTask[tid].num,0
	if self.clancrossinfo.sinfo then
		local stask,sr=(self.clancrossinfo.sinfo.stask or {}),(self.clancrossinfo.sinfo.r or {})
		cur=(stask[tid] or 0)
		for k,v in pairs(sr) do
			if tostring(v)==tid then
				state=2 --已领取
				do break end
			end
		end
		if state~=2 and cur>=max then
			state=1 --可以领取
		end
	end
	return cur,max,state
end

--清除赛季任务数据
function ltzdzVoApi:clearSeasonTaskState()
	if self.clancrossinfo and self.clancrossinfo.sinfo then
		self.clancrossinfo.sinfo.stask={}
		self.clancrossinfo.sinfo.r={}
	end
end

--领取赛季任务奖励
function ltzdzVoApi:getSeasonTaskReward(tid,callback)
	local function getRewardHandler(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data then
				self:updateCrossInit(sData.data)
				local cfg=self:getWarCfg()
				if cfg.seasonTask and cfg.seasonTask[tid] then
					local rewardlist=FormatItem(cfg.seasonTask[tid].reward,nil,true)
					for k,v in pairs(rewardlist) do
			       		G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
					end
				end
				eventDispatcher:dispatchEvent("ltzdz.seasonTaskRefresh",{})
			end
			if callback then
				callback()
			end
		end
	end
	socketHelper:getSeasonTaskReward(tid,getRewardHandler)
end

-- true 今天打过了，不能再打了
-- false 今天没打过
function ltzdzVoApi:todayBattleIsOver()
	local state=ltzdzVoApi:getWarState()
	if state~=1 then -- 正在参战
		return false
	end
	local et=self.clancrossinfo.et or 0
	return G_isToday(et)
end

--是否需要延迟结算
function ltzdzVoApi:isDelaySettlement()
	local state=self.clancrossinfo.state or 0
	if state and state==1 then
		local et=self.clancrossinfo.st+self:getWarCfg().warTime
		if base.serverTime>=et and base.serverTime<=(et+300) then
			return true,et+300-base.serverTime
		end
	end
	return false
end

-- 结算倒计时面板
function ltzdzVoApi:showCountDownSettleDialog(layerNum,istouch,isuseami,callBack,titleStr)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzConutDownSettleSmallDialog"
	ltzdzConutDownSettleSmallDialog:showCountDown(layerNum,istouch,isuseami,callBack,titleStr)
end

--结束势力战相关教学引导
function ltzdzVoApi:ltzdzGuildeFinished()
	for stepId=41,71 do
		otherGuideMgr:setGuideStepDone(stepId)
	end
	if otherGuideMgr.isGuiding then
		otherGuideMgr:endNewGuid()
	end
end

--是否在开战最后一天
function ltzdzVoApi:isAtEndDay()
	local week = G_getFormatWeekDay(base.serverTime)
	if week == 7 then
		week = 0
	end
	local openDay = self:getWarCfg().openDay
	if week == openDay[2] then
		return true
	end
	return false
end

--是否在开战最后一天最后一场参战
-- return 2 已过报名期，1 在报名期内
function ltzdzVoApi:isJoinFinalBattleAtToday()
	local state = self:getWarState()
	if state ~= 1 then
		return true
	end
	local cwCfg=self:getWarCfg()
	local weets = G_getWeeTs(base.serverTime) -- 当天零点时间戳
	local daySt = cwCfg.openTime[3][1] * 3600 + cwCfg.openTime[3][2] * 60
    local signSt = weets + daySt
    local signEt = signSt + cwCfg.standTime - cwCfg.notEnter
	if base.serverTime >= signEt then
		return false, 2
	end
	return false, 1
end