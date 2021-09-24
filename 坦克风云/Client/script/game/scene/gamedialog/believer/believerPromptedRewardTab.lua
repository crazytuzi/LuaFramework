local believerPromptedRewardTab={}

function believerPromptedRewardTab:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	
	return nc
end

function believerPromptedRewardTab:init(layerNum,parent)
	self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent

    self.expandIdx={}
    self.normalHeight=150

    self:initLayer()

    return self.bgLayer
end

function believerPromptedRewardTab:initLayer()
	local believerCfg=believerVoApi:getBelieverCfg()
	local grade=believerVoApi:getMySegment()
    self.cellNum=SizeOfTable(believerCfg.upReward)

    self.segRewardInfoList={}
    for k,v in pairs(believerCfg.upReward) do
    	self.segRewardInfoList[k]={}
    	local all,detail={},{}
    	for kk,vv in pairs(v) do
    		local rewardlist=FormatItem(vv[2])
			table.insert(detail,rewardlist)
			table.insert(all,G_clone(vv[2]))
    	end
	    local totalRewards=G_mergeAllRewards(all)
	    totalRewards=FormatItem(totalRewards)
	    self.segRewardInfoList[k]={totalRewards,detail}
    end

    local fontSize=25
    local promptLb=GetTTFLabelWrap(getlocal("believer_reward_grade_prompt"),fontSize,CCSizeMake(G_VisibleSizeWidth-150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    promptLb:setAnchorPoint(ccp(0.5,0.5))
    promptLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-190))
    self.bgLayer:addChild(promptLb)

    local function infoHandler()
    	local tabStr={}
    	for i=1,4 do
    		table.insert(tabStr,getlocal("believer_reward_grade_info_"..i))
    	end
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
    end
    G_addMenuInfo(self.bgLayer,self.layerNum,ccp(G_VisibleSizeWidth-60,promptLb:getPositionY()),{},nil,nil,28,infoHandler,true)

	self.tvWidth,self.tvHeight,self.cellHeight=G_VisibleSizeWidth-40,G_VisibleSizeHeight-260,150
    self.expandHeight=self.tvHeight
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    self.tv:setPosition((G_VisibleSizeWidth-self.tvWidth)/2,G_VisibleSizeHeight-220-self.tvHeight)
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    local grade=believerVoApi:getMySegment()
    if grade and grade<=5 then
        local expandIdx=grade-1 --展开当前段位的奖励信息，idx从0开始，故展开的idx应该为grade-1
        if expandIdx<self.cellNum then
            self:cellClick(expandIdx+1000)
        end
    end
end

