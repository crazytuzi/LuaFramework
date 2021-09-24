alienMinesSmallDialog=smallDialog:new()

--param type: 面板类型, 1是自己占领, 2是友军占领, 3是敌军占领,4是空地
--param data: 数据, 坐标 ID等
function alienMinesSmallDialog:new(type,data,parent,flag)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogWidth=550
	self.dialogHeight=730

	self.type=type
	self.data=data

	self.parent=parent
	self.flag=flag
	return nc
end

function alienMinesSmallDialog:init(layerNum,spWorldPos,layerMovePos)
	self.isTouch=nil
	self.layerNum=layerNum
	self.spWorldPos=spWorldPos
	self.layerMovePos=layerMovePos

	local function nilFunc()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		if self.flag and self.parent then
			self.parent.m_menuToggleSmall:setSelectedIndex(0)
	        self.parent:pushSmallMenu() 
		end
		return self:close()
	end

	self.dialogLayer=CCLayer:create()
	self:show()
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
    
	
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(0)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)
	self.touchDialogBg=touchDialogBg

	self:addMineLayer()

     

	
	local delay = CCDelayTime:create(self.time)
	local function callback()
		self:initWithType()
	end
	local callfunc = CCCallFunc:create(callback)
	local seq = CCSequence:createWithTwoActions(delay,callfunc)
	self.dialogLayer:runAction(seq)


	sceneGame:addChild(self.dialogLayer,self.layerNum+1)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end



