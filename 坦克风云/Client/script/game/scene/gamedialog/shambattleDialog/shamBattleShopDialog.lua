shamBattleShopDialog = commonDialog:new()

function shamBattleShopDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.normalHeight=180
    return nc
end

function shamBattleShopDialog:resetTab()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))

end

function shamBattleShopDialog:initTableView()
	self.shopTb=arenaVoApi:getShop()
	local function callBack(...)
    	return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-100-200-100-35),nil)
 	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(10,40+90))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function shamBattleShopDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return SizeOfTable(self.shopTb)
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,self.normalHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local cellWidth=self.bgLayer:getContentSize().width-20
        local cellHeight=120

	    local rect = CCRect(0, 0, 50, 50)
        local capInSet = CCRect(20, 20, 10, 10)
        local function cellClick(hd,fn,idx)
        end
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)

		    backSprie:setContentSize(CCSizeMake(cellWidth-10, self.normalHeight))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0.5,0))
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		    backSprie:setPosition(ccp((self.bgLayer:getContentSize().width-20)/2,0))
        cell:addChild(backSprie,1)

        local itemType = Split(self.shopTb[idx+1][1],"_")[1]


        local propIcon=""
        local namestr=""
        local descStr=""
        local propSp=""
        local hid=""
        if itemType=="props" then
            local pid = Split(self.shopTb[idx+1][1],"_")[2]
            propIcon=propCfg[pid].icon
            namestr=getlocal(propCfg[pid].name).."×"..self.shopTb[idx+1][2]
            descStr=getlocal(propCfg[pid].description)
            local num = self.shopTb[idx+1][2]
            local name,pic,desc,id,index,eType,equipId,bgname=getItem(pid,"p")
            local item = {name=name,num=num,pic=pic,desc=desc,id=id,type="p",index=index,key=pid,eType=eType,equipId=equipId,bgname=bgname}
            -- propSp=CCSprite:createWithSpriteFrameName(pic)
            propSp=G_getItemIcon(item,100,nil,self.layerNum+1)
        elseif itemType=="hero" then
            local sid = Split(self.shopTb[idx+1][1],"_")[2]
            hid = heroVoApi:getSoulHid(sid)
            propSp=heroVoApi:getHeroIcon(hid)
            propSp:setScale(0.7)

            namestr=heroVoApi:getHeroSoulName(hid).."×"..self.shopTb[idx+1][2]
            descStr=heroVoApi:getHeroDes(hid)
        elseif itemType=="equip" then
            local eid = Split(self.shopTb[idx+1][1],"_")[2]
            local num = self.shopTb[idx+1][2]

            local name,pic,desc,id,index,eType,equipId,bgname=getItem(eid,"f")
            local item = {name=name,num=num,pic=pic,desc=desc,id=id,type="f",index=index,key=eid,eType=eType,equipId=equipId,bgname=bgname}
            -- propSp=CCSprite:createWithSpriteFrameName(pic)
            propSp=G_getItemIcon(item,100,nil,self.layerNum+1)
            namestr=name .. "×"..num
            descStr=getlocal(desc)

        end
        propSp:setAnchorPoint(ccp(0,0.5))
        propSp:setPosition(ccp(10,backSprie:getContentSize().height/2))
        backSprie:addChild(propSp,1)

        local needWidh = 0
        local lbSortHeight = 50
        local neddHeight = 0
        if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="thai" then
          needWidh =180
          lbSortHeight =80
          neddHeight =80
        end
        local lbName=GetTTFLabelWrap(namestr,26,CCSizeMake(26*12+needWidh,neddHeight),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        lbName:setPosition(150,backSprie:getContentSize().height-20)
        lbName:setAnchorPoint(ccp(0,1));
        backSprie:addChild(lbName,2)
        lbName:setColor(G_ColorYellowPro)
        
           
        local labelSize = CCSize(270, 0);
        local lbDescription=GetTTFLabelWrap(descStr,22,labelSize, kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        lbDescription:setPosition(150,backSprie:getContentSize().height-lbSortHeight)
        lbDescription:setAnchorPoint(ccp(0,1));
        backSprie:addChild(lbDescription,2)

		local num = self.shopTb[idx+1][3]
		local numLb = GetTTFLabel(num,25)
		numLb:setAnchorPoint(ccp(0,0.5))
		numLb:setPosition(ccp(490,100))
		backSprie:addChild(numLb)

        local pointSp = CCSprite:createWithSpriteFrameName("icon_medal_sports.png")
        pointSp:setScale(0.4)
        pointSp:setAnchorPoint(ccp(0,0.5))
        pointSp:setPosition(ccp(numLb:getContentSize().width+4,numLb:getContentSize().height/2))
        numLb:addChild(pointSp,6)


        local function exchange()
          if self.tv:getIsScrolled()==true then
            do return end
          end
          
          local function buycallback()
              local function callback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        if itemType=="hero" then
                            local sid = Split(self.shopTb[idx+1][1],"_")[2]
                            local snum=self.shopTb[idx+1][2]
                            local hData={h={}}
                            hData.h[sid]=snum
                            local heroTb=FormatItem(hData)
                            if heroTb and heroTb[1] then
                                 local hero=heroVoApi:getHeroByHid(hid)
                                local heroIsExist = true
                                if hero==nil then
                                    heroIsExist = false
                                 end
                                G_recruitShowHero(2,heroTb[1],self.layerNum+1,heroIsExist,snum)
                                heroVoApi:addSoul(sid,snum)
                            end
                        elseif itemType=="equip" then
                            local eid = Split(self.shopTb[idx+1][1],"_")[2]
                            G_addPlayerAward("f",eid,nil,self.shopTb[idx+1][2])
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionBuySuccess",{namestr}),30)
                        else
                            local pid = Split(self.shopTb[idx+1][1],"_")[2]
                            bagVoApi:addBag(tonumber(RemoveFirstChar(pid)),self.shopTb[idx+1][2])

                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionBuySuccess",{namestr}),30)
                        end

                        arenaVoApi:addBuy(idx+1)
                        local point=arenaVoApi:getPoint()-self.shopTb[idx+1][3]
                        arenaVoApi:setPoint(point)
                        self:refresh()
                    end
                end
                socketHelper:shamBattleBuy(idx+1,self.shopTb[idx+1][1],self.shopTb[idx+1][2],callback)
          end

          smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buycallback,getlocal("dialog_title_prompt"),getlocal("expeditionBuy",{num,namestr}),nil,self.layerNum+1)
          
        
        end
        local exchangeItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",exchange,nil,getlocal("code_gift"),25)
        local exchangeBtn=CCMenu:createWithItem(exchangeItem)
        exchangeBtn:setTouchPriority(-(self.layerNum-1)*20-2)
        exchangeItem:setAnchorPoint(ccp(1,0))
        exchangeItem:setScale(0.8)
        exchangeBtn:setPosition(ccp(backSprie:getContentSize().width-20,10))
        backSprie:addChild(exchangeBtn,1)

        if arenaVoApi:isSoldOut(idx+1)==true then
           exchangeItem:setEnabled(false)
           local function touchLuaSpr( ... )
             
           end
           local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",  CCRect(10, 10, 1, 1),touchLuaSpr)
            touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
            local rect=CCSizeMake(backSprie:getContentSize().width,backSprie:getContentSize().height)
            touchDialogBg:setContentSize(rect)
            touchDialogBg:setOpacity(200)
            touchDialogBg:setPosition(getCenterPoint(backSprie))
            backSprie:addChild(touchDialogBg,3)
        
            local unlockDesc=GetTTFLabelWrap(getlocal("soldOut"),28,CCSizeMake(  G_VisibleSizeWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            unlockDesc:setColor(G_ColorRed)
            unlockDesc:setPosition(ccp((G_VisibleSizeWidth-60)/2,backSprie:getContentSize().height/2))
            backSprie:addChild(unlockDesc,5)
  
            local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20  , 20, 10, 10),function ()end)
            titleBg:setContentSize(CCSizeMake(titleBg:getContentSize().width,  unlockDesc:getContentSize().height+10))
            titleBg:setScaleX((G_VisibleSizeWidth-60)/titleBg:getContentSize().width)
            titleBg:setPosition(ccp((G_VisibleSizeWidth-60)/2,backSprie:getContentSize().height/2))
            backSprie:addChild(titleBg,4)
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

function shamBattleShopDialog:doUserHandler()
	local backSprie1=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),function () do return end end)
	backSprie1:setContentSize(CCSizeMake(600,200))
	backSprie1:setAnchorPoint(ccp(0.5,1))
	backSprie1:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-95)
	self.bgLayer:addChild(backSprie1)

	local iconName="icon_medal_sports.png"
	local iconSp = CCSprite:createWithSpriteFrameName(iconName)
	iconSp:setScale(130/iconSp:getContentSize().width)
	iconSp:setAnchorPoint(ccp(0,0.5))
	iconSp:setPosition(ccp(35,backSprie1:getContentSize().height/2+10))
	backSprie1:addChild(iconSp,2)

	-- local scale = 40/100
	-- local bgSp =LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),function () do return end end)
	-- bgSp:setContentSize(CCSizeMake(120, 100))
	-- bgSp:setAnchorPoint(ccp(0.5,0));
	-- bgSp:setIsSallow(false)
	-- bgSp:setTouchPriority(-(self.layerNum-1)*20-2)
	-- bgSp:setPosition(100, 10)
	-- bgSp:setScaleY(scale)
	-- backSprie1:addChild(bgSp)

	local num = arenaVoApi:getPoint()
	local numLb = GetTTFLabel(num,25)
    numLb:setAnchorPoint(ccp(0.5,0.5))
    numLb:setPosition(ccp(100, 30))
    -- numLb:setScaleY(1/scale)
    backSprie1:addChild(numLb)
    self.numLb=numLb

    local nameLb = GetTTFLabelWrap(getlocal("shamBattle_medal"),25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	backSprie1:addChild(nameLb)
	nameLb:setAnchorPoint(ccp(0,0.5))
	nameLb:setPosition(200, backSprie1:getContentSize().height/4*3)
	nameLb:setColor(G_ColorYellowPro)

	local upLb = ""
    if G_isMemoryServer() == true then
        upLb = getlocal("shamBattle_medal_msdes")
    else
        upLb = getlocal("shamBattle_medal_des")
    end
	local desTv, desLabel = G_LabelTableView(CCSizeMake(350, 100),upLb,25,kCCTextAlignmentLeft)
    desTv:setPosition(ccp(200,10))
    desTv:setAnchorPoint(ccp(0,1))
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv:setMaxDisToBottomOrTop(130)
    backSprie1:addChild(desTv)

    

    local bgSp2 =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function () do return end end)
	bgSp2:setContentSize(CCSizeMake(600, 100))
	bgSp2:setAnchorPoint(ccp(0.5,0));
	bgSp2:setTouchPriority(-(self.layerNum-1)*20-2)
	bgSp2:setPosition(self.bgLayer:getContentSize().width/2, 20)
	self.bgLayer:addChild(bgSp2)

	-- 刷新
	local timeStr=arenaVoApi:getRefreshTimeStr()
    local refreshTimeLb = GetTTFLabelWrap(getlocal("expeditionRefreshTime",{timeStr}),25,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	bgSp2:addChild(refreshTimeLb)
	refreshTimeLb:setAnchorPoint(ccp(0,0.5))
	refreshTimeLb:setPosition(20, bgSp2:getContentSize().height/2)
	self.refreshTimeLb=refreshTimeLb

	local function touchRefreshBtn()
		if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end

        local cost = arenaVoApi:getRefreshCost()
        if playerVoApi:getGems()<cost then
            GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
            return
        end

		local function callback()
            local function reShop(fn,data)
              local ret,sData=base:checkServerData(data)
              if ret==true then
                  playerVoApi:setGems(playerVoApi:getGems() - cost)
                  self.shopTb=arenaVoApi:getShop()
                  arenaVoApi:setBuy()
                  self:refresh()
              end
            end
            socketHelper:shamBattleRefshop(reShop)
        end

		
		if cost==0 then
			callback()
		else
			smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callback,getlocal("dialog_title_prompt"),getlocal("expendition_refreshDesc",{cost}),nil,self.layerNum+1)
		end
	end
	local refreshItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touchRefreshBtn,nil,getlocal("dailyTaskFlush"),25)
	refreshItem:setAnchorPoint(ccp(1,0.5))
	local refreshBtn=CCMenu:createWithItem(refreshItem);
	refreshBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	refreshBtn:setPosition(ccp(bgSp2:getContentSize().width-10,bgSp2:getContentSize().height/2))
    if(G_isHexie()~=true)then
    	bgSp2:addChild(refreshBtn)
    end    
end

function shamBattleShopDialog:refresh()

    local recordPoint = self.tv:getRecordPoint()
    self.tv:reloadData()
    self.tv:recoverToRecordPoint(recordPoint)
    self.pointLb=tolua.cast(self.numLb,"CCLabelTTF")
    self.pointLb:setString(arenaVoApi:getPoint())

    local timeStr=arenaVoApi:getRefreshTimeStr()
    self.refreshTimeLb:setString(getlocal("expeditionRefreshTime",{timeStr}))
end

function shamBattleShopDialog:tick()
	local isToday = arenaVoApi:isShopToday()
    if isToday==false and self.tv then
        local function reCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                 self.shopTb=arenaVoApi:getShop()
                 self:refresh()
            end
        end
        socketHelper:shamBattleGetshop(reCallback)
    end

    if self and self.refreshTimeLb then
        local timeStr=arenaVoApi:getRefreshTimeStr()
        self.refreshTimeLb:setString(getlocal("expeditionRefreshTime",{timeStr}))
    end
end

function shamBattleShopDialog:dispose()
	self.numLb=nil
	self.refreshTimeLb=nil
end