
expeditionShopDialog=commonDialog:new()

function expeditionShopDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	self.rankLabel=nil
	self.nameLabel=nil
	self.levelLabel=nil
	self.valueLabel=nil
	self.labelTab={}
	self.cellHeight=200
    return nc
end


function expeditionShopDialog:resetTab()

    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(119,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
         tabBtnItem:setPosition(320,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==2 then
         tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))
    self:initLayer()
end

function expeditionShopDialog:initLayer()
  if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
      self.cellHeight = 150
  end 

  local titleW = G_VisibleSizeWidth - 20
  local titileH = 180	
  local function cellClick(hd,fn,idx)

  end
  
  local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),cellClick)
  backSprie:setAnchorPoint(ccp(0.5,1))
  backSprie:setContentSize(CCSizeMake(titleW, titileH))
  backSprie:setPosition(ccp(G_VisibleSizeWidth/2, G_VisibleSizeHeight - 90));
  self.bgLayer:addChild(backSprie)

  local descLb=GetTTFLabelWrap(getlocal("expeditionShopInfo"),25,CCSizeMake(380,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  descLb:setAnchorPoint(ccp(0.5,0.5))
  descLb:setPosition(ccp(backSprie:getContentSize().width/2+80,backSprie:getContentSize().height/2))
  backSprie:addChild(descLb)

  local strSize2,curLan = 19,G_getCurChoseLanguage()
  if curLan =="cn" or curLan =="tw" or curLan =="ja" or curLan =="ko" then
    strSize2 = 25
  end
  self.pointLb=GetTTFLabel(getlocal("expeditionShopMyPoint",{expeditionVoApi:getPoint()}),strSize2)
  self.pointLb:setAnchorPoint(ccp(0,0.5))
  self.pointLb:setPosition(ccp(20,50))
  backSprie:addChild(self.pointLb)

  local sp=CCSprite:createWithSpriteFrameName("expeditionPoint.png")
  sp:setAnchorPoint(ccp(0,1))
  sp:setPosition(ccp(30,backSprie:getContentSize().height-20))
  -- sp:setScale(1.1)
  backSprie:addChild(sp)

  
  local timeStr=expeditionVoApi:getRefreshTimeStr()

  self.refreshLb=GetTTFLabelWrap(getlocal("expeditionRefreshTime",{timeStr}),25,CCSizeMake(430,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  self.refreshLb:setAnchorPoint(ccp(0,0.5))
  self.refreshLb:setPosition(ccp(20,60))
  self.bgLayer:addChild(self.refreshLb)

  self.shopTb=expeditionVoApi:getShop()

end

--设置对话框里的tableView
function expeditionShopDialog:initTableView()	
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-410),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(10,120))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(100)

    if base.ea==1 then
         local function refresh()
          if G_checkClickEnable()==false then
              do
                  return
              end
          else
              base.setWaitTime=G_getCurDeviceMillTime()
          end

          local cost = expeditionVoApi:getRefreshCost()
          if playerVoApi:getGems()<cost then
              GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
              return
          end

          local function callback()
            local function reShop(fn,data)
              local ret,sData=base:checkServerData(data)
              if ret==true then
                  playerVoApi:setGems(playerVoApi:getGems() - cost)
                  self.shopTb=expeditionVoApi:getShop()
                  expeditionVoApi:setBuy()
                  self:refresh()
              end
            end
            socketHelper:expeditionRefshop(reShop)
          end

          
          if cost==0 then
              callback()
          else
              smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callback,getlocal("dialog_title_prompt"),getlocal("expendition_refreshDesc",{cost}),nil,self.layerNum+1)
          end

          
        end
        local refreshItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",refresh,nil,getlocal("dailyTaskFlush"),24/0.8,101)
        refreshItem:setScale(0.8)
        local btnLb = refreshItem:getChildByTag(101)
        if btnLb then
          btnLb = tolua.cast(btnLb,"CCLabelTTF")
          btnLb:setFontName("Helvetica-bold")
        end
        local refreshBtn=CCMenu:createWithItem(refreshItem)
        refreshBtn:setTouchPriority(-(self.layerNum-1)*20-4)
        refreshBtn:setAnchorPoint(ccp(1,0.5))
        refreshBtn:setPosition(ccp(540,60))
        self.bgLayer:addChild(refreshBtn)
    end
   
end


--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function expeditionShopDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
	   return SizeOfTable(self.shopTb)
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,self.cellHeight)
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

		    backSprie:setContentSize(CCSizeMake(cellWidth-10, self.cellHeight))
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
            print("----dmj----pid:"..pid)
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

        local labelSize = CCSize(330, 0);
        local labelSize2 = CCSize(430, 0);
        local lbName=GetTTFLabelWrap(namestr,24,labelSize2,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
        lbName:setPosition(125,backSprie:getContentSize().height-20)
        lbName:setAnchorPoint(ccp(0,1));
        backSprie:addChild(lbName,2)
        lbName:setColor(G_ColorYellowPro)
        
           
        local lbDescription=GetTTFLabelWrap(descStr,20,labelSize, kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        lbDescription:setPosition(125,(lbName:getPositionY()-lbName:getContentSize().height)/2)
        lbDescription:setAnchorPoint(ccp(0,0.5));
        backSprie:addChild(lbDescription,2)

        local pointstr = self.shopTb[idx+1][3]
        local pointLb=GetTTFLabel(pointstr,25)
        pointLb:setAnchorPoint(ccp(0,0.5))
        pointLb:setPosition(ccp(490,115))
        backSprie:addChild(pointLb)

        local pointSp = CCSprite:createWithSpriteFrameName("expeditionPoint.png")
        pointSp:setScale(0.4)
        pointSp:setAnchorPoint(ccp(0,0.5))
        pointSp:setPosition(ccp(pointLb:getContentSize().width+4,pointLb:getContentSize().height/2))
        pointLb:addChild(pointSp,6)


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

                        expeditionVoApi:addBuy(idx+1)
                        local point=expeditionVoApi:getPoint()-self.shopTb[idx+1][3]
                        expeditionVoApi:setPoint(point)
                        self:refresh()
                    end
                end
                socketHelper:expeditionBuy(idx+1,self.shopTb[idx+1][1],self.shopTb[idx+1][2],callback)
          end

          smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buycallback,getlocal("dialog_title_prompt"),getlocal("expeditionBuy",{pointstr,namestr}),nil,self.layerNum+1)
          
        
        end
        local exchangeItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",exchange,nil,getlocal("code_gift"),22/0.6,101)
        exchangeItem:setScale(0.6)
        local btnLb = exchangeItem:getChildByTag(101)
        if btnLb then
          btnLb = tolua.cast(btnLb,"CCLabelTTF")
          btnLb:setFontName("Helvetica-bold")
        end
        local exchangeBtn=CCMenu:createWithItem(exchangeItem)
        exchangeBtn:setTouchPriority(-(self.layerNum-1)*20-2)
        exchangeItem:setAnchorPoint(ccp(1,0))
        -- exchangeItem:setScale(0.8)
        exchangeBtn:setPosition(ccp(backSprie:getContentSize().width-10,40))
        backSprie:addChild(exchangeBtn,1)

        if expeditionVoApi:isSoldOut(idx+1)==true then
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


--点击tab页签 idx:索引
function expeditionShopDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
            
            self.tv:reloadData()
            self:doUserHandler()
		else
			v:setEnabled(true)
		end
    end
end

function expeditionShopDialog:refresh()

    local recordPoint = self.tv:getRecordPoint()
    self.tv:reloadData()
    self.tv:recoverToRecordPoint(recordPoint)
    self.pointLb=tolua.cast(self.pointLb,"CCLabelTTF")
    self.pointLb:setString(getlocal("expeditionShopMyPoint",{expeditionVoApi:getPoint()}))

    local timeStr=expeditionVoApi:getRefreshTimeStr()
    self.refreshLb:setString(getlocal("expeditionRefreshTime",{timeStr}))

end

function expeditionShopDialog:tick()
    if base.ea==1 then
        local isToday = expeditionVoApi:isToday()
        if isToday==false and self.tv then
            local function reCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                     self.shopTb=expeditionVoApi:getShop()
                     self:refresh()
                end
            end

            socketHelper:expeditionGetshop(reCallback)
        end
    end

    if self and self.refreshLb then
        local timeStr=expeditionVoApi:getRefreshTimeStr()
        self.refreshLb:setString(getlocal("expeditionRefreshTime",{timeStr}))
    end
end

--用户处理特殊需求,没有可以不写此方法
function expeditionShopDialog:doUserHandler()
	
end


--点击了cell或cell上某个按钮
function expeditionShopDialog:cellClick(idx)

end

function expeditionShopDialog:dispose()

	self=nil
end





