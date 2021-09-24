playerRankDialog=commonDialog:new()

function playerRankDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.pageList={}
	self.layerList={}
	self.pageLayer=nil
	spriteController:addPlist("public/vipFinal.plist")
	return nc
end

function playerRankDialog:doUserHandler()
	self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40, G_VisibleSizeHeight-115))
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 20))
	self:initUp()
	self:initPage()
	self:initDown()
end

function playerRankDialog:initUp()
	local photoSp = GetBgIcon(playerVoApi:getRankIconName())
	photoSp:setScale(1/0.8)
	photoSp:setAnchorPoint(ccp(0,0.5))
	photoSp:setPosition(ccp(40,G_VisibleSizeHeight-160))
	self.bgLayer:addChild(photoSp)

	local playerNameLb=GetTTFLabel(playerVoApi:getPlayerName(),30)
	playerNameLb:setAnchorPoint(ccp(0,0.5))
	playerNameLb:setPosition(ccp(150,G_VisibleSizeHeight-130))
	self.bgLayer:addChild(playerNameLb)

	local rankNameLb = GetTTFLabel(playerVoApi:getRankName(),25)
	rankNameLb:setAnchorPoint(ccp(0,0.5))
	rankNameLb:setPosition(ccp(150,G_VisibleSizeHeight-180))
	self.bgLayer:addChild(rankNameLb)

	local labelSize = nil
	if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage() == "ru" then
		labelSize=22.5
	else
		labelSize=25
	end
	local function showInfo()
		PlayEffect(audioCfg.mouseClick)
		local td=smallDialog:new()
		local tabStr = {"\n",getlocal("military_rank_desc6"),"\n",getlocal("military_rank_desc5"),"\n",getlocal("military_rank_desc4"),"\n",getlocal("military_rank_desc3"),"\n",getlocal("military_rank_desc2"),"\n",getlocal("military_rank_desc1"),"\n"}
		if(base.rankPointLimit==1)then
			table.insert(tabStr,1,getlocal("military_rank_desc7"))
			table.insert(tabStr,1,"\n")
		end
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,labelSize)
		sceneGame:addChild(dialog,self.layerNum+1)
	end
	local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
	infoItem:setAnchorPoint(ccp(1,1))
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setAnchorPoint(ccp(1,1))
	infoBtn:setPosition(ccp(G_VisibleSizeWidth-35,G_VisibleSizeHeight-120))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(infoBtn,3)
end

function playerRankDialog:initPage()
	local rankTitleBg=LuaCCScale9Sprite:createWithSpriteFrameName("TeamTankNumBg.png",CCRect(20,20,10,10),function () end)
	rankTitleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,50))
	rankTitleBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-250))
	self.bgLayer:addChild(rankTitleBg)

	self.rankTitleLb=GetTTFLabel(playerVoApi:getRankName(),30)
	self.rankTitleLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-250))
	self.rankTitleLb:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(self.rankTitleLb,2)

	require "luascript/script/game/scene/gamedialog/playerDialog/playerRankDialogPage"
	local cfg=rankCfg.rank
	self.rankLength=#cfg
	self.pageHeight=0
	for i=1,self.rankLength do
		local rank=playerVoApi:getRank()-1+i
		if(rank>self.rankLength)then
			rank=rank-self.rankLength
		end
		local rankPage=playerRankDialogPage:new(rank)
		local layer=rankPage:init()
		local pageHeight=rankPage.height
		self.bgLayer:addChild(layer,1)
		-- layer:setPosition(ccp(30,G_VisibleSizeHeight-275-pageHeight))
		self.layerList[i]=layer
		self.pageList[i]=rankPage
		if pageHeight>self.pageHeight then
			self.pageHeight=pageHeight
		end
	end
	self.curPage=self.pageList[playerVoApi:getRank()]
	self.pageLayer=pageDialog:new()
	local page=1
	local isShowBg=false
	local isShowPageBtn=true
	local function onPage(topage)
		self.curPage=self.pageList[topage]

		local rank=playerVoApi:getRank()-1+topage
		if(rank>self.rankLength)then
			rank=rank-self.rankLength
		end
		self.rankTitleLb:setString(playerVoApi:getRankName(rank))
	end
	local posY=G_VisibleSizeHeight-275-self.pageHeight/2
	local leftBtnPos=ccp(40,posY)
	local rightBtnPos=ccp(G_VisibleSizeWidth-40,posY)
	self.pageLayer:create("panelItemBg.png",CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight),CCRect(20, 20, 10, 10),self.bgLayer,ccp(0,0),self.layerNum,page,self.layerList,isShowBg,isShowPageBtn,onPage,leftBtnPos,rightBtnPos)

	local maskSpHeight=self.bgLayer:getContentSize().height-133
	for k=1,2 do
		local leftMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
		leftMaskSp:setAnchorPoint(ccp(0,0))
		leftMaskSp:setPosition(0,38)
		leftMaskSp:setScaleY(maskSpHeight/leftMaskSp:getContentSize().height)
		self.bgLayer:addChild(leftMaskSp,6)

		local rightMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
		rightMaskSp:setFlipX(true)
		rightMaskSp:setAnchorPoint(ccp(0,0))
		rightMaskSp:setPosition(G_VisibleSizeWidth-rightMaskSp:getContentSize().width,38)
		rightMaskSp:setScaleY(maskSpHeight/rightMaskSp:getContentSize().height)
		self.bgLayer:addChild(rightMaskSp,6)
	end
