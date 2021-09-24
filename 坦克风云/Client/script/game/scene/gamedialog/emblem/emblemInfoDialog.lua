--弹出军徽信息小面板
emblemInfoDialog=smallDialog:new()

function emblemInfoDialog:new(data)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	
	nc.oneHeight = 40--装备属性每行所占高度
	nc.dialogWidth=550
	nc.data=data
	nc.eId = data.id
	nc.itemCfg = data.cfg
	nc.fontSize = 24
	nc.skillDescLbTb = nil -- 技能描述信息{描述，生效信息说明}或{无技能说明}
	nc.operatType = nil
	return nc
end

function emblemInfoDialog:init(layerNum,desVisible,doType,operatCallBack,parent)
	self.layerNum=layerNum
	self.operatType = doType--操作类型 1图鉴中显示 2装备基础操作  3装备上阵  4 邮件中查看 5装配大师装配 6 装配大师卸下 
	spriteController:addPlist("public/acAnniversary.plist")
	spriteController:addTexture("public/acAnniversary.png")
	local function nilFunc()
	end


	local function close()
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	self.dialogLayer=CCLayer:create()
	
	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	-- touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg);
	
	if self.itemCfg == nil then
		self.itemCfg = emblemVoApi:getEquipCfgById(self.eId)
	end

	self.skillDescLbTb = {}
	self.attUp,self.skillTb=nil,nil
	self.isEmblemTroop=emblemTroopVoApi:checkIfIsEmblemTroopById(self.eId)
	if self.isEmblemTroop==true then
		self.attUp,self.skillTb=emblemTroopVoApi:getTroopInfoById(self.eId,self.data)
	else
		self.attUp,self.skillTb=self.itemCfg.attUp,{self.itemCfg.skill}
	end
	local heightOffset
	if self.skillTb == nil or SizeOfTable(self.skillTb)==0 then
		heightOffset=-120
	else
		heightOffset=0
	end
	local function callback(...)
	   return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.dialogWidth - 80,340 + heightOffset),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	-- dialogBg:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(50)
	local titleStr=getlocal("emblem_infoTitle")
	local menuTb = {}
	if self.isEmblemTroop==true then
		titleStr=getlocal("emblem_troop_infoTitle")
	else
		if self.operatType==5 or self.operatType==6 then
				local function onClickBtnItem()
					if G_checkClickEnable()==false then
						do return end
					else
						base.setWaitTime=G_getCurDeviceMillTime()
					end
					PlayEffect(audioCfg.mouseClick)
					-- 执行回调，显示选择的超级状态
					if operatCallBack then
						operatCallBack(self.eId)
						self:close()
						if parent then
							parent:close()
						end
					end
				end
				local btnStr = getlocal("superEquip_infoBtn4")
				if self.operatType == 5 then
					btnStr = getlocal("accessory_ware")
				elseif self.operatType == 6 then
					btnStr = getlocal("accessory_unware")
				end
				local btnItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onClickBtnItem,2,btnStr,self.fontSize)
				btnItem:setScale(0.8)
				local btnMenu=CCMenu:createWithItem(btnItem)
				btnMenu:setTouchPriority(-(layerNum-1)*20-2)
				-- dialogBg:addChild(btnMenu)
				table.insert(menuTb,btnMenu)
		elseif self.data:getUsableNum()>0 then -- 全部出征则不可分解与升级
			local function onClickSell()
				if G_checkClickEnable()==false then
					do return end
				else
					base.setWaitTime=G_getCurDeviceMillTime()
				end
				PlayEffect(audioCfg.mouseClick)
				self:sellOneEquip()
			end
			local sellItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onClickSell,2,getlocal("emblem_btn_decompose"),self.fontSize)
			sellItem:setScale(0.8)
			local sellBtn=CCMenu:createWithItem(sellItem)
			sellBtn:setTouchPriority(-(layerNum-1)*20-2)
			-- dialogBg:addChild(sellBtn)
			table.insert(menuTb,sellBtn)

			local isMax
			local maxLv
			if(self.itemCfg.color==4)then
				maxLv=playerVoApi:getMaxLvByKey("emblemUpgrade4Lv")
			else
				maxLv=playerVoApi:getMaxLvByKey("emblemUpgrade5Lv")
			end
			if(maxLv and maxLv>0 and self.itemCfg.lv and self.itemCfg.lv>=maxLv)then
				isMax=true
			else
				isMax=false
			end
			if self.itemCfg.lvTo~=nil and isMax==false then
				local function onClickUpgradeBtn()
					if G_checkClickEnable()==false then
						do return end
					else
						base.setWaitTime=G_getCurDeviceMillTime()
					end
					PlayEffect(audioCfg.mouseClick)
					emblemVoApi:showUpgradeDialog(self.data,self.layerNum)
					self:close()
				end
				local upgradeItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onClickUpgradeBtn,2,getlocal("emblem_infoBtn1"),self.fontSize)
				upgradeItem:setScale(0.8)
				local upgradeBtn=CCMenu:createWithItem(upgradeItem)
				upgradeBtn:setTouchPriority(-(layerNum-1)*20-2)
				-- dialogBg:addChild(upgradeBtn)
				table.insert(menuTb,upgradeBtn)
			end
		elseif(self.data.num==0)then
			local typeStr--需要判断装备的获取类型
			if self.itemCfg.howToGet == 1 then
				typeStr=getlocal("emblem_infoType1")
			elseif self.itemCfg.howToGet == 2 then
				typeStr=getlocal("emblem_infoType2",{getlocal("emblem_tab_title_"..(self.itemCfg.color-1))})
			elseif self.itemCfg.howToGet == 3 then
				typeStr=getlocal("emblem_infoType3",{getlocal("emblem_tab_title_"..(self.itemCfg.color-1))})
			elseif self.itemCfg.howToGet == 4 then
				typeStr=getlocal("emblem_infoType4")
			end
			local typeLb = GetTTFLabelWrap(typeStr,25,CCSizeMake(self.dialogWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
			-- dialogBg:addChild(typeLb)
			typeLb:setColor(G_ColorGreen)
			table.insert(menuTb,typeLb)
			if desVisible then
				typeLb:setVisible(false)
			end		
		end
	end

	if SizeOfTable(menuTb) == 0 then
		self.dialogHeight=720 + heightOffset
		self.tv:setPosition(ccp(40,40))
	else
		self.dialogHeight=800 + heightOffset
		self.tv:setPosition(ccp(40,120))

		-- local lineSp3=CCSprite:createWithSpriteFrameName("LineCross.png")--LineCross
		-- lineSp3:setScaleX((self.dialogWidth - 120)/lineSp3:getContentSize().width)
		-- lineSp3:setScaleY(2/lineSp3:getContentSize().height)
		-- lineSp3:setPosition(ccp(self.dialogWidth/2,120 - lineSp3:getContentSize().height/2))
		-- dialogBg:addChild(lineSp3)
	end

	local dialogBg,titleBg,titleLb,closeBtnItem,closeBtn=G_getNewDialogBg(CCSizeMake(self.dialogWidth,self.dialogHeight),titleStr,32,nil,self.layerNum,true,close,nil)

	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),function()end)
	tvBg:setContentSize(CCSizeMake(self.dialogWidth-40,self.tv:getViewSize().height+10))
	tvBg:setAnchorPoint(ccp(0.5,0))
	tvBg:setPosition(self.dialogWidth/2,self.tv:getPositionY()-5)
	dialogBg:addChild(tvBg)

	dialogBg:addChild(self.tv)

	local px
	local btnWidth = 200
	local menuNum = SizeOfTable(menuTb)
	for k,v in pairs(menuTb) do
		px = self.dialogWidth/2-btnWidth/2*(menuNum-1)+btnWidth*(k-1)
		v:setPosition(ccp(px,60))
		dialogBg:addChild(v)
	end
	
	local jiange = 20
	local icon=emblemVoApi:getEquipIcon(self.eId,nil,nil,nil,self.itemCfg.qiangdu or 0,nil,nil,self.data)--CCSprite:createWithSpriteFrameName("7daysCheckmark.png")--
	icon:setAnchorPoint(ccp(0.5,1))
	icon:setPosition(self.dialogWidth/2,self.dialogHeight - 90)
	dialogBg:addChild(icon)
	
	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(CCSizeMake(self.dialogWidth,self.dialogHeight))
	self.bgLayer:setIsSallow(false)
	self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:setBSwallowsTouches(true);

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))

	return self.dialogLayer
