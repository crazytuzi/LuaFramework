worldBaseSmallDialog=smallDialog:new()

--param type: 面板类型, 1是自己, 2是玩家, 3是矿点
--param data: 数据, 坐标 ID等
--param extra: 额外的数据
function worldBaseSmallDialog:new(type,data,extra)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogWidth=550
	self.dialogHeight=730

	self.type=type
	self.data=data
	self.extra=extra

	if (self.type ==2 or self.type ==1 )and base.isGlory ==1 then
		self.dialogHeight =780
	end

	--如果是自己的话, 就把坐标修正为playerVo的xy, 防止搬家之后由于数据没有刷新造成的bug
	if(self.type==1)then
		self.data.x=playerVoApi:getMapX()
		self.data.y=playerVoApi:getMapY()
	end
	self.data.x=tonumber(self.data.x)
	self.data.y=tonumber(self.data.y)

	self.groundList={}
	return nc
end

function worldBaseSmallDialog:init(layerNum)
    local flag,goldMineLv=goldMineVoApi:isGoldMine(self.data.id)
    self.isPrivateMineFlag = privateMineVoApi:isPrivateMine(self.data.id)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/world_ground.plist")
	self.isTouch=nil
	self.layerNum=layerNum
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	local function close()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(self.dialogWidth-closeBtnItem:getContentSize().width,self.dialogHeight-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)
	
	local titleStr
	if(self.type==1)then
		titleStr=getlocal("city_info_myIsland")
	else
		titleStr=getlocal("city_info_targetInfo")
	end
	local titleLb=GetTTFLabel(titleStr,32,true)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-titleLb:getContentSize().height-5))
	dialogBg:addChild(titleLb,1)
    
    local mineRichLv=self.data.richLv
   	local rLv=worldBaseVoApi:getRichLv(self.data.id)
    if rLv>0 then
        mineRichLv=rLv
    end
	--左上角的头像
	if self.data.pic and self.data.pic~=0 and self.type~=3 then
		--local personPhotoName="photo"..self.data.pic..".png"
		--local playerPic = GetBgIcon(personPhotoName)
        local mypic =self.data.pic
        local mybpic = self.data.bpic
        if self.data.oid==playerVoApi:getUid() then
            mypic=playerVoApi:getPic()
            mybpic=playerVoApi:getHfid()
        end
        local personPhotoName=playerVoApi:getPersonPhotoName(mypic)
        local playerPic = playerVoApi:GetPlayerBgIcon(personPhotoName,nil,nil,nil,nil,mybpic)
		playerPic:setAnchorPoint(ccp(0,1))
		playerPic:setPosition(ccp(10,self.dialogHeight-5))
		dialogBg:addChild(playerPic,1)
	end
	if(self.type==3 and base.richMineOpen==1)then
		local function showInfo()
			PlayEffect(audioCfg.mouseClick)
			local tabStr={"\n",getlocal("richMine_info4"),"\n",getlocal("richMine_info3"),"\n",getlocal("richMine_info2"),"\n",getlocal("richMine_info1"),"\n"}
			local tabColor ={G_ColorYellowPro,G_ColorYellowPro,G_ColorYellowPro,G_ColorYellowPro,G_ColorYellowPro,G_ColorYellowPro,G_ColorYellowPro,G_ColorYellowPro,G_ColorYellowPro}
			local td=smallDialog:new()
			local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,20,tabColor)
			sceneGame:addChild(dialog,self.layerNum+1)
		end
		local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfo,11,nil,nil)
		-- infoItem:setScale(0.8)
		infoItem:setAnchorPoint(ccp(0,0))
		local infoBtn = CCMenu:createWithItem(infoItem)
		infoBtn:setPosition(ccp(20,self.dialogHeight-infoItem:getContentSize().height-20))
		infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		dialogBg:addChild(infoBtn,3)
	end

	local posY=self.dialogHeight-130

	--名字
	local nameStr
    local StrWidth
    local nameColor=G_ColorWhite
	local rank=tonumber(self.data.rank)
	if rank==nil or rank==0 then
		rank=1
	end
	if(self.type==1)then
		nameStr=getlocal("player_message_info_name",{playerVoApi:getPlayerName(),playerVoApi:getPlayerLevel(),playerVoApi:getRankName(tonumber(rank))})
        StrWidth=dialogBg:getContentSize().width-20
	elseif(self.type==2)then
		nameStr=getlocal("player_message_info_name",{self.data.name,self.data.level,playerVoApi:getRankName(rank)})
        StrWidth=dialogBg:getContentSize().width-180
	else
		-- local occupied=(self.data.oid and self.data.oid>0)
		if flag==true then
			local mineName=worldBaseVoApi:getMineNameByType(self.data.type)
			nameStr=getlocal("bountiful")..mineName..getlocal("city_info_level",{goldMineLv})
			nameColor=G_ColorYellowPro
		elseif mineRichLv and mineRichLv>0 then
			nameStr=getlocal("world_island_"..(self.data.type))..getlocal("city_info_level",{self.data.curLv})
			nameColor=worldBaseVoApi:getRichMineColorByLv(mineRichLv)
		else
			nameStr=getlocal("world_island_"..(self.data.type))..getlocal("city_info_level",{self.data.curLv})
		end
        StrWidth=dialogBg:getContentSize().width-20
	end
	local strSize2 = 28
	if mineRichLv and mineRichLv>0 then
		if G_getCurChoseLanguage() =="ar" or G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" then 
			StrWidth =260
	    	strSize2 =22
	    end
	elseif G_getCurChoseLanguage() =="ar" or G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" then 
		StrWidth =300
        strSize2 =24
	end
	strSize2=20

	local nameLb=GetTTFLabelWrap(nameStr,strSize2,CCSizeMake(StrWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	nameLb:setAnchorPoint(ccp(0,0.5))
	nameLb:setPosition(ccp(30,posY-5))
	nameLb:setColor(nameColor)
	dialogBg:addChild(nameLb)
	local realW=nameLb:getContentSize().width
	local tmpNameLb=GetTTFLabel(nameStr,strSize2)
	if realW>tmpNameLb:getContentSize().width then
		realW=tmpNameLb:getContentSize().width
	end
	local resIcon,resAddLb
	if(self.type==3 and base.landFormOpen==1 and base.richMineOpen==1)then
		-- local occupied=(self.data.oid and self.data.oid>0)
		if((flag==true and goldMineLv>0) or mineRichLv>0)then
			local baseAdd=0
			local mineColor=G_ColorWhite
			if flag==true and goldMineLv>0 then
				baseAdd=goldMineVoApi:getGoldMineAdd()
				mineColor=G_ColorYellowPro
			elseif mineRichLv>0 then
				baseAdd=worldBaseVoApi:getRichMineAdd(mineRichLv)*100
				mineColor=worldBaseVoApi:getRichMineColorByLv(mineRichLv)
			end
			local resIconName=worldBaseVoApi:getBaseResPicName(self.data.type)
			if(resIconName)then
				resIcon=CCSprite:createWithSpriteFrameName(resIconName)
				resIcon:setAnchorPoint(ccp(0,0.5))
				resIcon:setPosition(ccp(self.dialogWidth-180,nameLb:getPositionY()))
				resIcon:setScale(1.2)
				dialogBg:addChild(resIcon)
				resAddLb=GetTTFLabel("x"..baseAdd.."%",25)
				resAddLb:setAnchorPoint(ccp(0,0.5))
				resAddLb:setPosition(ccp(self.dialogWidth-120,nameLb:getPositionY()))
				resAddLb:setColor(mineColor)
				dialogBg:addChild(resAddLb)
			end
		end
	end

	if self.type==2 or self.type==3 then
		local function onShowDetail()
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			if(self.type==2)then
				self:showPlayerDetail()
			elseif self.type==3 then
	  	        require "luascript/script/game/scene/gamedialog/mineSmallDialog"
		        -- local layerNum=3
		        -- local occupied=(self.data.oid and self.data.oid>0)
		        local dataTb=worldBaseVoApi:getMineResContent(tonumber(self.data.type),tonumber(self.data.curLv),tonumber(mineRichLv),tonumber(goldMineLv),false)
		        smallDialog:showMineInfoDialog("TaskHeaderBg.png",CCSizeMake(500,750),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),dataTb,nil,true,true,self.layerNum+1)
			end
		end
		local detailItem=GetButtonItem("worldBtnInfor.png","worldBtnInfor_Down.png","worldBtnInfor.png",onShowDetail,2,nil,25)
		detailItem:setScale(0.9)
		local detailBtn=CCMenu:createWithItem(detailItem)
		detailBtn:setPosition(ccp(self.dialogWidth-detailItem:getContentSize().width/2-10,posY))
		detailBtn:setTouchPriority(-(layerNum-1)*20-2)
		dialogBg:addChild(detailBtn)
	end
	
	posY=posY-40

	local lineSp1=CCSprite:createWithSpriteFrameName("LineEntity.png")
	lineSp1:setAnchorPoint(ccp(0.5,0.5))
	lineSp1:setPosition(dialogBg:getContentSize().width/2,posY)
	lineSp1:setScaleY(3)
	lineSp1:setScaleX((self.bgLayer:getContentSize().width-60)/lineSp1:getContentSize().width)
	dialogBg:addChild(lineSp1)

	posY=posY-40

	local posLb=GetTTFLabel(getlocal("city_info_coordinate").."  "..getlocal("city_info_coordinate_style",{self.data.x,self.data.y}),20)
	posLb:setAnchorPoint(ccp(0,0.5))
	posLb:setPosition(ccp(30,posY))
	dialogBg:addChild(posLb)

	if(self.type~=1)then
		local function onFavor()
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			self:addToFavor()
		end
		local favorItem=GetButtonItem("worldBtnCollection.png","worldBtnCollection_Down.png","worldBtnCollection.png",onFavor,2,nil,25)
		favorItem:setScale(0.9)
		local favorBtn=CCMenu:createWithItem(favorItem)
		favorBtn:setPosition(ccp(self.dialogWidth-favorItem:getContentSize().width/2-10,posY))
		favorBtn:setTouchPriority(-(layerNum-1)*20-2)
		dialogBg:addChild(favorBtn)
	end

	posY=posY-40

	local lineSp2=CCSprite:createWithSpriteFrameName("LineEntity.png")
	lineSp2:setAnchorPoint(ccp(0.5,0.5))
	lineSp2:setPosition(dialogBg:getContentSize().width/2,posY)
	lineSp2:setScaleY(3)
	lineSp2:setScaleX((self.bgLayer:getContentSize().width-60)/lineSp2:getContentSize().width)
	dialogBg:addChild(lineSp2)

	local buildPicName,isSkin=worldBaseVoApi:getBaseResource(self.data.type,self.data.curLv,self.data.oid,nil,self.data.skinInfo)
	local buildSp = CCSprite:createWithSpriteFrameName(buildPicName)
    buildSp:setScale(0.5)
    buildSp:setAnchorPoint(ccp(0.5,0.5))

	local buildIcon = CCNode:create()
	buildIcon:setAnchorPoint(ccp(0,0.5))
	if self.type>=1 and self.type<=5 then
		buildIcon:setContentSize(CCSizeMake(buildSp:getContentSize().width*0.7,buildSp:getContentSize().height/2))
	else
		buildIcon:setContentSize(CCSizeMake(buildSp:getContentSize().width/2,buildSp:getContentSize().height/2))
	end
    buildIcon:setPosition(ccp(5,lineSp1:getPositionY()))
    buildIcon:addChild(buildSp)
    buildSp:setPosition(getCenterPoint(buildIcon))
    if isSkin and (isSkin == "b11" or isSkin == "b12" or isSkin == "b13") then
    	buildSp:setPositionY(buildSp:getPositionY() - 45)
    	buildSp:setScale(0.4)
    	local buildingPic = exteriorCfg.exteriorLit[isSkin].decorateSp
		if isSkin =="b11" then
			G_buildingAction1(buildingPic,buildSp,nil,nil,nil)
		elseif isSkin =="b12" then
			G_buildingAction2(buildingPic,buildSp,nil,nil,nil)
		else
			G_buildingAction3(buildingPic,buildSp,nil,nil,nil)
		end

	end

    dialogBg:addChild(buildIcon)
    if flag==true and goldMineLv>0 then
      	local starAni=CCParticleSystemQuad:create("public/fukuang.plist")
        starAni:setPosition(buildIcon:getContentSize().width/2,buildIcon:getContentSize().height/2-20)
        starAni:setScale(1.5)
        starAni:setPositionType(kCCPositionTypeGrouped)
        buildIcon:addChild(starAni)
    end
    if self.data.type==6 then --查看的玩家基地信息
    	--ba={}, 每日被其他玩家无视保护罩戏谑攻击次数(飞机主动技能s20){n=0,t=0}{次数,时间}
    	if self.extra and self.extra.flags and self.extra.flags.ba then
    		local ba=self.extra.flags.ba
    		local nscfg=planeVoApi:getNewSkillCfg()
    		if (ba.n or 0)>=nscfg.protectLimit and ba.t and G_isToday(ba.t) then --如果当天已经达到了被戏谑次数的话，该玩家处于戏谑保护中
    			local textWidth,textHeight=120,30
    			local tipLb=GetTTFLabelWrap(getlocal("playerSkillProtectStr"),22,CCSizeMake(textWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    			tipLb:setPosition(buildIcon:getPositionX()+buildIcon:getContentSize().width/2,buildIcon:getPositionY()-buildIcon:getContentSize().height/2+10)
    			dialogBg:addChild(tipLb,5)
    			local tmpLb=GetTTFLabel(getlocal("playerSkillProtectStr"),22)
    			local realW=tmpLb:getContentSize().width
    			if realW>textWidth then
    				realW=textWidth
    			end
    			local tipBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")
			    tipBg:setScaleX((realW+20)/tipBg:getContentSize().width)
			    tipBg:setScaleY(textHeight/tipBg:getContentSize().height)
			    tipBg:setPosition(tipLb:getPosition())
			    dialogBg:addChild(tipBg,3)
    		end
    	end
    end
    local buildW=buildIcon:getContentSize().width
    local fx=-30
    if self.data.type==2 then --油井的图大小跟其他矿点不一样，则特殊处理
    	fx=0
    end
    nameLb:setPositionX(nameLb:getPositionX()+buildW+fx)
    if resIcon and resAddLb then
    	resIcon:setPositionX(nameLb:getPositionX()+realW+5)
    	resAddLb:setPositionX(resIcon:getPositionX()+resIcon:getContentSize().width*resIcon:getScale()+5)
    end
    posLb:setPositionX(posLb:getPositionX()+buildW+fx)
    lineSp1:setPositionX((dialogBg:getContentSize().width+buildW+fx)/2)
    lineSp2:setPositionX((dialogBg:getContentSize().width+buildW+fx)/2)
    lineSp1:setScaleX((self.bgLayer:getContentSize().width-60-buildW-fx)/lineSp1:getContentSize().width)
    lineSp2:setScaleX((self.bgLayer:getContentSize().width-60-buildW-fx)/lineSp1:getContentSize().width)

	posY=posY-20

	if (self.type ==2 or self.type ==1 )and base.isGlory ==1 then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
		local boom = 0
		local boomMax = 0
		local level = 0
		local progressPic = nil
		if self.type ==1 then
			level,boom,boomMax = gloryVoApi:getPlayerCurGloryWithLevel( )
		elseif self.extra and self.extra.boomData and self.extra.boomData.bmax then --玩家城市的繁荣度信息
			boomMax=self.extra.boomData.bmax
			boom=gloryVoApi:computePlayerGlory(self.extra.boomData.boom,self.extra.boomData.bm_at,boomMax)
		else
			boom =self.data.boom or 0
			boomMax =self.data.boomMax
		end

		local percentStr=tostring(math.floor(boom/boomMax*100)).."%"
		if boomMax ==0 then
			-- print("in boomMax----->",boomMax)
	    	percentStr ="100%"
	    end
		local lb =getlocal("gloryDegreeStr")..":"..percentStr
		local per = tonumber(boom)/tonumber(boomMax) * 100
		AddProgramTimer(dialogBg,ccp(dialogBg:getContentSize().width/2,posY-10),999,12,lb,"platWarProgressBg.png","platWarProgress2.png",13,1,1.2)
	    local timerSpriteLv = dialogBg:getChildByTag(999)------------------
	    timerSpriteLvBg = dialogBg:getChildByTag(13)
	    timerSpriteLvBg:setScaleX((dialogBg:getContentSize().width-40)/timerSpriteLvBg:getContentSize().width)
	    timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
	    timerSpriteLv:setMidpoint(ccp(0,0))
	    -- print("per---->",per)
	    timerSpriteLv:setPercentage(per)
	    timerSpriteLv:setScaleX((dialogBg:getContentSize().width-45)/timerSpriteLv:getContentSize().width)
	    timerSpriteLv:setScaleY(1.2)
	    local lb = tolua.cast(timerSpriteLv:getChildByTag(12),"CCLabelTTF")
	    lb:setString(getlocal("gloryDegreeStr")..":"..percentStr)
	    lb:setScaleY(0.8)
	    lb:setScaleX(timerSpriteLv:getContentSize().width/(dialogBg:getContentSize().width-40))
		posY =posY - 60
	end
	local tipLb1=GetTTFLabel(getlocal("world_ground_tip1"),20)
	tipLb1:setAnchorPoint(ccp(0.5,0.5))
	tipLb1:setPosition(ccp(dialogBg:getContentSize().width/2,posY))
	dialogBg:addChild(tipLb1)

	-- local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
	-- infoItem:setScale(0.8)
	-- infoItem:setAnchorPoint(ccp(1,1))
	-- local infoBtn = CCMenu:createWithItem(infoItem);
	-- infoBtn:setAnchorPoint(ccp(1,1))
	-- infoBtn:setPosition(ccp(G_VisibleSizeWidth-35,(G_VisibleSizeHeight-160)/3+105))
	-- infoBtn:setTouchPriority(-(self.layerNum-1)*20-3);
	-- self.bgLayer:addChild(infoBtn,3);

	posY=posY-55
	for i=1,9 do
		local groundX,groundY=self:getPositionByIndex(i)
		local gType=worldBaseVoApi:getGroundType(groundX,groundY)
		local function showGroundDetail()
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			if(gType)then
				local tabStr={}
				local tabColor={}
				local td=smallDialog:new()
				local attackCfg=worldGroundCfg[gType]
				for k,v in pairs(attackCfg.attType) do
					local valueStr
					if(attackCfg.attValue[k]>0)then
						valueStr="+"..attackCfg.attValue[k]
						table.insert(tabColor,1,G_ColorGreen)
					else
						valueStr=attackCfg.attValue[k]
						table.insert(tabColor,1,G_ColorRed)
					end
					table.insert(tabColor,1,G_ColorWhite)
					table.insert(tabStr,1,getlocal("world_ground_effect_"..v).." "..valueStr.."%")
					table.insert(tabStr,1,"\n")
				end
				local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor,getlocal("world_ground_name_"..gType).." ("..groundX..","..groundY..")")
				sceneGame:addChild(dialog,self.layerNum+1)
			else
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("world_ground_no_ground"),30)
			end
		end
		local groundBg
		if(i==5)then
			groundBg=LuaCCScale9Sprite:createWithSpriteFrameName("rank1ItemBg.png",CCRect(20,20,10,10),showGroundDetail)
		else
			groundBg=LuaCCScale9Sprite:createWithSpriteFrameName("TeamTankNumBg.png",CCRect(20,20,10,10),showGroundDetail)
		end
		groundBg:setTouchPriority(-(self.layerNum-1)*20-2)
		groundBg:setContentSize(CCSizeMake(120,65))
		local tmpX=(i-1)%3*125+150
		local tmpY=posY-math.floor((i-1)/3)*70
		groundBg:setPosition(ccp(tmpX,tmpY))

		local groundIcon
		if(gType==nil)then
			groundIcon=CCSprite:createWithSpriteFrameName("world_ground_0.png")
		else
			groundIcon=CCSprite:createWithSpriteFrameName("world_ground_"..gType..".png")
		end
		groundIcon:setPosition(ccp(groundBg:getContentSize().width/2,groundBg:getContentSize().height/2-5))
		groundBg:addChild(groundIcon)

		self.groundList[i]=groundBg
		dialogBg:addChild(groundBg)
	end
	if(self.type~=1)then
		self:setArrow()
	end

	posY=posY-210
	local buffDesc
	if(self.type~=1)then
		buffDesc=getlocal("world_ground_buff_title")
	else
		buffDesc=getlocal("world_ground_buff_title_self")
	end
	local buffDescLb=GetTTFLabelWrap(buffDesc,20,CCSizeMake(self.dialogWidth-140,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	buffDescLb:setAnchorPoint(ccp(0,0.5))
	buffDescLb:setPosition(ccp(90,posY))
	dialogBg:addChild(buffDescLb)

	posY=posY-45
	local attackCfg=worldBaseVoApi:getAttackGroundCfg(self.data.x,self.data.y)
	for k,v in pairs(attackCfg.attType) do
		local buffLb=GetTTFLabel(getlocal("world_ground_effect_"..v),20)
		buffLb:setAnchorPoint(ccp(0,0.5))
		buffLb:setPosition(ccp(90,posY))
		dialogBg:addChild(buffLb)

		local buffValue=attackCfg.attValue[k].."%"
		if(attackCfg.attValue[k]>=0)then
			buffValue="+"..buffValue
		end
		local buffValueLb=GetTTFLabel(buffValue,20)
		if(attackCfg.attValue[k]>0)then
			buffValueLb:setColor(G_ColorGreen)
		elseif(attackCfg.attValue[k]<0)then
			buffValueLb:setColor(G_ColorRed)
		end
		buffValueLb:setAnchorPoint(ccp(0,0.5))
		buffValueLb:setPosition(ccp(105+buffLb:getContentSize().width,posY))
		dialogBg:addChild(buffValueLb)
		posY=posY-30
	end

	posY=posY-30
	if(self.type~=1)then
		local function onScout()
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			self:scout()
		end
		local scoutItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onScout,2,getlocal("city_info_scout"),24,101)
		scoutItem:setScale(0.8)
		local lb = scoutItem:getChildByTag(101)
		if lb then
			lb = tolua.cast(lb,"CCLabelTTF")
			lb:setFontName("Helvetica-bold")
		end
		local scoutBtn=CCMenu:createWithItem(scoutItem)
		scoutBtn:setPosition(ccp(self.dialogWidth/2-120,posY))
		scoutBtn:setTouchPriority(-(layerNum-1)*20-2)
		dialogBg:addChild(scoutBtn)

		local function onClickRightBtn()
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			if self.data.allianceName and allianceVoApi:isSameAlliance(self.data.allianceName) then
				self:help()
			else
				self:attack()
			end
		end
		local rightStr
		if self.data.allianceName and allianceVoApi:isSameAlliance(self.data.allianceName) then
			rightStr=getlocal("city_info_doubleCover")
		else
			rightStr=getlocal("city_info_attack")
		end
		local rightItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onClickRightBtn,2,rightStr,24,101)
		rightItem:setScale(0.8)
		local lb = rightItem:getChildByTag(101)
		if lb then
			lb = tolua.cast(lb,"CCLabelTTF")
			lb:setFontName("Helvetica-bold")
		end
		local rightBtn=CCMenu:createWithItem(rightItem)
		rightBtn:setPosition(ccp(self.dialogWidth/2+120,posY))
		rightBtn:setTouchPriority(-(layerNum-1)*20-2)
		dialogBg:addChild(rightBtn)
	else
		local function onEnterBase()
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			self:enterBase()
		end
		local function onEnterSkin( ... )
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			self:enterSkin()
		end
		local enterItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onEnterBase,2,getlocal("city_info_enterPort"),24,101)
		if base.isSkin == 1 and playerVoApi:getPlayerLevel() >= buildDecorateVoApi:getLevelLimit() then
			local skinItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onEnterSkin,2,getlocal("decorateTitle"),24,101)
			skinItem:setScale(0.8)
			local skinBtn=CCMenu:createWithItem(skinItem)
			skinBtn:setPosition(ccp(self.dialogWidth/4,posY))
			skinBtn:setTouchPriority(-(layerNum-1)*20-2)
			dialogBg:addChild(skinBtn)
			local lb1 = skinItem:getChildByTag(101)
			if lb1 then
				lb1 = tolua.cast(lb1,"CCLabelTTF")
				lb1:setFontName("Helvetica-bold")
			end
		end
		enterItem:setScale(0.8)
		local lb = enterItem:getChildByTag(101)
		if lb then
			lb = tolua.cast(lb,"CCLabelTTF")
			lb:setFontName("Helvetica-bold")
		end
		local enterBtn=CCMenu:createWithItem(enterItem)
		enterBtn:setPosition(ccp(self.dialogWidth*3/4,posY))
		enterBtn:setTouchPriority(-(layerNum-1)*20-2)
		dialogBg:addChild(enterBtn)

	end
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end

