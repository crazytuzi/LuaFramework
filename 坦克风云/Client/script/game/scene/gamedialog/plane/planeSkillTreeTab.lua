--战机革新页签
planeSkillTreeTab={}

function planeSkillTreeTab:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function planeSkillTreeTab:init(layerNum,parent,studySid)
    self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent
	self.studySid=studySid --正在研究的技能

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	spriteController:addPlist("public/plane/planeSkillTreeImages.plist")
    spriteController:addTexture("public/plane/planeSkillTreeImages.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    spriteController:addPlist("public/squaredImgs.plist")
  	spriteController:addTexture("public/squaredImgs.png")
    spriteController:addPlist("public/youhuaUI3.plist")
  	spriteController:addTexture("public/youhuaUI3.png")
   	spriteController:addPlist("public/youhuaUI4.plist")
   	spriteController:addTexture("public/youhuaUI4.png")

	local blackBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),function ()end)
    blackBg:setAnchorPoint(ccp(0.5,1))
    blackBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-330))
    blackBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160)
    self.bgLayer:addChild(blackBg)

    local treeBg=CCSprite:create("public/plane/planeSkillTreeBg.jpg")
    treeBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-435)
    self.bgLayer:addChild(treeBg)

	self.nscfg=planeVoApi:getNewSkillCfg()
	self.studyPoint=planeVoApi:getStudyPoint()
   
   	--技能树
   	self:initSkillTreeLayer()
   	--初始化主动技能的使用部分
   	self:initBottomLayer()

   	local function refreshSkillTree(event,data)
        self:refreshSkillTreeLayer()
    end
    self.refreshListener=refreshSkillTree
    eventDispatcher:addEventListener("plane.newskill.refresh",self.refreshListener)

    if self.studySid then
    	self:jumpToSkill(self.studySid)
    end

	return self.bgLayer
end

--初始化技能树
function planeSkillTreeTab:initSkillTreeLayer()
	self.nsBgWidth,self.nsBgHeight=138,176
	self.spaceX,self.spaceY=20,28
	self.tvWidth,self.tvHeight=G_VisibleSizeWidth-20,G_VisibleSizeHeight-360
	self.cellHeight=8*self.nsBgHeight+7*self.spaceY

	local function callBack(...)
	   return self:eventHandler(...)
	end

	local hd=LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition((G_VisibleSizeWidth-self.tvWidth)/2,G_VisibleSizeHeight-170-self.tvHeight)
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(80)
end

