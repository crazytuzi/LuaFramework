acRoulette4DialogTab2={}

function acRoulette4DialogTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	
	self.normalHeight=80
	
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
	self.selectedTabIndex=1
	self.acRoulette4Dialog=nil

    self.descLb=nil
    self.descLb1=nil
    self.rewardBtn=nil

    return nc
end

function acRoulette4DialogTab2:init(layerNum,selectedTabIndex,acRoulette4Dialog)
    self.layerNum=layerNum
    self.selectedTabIndex=selectedTabIndex
    self.acRoulette4Dialog=acRoulette4Dialog
    self.bgLayer=CCLayer:create()

    self:initTableView()
    self:doUserHandler()

    return self.bgLayer
end

--设置对话框里的tableView
function acRoulette4DialogTab2:initTableView()
	local height=self.bgLayer:getContentSize().height-285-20
	local widthSpace=80

	-- local rankLabel=GetTTFLabel(getlocal("RankScene_rank"),22)
	-- rankLabel:setPosition(widthSpace,height)
	-- self.bgLayer:addChild(rankLabel,2)
	-- rankLabel:setColor(G_ColorGreen)
	
	local nameLabel=GetTTFLabel(getlocal("RankScene_name"),22)
	-- nameLabel:setPosition(widthSpace+120,height)
    nameLabel:setPosition(widthSpace+90,height)
	self.bgLayer:addChild(nameLabel,2)
	nameLabel:setColor(G_ColorGreen)
	
	local levelLabel=GetTTFLabel(getlocal("RankScene_level"),22)
	levelLabel:setPosition(widthSpace+120*2+20,height)
    -- levelLabel:setPosition(widthSpace+120*2,height)
	self.bgLayer:addChild(levelLabel,2)
	levelLabel:setColor(G_ColorGreen)

	-- local powerLabel=GetTTFLabel(getlocal("RankScene_power"),22)
	-- powerLabel:setPosition(widthSpace+120*3+10,height)
	-- self.bgLayer:addChild(powerLabel,2)
	-- powerLabel:setColor(G_ColorGreen)

    
    local pointLabel=GetTTFLabel(getlocal("award"),22)
	-- local pointLabel=GetTTFLabel(getlocal("activity_wheelFortune_point"),22)
	-- pointLabel:setPosition(widthSpace+120*4,height)
    pointLabel:setPosition(widthSpace+120*4-80,height)
	self.bgLayer:addChild(pointLabel,2)
	pointLabel:setColor(G_ColorGreen)

	self.tvHeight=self.bgLayer:getContentSize().height-340-20

	local capInSet = CCRect(20, 20, 10, 10);
    local function bgClick(hd,fn,idx)
    end
    local backBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
    backBg:setContentSize(CCSizeMake(G_VisibleSize.width-60, self.tvHeight+10))
    backBg:setAnchorPoint(ccp(0,0))
    backBg:setPosition(ccp(30,30))
    self.bgLayer:addChild(backBg)


    -- local function rewardHandler()
    --     local rank=acRoulette4VoApi:rankCanReward()
    --     local function wheelfortuneCallback(fn,data)
    --         local ret,sData=base:checkServerData(data)
    --         if ret==true then
    --             local rouletteCfg=acRoulette4VoApi:getRouletteCfg()
    --             local rewardCfg=rouletteCfg.r or {}

    --             local reward
    --             if rank==1 then
    --                 reward=FormatItem(rewardCfg[1]) or {}
    --             elseif rank==2 then
    --                 reward=FormatItem(rewardCfg[2]) or {}
    --             elseif rank==3 then
    --                 reward=FormatItem(rewardCfg[3]) or {}
    --             elseif rank==4 or rank==5 then
    --                 reward=FormatItem(rewardCfg[4]) or {}
    --             elseif rank>=6 and rank<=10 then
    --                 reward=FormatItem(rewardCfg[5]) or {}
    --             end
    --             if reward then
    --                 for k,v in pairs(reward) do
    --                     G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
    --                 end
    --                 G_showRewardTip(reward)
    --             end
    --             acRoulette4VoApi:setListRewardNum()
    --             self:refresh()
    --         elseif sData.ret==-1975 then
    --             local function getListCallback(fn,data)
    --             local ret,sData=base:checkServerData(data)
    --                 if ret==true then
    --                     if self and self.bgLayer then
    --                         local rankList
    --                         if sData.data and sData.data.wheelFortune4 and sData.data.wheelFortune4.rankList then
    --                             acRoulette4VoApi:clearRankList()

    --                             rankList=sData.data.wheelFortune4
    --                             acRoulette4VoApi:updateData(rankList)
    --                             self:refresh()

    --                             acRoulette4VoApi:setLastListTime(base.serverTime)
    --                             -- acRoulette4VoApi:setFlag(2,1)
    --                         end
    --                     end
    --                 end
    --             end
    --             socketHelper:activeWheelfortune4(2,getListCallback)
    --         end
    --         -- self.rank=self.rank+1
    --     end
    --     -- if self.rank==nil then
    --     --     self.rank=1
    --     -- end
    --     if rank>0 then
    --         socketHelper:activeWheelfortune4(4,wheelfortuneCallback,rank)
    --     end
    -- end
    -- self.rewardBtn = GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",rewardHandler,nil,getlocal("newGiftsReward"),25,11)
    -- self.rewardBtn:setAnchorPoint(ccp(0.5,0))
    -- local rewardMenu=CCMenu:createWithItem(self.rewardBtn)
    -- rewardMenu:setPosition(ccp(backBg:getContentSize().width/2,15))
    -- rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    -- backBg:addChild(rewardMenu,2)
    -- self.rewardBtn:setEnabled(false)
    -- if acRoulette4VoApi:rankCanReward()>0 then
    --     self.rewardBtn:setEnabled(true)
    -- end
    -- local vo=acRoulette4VoApi:getAcVo()
    -- if vo and vo.listRewardNum==0 then
    --     tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("newGiftsReward"))
    -- else
    --     tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
    -- end
	
    local function callBack(...)
    	return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,self.tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,40))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(self.normalHeight)

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acRoulette4DialogTab2:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local num=0
        -- local num=1
        local rankList=acRoulette4VoApi:getRankList()
        if rankList and SizeOfTable(rankList)>0 then
            num=num+SizeOfTable(rankList)
        end
        return num
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-70,self.normalHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
    	local cell=CCTableViewCell:new()
		cell:autorelease()

        local vo=acRoulette4VoApi:getAcVo()
        local rankList=acRoulette4VoApi:getRankList()
        local rData
        
        local id
        local rank
        local name
        local level
        local power
        local point
        local award
		
		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(20, 20, 10, 10);
		local function cellClick(hd,fn,idx)
		   --return self:cellClick(idx)
		end

        local index=idx+1
   --      if idx==0 then
   --      	rank=acRoulette4VoApi:getSelfRank()
   --      	name=playerVoApi:getPlayerName()
			-- level=playerVoApi:getPlayerLevel()
			-- power=playerVoApi:getPlayerPower()
			-- point=vo.totalPoint or 0

			-- local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png")
			-- -- bgSp:setAnchorPoint(ccp(0,0.5))
			-- bgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.normalHeight/2-5));
			-- bgSp:setScaleY(self.normalHeight/bgSp:getContentSize().height)
			-- bgSp:setScaleX(1000/bgSp:getContentSize().width)
			-- cell:addChild(bgSp)
   --      else
   --          rData=rankList[idx] or {}
   --          rank=idx
            rData=rankList[index] or {}
            id=rData[1] or 0
            award=FormatItem(rData[2])[1] or {}
            rank=rData[3] or 0
            name=rData[4] or ""
            level=rData[5] or 0
		-- end
		
		local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
		lineSp:setAnchorPoint(ccp(0,1));
		lineSp:setPosition(ccp(0,self.normalHeight));
		cell:addChild(lineSp,1)

        local lbSize=25
        local lbHeight=35
        local lbWidth=50

  --       local rankLb=GetTTFLabel(rank,lbSize)
  --       rankLb:setPosition(ccp(lbWidth,lbHeight))
  --       cell:addChild(rankLb)
  --       rankLb:setColor(G_ColorYellow)

  --       local rankSp
		-- if tonumber(rank)==1 then
		-- 	rankSp=CCSprite:createWithSpriteFrameName("top1.png")
		-- elseif tonumber(rank)==2 then
		-- 	rankSp=CCSprite:createWithSpriteFrameName("top2.png")
		-- elseif tonumber(rank)==3 then
		-- 	rankSp=CCSprite:createWithSpriteFrameName("top3.png")
		-- end
		-- if rankSp then
	 --      	rankSp:setPosition(ccp(lbWidth,lbHeight))
		-- 	cell:addChild(rankSp,2)
		-- 	rankLb:setVisible(false)
		-- end

        local nameLb=GetTTFLabel(name,lbSize)
        -- nameLb:setPosition(ccp(lbWidth+120,lbHeight))
        nameLb:setPosition(ccp(lbWidth+90,lbHeight))
        cell:addChild(nameLb)

        local levelLb=GetTTFLabel(level,lbSize)
        levelLb:setPosition(ccp(lbWidth+120*2+20,lbHeight))
        cell:addChild(levelLb)
        
        -- local powerLb=GetTTFLabel(power,lbSize)
        -- powerLb:setPosition(ccp(lbWidth+120*3+10,lbHeight))
        -- cell:addChild(powerLb)

        -- local pointLb=GetTTFLabel(point,lbSize)
        -- pointLb:setPosition(ccp(lbWidth+120*4,lbHeight))
        -- cell:addChild(pointLb)
        -- pointLb:setColor(G_ColorYellow)

        local rankSp
        if award and award.pic then
            rankSp=CCSprite:createWithSpriteFrameName(award.pic)
        end
        -- if tonumber(rank)==1 then
        --     rankSp=CCSprite:createWithSpriteFrameName("The_commander_icon.png")
        -- elseif tonumber(rank)==2 then
        --     rankSp=CCSprite:createWithSpriteFrameName("The_general_icon.png")
        -- elseif tonumber(rank)==3 then
        --     rankSp=CCSprite:createWithSpriteFrameName("lieutenant_general_icon.png")
        -- end
        local size=70
        if rankSp then
            rankSp:setPosition(ccp(lbWidth+120*3+40,lbHeight))
            rankSp:setScale(size/rankSp:getContentSize().width)
            cell:addChild(rankSp,2)
        end

    	return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function acRoulette4DialogTab2:doUserHandler()
    local capInSet = CCRect(20, 20, 10, 10);
    local function bgClick(hd,fn,idx)
    end
    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
    titleBg:setContentSize(CCSizeMake(G_VisibleSize.width-60, 120))
    titleBg:setAnchorPoint(ccp(0,0));
    titleBg:setPosition(ccp(30,G_VisibleSize.height-85-80-120))
    self.bgLayer:addChild(titleBg,1)


  --   -- local vo=acRoulette4VoApi:getAcVo()
  --   -- self.descLb=GetTTFLabel(getlocal("activity_wheelFortune_has_num",{vo.totalPoint}),25)
  --   self.descLb=GetTTFLabelWrap(getlocal("activity_wheelFortune4_rank_desc"),22,CCSizeMake(titleBg:getContentSize().width-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  --   self.descLb:setAnchorPoint(ccp(0,0.5));
  --   -- self.descLb:setPosition(ccp(15,titleBg:getContentSize().height/2+20));
  --   self.descLb:setPosition(ccp(15,titleBg:getContentSize().height/2));
  --   titleBg:addChild(self.descLb,2);
 	-- self.descLb:setColor(G_ColorGreen)

    local function callBack1(...)
        return self:eventHandler1(...)
    end
    local hd= LuaEventHandler:createHandler(callBack1)
    self.tv1=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-80,110),nil)
    self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv1:setPosition(ccp(10,5))
    titleBg:addChild(self.tv1,2)
    self.tv1:setMaxDisToBottomOrTop(50)
