powerGuideNewDialog=commonDialog:new()

function powerGuideNewDialog:new(classIndex)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.guidTb = nil--大类集合
	self.cellNum = nil
	self.tv = nil
	self.hadAccessory = nil
	self.classType = classIndex -- 默认弹出的小面板类别

	self.bg = nil
	self.tickIndex = 0
	self.cellInitIndex=0
	self.cellTb={}
	nc.classDataTb={}

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acSdzsImages.plist")
    spriteController:addTexture("public/acSdzsImages.png")
    spriteController:addPlist("public/powerGuideImages.plist")
    spriteController:addTexture("public/powerGuideImages.png")
    spriteController:addPlist("public/resource_youhua.plist")
    spriteController:addTexture("public/resource_youhua.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")

	require "luascript/script/game/gamemodel/player/powerGuideVoApi"
	return nc
end

function powerGuideNewDialog:initTableView()
	local startY=G_VisibleSizeHeight - 85
	self.guidTb = powerGuideVoApi:getClassTb()
    self.cellNum = SizeOfTable(self.guidTb)
    self.cellInitIndex = self.cellNum

	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))

	-- local blackLayer = CCLayerColor:create(ccc4(4,31,43,255))
	-- blackLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-109))
	-- blackLayer:setPosition(ccp(20,22))
	-- self.bgLayer:addChild(blackLayer,1)

    -- for k,v in pairs(self.guidTb) do
    -- 	if v == powerGuideVoApi.CLASS_accessory then
    -- 		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    -- 	end
    -- end

	self.bg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function() end)
	self.bg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, 210))
	self.bg:setIsSallow(false)
	self.bg:setPosition(self.bgLayer:getContentSize().width/2,startY)
	-- self.bg:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bg:setAnchorPoint(ccp(0.5,1))
	self.bgLayer:addChild(self.bg,1)
	self.bg:setOpacity(0)

	local sbBgSp=CCSprite:createWithSpriteFrameName("ac_sdzs_bg.jpg")
	sbBgSp:setAnchorPoint(ccp(0.5,0.5))
	sbBgSp:setPosition(ccp(self.bg:getContentSize().width/2, self.bg:getContentSize().height/2))
	self.bg:addChild(sbBgSp)

	local tvBgPosH=30
	local tvBgH=startY-self.bg:getContentSize().height-tvBgPosH-10
	local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50,50,1,1),function() end)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20,tvBgH))
    tvBg:setAnchorPoint(ccp(0,0))
    -- tvBg:setOpacity(200)
    tvBg:setPosition(ccp(10,tvBgPosH))
    self.bgLayer:addChild(tvBg,1)

    local titleLb = GetTTFLabel(getlocal("powerGuide_classTitle"),24,true)
    -- titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(tvBg:getContentSize().width/2,tvBg:getContentSize().height-40)
    tvBg:addChild(titleLb,1)

    local  titleBg1=LuaCCScale9Sprite:createWithSpriteFrameName("panelTitleBg.png",CCRect(84, 25, 1, 1),function () end)
    tvBg:addChild(titleBg1)
    titleBg1:setPosition(tvBg:getContentSize().width/2,tvBg:getContentSize().height-40)
    titleBg1:setContentSize(CCSizeMake(titleLb:getContentSize().width+150,math.max(titleLb:getContentSize().height,50)))


	local tvX,tvY=25,tvBgPosH+10
	local tvHeight = tvBgH-10-70

	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-tvX*2,tvHeight),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(ccp(tvX,tvY))
	self.tv:setMaxDisToBottomOrTop(110)
	self.bgLayer:addChild(self.tv,8)

	self:initUp()
end