function planeSkillTreeTab:initBottomLayer()
	local bottomBgHeight=156
 	local bottomBg1=LuaCCSprite:createWithSpriteFrameName("creatRole1.png",function () end)
 	bottomBg1:setTouchPriority(-(self.layerNum-1)*20-5)
    bottomBg1:setAnchorPoint(ccp(0,0))
    bottomBg1:setScaleY(bottomBgHeight/bottomBg1:getContentSize().height)
    self.bgLayer:addChild(bottomBg1,1)
    bottomBg1:setPosition(0,0)

    local bottomBg2=LuaCCSprite:createWithSpriteFrameName("creatRole1.png",function () end)
 	bottomBg2:setTouchPriority(-(self.layerNum-1)*20-5)
    bottomBg2:setAnchorPoint(ccp(0,0))
    bottomBg2:setScaleY(bottomBgHeight/bottomBg2:getContentSize().height)
    self.bgLayer:addChild(bottomBg2,1)
    bottomBg2:setPosition(G_VisibleSizeWidth/2,0)
    bottomBg2:setFlipX(true)

   	--研究值状态
	local point,maxPoint=planeVoApi:getStudyPoint()
	local pw,ph=638,24
	if point<0 then
		point=0
	end
    local per=(point/maxPoint)*100

	local function touchBar()
		local returnSpeed = planeVoApi:getStudyPointReturnSpeed()
    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plane_studypoint_tip",{GetTimeStr(returnSpeed, true)}),28)
	end
    local pointBarBg=LuaCCScale9Sprite:createWithSpriteFrameName("studyPointBarBg.png",CCRect(4,4,1,1),touchBar)
	pointBarBg:setTouchPriority(-(self.layerNum-1)*20-5)
    pointBarBg:setContentSize(CCSizeMake(pw,ph))
    pointBarBg:setPosition(G_VisibleSizeWidth/2,bottomBgHeight+pointBarBg:getContentSize().height/2+2)
    self.bgLayer:addChild(pointBarBg)
    local pointBar=CCSprite:createWithSpriteFrameName("studyPointBar.png")
    local studyTimerSp=CCProgressTimer:create(pointBar)
    studyTimerSp:setMidpoint(ccp(0,1))
    studyTimerSp:setBarChangeRate(ccp(1,0))
    studyTimerSp:setType(kCCProgressTimerTypeBar)
    studyTimerSp:setPosition(pointBarBg:getPosition())
    studyTimerSp:setScaleX((pw-8)/studyTimerSp:getContentSize().width)
    self.bgLayer:addChild(studyTimerSp,2)
    studyTimerSp:setPercentage(per)
    self.studyTimerSp=studyTimerSp

    local scheduleStr=point.."/"..maxPoint
    local studyTimerLb=GetTTFLabel(scheduleStr,20)
    studyTimerLb:setPosition(pointBarBg:getPosition())
    self.bgLayer:addChild(studyTimerLb,2)
    self.studyTimerLb=studyTimerLb
 
    local propKey="p4630"
    self.studyPid=tonumber(RemoveFirstChar(propKey))
    local num=bagVoApi:getItemNumId(self.studyPid)
    local studyPropSp
    local function exchange()
    	local function realHandler()
    		local function realUseProp(buyFlag)
	            local function useNumProps(num)
	            	local function useProp()
		            	local function callbackUseProc(fn,data)
				      		local ret,sData=base:checkServerData(data)
			                if ret==true then
			                	--刷新研究值数据
			                	planeVoApi:initData(sData.data)
			       				if buyFlag==1 then
			       					--统计购买物品
			        				statisticsHelper:buyItem(propKey,propCfg[propKey].gemCost,num,propCfg[propKey].gemCost)
			       				end
						        --统计使用物品
						        statisticsHelper:useItem(propKey,num)
			                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("use_prop_success",{getlocal(propCfg[propKey].name)}),28)
			                    --刷新道具及研究值
			                    self:refreshStudyPoint()
			                end
			            end
						socketHelper:useProc(self.studyPid,buyFlag,callbackUseProc,nil,nil,num)
	            	end
	            	if buyFlag==1 then
	            		local costGems=num*propCfg[propKey].gemCost
						local popKey="plskill.buy.study"
						local function secondTipFunc(sbFlag)
				            local sValue=base.serverTime .. "_" .. sbFlag
				            G_changePopFlag(popKey,sValue)
				        end
					    if G_isPopBoard(popKey) then
		            		G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("buyAndUsePropStr",{costGems,getlocal(propCfg[propKey].name)}),true,useProp,secondTipFunc)
							do return end
						else
							useProp()
						end
	            	else
						useProp()
	            	end
	            end
	            if buyFlag==1 then --批量购买并使用
    				shopVoApi:showBatchBuyPropSmallDialog(propKey,self.layerNum+1,useNumProps,getlocal("buyAndUse"))
    			else --批量使用
               	 	bagVoApi:showBatchUsePropSmallDialog(propKey,self.layerNum+1,useNumProps)
	            end
	    	end
	    	local ownNum=bagVoApi:getItemNumId(self.studyPid)
	    	if ownNum>0 then --使用道具
				realUseProp()
	    	else --弹出购买二次确认
	    		local costGems=tonumber(propCfg[propKey].gemCost)
	        	if playerVo.gems<costGems then --购买金币不足
	        		local function buyGems()
	            		vipVoApi:showRechargeDialog(self.layerNum+1)
	        		end
	            	local num=costGems-playerVo.gems
	            	G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{costGems,playerVo.gems,num}),false,buyGems)
	        	else
    				realUseProp(1) --购买并使用
	        	end
	    	end
    	end
    	G_touchedItem(studyPropSp,realHandler,0.8*studyPropSp:getScale())
    end
    studyPropSp=LuaCCSprite:createWithSpriteFrameName("skillstudyAdd.png",exchange)
    studyPropSp:setTouchPriority(-(self.layerNum-1)*20-5)
    studyPropSp:setPosition(G_VisibleSizeWidth-32,pointBarBg:getPositionY())
    self.bgLayer:addChild(studyPropSp,4)
    local numBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")
    numBg:setScaleX(60/numBg:getContentSize().width)
    numBg:setScaleY(20/numBg:getContentSize().height)
    numBg:setPosition(studyPropSp:getPositionX(),studyPropSp:getPositionY()-37)
    self.bgLayer:addChild(numBg,4)
    local studyPropNumLb=GetTTFLabel(tostring(num),18)
    studyPropNumLb:setPosition(numBg:getPosition())
    self.bgLayer:addChild(studyPropNumLb,5)
    self.studyPropNumLb=studyPropNumLb

	local addPropBtn=CCSprite:createWithSpriteFrameName("believerAddBtn.png")
	addPropBtn:setColor(ccc3(255,255,0))
    addPropBtn:setPosition(studyPropSp:getContentSize().width-addPropBtn:getContentSize().width/2-5,addPropBtn:getContentSize().height/2+5)
    studyPropSp:addChild(addPropBtn,3)
    if num>0 then
    	addPropBtn:setVisible(false)
    end
    self.addPropBtn=addPropBtn

    --主动技能
    self.asUseStateTb={} --主动技能冷却cd显示
    self.asTb={} --主动技能
	local offsetX,iconWidth=30,113
	local leftPosX=(G_VisibleSizeWidth-3*offsetX-4*iconWidth)/2
	local fontSize,scale,skillBgHeight=20,0.8,90
	for k,sid in pairs(self.nscfg.activeSkill) do
		local posX=leftPosX+iconWidth/2+(k-1)*(iconWidth+offsetX)
		if self:isGermanyHandle(sid) then --德国平台戏谑技能特殊处理（不能使用）
			local skillSp=CCSprite:createWithSpriteFrameName("planeSkillNull.png")
			skillSp:setScale(scale)
			skillSp:setPosition(posX,95)
			self.bgLayer:addChild(skillSp,3)
			local skillBg=CCSprite:createWithSpriteFrameName("planeActiveSkillBg.png")
			skillBg:setPosition(skillSp:getPosition())
			skillBg:setScale(skillBgHeight/skillBg:getContentSize().height)
			self.bgLayer:addChild(skillBg,2)
		else
			local function useSkill() --使用技能
				self:useActiveSkill(sid)
			end
			local sinfo,maxLv=planeVoApi:getNewSkillInfoById(sid)
			local slv=(sinfo.lv or 0)
			local skillSp
			if slv>0 then
				skillSp=planeVoApi:getNewSkillIcon(sid,useSkill)
				skillSp:setTouchPriority(-(self.layerNum-1)*20-5)
			else
				skillSp=planeVoApi:getNewSkillIcon(sid,nil,true)
				local lockSp=CCSprite:createWithSpriteFrameName("LockIconCheckPoint.png")
				lockSp:setPosition(getCenterPoint(skillSp))
				skillSp:addChild(lockSp)
				local function goToSkill()
					self:jumpToSkill(sid)
				end
				local touchBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),goToSkill)
				touchBg:setContentSize(skillSp:getContentSize())
				touchBg:setTouchPriority(-(self.layerNum-1)*20-5)
				touchBg:setPosition(getCenterPoint(skillSp))
				touchBg:setOpacity(0)
				skillSp:addChild(touchBg)
			end
			skillSp:setScale(scale)
			skillSp:setPosition(posX,95)
			self.bgLayer:addChild(skillSp,3)

			local skillBg=CCSprite:createWithSpriteFrameName("planeActiveSkillBg.png")
			skillBg:setPosition(skillSp:getPosition())
			skillBg:setScale(skillBgHeight/skillBg:getContentSize().height)
			self.bgLayer:addChild(skillBg,2)

			local lvLb=GetTTFLabel(getlocal("fightLevel",{slv}),fontSize-2)
			lvLb:setAnchorPoint(ccp(0.5,1))
			lvLb:setPosition(skillSp:getPositionX(),skillSp:getPositionY()-skillBgHeight/2)
			self.bgLayer:addChild(lvLb,3)
			if slv==0 then
				lvLb:setVisible(false)
			end
			local lvinfo=planeVoApi:getNewSkillCfgByLv(sid,sinfo.lv)
			local cost=0
			if lvinfo and lvinfo.cost then
				cost=lvinfo.cost
			end
			local costLb=GetTTFLabel(tostring(cost),fontSize-2)
			costLb:setAnchorPoint(ccp(0,0.5))
			self.bgLayer:addChild(costLb,3)
			local studySp=CCSprite:createWithSpriteFrameName("psstudyExp.png")
			studySp:setAnchorPoint(ccp(0,0.5))
			studySp:setScale(20/studySp:getContentSize().width)
			self.bgLayer:addChild(studySp,3)
			local costWidth=costLb:getContentSize().width+25
			costLb:setPosition(skillSp:getPositionX()-costWidth/2,skillSp:getPositionY()-skillBgHeight/2-28)
			studySp:setPosition(costLb:getPositionX()+costLb:getContentSize().width+5,costLb:getPositionY())
			if point<cost then
				costLb:setColor(G_ColorRed)
			else
				costLb:setColor(G_ColorWhite)
			end
			if cost==0 then
				costLb:setVisible(false)
				studySp:setVisible(false)
			end
			self.asTb[sid]={skillSp,lvLb,costLb,studySp}

			self:refreshActiveSkillUseState(sid)
		end
	end
