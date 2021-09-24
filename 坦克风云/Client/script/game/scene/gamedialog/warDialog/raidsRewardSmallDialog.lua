raidsRewardSmallDialog=smallDialog:new()

function raidsRewardSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.message={}
	self.tv=nil
	spriteController:addPlist("public/vipFinal.plist")
	return nc
end

-- showStrTb endRaidStrTb  补给线扫荡 
-- isAccStreng 是否是配件连续强化结果面板
function raidsRewardSmallDialog:init(bgSrc,size,fullRect,inRect,title,content,istouch,isuseami,layerNum,callBackHandler,isOneByOne,upgradeTanks,showStrTb,endRaidStrTb,isAccStreng)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    -- local function touchHander()
    
    -- end
    -- local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHander)
    self.bgSize=size
    local dialogBg,titleBg,titleLb=G_getNewDialogBg(self.bgSize,title,32,nil,layerNum)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer=dialogBg
    
    self.bgLayer:setContentSize(size)
    self:show()

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()

    -- local titleLb=GetTTFLabelWrap(title,40,CCSizeMake(size.width-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    -- titleLb:setAnchorPoint(ccp(0.5,0.5))
    -- titleLb:setPosition(ccp(size.width/2,size.height-45))
    -- dialogBg:addChild(titleLb,1)
    
    if isAccStreng==true then
        -- titleLb:setPosition(ccp(size.width/2,size.height-55))
        -- local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png")
        -- bgSp:setPosition(ccp(size.width/2+10,size.height-titleLb:getContentSize().height-10))
        -- bgSp:setScaleY((titleLb:getContentSize().height+20)/bgSp:getContentSize().height)
        -- bgSp:setScaleX(size.width/bgSp:getContentSize().width)
        -- dialogBg:addChild(bgSp)
    else
        local linePy=size.height-100
        local subTitleBg=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    	-- subTitleBg:setScaleY(50/subTitleBg:getContentSize().height)
    	-- subTitleBg:setScaleX(3)
    	subTitleBg:setPosition(ccp(size.width/2,linePy))
    	dialogBg:addChild(subTitleBg)
    	local subTitleLb=GetTTFLabelWrap(getlocal("fight_award"),28,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    	subTitleLb:setPosition(ccp(size.width/2,linePy))
    	dialogBg:addChild(subTitleLb,1)
        -- local leftLineSP=CCSprite:createWithSpriteFrameName("lineAndPoint.png")
        -- leftLineSP:setFlipX(true)
        -- leftLineSP:setPosition(ccp(80,linePy))
        -- dialogBg:addChild(leftLineSP,1)
        -- local rightLineSP=CCSprite:createWithSpriteFrameName("lineAndPoint.png")
        -- rightLineSP:setPosition(ccp(size.width-80,linePy))
        -- dialogBg:addChild(rightLineSP,1)
    end

    
    local cellWidth=490
    local cellHeight=160
    local isMoved=false
    local iconSize=100

    if isOneByOne==true and type(content)=="table" and SizeOfTable(content)>1 then
        self.message={}
    else
        self.message=content
    end
    
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return SizeOfTable(self.message)
        elseif fn=="tableCellSizeForIndex" then
            local useCellHeight = cellHeight
            local item=self.message[idx+1] or {}
            if not isAccStreng then
                
                if SizeOfTable(item.award) > 4 then
                    useCellHeight = cellHeight + 110
                end
            end
            local tmpSize=CCSizeMake(cellWidth,useCellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local item=self.message[idx+1] or {}
            local award=item.award

            local useCellHeight = cellHeight
            if not isAccStreng then
                if SizeOfTable(award) > 4 then
                    useCellHeight = cellHeight + 110
                end
            end

	        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
			backSprie:setContentSize(CCSizeMake(cellWidth, useCellHeight-5))
	        backSprie:ignoreAnchorPointForPosition(false)
	        backSprie:setAnchorPoint(ccp(0,0))
	        backSprie:setIsSallow(false)
	        backSprie:setTouchPriority(-(layerNum-1)*20-2)
			backSprie:setPosition(ccp(0,0))
	        cell:addChild(backSprie)

	        local bgWidth=backSprie:getContentSize().width
	        local bgHeight=backSprie:getContentSize().height
            local numStr
            if showStrTb then
                numStr=showStrTb[idx+1]
            else
                numStr=getlocal("raids_reward_num",{idx+1})
            end
	        local numLb=GetTTFLabel(numStr,25)
	        numLb:setAnchorPoint(ccp(0,0.5))
	        numLb:setPosition(ccp(20,bgHeight-20))
	        backSprie:addChild(numLb,1)

            if not isAccStreng then
                backSprie:setOpacity(0)
            else
    	        local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
                lineSp:setContentSize(CCSizeMake(cellWidth-4, 3))
    			lineSp:setPosition(ccp(bgWidth/2,bgHeight-40))
    			backSprie:addChild(lineSp)
            end
            
            -- local point=item.point
            if award and SizeOfTable(award)>0 then
                if isAccStreng and isAccStreng==true then
                    local isVictory=item.isVictory or 0
                    local returnRes=item.returnRes or 0
                    if isVictory==1 then
                        numLb:setColor(G_ColorYellowPro)
                    end
                    local costLb=GetTTFLabelWrap(getlocal("activity_tankjianianhua_Consume")..":",25,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                    costLb:setAnchorPoint(ccp(0,0.5))
                    costLb:setPosition(ccp(20,backSprie:getContentSize().height/2))
                    backSprie:addChild(costLb,1)

                    local tmpTb={}
                    local finalPox=0
                    local scale=0.4
                    for k,v in pairs(award) do
                        if v and SizeOfTable(v)>0 then
                            local px,py=130,backSprie:getContentSize().height/2-50*(k-1)
                            local nameLb=GetTTFLabel(v.name,25)
                            nameLb:setAnchorPoint(ccp(0,0.5))
                            nameLb:setPosition(ccp(px,py))
                            backSprie:addChild(nameLb,1)
                            local sp=CCSprite:createWithSpriteFrameName(v.pic)
                            sp:setPosition(ccp(px+nameLb:getContentSize().width+10,py))
                            sp:setScale(scale)
                            backSprie:addChild(sp,1)
                            if finalPox<px+nameLb:getContentSize().width+10 then
                                finalPox=px+nameLb:getContentSize().width+10
                            end
                            
                            local numStr=FormatNumber(v.num)
                            if v.type=="u" and v.key=="gold" and returnRes and returnRes>0 then
                                numStr=numStr..getlocal("accessory_return_number",{FormatNumber(returnRes)})
                            end
                            local numLb=GetTTFLabelWrap(numStr,25,CCSizeMake(220,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                            numLb:setAnchorPoint(ccp(0,0.5))
                            local spx,spy=sp:getPosition()
                            numLb:setPosition(ccp(spx+sp:getContentSize().width/2*scale+10,spy))
                            backSprie:addChild(numLb,1)
                            if tmpTb[k]==nil then
                                tmpTb[k]={}
                            end
                            tmpTb[k].sp=sp
                            tmpTb[k].numLb=numLb
                        end
                    end
                    for k,v in pairs(tmpTb) do
                        if v then
                            local sp1
                            if v.sp then
                                sp1=tolua.cast(v.sp,"CCSprite")
                                if sp1 then
                                    local px,py=sp1:getPosition()
                                    px=finalPox+sp1:getContentSize().width/2*scale
                                    sp1:setPosition(ccp(px,py))
                                    if v.numLb then
                                        local lb=tolua.cast(v.numLb,"CCLabelTTF")
                                        if lb then
                                            local px,py=sp1:getPosition()
                                            lb:setPosition(ccp(px+sp1:getContentSize().width/2*scale+10,py))
                                        end
                                    end
                                end
                            end
                            
                        end
                    end
                else
                    local playerHonors =playerVoApi:getHonors() --用户当前的总声望值
                    local maxLevel =playerVoApi:getMaxLvByKey("roleMaxLevel") --当前服 最大等级
                    local honTb =Split(playerCfg.honors,",")
                    local maxHonors =honTb[maxLevel] --当前服 最大声望值
                    local expTb =Split(playerCfg.level_exps,",")
                    local maxExp = expTb[maxLevel] --当前服 最大经验值
                    local playerExp = playerVoApi:getPlayerExp() --用户当前的经验值
                    local AllGems = 0 --用于满级后的水晶数量
                    local isMaxHonors,isMaxExp=false,false
                    if base.isConvertGems==1 then
                        if tonumber(playerHonors)>=tonumber(maxHonors) then
                            isMaxHonors=true
                        end
                        if tonumber(playerExp)>=tonumber(maxExp) then
                            isMaxExp=true
                        end
                    end
                    -- local emptyNum=0
                	for k,v in pairs(award) do
                		-- local px,py=20+iconSize/2+120*(k-1-emptyNum),10+iconSize/2
                        local px,py = 20+iconSize/2+120*(k-1),10+useCellHeight - 60 - iconSize * 0.5
                        if k > 4 then
                            px,py = 20+iconSize/2+120*(k-5),5+useCellHeight - 60 - iconSize * 1.5
                        end
                        if (v.name==getlocal("honor") and isMaxHonors==true) or (v.name==getlocal("sample_general_exp") and isMaxExp==true) then
                            local gems=0
                            if v.name==getlocal("honor") and isMaxHonors==true then
                                gems=playerVoApi:convertGems(2,v.num)
                            elseif v.name==getlocal("sample_general_exp") and isMaxExp==true then
                                gems=playerVoApi:convertGems(1,v.num)
                            end
                            local tmpLb=tolua.cast(backSprie:getChildByTag(1031),"CCLabelTTF")
                            -- if tmpLb==nil then
                                local icon=CCSprite:createWithSpriteFrameName("resourse_normal_gold.png")
                                if icon:getContentSize().width < icon:getContentSize().height then
                                    scale = iconSize / icon:getContentSize().height
                                else
                                    scale = iconSize / icon:getContentSize().width
                                end
                                icon:setScale(scale)
                                icon:setAnchorPoint(ccp(0.5,0.5))
                                icon:setPosition(ccp(px,py))
                                backSprie:addChild(icon,1)
                                -- local lb=GetTTFLabel("x"..FormatNumber(gems),22)
                                -- lb:setAnchorPoint(ccp(1,0))
                                -- lb:setPosition(ccp(px+iconSize/2-5,py-iconSize/2+5))
                                -- lb:setScale(1/scale)
                                -- backSprie:addChild(lb,2)
                                -- lb:setTag(1031)

                                local numLb = GetTTFLabel("x"..FormatNumber(gems), 22)
                                numLb:setAnchorPoint(ccp(1, 0.5))
                                local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
                                numBg:setAnchorPoint(ccp(1, 0))
                                numBg:setContentSize(CCSizeMake(numLb:getContentSize().width + 5, numLb:getContentSize().height - 5))
                                numBg:setPosition(ccp(icon:getContentSize().width - 3, 7))
                                numBg:setOpacity(150)
                                icon:addChild(numBg, 2)
                                numLb:setPosition(numBg:getContentSize().width - 2, numBg:getContentSize().height / 2)
                                numBg:addChild(numLb)
                                numBg:setScale(1 / icon:getScale())

                                AllGems=gems
                            -- else
                            --     AllGems=AllGems+gems
                            --     tmpLb:setString("x"..FormatNumber(AllGems))
                            --     emptyNum=emptyNum+1
                            -- end
                        else
                            local icon,scale=G_getItemIcon(v,iconSize,false,layerNum+1)
                            if icon then
                                icon:setAnchorPoint(ccp(0.5,0.5))
                                icon:setPosition(ccp(px,py))
                                backSprie:addChild(icon,1)
                                if icon:getContentSize().width < icon:getContentSize().height then
                                    scale = iconSize / icon:getContentSize().height
                                else
                                    scale = iconSize / icon:getContentSize().width
                                end
                                icon:setScale(scale)
                                -- local lb=GetTTFLabel("x"..FormatNumber(v.num),22)
                                -- lb:setAnchorPoint(ccp(1,0))
                                -- -- lb:setPosition(ccp(icon:getContentSize().width-5,5))
                                -- lb:setScale(1 / scale)
                                -- -- icon:addChild(lb,1)
                                -- lb:setPosition(ccp(px+iconSize/2-5,py-iconSize/2+5))
                                -- backSprie:addChild(lb,2)

                                local numLb = GetTTFLabel("x"..FormatNumber(v.num), 22)
                                numLb:setAnchorPoint(ccp(1, 0.5))
                                local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
                                numBg:setAnchorPoint(ccp(1, 0))
                                numBg:setContentSize(CCSizeMake(numLb:getContentSize().width + 5, numLb:getContentSize().height - 5))
                                numBg:setPosition(ccp(icon:getContentSize().width - 3, 7))
                                numBg:setOpacity(150)
                                icon:addChild(numBg, 2)
                                numLb:setPosition(numBg:getContentSize().width - 2, numBg:getContentSize().height / 2)
                                numBg:addChild(numLb)
                                numBg:setScale(1 / icon:getScale())
                            end
                        end
                	end
                end
            end
            cellHeight=160
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
    
    local isEnd=true
    
    if isAccStreng==true then
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,size.height-210),nil)
        self.tv:setTableViewTouchPriority(-(layerNum-1)*20-2)
        self.tv:setPosition(ccp(60/2,120))
        self.bgLayer:addChild(self.tv,2)
        self.tv:setMaxDisToBottomOrTop(120)
    elseif upgradeTanks and SizeOfTable(upgradeTanks)>0 then
    	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,size.height-350),nil)
	    self.tv:setTableViewTouchPriority(-(layerNum-1)*20-2)
	    self.tv:setPosition(ccp(60/2,210))
	    self.bgLayer:addChild(self.tv,2)
	    self.tv:setMaxDisToBottomOrTop(120)

    	local upNum=0
    	for k,v in pairs(upgradeTanks) do
    		if v and tonumber(v) then
    			upNum=upNum+tonumber(v)
    		end
    	end
	    linePy=180
	    local subTitleBg1=CCSprite:createWithSpriteFrameName("groupSelf.png")
		subTitleBg1:setScaleY(50/subTitleBg1:getContentSize().height)
		subTitleBg1:setScaleX(3)
		subTitleBg1:setPosition(ccp(size.width/2,linePy))
		dialogBg:addChild(subTitleBg1)
		local tipLb=GetTTFLabelWrap(getlocal("raids_reward_help_tip"),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		tipLb:setPosition(ccp(size.width/2,linePy))
		dialogBg:addChild(tipLb,1)
	    local leftLineSP1=CCSprite:createWithSpriteFrameName("lineAndPoint.png")
	    leftLineSP1:setFlipX(true)
	    leftLineSP1:setPosition(ccp(80,linePy))
	    dialogBg:addChild(leftLineSP1,1)
	    local rightLineSP1=CCSprite:createWithSpriteFrameName("lineAndPoint.png")
	    rightLineSP1:setPosition(ccp(size.width-80,linePy))
	    dialogBg:addChild(rightLineSP1,1)
	    linePy=130
	    local descLb=GetTTFLabelWrap(getlocal("battleResultTankUpgrade",{upNum}),25,CCSizeMake(size.width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	    descLb:setAnchorPoint(ccp(0,0.5))
	    descLb:setPosition(ccp(30,linePy))
	    dialogBg:addChild(descLb,1)
	    local function gotoEliteTank( ... )
	    	if G_checkClickEnable()==false then
	            do
	                return
	            end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end
	        PlayEffect(audioCfg.mouseClick)

	    	tankVoApi:showTankUpgrade(layerNum+1,upgradeTanks)
	    	self:close()
	    end
	    local arrowSp=LuaCCSprite:createWithSpriteFrameName("vipArrow.png",gotoEliteTank)
	    arrowSp:setTouchPriority(-(layerNum-1)*20-4)
		arrowSp:setPosition(ccp(size.width-50,linePy))
		dialogBg:addChild(arrowSp,1)
    elseif endRaidStrTb then
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,size.height-350),nil)
        self.tv:setTableViewTouchPriority(-(layerNum-1)*20-2)
        self.tv:setPosition(ccp(60/2,213))
        self.bgLayer:addChild(self.tv,2)
        self.tv:setMaxDisToBottomOrTop(120)
	else
		self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,size.height-250),nil)
	    self.tv:setTableViewTouchPriority(-(layerNum-1)*20-2)
	    self.tv:setPosition(ccp(60/2,110))
	    self.bgLayer:addChild(self.tv,2)
	    self.tv:setMaxDisToBottomOrTop(120)
	end

    --确定
    local function confirmHandler(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        -- print("isEnd",isEnd)
        if isEnd==true then
            if callBackHandler~=nil then
                callBackHandler()
            end
            self:close()
        elseif isEnd==false then
            if self and self.bgLayer and self.tv then
                self.bgLayer:stopAllActions()
                self.message=content
                local recordPoint=self.tv:getRecordPoint()
                self.tv:reloadData()
                recordPoint.y=0
                self.tv:recoverToRecordPoint(recordPoint)
                tolua.cast(self.sureBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("ok"))
            end
            isEnd=true
            if endRaidStrTb then
                self:addCareTipLb(dialogBg,size,endRaidStrTb)
            end
        end
    end
    self.sureBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",confirmHandler,1,getlocal("ok"),33,11)
    self.sureBtn:setScale(0.9)
    local sureMenu=CCMenu:createWithItem(self.sureBtn);
    sureMenu:setPosition(ccp(size.width/2,60))
    sureMenu:setTouchPriority(-(layerNum-1)*20-3);
    dialogBg:addChild(sureMenu)
    if SizeOfTable(content)>1 then
        isEnd=false
        tolua.cast(self.sureBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("gemCompleted"))
    end

    
    local function touchLuaSpr()
        -- if self.isTouch==true and isMoved==false then
        --     if self.bgLayer~=nil then
        --         PlayEffect(audioCfg.mouseClick)
        --         self:close()
        --     end
        -- end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);

    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
    if isOneByOne==true and type(content)=="table" and SizeOfTable(content)>0 then
        local acArr=CCArray:create()
        for k,v in pairs(content) do
            local function showNextMsg()
                if self and self.tv and v then
                    local award=v.award
                    -- local point=v.point
                    if SizeOfTable(content) > 1 then
                        if award then
                            table.insert(self.message,v)
                        end

                        self.tv:insertCellAtIndex(k-1)
                    end

                    if k==SizeOfTable(content) then
                        tolua.cast(self.sureBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("ok"))
                        isEnd=true
                        if endRaidStrTb then
                            self:addCareTipLb(dialogBg,size,endRaidStrTb)
                        end
                    end

                    -- local index=v.index
                    -- local pBen
                    -- if award.pBen then
                    --     pBen = award.pBen
                    -- end

                    -- if callBackHandler~=nil and isRefitTank==nil and isAddDesc==nil then
                    --     callBackHandler(index,pBen)
                    -- end
                end
            end
            local callFunc1=CCCallFuncN:create(showNextMsg)
            local delay=CCDelayTime:create(0.5)

            acArr:addObject(delay)
            acArr:addObject(callFunc1)

        end
        local seq=CCSequence:create(acArr)
        self.bgLayer:runAction(seq)

    end

end

function raidsRewardSmallDialog:addCareTipLb(dialogBg,size,endRaidStrTb)
    local linePy=183
    local subTitleBg1=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    -- subTitleBg1:setScaleY(50/subTitleBg1:getContentSize().height)
    -- subTitleBg1:setScaleX(3)
    subTitleBg1:setPosition(ccp(size.width/2,linePy))
    dialogBg:addChild(subTitleBg1)
    local tipLb=GetTTFLabelWrap(getlocal("raids_care_help_tip"),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    tipLb:setPosition(ccp(size.width/2,linePy))
    dialogBg:addChild(tipLb,1)
    -- local leftLineSP1=CCSprite:createWithSpriteFrameName("lineAndPoint.png")
    -- leftLineSP1:setFlipX(true)
    -- leftLineSP1:setPosition(ccp(80,linePy))
    -- dialogBg:addChild(leftLineSP1,1)
    -- local rightLineSP1=CCSprite:createWithSpriteFrameName("lineAndPoint.png")
    -- rightLineSP1:setPosition(ccp(size.width-80,linePy))
    -- dialogBg:addChild(rightLineSP1,1)
    linePy=130
    local descLb=GetTTFLabelWrap(endRaidStrTb[1],25,CCSizeMake(size.width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0,0.5))
    descLb:setPosition(ccp(30,linePy))
    dialogBg:addChild(descLb,1)
    descLb:setColor(endRaidStrTb[2])
end

function raidsRewardSmallDialog:dispose()
	self.message={}
	self.tv=nil
	spriteController:removePlist("public/vipFinal.plist")
end
