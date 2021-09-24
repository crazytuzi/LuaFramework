acTitaniumOfharvestTab1={

}

function acTitaniumOfharvestTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    return nc
end

function acTitaniumOfharvestTab1:init(layerNum)
 	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum

	-- 活动info
	local capInSet = CCRect(65, 25, 1, 1)
	local function bgClick(hd,fn,idx)
    end
    local desBg=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",capInSet,bgClick)
	desBg:setContentSize(CCSizeMake(G_VisibleSize.width-60,180))
	desBg:setAnchorPoint(ccp(0.5,1))
	desBg:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height-165))
	desBg:setTouchPriority(-(self.layerNum-1)*20-1)
	self.bgLayer:addChild(desBg)

	local timeTitle = GetTTFLabel(getlocal("activity_timeLabel"),25)
    timeTitle:setAnchorPoint(ccp(0.5,1))
	timeTitle:setPosition(ccp(desBg:getContentSize().width/2, desBg:getContentSize().height-10))
	desBg:addChild(timeTitle)
	timeTitle:setColor(G_ColorGreen)

	local timeLabel = GetTTFLabelWrap(acTitaniumOfharvestVoApi:getTimeStr(),25,CCSizeMake(desBg:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	timeLabel:setAnchorPoint(ccp(0.5,1))
	timeLabel:setPosition(ccp(desBg:getContentSize().width/2, desBg:getContentSize().height-45))
	desBg:addChild(timeLabel)
	self.timeLb=timeLabel
	self:updateAcTime()

	local desTv,desLabel = G_LabelTableView(CCSizeMake(desBg:getContentSize().width-60, desBg:getContentSize().height-90),getlocal("activity_TitaniumOfharvest_tab1_des"),25,kCCTextAlignmentLeft)
 	desBg:addChild(desTv)
    desTv:setPosition(ccp(30,10))
    desTv:setAnchorPoint(ccp(0,1))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    desTv:setMaxDisToBottomOrTop(100) 

    local function touchDesItem()
    	PlayEffect(audioCfg.mouseClick)
	    local tabStr={}
	    local td=smallDialog:new()
	    tabStr = {"\n",getlocal("activity_TitaniumOfharvest_tab1_des3"),"\n",getlocal("activity_TitaniumOfharvest_tab1_des2"),"\n",getlocal("activity_TitaniumOfharvest_tab1_des1"),"\n"}
	    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,nil)
	    sceneGame:addChild(dialog,self.layerNum+1)
    end
    local desItem=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touchDesItem,nil,nil,0)
	desItem:setAnchorPoint(ccp(1,1))
	desItem:setScale(0.8)
	local desMenu=CCMenu:createWithItem(desItem)
	desMenu:setTouchPriority(-(self.layerNum-1)*20-2)
	desMenu:setPosition(ccp(desBg:getContentSize().width-20, desBg:getContentSize().height-20))
	desBg:addChild(desMenu)



	local characterSp = CCSprite:createWithSpriteFrameName("GuideCharacter.png") --姑娘
    characterSp:setAnchorPoint(ccp(0,0))
    characterSp:setPosition(ccp(20,self.bgLayer:getContentSize().height - 620))
    self.bgLayer:addChild(characterSp)



    local desTv1,desLabel1 = G_LabelTableView(CCSizeMake(self.bgLayer:getContentSize().width-characterSp:getContentSize().width-30, characterSp:getContentSize().height-60),getlocal("activity_TitaniumOfharvest_tab1_des4"),25,kCCTextAlignmentLeft)
 	self.bgLayer:addChild(desTv1)
    desTv1:setPosition(ccp(characterSp:getContentSize().width+20,self.bgLayer:getContentSize().height - 620))
    desTv1:setAnchorPoint(ccp(0,1))
    desTv1:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    desTv1:setMaxDisToBottomOrTop(100) 

    if(G_isIphone5())then

	else
		characterSp:setPosition(ccp(35,self.bgLayer:getContentSize().height - 540))
		desTv1:setPosition(ccp(characterSp:getContentSize().width+20,self.bgLayer:getContentSize().height - 540))
		characterSp:setScale(0.7)
	end



	local function touch()
    end
    local capInSet = CCRect(20, 20, 10, 10)
    local descBg =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",capInSet,touch)
    descBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,60))
    descBg:setAnchorPoint(ccp(0,0))
    descBg:setPosition(ccp(30,40))
    self.bgLayer:addChild(descBg)

    local function itemTouch()
    	PlayEffect(audioCfg.mouseClick)
	    local tabStr={}
	    local td=smallDialog:new()
	    tabStr = {}
	    local res = acTitaniumOfharvestVoApi:getDayres()
	    local num = SizeOfTable(res)
	    for i=num,1,-1 do
	    	local str = getlocal("activity_TitaniumOfharvest_tab1_function",{i,res[i]})
	    	table.insert(tabStr,"\n")
	    	table.insert(tabStr,str)
	    end
	    table.insert(tabStr,"\n")
	    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,nil)
	    sceneGame:addChild(dialog,self.layerNum+1)
    end
	local infoItem = GetButtonItem("hero_infoBtn.png","hero_infoBtn.png","hero_infoBtn.png",itemTouch,11,nil,nil)
	infoItem:setScale(0.9)
	local menu = CCMenu:createWithItem(infoItem)
	menu:setPosition(ccp(self.bgLayer:getContentSize().width-15-infoItem:getContentSize().width/2,40+descBg:getContentSize().height/2))
	menu:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(menu)

	local dayNumLb = GetTTFLabelWrap(getlocal("activity_TitaniumOfharvest_tab1_function2",{acTitaniumOfharvestVoApi:getPd()}),25,CCSizeMake(descBg:getContentSize().width-2*infoItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	dayNumLb:setPosition(ccp(descBg:getContentSize().width/2,descBg:getContentSize().height/2))
	descBg:addChild(dayNumLb)

	local function touchChongzhiItem()
		if G_checkClickEnable()==false then
				do
					return
				end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		
		PlayEffect(audioCfg.mouseClick)
		activityAndNoteDialog:closeAllDialog()
		vipVoApi:showRechargeDialog(3)
	end
	local chonzhiItem = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",touchChongzhiItem,nil,getlocal("recharge"),25)
	chonzhiItem:setAnchorPoint(ccp(0.5,0.5))
	local chongzhiMenu=CCMenu:createWithItem(chonzhiItem)
	chongzhiMenu:setTouchPriority(-(self.layerNum-1)*20-2);
	chongzhiMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2-150,descBg:getContentSize().height+descBg:getPositionY()+45))
	self.bgLayer:addChild(chongzhiMenu)

	local function touchLingjiangItem()
		if G_checkClickEnable()==false then
				do
					return
				end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		local function callBack(fn,data)
	        local ret,sData = base:checkServerData(data)
            if ret==true then 
            	local num = acTitaniumOfharvestVoApi:getChongzhiReward()
            	acTitaniumOfharvestVoApi:setTaiNum(num)
            	self:refresh()

            	local name,pic,desc,id,index,eType,equipId=getItem("r4","u")
            	G_addPlayerAward("u","r4",id,num,false,true)

            	local str = getlocal("daily_lotto_tip_10") .. name .. FormatNumber(num)
            	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)
            end                
		end
		local pd = acTitaniumOfharvestVoApi:getPd()
		socketHelper:TitaniumOfharvestGetReward("d" .. pd,nil,nil,nil,callBack)

	end
	local lingjiangItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touchLingjiangItem,nil,getlocal("daily_scene_get"),25)
	lingjiangItem:setAnchorPoint(ccp(0.5,0.5))
	local lingjiangMenu=CCMenu:createWithItem(lingjiangItem)
	lingjiangMenu:setTouchPriority(-(self.layerNum-1)*20-2);
	lingjiangMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2+150,descBg:getContentSize().height+descBg:getPositionY()+45))
	self.bgLayer:addChild(lingjiangMenu)
	self.lingjiangItem=lingjiangItem

	if acTitaniumOfharvestVoApi:getChongzhiReward()<=0 then
		lingjiangItem:setEnabled(false)
	end


    local descBg2 =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",capInSet,touch)
    descBg2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-840))
    descBg2:setAnchorPoint(ccp(0,0))
    descBg2:setPosition(ccp(30,descBg:getContentSize().height+descBg:getPositionY()+95))
    self.bgLayer:addChild(descBg2)

    if(G_isIphone5())then
    	descBg2:setPosition(ccp(30,descBg:getContentSize().height+descBg:getPositionY()+105))
    	descBg2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-820))
	else
		descBg2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-735))
	end

	local yingBg1 = CCSprite:createWithSpriteFrameName("ShapeEagle.png")
	descBg2:addChild(yingBg1)
	yingBg1:setPosition(ccp(descBg2:getContentSize().width/2,descBg2:getContentSize().height/2))

   local iconHeight = descBg2:getContentSize().height*0.5
   local textheight = 30
   local iconWidth = 20
   local GiconHeight = 0
   if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="in" or G_getCurChoseLanguage() =="fr" then
        iconHeight = descBg2:getContentSize().height*0.65
        textheight =60
        iconWidth =10
        GiconHeight=-20
   end

	local iconGoldSp = CCSprite:createWithSpriteFrameName("iconGold4.png")
	descBg2:addChild(iconGoldSp)
	iconGoldSp:setPosition(ccp(descBg2:getContentSize().width/4,iconHeight))

	for i=1,3 do
		local taiSp = CCSprite:createWithSpriteFrameName("IconUranium.png")
	    taiSp:setAnchorPoint(ccp(0,0))
	    taiSp:setScale(2)
	    descBg2:addChild(taiSp)
	    if i==1 then
	    	taiSp:setPosition(ccp(descBg2:getContentSize().width/4*3-40,iconHeight-30))
    	elseif i==2 then
    		taiSp:setPosition(ccp(descBg2:getContentSize().width/4*3-10,iconHeight-40))
		elseif i==3 then
			taiSp:setPosition(ccp(descBg2:getContentSize().width/4*3-20,iconHeight-15))
	    end
	end

	local pd = acTitaniumOfharvestVoApi:getPd()
	local res = acTitaniumOfharvestVoApi:getDayres()
	local biliStr = "1:" .. res[1]
	if pd and pd~=0 then
		biliStr = "1:" .. res[pd]
	end
	local biliLb = GetTTFLabel(biliStr ,25)
	biliLb:setPosition(ccp(descBg2:getContentSize().width/2, descBg2:getContentSize().height/2))
	descBg2:addChild(biliLb)

	local pf = acTitaniumOfharvestVoApi:getPf()
	local costStr = getlocal("activity_TitaniumOfharvest_today_cost",{0})
	if pf then
		local numStr = FormatNumber(pf["d" .. pd])
		costStr = getlocal("activity_TitaniumOfharvest_today_cost",{numStr})
	end

	local pt = acTitaniumOfharvestVoApi:getPt()
	if base.serverTime-pt>24*60*60 then
		costStr = getlocal("activity_TitaniumOfharvest_today_cost",{0})
	end


	local costLb = GetTTFLabelWrap(costStr ,22,CCSizeMake(240,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	descBg2:addChild(costLb)
	costLb:setAnchorPoint(ccp(0,0.5))
	costLb:setPosition(ccp(10,textheight))
	self.costLb=costLb

	local costSp = CCSprite:createWithSpriteFrameName("IconGold.png")
	costLb:addChild(costSp)
	costSp:setPosition(ccp(costLb:getContentSize().width+iconWidth,costLb:getContentSize().height/2+GiconHeight))

	local TaiLb = GetTTFLabelWrap(getlocal("activity_TitaniumOfharvest_today_Tai",{FormatNumber(acTitaniumOfharvestVoApi:getChongzhiReward())}) ,22,CCSizeMake(240,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	descBg2:addChild(TaiLb)
	TaiLb:setAnchorPoint(ccp(0,0.5))
	TaiLb:setPosition(ccp(30+descBg2:getContentSize().width/2,textheight))
	self.TaiLb=TaiLb


	return self.bgLayer
end

function acTitaniumOfharvestTab1:refresh()
	self.lingjiangItem:setEnabled(false)
	self.TaiLb:setString(getlocal("activity_TitaniumOfharvest_today_Tai",{0}))

end

function acTitaniumOfharvestTab1:tick()
	if G_isToday(playerVoApi:getLogindate())~=acTitaniumOfharvestVoApi:getEnterGameFlag()then
		if self.costLb then
			self.costLb:setString(getlocal("activity_TitaniumOfharvest_today_cost",{0}))
		end
	end
	self:updateAcTime()
end

function acTitaniumOfharvestTab1:updateAcTime()
  local acVo=acTitaniumOfharvestVoApi:getAcVo()
  if acVo and self.timeLb then
    G_updateActiveTime(acVo,self.timeLb)
  end
end

function acTitaniumOfharvestTab1:dispose()
	self.bgLayer=nil
	self.layerNum=nil
	self.tv=nil
	self.timeLb=nil
end