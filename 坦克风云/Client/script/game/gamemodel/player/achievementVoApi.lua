achievementVoApi={
	personAvts=nil,--个人成就
	serverAvts=nil, --全服成就
}

function achievementVoApi:getAchievementCfg()
	local cfg=G_requireLua("config/gameconfig/achievement")
  	return cfg
end

--成就系统是否开启：1：开启，0：开关未开，2：等级不够
function achievementVoApi:isOpen(level)
	if base.avt==0 then
		return 0
	end
	local cfg=self:getAchievementCfg()
	local playerLv=level or playerVoApi:getPlayerLevel()
	if playerLv<cfg.openLevel then
		return 2,cfg.openLevel
	end
	return 1
end

--获取成就总等级
function achievementVoApi:getAchievementLv()
	local avtData=self:getPersonAvtData()
	return avtData.level
end

--获取个人指定成就线的配置
function achievementVoApi:getPersonAvtCfgById(avtId)
	local cfg=self:getAchievementCfg()
	return cfg.person[avtId]
end

--获取全服成就线的配置
function achievementVoApi:getServerAvtCfgById(avtId)
	local cfg=self:getAchievementCfg()
	return cfg.all[avtId]
end

function achievementVoApi:getPersonAvtData()
	if self.personAvts==nil then
		self.personAvts={
			level=0, --成就等级
			uinfo={}, --玩家成就数据信息{a0=0,a1=10}(a0表示是否初始化，1有，0或为空则没有)
			reward={p={},a={}}, --玩家领奖信息{p={a1={1522120087,0,0}},a={a1={{1522120087,1522120087,1522120087},{1522120087,0,0},{1522120087,1522120087,0}}}}(p个人领奖,a全服领奖)
			info={rank={},cup={}}, --其他信息{rank={a1={1,1},a2={2,1}},cup={t={armor={1,"a1"},weapon={2,"a6"},sequip={1,"a3"}},a={a1={2,3},a2={1,1}}}}(排行信息(id:{排名,服id}),显示奖杯信息(a={id={index}},t={模块={1个人或2全服,id}})
		}
	end
	return self.personAvts
end

--全服成就数据
function achievementVoApi:getServerAvtData()
	self.serverAvts=self.serverAvts or {}
	return self.serverAvts
end

--更新成就相关数据
function achievementVoApi:updateData(data)
	if self.personAvts==nil then
		self.personAvts=self:getPersonAvtData()
	end
	local avt=data.achievement --成就个人信息
	if avt.level then
		self.personAvts.level=tonumber(avt.level) or 0
	end
	if avt.uinfo then
		self.personAvts.uinfo=avt.uinfo
	end
	if avt.reward then
		if avt.reward.p then
			self.personAvts.reward.p=avt.reward.p
		end
		if avt.reward.a then
			self.personAvts.reward.a=avt.reward.a
		end
	end
	if avt.info then --成就全服排名相关数据
		if avt.info.rank then
			self.personAvts.info.rank=avt.info.rank
		end
		if avt.info.cup then
			self.personAvts.info.cup=avt.info.cup
		end
	end
	 --成就全服信息，格式：{a1={0,0,0},a2={0,0,0}}
	if data.achievementAll then
		self.serverAvts=data.achievementAll
	end

	eventDispatcher:dispatchEvent("main.avt.refresh",{})
end

function achievementVoApi:getAvtsData(callback,waitingFlag)
	if self:isOpen()~=1 then
		if callback then
			callback()
		end
		do return end
	end
	local function requestCallBack(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data then
				self:updateData(sData.data)
			end
			if callback then
				callback()
			end
		end
	end
	socketHelper:getAchievement(requestCallBack,waitingFlag)
end

--获取成就模块的当前奖杯显示
--params：shareAvts分享的玩家成就信息
function achievementVoApi:getAvtModuleShowIcon(moduleId,callback,share)
	local avtBg
    local unlockFlag,openLv=self:getAvtModuleUnlockFlag(moduleId,share)
	local personAvts={}
	if share then
		personAvts=share.personAvts
	else
		personAvts=self:getPersonAvtData()
	end
	if personAvts.info and personAvts.info.cup and personAvts.info.cup.t and personAvts.info.cup.t[moduleId] and unlockFlag==1 then
		local v=personAvts.info.cup.t[moduleId]
		local atype,avtId=v[1],v[2]
		if atype and avtId then
			if atype==1 then --个人成就显示
				local idx=self:getBestAvtById(avtId,personAvts)
				avtBg=self:getAvtIcon(atype,avtId,idx,nil,callback,nil,nil,share)
			else
				if personAvts.info.cup.a and personAvts.info.cup.a[avtId] then
					local acup=personAvts.info.cup.a[avtId]
					avtBg=self:getAvtIcon(atype,avtId,acup[1],acup[2],callback,nil,nil,share)
				end
			end
			local gtime=achievementVoApi:getActivateTimeByAvtId(atype,avtId,personAvts) --获得奖杯的时间	
			if avtBg and gtime>0 then
				local gtimeLb=GetTTFLabelWrap(getlocal("activity_xinfulaba_PlayerName",{G_getDataTimeStr(gtime,true,true)}),18,CCSizeMake(avtBg:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)	 
	        	gtimeLb:setPosition(avtBg:getContentSize().width/2,25)
	        	gtimeLb:setColor(G_ColorGray2)
	        	avtBg:addChild(gtimeLb)
			end
		end
	end
	if avtBg==nil then --没有设置过奖杯显示，则显示默认的空的奖杯
		if unlockFlag~=1 then
			avtBg=achievementVoApi:getAvtIcon(nil,nil,nil,nil,callback,true)
		else
			avtBg=achievementVoApi:getAvtIcon(nil,nil,nil,nil,callback)
		end
	end
	return avtBg
end

--获取成就信息显示的icon
--params：atype:1个人，2：全服；avtId：成就线的id；idx:成就id；subIdx:全服指定成就的子成就，个人成就无需传此参数；state成就完成状态
function achievementVoApi:getAvtShowIcon(atype,avtId,idx,subIdx,callback,state)
	local avtBg
	if atype==1 then
		local showIdx=(idx and idx>0) and idx or self:getBestAvtById(avtId)
		avtBg=self:getAvtIcon(1,avtId,showIdx,nil,callback,nil,state)
	else
		if idx and idx>0 and subIdx and subIdx>0 then --显示指定成就奖杯
			avtBg=self:getAvtIcon(2,avtId,idx,subIdx,callback,nil,state)
		else --显示指定成就线的奖杯
			local personAvts=self:getPersonAvtData()
			if personAvts.info.cup.a and personAvts.info.cup.a[avtId] then
				local acup=personAvts.info.cup.a[avtId]
				avtBg=self:getAvtIcon(2,avtId,acup[1],acup[2],callback)
			end
		end
	end
	if avtBg==nil then --没有设置过奖杯显示，则显示默认的空的奖杯
		avtBg=achievementVoApi:getAvtIcon(atype,avtId,nil,nil,callback)
	end
	return avtBg
end

--获取成就信息显示的icon
--params：atype:1个人，2：全服；avtId：成就线的id；idx:成就id；subIdx:全服指定成就的子成就，个人成就无需传此参数
function achievementVoApi:getAvtIcon(atype,avtId,idx,subIdx,callback,isNull,state,share)
	local function touch()
	  	if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if callback then
        	callback()
        end
	end
	local avtBg=LuaCCSprite:createWithSpriteFrameName("achievement_cup_bg.png",touch)
	local bgWidth,bgHeight=avtBg:getContentSize().width,avtBg:getContentSize().height
	local cupSp,cupPicStr,avtNameStr,nameColor
	if isNull==true then --不显示任何奖杯
	elseif atype and avtId==nil then --未开放的成就则显示一个空的背景图
       	local tipLb=GetTTFLabelWrap(getlocal("achievement_willOpen"),18,CCSizeMake(bgWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        tipLb:setPosition(bgWidth/2,bgHeight/2)
        tipLb:setColor(G_ColorGray2)
        avtBg:addChild(tipLb)
		do return avtBg end
	elseif (atype==1 and idx and idx>0) or (atype==2 and idx and idx>0 and subIdx and subIdx>0) then --显示指定奖杯
		-- avtcup1_a1_1
		cupPicStr="avtcup"..atype.."_"..avtId.."_"..idx..".png"
		avtNameStr,nameColor=self:getAvtNameStrAndColor(atype,avtId,idx,subIdx)
	else --显示空奖杯
		cupPicStr,avtNameStr,nameColor="avt_cupnull.png",getlocal("no_set_avtcup"),G_ColorGray2
	end
	if cupPicStr and cupPicStr~="" then
		if state and state~=2 then --成就未激活则置灰奖杯
			cupSp=GraySprite:createWithSpriteFrameName(cupPicStr)
		else
			cupSp=CCSprite:createWithSpriteFrameName(cupPicStr)
		end
		if cupSp then
			cupSp:setAnchorPoint(ccp(0.5,0))
			cupSp:setPosition(bgWidth/2,70)
			cupSp:setTag(101)
			avtBg:addChild(cupSp,1)
		end
	end
	if avtNameStr then
		local nameLb=GetTTFLabelWrap(avtNameStr,20,CCSizeMake(bgWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
		nameLb:setPosition(bgWidth/2,bgHeight-17)
		nameLb:setColor((nameColor or G_ColorWhite))
		avtBg:addChild(nameLb)
	end

	if atype==1 then --个人成就线最高品质成就排名在前三名时显示排名信息（服务器名称和排名）
		local cfg=self:getAchievementCfg()
		if cfg.person[avtId] then
			local bestIdx=SizeOfTable(cfg.person[avtId].needNum)
			if idx and bestIdx==idx then 
				local personAvts={}
				if share and share.personAvts then
					personAvts=share.personAvts
				else
					personAvts=self:getPersonAvtData()
				end
				if personAvts.info and personAvts.info.rank and personAvts.info.rank[avtId] then --全服排名显示
					local rank,zid=(personAvts.info.rank[avtId][1] or 0),personAvts.info.rank[avtId][2]
					if rank<=3 then --排名前三显示排名及排名所在服务器
						--排名所在服务器
						local serverBg=LuaCCScale9Sprite:createWithSpriteFrameName("avt_serverbg.png",CCRect(44,0,2,32),function () end)
    					serverBg:setContentSize(CCSizeMake(150,32))
    					serverBg:setAnchorPoint(ccp(0,0))
    					serverBg:setPosition(-7,40)
    					avtBg:addChild(serverBg,2)
    					local serverNameStr=GetServerNameByID(zid)
    					local serverNameLb=GetTTFLabelWrap(serverNameStr,18,CCSizeMake(serverBg:getContentSize().width-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    					serverNameLb:setAnchorPoint(ccp(0,0.5))
    					serverNameLb:setPosition(10,serverBg:getContentSize().height/2)
    					serverBg:addChild(serverNameLb)

    					--排名
    					local rankSp=CCSprite:createWithSpriteFrameName("avt_"..rank.."th.png")
    					if rankSp then
    						rankSp:setAnchorPoint(ccp(0.5,1))
    						rankSp:setPosition(avtBg:getContentSize().width-rankSp:getContentSize().width/2-5,avtBg:getContentSize().height-30)
    						avtBg:addChild(rankSp,2)
    					end
					end
				end
			end
		end
	end
	if atype==2 and cupSp then --全服子成就会显示星星
		if subIdx and subIdx>0 then
			local swidth,hspace=29,8
			local starBg=CCNode:create()
			starBg:setAnchorPoint(ccp(0.5,0.5))
			starBg:setContentSize(CCSizeMake(subIdx*swidth+(subIdx-1)*hspace,swidth))
			starBg:setPosition(cupSp:getContentSize().width/2,0)
			cupSp:addChild(starBg,2)
			for i=1,subIdx do
				local starSp
				if state and state~=2 then --成就未激活则置灰奖杯
					starSp=GraySprite:createWithSpriteFrameName("avt_star.png")
				else
					starSp=CCSprite:createWithSpriteFrameName("avt_star.png")
				end
				starSp:setPosition((2*i-1)/2*swidth+(i-1)*hspace,starBg:getContentSize().height/2)
				starBg:addChild(starSp)
			end
		end
	end

	return avtBg
end

--个人成就icon（月度充值页面显示用）
function achievementVoApi:getAvtSimpleIcon(avtId,idx,subIdx,callback,state)
	local avtBg
	local function touch()
	  	if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if callback then
        	callback()
        end
	end
	avtBg=LuaCCSprite:createWithSpriteFrameName("ydczCupBg.png",touch)
	local bgWidth,bgHeight=avtBg:getContentSize().width,avtBg:getContentSize().height
	local cupSp,cupPicStr
	if avtId==nil or idx==nil then
		cupPicStr="ydczUnlockCup.png"
	elseif (avtId and idx and idx>0) then --显示指定奖杯
		cupPicStr="avtcup1".."_"..avtId.."_"..idx..".png"
	end
	if cupPicStr and cupPicStr~="" then
		if state and state~=2 then --成就未激活则置灰奖杯
			cupSp=GraySprite:createWithSpriteFrameName(cupPicStr)
		else
			cupSp=CCSprite:createWithSpriteFrameName(cupPicStr)
		end
		if cupSp then
			cupSp:setAnchorPoint(ccp(0.5,0))
			cupSp:setPosition(bgWidth/2,26)
			cupSp:setTag(101)
			avtBg:addChild(cupSp,1)
		end
		local cuplightSp=CCSprite:createWithSpriteFrameName("ydcz_cuplight.png")
		cuplightSp:setPosition(bgWidth/2,36)
		cuplightSp:setTag(102)
		avtBg:addChild(cuplightSp)
	end

	return avtBg
end

--params：atype：1个人，2全服；avtId：成就线的id；index：指定成就线的成就id；subIdx：全服成就的子成就id
--return 0:未获得, 1:可激活, 2:已获得
function achievementVoApi:getAvtState(atype,avtId,index,subIdx)
	--先判断是否已领取
	local personAvts=self:getPersonAvtData()	
	if atype==1 then --个人成就
		local avtcfg=self:getPersonAvtCfgById(avtId)
		if personAvts.reward and personAvts.reward.p and personAvts.reward.p[avtId] then
			local rt=tonumber(personAvts.reward.p[avtId][index] or 0)
			if rt>0 then --该成就有领奖时间说明已经领取过
				return 2
			end
		end
		local ownNum=personAvts.uinfo[avtId] or 0
		local needNum=avtcfg.needNum[index]
		if ownNum>=needNum then
			return 1
		end
	elseif atype==2 then --全服成就
		local avtcfg=self:getServerAvtCfgById(avtId)
		if personAvts.reward and personAvts.reward.a and personAvts.reward.a[avtId] and personAvts.reward.a[avtId][index] then
			local rt=tonumber(personAvts.reward.a[avtId][index][subIdx] or 0)
			if rt>0 then --该成就有领奖时间说明已经领取过
				return 2
			end
		end
		local serverAvts=self:getServerAvtData()
		local ownNum=0
		if serverAvts and serverAvts[avtId] and serverAvts[avtId][index] then
			ownNum=serverAvts[avtId][index]
		end
		local needNum=0
		if avtcfg.num[index] and avtcfg.num[index][subIdx] then
			needNum=tonumber(avtcfg.num[index][subIdx])
		end
		if ownNum>=needNum then
			return 1
		end
	end
	return 0
end

--判断指定成就线是否有可以激活（可领奖）的成就
--params：atype:1个人，2全服；avtId：成就线id
--return true 有，false 无
function achievementVoApi:isActivateByAvtId(atype,avtId)
	if atype==1 then --个人
		local avtcfg=self:getPersonAvtCfgById(avtId)
		for k,v in pairs(avtcfg.needNum) do
			if self:getAvtState(atype,avtId,k)==1 then
				return true
			end
		end
	elseif atype==2 then --全服
		local avtcfg=self:getServerAvtCfgById(avtId)
		for k,v in pairs(avtcfg.num) do
			for subIdx,vv in pairs(v) do
				if self:getAvtState(atype,avtId,k,subIdx)==1 then
					return true
				end
			end
		end
	end
	return false
end

--获取个人指定成就线已完成的最高成就id
function achievementVoApi:getBestAvtById(avtId,shareAvts)
	local bestIdx,gt=0,0
	local personAvts=shareAvts or self:getPersonAvtData()
	if personAvts.reward and personAvts.reward.p and personAvts.reward.p[avtId] then
		for k,v in pairs(personAvts.reward.p[avtId]) do
			if tonumber(v)>0 then
				bestIdx,gt=k,v
			else
				do break end
			end
		end
	end
	return bestIdx,gt
end

--获取成就奖杯激活时间
function achievementVoApi:getActivateTimeByAvtId(atype,avtId,shareAvts)
	local gtime=0
	if atype==1 then
		local bestIdx,gt=self:getBestAvtById(avtId,shareAvts)
		gtime=gt
	else
		local personAvts=shareAvts or self:getPersonAvtData()
		if personAvts.info and personAvts.info.cup and personAvts.info.cup.a then
			local v=personAvts.info.cup.a[avtId]
			if personAvts.reward and personAvts.reward.a and personAvts.reward.a[avtId] and v and v[1] and v[2] and personAvts.reward.a[avtId][v[1]] then
				gtime=tonumber(personAvts.reward.a[avtId][v[1]][v[2]] or 0)
			end
		end
	end
	return gtime
end

--获取指定成就奖杯的激活时间
function achievementVoApi:getActivateTimeById(atype,avtId,idx,subIdx)
	local gtime=0
	local personAvts=self:getPersonAvtData()
	if atype==1 then
		if personAvts.reward and personAvts.reward.p and personAvts.reward.p[avtId] then
			gtime=tonumber(personAvts.reward.p[avtId][idx]) or 0
		end
	else
		if personAvts.reward and personAvts.reward.a and personAvts.reward.a[avtId] and personAvts.reward.a[avtId][idx] then
			gtime=tonumber(personAvts.reward.a[avtId][idx][subIdx]) or 0
		end
	end
	return gtime
end

function achievementVoApi:socketAchievementReward(_atype,_aid,callback)
	local function socketCallback(fn,data)
		local ret,sData=base:checkServerData(data)
        if ret==true then
        	if sData.data then
				self:updateData(sData.data)
			end
        	if callback then
        		callback()
        	end
        	local personAvts=self:getPersonAvtData()
        	if _atype==1 and personAvts.info and personAvts.info.rank and personAvts.info.rank[_aid] then
        		local rank=tonumber(personAvts.info.rank[_aid][1])
        		if rank>0 and rank<=3 then --如果该成就线最高品质的成就激活排在全服的前三名的话发送系统滚屏公告
        			local avtcfg=self:getAchievementCfg()
        			if avtcfg.person[_aid] then
        				local bestIdx=SizeOfTable(avtcfg.person[_aid].needNum)
						local params={key="achievement_rank_tip",param={{playerVoApi:getPlayerName(),1},{"avt",_atype,_aid,bestIdx},{rank,3}},loopc=3}
	  					chatVoApi:sendUpdateMessage(41,params)
                        -- jumpScrollMgr:addScrollMessage(params)
                        --发送聊天公告
                		local avtNameStr,color=self:getAvtNameStrAndColor(_atype,_aid,bestIdx)
                        local msg={key="achievement_rank_tip",param={playerVoApi:getPlayerName(),avtNameStr,rank}}
						chatVoApi:sendSystemMessage(msg)
        			end
        		end
        	end
        	if _atype==1 then --如果领取了个人成就奖励的话就同步一下全服的成就进度
        		local serverAvts=self:getServerAvtData()
				local params={uid=playerVoApi:getUid(),serverAvts={[_aid]=serverAvts[_aid]}}
				chatVoApi:sendUpdateMessage(56,params)
        	end
        	eventDispatcher:dispatchEvent("player.sys.tipRefresh",{}) --通知刷新主页面的红点提示
        	eventDispatcher:dispatchEvent("player.dialogtab1.refresh",{}) --通知刷新玩家页面数据
        end
	end
	socketHelper:achievementReward(_atype,_aid,socketCallback)
end

--选择奖杯显示
function achievementVoApi:socketAchievementCup(action,aid,stype,index,callback)
	local function socketCallback(fn,data)
		local ret,sData=base:checkServerData(data)
        if ret==true then
        	if sData.data then
				self:updateData(sData.data)
			end
        	if callback then
        		callback()
        	end
        end
	end
	socketHelper:achievementCup(action,aid,stype,index,socketCallback)
end

--获取当前选择的奖杯
function achievementVoApi:getSelectCup(moduleId,atype,avtId)
	local avtcup,index
	local personAvts=self:getPersonAvtData()
	if moduleId and atype==nil and avtId==nil then
		if personAvts and personAvts.info and personAvts.info.cup and personAvts.info.cup.t and personAvts.info.cup.t[moduleId] then
			avtcup=personAvts.info.cup.t[moduleId]
		end
	elseif atype and avtId then
		if atype==2 then
			if personAvts.info and personAvts.info.cup and personAvts.info.cup.a and personAvts.info.cup.a[avtId] then
				index=personAvts.info.cup.a[avtId]
			end
		end
	end
	return avtcup,index
end

--判断某成就或者某成就线是否可以选择奖杯显示
function achievementVoApi:isCupCanSelect(atype,avtId,idx,subIdx)
	if atype==1 then
		local bestIdx=self:getBestAvtById(avtId)
		if bestIdx>0 then
			return true
		end
	elseif atype==2 then
		local personAvts=self:getPersonAvtData()
		if avtId and idx==nil and subIdx==nil then --选择全服指定成就线奖杯处理
			if personAvts.info and personAvts.info.cup and personAvts.info.cup.a and personAvts.info.cup.a[avtId] then
				if SizeOfTable(personAvts.info.cup.a[avtId])>0 then --如果选择了全服子成就的奖杯的话，才可以选择显示该成就线的奖杯
					return true
				end
			end
		elseif avtId and idx and subIdx then --选择全服指定成就奖杯处理
			if personAvts.reward and personAvts.reward.a and personAvts.reward.a[avtId] then
				local reward=personAvts.reward.a[avtId]
				if reward[idx] and reward[idx][subIdx] and tonumber(reward[idx][subIdx])>0 then --如果全服子成就已经激活，则可以设置该成就奖杯显示
					return true
				end
			end
		end
	end
	return false
end

--获取主界面效果解锁的成就等级
function achievementVoApi:getNextEffectUnlockLv()
	local cfg=self:getAchievementCfg()
	local lv=self:getAchievementLv()
	for k,v in pairs(cfg.stage) do
		if lv<v then
			return v
		end
	end
	return nil
end

--成就等级限制
function achievementVoApi:getAvtModuleUnlockLv(moduleId)
	local cfg=self:getAchievementCfg()
	return cfg.unlock[moduleId] or 0
end

--获取各个成就模块解锁标识：return 1：已解锁，0：未开启，2：等级不够，3：成就等级不够
function achievementVoApi:getAvtModuleUnlockFlag(moduleId,share)
	local flag=1
	local playerLv,openLv=0,nil
	if share then
		playerLv=share.level
	else
		playerLv=playerVoApi:getPlayerLevel()
	end
	if moduleId=="armor" then --装甲矩阵
		local openFlag=armorMatrixVoApi:isOpenArmorMatrix()
		if openFlag==false then
			flag=0
		else
			openLv=armorMatrixVoApi:getPermitLevel()
		end
	elseif moduleId=="sequip" then --军徽
		if base.emblemSwitch==0 then
			flag=0
		else
			openLv=emblemVoApi:getPermitLevel()
		end
	elseif moduleId=="weapon" then --超级武器
		if base.ifSuperWeaponOpen==0 then
			flag=0
		else
			openLv=base.superWeaponOpenLv
		end
	end
	if openLv and tonumber(openLv)>playerLv then
		flag=2
	end
	local avtLv=0
	if share and share.personAvts then
		avtLv=share.personAvts.level or 0
	else
		avtLv=self:getAchievementLv()
	end
	local unlockLv=self:getAvtModuleUnlockLv(moduleId)
	if avtLv<unlockLv then
		flag=3
		openLv=unlockLv
	end
	return flag,openLv
end

--获得奖杯的名字
function achievementVoApi:getAvtNameStrAndColor(atype,avtId,idx,subIdx)
	local nameStr,color="",nil
	local colorcfg={G_ColorWhite,G_ColorGreen,G_ColorBlue}
	if atype==1 then
		nameStr=getlocal("achievement_cup_name_"..atype.."_"..avtId)
		if idx then
			color=colorcfg[idx]
		end
	elseif atype==2 then
		nameStr=getlocal("achievement_cup_name_"..atype.."_"..avtId.."_"..idx)
		if subIdx then
			color=colorcfg[subIdx]
		end
	end
	return nameStr,(color or G_ColorWhite)
end

--是否有成就奖励可以领取
function achievementVoApi:hasReward()
	if self:isOpen()~=1 then
		do return false end
	end
	local cfg=self:getAchievementCfg()
	local flag=0
	local unlockTb={}
	for avtId,avtcfg in pairs(cfg.person) do
		if unlockTb[avtcfg.type]==nil then
			unlockTb[avtcfg.type]=achievementVoApi:getAvtModuleUnlockFlag(avtcfg.type)
		end
		if unlockTb[avtcfg.type]==1 then --该模块成就已解锁
			for idx,num in pairs(avtcfg.needNum) do
				flag=achievementVoApi:getAvtState(1,avtId,idx)
				if flag==1 then
					do return true end
				end
			end
		end
	end
	for avtId,avtcfg in pairs(cfg.all) do
		if unlockTb[avtcfg.type]==nil then
			unlockTb[avtcfg.type]=achievementVoApi:getAvtModuleUnlockFlag(avtcfg.type)
		end
		if unlockTb[avtcfg.type]==1 then --该模块成就已解锁
			for idx,subcfg in pairs(avtcfg.num) do
				for subIdx,num in pairs(subcfg) do
					flag=achievementVoApi:getAvtState(2,avtId,idx,subIdx)
					if flag==1 then
						do return true end
					end
				end
			end
		end
	end
	return false
end

--显示成就总览面板
function achievementVoApi:showAchievementDialog(layerNum)
	local flag,openLv=self:isOpen()
	if flag==0 then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("achievement_noopen"),28)
		do return end
	end
	require "luascript/script/game/scene/gamedialog/playerDialog/playerAchievementDialog"
	local dialog=playerAchievementDialog:new()
	local layer=dialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("google_achievement"),true,layerNum)
    sceneGame:addChild(layer,layerNum)
end

--显示某条成就线的成就详情
function achievementVoApi:showAvtDetailDialog(atype,avtId,layerNum,parent,jumpId)
  	require "luascript/script/game/scene/gamedialog/playerDialog/achievementInfoDialog"
    local dialog=achievementInfoDialog:new(atype,avtId,parent,jumpId)
    local layer=dialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("google_achievement"),true,layerNum)
    sceneGame:addChild(layer,layerNum)
end

--显示成就分享面板
function achievementVoApi:showAchievementShareDialog(share,layerNum)
	local flag,openLv=self:isOpen()
	if flag==0 then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("achievement_noopen"),28)
		do return end
	end
	require "luascript/script/game/scene/gamedialog/playerDialog/achievementShareSmallDialog"
	local dialog=achievementShareSmallDialog:new()
	dialog:initLayer(share,layerNum)
end

--有成就完成
--params：data：成就数据（个人成就的完成数据是后台推送的，全服的话就是玩家激活奖励时发送聊天通知全服玩家）
function achievementVoApi:onAvtFinished(data)
	local atype,avtId
	local changeFlag=false
	if data.achievement and data.achievement.uinfo then --个人完成的成就数据
		atype=1
		local personAvts=self:getPersonAvtData()
		if personAvts.uinfo==nil then
			personAvts.uinfo={}
		end
		for k,v in pairs(data.achievement.uinfo) do
			local num=personAvts.uinfo[k] or 0
			if tonumber(v)>num then
				personAvts.uinfo[k]=tonumber(v) --同步进度
				changeFlag=true
				avtId=k
			end
		end
	elseif data.serverAvts then --全服成就数据
		atype=2
		local serverAvts=self:getServerAvtData()
		for k,v in pairs(data.serverAvts) do
			if serverAvts[k] then
				for sk,sv in pairs(v) do
					local num=serverAvts[k][sk] or 0
					if tonumber(sv)>num then
						serverAvts[k][sk]=tonumber(sv) --同步进度
						changeFlag=true
						avtId=k
					end
				end
			end
		end
	end
	if changeFlag==true then --发送消息同步游戏主界面玩家头像的红点提示
		eventDispatcher:dispatchEvent("player.sys.tipRefresh",{})
		eventDispatcher:dispatchEvent("main.avt.refresh",{})
		eventDispatcher:dispatchEvent("player.dialogtab1.refresh",{})
	end
	if atype==nil or avtId==nil or (atype and atype==2) then
		do return end
	end
	local cfg=self:getAchievementCfg()
	if cfg.person[avtId]==nil then
		do return end
	end
	local moduleId=cfg.person[avtId].type
	local unlockFlag=achievementVoApi:getAvtModuleUnlockFlag(moduleId)
	if unlockFlag~=1 then --成就模块未解锁的话不显示提示弹板
		do return end
	end
	--个人成就完成弹出提示面板
	local flag=achievementVoApi:isActivateByAvtId(atype,avtId)
	if flag==false then --该条成就线有成就完成
		do return end
	end
	local popKey,layerNum="avtchange",25
	--跳转成就页面
	local function goAvtLayer()
        activityAndNoteDialog:closeAllDialog()
        G_closeAllSmallDialog()
        self:showAvtDetailDialog(atype,avtId,layerNum)
	end
	--保存页面弹出时间
	local function secondTipFunc(sbFlag)
        local sValue=base.serverTime .. "_" .. sbFlag
        G_changePopFlag(popKey,sValue)
    end
    if G_isPopBoard(popKey) then
		G_showSecondConfirm(layerNum,true,true,getlocal("dialog_title_prompt"),getlocal("achievement_finished_tip"),true,goAvtLayer,secondTipFunc)
	end
end

--首次解锁功能处理
function achievementVoApi:onPlayerLvChanged(lastLv)
    if self:isOpen(lastLv)~=1 and self:isOpen()==1 then
        local function callback()
        	eventDispatcher:dispatchEvent("player.sys.tipRefresh",{})
        end
        self:getAvtsData(callback,false)
    end
end

function achievementVoApi:clear()
	self.personAvts=nil
	self.serverAvts=nil
end