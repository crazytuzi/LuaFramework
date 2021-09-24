acMjzxTabTwo = {}

function acMjzxTabTwo:new(parent)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	
    nc.normalHeight = 80
    
    nc.tv           = nil
    nc.bgLayer      = nil
    nc.layerNum     = nil
    
    nc.descLb       = nil
    nc.descLb1      = nil
    nc.rewardBtn    = nil

    nc.parent = parent
    return nc
end

function acMjzxTabTwo:init(layerNum)
    self.layerNum      = layerNum
    self.rankList      = acMjzxVoApi:getPlayerList( )
    self.rankAwardList = acMjzxVoApi:getRankAwardList()
    self.bgLayer       = CCLayer:create()

    self:initLayer()
    self:initTableView()
    -- self:tick()

    return self.bgLayer
end
function acMjzxTabTwo:refresh( )
    self.rankList = acMjzxVoApi:getPlayerList( )
    print("in two ~~~~~refresh~~~=====>>>>>>",acMjzxVoApi:getScore())
    tolua.cast(self.bgLayer:getChildByTag(111),"CCLabelTTF"):setString(getlocal("dailyAnswer_tab1_recentLabelNum",{acMjzxVoApi:getScore()}))
    self.tv:reloadData()
end

function acMjzxTabTwo:initTableView(  )
	self.tvHeight=self.bgLayer:getContentSize().height-280
	local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),function ()end)
	tvBg:setAnchorPoint(ccp(0,0))
	tvBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,self.tvHeight))
	tvBg:setPosition(ccp(20,8))
	self.bgLayer:addChild(tvBg)

	local pointSp3=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp3:setPosition(ccp(2,tvBg:getContentSize().height/2))
    tvBg:addChild(pointSp3)
    local pointSp4=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp4:setPosition(ccp(tvBg:getContentSize().width-2,tvBg:getContentSize().height/2))
    tvBg:addChild(pointSp4)

    local height=self.bgLayer:getContentSize().height-310
    local widthSpace=80

    local rankLabel=GetTTFLabel(getlocal("RankScene_rank"),24)
    rankLabel:setPosition(widthSpace,height)
    self.bgLayer:addChild(rankLabel,2)
    rankLabel:setColor(G_ColorYellowPro)
    
    local nameLabel=GetTTFLabel(getlocal("RankScene_name"),24)
    nameLabel:setPosition(widthSpace+150,height)
    self.bgLayer:addChild(nameLabel,2)
    nameLabel:setColor(G_ColorYellowPro)
    
    local levelLabel=GetTTFLabel(getlocal("serverwar_point"),24)
    levelLabel:setPosition(widthSpace+120*2.6,height)
    self.bgLayer:addChild(levelLabel,2)
    levelLabel:setColor(G_ColorYellowPro)

    local powerLabel=GetTTFLabel(getlocal("award"),24)
    powerLabel:setPosition(widthSpace+120*4-10,height)
    self.bgLayer:addChild(powerLabel,2)
    powerLabel:setColor(G_ColorYellowPro)

    
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,self.tvHeight-70),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,10))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(self.normalHeight)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acMjzxTabTwo:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local num=1
	    local playerList=acMjzxVoApi:getPlayerList()
	    if playerList and SizeOfTable(playerList)>0 then
	        num=num + SizeOfTable(playerList)
	    end
	    return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-70,self.normalHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cellWidht = self.bgLayer:getContentSize().width-70
        local cell=CCTableViewCell:new()
          cell:autorelease()
        local bgWidth = self.bgLayer:getContentSize().width-60
        local rankList=acMjzxVoApi:getPlayerList()

        if idx==0 then
            backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",CCRect(20, 20, 10, 10),function ()end)
        elseif idx==1 then
            backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank1ItemBg.png",CCRect(20, 20, 10, 10),function ()end)
        elseif idx==2 then
            backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank2ItemBg.png",CCRect(20, 20, 10, 10),function ()end)
        elseif idx==3 then
            backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank3ItemBg.png",CCRect(20, 20, 10, 10),function ()end)
        else
            backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",CCRect(20, 20, 10, 10),function ()end)
        end
        backSprie:setContentSize(CCSizeMake(bgWidth, self.normalHeight-2))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0,0))
        backSprie:setIsSallow(false)
        cell:addChild(backSprie)

        local rData,rank,name,point = nil
        
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
        end

        if idx==0 then
            rank=acMjzxVoApi:getSelfPos()
            name=playerVoApi:getPlayerName()
            point=acMjzxVoApi:getScore()

        else
            rData=self.rankList[idx] or {}
            rank=idx
            name=rData[1] or ""
            point=rData[2] or 0
        end

        local lbSize=25
        local lbHeight=(self.normalHeight-2)*0.5
        local lbWidth=50

        if rank==nil then
            rank="10+"
        end
        local rankLb=GetTTFLabel(rank,lbSize)
        rankLb:setPosition(ccp(lbWidth,lbHeight))
        cell:addChild(rankLb)
        rankLb:setColor(G_ColorYellow)

        local rankSp
        if tonumber(rank)==1 then
            rankSp=CCSprite:createWithSpriteFrameName("top1.png")
        elseif tonumber(rank)==2 then
            rankSp=CCSprite:createWithSpriteFrameName("top2.png")
        elseif tonumber(rank)==3 then
            rankSp=CCSprite:createWithSpriteFrameName("top3.png")
        end
        if rankSp then
            rankSp:setPosition(ccp(lbWidth,lbHeight))
            cell:addChild(rankSp,2)
            rankLb:setVisible(false)
        end

        local nameLb=GetTTFLabel(name,lbSize)
        nameLb:setPosition(ccp(lbWidth+150,lbHeight))
        cell:addChild(nameLb)

        local pointLb=GetTTFLabel(point,lbSize)
        pointLb:setPosition(ccp(lbWidth+120*2.6,lbHeight))
        cell:addChild(pointLb)
        pointLb:setColor(G_ColorYellow)

        if idx > 0 then
        	for k,v in pairs(self.rankAwardList[idx]) do
        		local function callback( )
					G_showNewPropInfo(self.layerNum+1,true,nil,nil,v,nil,nil,nil)
				end 
        		local icon,scale=G_getItemIcon(v,65,false,self.layerNum,callback,nil)
				backSprie:addChild(icon)
				icon:setTouchPriority(-(self.layerNum-1)*20-4)
				icon:setPosition(ccp(backSprie:getContentSize().width-70*k+20,backSprie:getContentSize().height*0.5))

				local numLabel=GetTTFLabel("x"..v.num,21,"Helvetica-bold")
                numLabel:setAnchorPoint(ccp(1,0))
                numLabel:setPosition(icon:getContentSize().width + 5, 5)
                numLabel:setScale(1/scale)
                icon:addChild(numLabel,1)
        	end
        elseif rank ~="10+" and tonumber(rank) then
        	for k,v in pairs(self.rankAwardList[rank]) do
        		local function callback( )
					G_showNewPropInfo(self.layerNum+1,true,nil,nil,v,nil,nil,nil)
				end 
        		local icon,scale=G_getItemIcon(v,65,false,self.layerNum,callback,nil)
				backSprie:addChild(icon)
				icon:setTouchPriority(-(self.layerNum-1)*20-4)
				icon:setPosition(ccp(backSprie:getContentSize().width-70*k+20,backSprie:getContentSize().height*0.5))

				local numLabel=GetTTFLabel("x"..v.num,21,"Helvetica-bold")
                numLabel:setAnchorPoint(ccp(1,0))
                numLabel:setPosition(icon:getContentSize().width + 5, 5)
                numLabel:setScale(1/scale)
                icon:addChild(numLabel,1)
        	end

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