end

function planeSkillTreeTab:useActiveSkill(sid)
	local function realUse()
		local useFlag,et=planeVoApi:getNewActiveSkillUseFlag(sid)
		if useFlag~=0 then --正在冷却不能使用
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage29105"),28)
			do return end
		end
		local sinfo,maxLv=planeVoApi:getNewSkillInfoById(sid)
		if sinfo.lv==nil or tonumber(sinfo.lv)==0 then --等级为0，不能使用
			do return end
		end
		local studyPoint=planeVoApi:getStudyPoint()
		local lvinfo=planeVoApi:getNewSkillCfgByLv(sid,sinfo.lv)
		if lvinfo and lvinfo.cost and lvinfo.cost>studyPoint then --研究值不够
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage29106"),28)
			do return end
		end
		--使用技能的逻辑处理
		local function refresh(gives)
			self:refreshActiveSkillUseState(sid)
			self:refreshStudyPoint()
			if sid=="s5" and gives then --使用赠送部队的技能时弹出赠送部队的面板
				believerVoApi:showReceiveTroopsDialog(gives,self.layerNum+1) --赠送部队面板
			end
			if sid~="s5" then --显示技能已生效提示
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plane_skill_takeEffect"),28)
			end
		end
		planeVoApi:useNewActiveSkill(sid,refresh)
	end
	local skillSp=tolua.cast(self.asTb[sid][1],"CCSprite")
	if skillSp then
		G_touchedItem(skillSp,realUse,0.8*skillSp:getScale())
	end