function worldBaseSmallDialog:getPositionByIndex(index)
	local groundX,groundY
	if(index==1)then
		groundX=self.data.x-1
		groundY=self.data.y-1
	elseif(index==2)then
		groundX=self.data.x
		groundY=self.data.y-1
	elseif(index==3)then
		groundX=self.data.x+1
		groundY=self.data.y-1
	elseif(index==4)then
		groundX=self.data.x-1
		groundY=self.data.y
	elseif(index==5)then
		groundX=self.data.x
		groundY=self.data.y
	elseif(index==6)then
		groundX=self.data.x+1
		groundY=self.data.y
	elseif(index==7)then
		groundX=self.data.x-1
		groundY=self.data.y+1
	elseif(index==8)then
		groundX=self.data.x
		groundY=self.data.y+1
	elseif(index==9)then
		groundX=self.data.x+1
		groundY=self.data.y+1
	end
	return groundX,groundY
end

function worldBaseSmallDialog:setArrow()
	local direction=worldBaseVoApi:getAttackDirection(self.data.x,self.data.y,playerVoApi:getMapX(),playerVoApi:getMapY())
	if(direction==nil)then
		do return end
	end
	local arrowSP=CCSprite:createWithSpriteFrameName("arrow_direction_"..direction..".png")
	if(arrowSP==nil)then
		local nameIndex=10-direction
		arrowSP=CCSprite:createWithSpriteFrameName("arrow_direction_"..nameIndex..".png")
		arrowSP:setRotation(180)
	end
	local bgPosX,bgPosY=self.groundList[direction]:getPosition()
	local bgSize=self.groundList[direction]:getContentSize()
	local posX,posY
	if(direction==1)then
		posX=bgPosX+bgSize.width/2
		posY=bgPosY-bgSize.height/2
	elseif(direction==2)then
		posX=bgPosX
		posY=bgPosY-bgSize.height/2
	elseif(direction==3)then
		posX=bgPosX-bgSize.width/2
		posY=bgPosY-bgSize.height/2
	elseif(direction==4)then
		posX=bgPosX+bgSize.width/2
		posY=bgPosY
	elseif(direction==5)then
		posX=bgPosX
		posY=bgPosY
	elseif(direction==6)then
		posX=bgPosX-bgSize.width/2
		posY=bgPosY
	elseif(direction==7)then
		posX=bgPosX+bgSize.width/2
		posY=bgPosY+bgSize.height/2
	elseif(direction==8)then
		posX=bgPosX
		posY=bgPosY+bgSize.height/2
	elseif(direction==9)then
		posX=bgPosX-bgSize.width/2
		posY=bgPosY+bgSize.height/2
	end
	arrowSP:setPosition(ccp(posX,posY))
	self.bgLayer:addChild(arrowSP)