function powerGuideNewDialog:initUp()
	local rankLb=GetTTFLabel(getlocal("youhua_fightRank",{""}),20)
	rankLb:setAnchorPoint(ccp(0,0))
	rankLb:setPosition(ccp(40,12))
	self.bg:addChild(rankLb)

    local rank = powerGuideVoApi:getFcRank()
    local rankStr
    if rank > 0 then
    	rankStr = tostring(rank) 
    else
    	rankStr = getlocal("dimensionalWar_out_of_rank")
    end
	local rankValueLb=GetTTFLabel(rankStr,20)
	rankValueLb:setAnchorPoint(ccp(0,0.5))
	rankValueLb:setPosition(ccp(40 + rankLb:getContentSize().width,12 + rankLb:getContentSize().height/2))
	self.bg:addChild(rankValueLb)
	rankValueLb:setColor(G_ColorYellowPro)

	local function gotoRankDialog()
		G_goToDialog2("rankDialog",self.layerNum+1,false)
	end
	local rankItem=GetButtonItem("mainBtnRank.png","mainBtnRank_Down.png","mainBtnRank_Down.png",gotoRankDialog)
	rankItem:setAnchorPoint(ccp(0.5,0.5))
	rankItem:setScale(1.2)
	local rankBtn=CCMenu:createWithItem(rankItem)
	rankBtn:setTouchPriority(-(self.layerNum-1)*20-5)
	rankBtn:setPosition(ccp(self.bg:getContentSize().width - 75,rankValueLb:getPositionY() + 15))
	self.bg:addChild(rankBtn)

	local power=playerVoApi:getPlayerPower()
	local powerLb=GetTTFLabel(getlocal("world_war_power",{""}),20)
	powerLb:setAnchorPoint(ccp(0,0))
	powerLb:setPosition(ccp(40,16+ rankLb:getContentSize().height))
	self.bg:addChild(powerLb)

	local powerValueLb = GetTTFLabel(power.."（"..FormatNumber(power).."）",20)
	powerValueLb:setAnchorPoint(ccp(0,0.5))
	powerValueLb:setPosition(ccp(40+powerLb:getContentSize().width,powerLb:getPositionY() + powerLb:getContentSize().height/2))
	self.bg:addChild(powerValueLb)
	powerValueLb:setColor(G_ColorYellowPro)

	
	local strSize2 = 24
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
		strSize2 = 24
	end
	local maxPowerDescLb=GetTTFLabel(getlocal("powerGuide_maxPower"),strSize2,true)
	maxPowerDescLb:setPosition(ccp(self.bg:getContentSize().width/2,self.bg:getContentSize().height/2 + 70))
	self.bg:addChild(maxPowerDescLb,1)
	-- maxPowerDescLb:setColor(G_ColorYellowPro)

	local desBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")
	desBg:setPosition(ccp(self.bg:getContentSize().width/2,self.bg:getContentSize().height/2 + 70))
	self.bg:addChild(desBg)
	desBg:setScaleX((maxPowerDescLb:getContentSize().width+20)/desBg:getContentSize().width)
	desBg:setScaleY((maxPowerDescLb:getContentSize().height+10)/desBg:getContentSize().height)
	desBg:setOpacity(180)

	

	local percent=0	
	-- for i=1,self.cellNum do
	-- 	local classData = powerGuideVoApi:getClassContentData(i)
	-- 	percent=percent+classData[3]
	-- end
	-- percent=(percent/self.cellNum) * 100

	-- if(percent>100)then
	-- 	percent=100
	-- end
	local scaleX=1.8
	local scaleY=1.0
	AddProgramTimer(self.bg,ccp(self.bg:getContentSize().width/2,self.bg:getContentSize().height/2 + 20),11,22,string.format("%.2f",percent).."%","res_progressbg.png","resblue_progress.png",33,scaleX,scaleY)
	local bar = tolua.cast(self.bg:getChildByTag(11),"CCProgressTimer")
	bar:setPercentage(percent)

	local barLb = tolua.cast(bar:getChildByTag(22),"CCLabelTTF")
	barLb:setScaleY(1/scaleY)
	barLb:setScaleX(1/scaleX)
end

function powerGuideNewDialog:refreshUp()
	local bar = tolua.cast(self.bg:getChildByTag(11),"CCProgressTimer")
	local barLb = tolua.cast(bar:getChildByTag(22),"CCLabelTTF")
	if bar and barLb then
		local percent=0	
	
		for k,v in pairs(self.classDataTb) do
			local classData = v
			percent=percent+classData[3]
		end
		-- for i=1,self.cellNum do
		-- 	local classData = powerGuideVoApi:getClassContentData(i)
		-- 	percent=percent+classData[3]
		-- end
		percent=(percent/self.cellNum) * 100

		if(percent>100)then
			percent=100
		end
		local function setBarPercent()
			local nowPer=bar:getPercentage() or 0
			if nowPer+1<percent then
				bar:setPercentage(nowPer+1)
				barLb:setString(string.format("%.2f",nowPer+1).."%")
				local delay=CCDelayTime:create(0.02)
				local function callback1()
					setBarPercent()
				end
				local fc= CCCallFunc:create(callback1)
				local acArr=CCArray:create()
				acArr:addObject(delay)
				acArr:addObject(fc)
				local seq=CCSequence:create(acArr)
				self.bgLayer:runAction(seq)
			else
				bar:setPercentage(percent)
				barLb:setString(string.format("%.2f",percent).."%")
			end
		end
		setBarPercent()
	end
	
