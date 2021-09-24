acRechargeGameTab1={}

function acRechargeGameTab1:new( )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.layerNum=nil
	self.backSprie =nil
	self.tv =nil
	self.tvHeightSize=nil
	self.downBg =nil
	self.rankTb={}
	self.rewardRankTb={}
	self.upBgSubHeight = 0
	if G_isIphone5() then
		self.upBgSubHeight =20
	end
	return nc
end
function acRechargeGameTab1:dispose()
	self.bgLayer=nil
	self.layerNum=nil
	self.backSprie =nil
	self.tv =nil
	self.tvHeightSize=nil
	self.downBg =nil
	self.rankTb =nil
	self.upBgSubHeight = nil
end
function acRechargeGameTab1:init(layerNum )
	self.bgLayer = CCLayer:create()
	-- self.bgLayer:setBSwallowsTouches(true);
	self.layerNum = layerNum
	local rewardList = acRechargeGameVoApi:getRewardList()
	for k,v in pairs(rewardList) do
		table.insert(self.rewardRankTb,v[1])
	end

	local function cellClick(hd,fn,index)
    end
    local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
    backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-44, G_VisibleSizeHeight-185))
    backSprie:setAnchorPoint(ccp(0.5,0))
    backSprie:setOpacity(0)
    backSprie:setPosition(ccp(G_VisibleSizeWidth*0.5,25))
    self.bgLayer:addChild(backSprie)
    self.backSprie =backSprie

	self:initUpDia()
	self:initDownDia()

	return self.bgLayer
end

function acRechargeGameTab1:initUpDia( )
	
	local strSize2 = 22
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
		strSize2 =25
	end

	local bgWidht = self.backSprie:getContentSize().width
    local bgHeight = self.backSprie:getContentSize().height 

	local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),strSize2)
    acLabel:setAnchorPoint(ccp(1,1))
    acLabel:setPosition(ccp(self.backSprie:getContentSize().width*0.37-10,self.backSprie:getContentSize().height-5))
    acLabel:setColor(G_ColorYellow)
    self.backSprie:addChild(acLabel,2)

    local acVo = acRechargeGameVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt-86400)
    local messageLabel=GetTTFLabel(timeStr,strSize2)
    messageLabel:setAnchorPoint(ccp(0,1))
    messageLabel:setPosition(ccp(self.backSprie:getContentSize().width*0.37-5, self.backSprie:getContentSize().height-5))
    self.backSprie:addChild(messageLabel,2)

--领奖时间

    local acRewardLabel = GetTTFLabel(getlocal("recRewardTime"),strSize2)
    acRewardLabel:setAnchorPoint(ccp(1,1))
    acRewardLabel:setPosition(ccp(self.backSprie:getContentSize().width*0.37-10,self.backSprie:getContentSize().height-35))
    acRewardLabel:setColor(G_ColorYellow)
    self.backSprie:addChild(acRewardLabel,2)

    local endTime = acRechargeGameVoApi:getRewardTimeStr()
    local endTimeLabel=GetTTFLabel(endTime,strSize2)
    endTimeLabel:setAnchorPoint(ccp(0,1))
    endTimeLabel:setPosition(ccp(self.backSprie:getContentSize().width*0.37-5, self.backSprie:getContentSize().height-35))
    self.backSprie:addChild(endTimeLabel,2)

     local function touch33(tag,object)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        self:openInfo()
    end
    local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch33,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(self.backSprie:getContentSize().width-5,self.backSprie:getContentSize().height-5))
    self.backSprie:addChild(menuDesc,2)

    local headBg = CCSprite:createWithSpriteFrameName("rankItem.jpg")
    headBg:setPosition(ccp(2,bgHeight))
    headBg:setAnchorPoint(ccp(0,1))
    local headbgScaleX = (bgWidht-4)/headBg:getContentSize().width
    local headbgScaleY = (bgHeight*0.33-self.upBgSubHeight)/headBg:getContentSize().height
    headBg:setScaleX(headbgScaleX)
    headBg:setScaleY(headbgScaleY)
    self.backSprie:addChild(headBg,1)
    headBg:setTag(111)

    local headBgWidht = headBg:getContentSize().width
    local headBgHeight = headBg:getContentSize().height

    local function noData( )
    end 
    --拿到当前的排名名次的人名 顺序按 1，2，3
    local addHeightPos = 0
    if G_isIphone5() then
    	addHeightPos =5
    end
    local rankPosTb = {ccp(headBg:getContentSize().width*0.51,headBg:getContentSize().height*0.65+addHeightPos),ccp(headBg:getContentSize().width*0.25,headBg:getContentSize().height*0.45+addHeightPos),ccp(headBg:getContentSize().width*0.78,headBg:getContentSize().height*0.31+addHeightPos)}
    self.rankTb =G_clone(acRechargeGameVoApi:getRankList())
    if SizeOfTable(self.rankTb) ==0 then
    	self.rankTb ={{getlocal("activity_rechargeGame_rankEmpty")},{getlocal("activity_rechargeGame_rankEmpty")},{getlocal("activity_rechargeGame_rankEmpty")}}
    else
	    for i=1,3 do
	    	if self.rankTb[i] ==nil then
	    		table.insert(self.rankTb,{getlocal("activity_rechargeGame_rankEmpty")})
	    	end
	    end
	end

	for i=1,3 do
		local rankName = GetTTFLabel(self.rankTb[i][1],strSize2)
		local nameBlackGround = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(1, 1, 2, 2),noData)
	    nameBlackGround:setTouchPriority(-(self.layerNum-1)*20-2)
	    nameBlackGround:setScaleX(1/headbgScaleX)
	    nameBlackGround:setScaleY(1/headbgScaleY)
	    nameBlackGround:setOpacity(150)
	    nameBlackGround:setContentSize(CCSizeMake(rankName:getContentSize().width+6,rankName:getContentSize().height+4))
	    nameBlackGround:setAnchorPoint(ccp(0.5,0.5))
	    nameBlackGround:setPosition(rankPosTb[i])
	    headBg:addChild(nameBlackGround,1)
	    nameBlackGround:setTag(110+i)

	    rankName:setColor(G_ColorGreen)
	    rankName:setAnchorPoint(ccp(0.5,0.5))
	    rankName:setPosition(getCenterPoint(nameBlackGround))
	    nameBlackGround:addChild(rankName,1)
	    rankName:setTag(111)
	end
