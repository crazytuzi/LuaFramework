acChrisEveSmallDialog=smallDialog:new()

function acChrisEveSmallDialog:new(layerNum)
    local nc={
            bgLayer,
        }
    setmetatable(nc,self)
    self.__index=self
    self.getAllRewardBtn=nil
    self.layerNum=layerNum
    self.curPage=1
    self.maxNum=0
    self.rewardNumLb=nil
    self.listNum=0
    self.pageLb=nil
    self.awardIndex=0;

    self.listNumTb={}
    self.dialogWidth =nil
    self.dialogHeight =nil
    self.loveGems=nil
    self.recNoNameList ={}
    self.firT =0
    self.isHasName =0 -- 0 无 1 firT 2 recList 3 recNoNameList
    self.recNeedLoveGems=0
    self.maxNumTb ={}
    self.whiIdxGift=1
    self.isRefresh=false
    self.isError=false
    self.version=acChrisEveVoApi:getVersion()
    return nc
end
function acChrisEveSmallDialog:close()
    self.version=nil
    self.isError=false
    self.whiIdxGift=1
    self.layerNum =0
    self.dialogWidth =nil
    self.dialogHeight =nil
    self.loveGems=nil
    self.recNoNameList =nil
    self.firT =nil
    self.isHasName =nil
    self.maxNum=1
    self.rewardNumLb=nil
    self.listNum=0
    self.pageLb=nil
    self.awardIndex=0;
    self.curPage=1
    self.maxNumTb =nil
    self.isRefresh =false
    if self and self.touchDialogBg then
        self.touchDialogBg:removeFromParentAndCleanup(true)
        self.touchDialogBg=nil
    end
    if self and self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    base:removeFromNeedRefresh(self)
