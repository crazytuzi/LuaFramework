begingPurifyingDialog = commonDialog:new()

--doType 操作类型：1 配件精炼  2 军徽部队训练
function begingPurifyingDialog:new(parent,vo,position,tankId,callback,doType)
	local nc = {
        callback=callback,
        doType=doType,
    }
	setmetatable(nc, self)
	self.__index = self
	self.parent=parent
	self.itemVo=vo
	self.position=position
	self.tankId=tankId
	return nc
end	

function begingPurifyingDialog:resetTab()
    self.panelLineBg:setVisible(false)
	local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
	panelBg:setAnchorPoint(ccp(0.5,0))
	panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
	panelBg:setPosition(G_VisibleSizeWidth/2,5)
	self.bgLayer:addChild(panelBg)
end	

function begingPurifyingDialog:initTableView()
    self.titleH=32
    self.cellHeightTb={}
    if self.doType==nil then
        self.doType=1 --默认是配件精炼
    end
    self:initPurifyingShowCfg()
    self:initTypeLb()
    self:initLayer()
    self.tvWidth,self.tvHeight=self.bgLayer:getContentSize().width-40,G_VisibleSizeHeight-260
    if self.doType==2 then
        self.tvHeight=G_VisibleSizeHeight-280
    end
    local viewH=0
   	for i=1,4 do
   		viewH=viewH+self:getCellHeight(i)
   	end
    local viewBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    viewBg:setAnchorPoint(ccp(0.5,0))
    viewBg:setContentSize(CCSizeMake(self.tvWidth+10,self.tvHeight+10))
  	self.bgLayer:addChild(viewBg)
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition((G_VisibleSizeWidth-self.tvWidth)/2,G_VisibleSizeHeight-90-self.tvHeight)
    self.bgLayer:addChild(self.tv,2)
    -- print("viewH,self.tvHeight=====>>>",viewH,self.tvHeight)
   	if viewH>self.tvHeight then
   		self.tv:setMaxDisToBottomOrTop(120)
   	else
   		self.tv:setMaxDisToBottomOrTop(0)
   	end
    viewBg:setPosition(G_VisibleSizeWidth/2,self.tv:getPositionY()-5)

    if self.doType==2 then
        local usedTimes=emblemTroopVoApi:getTroopWashTimes(self.typeFlag)
        local maxTimes=emblemTroopVoApi:getTroopWashMaxTimes(self.typeFlag)
        if usedTimes and maxTimes then
            local lastTimes=0
            if maxTimes>usedTimes then
                lastTimes=maxTimes-usedTimes
            end
            self.timesLimit=GetTTFLabel("",20)
            self.timesLimit:setAnchorPoint(ccp(0.5,0.5))
            self.timesLimit:setPosition(ccp(self.bgLayer:getContentSize().width/2,160))
            self.bgLayer:addChild(self.timesLimit)
        end
        self:refreshTimesLimitShow()
    end

    self:initPurifyingConsumeView()
end

function begingPurifyingDialog:getCellHeight(idx)
    if self.cellHeightTb[idx]==nil then
        local height=self.titleH
        local add=0
        if idx==1 or idx==2 then
            add=65
            if G_isIphone5() then
                add=100
            end
        elseif idx==3 then
            local perH=65
            if G_isIphone5() then
                perH=70
            end
            add=10+(#self.typeTb)*perH
        end
        height=height+add
        self.cellHeightTb[idx]=height
    end
    return self.cellHeightTb[idx]
end

function begingPurifyingDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
            return 3
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.tvWidth,self:getCellHeight(idx+1))
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local cellHeight=self:getCellHeight(idx+1)
    	self:createTitle(cell,self.titleCfg[idx+1],0,cellHeight-self.titleH/2)

        if idx==0 then
            self:initPurifyingWayView(cell,idx)
        elseif idx==1 then
            self:initPurifyingTimesView(cell,idx)
        elseif idx==2 then
            self:initPurifyingConditionView(cell,idx)
        end

        return cell
    elseif fn=="ccTouchBegan" then
           self.isMoved=false
           return true
    elseif fn=="ccTouchMoved" then
           self.isMoved=true
    elseif fn=="ccTouchEnded"  then
    elseif fn=="ccScrollEnable" then
    end
