stewardLotterySmallDialogTwo=smallDialog:new()

function stewardLotterySmallDialogTwo:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    nc.allAwardTb = {}
    nc.allAwardTipTb = {}
    nc.iconSize = 120
    nc.awardTbHeight = {}
    nc.awardNameTb   = {}
    nc.cellPosTb     = {}
    nc.awardNodeTb   = {}
    self.isShow      = false
    return nc
end

function stewardLotterySmallDialogTwo:showLotteryRewardDialog(layerNum, titleStr, allAwardTb,allAwardTipTb,pParent)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    local sd = stewardLotterySmallDialogTwo:new()
    sd:initLotteryRewardDialog(layerNum, titleStr, allAwardTb,allAwardTipTb,pParent)
    return sd
end

function stewardLotterySmallDialogTwo:getCellHeight()--测算高度 + 设置标题
    self.awardTbHeight[1]  = 50 -- 50 默认标题高度
    self.awardTbHeight[2]  = 50
    self.awardTbHeight[3]  = 150 -- 神秘组织 提示高度
    self.awardIconHeight = self.iconSize + 10
    if self.allAwardTb[1] and SizeOfTable(self.allAwardTb[1]) > 0 then--补给线 sl
        self.award1CellNum  = SizeOfTable(self.allAwardTb[1])
        local rh = 0 --奖励高度
        for k = 1, self.award1CellNum do
            local item = self.allAwardTb[1][k]
            if item and item.award then
                local row = math.ceil(SizeOfTable(item.award) / 4)
                rh = rh + (85 + 10) * row + 40
            end
        end
        self.awardTbHeight[1] = self.awardTbHeight[1] + rh
        self.awardTbHeight[1] = self.awardTbHeight[1] +  50 -- 补给线 结束描述(三种状态 1 满 2 没能量 3 完成)
        if self.allAwardTipTb["slEndRaidStr"][3] == 1 then--跳转仓库的按钮
            self.awardTbHeight[1] = self.awardTbHeight[1] + 70
        end
        self.awardNameTb[1] = getlocal("accessory_title_2")
        -- table.insert(self.awardNameTb,getlocal("accessory_title_2"))
    else
        self.awardTbHeight[1] = 0
    end
        
    -----

    if self.allAwardTb[2] and SizeOfTable(self.allAwardTb[2]) > 0 then--远征军 sw
        self.award2CellNum  = SizeOfTable(self.allAwardTb[2])/4 + (SizeOfTable(self.allAwardTb[2])%4 > 0 and 1 or 0)
        self.awardTbHeight[2] = self.awardTbHeight[2] + self.award2CellNum * self.awardIconHeight

        self.awardNameTb[2] = getlocal("expedition")
        -- table.insert(self.awardNameTb,getlocal("expedition"))
    else
        self.awardTbHeight[2] = 0
    end

    -----

    if self.allAwardTipTb["swTip"] then 
        self.awardNameTb[3] = getlocal("super_weapon_title_2")
        -- table.insert(self.awardNameTb,getlocal("super_weapon_title_2"))
    else
        self.awardTbHeight[3] = 0
    end

    -----

    if self.allAwardTb[1] and SizeOfTable(self.allAwardTb[1]) > 0 then
        self.cellPosTb[1] = self.awardTbHeight[2] + self.awardTbHeight[3]
    end
    if self.allAwardTb[2] and SizeOfTable(self.allAwardTb[2]) > 0 then
        self.cellPosTb[2] = self.awardTbHeight[3]
    end
    if self.allAwardTb[3] then --and SizeOfTable(self.allAwardTb[3]) then
        self.cellPosTb[3] = 0
    end

end

function stewardLotterySmallDialogTwo:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 1
	elseif fn=="tableCellSizeForIndex" then
        local useCellWidth,useCellHeight = self.cellWidth or self.bgSize.width-40,self.awardTbHeight[1] + self.awardTbHeight[2] + self.awardTbHeight[3]
        self.cellHeight = useCellHeight
		return CCSizeMake(useCellWidth,useCellHeight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

        self.actionCell = cell
        self.cellPosx,self.cellPosy = cell:getPositionX(),cell:getPositionY()
		for i=1,3 do--设置背景框
            if self.allAwardTb[i] and self.awardTbHeight[i] > 0 then
                local cellBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()end)
                cellBgSp:setContentSize(CCSizeMake(self.cellWidth,self.awardTbHeight[i]))
                cellBgSp:setAnchorPoint(ccp(0.5,0))
                cellBgSp:setPosition(self.cellWidth * 0.5,self.cellPosTb[i] + (i-1) * 2 )

                self:showAwardInCellBg(cellBgSp,i,self.cellWidth,self.awardTbHeight[i])

                cell:addChild(cellBgSp)
            end
        end

		return cell
	elseif fn=="ccTouchBegan" then
		return true
	elseif fn=="ccTouchMoved" then
	elseif fn=="ccTouchEnded" then
	end