end


function powerGuideNewDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return math.ceil(self.cellNum/3)
	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(G_VisibleSizeWidth-50,230)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local classIndex = 0
		
		local function showDetailPanel(tag,object)
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				self:showSmallDialog(self.guidTb[tag])
			end
		end
		local singW = (G_VisibleSizeWidth-50)/3
		local cellH = 230
		local theX
		for i=1,3 do
			classIndex = idx * 3 + i
			if classIndex <= self.cellNum then
				local classData = powerGuideVoApi:getClassContentData(self.guidTb[classIndex],false)
				if classData then
					theX = singW * i - singW * 0.5

					local selectN = CCSprite:createWithSpriteFrameName("powerGuide_classBg.png")
				    local selectS = CCSprite:createWithSpriteFrameName("powerGuide_classSelectedBg.png")
				    local selectD = GraySprite:createWithSpriteFrameName("powerGuide_classSelectedBg.png")

				    local classIconN = CCSprite:createWithSpriteFrameName("powerGuide_icon"..classIndex.."_0.png")--classData[2]
					classIconN:setAnchorPoint(ccp(0.5,0.5))
					classIconN:setPosition(ccp(selectN:getContentSize().width/2,selectN:getContentSize().height/2 - 6))
					selectN:addChild(classIconN,2)


					local classIconS = CCSprite:createWithSpriteFrameName("powerGuide_icon"..classIndex.."_1.png")--classData[2]
					classIconS:setAnchorPoint(ccp(0.5,0.5))
					classIconS:setPosition(ccp(selectS:getContentSize().width/2,selectS:getContentSize().height/2 - 6))
					selectS:addChild(classIconS,2)

				    local itemBg = CCMenuItemSprite:create(selectN,selectS,selectD)
				    itemBg:setAnchorPoint(ccp(0.5,0.5))
				    itemBg:registerScriptTapHandler(showDetailPanel)
				    itemBg:setTag(classIndex)

					local itemMenu=CCMenu:createWithItem(itemBg)
					
					itemMenu:setTouchPriority(-(self.layerNum-1)*20-2)
					itemMenu:setPosition(ccp(theX, cellH/2))
					cell:addChild(itemMenu,1)

					local testLb,strWidth2,lbPos = GetTTFLabel(classData[1],20),20,18
					if testLb:getContentSize().width > 160 then
						strWidth2 = 21
						lbPos = 24
					end

					local titleLb=GetTTFLabelWrap(classData[1],strWidth2,CCSizeMake(160,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
					titleLb:setAnchorPoint(ccp(0.5,0.5))
					titleLb:setPosition(ccp(itemBg:getContentSize().width/2,itemBg:getContentSize().height - lbPos))
					itemBg:addChild(titleLb)

					local sbIndex=self.guidTb[classIndex]
					local playerLv=playerVoApi:getPlayerLevel()
					local function sbFunc(sblevel)
						itemBg:setEnabled(false)

						local classIconN = GraySprite:createWithSpriteFrameName("powerGuide_icon"..classIndex.."_0.png")--classData[2]
						classIconN:setAnchorPoint(ccp(0.5,0.5))
						classIconN:setPosition(ccp(selectD:getContentSize().width/2,selectD:getContentSize().height/2 - 6))
						selectD:addChild(classIconN,2)

						local lockLb = GetTTFLabel(getlocal("alliance_unlock_str2",{sblevel}),20)
						lockLb:setAnchorPoint(ccp(0.5,0.5))
						lockLb:setPosition(ccp(theX,itemMenu:getPositionY()- itemBg:getContentSize().height/2 + 15))
						lockLb:setColor(G_ColorYellow)
						cell:addChild(lockLb,3)
					end
					local flag=false
					local lockLevel=0
					if sbIndex==powerGuideVoApi.CLASS_armor then
						local limitLv = armorMatrixVoApi:getPermitLevel()
						if playerLv<limitLv then
							flag=true
							lockLevel=limitLv
						end
					elseif sbIndex==powerGuideVoApi.CLASS_accessory then
						if playerLv<8 then
							flag=true
							lockLevel=8
						end
					elseif sbIndex==powerGuideVoApi.CLASS_hero then
						if playerLv<20 then
							flag=true
							lockLevel=20
						end
					elseif sbIndex==powerGuideVoApi.CLASS_alienweapon then
						local superWeaponOpenLv=base.superWeaponOpenLv or 25
						if playerLv<superWeaponOpenLv then
							flag=true
							lockLevel=superWeaponOpenLv
						end
					elseif sbIndex==powerGuideVoApi.CLASS_alientech then
						if playerLv<alienTechCfg.openlevel then
							flag=true
							lockLevel=alienTechCfg.openlevel
						end
					elseif sbIndex==powerGuideVoApi.CLASS_superequip then
						local permitLevel = emblemVoApi:getPermitLevel()
						if playerLv<permitLevel then
							flag=true
							lockLevel=permitLevel
						end
					elseif sbIndex==powerGuideVoApi.CLASS_plane then
						local permitLevel = planeVoApi:getOpenLevel()
						if playerLv<permitLevel then
							flag=true
							lockLevel=permitLevel
						end
					end
					if flag then
						sbFunc(lockLevel)
						return cell
					end

					
					local percent = classData[3] * 100
					AddProgramTimer(selectN,ccp(-1+selectN:getContentSize().width/2,-9+selectN:getContentSize().height/2),10+classIndex,nil,nil,"powerGuide_barBig.png","powerGuide_barBig.png",20+classIndex,nil,nil,nil,ccp(0, 1),nil,nil,1)
					local barN = tolua.cast(selectN:getChildByTag(10+classIndex),"CCProgressTimer")
					barN:setPercentage(percent)
					barN:setRotation(-180)

					local barBgN = tolua.cast(selectN:getChildByTag(20+classIndex),"CCSprite")
					barBgN:setRotation(-180)
					barBgN:setOpacity(0)

					AddProgramTimer(selectS,ccp(-1+selectS:getContentSize().width/2,-9+selectS:getContentSize().height/2),10+classIndex,nil,nil,"powerGuide_barBig.png","powerGuide_barBig.png",20+classIndex,nil,nil,nil,ccp(0, 1),nil,nil,1)
					local barS = tolua.cast(selectS:getChildByTag(10+classIndex),"CCProgressTimer")
					barS:setPercentage(percent)
					barS:setRotation(-180)

					local barBgS = tolua.cast(selectS:getChildByTag(20+classIndex),"CCSprite")
					barBgS:setRotation(-180)
					barBgS:setOpacity(0)

					local perLb = GetTTFLabel(string.format("%.2f",percent).."%",20)
					perLb:setAnchorPoint(ccp(0.5,0.5))
					perLb:setPosition(ccp(theX,itemMenu:getPositionY()- itemBg:getContentSize().height/2 + 15))
					perLb:setColor(G_ColorYellow)
					cell:addChild(perLb,3)

					self.cellTb[classIndex]={barN,barS,perLb}
				end
			end
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

function powerGuideNewDialog:refreshCellTb(classIndex)
	local tb = self.cellTb[classIndex]
	if tb then
		local classData = powerGuideVoApi:getClassContentData(self.guidTb[classIndex])
		self.classDataTb[classIndex]=classData
		if classData then
			local percent = classData[3] * 100
			local barN = tolua.cast(tb[1],"CCProgressTimer")
			local barS = tolua.cast(tb[2],"CCProgressTimer")
			local perLb = tolua.cast(tb[3],"CCLabelTTF")
			-- local loadingBgSp = tolua.cast(tb[4],"CCSprite")
			if barN and barS and perLb then
				local function setBarPercent()
					local nowPer=barN:getPercentage() or 0
					if nowPer+1<percent then
						barN:setPercentage(nowPer+1)
						barS:setPercentage(nowPer+1)
						perLb:setString(string.format("%.2f",nowPer+1).."%")
						local delay=CCDelayTime:create(0.02)
						local function callback1()
							setBarPercent()
						end
						local fc= CCCallFunc:create(callback1)
						local acArr=CCArray:create()
						acArr:addObject(delay)
						acArr:addObject(fc)
						local seq=CCSequence:create(acArr)
						self.bgLayer:runAction(seq)
					else
						barN:setPercentage(percent)
						barS:setPercentage(percent)
						perLb:setString(string.format("%.2f",percent).."%")
					end
				end
				setBarPercent()
			end
			-- if loadingBgSp then
			-- 	loadingBgSp:stopAllActions()
			-- 	loadingBgSp:removeFromParentAndCleanup(true)
			-- 	loadingBgSp = nil
			-- end
			self.cellTb[classIndex] = nil
		end
	end
end

function powerGuideNewDialog:fastTick()
	self.tickIndex=self.tickIndex+1
	if(self.tickIndex%5==0)then
		self:refreshCellTb(self.cellInitIndex)
		self.cellInitIndex=self.cellInitIndex-1
		-- self:refreshUp()
	end
	if(self.cellInitIndex==0)then
		self:refreshUp()
		base:removeFromNeedRefresh(self)
	end
end

function powerGuideNewDialog:showSmallDialog(classIndex)
	local function gotoFun(class,index)
		self:redirect(class,index)
	end
	powerGuideVoApi:showDetailPanel(classIndex,gotoFun,self.layerNum+1)
end


function powerGuideNewDialog:redirect(classIndex,idx)
	self:close()
	if classIndex == powerGuideVoApi.CLASS_player then--角色
		if(idx==1)then--统率等级
           local td=playerVoApi:showPlayerDialog(1,self.layerNum)
		elseif(idx==2)then--技能等级
            local td=playerVoApi:showPlayerDialog(2,self.layerNum)
	        td:tabClick(1)
		elseif(idx==3)then--科技等级
			local buildVo=buildingVoApi:getBuildiingVoByBId(3)
			require "luascript/script/game/scene/gamedialog/portbuilding/techCenterDialog"
            local td=techCenterDialog:new(3,self.layerNum,true)
			local bName=getlocal(buildingCfg[8].buildName)
			local tbArr={getlocal("building"),getlocal("startResearch")}
			local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildVo.level..")",true,self.layerNum)
			sceneGame:addChild(dialog,self.layerNum)
			td:tabClick(1)
		elseif(idx==4)then--军团科技等级
            require "luascript/script/game/scene/gamedialog/allianceDialog/allianceSkillDialog"
			local td=allianceSkillDialog:new(self.layerNum)
			local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("alliance_technology"),true,self.layerNum)
			sceneGame:addChild(dialog,self.layerNum)
		elseif(idx==5)then--兵种强度
			local buildVo=buildingVoApi:getBuildiingVoByBId(11)
			require "luascript/script/game/scene/gamedialog/portbuilding/tankFactoryDialog"
            local td=tankFactoryDialog:new(11,self.layerNum)
			local bName=getlocal(buildingCfg[6].buildName)
			local tbArr={getlocal("buildingTab"),getlocal("startProduce"),getlocal("chuanwu_scene_process")}
			local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildVo.level..")",true,self.layerNum)
			td:tabClick(1)
			sceneGame:addChild(dialog,self.layerNum)
		elseif(idx==6)then--出战部队满编
			local buildVo=buildingVoApi:getBuildiingVoByBId(11)
			require "luascript/script/game/scene/gamedialog/portbuilding/tankFactoryDialog"
            local td=tankFactoryDialog:new(11,self.layerNum)
			local bName=getlocal(buildingCfg[6].buildName)
			local tbArr={getlocal("buildingTab"),getlocal("startProduce"),getlocal("chuanwu_scene_process")}
			local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildVo.level..")",true,self.layerNum)
			td:tabClick(1)
			sceneGame:addChild(dialog,self.layerNum)
		elseif(idx==7)then--个人繁荣度
			local td=playerVoApi:showPlayerDialog(3,self.layerNum)
	        td:tabClick(2)
		end
	elseif classIndex == powerGuideVoApi.CLASS_armor then--海兵方阵(海兵方阵品质/海兵方阵强化等级)
		G_goToDialog2("armor",4,true)
	elseif classIndex == powerGuideVoApi.CLASS_accessory then--配件
		if(idx==1 or idx==3 or idx==4 or idx==5 )then--已装配件品质
			accessoryVoApi:showAccessoryDialog(sceneGame,self.layerNum)
		elseif(idx==2)then--配件强化等级
			local canUpgrade=powerGuideVoApi:checkCanUpgrade()
			if(canUpgrade==2)then
                local td=shopVoApi:showPropDialog(self.layerNum,true,1)
				--td:tabClick(1,false)
			elseif(canUpgrade==0)then
				accessoryVoApi:showAccessoryDialog(sceneGame,self.layerNum)
			end
		end
	elseif classIndex == powerGuideVoApi.CLASS_hero then--将领
		if(idx==4)then--将领装备强度
			G_goToDialog("hu",4,true)
		elseif idx== 5 then --将领副官
			G_goToDialog2("heroAdjutant",4,true)
		else--将领品质/将领等级/将领技能等级
			G_goToDialog2("heroM",4,true)
		end
	elseif classIndex == powerGuideVoApi.CLASS_alienweapon then-- 超级武器
		if idx==1 or idx==2 then
			G_goToDialog2("superWeapon",4,true)
		else
			G_goToDialog2("crystal",4,true)
		end
	elseif classIndex == powerGuideVoApi.CLASS_alientech then--异星科技
		-- if((idx==1)or(idx==2))then--常规军舰/特战军舰
			G_goToDialog2("alien",4,true)
		-- end
	elseif classIndex == powerGuideVoApi.CLASS_superequip then--超级装备
		emblemVoApi:showMainDialog(4)
	elseif classIndex == powerGuideVoApi.CLASS_plane then--空战指挥所
		if idx==1 then
			planeVoApi:showMainDialog(4,1)
		elseif idx == 3 then
			planeVoApi:showMainDialog(4)
			planeRefitVoApi:showMainDialog(4 + 1)
		else
			PlayEffect(audioCfg.mouseClick)
			planeVoApi:showMainDialog(4)
		end
	elseif classIndex == powerGuideVoApi.CLASS_strategy then--战略中心
		strategyCenterVoApi:showMainDialog(self.layerNum)
	elseif classIndex == powerGuideVoApi.CLASS_airship then --战争飞艇
		airShipVoApi:showMainDialog(self.layerNum)
	end
