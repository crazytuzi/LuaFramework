otherGuideMgr=
{
	hasInit=false,
	curStep=1,
	bgLayer,
	bgLayer1,
	panel,
	arrow,
	guidLabel,
	isGuiding=false,
	selectSp,
	closeBtn,
	dArrowSp,
	isTextGoing=false,
	fastTickNum=0,
	eventListener=nil,
	waitingForGuideTb={}, 	--一个等待队列, 里面存的是所有等待引导的步数
	eventStepTb={},			--另一个队列, key是event, value是一个table, 存储在该event的哪个引导还没有做过, 加这个队列是为了当同一个event有多个引导的时候，让引导挨个出现
	checkGuideTb={},		--一个检查某个本地数据是否已经存在的tb
    showFlag=false, --教学是否已经显示的标记
    otherRectFlag=false,
    otherRectSpTb=nil,
}

function otherGuideMgr:init()
	if(self.hasInit) or GM_UidCfg[playerVoApi:getUid()] then
		do return end
	end
	self.hasInit=true
	local function listener(event,data)
		self:guideEventListener(event,data)
	end
	self.waitingForGuideTb={}
	self.eventStepTb={}
	self.eventListener=listener
	for k,v in pairs(otherGuideCfg) do
		if(v.event and v.event~="")then
			if(self:checkGuide(v.stepId)==false)then
				if(self.eventStepTb[v.event]==nil)then
					self.eventStepTb[v.event]={}
				end
				table.insert(self.eventStepTb[v.event],v.stepId)
				eventDispatcher:addEventListener(v.event,listener)
			end
		end
	end
	base:addNeedRefresh(self)
	self:checkOnInit()
end

function otherGuideMgr:checkOnInit()
	-- if(self:checkGuide(1)==false)then
	-- 	local allTanks=tankVoApi:getAllTanks()
	-- 	for k,v in pairs(allTanks) do
	-- 	    if(tankCfg[k].inWarehouse)then
 --        		eventDispatcher:dispatchEvent("tank.addToWarehouse")
 --        		break
 --    		end
	-- 	end
	-- end
	if self:checkGuide(83) == false and FuncSwitchApi:isEnabled("diku_repair") == true then
		table.insert(self.waitingForGuideTb,83)
	end

	-- if(self:checkGuide(16)==false)then
	-- 	if(emblemCfg and base.emblemSwitch==1 and playerVoApi:getPlayerLevel()>=emblemCfg.equipOpenLevel)then
	-- 		print("waitingStep---->>>16")
	-- 		table.insert(self.waitingForGuideTb,16)
	-- 	end
	-- elseif(self:checkGuide(73)==false) then
	-- 	if emblemTroopVoApi:checkIfEmblemTroopIsOpen()==true then
	-- 		table.insert(self.waitingForGuideTb,73)
	-- 	end
	if (self:checkGuide(18)==false) then
		if base.armor==1 and armorCfg and playerVoApi:getPlayerLevel()>=armorCfg.openLvLimit then
			local lastLv=playerVoApi.playerLastLevel
			if lastLv<armorCfg.openLvLimit then
				table.insert(self.waitingForGuideTb,18)
			end
		end
	elseif (self:checkGuide(32)==false) then
		if base.plane==1 then
			local openLv=planeVoApi:getOpenLevel()
			if playerVoApi:getPlayerLevel()>=openLv then
				local lastLv=playerVoApi.playerLastLevel
				if lastLv<openLv then
					table.insert(self.waitingForGuideTb,32)
				end
			end
		end
	elseif (self:checkGuide(41)==false) then
		if ltzdzVoApi:isOpen()==true then
			local openLv=ltzdzVoApi:getOpenLv()
			if playerVoApi:getPlayerLevel()>=openLv then
				table.insert(self.waitingForGuideTb,41)
			end
		end
	end
	if (self:checkGuide(90)==false) then
		if airShipVoApi:isOpen() == true then
			local openLv=airShipVoApi:getOpenLv()
			if playerVoApi:getPlayerLevel()>=openLv then
				table.insert(self.waitingForGuideTb,90)
			end
		end
	end
end

function otherGuideMgr:guideEventListener(event,data)
	for k,v in pairs(self.eventStepTb[event]) do
		if(v==16)then
			if(emblemCfg and base.emblemSwitch==1 and playerVoApi:getPlayerLevel()>=emblemCfg.equipOpenLevel)then
				local lastLv=data
				if(lastLv<emblemCfg.equipOpenLevel)then
					table.insert(self.waitingForGuideTb,v)
				end
			end
		elseif (v==73) then --军徽部队建筑引导
			local isOpen,openLv=emblemTroopVoApi:checkIfEmblemTroopIsOpen()
			if isOpen==true and playerVoApi:getPlayerLevel()>=openLv then
				local lastLv=data
				if(lastLv<openLv)then
					table.insert(self.waitingForGuideTb,v)
				end
			end
		elseif (v==18) then
			if base.armor==1 and armorCfg and playerVoApi:getPlayerLevel()>=armorCfg.openLvLimit and self:checkGuide(v)==false then
				local lastLv=data
				if lastLv<armorCfg.openLvLimit then
					table.insert(self.waitingForGuideTb,v)
				end
			end
		elseif (v==80) then
			if heroAdjutantVoApi:isOpen() and self:checkGuide(v)==false then
				local lastLv=data
				if lastLv<heroAdjutantVoApi:getAdjutantCfg().openLv then
					table.insert(self.waitingForGuideTb,v)
				end
			end
		elseif (v==82) then
			if supplyShopVoApi and supplyShopVoApi:isOpen() and self:checkGuide(v)==false then
				local lastLv=data
				if lastLv<supplyShopVoApi:getOpenLv() then
					table.insert(self.waitingForGuideTb,v)
				end
			end
		elseif (v==32) then
			if base.plane==1 then
				local openLv=planeVoApi:getOpenLevel()
				if playerVoApi:getPlayerLevel()>=openLv and self:checkGuide(v)==false then
					local lastLv=data
					if lastLv<openLv then
						table.insert(self.waitingForGuideTb,v)
					end
				end
			end
		elseif (v == 85) then
			if base.plane == 1 and planeRefitVoApi and planeRefitVoApi:isCanEnter() == true then
				table.insert(self.waitingForGuideTb, v)
			end
		elseif (v==41) then
			if ltzdzVoApi:isOpen()==true and self:checkGuide(v)==false then
				local openLv,lastLv,playerLv=ltzdzVoApi:getOpenLv(),data,playerVoApi:getPlayerLevel()
				if playerLv>=openLv and lastLv<openLv then
					table.insert(self.waitingForGuideTb,41)
				end
			end
		elseif (v==90) then
			if airShipVoApi:isOpen()==true and self:checkGuide(v)==false then
				local openLv,lastLv,playerLv=airShipVoApi:getOpenLv(),data,playerVoApi:getPlayerLevel()
				if playerLv>=openLv and lastLv<openLv then
					table.insert(self.waitingForGuideTb,v)
				end
			end
		elseif(self:checkGuide(v)==false)then
			local flag=false
			for k1,v1 in pairs(self.waitingForGuideTb) do
				if(v1==v)then
					flag=true
					break
				end
			end
			if(flag==false)then
				table.insert(self.waitingForGuideTb,v)
			end
		end
	end