function alienMinesSmallDialog:initWithType()

	local capInSet = CCRect(0, 0, 192, 192)
	local function nilFunc()
	end
	local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("alien_mines_circle.png",capInSet,nilFunc)
	backSprie:setContentSize(CCSizeMake(250, 250))
	backSprie:ignoreAnchorPointForPosition(false);
	-- backSprie:setAnchorPoint(ccp(0,0));
	backSprie:setPosition(self.spWorldPos)
	backSprie:setIsSallow(true)
	-- backSprie:setScale(2)
	backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
	self.touchDialogBg:addChild(backSprie,3)


	-- 信息
	local function callback1()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)

		local isScout=false
		local num=0
		local name=""
		if self.type==3 then
			local dataKey="alienMine@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
			local str = CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
			
			if str==nil or str=="" then
			else
				local alienMineTb=G_Json.decode(tostring(str))
				local startTime,endTime=alienMinesVoApi:getBeginAndEndtime()
				local myTs=(endTime[1]-startTime[1])*3600+(endTime[2]-startTime[2])*60
				if base.serverTime-tonumber(alienMineTb[tostring(1)])<myTs then
					if alienMineTb[tostring(100*self.data.x+self.data.y)]~=nil and SizeOfTable(alienMineTb[tostring(100*self.data.x+self.data.y)])==2 then
						isScout=true
						num=alienMineTb[tostring(100*self.data.x+self.data.y)][tostring(2)]
						name=alienMineTb[tostring(100*self.data.x+self.data.y)][tostring(1)]
					end
				end

			end
		end
		require "luascript/script/game/scene/gamedialog/alienMines/alienMinesTargetSmallDialog"
		if self.type==3  or self.type==2 then
	        
	        local function callback(fn,data)
	        	local ret,sData = base:checkServerData(data)
	        	if ret==true then 
	        		if sData and sData.data and sData.data.usergetinfo then
	        			alienMinesEnemyInfoVoApi:add(self.data.x,self.data.y,self.data.oid,sData.data.usergetinfo)
	     
					    local sd=alienMinesTargetSmallDialog:new(self.type,self.data,isScout,num,name)
					    return sd:init(self.layerNum+1)
	        		end
	        	end
	        end
	        local vo = alienMinesEnemyInfoVoApi:getEnemyInfoVoByXYAndOid(self.data.x,self.data.y,self.data.oid)
	        if vo then
	        	
			    local sd=alienMinesTargetSmallDialog:new(self.type,self.data,isScout,num,name)
			    return sd:init(self.layerNum+1)
        	else
	        	socketHelper:alienMinesGetEnemyInfo(self.data.oid,callback)
	        end
	        
		else
		    local sd=alienMinesTargetSmallDialog:new(self.type,self.data,isScout,num,name)
		    return sd:init(self.layerNum+1)
		end
		
	end
	-- 占领
	local function callback2()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		local occupyNum=alienMinesVoApi:getOccupyNum()
		local totalccupyNum = alienMinesVoApi:getTotalOccupyNum()
		if occupyNum>=totalccupyNum then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage5018"),30)
		else
			self:attack(1)
		end
		
	end
	-- 掠夺
	local function callback3()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		local robNum = alienMinesVoApi:getRobNum()
		local totalRobNum = alienMinesVoApi:getTotalRobNum()
		if robNum>=totalRobNum then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage5017"),30)
		else
			self:attack(0)
		end
		
	end
	-- 侦查
	local function callback4()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		self:scout()
	end
	-- 返回
	local function callback5()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		 local function serverBack(fn,data)
                                --local retTb=OBJDEF:decode(data)
            if base:checkServerData(data)==true then
            	eventDispatcher:dispatchEvent("alienMines.mineChange",{{x=self.data.x,y=self.data.y}})
            	 -- local params = {uid=playerVoApi:getUid(),x=self.data.x,y=self.data.y}
              --   chatVoApi:sendUpdateMessage(21,params)
             	self:close()
         	else
         		eventDispatcher:dispatchEvent("alienMines.mineChange",{{x=self.data.x,y=self.data.y}})
                self:close()
            end
         end
        local slotId = attackTankSoltVoApi:getSlotIdBytargetid(self.data.x,self.data.y)
        socketHelper:alienMinesTroopBack(slotId,serverBack)
	end



	self.functionTb={
	{btnLb=getlocal("world_scene_info"),callback=callback1,icon="alien_mines_info.png",icon_on="alien_mines_info_on.png"},
	{btnLb=getlocal("alienMines_Occupied"),callback=callback2,icon="alien_mines_occupy.png",icon_on="alien_mines_occupy_on.png"},
	{btnLb=getlocal("help4_t3_t3"),callback=callback3,icon="alien_mines_attack.png",icon_on="alien_mines_attack_on.png"},
	{btnLb=getlocal("city_info_scout"),callback=callback4,icon="alien_mines_scout.png",icon_on="alien_mines_scout_on.png"},
	{btnLb=getlocal("coverFleetBack"),callback=callback5,icon="alien_mines_back.png",icon_on="alien_mines_back_on.png"},
	}
	local changeX=130
	local changeY=130
	local changeNum=110
	local changeY1=110
	local changeX1=60
	-- self.type=3
	local informationTb
	if self.type==1 then
		informationTb={
		{pos=ccp(self.spWorldPos.x-changeX,self.spWorldPos.y),btnLb=self.functionTb[1].btnLb,callback=self.functionTb[1].callback,icon=self.functionTb[1].icon,icon_on=self.functionTb[1].icon_on},
		{pos=ccp(self.spWorldPos.x+changeX,self.spWorldPos.y),btnLb=self.functionTb[5].btnLb,callback=self.functionTb[5].callback,icon=self.functionTb[5].icon,icon_on=self.functionTb[5].icon_on},
		}

	elseif self.type==2 then
		informationTb={
		{pos=ccp(self.spWorldPos.x,self.spWorldPos.y+changeY),btnLb=self.functionTb[1].btnLb,callback=self.functionTb[1].callback,icon=self.functionTb[1].icon,icon_on=self.functionTb[1].icon_on}
		}
	elseif self.type==3 then
		informationTb={
		{pos=ccp(self.spWorldPos.x-changeX,self.spWorldPos.y),btnLb=self.functionTb[2].btnLb,callback=self.functionTb[2].callback,icon=self.functionTb[2].icon,icon_on=self.functionTb[2].icon_on},
		{pos=ccp(self.spWorldPos.x-changeX+changeX1,self.spWorldPos.y+changeY1),btnLb=self.functionTb[1].btnLb,callback=self.functionTb[1].callback,icon=self.functionTb[1].icon,icon_on=self.functionTb[1].icon_on},
		{pos=ccp(self.spWorldPos.x+changeX-changeX1,self.spWorldPos.y+changeY1),btnLb=self.functionTb[4].btnLb,callback=self.functionTb[4].callback,icon=self.functionTb[4].icon,icon_on=self.functionTb[4].icon_on},
		{pos=ccp(self.spWorldPos.x+changeX,self.spWorldPos.y),btnLb=self.functionTb[3].btnLb,callback=self.functionTb[3].callback,icon=self.functionTb[3].icon,icon_on=self.functionTb[3].icon_on}
		
		}
	elseif self.type==4 then
		informationTb={
		{pos=ccp(self.spWorldPos.x-changeX,self.spWorldPos.y),btnLb=self.functionTb[2].btnLb,callback=self.functionTb[2].callback,icon=self.functionTb[2].icon,icon_on=self.functionTb[2].icon_on},
		{pos=ccp(self.spWorldPos.x+changeX,self.spWorldPos.y),btnLb=self.functionTb[4].btnLb,callback=self.functionTb[4].callback,icon=self.functionTb[4].icon,icon_on=self.functionTb[4].icon_on},
		{pos=ccp(self.spWorldPos.x,self.spWorldPos.y+changeY),btnLb=self.functionTb[1].btnLb,callback=self.functionTb[1].callback,icon=self.functionTb[1].icon,icon_on=self.functionTb[1].icon_on}

		}
	end

	for i=1,SizeOfTable(informationTb) do
		self:addMenu(informationTb[i])
	end

	self:addBottom()

	
