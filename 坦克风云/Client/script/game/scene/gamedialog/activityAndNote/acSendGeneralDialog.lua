acSendGeneralDialog = commonDialog:new()

function acSendGeneralDialog:new(layerNum )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self
	self.layerNum = layerNum
	return nc
end
function acSendGeneralDialog:initTableView(layerNum )
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/heroRecruitImage.plist")
	local heroList = acSendGeneralVoApi:formatHeroList()

    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSize.width-20,G_VisibleSize.height-105))
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.panelLineBg:getContentSize().height/2+20))
	local capInSetNew=CCRect(20, 20, 10, 10)
	local function cellClick(hd,fn,idx)
	end
	self.backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSetNew,cellClick)
	self.backSprie:setContentSize(CCSizeMake(self.panelLineBg:getContentSize().width-10, self.panelLineBg:getContentSize().height-10))
	self.backSprie:setAnchorPoint(ccp(0,1))
	self.backSprie:setPosition(ccp(5,self.panelLineBg:getContentSize().height-5))
	self.panelLineBg:addChild(self.backSprie)

    local titleStr=getlocal("activity_timeLabel")
    local titleLb=GetTTFLabelWrap(titleStr,35,CCSizeMake(0,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    titleLb:setAnchorPoint(ccp(0.5,1))
    titleLb:setPosition(ccp(self.backSprie:getContentSize().width*0.5,self.backSprie:getContentSize().height-10))
    self.backSprie:addChild(titleLb,1)
    titleLb:setColor(G_ColorGreen)

    local vo=acSendGeneralVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(vo.st,vo.acEt)
    local timeLb=GetTTFLabelWrap(timeStr,30,CCSizeMake(0,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    timeLb:setAnchorPoint(ccp(0.5,1))
    timeLb:setPosition(ccp(self.backSprie:getContentSize().width*0.5,titleLb:getPositionY()-45))
    self.backSprie:addChild(timeLb,1)
    self.timeLb=timeLb
    G_updateActiveTime(vo,self.timeLb)

	local function showInfo()
        PlayEffect(audioCfg.mouseClick)
        local tabStr={};
        local tabColor ={};
        local td=smallDialog:new()
        tabStr = {"\n",getlocal("activity_SendGeneral_label_3"),"\n",getlocal("activity_SendGeneral_label_2"),"\n",getlocal("activity_SendGeneral_label_1"),"\n"}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    infoItem:setAnchorPoint(ccp(1,1))
    -- infoItem:setScale(0.8)
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setAnchorPoint(ccp(1,1))
    infoBtn:setPosition(ccp(self.backSprie:getContentSize().width-15,self.backSprie:getContentSize().height-25))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    self.backSprie:addChild(infoBtn,1)

    local StrPosWidth = 10
    local descSize = 22
    local posW = 0
    local strPosHeight = 10
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
    	StrPosWidth = self.backSprie:getContentSize().width*0.5
    	descSize=25
    	posW = 0.5
    	strPosHeight = 0
    end
    local rechargeStr = getlocal("activity_SendGeneral_desc")
    rechargeLabel = GetTTFLabelWrap(rechargeStr,descSize,CCSizeMake(600,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    rechargeLabel:setAnchorPoint(ccp(posW,1))
    rechargeLabel:setPosition(ccp(StrPosWidth,timeLb:getPositionY()-60+strPosHeight))
    self.backSprie:addChild(rechargeLabel,1)

	self.headBs=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function () do return end end)
    self.headBs:setContentSize(CCSizeMake(self.backSprie:getContentSize().width,self.backSprie:getContentSize().height*0.3))
    self.headBs:setAnchorPoint(ccp(0.5,1))
    self.headBs:setPosition(ccp(self.backSprie:getContentSize().width*0.5,rechargeLabel:getPositionY()-50-strPosHeight))
    self.backSprie:addChild(self.headBs,1)

    local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
    lightSp:setAnchorPoint(ccp(0.5,0.5))
    lightSp:setPosition(ccp(self.headBs:getContentSize().width*0.15,self.headBs:getContentSize().height*0.5))
    lightSp:setScale(1.4)
    self.headBs:addChild(lightSp,1)

    local bigGiftBg =CCSprite:createWithSpriteFrameName("Icon_BG.png")
    bigGiftBg:setAnchorPoint(ccp(0.5,0.5))
    bigGiftBg:setPosition(ccp(self.headBs:getContentSize().width*0.15-5,self.headBs:getContentSize().height*0.5))
    bigGiftBg:setScale(1.5)
    self.headBs:addChild(bigGiftBg,1)

	local frames=CCArray:create()
	for i=1 ,20 do
		local nameStr = "RotatingEffect"..i..".png"
		local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
		frames:addObject(frame)
	end
	local pBAnimation = CCAnimation:createWithSpriteFrames(frames,0.05)
	local pBAnimate = CCAnimate:create(pBAnimation)
	self.pBSprite = CCSprite:createWithSpriteFrameName("RotatingEffect1.png")
	self.pBSprite:runAction(CCRepeatForever:create(pBAnimate))
	self.pBSprite:setScale(1.1)
	self.pBSprite:setPosition(ccp(bigGiftBg:getContentSize().width*0.5,bigGiftBg:getContentSize().height*0.5))
	bigGiftBg:addChild(self.pBSprite,1)

	local msgContent = acSendGeneralVoApi:getHeroNameList( )

	local function showClick( ... )
        if heroList and SizeOfTable(heroList)>0 then
            smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_tankjianianhua_awardContent"),heroList,true,true,self.layerNum+1,nil,false,false,true,nil,nil,msgContent)
        end
	end
	local addIcon = LuaCCSprite:createWithSpriteFrameName("mainBtnGift.png",showClick)	
	addIcon:setScale(1.2)	
	addIcon:setAnchorPoint(ccp(0.5,0.5))
	addIcon:setPosition(ccp(self.headBs:getContentSize().width*0.15-5,self.headBs:getContentSize().height*0.5))
	addIcon:setTouchPriority(-(self.layerNum-1)*20-5)
	self.headBs:addChild(addIcon,1)

	local value = acSendGeneralVoApi:getValue()
	local valStr = getlocal("activity_SendGeneral_value",{value})
	local valLb = GetTTFLabelWrap(valStr,25,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	valLb:setAnchorPoint(ccp(0.5,0.5))
	valLb:setPosition(ccp(self.headBs:getContentSize().width*0.15-5,40))
	self.headBs:addChild(valLb,1)

	local iconGold=CCSprite:createWithSpriteFrameName("IconGold.png")
	iconGold:setAnchorPoint(ccp(0.5,0.5))
	iconGold:setPosition(ccp(self.headBs:getContentSize().width*0.15+65,40))
	self.headBs:addChild(iconGold,1)  	

	for i=1,6 do --6个将领名单
		local px=50+self.headBs:getContentSize().width*0.3+((i-1)%3)*150
        local py
        if i<4 then
        	py = self.headBs:getContentSize().height*0.7+10
        else
        	py = self.headBs:getContentSize().height*0.3-10
        end

	    local smGiftBg =CCSprite:createWithSpriteFrameName("Icon_BG.png")
	    smGiftBg:setAnchorPoint(ccp(0.5,0.5))
	    smGiftBg:setPosition(ccp(px,py))
	    smGiftBg:setScale(1.2)
	    self.headBs:addChild(smGiftBg,1)
		--添加将领点击事件
		 local function touchHeroIcon(...)
		    PlayEffect(audioCfg.mouseClick)        
		    require "luascript/script/game/scene/gamedialog/activityAndNote/acHuoxianmingjiangHeroInfoDialog"

		    local hid = heroList[i].name
		    local heroProductOrder = heroList[i].quality

		    local td = acHuoxianmingjiangHeroInfoDialog:new(hid,heroProductOrder)
		    local dialog = td:init("PanelHeaderPopup.png",self.layerNum+1,CCRect(168, 86, 10, 10),CCSizeMake(600,800),getlocal("report_hero_message"))
		    sceneGame:addChild(dialog,self.layerNum+1)
		    
		 end   
		local hid = heroList[i].name
		local heroProductOrder = heroList[i].quality
		local heroIcon = heroVoApi:getHeroIcon(hid,heroProductOrder,true,touchHeroIcon,nil,nil,nil,{adjutants={}})
		heroIcon:setTouchPriority(-(self.layerNum-1)*20-5)
		heroIcon:setPosition(ccp(px,py))
		heroIcon:setScale(0.6)
		self.headBs:addChild(heroIcon,1)
	end

	local borderHeight = 100
	local borderPosh = 5
	if G_isIphone5() then
		borderHeight =120
		borderPosh =25
	end
   	local function borderNilFunc()
    end
   	local borderDownSetNew=CCRect(20, 20, 10, 10)
    self.borderDown=LuaCCScale9Sprite:createWithSpriteFrameName("heroRecruitBox3.png",borderDownSetNew,borderNilFunc)
	self.borderDown:setContentSize(CCSizeMake(self.backSprie:getContentSize().width, self.headBs:getPositionY()-self.headBs:getContentSize().height-borderHeight))
	self.borderDown:setAnchorPoint(ccp(0,1))
	self.borderDown:setPosition(ccp(0,self.headBs:getPositionY()-self.headBs:getContentSize().height-borderPosh))
	self.backSprie:addChild(self.borderDown,2)

   	local function downNilFunc()
    end
	self.downBg =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSetNew,downNilFunc)
	self.downBg:setContentSize(CCSizeMake(self.backSprie:getContentSize().width, self.headBs:getPositionY()-self.headBs:getContentSize().height-borderHeight))
	self.downBg:setAnchorPoint(ccp(0,1))
	self.downBg:setPosition(ccp(0,self.headBs:getPositionY()-self.headBs:getContentSize().height-borderPosh))
	self.backSprie:addChild(self.downBg,1)

	local verticalLinePosWidth = 0.3
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
		verticalLinePosWidth =0.2
	end
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setAnchorPoint(ccp(0.5,1))
    lineSp:setScale(0.7)
    lineSp:setPosition(ccp(self.panelLineBg:getContentSize().width*verticalLinePosWidth,self.downBg:getContentSize().height*0.5))
    self.downBg:addChild(lineSp,1)
    lineSp:setRotation(90)

    local function callBack(...)
    	return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.downBg:getContentSize().width-10,self.downBg:getContentSize().height-10),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    self.tv:setPosition(ccp(5,5))
    self.downBg:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(100)

    local function rechargeCallback(tag,object)
	    if G_checkClickEnable()==false then
	        do
	            return
	        end
	    else
	        base.setWaitTime=G_getCurDeviceMillTime()
	    end
	    activityAndNoteDialog:closeAllDialog()
		vipVoApi:showRechargeDialog(self.layerNum+1)
    end
    local rewardBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",rechargeCallback,nil,getlocal("recharge"),25,11)
    rewardBtn:setAnchorPoint(ccp(0.5,0))
    local rewardMenu=CCMenu:createWithItem(rewardBtn)
    rewardMenu:setPosition(ccp(self.backSprie:getContentSize().width*0.3,10))
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.backSprie:addChild(rewardMenu,2)
    	local Had = acSendGeneralVoApi:getBigRewardHad( )
    local function rewardBtnCallback( )
    	local Had = acSendGeneralVoApi:getBigRewardHad( )
    	if Had ==nil then
    		local function recBtnCallback(fn,data)
    			local ret,sData=base:checkServerData(data)
    			if ret == true then
                    -- local rewardList = heroList or {}
                    -- for k,v in pairs(rewardList) do
                    --     local awardTb= rewardList or {}
                    --     local award=awardTb[1]

                    --      if award.type=="h" and award.eType=="h" then
                    --         local type,heroIsExist,addNum=heroVoApi:getNewHeroData(award,oldHeroList3)
                    --         if heroIsExist==true then

                    --         elseif heroIsExist==false then
                    --             local vo = heroVo:new()
                    --             vo.hid=award.key
                    --             vo.level=1
                    --             vo.points=0
                    --             vo.productOrder=award.num
                    --             vo.skill={}
                    --             table.insert(oldHeroList3,vo)

                    --             heroVoApi:getNewHeroChat(award.key)
                    --         end
                    --     end
                    -- end


                    local pbig,pNum,pIndex,pId = acSendGeneralVoApi:getBigRewardKeyValue()
                    bagVoApi:addBag(pId,pNum)
           --          local prop = propCfg[pbig]
           --          local item={name=getlocal(prop.name), pic=prop.icon, num=1, desc=prop.description}
           --          print("item......",prop,prop.name,propicon,prop.description)
			        -- if item and item.name and item.pic and item.num and item.desc then
			        --       propInfoDialog:create(sceneGame,item,self.layerNum+1)
			        -- end

	       	        smallDialog:showSure("PanelPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("activity_SendGeneral_lastReward"),nil,self.layerNum+1)
	       	        acSendGeneralVoApi:setBigRewardHad()
       	    	end
    		end
    		socketHelper:activitySendGeneralLastReward("getLastReward",recBtnCallback)
    	else
    		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage10007"),30)
    	end
    end 
	self.lotteryBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rewardBtnCallback,1,getlocal("activity_continueRecharge_reward"),25)
	self.lotteryBtn:setAnchorPoint(ccp(0.5,0))
	local lotteryMenu=CCMenu:createWithItem(self.lotteryBtn)
	lotteryMenu:setPosition(ccp(self.backSprie:getContentSize().width*0.7,10))
	lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	self.backSprie:addChild(lotteryMenu,2)
	self.lotteryBtn:setEnabled(false)
	local todayDays = acSendGeneralVoApi:getCurrentDay()
	if todayDays >=7 then
		if acSendGeneralVoApi:getAllValue() then
			self.lotteryBtn:setEnabled(true)
			--acSendGeneralVoApi:setBigRewardHad()
		end
	end
end

function acSendGeneralDialog:eventHandler(handler,fn,idx,cel)
	if fn =="numberOfCellsInTableView" then
		return 7
	elseif fn =="tableCellSizeForIndex" then
		local posHeight = 0.25
		if G_isIphone5() then
			posHeight =0.2
		end
		local daysSize = CCSizeMake(self.downBg:getContentSize().width-10,self.downBg:getContentSize().height*posHeight)
		return daysSize
	elseif fn =="tableCellAtIndex" then
		local  cell = CCTableViewCell:new()
		cell:autorelease()
		local posHeight = 0.25
		if G_isIphone5() then
			posHeight =0.2
		end
		self.cellHeight= self.downBg:getContentSize().height*posHeight
		self.cellWidth = self.downBg:getContentSize().width-10
		local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp:setAnchorPoint(ccp(0.5,1))
		lineSp:setPosition(ccp(self.cellWidth*0.5,2))
		cell:addChild(lineSp,1)

    	local curDay = acSendGeneralVoApi:getCurrentDay()--当前第几天
    	local allDayReward = acSendGeneralVoApi:getAllReward()--7天所有的是否有充值的记录

		local titleStr=getlocal("activity_continueRecharge_dayDes",{idx+1})
		local titleLb=GetTTFLabel(titleStr,25)
		titleLb:setAnchorPoint(ccp(0,0.5))
		titleLb:setPosition(ccp(25,self.cellHeight*0.5))
		cell:addChild(titleLb,1)
		titleLb:setColor(G_ColorGreen)

		local checkMark = CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
		checkMark:setAnchorPoint(ccp(0.5,0.5))
		checkMark:setPosition(ccp(self.cellWidth*0.8,self.cellHeight*0.6))
		cell:addChild(checkMark,1)
		checkMark:setVisible(false)

		local function touch(tag,object)
	       -- if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
	       --    if G_checkClickEnable()==false then
	       --        do
	       --            return
	       --        end
	       --    else
	       --        base.setWaitTime=G_getCurDeviceMillTime()
	       --    end

	          self:revisePanel(idx+1)
	        -- end
		end
		local bqSize = 28
		if G_getCurChoseLanguage() =="ru" then
			bqSize =23
		end
		local menuItemDesc=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",touch,idx,getlocal("addSignBtn"),bqSize,33)
		menuItemDesc:setAnchorPoint(ccp(0.5,0.5))
		menuItemDesc:setScale(0.7)
		local menuDesc=CCMenu:createWithItem(menuItemDesc)
		menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
		menuDesc:setPosition(ccp(self.cellWidth*0.8,self.cellHeight*0.5))
		cell:addChild(menuDesc,1)
		menuItemDesc:setVisible(false)

	    if idx+1 > curDay then                --大于当前天
	      	checkMark:setVisible(false)
			menuItemDesc:setVisible(false)
	    elseif idx+1 ==curDay then            --等于当前天
	      if allDayReward[idx+1] ==0 then
	      	checkMark:setVisible(false)
			menuItemDesc:setVisible(false)
	      elseif allDayReward[idx+1] >0 then
	      	checkMark:setVisible(true)
			--menuItemDesc:setVisible(true)
		  end
	    elseif idx+1 <curDay then             --小于当前天
	      if allDayReward[idx+1] >0 then --领取
	      		checkMark:setVisible(true)
				menuItemDesc:setVisible(false)
	      elseif allDayReward[idx+1] ==0 then --补签
				menuItemDesc:setVisible(true)
	      		checkMark:setVisible(false)				
	      end
	    end

		return cell
	elseif fn =="ccTouchBegan" then
		self.isMoved =false
		return true
	elseif fn =="ccTouchMoved" then
		self.isMoved =true
	elseif fn =="ccTouchEnded" then
	end
end

--补签的跳转，
function acSendGeneralDialog:revisePanel(day)
  local needGems = acSendGeneralVoApi:getReviseNeedMoneyByDay()
  if needGems>playerVoApi:getGems() then
    GemsNotEnoughDialog(nil,nil,needGems-playerVoApi:getGems(),self.layerNum+1,needGems)
  else
    local function usePropHandler(tag1,object)
        PlayEffect(audioCfg.mouseClick)
        local function reviseSuccess(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                playerVoApi:setValue("gems",playerVoApi:getGems()-needGems)

                acSendGeneralVoApi:afterSuppleSet(day)
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_continueRecharge_reviseSuc"),28)
                self:refresh()
            end
        end

        socketHelper:activitySendGeneralSevenBQ("modify",day,reviseSuccess)
    end
    smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),usePropHandler,getlocal("dialog_title_prompt"),getlocal("activity_continueRecharge_revise",{day,acSendGeneralVoApi:getReviseNeedMoneyByDay(day)}),nil,self.layerNum+1)
  end
end


function acSendGeneralDialog:refresh()
  --self:refreshRewardBtn()
  if self and self.tv then
    local recordPoint = self.tv:getRecordPoint()
    self.tv:reloadData()
    self.tv:recoverToRecordPoint(recordPoint)
  end

end
function acSendGeneralDialog:tick( )
    local vo=acSendGeneralVoApi:getAcVo()
	if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
  local todayDays = acSendGeneralVoApi:getCurrentDay()
  if todayDays >=7 then
  	if acSendGeneralVoApi:getAllValue() then
  		self.lotteryBtn:setEnabled(true)
  		--acSendGeneralVoApi:setBigRewardHad()
  	end
  end
  if acSendGeneralVoApi.todayRech ==1 then
  	acSendGeneralVoApi.todayRech = 0
  	self:refresh()
  end
  	if self.timeLb then
        local vo=acSendGeneralVoApi:getAcVo()
        G_updateActiveTime(vo,self.timeLb)
    end
end
function acSendGeneralDialog:dispose( )
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/heroRecruitImage.plist")
end