end

function otherGuideMgr:tick()
	if(newGuidMgr.isGuiding or self.isGuiding)then
		do return end
	end
	local waitingStep=self.waitingForGuideTb[1]
	if(waitingStep==1 or waitingStep==83)then
		if sceneController:getNextIndex()==1 and base.allShowedCommonDialog==0 and newGuidMgr:isNewGuiding()==false and SizeOfTable(G_SmallDialogDialogTb)==0 then
			portScene.sceneSp:setScale(portScene.minScale)
			portScene:focusOnScreen(15)
			
			-- if G_isIphone5() == true then
			-- 	portScene.clayer:setPosition(ccp(-820-600,80))
			-- else
			-- 	portScene.clayer:setPosition(ccp(-820-600,80-170))
			-- end
			self:showGuide(waitingStep)
		end
	elseif(waitingStep==2 or waitingStep==6)then
		self:showGuide(waitingStep)
	elseif(waitingStep==5)then
		if sceneController:getNextIndex()==1 and base.allShowedCommonDialog==0 and newGuidMgr:isNewGuiding()==false and SizeOfTable(G_SmallDialogDialogTb)==0 then
			portScene.sceneSp:setScale(portScene.minScale)
			portScene:focusOnScreen(102)
			-- portScene.clayer:setPosition(ccp(-1200,G_VisibleSizeHeight - 950))
			self:showGuide(waitingStep)
		end
	elseif(waitingStep==16 or waitingStep==73)then
		if sceneController:getNextIndex()==1 and base.allShowedCommonDialog==0 and newGuidMgr:isNewGuiding()==false and SizeOfTable(G_SmallDialogDialogTb)==0 then
			portScene.sceneSp:setScale(portScene.minScale)
			portScene:focusOnScreen(104)
			-- portScene.clayer:setPosition(ccp(-650,G_VisibleSizeHeight - 1200))
			self:showGuide(waitingStep)
		end
	elseif(waitingStep==18)then
		if sceneController:getNextIndex()==1 and base.allShowedCommonDialog==0 and newGuidMgr:isNewGuiding()==false and SizeOfTable(G_SmallDialogDialogTb)==0 then
			portScene.sceneSp:setScale(portScene.minScale)
			portScene:focusOnScreen(105)
			-- portScene.clayer:setPosition(ccp(-908,G_VisibleSizeHeight - 1210))
			self:showGuide(waitingStep)
		end
	elseif(waitingStep==32) then
		if base.plane==1 and sceneController:getNextIndex()==1 and base.allShowedCommonDialog==0 and newGuidMgr:isNewGuiding()==false and SizeOfTable(G_SmallDialogDialogTb)==0 then
			portScene.sceneSp:setScale(portScene.minScale)
			portScene:focusOnScreen(106)
			-- portScene.clayer:setPosition(ccp(-80,G_VisibleSizeHeight - 1000))
			self:showGuide(waitingStep)
		end
	elseif(waitingStep==41) then
		if sceneController:getNextIndex()==1 and base.allShowedCommonDialog==0 and newGuidMgr:isNewGuiding()==false and SizeOfTable(G_SmallDialogDialogTb)==0 then
			portScene.sceneSp:setScale(portScene.minScale)
			portScene:focusOnScreen(14)
			-- portScene.clayer:setPosition(ccp(-820,80))
			self:showGuide(waitingStep)
		end
	elseif(waitingStep==80) then
		if sceneController:getNextIndex()==1 and base.allShowedCommonDialog==0 and newGuidMgr:isNewGuiding()==false and SizeOfTable(G_SmallDialogDialogTb)==0 then
			portScene.sceneSp:setScale(portScene.minScale)
			portScene:focusOnScreen(9)
			-- portScene.clayer:setPosition(ccp(-650,G_VisibleSizeHeight - 1200))
			self:showGuide(waitingStep)
		end
	elseif(waitingStep==82) then
		if sceneController:getNextIndex()==1 and base.allShowedCommonDialog==0 and newGuidMgr:isNewGuiding()==false and SizeOfTable(G_SmallDialogDialogTb)==0 then
			portScene.sceneSp:setScale(portScene.minScale)
			portScene:focusOnScreen(nil)
			-- portScene.clayer:setPosition(ccp(-650,G_VisibleSizeHeight - 1200))
			self:showGuide(waitingStep)
		end
	elseif(waitingStep==90) then
		if sceneController:getNextIndex()==1 and base.allShowedCommonDialog==0 and newGuidMgr:isNewGuiding()==false and SizeOfTable(G_SmallDialogDialogTb)==0 then
			portScene.sceneSp:setScale(portScene.minScale)
			portScene:focusOnScreen(52)
			-- portScene.clayer:setPosition(ccp(-650,G_VisibleSizeHeight - 1200))
			self:showGuide(waitingStep)
		end
	-- else
	-- 	if waitingStep then
	-- 		self:showGuide(waitingStep)
	-- 	end
	end
end

