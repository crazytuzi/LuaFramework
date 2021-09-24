acZnkhTabTwo={}

function acZnkhTabTwo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.cellHeight=68

    return nc
end

function acZnkhTabTwo:init(layerNum)
	self.layerNum=layerNum

	self.bgLayer=CCLayer:create()

	self:initUI()

	return self.bgLayer
end

function acZnkhTabTwo:initUI()
	local fontSize = 24
	local curValueLb=GetTTFLabel(getlocal("activity_znkh_curScore",{acZnkhVoApi:getLotteryScore()}),fontSize)
	curValueLb:setAnchorPoint(ccp(0,0.5))
	curValueLb:setPosition(50,self.bgLayer:getContentSize().height-180)
	curValueLb:setColor(G_ColorGreen)
	self.bgLayer:addChild(curValueLb)
	self.curScoreLb=curValueLb

	local tipLabel=GetTTFLabel(getlocal("activity_znkh_scoreLimit",{acZnkhVoApi:getRankLimit()}),fontSize)
	tipLabel:setAnchorPoint(ccp(0,0.5))
	tipLabel:setPosition(curValueLb:getPositionX(),curValueLb:getPositionY()-curValueLb:getContentSize().height/2-5-tipLabel:getContentSize().height/2)
	self.bgLayer:addChild(tipLabel)

	local function showInfo()
		if G_checkClickEnable()==false then
			do return end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		
		local tabStr = {
			getlocal("activity_znkh_tabTwoInfo1"),
			getlocal("activity_znkh_tabTwoInfo2"),
			getlocal("activity_znkh_tabTwoInfo3"),
			getlocal("activity_znkh_tabTwoInfo4"),
		}

		local descStrTb = acZnkhVoApi:getRankRewardDesc()
		if descStrTb then
			for k,v in pairs(descStrTb) do
				table.insert(tabStr,v)
			end
		end
		local titleStr=getlocal("activity_baseLeveling_ruleTitle")
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,25)
	end
	local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfo,11,nil,nil)
	infoItem:setScale(0.8)
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(G_VisibleSizeWidth - 50,G_VisibleSizeHeight - 210))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-5)
	self.bgLayer:addChild(infoBtn)

	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),function()end)
	tvBg:setContentSize(CCSize(self.bgLayer:getContentSize().width-40,self.bgLayer:getContentSize().height-330))
	tvBg:setAnchorPoint(ccp(0.5,1))
	tvBg:setPosition(self.bgLayer:getContentSize().width/2,tipLabel:getPositionY()-tipLabel:getContentSize().height)
	self.bgLayer:addChild(tvBg)

	local rankLb=GetTTFLabel(getlocal("rank"),fontSize)
	local nameLb=GetTTFLabel(getlocal("RankScene_name"),fontSize)
	local valueLb=GetTTFLabel(getlocal("serverwar_point"),fontSize)
	-- local awardLb=GetTTFLabel(getlocal("award"),fontSize)
	rankLb:setAnchorPoint(ccp(0.5,1))
	nameLb:setAnchorPoint(ccp(0.5,1))
	valueLb:setAnchorPoint(ccp(0.5,1))
	-- awardLb:setAnchorPoint(ccp(0.5,1))
	rankLb:setPosition(85,tvBg:getContentSize().height-5)
	nameLb:setPosition(280,tvBg:getContentSize().height-5)
	valueLb:setPosition(485,tvBg:getContentSize().height-5)
	-- awardLb:setPosition(525,tvBg:getContentSize().height-5)
	rankLb:setColor(G_ColorGreen)
	nameLb:setColor(G_ColorGreen)
	valueLb:setColor(G_ColorGreen)
	-- awardLb:setColor(G_ColorGreen)
	tvBg:addChild(rankLb)
	tvBg:addChild(nameLb)
	tvBg:addChild(valueLb)
	-- tvBg:addChild(awardLb)

	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvBg:getContentSize().width-10,tvBg:getContentSize().height-40),nil)
	-- self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(5,0))
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setMaxDisToBottomOrTop(100)
	tvBg:addChild(self.tv)

	local function awardHandler()
		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        if self.rankList then
	        local function socketCallback(fn,data)
	        	local ret,sData=base:checkServerData(data)
	            if ret==true then
	            	acZnkhVoApi:updateData(sData.data.znkh)
	            	if sData.data.reward then
		            	local rewardList=FormatItem(sData.data.reward)
	            		for k,v in pairs(rewardList) do
	                        G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),nil,true)
	                    end
	                    local function showEndHandler()
					        G_showRewardTip(rewardList,true)
					    end
						local titleStr=getlocal("activity_wheelFortune4_reward")
					    require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
					    rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,rewardList,showEndHandler,titleStr)
                	end
                	if acZnkhVoApi:isGetRankReward() then
	                	if self.awardBtn then
	                		self.awardBtn:setEnabled(false)
	                	end
	                	if self.awardBtnLb then
					    	self.awardBtnLb:setString(getlocal("activity_hadReward"))
					    end
					end
	            end
	        end
	        socketHelper:acZnkhRankReward(socketCallback,{self.rankList[1].rank})
    	end
    end
	local awardBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",awardHandler,11)
    awardBtn:setScale(0.8)
    awardBtn:setAnchorPoint(ccp(0.5,0.5))
    local awardMenu=CCMenu:createWithItem(awardBtn)
    awardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    awardMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,50))
    self.bgLayer:addChild(awardMenu)
    local awardBtnLb=GetTTFLabel(getlocal("newGiftsReward"),24,true)
    awardBtnLb:setPosition(awardMenu:getPositionX(),awardMenu:getPositionY())
    self.bgLayer:addChild(awardBtnLb)
    awardBtn:setEnabled(false)
    if acZnkhVoApi:isGetRankReward() then
    	awardBtnLb:setString(getlocal("activity_hadReward"))
    -- elseif acZnkhVoApi:isRewardTime() then
    -- 	awardBtn:setEnabled(true)
    end
    self.awardBtn=awardBtn
    self.awardBtnLb=awardBtnLb

    self:initRankList()
