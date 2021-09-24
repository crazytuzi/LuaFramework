rewardShowSmallDialog=smallDialog:new()

function rewardShowSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function rewardShowSmallDialog:showNewReward(layerNum,istouch,isuseami,rewardItem,callBack,titleStr,titleStr2,addStrTb,addStrTb2,specicalMark,subTitleColor)
	local sd=rewardShowSmallDialog:new()
    sd:initNewReward(layerNum,istouch,isuseami,rewardItem,callBack,titleStr,titleStr2,addStrTb,addStrTb2,specicalMark,subTitleColor)
    return sd
end

function rewardShowSmallDialog:initNewReward(layerNum,istouch,isuseami,rewardItem,pCallBack,titleStr,titleStr2,addStrTb,addStrTb2,specicalMark,subTitleColor)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    self.rewardItem = rewardItem
    self.addStrTb2 = addStrTb2
    self.addStrTb = addStrTb
   
    base:removeFromNeedRefresh(self) --停止刷新

    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

     local function touchLuaSpr()
         if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if pCallBack then
        	pCallBack()
        end
        return self:close()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    -- touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local rewardNum=SizeOfTable(rewardItem)
    self.rewardNum = rewardNum
    local heightNum=math.ceil(rewardNum/3)
    self.heightNum = heightNum
    useheightNum = heightNum > 4 and 4 or heightNum
    self.useheightNum = useheightNum
    local everyCellH=180
    local isAddStr=false
    if addStrTb and SizeOfTable(addStrTb)>0 then
        isAddStr=true
        if SizeOfTable(addStrTb)>9 then
            everyCellH=180
        else
            everyCellH=200
        end
    end
    local isAddStr2=false
    if addStrTb2 and SizeOfTable(addStrTb2)>0 then
        isAddStr2=true
        everyCellH=220
    end
    local jianGeH=30
    local bgSize=CCSizeMake(560,jianGeH*2)
    local lb2H=30
    if titleStr2 then
    	bgSize.height=bgSize.height+lb2H
    end
    bgSize.height=bgSize.height+useheightNum*everyCellH
    local startH=bgSize.height-jianGeH

    self.everyCellH = everyCellH
    self.startH = startH

    -- rewardItem
    local function touchHandler()
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30, 30, 1, 1),touchHandler)
    self.bgLayer=dialogBg
    self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)
    self.bgLayer:setContentSize(bgSize)
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

    local lineSp1=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
    lineSp1:setAnchorPoint(ccp(0.5,1))
    lineSp1:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height))
    self.bgLayer:addChild(lineSp1)
    local lineSp2=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
    lineSp2:setAnchorPoint(ccp(0.5,0))
    lineSp2:setPosition(ccp(self.bgLayer:getContentSize().width/2,lineSp2:getContentSize().height))
    self.bgLayer:addChild(lineSp2)
    lineSp2:setRotation(180)

    -- local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
    -- pointSp1:setPosition(ccp(5,self.bgLayer:getContentSize().height/2))
    -- self.bgLayer:addChild(pointSp1)
    -- local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
    -- pointSp2:setPosition(ccp(self.bgLayer:getContentSize().width-5,self.bgLayer:getContentSize().height/2))
    -- self.bgLayer:addChild(pointSp2)

    -- 标题
    local titlePos=self.bgLayer:getContentSize().height+40
    local titleLb = GetTTFLabel(titleStr,35)
    titleLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,titlePos+20))
    self.bgLayer:addChild(titleLb,1)
    titleLb:setColor(G_ColorYellow)
    local tmpBg=CCSprite:createWithSpriteFrameName("rewardPanelSuccessBg.png")
    local originalWidth=tmpBg:getContentSize().width
    local titleBgWidth=titleLb:getContentSize().width+260
    if titleBgWidth<originalWidth then
        titleBgWidth=originalWidth
    end
    if titleBgWidth>(G_VisibleSizeWidth) then
        titleBgWidth=G_VisibleSizeWidth
    end

	local rewardTitleBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelSuccessBg.png",CCRect(originalWidth/2, 20, 1, 1),function ()end)
	rewardTitleBg:setContentSize(CCSizeMake(titleBgWidth,tmpBg:getContentSize().height))
	rewardTitleBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,titlePos))
	self.bgLayer:addChild(rewardTitleBg)
	local rewardTitleLineSp=CCSprite:createWithSpriteFrameName("rewardPanelSuccessLight.png")
	rewardTitleLineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,titlePos))
	self.bgLayer:addChild(rewardTitleLineSp)

	if titleStr2 then
        local titleLb2,richHeight = nil,0
        if specicalMark =="qmcj" then
            colorTb={G_ColorYellowPro,G_ColorRed,G_ColorYellowPro,G_ColorRed,G_ColorYellowPro,G_ColorRed,G_ColorYellowPro}
            titleLb2,richHeight = G_getRichTextLabel(titleStr2,colorTb,24,bgSize.width - 40,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        else
    		titleLb2 = GetTTFLabel(titleStr2,25)
            if subTitleColor then
                titleLb2:setColor(subTitleColor)
            else
                titleLb2:setColor(G_ColorYellowPro)
            end
        end
	    titleLb2:setPosition(ccp(self.bgLayer:getContentSize().width/2,startH-lb2H/4 + richHeight*0.5))
	    self.bgLayer:addChild(titleLb2,1)
	    
        if specicalMark =="qmcj" then
            if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
            else
                titleLb2:setPositionY(titleLb2:getPositionY() + 5)
            end
        end

	    startH=startH-lb2H
        local newLineSp = LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(27,3,1,1),function ()end)
        newLineSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,newLineSp:getContentSize().height))
        newLineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,startH))
        self.bgLayer:addChild(newLineSp)
    end

	local nameH=20
    if isAddStr==true then
        nameH=30
    end
    self.nameH = nameH

    if rewardNum > 12 then
        local cellWidth = self.bgLayer:getContentSize().width - 4
        local cellHeight = 180 * self.heightNum--self.useheightNum
        self.cellWidth,self.cellHeight = cellWidth,cellHeight
        local function callBack(handler,fn,idx,cel)
            -- return self:eventHandler(...)
            if fn=="numberOfCellsInTableView" then
                return 1
            elseif fn=="tableCellSizeForIndex" then
                local tmpSize=CCSizeMake(cellWidth,cellHeight)
                return tmpSize
            elseif fn=="tableCellAtIndex" then
                local cell=CCTableViewCell:new()
                cell:autorelease()
                -- print("in cell???????????")
                self:IneventHandler(cell)
                return cell
            end
        end
        local hd= LuaEventHandler:createHandler(callBack)
        local tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(bgSize.width -4,bgSize.height -4 - 60),nil)
        tv:setAnchorPoint(ccp(0,0))
        tv:setPosition(ccp(4,4))
        tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
        tv:setMaxDisToBottomOrTop(220)
        self.bgLayer:addChild(tv,1)

    else

            local function addContent(parent,num,iconPos)
                local strSize2 = 17
                if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
                    strSize2 = 22
                end
                local function showNewPropInfo()
                    if rewardItem[num].type == "at" and rewardItem[num].eType == "a" then --AI部队
                        local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(rewardItem[num].key, true)
                        AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, layerNum + 1)
                    else
                        G_showNewPropInfo(layerNum+1,true,true,nil,rewardItem[num],nil,nil,nil,nil,true)
                        return false
                    end
                end
                local icon
                if rewardItem[num].type == "se" then
                    icon=G_getItemIcon(rewardItem[num],100,true,layerNum,nil,nil,nil,nil,nil,nil,true)
                else
                    icon=G_getItemIcon(rewardItem[num],100,false,layerNum,showNewPropInfo,nil)
                end
                if rewardItem[num].type == "ac" and rewardItem[num].eType == "o" then --周年狂欢数字卡适配
                    icon:setScale(84/icon:getContentSize().height)
                end
                icon:setTouchPriority(-(layerNum-1)*20-3)
                parent:addChild(icon)
                icon:setPosition(iconPos)
                if addStrTb2 and addStrTb2[num] then
                    local addStr=addStrTb2[num][1] or ""
                    local color=addStrTb2[num][2] or G_ColorWhite
                    local addStrLb=GetTTFLabelWrap(addStr,strSize2,CCSizeMake(160,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
                    addStrLb:setAnchorPoint(ccp(0.5,0))
                    addStrLb:setColor(color)
                    local posX=icon:getPositionX()
                    addStrLb:setPosition(posX,icon:getPositionY()+50+2)
                    parent:addChild(addStrLb)
                end

                local nameStr=rewardItem[num].name
                if addStrTb and addStrTb[num] and addStrTb[num]~="" then
                    nameStr=rewardItem[num].name.."\n"..addStrTb[num]
                end
                local nameLb=GetTTFLabelWrap(nameStr,strSize2,CCSizeMake(160,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                nameLb:setAnchorPoint(ccp(0.5,1))
                local posX=icon:getPositionX()
                nameLb:setPosition(posX,icon:getPositionY()-50-2)
                parent:addChild(nameLb)

                local numLb=GetTTFLabel(FormatNumber(rewardItem[num].num),strSize2+2)
                numLb:setAnchorPoint(ccp(1,0))
                numLb:setPosition(ccp(icon:getContentSize().width-5,5))
                icon:addChild(numLb,4)
                local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
                numBg:setAnchorPoint(ccp(1,0))
                numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
                numBg:setPosition(ccp(icon:getContentSize().width-5,5))
                numBg:setOpacity(150)
                icon:addChild(numBg,3) 

                if rewardItem[num].type == "o" then
                    numLb:setScale(1/icon:getScale())
                    numBg:setScale(1/icon:getScale())

                    if specicalMark == "wpbd" then--其他功能或活动需要加坦克icon外边框，需要加载相应的plist文件！！！！
                        local borderColorTb = {["5.5"]="greenBorder.png",["6.5"]="blueBorder.png",["7.5"]="purpleBorder.png"}
                        local tankItem = rewardItem[num]
                        local pic = borderColorTb[tostring(tankCfg[tankItem.id].tankLevel)]
                        local borderSp = CCSprite:createWithSpriteFrameName(pic)
                        borderSp:setPosition(getCenterPoint(icon))
                        icon:addChild(borderSp)
                    end
                end

                local _index = tostring(rewardItem[num].index)
                if specicalMark =="haloween2" then
                    acHalloween2018VoApi:specicalMarkShow(icon,rewardItem[num].key)
                elseif specicalMark =="jsss" then
                    acJsysVoApi:specicalMarkShow(icon,rewardItem[num].key)
                elseif type(specicalMark)=="table" and type(specicalMark[_index])=="string" then
                    G_addRectFlicker2(icon,1.15,1.15,tonumber(_index),specicalMark[_index],nil,55)
                end
            end
        	local function addSubChild(parent,row)
        		local centerX=parent:getContentSize().width/2
        		local centerY=parent:getContentSize().height/2
        		for i=1,3 do
        			local num=(row-1)*3+i
                    local iconPos
        	        if i==1 then
                        iconPos=ccp(centerX-160,centerY+nameH)
        	        elseif i==2 then
                        iconPos=ccp(centerX,centerY+nameH)
        	        else
                        iconPos=ccp(centerX+160,centerY+nameH)
        	        end

                    addContent(parent,num,iconPos)
        		end
        	end

            local bigBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
            bigBg2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,everyCellH*heightNum))
            bigBg2:setAnchorPoint(ccp(0.5,1))
            bigBg2:setPosition(self.bgLayer:getContentSize().width/2,startH)
            self.bgLayer:addChild(bigBg2)
            -- bigBg2:setOpacity(0)


        	for i=1,heightNum do
        		local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
        		dialogBg2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,everyCellH-5))
        		dialogBg2:setAnchorPoint(ccp(0.5,1))
        		dialogBg2:setPosition(self.bgLayer:getContentSize().width/2,startH-(i-1)*everyCellH-5)
        		self.bgLayer:addChild(dialogBg2)
                dialogBg2:setOpacity(0)
        		if i==heightNum then
        			if rewardNum%3==0 then
        				addSubChild(dialogBg2,i)
        			elseif rewardNum%3==1 then
        				local num=(i-1)*3+1

                        local iconPos=ccp(dialogBg2:getContentSize().width/2,dialogBg2:getContentSize().height/2+nameH)
                        addContent(dialogBg2,num,iconPos)
        			else
        				local centerX=dialogBg2:getContentSize().width/2
        				local centerY=dialogBg2:getContentSize().height/2
        				for j=1,2 do
        					local num=(i-1)*3+j

                            local iconPos
        			        if j==1 then
                                iconPos=ccp(centerX-85,centerY+nameH)
        			        else
                                iconPos=ccp(centerX+85,centerY+nameH)
        			        end

                            addContent(dialogBg2,num,iconPos)
        				end

        			end
        		else
        			addSubChild(dialogBg2,i)
        		end
        	end
    end
	-- 下面的点击屏幕继续
	local clickLbPosy=-80
    if rewardNum > 9 then
        clickLbPosy = -40
    end
    local tmpLb=GetTTFLabel(getlocal("click_screen_continue"),25)
    local clickLb=GetTTFLabelWrap(getlocal("click_screen_continue"),25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    clickLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,clickLbPosy))
    self.bgLayer:addChild(clickLb)
    local arrowPosx1,arrowPosx2
    local realWidth,maxWidth=tmpLb:getContentSize().width,clickLb:getContentSize().width
    if realWidth>maxWidth then
        arrowPosx1=self.bgLayer:getContentSize().width/2-maxWidth/2
        arrowPosx2=self.bgLayer:getContentSize().width/2+maxWidth/2
    else
        arrowPosx1=self.bgLayer:getContentSize().width/2-realWidth/2
        arrowPosx2=self.bgLayer:getContentSize().width/2+realWidth/2
    end
    local smallArrowSp1=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp1:setPosition(ccp(arrowPosx1-15,clickLbPosy))
    self.bgLayer:addChild(smallArrowSp1)
    local smallArrowSp2=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp2:setPosition(ccp(arrowPosx1-25,clickLbPosy))
    self.bgLayer:addChild(smallArrowSp2)
    smallArrowSp2:setOpacity(100)
    local smallArrowSp3=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp3:setPosition(ccp(arrowPosx2+15,clickLbPosy))
    self.bgLayer:addChild(smallArrowSp3)
    smallArrowSp3:setRotation(180)
    local smallArrowSp4=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp4:setPosition(ccp(arrowPosx2+25,clickLbPosy))
    self.bgLayer:addChild(smallArrowSp4)
    smallArrowSp4:setOpacity(100)
    smallArrowSp4:setRotation(180)

    local space=20
    smallArrowSp1:runAction(G_actionArrow(1,space))
    smallArrowSp2:runAction(G_actionArrow(1,space))
    smallArrowSp3:runAction(G_actionArrow(-1,space))
    smallArrowSp4:runAction(G_actionArrow(-1,space))


    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer

