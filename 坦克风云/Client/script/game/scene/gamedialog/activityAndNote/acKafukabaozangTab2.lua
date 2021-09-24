acKafukabaozangTab2={}

function acKafukabaozangTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	
	self.normalHeight=80
	
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
	self.selectedTabIndex=1
	self.acEquipSearchDialog=nil

    self.descLb=nil
    self.descLb1=nil
    self.rewardBtn=nil

    return nc
end

function acKafukabaozangTab2:init(layerNum,selectedTabIndex,acEquipSearchDialog)
    self.layerNum=layerNum
    self.selectedTabIndex=selectedTabIndex
    self.acEquipSearchDialog=acEquipSearchDialog
    self.bgLayer=CCLayer:create()

    self:initTableView()
    self:doUserHandler()

    return self.bgLayer
end

--设置对话框里的tableView
function acKafukabaozangTab2:initTableView()
	local height=self.bgLayer:getContentSize().height-285-20
	local widthSpace=80

	local rankLabel=GetTTFLabel(getlocal("RankScene_rank"),22)
	rankLabel:setPosition(widthSpace,height)
	self.bgLayer:addChild(rankLabel,2)
	rankLabel:setColor(G_ColorGreen)
	
	local nameLabel=GetTTFLabel(getlocal("RankScene_name"),22)
	nameLabel:setPosition(widthSpace+120,height)
	self.bgLayer:addChild(nameLabel,2)
	nameLabel:setColor(G_ColorGreen)
	
	local levelLabel=GetTTFLabel(getlocal("RankScene_level"),22)
	levelLabel:setPosition(widthSpace+120*2+20,height)
	self.bgLayer:addChild(levelLabel,2)
	levelLabel:setColor(G_ColorGreen)

	local powerLabel=GetTTFLabel(getlocal("RankScene_power"),22)
	powerLabel:setPosition(widthSpace+120*3+10,height)
	self.bgLayer:addChild(powerLabel,2)
	powerLabel:setColor(G_ColorGreen)

	local pointLabel=GetTTFLabel(getlocal("activity_wheelFortune_point"),22)
	pointLabel:setPosition(widthSpace+120*4,height)
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


    local function rewardHandler()
        local rank=acEquipSearchIIVoApi:rankCanReward()
        local function equipsearchRewardCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                local cfg=acEquipSearchIIVoApi:getEquipSearchCfg()
                local rewardCfg=cfg.r or {}

                local reward
                if rank==1 then
                    reward=FormatItem(rewardCfg[1]) or {}
                elseif rank==2 then
                    reward=FormatItem(rewardCfg[2]) or {}
                elseif rank==3 then
                    reward=FormatItem(rewardCfg[3]) or {}
                elseif rank==4 or rank==5 then
                    reward=FormatItem(rewardCfg[4]) or {}
                elseif rank>=6 and rank<=10 then
                    reward=FormatItem(rewardCfg[5]) or {}
                end
                if reward then
                    for k,v in pairs(reward) do
                        G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),nil,true)
                    end
                    G_showRewardTip(reward)
                end
                acEquipSearchIIVoApi:setListRewardNum()
                self:refresh()
            elseif sData.ret==-1975 or sData.ret==-1976 then
                local function getListCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                    if ret==true then
                        if self and self.bgLayer then
                            local rankList
                            if sData.data and sData.data.equipSearchII and sData.data.equipSearchII.rankList then
                                acEquipSearchIIVoApi:clearRankList()

                                rankList=sData.data.equipSearchII
                                acEquipSearchIIVoApi:updateData(rankList)
                                self:refresh()

                                -- acEquipSearchVoApi:setLastListTime(base.serverTime)
                                -- acEquipSearchVoApi:setFlag(2,1)
                            end
                        end
                    end
                end
                socketHelper:activeEquipsearchII(2,getListCallback)
            end
        end
        if rank>0 then
            socketHelper:activeEquipsearchII(3,equipsearchRewardCallback,nil,rank)
        end
    end
    self.rewardBtn = GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",rewardHandler,nil,getlocal("newGiftsReward"),25,11)
    self.rewardBtn:setAnchorPoint(ccp(0.5,0))
    local rewardMenu=CCMenu:createWithItem(self.rewardBtn)
    rewardMenu:setPosition(ccp(backBg:getContentSize().width/2,15))
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    backBg:addChild(rewardMenu,2)
    self.rewardBtn:setEnabled(false)
    if acEquipSearchIIVoApi:rankCanReward()>0 then
        self.rewardBtn:setEnabled(true)
    end
    local vo=acEquipSearchIIVoApi:getAcVo()
    if vo and vo.listRewardNum==0 then
        tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("newGiftsReward"))
    else
        tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
    end
	
    local function callBack(...)
    	return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,self.tvHeight-90),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,40+90))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(self.normalHeight)

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acKafukabaozangTab2:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local num=1
        local rankList=acEquipSearchIIVoApi:getRankList()
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

        local vo=acEquipSearchIIVoApi:getAcVo()
        local rankList=acEquipSearchIIVoApi:getRankList()
        local rData
        
        local rank
        local name
        local level
        local power
        local point
		
		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(20, 20, 10, 10);
		local function cellClick(hd,fn,idx)
		end

        if idx==0 then
        	rank=acEquipSearchIIVoApi:getSelfRank()
        	name=playerVoApi:getPlayerName()
			level=playerVoApi:getPlayerLevel()
			power=playerVoApi:getPlayerPower()
			point=vo.point or 0

			local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png")
			-- bgSp:setAnchorPoint(ccp(0,0.5))
			bgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.normalHeight/2-5));
			bgSp:setScaleY(self.normalHeight/bgSp:getContentSize().height)
			bgSp:setScaleX(1000/bgSp:getContentSize().width)
			cell:addChild(bgSp)
        else
            rData=rankList[idx] or {}
            rank=idx
            name=rData[1] or ""
            level=rData[2] or 0
            power=rData[3] or 0
            point=rData[4] or 0
		end
		
		local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
		lineSp:setAnchorPoint(ccp(0,1));
		lineSp:setPosition(ccp(0,self.normalHeight));
		cell:addChild(lineSp,1)

        local lbSize=25
        local lbHeight=35
        local lbWidth=50

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
        nameLb:setPosition(ccp(lbWidth+120,lbHeight))
        cell:addChild(nameLb)

        local levelLb=GetTTFLabel(level,lbSize)
        levelLb:setPosition(ccp(lbWidth+120*2+20,lbHeight))
        cell:addChild(levelLb)
        
        local powerLb=GetTTFLabel(power,lbSize)
        powerLb:setPosition(ccp(lbWidth+120*3+10,lbHeight))
        cell:addChild(powerLb)

        local pointLb=GetTTFLabel(point,lbSize)
        pointLb:setPosition(ccp(lbWidth+120*4,lbHeight))
        cell:addChild(pointLb)
        pointLb:setColor(G_ColorYellow)

    	return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function acKafukabaozangTab2:doUserHandler()
    local capInSet = CCRect(20, 20, 10, 10);
    local function bgClick(hd,fn,idx)
    end
    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
    titleBg:setContentSize(CCSizeMake(G_VisibleSize.width-60, 120))
    titleBg:setAnchorPoint(ccp(0,0));
    titleBg:setPosition(ccp(30,G_VisibleSize.height-85-80-120))
    self.bgLayer:addChild(titleBg,1)

    local vo=acEquipSearchIIVoApi:getAcVo()
    self.descLb=GetTTFLabel(getlocal("activity_wheelFortune_has_num",{vo.point}),25)
    self.descLb:setAnchorPoint(ccp(0,0.5));
    self.descLb:setPosition(ccp(15,titleBg:getContentSize().height/2+20));
    titleBg:addChild(self.descLb,2);
 	self.descLb:setColor(G_ColorGreen)

    local cfg=acEquipSearchIIVoApi:getEquipSearchCfg()
    self.descLb1=GetTTFLabelWrap(getlocal("activity_wheelFortune_rank_point",{cfg.rankPoint}),25,CCSizeMake(titleBg:getContentSize().width-125,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    self.descLb1:setAnchorPoint(ccp(0,0.5));
    self.descLb1:setPosition(ccp(15,titleBg:getContentSize().height/2-20));
    titleBg:addChild(self.descLb1,2);
    self.descLb1:setColor(G_ColorYellow)

    local function onClickDesc()
        local sd=smallDialog:new()
        local cfg=activityCfg.equipSearchII
        local rewardStrTab={}
        for k,v in pairs(cfg.r) do
            local award=FormatItem(v)
            local str=""
            for k,v in pairs(award) do
                if k==SizeOfTable(award) then
                    str = str .. v.name .. " x" .. v.num
                else
                    str = str .. v.name .. " x" .. v.num .. ","
                end
            end
            rewardStrTab[k]=str
        end

        local strTab={" ",getlocal("activity_equipSearch_rank_tip_4",{rewardStrTab[1],rewardStrTab[2],rewardStrTab[3],rewardStrTab[4],rewardStrTab[5]}),getlocal("activity_equipSearch_rank_tip_3"),getlocal("activity_equipSearch_rank_tip_2"),getlocal("activity_equipSearch_rank_tip_1")," "}
        local colorTab={}
        local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,strTab,25,colorTab)
        sceneGame:addChild(dialogLayer,self.layerNum+1)
        dialogLayer:setPosition(ccp(0,0))
    end
    local descBtnItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",onClickDesc)
    descBtnItem:setAnchorPoint(ccp(0,0.5))
    local descBtn=CCMenu:createWithItem(descBtnItem)
    descBtn:setAnchorPoint(ccp(0,0.5))
    descBtn:setPosition(ccp(titleBg:getContentSize().width-descBtnItem:getContentSize().width-30,titleBg:getContentSize().height/2))
    descBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    titleBg:addChild(descBtn,2)

end

function acKafukabaozangTab2:refresh()
    if self and self.bgLayer then
        local vo=acEquipSearchIIVoApi:getAcVo()
        if self.descLb then
            self.descLb:setString(getlocal("activity_wheelFortune_has_num",{vo.point}))
        end
        if self.tv then
            self.tv:reloadData()
        end
        if self.rewardBtn then
            if acEquipSearchIIVoApi:rankCanReward()>0 then
                self.rewardBtn:setEnabled(true)
            else
                self.rewardBtn:setEnabled(false)
            end
            if vo and vo.listRewardNum==0 then
                tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("newGiftsReward"))
            else
                tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
            end
        end
        
    end
end

function acKafukabaozangTab2:dispose()
    self.noFriendLabel = nil
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.selectedTabIndex=nil
    self.acEquipSearchDialog=nil

    self.descLb=nil
    self.descLb1=nil
    self.rewardBtn=nil

    self=nil
end






