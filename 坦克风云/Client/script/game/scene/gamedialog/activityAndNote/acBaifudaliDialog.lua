acBaifudaliDialog = commonDialog:new()

function acBaifudaliDialog:new()
	local  nc = {}
	setmetatable(nc,self)
	self.__index=self
	self.isToday = nil
	return nc
end

--初始化对话框面板
function acBaifudaliDialog:initTableView( )
	
	-----拿数据
	self.isToday = acBaifudaliVoApi:isToday()
	localHeight=self.bgLayer:getContentSize().height*0.25-30
	self.panelLineBg:setVisible(false)
	local function callBack( ... )
		return self:eventHandler(...)
	end
	local hd = LuaEventHandler:createHandler(callBack)

	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,localHeight*3),nil)

	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	self.tv:setPosition(ccp(10,20))
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(120)

	local changeIcon  ----需要通过version 变换图标
	local version =acBaifudaliVoApi:getVersion()

	changeIcon = CCSprite:createWithSpriteFrameName("Icon_BG.png")
	changeIcon:setPosition(ccp(40,localHeight*3+100))
	changeIcon:setAnchorPoint(ccp(0,0))
	self.bgLayer:addChild(changeIcon,5)
	changeIcon:setScale(100 / changeIcon:getContentSize().width)

if version ==3 then
	changeIcon:setVisible(false)

	self.display1 = CCParticleSystemQuad:create("public/display.plist")
	self.display1.positionType=kCCPositionTypeFree
	self.display1:setPosition(ccp(80,localHeight*3+120))
	self.bgLayer:addChild(self.display1,5)
	self.display1:setScale(3.0)

	self.display2 = CCParticleSystemQuad:create("public/display.plist")
	self.display2.positionType=kCCPositionTypeFree
	self.display2:setPosition(ccp(40,localHeight*3+160))
	self.bgLayer:addChild(self.display2,5)
	self.display2:setScale(3.0)

	self.display3 = CCParticleSystemQuad:create("public/display.plist")
	self.display3.positionType=kCCPositionTypeFree
	self.display3:setPosition(ccp(100,localHeight*3+180))
	self.bgLayer:addChild(self.display3,5)
	self.display3:setScale(3.0)
end

    local function timeIconClick( ... )
    end
    local addIconStr=""
    if version == 1 then
        addIconStr="360LOGO.png"
    elseif version == 2 then
        addIconStr="3KLOGO.png"
        if G_curPlatName() =="11" or G_curPlatName() =="androidsevenga" then
			addIconStr="sevenga.png"
		end	
    end
    if version <= 2 then

	    addIcon = LuaCCSprite:createWithSpriteFrameName(addIconStr,timeIconClick)
	    addIcon:setScale(0.4)
	    if G_curPlatName() =="11" or G_curPlatName() =="androidsevenga"  then
			addIcon:setScale(0.7)
		end	
	    addIcon:setPosition(getCenterPoint(changeIcon))
	    changeIcon:addChild(addIcon)
    end

	local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
	actTime:setPosition(ccp(self.bgLayer:getContentSize().width*0.5+50,self.bgLayer:getContentSize().height-110))
	actTime:setColor(G_ColorGreen)
	self.bgLayer:addChild(actTime,5)

	local acVo =acBaifudaliVoApi:getAcVo()  ---
	if acVo ~=nil then
		local timeStr = activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
		local timeLabel=GetTTFLabel(timeStr,26)
		timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width*0.5+50,self.bgLayer:getContentSize().height-145))
		self.bgLayer:addChild(timeLabel,5)
	end
	local tabelLb 
	local gameName = ""
	  if type(platFormCfg.gameName)=="table" then
	    -- print("G_getCurChoseLanguage(): ",G_getCurChoseLanguage())
	    -- for k,v in pairs(platFormCfg.gameName) do
	    --   print("k: ",k)
	    --   print("v: ",v)
	    -- end
	    gameName=platFormCfg.gameName[G_getCurChoseLanguage()]
	  else
	    gameName=platFormCfg.gameName
	  end
	local headerLabel =getlocal("activity_baifudali_headerLabel",{gameName})
	if version ==3 then
		headerLabel = getlocal("activity_baifudali_decTW")
	end
	tabelLb = G_LabelTableView(CCSizeMake(self.bgLayer:getContentSize().width*0.7,120),headerLabel,26,kCCTextAlignmentLeft)
	tabelLb:setPosition(ccp(150,self.bgLayer:getContentSize().height-280))
	tabelLb:setAnchorPoint(ccp(0,0))
	tabelLb:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	tabelLb:setMaxDisToBottomOrTop(70)
	self.bgLayer:addChild(tabelLb,5)
