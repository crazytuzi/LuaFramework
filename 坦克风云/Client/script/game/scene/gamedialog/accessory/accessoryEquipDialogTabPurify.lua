--配件精炼的tab
accessoryEquipDialogTabPurify={}

function accessoryEquipDialogTabPurify:new(tankID,partID)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	nc.tankID=tankID
	nc.partID=partID
	nc.flag = 1
	nc.data=accessoryVoApi:getAccessoryByPart(tankID,partID)
	return nc
end

function accessoryEquipDialogTabPurify:init(layerNum,parent)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("serverWar/serverWar2.plist")
	self:initUp()
	self:initDown()
	return self.bgLayer
end

function accessoryEquipDialogTabPurify:initUp()
	local function touchItem()
		PlayEffect(audioCfg.mouseClick)
		local td=smallDialog:new()
		local str1 = getlocal("purifying_item_des1")
		local str2 = getlocal("purifying_item_des2")
		local str3 = getlocal("purifying_item_des3")
		local str4 = getlocal("purifying_item_des4")
		local tabStr = {" ",str4,str3,str2,str1," "}
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,{})
		sceneGame:addChild(dialog,self.layerNum+1)
	end
	local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchItem,11,nil,nil)
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(self.bgLayer:getContentSize().width - 80,G_VisibleSizeHeight - 245))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(infoBtn,3)
	local function touchSp()
		PlayEffect(audioCfg.mouseClick)
		require "luascript/script/game/scene/gamedialog/purifying/purifyingSmallUpdateDialog"
		local smallDialog=purifyingSmallUpdateDialog:new()
		smallDialog:init(self.layerNum+1,self.parent,getlocal("upgradeBuild"))
	end

	local engineerSp = LuaCCSprite:createWithSpriteFrameName("jiyou.png",touchSp)
	engineerSp:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(engineerSp)
	engineerSp:setPosition(90,G_VisibleSizeHeight - 245)
	engineerSp:setScale(1.2)
	local lbWidth = 180
	local strSize2 = 25
	local needWidth = 40
	if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="tu" or G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage() =="ar" then
		lbWidth =150
		strSize2 = 20
		needWidth = 120
	end
	local quality = self.data:getConfigData("quality")
	local lvLb = GetTTFLabel(getlocal("purifying_engineer_level",{accessoryVoApi:getSuccinct_level()}),strSize2)
	lvLb:setPosition(ccp(lbWidth,G_VisibleSizeHeight - 200))
	lvLb:setAnchorPoint(ccp(0,0.5))
	self.bgLayer:addChild(lvLb)
	self.lvLb=lvLb
	local exp=succinctCfg.engineerExp[accessoryVoApi:getSuccinct_level()+1]
	local subLevel
	if  accessoryVoApi:getSuccinct_level()==1 then
		subLevel=0
	else
		subLevel=succinctCfg.engineerExp[accessoryVoApi:getSuccinct_level()]
	end
	local exLbStr = GetTTFLabel(getlocal("purifying_engineer_experience2",{""}),strSize2)
	exLbStr:setPosition(ccp(lbWidth,G_VisibleSizeHeight - 230))
	exLbStr:setAnchorPoint(ccp(0,0.5))
	self.bgLayer:addChild(exLbStr)

	local exLb = GetTTFLabel(getlocal("scheduleChapter",{accessoryVoApi:getSuccinct_exp()-subLevel,exp-subLevel}),strSize2)
	exLb:setPosition(ccp(exLbStr:getPositionX()+exLbStr:getContentSize().width,G_VisibleSizeHeight - 230))
	exLb:setAnchorPoint(ccp(0,0.5))
	self.bgLayer:addChild(exLb)
	self.exLb=exLb
	local lifeLb
	if quality==3 then
		lifeLb = GetTTFLabel(getlocal("engineer_experience1_limit",{""}),strSize2)
	else
		lifeLb = GetTTFLabel(getlocal("engineer_experience1_limit",{succinctCfg.attLifeLimit[accessoryVoApi:getSuccinct_level()]*100 .. "%%"}),strSize2)
	end
	lifeLb:setPosition(ccp(lbWidth,G_VisibleSizeHeight - 260))
	lifeLb:setAnchorPoint(ccp(0,0.5))
	self.bgLayer:addChild(lifeLb)
	self.lifeLb=lifeLb

	local proLb
	if quality==3 then
		proLb = GetTTFLabel(getlocal("engineer_experience2_limit",{""}),strSize2)
	else
		proLb = GetTTFLabel(getlocal("engineer_experience2_limit",{succinctCfg.arpArmorLimit[accessoryVoApi:getSuccinct_level()]}),strSize2)
	end
	proLb:setPosition(ccp(lbWidth,G_VisibleSizeHeight - 290))
	proLb:setAnchorPoint(ccp(0,0.5))
	self.bgLayer:addChild(proLb)
	self.proLb=proLb
	if quality==3 then
		local lifePercent = GetTTFLabel(succinctCfg.attLifeLimit[accessoryVoApi:getSuccinct_level()]*100/2 .. "%",strSize2)
		lifePercent:setPosition(ccp(lifeLb:getContentSize().width,lifeLb:getContentSize().height/2))
		lifeLb:addChild(lifePercent)
		lifePercent:setAnchorPoint(ccp(0,0.5))
		lifePercent:setColor(G_ColorYellowPro)
		self.lifePercent=lifePercent

		local proPercent = GetTTFLabel(succinctCfg.arpArmorLimit[accessoryVoApi:getSuccinct_level()]/2,strSize2)
		proPercent:setPosition(ccp(proLb:getContentSize().width,proLb:getContentSize().height/2))
		proLb:addChild(proPercent)
		proPercent:setAnchorPoint(ccp(0,0.5))
		proPercent:setColor(G_ColorYellowPro)
		self.proPercent=proPercent
	end
