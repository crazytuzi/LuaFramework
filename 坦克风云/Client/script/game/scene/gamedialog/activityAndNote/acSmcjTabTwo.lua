acSmcjTabTwo={}
function acSmcjTabTwo:new(parent)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.parent    = parent
	nc.bgLayer   = nil
	nc.isIphone5 = G_isIphone5()

	nc.url       = G_downloadUrl("active/".."acSmcjImage.jpg") or nil
	nc.upPosY    = G_VisibleSizeHeight-160
	nc.upHeight  = 160 + 240
    nc.rankShowIdx = 0
    nc.rankShowScore = nil
    nc.addShowIdx = 1
	return nc
end
function acSmcjTabTwo:dispose( )
    self.addShowIdx    = nil
    self.rankShowIdx   = nil
    self.rankShowScore = nil
    self.bgLayer       = nil
    self.parent        = nil
    self.isIphone5     = nil
end
function acSmcjTabTwo:init(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()

	self.rankList,self.cellNum = acSmcjVoApi:getRankList()

	self:initUpPanel()
	self:initDownPanel()
	return self.bgLayer
end

function acSmcjTabTwo:initUpPanel( )
	local function onLoadIcon(fn,icon)
		if icon and self and self.bgLayer then
		    icon:setAnchorPoint(ccp(0.5,1))
		    icon:setPosition(G_VisibleSizeWidth * 0.5,self.upPosY)
		    self.bgLayer:addChild(icon)
		end
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	--顶框
	local topBorder = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function() end)
	self.bgLayer:addChild(topBorder,1)
	topBorder:setAnchorPoint(ccp(0.5,1))
	topBorder:setContentSize(CCSizeMake(G_VisibleSizeWidth,85))
	topBorder:setPosition(ccp(G_VisibleSizeWidth * 0.5,G_VisibleSizeHeight-160))

	--倒计时 
	-- local timeLb = GetTTFLabel(acSmcjVoApi:getTimer(),25)
	-- timeLb:setColor(G_ColorYellowPro3)
	-- timeLb:setAnchorPoint(ccp(0.5,1))
	-- timeLb:setPosition(ccp(G_VisibleSizeWidth * 0.5,G_VisibleSizeHeight-170))
	-- self.timeLb = timeLb
	-- self.bgLayer:addChild(timeLb,1)

	local descStr1=acSmcjVoApi:getTimer()
    local descStr2=acSmcjVoApi:getRewardTimeStr()
    local addposy = G_isIOS() and 0 or 3
    local moveBgStarStr,timeLb1,timeLb2=G_LabelRollView(CCSizeMake(self.bgLayer:getContentSize().width,46 + addposy),descStr1,25,kCCTextAlignmentCenter,G_ColorGreen,nil,descStr2,G_ColorYellowPro,2,2,2,nil)
    self.timeLb1=timeLb1
    self.timeLb2=timeLb2
    moveBgStarStr:setPosition(ccp(0,self.bgLayer:getContentSize().height-moveBgStarStr:getContentSize().height-180))
    self.bgLayer:addChild(moveBgStarStr,999)

	local function touchInfo()
        -- local tabStr={}
        -- for i=1,4 do
        -- 	table.insert(tabStr,getlocal("activity_smcj_tab1_tip"..i))
        -- end
        -- local titleStr=getlocal("activity_baseLeveling_ruleTitle")
        -- require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        -- local textSize = 25
        -- tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,textSize)
        local strSize = 25
	    if G_getCurChoseLanguage() ~= "cn" then
	        strSize = 20
	    end
        local strTab={}
        local colorTab={}
        local tabAlignment={}
        local rewards=acSmcjVoApi:getRankReward()
        local needRank=0
        for k,v in pairs(rewards) do
            local rank=v.rank
            local reward=FormatItem(v.reward,false,true)
            local rewardCount=SizeOfTable(reward)
            local str=""
            for k,v in pairs(reward) do
                if k==rewardCount then
                    str=str..v.name.." x"..v.num
                else
                    str=str..v.name.." x"..v.num..","
                end
            end
            if rank[1]==rank[2] then
                str=getlocal("rank_reward_str",{rank[1],str})
            else
                str=getlocal("rank_reward_str",{rank[1].."~"..rank[2],str})
            end
            table.insert(strTab,1,str)
            table.insert(colorTab,1,G_ColorWhite)
            table.insert(tabAlignment,1,kCCTextAlignmentLeft)
            -- if tonumber(rank[2])>needRank then
            --     needRank=rank[2]
            -- end
        end
        table.insert(strTab,1," ")
        table.insert(colorTab,1,G_ColorWhite)
        table.insert(tabAlignment,1,kCCTextAlignmentLeft)
        local ruleStr=getlocal("activityDescription")
        local ruleStr1=getlocal("activity_smcj_tab2_tip1",{acSmcjVoApi:getrShowNum()})
        local ruleStr2=getlocal("activity_smcj_tab2_tip2",{acSmcjVoApi:getMinRecharge()})
        local ruleStr3=getlocal("activity_smcj_tab2_tip3")
        local ruleStr5=getlocal("activity_smcj_tab2_tip4")
        local ruleStr4=getlocal("miaautumn_rank_rule4")

        local strTab2={" ",ruleStr4," ",ruleStr5,ruleStr3,ruleStr2,ruleStr1," ",ruleStr," "}
        for k,v in pairs(strTab2) do
            table.insert(strTab,v)
            if tostring(v)==tostring(ruleStr) or tostring(v)==tostring(ruleStr4) then
                table.insert(colorTab,G_ColorYellowPro)
                table.insert(tabAlignment,kCCTextAlignmentCenter)
            else
                table.insert(colorTab,G_ColorWhite)
                table.insert(tabAlignment,kCCTextAlignmentLeft)
            end     
        end

        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,strTab,strSize,colorTab,nil,nil,nil,tabAlignment)
        sceneGame:addChild(dialog,self.layerNum+1)
	end 
    local tipButton = G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth-40,G_VisibleSizeHeight-160-40),nil,"i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchInfo,1,-(self.layerNum-1)*20-4,1)



    local lbPosy = G_VisibleSizeHeight - self.upHeight * 0.7 + 20
    local basePosx1 = 150
    local totalScoreLb = GetTTFLabel(getlocal("totalScore")..":",23,true)
    totalScoreLb:setAnchorPoint(ccp(0,0.5))
    totalScoreLb:setPosition(basePosx1,lbPosy)
    self.bgLayer:addChild(totalScoreLb,1)
    --acRadar_integralIcon.png
    local tipIcon = CCSprite:createWithSpriteFrameName("acRadar_integralIcon.png")
    tipIcon:setAnchorPoint(ccp(0,0.5))
    tipIcon:setPosition(basePosx1 + totalScoreLb:getContentSize().width + 5,lbPosy)
    self.bgLayer:addChild(tipIcon,1)

    local scoreNum = GetTTFLabel(acSmcjVoApi:getCurScore( ),24,true)
    scoreNum:setColor(G_ColorYellowPro2)
    scoreNum:setAnchorPoint(ccp(0,0.5))
    scoreNum:setPosition(basePosx1 + totalScoreLb:getContentSize().width + tipIcon:getContentSize().width + 10, lbPosy)
    self.bgLayer:addChild(scoreNum,1)
    self.scoreNum = scoreNum

    local lbPosy2 = lbPosy - 40
    local totalRcLb = GetTTFLabel(getlocal("totalRecharge")..":",23,true)
    totalRcLb:setAnchorPoint(ccp(0,0.5))
    totalRcLb:setPosition(basePosx1,lbPosy2)
    self.bgLayer:addChild(totalRcLb,1)

    local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
    goldIcon:setAnchorPoint(ccp(0,0.5))
    goldIcon:setPosition(basePosx1 + totalRcLb:getContentSize().width + 5,lbPosy2)
    self.bgLayer:addChild(goldIcon,1)

    local rcGoldNum = GetTTFLabel(acSmcjVoApi:getCurRechargeNum( ),24,true)
    rcGoldNum:setColor(G_ColorYellowPro2)
    rcGoldNum:setAnchorPoint(ccp(0,0.5))
    rcGoldNum:setPosition(basePosx1 + totalRcLb:getContentSize().width + goldIcon:getContentSize().width + 10, lbPosy2)
    self.bgLayer:addChild(rcGoldNum,1)
    self.rcGoldNum = rcGoldNum

    local lbPosy3 = lbPosy2 - 40
    local strSize2 = G_isAsia() and 24 or 18
    local subPosx = G_isAsia() and 0 or 120
    if G_getCurChoseLanguage()=="ko" then
        subPosx = subPosx + 80
    end
    local rcToLimitLb =GetTTFLabel("("..getlocal("rechargeToLimitStr"),strSize2,true)
    rcToLimitLb:setAnchorPoint(ccp(0,0.5))
    rcToLimitLb:setPosition(basePosx1 - subPosx,lbPosy3)
    self.bgLayer:addChild(rcToLimitLb,1)

    --acSmcjVoApi:getMinRecharge()
    local limitGold = GetTTFLabel(acSmcjVoApi:getMinRecharge(),strSize2,true)
    limitGold:setColor(G_ColorYellowPro2)
    limitGold:setAnchorPoint(ccp(0,0.5))
    limitGold:setPosition(basePosx1 - subPosx + rcToLimitLb:getContentSize().width, lbPosy3)
    self.bgLayer:addChild(limitGold,1)

    local goldIcon2 = CCSprite:createWithSpriteFrameName("IconGold.png")
    goldIcon2:setAnchorPoint(ccp(0,0.5))
    goldIcon2:setPosition(basePosx1 - subPosx + rcToLimitLb:getContentSize().width + 5 + limitGold:getContentSize().width,lbPosy3)
    self.bgLayer:addChild(goldIcon2,1)

     local willToRank = GetTTFLabel(getlocal("willInRankStr")..")",strSize2,true)
    willToRank:setAnchorPoint(ccp(0,0.5))
    willToRank:setPosition(basePosx1 - subPosx + rcToLimitLb:getContentSize().width + goldIcon2:getContentSize().width + 10  + limitGold:getContentSize().width, lbPosy3)
    self.bgLayer:addChild(willToRank,1)
    if G_getCurChoseLanguage()=="ar" then
        local realWidth=willToRank:getContentSize().width+goldIcon2:getContentSize().width+limitGold:getContentSize().width+rcToLimitLb:getContentSize().width+5
        willToRank:setPositionX((G_VisibleSizeWidth-realWidth)/2)
        limitGold:setPositionX(willToRank:getPositionX()+willToRank:getContentSize().width+5)
        goldIcon2:setPositionX(limitGold:getPositionX()+limitGold:getContentSize().width)
        rcToLimitLb:setPositionX(goldIcon2:getPositionX()+goldIcon2:getContentSize().width)
    end

    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function() end)
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-5)
    touchDialogBg:setContentSize(CCSizeMake(150,370))
    touchDialogBg:setAnchorPoint(ccp(1,1))
    touchDialogBg:setOpacity(0)
    touchDialogBg:setPosition(G_VisibleSizeWidth-30,G_VisibleSizeHeight-230)
    self.bgLayer:addChild(touchDialogBg,1)