--设置教学步骤的某些字段的数值
--pullFlag：--引导元素所在板子是否有向上拉取的动作，有的话引导元素最终在屏幕中显示的位置与初始化时的位置相差一个屏幕高度
function otherGuideMgr:setGuideStepField(step,guideSp,pullFlag,otherSpTb,params)
	if G_isApplyVersion()==true then
		do return end
	end
    if otherGuideCfg[step] then
        local clickRect=nil
        if params then
            if params.panlePos then
                otherGuideCfg[step].panlePos=params.panlePos
            end
        end
	    local offestY=0
        if pullFlag and pullFlag==true then
            offestY=G_VisibleSizeHeight
        end
        if params and params.clickRect then
            clickRect=params.clickRect
        else
            if guideSp then
            	local mx,my = 0,0
            	if params and params.mx then
            		mx = params.mx --x坐标偏移量
            	end
            	if params and params.my then
            		my = params.my --y坐标偏移量
            	end
                local x,y,width,height=G_getSpriteWorldPosAndSize(guideSp,1)
                y=y+offestY
                local scale=otherGuideCfg[step].scale or 1
                clickRect=CCRectMake(x-(scale-1)*width*0.5+mx,y-(scale-1)*height*0.5+my,width*scale,height*scale)
            end
        end
        otherGuideCfg[step].clickRect=clickRect
        if clickRect then
            if otherGuideCfg[step].panelOffsetY then
                otherGuideCfg[step].panlePos=ccp(10,clickRect:getMinY()+otherGuideCfg[step].panelOffsetY)
            end
            -- print("otherstep"..step..".clickRect=".."{"..clickRect:getMinX()..","..clickRect:getMinY()..","..clickRect.size.width..","..clickRect.size.height.."}")
        end
        if otherSpTb then
            -- print("otherstep"..step..".otherRectTb===>")
            local otherRectTb=otherGuideCfg[step].otherRectTb or {}
           	local otherSp,idx=otherSpTb[1],otherSpTb[2]
        	if otherRectTb[idx]==nil and otherSp and idx then
        		local x,y,width,height=G_getSpriteWorldPosAndSize(otherSp)
                y=y+offestY
                if step==63 then
                	width,height=110,60
            	elseif step==53 then
            		width,height=310,85
                end
                otherRectTb[idx]={x,y,width,height}
                -- print("{"..x..","..y..","..width..","..height.."}")
        	end
            otherGuideCfg[step].otherRectTb=otherRectTb
        end
    end
end

--检查该步引导是否已经出现过，出现过的引导会在本地存数据
--param step 要检查的步骤
--return true or false,是否已经引导过
function otherGuideMgr:checkGuide(step)
	if G_isApplyVersion()==true then
		do return true end
	end
	local dataKey="otherGuide@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID).."@"..tostring(step)
	if(self.checkGuideTb[dataKey]==nil)then
		local localData=CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
		if(localData~=nil and localData~="")then
			self.checkGuideTb[dataKey]=true
		else
			self.checkGuideTb[dataKey]=false
		end
	end
	if self.checkGuideTb[dataKey]==nil or self.checkGuideTb[dataKey]==false then
		local guidCfg=otherGuideCfg[step]
		if tonumber(step)==18 or tonumber(step)==32 or tonumber(step)==34 or tonumber(step)==38 or (guidCfg.sync and guidCfg.sync==1) then --sync该教学步骤需要同步服务器
			local funcStepTb=playerVoApi:getFuncGuideStep()
			for k,sid in pairs(funcStepTb) do
				if tonumber(sid)==tonumber(step) then
					self.checkGuideTb[dataKey]=true
				end
			end
		end
	end
	return self.checkGuideTb[dataKey]
end

function otherGuideMgr:showGuide(step)
	if G_isApplyVersion()==true then
		do return end
	end
	if guideTipMgr.isTiping==true or GM_UidCfg[playerVoApi:getUid()] then
		do return end
	end
    self:hidingGuild() --先隐藏之前的教学页面
	self.isGuiding=true
	self.curStep=step
	self:removeOtherRectSp() --移除跟下一步教学无关的显示元素
	-- print("self.curStep---->",self.curStep)
	local dataKey="otherGuide@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID).."@"..tostring(step)
	CCUserDefault:sharedUserDefault():setStringForKey(dataKey,"1")
	CCUserDefault:sharedUserDefault():flush()
	self.checkGuideTb[dataKey]=true

	local guideItem=nil
	-- if self.curStep==1 or self.curStep==5 or self.curStep==16 or self.curStep==18 or self.curStep==32 or self.curStep==41 then --地库引导
        local buildObj
        if self.curStep==1 or self.curStep==83 then
        	buildObj=buildings.allBuildings[15]
    	elseif self.curStep==5 then
        	buildObj=buildings.allBuildings[102]
    	elseif self.curStep==16 or self.curStep==73 then
        	buildObj=buildings.allBuildings[104]
      	elseif self.curStep==18 then
        	buildObj=buildings.allBuildings[105]
      	elseif self.curStep==32 then
        	buildObj=buildings.allBuildings[106]
      	elseif self.curStep==41 then
        	buildObj=buildings.allBuildings[14]
        elseif self.curStep==80 then
        	buildObj=buildings.allBuildings[9]
        elseif self.curStep==82 then
        	buildObj={buildSp=portScene.copterBody}
        elseif self.curStep==90 then --飞艇建筑引导
        	buildObj=buildings.allBuildings[52]
        end
        if buildObj and buildObj.buildSp then
            guideItem=buildObj.buildSp
        end
	-- end
    if guideItem then
        self:setGuideStepField(self.curStep,guideItem)
    end
	local guidCfg=otherGuideCfg[self.curStep]
	if self.curStep==18 or self.curStep==32 or self.curStep==34 or self.curStep==38 or (guidCfg.sync and guidCfg.sync==1) then --sync该教学步骤需要同步服务器
		--与服务器同步功能阶段性引导
	  	local function syncStep(fn,data)
            if base:checkServerData(data)==true then
   				playerVoApi:setFuncGuideStep(self.curStep)
            end
        end
        socketHelper:funcStepSync(self.curStep,syncStep)
	end

	local startSpTb={}
	
	local function tmpFunc()
		print("--------->tmpFunc?????")
		if otherGuideCfg[self.curStep].clickToNext==true and self.showFlag==true then --点击屏幕跳入下一步
            self:hidingGuild()
			self:toNextStep()
		else
            if self.showFlag==true then
                self:playCircleEffect()
            end
		end
	end
	if self.bgLayer==nil then
		self.bgLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),tmpFunc)
		self.bgLayer:setAnchorPoint(ccp(0.5,0.5))
		self.bgLayer:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height/2))
		self.bgLayer:setContentSize(CCSizeMake(G_VisibleSize.width,G_VisibleSize.height))
		self.bgLayer:setTouchPriority(-320)
		self.bgLayer:setOpacity(0)
		sceneGame:addChild(self.bgLayer,15) --背景透明遮挡层，第7层
	end
    -- if self.touchLayer==nil then
    --     local function touchHandler(fn,x,y,touch)
    --         if fn=="began" then
    --             return 1
    --         elseif fn=="ended" then
    --           	local guidCfg=otherGuideCfg[self.curStep]
    --             if guidCfg.clickRect then
    --                 local touchFlag=guidCfg.clickRect:containsPoint(ccp(x,y))
    --                 if touchFlag==true and self.showFlag==true then
    --                 	print("-------->?????touchHandler")
    --                     self:hidingGuild()
    --                     do return end
    --                 end
    --             end
    --         end
    --     end
    --     self.touchLayer=CCLayer:create()
    --     self.touchLayer:setTouchEnabled(true)
    --     self.touchLayer:registerScriptTouchHandler(touchHandler,false,-320,false)
    --     self.touchLayer:setPosition(0,0)
    --     self.touchLayer:setContentSize(CCSizeMake(G_VisibleSize.width,G_VisibleSize.height))
    --     sceneGame:addChild(self.touchLayer,10) --背景透明遮挡层，第7层
    -- end
    -- print("guidCfg.clickRect",guidCfg.clickRect)
	self.bgLayer:setNoSallowArea(CCRect(-1000,-1000,1,1))	
	if guidCfg.hasPanel==true then --新手引导面板
		self:showPanel()
		self.panel=tolua.cast(self.panel,"CCNode")
		self.panel:setVisible(true)
	else
		if self.panel~=nil then
			self.panel=tolua.cast(self.panel,"CCNode")
			self.panel:setVisible(false)
		end
		if self.arrow~=nil then
			self.arrow=tolua.cast(self.arrow,"CCNode")
			self.arrow:setVisible(false)
		end
        local function realShow()
            -- self:showArrowSp() --显示引导箭头
            if guidCfg.clickRect==nil then
        		self.bgLayer:setOpacity(125)
            	self:showOtherRectSp(self.bgLayer)
            	self.showFlag=true
            	self:setNoSallowArea()
            else
            	self.bgLayer:setOpacity(0)
	            self:showSelectSp() --显示引导选择框
            end
        end
        local delay=CCDelayTime:create(guidCfg.delayTime==nil and 0.4 or guidCfg.delayTime)
        local ffunc=CCCallFuncN:create(realShow)
        local fseq=CCSequence:createWithTwoActions(delay,ffunc)
        self.bgLayer:runAction(fseq)
	end