end

function begingPurifyingDialog:initLayer()
	local function btnPurifyingCallback()
        local count,max=0,#self.typeTb
        for k,v in pairs(self.typeTb) do
        	if v==0 then
        		count=count+1
        	end
        end
        if count==max then
        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("purifying_select_tip"),30)
    	else
            if self.doType==2 then
                local usedTimes=emblemTroopVoApi:getTroopWashTimes(self.typeFlag)
                local maxTimes=emblemTroopVoApi:getTroopWashMaxTimes(self.typeFlag)
                if usedTimes+self.typeNumTb[self.numFlag]>maxTimes then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_troop_wash_limitMax"),30)
                    return
                end
            end
	    	local key,num = self:getConsumeKeyAndNum()
            local function onSureLogic()
            	if self.doType==1 then
            		local function callback(fn,data)
						local oldLevel = accessoryVoApi:getSuccinct_level()
			            local ret,sData = base:checkServerData(data)
			            if ret==true then 
			                if sData.data==nil then 
			                  return
			                end
			                if sData.data.accessory then
			                    accessoryVoApi:updateSuccinctData(sData.data.accessory)
			                    self:refresh()
			                end
			                if sData.data.report then
								require "luascript/script/game/scene/gamedialog/purifying/begingPurifyingDialog2"
								local td=begingPurifyingDialog2:new(self,sData.data.report,self.itemVo,self.typeNumTb[self.numFlag],self.typeFlag,self.typeTb,self.position,self.tankId,oldLevel)
								local tbArr={}
								local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("begin_purifying"),true,self.layerNum+1)
								sceneGame:addChild(dialog,self.layerNum+1)
			                end
			            end
			        end
	                socketHelper:accessoryPurifying(self.typeNumTb[self.numFlag],self.typeFlag,self.position,self.tankId,self.typeTb,callback)
	            elseif self.doType==2 then --军徽部队训练
	            	local function washRefresh(report)
			            if report then
			            	self:refresh()
	                        require "luascript/script/game/scene/gamedialog/purifying/begingPurifyingDialog2"
	                        local td=begingPurifyingDialog2:new(self,report,self.itemVo,self.typeNumTb[self.numFlag],self.typeFlag,self.typeTb,nil,nil,oldLevel,self.doType)
	                        local tbArr={}
	                        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("emblem_troop_washBegin"),true,self.layerNum+1)
	                        sceneGame:addChild(dialog,self.layerNum+1)
			            end
	            	end
	            	emblemTroopVoApi:troopWashAuto(self.itemVo.id,self.typeFlag,self.numFlag,self.typeTb,washRefresh)
            	end
            end
	        if key=="r4" then
	            local r4 = playerVoApi:getR4()
	            if num*self.typeNumTb[self.numFlag]>r4 then
	                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("resourcelimit"),30)
	                return
	            end
	        elseif key=="p8" then
                local shopProps = accessoryVoApi:getShopPropNum()
                if num*self.typeNumTb[self.numFlag]>shopProps.p8 then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("purifying_crystal_notenough"),30)
                    return
                end 
                local propNum = {shopProps.p8-num*self.typeNumTb[self.numFlag],shopProps.p9,shopProps.p10}
                accessoryVoApi:setShopPropNum(propNum)
	        elseif key=="p9" then
                local shopProps = accessoryVoApi:getShopPropNum()
                if num*self.typeNumTb[self.numFlag]>shopProps.p9 then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("purifying_crystal_notenough"),30)
                    return
                end 
	            local propNum = {shopProps.p8,shopProps.p9-num*self.typeNumTb[self.numFlag],shopProps.p10}
                accessoryVoApi:setShopPropNum(propNum) 
	        elseif key=="p10" then	            
                local shopProps = accessoryVoApi:getShopPropNum()
                if num*self.typeNumTb[self.numFlag]>shopProps.p10 then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("purifying_crystal_notenough"),30)
                    return
                end 
	            local propNum = {shopProps.p8,shopProps.p9,shopProps.p10-num*self.typeNumTb[self.numFlag]}
                accessoryVoApi:setShopPropNum(propNum)
	           
	        elseif key=="gems" then
	            if playerVoApi:getGems()<num*self.typeNumTb[self.numFlag] then
	                GemsNotEnoughDialog(nil,nil,num*self.typeNumTb[self.numFlag]-playerVoApi:getGems(),self.layerNum+1,num*self.typeNumTb[self.numFlag])
	                return
	            end
                local function secondTipFunc(sbFlag)
                    local sValue=base.serverTime .. "_" .. sbFlag
                    G_changePopFlag("begingPurifyingDialog",sValue)
                end
                if G_isPopBoard("begingPurifyingDialog") then
                    G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{num*self.typeNumTb[self.numFlag]}),true,onSureLogic,secondTipFunc)
                    do return end
                end
	        end
    		onSureLogic()
        end       
    end
    local btnScale,btnPosY,btnStr=0.8,60,""
    if self.doType==1 then
        btnStr=getlocal("begin_purifying")
    elseif self.doType==2 then
        btnStr=getlocal("emblem_troop_washBegin")
    end
    local purifyingItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",btnPurifyingCallback,nil,btnStr,25/btnScale)
    purifyingItem:setScale(btnScale)
    local purifyingMenu=CCMenu:createWithItem(purifyingItem)
    purifyingMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,btnPosY))
    purifyingMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(purifyingMenu)