end

function alienMinesSmallDialog:addMenu(informationTb)
	local function callback()
	end
	local  lbSize = 22
	if G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="ru" then
		lbSize=16
	end
	local menuItem = GetButtonItem(informationTb.icon,informationTb.icon_on,informationTb.icon_on,informationTb.callback,11,informationTb.btnLb,lbSize,10)
	local desLb = tolua.cast(menuItem:getChildByTag(10), "CCLabelTTF")
	desLb:setPositionY(-desLb:getContentSize().height/2)
	-- menuItem:setPosition(ccp(informationTb.pos.x-G_VisibleSize.width/2,informationTb.pos.y-G_VisibleSize.height/2))
	menuItem:setPosition(ccp(self.spWorldPos.x-G_VisibleSize.width/2,self.spWorldPos.y-G_VisibleSize.height/2))
	local menu = CCMenu:createWithItem(menuItem)
	-- menu:setAnchorPoint(ccp(0,0))
	menu:setPosition(0,0)
	menu:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:addChild(menu,6)

	-- 添加按钮名字底框
	local function userNameClick()         
	end
	local  userNameSp=LuaCCScale9Sprite:createWithSpriteFrameName("BattleTankNumBg.png",CCRect(10, 4, 2, 2),userNameClick)
	userNameSp:setOpacity(200)  
	userNameSp:setAnchorPoint(ccp(0.5,0.5))
	userNameSp:setPosition(ccp(menuItem:getContentSize().width/2,-desLb:getContentSize().height/2))
	userNameSp:setContentSize(CCSizeMake(desLb:getContentSize().width,desLb:getContentSize().height+4))
	menuItem:addChild(userNameSp,2)  

	-- 散开的动作
	local moveTo = CCMoveTo:create(0.3,ccp(informationTb.pos.x-G_VisibleSize.width/2,informationTb.pos.y-G_VisibleSize.height/2))
	menuItem:runAction(moveTo)
end

function alienMinesSmallDialog:addBottom()
	-- 最下面的文字描述
	local corLb = GetTTFLabel(getlocal("alienMines_coordinate",{self.data.x,self.data.y}),22)
	corLb:setPosition(ccp(self.spWorldPos.x,self.spWorldPos.y-110))
	self.touchDialogBg:addChild(corLb,4)

	local function click()
    end
    local barSprie = LuaCCScale9Sprite:createWithSpriteFrameName("HelpBgBottom.png", CCRect(20,20,1,1),click)
    barSprie:setContentSize(CCSizeMake(corLb:getContentSize().height+20, corLb:getContentSize().width+30))
    barSprie:setRotation(90)
    barSprie:setPosition(ccp(self.spWorldPos.x,self.spWorldPos.y-110))
    self.touchDialogBg:addChild(barSprie,3)
end