end

function otherGuideMgr:showPanel()
	local sizeStr2 = 25
	if G_getCurChoseLanguage() =="ru" then
		sizeStr2 =22
	end
	local guidCfg=otherGuideCfg[self.curStep]
	if guidCfg.panlePos==nil then
		do return end
	end
	if self.panel==nil then
		self.panel=CCNode:create()
		if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
			self.gn=CCSprite:create("public/guide.png")
		else
			self.gn=CCSprite:createWithSpriteFrameName("GuideCharacter_new.png") --姑娘
		end
		self.gn:setAnchorPoint(ccp(0,0))
		self.gn:setPosition(ccp(30,100))
		self.panel:addChild(self.gn)
		 
		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(20, 20, 10, 10);
		local function cellClick(hd,fn,idx)
		end
		self.headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("GuideNewPanel.png",capInSet,cellClick)--对话背景
		self.headerSprie:setContentSize(CCSizeMake(G_VisibleSize.width-20,120))
		self.headerSprie:ignoreAnchorPointForPosition(false);
		self.headerSprie:setAnchorPoint(ccp(0,0));
		self.headerSprie:setTouchPriority(0)
		self.panel:addChild(self.headerSprie)
		self.guidLabel=GetTTFLabelWrap("",sizeStr2,CCSize(G_VisibleSize.width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		self.guidLabel:setAnchorPoint(ccp(0,0.5))
		self.guidLabel:setPosition(ccp(20,self.headerSprie:getContentSize().height/2))
		self.headerSprie:addChild(self.guidLabel) --添加文本框
		local function closeBtnHandler()
			guidCfg=otherGuideCfg[self.curStep]
			if guidCfg.hasCloseBtn~=true then
				do return end
			end
			local function callBack()
				self:endNewGuid()
			end
			PlayEffect(audioCfg.mouseClick)   
			smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,getlocal("dialog_title_prompt"),getlocal("guide_skip_prompt"),nil,100)
		end
		self.closeBtn= LuaCCSprite:createWithSpriteFrameName("GuideNewClose.png",closeBtnHandler)
		self.closeBtn:setPosition(self.headerSprie:getContentSize().width-self.closeBtn:getContentSize().width/2,self.headerSprie:getContentSize().height+self.closeBtn:getContentSize().height/2-3)
		self.closeBtn:setTouchPriority(-322)
		self.headerSprie:addChild(self.closeBtn,1)

	    local rect=CCSizeMake(80,80)
        self.bigCloseBtn=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),closeBtnHandler)
        self.bigCloseBtn:setTouchPriority(-321)
        self.bigCloseBtn:setContentSize(rect)
        self.bigCloseBtn:setOpacity(0)
        self.bigCloseBtn:setPosition(self.closeBtn:getPosition())
        self.headerSprie:addChild(self.bigCloseBtn)
		 
		----以下面板上的倒三角----
		self.dArrowSp=CCSprite:createWithSpriteFrameName("DownArow1.png")
		local spcArr=CCArray:create()
		for kk=1,12 do
			local nameStr="DownArow"..kk..".png"
			local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
			spcArr:addObject(frame)
		end
		local animation=CCAnimation:createWithSpriteFrames(spcArr)
		animation:setRestoreOriginalFrame(true);
		animation:setDelayPerUnit(0.08)
		local animate=CCAnimate:create(animation)
		local repeatForever=CCRepeatForever:create(animate)
		self.dArrowSp:runAction(repeatForever)
		self.dArrowSp:setAnchorPoint(ccp(1,0))
		self.dArrowSp:setPosition(ccp(self.headerSprie:getContentSize().width,2))
		self.panel:addChild(self.dArrowSp)
		 ----以上面板上的倒三角----
		self.bgLayer:addChild(self.panel,10)
	end
	if self.dArrowSp~=nil then
		self.dArrowSp=tolua.cast(self.dArrowSp,"CCNode")
		self.dArrowSp:setVisible(false)
	end
	if self.arrow==nil and guidCfg.arrowPos then --箭头
		self.arrow=CCSprite:createWithSpriteFrameName("GuideArow.png")
		self.arrow:setAnchorPoint(ccp(0.5,0.5))
		self.bgLayer:addChild(self.arrow)
	end
	if self.arrow~=nil then --箭头
		self.arrow:setPosition(guidCfg.arrowPos)
	end

	if guidCfg.hasCloseBtn==true then --面板上的关闭按钮
		 self.closeBtn:setVisible(true)
		 self.bigCloseBtn:setVisible(true)
	else
		 self.closeBtn:setVisible(false)
		 self.bigCloseBtn:setVisible(false)
	end
	self.guidLabel:setString(getlocal("other_guide_tip_"..self.curStep))
	self.panel:setPosition(guidCfg.panlePos)
	self.panel:stopAllActions()
	if self.guidLabel:getContentSize().height>120 then
		self.headerSprie:setContentSize(CCSizeMake(G_VisibleSize.width-20,self.guidLabel:getContentSize().height+16))
	else
		self.headerSprie:setContentSize(CCSizeMake(G_VisibleSize.width-20,120))
	end
	self.guidLabel:setPosition(20,self.headerSprie:getContentSize().height/2)
	if self.closeBtn and self.bigCloseBtn and tolua.cast(self.closeBtn,"CCSprite") and tolua.cast(self.bigCloseBtn,"CCScale9Sprite") then
		self.closeBtn:setPosition(self.headerSprie:getContentSize().width-self.closeBtn:getContentSize().width/2,self.headerSprie:getContentSize().height+self.closeBtn:getContentSize().height/2-3)
		self.bigCloseBtn:setPosition(self.closeBtn:getPosition())
	end
	if self.dArrowSp and tolua.cast(self.dArrowSp,"CCSprite") then
		self.dArrowSp:setPosition(ccp(self.headerSprie:getContentSize().width,2))
	end
	if self.gn and tolua.cast(self.gn,"CCSprite") then
		self.gn:setPosition(30,self.headerSprie:getPositionY()+self.headerSprie:getContentSize().height-20)
	end

	if self.headerSprie~=nil then
		self.headerSprie:stopAllActions()
		self.headerSprie:setOpacity(0)
	end
	
	if self.gn~=nil then
		 self.gn:stopAllActions()
		self.gn:setOpacity(0)
	end

	if self.arrow~=nil then
		self.arrow:stopAllActions()
		self.arrow:setOpacity(0)
	end
	if self.guidLabel~=nil then
		self.guidLabel:stopAllActions()
		self.guidLabel:setOpacity(0)
		if guidCfg.showGirl~=nil and guidCfg.showGirl==false then
			self.gn=tolua.cast(self.gn,"CCNode")
			self.gn:setVisible(false)
		else
			self.gn=tolua.cast(self.gn,"CCNode")
			self.gn:setVisible(true)
		end
		
		if self.arrow then
			if guidCfg.clickRect==nil then
				self.arrow=tolua.cast(self.arrow,"CCNode")
				self.arrow:setVisible(false)
			else
				self.arrow=tolua.cast(self.arrow,"CCNode")
				self.arrow:setVisible(true)
			end
		end
	end
	
	if self.selectSp~=nil then
		self.selectSp:stopAllActions()
		self.selectSp:setOpacity(0)
	end

	if self.closeBtn~=nil and self.closeBtn:isVisible()==true then
		self.closeBtn:stopAllActions()
		self.closeBtn:setOpacity(0)
	end
	

	local function showP()
		if self.headerSprie~=nil then
			self.headerSprie:stopAllActions()
			local fadeIn=CCFadeIn:create(0.3)
			self.headerSprie:setOpacity(0)
			self.headerSprie:runAction(fadeIn)
		end			
		if self.gn~=nil then
			self.gn:stopAllActions()
			local fadeIn=CCFadeIn:create(0.3)
			self.gn:setOpacity(0)
			self.gn:runAction(fadeIn)
		end
		if self.dArrowSp~=nil then
			if guidCfg.clickToNext==true then
				self.dArrowSp:setVisible(true)
			else
				self.dArrowSp:setVisible(false)
			end
		end
		
		if self.guidLabel~=nil then
			self.guidLabel:stopAllActions()
			local fadeIn=CCFadeIn:create(0.3)
			self.guidLabel:setOpacity(0)
			self.guidLabel:runAction(fadeIn)
		end
		if self.closeBtn~=nil and self.closeBtn:isVisible()==true then
			self.closeBtn:stopAllActions()
			local fadeIn=CCFadeIn:create(0.3)
			self.closeBtn:setOpacity(0)
			self.closeBtn:runAction(fadeIn)
		end
	end
	local function realShow()
        if guidCfg.clickRect==nil then
        	self.bgLayer:setOpacity(125)
        	showP()
        	self:showOtherRectSp(self.bgLayer)
        	self.showFlag=true
        	self:setNoSallowArea()
        else
        	self.bgLayer:setOpacity(0)
       		self:showSelectSp(showP)
        end
    end
    local delay=CCDelayTime:create(guidCfg.delayTime==nil and 0.4 or guidCfg.delayTime)
    local ffunc=CCCallFuncN:create(realShow)
    local fseq=CCSequence:createWithTwoActions(delay,ffunc)
    self.panel:runAction(fseq)