end

function rewardShowSmallDialog:IneventHandler(cell)
        local nameH,rewardItem,addStrTb2,everyCellH = self.nameH,self.rewardItem,self.addStrTb2,self.everyCellH
        local heightNum,startH,rewardNum,layerNum = self.heightNum,self.startH,self.rewardNum,self.layerNum
            local function addContent(parent,num,iconPos)
                local strSize2 = 18
                if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
                    strSize2 = 22
                end
                local function showNewPropInfo()
                    if rewardItem[num].type == "at" and rewardItem[num].eType == "a" then --AI部队
                        local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(rewardItem[num].key, true)
                        AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, layerNum + 1)
                    else
                        G_showNewPropInfo(layerNum+1,true,true,nil,rewardItem[num])
                        return false
                    end
                end
                local icon=G_getItemIcon(rewardItem[num],100,true,self.layerNum,showNewPropInfo)
                icon:setTouchPriority(-(layerNum-1)*20-3)
                parent:addChild(icon)
                icon:setPosition(iconPos)
                if rewardItem[num].type == "ac" and rewardItem[num].eType == "o" then --周年狂欢数字卡适配
                    icon:setScale(84/icon:getContentSize().height)
                end
                if addStrTb2 and addStrTb2[num] then
                    local addStr=addStrTb2[num][1] or ""
                    local color=addStrTb2[num][2] or G_ColorWhite
                    local addStrLb=GetTTFLabelWrap(addStr,strSize2,CCSizeMake(160,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
                    addStrLb:setAnchorPoint(ccp(0.5,0))
                    addStrLb:setColor(color)
                    local posX=icon:getPositionX()
                    addStrLb:setPosition(posX,icon:getPositionY()+50+2)
                    parent:addChild(addStrLb)
                end

                local nameStr=rewardItem[num].name
                if addStrTb and addStrTb[num] and addStrTb[num]~="" then
                    nameStr=rewardItem[num].name.."\n"..addStrTb[num]
                end
                local nameLb=GetTTFLabelWrap(nameStr,strSize2,CCSizeMake(160,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                nameLb:setAnchorPoint(ccp(0.5,1))
                local posX=icon:getPositionX()
                nameLb:setPosition(posX,icon:getPositionY()-50-2)
                parent:addChild(nameLb)

                local numLb=GetTTFLabel(FormatNumber(rewardItem[num].num),strSize2+2)
                numLb:setAnchorPoint(ccp(1,0))
                numLb:setPosition(ccp(icon:getContentSize().width-5,5))
                icon:addChild(numLb,4)
                local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
                numBg:setAnchorPoint(ccp(1,0))
                numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
                numBg:setPosition(ccp(icon:getContentSize().width-5,5))
                numBg:setOpacity(150)
                icon:addChild(numBg,3) 

                local _index = tostring(rewardItem[num].index)
                if specicalMark =="haloween2" then
                    acHalloween2018VoApi:specicalMarkShow(icon,rewardItem[num].key)
                elseif specicalMark =="jsss" then
                    acJsysVoApi:specicalMarkShow(icon,rewardItem[num].key)
                elseif type(specicalMark)=="table" and type(specicalMark[_index])=="string" then
                    G_addRectFlicker2(icon,1.15,1.15,tonumber(_index),specicalMark[_index],nil,55)
                end
            end
            local function addSubChild(parent,row)
                local centerX=parent:getContentSize().width/2
                local centerY=parent:getContentSize().height/2
                for i=1,3 do
                    local num=(row-1)*3+i

                    local iconPos
                    if i==1 then
                        iconPos=ccp(centerX-160,centerY+nameH)
                    elseif i==2 then
                        iconPos=ccp(centerX,centerY+nameH)
                    else
                        iconPos=ccp(centerX+160,centerY+nameH)
                    end
                    addContent(parent,num,iconPos)
                end
            end

            local bigBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
            bigBg2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,everyCellH*heightNum))
            bigBg2:setAnchorPoint(ccp(0.5,1))
            bigBg2:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.cellHeight))
            cell:addChild(bigBg2)

            for i=1,heightNum do
                -- print("everyCellH====>>>>",everyCellH)
                local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
                dialogBg2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,everyCellH-5))
                dialogBg2:setAnchorPoint(ccp(0.5,1))
                dialogBg2:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.cellHeight-(i-1)*(everyCellH - 20)-5))
                cell:addChild(dialogBg2)
                dialogBg2:setOpacity(0)
                if i==heightNum then
                    if rewardNum%3==0 then
                        addSubChild(dialogBg2,i)
                    elseif rewardNum%3==1 then
                        local num=(i-1)*3+1
                        local iconPos=ccp(dialogBg2:getContentSize().width/2,dialogBg2:getContentSize().height/2+nameH)
                        addContent(dialogBg2,num,iconPos)
                    else
                        local centerX=dialogBg2:getContentSize().width/2
                        local centerY=dialogBg2:getContentSize().height/2
                        for j=1,2 do
                            local num=(i-1)*3+j

                            local iconPos
                            if j==1 then
                                iconPos=ccp(centerX-85,centerY+nameH)
                            else
                                iconPos=ccp(centerX+85,centerY+nameH)
                            end
                            addContent(dialogBg2,num,iconPos)
                        end

                    end
                else
                    addSubChild(dialogBg2,i)
                end
            end


    --     return cell
    -- end
end