end

function planeSkillTreeTab:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 1
	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(self.tvWidth,self.cellHeight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local leftPosX,centerPosX=(self.tvWidth-3*self.spaceX-4*self.nsBgWidth)/2,self.tvWidth/2
		local nsPosY=self.cellHeight
		local fontSize=20
		for k,v in pairs(self.nscfg.tree) do
			local firstPosX=centerPosX
			if (k%2)>0 then
				firstPosX=leftPosX+self.nsBgWidth/2
			end
			for sidx,sid in pairs(v) do
				local shadeBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),function()end)
				shadeBg:setContentSize(CCSizeMake(self.nsBgWidth,self.nsBgHeight))
				shadeBg:setPosition(firstPosX+(sidx-1)*(self.nsBgWidth+self.spaceX),nsPosY-self.nsBgHeight/2)
				cell:addChild(shadeBg)
				local nsBg
				local function touchSkill()
				    if G_checkClickEnable()==false then
			            do
			                return
			            end
			        else
			            base.setWaitTime=G_getCurDeviceMillTime()
			        end
        			if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        				local function realHandler()
							if self:isGermanyHandle(sid) then --德国特殊处理
            					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("achievement_willOpen"),28)
								do return end
							end
							if self.selectSp then --点击去掉选中效果
								self.selectSp:removeFromParentAndCleanup(true)
								self.selectSp,self.jumpSid=nil,nil
							end
	        				require "luascript/script/game/scene/gamedialog/plane/planeSkillStudyDialog"
							planeSkillStudyDialog:showStudyDialog(self.layerNum+1,sid,getlocal("skill_study"),self)
						end
						G_touchedItem(nsBg,realHandler,0.8)
        			end
				end
				nsBg=LuaCCSprite:createWithSpriteFrameName("plane_nspic_bg.png",touchSkill)
				nsBg:setPosition(getCenterPoint(shadeBg))
				nsBg:setTouchPriority(((-(self.layerNum-1)*20-2)))
				shadeBg:addChild(nsBg,3)

				if self.jumpSid and self.jumpSid==sid then --如果该技能被选中，显示选中效果
					local selectSp=LuaCCScale9Sprite:createWithSpriteFrameName("planeSkillSelectBg.png",CCRect(4,4,1,1),function ()end)
					selectSp:setContentSize(CCSizeMake(self.nsBgWidth-4,self.nsBgHeight-4))
					selectSp:setPosition(getCenterPoint(shadeBg))
					shadeBg:addChild(selectSp)
					self.selectSp=selectSp

					--选中技能做缩放效果
					local scaleTo1=CCScaleTo:create(0.1,0.8)
					local scaleTo2=CCScaleTo:create(0.1,1)
					local acArr=CCArray:create()
					acArr:addObject(scaleTo1)
					acArr:addObject(scaleTo2)
					local seq=CCSequence:create(acArr)
					shadeBg:runAction(seq)
				end

				local scale=0.8
				local skillBgPic
				local stype=self.nscfg.skill[sid].type --技能类型
				if stype==0 then --被动技能
					skillBgPic="planePassiveSkillBar.png"
				else --主动技能
					skillBgPic="planeActiveSkillBg.png"
				end
				local skillBg=CCSprite:createWithSpriteFrameName(skillBgPic)
				skillBg:setScale(scale)
				skillBg:setPosition(nsBg:getContentSize().width/2,self.nsBgHeight-70)
				nsBg:addChild(skillBg)

				local skillSp
				if self:isGermanyHandle(sid) then --德国平台戏谑技能特殊处理（不能使用）
					skillSp=CCSprite:createWithSpriteFrameName("planeSkillNull.png")
				else
					local unlockFlag=planeVoApi:isNewSkillUnlock(sid)
					if unlockFlag==false then --未解锁
						skillSp=planeVoApi:getNewSkillIcon(sid,nil,true)
					else
						skillSp=planeVoApi:getNewSkillIcon(sid)
					end
				end
				skillSp:setPosition(getCenterPoint(skillBg))
				skillBg:addChild(skillSp)

				if planeVoApi:isNewSkillStudying(sid) then --正在研究中
					G_addFlicker(skillSp,2.5,2.5,getCenterPoint(skillSp))
				end
				local nameStr
				if G_curPlatName()=="androidsevenga" or G_curPlatName()=="11" then
					-- 德国特殊需求，因为文字爆框严重，去掉技能树上面所有关于技能的说明，仅保留点击之后的技能说明文字
					nameStr = ""
				else
					nameStr=planeVoApi:getNewSkillNameStr(sid)
				end

				-- print("\""..sid.."\"".."=>".."\""..nameStr.."\""..",")
				local nameLb=GetTTFLabelWrap(nameStr,fontSize-2,CCSizeMake(self.nsBgWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
				nameLb:setAnchorPoint(ccp(0.5,0))
				nameLb:setPosition(nsBg:getContentSize().width/2,skillBg:getPositionY()-skillBg:getContentSize().height*scale/2-22)
				nsBg:addChild(nameLb)
				if self:isGermanyHandle(sid)~=true then --德国特殊处理
					local sinfo,maxLv=planeVoApi:getNewSkillInfoById(sid)
					local lv=sinfo.lv or 0
					local scalex,scaley=1,1
			        local scheduleStr=lv.."/"..maxLv
			        local per=(lv/maxLv)*100
			        local barPic="smallGreenBar.png"
			        if lv>=maxLv then
			        	barPic="smallYellowBar.png"
			        end
				    AddProgramTimer(nsBg,ccp(nsBg:getContentSize().width/2,25),11,12,scheduleStr,"smallBarBg.png",barPic,13,scalex,scaley,nil,nil,fontSize-2)
			        local timerSpriteLv=nsBg:getChildByTag(11)
			        timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
			        timerSpriteLv:setPercentage(per)
			        local lb=tolua.cast(timerSpriteLv:getChildByTag(12),"CCLabelTTF")
			        lb:setScaleX(1/scalex)
			        lb:setScaleY(1/scaley)
				end
			end

			--画技能树的线
	        if (k%2)==0 then --主动技能所在行
				local upLineSp=CCSprite:createWithSpriteFrameName("planeSkillTreeLine2.png")
        		upLineSp:setPosition(self.tvWidth/2,nsPosY+self.spaceY/2)
        		cell:addChild(upLineSp,2)
        		if k~=SizeOfTable(self.nscfg.tree) then
					local downLineSp=CCSprite:createWithSpriteFrameName("planeSkillTreeLine2.png")
	        		downLineSp:setPosition(self.tvWidth/2,nsPosY-self.nsBgHeight-self.spaceY/2)
					downLineSp:setFlipY(true)
	        		cell:addChild(downLineSp,2)
        		end
	        else --被动技能所在行
				for i=1,3 do
	        		local lineSp=CCSprite:createWithSpriteFrameName("planeSkillTreeLine1.png")
	        		lineSp:setPosition(leftPosX+i*self.nsBgWidth+(2*i-1)/2*self.spaceX,nsPosY-self.nsBgHeight/2)
	        		cell:addChild(lineSp,2)
	        	end
	        end

			nsPosY=nsPosY-self.nsBgHeight-self.spaceY
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

--刷新技能树
function planeSkillTreeTab:refreshSkillTreeLayer()
	if self.tv then
		local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
	end
	if self.asTb then
		for sid,v in pairs(self.asTb) do
			local function useSkill() --使用技能
				self:useActiveSkill(sid)
			end
			local skillSp=tolua.cast(v[1],"CCSprite")
			local skillPos=ccp(skillSp:getPosition())
			if skillSp then
				skillSp:removeFromParentAndCleanup(true)
				skillSp,self.asTb[sid][1]=nil,nil
	        	self.asUseStateTb[sid]=nil
			end
			local sinfo,maxLv=planeVoApi:getNewSkillInfoById(sid)
			local slv=sinfo.lv or 0
			local lvLb=tolua.cast(v[2],"CCLabelTTF")
			if lvLb then
				lvLb:setString(getlocal("fightLevel",{slv}))
			end
			if slv>0 then
				lvLb:setVisible(true)
				skillSp=planeVoApi:getNewSkillIcon(sid,useSkill)
				skillSp:setTouchPriority(-(self.layerNum-1)*20-5)
			else
				lvLb:setVisible(false)
				skillSp=planeVoApi:getNewSkillIcon(sid,nil,true)
				local lockSp=CCSprite:createWithSpriteFrameName("LockIconCheckPoint.png")
				lockSp:setPosition(getCenterPoint(skillSp))
				skillSp:addChild(lockSp)
				local function goToSkill()
					self:jumpToSkill(sid)
				end
				local touchBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),goToSkill)
				touchBg:setContentSize(skillSp:getContentSize())
				touchBg:setTouchPriority(-(self.layerNum-1)*20-5)
				touchBg:setPosition(getCenterPoint(skillSp))
				touchBg:setOpacity(0)
				skillSp:addChild(touchBg)
			end
			skillSp:setScale(0.8)
			skillSp:setPosition(skillPos)
			self.bgLayer:addChild(skillSp,3)
			self.asTb[sid][1]=skillSp
			self:refreshActiveSkillUseState(sid)
		end
	end
	self:refreshStudyPoint()