end

function acZnkhTabTwo:refreshCurScore()
	if self.curScoreLb and tolua.cast(self.curScoreLb,"CCLabelTTF") then
		self.curScoreLb:setString(getlocal("activity_znkh_curScore",{acZnkhVoApi:getLotteryScore()}))
	end
end

function acZnkhTabTwo:initRankList()
	socketHelper:acZnkhRankList(function(fn,data)
		local ret,sData=base:checkServerData(data)
        if ret==true then
        	self.rankList = sData.data.ranklist
        	table.sort(self.rankList, function(a,b)
        		if a[3] and b[3] and tonumber(a[3]) > tonumber(b[3]) then
        			return true
        		end
        	end)
        	local _isUnRnak=true
        	for k,v in pairs(self.rankList) do
        		if v[1]==playerVoApi:getUid() then
        			local tb = G_clone(v)
        			tb.rank=k
        			table.insert(self.rankList,1,tb)
        			_isUnRnak=false
        			break
        		end
        	end
        	if _isUnRnak then
        		local tb={ playerVoApi:getUid(),playerVoApi:getPlayerName(),acZnkhVoApi:getLotteryScore() }
        		tb.rank=-1
        		table.insert(self.rankList,1,tb)
        		if self.awardBtn then
        			self.awardBtn:setEnabled(false)
        		end
        	else
        		if acZnkhVoApi:isGetRankReward()==false and acZnkhVoApi:isRewardTime() then
        			if self.awardBtn then
	        			self.awardBtn:setEnabled(true)
	        		end
        		end
        	end
        	self.tv:reloadData()
        end
	end)
end

function acZnkhTabTwo:tick()
	if acZnkhVoApi:isRewardTime() and self.awardBtn and tolua.cast(self.awardBtn,"CCNode") then
		if acZnkhVoApi:isGetRankReward()==false and self.rankList and self.rankList[1].rank > 0 then
			self.awardBtn:setEnabled(true)
		end
	end
end

function acZnkhTabTwo:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.rankList and SizeOfTable(self.rankList) or 0
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(G_VisibleSizeWidth-50,self.cellHeight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local function cellClick1(hd,fn,idx)
		end
		if idx==0 then
			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",CCRect(20, 20, 10, 10),cellClick1)
		elseif idx==1 then
			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank1ItemBg.png",CCRect(20, 20, 10, 10),cellClick1)
		elseif idx==2 then
			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank2ItemBg.png",CCRect(20, 20, 10, 10),cellClick1)
		elseif idx==3 then
			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank3ItemBg.png",CCRect(20, 20, 10, 10),cellClick1)
		else
			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",CCRect(40, 40, 10, 10),cellClick1)
		end
		backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, self.cellHeight-4))
		backSprie:ignoreAnchorPointForPosition(false)
		backSprie:setAnchorPoint(ccp(0,0))
		backSprie:setIsSallow(false)
		-- backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		cell:addChild(backSprie)

		local data = self.rankList[idx+1]
		local rankStr = tostring(idx)
		if idx==0 then
			rankStr = tostring(data.rank)
		end
		local nameStr=data[2]
		local scoreStr=tostring(data[3])

		local rankLabel=GetTTFLabel(rankStr=="-1" and getlocal("dimensionalWar_out_of_rank") or rankStr,24)
		rankLabel:setPosition(100,self.cellHeight/2)
		cell:addChild(rankLabel,2)
		
		local rankSp
		if tonumber(rankStr)==1 then
			rankSp=CCSprite:createWithSpriteFrameName("top1.png")
		elseif tonumber(rankStr)==2 then
			rankSp=CCSprite:createWithSpriteFrameName("top2.png")
		elseif tonumber(rankStr)==3 then
			rankSp=CCSprite:createWithSpriteFrameName("top3.png")
		end
		if rankSp then
	      	rankSp:setPosition(ccp(75,self.cellHeight/2))
			backSprie:addChild(rankSp,3)
			rankLabel:setVisible(false)
		end

		local nameLb=GetTTFLabel(nameStr,24)
		nameLb:setPosition(280,self.cellHeight/2)
		backSprie:addChild(nameLb,3)

		local scoreLb=GetTTFLabel(scoreStr,24)
		scoreLb:setPosition(485,self.cellHeight/2)
		backSprie:addChild(scoreLb,3)

		if idx==0 then
			rankLabel:setColor(G_ColorYellowPro)
			nameLb:setColor(G_ColorYellowPro)
			scoreLb:setColor(G_ColorYellowPro)
		end

		return cell
	elseif fn=="ccTouchBegan" then
		return true
	elseif fn=="ccTouchMoved" then
	elseif fn=="ccTouchEnded"  then
	end
end

function acZnkhTabTwo:dispose()
end