end

function stewardLotterySmallDialogTwo:showAwardInCellBg(parent,curIdx,pWidth,pHeight)
    local titleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    titleBg:setAnchorPoint(ccp(0.5,1))
    titleBg:setPosition(pWidth * 0.5,pHeight)
    parent:addChild(titleBg)

    local title = GetTTFLabel(self.awardNameTb[curIdx],23,true,"Helvetica-bold")
    title:setPosition(getCenterPoint(titleBg))
    titleBg:addChild(title)

    local awardHeight = self.awardTbHeight[curIdx] - 50

    if curIdx == 1 then
        local message = self.allAwardTb[curIdx]
        local showStrTb = self.allAwardTipTb["slShowStrTb"]
        local iconSize=self.iconSize
        local rwidth = 85
        local bgPosy = awardHeight
        for i=1,self.award1CellNum do
            local item= message[i] or {}
            local award=item.award

            local bgHeight = math.ceil(SizeOfTable(award)/4)*(rwidth+10) + 40

            local awardBg =CCNode:create()
            awardBg:setContentSize(CCSizeMake(pWidth, bgHeight))
            awardBg:setAnchorPoint(ccp(0.5,1))
            -- awardBg:setOpacity(0)
            awardBg:setPosition(ccp(pWidth * 0.5,bgPosy))
            parent:addChild(awardBg)
            if not self.isShow then
                awardBg:setVisible(false)
            end
            table.insert(self.awardNodeTb,awardBg)

            local bgWidth=awardBg:getContentSize().width
            local numStr = ""
            if showStrTb then
                numStr=showStrTb[i]
            end
            local numLb=GetTTFLabel(numStr,22,"Helvetica-bold")
            numLb:setAnchorPoint(ccp(0,1))
            numLb:setPosition(ccp(20,bgHeight-5))
            awardBg:addChild(numLb,1)

            local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
            lineSp:setContentSize(CCSizeMake(pWidth-4, 3))
            lineSp:setPosition(pWidth * 0.5,0)
            awardBg:addChild(lineSp)

            local rposy = numLb:getPositionY() - numLb:getContentSize().height - 5

            if award and SizeOfTable(award)>0 then
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
                local emptyNum=0
                for k,v in pairs(award) do
                    local px = 20 + rwidth * 0.5 + ((k - 1) % 4) * (rwidth + 20)
                    local py = rposy - (math.ceil(k / 4) - 1) * (rwidth + 10) - rwidth / 2 - 5
                    -- local px,py=20+iconSize * 0.5 + 120 * (k-1-emptyNum), iconSize * 0.4
                    -- print("v.name,v.pic,v.key====>",v.name,v.pic,v.key)
                    if (v.name==getlocal("honor") and isMaxHonors==true) or (v.name==getlocal("sample_general_exp") and isMaxExp==true) then
                        local gems=0
                        if v.name==getlocal("honor") and isMaxHonors==true then
                            gems=playerVoApi:convertGems(2,v.num)
                        elseif v.name==getlocal("sample_general_exp") and isMaxExp==true then
                            gems=playerVoApi:convertGems(1,v.num)
                        end
                        local tmpLb=tolua.cast(awardBg:getChildByTag(1031),"CCLabelTTF")
                        if tmpLb==nil then
                            local icon=CCSprite:createWithSpriteFrameName("resourse_normal_gold.png")
                            scale=rwidth/icon:getContentSize().width
                            icon:setScale(scale)
                            icon:setAnchorPoint(ccp(0.5,0.5))
                            icon:setPosition(ccp(px,py))
                            awardBg:addChild(icon,1)
                            local lb=GetTTFLabel("x"..FormatNumber(gems),25)
                            lb:setAnchorPoint(ccp(1,0))
                            lb:setPosition(ccp(85,3))
                            icon:addChild(lb,2)
                            lb:setTag(1031)
                            AllGems=gems
                        else
                            AllGems=AllGems+gems
                            tmpLb:setString("x"..FormatNumber(AllGems))
                            emptyNum=emptyNum+1
                        end
                    else
                        -- print("v.======>>>",v.pic,v.key,v.type)
                        local function showNewPropInfo()
                            G_showNewPropInfo(self.layerNum+1,true,true,nil,v)
                            return false
                        end
                        local icon,scale=G_getItemIcon(v,100,true,self.layerNum+1,showNewPropInfo)
                        icon:setTouchPriority(-(self.layerNum-1)*20-3)
                        scale = rwidth / icon:getContentSize().width
                        if icon:getContentSize().height > icon:getContentSize().width then
                            scale = rwidth / icon:getContentSize().height  
                        end
                        icon:setScale(scale)
                        if icon then
                            icon:setAnchorPoint(ccp(0.5,0.5))
                            icon:setPosition(ccp(px,py))
                            awardBg:addChild(icon,1)
                            local lb=GetTTFLabel("x"..FormatNumber(v.num),25)
                            lb:setAnchorPoint(ccp(1,0))
                            lb:setPosition(ccp(icon:getContentSize().width,3))
                            icon:addChild(lb,2)
                        end
                    end
                end
            end

            if i == self.award1CellNum then
                local lb,lbColor = self.allAwardTipTb["slEndRaidStr"][1],self.allAwardTipTb["slEndRaidStr"][2]
                local slBottomTip = GetTTFLabelWrap(lb,22,CCSizeMake(pWidth - 10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
                slBottomTip:setPosition(ccp(pWidth * 0.5, -25))
                slBottomTip:setColor(lbColor)
                awardBg:addChild(slBottomTip)

                if self.allAwardTipTb["slEndRaidStr"][3] == 1 then--sample_build_name_10
                    local function gotoCallback(tag ,obj)
                        if G_checkClickEnable()==false then
                            do return end
                        else
                            base.setWaitTime=G_getCurDeviceMillTime()
                        end
                        PlayEffect(audioCfg.mouseClick)
                        if self.pParent and self.pParent.closeDialog then
                            self.pParent:closeDialog()
                        end
                        self:close()
                        G_goToDialog2("au",self.layerNum,true,1)
                    end
                    local gotoItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",gotoCallback,111,getlocal("sample_build_name_10"),24/0.8)
                    gotoItem:setAnchorPoint(ccp(0.5,1))
                    gotoItem:setScale(0.7)
                    gotoMenu = CCMenu:createWithItem(gotoItem)
                    gotoMenu:setTouchPriority(-(self.layerNum-1)*20-3)
                    gotoMenu:setPosition(pWidth * 0.5, - 50)
                    awardBg:addChild(gotoMenu)
                end
            end
            bgPosy = bgPosy - bgHeight
        end
    elseif curIdx == 2 then
        local expAwardTb = self.allAwardTb[2]
        local sHeight = 0
        for k,v in pairs(expAwardTb) do
            local k1 = k%4 > 0 and k%4 or 4
            if k%4 == 1 then
                sHeight = awardHeight- (k/4 + 1)* (self.awardIconHeight - 5)
            end
            local iconSize = self.iconSize
            local px,py=20+iconSize * 0.5 + 120 * (k1 - 1), sHeight + self.awardIconHeight * 0.8
            local function showNewPropInfo()
                G_showNewPropInfo(self.layerNum+1,true,true,nil,v)
                return false
            end
            local icon,scale=G_getItemIcon(v,85,true,self.layerNum+1,showNewPropInfo)
            icon:setTouchPriority(-(self.layerNum-1)*20-3)
            icon:setScale(0.85)
            local useScale = nil
            if v.type == "h" then
                useScale = 85 / icon:getContentSize().height
                icon:setScale(useScale)
            end
            if icon then
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setPosition(ccp(px,py))
                parent:addChild(icon,1)
                
                local lb=GetTTFLabel("x"..FormatNumber(v.num),25)
                lb:setAnchorPoint(ccp(1,0))
                lb:setPosition(ccp(icon:getContentSize().width - 4,3))
                if useScale then
                    lb:setScale(1/useScale - 0.2)
                end
                icon:addChild(lb,2)
            end
        end

        if self.allAwardTipTb["expTip"] then
            local swTip = GetTTFLabelWrap(self.allAwardTipTb["expTip"],23,CCSizeMake(pWidth - 10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
            swTip:setAnchorPoint(ccp(0.5,0))
            swTip:setColor(G_ColorGreen)
            swTip:setPosition(pWidth * 0.5,10)
            parent:addChild(swTip)
        end

        if not self.isShow then
            parent:setVisible(false)
        end
        table.insert(self.awardNodeTb,parent)
    else
        if self.allAwardTipTb["swTip"] then
            local swTip = GetTTFLabelWrap(self.allAwardTipTb["swTip"],23,CCSizeMake(pWidth - 10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
            swTip:setAnchorPoint(ccp(0.5,0))
            swTip:setPosition(pWidth * 0.5,20)
            parent:addChild(swTip)
            if not self.isShow then
                parent:setVisible(false)
            end
            table.insert(self.awardNodeTb,parent)
        end
    end
end

function stewardLotterySmallDialogTwo:initLotteryRewardDialog(layerNum, titleStr, allAwardTb,allAwardTipTb,pParent)
	self.layerNum = layerNum
    self.isUseAmi = true
    self.allAwardTb,self.allAwardTipTb = allAwardTb,allAwardTipTb
    self.pParent = pParent
    self.dialogLayer = CCLayer:create()

    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority( - (layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    -- touchDialogBg:setOpacity(50)
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)

    self.bgSize = CCSizeMake(560, 680)
    self.cellWidth = self.bgSize.width-40

    self:getCellHeight()

    local function closeDialog()
    	if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local dialogBg,titleBg,titleLb,closeBtnItem,closeBtn=G_getNewDialogBg(self.bgSize,titleStr,32,nil,layerNum,true,closeDialog,nil)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
    self.dialogLayer:addChild(self.bgLayer,2)

	local function tvCallBack(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(tvCallBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgSize.width-40,self.bgSize.height-98),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    local useSize,usePos = CCSizeMake(self.bgSize.width-40,self.bgSize.height-98),ccp(20,30)
    self:initMaskDialog(useSize,usePos)

    local function touchDialog()
        print("touchDialog show~~~~~~~~~~~~~~~")
        self.touchDialog:setPosition(ccp(G_VisibleSizeWidth*2.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
        self.bgLayer:stopAllActions()
        self.actionCell:stopAllActions()
        local usePosy = self.actionCell:getPositionY()
        self.isShow = true
        local recordPoint = self.tv:getRecordPoint()
        recordPoint.y = recordPoint.y + usePosy
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
    self.tDialogHeight = 80
    self.touchDialog = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    self.touchDialog:setTouchPriority(-(self.layerNum-1)*20-99)
    self.touchDialog:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-self.tDialogHeight))
    self.touchDialog:setOpacity(0)
    self.touchDialog:setIsSallow(true) -- 点击事件透下去
    self.touchDialog:setPosition(ccp(G_VisibleSizeWidth*0.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
    self.bgLayer:addChild(self.touchDialog,99)

    if SizeOfTable(self.awardNodeTb) > 0 then
        self:show(callback)
    end
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function stewardLotterySmallDialogTwo:show( )
    local allShowIdx = SizeOfTable(self.awardNodeTb)
    local showIdx = 1
    local deT = CCDelayTime:create(0.4)
    local function showCall ()
        if self.awardNodeTb[showIdx] then
            self.awardNodeTb[showIdx]:setVisible(true)
            showIdx = showIdx + 1
        end
    end
    local showC = CCCallFunc:create(showCall)
    local arry=CCArray:create()
    arry:addObject(deT)
    arry:addObject(showC)
    local seq1 = CCSequence:create(arry)
    local reapt = CCRepeat:create(seq1, SizeOfTable(self.awardNodeTb)+1)
    self.bgLayer:runAction(reapt)

    if SizeOfTable(self.awardNodeTb) > 3 or (self.allAwardTb[2] and SizeOfTable(self.allAwardTb[2]) > 0) then
        
        local deT2 = CCDelayTime:create(1.6)
        local useT = SizeOfTable(self.awardNodeTb) * 0.4
        local ccmov = CCMoveBy:create(useT,ccp(self.cellPosx,self.cellHeight - self.bgSize.height + 100))
        local arr2 = CCArray:create()
        arr2:addObject(deT2)
        arr2:addObject(ccmov)
        local function endCall ()
            self.touchDialog:setPosition(ccp(G_VisibleSizeWidth*2.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
            self.bgLayer:stopAllActions()
            self.actionCell:stopAllActions()
            -- print("self.actionCell.posy---->>>>>",self.actionCell:getPositionY())
            local usePosy = self.actionCell:getPositionY()
            self.isShow = true
            local recordPoint = self.tv:getRecordPoint()
            recordPoint.y = recordPoint.y + usePosy
            self.tv:reloadData()
            self.tv:recoverToRecordPoint(recordPoint)
        end
        local endC = CCCallFunc:create(endCall)
        arr2:addObject(endC)
        local seq2 = CCSequence:create(arr2)
        self.actionCell:runAction(seq2)
    end
end

function stewardLotterySmallDialogTwo:dispose()
    self.awardNodeTb = nil
end

function stewardLotterySmallDialogTwo:initMaskDialog(useSize,usePos)
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority( - (self.layerNum - 1) * 20 - 99)
    touchDialogBg:setContentSize(useSize)
    touchDialogBg:setIsSallow(true)
    touchDialogBg:setOpacity(0)
    touchDialogBg:setAnchorPoint(ccp(0,0))
    touchDialogBg:setPosition(ccp(usePos.x - 50,useSize.height + usePos.y))
    self.bgLayer:addChild(touchDialogBg,99)

    local touchDialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg2:setTouchPriority( - (self.layerNum - 1) * 20 - 99)
    touchDialogBg2:setContentSize(useSize)
    touchDialogBg2:setIsSallow(true)
    touchDialogBg2:setOpacity(0)
    touchDialogBg2:setAnchorPoint(ccp(0,1))
    touchDialogBg2:setPosition(ccp(usePos.x - 50,usePos.y))
    self.bgLayer:addChild(touchDialogBg2,99)
end