end

--刷新指定主动技能的状态
function planeSkillTreeTab:refreshActiveSkillUseState(sid)
	local useFlag,et,cdTime=planeVoApi:getNewActiveSkillUseFlag(sid)
	if self.asTb[sid]==nil then
		do return end
	end
	-- print("sid,useFlag===???",sid,useFlag)
	if useFlag~=0 then --技能正在使用中
		local skillSp=tolua.cast(self.asTb[sid][1],"CCSprite")
		if skillSp==nil then
			do return end
		end
		local fontSize=18
		local useTimerSp,useTimerLb,useStateLb,stateBg
		if self.asUseStateTb[sid]==nil then
			local psSprite=CCSprite:createWithSpriteFrameName("planeActiveSkillBar.png")
			psSprite:setOpacity(255*0.7)
			useTimerSp=CCProgressTimer:create(psSprite)
		    useTimerSp:setType(kCCProgressTimerTypeRadial) --圆形进度条
		    useTimerSp:setReverseProgress(true) --顺时针进度条
		    useTimerSp:setPosition(getCenterPoint(skillSp))
		    skillSp:addChild(useTimerSp)
	        useTimerLb=GetTTFLabel("",fontSize)
	        useTimerLb:setColor(G_LowfiColorRed2)
	        useTimerLb:setScale(1/skillSp:getScale())
		   	skillSp:addChild(useTimerLb,3)
	        useStateLb=GetTTFLabel("",fontSize)
	        useStateLb:setColor(G_HighSATColorGreen)
	        useStateLb:setScale(1/skillSp:getScale())
	        skillSp:addChild(useStateLb,3)
            stateBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")
            stateBg:setOpacity(255*0.8)
		    skillSp:addChild(stateBg,2)
	        self.asUseStateTb[sid]={useTimerSp,useTimerLb,useStateLb,stateBg}
	    else
	    	useTimerSp,useTimerLb,useStateLb,stateBg=tolua.cast(self.asUseStateTb[sid][1],"CCProgressTimer"),tolua.cast(self.asUseStateTb[sid][2],"CCLabelTTF"),tolua.cast(self.asUseStateTb[sid][3],"CCLabelTTF"),tolua.cast(self.asUseStateTb[sid][4],"CCSprite")
		end
		local bgWidth,bgHeight=80,0
		local leftTime=et-base.serverTime
		if leftTime<0 then
			leftTime=0
		end
		local per=(leftTime/cdTime)*100
		-- print("sid,per,leftTime,cdTime",sid,per,leftTime,cdTime)
		if useTimerSp then
	        useTimerSp:setPercentage(per)
		end
        local stateStr
		if useFlag==1 then --生效中
			stateStr=getlocal("into_effect")
		end
		useTimerLb:setString(GetTimeStr(leftTime))
		bgHeight=useTimerLb:getContentSize().height
		if stateStr then
			useStateLb:setString(stateStr)
			useStateLb:setPosition(skillSp:getContentSize().width/2,skillSp:getContentSize().height/2+useStateLb:getContentSize().height/2)
			useTimerLb:setPosition(skillSp:getContentSize().width/2,skillSp:getContentSize().height/2-useTimerLb:getContentSize().height/2)
			bgHeight=bgHeight+useStateLb:getContentSize().height
		else
			useStateLb:setVisible(false)
			useTimerLb:setPosition(getCenterPoint(skillSp))
		end
	    stateBg:setScaleX(bgWidth/stateBg:getContentSize().width)
	    stateBg:setScaleY(bgHeight/stateBg:getContentSize().height)
	    stateBg:setPosition(getCenterPoint(skillSp))
	else --技能未使用状态
		if self.asUseStateTb[sid] then
			local useTimerSp,useTimerLb,useStateLb,stateBg=self.asUseStateTb[sid][1],self.asUseStateTb[sid][2],self.asUseStateTb[sid][3],self.asUseStateTb[sid][4]
			if useTimerSp and tolua.cast(useTimerSp,"CCProgressTimer") then
				useTimerSp:removeFromParentAndCleanup(true)
				useTimerSp=nil
			end
			if useTimerLb and tolua.cast(useTimerLb,"CCLabelTTF") then
				useTimerLb:removeFromParentAndCleanup(true)
				useTimerLb=nil
			end
			if useStateLb and tolua.cast(useStateLb,"CCLabelTTF") then
				useStateLb:removeFromParentAndCleanup(true)
				useStateLb=nil
			end
			if stateBg and tolua.cast(stateBg,"CCSprite") then
				stateBg:removeFromParentAndCleanup(true)
				stateBg=nil
			end
			self.asUseStateTb[sid]=nil
		end
	end
