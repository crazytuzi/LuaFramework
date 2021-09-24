BossBuyBuffDialog=smallDialog:new()

function BossBuyBuffDialog:new(parent)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogHeight=400
	self.dialogWidth=550

	self.parent=parent
	return nc
end

function BossBuyBuffDialog:init(layerNum)
end

function BossBuyBuffDialog:createWithBuffId(buffId,layerNum,updateCallback)
	local sd=BossBuyBuffDialog:new()
	sd:initWithBuffId(buffId,layerNum,updateCallback)
	return sd

end
function BossBuyBuffDialog:initWithBuffId(buffId,layerNum,updateCallback)
	self.isTouch=false
	self.isUseAmi=false
	local function touchHandler()
	
	end
	
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),touchHandler)
	self.dialogLayer=CCLayer:create()
	
	self.bgLayer=dialogBg
	self.bgSize=CCSizeMake(550,600)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	
	local bid="b"..buffId
	local iconSp=CCSprite:createWithSpriteFrameName(bossCfg.buffSkill[bid].icon)
	iconSp:setPosition(ccp(self.bgLayer:getContentSize().width/2-90,self.bgLayer:getContentSize().height/2+70))
	self.bgLayer:addChild(iconSp)
	
    local nameLb=GetTTFLabelWrap(getlocal("buffName",{getlocal(bossCfg.buffSkill[bid].name)}),26,CCSize(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    nameLb:setAnchorPoint(ccp(0,0))
    nameLb:setPosition(ccp(self.bgSize.width/2,self.bgLayer:getContentSize().height/2+85))
	dialogBg:addChild(nameLb)
	
	local buffLv=tonumber(BossBattleVoApi:getBattlefieldUser()[bid])
	
	local lvLb=GetTTFLabel(getlocal("buffLv",{buffLv}),26)
	lvLb:setAnchorPoint(ccp(0,0.5))
	lvLb:setPosition(ccp(self.bgSize.width/2,self.bgLayer:getContentSize().height/2+50))
	dialogBg:addChild(lvLb)
	
	local lineSp = CCSprite:createWithSpriteFrameName("LineEntity.png");
	lineSp:setAnchorPoint(ccp(0.5,0.5));
	lineSp:setPosition(self.bgLayer:getContentSize().width/2+100,self.bgLayer:getContentSize().height/2+70)
	lineSp:setScaleY(3)
	lineSp:setScaleX(0.5)
	self.bgLayer:addChild(lineSp)
	
	local lineSp = CCSprite:createWithSpriteFrameName("LineEntity.png");
	lineSp:setAnchorPoint(ccp(0.5,0.5));
	lineSp:setPosition(self.bgLayer:getContentSize().width/2+100,self.bgLayer:getContentSize().height/2+20)
	lineSp:setScaleY(3)
	lineSp:setScaleX(0.5)
	self.bgLayer:addChild(lineSp)

	local costTb = FormatItem(bossCfg.buffSkill[bid].cost)
	local costItem = costTb[1]

	local costLb=GetTTFLabel(FormatNumber(costItem.num),26)
	costLb:setAnchorPoint(ccp(1,0.5))
	costLb:setPosition(ccp(self.bgLayer:getContentSize().width/2-20,150))
	costLb:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(costLb)

	local picStr = costItem.pic

	if costItem.key == "gem" or costItem.key =="gems" then
		picStr="IconGold.png"
	elseif costItem.key == "r1" then
		picStr="IconCopper.png"
	elseif costItem.key == "r2" then
		picStr="IconOil.png"
	elseif costItem.key == "r3" then
		picStr="IconIron.png"
	elseif costItem.key == "r4" then
		picStr="IconOre.png"
	elseif costItem.key == "gold" then
		picStr="IconCrystal-.png"
	end
	
	local goldIcon=CCSprite:createWithSpriteFrameName(picStr);
	goldIcon:setAnchorPoint(ccp(1,0.5))
    goldIcon:setPosition(ccp(self.bgLayer:getContentSize().width/2-costLb:getContentSize().width-20,150));
	self.bgLayer:addChild(goldIcon)

	

	
	local rateStr=""
	local point1=ccp(0,0)
	local point2 = ccp(0,0)
	if tonumber(BossBattleVoApi:getBattlefieldUser()[bid])==bossCfg.buffSkill[bid]["maxLv"] then
		rateStr=getlocal("technology_max_level",{""})
		point1=ccp(0.5,0.5)
		point2=ccp(self.bgLayer:getContentSize().width/2,goldIcon:getPositionY())
		goldIcon:setVisible(false)
		costLb:setVisible(false)
	else
		local per=tonumber(bossCfg.buffSkill[bid]["probability"][buffLv+1])
		rateStr=getlocal("tip_succeedRate",{per})
		point1=ccp(0,0.5)
        point2=ccp(self.bgLayer:getContentSize().width/2,goldIcon:getPositionY())
	end
	
	local rateLb=GetTTFLabel(rateStr,25)
	rateLb:setAnchorPoint(point1)
	rateLb:setPosition(point2)
	
	
	self.bgLayer:addChild(rateLb)
	
    local contentLb=GetTTFLabelWrap(getlocal(bossCfg.buffSkill[bid]["des"],{bossCfg.buffSkill[bid]["per"]*100}),25,CCSize(420,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
   	contentLb:setAnchorPoint(ccp(0.5,0.5))
    contentLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height/2-60))
	self.bgLayer:addChild(contentLb)


	local function touchLuaSpr()

	end
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg,1);
	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
	
	local function close()
			PlayEffect(audioCfg.mouseClick)
			return self:close()
		end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
	 
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)
	
	local titleLb=GetTTFLabel(getlocal("activation"),40)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
	dialogBg:addChild(titleLb)

	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true);
	
	local oldLv=tonumber(BossBattleVoApi:getBattlefieldUser()[bid])
	
	local function okback()
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("technology_max_level",{""}),30)
	end
	local okBtn=GetButtonItem("BtnGraySmall.png","BtnGraySmall_Down.png","BtnGraySmall.png",okback,1,getlocal("confirm"),25)
	local menuOkBtn=CCMenu:createWithItem(okBtn)
	menuOkBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2,80))
	menuOkBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.bgLayer:addChild(menuOkBtn,1)


	local function activation()
		if tonumber(BossBattleVoApi:getBattlefieldUser()[bid])==bossCfg.buffSkill[bid]["maxLv"] then
			local str=getlocal("technology_max_level",{getlocal(bossCfg.buffSkill[bid].name)})
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,30)
			do
				return
			end
		end

		if costItem.key=="gem" or costItem.key=="gems" then
           if playerVoApi:getGems()<tonumber(costItem.num) then
				local function jumpGemDlg()
	                vipVoApi:showRechargeDialog(layerNum+2)
				end
				smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),jumpGemDlg,getlocal("dialog_title_prompt"),getlocal("alliance_createAllianceNoGem"),nil,layerNum+1)

				do
					return
				end
			end
        elseif playerVo[costItem.key] then
            if playerVo[costItem.key]<tonumber(costItem.num) then
				-- local function jumpGemDlg()
	   --              vipVoApi:showRechargeDialog(self.layerNum+2)
				-- end
				-- smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),jumpGemDlg,getlocal("dialog_title_prompt"),getlocal("alliance_createAllianceNoGem"),nil,layerNum+1)
				 smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("resourcelimit"),nil,layerNum+1)
				do
					return
				end
			end
        end

		


		local function callback(fn,data)
			local ret,sData=base:checkServerData(data)
            if ret==true then

				BossBattleVoApi:setHadBuyBuff(sData.data.worldboss.info.b)
				if updateCallback then
					updateCallback()
				end
				local buffLv=tonumber(BossBattleVoApi:getBattlefieldUser()[bid])
				lvLb:setString(getlocal("buffLv",{buffLv}))
				
				local rateStr=""
				if tonumber(BossBattleVoApi:getBattlefieldUser()[bid])==bossCfg.buffSkill[bid]["maxLv"] then
					rateStr=getlocal("technology_max_level",{""})
					okBtn:setVisible(true)
					rateLb:setAnchorPoint(ccp(0.5,0.5))
					rateLb:setPosition(ccp(self.bgSize.width/2,goldIcon:getPositionY()))
					goldIcon:setVisible(false)
					costLb:setVisible(false)
					self.activationBtn:setVisible(false)
				else
					local per=tonumber(bossCfg.buffSkill[bid]["probability"][buffLv+1])
					rateStr=getlocal("tip_succeedRate",{per})

				end
				rateLb:setString(rateStr)

				local str=getlocal("buffSuccess")
				if buffLv==oldLv then
					str=getlocal("buffField")

				else
					oldLv=buffLv
				end
				playerVoApi:setValue(costItem.key,playerVo[costItem.key]-tonumber(costItem.num))
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,30)

			end
		end
		socketHelper:BossBattleBuyBuff(bid,callback)
	end
	self.activationBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",activation,1,getlocal("activation"),25)
	local menuActivationBtn=CCMenu:createWithItem(self.activationBtn)
	menuActivationBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2,80))
	menuActivationBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.bgLayer:addChild(menuActivationBtn,1)
	
	if tonumber(BossBattleVoApi:getBattlefieldUser()[bid])==bossCfg.buffSkill[bid]["maxLv"] then
		okBtn:setVisible(true)
		self.activationBtn:setVisible(false)
	else
		okBtn:setVisible(false)
		self.activationBtn:setVisible(true)
		local state = BossBattleVoApi:getBossState()
		if state==3 or state==2 then
			self.activationBtn:setEnabled(true)
		else
			self.activationBtn:setEnabled(false)
		end
	end


end