end

function acRoulette4DialogTab2:getCellHeight()
    local descLb=GetTTFLabelWrap(getlocal("activity_wheelFortune4_rank_desc"),22,CCSizeMake(G_VisibleSize.width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    local cellHeight=descLb:getContentSize().height+50
    if cellHeight<110 then
        cellHeight=110
    end
    return cellHeight
end

function acRoulette4DialogTab2:eventHandler1(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        if self.cellHeight==nil then
            self.cellHeight=self:getCellHeight()
        end
        tmpSize=CCSizeMake(G_VisibleSize.width-80,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        -- local vo=acRoulette4VoApi:getAcVo()
        -- if vo==nil then
        --     do return cell end
        -- end
        if self.cellHeight==nil then
            self.cellHeight=self:getCellHeight()
        end

        self.descLb=GetTTFLabelWrap(getlocal("activity_wheelFortune4_rank_desc"),22,CCSizeMake(G_VisibleSize.width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        self.descLb:setAnchorPoint(ccp(0,0.5))
        self.descLb:setPosition(ccp(0,self.cellHeight/2))
        cell:addChild(self.descLb,2)
        self.descLb:setColor(G_ColorGreen)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acRoulette4DialogTab2:tick()
end

function acRoulette4DialogTab2:subtick()
end

function acRoulette4DialogTab2:refresh()
    if self and self.bgLayer then
        local vo=acRoulette4VoApi:getAcVo()
        -- if self.descLb then
        --     self.descLb:setString(getlocal("activity_wheelFortune_has_num",{vo.totalPoint}))
        -- end
        if self.tv then
            self.tv:reloadData()
        end
        -- if self.rewardBtn then
        --     if acRoulette4VoApi:rankCanReward()>0 then
        --         self.rewardBtn:setEnabled(true)
        --     else
        --         self.rewardBtn:setEnabled(false)
        --     end
        --     if vo and vo.listRewardNum==0 then
        --         tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("newGiftsReward"))
        --     else
        --         tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
        --     end
        -- end
        
    end
end

function acRoulette4DialogTab2:dispose()
    self.noFriendLabel = nil
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.selectedTabIndex=nil
    self.acRoulette4Dialog=nil

    self.descLb=nil
    self.descLb1=nil
    self.rewardBtn=nil

    self=nil
end