end

--设置可点击区域
function otherGuideMgr:setNoSallowArea()
	local guidCfg=otherGuideCfg[self.curStep]
	if guidCfg.clickRect~=nil then
		self.bgLayer:setNoSallowArea(guidCfg.clickRect)
	end
end

function otherGuideMgr:toNextStep(nextId)
	if G_isApplyVersion()==true then
		do return end
	end
	if self.bgLayer~=nil then
		self.bgLayer:setNoSallowArea(CCRect(-1000,-1000,1,1))
	end
	local nextStep
	if nextId~=nil then
		nextStep=nextId
	elseif(self.curStep)then
		nextStep=otherGuideCfg[self.curStep].toStepId
	end
	if(nextStep==nil or nextStep=="")then
		self:endNewGuid()
	else
		self:showGuide(nextStep)
	end
end

function otherGuideMgr:showSelectSp(callBack)
    if self.bgLayer==nil then
        do return end
    end
    self:displayGuild()

    guidCfg=otherGuideCfg[self.curStep]
    if self.selectSp==nil then
      	local function clickAreaHandler()
        end
    	self.selectSp=LuaCCSprite:createWithSpriteFrameName("guildExternal.png",clickAreaHandler)
        local scale=self:getSelectSpScale()
        self.selectSp:setScale(scale)
        self.selectSp:setAnchorPoint(ccp(0.5,0.5))
        local internalSp=CCSprite:createWithSpriteFrameName("guildInternal.png")
        internalSp:setPosition(getCenterPoint(self.selectSp))
        internalSp:setTag(1001)
        self.selectSp:addChild(internalSp)
        self.selectSp:setTouchPriority(-1)
        self.selectSp:setIsSallow(false)
        self.bgLayer:addChild(self.selectSp,4)
        self.selectSp:setVisible(false)

        --调教学使用
        -- self.halo=LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png",CCRect(28,28,2,2),clickAreaHandler)
        -- self.halo:setAnchorPoint(ccp(0,0))
        -- self.halo:setTouchPriority(1000)
        -- self.bgLayer:addChild(self.halo)
        -- self.halo:setVisible(false)


        local shadeLayer=CCClippingNode:create() --遮罩层
        shadeLayer:setContentSize(CCSizeMake(G_VisibleSize.width,G_VisibleSize.height))
        shadeLayer:setAnchorPoint(ccp(0.5,0.5))
        shadeLayer:setInverted(true)
        shadeLayer:setPosition(G_VisibleSize.width/2,G_VisibleSize.height/2)
        shadeLayer:setVisible(false)

        local back=CCLayerColor:create(ccc4(0,0,0,125))
        shadeLayer:addChild(back)
        local stencilLayer=CCNode:create()
        stencilLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
        stencilLayer:setAnchorPoint(ccp(0.5,0.5))
        stencilLayer:setPosition(getCenterPoint(shadeLayer))

        local circleSp=CCSprite:createWithSpriteFrameName("guidShade.png")
        circleSp:setScale(scale)
        stencilLayer:addChild(circleSp)
        shadeLayer:setStencil(stencilLayer)
        self.bgLayer:addChild(shadeLayer,3)

        local clipLayer=CCClippingNode:create() --裁切层
        clipLayer:setContentSize(CCSizeMake(G_VisibleSize.width,G_VisibleSize.height))
        clipLayer:setAnchorPoint(ccp(0.5,0.5))
        clipLayer:setPosition(G_VisibleSize.width/2,G_VisibleSize.height/2)
        clipLayer:setVisible(false)

        local stencil=CCSprite:createWithSpriteFrameName("guidShade.png")
        stencil:setOpacity(0)
        stencil:setScale(scale)
        clipLayer:setStencil(stencil)

        local shadeSp=CCSprite:createWithSpriteFrameName("guidShade_big.png")
        shadeSp:setOpacity(125)
        shadeSp:setScale(scale)
        shadeSp:setPosition(getCenterPoint(clipLayer))
        clipLayer:addChild(shadeSp)


        self.bgLayer:addChild(clipLayer,2)

        self.shadeLayer=shadeLayer
        self.clipLayer=clipLayer
        self.circleSp=circleSp
        self.shadeSp=shadeSp
        self.stencil=stencil
        self.stencilLayer=stencilLayer
    end     
    if self.selectSp~=nil then
        if guidCfg.clickRect~=nil then --添加点击区域图标
            self.selectSp:setVisible(true)
            if self.shadeLayer then
                self.shadeLayer:setVisible(true)
            end
            if self.clipLayer then
                self.clipLayer:setVisible(true)
            end
            self.selectSp:setPosition(ccp(guidCfg.clickRect:getMinX()+guidCfg.clickRect.size.width/2,guidCfg.clickRect:getMinY()+guidCfg.clickRect.size.height/2))
            --调教学使用
            -- self.halo:setPosition(guidCfg.clickRect:getMinX(),guidCfg.clickRect:getMinY())
            -- self.halo:setContentSize(CCSizeMake(guidCfg.clickRect.size.width,guidCfg.clickRect.size.height))
            -- self.halo:setVisible(true)
            if self.circleSp and self.shadeSp and self.stencil then
                local x=self.selectSp:getPositionX()
                local y=self.selectSp:getPositionY()
                self.circleSp:setPosition(x,y)
                self.shadeSp:setPosition(x,y)
                self.stencil:setPosition(x,y)
            end
        else
            if self.shadeLayer then
                self.shadeLayer:setVisible(false)
            end
            if self.clipLayer then
                self.clipLayer:setVisible(false)
            end
            self.selectSp:setVisible(false)
        end
        local function playSelectEffect(target,angle,isScale)
            if target then
                local rotateAc=CCRotateBy:create(2,angle)
                if isScale and isScale==true then
                    local scale=self:getSelectSpScale()
                    local maxScale=1.3*scale
                    local scaleAc1=CCScaleTo:create(0.5,maxScale)
                    local scaleAc2=CCScaleTo:create(0.5,scale)
                    local scaleSeq=CCSequence:createWithTwoActions(scaleAc1,scaleAc2)
                    local effectArr=CCArray:create()
                    effectArr:addObject(rotateAc)
                    effectArr:addObject(scaleSeq)
                    local spawnAc=CCSpawn:create(effectArr)
                    target:runAction(CCRepeatForever:create(scaleSeq))
                    target:runAction(CCRepeatForever:create(rotateAc))
                else
                    target:runAction(CCRepeatForever:create(rotateAc))
                end
            end
        end

        local function realShowSelect()
            self.selectSp:setOpacity(255)
            local internalSp=tolua.cast(self.selectSp:getChildByTag(1001),"CCSprite")
            if internalSp then
                internalSp:setOpacity(255)
                playSelectEffect(internalSp,720)
            end
            playSelectEffect(self.selectSp,-360,true)
            if callBack then
                callBack()
            end
            self.showFlag=true
        end
        self:playCircleEffect(realShowSelect)
    end