end

-- 此方法仅用于延迟弹小面板，修改需谨慎，此方法在大面板出现的动画结束之后会调用一次
function powerGuideNewDialog:getDataByType()
	if self.classType~=nil then
		self:showSmallDialog(self.classType)
		self.classType = nil
	end
end

function powerGuideNewDialog:doUserHandler()
	-- 蓝底背景
    local function addBlueBg()
        local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
        blueBg:setAnchorPoint(ccp(0.5,0))
        -- blueBg:setScaleX(600/blueBg:getContentSize().width)
        blueBg:setScaleY((G_VisibleSizeHeight-110)/blueBg:getContentSize().height)
        blueBg:setPosition(G_VisibleSizeWidth/2,20)
        blueBg:setOpacity(200)
        -- blueBg:setAnchorPoint(ccp(0,0))
        -- blueBg:setPosition(ccp(0,0))
        self.bgLayer:addChild(blueBg)
    end
    G_addResource8888(addBlueBg)
end



function powerGuideNewDialog:dispose()
    powerGuideVoApi:clear()
	-- if self.hadAccessory == true then
	-- 	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("boatImage/pressedPkg/accessoryImage.plist")
	--     CCTextureCache:sharedTextureCache():removeTextureForKey("boatImage/pressedPkg/accessoryImage.png")
 --    end
    
    self.hadAccessory = nil
	self.guidTb = nil--大类集合
	self.cellNum = nil
	self.tv = nil
	self.classType = nil
	self.bg = nil
	self.tickIndex = nil
	self.cellInitIndex=nil
	self.cellTb=nil
	spriteController:removePlist("public/acSdzsImages.plist")
    spriteController:removeTexture("public/acSdzsImages.png")
    spriteController:removePlist("public/powerGuideImages.plist")
    spriteController:removeTexture("public/powerGuideImages.png")
    spriteController:removePlist("public/resource_youhua.plist")
    spriteController:removeTexture("public/resource_youhua.png")
end