end

function begingPurifyingDialog:initPurifyingShowCfg()
	self.typeTb,self.wayStrCfg,self.conditionTb,self.titleCfg,self.washNumCfg={},{},{},{},{}
	if self.doType==1 then
		self.typeTb={0,0,0,0,0}
		self.wayStrCfg={getlocal("purifying_common"),getlocal("purifying_expert"),getlocal("purifying_master")}
    	self.conditionTb={getlocal("purifying_accessary_up"),getlocal("purifying_attact_up"),getlocal("purifying_life_up"),getlocal("purifying_jipo_up"),getlocal("purifying_protect_up")}
    	self.titleCfg={getlocal("purifying_type"),getlocal("purifying_continuation"),getlocal("purifying_costStr"),getlocal("purifying_tip2")}
    	self.washNumCfg={10,20,50,100}
	elseif self.doType==2 then
		self.typeTb={1,0,0,0,0,0,0} --军徽部队训练是7个显示条件（默认勾选第一个条件）
		self.wayStrCfg={getlocal("emblem_troop_washType1"),getlocal("emblem_troop_washType2")}
    	self.conditionTb={getlocal("emblem_troop_washAuto_up"),getlocal("purifying_life_up"),getlocal("purifying_attact_up"),getlocal("accuracy_upgrade"),getlocal("sample_prop_name_428"),getlocal("sample_prop_name_429"),getlocal("sample_prop_name_430")}
    	self.titleCfg={getlocal("emblem_troop_washType"),getlocal("emblem_troop_washContinuation"),getlocal("emblem_troop_washConsume2"),getlocal("purifying_tip2")}
    	self.washNumCfg=emblemTroopVoApi:getTroopAutoWashTimes()
	end
end