end

function accessoryEquipDialogTabPurify:initDown()
	local spH = G_VisibleSizeHeight - 100
	local lbWidth = 220
	local strSize2 = 25
	local needWidth = 40
	if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="tu" or G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage() =="ar" then
		lbWidth =150
		strSize2 = 20
		needWidth = 120
	end
	local function btnSaveCallback()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		self:save()
	end
	local saveItem = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",btnSaveCallback,nil,getlocal("collect_border_save"),24/0.7)
	saveItem:setScale(0.7)
	local saveMenu=CCMenu:createWithItem(saveItem)
	saveMenu:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-890))
	saveMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(saveMenu)
	saveItem:setEnabled(false)
	self.saveItem=saveItem

	local function btnPurifyingCallback()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		self:purify()
	end
	local purifyingItem = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",btnPurifyingCallback,nil,getlocal("purifying"),24/0.7)
	purifyingItem:setScale(0.7)
	local purifyingMenu=CCMenu:createWithItem(purifyingItem)
	purifyingMenu:setPosition(ccp(G_VisibleSizeWidth/2 - 200,G_VisibleSizeHeight - 890))
	purifyingMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(purifyingMenu)

	local award = self:getConsume()
	local level = accessoryVoApi:getSuccinct_level()
	local num = award.num
	if level < succinctCfg.privilege_5 then
		num=award.num
	elseif level < succinctCfg.privilege_10 then
		num=award.num*0.9
	else
		num=award.num*0.8
	end

	local numStr = FormatNumber(num)
	local consumeStr = getlocal("activity_tankjianianhua_Consume")  .. numStr
	self.consumeLb=GetTTFLabel(consumeStr,20)
	self.bgLayer:addChild(self.consumeLb)
	self.consumeLb:setPosition(ccp(G_VisibleSizeWidth/2-200,G_VisibleSizeHeight - 830))
	
	local r4 = playerVoApi:getR4()
	if num>r4 then
		self.consumeLb:setColor(G_ColorRed)
	else
		self.consumeLb:setColor(G_ColorWhite)
	end

	local function nilTouch()
	end
	self.consumeSp=LuaCCSprite:createWithSpriteFrameName("IconUranium.png",nilTouch)
	self.consumeSp:setAnchorPoint(ccp(0,0.5))
	self.consumeLb:addChild(self.consumeSp)
	self.consumeSp:setPosition(ccp(self.consumeLb:getContentSize().width + 5,self.consumeLb:getContentSize().height/2))

	local function btnAutoPurifyingCallback()
		local flag = 0
		if self.changeTypeTb then
			for i,v in ipairs(self.changeTypeTb) do
				if v>0 then
					flag = v
					break
				end
			end
		end 
		PlayEffect(audioCfg.mouseClick)
		if flag>0 then	  
			require "luascript/script/game/scene/gamedialog/purifying/purifyingCheckSave"
			local smallDialog=purifyingCheckSave:new(self,true)
			smallDialog:init(self.layerNum+1,self.parent,getlocal("dialog_title_prompt"))
		else
			if self.changeTypeLb then
				for k,v in pairs(self.changeTypeLb) do
					v:removeFromParentAndCleanup(true)
				end
			   
			end
			self.changeTypeLb=nil
			self.changeTypeTb=nil
			if self.gsAddLb then
				self.gsAddLb:removeFromParentAndCleanup(true)
			end
			self.gsAddLb=nil
			require "luascript/script/game/scene/gamedialog/purifying/begingPurifyingDialog"
			local td=begingPurifyingDialog:new(self,self.data,"p"..self.partID,"t"..self.tankID)
			local tbArr={}
			local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("begin_purifying"),true,self.layerNum+1)
			sceneGame:addChild(dialog,self.layerNum+1)
		end
	end
	local autoPurifyingItem = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",btnAutoPurifyingCallback,nil,getlocal("privilege_1"),24/0.7)
	autoPurifyingItem:setScale(0.7)
	self.autoPurifyingItem=autoPurifyingItem
	local autoPurifyingMenu=CCMenu:createWithItem(autoPurifyingItem)
	autoPurifyingMenu:setPosition(ccp(G_VisibleSizeWidth/2 + 200,G_VisibleSizeHeight - 890))
	autoPurifyingMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(autoPurifyingMenu)

	local function bsClick(hd,fn,idx)
	end

	local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),bsClick)
	backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60, 190))
	backSprie:setAnchorPoint(ccp(0.5,0))
	backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
	backSprie:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 510))
	self.bgLayer:addChild(backSprie,1)

	local function onClickIcon()
	end
	local aIcon=accessoryVoApi:getAccessoryIcon(self.data.type,60,80,onClickIcon)
	aIcon:setTouchPriority(-(self.layerNum-1)*20-2)
	aIcon:setAnchorPoint(ccp(0,1))
	aIcon:setPosition(ccp(20,backSprie:getContentSize().height-10))
	backSprie:addChild(aIcon,1)

	local nameStr
	if self.data:getConfigData("quality")==3 then
		nameStr=getlocal(self.data:getConfigData("name")) .. getlocal("purifying_advance")
	elseif self.data:getConfigData("quality")==4 then
		nameStr=getlocal(self.data:getConfigData("name")) .. getlocal("purifying_external")
    else
        nameStr=getlocal(self.data:getConfigData("name")) .. getlocal("purifying_red")
	end
	local nameLb=GetTTFLabelWrap(nameStr,strSize2,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	nameLb:setAnchorPoint(ccp(0,1))
	nameLb:setPosition(150,backSprie:getContentSize().height-20)
	backSprie:addChild(nameLb)

	local succinct = self.data:getSuccinct()
	local gsLbHeightPos = 60
	local LbSizeWidth= 200
	-- if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="tu" or G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage() =="ja" or 
	if G_getCurChoseLanguage() =="ar" then
		LbSizeWidth =400
	end

	local gsStr = math.ceil((succinct[1]+succinct[2])*800+(succinct[3]+succinct[4])*20)

	local gsLb=GetTTFLabelWrap(getlocal("purifying_gsAdd",{gsStr}),25,CCSizeMake(self.bgLayer:getContentSize().width-LbSizeWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	gsLb:setAnchorPoint(ccp(0,1))
	gsLb:setPosition(150,backSprie:getContentSize().height-gsLbHeightPos)
	backSprie:addChild(gsLb)
	self.gsLb=gsLb

	self.attributeTb={}
	local arrStr1=succinct[1]*100 .. "%%"
	local attribute1 = GetTTFLabelWrap(getlocal("purifying_attribute1",{arrStr1}),20,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	attribute1:setAnchorPoint(ccp(0,0))
	attribute1:setPosition(30,60)
	backSprie:addChild(attribute1)
	self.attributeTb[1]=attribute1

	local attribute3 = GetTTFLabelWrap(getlocal("purifying_attribute3",{succinct[3]}),20,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	attribute3:setAnchorPoint(ccp(0,0))
	attribute3:setPosition(30,30)
	backSprie:addChild(attribute3)
	self.attributeTb[3]=attribute3

	local arrStr2=succinct[2]*100 .. "%%"
	local attribute2 = GetTTFLabelWrap(getlocal("purifying_attribute2",{arrStr2}),20,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	attribute2:setAnchorPoint(ccp(0,0))
	attribute2:setPosition(300,60)
	backSprie:addChild(attribute2)
	self.attributeTb[2]=attribute2

	local attribute4 = GetTTFLabelWrap(getlocal("purifying_attribute4",{succinct[4]}),20,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	attribute4:setAnchorPoint(ccp(0,0))
	attribute4:setPosition(300,30)
	backSprie:addChild(attribute4)
	self.attributeTb[4]=attribute4

	local desType = self.data.type
	local refineId = accessoryCfg.aCfg[desType].refineId
	local bounsAtt = succinctCfg.bounsAtt[refineId]
	self.bounsAtt=bounsAtt
	local str1
	local str2
	local str3
	local str4
	local posY=G_VisibleSizeHeight - 550
	local pointFlag={0,0,0,0}
	self.desLbTb={}
	self.pointSpTb={}
	for i=1,4 do
		local attIndex
		if(i==1)then
			attIndex=2
		elseif(i==2)then
			attIndex=1
		else
			attIndex=i
		end
		for k,v in pairs(bounsAtt[i][1]) do
			str1 = G_getPropertyStr(k)
			if(i<3)then
				str3 = v*100 .. "%%"
			else
				str3 = v
			end
			if succinct[attIndex]>=v then
				pointFlag[i]=1
			end
		end
		for k,v in pairs(bounsAtt[i][2]) do
			str2 = G_getPropertyStr(k)
			str4 = v .. "%%"	
		end
		local des = GetTTFLabelWrap(getlocal("purifying_des1",{str2,str4,str1,str3}),22,CCSizeMake(540,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		des:setAnchorPoint(ccp(0,0.5))
		des:setPosition(80,posY)
		self.bgLayer:addChild(des)
		self["des"..i]=des
		self.desLbTb[i]=des
		local pointSp
		local function nilFunc()
		end
		if pointFlag[i]==1 then
			pointSp = LuaCCSprite:createWithSpriteFrameName("circleSelect.png",nilFunc)
		else
			pointSp = LuaCCSprite:createWithSpriteFrameName("circlenormal.png",nilFunc)
			self.desLbTb[i]:setColor(G_ColorGray)
		end
		pointSp:setPosition(50,posY)
		self.bgLayer:addChild(pointSp)
		self.pointSpTb[i]=pointSp
		posY=posY - 55
	end
    local wayUnlockCfg={succinctCfg.privilege_1,succinctCfg.privilege_2,succinctCfg.privilege_4}
	local level=accessoryVoApi:getSuccinct_level()
	local function touch1(object,name,tag)   
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        tag=tag/99
        local selectIdx=tag-100
		local level=accessoryVoApi:getSuccinct_level()
        if level<wayUnlockCfg[selectIdx] then
            local tipStr=getlocal("unlock_str",{getlocal("purifying_engineer_levelStr"),getlocal("level_title",{wayUnlockCfg[selectIdx]})})
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,30)
            do return end
        end
		if tag==self.flag+100 then
			return
		else
			PlayEffect(audioCfg.mouseClick)
			if self.flag==1 then
				self.typeSp1:initWithSpriteFrameName("LegionCheckBtnUn.png")
			elseif self.flag==2 then
				self.typeSp2:initWithSpriteFrameName("LegionCheckBtnUn.png")
			else
				self.typeSp3:initWithSpriteFrameName("LegionCheckBtnUn.png")
			end
			self.flag=tag-100
			if self.flag==1 then
				self.typeSp1:initWithSpriteFrameName("LegionCheckBtn.png")
			elseif self.flag==2 then
				self.typeSp2:initWithSpriteFrameName("LegionCheckBtn.png")
			else
				self.typeSp3:initWithSpriteFrameName("LegionCheckBtn.png")
			end
			self:refreshConsume()
		end
	end
	for i=1,3 do
		local typeGraySp1=GraySprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
		local typeSp1=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",touch1)
		local str
		if i==1 then
			str = getlocal("purifying_common")
		elseif i==2 then
			str = getlocal("purifying_expert")
		else
			str = getlocal("purifying_master")
		end
		local typeLb1 = GetTTFLabel(str,25)
		local tag=i+100
		typeSp1:setTag(tag)
		-- typeSp1:setTouchPriority(-(self.layerNum-1)*20-4)
		typeSp1:setPosition(100+(i-1)*180,posY - 10)
		self.bgLayer:addChild(typeSp1,2)
		typeGraySp1:setPosition(typeSp1:getPosition())
		self.bgLayer:addChild(typeGraySp1,2)

		local x,y=typeSp1:getPosition()
		self:addTouchBg(self.bgLayer,ccp(x,y),touch1,tag*99,80,80)

		typeLb1:setPosition(ccp(140+(i-1)*180,posY - 10))
		typeLb1:setAnchorPoint(ccp(0,0.5))
		self.bgLayer:addChild(typeLb1)
		if i==1 then
			self.typeSp1=typeSp1
			self.typeLb1 = typeLb1
			self.typeGraySp1=typeGraySp1
		elseif i==2 then
			self.typeSp2=typeSp1
			self.typeLb2 = typeLb1
			self.typeGraySp2=typeGraySp1

		else
			self.typeSp3=typeSp1
			self.typeLb3 = typeLb1
			self.typeGraySp3=typeGraySp1
		end
	end
	self.partIDTb={}
	self.partIDTb[1]=self.typeSp2:getPosition()
	self.partIDTb[2]=self.typeSp3:getPosition()
	self.typeSp1:initWithSpriteFrameName("LegionCheckBtn.png")
	self.typeGraySp1:setVisible(false)
	local level = accessoryVoApi:getSuccinct_level()

	if level < succinctCfg.privilege_2 then
		self.typeSp2:setVisible(false)
		self.typeLb2:setColor(G_ColorGray)
		self.typeGraySp2:setVisible(true)

		self.typeSp3:setVisible(false)
		self.typeGraySp3:setVisible(true)
		self.typeLb3:setColor(G_ColorGray)
	elseif level < succinctCfg.privilege_4 then
		self.typeSp2:setVisible(true)
		self.typeLb2:setColor(G_ColorWhite)
		self.typeGraySp2:setVisible(false)

		self.typeSp3:setVisible(false)
		self.typeGraySp3:setVisible(true)
		self.typeLb3:setColor(G_ColorGray)
	else
		self.typeGraySp1:setVisible(false)
		self.typeGraySp2:setVisible(false)
		self.typeGraySp3:setVisible(false)
	end
	if level<succinctCfg.privilege_1 then
		self.autoPurifyingItem:setVisible(false)
	end
end

function accessoryEquipDialogTabPurify:addTouchBg(parent,pos,handler,tag,width,height)
    width=width or 100
    height=height or 100
    local rect=CCSizeMake(width,height)
    local touchBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),handler)
    touchBg:setTouchPriority(-(self.layerNum-1)*20-4)
    touchBg:setContentSize(rect)
    touchBg:setTag(tag)
    touchBg:setOpacity(0)
    touchBg:setPosition(pos)
    parent:addChild(touchBg,5)
end

function accessoryEquipDialogTabPurify:refreshConsume()
	local key,num = self:getConsumeKeyAndNum()
	if self.consumeLb and self.consumeSp then
		if key=="r4" then
			local numStr = FormatNumber(num)
			local consumeStr = getlocal("activity_tankjianianhua_Consume")  .. numStr
			self.consumeLb:setString(consumeStr)
			self.consumeSp:initWithSpriteFrameName("IconUranium.png")
			self.consumeSp:setScale(1)
			self.consumeSp:setAnchorPoint(ccp(0,0.5))
			self.consumeSp:setPosition(ccp(self.consumeLb:getContentSize().width+5,self.consumeLb:getContentSize().height/2))
			self.consumeSp:setVisible(true)
			local r4 = playerVoApi:getR4()
			if num>r4 then
				self.consumeLb:setColor(G_ColorRed)
			else
				self.consumeLb:setColor(G_ColorWhite)
			end
		elseif key=="p8" then
			local succ_at = accessoryVoApi:getSucc_at()
			if G_isToday(succ_at)==false then
				num=getlocal("daily_lotto_tip_2")
				self.consumeLb:setColor(G_ColorWhite)
			else
				local shopProps = accessoryVoApi:getShopPropNum()
				if num>shopProps.p8 then
					self.consumeLb:setColor(G_ColorRed)
				else
					self.consumeLb:setColor(G_ColorWhite)
				end
			end
			local numStr = num
			if type(num)=="number" then
				numStr = FormatNumber(numStr)
			end

			local consumeStr = getlocal("activity_tankjianianhua_Consume")  .. numStr
			self.consumeLb:setString(consumeStr)
			self.consumeSp:initWithSpriteFrameName("accessoryP8_1.png")
			self.consumeSp:setScale(0.3)
			self.consumeSp:setAnchorPoint(ccp(0,0.5))
			self.consumeSp:setPosition(ccp(self.consumeLb:getContentSize().width+5,self.consumeLb:getContentSize().height/2))
			if G_isToday(succ_at)==false then
				self.consumeSp:setVisible(false)
			else
				self.consumeSp:setVisible(true)
			end
		elseif key=="p9" then
			local succ_at = accessoryVoApi:getSucc_at()
			if G_isToday(succ_at)==false then
				num=getlocal("daily_lotto_tip_2")
				self.consumeLb:setColor(G_ColorWhite)
			else
				local shopProps = accessoryVoApi:getShopPropNum()
				if num>shopProps.p9 then
					self.consumeLb:setColor(G_ColorRed)
				else
					self.consumeLb:setColor(G_ColorWhite)
				end
			end
			local numStr = num
			if type(num)=="number" then
				numStr = FormatNumber(numStr)
			end
			local consumeStr = getlocal("activity_tankjianianhua_Consume")  .. numStr
			self.consumeLb:setString(consumeStr)
			self.consumeSp:initWithSpriteFrameName("accessoryP9_1.png")
			self.consumeSp:setScale(0.3)
			self.consumeSp:setAnchorPoint(ccp(0,0.5))
			self.consumeSp:setPosition(ccp(self.consumeLb:getContentSize().width+5,self.consumeLb:getContentSize().height/2))
			if G_isToday(succ_at)==false then
				self.consumeSp:setVisible(false)
			else
				self.consumeSp:setVisible(true)
			end
		elseif key=="p10" then
			local succ_at = accessoryVoApi:getSucc_at()
			if G_isToday(succ_at)==false then
				num=getlocal("daily_lotto_tip_2")
				self.consumeLb:setColor(G_ColorWhite)
			else
				local shopProps = accessoryVoApi:getShopPropNum()
				if num>shopProps.p10 then
					self.consumeLb:setColor(G_ColorRed)
				else
					self.consumeLb:setColor(G_ColorWhite)
				end
			end
			local numStr = num
			if type(num)=="number" then
				numStr = FormatNumber(numStr)
			end
			local consumeStr = getlocal("activity_tankjianianhua_Consume")  .. numStr
			self.consumeLb:setString(consumeStr)
			self.consumeSp:initWithSpriteFrameName("accessoryP10_1.png")
			self.consumeSp:setScale(0.3)
			self.consumeSp:setAnchorPoint(ccp(0,0.5))
			self.consumeSp:setPosition(ccp(self.consumeLb:getContentSize().width+5,self.consumeLb:getContentSize().height/2))
			if G_isToday(succ_at)==false then
				self.consumeSp:setVisible(false)
			else
				self.consumeSp:setVisible(true)
			end
		elseif key=="gems" then
			local numStr = FormatNumber(num)
			local consumeStr = getlocal("activity_tankjianianhua_Consume")  .. numStr
			self.consumeLb:setString(consumeStr)
			self.consumeSp:initWithSpriteFrameName("IconGold.png")
			self.consumeSp:setScale(1)
			self.consumeSp:setAnchorPoint(ccp(0,0.5))
			self.consumeSp:setPosition(ccp(self.consumeLb:getContentSize().width+5,self.consumeLb:getContentSize().height/2))
			self.consumeSp:setVisible(true)
			if playerVoApi:getGems()<num then
				self.consumeLb:setColor(G_ColorRed)
			else
				self.consumeLb:setColor(G_ColorYellow)
			end 
		end
	end
end

function accessoryEquipDialogTabPurify:refresh()
	self.lvLb:setString(getlocal("purifying_engineer_level",{accessoryVoApi:getSuccinct_level()}))
	local exp
	-- if accessoryVoApi:getSuccinct_level()==succinctCfg.engineerLvLimit then
	--	 exp=succinctCfg.engineerExp[succinctCfg.engineerLvLimit]
	-- else
		exp=succinctCfg.engineerExp[accessoryVoApi:getSuccinct_level()+1]
	-- end
	local subLevel
	 if  accessoryVoApi:getSuccinct_level()==1 then
		subLevel=0
	else
		subLevel=succinctCfg.engineerExp[accessoryVoApi:getSuccinct_level()]
	 end
	self.exLb:setString(getlocal("scheduleChapter",{accessoryVoApi:getSuccinct_exp()-subLevel,exp-subLevel}))

	if self.lifePercent then
		self.lifePercent:setString(succinctCfg.attLifeLimit[accessoryVoApi:getSuccinct_level()]*100/2 .. "%")
	else
		self.lifeLb:setString(getlocal("engineer_experience1_limit",{succinctCfg.attLifeLimit[accessoryVoApi:getSuccinct_level()]*100 .. "%%"}))
	end
	
	if self.proPercent then
		self.proPercent:setString(succinctCfg.arpArmorLimit[accessoryVoApi:getSuccinct_level()]/2)
	else
		self.proLb:setString(getlocal("engineer_experience2_limit",{succinctCfg.arpArmorLimit[accessoryVoApi:getSuccinct_level()]}))
	end

	-- 类型
	local level = accessoryVoApi:getSuccinct_level()
	if level < succinctCfg.privilege_2 then
	elseif level < succinctCfg.privilege_4 then
		self.typeSp2:setVisible(true)
		self.typeLb2:setColor(G_ColorWhite)
		self.typeGraySp2:setVisible(false)
	else
		self.typeSp2:setVisible(true)
		self.typeLb2:setColor(G_ColorWhite)
		self.typeGraySp2:setVisible(false)

		self.typeSp3:setVisible(true)
		self.typeLb3:setColor(G_ColorWhite)
		self.typeGraySp3:setVisible(false)
	end

	if level>=succinctCfg.privilege_1 then
		self.autoPurifyingItem:setVisible(true)
	end
end 

function accessoryEquipDialogTabPurify:refreshType()
	-- 属性
	local succinct = self.data:getSuccinct()
	for k,v in pairs(self.attributeTb) do
		local str 
		if k==1 or k==2 then
			str = succinct[k]*100 .."%%"
		else
			str = succinct[k]
		end
		v:setString(getlocal("purifying_attribute" .. k,{str}))
	end
	local gsStr = math.ceil((succinct[1]+succinct[2])*800+(succinct[3]+succinct[4])*20)
	self.gsLb:setString(getlocal("purifying_gsAdd",{gsStr}))

	local pointFlag={0,0,0,0}
	for k,v in pairs(self.bounsAtt[1][1]) do
		if succinct[2]>=v then
			pointFlag[1]=1
		end
	end
	for k,v in pairs(self.bounsAtt[2][1]) do
		if succinct[1]>=v then
			pointFlag[2]=1
		end
	end
	for k,v in pairs(self.bounsAtt[3][1]) do
		if succinct[3]>=v then
			pointFlag[3]=1
		end
	end
	for k,v in pairs(self.bounsAtt[4][1]) do
		if succinct[4]>=v then
			pointFlag[4]=1
		end
	end
	for k,v in pairs(pointFlag) do
		if v == 1 then
			self.pointSpTb[k]:initWithSpriteFrameName("circleSelect.png")
			self.desLbTb[k]:setColor(G_ColorWhite)
		else
			self.pointSpTb[k]:initWithSpriteFrameName("circlenormal.png")
			self.desLbTb[k]:setColor(G_ColorGray)
		end
	end
	
end 

function accessoryEquipDialogTabPurify:getConsumeKeyAndNum()
	local award = self:getConsume()
	local level = accessoryVoApi:getSuccinct_level()
	local num=0
	if award.key=="r4" then
		if level < succinctCfg.privilege_5 then
			num=award.num
		elseif level < succinctCfg.privilege_10 then
			num=award.num*0.9
		else
			num=award.num*0.8
		end
	elseif award.key=="p8" then	   
		if level < succinctCfg.privilege_7 then
			num=award.num
		elseif level < succinctCfg.privilege_11 then
			num=award.num*0.9
		else
			num=award.num*0.8
		end
	elseif award.key=="p9" then
		if level < succinctCfg.privilege_7 then
			num=award.num
		elseif level < succinctCfg.privilege_11 then
			num=award.num*0.9
		else
			num=award.num*0.8
		end
	elseif award.key=="p10" then	   
	   if level < succinctCfg.privilege_7 then
			num=award.num
		elseif level < succinctCfg.privilege_11 then
			num=award.num*0.9
		else
			num=award.num*0.8
		end
	elseif award.key=="gems" then
	   if level < succinctCfg.privilege_8 then
			num=award.num
		else
			num=award.num*0.9
		end
	end
	return award.key,num
end

function accessoryEquipDialogTabPurify:getConsume()
	local priceTb = succinctCfg.price[self.partID]
	local price = priceTb[self.flag]
	local award = FormatItem(price)
	return award[1]
end

function accessoryEquipDialogTabPurify:save()
	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then 
			if sData.data==nil then 
				return
			end
			if sData.data.accessory then
				if self.changeTypeLb then
					for k,v in pairs(self.changeTypeLb) do
						v:removeFromParentAndCleanup(true)
					end
					self.changeTypeLb=nil
					self.changeTypeTb=nil
				end
				if self.gsAddLb then
					self.gsAddLb:removeFromParentAndCleanup(true)
					self.gsAddLb=nil
				end
				accessoryVoApi:updateSuccinctData(sData.data.accessory)
				self:refresh()
				self:refreshType()
				self.saveItem:setEnabled(false)

				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("save_success"),30,nil,nil,nil,G_ColorYellowPro)
			end
		end
	end
	local gsAdd = G_keepNumber((self.changeTypeTb[1]+self.changeTypeTb[2])*800 + (self.changeTypeTb[3]+self.changeTypeTb[4])*20,1)
	if gsAdd<0 then
		require "luascript/script/game/scene/gamedialog/purifying/purifyingCheckSave"
		local smallDialog=purifyingCheckSave:new(self)
		smallDialog:init(self.layerNum+1,self,getlocal("dialog_title_prompt"),getlocal("purifying_gsAdd_sub"),callback)
	else
		socketHelper:accessoryPurifyingSave(1,callback)
	end	   
end

function accessoryEquipDialogTabPurify:purify()
	local key,num = self:getConsumeKeyAndNum()
	local function onSureLogic()
		if self.changeTypeLb then
			for k,v in pairs(self.changeTypeLb) do
				v=tolua.cast(v, "CCNode")
				if v~=nil then
					v:removeFromParentAndCleanup(true)
				end
			end
		end
		if self.gsAddLb then
			self.gsAddLb:removeFromParentAndCleanup(true)
			self.gsAddLb=nil
		end
		local function callback(fn,data)
			self.oldLevel = accessoryVoApi:getSuccinct_level()
			local ret,sData = base:checkServerData(data)
			if ret==true then 
				if sData.data==nil then 
				  return
				end
				if sData.data.accessory then
					accessoryVoApi:updateSuccinctData(sData.data.accessory)
					self:refresh()
					self.exLb:stopAllActions()
					self.exLb:setScale(1)
					G_showNumberScaleByAction(self.exLb,0.15,1.2)
					self:refreshConsume()
				end
				local succ_at = accessoryVoApi:getSucc_at()
				if G_isToday(succ_at)==false and self.flag==2 then
					accessoryVoApi:setSucc_at(sData.data.ts)
				end
				local level = accessoryVoApi:getSuccinct_level()
				if level~=self.oldLevel then
					 require "luascript/script/game/scene/gamedialog/purifying/purifyingSmallUpdateDialog2"
					local smallDialog=purifyingSmallUpdateDialog2:new(self.oldLevel)
					smallDialog:init(self.layerNum+1,self.parent,getlocal("upgradeBuild"))
				end
				if sData.data.report and sData.data.report[1] then
					self.saveItem:setEnabled(true)
					local oldTb = sData.data.report[1][1]
					local newTb = sData.data.report[1][2]
					self.changeTypeTb = {0,0,0,0}
					self.changeTypeLb = {}
					for k,v in pairs(newTb) do
						self.changeTypeTb[k]=v-oldTb[k]
						local str
						if k==1 or k==2 then
							str=G_keepNumber(self.changeTypeTb[k],3)*100 .. "%"
						else
							str=G_keepNumber(self.changeTypeTb[k],1)
						end
						if self.changeTypeTb[k]>=0 then
							str = "+" .. str
						else
							str = str
						end
						local changeLb = GetTTFLabel(str,20)
						if self.changeTypeTb[k]>=0 then
							 changeLb:setColor(G_ColorYellow)
						else
							 changeLb:setColor(G_ColorRed)
						end					   
						local needWidth = self.attributeTb[k]:getContentSize().width*0.5+10
						if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
					        needWidth =40
					    elseif G_getCurChoseLanguage() =="ar" then
							needWidth = -60
						end
						self.attributeTb[k]:addChild(changeLb)
						changeLb:setPosition(self.attributeTb[k]:getContentSize().width/2+needWidth,self.attributeTb[k]:getContentSize().height/2)
						local scaleBig = CCScaleTo:create(0.2,1.5)
						local scaleSmall = CCScaleTo:create(0.2,1)
						local seq = CCSequence:createWithTwoActions(scaleBig,scaleSmall)
						changeLb:runAction(seq)
						self.changeTypeLb[k]=changeLb
					end
					local gsAdd = G_keepNumber((self.changeTypeTb[1]+self.changeTypeTb[2])*800 + (self.changeTypeTb[3]+self.changeTypeTb[4])*20,1)
					local gsAddStr=gsAdd
					if gsAddStr>=0 then
						gsAddStr="+" .. gsAddStr
					end
					self.gsAddLb = GetTTFLabel(gsAddStr,25)
					if gsAdd>=0 then
						self.gsAddLb:setColor(G_ColorYellow)
					else
						self.gsAddLb:setColor(G_ColorRed)
					end 
					local needWidth2 = 40
				    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
				        needWidth2 =0
				    elseif G_getCurChoseLanguage() =="ar" then
						needWidth2 = -140
					end					
					self.gsAddLb:setAnchorPoint(ccp(0,0.5))
					self.gsAddLb:setPosition(ccp(self.gsLb:getContentSize().width/2+needWidth2,self.gsLb:getContentSize().height/2))
					self.gsLb:addChild(self.gsAddLb)
					local scaleBig = CCScaleTo:create(0.2,1.5)
					local scaleSmall = CCScaleTo:create(0.2,1)
					local seq = CCSequence:createWithTwoActions(scaleBig,scaleSmall)
					self.gsAddLb:runAction(seq)
				end
			end
		end
		socketHelper:accessoryPurifying(1,self.flag,"p"..self.partID,"t"..self.tankID,nil,callback)
	end
	if key=="r4" then
		local r4 = playerVoApi:getR4()
		if num>r4 then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("resourcelimit"),30)
			return
		end
	elseif key=="p8" then
		local succ_at = accessoryVoApi:getSucc_at()
		if G_isToday(succ_at)==false then
		else
			local shopProps = accessoryVoApi:getShopPropNum()
			if num>shopProps.p8 then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("purifying_crystal_notenough"),30)
				return
			end 
			local propNum = {shopProps.p8-num,shopProps.p9,shopProps.p10}
			accessoryVoApi:setShopPropNum(propNum)
		end
	elseif key=="p9" then
		local succ_at = accessoryVoApi:getSucc_at()
		if G_isToday(succ_at)==false then
		else
			local shopProps = accessoryVoApi:getShopPropNum()
			if num>shopProps.p9 then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("purifying_crystal_notenough"),30)
				return
			end
			local propNum = {shopProps.p8,shopProps.p9-num,shopProps.p10}
			accessoryVoApi:setShopPropNum(propNum) 
		end			
	elseif key=="p10" then
		local succ_at = accessoryVoApi:getSucc_at()
		if G_isToday(succ_at)==false then
		else
			local shopProps = accessoryVoApi:getShopPropNum()
			if num>shopProps.p10 then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("purifying_crystal_notenough"),30)
				return
			end 
			local propNum = {shopProps.p8,shopProps.p9,shopProps.p10-num}
			accessoryVoApi:setShopPropNum(propNum) 
		end
	elseif key=="gems" then
		if playerVoApi:getGems()<num then
			GemsNotEnoughDialog(nil,nil,num-playerVoApi:getGems(),self.layerNum+1,num)
			return
		end
		local function secondTipFunc(sbFlag)
            local sValue=base.serverTime .. "_" .. sbFlag
            G_changePopFlag("accessoryEquipDialogTabPurify",sValue)
        end
	    if G_isPopBoard("accessoryEquipDialogTabPurify") then
			G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{num}),true,onSureLogic,secondTipFunc)
			do return end
		end
	end
	onSureLogic()
end

function accessoryEquipDialogTabPurify:tick()
	local succ_at=accessoryVoApi:getSucc_at()
	if G_isToday(succ_at)==false and self.flag==2 then
		self:refreshConsume()
	end

end

function accessoryEquipDialogTabPurify:dispose()
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("serverWar/serverWar2.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("serverWar/serverWar2.png")
	self.data = nil
	self.parent = nil
	self.flag = nil
	self.partID=nil
	self.tankID=nil
	self.lvLb=nil
	self.exLb=nil
	self.lifeLb=nil
	self.proLb=nil
	self.tv=nil
	self.lifePercent=nil
	self.proPercent=nil
	self.changeTypeLb=nil
	self.changeTypeTb=nil
	self.gsAddLb=nil
	self.saveItem=nil
	self.oldLevel=nil
	self.attributeTb=nil
	self.consumeLb=nil
	self.consumeSp=nil
	self.des1=nil
	self.des2=nil
	self.des3=nil
	self.des4=nil
	self.typeSp2=nil
	self.typeSp3=nil
	self.typeSp1=nil
end