end

function acRechargeGameTab1:refData( )

	self.rankTb = G_clone(acRechargeGameVoApi:getRankList())
	local headBg = self.backSprie:getChildByTag(111)
	for i=1,3 do
		if self.rankTb[i] then
			local bg = headBg:getChildByTag(110+i)
			tolua.cast(bg:getChildByTag(111),"CCLabelTTF"):setString(self.rankTb[i][1])
		else
			local bg = headBg:getChildByTag(110+i)
			tolua.cast(bg:getChildByTag(111),"CCLabelTTF"):setString(getlocal("activity_rechargeGame_rankEmpty"))
		end
	end
end



function acRechargeGameTab1:initDownDia( )
	local strSize2 = 23
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
		strSize2 =25
	end
	local function noData(hd,fn,index)
    end
    local downBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),noData)
    downBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-44, G_VisibleSizeHeight-165-G_VisibleSizeHeight*0.3+self.upBgSubHeight))
    downBg:setAnchorPoint(ccp(0.5,0))
    downBg:setPosition(ccp(G_VisibleSizeWidth*0.5,30))
    self.bgLayer:addChild(downBg,1)
    self.downBg = downBg

    local desTv, desLabel = G_LabelTableView(CCSizeMake(downBg:getContentSize().width-20,90),getlocal("activity_rechargeGame_rewardDirStr"),strSize2,kCCTextAlignmentLeft)
    downBg:addChild(desTv,10)
    desTv:setPosition(ccp(10,downBg:getContentSize().height-95))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-10)
    desTv:setMaxDisToBottomOrTop(120)

    local desBgSp = CCSprite:createWithSpriteFrameName("orangeMask.png")
    local scaleH = 40/desBgSp:getContentSize().height
    local scaleW = 460/desBgSp:getContentSize().width
    desBgSp:setScaleY(40/desBgSp:getContentSize().height)
    desBgSp:setScaleX(460/desBgSp:getContentSize().width)
    desBgSp:setPosition(ccp(downBg:getContentSize().width*0.5,downBg:getContentSize().height-120))
    desBgSp:setAnchorPoint(ccp(0.5,0.5))
    downBg:addChild(desBgSp,2)

    local desBgSpStr = GetTTFLabel(getlocal("BossBattle_rankTitle"),strSize2)
    desBgSpStr:setAnchorPoint(ccp(0.5,0.5))
    desBgSpStr:setPosition(getCenterPoint(desBgSp))
    desBgSpStr:setColor(G_ColorYellow)
    desBgSpStr:setScaleX(1/scaleW)
    desBgSpStr:setScaleY(1/scaleH)
    desBgSp:addChild(desBgSpStr)

    self.tvHeightSize =desBgSp:getPositionY()-30
    self:initTableView()

    local aligLine = CCSprite:createWithSpriteFrameName("LineCross.png");
    aligLine:setAnchorPoint(ccp(0.5,0.5))
    aligLine:setScaleX(downBg:getContentSize().width/aligLine:getContentSize().width)
    aligLine:setPosition(ccp(downBg:getContentSize().width*0.5,self.tvHeightSize+4))
    downBg:addChild(aligLine,2)

    local vertLine = CCSprite:createWithSpriteFrameName("LineCross.png");
    vertLine:setAnchorPoint(ccp(0.5,0.5))
    vertLine:setScaleX((self.tvHeightSize-20)/vertLine:getContentSize().width)
    vertLine:setPosition(ccp(downBg:getContentSize().width*0.25+20,self.tvHeightSize*0.5))
    vertLine:setRotation(90)
    downBg:addChild(vertLine,2)

