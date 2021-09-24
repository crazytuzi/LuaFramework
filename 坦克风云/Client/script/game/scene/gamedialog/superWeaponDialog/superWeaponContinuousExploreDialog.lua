superWeaponContinuousExploreDialog=commonDialog:new()
function superWeaponContinuousExploreDialog:new(fid,level)
    local nc={}
    setmetatable(nc,self)
    nc.fid=fid
    nc.level = level
    nc.ccHeightTb = {}
    nc.deSize = G_getCurChoseLanguage() =="de" and -3 or 0 
    self.__index=self
    return nc
end
function superWeaponContinuousExploreDialog:dispose()
    self.fid=nil
    self.ccHeightTb = nil
    self.level = nil
    superWeaponVoApi:setExploreFlag(1)
end
--设置对话框里的tableView
function superWeaponContinuousExploreDialog:initTableView()
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")

    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
    self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,G_VisibleSize.height-95))

    self.awardList,self.usePropList,self.swBlueprint = superWeaponVoApi:getAwardListAndUsePropList()--探索的奖励列表，使用的体力药剂或金币列表
    self.tvWidth,self.cellHeight = G_VisibleSizeWidth - 30, 230
    self.awardListNum = SizeOfTable(self.awardList) or 0
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight - 160),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,70))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(140)
    -- if self.awardListNum > 3 then
    --     self.tv:recoverToRecordPoint(ccp(0,0))
    -- end

    if superWeaponVoApi:getContinuousExp( ) then
        local propTb=FormatItem(weaponrobCfg.addEnergyCostProp)
        local item=propTb[1]
        local pid=(tonumber(item.key) or tonumber(RemoveFirstChar(item.key)))
        local costPropNum=bagVoApi:getItemNumId(pid)

        local numLb1=GetTTFLabel("x"..costPropNum,25)
        numLb1:setAnchorPoint(ccp(0,0))
        numLb1:setPosition(ccp(G_VisibleSizeWidth * 0.5 + 2,30))
        self.bgLayer:addChild(numLb1,2)

        local sp1=CCSprite:createWithSpriteFrameName("sw_9.png")
        sp1:setAnchorPoint(ccp(1,0))
        sp1:setScale(0.4)
        sp1:setPosition(ccp(G_VisibleSizeWidth * 0.5 - 2,30))
        self.bgLayer:addChild(sp1,2)

        local bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function() end)
        bgSp:setPosition(ccp(sp1:getPositionX() - sp1:getContentSize().width * 0.4 -2, numLb1:getPositionY() - 2))
        bgSp:setAnchorPoint(ccp(0,0))
        bgSp:setOpacity(150)
        bgSp:setContentSize(CCSizeMake(numLb1:getContentSize().width + sp1:getContentSize().width * 0.4 + 10,numLb1:getContentSize().height + 10))
        self.bgLayer:addChild(bgSp)
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function superWeaponContinuousExploreDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.awardListNum
    elseif fn=="tableCellSizeForIndex" then
        self.ccHeightTb[idx + 1] = self.usePropList[idx + 1] and self.cellHeight + 40 or self.cellHeight--150
        if self.awardListNum == idx + 1 and self.swBlueprint == nil then
            self.ccHeightTb[idx + 1] = self.ccHeightTb[idx + 1] + 20
        end
        local tmpSize=CCSizeMake(self.tvWidth,self.ccHeightTb[idx + 1])
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local function realShow()
            if idx + 1 > 4 then
                local recordPoint=self.tv:getRecordPoint()
                recordPoint.y = self.ccHeightTb[idx +1] + recordPoint.y
                self.tv:recoverToRecordPoint(recordPoint)
            end
            local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function() end)
            cellBg:setContentSize(CCSizeMake(self.tvWidth,self.ccHeightTb[idx + 1] - 20))
            cellBg:setAnchorPoint(ccp(0,0))
            cellBg:setPosition(ccp(0,0))
            cellBg:setOpacity(0)
            cell:addChild(cellBg)
            local celluWidth,celluHeight = cellBg:getContentSize().width,cellBg:getContentSize().height

            local exploreLb = GetTTFLabelWrap(getlocal("super_weapon_exploreLb",{idx+1}),24 + self.deSize,CCSizeMake(celluWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
            exploreLb:setAnchorPoint(ccp(0,1))
            exploreLb:setPosition(ccp(0,celluHeight - 5))
            cellBg:addChild(exploreLb)

            exLb1Height = exploreLb:getContentSize().height

            local exploreLb2,exLb2Height
            if self.swBlueprint and idx + 1 == self.awardListNum then
                if self.swBlueprint.addount then
                    local colorTab={G_ColorWhite,G_ColorYellowPro,G_ColorWhite}
                    local nameStr=getlocal("super_weapon_rob_max_tips",{self.swBlueprint.addount})
                    local exploreStr2=getlocal("super_weapon_rob_max_tips2",{nameStr})
                    local richSize = G_isAsia() and 24 or 21
                    exploreLb2,exLb2Height = G_getRichTextLabel(exploreStr2,colorTab,richSize + self.deSize,celluWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,0,true)
                    exploreLb2:setAnchorPoint(ccp(0,1))
                    exploreLb2:setPosition(ccp(0,celluHeight- 5 - 15 - exLb1Height))
                    cellBg:addChild(exploreLb2)
                else
                    local colorTab={G_ColorWhite,G_ColorYellowPro,G_ColorWhite}
                    local fName,fDesc=superWeaponVoApi:getFragmentNameAndDesc(self.swBlueprint.gf)
                    local nameStr=getlocal("fightLevel",{self.level})..fName
                    local exploreStr2=getlocal("super_weapon_exploreSuccess",{nameStr})
                    local richSize = G_isAsia() and 24 or 21
                    exploreLb2,exLb2Height = G_getRichTextLabel(exploreStr2,colorTab,richSize + self.deSize,celluWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,0,true)
                    exploreLb2:setAnchorPoint(ccp(0,1))
                    exploreLb2:setPosition(ccp(0,celluHeight- 5 - 15 - exLb1Height))
                    cellBg:addChild(exploreLb2)
                end
            else
                exploreLb2 = GetTTFLabelWrap(getlocal("super_weapon_exploreFail"),24,CCSizeMake(celluWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                exploreLb2:setAnchorPoint(ccp(0,1))
                exploreLb2:setColor(G_ColorGray)
                exploreLb2:setPosition(ccp(0,celluHeight - 5 - 15 - exLb1Height))
                cellBg:addChild(exploreLb2)
                exLb2Height = exploreLb2:getContentSize().height
            end

            local colon = G_isAsia() and "：" or ":"
            local awardTip = GetTTFLabel(getlocal("award")..colon,24)
            awardTip:setAnchorPoint(ccp(0,1))
            awardTip:setPosition(ccp(0,celluHeight - 5 - 10 - exLb1Height - exLb2Height - 30))
            cellBg:addChild(awardTip)

            local iconSize = 80--95
            local v = self.awardList[idx + 1][1]
            local function callback( )
                G_showNewPropInfo(self.layerNum+1,true,nil,nil,v,nil,nil,nil)
            end 
            local icon,scale=G_getItemIcon(v,iconSize,false,self.layerNum,callback,nil)
            cellBg:addChild(icon)
            icon:setTouchPriority(-(self.layerNum-1)*20-4)
            icon:setAnchorPoint(ccp(0.5,1))
            icon:setPosition(ccp(self.tvWidth * 0.5,awardTip:getPositionY()))

            local numLabel=GetTTFLabel("x"..v.num,21,"Helvetica-bold")
            numLabel:setAnchorPoint(ccp(1,0))
            numLabel:setPosition(icon:getContentSize().width - 5, 5)
            numLabel:setScale(1/scale)
            icon:addChild(numLabel,1)

            local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
            lineSp:setContentSize(CCSizeMake((self.tvWidth-40),4))
            cellBg:addChild(lineSp)

            if idx + 1 == self.awardListNum then
                local addPosx,addPosy = 0,0
                if G_isAsia() == false then
                    addPosx,addPosy = 20,15
                end
                if self.swBlueprint then
                    if self.swBlueprint.addount then
                        local fragmentV = {
                            name = getlocal("weapon_smelt_p1"),
                            num = self.swBlueprint.addount,
                            pic = "superWeaponP1.png",
                            desc = "weapon_smelt_desc_p1",
                            -- bgname = bgname
                        }
                        icon:setPosition(ccp(self.tvWidth * 0.3 + addPosx,icon:getPositionY() + addPosy))
                        local function clickHandler()
                            G_showNewPropInfo(self.layerNum+1,true,nil,nil,fragmentV,nil,nil,nil)
                            return false
                        end

                        local fragmentIcon,scale=G_getItemIcon(fragmentV,iconSize,false,self.layerNum,clickHandler,nil)
                        fragmentIcon:setTouchPriority(-(self.layerNum-1)*20-4)
                        fragmentIcon:setAnchorPoint(ccp(1,1))
                        local fscale = iconSize/fragmentIcon:getContentSize().width
                        fragmentIcon:setScale(fscale)
                        fragmentIcon:setPosition(ccp(self.tvWidth * 0.7 + addPosx,awardTip:getPositionY() + addPosy))
                        cellBg:addChild(fragmentIcon,1)

                        local numLabel=GetTTFLabel("x"..self.swBlueprint.addount, 21, "Helvetica-bold")
                        numLabel:setAnchorPoint(ccp(1,0))
                        numLabel:setPosition(fragmentIcon:getContentSize().width - 5, 5)
                        numLabel:setScale(1/fscale)
                        fragmentIcon:addChild(numLabel,1)

                        lineSp:setPosition(self.tvWidth * 0.5,0)
                    else
                        icon:setPosition(ccp(self.tvWidth * 0.3 + addPosx,icon:getPositionY() + addPosy))
                        local function clickHandler()
                            G_showNewPropInfo(self.layerNum+1,true,true,nil,superWeaponVoApi:getBlueprintItem(self.swBlueprint.gf,self.level),nil,nil,nil,nil,true)
                            return false
                        end
                        local fragmentIcon=superWeaponVoApi:getFragmentIcon(self.swBlueprint.gf,clickHandler)
                        fragmentIcon:setTouchPriority(-(self.layerNum-1)*20-4)
                        fragmentIcon:setAnchorPoint(ccp(1,1))
                        local fscale = iconSize/fragmentIcon:getContentSize().width
                        fragmentIcon:setScale(fscale)
                        fragmentIcon:setPosition(ccp(self.tvWidth * 0.7 + addPosx,awardTip:getPositionY() + addPosy))
                        cellBg:addChild(fragmentIcon,1)

                        local numLabel=GetTTFLabel("x1",21,"Helvetica-bold")
                        numLabel:setAnchorPoint(ccp(1,0))
                        numLabel:setPosition(fragmentIcon:getContentSize().width - 5, 5)
                        numLabel:setScale(1/fscale)
                        fragmentIcon:addChild(numLabel,1)

                        lineSp:setPosition(self.tvWidth * 0.5,0)
                    end
                else
                    local buyNum=superWeaponVoApi:getEnergyBuyNum()
                    local maxNum=superWeaponVoApi:getMaxBuyNum()
                    local addStr,strSize2 = "",23
                    if buyNum >= maxNum then
                        addStr = ","..getlocal("super_weapon_buyMax2")
                        strSize2 = 22
                    end

                    lineSp:setPosition(self.tvWidth * 0.5,35)

                    local noEnergy = GetTTFLabel(getlocal("super_weapon_noEnergy")..addStr,strSize2)
                    noEnergy:setAnchorPoint(ccp(0.5,0))
                    noEnergy:setPosition(ccp(self.tvWidth * 0.5,0))
                    noEnergy:setColor(G_ColorRed)
                    cellBg:addChild(noEnergy)
                end
                
            else
                lineSp:setPosition(self.tvWidth * 0.5,0)
            end

            

            if self.usePropList[idx + 1] then
                local useTb = self.usePropList[idx + 1]
                if useTb.p and useTb.p > 0 then
                    local pTip = GetTTFLabel(getlocal("super_weapon_autoUseProp"),24,"Helvetica-bold")
                    pTip:setAnchorPoint(ccp(0.5,0))
                    pTip:setPosition(ccp(self.tvWidth * 0.5,10))
                    pTip:setColor(G_ColorGreen2)
                    cellBg:addChild(pTip)
                elseif useTb.g and useTb.g > 0 then
                    local goldBg = self:addGoldTip(useTb.g)
                    cellBg:addChild(goldBg)
                end

                local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
                lineSp:setContentSize(CCSizeMake((self.tvWidth-40),4))
                lineSp:setPosition(ccp(self.tvWidth * 0.5, 45))
                cellBg:addChild(lineSp)
            end
        end

        local delay=CCDelayTime:create((idx + 1)*0.4)
        local callFunc=CCCallFunc:create(realShow)
        local seq=CCSequence:createWithTwoActions(delay,callFunc)
        cell:runAction(seq)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
       
    end
end

function superWeaponContinuousExploreDialog:addGoldTip(gemsNum)

    local bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function() end)
    bgSp:setPosition(ccp(self.tvWidth * 0.5,5))
    bgSp:setAnchorPoint(ccp(0.5,0))
    bgSp:setOpacity(0)
    local bgWidth = bgSp:getContentSize().height

    local tip1 = GetTTFLabel(getlocal("activity_tankjianianhua_Consume")..gemsNum,24,"Helvetica-bold")
    tip1:setPosition(ccp(0,bgWidth * 0.5))
    tip1:setAnchorPoint(ccp(0,0.5))
    bgSp:addChild(tip1)
    local tip1Width = tip1:getContentSize().width

    local gSp =CCSprite:createWithSpriteFrameName("IconGold.png")
    gSp:setAnchorPoint(ccp(0,0.5))
    local gSpScale = tip1:getContentSize().height/gSp:getContentSize().height
    gSp:setScale(gSpScale)
    gSp:setPosition(ccp(2 + tip1Width,tip1:getPositionY()))
    bgSp:addChild(gSp)
    local gSpWidth = gSp:getContentSize().width * gSpScale

    local tip2 = GetTTFLabel(getlocal("super_weapon_buyEnergy"),24,"Helvetica-bold")
    tip2:setAnchorPoint(ccp(0,0.5))
    tip2:setPosition(ccp(4 + tip1Width + gSpWidth,tip1:getPositionY()))
    bgSp:addChild(tip2)

    bgSp:setContentSize(CCSizeMake(tip1Width + gSpWidth + tip2:getContentSize().width,tip1:getContentSize().height + 2))

    return bgSp
end