function alienMinesSmallDialog:addMineLayer()

	-- 屏蔽层（透明度）
	local myLayer = CCLayer:create()
	myLayer:setPosition(0, 0)
	myLayer:setAnchorPoint(ccp(0,0))
	sceneGame:addChild(myLayer,self.layerNum,169)
	-- self.myLayer=myLayer

	local function nilfunc()
	end

	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilfunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setAnchorPoint(ccp(0,0))
	touchDialogBg:setPosition(ccp(0,0))
	myLayer:addChild(touchDialogBg)

	local mineLayer = CCLayer:create()
	mineLayer:setPosition(0, 0)
	mineLayer:setAnchorPoint(ccp(0,0))
	sceneGame:addChild(mineLayer,self.layerNum,168)


	local function nilFunc()
	end
	local minesSp=LuaCCSprite:createWithSpriteFrameName("alien_mines"..self.data.type..".png",nilFunc)
	if self.data.type==6 then
	minesSp:setScale(0.8)
	end
	minesSp:setAnchorPoint(ccp(0.5,0.5))
	minesSp:setPosition(self.spWorldPos.x-self.layerMovePos.x,self.spWorldPos.y-self.layerMovePos.y)
	mineLayer:addChild(minesSp)

	self:baseShowLvTip(minesSp,self.data)

	self.time=math.sqrt(self.layerMovePos.x*self.layerMovePos.x+self.layerMovePos.y*self.layerMovePos.y)/400

	local moveby=CCMoveBy:create(self.time,self.layerMovePos)
	mineLayer:runAction(moveby)
end