function begingPurifyingDialog:createTitle(parent,titleStr,posX,posY,color)
    if parent==nil then
        do return end
    end
    local  titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function () end)
    titleBg:setAnchorPoint(ccp(0,0.5))
    titleBg:setPosition(posX,posY)
    titleBg:setContentSize(CCSizeMake(self.tvWidth,32))
    parent:addChild(titleBg)
    local titleLb=GetTTFLabelWrap(titleStr,22,CCSizeMake(titleBg:getContentSize().width-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    titleLb:setAnchorPoint(ccp(0,0.5))
    titleLb:setPosition(15,titleBg:getContentSize().height/2)
    titleBg:addChild(titleLb)
end

function begingPurifyingDialog:initPurifyingWayView(cell,idx)
    local cellWidth,cellHeight=self.tvWidth,self:getCellHeight(idx+1)
    local itemHeight=cellHeight-self.titleH
    self.waySpTb={}
    self.typeFlag=1
    local num=#self.wayStrCfg
    local space=20
    local wayNode=CCNode:create()
    wayNode:setAnchorPoint(ccp(0.5,0.5))
    cell:addChild(wayNode)
    local totalW,posX=0,0
    for i=1,num do
        local function selectHandler(hd,fn,tag)
            tag=tag/9
            local selectIdx=tag-10
            if selectIdx>self.wayNum and self.doType==1 then
                local tipStr=getlocal("unlock_str",{getlocal("purifying_engineer_levelStr"),getlocal("level_title",{self.wayUnlockCfg[i]})})
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,30)
                do return end
            end
            if self.typeFlag==selectIdx then
                do return end
            else
                if self.waySelectedSp then
                    self.waySelectedSp:initWithSpriteFrameName("LegionCheckBtnUn.png")
                end
                local selectedSp=tolua.cast(wayNode:getChildByTag(tag),"LuaCCSprite")
                selectedSp:initWithSpriteFrameName("LegionCheckBtn.png")
                self.typeFlag=selectIdx
                self.waySelectedSp=selectedSp
                self:refreshConsume()
                self:refreshTimesLimitShow()
            end
        end
        local function touch()
        end
        local selectSp
        local graySelectSp=GraySprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
        if self.typeFlag==i then
            selectSp=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtn.png",touch)
            self.waySelectedSp=selectSp
            graySelectSp:setVisible(false)
        else
            selectSp=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",touch)    
            if i>self.wayNum then
                graySelectSp:setVisible(true)
                selectSp:setVisible(false)
            else
                graySelectSp:setVisible(false)
                selectSp:setVisible(true)
            end
        end
        local tag=i+10
        selectSp:setTag(tag)
        wayNode:addChild(selectSp,2)
        wayNode:addChild(graySelectSp,2)

        local sizeWidth = 120
        if G_getCurChoseLanguage() == 'ar' then
            sizeWidth = 60
        end
        local wayStr=self.wayStrCfg[i] or ""
        local wayLb=GetTTFLabelWrap(wayStr,25,CCSizeMake(sizeWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        wayLb:setAnchorPoint(ccp(0,0.5))
        wayNode:addChild(wayLb,2)
        if i>self.wayNum then
            wayLb:setColor(G_ColorGray)
        end
        local tempLb=GetTTFLabel(wayStr,25)
        local realW=wayLb:getContentSize().width
        if realW>tempLb:getContentSize().width then
            realW=tempLb:getContentSize().width
        end
        realW=realW+selectSp:getContentSize().width+10
        selectSp:setPosition(posX+selectSp:getContentSize().width/2,wayNode:getContentSize().height/2)
        graySelectSp:setPosition(selectSp:getPosition())
        local addW=0
        if G_getCurChoseLanguage()=="ar" then
            addW=-15
        end
        wayLb:setPosition(selectSp:getPositionX()+selectSp:getContentSize().width/2+10+addW,selectSp:getPositionY())

        local x,y=selectSp:getPosition()
        self:addTouchBg(wayNode,ccp(x,y),selectHandler,tag*9)

        self.waySpTb[i]={selectSp,graySelectSp,wayLb}

    	if num==i then
        	totalW=totalW+realW+addW
        	posX=posX+realW+addW
        else
        	totalW=totalW+realW+addW+space
        	posX=posX+realW+addW+space
        end
    end
    wayNode:setPosition((cellWidth-totalW)/2,itemHeight/2)
end

function begingPurifyingDialog:initPurifyingTimesView(cell,idx)
    local cellWidth,cellHeight=self.tvWidth,self:getCellHeight(idx+1)
    local itemHeight=cellHeight-self.titleH
    self.timesSpTb={}
    self.numFlag=1
    local count=#self.typeNumTb
    local space=20
    local timesNode=CCNode:create()
    timesNode:setAnchorPoint(ccp(0.5,0.5))
    cell:addChild(timesNode)
    local totalW,posX=0,0
    for i=1,count do
        local function selectHandler(hd,fn,tag)
            tag=tag/99
            local selectIdx=tag-100
            local maxIdx=#self.typeNumTb
            if selectIdx>maxIdx and self.doType==1 then
                local tipStr=getlocal("unlock_str",{getlocal("purifying_engineer_levelStr"),getlocal("level_title",{self.numUnlockCfg[i]})})
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,30)
                do return end
            end
            if self.numFlag==selectIdx then
                do return end
            else
                if self.numSelectedSp then
                    self.numSelectedSp:initWithSpriteFrameName("LegionCheckBtnUn.png")
                end
                local selectedSp=tolua.cast(timesNode:getChildByTag(tag),"LuaCCSprite")
                selectedSp:initWithSpriteFrameName("LegionCheckBtn.png")
                self.numFlag=selectIdx
                self.numSelectedSp=selectedSp
                self:refreshConsume()
            end
        end
        local function touch()
        end
        local graySelectSp=GraySprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
        local selectSp
        if self.numFlag==i then
            selectSp=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtn.png",touch)
            self.numSelectedSp=selectSp
            graySelectSp:setVisible(false)
        else
            selectSp=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",touch)
            if i>count then
                graySelectSp:setVisible(true)
                selectSp:setVisible(false)
            else
                graySelectSp:setVisible(false)
                selectSp:setVisible(true)
            end
        end
        local tag=i+100
        selectSp:setTag(tag)
        timesNode:addChild(selectSp,2)
        timesNode:addChild(graySelectSp,2)
        local strSize = 25
        local size = 120
        if G_isAsia() == false then
            strSize = 18
            size = 60
        end
        local timesStr=getlocal("purifying_num",{self.washNumCfg[i]})
        local timesLb=GetTTFLabelWrap(timesStr,strSize,CCSizeMake(size,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        timesLb:setAnchorPoint(ccp(0,0.5))
        timesNode:addChild(timesLb,2)
        if i>count then
            timesLb:setColor(G_ColorGray)
        end

        local tempLb=GetTTFLabel(timesStr,25)
        local realW=timesLb:getContentSize().width
        if realW>tempLb:getContentSize().width then
            realW=tempLb:getContentSize().width
        end
        realW=realW+selectSp:getContentSize().width+10
        selectSp:setPosition(posX+selectSp:getContentSize().width/2,timesNode:getContentSize().height/2)
        graySelectSp:setPosition(selectSp:getPosition())
        local addW=0
        if G_getCurChoseLanguage()=="ar" then
            addW=-15
        end
        timesLb:setPosition(selectSp:getPositionX()+selectSp:getContentSize().width/2+10+addW,selectSp:getPositionY())
        local x,y=selectSp:getPosition()
        self:addTouchBg(timesNode,ccp(x,y),selectHandler,tag*99)

        self.timesSpTb[i]={selectSp,graySelectSp,timesLb}

        if count==i then
        	totalW=totalW+realW+addW
        	posX=posX+realW+addW
        else
        	totalW=totalW+realW+addW+space
        	posX=posX+realW+addW+space
        end
    end
    timesNode:setPosition((cellWidth-totalW)/2,itemHeight/2)
end

function begingPurifyingDialog:initPurifyingConsumeView()
    local tipStr=""
    if self.doType==1 then
        tipStr=getlocal("purifying_costStr")..":"
    elseif self.doType==2 then
        tipStr=getlocal("emblem_troop_washConsume2")..":"
    end
    local costTipLb=GetTTFLabel(tipStr,22)
    costTipLb:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(costTipLb)
    self.costTipLb=costTipLb
    local key,num=self:getConsumeKeyAndNum()
    local function nilTouch()
    end
    local consumeSp=LuaCCSprite:createWithSpriteFrameName("resourse_normal_uranium.png",nilTouch)
    consumeSp:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(consumeSp)
    self.consumeSp=consumeSp
    local numStr=FormatNumber(self.typeNumTb[1]*num)
    local numConsume=GetTTFLabel(numStr,22)
    numConsume:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(numConsume)
    self.numConsume=numConsume

    self:refreshConsume()
end

function begingPurifyingDialog:initPurifyingConditionView(cell,idx)
    local cellWidth,cellHeight=self.tvWidth,self:getCellHeight(idx+1)
    local itemHeight=cellHeight-self.titleH
    if self.doType==1 then
        self.typeTb={0,0,0,0,0}
    elseif self.doType==2 then
        self.typeTb={1,0,0,0,0,0,0} --默认勾选第一个条件
    end
    local perH=65
    if G_isIphone5() then
        perH=70
    end
    local function selectHandler(hd,fn,tag)
        tag=tag/999
        if self.typeTb[tag-1000]==0 then
            self.typeTb[tag-1000]=1
            local selectedSp=tolua.cast(cell:getChildByTag(tag),"LuaCCSprite")
            selectedSp:initWithSpriteFrameName("LegionCheckBtn.png")
            local lb=tolua.cast(selectedSp:getChildByTag(10),"CCLabelTTF")
            if lb then
                lb:setColor(G_ColorYellowPro)
            end
        else
            self.typeTb[tag-1000]=0
            local selectedSp=tolua.cast(cell:getChildByTag(tag),"LuaCCSprite")
            selectedSp:initWithSpriteFrameName("LegionCheckBtnUn.png")
            local lb=tolua.cast(selectedSp:getChildByTag(10),"CCLabelTTF")
            if lb then
                lb:setColor(G_ColorWhite)
            end
        end
    end
    local function touch()
    end
    local max=#self.conditionTb
    for k,v in pairs(self.conditionTb) do
        local checkPic="LegionCheckBtnUn.png"
        if self.typeTb[k]==1 then
            checkPic="LegionCheckBtn.png"
        end
        local selectSp=LuaCCSprite:createWithSpriteFrameName(checkPic,touch)
        local tag=k+1000
        selectSp:setTag(tag)
        selectSp:setPosition(cellWidth-90,cellHeight-self.titleH-(k-1)*perH-perH/2)
        cell:addChild(selectSp,2)
        local x,y=selectSp:getPosition()
        self:addTouchBg(cell,ccp(x,y),selectHandler,tag*999)

        local lb=GetTTFLabelWrap(v,25,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        lb:setAnchorPoint(ccp(0,0.5))
        lb:setTag(10)
        lb:setPosition(ccp(70,selectSp:getPositionY()))
        cell:addChild(lb,2)

        if k~=max then
	        local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(3,0,1,1),function ()end)
	        lineSp:setContentSize(CCSizeMake(cellWidth-60,2))
	        lineSp:setPosition(cellWidth/2,selectSp:getPositionY()-perH/2)
	        cell:addChild(lineSp)
        end
    end
end

function begingPurifyingDialog:addTouchBg(parent,pos,handler,tag,width,height)
    width=width or 100
    height=height or 100
    local rect=CCSizeMake(width,height)
    local touchBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),handler)
    touchBg:setTouchPriority(-(self.layerNum-1)*20-4)
    touchBg:setContentSize(rect)
    touchBg:setTag(tag)
    touchBg:setOpacity(0)
    touchBg:setPosition(pos)
    parent:addChild(touchBg,5)
end

function begingPurifyingDialog:getConsume()
	if self.doType==1 then
		local position = tonumber(string.sub(self.position,2))
	    local priceTb = succinctCfg.price[position]
	    local price = priceTb[self.typeFlag]
	    local award = FormatItem(price)
	    return award[1]
	elseif self.doType==2 then
		return emblemTroopVoApi:getTroopWashCost(self.typeFlag)
	end
   return nil
end

function begingPurifyingDialog:getConsumeKeyAndNum()
    local award = self:getConsume()
    if award==nil then
    	do return nil,0 end
    end
    local num=0
    if self.doType==1 then
    	local level = accessoryVoApi:getSuccinct_level()
	    if award.key=="r4" then
	        if level < succinctCfg.privilege_5 then
	            num=award.num
	        elseif level < succinctCfg.privilege_10 then
	            num=award.num*0.9
	        else
	            num=award.num*0.8
	        end
	    elseif award.key=="p8" then       
	        if level < succinctCfg.privilege_7 then
	            num=award.num
	        elseif level < succinctCfg.privilege_11 then
	            num=award.num*0.9
	        else
	            num=award.num*0.8
	        end
	    elseif award.key=="p9" then
	        if level < succinctCfg.privilege_7 then
	            num=award.num
	        elseif level < succinctCfg.privilege_11 then
	            num=award.num*0.9
	        else
	            num=award.num*0.8
	        end
	    elseif award.key=="p10" then       
	       if level < succinctCfg.privilege_7 then
	            num=award.num
	        elseif level < succinctCfg.privilege_11 then
	            num=award.num*0.9
	        else
	            num=award.num*0.8
	        end
	    elseif award.key=="gems" then
	       if level < succinctCfg.privilege_8 then
	            num=award.num
	        else
	            num=award.num*0.9
	        end
	    end
	elseif self.doType==2 then
		num=award.num
    end
    return award.key,num,award
end

function begingPurifyingDialog:initTypeLb()
	self.typeNumTb={}
	if self.doType==1 then
	    self.wayUnlockCfg={succinctCfg.privilege_1,succinctCfg.privilege_2,succinctCfg.privilege_4}
	    self.numUnlockCfg={succinctCfg.privilege_1,succinctCfg.privilege_3,succinctCfg.privilege_6,succinctCfg.privilege_9}

		local level = accessoryVoApi:getSuccinct_level()
	    self.wayNum=1
	    if level < succinctCfg.privilege_2 then
	        self.wayNum=1
	    elseif level < succinctCfg.privilege_4 then
	        self.wayNum=2
	    else
	        self.wayNum=3
	    end
		if level < succinctCfg.privilege_3 then
			self.typeNumTb[1]=10
		elseif level < succinctCfg.privilege_6 then
			self.typeNumTb[1]=10
			self.typeNumTb[2]=20
		elseif level < succinctCfg.privilege_9 then
			self.typeNumTb[1]=10
			self.typeNumTb[2]=20
			self.typeNumTb[3]=50
		else
			self.typeNumTb[1]=10
			self.typeNumTb[2]=20
			self.typeNumTb[3]=50
			self.typeNumTb[4]=100
		end
	elseif self.doType==2 then
		self.typeNumTb=emblemTroopVoApi:getTroopAutoWashTimes()
		self.wayNum=2
	end
end

function begingPurifyingDialog:refresh()
	self.parent:refresh()
	self.parent:refreshType()
    self:refreshConsume()
    self:refreshType()
    self:refreshTimesLimitShow()
end

function begingPurifyingDialog:refreshType()
    self:initTypeLb() --刷新一下当前可选择的精炼方式以及最大精炼次数
    for k,spTb in pairs(self.waySpTb) do
        local selectSp=spTb[1]
        local graySelectSp=spTb[2]
        local wayLb=spTb[3]
        if k>self.wayNum then --未解锁
            graySelectSp:setVisible(true)
            selectSp:setVisible(false)
            wayLb:setColor(G_ColorGray)
        else
            graySelectSp:setVisible(false)
            selectSp:setVisible(true)
            wayLb:setColor(G_ColorWhite)
        end
    end
    local count=#self.typeNumTb
    for k,spTb in pairs(self.timesSpTb) do
        local selectSp=spTb[1]
        local graySelectSp=spTb[2]
        local timesLb=spTb[3]
        if k>count then --未解锁
            graySelectSp:setVisible(true)
            selectSp:setVisible(false)
            timesLb:setColor(G_ColorGray)
        else
            graySelectSp:setVisible(false)
            selectSp:setVisible(true)
            timesLb:setColor(G_ColorWhite)
        end
    end
end

function begingPurifyingDialog:refreshConsume()
    local key,num,award = self:getConsumeKeyAndNum()
    local numStr = FormatNumber(self.typeNumTb[self.numFlag]*num)
    self.numConsume:setString(numStr)
    if self.doType==1 then
		if self.typeFlag==1 then
	        self.consumeSp:initWithSpriteFrameName("resourse_normal_uranium.png")
	        local r4 = playerVoApi:getR4()
	        if num*self.typeNumTb[self.numFlag]>r4 then
	            self.numConsume:setColor(G_ColorRed)
	        else
	            self.numConsume:setColor(G_ColorWhite)
	        end
	    elseif self.typeFlag==2 then
	        if key=="p8" then
	            self.consumeSp:initWithSpriteFrameName("accessoryP8.png")
	            local shopProps = accessoryVoApi:getShopPropNum()
	            if num*self.typeNumTb[self.numFlag]>shopProps.p8 then
	                self.numConsume:setColor(G_ColorRed)
	            else
	                self.numConsume:setColor(G_ColorWhite)
	            end
	        elseif key=="p9" then
	            self.consumeSp:initWithSpriteFrameName("accessoryP9.png")
	            local shopProps = accessoryVoApi:getShopPropNum()
	            if num*self.typeNumTb[self.numFlag]>shopProps.p9 then
	                self.numConsume:setColor(G_ColorRed)
	            else
	                self.numConsume:setColor(G_ColorWhite)
	            end
	        else
	            self.consumeSp:initWithSpriteFrameName("accessoryP10.png")
	            local shopProps = accessoryVoApi:getShopPropNum()
	            if num*self.typeNumTb[self.numFlag]>shopProps.p10 then
	                self.numConsume:setColor(G_ColorRed)
	            else
	                self.numConsume:setColor(G_ColorWhite)
	            end
	        end
	    else
	        self.consumeSp:initWithSpriteFrameName("resourse_normal_gem.png")
	         if playerVoApi:getGems()<num*self.typeNumTb[self.numFlag] then
	            self.numConsume:setColor(G_ColorRed)
	        else
	            self.numConsume:setColor(G_ColorYellow)
	        end 
	    end
	elseif self.doType==2 then
		if key=="gems" then
			self.consumeSp:initWithSpriteFrameName("IconGold.png")
			self.consumeSp:setScale(1)
			if playerVoApi:getGems()<num*self.typeNumTb[self.numFlag] then
	        	self.numConsume:setColor(G_ColorRed)
	        else
	            self.numConsume:setColor(G_ColorYellow)
	        end
	    else
            self.consumeSp:initWithSpriteFrameName(award.pic)
            local hadNum=bagVoApi:getItemNumId(award.id)
            if num*self.typeNumTb[self.numFlag]>hadNum then
                self.numConsume:setColor(G_ColorRed)
            else
                self.numConsume:setColor(G_ColorWhite)
            end
		end
    end
    
    local iconWidth,posY=60,120
    if self.doType==1 then
        posY=130
    end
    self.consumeSp:setAnchorPoint(ccp(0,0.5))
    if self.consumeSp:getContentSize().width>iconWidth then
        self.consumeSp:setScale(iconWidth/self.consumeSp:getContentSize().width)
    else
        self.consumeSp:setScale(1)
    end
    local costWidth=self.costTipLb:getContentSize().width+10+self.consumeSp:getContentSize().width*self.consumeSp:getScale()+self.numConsume:getContentSize().width
    self.costTipLb:setPosition((G_VisibleSizeWidth-costWidth)/2,posY)
    self.consumeSp:setPosition(self.costTipLb:getPositionX()+self.costTipLb:getContentSize().width+5,posY)
    self.numConsume:setPosition(self.consumeSp:getPositionX()+self.consumeSp:getContentSize().width*self.consumeSp:getScale()+5,posY)
end

function begingPurifyingDialog:refreshTimesLimitShow()
    if self.doType==2 then
        if self.timesLimit then --军徽部队训练次数刷新
            self.timesLimit:setVisible(true)
            local usedTimes=emblemTroopVoApi:getTroopWashTimes(self.typeFlag)
            local maxTimes=emblemTroopVoApi:getTroopWashMaxTimes(self.typeFlag)
            local lastTimes=0
            if maxTimes>usedTimes then
                lastTimes=maxTimes-usedTimes
            end
            if usedTimes and maxTimes then
                local str=getlocal("emblem_troop_washType"..self.typeFlag)
                self.timesLimit:setString(getlocal("emblem_troop_wash_limitCurrent",{str,lastTimes}))
            end
            if lastTimes==0 then
                self.timesLimit:setColor(G_ColorRed)
            else
                self.timesLimit:setColor(G_ColorWhite)
            end
        end
    end
end
function begingPurifyingDialog:dispose()
    self.parent=nil
    self.itemVo=nil
    self.position=nil
    self.tankId=nil
    self.consumeSp=nil
    self.numConsume=nil
    self.typeNumTb=nil
    self.typeStrTb=nil
    self.numLb=nil
    self.consumeLb=nil
    self.typeFlag=nil
    self.numFlag=nil
    self.waySelectedSp=nil
    self.numSelectedSp=nil
    self.waySpTb={}
    self.timesSpTb={}
    self.cellHeightTb=nil
    self.tvWidth=nil
    self.tvHeight=nil
    self.typeTb=nil
    self.washNumCfg=nil
    self.typeNumTb=nil
    self.titleCfg=nil
    self.conditionTb=nil
    self.wayStrCfg=nil
    self.doType=nil
    self.timesLimit=nil
end