end

function acSmcjTabTwo:initDownPanel()
	self.tvWidth,self.tvHeight = G_VisibleSizeWidth, G_VisibleSizeHeight - self.upHeight - 15
	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
    tvBg:setContentSize(CCSizeMake(self.tvWidth,self.tvHeight))
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(20,15))
    self.bgLayer:addChild(tvBg)

    self.noRankLb=GetTTFLabelWrap(getlocal("activity_fightRanknew_no_rank"),35,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRankLb:setAnchorPoint(ccp(0.5,0.5))
    self.noRankLb:setPosition(tvBg:getContentSize().width * 0.5,tvBg:getContentSize().height * 0.5)
    tvBg:addChild(self.noRankLb,1)
    self.noRankLb:setColor(G_ColorGray)

    local tvTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName("ltzdzNameBg.png",CCRect(4, 4, 1, 1),function() end)
    tvTitleBg:setContentSize(CCSizeMake(self.tvWidth - 8,45))
    tvTitleBg:setAnchorPoint(ccp(0.5,1))
    tvTitleBg:setPosition(self.tvWidth * 0.5,self.tvHeight - 4)
    tvBg:addChild(tvTitleBg)

    local lbSize= G_isAsia() and 22 or 18
    local posxTb = {65,215,380,520}
    self.posxTb = posxTb
    local lbTb = {"RankScene_rank","playerName","serverwar_point","award"}
    for i=1,4 do
    	local label = GetTTFLabel(getlocal(lbTb[i]),lbSize)
    	label:setPosition(posxTb[i],tvTitleBg:getContentSize().height * 0.5)
    	label:setColor(G_ColorYellowPro2)
    	tvTitleBg:addChild(label)
    end

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth - 8,self.tvHeight - 49),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(24,17))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acSmcjTabTwo:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth - 8,80) 
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local cellWidth=self.tvWidth - 8
        local cellHeight=80
        local rank
        local rankStr
        local name
        local value
        local rankData
        if idx == 0 then
            rank,rankStr=acSmcjVoApi:getRankShowIndex()
            name=playerVoApi:getPlayerName()
            value=acSmcjVoApi:getCurScore( )
        else
            rankData = self.rankList[idx]
        end
        if rankData then
            if not self.rankShowScore or self.rankShowScore ~= rankData[3] then
                self.rankShowScore = rankData[3]
                self.rankShowIdx = self.rankShowIdx + self.addShowIdx
                self.addShowIdx = 1
            else
                self.addShowIdx = self.addShowIdx + 1
            end
            rank=self.rankShowIdx
            name=rankData[2] or ""
            value=rankData[3] or 0
        end
        
        if rank and name and value then
            local height=40
            local w=(G_VisibleSizeWidth-60)/3
            local function getX(index)
                return -5+w*index+w/2
            end
            local capInSet = CCRect(40, 40, 10, 10);
            local capInSetNew=CCRect(20, 20, 10, 10)
            local widthSpace=50
            local backSprie

            local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png", CCRect(4, 4, 1, 1), function () end)
            backSprie:setContentSize(CCSizeMake(cellWidth,80))
            backSprie:setPosition(ccp(cellWidth * 0.5,cellHeight * 0.5))
            cell:addChild(backSprie)
            backSprie:setOpacity(idx % 2 * 255)
            local height=backSprie:getContentSize().height * 0.5

            if tonumber(rank) and tonumber(rank) < 4 then
                local signSp = CCSprite:createWithSpriteFrameName("top_" .. rank .. ".png")
                signSp:setPosition(ccp(cellWidth * 0.5 , cellHeight * 0.5))
                signSp:setScaleY((cellHeight-10)/signSp:getContentSize().height)
                signSp:setScaleX((cellWidth-10)/signSp:getContentSize().width)
                cell:addChild(signSp, 1)

                local rankSp=CCSprite:createWithSpriteFrameName("top" .. rank .. ".png")
                rankSp:setAnchorPoint(ccp(0.5,0.5))
                rankSp:setScale(0.7)
                rankSp:setPosition(ccp(self.posxTb[1],height))
                cell:addChild(rankSp,3)
            else
                local rankLabel
                if idx == 0 then
                    -- 第一条是自己
                    rankLabel=GetTTFLabel(rankStr,25)
                else
                    -- 默认
                    rankLabel=GetTTFLabel(rank,25)
                end
                rankLabel:setAnchorPoint(ccp(0.5,0.5))
                rankLabel:setPosition(self.posxTb[1],height)
                cell:addChild(rankLabel,2)
            end
          
            local playerNameLabel=GetTTFLabelWrap(name,25,CCSizeMake(175,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            playerNameLabel:setAnchorPoint(ccp(0.5,0.5))
            playerNameLabel:setPosition(self.posxTb[2],height)
            cell:addChild(playerNameLabel,2)
            
            local valueLabel=GetTTFLabel(FormatNumber(value),25)
            valueLabel:setAnchorPoint(ccp(0.5,0.5))
            valueLabel:setPosition(self.posxTb[3],height)
            cell:addChild(valueLabel,2)

            if rank < 11 then
	            local awardTb = acSmcjVoApi:getRankAward(rank)
	            for k,v in pairs(awardTb) do
	            	local function callback()
						G_showNewPropInfo(self.layerNum+1,true,nil,nil,v,nil,nil,nil,nil,true)
					end
					local icon,scale=G_getItemIcon(v,60,false,self.layerNum,callback,nil)
					cell:addChild(icon,3)
					icon:setTouchPriority(-(self.layerNum-1)*20-3)
					icon:setPosition(self.posxTb[4] + (k-1) * 65 - 40,height)

					local numLb = GetTTFLabel("x" .. FormatNumber(v.num),20)
					numLb:setAnchorPoint(ccp(1,0))
					icon:addChild(numLb,4)
					numLb:setPosition(icon:getContentSize().width-5, 5)
					numLb:setScale(1/scale)

					local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
			        numBg:setAnchorPoint(ccp(1,0))
			        numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
			        numBg:setPosition(ccp(icon:getContentSize().width-5,5))
			        numBg:setOpacity(150)
			        icon:addChild(numBg,3)
	            end
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

function acSmcjTabTwo:updataRank( )
	self.rankList,self.cellNum = acSmcjVoApi:getRankList()
	print(" in updataRank self.cellNum==>>",self.cellNum)
	if self.scoreNum then
		self.scoreNum:setString(acSmcjVoApi:getCurScore())
	end
	if self.rcGoldNum then
		self.rcGoldNum:setString(acSmcjVoApi:getCurRechargeNum())
	end
	if self.tv then
        self.rankShowIdx   = 0
        self.rankShowScore = nil
        self.addShowIdx    = 1
		self.tv:reloadData()
	end
	if self.noRankLb then
		if self.cellNum > 1 then
			self.noRankLb:setVisible(false)
		else
			self.noRankLb:setVisible(true)
		end
	end
end
function acSmcjTabTwo:tick( )
	-- if self.timeLb then
 --    	self.timeLb:setString(acSmcjVoApi:getTimer())
 --    end
  local acVo=acSmcjVoApi:getAcVo()
    if(acVo and self.timeLb1 and tolua.cast(self.timeLb1,"CCLabelTTF"))then
        -- G_updateActiveTime(acVo,self.timeLb1,self.timeLb2,true)
        local descStr1=acSmcjVoApi:getTimer()
        local descStr2=acSmcjVoApi:getRewardTimeStr()
        self.timeLb1:setString(descStr1)
        self.timeLb2:setString(descStr2)
    end
end