end

--同军团协防
function worldBaseSmallDialog:help()
	--判断是否是盟友 同联盟
	if self.data.allianceName and allianceVoApi:isSameAlliance(self.data.allianceName) then
		--判断是否有能量
		if playerVoApi:getEnergy()<=0 then
			local function buyEnergy()
				G_buyEnergy(5)
			end
			smallDialog:showEnergySupplementDialog(4)
			do return end
		end
		self:realClose()
        require "luascript/script/game/scene/gamedialog/warDialog/tankAttackDialog"
		local td=tankAttackDialog:new(self.data.type,self.data,4)
		local tbArr={getlocal("AEFFighting"),getlocal("dispatchCard"),getlocal("repair")}
		local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("fleetCover"),true,7)
		sceneGame:addChild(dialog,4)
	else
		smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage5009"),true,4)
	end
end

function worldBaseSmallDialog:showPlayerDetail()
	require "luascript/script/game/scene/gamedialog/worldBaseSmallDetailDialog"
	local detailDialog=worldBaseSmallDetailDialog:new(self.data)
	detailDialog:init(self.layerNum+1)
end

--收藏
function worldBaseSmallDialog:addToFavor()
	self:realClose()
	local bookmarkTypeTab={0,0,0}
	local bookmarkType
	local function operateHandler(tag1,object)
		PlayEffect(audioCfg.mouseClick)
		local selectIndex=self.btnTab[tag1]:getSelectedIndex()
		if selectIndex==1 then
			bookmarkType=tag1
		else
			bookmarkType=0
		end
		bookmarkTypeTab[tag1]=bookmarkType
	end
	self.btnTab={}
	local tabBtn=CCMenu:create()
	for i=1,3 do
		local height=0
		local tabBtnItem
		if i==1 then
			local selectSp1 = CCSprite:createWithSpriteFrameName("worldBtnSelf.png")
			local selectSp2 = CCSprite:createWithSpriteFrameName("worldBtnSelf.png")
			local menuItemSp1 = CCMenuItemSprite:create(selectSp1,selectSp2)
			local selectSp3 = CCSprite:createWithSpriteFrameName("worldBtnSelf_Down.png")
			local selectSp4 = CCSprite:createWithSpriteFrameName("worldBtnSelf_Down.png")
			local menuItemSp2 = CCMenuItemSprite:create(selectSp3,selectSp4)
			tabBtnItem = CCMenuItemToggle:create(menuItemSp1)
			tabBtnItem:addSubItem(menuItemSp2)
			tabBtnItem:setPosition(0,height)
		elseif i==2 then
			local selectSp1 = CCSprite:createWithSpriteFrameName("worldBtnEnemy.png")
			local selectSp2 = CCSprite:createWithSpriteFrameName("worldBtnEnemy.png")
			local menuItemSp1 = CCMenuItemSprite:create(selectSp1,selectSp2)
			local selectSp3 = CCSprite:createWithSpriteFrameName("worldBtnEnemy_Down.png")
			local selectSp4 = CCSprite:createWithSpriteFrameName("worldBtnEnemy_Down.png")
			local menuItemSp2 = CCMenuItemSprite:create(selectSp3,selectSp4)
			tabBtnItem = CCMenuItemToggle:create(menuItemSp1)
			tabBtnItem:addSubItem(menuItemSp2)
			tabBtnItem:setPosition(160,height)
		elseif i==3 then
			local selectSp1 = CCSprite:createWithSpriteFrameName("worldBtnFriend.png")
			local selectSp2 = CCSprite:createWithSpriteFrameName("worldBtnFriend.png")
			local menuItemSp1 = CCMenuItemSprite:create(selectSp1,selectSp2)
			local selectSp3 = CCSprite:createWithSpriteFrameName("worldBtnFriend_Down.png")
			local selectSp4 = CCSprite:createWithSpriteFrameName("worldBtnFriend_Down.png")
			local menuItemSp2 = CCMenuItemSprite:create(selectSp3,selectSp4)
			tabBtnItem = CCMenuItemToggle:create(menuItemSp1)
			tabBtnItem:addSubItem(menuItemSp2)
			tabBtnItem:setPosition(320,height)
		end
		tabBtnItem:setAnchorPoint(CCPointMake(0,0))
		tabBtnItem:registerScriptTapHandler(operateHandler)
		tabBtnItem:setSelectedIndex(0)
		tabBtn:addChild(tabBtnItem)
		tabBtnItem:setTag(i)
		self.btnTab[i]=tabBtnItem
	end
	tabBtn:setPosition(ccp(70,20))
	local function returnHandler()
	end
	local function saveHandler()
		local maxNum=bookmarkVoApi:getMaxNum()
		if bookmarkVoApi:getBookmarkNum(0)>=maxNum then
			smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("collect_border_max_num",{maxNum}),nil,4)
			do return end
		end
		if bookmarkVoApi:isBookmark(self.data.x,self.data.y) then
			smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("collect_border_same_book_mark",{self.data.x,self.data.y}),nil,4)
			do return end
		end
		local ifAddToNoTag=true
		local desc=G_getIslandName(self.data.type,self.data.name)..getlocal("city_info_level",{self.data.level})
		local function serverSuperMark(fn,data)
			base:checkServerData(data)
		end
		socketHelper:markBookmark(bookmarkTypeTab,desc,self.data.x,self.data.y,serverSuperMark)
		return true
	end
	local title=getlocal("collect_border_title")
	local content1=getlocal("collect_border_siteInfo")
	local nameStr=G_getIslandName(self.data.type,self.data.name)
	local content2=getlocal("collect_border_name_loc",{nameStr,self.data.x,self.data.y})
	local content3=getlocal("collect_border_type")
	local content={{content1,30},{content2,25},{content3,30}}
	local leftStr=getlocal("collect_border_return")
	local rightStr=getlocal("collect_border_save")
	local itemTab={tabBtn}
	smallDialog:showPlayerInfoSmallDialog("PanelHeaderPopup.png",CCSizeMake(550,450),CCRect(0, 0, 400, 400),CCRect(168, 86, 10, 10),leftStr,returnHandler,rightStr,saveHandler,title,content,nil,3,5,itemTab,nil,nil,self.data.pic)