function believerPromptedRewardTab:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
		if self.expandIdx["k"..idx]~=nil then
			tmpSize=CCSizeMake(self.tvWidth,self.expandHeight)
		else
			tmpSize=CCSizeMake(self.tvWidth,self.normalHeight)
		end
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

		local expanded=false
		if self.expandIdx["k"..idx]==nil then
		    expanded=false
		else
		   	expanded=true
		end
		if expanded then
		    cell:setContentSize(CCSizeMake(self.tvWidth,self.expandHeight))
		else
		    cell:setContentSize(CCSizeMake(self.tvWidth,self.normalHeight))
		end

        local grade=idx+1
        local rewardInfo=self.segRewardInfoList[grade]
        if rewardInfo then
            local function cellClick(hd,fn,idx)
                return self:cellClick(idx,cell)
            end
        	local itemHeight=self.cellHeight-6
            local itemBg=LuaCCScale9Sprite:createWithSpriteFrameName("newUnReadBg.png",CCRect(5,23,1,1),cellClick)
            itemBg:setContentSize(CCSizeMake(self.tvWidth,itemHeight))
            itemBg:setPosition(self.tvWidth/2,cell:getContentSize().height-(self.cellHeight-itemHeight)/2-itemHeight/2)
            itemBg:setTag(1000+idx)
            itemBg:setTouchPriority(-(self.layerNum-1)*20-3)
            cell:addChild(itemBg)

            local iconBg=LuaCCScale9Sprite:createWithSpriteFrameName("newChat_head_shade.png",CCRect(16,16,2,2),function()end)
            iconBg:setContentSize(CCSizeMake(itemHeight-10,itemHeight-10))
            iconBg:setPosition(iconBg:getContentSize().width/2,itemHeight/2)
            itemBg:addChild(iconBg)

            local segIconSp=believerVoApi:getSegmentIcon(grade)
            if segIconSp then
                segIconSp:setScale(0.6)
                segIconSp:setPosition(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2-5)
                iconBg:addChild(segIconSp,2)
            end
            local fontSize=22
            local segNameStr=believerVoApi:getSegmentName(grade)
            local segmentLb=GetTTFLabelWrap(segNameStr,fontSize,CCSizeMake(self.tvWidth-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
            segmentLb:setAnchorPoint(ccp(0,0.5))
            segmentLb:setColor(G_ColorHighGreen)
            segmentLb:setPosition(ccp(iconBg:getPositionX()+itemHeight/2+10,itemHeight-segmentLb:getContentSize().height/2-15))
            itemBg:addChild(segmentLb)

            local rewardLb=GetTTFLabelWrap(getlocal("believer_total_reward")..":",fontSize-2,CCSizeMake(120,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            rewardLb:setAnchorPoint(ccp(0,0.5))
            rewardLb:setPosition(ccp(segmentLb:getPositionX(),(itemHeight-segmentLb:getContentSize().height-20)/2))
            itemBg:addChild(rewardLb)
            local tempLb=GetTTFLabel(getlocal("believer_total_reward")..":",fontSize)
            local realW=tempLb:getContentSize().width
            if realW>rewardLb:getContentSize().width then
            	realW=rewardLb:getContentSize().width
            end

            local allRewards=rewardInfo[1]
            local iconWidth=70
 			for k,item in pairs(allRewards) do
                local iconSp
                if item.key=="gems" or item.key=="gem" then
                    iconSp=CCSprite:createWithSpriteFrameName("iconGoldNew1.png")
                else
                    iconSp=G_getItemIcon(item,100,true,self.layerNum+1)
                end
 				iconSp:setScale(iconWidth/iconSp:getContentSize().width)
 				iconSp:setPosition(rewardLb:getPositionX()+realW+10+iconWidth/2+(k-1)*(iconWidth+10),rewardLb:getPositionY())
 				itemBg:addChild(iconSp)
                local numLb=GetTTFLabel("x"..item.num,fontSize-2)
                numLb:setAnchorPoint(ccp(0,0.5))
                numLb:setPosition(iconSp:getPositionX()+iconWidth/2+10,iconSp:getPositionY())
                itemBg:addChild(numLb)
 			end
			local btn
			if expanded==false then
				btn=CCSprite:createWithSpriteFrameName("sYellowAddBtn.png")
			else
				btn=CCSprite:createWithSpriteFrameName("sYellowSubBtn.png")
			end
			btn:setAnchorPoint(ccp(0,0))
			btn:setPosition(ccp(itemBg:getContentSize().width-10-btn:getContentSize().width,5))
			itemBg:addChild(btn)
            for k,v in pairs(rewardInfo[2]) do
                local flag=believerVoApi:getSegmentRewardFlags(grade,k)
                if flag==0 then
                    local tipSp=LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",CCRect(17,17,1,1),function () end)
                    tipSp:setPosition(btn:getContentSize().width-5,btn:getContentSize().height-5)
                    tipSp:setScale(0.6)
                    btn:addChild(tipSp)
                    do break end
                end
            end
            if expanded==true then
                local subSegRewards=rewardInfo[2]
                local count,iconSize=SizeOfTable(subSegRewards),80
                local subItemHeight=iconSize+20
                local exBgWidth,exBgHeight=self.tvWidth-10,count*(subItemHeight)+80
                local exBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function () end)
                exBg:setContentSize(CCSizeMake(exBgWidth,exBgHeight))
                exBg:setAnchorPoint(ccp(0.5,1))
                exBg:setTag(2)
                exBg:setPosition(self.tvWidth/2,self.expandHeight-self.cellHeight)
                cell:addChild(exBg)

                local canRewardList={}
                local state=0
                for k,rewardlist in pairs(subSegRewards) do
                    local smallIconSp=believerVoApi:getSegmentIcon(grade,k)
                    local iconPosX,iconPosY=20+iconSize/2,exBgHeight-10-iconSize/2-(k-1)*(subItemHeight)
                    if smallIconSp then
                        smallIconSp:setScale(iconSize/smallIconSp:getContentSize().width)
                        smallIconSp:setPosition(iconPosX,iconPosY)
                        exBg:addChild(smallIconSp)
                    end
                    local rewardLb=GetTTFLabelWrap(getlocal("donateReward"),fontSize-2,CCSizeMake(120,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                    -- if G_getCurChoseLanguage() == "ar" then
                    --     rewardLb=GetTTFLabelWrap(getlocal("donateReward"),fontSize-2,CCSizeMake(80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                    -- end
                    rewardLb:setAnchorPoint(ccp(0,0.5))
                    rewardLb:setPosition(iconPosX+iconSize/2+20,iconPosY)
                    exBg:addChild(rewardLb)

                    local tempLb=GetTTFLabel(getlocal("donateReward"),fontSize-2)
                    local realW=tempLb:getContentSize().width
                    if realW>rewardLb:getContentSize().width or G_getCurChoseLanguage() == "ar" then
                        realW=rewardLb:getContentSize().width
                    end
                    local iconWidth=60
                    for kk,item in pairs(rewardlist) do
                        local iconSp
                        if item.key=="gems" or item.key=="gem" then
                            iconSp=CCSprite:createWithSpriteFrameName("iconGoldNew1.png")
                        else
                            iconSp=G_getItemIcon(item,100,true,self.layerNum+1)
                        end
                        iconSp:setScale(iconWidth/iconSp:getContentSize().width)
                        iconSp:setPosition(rewardLb:getPositionX()+realW+10+iconWidth/2,iconPosY)
                        exBg:addChild(iconSp)

                        local numLb=GetTTFLabel("x"..item.num,fontSize-2)
                        numLb:setAnchorPoint(ccp(0,0.5))
                        numLb:setPosition(iconSp:getPositionX()+iconWidth/2+10,iconPosY)
                        exBg:addChild(numLb)
                    end

                    local str,color="",G_ColorRed
                    local flag=believerVoApi:getSegmentRewardFlags(grade,k)
                    if flag==-1 then --未完成
                        str=getlocal("local_war_incomplete")
                    elseif flag==0 then --可领取
                        str=getlocal("canReward")
                        color=G_ColorYellowPro
                        state=1
                    else --已领取
                        str=getlocal("activity_hadReward")
                        color=G_ColorGray
                    end
                    local stateLb=GetTTFLabelWrap(str,fontSize-2,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    stateLb:setPosition(exBgWidth-85,iconPosY)
                    stateLb:setColor(color)
                    exBg:addChild(stateLb)

                    local mLine=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function () end)
                    mLine:setContentSize(CCSizeMake(exBgWidth-20,mLine:getContentSize().height))
                    mLine:setPosition(exBgWidth/2,exBgHeight-k*subItemHeight)
                    exBg:addChild(mLine,1)
                    if flag==0 then --可领取的话，先插入到可领取奖励列表中
                        table.insert(canRewardList,G_clone(rewardlist))
                    end
                end
                canRewardList=G_mergeAllFormatRewards(canRewardList)
                local function getHandler()
                    if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                        local function getCallBack()
                            for k,v in pairs(canRewardList) do
                                G_addPlayerAward(v.type,v.key,v.id,v.num)
                            end
                            if self.tv then
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),28)
                                local recordPoint=self.tv:getRecordPoint()
                                self.tv:reloadData()
                                self.tv:recoverToRecordPoint(recordPoint)
                            end
                            if self.parent and self.parent.refreshRedTip then
                                self.parent:refreshRedTip(2)
                            end
                        end
                        local queue=believerVoApi:getMaxCanSegReward(grade)
                        -- print("grade,queue------???",grade,queue)
                        believerVoApi:getRewardRequest(2,{grade=grade,queue=queue},getCallBack)
                    end
                end
                local btnScale,priority=0.7,-(self.layerNum-1)*20-4
                local getItem=G_createBotton(exBg,ccp(exBgWidth/2,40),{getlocal("daily_scene_get"),22},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",getHandler,btnScale,priority)
                if state~=1 then --没有可领取的奖励，按钮置灰
                    getItem:setEnabled(false)
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

function believerPromptedRewardTab:cellClick(idx,cell)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        PlayEffect(audioCfg.mouseClick)
        if self.expandIdx["k"..(idx-1000)]==nil then
                self.expandIdx["k"..(idx-1000)]=idx-1000
                self.tv:openByCellIndex(idx-1000,self.normalHeight)
        else
            local exbg=tolua.cast(cell:getChildByTag(2),"LuaCCScale9Sprite")
            if exbg then
              exbg:setVisible(false)
            end
            self.expandIdx["k"..(idx-1000)]=nil
            self.tv:closeByCellIndex(idx-1000,self.expandHeight)
        end
    end
end

function believerPromptedRewardTab:dispose()
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    self.layerNum=nil
    self.parent=nil
    self.expandIdx=nil
    self.normalHeight=nil
    self.expandHeight=nil
    self.segRewardInfoList=nil
    self.tvWidth=nil
    self.tvHeight=nil
    self.cellHeight=nil
end

return believerPromptedRewardTab