end

function acBaifudaliDialog:eventHandler( handler,fn,idx,cel )
	if fn=="numberOfCellsInTableView" then
		return 3
	elseif fn =="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-15,localHeight)
		return tmpSize
	elseif fn =="tableCellAtIndex" then
		local  cell = CCTableViewCell:new()
		cell:autorelease()
		cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-15,localHeight))


		local capInset = CCRect(20,20,10,10)
		local function cellClick( hd,fn,idx )
			
		end
		local headerSpri = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInset,cellClick)
		headerSpri:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,localHeight))
		headerSpri:setPosition(ccp(10,cell:getContentSize().height-headerSpri:getContentSize().height))
		headerSpri:setAnchorPoint(ccp(0,0))

		cell:addChild(headerSpri)

		local capInseth = CCRect(20,20,10,10)
		local function cellHeaderClick( hd,fn,idx )
			
		end
		local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBgSelect.png",capInseth,cellHeaderClick)
		titleBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,50))
		titleBg:setAnchorPoint(ccp(0,1))
		titleBg:setPosition(ccp(-10,headerSpri:getContentSize().height))
		headerSpri:addChild(titleBg,1)

		local addGold = acBaifudaliVoApi:getAddGold() ---拿到累加的金币数量
		local isRecGold = acBaifudaliVoApi:getIsRecGold()
		local goldAction = acBaifudaliVoApi:getGoldAction()--拿到金币限制值
		local goldReward = acBaifudaliVoApi:getGoldReward()--拿到 返利的金币值
		local repairVate = acBaifudaliVoApi:getRepairVate() * 100--拿到 优惠力度
		--local dayFreeRew = "3M"  --无配置要求，可以写死
		local valueStr  --不同配置的取值 ，放在不同的cell里显示用
		local titleLbStr
		local cellSmallTitleStr
		local cellSmallTitle
		local cellLbStr
		local singleGoldIcon
		local cellLeftIcon
		local clickItem
		local buttonName
		local function  onClick( tag,object )

			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end

                PlayEffect(audioCfg.mouseClick)
				if idx==0 then
					local function buyGems( )
						if G_checkClickEnable()==false then
							do
							return
							end
						end
						activityAndNoteDialog:closeAllDialog()
						vipVoApi:showRechargeDialog(self.layerNum+1)--弹出充值页面
					end


					if addGold < goldAction then
						local smallD = smallDialog:new()
						smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("activity_baifudali_notEnoughGold"),nil,self.layerNum+1)

				    elseif isRecGold==1 then
				    	
				    else
						local function goldCallback(fn,data)
							local ret,sData=base:checkServerData(data)
			                if ret==true then
			                	playerVoApi:setValue("gems",playerVo["gems"]+tonumber(goldReward))
			                	acBaifudaliVoApi:updateIsRecGold()
			                	self.tv:reloadData()
			                	local str = getlocal("daily_lotto_tip_10")..getlocal("gem").." x"..goldReward
			                	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)

			                end
						end
				    	socketHelper:activityBaifudaliRecGold(goldCallback)
				    end
				elseif idx==1 then 
					local playerLV = playerVoApi:getPlayerLevel()
					if acBaifudaliVoApi:getLevelLimit()<=playerLV then
						--判断如果没有领取当日奖励，通过配置领奖励，给后端传输数据
						local function rewradCallback(fn,data)
							local ret,sData=base:checkServerData(data)
			                if ret==true then
			                	local rewardCfg = acBaifudaliVoApi:getDailyRewardCfg()
			                	local award = FormatItem(rewardCfg)
			                	for k,v in pairs(award) do
			                		G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
			                	end
			                	G_showRewardTip(award, true)
			                	acBaifudaliVoApi:updateLastTime()
			                	self.isToday = acBaifudaliVoApi:isToday()
			                	self.tv:reloadData()
			                end
						end
						socketHelper:activityBaifudaliRecReward(rewradCallback)
					else
						 smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_baifudali_levelLimit"),28)
					end

				elseif idx==2 then
					activityAndNoteDialog:closeAllDialog()
	        		storyScene:setShow()
				end
             end
			
			

		end
		local cellLb
		if idx==0 then
			titleLbStr="activity_baifudali_headerLabel_str1"
			cellSmallTitleStr="recharge"
			cellLbStr=getlocal("activity_baifudali_cellLb_str1",{goldReward})

			cellLb = GetTTFLabel(cellLbStr,26)

			cellSmallTitle=GetTTFLabel(getlocal(cellSmallTitleStr)..goldAction,24)
			cellSmallTitle:setAnchorPoint(ccp(0,0))
			cellSmallTitle:setPosition(ccp(20,headerSpri:getContentSize().height-100))
			headerSpri:addChild(cellSmallTitle)

			singleGoldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
			singleGoldIcon:setAnchorPoint(ccp(0,0))
			singleGoldIcon:setPosition(ccp(cellSmallTitle:getContentSize().width+25,cellSmallTitle:getPositionY()))
			headerSpri:addChild(singleGoldIcon)

			cellLeftIcon = CCSprite:createWithSpriteFrameName("iconGold6.png")
			cellLeftIcon:setAnchorPoint(ccp(0,0))
			-- cellLeftIcon:setScale(1.3)
			cellLeftIcon:setPosition(ccp(cellLb:getContentSize().width+80,cellSmallTitle:getPositionY()-100))
			headerSpri:addChild(cellLeftIcon)

			--cell1 右上角文字和金币图标
			local addGoldStr = GetTTFLabelWrap(getlocal("activity_baifudali_totalMoney"),25,CCSizeMake(headerSpri:getContentSize().width*0.25+10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			addGoldStr:setAnchorPoint(ccp(0.5,0))
			addGoldStr:setPosition(ccp(headerSpri:getContentSize().width-90,headerSpri:getContentSize().height/2+20))
			headerSpri:addChild(addGoldStr)

			local addGoldNum = GetTTFLabel(tostring(addGold),25)
			addGoldNum:setAnchorPoint(ccp(1,0.5))
			addGoldNum:setPosition(headerSpri:getContentSize().width-90,headerSpri:getContentSize().height/2)
			headerSpri:addChild(addGoldNum)

			local singleGoldIcon2 = CCSprite:createWithSpriteFrameName("IconGold.png")
			singleGoldIcon2:setAnchorPoint(ccp(0,0.5))
			singleGoldIcon2:setPosition(ccp(headerSpri:getContentSize().width-90,headerSpri:getContentSize().height/2))
			headerSpri:addChild(singleGoldIcon2)

			buttonName=getlocal("daily_scene_get")
			clickItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClick,idx,buttonName,25)
			if addGold < goldAction then--充值
				clickItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",onClick,idx,getlocal("recharge"),25)
			end
		elseif idx==1 then
			titleLbStr="activity_baifudali_headerLabel_str2"
			local resourceNum
			local version =acBaifudaliVoApi:getVersion()
			if version ==1 then
				resourceNum = 3.6
			elseif version == 2 or version ==3 then
				resourceNum = 3
			end
			local strSize = 26
			if G_curPlatName() =="androidsevenga" then
				strSize =21
			end
			cellLbStr=getlocal("activity_baifudali_cellLb_str2",{acBaifudaliVoApi:getLevelLimit(),resourceNum})
			cellLb = GetTTFLabelWrap(cellLbStr,strSize,CCSizeMake(headerSpri:getContentSize().width*0.5,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

			cellLeftIcon = CCSprite:createWithSpriteFrameName("item_baoxiang_05.png")
			cellLeftIcon:setAnchorPoint(ccp(0,0))
			cellLeftIcon:setPosition(ccp(20,headerSpri:getContentSize().height*0.5-60))
			headerSpri:addChild(cellLeftIcon)

			clickItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClick,idx,getlocal("daily_scene_get"),25)

		elseif idx==2 then
			titleLbStr="activity_baifudali_headerLabel_str3"
			cellLbStr=getlocal("activity_baifudali_cellLb_str3",{repairVate})
			cellLb = GetTTFLabelWrap(cellLbStr,26,CCSizeMake(headerSpri:getContentSize().width*0.5,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

			cellLeftIcon = CCSprite:createWithSpriteFrameName("icon_build.png")
			cellLeftIcon:setAnchorPoint(ccp(0,0))
			cellLeftIcon:setPosition(ccp(20,headerSpri:getContentSize().height*0.5-60))
			headerSpri:addChild(cellLeftIcon)

			clickItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClick,idx,getlocal("activity_baifudali_goFighting"),25)

		end

		local titleLb= GetTTFLabelWrap(getlocal(titleLbStr),25,CCSizeMake(titleBg:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		titleLb:setAnchorPoint(ccp(0,0.5))
		titleLb:setPosition(ccp(20,titleBg:getContentSize().height*0.5))
		titleLb:setColor(G_ColorYellow)
		titleBg:addChild(titleLb,5)

		--确定getlocal是否有替换符功能，如果可以 直接用 valueStr 替换下面的getlocal
		
		cellLb:setAnchorPoint(ccp(0,0.5))

		local clickItemBtn=CCMenu:createWithItem(clickItem)
		clickItemBtn:setAnchorPoint(ccp(0.5,0))
		clickItemBtn:setPosition(ccp(headerSpri:getContentSize().width-90,50))
		clickItemBtn:setTouchPriority(-(self.layerNum-1)*20-3)
		headerSpri:addChild(clickItemBtn)

		if idx==0 then 
			local hadRecGoldLb 
			if acBaifudaliVoApi:getIsRecGold()==1 then
				clickItemBtn:setVisible(false)
				hadRecGoldLb= GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				hadRecGoldLb:setAnchorPoint(ccp(0.5,0))
				hadRecGoldLb:setPosition(headerSpri:getContentSize().width-90,50)
				hadRecGoldLb:setColor(G_ColorGreen)
				headerSpri:addChild(hadRecGoldLb)
				hadRecGoldLb:setVisible(true)
			else
				clickItemBtn:setVisible(true)
				if hadRecGoldLb then
					hadRecGoldLb:setVisible(false)
				end
			end

			cellLb:setPosition(ccp(20,headerSpri:getContentSize().height*0.5-60))
			cellLb:setScale(1.5)
			cellLb:setColor(G_ColorYellow)

			headerSpri:addChild(cellLb)
		elseif idx==1 then

			local hadRewardLb 
			local playerLV = playerVoApi:getPlayerLevel()
			if acBaifudaliVoApi:isToday()==true and playerLV>=acBaifudaliVoApi:getLevelLimit() then
				clickItemBtn:setVisible(false)
				hadRewardLb= GetTTFLabelWrap(getlocal("activity_baifudali_dailyHadReward"),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				hadRewardLb:setAnchorPoint(ccp(0.5,0))
				hadRewardLb:setPosition(headerSpri:getContentSize().width-90,50)
				hadRewardLb:setColor(G_ColorGreen)
				headerSpri:addChild(hadRewardLb)
				hadRewardLb:setVisible(true)
			else
				clickItemBtn:setVisible(true)
				if hadRewardLb then
					hadRewardLb:setVisible(false)
				end
			end
			
			cellLb:setPosition(ccp(cellLeftIcon:getContentSize().width+40,cellLeftIcon:getPositionY()+50))
			headerSpri:addChild(cellLb)
			-- local cellLbLevel = GetTTFLabel(getlocal("activity_baifudali_level20",{acBaifudaliVoApi:getLevelLimit()}),25)
			-- cellLbLevel:setAnchorPoint(ccp(0,0.5))
			-- cellLbLevel:setPosition(cellLeftIcon:getContentSize().width+40,20)
			-- cellLbLevel:setColor(G_ColorRed)
			-- headerSpri:addChild(cellLbLevel)
		elseif idx==2 then 
			
			cellLb:setPosition(ccp(cellLeftIcon:getContentSize().width+40,cellLeftIcon:getPositionY()+50))
			headerSpri:addChild(cellLb)
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

function acBaifudaliDialog:tick( ... )
    
	local istoday = acBaifudaliVoApi:isToday()
	if istoday ~= self.isToday then
		self.isToday = istoday
		if acBaifudaliVoApi:checkIsCanReward() == true then
			if self.tv then
				self.tv:reloadData()
			end
		end
	end
end

function acBaifudaliDialog:particPlay( )
  local display = CCParticleSystemQuad:create("public/display.plist")
  display.positionType=kCCPositionTypeFree
  display:setPosition(ccp(40,localHeight*3+80))
  self.bgLayer:addChild(display,5)

  self:removePartic()
end
function acBaifudaliDialog:removePartic( )
	
end

function acBaifudaliDialog:update()
  local acVo = acBaifudaliVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    end
  end 
end
function acBaifudaliDialog:dispose( ... )
	self.tv = nil
	self.isToday = nil
	self = nil
end