function alienMinesSmallDialog:baseShowLvTip(baseSp,vv)
	 -- 显示保护罩
    local showProtectSp=false

    if vv.ptEndTime>base.serverTime then
        showProtectSp=true
    end

    if showProtectSp==true then
       local protectedSp=CCSprite:createWithSpriteFrameName("ShieldingShape.png")
       protectedSp:setAnchorPoint(ccp(0.5,0.5))
       protectedSp:setPosition(ccp(baseSp:getContentSize().width/2,baseSp:getContentSize().height/2))
       baseSp:addChild(protectedSp)
       protectedSp:setTag(111)
       protectedSp:setScale(1.5)
    end           

    -- if baseSp:getChildByTag(101)~=nil then
    --     tolua.cast(baseSp:getChildByTag(101),"CCSprite"):removeFromParentAndCleanup(true)
    -- end
   
    local lvTip 

    lvTip=CCSprite:createWithSpriteFrameName("IconLevel.png")

    local lvLb=GetTTFLabel(vv.level,25)

    lvLb:setPosition(ccp(lvTip:getContentSize().width/2,lvTip:getContentSize().height/2))

    lvTip:setScale(0.7)
    lvTip:addChild(lvLb)
    lvTip:setAnchorPoint(ccp(0.5,0.5))
    lvTip:setPosition(ccp(baseSp:getContentSize().width/2-5,baseSp:getContentSize().height))
    baseSp:addChild(lvTip,1)
    lvTip:setTag(101)

    -- vv.oid=playerVoApi:getUid()
    local addH=15
    local baseWidth=baseSp:getContentSize().width/2
    if vv.oid==playerVoApi:getUid() then
        -- print("+++++++++++++自己")
        local nameStr = playerVoApi:getPlayerName()
        local nameLb = GetTTFLabel(nameStr, 22)

        local function click()
        end
        local barSprie = LuaCCScale9Sprite:createWithSpriteFrameName("alien_mines_allybg.png", CCRect(15,8,153,28),click)
        barSprie:setContentSize(CCSizeMake(nameLb:getContentSize().width+20, nameLb:getContentSize().height+10))
        barSprie:setPosition(ccp(baseSp:getContentSize().width/2,-barSprie:getContentSize().height/2+addH))
        baseSp:addChild(barSprie)

        barSprie:addChild(nameLb)
        nameLb:setPosition(barSprie:getContentSize().width/2, barSprie:getContentSize().height/2)

        local alliance =  allianceVoApi:getSelfAlliance()
        local allianceSp
        if alliance==nil or SizeOfTable(alliance)==0 then
            barSprie:setAnchorPoint(ccp(0.5,0.5))
        else
            barSprie:setAnchorPoint(ccp(0.5,0.5))
            barSprie:setPositionX(baseSp:getContentSize().width/2+5)
            if base.isAf == 1 then
                local defaultSelect = allianceVoApi:getFlagIconTab(alliance.banner)
                allianceSp = allianceVoApi:createShowFlag(defaultSelect[1], defaultSelect[2], defaultSelect[3], 0.2)
                allianceSp:setPosition(ccp(baseWidth-barSprie:getContentSize().width/2-20,-barSprie:getContentSize().height/2+addH-5))
            else
                allianceSp=CCSprite:createWithSpriteFrameName("ArmyGroupIcon.png")
                allianceSp:setAnchorPoint(ccp(1,0.5))
                allianceSp:setPosition(ccp(baseWidth-barSprie:getContentSize().width/2,-barSprie:getContentSize().height/2+addH))
            end
            baseSp:addChild(allianceSp)
        end

    else
       
        if vv.name==nil or vv.name==""  then
            -- print("+++++++++++++++空地")
        else
            local alliance =  allianceVoApi:getSelfAlliance()

            local nameStr = vv.name
            local nameLb = GetTTFLabel(nameStr, 22)

            local function click()
            end

            local barSprie
            if alliance and vv.allianceName and alliance.name==vv.allianceName then
                barSprie = LuaCCScale9Sprite:createWithSpriteFrameName("alien_mines_allybg.png", CCRect(15,8,153,28),click)
            else
                barSprie = LuaCCScale9Sprite:createWithSpriteFrameName("alien_mines_enemybg.png", CCRect(15,8,153,28),click)
            end
            barSprie:setContentSize(CCSizeMake(nameLb:getContentSize().width+20, nameLb:getContentSize().height+10))
            barSprie:setPosition(ccp(baseSp:getContentSize().width/2,-barSprie:getContentSize().height/2+addH))
            baseSp:addChild(barSprie)

            barSprie:addChild(nameLb)
            nameLb:setPosition(barSprie:getContentSize().width/2, barSprie:getContentSize().height/2)

            barSprie:setAnchorPoint(ccp(0.5,0.5))
            
            if alliance==nil or SizeOfTable(alliance)==0 then
                -- if vv.allianceName~=nil and vv.allianceName~="" then
                    barSprie:setPositionX(baseSp:getContentSize().width/2+5)
                    local allianceSp=CCSprite:createWithSpriteFrameName("alien_mines_enemy.png")
                    allianceSp:setAnchorPoint(ccp(1,0.5))
                    allianceSp:setPosition(ccp(baseWidth-barSprie:getContentSize().width/2,-barSprie:getContentSize().height/2+addH))
                    baseSp:addChild(allianceSp)
                -- end
            else
                -- if vv.allianceName==nil or vv.allianceName=="" then
                -- else
                    local allianceSp
                    barSprie:setPositionX(baseSp:getContentSize().width/2+5)
                    if vv.allianceName==alliance.name then
                        if base.isAf == 1 then
                            local defaultSelect = allianceVoApi:getFlagIconTab(alliance.banner)
                            allianceSp = allianceVoApi:createShowFlag(defaultSelect[1], defaultSelect[2], defaultSelect[3], 0.2)
                            allianceSp:setPosition(ccp(baseWidth-barSprie:getContentSize().width/2-20,-barSprie:getContentSize().height/2+addH-5))
                        else
                            allianceSp=CCSprite:createWithSpriteFrameName("ArmyGroupIcon.png") 
                            allianceSp:setAnchorPoint(ccp(1,0.5))
                            allianceSp:setPosition(ccp(baseWidth-barSprie:getContentSize().width/2,-barSprie:getContentSize().height/2+addH))
                        end
                    else
                        allianceSp=CCSprite:createWithSpriteFrameName("alien_mines_enemy.png")
                        allianceSp:setAnchorPoint(ccp(1,0.5))
                        allianceSp:setPosition(ccp(baseWidth-barSprie:getContentSize().width/2,-barSprie:getContentSize().height/2+addH))
                    end
                    -- allianceSp:setAnchorPoint(ccp(1,0.5))
                    baseSp:addChild(allianceSp)
                -- end
            end
        end
    end