end

function emblemInfoDialog:eventHandler(handler,fn,idx,cel)
	local strSubSize3 = 5
	local subPosX = 60
	if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
		strSubSize3 =0
		subPosX =0
	end
   if fn=="numberOfCellsInTableView" then
   	   	   return 3
   elseif fn=="tableCellSizeForIndex" then
   		if idx == 0 then
   			if (self.data.num and self.data.num>0) then
	   			if self.itemCfg and self.itemCfg.etype==1 then
				    return  CCSizeMake(self.dialogWidth - 80,self.oneHeight * 2)
				else
			   		return  CCSizeMake(self.dialogWidth - 80,self.oneHeight)
			   	end
			else
				return CCSizeMake(self.dialogWidth - 80,0)
			end
		elseif idx == 1 then
			if self.attUp then
				-- return  CCSizeMake(self.dialogWidth - 80,self.oneHeight * 3 + 40)
				return  CCSizeMake(self.dialogWidth - 80,self.oneHeight * math.ceil(SizeOfTable(self.attUp)/2) + 40)
			else
				local tipLb1 = GetTTFLabelWrap(getlocal("emblem_noAttTip1"),self.fontSize,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
				local tipLb2 = GetTTFLabelWrap(getlocal("emblem_noAttTip2"),self.fontSize,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
				return  CCSizeMake(self.dialogWidth - 80,tipLb1:getContentSize().height + tipLb2:getContentSize().height + 60)-- 40 标题高度  20是文字下端预留空间10+两行文字之间预留空间
			end
		elseif idx == 2 then
			if self.skillTb == nil or SizeOfTable(self.skillTb)==0 then
				local noSkillStr=""
				if self.isEmblemTroop==true then
					noSkillStr=getlocal("emblem_troop_noskill")
				else
					noSkillStr=getlocal("emblem_noSkill")
				end
				local skillnoLb = GetTTFLabel(noSkillStr,self.fontSize)
				table.insert(self.skillDescLbTb,skillnoLb)
				return  CCSizeMake(self.dialogWidth - 80,40+skillnoLb:getContentSize().height + 10)
			else
				if self.isEmblemTroop==true then --军徽部队技能处理
					local height=0
					local skillId,skillLv
					for k,v in pairs(self.skillTb) do
						skillId,skillLv=v[1],v[2]
						local skillDescLb = GetTTFLabelWrap(emblemVoApi:getEquipSkillDesById(skillId,skillLv),self.fontSize,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
						table.insert(self.skillDescLbTb,skillDescLb)
						height=height+skillDescLb:getContentSize().height+40 --40是技能名称的高度
					end
					return CCSizeMake(self.dialogWidth - 80,40 + height + 10)
				else
					local skill=self.skillTb[1]
					local skillId = skill[1] --  显示装备的技能信息
					local skillLv = skill[2]
					local skillDescLb = GetTTFLabelWrap(emblemVoApi:getEquipSkillDesById(skillId,skillLv),self.fontSize,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
					table.insert(self.skillDescLbTb,skillDescLb)
					if self.itemCfg.etype == 2 and self.data then
						local skillCfg = emblemVoApi:getEquipSkillCfgById(skillId)
						local skillValue = emblemVoApi:getEquipSkillValueByLv(skillId,skillLv)
						local maxValue = emblemVoApi:getSkillValue(skillCfg.stype,true)
						local skillTip
						if maxValue > skillValue[1] then
							skillTip = getlocal("emblem_skillTip1")
						elseif self.data.num > 1 then
							skillTip = getlocal("emblem_skillTip3")
						elseif self.data.num == 1 then
							skillTip = getlocal("emblem_skillTip2")
						end
						local skillTipLb = GetTTFLabelWrap(skillTip,self.fontSize,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
						table.insert(self.skillDescLbTb,skillTipLb)
						return  CCSizeMake(self.dialogWidth - 80,80 + skillDescLb:getContentSize().height+ 10+skillTipLb:getContentSize().height)--10文字下方预留  80 = 40技能名字 + 40技能标题
					else
						return  CCSizeMake(self.dialogWidth - 80,80 + skillDescLb:getContentSize().height+ 10)--10文字下方预留  80 = 40技能名字 + 40技能标题
					end
				end
			end
		   
		end
   elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local cellWidth = self.dialogWidth - 80
		local firstLbX = 50
		local secndLbX = cellWidth - 180
		if idx == 0 then
			if(self.data.num and self.data.num>0)then
				local ownStr = getlocal("emblem_infoOwn",{self.data ~= nil and self.data.num or 0})
				local ownLb = GetTTFLabel(ownStr,self.fontSize)
				ownLb:setAnchorPoint(ccp(0,0.5))
				ownLb:setPosition(ccp(firstLbX, self.oneHeight/2))
				cell:addChild(ownLb)
				
				local equipCfg = emblemVoApi:getEquipCfgById(self.eId)
				if equipCfg and equipCfg.etype==1 then
					ownLb:setPosition(ccp(firstLbX, self.oneHeight*1.5))

					local expeditionLb = GetTTFLabel(getlocal("emblem_infoExpedition",{self.data ~= nil and self.data:getEquipBattleNum() or 0}),self.fontSize)
					expeditionLb:setAnchorPoint(ccp(0,0.5))
					expeditionLb:setPosition(ccp(secndLbX-subPosX,self.oneHeight*1.5))
					cell:addChild(expeditionLb)

					local equipLb = GetTTFLabel(getlocal("emblem_infoEquip",{self.data ~= nil and self.data:getTroopEquipNum() or 0}),self.fontSize)
				    equipLb:setAnchorPoint(ccp(0,0.5))
				    equipLb:setPosition(ccp(firstLbX,self.oneHeight * 0.5))
				    cell:addChild(equipLb)
				end
			end

			if self.data.num>0 and self.itemCfg.color>3 then
				local function onClickShareBtn()
					if G_checkClickEnable()==false then
						do return end
					else
						base.setWaitTime=G_getCurDeviceMillTime()
					end
					PlayEffect(audioCfg.mouseClick)
					self:share()
				end
				local shareItem=GetButtonItem("anniversarySend.png","anniversarySendDown.png","anniversarySendDown.png",onClickShareBtn,2)
				local shareBtn=CCMenu:createWithItem(shareItem)
				shareBtn:setPosition(ccp(cellWidth - 25,self.oneHeight/2))
				shareBtn:setTouchPriority(-(self.layerNum-1)*20-2)
				cell:addChild(shareBtn)
			end

			-- local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
			-- lineSp:setScaleX((cellWidth-40)/lineSp:getContentSize().width)
			-- lineSp:setPosition(ccp(cellWidth/2,0))
			-- cell:addChild(lineSp)
		elseif idx == 1 then
			--攻击	
			local attY
			local lightSp=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
		    lightSp:setAnchorPoint(ccp(0.5,0.5))
		    lightSp:setScaleX(3)
		    -- lightSp:setPosition(cellWidth/2,self.bgSize.height-100)
		    cell:addChild(lightSp)

		    local titleStr=""
		    if self.isEmblemTroop==true then
				titleStr=getlocal("emblem_troop_addAttUp")
		    else
				titleStr=getlocal("emblem_infoAttup")
		    end
		    local attupTitleLb=GetTTFLabel(titleStr,self.fontSize + 2)
		    attupTitleLb:setAnchorPoint(ccp(0.5,0.5))
		    cell:addChild(attupTitleLb)
		    attupTitleLb:setColor(G_ColorYellowPro)
		    local realNameW=attupTitleLb:getContentSize().width
		    local pointSpTb={}
		    for i=1,2 do
		        local pointSp=CCSprite:createWithSpriteFrameName("newPointRect.png")
		        local anchorX=1
		        local posX=cellWidth/2-(realNameW/2+20)
		        local pointX=-7
		        if i==2 then
		            anchorX=0
		            posX=cellWidth/2+(realNameW/2+20)
		            pointX=15
		        end
		        pointSp:setAnchorPoint(ccp(anchorX,0.5))
		        pointSp:setPosition(posX,attupTitleLb:getPositionY())
		        cell:addChild(pointSp)

		        local pointLineSp=CCSprite:createWithSpriteFrameName("newPointLine.png")
		        pointLineSp:setAnchorPoint(ccp(0,0.5))
		        pointLineSp:setPosition(pointX,pointSp:getContentSize().height/2)
		        pointSp:addChild(pointLineSp)
		        if i==1 then
		            pointLineSp:setRotation(180)
		        end
		        pointSpTb[i]=pointSp
		    end

			if self.attUp then
				local hangshu = math.ceil(SizeOfTable(self.attUp)/2)
				attY = self.oneHeight * hangshu + 20 --self.oneHeight * 3 + 20
				attupTitleLb:setPosition(ccp(cellWidth/2, attY))
				attY = self.oneHeight * (hangshu - 1) + self.oneHeight/2
				local showAttUp = emblemVoApi:getEquipAttUpForShow(self.attUp)
				local index = 1
				for k,v in pairs(showAttUp) do
					local attNameLb=GetTTFLabel(getlocal("emblem_attUp_"..v[1]),self.fontSize-strSubSize3)--getlocal(k)
					attNameLb:setAnchorPoint(ccp(0,0.5))
					attNameLb:setPosition(ccp(index == 1 and firstLbX or secndLbX,attY))
					cell:addChild(attNameLb)

					local attLbAdd
					if v[1] == "troopsAdd" or v[1] =="first" then
						attLbAdd=GetTTFLabel("+"..(v[2]),self.fontSize)
					else
						attLbAdd=GetTTFLabel("+"..(v[2] * 100).."%",self.fontSize)
					end
					attLbAdd:setAnchorPoint(ccp(0,0.5))
					attLbAdd:setPosition(ccp(attNameLb:getPositionX()+attNameLb:getContentSize().width + 5,attY))
					attLbAdd:setColor(G_ColorGreen)
					cell:addChild(attLbAdd)
					if index == 2 then
						attY = attY - self.oneHeight
					end
					index = (index == 1) and 2 or 1
				end
			else
				
				local tipLb1 = GetTTFLabelWrap(getlocal("emblem_noAttTip1"),self.fontSize,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
				tipLb1:setAnchorPoint(ccp(0,1))
				tipLb1:setColor(G_ColorGreen)

				cell:addChild(tipLb1)
				
				
				local tipLb2 = GetTTFLabelWrap(getlocal("emblem_noAttTip2"),self.fontSize,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
				tipLb2:setAnchorPoint(ccp(0,1))
				cell:addChild(tipLb2)

				attY = tipLb1:getContentSize().height + tipLb2:getContentSize().height + 40
				attupTitleLb:setPosition(ccp(cellWidth/2, attY))
				
				attY = attY - 20

				tipLb1:setPosition(ccp(firstLbX,attY))
				attY = attY - tipLb1:getContentSize().height - 10
				tipLb2:setPosition(ccp(firstLbX,attY))  
			end

			lightSp:setPosition(cellWidth/2,attupTitleLb:getPositionY()-5)
			for k, v in pairs(pointSpTb) do
				v:setPositionY(attupTitleLb:getPositionY())
			end

			-- local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png")
			-- lineSp2:setScaleX((cellWidth-40)/lineSp2:getContentSize().width)
			-- lineSp2:setPosition(ccp(cellWidth/2,0))
			-- cell:addChild(lineSp2)
		else
			local addH = 10

			if self.skillTb == nil or SizeOfTable(self.skillTb)==0 then
				local skillnoLb = self.skillDescLbTb[1]
				skillnoLb:setAnchorPoint(ccp(0,0))
				skillnoLb:setPosition(ccp(firstLbX, addH))
				cell:addChild(skillnoLb)
				addH = addH + skillnoLb:getContentSize().height + 20
			else
				local anchorPoint = G_getCurChoseLanguage() =="ar" and ccp(1,0.5) or ccp(0,0.5)
				local posX = G_getCurChoseLanguage() =="ar" and firstLbX+400 or firstLbX
				if self.isEmblemTroop==true then --军徽部队技能处理
					local skillId,skillLv
					for k,v in pairs(self.skillTb) do
						skillId,skillLv=v[1],v[2]
						local skillDescLb = tolua.cast(self.skillDescLbTb[k],"CCLabelTTF")
						skillDescLb:setAnchorPoint(ccp(0,0))
						skillDescLb:setPosition(ccp(firstLbX,addH))
						cell:addChild(skillDescLb)

						addH = addH + skillDescLb:getContentSize().height + 20

						local skillNameLb = GetTTFLabel(emblemVoApi:getEquipSkillNameById(skillId,skillLv),self.fontSize)
						skillNameLb:setAnchorPoint(anchorPoint)
						skillNameLb:setPosition(ccp(posX,addH))
						cell:addChild(skillNameLb)
						skillNameLb:setColor(G_ColorGreen)

						addH=addH+20
					end
					addH = addH + 20
				else
					local skill=self.skillTb[1]
					local skillId = skill[1] --  显示装备的技能信息
					local skillLv = skill[2]
					if self.itemCfg.etype == 2 and self.item then
						local skillUseLb = self.skillDescLbTb[2]
						skillUseLb:setAnchorPoint(ccp(0,0))
						skillUseLb:setPosition(ccp(firstLbX,addH))
						skillUseLb:setColor(G_ColorRed)
						cell:addChild(skillUseLb)

						addH = addH + skillUseLb:getContentSize().height
					end

					local skillDescLb = self.skillDescLbTb[1]
					skillDescLb:setAnchorPoint(ccp(0,0))
					skillDescLb:setPosition(ccp(firstLbX,addH))
					cell:addChild(skillDescLb)

					addH = addH + skillDescLb:getContentSize().height + 20

					local skillNameLb = GetTTFLabel(emblemVoApi:getEquipSkillNameById(skillId,skillLv),self.fontSize)

					skillNameLb:setAnchorPoint(anchorPoint)
					skillNameLb:setPosition(ccp(posX,addH))
					cell:addChild(skillNameLb)
					skillNameLb:setColor(G_ColorGreen)

					addH = addH + 40
				end
			end

			local lightSp=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
		    lightSp:setAnchorPoint(ccp(0.5,0.5))
		    lightSp:setScaleX(3)
		    cell:addChild(lightSp)

		    local skillTitleStr=""
		    if self.isEmblemTroop==true then
				skillTitleStr=getlocal("emblem_troop_skill2")
		    else
				skillTitleStr=getlocal("emblem_infoSkill")
		    end
		    local skillTitleLb = GetTTFLabel(skillTitleStr,self.fontSize+2)
			skillTitleLb:setAnchorPoint(ccp(0.5,0.5))
			skillTitleLb:setPosition(ccp(cellWidth/2, addH))
			cell:addChild(skillTitleLb)
			skillTitleLb:setColor(G_ColorYellowPro)
			lightSp:setPosition(cellWidth/2,skillTitleLb:getPositionY()-5)
		    local realNameW=skillTitleLb:getContentSize().width
		    for i=1,2 do
		        local pointSp=CCSprite:createWithSpriteFrameName("newPointRect.png")
		        local anchorX=1
		        local posX=cellWidth/2-(realNameW/2+20)
		        local pointX=-7
		        if i==2 then
		            anchorX=0
		            posX=cellWidth/2+(realNameW/2+20)
		            pointX=15
		        end
		        pointSp:setAnchorPoint(ccp(anchorX,0.5))
		        pointSp:setPosition(posX,skillTitleLb:getPositionY())
		        cell:addChild(pointSp)

		        local pointLineSp=CCSprite:createWithSpriteFrameName("newPointLine.png")
		        pointLineSp:setAnchorPoint(ccp(0,0.5))
		        pointLineSp:setPosition(pointX,pointSp:getContentSize().height/2)
		        pointSp:addChild(pointLineSp)
		        if i==1 then
		            pointLineSp:setRotation(180)
		        end
		    end
		end
		return cell
	elseif fn=="ccTouchBegan" then
	   self.isMoved=false
	   return true
   elseif fn=="ccTouchMoved" then
		self.isMoved=true
		G_removeFlicker(self.bgLayer)
   elseif fn=="ccTouchEnded"  then
	   
   end
end

-- 分解单件装备
function emblemInfoDialog:sellOneEquip()
	if self.data.num<=self.data:getEquipBattleNum() then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_decompose_no_enough"),30)
		do return end
	end
	local function onSell()
		if(self.data==nil or self.data.num==nil)then
			do return end
		end
		local function callback()
			self:close()
		end
		emblemVoApi:sell(self.data.id,nil,callback)
	end
	emblemVoApi:showSellRewardDialog({self.data},self.layerNum + 1,onSell)
end

--分享
function emblemInfoDialog:share()
	local hasAlliance=allianceVoApi:isHasAlliance()
	if hasAlliance==false then
		local sender=playerVoApi:getUid()
		local senderName=playerVoApi:getPlayerName()
		local level=playerVoApi:getPlayerLevel()
		local rank=playerVoApi:getRank()
		base.lastSendTime=base.serverTime
		local message=getlocal("emblem_shareMsg",{emblemVoApi:getEquipName(self.eId)})
		local params={subType=1,contentType=2,brType=14,message=message,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),ts=base.serverTime,vip=playerVoApi:getVipLevel(),eId=self.eId}
		chatVoApi:sendChatMessage(1,sender,senderName,0,"",params)
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_share_sucess"),28)
	else
		local function sendReportHandle(tag,object)
			base.lastSendTime=base.serverTime
			local channelType=tag or 1
			local sender=playerVoApi:getUid()
			local senderName=playerVoApi:getPlayerName()
			local level=playerVoApi:getPlayerLevel()
			local rank=playerVoApi:getRank()
			local allianceName
			local allianceRole
			if allianceVoApi:isHasAlliance() then
				local allianceVo=allianceVoApi:getSelfAlliance()
				allianceName=allianceVo.name
				allianceRole=allianceVo.role
			end
			
			local message=getlocal("emblem_shareMsg",{emblemVoApi:getEquipName(self.eId)})
			local params={subType=channelType,contentType=2,message=message,brType=14,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),ts=base.serverTime,allianceName=allianceName,allianceRole=allianceRole,vip=playerVoApi:getVipLevel(),eId = self.eId}
			local aid=playerVoApi:getPlayerAid()
			if channelType==1 then
				chatVoApi:sendChatMessage(1,sender,senderName,0,"",params)
			elseif aid then
				chatVoApi:sendChatMessage(aid+1,sender,senderName,0,"",params)
			end
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_share_sucess"),28)
		end
		require "luascript/script/game/scene/gamedialog/allianceDialog/allianceSmallDialog"
		allianceSmallDialog:selectChannelDialog("PanelHeaderPopup.png",CCSizeMake(450,350),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,sendReportHandle)
	end
end

function emblemInfoDialog:dispose()
	spriteController:removePlist("public/acAnniversary.plist")
	spriteController:removeTexture("public/acAnniversary.png")
	self.tv = nil
	self.oneHeight = nil
	self.dialogHeight=nil
	self.dialogWidth=nil
	self.eId = nil
	self.data = nil
	self.itemCfg = nil
	self.fontSize = nil
	self.skillDescLbTb = nil
	self.skillTb=nil
	self.attUp=nil
	self.isEmblemTroop=nil
end