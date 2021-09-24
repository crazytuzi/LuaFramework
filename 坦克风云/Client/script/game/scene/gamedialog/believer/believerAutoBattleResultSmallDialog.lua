local believerAutoBattleResultSmallDialog=smallDialog:new()

function believerAutoBattleResultSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function believerAutoBattleResultSmallDialog:showBattleResultDialog(battleData,layerNum,callback,parent)
  	local smdialog=believerAutoBattleResultSmallDialog:new()
	smdialog:initBattleResultDialog(battleData,layerNum,callback,parent)
	return smdialog
end

function believerAutoBattleResultSmallDialog:initBattleResultDialog(battleData,layerNum,callback,parent)
    self.isTouch=nil
    self.isUseAmi=true
    self.layerNum=layerNum
    self.parent=parent
    self.bgSize=CCSizeMake(560,G_VisibleSizeHeight-300)

    local function touchHander()
    end
    local dialogBg=G_getNewDialogBg2(self.bgSize,self.layerNum,touchHander,getlocal("believer_battle_result"),28)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer=dialogBg
    self:show()

  	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)
    self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)

    local itemBgWidth,itemBgHeight=self.bgSize.width-30,self.bgSize.height-40
    local itemBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20,20,1,1),function () end)
    itemBg:setContentSize(CCSizeMake(itemBgWidth,itemBgHeight))
    itemBg:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(itemBg)

    local cellHeightTb={}
    local fontSize,fontWidth=22,itemBgHeight-30
    local allBattleFlag=true --如果为false说明中途因部队数量不足，战斗中断
    local believerCfg=believerVoApi:getBelieverCfg()
    local cellNum=SizeOfTable(battleData)
    if cellNum<believerCfg.contiMatch then
    	cellNum=cellNum+1
    	allBattleFlag=false
    end
    
 	local contentTb={}
    for k,v in pairs(battleData) do
    	local content={}
    	local height=10+40 --10：上间距，40：下间距
    	local resultStr=getlocal("fight_content_result_win")
    	if v.isVictory~=1 then
			resultStr=getlocal("fight_content_result_defeat")
    	end
    	--战斗结果
    	local victoryStr=getlocal("believer_battle_numResult",{k,resultStr})
    	local victoryLb,lbheight=G_getRichTextLabel(victoryStr,{},fontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		content[1]=victoryStr
    	height=height+lbheight+5

    	--对手信息
    	local serverName=GetServerNameByID(((v.zid==0) and base.curZoneID or v.zid),true)
        local playerInfoStr=getlocal("believer_enemy_info")
        local npcNameStr=getlocal("believer_npc_name")
    	local playerName=believerVoApi:getEnemyNameStr(v.name)
        local lvStr=getlocal("fightLevel",{v.level})
        if npcNameStr==playerName then
            playerInfoStr=playerInfoStr..getlocal("believer_enemy_namestr2",{playerName,lvStr})
        else
            playerInfoStr=playerInfoStr..getlocal("believer_enemy_namestr",{serverName,playerName,lvStr})
        end
    	local playerLb,lbheight=G_getRichTextLabel(playerInfoStr,{},fontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		content[2]=playerInfoStr
    	height=height+lbheight+5

    	--生存率
		local dmgrateStr=getlocal("believer_kill_rate",{v.dmgrate/10})
	   	local dmgrateLb,lbheight=G_getRichTextLabel(dmgrateStr,{},fontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		content[3]=dmgrateStr
    	height=height+lbheight+5

  --   	--平均生存率
  --   	local aveDmgrateStr=getlocal("believer_avedmgRate",{v.aveDmgrate/10})
		-- local aveDmgrateLb,lbheight=G_getRichTextLabel(aveDmgrateStr,{},fontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		-- content[4]=aveDmgrateStr
  --   	height=height+lbheight+5

    	--积分
    	local scoreStr=getlocal("believer_get_score",{v.score})
		local scoreLb,lbheight=G_getRichTextLabel(scoreStr,{},fontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		content[5]=scoreStr
    	height=height+lbheight+5

    	--段位
    	local segNameStr=getlocal("believer_gradeto",{believerVoApi:getSegmentName(v.grade,v.queue)})
		local gradeLb,lbheight=G_getRichTextLabel(segNameStr,{},fontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		content[6]=segNameStr
    	height=height+lbheight+5

    	--联赛币
    	local kcoinLbStr=getlocal("believer_get_kcoin",{v.kcoin})
    	local kcoinLb,lbheight=G_getRichTextLabel(getlocal("believer_get_kcoin",{v.kcoin}),{},fontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		content[7]=kcoinLbStr
    	height=height+lbheight

    	cellHeightTb[k]=height
    	contentTb[k]=content
    end
    if allBattleFlag==false then
    	local tipStr=getlocal("believer_battle_trooplack")
    	local tipLb,lbheight=G_getRichTextLabel(tipStr,{},fontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    	cellHeightTb[cellNum]=lbheight+10
    	contentTb[cellNum]={tipStr}
    end
	local tempContentTb
    if type(contentTb)=="table" and SizeOfTable(contentTb)>1 then
        tempContentTb={}
    else
        tempContentTb=contentTb
    end

    local tvWidth,tvHeight=itemBgWidth,itemBgHeight-100
    local isMoved=false
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return SizeOfTable(tempContentTb)
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(tvWidth,cellHeightTb[idx+1])
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local cellHeight=cellHeightTb[idx+1]
            local result=battleData[idx+1]
            local content=contentTb[idx+1]
            if content then
            	local posY=cellHeight-10
            	for k,v in pairs(content) do
            		local color={}
            		if allBattleFlag==false and (idx+1)==cellNum then
            			color={G_ColorRed}
            		elseif result then
            			if k==1 then
            				if result.isVictory==1 then
            					color={nil,G_ColorGreen,nil}
            				else
            					color={nil,G_ColorRed,nil}
            				end
            			else
            				color={nil,G_ColorYellowPro,nil}
            			end
            		end
					local textLb,lbheight=G_getRichTextLabel(v,color,fontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
					textLb:setAnchorPoint(ccp(0,1))
					textLb:setPosition(20,posY)
					cell:addChild(textLb)
					if k==6 then --显示联赛币
		    -- 			local iconWidth=40
						-- local kCoinSp=CCSprite:createWithSpriteFrameName("believerKcoin.png")
						-- kCoinSp:setAnchorPoint(ccp(0,0.5))
						-- kCoinSp:setPosition(ccp(rewardLb:getPositionX()+rewardLb:getContentSize().width,rewardLb:getPositionY()))
						-- kCoinSp:setScale(iconWidth/kCoinSp:getContentSize().width)
						-- cell:addChild(kCoinSp)
        			end
        			posY=posY-lbheight-5
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
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.tv:setPosition(ccp((self.bgSize.width-tvWidth)/2,110))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)

    if type(contentTb)=="table" and SizeOfTable(contentTb)>1 then
        local acArr=CCArray:create()
        for k,v in pairs(contentTb) do
        	if tempContentTb[k]==nil then
				local function showNextMsg()
	                if self and self.tv and v then
	                    table.insert(tempContentTb,v)
	                    if k==cellNum then
	                        isEnd=true
	                    end
	                    self.tv:insertCellAtIndex(k-1)
	                end
	            end
	            local callFunc=CCCallFuncN:create(showNextMsg)
	            local delay=CCDelayTime:create(1)

	            acArr:addObject(delay)
	            acArr:addObject(callFunc)
        	end
        end
        local seq=CCSequence:create(acArr)
        self.bgLayer:runAction(seq)
    end
  
    local function confirm()
        PlayEffect(audioCfg.mouseClick)
        if callback~=nil then
            callback()
        end
        self:close()
        if self.parent and self.parent.backToMainDialogHandler then
            self.parent:backToMainDialogHandler()
            self.parent=nil
        end
    end
    local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",confirm,2,getlocal("ok"),25/0.8)
    sureItem:setScale(0.8)
    local sureMenu=CCMenu:createWithItem(sureItem)
    sureMenu:setPosition(ccp(self.bgSize.width/2,60))
    sureMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    dialogBg:addChild(sureMenu)
    
    local function touchLuaSpr()
         
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,self.layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
end

return believerAutoBattleResultSmallDialog