end

function acRechargeGameTab1:initTableView()
    local function callBack(...)
           return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-44 ,self.tvHeightSize),nil)
    self.downBg:addChild(self.tv,1)
    self.tv:setPosition(ccp(0,2))
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1) * 20 - 3)
    self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
    self.tv:setMaxDisToBottomOrTop(120)

    local function forbidClick()
       print("点击了啦啦啦啦啦~")
    end
    local rect2 = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(20, 20, 10, 10)
    local topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
    topforbidSp:setTouchPriority(-(self.layerNum-1)*20-5)
    topforbidSp:setAnchorPoint(ccp(0,0))
    topforbidSp:setIsSallow(true)
    topforbidSp:setOpacity(0)
    topforbidSp:setContentSize(CCSizeMake(self.downBg:getContentSize().width-20,300))
    topforbidSp:setPosition(10,self.downBg:getContentSize().height-140)
    self.downBg:addChild(topforbidSp,1)
end

function acRechargeGameTab1:eventHandler( handler,fn,idx,cel )
	local strSize2 = 22
	local nums = SizeOfTable(acRechargeGameVoApi:getRewardList()) --根据配置确定具体Size
	local cellHeight = 110
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
    	strSize2 =25
    end
   if fn=="numberOfCellsInTableView" then
       return 1 
   elseif fn=="tableCellSizeForIndex" then
       return  CCSizeMake(G_VisibleSizeWidth-44 ,nums*cellHeight)-- -100
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       local cellWidth = G_VisibleSizeWidth-44
       local cellAllHeight = nums*cellHeight
       local placeTb = self.rewardRankTb--取名次，取相应的奖励信息
       local placeRewardTb = {} --取相应的奖励信息
       for i=1,nums do
       		local place = nil
       		if i<4 then
       			place =CCSprite:createWithSpriteFrameName("top"..i..".png")
       		else
       			place =GetTTFLabel(getlocal("rankTwo",{placeTb[i][1],placeTb[i][2]}),strSize2)
       		end
       		place:setAnchorPoint(ccp(0.5,0.5))
       		place:setPosition(ccp(cellWidth*0.15,cellHeight*(nums-i+0.5)))
       		cell:addChild(place)

       		local rewardTb = acRechargeGameVoApi:getFortmatReward(i) --每一行的 奖励信息
       		for k,v in pairs(rewardTb) do
			    local icon,iconScale = G_getItemIcon(v,80,true,self.layerNum,nil,self.tv)
			    icon:setTouchPriority(-(self.layerNum-1)*20-2)
			    icon:setAnchorPoint(ccp(0.5,0.5))
			    icon:setPosition(cellWidth*0.38+(k-1)*90,cellHeight*(nums-i+0.5))
			    cell:addChild(icon)

			    local picNums = v.num
			    local picNumsStr = GetTTFLabel("x"..picNums,22)
                picNumsStr:setAnchorPoint(ccp(1,0))
                picNumsStr:setPosition(ccp(icon:getContentSize().width-6,3))
                icon:addChild(picNumsStr,1)

			    if v.border and v.border == 1 then
			      G_addRectFlicker(icon,1.1/iconScale,1.1/iconScale)
			    end
       		end

       		local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png");
            lineSP:setAnchorPoint(ccp(0.5,0.5))
            lineSP:setScaleX(cellWidth/lineSP:getContentSize().width)
            lineSP:setPosition(ccp(cellWidth*0.5,cellHeight*(nums-i)))
            cell:addChild(lineSP)
       end

       cell:autorelease()
       return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

function acRechargeGameTab1:openInfo( )
    -- print("in openInfo~~~~~")
    local rankLimit = acRechargeGameVoApi:getRanklimit()
    local rankMix = acRechargeGameVoApi:getRankMixValue()
    local strSize2 = 28
    if G_getCurChoseLanguage() =="ru" then
        strSize2 =24
    end
    local td=smallDialog:new()
    local tabStr = nil 
    tabStr ={"\n",getlocal("activity_rechargeGame_dec7"),"\n",getlocal("activity_rechargeGame_dec6"),"\n",getlocal("activity_rechargeGame_dec5"),"\n",getlocal("activity_rechargeGame_dec4",{rankMix,rankLimit}),"\n",getlocal("activity_rechargeGame_dec3"),"\n",getlocal("activity_rechargeGame_dec2"),"\n",getlocal("activity_rechargeGame_dec1"),"\n"}
    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,strSize2,{nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil})
    sceneGame:addChild(dialog,self.layerNum+1)
end