end

--侦察
function worldBaseSmallDialog:scout()
	if self.data.oid==playerVoApi:getUid() then
		smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("city_info_cant_scout_tip"),true,4)
		do return end
	end
	--判断被保护
	if self.data.ptEndTime>=base.serverTime then
		smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("playerhavenoFightBuffview"),true,4)
		do return end
	end
	local flag,goldMineLv=goldMineVoApi:isGoldMine(self.data.id)
    local level=self.data.curLv
    if flag==true and goldMineLv>0 then
		level=goldMineLv
    end
	if(base.sctlv==1 and self.type==3 and tonumber(level)>playerVoApi:getPlayerLevel() + 10)then
		smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("scout_lvNotEnough"),true,4)
		do return end
	end
	local scoutRes=tonumber(mapCfg.scoutConsume[level]) or 0
	local function callBack()
		if playerVoApi:getGold()>=scoutRes then
			local function mapScoutHandler(fn,data)
				local cresult,retTb=base:checkServerData(data)
				if cresult==true then
					if base.isCheckCode==1 then
						-- print("88888888812123123123131313")
						local checkcodeNum=CCUserDefault:sharedUserDefault():getIntegerForKey(G_checkCodeKey..playerVoApi:getUid())
				        CCUserDefault:sharedUserDefault():setIntegerForKey(G_checkCodeKey..playerVoApi:getUid(),(checkcodeNum+10))
				        CCUserDefault:sharedUserDefault():setIntegerForKey(G_lastMapscoutTime..playerVoApi:getUid(),base.serverTime)
                		CCUserDefault:sharedUserDefault():flush()
					end
					if(self.type==3 and base.richMineOpen==1)then
						local occupied=(self.data.oid and self.data.oid>0)
						local oldMineRichLv=mineRichLv
						if(retTb.data.mail and retTb.data.mail.report and retTb.data.mail.report[1] and retTb.data.mail.report[1].content and retTb.data.mail.report[1].content.info and retTb.data.mail.report[1].content.info.mapHeat)then
							local heatTime=tonumber(retTb.data.mail.report[1].content.info.mapHeat.ts)
							local heatPoint=tonumber(retTb.data.mail.report[1].content.info.mapHeat.point)
							if(heatTime and heatPoint)then
								local newMineRichLv=worldBaseVoApi:getRichMineLv(occupied,heatTime,heatPoint)
								if(newMineRichLv~=oldMineRichLv)then
									eventDispatcher:dispatchEvent("worldScene.mineChange",{{x=self.data.x,y=self.data.y}})
								end
							end
						end
					end
					self:realClose()
					local reportTb
					if retTb.data.mail and retTb.data.mail.report then
						reportTb=retTb.data.mail.report
					end
					if reportTb then
						local eid
						for k,v in pairs(reportTb) do
							eid=v.eid
						end
						if eid then
                            require "luascript/script/game/scene/gamedialog/emailDetailDialog"
							local layerNum=4
							local td=emailDetailDialog:new(layerNum,2,eid)
							local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("scout_content_scout_title"),false,layerNum)
							sceneGame:addChild(dialog,layerNum)
							--侦查到金矿或者富矿后将原先的矿刷成金矿或富矿
							local report=reportVoApi:getReport(eid) --获取侦查数据
							if report then
								local mine={mid=self.data.id,level=level,goldMineLv=report.goldMineLv,richLv=report.richLevel,disappearTime=report.disappearTime,x=self.data.x,y=self.data.y}
								worldBaseVoApi:resetWorldMine(mine)
							end
						end
					end
					if(skillVoApi:checkBaseScout(self.data.x,self.data.y) and skillVoApi:getEagleEyeTime())then
						local dataKey="eagleEyeRemove@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
						CCUserDefault:sharedUserDefault():setIntegerForKey(dataKey,skillVoApi:getEagleEyeTime())
						CCUserDefault:sharedUserDefault():flush()
						worldScene:refreshChangedMine()
						eventDispatcher:dispatchEvent("skill.eagleeye.change")
					end
				end
			end
			-- 验证码
			local function realMapScout()
				local target={x=self.data.x,y=self.data.y}
				socketHelper:mapScout(target,mapScoutHandler)
			end
			local function checkcodeHandler()
				if base.isCheckCode==1 then
					local function checkcodeSuccess(fn,data)
			        	local ret,sData = base:checkServerData(data)
						if ret==true then
							-- print("++++++++领取奖励成功++++++++")
                            --领取验证码奖励成功后再更新lastCheckcodeNum			
			                local checkcodeNum=CCUserDefault:sharedUserDefault():getIntegerForKey(G_checkCodeKey..playerVoApi:getUid())
                            CCUserDefault:sharedUserDefault():setIntegerForKey(G_lastCheckCodeKey..playerVoApi:getUid(),checkcodeNum)
                    		CCUserDefault:sharedUserDefault():flush()
							if sData and sData.data and sData.data.reward then
								local reward = FormatItem(sData.data.reward)
								local rewardStr=getlocal("daily_lotto_tip_10")
								if reward then
									for k,v in pairs(reward) do
										if k==SizeOfTable(reward) then
									        rewardStr = rewardStr .. v.name .. " x" .. v.num
									    else
									        rewardStr = rewardStr .. v.name .. " x" .. v.num .. ","
									    end
									end
									smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),rewardStr ,30)
								end
							end
						elseif sData.ret==-6010 then
							-- print("++++++++领取奖励失败++++++++")
                            CCUserDefault:sharedUserDefault():setIntegerForKey(G_checkCodeKey..playerVoApi:getUid(),G_maxCheckCount)
                            CCUserDefault:sharedUserDefault():setIntegerForKey(G_lastCheckCodeKey..playerVoApi:getUid(),G_maxCheckCount)
                    		CCUserDefault:sharedUserDefault():flush()
						end
			        	realMapScout()
			        end
			        socketHelper:checkcodereward(checkcodeSuccess)
			    end
			end
			
			if G_isCheckCode()==true then
				self:realClose()
				smallDialog:initCheckCodeDialog(self.layerNum+1,checkcodeHandler)
			else
				realMapScout()
			end
		else
			smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("reputation_scene_money_require"),true,4)
		end
	end
	smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,getlocal("dialog_title_prompt"),getlocal("city_info_scout_tip",{scoutRes}),nil,4)
