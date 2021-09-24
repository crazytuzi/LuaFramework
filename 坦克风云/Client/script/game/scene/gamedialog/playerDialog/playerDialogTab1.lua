playerDialogTab1={

}

function playerDialogTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	
	self.tv=nil;
	self.bgLayer=nil;
	self.tableCell1={};
	self.layerNum=nil;
	self.enTime=nil;
	self.enTimeCount=nil;
	self.rankmenuItem1=nil;
	self.troopsMenuItem1=nil;
	self.m_rankPlayer=nil;
	self.m_gloryPlayer=nil;
	self.curLevel=playerVoApi:getPlayerLevel()
	self.isGuide=nil;
	self.tenCountsLb=nil
	self.isBuyingTime=nil
	self.btn = nil
	return nc;
end

function playerDialogTab1:init(layerNum,isGuide,taskVo)
	self.isGuide=isGuide;
	self.taskVo=taskVo
	
	self.enTime = playerVoApi:getEnergyRecoverLeftTime() --下一次刷新能量点时间

	self.tickFlag=false
	self.bgLayer=CCLayer:create();
	self.layerNum=layerNum;
    local function realShow()
    	if self.bgLayer==nil or tolua.cast(self.bgLayer,"CCLayer")==nil then
    		do return end
    	end
		-- 个人信息面板的带兵量不包含军徽的加成，所以清空临时的军徽
		if base.emblemSwitch==1 then
			emblemVoApi:setTmpEquip(nil)
		end
		self:initTableView();
		
		eventDispatcher:addEventListener("user.power.change",self.onUserPowerChange)

		if newGuidMgr:isNewGuiding() and newGuidMgr.curStep==36 then
			local stepId=newGuidCfg[newGuidMgr.curStep].toStepId
			if stepId and self.guideItem then
				newGuidMgr:setGuideStepField(stepId,self.guideItem)
			end
		end
		self.tickFlag=true
    end
    achievementVoApi:getAvtsData(realShow)
	return self.bgLayer
end


