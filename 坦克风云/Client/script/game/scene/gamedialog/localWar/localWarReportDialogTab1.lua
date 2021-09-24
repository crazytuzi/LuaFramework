localWarReportDialogTab1={}

function localWarReportDialogTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.bgLayer=nil
	self.layerNum=nil
	self.cellHeight=200

	return nc
end

function localWarReportDialogTab1:init(layerNum,parent)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent
	self:initLayer()
	return self.bgLayer
end

function localWarReportDialogTab1:initLayer()
	local descLb=GetTTFLabelWrap(getlocal("local_war_report_max_num",{localWarCfg.reportMaxNum}),25,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0,0.5))
	descLb:setColor(G_ColorRed)
	descLb:setPosition(ccp(40,50))
	self.bgLayer:addChild(descLb,2)

	self:initTableView()
end

function localWarReportDialogTab1:initTableView()
	local function callBack(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-280),nil)
    self.bgLayer:addChild(self.tv)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition(ccp(30,90))
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setMaxDisToBottomOrTop(80)

    local list=localWarVoApi:getReportList(1)
    if list and SizeOfTable(list)>0 then
    else
        local noReportLb=GetTTFLabelWrap(getlocal("local_war_alliance_no_report"),30,CCSizeMake(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        noReportLb:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2)
        self.bgLayer:addChild(noReportLb,1)
        noReportLb:setColor(G_ColorYellowPro)
    end
end

function localWarReportDialogTab1:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local reportList=localWarVoApi:getReportList(1)
        return SizeOfTable(reportList)
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(G_VisibleSizeWidth-60,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        -- local hasMore=rankVoApi:hasMore(self.selectedTabIndex)
        -- local num=rankVoApi:getRankNum(self.selectedTabIndex)
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(40, 40, 10, 10);
        local capInSetNew=CCRect(20, 20, 10, 10)
        local backSprie
        -- if hasMore and idx==num then
        --     local function cellClick(hd,fn,idx)
        --         self:cellClick(idx)
        --     end
        --     backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSetNew,cellClick)
        --     backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.cellHeight))
        --     backSprie:ignoreAnchorPointForPosition(false)
        --     backSprie:setAnchorPoint(ccp(0,0))
        --     backSprie:setIsSallow(false)
        --     backSprie:setTouchPriority(-42)
        --     backSprie:setTag(idx)
        --     cell:addChild(backSprie,1)
            
        --     local moreLabel=GetTTFLabel(getlocal("showMore"),30)
        --     moreLabel:setPosition(getCenterPoint(backSprie))
        --     backSprie:addChild(moreLabel,2)
            
        --     do return cell end
        -- end
        
        local function cellClick1(hd,fn,idx)
        end
        backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSetNew,cellClick1)
        backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,self.cellHeight-5))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0,1))
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        backSprie:setPosition(ccp(0,self.cellHeight))
        cell:addChild(backSprie,1)
        
        local reportList=localWarVoApi:getReportList(1)
        local report=reportList[idx+1] or {}
        local id=report.id
        local buildType=report.buildType
        local buildName=getlocal("local_war_cityName_"..buildType)
        local timeStr=G_getDataTimeStr(report.time)
        local attackName=report.attackName
        local defenceName=report.defenceName
        local attackAName=report.attackAName
        local defenceAName=report.defenceAName
        -- local buffIndex=report.buffIndex
        -- local buffStr="buff效果"..buffIndex
        local isAttack=report.isAttack
        local isVictory=report.isVictory
        local isOccupied=report.isOccupied
        local reportType=0
        if isVictory==1 then
        	if isOccupied==1 then
    			reportType=2
    		else
    			reportType=1
    		end
        else
        	if isOccupied==1 then
    			reportType=4
    		else
    			reportType=3
    		end
        end

        local midHeight=backSprie:getContentSize().height/2
        local spPosX=70

        local bgHeight1 = 80
        local bulidHeight1 = midHeight+40
        local lbSize = 120
        if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
            bgHeight1 =45
            bulidHeight1 =midHeight+20
            lbSize =270
        end 

        local buildSp=CCSprite:createWithSpriteFrameName(localWarMapCfg.cityCfg[buildType].icon)
        buildSp:setScale(0.6)
        buildSp:setPosition(ccp(spPosX,bulidHeight1))
        backSprie:addChild(buildSp,1)

        local function click()
        end
        local textBg=LuaCCScale9Sprite:createWithSpriteFrameName("alien_mines_allybg.png",CCRect(15,8,153,28),click)
        textBg:setContentSize(CCSizeMake(120,bgHeight1))
        textBg:setPosition(ccp(spPosX,50))
        backSprie:addChild(textBg,2)
        -- local buildLb=GetTTFLabel(buildName,18)
        local buildLb =GetTTFLabelWrap(buildName,18,CCSizeMake(lbSize,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        buildLb:setPosition(getCenterPoint(textBg))
        textBg:addChild(buildLb)


        local lineSp=CCSprite:createWithSpriteFrameName("heroRecruitLine.png")
		lineSp:setAnchorPoint(ccp(1,0.5))
		lineSp:setScaleX(300/lineSp:getContentSize().width)
		lineSp:setScaleY(1)
		lineSp:setPosition(ccp(backSprie:getContentSize().width,backSprie:getContentSize().height-50))
		backSprie:addChild(lineSp,2)


		local timeLb=GetTTFLabel(timeStr,25)
		timeLb:setAnchorPoint(ccp(1,0.5))
        timeLb:setPosition(backSprie:getContentSize().width-10,backSprie:getContentSize().height-25)
        backSprie:addChild(timeLb,2)
        -- self.labelTab[idx].nameLabel=nameLabel
        
        local attAllName=attackName
        if attackAName and attackAName~="" then
            attAllName=getlocal("local_war_time",{attackAName,attackName})
        end
        local defAllName=defenceName
        if defenceAName and defenceAName~="" then
            defAllName=getlocal("local_war_time",{defenceAName,defenceName})
        end
        local selfName=""
        local targetAllName=""
        if isAttack==1 then
            selfName=attackName
            targetAllName=defAllName
        else
            selfName=defenceName
            targetAllName=attAllName
        end
        local rParams={}
        local color=G_ColorWhite
        if reportType==1 then
        	rParams={selfName,targetAllName}
        	color=G_ColorGreen
        elseif reportType==2 then
        	rParams={selfName,targetAllName}
        	color=G_ColorGreen
        elseif reportType==3 then
        	rParams={selfName,targetAllName}
        	color=G_ColorRed
        elseif reportType==4 then
        	rParams={targetAllName,selfName}
        	color=G_ColorRed
        end
        local reportDesc=getlocal("local_war_report_desc_"..reportType,rParams)
        local reportDescLb=GetTTFLabelWrap(reportDesc,20,CCSizeMake(270,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	    reportDescLb:setAnchorPoint(ccp(0,0.5))
		reportDescLb:setColor(color)
		reportDescLb:setPosition(ccp(150,midHeight+30))
		backSprie:addChild(reportDescLb,2)


		local function operateHandler(tag,object)
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
		        if G_checkClickEnable()==false then
		            do
		                return
		            end
		        end
		        PlayEffect(audioCfg.mouseClick)
				
                local function getBattleReportCallback(report)
                    local islandType
                    if localWarMapCfg and localWarMapCfg.cityCfg and localWarMapCfg.cityCfg[buildType] and localWarMapCfg.cityCfg[buildType].landType then
                        islandType=localWarMapCfg.cityCfg[buildType].landType
                    end
                    if report and SizeOfTable(report)>0 then
                        local data={data={report=report},isReport=true,battleType=1}
                        if islandType then
                            data.landform={islandType,islandType}
                        end
                        if tag==11 then
                            battleScene:initData(data)
                        elseif tag==12 then
                            local content=getlocal("local_war_report_chat_prefix",{buildName})..reportDesc
                            G_sendReportChat(self.layerNum,content,report,8,islandType)
                        end
                    end
                end
                localWarVoApi:getBattleReport(1,id,getBattleReportCallback)
			end
		end

		local scale=0.6
		local replayBtn=GetButtonItem("letterBtnPlay.png","letterBtnPlay_Down.png","letterBtnPlay_Down.png",operateHandler,11,nil,nil)
		replayBtn:setScale(scale)
		local replaySpriteMenu=CCMenu:createWithItem(replayBtn)
		replaySpriteMenu:setAnchorPoint(ccp(0.5,0.5))
		replaySpriteMenu:setTouchPriority(-(self.layerNum-1)*20-2)
		replaySpriteMenu:setPosition(ccp(backSprie:getContentSize().width-replayBtn:getContentSize().width/2*scale-10,35))
		backSprie:addChild(replaySpriteMenu,2)

		local sendBtn=GetButtonItem("letterBtnSend.png","letterBtnSend_Down.png","letterBtnSend_Down.png",operateHandler,12,nil,nil)
		sendBtn:setScaleX(scale)
		sendBtn:setScaleY(scale)
		local sendSpriteMenu=CCMenu:createWithItem(sendBtn)
		sendSpriteMenu:setAnchorPoint(ccp(0.5,0.5))
		sendSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-2)
		sendSpriteMenu:setPosition(ccp(backSprie:getContentSize().width-replayBtn:getContentSize().width*scale-sendBtn:getContentSize().width/2*scale-20,35))
		backSprie:addChild(sendSpriteMenu,2)
		
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function localWarReportDialogTab1:refresh()

end

function localWarReportDialogTab1:tick()
	
end

function localWarReportDialogTab1:dispose()
	self.bgLayer=nil
	self.layerNum=nil
	self.cellHeight=200
end