end

function otherGuideMgr:playCircleEffect(callBack)
    local function realPlay(target,callBack)
       if target then
            target:stopAllActions()
            local scale=self:getSelectSpScale()
            local maxScale=1.1*scale
            local beginScale=15*scale
            target:setScale(beginScale)
            local arr=CCArray:create()
            local scaleAc=CCScaleTo:create(0.5,scale)
            arr:addObject(scaleAc)
            local function scaleHandler()
                local scaleAc1=CCScaleTo:create(0.3,maxScale)
                local scaleAc2=CCScaleTo:create(0.3,scale)
                local scaleSeq=CCSequence:createWithTwoActions(scaleAc1,scaleAc2)
                -- target:runAction(CCRepeatForever:create(scaleSeq))
                if callBack then
                    callBack()
                    self:showOtherRectSp(self.bgLayer,self.stencilLayer)
                    self:setNoSallowArea()
                end
            end
            local func=CCCallFuncN:create(scaleHandler)
            arr:addObject(func)
            local scaleSeq=CCSequence:create(arr)
            target:runAction(scaleSeq)
       end
    end
    if self.circleSp then
        realPlay(self.circleSp,callBack)
    end
    if self.shadeSp then
        self.shadeSp:setVisible(true)
        realPlay(self.shadeSp)
    end
    if self.stencil then
        realPlay(self.stencil)
    end