function acMjzxTabTwo:initLayer( )
    local innerWidth = G_VisibleSizeWidth - 30
    local innerHeight = G_VisibleSizeHeight-200
    if(G_isIphone5())then
        h = G_VisibleSizeHeight - 100
    end


    local score = acMjzxVoApi:getScore()
    local currentIntegral=GetTTFLabel(getlocal("dailyAnswer_tab1_recentLabelNum",{score}),28) --当前积分 需要刷新 需要添加积分的函数VoApi
    currentIntegral:setPosition(ccp(50,innerHeight-10))
    currentIntegral:setAnchorPoint(ccp(0,0.5))
    currentIntegral:setTag(111)
    currentIntegral:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(currentIntegral)

    
    local str2Size = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        str2Size =25
    end
    local floor = acMjzxVoApi:getScoreFloor( )
    local scoreFloor = GetTTFLabelWrap(getlocal("activity_heroGift_scoreLb",{floor}),str2Size,CCSizeMake(innerWidth-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    scoreFloor:setPosition(ccp(50,innerHeight -50))
    scoreFloor:setAnchorPoint(ccp(0,0.5))
    scoreFloor:setTag(112)
    scoreFloor:setColor(G_ColorGreen)
    self.bgLayer:addChild(scoreFloor)

    local function touch(tag,object)
    	if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr=acMjzxVoApi:getRankInfoStr()

        local titleStr=getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,25)
    end

    local menuItemDesc = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",touch,nil,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    menuItemDesc:setScale(0.9)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(innerWidth-20, innerHeight))
    self.bgLayer:addChild(menuDesc)

    ----------------
    -- local function onClickDesc()
    --     local isReaward = acMjzxVoApi:isReaward( )
    --     if acMjzxVoApi:getedBigAward() ~=nil then
    --         smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_hadReward"),28)
    --         do return end 
    --     end
    --     if isReaward ==true and acMjzxVoApi:acIsStop() ==true then
    --         self:getBigReward()
    --     end
    -- end
    -- self.bigAwardClick = GetButtonItem("creatRoleBtn.png","newGreenBtn_down.png","creatRoleBtn.png",onClickDesc,nil,getlocal("newGiftsReward"),28,11)
    -- self.bigAwardClick:setTag(888)
    -- self.bigAwardClick:setEnabled(false)
    -- local descBtn=CCMenu:createWithItem(self.bigAwardClick)
    -- descBtn:setAnchorPoint(ccp(0,0.5))
    -- descBtn:setPosition(ccp(G_VisibleSizeWidth*0.5,60))
    -- descBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    -- self.bgLayer:addChild(descBtn,2)
end
-- function acMjzxTabTwo:getBigReward( )
--     local function getRanklist(fn,data)
--         local ret,sData=base:checkServerData(data)
--         if ret==true then
--             if sData and sData.data and sData.data.rankList  then
--                 acMjzxVoApi:setPlayerList(sData.data.rankList)
--             end
--             self:refresh(1)
--         end
--         local bigAwardIdx = acMjzxVoApi:getSelfPos()
-- 	    local function getBigAwardCall(fn,data)
-- 	        local ret,sData = base:checkServerData(data)
-- 	        if ret==true then
-- 	            acMjzxVoApi:getAndShowBigAward(bigAwardIdx)
-- 	            self.bigAwardClick:setEnabled(false)
-- 	        end
-- 	    end
-- 	    socketHelper:acMjzxRequest({action=4,rank=bigAwardIdx},getBigAwardCall)

--       end
--     socketHelper:acMjzxRequest({action=2},getRanklist)
-- end

function acMjzxTabTwo:tick( )
    -- if acMjzxVoApi:getedBigAward() then
    --     self.bigAwardClick:setEnabled(false)
    -- elseif acMjzxVoApi:acIsStop() ==true and acMjzxVoApi:isReaward() ==true and acMjzxVoApi:getedBigAward( ) == nil then
    --     self.bigAwardClick:setEnabled(true)
    -- end
end

function acMjzxTabTwo:dispose( )
    self.rankAwardList = nil
    self.normalHeight  = nil
    self.tv            = nil
    self.bgLayer       = nil
    self.layerNum      = nil
    self.descLb        = nil
    self.descLb1       = nil
    self.rewardBtn     = nil
    self.parent = nil
end