end
--设置对话框里的tableView
function acChrisEveSmallDialog:initTableView()
    if self.version == 5 then
        spriteController:addPlist("public/believer/believerMain.plist")
        spriteController:addTexture("public/believer/believerMain.plist")
    end
	local subLbSize = 16
	local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        subLbSize =26
        strSize2 =25
    end

    acChrisEveVoApi:setGAndListInTb()
    self:refreshPageAndNum()

    local function touch( ... )
        
    end
    local capInSet = CCRect(130, 50, 1, 1)
	local dialogBg = nil
    if self.version == 5 then
        dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30, 30, 1, 1),function() end)
    else
        dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),touch)
    end
    dialogBg:setContentSize(CCSizeMake(560,800))
    self.bgLayer=dialogBg
    self.bgLayer:setPosition(getCenterPoint(sceneGame))
    dialogBg:setTouchPriority(-(self.layerNum-1)*20-3)
    -- self.layerNum=self.layerNum+1
    self.dialogHeight=800

	self.dialogWidth=560

    -- 翻页start
    self:initPageBtn()
    -- 翻页end

    local capInSet1 = CCRect(10, 10, 1, 1)
    self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",capInSet1,touch);
    self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-3)
    local rect1=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.touchDialogBg:setContentSize(rect1)
    self.touchDialogBg:setOpacity(250)
    self.touchDialogBg:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.touchDialogBg,3);
    -- self.layerNum=self.layerNum+1

    if(acChrisEveVoApi:isNormalVersion()==false) and self.version ~= 5 then
        local cloud1 = CCSprite:createWithSpriteFrameName("snowBg_1.png")
        cloud1:setAnchorPoint(ccp(0,0.5))
        cloud1:setScale(0.95)
    
        cloud1:setPosition(ccp(0,dialogBg:getContentSize().height-10))
        dialogBg:addChild(cloud1,3)
    
        local cloud2 = CCSprite:createWithSpriteFrameName("snowBg_2.png")
        cloud2:setAnchorPoint(ccp(1,1))
        cloud2:setScale(0.95)
        cloud2:setPosition(ccp(dialogBg:getContentSize().width+5,dialogBg:getContentSize().height))
        dialogBg:addChild(cloud2,3)

        local bellPic = CCSprite:createWithSpriteFrameName("bellPic.png")
        -- bellPic:setScale(0.8)
        bellPic:setAnchorPoint(ccp(0.5,0.5))
        bellPic:setPosition(ccp(30,dialogBg:getContentSize().height-20))
        dialogBg:addChild(bellPic,3)
    end

    if self.version == 5 then
        local v5_bgSp=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
        v5_bgSp:setPosition(dialogBg:getContentSize().width*0.5,dialogBg:getContentSize().height-30)
        v5_bgSp:setAnchorPoint(ccp(0.5,1))
        dialogBg:addChild(v5_bgSp)
    end

    -- 标题文本
    local orangeMask = CCSprite:createWithSpriteFrameName("orangeMask.png")
    orangeMask:setAnchorPoint(ccp(0.5,1))
    orangeMask:setScaleX(0.9)
    orangeMask:setScaleY(1.1)
    orangeMask:setPosition(ccp(dialogBg:getContentSize().width*0.5,dialogBg:getContentSize().height-40))
    dialogBg:addChild(orangeMask)

    local loveGemsNum = acChrisEveVoApi:getLoveGems()-acChrisEveVoApi:getExpendLoveGems()
    self.loveGems = GetTTFLabelWrap(getlocal("activity_chrisEve_curLoveGems",{loveGemsNum}),strSize2,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.loveGems:setColor(G_ColorYellowPro)
    self.loveGems:setAnchorPoint(ccp(0.5,0.5))
    self.loveGems:setPosition(dialogBg:getContentSize().width*0.5,dialogBg:getContentSize().height-40-orangeMask:getContentSize().height*0.5)
    dialogBg:addChild(self.loveGems,1)
    --TrialSquadBox
    if self.version == 5 then
        orangeMask:setOpacity(0)
    end

    -- 全部领取
    local function getAllRewardHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        self:socketRecAll()
    end
    local function closeHandler( ... )
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		-- acChrisEveVoApi:setIsNewData(1)------
		return self:close()    
	end
    local closeBtn=GetButtonItem("newGrayBtn.png","newGrayBtn_Down.png","newGrayBtn.png",closeHandler,2,getlocal("fight_close"),24/0.8)
    closeBtn:setScale(0.8)
    closeBtn:setAnchorPoint(ccp(0.5,0.5))
    local closeBtnMenu=CCMenu:createWithItem(closeBtn)
    closeBtnMenu:setPosition(ccp(dialogBg:getContentSize().width/4,closeBtn:getContentSize().height/2+21))
    closeBtnMenu:setTouchPriority(-(99-1)*20-1)
    dialogBg:addChild(closeBtnMenu,2)
    -- self.layerNum=self.layerNum+1

    self.getAllRewardBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",getAllRewardHandler,11,getlocal("alien_tech_acceptAll"),24/0.8)
    self.getAllRewardBtn:setScale(0.8)
    self.getAllRewardBtn:setAnchorPoint(ccp(0.5,0.5))
    local getAllRewardMenu=CCMenu:createWithItem(self.getAllRewardBtn)
    getAllRewardMenu:setPosition(ccp(dialogBg:getContentSize().width/4*3,self.getAllRewardBtn:getContentSize().height/2+21))
    getAllRewardMenu:setTouchPriority(-(99-1)*20-1)
    dialogBg:addChild(getAllRewardMenu,2)
    -- self.layerNum=self.layerNum+1
    -- 奖励列表
    local tvHight= self.loveGems:getPositionY()-150
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(dialogBg:getContentSize().width-20,tvHight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    self.tv:setAnchorPoint(ccp(0,1))
    self.tv:setPosition(ccp(10,100))
    dialogBg:addChild(self.tv,3)
    -- self.layerNum=self.layerNum+1

    local function touch3( ... )
        -- print("----dmj======touch3")
    end
    local topSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",capInSet1,touch3);
    topSp:setAnchorPoint(ccp(0,1))
    topSp:setContentSize(CCSizeMake(dialogBg:getContentSize().width,dialogBg:getContentSize().height-self.loveGems:getPositionY()-100))
    dialogBg:addChild(topSp)
    topSp:setPosition(ccp(0,dialogBg:getContentSize().height))
    topSp:setTouchPriority(-(self.layerNum-1)*20-9)
    topSp:setVisible(false)

    local bottomSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",capInSet1,touch3);
    bottomSp:setAnchorPoint(ccp(0,0))
    bottomSp:setContentSize(CCSizeMake(dialogBg:getContentSize().width,self.getAllRewardBtn:getContentSize().height+20))
    dialogBg:addChild(bottomSp)
    bottomSp:setPosition(ccp(0,0))
    bottomSp:setTouchPriority(-(self.layerNum-1)*20-9)
    bottomSp:setVisible(false)
    base:addNeedRefresh(self)
    return self.bgLayer
end

function acChrisEveSmallDialog:refreshPageAndNum()
    self.maxNumTb={}
    local noNameGiftTb
    noNameGiftTb,self.maxNum=acChrisEveVoApi:getRecGiftTbNoName()
    for i=1,math.floor(self.maxNum/10) do
        table.insert(self.maxNumTb,10)
    end
    if self.maxNum%10 >0 then
        table.insert(self.maxNumTb,self.maxNum%10)
    end
    if self.pageLb then
        local pageStr = self.curPage.."/"..acChrisEveVoApi:getMaxPage()
        self.pageLb:setString(pageStr)
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acChrisEveSmallDialog:eventHandler(handler,fn,idx,cel)
	local recGiftTb = acChrisEveVoApi:getRecGiftTb()
	local recGiftTbNoName=nil 
	recGiftTbNoName,self.maxNum =acChrisEveVoApi:getRecGiftTbNoName()
	if self.firT ==0 then
		self.isHasName =1
	end
 	if recGiftTb and SizeOfTable(recGiftTb)>0 or SizeOfTable(acChrisEveVoApi:getGAndListInTb()) > 0 then
 		self.isHasName =2
 	elseif recGiftTbNoName and SizeOfTable(recGiftTbNoName)>0 then
 		self.isHasName =3
 	end
 	-- print("self.isHasName----->",self.isHasName)
    local temHeight = 260-26
    local temLbHeight = 28
    if fn=="numberOfCellsInTableView" then
        local listNum = 0
        -- print("self.maxNum-----1>",self.maxNum)
        if self.maxNum <11 then
            listNum =self.maxNum
        else
           listNum =self.maxNumTb[self.curPage]
           -- print("self.maxNum-----2>",self.maxNum)
        end
        -- print("self.maxNum-----3>",self.maxNum)
        if self.firT ==0 then
        	listNum =listNum+1
        end

        return listNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,temHeight)

        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local strSize2 = 16
        if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
            strSize2 =23
        end
        local sizeW = self.bgLayer:getContentSize().width-20
		local sizeH = temHeight-10

		local function touch( )
		end 
        local sprieBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),touch)--"believerRankItemBg.png",CCRect(18,21,1,1)
        sprieBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,temHeight-10))
        sprieBg:setAnchorPoint(ccp(0,0))
        sprieBg:setPosition(ccp(0,10))
        sprieBg:setTouchPriority(-(self.layerNum-1)*20-2)
        cell:addChild(sprieBg)

		local titleSp1= nil 
        if self.version == 5 then--
            titleSp1 = LuaCCScale9Sprite:createWithSpriteFrameName("believerRankItemBg.png",CCRect(18,21,1,1),touch)
        else
            titleSp1 = LuaCCScale9Sprite:createWithSpriteFrameName("TrialSquadBox.png",CCRect(20, 20, 10, 10),touch)
        end
		titleSp1:setContentSize(CCSizeMake(sizeW,sizeH*0.3))
		titleSp1:ignoreAnchorPointForPosition(false)
		titleSp1:setAnchorPoint(ccp(0.5,0))
		titleSp1:setIsSallow(false)
		titleSp1:setTouchPriority(-(self.layerNum-1)*20-2)
		titleSp1:setPosition(ccp(sizeW*0.5,sizeH*0.7))
		sprieBg:addChild(titleSp1,1)

        self.firT  = acChrisEveVoApi:getFirstRecTime()
		local recGiftTb = acChrisEveVoApi:getGAndListInTb( )--数据从新排列
		local recGiftTbNoName = acChrisEveVoApi:getRecGiftTbNoName() --准确的礼包数据
		local giftNums = 0 --礼物数量 用于 recGiftTbNoName
		local playerName = nil
		local formatRewardTb = nil
		local awardName = nil
		local awardPic = nil
		local awardNum = nil
		local curIdx = (self.curPage-1)*10+idx+1
		-- print("curIdx---->",curIdx)
		-- self.isHasName =3----测试使用
        -- print("self.isHasName=========",self.isHasName)
        local giftUseUpLoveGems=0 --消耗值
        local user = nil
        local giftId = nil
        -- print("self.isHasName=====>>>>",self.isHasName)
		if self.isHasName ==2 then
			if self.firT  ==0 then
				if idx ==0 then
                        if self.curPage > 1 and self.maxNumTb[self.curPage] ==0 then
                            self.isError =true
                            return cell
                        end
                        if(acChrisEveVoApi:isNormalVersion()==false) and self.version ~= 5 then
        					playerName =getlocal("activity_chrisEve_oldMan")
                        else
                            playerName =getlocal("activity_chrisEve_oldMan_1")
                        end
    					giftUseUpLoveGems =0
    					formatRewardTb =acChrisEveVoApi:getFirstreward()
    					giftNums =1
				elseif idx >0 then
                    -- print("recGiftTb[curIdx-1][2]----curIdx------>",recGiftTb[curIdx-1][2],curIdx)
                        if recGiftTb[curIdx-1] ==nil  then
                            self.isError =true
                            return cell
                        end
    					playerName = recGiftTb[curIdx-1][2]
    					giftUseUpLoveGems,formatRewardTb =acChrisEveVoApi:getUseUpLoveGems(recGiftTb[curIdx-1][1])
                        giftId=recGiftTb[curIdx-1][1]
                        user=recGiftTb[curIdx-1][4]
				end
			elseif recGiftTb[curIdx] and  recGiftTb[curIdx][2] then
				playerName = recGiftTb[curIdx][2]
				giftUseUpLoveGems,formatRewardTb =acChrisEveVoApi:getUseUpLoveGems(recGiftTb[curIdx][1])
                giftId=recGiftTb[curIdx][1]
                user=recGiftTb[curIdx][4]
            elseif recGiftTb[curIdx] ==nil then
                self.isError =true
                return cell
			end
		elseif self.isHasName ==3 then
			if self.firT  ==0 then
				if idx ==0 then
					giftUseUpLoveGems =0
					formatRewardTb =acChrisEveVoApi:getFirstreward()
					giftNums =1
				elseif idx >0 then
					formatRewardTb,giftUseUpLoveGems,giftNums =acChrisEveVoApi:getUseUpLoveGemsNoName(idx)
                    giftId=idx
				end
                if(acChrisEveVoApi:isNormalVersion() or self.version == 5 )then
                    playerName =getlocal("activity_chrisEve_oldMan_1")
                else
    				playerName =getlocal("activity_chrisEve_oldMan")
                end
			else
                if(acChrisEveVoApi:isNormalVersion() or self.version == 5 )then
                    playerName =getlocal("activity_chrisEve_oldMan_1")
                else
                    playerName =getlocal("activity_chrisEve_oldMan")
                end
				formatRewardTb,giftUseUpLoveGems,giftNums =acChrisEveVoApi:getUseUpLoveGemsNoName(idx+1)
                giftId=idx+1
			end
		elseif self.isHasName ==1 then
            if(acChrisEveVoApi:isNormalVersion() or self.version == 5 )then
                playerName =getlocal("activity_chrisEve_oldMan_1")
            else
                playerName =getlocal("activity_chrisEve_oldMan")
            end

			giftUseUpLoveGems =0
			formatRewardTb =acChrisEveVoApi:getFirstreward()
		end