end

--刷新研究值相关（包括道具数量和研究值）
function planeSkillTreeTab:refreshStudyPoint()
	local point,maxPoint,refreshTs=planeVoApi:getStudyPoint()
	if self.studyTimerSp and self.studyTimerLb then
		local per=(point/maxPoint)*100
	    local scheduleStr=point.."/"..maxPoint
	    self.studyTimerSp:setPercentage(per)
	    self.studyTimerLb:setString(scheduleStr)
	end
	if self.studyPropNumLb and self.addPropBtn then
		local ownNum=bagVoApi:getItemNumId(self.studyPid)
		if ownNum>0 then
			self.addPropBtn:setVisible(false)
		else
			self.addPropBtn:setVisible(true)
		end
		self.studyPropNumLb:setString(tostring(ownNum))
	end
	for sid,v in pairs(self.asTb) do
		local skillSp,costLb,studySp=v[1],v[3],v[4]
		if skillSp and tolua.cast(skillSp,"CCSprite") and costLb and tolua.cast(costLb,"CCLabelTTF") and studySp and tolua.cast(studySp,"CCSprite") then
			local sinfo=planeVoApi:getNewSkillInfoById(sid)
			local lvinfo=planeVoApi:getNewSkillCfgByLv(sid,sinfo.lv)
			local cost=0
			if lvinfo and lvinfo.cost then
				cost=lvinfo.cost
			end
			costLb:setString(tostring(cost))
			if point<cost then
				costLb:setColor(G_ColorRed)
			else
				costLb:setColor(G_ColorWhite)
			end
			if cost==0 then
				costLb:setVisible(false)
				studySp:setVisible(false)
			else
				costLb:setVisible(true)
				studySp:setVisible(true)
			end
			local costWidth=costLb:getContentSize().width+25
			costLb:setPositionX(skillSp:getPositionX()-costWidth/2)
			studySp:setPositionX(costLb:getPositionX()+costLb:getContentSize().width+5)
		end
	end