end

--进攻
function worldBaseSmallDialog:attack()
	if self.isPrivateMineFlag and self.type == 3 then
		-- print "ready to attack~~~~~"
		local attackSlotsTb = attackTankSoltVoApi:getAllAttackTankSlots()
		local hadIdx = 0
		for k,v in pairs(attackSlotsTb) do
			if v.privateMine and v.bs == nil then
				hadIdx = hadIdx + 1
			end
			if hadIdx > 1 then
				do break end
			end
		end
		-- print("hadIdx===>>>",hadIdx)
		if hadIdx > 1 then
			smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("privateMineAttackNoMuch"),true,4)
			do return end
		end
	end
	--判断是否被占领
	if self.data.oid==playerVoApi:getUid() then
		smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("city_info_cant_attack_tip"),true,4)
		do return end
	end
	--判断被保护
	local seflag=false --戏谑技能是否生效中
	if self.data.type==6 then
		local flag=planeVoApi:getNewActiveSkillUseFlag("s20")
		-- print("flag=====>>>",flag)
		if flag==1 then --戏谑技能生效中
			seflag=true
		end
	end
	if self.data.ptEndTime>=base.serverTime then
		if seflag==false then
			smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("playerhavenoFightBuffattack"),true,4)
			do return end
		end
	end
	--判断是否是盟友 同联盟
	if self.data.allianceName and allianceVoApi:isSameAlliance(self.data.allianceName) then
		smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("city_info_cant_attack_tip_1"),true,4)
		do return end
	end
	--判断是否有能量
	if playerVoApi:getEnergy()<=0 then
		local function buyEnergy()
			G_buyEnergy(5)
		end
		smallDialog:showEnergySupplementDialog(4)
		do return end
	end
	local function realAttack()
		self:realClose()
	    require "luascript/script/game/scene/gamedialog/warDialog/tankAttackDialog"
		local td=tankAttackDialog:new(self.data.type,self.data,4)
		local tbArr={getlocal("AEFFighting"),getlocal("dispatchCard"),getlocal("repair")}
		local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("AEFFighting"),true,7)
		sceneGame:addChild(dialog,4)
	end
	if self.data.type==6 and seflag==true then --戏谑技能生效中
		if self.extra.flags and self.extra.flags.ba then
			local ba=self.extra.flags.ba
			local nscfg=planeVoApi:getNewSkillCfg()
			if ((ba.n or 0)<nscfg.protectLimit and G_isToday((ba.t or base.serverTime))) or G_isToday((ba.t or base.serverTime))==false then --该玩家可以被戏谑，直接攻击
				realAttack()
			else --不可以被戏谑，给玩家二次确认弹窗是否攻击
				G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("playerSkillProtectStr2"),false,realAttack)
			end
		else
			realAttack()
		end
    else
    	realAttack()
    end