end

function otherGuideMgr:showArrowSp()
    if self.bgLayer==nil then
        do return end
    end
    guidCfg=otherGuideCfg[self.curStep]
    if guidCfg.arrowDirect==nil or guidCfg.arrowPos==nil then
    	do return end
    end
    if self.arrow==nil then --箭头
        self.arrow=CCSprite:createWithSpriteFrameName("GuideArow.png")
        self.arrow:setAnchorPoint(ccp(0.5,0.5))
        self.bgLayer:addChild(self.arrow,2)
    end
    if self.arrow~=nil then
        self.arrow:stopAllActions()
        self.arrow:setVisible(false)
        if guidCfg.arrowDirect==1 then  --下
                guidCfg.arrowPos.y=guidCfg.arrowPos.y-100/2
        elseif guidCfg.arrowDirect==2 then  --上
                guidCfg.arrowPos.y=guidCfg.arrowPos.y+100/2
        elseif guidCfg.arrowDirect==3 then  --右上
                guidCfg.arrowPos.x=guidCfg.arrowPos.x+80/2
                guidCfg.arrowPos.y=guidCfg.arrowPos.y+80/2
        end
        self.arrow:setPosition(guidCfg.arrowPos)
        local function showArrowAction()
            local aimPos
            if guidCfg.arrowDirect==1 then  --下
                aimPos=ccp(guidCfg.arrowPos.x,guidCfg.arrowPos.y-100/2)
                self.arrow:setRotation(0)
            elseif guidCfg.arrowDirect==2 then  --上
                aimPos=ccp(guidCfg.arrowPos.x,guidCfg.arrowPos.y+100/2)
                self.arrow:setRotation(180)
            elseif guidCfg.arrowDirect==3 then  --右上
                aimPos=ccp(guidCfg.arrowPos.x+80/2,guidCfg.arrowPos.y+80/2)
                self.arrow:setRotation(-135)
            elseif guidCfg.arrowDirect==4 then  --从右往左动
                aimPos=ccp(guidCfg.arrowPos.x+50,guidCfg.arrowPos.y)
                self.arrow:setRotation(90)
            end
            if guidCfg.clickRect~=nil then
                self.arrow:setVisible(true)
            end
            local mvTo=CCMoveTo:create(0.35,aimPos)
            local mvBack=CCMoveTo:create(0.35,guidCfg.arrowPos)
            local seq=CCSequence:createWithTwoActions(mvTo,mvBack)
            self.arrow:runAction(CCRepeatForever:create(seq))
        end
        local fadeIn=CCFadeIn:create(0.3)
        self.arrow:setOpacity(0)
        local ffunc=CCCallFuncN:create(showArrowAction)
        local fseq=CCSequence:createWithTwoActions(fadeIn,ffunc)
        self.arrow:runAction(fseq)
    end
end

function otherGuideMgr:getSelectSpScale()
    if self.curStep and self.selectSp then
        guidCfg=otherGuideCfg[self.curStep]
        if guidCfg and guidCfg.clickRect then
            local width=guidCfg.clickRect.size.width
            local height=guidCfg.clickRect.size.height
            if width<height then
                width=height
            end
            local spW=self.selectSp:getContentSize().width
            local scale=width/spW
            if scale>1.5 then
                scale=1.5
            end
            return scale
        end
    end
    return 1
end

--隐藏教学页面
function otherGuideMgr:hidingGuild()
    if self.selectSp~=nil then
        self.selectSp:setVisible(false)
    end
    if self.circleSp then
        self.circleSp:setVisible(false)
    end
    if self.shadeLayer~=nil then
        self.shadeLayer:setVisible(false)
    end
    if self.clipLayer~=nil then
        self.clipLayer:setVisible(false)
    end
   	if self.bgLayer then
		self.bgLayer:stopAllActions()
        self.bgLayer:setOpacity(0)
		if self.isGuiding==false then
			self.bgLayer:setNoSallowArea(CCRect(0,0,G_VisibleSizeWidth,G_VisibleSizeHeight))
		else
			self.bgLayer:setNoSallowArea(CCRect(-1000,-1000,1,1))
		end
    end
    if self.panel then
    	self.panel:stopAllActions()
    	self.panel:setVisible(false)
    end
    if self.touchLayer then
    	self.touchLayer:setVisible(false)
    end
    self.showFlag=false
end

function otherGuideMgr:displayGuild()
	local scale=self:getSelectSpScale()
    if self.selectSp~=nil then
        self.selectSp:setVisible(true)
        self.selectSp:stopAllActions()
        self.selectSp:setScale(scale)
        self.selectSp:setOpacity(0)
        local internalSp=tolua.cast(self.selectSp:getChildByTag(1001),"CCSprite")
        if internalSp then
            internalSp:stopAllActions()
            internalSp:setScale(1)
            internalSp:setOpacity(0)
        end
    end
    if self.circleSp then
        self.circleSp:setScale(scale)
        self.circleSp:stopAllActions()
        self.circleSp:setVisible(true)
    end
    if self.shadeSp then
        self.shadeSp:setVisible(true)
        self.shadeSp:setScale(scale)
        self.shadeSp:stopAllActions()
    end
    if self.shadeLayer~=nil then
        self.shadeLayer:setVisible(true)
    end
    if self.clipLayer~=nil then
        self.clipLayer:setVisible(true)
    end
    if self.touchLayer then
    	self.touchLayer:setVisible(true)
    end
    if self.stencil then
        self.stencil:setScale(scale)
        self.stencil:stopAllActions()
        self.stencil:setVisible(true)
    end