end

--跳转到指定技能的问题
function planeSkillTreeTab:jumpToSkill(sid)
	if self.tv==nil then
		do return end
	end
	self.jumpSid=sid
	local jumpIdx=1
	for layerIdx,layerCfg in pairs(self.nscfg.tree) do
		for k,v in pairs(layerCfg) do
			if tostring(sid)==tostring(v) then --找出要跳转的技能id
				jumpIdx=layerIdx
				do break end
			end
		end
	end
	local minJumpH,maxJumpH=-(self.cellHeight-self.tvHeight),0
	local jumpHeight=jumpIdx*self.nsBgHeight+(jumpIdx-1)*self.spaceY-self.tvHeight+self.nsBgHeight/2
	local recordPoint=self.tv:getRecordPoint()
    recordPoint.y=0-(self.cellHeight-self.tvHeight-jumpHeight)
    if recordPoint.y>maxJumpH then
    	recordPoint.y=maxJumpH
	elseif recordPoint.y<minJumpH then
		recordPoint.y=minJumpH
    end
    self.tv:reloadData()
    self.tv:recoverToRecordPoint(recordPoint)
end

--戏谑技能德国需要特殊处理（不开此技能）
function planeSkillTreeTab:isGermanyHandle(sid)
	if sid and sid=="s20" and (G_curPlatName()=="androidsevenga" or G_curPlatName()=="11") then --德国平台戏谑技能特殊处理（不能使用）
		return true
	end
	return false