end

--进入基地, 当该面板是点击自己的基地弹出来的时候使用
function worldBaseSmallDialog:enterBase()
	self:realClose()
	mainUI:changeToMyPort()
end

function worldBaseSmallDialog:enterSkin( ... )
  if buildDecorateVoApi.getLevelLimit and playerVoApi:getPlayerLevel() >= buildDecorateVoApi:getLevelLimit() then
    self:realClose()
    buildDecorateVoApi:showDialog(self.layerNum)
  else
    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("decorateNotLevel",{buildDecorateVoApi:getLevelLimit()}),30)
  end
end

--因为要释放图片，所以重写realclose方法
function worldBaseSmallDialog:realClose()
	self.groundList=nil
	for k,v in pairs(G_SmallDialogDialogTb) do
	    if v==self then
	        v=nil
	        G_SmallDialogDialogTb[k]=nil
	    end
    end

	G_AllianceDialogTb["chatSmallDialog"]=nil
	base:removeFromNeedRefresh(self)
	if self.dialogLayer~=nil then
		self.dialogLayer:removeFromParentAndCleanup(true)
	end
	self.bgLayer=nil
	self.dialogLayer=nil
	self.bgSize=nil
	if self.refreshData~=nil then
		for k,v in pairs(self.refreshData) do
			self.refreshData[k]=nil
		end
	end
	self.refreshData=nil
	self.message=nil
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/world_ground.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/world_ground.pvr.ccz")
end