end

--侦察
function alienMinesSmallDialog:scout()
	-- if self.data.oid==playerVoApi:getUid() then
	-- 	smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("city_info_cant_scout_tip"),true,4)
	-- 	do return end
	-- end
	--判断被保护
	if self.data.ptEndTime>=base.serverTime then
		smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("playerhavenoFightBuffview"),true,self.layerNum+1)
		do return end
	end
	local scoutRes=tonumber(mapCfg.scoutConsume[self.data.level]) or 0
	local function callBack()
		if playerVoApi:getGold()>=scoutRes then
			local function mapScoutHandler(fn,data)
				local cresult,retTb=base:checkServerData(data)
				if cresult==true then
					local layerNum=self.layerNum
					self:realClose()
					local reportTb
					if retTb.data.mail and retTb.data.mail.alienreport then
						reportTb=retTb.data.mail.alienreport
					end

					-- 敌人的话侦察信息存起来
					if self.type==3 then
						local dataKey="alienMine@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
						local str = CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
						local alienMineTb={}

						-- 第一个存时间戳
						if str==nil or str=="" then
							alienMineTb[tostring(1)]=retTb.ts
						else
							alienMineTb=G_Json.decode(tostring(str))
							local startTime,endTime = alienMinesVoApi:getBeginAndEndtime()
							local myTs=(endTime[1]-startTime[1])*3600+(endTime[2]-startTime[2])*60
							if base.serverTime-tonumber(alienMineTb[tostring(1)])<myTs then
							else
								alienMineTb={}
								alienMineTb[tostring(1)]=retTb.ts

							end
						end

						
						

						-- 第100*x+y 的[1]存name [2]存资源量
						alienMineTb[tostring(100*self.data.x+self.data.y)]={}
						alienMineTb[tostring(100*self.data.x+self.data.y)][tostring(1)]=self.data.name
						local num=0
						if reportTb[1] and reportTb[1].content and reportTb[1].content.resource and reportTb[1].content.resource.collect then
							num=reportTb[1].content.resource.collect.r4 or 0
						end
						alienMineTb[tostring(100*self.data.x+self.data.y)][tostring(2)]=num

						local strTb=G_Json.encode(alienMineTb)

						CCUserDefault:sharedUserDefault():setStringForKey(dataKey,strTb)
			            CCUserDefault:sharedUserDefault():flush()

					end
					
					if reportTb then
						local eid
						for k,v in pairs(reportTb) do
							eid=v.eid
						end
						if eid then
							-- require "luascript/script/game/scene/gamedialog/alienMines/alienMinesEmailDetailDialog"
							-- local td=alienMinesEmailDetailDialog:new(layerNum,4,eid)
							require "luascript/script/game/scene/gamedialog/alienMines/alienMinesReportDetailDialog"
							local td=alienMinesReportDetailDialog:new(layerNum,eid)
							local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("scout_content_scout_title"),false,layerNum)
							sceneGame:addChild(dialog,layerNum)
						end
					end
				end
			end
			local target={x=self.data.x,y=self.data.y}
			socketHelper:alienMinesScout(target,mapScoutHandler)
		else
			smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("reputation_scene_money_require"),true,self.layerNum+1)
		end
	end
	smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,getlocal("dialog_title_prompt"),getlocal("city_info_scout_tip",{scoutRes}),nil,self.layerNum+1)
end

--进攻
function alienMinesSmallDialog:attack(flag)
	alienMinesVoApi:showAttackDialog(flag,self.data,self.layerNum,self)
	self:realClose()
end

function alienMinesSmallDialog:dispose()
	local mineLyer = tolua.cast(sceneGame:getChildByTag(168),"CCLayer")
	if mineLyer then
		mineLyer:removeFromParentAndCleanup(true)
	end
	local myLayer = tolua.cast(sceneGame:getChildByTag(169),"CCLayer")
	if myLayer then
		myLayer:removeFromParentAndCleanup(true)
	end
	self.parent=nil
	self.layerNum=nil
	self.spWorldPos=nil
	self.layerMovePos=nil
	self.dialogWidth=550
	self.dialogHeight=730
	self.type=nil
	self.data=nil
	self.flag=nil
end