function playerDialogTab1:initTableView()
	-- local dataKey="playerTab1TimeNow@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)-- upperTen_small
	-- local timeNow = tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))
	-- if timeNow ==nil then
	-- 	timeNow=G_getWeeTs(base.serverTime)
	-- end

	-- 添加监听事件
	local function playerIconChange(event,data)
        self:playerIconChange(data)
    end
    self.playerIconChangeListener=playerIconChange
    eventDispatcher:addEventListener("playerIcon.Change",playerIconChange)
    

    self.cellNum=4
    if achievementVoApi:isOpen()~=0 then --成就系统开放
    	self.cellNum=self.cellNum+1
    end

    self.cellWidth=616
	local function callBack(...)
	   return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	local height=0;
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.cellWidth,G_VisibleSize.height-85-110),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(ccp((G_VisibleSize.width-self.cellWidth)/2,30))
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(120)

	local function refresh(event,data)
        self:refresh(data)
    end
    self.refreshListener=refresh
    eventDispatcher:addEventListener("player.dialogtab1.refresh",refresh)

    if base.reNameSwitch==1 then
		local function onUserNameChanged(event,data)
			self:refresh() --更新玩家昵称显示
		end
		self.nameChangeListener = onUserNameChanged
		eventDispatcher:addEventListener("user.name.change",onUserNameChanged)
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function playerDialogTab1:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.cellNum
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		if idx==0 then
			tmpSize=CCSizeMake(self.cellWidth,250)
		else
			tmpSize=CCSizeMake(self.cellWidth,120)
		end
		return tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local function cellClick(hd,fn,idx)
		end
		local hei=0
		local panelItemPic,capInSet
		if idx==0 then
			hei=250-5
			panelItemPic,capInSet="newItemKuang.png",CCRect(15,15,2,2)
		else
			hei=120-5
			panelItemPic,capInSet="newKuang2.png",CCRect(7,7,1,1)
		end
		local subTopHeight = 10
		local subBottomHeight = 105
		local subMiddleHeight = 60
		local btnWidthAdd = 10

		local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName(panelItemPic,capInSet,cellClick)
		backSprie:setContentSize(CCSizeMake(self.cellWidth, hei))
		backSprie:ignoreAnchorPointForPosition(false);
		backSprie:setAnchorPoint(ccp(0,0));
		backSprie:setTag(1000+idx)
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		cell:addChild(backSprie,1)
		self.tableCell1[idx+1]=cell
        
        local cell0StrNum2Width=204
        local cell1StrNum1width=250
        local cell1StrNum2Width=250
        local cell3Str2Width=26
        if G_getCurChoseLanguage() =="ru" then
            cell0StrNum2Width =self.bgLayer:getContentSize().width*0.6+30
            cell1StrNum1width =330
            cell1StrNum2Width =330
            cell3Str2Width =20
        end

		if idx==0 then
			local wd=150
			local nameLb = GetTTFLabel(playerVoApi:getPlayerName(),24,true);
			nameLb:setAnchorPoint(ccp(0,0.5));
			nameLb:setPosition(ccp(wd,210));
			cell:addChild(nameLb,2);
			nameLb:setColor(G_ColorYellowPro)

			if base.reNameSwitch == 1 then --改名卡功能
				local function changeNameHandler()
					if GM_UidCfg and GM_UidCfg[playerVoApi:getUid()] == 1 then
			        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("changenameTip_Gm"),30)
			        else
			        	local cdTime = playerVoApi:getChangeNameCD()
			        	if cdTime > 0 then
			                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("changenameTip_timeLimit",{GetTimeForItemStrState(cdTime)}),30)
					    else
					    	require "luascript/script/game/scene/gamedialog/mergerServersChangeNameDialog"
			        		mergerServersChangeNameDialog:create(self.layerNum+1,getlocal("player_changeName"),getlocal("changenameTip_tip"),1,nil,true)
					    end
			        end
				end
				G_createBotton(cell,ccp(nameLb:getPositionX()+nameLb:getContentSize().width+10,nameLb:getPositionY()),nil,"changeNameBtn.png","changeNameBtn_Down.png","changeNameBtn.png",changeNameHandler,0.8,-(self.layerNum-1)*20-2,2,nil,ccp(0,0.5))
			end
			
			local levelLb = GetTTFLabel(getlocal("fightLevel",{playerVoApi:getPlayerLevel()}),20);
			levelLb:setAnchorPoint(ccp(0,0.5));
			levelLb:setPosition(ccp(wd,180));
			levelLb:setTag(20)
			cell:addChild(levelLb,2);
            

			local powerLb=GetTTFLabel(getlocal("showAttackRank")..":",20)
			powerLb:setAnchorPoint(ccp(0,0.5))
			powerLb:setPosition(ccp(wd,150))
			cell:addChild(powerLb,2)

			local troopWidthPos = 0
			-- if G_getCurChoseLanguage() =="vi" then
			-- 	troopWidthPos =30
			-- end

			local powerStr = G_countDigit(playerVoApi:getPlayerPower())

			local powerLbCount=GetTTFLabel(powerStr,20)
			powerLbCount:setTag(518)
			powerLbCount:setAnchorPoint(ccp(0,0.5))
			powerLbCount:setPosition(ccp(224+troopWidthPos,150))
			cell:addChild(powerLbCount,2)
			
			local troopsLb = GetTTFLabel(getlocal("player_leader_troop_num",{""}),G_getCurChoseLanguage() == "ru" and 16 or 20);
			troopsLb:setAnchorPoint(ccp(0,0.5));
			troopsLb:setPosition(ccp(wd,120));
			cell:addChild(troopsLb,2);
			
			local troopsNumLb = GetTTFLabel(playerVoApi:getTotalTroops(),20);
			troopsNumLb:setTag(519)
			troopsNumLb:setAnchorPoint(ccp(0,0.5));
			troopsNumLb:setPosition(ccp(troopsLb:getPositionX() +troopsLb:getContentSize().width,120));
			cell:addChild(troopsNumLb,2);

			local ownAddTroopNums=playerVoApi:getAddTroops()
			local addTroopNums= GetTTFLabel("("..playerVoApi:getTroopsLvNum().."+"..ownAddTroopNums..")",20)
			addTroopNums:setColor(G_ColorGreen)
			addTroopNums:setAnchorPoint(ccp(0,0.5))
			addTroopNums:setPosition(ccp(troopsNumLb:getPositionX()+troopsNumLb:getContentSize().width+2,120))
			-- if G_getCurChoseLanguage() == "ru" then
			-- 	addTroopNums:setAnchorPoint(ccp(1,0))
			-- 	addTroopNums:setPosition(ccp(backSprie:getContentSize().width-5,hei*0.5+20))
			-- end
			cell:addChild(addTroopNums,2)
			addTroopNums:setTag(133)

			--glory 缺真实数据
			local function showAddCall( )
				local sd=gloryInPlayerLabel:new(4,2)
		        local dialog= sd:init(nil)
			end 
			local addPosY2 = 30
			if G_getCurChoseLanguage() =="ru" then
				addPosY2 = 40
			end
			local addTroopBtn = LuaCCScale9Sprite:createWithSpriteFrameName("picked_icon2.png",CCRect(2, 2, 1, 1),showAddCall)
			addTroopBtn:setAnchorPoint(ccp(1,0.5))
			addTroopBtn:setTouchPriority(-(self.layerNum-1)*20-3)
			addTroopBtn:setPosition(ccp(backSprie:getContentSize().width-20,hei*0.5+addPosY2))
			cell:addChild(addTroopBtn,2)
			local strSize3 = G_getCurChoseLanguage() == "de" and 15 or 20
			if G_getCurChoseLanguage() ~="ru" then
				local addTroopBtnLabel = GetTTFLabel(getlocal("haveTroopNumsStr"),strSize3)
				addTroopBtnLabel:setAnchorPoint(ccp(0.5,1))
				addTroopBtnLabel:setPosition(addTroopBtn:getPositionX()-addTroopBtn:getContentSize().width/2,addTroopBtn:getPositionY()-addTroopBtn:getContentSize().height/2)
				cell:addChild(addTroopBtnLabel,2)
			end

			local lineSP=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine4.png",CCRect(2,1,1,1),function ()end)
			lineSP:setContentSize(CCSizeMake(self.cellWidth-160,lineSP:getContentSize().height))
			lineSP:setAnchorPoint(ccp(0,0.5))
			lineSP:setPosition(ccp(troopsLb:getPositionX(),hei/2 - 25))
			backSprie:addChild(lineSP,1)

			local function showIndividuationDialog()
				if self.tv:getIsScrolled()==true then
					do return end
				end
				PlayEffect(audioCfg.mouseClick)
				playerVoApi:showPlayerCustomDialog(self.layerNum)
			end
			local strSize2 = G_getCurChoseLanguage() == "de" and 18 or 22
			strSize2 = G_getCurChoseLanguage() == "ru" and 15 or strSize2
			local tipItem = GetButtonItem("HeaderBg.png","HeaderBg.png","HeaderBg.png",showIndividuationDialog,11,getlocal("individuation"),strSize2,11)
			local tipLb = tolua.cast(tipItem:getChildByTag(11),"CCLabelTTF")
			tipLb:setFontName("Helvetica-bold")
			tipItem:setScale(0.8)
			tipItem:setScaleY(1.2)
			tipLb:setScaleY(1/1.2*0.8)
			tipLb:setPositionX(tipLb:getPositionX()-10)

			local tipMenu = CCMenu:createWithItem(tipItem)
			tipMenu:setPosition(ccp(70,50))
			tipMenu:setTouchPriority(-(self.layerNum-1)*20-2)
			if playerVoApi:getSwichOfGXH() then
				cell:addChild(tipMenu,1)
			else
				
			end
			

			
			
			local energyLb = GetTTFLabel(getlocal("energy"),20);
			energyLb:setAnchorPoint(ccp(0,0.5));
			energyLb:setPosition(ccp(150,30));
			cell:addChild(energyLb,2);

			local experienceLb = GetTTFLabel(getlocal("sample_general_exp"),20);
			experienceLb:setAnchorPoint(ccp(0,0.5));
			experienceLb:setPosition(ccp(150,70));
			cell:addChild(experienceLb,2);
			
			local personPhotoName=playerVoApi:getPersonPhotoName()
			local photoSp = playerVoApi:GetPlayerBgIcon(personPhotoName,nil,nil,nil,nil,playerVoApi:getHfid());
			photoSp:setScale(1/0.7);
			photoSp:setAnchorPoint(ccp(0,0.5));
			photoSp:setPosition(ccp(10,160));
			self.photoSp=photoSp
			cell:addChild(photoSp,2);
			local lvPer= playerVoApi:getLvPercent()
			local lvExp,lvMaxExp = playerVoApi:getLvExp()
			AddProgramTimer(cell,ccp(340,70),21,22,lvExp.."/"..lvMaxExp,"AllBarBg.png","AllXpBar.png",23,nil,nil,nil,nil,20)
			local timerSpriteLv = cell:getChildByTag(21);
			timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
			timerSpriteLv:setPercentage(playerVoApi:getLvPercent());

			
	
				
			local energyStr;
			local maxEnergy = checkPointVoApi:getMaxEnergy()
			if playerVoApi:getEnergy()<maxEnergy then
				energyStr = playerVoApi:getEnergy().."/"..maxEnergy.."("..GetTimeStr(self.enTime)..")"
			else
				energyStr = playerVoApi:getEnergy().."/"..maxEnergy
			end

			AddProgramTimer(cell,ccp(340,30),24,25,energyStr,"AllBarBg.png","AllEnergyBar.png",26,nil,nil,nil,nil,20)
			local timerSpriteEnergy = cell:getChildByTag(24);
			timerSpriteEnergy=tolua.cast(timerSpriteEnergy,"CCProgressTimer")
			timerSpriteEnergy:setPercentage(playerVoApi:getEnergyPercent()*100);
			if G_isToday(base.daily_buy_energy.ts)==false then
				base.daily_buy_energy.num=0
			end

			--弹出添加能量的板子
			local function addEnergy()
				if self.tv:getIsScrolled()==true then
					do return end
				end
				PlayEffect(audioCfg.mouseClick)
				G_buyEnergy(self.layerNum)
			end

			local menuItem = GetButtonItem("yh_BtnUp.png","yh_BtnUp_Down.png","yh_BtnUp_Down.png",addEnergy,10,nil,nil)
			local menuAddEnergy = CCMenu:createWithItem(menuItem);
			menuAddEnergy:setTouchPriority(-(self.layerNum-1)*20-2);
			menuItem:setScale(0.8)
			menuAddEnergy:setPosition(ccp(510+20,30));
			cell:addChild(menuAddEnergy,3);
			--
							
		elseif idx==1 then
			if self.taskVo and self.taskVo.group and tonumber(self.taskVo.group)==5 then
				local lightBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBgSelect.png",capInSet,cellClick)
				lightBgSp:setContentSize(backSprie:getContentSize())
				lightBgSp:ignoreAnchorPointForPosition(false)
				lightBgSp:setAnchorPoint(ccp(0,0))
				lightBgSp:setIsSallow(false)
				lightBgSp:setOpacity(0)
				lightBgSp:setTouchPriority(-(self.layerNum-1)*20-1)
				cell:addChild(lightBgSp,1)
				local function playBlinkEffect()
					local fadeIn=CCFadeIn:create(0.5)
					local fadeOut=CCFadeOut:create(0.5)
		            local seq=CCSequence:createWithTwoActions(fadeIn,fadeOut)
            		lightBgSp:runAction(CCRepeatForever:create(seq))
				end
				local function removeBlinkEffect()
					if lightBgSp then
						lightBgSp:removeFromParentAndCleanup(true)
						lightBgSp=nil
					end
				end
				guideTipMgr:setCallBackFunc(playBlinkEffect,removeBlinkEffect)
			end
	
			self.m_rankPlayer=playerVoApi:getRank();
			local rankStr=playerVoApi:getRankIconName()
			local photoSp = GetBgIcon(rankStr);
			photoSp:setTag(50);
			photoSp:setScale(1/0.8);
			photoSp:setAnchorPoint(ccp(0,0.5));
			photoSp:setPosition(ccp(10,hei / 2));
			cell:addChild(photoSp,2);

			local nameLb = GetTTFLabel(playerVoApi:getRankName(),24,true);
			nameLb:setAnchorPoint(ccp(0,1));
			nameLb:setPosition(ccp(120,hei - subTopHeight));
			nameLb:setTag(1)
			cell:addChild(nameLb,2);

			local pointDescLb = GetTTFLabel(getlocal("military_rank_battlePoint"),20)
			pointDescLb:setAnchorPoint(ccp(0,0.5))
			pointDescLb:setPosition(ccp(120,hei - subMiddleHeight))
			cell:addChild(pointDescLb,2)

			local pointLb=GetTTFLabel(FormatNumber(playerVoApi:getRankPoint()-playerVoApi:getTodayRankPoint()),20)
			pointLb:setAnchorPoint(ccp(0,0.5))
			pointLb:setPosition(ccp(cell1StrNum1width,hei - subMiddleHeight))
			pointLb:setTag(2)
			cell:addChild(pointLb,2)

			local troopsDescLb=GetTTFLabel(getlocal("military_rank_troopLeader")..":",20)
			troopsDescLb:setAnchorPoint(ccp(0,0))
			troopsDescLb:setPosition(ccp(120,hei - subBottomHeight))
			cell:addChild(troopsDescLb,2)

			local troopsLb=GetTTFLabel(playerVoApi:getRankTroops(),20)
			troopsLb:setAnchorPoint(ccp(0,0))
			troopsLb:setPosition(ccp(cell1StrNum2Width,hei - subBottomHeight))
			troopsLb:setTag(3)
			cell:addChild(troopsLb,2)

			-- local function showRank()
			-- 	if playerVoApi.rankIsOpen==1 then
			-- 		local function callback(fn,data)
			-- 			local ret,sData=base:checkServerData(data)
			-- 			if ret==true then
			-- 				if sData and sData.ranklist then
			-- 					playerVoApi.rankList=sData.ranklist
			-- 					require "luascript/script/game/scene/gamedialog/playerDialog/medalsRankDialog"
			-- 					local td=medalsRankDialog:new()
			-- 					local tbArr={}
			-- 					local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("medalsRank"),false,self.layerNum+1)
			-- 					sceneGame:addChild(dialog,self.layerNum+1)
			-- 					playerVoApi.rankIsOpen=0
			-- 				end
			-- 			end
			-- 		end
			-- 		socketHelper:userGetnewranklist(callback)
			-- 	else
			-- 		require "luascript/script/game/scene/gamedialog/playerDialog/medalsRankDialog"
			-- 		local td=medalsRankDialog:new()
			-- 		local tbArr={}
			-- 		local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("medalsRank"),false,self.layerNum+1)
			-- 		sceneGame:addChild(dialog,self.layerNum+1)
			-- 	end
		
			-- end
			-- local rankItem = GetButtonItem("mainBtnRank.png","mainBtnRank_Down.png","mainBtnRank.png",showRank,11,nil,nil)
			-- local rankBtn = CCMenu:createWithItem(rankItem)
			-- rankBtn:setPosition(ccp(50,50))
			-- rankBtn:setTouchPriority(-(self.layerNum-1)*20-2)
			-- cell:addChild(rankBtn,2)

			-- if(base.rpShop==1)then
			-- 	local function openRpShop()
			-- 		if(self.rpShopTip)then
			-- 			self.rpShopTip:removeFromParentAndCleanup(true)
			-- 			self.rpShopTip=nil
			-- 		end
			-- 		rpShopVoApi:showShop(self.layerNum+1)
			-- 	end
			-- 	local rpShopItem=GetButtonItem("mainBtnItems.png","mainBtnItems_Down.png","mainBtnItems.png",openRpShop)
			-- 	if(rpShopVoApi:checkNoticed()==false)then
			-- 		self.rpShopTip=CCSprite:createWithSpriteFrameName("IconTip.png")
			-- 		self.rpShopTip:setPosition(ccp(70,70))
			-- 		rpShopItem:addChild(self.rpShopTip)
			-- 	end
			-- 	local rpShopBtn=CCMenu:createWithItem(rpShopItem)
			-- 	rpShopBtn:setPosition(ccp(150,50))
			-- 	rpShopBtn:setTouchPriority(-(self.layerNum-1)*20-2)
			-- 	cell:addChild(rpShopBtn,2)
			-- end


			local function showRankDetail()
				require "luascript/script/game/scene/gamedialog/playerDialog/playerRankDialog"
				local dialog=playerRankDialog:new()
	        	local layer=dialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("help2_t1_t3"),true,self.layerNum+1)
    		    sceneGame:addChild(layer,self.layerNum+1)
			end
			local menuItem=GetButtonItem("yh_IconReturnBtn.png","yh_IconReturnBtn_Down.png","yh_IconReturnBtn_Down.png",showRankDetail,nil,nil,nil)
			local menuBtn=CCMenu:createWithItem(menuItem)
			menuBtn:setPosition(ccp(520+btnWidthAdd,60));
			menuBtn:setTouchPriority(-(self.layerNum-1)*20-2);
			cell:addChild(menuBtn,3);

			local function rankHelpCall( )--------rankLabelStr2
			   local sd=smallDialog:new()
			   local labelTab={"\n",getlocal("rankLabelStr22"),"\n",getlocal("rankLabelStr21")}
			   local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,labelTab,28,nil,getlocal("dialog_title_prompt"))
			   sceneGame:addChild(dialogLayer,self.layerNum+1)
			end 
			local menuItem2 = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",rankHelpCall,11,nil,nil)
			local menu2 = CCMenu:createWithItem(menuItem2);
			menu2:setPosition(ccp(445+btnWidthAdd,60));
			menu2:setTouchPriority(-(self.layerNum-1)*20-2);
			cell:addChild(menu2,3);
		elseif idx==2 then
			local photoSp = CCSprite:createWithSpriteFrameName("item_shuji_04.png");
			photoSp:setAnchorPoint(ccp(0,0.5));
			photoSp:setPosition(ccp(10,hei / 2));
			cell:addChild(photoSp,2);
			
			local nameLb = GetTTFLabel(getlocal("leaderLevel",{playerVoApi:getTroops()}),24,true);
			nameLb:setAnchorPoint(ccp(0,1));
			nameLb:setPosition(ccp(120,hei-subTopHeight-10));
			nameLb:setTag(11)
			cell:addChild(nameLb,2);
			
			local soldiersLbNum
			local soldiersLbNum2
			local timerSpriteLvLuck=nil
			
			local soldiersLb = GetTTFLabel(getlocal("leadership"),20);
			soldiersLb:setAnchorPoint(ccp(0,0.5));
			soldiersLb:setPosition(ccp(120,hei-subMiddleHeight-15));
			cell:addChild(soldiersLb,2);
				
			-- soldiersLbNum = GetTTFLabel(playerVoApi:getTroopsLvNum(),26);
			-- soldiersLbNum:setAnchorPoint(ccp(0,0.5));
			-- soldiersLbNum:setPosition(ccp(120+soldiersLb:getContentSize().width+5,hei-subMiddleHeight-20));
			-- cell:addChild(soldiersLbNum,2);
			-- soldiersLbNum:setTag(12)

			soldiersLbNum2 = GetTTFLabel("+"..playerVoApi:getTroopsNum(),20)
			soldiersLbNum2:setColor(G_ColorGreen)
			soldiersLbNum2:setAnchorPoint(ccp(0,0.5))
			soldiersLbNum2:setPosition(ccp(120+soldiersLb:getContentSize().width+5,hei-subMiddleHeight-15))
			cell:addChild(soldiersLbNum2,2)
			soldiersLbNum2:setTag(13)

			local leaderMaxLv = playerVoApi:getMaxLvByKey("roleMaxLevel")
			local addValue = strategyCenterVoApi:getAttributeValue(15)
			if addValue and addValue > 0 then
				leaderMaxLv = leaderMaxLv + addValue
			end

			if G_getBHVersion() ==2 then
				local dataKey="playerTab1@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)-- upperTen_small
				local coutNums = tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))

				if coutNums ==nil or tonumber(coutNums)<1 then
					coutNums =0
				end
				 self.tenCountsLb = GetTTFLabelWrap(getlocal("dailyTenCounts",{coutNums}),17,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				self.tenCountsLb:setAnchorPoint(ccp(0,0.5))
				self.tenCountsLb:setPosition(ccp(120,15))
				cell:addChild(self.tenCountsLb,2)
				if playerVoApi:getPlayerLevel()>15 and base.isCheckVersion ==0 then
					self.tenCountsLb:setVisible(false)
				end			 
			end
			
			local function callBack()
				local function serverTroopsUp(fn,data)
					local cresult,retTb=base:checkServerData(data)
					if cresult==true then
						if newGuidMgr:isNewGuiding() then --新手引导
							newGuidMgr:toNextStep()
						else
							if playerVoApi:getTroops()>=leaderMaxLv or playerVoApi:getTroops()>=playerVoApi:getPlayerLevel() then
								eventDispatcher:dispatchEvent("secondConfirmShowSmallDialog.close")								
							end
						end
						if retTb.data.ConsumeType==1 then
							--统计使用物品
							statisticsHelper:useItem("p20",1)
						else
							--统计购买物品
							  statisticsHelper:buyItem("p20",propCfg["p20"].gemCost,1,propCfg["p20"].gemCost)
							--统计使用物品
							statisticsHelper:useItem("p20",1)
						end
						if retTb.data.status==1 then
							nameLb:setString(getlocal("leaderLevel",{playerVoApi:getTroops()}))
							-- soldiersLbNum:setString(playerVoApi:getTroopsLvNum())
							soldiersLbNum2:setString("+"..playerVoApi:getTroopsNum())

							if G_getBHVersion()==2 then
								local num2 = 0
								if retTb.data.bhreward[2]~=nil then
									num2=retTb.data.bhreward[2]
								end
								local num = retTb.data.bhreward[1]+num2
								-- local honors=playerVoApi:getHonors()+num
								-- print("honors1=",playerVoApi:getHonors(),num)
								-- playerVoApi:setHonors(honors)
								smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("new_player_info_leader_prompt_success",{num,playerVoApi:getTroopsNum()}),28)

								local dataKeys="playerTab1TimeNow@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
								local timeNow =base.serverTime
								CCUserDefault:sharedUserDefault():setStringForKey(dataKeys,tostring(timeNow))
								CCUserDefault:sharedUserDefault():flush()

								local dataKey="playerTab1@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
								local coutNums =tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))
								if coutNums~=nil and coutNums <10 then
									coutNums =coutNums+1
								end
								if coutNums==nil then
									coutNums=0
								end
								if self.tenCountsLb then
									self.tenCountsLb:setString(getlocal("dailyTenCounts",{coutNums}))
								end								
								CCUserDefault:sharedUserDefault():setStringForKey(dataKey,tostring(coutNums))
								CCUserDefault:sharedUserDefault():flush()								
							else
								-- 新手引导飘字，否则出现弹出框
								if newGuidMgr:isNewGuiding() then
									smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("player_info_leader_prompt_success",{playerVoApi:getTroopsNum()}),28)
								else
									local str1 = getlocal("dominance_promotion_tip", {playerVoApi:getTroops(),playerVoApi:getTroopsNum()})
									local tabStr = {" ",str1," "}

									--升级成功后判断是不是在元旦活动期间，如果在的话显示额外奖励的统率书的提示
									local newyearVoApi = activityVoApi:getVoApiByType("newyeargift")
									if newyearVoApi then
										local openAc,troopNum = newyearVoApi:getTroopsConfig()
										print("元旦活动现已开启，统率书个数 ："..troopNum)
										if openAc == true then
											table.insert(tabStr,1,getlocal("activity_newyeargift_troopstip",{getlocal("activity_newyeargift_title"),troopNum}))
										end
									end

									local td=smallDialog:new()
									local dialog
									if G_getCurChoseLanguage() =="ar" then
										 dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+3,tabStr,28,tabColor, getlocal("dominance_promotion_success"),true)
									else
										dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+3,tabStr,28,tabColor, getlocal("dominance_promotion_success"),true,true)
									end
									sceneGame:addChild(dialog,self.layerNum+1)
								end
							
							end

							-- local playerTroops=playerVoApi:getTroops()
							-- if playerTroops>=15 then
							-- 	local message={key="chatSystemMessage1",param={playerVoApi:getPlayerName(),playerTroops}}
							-- 	chatVoApi:sendSystemMessage(message)

							-- 	local params = {key="chatSystemMessage1",param={{playerVoApi:getPlayerName(),1},{playerTroops,3}}}
							-- 	chatVoApi:sendUpdateMessage(41,params)
							-- end
						else

							
							if G_getBHVersion()==2 then

								local num2 = 0
								if retTb.data.bhreward[2]~=nil then
									num2=retTb.data.bhreward[2]
								end
								local num = retTb.data.bhreward[1]+num2
								-- local honors=playerVoApi:getHonors()+num
								-- print("honors2=",playerVoApi:getHonors(),num)
								-- playerVoApi:setHonors(honors)
								smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("new_player_info_leader_prompt_success2",{num}),28)
	
								local dataKeys="playerTab1TimeNow@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
								local timeNow =base.serverTime
								CCUserDefault:sharedUserDefault():setStringForKey(dataKeys,tostring(timeNow))
								CCUserDefault:sharedUserDefault():flush()

								local dataKey="playerTab1@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
								local coutNums =tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))
								if coutNums~=nil and coutNums <10 then
									coutNums =coutNums+1
								end
								if coutNums==nil then
									coutNums=0
								end

								if self.tenCountsLb then
									self.tenCountsLb:setString(getlocal("dailyTenCounts",{coutNums}))
								end								
								CCUserDefault:sharedUserDefault():setStringForKey(dataKey,tostring(coutNums))
								CCUserDefault:sharedUserDefault():flush()
							else

								smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("player_info_leader_prompt_fail"),28)
							end
						end
					end
				end
				socketHelper:troopsUp(serverTroopsUp)
			end
			local function touch1()
				if self.tv:getIsScrolled()==true then
					do return end
				end

				PlayEffect(audioCfg.mouseClick)

				if playerVoApi:getTroops()==leaderMaxLv then
					do return end
				end
				if G_getBHVersion()==2 then 

					 local dataKey="playerTab1@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)-- upperTen_small
				     local coutNums = tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))	
					if base.isCheckVersion==1 and coutNums~=nil and coutNums >=10 then
					
					smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("upperTen"),nil,self.layerNum+1)
					do return end
					end
				end					
				G_removeFlicker(self.troopsMenuItem1)

				local multiUpgradeNum = 10 --批量升级统率的次数
				--单次提升统率
				local function singleCommanderUpgrade()
					local num=bagVoApi:getItemNumId(20)
					if num>0 then
						if newGuidMgr:isNewGuiding() or num>0 then --新手引导
							callBack()
						else
							smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,getlocal("dialog_title_prompt"),getlocal("usePropPromptLeader"),nil,self.layerNum+1)
						end
					else				
						if playerVoApi:getGems()>=tonumber(propCfg["p20"].gemCost) then
							smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,getlocal("dialog_title_prompt"),getlocal("sureBuyAndUse",{propCfg["p20"].gemCost}),nil,self.layerNum+1)
						else
							local function buyGems()
								if G_checkClickEnable()==false then
									do return end
								end
								vipVoApi:showRechargeDialog(self.layerNum+1)
							end
							local ca = tonumber(propCfg["p20"].gemCost)-playerVoApi:getGems()
							smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{tonumber(propCfg["p20"].gemCost),playerVoApi:getGems(),ca}),nil,self.layerNum+1)
						end
					end
				end

				--提升统率处理
				local function commanderUpgrade(upgradeNum)
					local pid = "p20"
					local id = tonumber(RemoveFirstChar(pid))
					local num = bagVoApi:getItemNumId(id)
					local price = tonumber(propCfg[pid].gemCost)
					local function multiCommanderUpgrade() --提升处理
						local function commanderUpCallback(fn,data)
							local ret, sData = base:checkServerData(data)
							if ret == true then
								if sData == nil or sData.data == nil or sData.data.result == nil then
									do return end
								end
								local result = sData.data.result
								require "luascript/script/game/scene/gamedialog/playerDialog/playerCommanderUpSmallDialog"
								playerCommanderUpSmallDialog:showCommanderUpDialog(result, self.layerNum+3)

								local realUseNum = 0
								local successFlag = false --是否有升级成功的
								for k,v in pairs(result) do
									--v[1]代表本次提升结果，0：失败，1：成功，2：已达统率上限
									--v[2]代表本次提升后的统率等级
									if v[1] and tonumber(v[1]) ~= 2 then
										realUseNum = realUseNum + 1
										if tonumber(v[1]) == 1 then
											successFlag = true
										end
									end
								end
								--统计使用物品
								statisticsHelper:useItem(pid,realUseNum)

								if successFlag==true then
									--刷新统率和带兵量显示
									nameLb:setString(getlocal("leaderLevel",{playerVoApi:getTroops()}))
									soldiersLbNum2:setString("+"..playerVoApi:getTroopsNum())

									--发送全服公告
									-- local playerTroops=playerVoApi:getTroops()
									-- if playerTroops>=15 then
									-- 	local message={key="chatSystemMessage1",param={playerVoApi:getPlayerName(),playerTroops}}
									-- 	chatVoApi:sendSystemMessage(message)

									-- 	local params = {key="chatSystemMessage1",param={{playerVoApi:getPlayerName(),1},{playerTroops,3}}}
									-- 	chatVoApi:sendUpdateMessage(41,params)
									-- end
								end
								if playerVoApi:getTroops()>=leaderMaxLv or playerVoApi:getTroops()>=playerVoApi:getPlayerLevel() then
									eventDispatcher:dispatchEvent("secondConfirmShowSmallDialog.close")								
								end
							end
						end
						socketHelper:multiCommanderUpgradeRequest(commanderUpCallback)	
					end
					
					if num >= upgradeNum then --够批量升级要求数量直接提升
						if upgradeNum == 1 then
							singleCommanderUpgrade()
						else
							multiCommanderUpgrade()
						end
					else --数量不足时需要弹出金币购买的二次确认弹窗
						local buyNum = upgradeNum - num
						local gemCost = buyNum * price
						local function confirmHandler()
							local ownGems = playerVoApi:getGems()
							if ownGems < gemCost then --金币不足购买所需统率书，则跳转充值页面
								GemsNotEnoughDialog(nil,nil,gemCost-ownGems,self.layerNum+3,gemCost)
							else
								local function realUpgrade(fn,data)
									local ret, sData = base:checkServerData(data)
									if ret == true then
										if upgradeNum == 1 then
											singleCommanderUpgrade()
										else
											multiCommanderUpgrade()
										end
										--统计购买物品
									  	statisticsHelper:buyItem(pid,price,buyNum,buyNum*price)
									end
								end
								--先购买补充所需统率书
        						socketHelper:buyProc(id,realUpgrade,buyNum)
							end
						end
						G_showSecondConfirm(self.layerNum+2,true,true,getlocal("dialog_title_prompt"),getlocal("upgrade_command_numlack_tip",{upgradeNum,gemCost,upgradeNum}),false,confirmHandler)
					end
				end
				--单次提升
				local function commanderUpgrade_one()
					commanderUpgrade(1)
				end
				--多次提升
				local function commanderUpgrade_ten()
					commanderUpgrade(multiUpgradeNum)
				end
				--新手引导的话保持原先单次升级统率的逻辑
				if newGuidMgr:isNewGuiding() == true or G_getBHVersion() == 2 then
					singleCommanderUpgrade()
				else
					multiConfrimDialog = G_showSecondConfirm(self.layerNum+1,true,true,getlocal("fight_fail_tip_13"),getlocal("upgrade_command_tip"),false,commanderUpgrade_ten,nil,commanderUpgrade_one,nil,nil,{getlocal("upgrade_command_btnStr",{multiUpgradeNum})},{getlocal("upgrade_command_btnStr",{1})},true,nil,1)
				end
			end
			local function touch2()
				if self.tv:getIsScrolled()==true then
					do return end
				end
				if newGuidMgr:isNewGuiding() then --新手引导
					do return end
				end
				PlayEffect(audioCfg.mouseClick)
				local td=smallDialog:new()
				local tabStr ={}
				local tabColor ={}
				local str1 = getlocal("player_leader_tip_1")
				if G_getBHVersion()==2 then
					str1 = getlocal("new_player_leader_tip_1")
				end
				
				local str2 = getlocal("player_leader_tip_2")
				local str3 = getlocal("tip_nextLevel",{playerVoApi:getTroops()+1,playerVoApi:getNextTroopsNum()})
				--vip对统率升级的加成				
				local addPercent=1 + playerCfg.commandedSpeed[playerVoApi:getVipLevel()+1]
				--提高统率概率的活动 "data":{"attackIsland":{"propRate":0.3,"exp":0.2},"troopsup":{"upRate":0.1},"attackChallenge":{"exp":0.2}}
				local luckupActive=activityVoApi:getActivityVo("luckUp")
				if luckupActive and playerVoApi:getTroops()<leaderMaxLv then
					if luckupActive.otherData and luckupActive.st and luckupActive.et and base.serverTime>luckupActive.st and base.serverTime<luckupActive.et  then
						if luckupActive.otherData.troopsup and luckupActive.otherData.troopsup.upRate then
							local upRate=tonumber(luckupActive.otherData.troopsup.upRate)
							addPercent=addPercent*(1 + upRate)
						end
					end
				end
				local str4
				if(addPercent>1)then
					local realPercent=playerVoApi:getTroopsSuccess()*addPercent
					local extraPercent=realPercent - playerVoApi:getTroopsSuccess()
					str4=getlocal("tip_succeedRate",{playerVoApi:getTroopsSuccess()}).." + "..extraPercent.."%"
				else
					str4=getlocal("tip_succeedRate",{playerVoApi:getTroopsSuccess()})
				end

				--判断是不是在元旦活动期间，如果在的话提升成功率
				local newyearVoApi = activityVoApi:getVoApiByType("newyeargift")
				if newyearVoApi then
					local openAc,troopNum,addRate = newyearVoApi:getTroopsConfig()
					print("元旦活动现已开启，增加成功率 ："..addPercent.."%")
					local realRate = playerVoApi:getTroopsSuccess()*addRate
					if openAc == true then
						str4 = str4 .. " + " .. realRate .. "%"
					end
				end

				local str5 = getlocal("player_rank_tip_5")
				local str6 = getlocal("player_rank_tip_6",{playerVoApi:getTroops()+1})
				local str7 = getlocal("dominanceBook",{bagVoApi:getItemNumId(20)})


				tabStr = {" ",str7,str6,str5," ",str4,str3," ",str2,str1," "}
				--审核服不显示概率
				if(tonumber(base.curZoneID)==999)then
				-- if(true)then
					for k,v in pairs(tabStr) do
						if(v==str4)then
							table.remove(tabStr,k)
							break
						end
					end
				end
			
				if tonumber(playerVoApi:getTroops()+1)>playerVoApi:getPlayerLevel() then
					table.insert(tabColor, 3, G_ColorRed)
				end

				if G_getBHVersion()==2 then

					tabStr = {" ",str3," ",str1," "}
				end

				if playerVoApi:getTroops()==leaderMaxLv then
					local str=getlocal("show_tip_maxlevel");
					tabStr={" ",str," "}
				end
				local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,tabColor)
				sceneGame:addChild(dialog,self.layerNum+1)
			end

			-- 如果用户背包中存在统率书，则在点击统率升级按钮时不弹出提示，直接使用。
								
			self.troopsMenuItem1 = GetButtonItem("yh_BtnUp.png","yh_BtnUp_Down.png","yh_BtnUp_Down.png",touch1,10,nil,nil)
			
			if newGuidMgr:isNewGuiding() and newGuidMgr.curStep==36 then
				self.guideItem=self.troopsMenuItem1
			end

			local menu1 = CCMenu:createWithItem(self.troopsMenuItem1);
			menu1:setPosition(ccp(520+btnWidthAdd,60));
			menu1:setTouchPriority(-(self.layerNum-1)*20-2);
			cell:addChild(menu1,3);

			if playerVoApi:getTroops()>=leaderMaxLv then
				self.troopsMenuItem1:setEnabled(false);
			end
			if playerVoApi:getTroops()>=playerVoApi:getPlayerLevel() + (addValue or 0) then
				self.troopsMenuItem1:setEnabled(false);
			end

			if self.isGuide~=nil then
				if self.troopsMenuItem1:isEnabled()==true then
					local scale=(self.troopsMenuItem1:getContentSize().width+10)/40
					G_addFlicker(self.troopsMenuItem1,scale,scale,ccp(self.troopsMenuItem1:getContentSize().width/2,self.troopsMenuItem1:getContentSize().height/2))
				end
			end

			local menuItem2 = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touch2,11,nil,nil)
			local menu2 = CCMenu:createWithItem(menuItem2);
			menu2:setPosition(ccp(445+btnWidthAdd,60));
			menu2:setTouchPriority(-(self.layerNum-1)*20-2);
			cell:addChild(menu2,3);
		elseif idx==3 then
			local lv,cur,next = playerVoApi:getHonorInfo()
			local photoSp = CCSprite:createWithSpriteFrameName("Icon_prestige.png");
			photoSp:setAnchorPoint(ccp(0,0.5));
			photoSp:setPosition(ccp(10,hei / 2));
			cell:addChild(photoSp,2);
			
			local nameLb = GetTTFLabel(getlocal("honorLevel",{lv}),24,true);
			nameLb:setAnchorPoint(ccp(0,1));
			nameLb:setPosition(ccp(120,hei-subTopHeight-10));
			cell:addChild(nameLb,2);
			nameLb:setTag(10)




			local str = cur.."/"..next
			AddProgramTimer(cell,ccp(240,hei-subMiddleHeight-15),11,12,str,"AllBarBg.png","AllXpBar.png",13,nil,nil,nil,nil,20)
			local timerSpriteBg = cell:getChildByTag(13);
			timerSpriteBg = tolua.cast(timerSpriteBg,"CCSprite")
			timerSpriteBg:setPositionX(nameLb:getPositionX()+timerSpriteBg:getContentSize().width/2)
			local per = cur/next*100;
			local timerSpriteLv = cell:getChildByTag(11);
			timerSpriteLv:setPositionX(timerSpriteBg:getPositionX())
			timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
			timerSpriteLv:setPercentage(per);
			-- local everydayLb = GetTTFLabelWrap(getlocal("rankInfo",{playerVoApi:getRankDailyHonor(playerVoApi:getRank())}),cell3Str2Width,CCSizeMake(26*10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter);
			-- everydayLb:setAnchorPoint(ccp(0,0.5));
			-- everydayLb:setPosition(ccp(120,35));
			-- everydayLb:setTag(518)
			-- cell:addChild(everydayLb,2);
			local function touch1()
				if self.tv:getIsScrolled()==true then
					do return end
				end
				if G_checkClickEnable()==false then
					do return end
				end
                require "luascript/script/game/scene/gamedialog/prestigeDialog"
				local td=prestigeDialog:new(self.layerNum+1)
				local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("reputation_scene_title"),true,self.layerNum+1)
				sceneGame:addChild(dialog,self.layerNum+1)
				PlayEffect(audioCfg.mouseClick)
			end
			local function touch2()
				if self.tv:getIsScrolled()==true then
					do
						return
					end
				end
				if G_checkClickEnable()==false then
					do
						return
					end
				end
				
				local td=smallDialog:new()
				local str1 = getlocal("tip_honorInfo")
				local str2 = getlocal("tip_honorInfo1")
				local str3 = getlocal("tip_honorInfo2")
				local str4 = nil
				local tabStr = {" ",str3,str2,str1," "}
				if base.isConvertGems ==1 then
					str4=getlocal("isConvertGemsByHonorsOrExp")
					tabStr = {" ",str4,str3,str2,str1," "}
				end
				local tabColor ={}
				local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,tabColor)
				sceneGame:addChild(dialog,self.layerNum+1)
				PlayEffect(audioCfg.mouseClick)
			end

			local menuItem1 = GetButtonItem("yh_BtnUp.png","yh_BtnUp_Down.png","yh_BtnUp_Down.png",touch1,10,nil,nil)
			local menu1 = CCMenu:createWithItem(menuItem1);
			menu1:setPosition(ccp(520+btnWidthAdd,60));
			menu1:setTouchPriority(-(self.layerNum-1)*20-2);
			self.btn = menuItem1
			cell:addChild(menu1,3);
			local honorMaxLv = playerVoApi:getMaxLvByKey("roleMaxLevel")
			local addValue = strategyCenterVoApi:getAttributeValue(14)
		    if addValue and addValue > 0 then
		        honorMaxLv = honorMaxLv + addValue
		    end
			if lv>=honorMaxLv then
				menuItem1:setEnabled(false);
			end
			
			local menuItem2 = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touch2,11,nil,nil)
			local menu2 = CCMenu:createWithItem(menuItem2);
			menu2:setPosition(ccp(445+btnWidthAdd,60));
			menu2:setTouchPriority(-(self.layerNum-1)*20-2);
			cell:addChild(menu2,3);
		elseif idx==4 then --成就
			local photoSp=CCSprite:createWithSpriteFrameName("avt_icon.png")
			photoSp:setAnchorPoint(ccp(0,0.5))
			photoSp:setPosition(ccp(10,hei/2))
			cell:addChild(photoSp,2)

			local nameStr,color="",G_ColorWhite
			local openFlag,openLv=achievementVoApi:isOpen()
			if openFlag==2 then --等级不够
				nameStr,color=getlocal("achievement_openlevel",{openLv}),G_ColorRed
			else
				nameStr=getlocal("google_achievement")..getlocal("fightLevel",{achievementVoApi:getAchievementLv()})
			end

			local nameLb=GetTTFLabelWrap(nameStr,24,CCSizeMake(280,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
			nameLb:setAnchorPoint(ccp(0,0.5))
			nameLb:setPosition(ccp(120,hei/2))
			nameLb:setColor(color)
			cell:addChild(nameLb,2)
			nameLb:setTag(10)

			local priority=-(self.layerNum-1)*20-2
			local function showAchievementDialog()
				if openFlag==2 then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),nameStr,28)
					do return end
				end
				achievementVoApi:showAchievementDialog(self.layerNum+1)
			end
			local goBtn=G_createBotton(cell,ccp(520+btnWidthAdd,60),nil,"yh_IconReturnBtn.png","yh_IconReturnBtn_Down.png","yh_IconReturnBtn_Down.png",showAchievementDialog,1,priority,3)
			local flag=achievementVoApi:hasReward() --有奖励可以领取
			if flag==true then
				G_addFlicker(goBtn,1.5,1.5,getCenterPoint(goBtn))
			end
			local function showRuleInfo( )
	   		   local sd=smallDialog:new()
			   local labelTab={"\n",getlocal("achievement_rule4"),"\n",getlocal("achievement_rule3"),"\n",getlocal("achievement_rule2"),"\n",getlocal("achievement_rule1")}
			   local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,labelTab,28,nil,getlocal("dialog_title_prompt"))
			   sceneGame:addChild(dialogLayer,self.layerNum+1)
			end
			G_createBotton(cell,ccp(445+btnWidthAdd,60),nil,"i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showRuleInfo,1,priority,3)
		end
		return cell;
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	elseif fn=="ccScrollEnable" then
		if newGuidMgr:isNewGuiding()==true then
			return 0
		else
			return 1
		end
	end
end

function playerDialogTab1:removeGuied()
	G_removeFlicker(self.troopsMenuItem1)
end

function playerDialogTab1:tick()
	if self.tickFlag==false then
		do return end
	end
	if G_getBHVersion()==2 then
		local dataKey="playerTab1TimeNow@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)-- upperTen_small
		local timeNow = tonumber(CCUserDefault:sharedUserDefault():getStringForKey(dataKey))
		if timeNow ==nil then
			timeNow=0
		end
		--if self.tenCountsLb then
			if G_isToday(timeNow)==false then

				local coutNums =0
				if self.tenCountsLb then
					self.tenCountsLb:setString(getlocal("dailyTenCounts",{coutNums}))
				end
				local dataKey="playerTab1@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
				CCUserDefault:sharedUserDefault():setStringForKey(dataKey,tostring(coutNums))
				CCUserDefault:sharedUserDefault():flush()
			else
				local dataKey="playerTab1@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
				local coutNum=CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
				if coutNum=="" then
					coutNum=0
				end
				if self.tenCountsLb then
					self.tenCountsLb:setString(getlocal("dailyTenCounts",{coutNum}))
				end
			end
		--end
	end

		local cell1 = self.tableCell1[1]
		local newLevel = playerVoApi:getPlayerLevel()
		local lableLv = cell1:getChildByTag(20);
		lableLv=tolua.cast(lableLv,"CCLabelTTF")
		lableLv:setString(getlocal("fightLevel",{newLevel}))

		local timePro = cell1:getChildByTag(21);
		timePro=tolua.cast(timePro,"CCProgressTimer")
		timePro:setPercentage(playerVoApi:getLvPercent());

		local lableExp = timePro:getChildByTag(22);
		lableExp=tolua.cast(lableExp,"CCLabelTTF")
		local lvPer = playerVoApi:getLvPercent()
		local lvExp,lvMaxExp = playerVoApi:getLvExp()

		local ownAddTroopNums=playerVoApi:getAddTroops()
		local addTroopNums = cell1:getChildByTag(133)
		addTroopNums = tolua.cast(addTroopNums,"CCLabelTTF")
		addTroopNums:setString("("..playerVoApi:getTroopsLvNum().."+"..ownAddTroopNums..")")

		local expStr= lvExp.."/"..lvMaxExp
		lableExp:setString(expStr)

		local timeProEn = cell1:getChildByTag(24);
		timeProEn=tolua.cast(timeProEn,"CCProgressTimer")
		timeProEn:setPercentage(playerVoApi:getEnergyPercent()*100);
		
    	local per = playerVoApi:getPerEnergyRecoverTime()
		local energyStr;
		local lableEn = timeProEn:getChildByTag(25);
		lableEn=tolua.cast(lableEn,"CCLabelTTF")
		local maxEnergy = checkPointVoApi:getMaxEnergy()
		if playerVoApi:getEnergy()>=maxEnergy then
			energyStr = playerVoApi:getEnergy().."/"..maxEnergy
			lableEn:setString(energyStr)
		else
			self.enTime=playerVoApi:getEnergyRecoverLeftTime() --下一次刷新能量点时间
			-- self.enTimeCount=math.floor(playerVoApi:getPlayerEnergycd()/1800)
			-- print("self.enTime,self.enTimeCount,playerVoApi:getPlayerEnergycd",self.enTime,self.enTimeCount,playerVoApi:getPlayerEnergycd())
			energyStr = playerVoApi:getEnergy().."/"..maxEnergy.."("..GetTimeStr(self.enTime)..")"
			lableEn:setString(energyStr)
			
			-- self.enTime=self.enTime-1
			-- if self.enTime<0 then
			-- 	playerVo.energy=playerVo.energy+1
			-- 	-- if self.enTimeCount>0 then
			-- 	-- 	self.enTime=1800
			-- 	-- 	self.enTimeCount=self.enTimeCount-1
			-- 	-- end	
			-- end

		end

		local troopsLb=tolua.cast(cell1:getChildByTag(519),"CCLabelTTF")
		troopsLb:setString(playerVoApi:getTotalTroops())
		
		local cell2 = self.tableCell1[2]
		local lableRank = cell2:getChildByTag(1);
		lableRank=tolua.cast(lableRank,"CCLabelTTF")
		lableRank:setString(playerVoApi:getRankName(playerVoApi:getRank()))
		
		local lablePoint = cell2:getChildByTag(3);
		lablePoint=tolua.cast(lablePoint,"CCLabelTTF")
		lablePoint:setString(FormatNumber(playerVoApi:getRankPoint()-playerVoApi:getTodayRankPoint()))
		local troopsLb=tolua.cast(cell2:getChildByTag(3),"CCLabelTTF")
		troopsLb:setString(playerVoApi:getRankTroops())
		if self.m_rankPlayer~=playerVoApi:getRank() then
			local rankSp=cell2:getChildByTag(50)
			rankSp:removeFromParentAndCleanup(true)
			self.m_rankPlayer=playerVoApi:getRank();
			local rankStr=playerVoApi:getRankIconName()
			local rankSP = GetBgIcon(rankStr)
			rankSP:setScale(1/0.8);
			rankSP:setAnchorPoint(ccp(0,0.5));
			rankSP:setPosition(ccp(10,72));
			rankSP:setTag(50)
			cell2:addChild(rankSP,2);

		end

		local cell3 = self.tableCell1[3]
		local lableTroops = cell3:getChildByTag(11);
		lableTroops=tolua.cast(lableTroops,"CCLabelTTF")
		lableTroops:setString(getlocal("leaderLevel",{playerVoApi:getTroops()}))
		
		local menuItemTroop=tolua.cast(lableTroops,"CCLabelTTF")
		local addValue = 0
		if newLevel == playerVoApi:getMaxLvByKey("roleMaxLevel") then
			addValue = strategyCenterVoApi:getAttributeValue(15)
		end
		if playerVoApi:getTroops()>=newLevel + (addValue or 0) then
				self.troopsMenuItem1:setEnabled(false);
		end

		-- local lableSolidersNums = cell3:getChildByTag(12);
		-- lableSolidersNums=tolua.cast(lableSolidersNums,"CCLabelTTF")
		-- lableSolidersNums:setString(playerVoApi:getTroopsLvNum())

		local lableSolidersNums2 = cell3:getChildByTag(13);
		lableSolidersNums2=tolua.cast(lableSolidersNums2,"CCLabelTTF")
		lableSolidersNums2:setString("+"..playerVoApi:getTroopsNum())

		local lv,cur,next = playerVoApi:getHonorInfo()
		local cell4 = self.tableCell1[4]
		local honorLevelLb = cell4:getChildByTag(10);
		honorLevelLb=tolua.cast(honorLevelLb,"CCLabelTTF")
		honorLevelLb:setString(getlocal("honorLevel",{lv}))

		-- local everydayLb=tolua.cast(cell4:getChildByTag(518),"CCLabelTTF")
		-- everydayLb:setString(getlocal("rankInfo",{playerVoApi:getRankDailyHonor(playerVoApi:getRank())}))	
		
		local honorProEn = cell4:getChildByTag(11);
		local per = cur/next*100;
		honorProEn=tolua.cast(honorProEn,"CCProgressTimer")
		honorProEn:setPercentage(per);
		
		local str = cur.."/"..next
		local honorLb = honorProEn:getChildByTag(12);
		honorLb=tolua.cast(honorLb,"CCLabelTTF")
		honorLb:setString(str)
end


--用户处理特殊需求,没有可以不写此方法
function playerDialogTab1:doUserHandler()

end

--点击了cell或cell上某个按钮
function playerDialogTab1:cellClick(idx)
	if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
		if self.expandIdx["k"..(idx-1000)]==nil then
				self.expandIdx["k"..(idx-1000)]=idx-1000
				self.tv:openByCellIndex(idx-1000,120)
		else
			self.expandIdx["k"..(idx-1000)]=nil
			self.tv:closeByCellIndex(idx-1000,800)
		end
	end
end

function playerDialogTab1:onUserPowerChange()
	local cell=playerDialogTab1.tableCell1[1]
	if(cell and cell:getChildByTag(518))then
		local lb=tolua.cast(cell:getChildByTag(518),"CCLabelTTF")
		lb:setString(playerVoApi:getPlayerPower())
	end
end

function playerDialogTab1:playerIconChange(data)
	local recordPoint=self.tv:getRecordPoint()
	self.tv:reloadData()
	self.tv:recoverToRecordPoint(recordPoint)
end

function playerDialogTab1:refresh(data)
	if self.tv then
		local recordPoint=self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
	end
end

function playerDialogTab1:dispose()
	eventDispatcher:removeEventListener("playerIcon.Change",self.playerIconChangeListener)
	eventDispatcher:removeEventListener("user.power.change",self.onUserPowerChange)
	self.bgLayer:removeFromParentAndCleanup(true)
	self.bgLayer=nil;
	self.tv=nil;
	self.tableCell1={};
	self.tableCell1=nil;
	self.layerNum=nil;
	self.enTime=nil;
	self.enTimeCount=nil;
	self.rankmenuItem1=nil;
	self.troopsMenuItem1=nil;
	self.tenCountsLb=nil
	self.isBuyingTime=nil
	self.photoSp=nil
	self.guideItem=nil
	self.tickFlag=nil
	if self.refreshListener then
    	eventDispatcher:removeEventListener("player.dialogtab1.refresh",self.refreshListener)
    	self.refreshListener=nil
	end
	if self.nameChangeListener then
    	eventDispatcher:removeEventListener("user.name.change",self.nameChangeListener)
    	self.nameChangeListener=nil
	end
	self.cellWidth=nil
end