end

function otherGuideMgr:hasOtherRects()
	local guidCfg=otherGuideCfg[self.curStep]
	if guidCfg.otherRectTb~=nil then
		return true
	end
	return false
end

function otherGuideMgr:showOtherRectSp(guildLayer,stencilLayer)
	if guildLayer==nil then
		do return end
	end
	local guidCfg=otherGuideCfg[self.curStep]
	if guidCfg.otherRectTb and self.otherRectFlag==false then
		self.otherRectSpTb={}
		if stencilLayer==nil then --如果当前教学页面没有裁剪层的话，就创建一个
			guildLayer:setOpacity(0) --创建裁剪层时会创建一个黑色遮罩，故将原来的黑色遮罩去掉

	        local clipLayer=CCClippingNode:create() --裁切层
	        clipLayer:setContentSize(CCSizeMake(G_VisibleSize.width,G_VisibleSize.height))
	        clipLayer:setAnchorPoint(ccp(0.5,0.5))
	    	clipLayer:setInverted(true)
	        clipLayer:setPosition(G_VisibleSize.width/2,G_VisibleSize.height/2)

		   	local blackLayer=CCLayerColor:create(ccc4(0,0,0,125))
	        clipLayer:addChild(blackLayer)

	        stencilLayer=CCNode:create()
	        stencilLayer:setContentSize(CCSizeMake(G_VisibleSize.width,G_VisibleSize.height))
	        stencilLayer:setAnchorPoint(ccp(0.5,0.5))
	        stencilLayer:setPosition(getCenterPoint(clipLayer))
            clipLayer:setStencil(stencilLayer)
			guildLayer:addChild(clipLayer)
			table.insert(self.otherRectSpTb,clipLayer)
		end

		for k,v in pairs(guidCfg.otherRectTb) do
			local x,y,width,height=v[1],v[2],v[3],v[4]
			local highLightSp=LuaCCScale9Sprite:createWithSpriteFrameName("guideHighLight.png",CCRect(11,11,1,1),function ()end)
			highLightSp:setPosition(x,y)
			highLightSp:setIsSallow(false)
			highLightSp:setContentSize(CCSizeMake(width,height))
			guildLayer:addChild(highLightSp,8)

			--淡入淡出效果
			local fadeIn=CCFadeIn:create(0.8)
			local fadeOut=CCFadeOut:create(0.8)
			local seq=CCSequence:createWithTwoActions(fadeIn,fadeOut)
			local repeatAc=CCRepeatForever:create(seq)
			highLightSp:runAction(repeatAc)

			--将要裁剪的区域添加到裁剪模板中
			local stencilSp=LuaCCScale9Sprite:createWithSpriteFrameName("guideHighLight.png",CCRect(11,11,1,1),function ()end)
			stencilSp:setPosition(x,y)
			stencilSp:setContentSize(CCSizeMake(width,height))
			stencilLayer:addChild(stencilSp)

			table.insert(self.otherRectSpTb,highLightSp)
			table.insert(self.otherRectSpTb,1,stencilSp) --裁剪的模板必须放在最前面，否则会造成stencilLayer先移除，stencilSp找不到父节点的问题
		end

		self.otherRectFlag=true
	end
end

function otherGuideMgr:removeOtherRectSp()
	if self.otherRectSpTb then
		for k,v in pairs(self.otherRectSpTb) do
			local rectSp=tolua.cast(v,"CCNode")
			if rectSp then
				rectSp:removeFromParentAndCleanup(true)
				rectSp=nil
			end
		end
		self.otherRectSpTb=nil
		self.otherRectFlag=false
	end
end

function otherGuideMgr:endNewGuid()
	self:removeOtherRectSp() --移除跟下一步教学无关的显示元素
	if self.bgLayer~=nil then
		self.bgLayer:removeFromParentAndCleanup(true)
		self.bgLayer=nil
	end
	if self.touchLayer then
		self.touchLayer:removeFromParentAndCleanup(true)
		self.touchLayer=nil
	end
	if(self.waitingForGuideTb[1])then
		table.remove(self.waitingForGuideTb,1)
	end
	self.isGuiding=false
	self.selectSp=nil
	self.panel=nil
	self.arrow=nil
	self.guidLabel=nil
	self.closeBtn=nil
	self.bigCloseBtn=nil
	self.headerSprie=nil
	self.gn=nil
	self.dArrowSp=nil
    self.stencil=nil
    self.clipLayer=nil
    self.shadeLayer=nil
    self.shadeSp=nil
    self.circleSp=nil
    self.showFlag=false
end

function otherGuideMgr:endGuideStep(stepId)
	self:endNewGuid()
	local dataKey="otherGuide@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID).."@"..tostring(stepId)
	CCUserDefault:sharedUserDefault():setStringForKey(dataKey,"1")
	CCUserDefault:sharedUserDefault():flush()
	self.checkGuideTb[dataKey]=true
end

function otherGuideMgr:setGuideStepDone(stepId)
	local dataKey="otherGuide@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID).."@"..tostring(stepId)
	CCUserDefault:sharedUserDefault():setStringForKey(dataKey,"1")
	CCUserDefault:sharedUserDefault():flush()
	self.checkGuideTb[dataKey]=true
end

function otherGuideMgr:clear()
	if(self.eventListener~=nil)then
		for k,v in pairs(otherGuideCfg) do
			if(v.event and v.event~="")then
				eventDispatcher:removeEventListener(v.event,self.eventListener)
			end
		end
	end
	self:removeOtherRectSp()
	self.hasInit=false
	self.curStep=1
	self.bgLayer=nil
	self.bgLayer1=nil
	self.touchLayer=nil
	self.panel=nil
	self.arrow=nil
	self.guidLabel=nil
	self.isGuiding=false
	self.selectSp=nil
	self.closeBtn=nil
	self.bigCloseBtn=nil
	self.dArrowSp=nil
	self.isTextGoing=false
	self.fastTickNum=0
	self.eventListener=nil
	self.waitingForGuideTb={}
	self.eventStepTb={}
	self.checkGuideTb={}
    self.stencil=nil
    self.clipLayer=nil
    self.shadeLayer=nil
    self.shadeSp=nil
    self.circleSp=nil
    self.showFlag=false
end
