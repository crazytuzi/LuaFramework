acBuyrewardDialog = commonDialog:new()

function acBuyrewardDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.isToday=true
    spriteController:addPlist("public/datebaseShow.plist")
    return nc
end

function acBuyrewardDialog:resetTab()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))
end

function acBuyrewardDialog:initTableView( )
end

function acBuyrewardDialog:analyzeData( )
	self.activeName=acBuyrewardVoApi:getActiveName()
	for i=1,2 do
		local buyProp=acBuyrewardVoApi:getBuyPropByType(i)
		local buyReward=FormatItem(buyProp.reward)
		self["buyReward" .. i]=buyReward[1]
	end
	local showList=acBuyrewardVoApi:getShowlist()
	self.showReward=FormatItem(showList,true,true)
	self.flickReward=acBuyrewardVoApi:getFlickReward()
end	

function acBuyrewardDialog:doUserHandler()
	self:analyzeData( )
	self.isShow=true

	self.url=G_downloadUrl("active/" .. "buyreward/" .. "acBuyrewardjpg" .. acBuyrewardVoApi:getBgImg() .. ".jpg")

	local function onRechargeChange(event,data)
		self:checkCost()
		self:refreshVisible2()
		self:refreshVisible3()
	end
	self.KoreaListener=onRechargeChange
	eventDispatcher:addEventListener("activity.recharge",onRechargeChange)

	local w = G_VisibleSizeWidth - 40 -- 背景框的宽度
	local h = G_VisibleSizeHeight - 100
	local function  bgClick()
		-- body
	end
	local baspH=150
	if(G_isIphone5()==false)then
		baspH=130
	end
	local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),bgClick)
	backSprie:setPosition(self.bgLayer:getContentSize().width/2,h)
	backSprie:setContentSize(CCSizeMake(w, baspH))
	backSprie:setAnchorPoint(ccp(0.5,1))
	self.bgLayer:addChild(backSprie,5)

	local bsW=backSprie:getContentSize().width
	local bsH=backSprie:getContentSize().height
	local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),25)
	acLabel:setAnchorPoint(ccp(0.5,1))
	acLabel:setColor(G_ColorGreen)
	acLabel:setPosition(bsW/2,bsH-10)
	backSprie:addChild(acLabel,1)

	local acLbH = acLabel:getContentSize().height

	local acVo = acBuyrewardVoApi:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
	local timeLabel=GetTTFLabel(timeStr,25)
	timeLabel:setAnchorPoint(ccp(0.5,1))
	timeLabel:setPosition(ccp(bsW/2, bsH-10-acLbH-5))
	backSprie:addChild(timeLabel,3)

	local function touchInfo()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
		local td=smallDialog:new()
		local tabStr = {"\n",getlocal("activity_buyreward_tip2",{self.buyReward2.name .. "*" .. self.buyReward2.num}),"\n",getlocal("activity_buyreward_tip1",{self.buyReward1.name .. "*" .. self.buyReward1.num}),"\n"}
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,nil)
		sceneGame:addChild(dialog,self.layerNum+1)
	end
	local menuItem=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touchInfo,1,nil,0)
	menuItem:setAnchorPoint(ccp(1,1))
	menuItem:setScale(0.8)
	local menuBtn=CCMenu:createWithItem(menuItem)
	menuBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	menuBtn:setPosition(ccp(bsW-10, bsH-20))
	backSprie:addChild(menuBtn,2)

	local desLb=GetTTFLabelWrap(getlocal("activity_buyreward_des"),25,CCSizeMake(540,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	desLb:setAnchorPoint(ccp(0.5,0.5))
	desLb:setPosition(bsW/2,(bsH-10-acLbH-5-timeLabel:getContentSize().height-5-10)/2+5)
	backSprie:addChild(desLb)

	local diSpH=170
	local intervalH = 10
	local startH = 30
	local iconWH=100

	if(G_isIphone5()==false)then
		diSpH=150
		intervalH = 0
		startH = 25
		iconWH=90
	end


	local centerBg=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),bgClick)
	centerBg:setContentSize(CCSizeMake(w, G_VisibleSize.height-100-backSprie:getContentSize().height-diSpH*2-intervalH-startH-20))
	centerBg:setPosition(self.bgLayer:getContentSize().width/2,diSpH*2+intervalH+startH+10)
	centerBg:setAnchorPoint(ccp(0.5,0))
	self.bgLayer:addChild(centerBg)

	local jpgBg1=CCSprite:create("public/hero/heroequip/equipLabBigBg.jpg")
	centerBg:addChild(jpgBg1)
	jpgBg1:setPosition(centerBg:getContentSize().width/2,centerBg:getContentSize().height/2)
	jpgBg1:setScaleX(centerBg:getContentSize().width/jpgBg1:getContentSize().width)
	jpgBg1:setScaleY((centerBg:getContentSize().height+100)/jpgBg1:getContentSize().height)

	local function onLoadIcon(fn,icon)
	    if self and self.isShow then
			centerBg:addChild(icon)
			icon:setPosition(centerBg:getContentSize().width/2,centerBg:getContentSize().height/2)
			icon:setScaleX(centerBg:getContentSize().width/icon:getContentSize().width)
			icon:setScaleY((centerBg:getContentSize().height+100)/icon:getContentSize().height)
	    end
    
	end
	local webImage = LuaCCWebImage:createWithURL(self.url,onLoadIcon)

	local showNum = SizeOfTable(self.showReward)
	local showMoreH = 60
	if showNum<=9 then
		showMoreH=0
	end

	local colum
	colum=3
    local iconW=centerBg:getContentSize().width/3
    local iconH=(centerBg:getContentSize().height-showMoreH)/colum
    self.flickItem={}
    for i=1,colum do
    	for j=1,3 do
			local icon,scale=G_getItemIcon(self.showReward[j+(i-1)*3],iconWH,true,self.layerNum)
			icon:setTouchPriority(-(self.layerNum-1)*20-2)
			icon:setPosition(iconW/2+(j-1)*iconW,centerBg:getContentSize().height-5-iconH/2-(i-1)*iconH)
			centerBg:addChild(icon,5)

			local numLb = GetTTFLabel("x" .. self.showReward[j+(i-1)*3].num,25)
			icon:addChild(numLb)
			numLb:setAnchorPoint(ccp(1,0))
			numLb:setPosition(icon:getContentSize().width-5,5)
			numLb:setScale(1/scale)

			local flag=false
			for k,v in pairs(self.flickReward) do
				if v==self.showReward[j+(i-1)*3].index then
					flag=true
					table.insert(self.flickItem,{self.showReward[j+(i-1)*3].key,self.showReward[j+(i-1)*3].num})
					break
				end
			end
			if flag then
				G_addRectFlicker(icon,1/scale*1.35,1/scale*1.3)
			end
			
    	end
    end

    if showNum>9 then
		local function click()
			if G_checkClickEnable()==false then
	            do
	                return
	            end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
	        end
	        PlayEffect(audioCfg.mouseClick)
	        local scaleSmall = CCScaleTo:create(0.1,0.8)
			local scaleBig = CCScaleTo:create(0.1,1)
			local function onShowBuyrewardSmallDialog()
				require "luascript/script/game/scene/gamedialog/activityAndNote/acBuyrewardSmallDialog"
			    local td=acBuyrewardSmallDialog:new()
			    local title = getlocal("activity_buyreward_smallTitle")
			    local showList=acBuyrewardVoApi:getShowlist()
				local hshowReward=FormatItem(showList,true,true)
			    local dialog=td:init("TankInforPanel.png",CCRect(130, 50, 1, 1),CCSizeMake(550,700),false,false,self.layerNum+1,hshowReward,self.flickReward,title)
			    sceneGame:addChild(dialog,self.layerNum+1)
	        end
	        local callFunc=CCCallFunc:create(onShowBuyrewardSmallDialog)
	        local acArr=CCArray:create()
	        acArr:addObject(scaleSmall)
	        acArr:addObject(scaleBig)
	        acArr:addObject(callFunc)
	        local seq=CCSequence:create(acArr)
	        self.nameBg:runAction(seq)
			 
		end
		local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("alien_mines_allybg.png", CCRect(15,8,153,28),click)
		nameBg:setContentSize(CCSizeMake(300, 40))
		nameBg:setTouchPriority(-(self.layerNum-1)*20-2)
		nameBg:setPosition(ccp(centerBg:getContentSize().width/2,30))
		centerBg:addChild(nameBg,5)
		self.nameBg=nameBg

		local fangdajinSp=CCSprite:createWithSpriteFrameName("datebaseShow2.png")
		fangdajinSp:setAnchorPoint(ccp(0,0.5))
		fangdajinSp:setPosition(15,nameBg:getContentSize().height/2)
		-- touchSp:setOpacity(0)
		nameBg:addChild(fangdajinSp,2)

		local moreLb=GetTTFLabelWrap(getlocal("activity_buyreward_seeMore"),25,CCSizeMake(240,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		moreLb:setAnchorPoint(ccp(0.5,0.5))
		moreLb:setPosition(nameBg:getContentSize().width/2+10,nameBg:getContentSize().height/2)
		nameBg:addChild(moreLb)
	end



	local function  btnClick(tag,object)
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        local free=false
		if tag==1 and acBuyrewardVoApi:canReward()==true then
			free=true
		else
			local cost = acBuyrewardVoApi:getCostByType(tag)
			if cost>playerVoApi:getGems() then
				local function onSure()
					activityAndNoteDialog:closeAllDialog()
				end
				GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost,onSure)
				return
			end
		end

		local function getRawardCallback(fn,data)
			local oldHeroList=heroVoApi:getHeroList()
			local ret,sData = base:checkServerData(data)
			if ret==true then
				if sData and sData.data and sData.data[self.activeName] then
					acBuyrewardVoApi:updateSpecialData(sData.data[self.activeName])
				end
				G_addPlayerAward(self["buyReward" ..tag].type,self["buyReward" ..tag].key,self["buyReward" ..tag].id,self["buyReward" ..tag].num,true)
				if sData and sData.data and sData.data.accessory then
        			accessoryVoApi:onRefreshData(sData.data.accessory)
        		end
        		if free then
			        self.isToday=true
			    else
			    	local playerGem=playerVoApi:getGems()
					local cost = acBuyrewardVoApi:getCostByType(tag)
					playerVoApi:setGems(playerGem-cost)
				end
				if sData and sData.data and sData.data[self.activeName] and sData.data[self.activeName].report then
					local report = sData.data[self.activeName].report
					if tag==1 then
						self:showHero(report[1],oldHeroList)
					else
						local reward = {}
                        for k,v in pairs(sData.data[self.activeName].report) do
                            local item = FormatItem(v)
                            table.insert(reward,item[1])
                            G_addPlayerAward(item[1].type,item[1].key,item[1].id,item[1].num,true)
                        end
						self:showTenSearch(reward)
					end
				end
				
				self:checkCost()
				
			end
		end
		socketHelper:acBuyreward(tag,free,self.activeName,getRawardCallback)
	end
	for i=1,2 do
		local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),bgClick)
		backSprie:setContentSize(CCSizeMake(w, diSpH))
		backSprie:setAnchorPoint(ccp(0.5,0))
		self.bgLayer:addChild(backSprie,5)

		local mustReward=self["buyReward" .. i]
		if i==2 then
			backSprie:setPosition(ccp(G_VisibleSizeWidth/2, startH))
		else
			backSprie:setPosition(ccp(G_VisibleSizeWidth/2, startH+diSpH+intervalH))
		end

		local icon,scale=G_getItemIcon(mustReward,100,true,self.layerNum)
		icon:setTouchPriority(-(self.layerNum-1)*20-2)
		icon:setPosition(60,backSprie:getContentSize().height/2)
		backSprie:addChild(icon)
		

		local nameLb=GetTTFLabelWrap(
			mustReward.name .. "x" .. mustReward.num,25,CCSizeMake(290,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
		nameLb:setAnchorPoint(ccp(0,0))
		backSprie:addChild(nameLb)
		nameLb:setPosition(ccp(120,backSprie:getContentSize().height/2+20))

		local num
		if i==1 then
			num=1
		else
			num=10
		end
		local desLb=GetTTFLabelWrap(
		getlocal("activity_buyreward_propDes",{num}),22,CCSizeMake(290,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		desLb:setAnchorPoint(ccp(0,1))
		backSprie:addChild(desLb)
		desLb:setPosition(ccp(120,backSprie:getContentSize().height/2+5)
		)

		local btnW=G_VisibleSizeWidth-140
		local btnItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",btnClick,i,getlocal("buy"),25)
		btnItem:setAnchorPoint(ccp(0.5,0))
		btnItem:setScale(0.9)
		local btn=CCMenu:createWithItem(btnItem);
		btn:setTouchPriority(-(self.layerNum-1)*20-4);
		btn:setPosition(ccp(btnW,15))
		backSprie:addChild(btn)

		local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
		goldIcon:setAnchorPoint(ccp(0,0.5))
		goldIcon:setPosition(btnW-btnItem:getContentSize().width/4, 15+btnItem:getContentSize().height+15)
		backSprie:addChild(goldIcon)

		local goldNum=acBuyrewardVoApi:getCostByType(i)
		local costLb = GetTTFLabel(goldNum, 25)
		costLb:setAnchorPoint(ccp(0,0.5))
		costLb:setPosition(ccp(btnW+btnItem:getContentSize().width/4-40, 15+btnItem:getContentSize().height+15))
		backSprie:addChild(costLb)

		if i==2 then
			G_addRectFlicker(icon,1/scale*1.35,1/scale*1.3)

			local goldNum1=acBuyrewardVoApi:getCostByType(1)
			if goldNum<goldNum1*10 then
				local goldIconD = CCSprite:createWithSpriteFrameName("IconGold.png")
				goldIconD:setAnchorPoint(ccp(0,0.5))
				goldIconD:setPosition(btnW-btnItem:getContentSize().width/4, 15+btnItem:getContentSize().height+15+30)
				backSprie:addChild(goldIconD)

				local costLbD = GetTTFLabel(goldNum1*10, 25)
				costLbD:setAnchorPoint(ccp(0,0.5))
				costLbD:setPosition(ccp(btnW+btnItem:getContentSize().width/4-40, 15+btnItem:getContentSize().height+15+30))
				backSprie:addChild(costLbD)

				local line = CCSprite:createWithSpriteFrameName("redline.jpg")
				line:setScaleX((costLbD:getContentSize().width+50)/line:getContentSize().width)
				line:setPosition(ccp(costLbD:getContentSize().width/2-20,costLbD:getContentSize().height/2))
				costLbD:addChild(line)
			end
		else
			local freeLb = GetTTFLabel(getlocal("daily_lotto_tip_2"), 25)
			freeLb:setPosition(ccp(btnW, 15+btnItem:getContentSize().height+20))
			freeLb:setColor(G_ColorGreen)
			backSprie:addChild(freeLb)
			self.freeLb=freeLb
		end
		self["costLb" .. i]=costLb
		if i==1 then
			self.goldIcon1=goldIcon
		end
		
	end
	self:checkCost()

	

end

function acBuyrewardDialog:checkCost()
	local goldNum1=acBuyrewardVoApi:getCostByType(1)
	local goldNum2=acBuyrewardVoApi:getCostByType(2)
	local haveCost = playerVoApi:getGems()
	if acBuyrewardVoApi:canReward()==true then
		self.freeLb:setVisible(true)
		self.costLb1:setVisible(false)
		self.goldIcon1:setVisible(false)

	else
		self.freeLb:setVisible(false)
		self.costLb1:setVisible(true)
		self.goldIcon1:setVisible(true)

		if goldNum1>haveCost then
			self.costLb1:setColor(G_ColorRed)
		else
			self.costLb1:setColor(G_ColorWhite)
		end
	end

	if goldNum2<=haveCost then
		self.costLb2:setColor(G_ColorWhite)
	else
		self.costLb2:setColor(G_ColorRed)
	end
end
function acBuyrewardDialog:tick()
	local acVo = acBuyrewardVoApi:getAcVo()
	if acVo ~= nil then
		if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
			if self ~= nil then
				self:close()
			end
		end
	end

	if acBuyrewardVoApi:isToday()==false and self.isToday==true then
		self.isToday=false
		acBuyrewardVoApi:setF(0)
		self:checkCost()
		self:refreshVisible2()
	end
end

function acBuyrewardDialog:showTenSearch(reward)

    if self.tenHuaBg==nil then
        local function callback()
            if self.isAction==false then
                for k,v in pairs(self.spTb) do
                    v:stopAllActions()
                    v:setScale(100/v:getContentSize().width)
                    self.isAction=true

                    if self.guangSpTb[k] then
                        self.guangSpTb[k]:stopAllActions()
                        self.guangSpTb[k]:setScale(1.6)
                        local rotateBy = CCRotateBy:create(4,360)
                        local reverseBy = rotateBy:reverse()
                        self.guangSpTb[k]:runAction(CCRepeatForever:create(reverseBy))
                        -- guangSpTb[k]:runAction(CCRepeatForever:create(rotateBy))
                    end

                    if self.guangSpTb2[k] then
                        self.guangSpTb2[k]:stopAllActions()
                        self.guangSpTb2[k]:setScale(1.6)
                        local rotateBy = CCRotateBy:create(4,360)
                        -- local reverseBy = rotateBy:reverse()
                        -- self.guangSpTb2[k]:runAction(CCRepeatForever:create(reverseBy))
                        self.guangSpTb2[k]:runAction(CCRepeatForever:create(rotateBy))
                    end
                    
                end
                self.againBtn:setVisible(true)
                self.okBtn:setVisible(true)
            end
        end
        self.tenHuaBg=LuaCCSprite:createWithFileName("public/hero/heroequip/equipLabBigBg.jpg",callback)
        -- self.tenHuaBg:setAnchorPoint(ccp(0,0))
        -- self.tenHuaBg:setPosition(ccp(0,0))
        self.bgLayer:addChild(self.tenHuaBg,10)
        self.tenHuaBg:setColor(ccc3(150, 150, 150))
        self.tenHuaBg:setScaleX(G_VisibleSize.width/self.tenHuaBg:getContentSize().width)
        self.tenHuaBg:setScaleY((G_VisibleSize.height)/self.tenHuaBg:getContentSize().height)
        self.tenHuaBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2))
        self.tenHuaBg:setTouchPriority(-(self.layerNum-1)*20-10)

        local function onLoadIcon(fn,icon)
		    if self and self.tenHuaBg then
				self.tenHuaBg:addChild(icon)
				icon:setPosition(self.tenHuaBg:getContentSize().width/2,self.tenHuaBg:getContentSize().height/2)
				icon:setScaleX(G_VisibleSize.width/icon:getContentSize().width)
				icon:setScaleY((G_VisibleSize.height)/icon:getContentSize().height)
				icon:setColor(ccc3(150, 150, 150))
		    end
	    
		end
		local webImage = LuaCCWebImage:createWithURL(self.url,onLoadIcon)

        self.tenSearchBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),callback)
        self.bgLayer:addChild(self.tenSearchBg,10)
        -- self.tenSearchBg:setColor(ccc3(150, 150, 150))
        self.tenSearchBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))
        self.tenSearchBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
        self.tenSearchBg:setTouchPriority(-(self.layerNum-1)*20-10)
        self.tenSearchBg:setOpacity(0)

        -- self.titleBG = LuaCCScale9Sprite:createWithSpriteFrameName("equip_titleBg.png",CCRect(55, 41, 1, 1),callback)
        -- self.titleBG:setContentSize(CCSizeMake(640,100))
        -- self.bgLayer:addChild(self.titleBG,10)
        -- self.titleBG:setAnchorPoint(ccp(0,1))
        -- self.titleBG:setPosition(0, self.bgLayer:getContentSize().height)
        -- self.titleBG:setTouchPriority(-(self.layerNum-1)*20-10)

        -- local titleStr = getlocal("equip_lab_title")
        -- if titleStr~=nil then
        --     if G_getCurChoseLanguage() == "de" or G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="thai"  or G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage()=="pt" or G_getCurChoseLanguage()=="fr" then
        --         self.titlb = GetTTFLabelWrap(titleStr,33,CCSizeMake(self.bgLayer:getContentSize().width-220,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter);
        --     else
        --         self.titlb = GetTTFLabel(titleStr,40)
        --     end
        --     self.titlb:setPosition(ccp(self.titleBG:getContentSize().width/2,self.titleBG:getContentSize().height/2))
        --     self.titleBG:addChild(self.titlb,10);
        -- end

    else
        self.tenSearchBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
        self.tenSearchBg:setVisible(true)

        self.tenHuaBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2))
        self.tenHuaBg:setVisible(true)

        -- self.titleBG:setPosition(0, self.bgLayer:getContentSize().height)
        -- self.titleBG:setVisible(true)

    end

    local name=self.buyReward2.name
    local num=self.buyReward2.num
    local titleLb = GetTTFLabelWrap(getlocal("equip_getReward",{name .. "*" .. num}),25,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setPosition(ccp(320,self.tenSearchBg:getContentSize().height-70))
    titleLb:setColor(G_ColorYellowPro)
    self.tenSearchBg:addChild(titleLb)

    self.isAction = false

    local spTb={}
    local guangSpTb={}
    local guangSpTb2={}
    local subH = 170
    if G_isIphone5()==true then
        subH=190
    end
    for k,v in pairs(reward) do
        
        local i=math.ceil(k/3)
        local j=k%3
        if j==0 then
            j=3
        end

        local sp,scale = G_getItemIcon(v,100,false)
        self.tenSearchBg:addChild(sp,4)
       
        -- sp:setAnchorPoint(ccp(0,0.5))
        sp:setPosition(68+(j-1)*200+50, self.tenSearchBg:getContentSize().height-subH-(i-1)*160)
        if k==10 then
            sp:setPosition(68+(2-1)*200+50, self.tenSearchBg:getContentSize().height-subH-(i-1)*160)
        end

        local nameLb = GetTTFLabelWrap(v.name .. "x" .. v.num,22,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        nameLb:setPosition(ccp(sp:getContentSize().width/2,-30))
        sp:addChild(nameLb)
        
        sp:setScale(0.0001)
        nameLb:setScale(1/scale)
        table.insert(spTb,sp)

       

        local flag = self:isAddHuangguang(v.key,v.num)
        if flag == true then
            local guangSp = CCSprite:createWithSpriteFrameName("equipShine.png")
            self.tenSearchBg:addChild(guangSp,1)
            guangSp:setPosition(68+(j-1)*200+50, self.tenSearchBg:getContentSize().height-subH-(i-1)*160)
            if k==10 then
                guangSp:setPosition(68+(2-1)*200+50, self.tenSearchBg:getContentSize().height-subH-(i-1)*160)
            end
            guangSp:setScale(0.0001)
            guangSpTb[k]=guangSp

            local guangSp = CCSprite:createWithSpriteFrameName("equipShine.png")
            self.tenSearchBg:addChild(guangSp,1)
            guangSp:setPosition(68+(j-1)*200+50, self.tenSearchBg:getContentSize().height-subH-(i-1)*160)
            if k==10 then
                guangSp:setPosition(68+(2-1)*200+50, self.tenSearchBg:getContentSize().height-subH-(i-1)*160)
            end
            guangSp:setScale(0.0001)
            guangSpTb2[k]=guangSp
        end
    end

    for k,v in pairs(spTb) do
        local time = (k-1)*0.7

         if guangSpTb[k] then
            local delay=CCDelayTime:create(time)
            local scaleTo1 = CCScaleTo:create(0.6,2)
            local scaleTo2 = CCScaleTo:create(0.1,1.6)
            local acArr=CCArray:create()
            acArr:addObject(delay)
            acArr:addObject(scaleTo1)
            acArr:addObject(scaleTo2)

            local function callback()
                local rotateBy = CCRotateBy:create(4,360)
                local reverseBy = rotateBy:reverse()
                guangSpTb[k]:runAction(CCRepeatForever:create(reverseBy))
                -- guangSpTb[k]:runAction(CCRepeatForever:create(rotateBy))
            end
            local callFunc=CCCallFunc:create(callback)
            acArr:addObject(callFunc)

            local seq=CCSequence:create(acArr)
            guangSpTb[k]:runAction(seq)
        end


         if guangSpTb2[k] then
            local delay=CCDelayTime:create(time)
            local scaleTo1 = CCScaleTo:create(0.6,2)
            local scaleTo2 = CCScaleTo:create(0.1,1.6)
            local acArr=CCArray:create()
            acArr:addObject(delay)
            acArr:addObject(scaleTo1)
            acArr:addObject(scaleTo2)

            local function callback()
                local rotateBy = CCRotateBy:create(4,360)
                -- local reverseBy = rotateBy:reverse()
                -- guangSpTb2[k]:runAction(CCRepeatForever:create(reverseBy))
                guangSpTb2[k]:runAction(CCRepeatForever:create(rotateBy))
            end
            local callFunc=CCCallFunc:create(callback)
            acArr:addObject(callFunc)

            local seq=CCSequence:create(acArr)
            guangSpTb2[k]:runAction(seq)
        end



        local delay=CCDelayTime:create(time)
        local scale1=120/v:getContentSize().width
     	local scale2=100/v:getContentSize().width
        local scaleTo1 = CCScaleTo:create(0.3,scale1)
        local scaleTo2 = CCScaleTo:create(0.05,scale2)
        local acArr=CCArray:create()
        acArr:addObject(delay)
        acArr:addObject(scaleTo1)
        acArr:addObject(scaleTo2)
        if k==10 then
            local function callback()
                self.isAction=true
                self.againBtn:setVisible(true)
                self.okBtn:setVisible(true)
            end
            local callFunc=CCCallFunc:create(callback)
            acArr:addObject(callFunc)
        end
        local seq=CCSequence:create(acArr)
        v:runAction(seq)
    end

    self.guangSpTb=guangSpTb
    self.guangSpTb2=guangSpTb2
    self.spTb=spTb

    local function ok()
        self.tenSearchBg:setPosition(ccp(0,999999))
        self.tenSearchBg:setVisible(false)
        self.tenSearchBg:removeAllChildrenWithCleanup(true)
        self.goldLb2=nil

        -- self.titleBG:setPosition(ccp(0,999999))
        -- self.titleBG:setVisible(false)

        self.tenHuaBg:setPosition(ccp(0,999999))
        self.tenHuaBg:setVisible(false)
    end

    local subWidth=160
    local okItem=GetButtonItem("LoadingSelectServerBtn.png","LoadingSelectServerBtn_Down.png","LoadingSelectServerBtn_Down.png",ok,nil,getlocal("confirm"),25,100)
    local okBtn=CCMenu:createWithItem(okItem)
    okBtn:setTouchPriority(-(self.layerNum+1)*20-1)
    okBtn:setAnchorPoint(ccp(0.5,0.5))
    okBtn:setPosition(ccp(320+subWidth,50))
    self.tenSearchBg:addChild(okBtn)
    okBtn:setVisible(false)
    self.okBtn=okBtn
    local okLabel = tolua.cast(okItem:getChildByTag(100),"CCLabelTTF")
    okLabel:setPosition(ccp(okItem:getContentSize().width/2,okItem:getContentSize().height/2 + 5))

    local function tenCallback()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

        local function getRawardCallback(fn,data)
            local oldHeroList=heroVoApi:getHeroList()
            local ret,sData=base:checkServerData(data)
			if ret==true then
				if sData and sData.data and sData.data[self.activeName] then
					acBuyrewardVoApi:updateSpecialData(sData.data[self.activeName])
				end
				G_addPlayerAward(self.buyReward2.type,self.buyReward2.key,self.buyReward2.id,self.buyReward2.num,true)
				if sData and sData.data and sData.data.accessory then
        			accessoryVoApi:onRefreshData(sData.data.accessory)
        		end
				
		    	local playerGem=playerVoApi:getGems()
				local cost = acBuyrewardVoApi:getCostByType(2)
				playerVoApi:setGems(playerGem-cost)
				if sData and sData.data and sData.data[self.activeName] and sData.data[self.activeName].report then
					local report = sData.data[self.activeName].report
					local reward = {}
                    for k,v in pairs(sData.data[self.activeName].report) do
                        local item = FormatItem(v)
                        table.insert(reward,item[1])
                        G_addPlayerAward(item[1].type,item[1].key,item[1].id,item[1].num,true)
                    end
					self:showTenSearch(reward)
				end
				self:checkCost()
				
			end
        end
        local cost = acBuyrewardVoApi:getCostByType(2)
        if playerVoApi:getGems()<cost then 
        	local function onSure()
        		activityAndNoteDialog:closeAllDialog()
        	end
            GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost,onSure)
            do
                return
            end
        end
        self.tenSearchBg:removeAllChildrenWithCleanup(true)
        self.goldLb2=nil
        socketHelper:acBuyreward(2,false,self.activeName,getRawardCallback)
    end

    local againItem=GetButtonItem("LoadingSelectServerBtn.png","LoadingSelectServerBtn_Down.png","LoadingSelectServerBtn_Down.png",tenCallback,nil,getlocal("heroEquip_again"),25,100)
    local againBtn=CCMenu:createWithItem(againItem)
    againBtn:setTouchPriority(-(self.layerNum+1)*20-1)
    againBtn:setAnchorPoint(ccp(0.5,0.5))
    againBtn:setPosition(ccp(320-subWidth,50))
    self.tenSearchBg:addChild(againBtn)
    againBtn:setVisible(false)
    self.againBtn=againBtn
    local againLabel = tolua.cast(againItem:getChildByTag(100),"CCLabelTTF")
    againLabel:setPosition(ccp(againItem:getContentSize().width/2,againItem:getContentSize().height/2 + 5))

    local moneyNode = CCNode:create()

    local goldIconSp2=CCSprite:createWithSpriteFrameName("IconGold.png")
    goldIconSp2:setAnchorPoint(ccp(0,0.5))
    moneyNode:addChild(goldIconSp2)

    local cost = acBuyrewardVoApi:getCostByType(2)
    local goldLb2 = GetTTFLabel(cost,22)
    goldLb2:setAnchorPoint(ccp(0,0.5))
    moneyNode:addChild(goldLb2)
    self.goldLb2=goldLb2
    self:refreshVisible3()

    local moneyLabelWidth = goldIconSp2:getContentSize().width + goldLb2:getContentSize().width
    moneyNode:setContentSize(CCSizeMake(moneyLabelWidth,goldLb2:getContentSize().height))
    goldIconSp2:setPosition(ccp(0,moneyNode:getContentSize().height/2))
    goldLb2:setPosition(ccp(goldIconSp2:getContentSize().width,moneyNode:getContentSize().height/2))

    moneyNode:setPosition(ccp((againItem:getContentSize().width - moneyLabelWidth)/2,againItem:getContentSize().height+10))
    moneyNode:setAnchorPoint(ccp(0,0.5))
    againItem:addChild(moneyNode)


    if G_isIphone5()==true then
        okBtn:setPosition(ccp(320+subWidth,150))
        againBtn:setPosition(ccp(320-subWidth,150))
    end

end

function acBuyrewardDialog:isAddHuangguang(key,num)
    for k,v in pairs(self.flickItem) do
		-- for kk,vv in pairs(self.flickReward) do
		if v[1]==key and v[2]==num then
			return true
		end
		-- end
    end
    return false
end

function acBuyrewardDialog:showHero(reward,oldHeroList)
    if reward then
        local rewardTb=FormatItem(reward)
        local award=rewardTb[1]
        if award then
            if award.type=="h" then
                local type,heroIsExist,addNum,newProductOrder=heroVoApi:getNewHeroData(award,oldHeroList)
                self:showOneSearch(4,award,self.layerNum+1,heroIsExist,addNum,nil,newProductOrder,nil,"public/hero/heroequip/equipLabBigBg.jpg")

                if award.eType=="h" and heroIsExist==false then
                    heroVoApi:getNewHeroChat(award.key)
                end

                if heroVoApi:heroHonorIsOpen()==true then
                    local hid
                    if award.eType=="h" then 
                        hid=award.key
                    elseif award.eType=="s" then
                        hid=heroCfg.soul2hero[award.key]
                    end 
                    if hid and heroVoApi:getIsHonored(hid)==true then
                        local pid=heroCfg.getSkillItem
                        local id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
                        bagVoApi:addBag(id,addNum)
                    end
                end
            else
                G_addPlayerAward(award.type,award.key,award.id,award.num,true)
                self:showOneSearch(4,award,self.layerNum+1,nil,nil,nil,nil,nil,"public/hero/heroequip/equipLabBigBg.jpg")
            end
        end
    end
end

function acBuyrewardDialog:showOneSearch(type,item,layerNum,heroIsExist,addSoulNum,callback,newProductOrder,score,scenePic)
    if self.myLayer==nil then
        self.myLayer=CCLayer:create()
        self.bgLayer:addChild(self.myLayer,layerNum)
    end
   

    local layer = CCLayer:create()
    self.myLayer:addChild(layer,2)

    local function callback()
     
    end
    local diPic = "story/CheckpointBg.jpg"
    if scenePic then
        diPic = scenePic
    end
    local sceneSp=LuaCCSprite:createWithFileName(diPic,callback)
    sceneSp:setAnchorPoint(ccp(0,0))
    sceneSp:setPosition(ccp(0,0))
    sceneSp:setTouchPriority(-(layerNum)*20-1)
    self.myLayer:addChild(sceneSp)
    sceneSp:setColor(ccc3(150, 150, 150))
    if G_isIphone5()==true then
        sceneSp:setScaleY(1.2)
    end

    if scenePic then
        sceneSp:setScaleY(G_VisibleSizeHeight/sceneSp:getContentSize().height)
        sceneSp:setScaleX(G_VisibleSizeWidth/sceneSp:getContentSize().width)
    end

    local function onLoadIcon(fn,icon)
	    if self and self.myLayer then
			self.myLayer:addChild(icon)
			icon:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
			icon:setScaleX(G_VisibleSizeWidth/icon:getContentSize().width)
			icon:setScaleY(G_VisibleSizeHeight/icon:getContentSize().height)
			icon:setColor(ccc3(150, 150, 150))
	    end
    
	end
	local webImage = LuaCCWebImage:createWithURL(self.url,onLoadIcon)



    local function callback1()
        local particleS = CCParticleSystemQuad:create("public/1.plist")
        particleS:setScale(1)
        particleS.positionType=kCCPositionTypeFree
        particleS:setPosition(ccp(320,G_VisibleSizeHeight/2+100))
        layer:addChild(particleS,10)
    end
    local function callback2()
        local mIcon
        if item.type=="h" then
            if item.eType=="h" then
                mIcon=heroVoApi:getHeroIcon(item.key,item.num,nil,nil,nil,nil,nil,{adjutants={}})
            else
                mIcon=heroVoApi:getHeroIcon(item.key,1,false)
            end
        else
            mIcon=G_getItemIcon(item,100,false,layerNum)
        end
        if mIcon then
            local function callback3()
                local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
                -- local lightSp = CCSprite:createWithSpriteFrameName("BgSelect.png")
                lightSp:setAnchorPoint(ccp(0.5,0.5))
                lightSp:setPosition(ccp(320+7,G_VisibleSizeHeight/2+100))
                layer:addChild(lightSp,10)
                lightSp:setScale(2)

                local descStr=""
                local nameStr=item.name or ""
                if item.type=="h" and item.eType=="h" then
                else
                    nameStr=nameStr.."x"..item.num
                end
                if type==1 then
                    descStr=getlocal("getNewHeroDesc")
                elseif type==2 then
                    descStr=getlocal("getNewSoulDesc")
                elseif type==4 then
                    local name=self.buyReward1.name
                    local num=self.buyReward1.num
                    descStr=getlocal("equip_getReward",{name .. "*" .. num})
                else
                    descStr=getlocal("getNewPropDesc")
                end
                local lb=GetTTFLabelWrap(descStr,30,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                lb:setPosition(ccp(320,G_VisibleSizeHeight-150))
                lb:setColor(G_ColorYellowPro)
                layer:addChild(lb,11)

                local nameLb=GetTTFLabel(nameStr,30)
                nameLb:setPosition(ccp(320,G_VisibleSizeHeight/2-80))
                nameLb:setColor(G_ColorYellowPro)
                layer:addChild(nameLb,11)

                if addSoulNum and addSoulNum>0 then
                    local hid
                    if item.type=="h" then
                        if item.eType=="h" then
                            hid=item.key
                        elseif item.eType=="s" then
                            hid=heroCfg.soul2hero[item.key]
                        end
                    end
                    local existStr=""
                    if hid and heroVoApi:getIsHonored(hid)==true and heroVoApi:heroHonorIsOpen()==true then
                        existStr=getlocal("hero_honor_recruit_honored_hero",{addSoulNum})
                    elseif type==1 and heroIsExist==true then
                        if newProductOrder then
                            existStr=getlocal("hero_breakthrough_desc",{newProductOrder})
                        else
                            existStr=getlocal("alreadyHasDesc",{addSoulNum})
                        end
                    end
                    if existStr and existStr~="" then
                        local existLb=GetTTFLabelWrap(existStr,25,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                        existLb:setPosition(ccp(320,300))
                        existLb:setColor(G_ColorYellowPro)
                        layer:addChild(existLb,11)
                    end
                end
                if score and score~="" then
                        local scoreLb=GetTTFLabelWrap(getlocal("serverwar_get_point")..score,28,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                        scoreLb:setPosition(ccp(320,350))
                        scoreLb:setColor(G_ColorYellowPro)
                        layer:addChild(scoreLb,777)
                end
                local function ok( ... )
                    self.myLayer:removeFromParentAndCleanup(true)
                    self.freeLb1=nil

                    self.goldSp1=nil
                    self.goldNumLb1=nil
                    self.myLayer=nil
                    if callback then
                        callback()
                    end
                end

                local subWidth=160
                local okItem=GetButtonItem("LoadingSelectServerBtn.png","LoadingSelectServerBtn_Down.png","LoadingSelectServerBtn_Down.png",ok,nil,getlocal("confirm"),25,100)
                local okBtn=CCMenu:createWithItem(okItem)
                okBtn:setTouchPriority(-(layerNum)*20-2)
                okBtn:setAnchorPoint(ccp(1,0.5))
                okBtn:setPosition(ccp(320+subWidth,150))
                layer:addChild(okBtn,11)
                local okLabel = tolua.cast(okItem:getChildByTag(100),"CCLabelTTF")
                okLabel:setPosition(ccp(okItem:getContentSize().width/2,okItem:getContentSize().height/2 + 5))

                local lotteryGold = acBuyrewardVoApi:getCostByType(1)
                local function oneCallback()
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    local flag = acBuyrewardVoApi:canReward()
                    local function getRawardCallback(fn,data)
                        local oldHeroList=heroVoApi:getHeroList()
						local ret,sData = base:checkServerData(data)
						if ret==true then
							if sData and sData.data and sData.data[self.activeName] then
								acBuyrewardVoApi:updateSpecialData(sData.data[self.activeName])
							end
							G_addPlayerAward(self.buyReward1.type,self.buyReward1.key,self.buyReward1.id,self.buyReward1.num,true)
							if sData and sData.data and sData.data.accessory then
			        			accessoryVoApi:onRefreshData(sData.data.accessory)
			        		end
			        		if free then
						        self.isToday=true
						    else
						    	local playerGem=playerVoApi:getGems()
								local cost = acBuyrewardVoApi:getCostByType(1)
								playerVoApi:setGems(playerGem-cost)
							end
							if sData and sData.data and sData.data[self.activeName] and sData.data[self.activeName].report then
								local report = sData.data[self.activeName].report
								self:showHero(report[1],oldHeroList)
								
							end
							self:checkCost()
						end
                    end
                    if flag==true then
                        layer:removeFromParentAndCleanup(true)
                        self.freeLb1=nil

                        self.goldSp1=nil
                        self.goldNumLb1=nil

                        socketHelper:acBuyreward(1,true,self.activeName,getRawardCallback)
                    else
                            
                        if playerVoApi:getGems()<lotteryGold then 
							local function onSure()
								activityAndNoteDialog:closeAllDialog()
							end
                            GemsNotEnoughDialog(nil,nil,lotteryGold-playerVoApi:getGems(),layerNum+1,lotteryGold,onSure)
                            do
                                return
                            end
                        end
                        layer:removeFromParentAndCleanup(true)
                        self.freeLb1=nil


                        self.goldSp1=nil
                        self.goldNumLb1=nil
                        socketHelper:acBuyreward(1,false,self.activeName,getRawardCallback)
                    end
                end

                local againItem=GetButtonItem("LoadingSelectServerBtn.png","LoadingSelectServerBtn_Down.png","LoadingSelectServerBtn_Down.png",oneCallback,nil,getlocal("heroEquip_again"),25,100)
                local againBtn=CCMenu:createWithItem(againItem)
                againBtn:setTouchPriority(-(self.layerNum+1)*20-2)
                againBtn:setAnchorPoint(ccp(0.5,0.5))
                againBtn:setPosition(ccp(320-subWidth,150))
                layer:addChild(againBtn,11)
                local againLabel = tolua.cast(againItem:getChildByTag(100),"CCLabelTTF")
                againLabel:setPosition(ccp(againItem:getContentSize().width/2,againItem:getContentSize().height/2 + 5))

                local height=againItem:getContentSize().height+10
                local freeLb = GetTTFLabelWrap(getlocal("daily_lotto_tip_2"),22,CCSizeMake(100, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                freeLb:setAnchorPoint(ccp(0.5,0.5))
                againItem:addChild(freeLb)
                freeLb:setPosition(ccp(againItem:getContentSize().width-140,height))
                self.freeLb1=freeLb



                local moneyNode = CCNode:create()

                local goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
                goldSp:setAnchorPoint(ccp(0,0.5))
                moneyNode:addChild(goldSp)
                self.goldSp1=goldSp

                local goldNumLb = GetTTFLabel(lotteryGold,22)
                goldNumLb:setAnchorPoint(ccp(0,0.5))
                moneyNode:addChild(goldNumLb)
                self.goldNumLb1=goldNumLb

                local moneyLabelWidth = goldSp:getContentSize().width + goldNumLb:getContentSize().width
                moneyNode:setContentSize(CCSizeMake(moneyLabelWidth,goldNumLb:getContentSize().height))
                goldSp:setPosition(ccp(0,moneyNode:getContentSize().height/2))
                goldNumLb:setPosition(ccp(goldSp:getContentSize().width,moneyNode:getContentSize().height/2))

                moneyNode:setPosition(ccp((againItem:getContentSize().width - moneyLabelWidth)/2,againItem:getContentSize().height+10))
                moneyNode:setAnchorPoint(ccp(0,0.5))
                againItem:addChild(moneyNode)

                self:refreshVisible2()
            end
            mIcon:setScale(0)
            mIcon:setPosition(ccp(320,G_VisibleSizeHeight/2+100))
            layer:addChild(mIcon,11)
            local ccScaleTo = CCScaleTo:create(0.6,150/mIcon:getContentSize().width)
            local ccScaleTo1 = CCScaleTo:create(0.1,(150+100)/mIcon:getContentSize().width)
            local ccScaleTo2 = CCScaleTo:create(0.1,150/mIcon:getContentSize().width)
            local callFunc3=CCCallFunc:create(callback3)
            local acArr=CCArray:create()
            acArr:addObject(ccScaleTo)
            acArr:addObject(ccScaleTo1)
            acArr:addObject(ccScaleTo2)
            acArr:addObject(callFunc3)
            local seq=CCSequence:create(acArr)
            mIcon:runAction(seq)
        end
    end
    local callFunc1=CCCallFunc:create(callback1)
    local callFunc2=CCCallFunc:create(callback2)

    local delay=CCDelayTime:create(0.2)
    local acArr=CCArray:create()
    acArr:addObject(delay)
    acArr:addObject(callFunc1)
    acArr:addObject(callFunc2)
    local seq=CCSequence:create(acArr)
    sceneSp:runAction(seq)
end

function acBuyrewardDialog:refreshVisible2()
    if self.freeLb1==nil or self.goldSp1==nil or self.goldNumLb1==nil then
        return
    end
    local goldNum1=acBuyrewardVoApi:getCostByType(1)
	local haveCost = playerVoApi:getGems()

    if acBuyrewardVoApi:canReward()==true then
        self.freeLb1:setVisible(true)
        self.goldSp1:setVisible(false)
        self.goldNumLb1:setVisible(false)
    else
        self.freeLb1:setVisible(false)
        self.goldSp1:setVisible(true)
        self.goldNumLb1:setVisible(true)
    end
    if haveCost<goldNum1 then
    	self.goldNumLb1:setColor(G_ColorRed)
    else
    	self.goldNumLb1:setColor(G_ColorWhite)
    end

end

function acBuyrewardDialog:refreshVisible3()
	if self.goldLb2==nil then
		return
	end
	local goldNum2=acBuyrewardVoApi:getCostByType(2)
	local haveCost = playerVoApi:getGems()
	-- print("++++++goldNum2,haveCost",goldNum2,haveCost)
	if haveCost<goldNum2 then
    	self.goldLb2:setColor(G_ColorRed)
    else
    	self.goldLb2:setColor(G_ColorWhite)
    end
end



function acBuyrewardDialog:dispose()
	self.isShow=nil
	self.activeName=nil
	eventDispatcher:removeEventListener("activity.recharge",self.KoreaListener)
	spriteController:removePlist("public/datebaseShow.plist")
    spriteController:removeTexture("public/datebaseShow.png")
end