end

function playerRankDialog:initDown()
	local needSubHeight = 0
	if G_getCurChoseLanguage() =="de" then
		needSubHeight =-10
	end
	local posY=G_VisibleSizeHeight-275-self.pageHeight-25
	local rankTitleBg=LuaCCScale9Sprite:createWithSpriteFrameName("TeamTankNumBg.png",CCRect(20,20,10,10),function () end)
	rankTitleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,50))
	rankTitleBg:setPosition(ccp(G_VisibleSizeWidth/2,posY))
	self.bgLayer:addChild(rankTitleBg)

	local rankRecordLb=GetTTFLabel(getlocal("military_rank_battlePointRecord"),30)
	rankRecordLb:setPosition(ccp(G_VisibleSizeWidth/2,posY))
	rankRecordLb:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(rankRecordLb,2)

	posY=posY-25-20-13
	if G_isIOS() == false then
		posY = posY + 25
	end
	local infoTb={}
	local cellHeight,tvWidth,tvHeight=0,G_VisibleSizeWidth,0
	local todayPointDesc=GetTTFLabel(getlocal("military_rank_battlePointToday"),25)
	todayPointDesc:setAnchorPoint(ccp(0,0.5))
	todayPointDesc:setPosition(ccp(80,posY))
	-- self.bgLayer:addChild(todayPointDesc)
    cellHeight=cellHeight+todayPointDesc:getContentSize().height+10
    local strSize=350
    if G_getCurChoseLanguage() == "ru" then
        strSize=520
    end

	local todayPoint=GetTTFLabel(playerVoApi:getTodayRankPoint(),25)
	todayPoint:setAnchorPoint(ccp(0,0.5))
	todayPoint:setColor(G_ColorGreen)
	todayPoint:setPosition(ccp(strSize,posY))
	-- self.bgLayer:addChild(todayPoint)
	table.insert(infoTb,{todayPointDesc,todayPoint})

	-- posY=posY-todayPoint:getContentSize().height-10
	local totalPointDesc=GetTTFLabel(getlocal("military_rank_battlePointTotal"),25)
	totalPointDesc:setAnchorPoint(ccp(0,0.5))
	totalPointDesc:setPosition(ccp(80,posY))
	-- self.bgLayer:addChild(totalPointDesc)
    cellHeight=cellHeight+totalPointDesc:getContentSize().height+10

	local totalPoint=GetTTFLabel(playerVoApi:getRankPoint()-playerVoApi:getTodayRankPoint(),25)
	totalPoint:setAnchorPoint(ccp(0,0.5))
	totalPoint:setColor(G_ColorGreen)
	totalPoint:setPosition(ccp(strSize,posY))
	-- self.bgLayer:addChild(totalPoint)
	table.insert(infoTb,{totalPointDesc,totalPoint})

	-- posY=posY-totalPoint:getContentSize().height-20
	if(base.rpShop==1)then
		local myRpCoinDesc=GetTTFLabelWrap(getlocal("rpshop_ownCoin"),25,CCSizeMake(220,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		myRpCoinDesc:setAnchorPoint(ccp(0,0.5))
		myRpCoinDesc:setPosition(ccp(80,posY+needSubHeight))
		-- self.bgLayer:addChild(myRpCoinDesc)
    	cellHeight=cellHeight+myRpCoinDesc:getContentSize().height
	
		local myRpCoin=GetTTFLabel(playerVoApi:getRpCoin(),25)
		myRpCoin:setAnchorPoint(ccp(0,0.5))
		myRpCoin:setColor(G_ColorGreen)
		myRpCoin:setPosition(ccp(strSize,posY))
		-- self.bgLayer:addChild(myRpCoin)
		table.insert(infoTb,{myRpCoinDesc,myRpCoin})
	end
	tvHeight=cellHeight
	if tvHeight>150 then
		tvHeight=150
	end
    local isMoved=false
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return 1
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(tvWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local posY=cellHeight
            for k,v in pairs(infoTb) do
                local promptLb=tolua.cast(v[1],"CCLabelTTF")
                local valueLb=tolua.cast(v[2],"CCLabelTTF")
                if promptLb and valueLb then
                	promptLb:setPosition(80,posY-promptLb:getContentSize().height/2)
                	valueLb:setPosition(strSize,promptLb:getPositionY())
                	cell:addChild(promptLb)
                	cell:addChild(valueLb)
                	local subHeight = 5
                	if G_isIOS() then
                		subHeight = 10
                	end
                	posY=posY-promptLb:getContentSize().height-subHeight
                end
            end
            
            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
	local hd=LuaEventHandler:createHandler(tvCallBack)
	self.infotv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
	self.infotv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.infotv:setPosition(ccp(0,posY-tvHeight))
	self.bgLayer:addChild(self.infotv)
	if cellHeight>tvHeight then
		self.infotv:setMaxDisToBottomOrTop(120)
	else
		self.infotv:setMaxDisToBottomOrTop(0)
	end
end

function playerRankDialog:dispose()
    spriteController:removePlist("public/vipFinal.plist")
end