end

function planeSkillTreeTab:updateUI()
	
end

function planeSkillTreeTab:tick()
	for k,sid in pairs(self.nscfg.activeSkill) do
		self:refreshActiveSkillUseState(sid)
	end
	local curPoint=planeVoApi:getStudyPoint()
	if self.studyPoint~=curPoint then
		self:refreshStudyPoint()
	end
end

function planeSkillTreeTab:fastTick()
	
end

function planeSkillTreeTab:dispose()
	if self.bgLayer then
		self.bgLayer:removeFromParentAndCleanup(true)
		self.bgLayer=nil
	end
	self.nscfg=nil
	self.tvWidth=nil
	self.tvHeight=nil
	self.cellHeight=nil
	self.isMoved=nil
	self.nsBgWidth=nil
	self.nsBgHeight=nil
	self.spaceX=nil
	self.spaceY=nil
	self.parent=nil
	self.layerNum=nil
	self.asUseStateTb=nil
	self.asTb=nil
	self.studyPid=nil
	self.studyPropNumLb=nil
	self.addPropBtn=nil
	self.studyPoint=nil
	self.jumpSid=nil
	self.selectSp=nil
	self.studySid=nil
	spriteController:removePlist("public/plane/planeSkillTreeImages.plist")
    spriteController:removeTexture("public/plane/planeSkillTreeImages.png")
    spriteController:removePlist("public/squaredImgs.plist")
  	spriteController:removeTexture("public/squaredImgs.png")
  	spriteController:removePlist("public/youhuaUI3.plist")
  	spriteController:removeTexture("public/youhuaUI3.png")
   	spriteController:removePlist("public/youhuaUI4.plist")
   	spriteController:removeTexture("public/youhuaUI4.png")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/plane/planeSkillTreeBg.jpg")
    eventDispatcher:removeEventListener("plane.newskill.refresh",self.refreshListener)
end