----------------
		-- print("~~SizeOfTable(formatRewardTb)~~~~",SizeOfTable(formatRewardTb))
        if formatRewardTb ==nil then
            self.isError =true
            return cell
        end
    		awardPic =G_getItemIcon(formatRewardTb,100,false,self.layerNum+1,nil)
    		awardName =formatRewardTb.name
    		awardNum =formatRewardTb.num 

    		local playerNameStr = GetTTFLabelWrap(getlocal("activity_chrisEve_fromPlayerGift",{playerName}),strSize2,CCSizeMake(titleSp1:getContentSize().width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            playerNameStr:setAnchorPoint(ccp(0,0.5))
            playerNameStr:setPosition(ccp(20,titleSp1:getContentSize().height*0.5))
            titleSp1:addChild(playerNameStr,1)

    		local giftBox
            if(acChrisEveVoApi:isNormalVersion() or self.version == 5 )then
                giftBox = CCSprite:createWithSpriteFrameName("acChrisBox.png")
                giftBox:setScale(0.3)
            else
                giftBox = CCSprite:createWithSpriteFrameName("friendBtn.png")
                giftBox:setScale(0.5)
            end
    	    giftBox:setAnchorPoint(ccp(1,0.5))
    	    giftBox:setPosition(ccp(titleSp1:getContentSize().width-5,titleSp1:getContentSize().height*0.5))
    	    titleSp1:addChild(giftBox,1)

    	    local giftBoxIdx,xPic=nil
    	    if giftNums> 0 and self.isHasName==3 then
    		    xPic =CCSprite:createWithSpriteFrameName("xPic.png")
    		    xPic:setScale(0.4)
    		    xPic:setAnchorPoint(ccp(1,0.5))
    		    xPic:setPosition(ccp(titleSp1:getContentSize().width-55,titleSp1:getContentSize().height*0.5))
    		    titleSp1:addChild(xPic,1)
    		    
    		    giftBoxIdx =GetBMLabel(giftNums,G_GoldFontSrc,25)
    		    giftBoxIdx:setPosition(ccp(titleSp1:getContentSize().width-85,titleSp1:getContentSize().height*0.5))
    		    giftBoxIdx:setAnchorPoint(ccp(1,0.5))
    		    titleSp1:addChild(giftBoxIdx,1)
    		end
    -----
    		--"PanelPopup.png"
            local downBg = nil
            if self.version == 5 then
                downBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),touch)
            else
    		    downBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)
            end
    		downBg:setContentSize(CCSizeMake(sizeW,sizeH*0.7))
    		downBg:ignoreAnchorPointForPosition(false)
    		downBg:setAnchorPoint(ccp(0.5,1))
    		downBg:setIsSallow(false)
    		downBg:setTouchPriority(-(self.layerNum-1)*20-2)
    		downBg:setPosition(ccp(sizeW*0.5,sizeH*0.7))
    		sprieBg:addChild(downBg,1)

            if self.version == 5 then
                local subTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,16,1,1),function() end)
                subTitleBg:setContentSize(CCSizeMake(sizeW,32))
                subTitleBg:setPosition(ccp(downBg:getContentSize().width*0.5,downBg:getContentSize().height-1))
                subTitleBg:setAnchorPoint(ccp(0.5,1))
                downBg:addChild(subTitleBg)
            end

    		local groupSelf = CCSprite:createWithSpriteFrameName("groupSelf.png")
    	    groupSelf:setScaleY(40/groupSelf:getContentSize().height)
    	    groupSelf:setScaleX(5)
    	    groupSelf:setPosition(ccp(downBg:getContentSize().width*0.5,downBg:getContentSize().height-1))
    	    groupSelf:ignoreAnchorPointForPosition(false)
    	    groupSelf:setAnchorPoint(ccp(0.5,1))
    	    downBg:addChild(groupSelf)
            if self.version == 5 then
                groupSelf:setOpacity(0)
            end
    	    --activity_chrisEve_useUpLoveGems
    	    self.recNeedLoveGems =giftUseUpLoveGems +self.recNeedLoveGems 
    	    local useUpLoveGems = GetTTFLabelWrap(getlocal("activity_chrisEve_useUpLoveGems",{giftUseUpLoveGems}),strSize2,CCSizeMake(titleSp1:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            useUpLoveGems:setAnchorPoint(ccp(0,0.5))
            useUpLoveGems:setPosition(ccp(20,downBg:getContentSize().height-20))
            downBg:addChild(useUpLoveGems,1)
            if giftUseUpLoveGems ==0 then
            	useUpLoveGems:setVisible(false)
            end

            awardPic:setPosition(ccp(20,5))
            awardPic:setAnchorPoint(ccp(0,0))
            awardPic:setScale(110/awardPic:getContentSize().width)
            downBg:addChild(awardPic)

            local posW = 150
            awardNameStr = GetTTFLabelWrap(awardName,strSize2,CCSizeMake(titleSp1:getContentSize().width-350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            awardNameStr:setAnchorPoint(ccp(0,0))
            awardNameStr:setPosition(ccp(posW,65))
            downBg:addChild(awardNameStr)

            awardNumStr	=GetTTFLabelWrap(getlocal("alliance_challenge_prop_num",{awardNum}),strSize2,CCSizeMake(titleSp1:getContentSize().width-350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            awardNumStr:setAnchorPoint(ccp(0,0))
            awardNumStr:setPosition(ccp(posW,20))
            downBg:addChild(awardNumStr)

            local allGiftNums = nil
            if giftNums >0 then
            	allGiftNums =giftNums*formatRewardTb.num
            else
            	allGiftNums = formatRewardTb.num
            end
            -- print("formatRewardTb.name---->",formatRewardTb.name)
            local chatMsg
            if(acChrisEveVoApi:isNormalVersion() or self.version == 5 )then
                chatMsg=getlocal("activity_chrisEve_chatMes_1",{playerVoApi:getPlayerName(),playerName,formatRewardTb.name,allGiftNums})
            else
                chatMsg=getlocal("activity_chrisEve_chatMes",{playerVoApi:getPlayerName(),playerName,formatRewardTb.name,allGiftNums})
            end
            ---11111-------
            local function touch33(tag,object)
            	if G_checkClickEnable()==false then
    	            do
    	                return
    	            end
    	        else
    	            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
    	        end
            	local firT = acChrisEveVoApi:getFirstRecTime()
            	local idx = tag-20
            	local action = nil
            	local method = nil
            	
            	if firT ==0 and idx ==0 then
            		action="firstreward"
            	else
            		method =0
            		action="gift"
            	end
 
            	local needLoves = giftUseUpLoveGems
            	local currLoves = acChrisEveVoApi:getLoveGems()-acChrisEveVoApi:getExpendLoveGems()
            	-- print("needLoves---currloves-----allloves-----expendloves----->",needLoves,currLoves,acChrisEveVoApi:getLoveGems(),acChrisEveVoApi:getExpendLoveGems())
            	if currLoves < needLoves then
            		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_chrisEve_noLove"),30)
                    do return end
            	end
                if self.isError ==true then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("netiswrong"),30)
                    do return end
                end
            	local function recCallBack(fn,data)
                      local ret,sData=base:checkServerData(data)
                      if ret ==true then
                      	  
    	                  if sData.data.shengdanqianxi.f ~= acChrisEveVoApi:getFirstRecTime() then
                            local reward = acChrisEveVoApi:getFirstreward()
                            G_addPlayerAward(reward.type,reward.key,reward.id,reward.num)
    	                  	acChrisEveVoApi:setFirstRecTime(sData.data.shengdanqianxi.f)
    	                  end
    	                  if sData.data.shengdanqianxi.d then
    	                  	acChrisEveVoApi:setExpendLoveGems(sData.data.shengdanqianxi.d)
    	                  else
    			            acChrisEveVoApi:setExpendLoveGems()
    	                  end
    	                  if sData.data.shengdanqianxi.g then
    	                  	acChrisEveVoApi:setRecGiftTbNoName(sData.data.shengdanqianxi.g)
    	                  else
    			            acChrisEveVoApi:setRecGiftTbNoName()
    	                  end
                          -- if sData.data and sData.data.reward then
                                
                          -- end
                          local loveGemsNum = acChrisEveVoApi:getLoveGems()-acChrisEveVoApi:getExpendLoveGems()
                          self.loveGems:setString(getlocal("activity_chrisEve_curLoveGems",{loveGemsNum}))
                            self.recNeedLoveGems=self.recNeedLoveGems-giftUseUpLoveGems
                         --发送系统公告 
                        chatVoApi:sendSystemMessage(chatMsg)

    					  local showStr=getlocal("congratulationsGet",{formatRewardTb.name.." x"..allGiftNums})
    					  smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),showStr,30)
                  		  local function sendRequestCallBack(fn,data)
    			              local ret,sData=base:checkServerData(data)
    			              if ret ==true then
    			               	  if sData.data and sData.data and sData.data.list then
    			                    acChrisEveVoApi:setRecGiftTb(sData.data.list)
    			                  else
    			                  	acChrisEveVoApi:setRecGiftTb()
    			                  end
    			                  acChrisEveVoApi:setGAndListInTb()
                                  local otherData = nil
                                  otherData,self.maxNum =acChrisEveVoApi:getRecGiftTbNoName(0)

                                    --重新计算每一个页面的礼包个数
                                    self:refreshPageAndNum()
                                    --清空全部领取所需要的爱心值
                                    self.recNeedLoveGems=0
                                    if SizeOfTable(self.maxNumTb)<self.curPage then
                                        self:leftPage()
                                    end
                                    -- print("self.maxNum---->",self.maxNum)
                                  self.firT  = acChrisEveVoApi:getFirstRecTime()
    		                      self.tv:reloadData()
    		                      acChrisEveVoApi:setIsNewData(3)
                                  if acChrisEveVoApi:getRecGiftTbNoName() ==nil or  SizeOfTable(acChrisEveVoApi:getRecGiftTbNoName())==0 then
                                    return self:close()
                                  end
    			              end
    			          end
    			          socketHelper:chrisEveSend(sendRequestCallBack,"get")
                      end

                end--callback,action,method,sid,tuid,rank,user
                -- print("action,method,giftId,user------>",action,method,giftId,user)
              	socketHelper:chrisEveSend(recCallBack,action,method,giftId,nil,nil,user)
            	
            end 
            local recBtn =GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touch33,20+idx,getlocal("daily_scene_get"),24/0.8,21)
    	    recBtn:setScale(0.8)
            recBtn:setAnchorPoint(ccp(1,0))
    	    local recBtnMenu=CCMenu:createWithItem(recBtn)
    	    recBtnMenu:setPosition(ccp(downBg:getContentSize().width-10,25))
    	    -- recBtnMenu:setIsSallow(true)
    	    recBtnMenu:setTouchPriority(-(self.layerNum-1)*20-7)
    	    downBg:addChild(recBtnMenu,1)  
----------------
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
       
    end
end



-- 翻页按钮
function acChrisEveSmallDialog:initPageBtn()
    
    local scale=1.3
    if self.leftBtn==nil then
        local function leftPageHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            if self.isAnimation==true or (battleScene and battleScene.isBattleing==true) then
                do return end
            end
            PlayEffect(audioCfg.mouseClick)
            self:leftPage()
        end
        self.leftBtn=GetButtonItem("leftBtnGreen.png","leftBtnGreen.png","leftBtnGreen.png",leftPageHandler,11,nil,nil)
        self.leftBtn:setScale(scale)
        local leftMenu=CCMenu:createWithItem(self.leftBtn)
        leftMenu:setAnchorPoint(ccp(0.5,0.5))
        leftMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        self.bgLayer:addChild(leftMenu,6)
        leftMenu:setPosition(ccp(-15,self.bgLayer:getContentSize().height/2))

        local posX,posY=leftMenu:getPosition()
        local posX2=posX+20

        local mvTo=CCMoveTo:create(0.5,ccp(posX,posY))
        local fadeIn=CCFadeIn:create(0.5)
        local carray=CCArray:create()
        carray:addObject(mvTo)
        carray:addObject(fadeIn)
        local spawn=CCSpawn:create(carray)

        local mvTo2=CCMoveTo:create(0.5,ccp(posX2,posY))
        local fadeOut=CCFadeOut:create(0.5)
        local carray2=CCArray:create()
        carray2:addObject(mvTo2)
        carray2:addObject(fadeOut)
        local spawn2=CCSpawn:create(carray2)

        local seq=CCSequence:createWithTwoActions(spawn2,spawn)
        leftMenu:runAction(CCRepeatForever:create(seq))
    end

    if self.rightBtn==nil then
        local function rightPageHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            if self.isAnimation==true or (battleScene and battleScene.isBattleing==true) then
                do return end
            end
            PlayEffect(audioCfg.mouseClick)
            self:rightPage()
        end
        self.rightBtn=GetButtonItem("leftBtnGreen.png","leftBtnGreen.png","leftBtnGreen.png",rightPageHandler,11,nil,nil)
        self.rightBtn:setRotation(180)
        self.rightBtn:setScale(scale)
        local rightMenu=CCMenu:createWithItem(self.rightBtn)
        rightMenu:setAnchorPoint(ccp(0.5,0.5))
        rightMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        self.bgLayer:addChild(rightMenu,6)

        rightMenu:setPosition(ccp(self.bgLayer:getContentSize().width+15,self.bgLayer:getContentSize().height/2))

        local posX,posY=rightMenu:getPosition()
        local posX2=posX-20

        local mvTo=CCMoveTo:create(0.5,ccp(posX,posY))
        local fadeIn=CCFadeIn:create(0.5)
        local carray=CCArray:create()
        carray:addObject(mvTo)
        carray:addObject(fadeIn)
        local spawn=CCSpawn:create(carray)

        local mvTo2=CCMoveTo:create(0.5,ccp(posX2,posY))
        local fadeOut=CCFadeOut:create(0.5)
        local carray2=CCArray:create()
        carray2:addObject(mvTo2)
        carray2:addObject(fadeOut)
        local spawn2=CCSpawn:create(carray2)

        local seq=CCSequence:createWithTwoActions(spawn2,spawn)
        rightMenu:runAction(CCRepeatForever:create(seq))
    end

    

    local pageStr = self.curPage.."/"..acChrisEveVoApi:getMaxPage()
    self.pageLb=GetTTFLabel(pageStr,26)
    self.pageLb:setPosition(self.bgLayer:getContentSize().width/2,38)
    self.pageLb:setAnchorPoint(ccp(0.5,0));
    self.bgLayer:addChild(self.pageLb,6)

    local spriteTitle1 = CCSprite:createWithSpriteFrameName("worldInputBg.png");
    spriteTitle1:setAnchorPoint(ccp(0.5,0));
    spriteTitle1:setPosition(self.bgLayer:getContentSize().width/2,35)
    self.bgLayer:addChild(spriteTitle1,5)

    self:controlPageBtn()
end

function acChrisEveSmallDialog:leftPage()

            self.curPage=self.curPage-1
            if self.curPage<1 then 
                self.curPage=acChrisEveVoApi:getMaxPage() 
            end
            if self.curPage>acChrisEveVoApi:getMaxPage() then 
                self.curPage=1
            end
            self.tv:reloadData()
            self:refresh()
            self:controlPageBtn()
    local temPage = self.curPage-1
    if temPage<1 then 
        temPage=acChrisEveVoApi:getMaxPage() 
    end
    if temPage>acChrisEveVoApi:getMaxPage() then 
        temPage=1
    end
end

function acChrisEveSmallDialog:rightPage()
            self.curPage=self.curPage+1
            if self.curPage<1 then 
                self.curPage=acChrisEveVoApi:getMaxPage() 
            end
            if self.curPage>acChrisEveVoApi:getMaxPage() then 
                self.curPage=1
            end
            self.tv:reloadData()
            self:refresh()
            self:controlPageBtn()
    local temPage = self.curPage+1
    if temPage<1 then 
        temPage=acChrisEveVoApi:getMaxPage() 
    end
    if temPage>acChrisEveVoApi:getMaxPage() then 
        temPage=1
    end
end

function acChrisEveSmallDialog:controlPageBtn()
    local maxPage = acChrisEveVoApi:getMaxPage()
    if maxPage>1 then
        if self.leftBtn then
            self.leftBtn:setVisible(true)
        end    
        if self.rightBtn then
            self.rightBtn:setVisible(true)
        end
    else
        if self.leftBtn then
            self.leftBtn:setVisible(false)
        end
        if self.rightBtn then
            self.rightBtn:setVisible(false)
        end
    end
    if self.pageLb then
        local pageStr = self.curPage.."/"..acChrisEveVoApi:getMaxPage()
        self.pageLb:setString(pageStr)
    end
end


--刷新板子
function acChrisEveSmallDialog:refresh()

end

function acChrisEveSmallDialog:socketRecAll( )
    local currLoves = acChrisEveVoApi:getLoveGems()-acChrisEveVoApi:getExpendLoveGems()
    -- print("self.recNeedLoveGems >currLoves====>>>",self.recNeedLoveGems ,currLoves)
    if self.recNeedLoveGems >currLoves then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_chrisEve_noLove"),30)
                do return end
    end
    -- do return end
    local function recCallBack(fn,data)
          local ret,sData=base:checkServerData(data)
          if ret ==true then
             local showTb = nil 
             local otherDat,maxNum =acChrisEveVoApi:getRecGiftTbNoName()
            if maxNum ==0 and self.firT ==0 then
                showTb = acChrisEveVoApi:getAllGiftToChat()
            else
                showTb = acChrisEveVoApi:getAllGiftToChat(true)
            end
             
             local showStrTb = G_showRewardTip(showTb,false,true)
             if(acChrisEveVoApi:isNormalVersion() or self.version == 5 )then
                chatVoApi:sendSystemMessage(getlocal("gongxiAllRec_1",{playerVoApi:getPlayerName(),showStrTb}))
             else
                 chatVoApi:sendSystemMessage(getlocal("gongxiAllRec",{playerVoApi:getPlayerName(),showStrTb}))
             end

              if sData.data.shengdanqianxi.f ~= acChrisEveVoApi:getFirstRecTime() then
              	local reward = acChrisEveVoApi:getFirstreward()
                G_addPlayerAward(reward.type,reward.key,reward.id,reward.num)
                acChrisEveVoApi:setFirstRecTime(sData.data.shengdanqianxi.f)
              end
              if sData.data.shengdanqianxi.d then
              	acChrisEveVoApi:setExpendLoveGems(sData.data.shengdanqianxi.d)
              else
	            acChrisEveVoApi:setExpendLoveGems()
              end
              if sData.data.shengdanqianxi.g then
              	acChrisEveVoApi:setRecGiftTbNoName(sData.data.shengdanqianxi.g)
              else
	            acChrisEveVoApi:setRecGiftTbNoName()
              end
                local loveGemsNum = acChrisEveVoApi:getLoveGems()-acChrisEveVoApi:getExpendLoveGems()
                self.loveGems:setString(getlocal("activity_chrisEve_curLoveGems",{loveGemsNum}))
                --清空全部领取所需要的爱心值
                self.recNeedLoveGems=0

              local function sendRequestCallBack(fn,data)
                  local ret,sData=base:checkServerData(data)
                  if ret ==true then
                      if sData.data and sData.data and sData.data.list then
                        local otherDat,maxNum =acChrisEveVoApi:getRecGiftTbNoName()
                        if maxNum ==0 and SizeOfTable(sData.data.list)>0 then
                            acChrisEveVoApi:setRecGiftTb()
                        else
                            acChrisEveVoApi:setRecGiftTb(sData.data.list)
                        end
                      else
			            acChrisEveVoApi:setRecGiftTb()
                      end
                      if sData.data and sData.data.reward then
                            local reward = FormatItem(sData.data.reward,false)
                            for k,v in pairs(reward) do
                               G_addPlayerAward(v.type,v.key,v.id,v.num)
                            end
                      end
                      acChrisEveVoApi:setIsNewData(3)
	                  acChrisEveVoApi:setGAndListInTb()
                      local otherData = nil
                      otherData,self.maxNum =acChrisEveVoApi:getRecGiftTbNoName(0)
                      --重新计算每一个页面的礼包个数
                        self:refreshPageAndNum()
                        
                        if SizeOfTable(self.maxNumTb)<self.curPage then
                            self:leftPage()
                        end
                      self.firT  = acChrisEveVoApi:getFirstRecTime()
                      self.tv:reloadData()
                      smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allRecevied"),30)

                      return self:close()
                  end
              end
              socketHelper:chrisEveSend(sendRequestCallBack,"get")
          end

    end--callback,action,method,sid,tuid,rank,user
    local otherDat,maxNum =acChrisEveVoApi:getRecGiftTbNoName()
    if maxNum ==0 and self.firT ==0 then
        socketHelper:chrisEveSend(recCallBack,"firstreward")
    else
        socketHelper:chrisEveSend(recCallBack,"gift",1)
    end
end



function acChrisEveSmallDialog:dispose()
    self.layerNum =0
    self.dialogWidth =nil
    self.dialogHeight =nil
    self.loveGems=nil
    self.recNoNameList =nil
    self.firT =nil
    self.isHasName =nil
    self.maxNum=1
    self.rewardNumLb=nil
    self.listNum=0
    self.pageLb=nil
    self.awardIndex=0;
    self.curPage=1
    self.maxNumTb =nil
    base:removeFromNeedRefresh(self)
end

function acChrisEveSmallDialog:tick( )
	if self.isRefresh ==true then
		self.isRefresh=false
		if self.tv then
            acChrisEveVoApi:setGAndListInTb()
            self.firT=acChrisEveVoApi:getFirstRecTime()
            self:refreshPageAndNum()
            self:controlPageBtn()
			-- acChrisEveVoApi:setRecGiftTb()
			self.tv:reloadData()
		end
	end
    local acVo = acChrisEveVoApi:getAcVo()
    -- if base.serverTime > acVo.acEt -86400 then
    if base.serverTime > acVo.acEt then
        return self:close()
    end
end