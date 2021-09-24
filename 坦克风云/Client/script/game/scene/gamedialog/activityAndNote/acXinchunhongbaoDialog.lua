acXinchunhongbaoDialog=commonDialog:new()

function acXinchunhongbaoDialog:new(layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.layerNum=layerNum

    self.selectedTabIndex=0
    self.cellHeight=nil

    self.tv = nil
    self.tv1=nil
    self.tv2=nil
    self.tv3=nil
    self.reportList={}
    self.smallDialogTick=false
    self.acSmallDialog=nil
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	return nc
end

function acXinchunhongbaoDialog:initTab(tabTb)
   local tabBtn=CCMenu:create()
   local tabIndex=0
   local tabBtnItem;
   if tabTb~=nil then
       for k,v in pairs(tabTb) do

           tabBtnItem = CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
           
           tabBtnItem:setAnchorPoint(CCPointMake(0.5,0.5))
           --tabBtnItem:setScaleY(1.4)
           --tabBtnItem:setScaleX(1.5)
           local function tabClick(idx)
               return self:tabClick(idx)
           end
           tabBtnItem:registerScriptTapHandler(tabClick)
           
           local lb=GetTTFLabelWrap(v,20,CCSizeMake(tabBtnItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
           lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
           tabBtnItem:addChild(lb)
           --lb:setScaleY(1/1.4)
           --lb:setScaleX(1/1.5)
		   lb:setTag(31)
           if k~=1 then
              lb:setColor(G_TabLBColorGreen)
           end
			
           self.allTabs[k]=tabBtnItem
           tabBtn:addChild(tabBtnItem)
           tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
           tabBtnItem:setTag(tabIndex)
           tabIndex=tabIndex+1
       end
   end
   tabBtn:setPosition(0,0)
   self.bgLayer:addChild(tabBtn,6)

end
function acXinchunhongbaoDialog:resetTab()
	self.allTabs={getlocal("activity_xinchunhongbao_giftTitle"),getlocal("friend_title"),getlocal("serverwar_point_record")}
    self:initTab(self.allTabs)
    local index=0
    for k,v in pairs(self.allTabs) do
         local tabBtnItem=v
         local tabBtnHeight=(self.bgLayer:getContentSize().height-300)-tabBtnItem:getContentSize().height/2-10
         if index==0 then
            tabBtnItem:setPosition(90,tabBtnHeight)
         elseif index==1 then
            tabBtnItem:setPosition(238,tabBtnHeight)
         elseif index==2 then
            tabBtnItem:setPosition(386,tabBtnHeight)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
end

function acXinchunhongbaoDialog:initTableView()
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSize.height-105))
	self.panelLineBg:setAnchorPoint(ccp(0,0))
	self.panelLineBg:setPosition(ccp(15,15))
	
  self:initBg()
  self:resetTab()

	local function callBack(...)
        return self:eventHandler(...)
    end
    hd= LuaEventHandler:createHandler(callBack)

    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight/2 - 170),nil)
	self.bgLayer:addChild(self.tv)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(20,105))
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	self.tv:setMaxDisToBottomOrTop(10)

  self:tabClick(0)
end

-- 面板上部分活动时间、说明按钮以及美女图片
function acXinchunhongbaoDialog:initBg()

	local headBs=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function () do return end end)
    headBs:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,200))
    headBs:setAnchorPoint(ccp(0.5,1))
    headBs:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height - 95))
    self.bgLayer:addChild(headBs,4)


	local leftIcon = CCSprite:createWithSpriteFrameName("acBigGift.png")
	--leftIcon:setScale(1.5)
    leftIcon:setPosition(ccp(10,headBs:getContentSize().height/2))
    leftIcon:setAnchorPoint(ccp(0,0.5))
    headBs:addChild(leftIcon,5)

    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),25)
    actTime:setPosition(ccp(headBs:getContentSize().width/2,headBs:getContentSize().height-20))
    headBs:addChild(actTime,5)
    actTime:setColor(G_ColorGreen)

    local acVo = acXinchunhongbaoVoApi:getAcVo()
    if acVo then
    	local timeStr = activityVoApi:getActivityTimeStr(acVo.st,acVo.et)
    	local timeLabel = GetTTFLabel(timeStr,25)
    	timeLabel:setPosition(ccp(headBs:getContentSize().width/2,headBs:getContentSize().height-20-actTime:getContentSize().height))
    	headBs:addChild(timeLabel,5)
    end

    local descTv = G_LabelTableView(CCSize(headBs:getContentSize().width-leftIcon:getContentSize().width-70,100),getlocal("activity_xinchunhongbao_content"),25,kCCTextAlignmentLeft)
    descTv:setPosition(ccp(leftIcon:getContentSize().width+30,15))
    descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    descTv:setAnchorPoint(ccp(0,0))
    headBs:addChild(descTv,2)
    descTv:setMaxDisToBottomOrTop(50)

    local function showInfo()
        local tabStr={"\n",getlocal("activity_xinchunhongbao_Tip6"),"\n",getlocal("activity_xinchunhongbao_Tip5"),"\n",getlocal("activity_xinchunhongbao_Tip4",{acXinchunhongbaoVoApi:getDailyTimes()}),"\n",getlocal("activity_xinchunhongbao_Tip3"),"\n",getlocal("activity_xinchunhongbao_Tip2"),"\n",getlocal("activity_xinchunhongbao_Tip1"),"\n"}
        -- local tabCol"\n",getlocal("activity_xinchunhongbao_Tip7"),or = {nil,nil,nil,G_ColorYellow,nil,nil,nil,nil,G_ColorYellow,nil}
        PlayEffect(audioCfg.mouseClick)
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    infoItem:setScale(0.8)
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setPosition(ccp(headBs:getContentSize().width-80,headBs:getContentSize().height-50));
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    headBs:addChild(infoBtn)
end

function acXinchunhongbaoDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 1
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		local w = G_VisibleSizeWidth-40

		tmpSize=CCSizeMake(w, self.bgLayer:getContentSize().height-350)

		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function acXinchunhongbaoDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            local tabBtnItem = v
            local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
            tabBtnLabel:setColor(G_ColorWhite)
         else
            v:setEnabled(true)
            local tabBtnItem = v
            local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
            tabBtnLabel:setColor(G_TabLBColorGreen)
         end
    end 

    if idx==2 then

      if self.bgLayer1~=nil then
          self.bgLayer1:setPosition(ccp(999333,0))
          self.bgLayer1:setVisible(false)
      end
      if self.bgLayer2~=nil then
          self.bgLayer2:setPosition(ccp(999333,0))
          self.bgLayer2:setVisible(false)
      end
      
      if self.bgLayer3==nil then
          self:initLayer3()
          self.bgLayer:addChild(self.bgLayer3)
      else
          self.bgLayer3:setVisible(true)
          self:getRecordList()
      end

      self.bgLayer3:setPosition(ccp(0,0))
            
    elseif idx==1 then
      if self.bgLayer3~=nil then
          self.bgLayer3:setPosition(ccp(999333,0))
          self.bgLayer3:setVisible(false)
      end
      if self.bgLayer1~=nil then
          self.bgLayer1:setPosition(ccp(999333,0))
          self.bgLayer1:setVisible(false)
      end
      
      if self.bgLayer2==nil then
          self:initLayer2()
          self.bgLayer:addChild(self.bgLayer2)
      else
           self.bgLayer2:setVisible(true)
           if self.tv2 then
            self.tv2:reloadData()
          end
          self:updateNoFriends()
      end



      self.bgLayer2:setPosition(ccp(0,0))

    elseif idx==0 then
       if self.bgLayer3~=nil then
          self.bgLayer3:setPosition(ccp(999333,0))
          self.bgLayer3:setVisible(false)
      end
      if self.bgLayer2~=nil then
          self.bgLayer2:setPosition(ccp(999333,0))
          self.bgLayer2:setVisible(false)
      end
      
      if self.bgLayer1==nil then
          self:initLayer1()
          self.bgLayer:addChild(self.bgLayer1)
      else
           self.bgLayer1:setVisible(true)
           if self.tv1 then
            self.tv1:reloadData()
          end
      end

      self.bgLayer1:setPosition(ccp(0,0))

    end
end


function acXinchunhongbaoDialog:initLayer1()

  self.bgLayer1=CCLayer:create()


  local backSprite = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(20,20,10,10),function ( ... ) end)
  backSprite:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,self.bgLayer:getContentSize().height-380))
  backSprite:setAnchorPoint(ccp(0.5,0))
  backSprite:setPosition(self.bgLayer1:getContentSize().width/2,20)
  self.bgLayer1:addChild(backSprite)

  local function callBack(...)
       return self:eventHandler1(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.tv1=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(backSprite:getContentSize().width-20,560),nil)
  backSprite:addChild(self.tv1,1)
  self.tv1:setAnchorPoint(ccp(0,0))
  self.tv1:setPosition(ccp(10,backSprite:getContentSize().height-570))
  self.bgLayer1:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  -- self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
  --self.tv1:setMaxDisToBottomOrTop(120)
end

function acXinchunhongbaoDialog:eventHandler1(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize
    tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40, 560)

    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, 560))

    local medalIcon = CCSprite:createWithSpriteFrameName("top3.png")
    medalIcon:setAnchorPoint(ccp(0,0.5))
    medalIcon:setPosition(10,cell:getContentSize().height-30)
    cell:addChild(medalIcon)

    local hasMedal = acXinchunhongbaoVoApi:getHasMedals()
    local hasSmallGift = acXinchunhongbaoVoApi:getGiftNumByType(1)
    local hasBigGift = acXinchunhongbaoVoApi:getGiftNumByType(2)
    local smallNeedMedal = acXinchunhongbaoVoApi:getOpenSmall()
    local bigNeedMedal = acXinchunhongbaoVoApi:getOpenBig()

    local hasMedalLb = GetTTFLabelWrap(getlocal("activity_xinchunhongbao_medalNum",{hasMedal}),25,CCSizeMake(cell:getContentSize().width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    hasMedalLb:setAnchorPoint(ccp(0,0.5))
    hasMedalLb:setPosition(20+medalIcon:getContentSize().width,cell:getContentSize().height-30)
    cell:addChild(hasMedalLb)

    local function nilFun( ... )
      -- body
    end

    local panelSp =LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFun)
    panelSp:setContentSize(CCSizeMake(cell:getContentSize().width-20,500))
    panelSp:setAnchorPoint(ccp(0,0))
    panelSp:setPosition(ccp(0,0))
    cell:addChild(panelSp,1)

    local function rewardHandler(tag,object)
      local function rewardCallback( fn,data )
        local ret,sData = base:checkServerData(data)
        if ret==true then
            if sData.data.xinchunhongbao then
              if sData.data.xinchunhongbao.type then
                acXinchunhongbaoVoApi:reduceHasGiftNumTb(sData.data.xinchunhongbao.type)
                if sData.data.xinchunhongbao.type==1 then
                  acXinchunhongbaoVoApi:reduceHasMedals(acXinchunhongbaoVoApi:getOpenSmall())
                elseif sData.data.xinchunhongbao.type==2 then
                  acXinchunhongbaoVoApi:reduceHasMedals(acXinchunhongbaoVoApi:getOpenBig())
                end
              end
              if self.tv1 then
                self.tv1:reloadData()
              end
              if sData.data.xinchunhongbao.clientReward then
                local reward = sData.data.xinchunhongbao.clientReward
                local content={}

                if reward then
                    local giftName = ""
                    if tag==1 then
                      giftName=getlocal("activity_xinchunhongbao_smallGiftName")
                    elseif tag ==2 then
                      giftName=getlocal("activity_xinchunhongbao_bigGiftName")
                    end
                    for k,v in pairs(reward) do
                        local ptype = v[1]
                        local pid = v[2]
                        local pnum = v[3]
                        local name,pic,desc,id,noUseIdx,eType,equipId=getItem(pid,ptype)
                        local award={name=name,num=pnum,pic=pic,desc=desc,id=id,type=ptype,index=index,key=pid,eType=eType,equipId=equipId}
                        if acXinchunhongbaoVoApi:checkIsChatByID(ptype,pid,pnum)==true then
                            local message={key="activity_xinchunhongbao_chatSystemMessage",param={playerVoApi:getPlayerName(),giftName,award.name.." x"..award.num}}
                            chatVoApi:sendSystemMessage(message)
                        end
                        table.insert(content,award)
                        G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
                    end
                    local str=""
                    if content and SizeOfTable(content)>0 then
                        str = getlocal("activity_xinchunhongbao_awardTip",{giftName})
                        for k,v in pairs(content) do
                            local nameStr=v.name
                            if v.type=="c" then
                                nameStr=getlocal(v.name,{v.num})
                            end
                            if k==SizeOfTable(content) then
                                str = str .. nameStr .. " x" .. v.num
                            else
                                str = str .. nameStr .. " x" .. v.num .. ","
                            end
                        end
                    end
                    if str and str~="" then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)
                    end

                end
               
              end

            end
        end
      end
      if tag == 1 then
        if hasSmallGift and hasSmallGift>0 then
          if hasMedal>=smallNeedMedal then
            socketHelper:activityXinchunhongbaoOpenGift(1,rewardCallback)
          else
            local function onConfirm( ... )
              self:tabClick(1)
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("activity_xinchunhongbao_notEnoughMedal"),nil,self.layerNum+1)
          end
        else
          self:tabClick(1)
        end
      elseif tag == 2 then
        if hasBigGift and hasBigGift>0 then
          if hasMedal>=bigNeedMedal then
            socketHelper:activityXinchunhongbaoOpenGift(2,rewardCallback)
          else
            local function onConfirm( ... )
              self:tabClick(1)
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("activity_xinchunhongbao_notEnoughMedal"),nil,self.layerNum+1)
          end
        else
          self:tabClick(1)
        end
      end
    end

    local smallBtnX = panelSp:getContentSize().width/4
    local bigBtnX = panelSp:getContentSize().width/4*3
    local btnY = 60
    local smallGiftBtn = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rewardHandler,1,getlocal("activity_xinchunhongbao_getGiftBtn"),25,101)
    local smallGiftMenu=CCMenu:createWithItem(smallGiftBtn)
    smallGiftMenu:setPosition(ccp(smallBtnX,btnY))
    smallGiftMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    panelSp:addChild(smallGiftMenu,2)

    local medalIcon1 = CCSprite:createWithSpriteFrameName("top3.png")
    medalIcon1:setScale(0.8)
    medalIcon1:setAnchorPoint(ccp(1,0.5))
    medalIcon1:setPosition(smallBtnX,btnY+60)
    panelSp:addChild(medalIcon1)

    local medalNum1 = GetTTFLabel(tostring(smallNeedMedal),25)
    medalNum1:setPosition(smallBtnX,btnY+60)
    medalNum1:setAnchorPoint(ccp(0,0.5))
    panelSp:addChild(medalNum1)

    local smallGiftSp=CCSprite:createWithSpriteFrameName("yuanzhuSp.png")
    smallGiftSp:setAnchorPoint(ccp(0.5,1))
    smallGiftSp:setPosition(smallBtnX,panelSp:getContentSize().height-10)
    panelSp:addChild(smallGiftSp,4)

    local smallAward =FormatItem(acXinchunhongbaoVoApi:getSmallPool())
    local function showSmallReward( ... )
      local td = acFeixutansuoRewardTip:new()
      td:init("PanelHeaderPopup.png",getlocal("activity_xinchunhongbao_smallGiftName"),getlocal("activity_feixutansuo_rewardDesc"),smallAward,nil,self.layerNum+1)
    end

    local smallGiftIcon = LuaCCSprite:createWithSpriteFrameName("acSmallGift.png",showSmallReward)
    --smallGiftIcon:setScale(1.2)
    smallGiftIcon:setAnchorPoint(ccp(0.5,0))
    smallGiftIcon:setTouchPriority(-(self.layerNum-1)*20-4)
    smallGiftIcon:setPosition(smallGiftSp:getContentSize().width/2,smallGiftSp:getContentSize().height/2-30)
    smallGiftSp:addChild(smallGiftIcon)

    local hasSmallGiftNumLb = GetTTFLabelWrap(getlocal("propOwned")..hasSmallGift,25,CCSizeMake(smallGiftSp:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    hasSmallGiftNumLb:setAnchorPoint(ccp(0.5,0))
    hasSmallGiftNumLb:setPosition(smallGiftSp:getContentSize().width/2,50)
    smallGiftSp:addChild(hasSmallGiftNumLb)

    local smallGiftName = GetTTFLabelWrap(getlocal("activity_xinchunhongbao_smallGiftName"),25,CCSizeMake(smallGiftSp:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    smallGiftName:setAnchorPoint(ccp(0.5,0))
    smallGiftName:setPosition(smallGiftSp:getContentSize().width/2,50+hasSmallGiftNumLb:getContentSize().height)
    smallGiftSp:addChild(smallGiftName)

    local smallButtomSp = CCSprite:createWithSpriteFrameName("expedition_bg2.png")
    smallButtomSp:setScaleY(0.5)
    -- smallButtomSp:setAnchorPoint(ccp(0.5,1))
    smallButtomSp:setScaleX(1.2)
    smallButtomSp:setPosition(smallBtnX,panelSp:getContentSize().height-smallGiftSp:getContentSize().height)
    panelSp:addChild(smallButtomSp,3)


    local bigGiftBtn = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rewardHandler,2,getlocal("activity_xinchunhongbao_getGiftBtn"),25,102)
    local bigGiftMenu=CCMenu:createWithItem(bigGiftBtn)
    bigGiftMenu:setPosition(ccp(bigBtnX,btnY))
    bigGiftMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    panelSp:addChild(bigGiftMenu,2)

    local medalIcon2 = CCSprite:createWithSpriteFrameName("top3.png")
    medalIcon2:setScale(0.8)
    medalIcon2:setAnchorPoint(ccp(1,0.5))
    medalIcon2:setPosition(bigBtnX,btnY+60)
    panelSp:addChild(medalIcon2)

    local medalNum2 = GetTTFLabel(tostring(bigNeedMedal),25)
    medalNum2:setPosition(bigBtnX,btnY+60)
    medalNum2:setAnchorPoint(ccp(0,0.5))
    panelSp:addChild(medalNum2)

    local bigGiftSp=CCSprite:createWithSpriteFrameName("yuanzhuSp.png")
    bigGiftSp:setAnchorPoint(ccp(0.5,1))
    bigGiftSp:setPosition(bigBtnX,panelSp:getContentSize().height-10)
    panelSp:addChild(bigGiftSp,4)
    bigGiftSp:setColor(ccc3(238,207,0))

    local bigAward =FormatItem(acXinchunhongbaoVoApi:getBigPool())
    local function showBigReward( ... )
      local td = acFeixutansuoRewardTip:new()
      td:init("PanelHeaderPopup.png",getlocal("activity_xinchunhongbao_bigGiftName"),getlocal("activity_feixutansuo_rewardDesc"),bigAward,nil,self.layerNum+1)
    end
    local bigGiftIcon = LuaCCSprite:createWithSpriteFrameName("acBigGift.png",showBigReward)
    --bigGiftIcon:setScale(1.2)
    bigGiftIcon:setAnchorPoint(ccp(0.5,0))
    bigGiftIcon:setTouchPriority(-(self.layerNum-1)*20-4)
    bigGiftIcon:setPosition(bigGiftSp:getContentSize().width/2,bigGiftSp:getContentSize().height/2-30)
    bigGiftSp:addChild(bigGiftIcon)

    local hasBigGiftNumLb = GetTTFLabelWrap(getlocal("propOwned")..hasBigGift,25,CCSizeMake(bigGiftSp:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    hasBigGiftNumLb:setAnchorPoint(ccp(0.5,0))
    hasBigGiftNumLb:setPosition(bigGiftSp:getContentSize().width/2,50)
    bigGiftSp:addChild(hasBigGiftNumLb)

    local bigGiftName = GetTTFLabelWrap(getlocal("activity_xinchunhongbao_bigGiftName"),25,CCSizeMake(bigGiftSp:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    bigGiftName:setAnchorPoint(ccp(0.5,0))
    bigGiftName:setPosition(bigGiftSp:getContentSize().width/2,50+hasBigGiftNumLb:getContentSize().height)
    bigGiftSp:addChild(bigGiftName)

    local bigButtomSp = CCSprite:createWithSpriteFrameName("expedition_bg1.png")
    bigButtomSp:setScaleY(0.5)
    bigButtomSp:setScaleX(1.2)
    bigButtomSp:setPosition(bigBtnX,panelSp:getContentSize().height-bigGiftSp:getContentSize().height)
    panelSp:addChild(bigButtomSp,3)


    if hasSmallGift and hasSmallGift>0 then
      local smallBtnLb=tolua.cast(smallGiftBtn:getChildByTag(101),"CCLabelTTF")
      smallBtnLb:setString(getlocal("activity_xinchunhongbao_getGiftBtn"))
      hasSmallGiftNumLb:setColor(G_ColorWhite)
      medalIcon1:setVisible(true)
      medalNum1:setVisible(true)
      if hasMedal>=smallNeedMedal then
        medalNum1:setColor(G_ColorWhite)
      else
        medalNum1:setColor(G_ColorRed)
      end
    else
      local smallBtnLb=tolua.cast(smallGiftBtn:getChildByTag(101),"CCLabelTTF")
      smallBtnLb:setString(getlocal("activity_xinchunhongbao_giveGiftBtn"))
      hasSmallGiftNumLb:setColor(G_ColorRed)
      medalIcon1:setVisible(false)
      medalNum1:setVisible(false)
    end

     if hasBigGift and hasBigGift>0 then
      local bigBtnLb=tolua.cast(bigGiftBtn:getChildByTag(102),"CCLabelTTF")
      bigBtnLb:setString(getlocal("activity_xinchunhongbao_getGiftBtn"))
      hasBigGiftNumLb:setColor(G_ColorWhite)
      medalIcon2:setVisible(true)
      medalNum2:setVisible(true)
      if hasMedal>=bigNeedMedal then
        medalNum2:setColor(G_ColorWhite)
      else
        medalNum2:setColor(G_ColorRed)
      end
    else
      local bigBtnLb=tolua.cast(bigGiftBtn:getChildByTag(102),"CCLabelTTF")
      bigBtnLb:setString(getlocal("activity_xinchunhongbao_giveGiftBtn"))
      hasBigGiftNumLb:setColor(G_ColorRed)
      medalIcon2:setVisible(false)
      medalNum2:setVisible(false)
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

function acXinchunhongbaoDialog:initLayer2()

  self.bgLayer2=CCLayer:create()

  local backSprite = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(20,20,10,10),function ( ... ) end)
  backSprite:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,self.bgLayer:getContentSize().height-380))
  backSprite:setAnchorPoint(ccp(0.5,0))
  backSprite:setPosition(self.bgLayer2:getContentSize().width/2,20)
  self.bgLayer2:addChild(backSprite)

  local posY = backSprite:getContentSize().height-10

  local friendTitle = GetTTFLabelWrap(getlocal("activity_xinchunhongbao_myFriendsTitle"),25,CCSizeMake(backSprite:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
  friendTitle:setAnchorPoint(ccp(0.5,1))
  friendTitle:setPosition(backSprite:getContentSize().width/2,posY)
  backSprite:addChild(friendTitle)
  friendTitle:setColor(G_ColorYellow)

  posY = posY-friendTitle:getContentSize().height-10
  local lineSP1 =CCSprite:createWithSpriteFrameName("LineCross.png");
  lineSP1:setAnchorPoint(ccp(0.5,0.5))
  lineSP1:setScaleX(backSprite:getContentSize().width/lineSP1:getContentSize().width)
  lineSP1:setScaleY(1.2)
  lineSP1:setPosition(ccp(backSprite:getContentSize().width/2,posY))
  backSprite:addChild(lineSP1)

  posY = posY-30

  local function nilClick( ... )
    -- body
  end

  local titleSp=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),nilClick)
  titleSp:setContentSize(CCSizeMake(backSprite:getContentSize().width-40,50))
  titleSp:setPosition(backSprite:getContentSize().width/2,posY)
  backSprite:addChild(titleSp)
  
  local namelb= GetTTFLabel(getlocal("alliance_scene_button_info_name"),25)
  namelb:setPosition(backSprite:getContentSize().width/4-50,posY)
  backSprite:addChild(namelb)
  namelb:setColor(G_ColorGreen)

  local levellb= GetTTFLabel(getlocal("RankScene_level"),25)
  levellb:setPosition(backSprite:getContentSize().width/2,posY)
  backSprite:addChild(levellb)
  levellb:setColor(G_ColorGreen)

  local actionlb= GetTTFLabel(getlocal("alliance_list_scene_operator"),25)
  actionlb:setPosition(backSprite:getContentSize().width/4*3+50,posY)
  backSprite:addChild(actionlb)
  actionlb:setColor(G_ColorGreen)


  self.hadGiveFriends = GetTTFLabelWrap(getlocal("activity_xinchunhongbao_giveFirendsNum",{acXinchunhongbaoVoApi:getGiveGiftNum(),acXinchunhongbaoVoApi:getDailyTimes()}),25,CCSizeMake(backSprite:getContentSize().width-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  self.hadGiveFriends:setAnchorPoint(ccp(0,0))
  self.hadGiveFriends:setPosition(10,10)
  backSprite:addChild(self.hadGiveFriends)

  local lineSP2 =CCSprite:createWithSpriteFrameName("LineCross.png");
  lineSP2:setAnchorPoint(ccp(0.5,0.5))
  lineSP2:setScaleX(backSprite:getContentSize().width/lineSP2:getContentSize().width)
  lineSP2:setScaleY(1.2)
  lineSP2:setPosition(ccp(backSprite:getContentSize().width/2,20+self.hadGiveFriends:getContentSize().height))
  backSprite:addChild(lineSP2)

  self.friendTb=friendMailVoApi:getFriendTb()

  local function callBack(...)
       return self:eventHandler2(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(backSprite:getContentSize().width-20,backSprite:getContentSize().height-170),nil)
  backSprite:addChild(self.tv2,1)
  self.tv2:setAnchorPoint(ccp(0,0))
  self.tv2:setPosition(ccp(10,60))
  self.bgLayer2:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  backSprite:setTouchPriority(-(self.layerNum-1) * 20 - 2)
  self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
  self.tv2:setMaxDisToBottomOrTop(120)
  
  local function callbackList(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            self.friendTb=friendMailVoApi:getFriendTb()
            if self.tv2 then
              self.tv2:reloadData()
            end
            self:updateNoFriends()
        end
   end
  socketHelper:friendsList(callbackList)


  self.noFriendsLb = GetTTFLabelWrap(getlocal("activity_xinchunhongbao_noFriends"),25,CCSizeMake(backSprite:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
  self.noFriendsLb:setPosition(backSprite:getContentSize().width/2,backSprite:getContentSize().height/2)
  backSprite:addChild(self.noFriendsLb)
  self.noFriendsLb:setVisible(false)

  
end

function acXinchunhongbaoDialog:updateNoFriends()
  if self.noFriendsLb then
    if self.friendTb and SizeOfTable(self.friendTb)>0 then
      self.noFriendsLb:setVisible(false)
    else
      self.noFriendsLb:setVisible(true)
    end
  end
end

function acXinchunhongbaoDialog:eventHandler2(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return SizeOfTable(self.friendTb)
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize
    tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40, 60)

    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, 60))

    local nameStr=self.friendTb[idx+1].nickname
    local levelStr=self.friendTb[idx+1].level
    local uid = self.friendTb[idx+1].uid
    
    local nameLabel=GetTTFLabel(nameStr,25)
    nameLabel:setPosition(cell:getContentSize().width/4-60,cell:getContentSize().height/2)
    cell:addChild(nameLabel,2)

    local levelLabel=GetTTFLabel(getlocal("fightLevel",{levelStr}),25)
    levelLabel:setPosition(cell:getContentSize().width/2-10,cell:getContentSize().height/2)
    cell:addChild(levelLabel,2)

    local function giveGiftCallback( ... )

      if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end 
        PlayEffect(audioCfg.mouseClick)
        self.smallDialogTick = true
        local function callback( ... )
          if self.tv2 then
            local recordPoint = self.tv2:getRecordPoint()
            self.tv2:reloadData()
            self.tv2:recoverToRecordPoint(recordPoint)
          end
          self.smallDialogTick = false
          self:updateHadGiveFriendsNum()
        end
        if self.acSmallDialog then
          --self.acSmallDialog:removeFromParentAndCleanup(true)
          self.acSmallDialog=nil
        end
        self.acSmallDialog=acXinchunhongbaoSmallDialog:create(self.layerNum+1,nameStr,uid,callback)
      end
    end
    local giveGiftBtn = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",giveGiftCallback,2,getlocal("activity_xinchunhongbao_giveFirendsGiftBtn"),25)
    giveGiftBtn:setScale(0.6)
    local giveGiftMenu=CCMenu:createWithItem(giveGiftBtn)
    giveGiftMenu:setPosition(ccp(cell:getContentSize().width/4*3+40,cell:getContentSize().height/2))
    giveGiftMenu:setTouchPriority(-(self.layerNum-1)*20-3)
    cell:addChild(giveGiftMenu,2)

    if acXinchunhongbaoVoApi:checkIsCanGiveGiftByID(uid)==false then
      giveGiftBtn:setEnabled(false)
    else
      giveGiftBtn:setEnabled(true)
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

function acXinchunhongbaoDialog:updateHadGiveFriendsNum()
  if self.hadGiveFriends then
    self.hadGiveFriends:setString(getlocal("activity_xinchunhongbao_giveFirendsNum",{acXinchunhongbaoVoApi:getGiveGiftNum(),acXinchunhongbaoVoApi:getDailyTimes()}))
  end
end


function acXinchunhongbaoDialog:initLayer3()

  self.bgLayer3=CCLayer:create()


  local backSprite = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(20,20,10,10),function ( ... ) end)
  backSprite:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,self.bgLayer:getContentSize().height-380))
  backSprite:setAnchorPoint(ccp(0.5,0))
  backSprite:setPosition(self.bgLayer3:getContentSize().width/2,20)
  self.bgLayer3:addChild(backSprite)

  local function nilClick( ... )
    -- body
  end

  local titleSp=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),nilClick)
  titleSp:setContentSize(CCSizeMake(backSprite:getContentSize().width-40,50))
  titleSp:setPosition(backSprite:getContentSize().width/2,backSprite:getContentSize().height-30)
  backSprite:addChild(titleSp)

  local timeLb = GetTTFLabel(getlocal("alliance_event_time"),26)
  timeLb:setPosition(90,backSprite:getContentSize().height-30)
  timeLb:setColor(G_ColorGreen)
  backSprite:addChild(timeLb)

  local contentLb = GetTTFLabel(getlocal("serverwar_point_record"),26)
  contentLb:setPosition(backSprite:getContentSize().width/2+60,backSprite:getContentSize().height-30)
  contentLb:setColor(G_ColorGreen)
  backSprite:addChild(contentLb)

  local reportMax = GetTTFLabelWrap(getlocal("activity_xinchunhongbao_repordMax",{acXinchunhongbaoVoApi:getRecordNum()}),25,CCSizeMake(backSprite:getContentSize().width-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  reportMax:setAnchorPoint(ccp(0,0))
  reportMax:setPosition(10,10)
  backSprite:addChild(reportMax)
  reportMax:setColor(G_ColorRed)

  local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png");
  lineSP:setAnchorPoint(ccp(0.5,0.5))
  lineSP:setScaleX(backSprite:getContentSize().width/lineSP:getContentSize().width)
  lineSP:setScaleY(1.2)
  lineSP:setPosition(ccp(backSprite:getContentSize().width/2,20+reportMax:getContentSize().height))
  backSprite:addChild(lineSP)


  -- self.reportList={
  --       {
  --         9000025,  --赠送人的uid
  --         "bbb", --姓名
  --         70, --赠送人等级
  --         2,  --类型 1 小礼包 2 大礼包
  --         1,  --1 赠送他人礼包时自己获取的礼包， 2 别人赠送的礼包
  --         1422721498 --获取礼包的时间
  --       },
  --       {
  --         9000025,
  --         "bbb",
  --         70,
  --         1,
  --         2,
  --         1422720808
  --       }
  --     }
  self:getRecordList()

  local function callBack(...)
       return self:eventHandler3(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.tv3=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(backSprite:getContentSize().width-20,backSprite:getContentSize().height-120),nil)
  backSprite:addChild(self.tv3,1)
  self.tv3:setAnchorPoint(ccp(0,0))
  self.tv3:setPosition(ccp(10,60))
  self.bgLayer3:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  backSprite:setTouchPriority(-(self.layerNum-1) * 20 - 2)
  self.tv3:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
  self.tv3:setMaxDisToBottomOrTop(120)


  self.noRepordLb = GetTTFLabelWrap(getlocal("activity_xinchunhongbao_noRepord"),25,CCSizeMake(backSprite:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
  self.noRepordLb:setPosition(backSprite:getContentSize().width/2,backSprite:getContentSize().height/2)
  backSprite:addChild(self.noRepordLb)
  self.noRepordLb:setVisible(false)
end

function acXinchunhongbaoDialog:getRecordList()
    local function ListCallback(fn,data)
      local ret,sData = base:checkServerData(data)
      if ret==true then
        if sData.data.xinchunhongbao.recordlist then
          self.reportList=sData.data.xinchunhongbao.recordlist
          if self.tv3 then
            self.tv3:reloadData()
          end
          self:updateNoRepord()
        end
      end
    end

    socketHelper:activityXinchunhongbaoReportList(ListCallback)
end

function acXinchunhongbaoDialog:updateNoRepord()
  if self.noFriendsLb then
    if self.reportList and SizeOfTable(self.reportList)>0 then
      self.noRepordLb:setVisible(false)
    else
      self.noRepordLb:setVisible(true)
    end
  end
end

function acXinchunhongbaoDialog:eventHandler3(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return SizeOfTable(self.reportList)
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize

    tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,60)

    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,80))

    local data = self.reportList[idx+1]
    local name = data[2]
    local giftType = data[4]
    local getGiftType = data[5]
    local time = data[6]
    local giveTime =GetTTFLabel(G_getDataTimeStr(time),25)
    giveTime:setPosition(80,cell:getContentSize().height/2)
    cell:addChild(giveTime) 

    local giftName = ""
    if giftType==1 then
      giftName=getlocal("activity_xinchunhongbao_smallGiftName")
    elseif giftType==2 then
      giftName=getlocal("activity_xinchunhongbao_bigGiftName")
    end
    local nameStr = ""
    if getGiftType==1 then
      nameStr=getlocal("activity_xinchunhongbao_repordSystem")
    elseif getGiftType==2 then
      nameStr=tostring(name)
    end

    local widthPos = 50
    local lbSize =25
    if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="in" then
        widthPos =68
        lbSize =22
    end

    local content = GetTTFLabelWrap(getlocal("activity_xinchunhongbao_repord",{nameStr,giftName}),lbSize,CCSizeMake(cell:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    content:setPosition(cell:getContentSize().width/2+widthPos,cell:getContentSize().height/2)
    cell:addChild(content)
    if giftType==2 then
      content:setColor(G_ColorYellow)
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

function acXinchunhongbaoDialog:tick()
    if acXinchunhongbaoVoApi:isRefreshMedalTime()==false then
      acXinchunhongbaoVoApi:refreshDataToday()
      if self.tv1 then
        self.tv1:reloadData()
      end
      if self.tv2 then
        self.tv2:reloadData()
      end
      self:updateHadGiveFriendsNum()
    end
    if self.smallDialogTick == true then
      if self.acSmallDialog then
        self.acSmallDialog:tick()
      end
    end
end

function acXinchunhongbaoDialog:update()
  local acVo = acXinchunhongbaoVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self.acSmallDialog then
            for k,v in pairs(G_SmallDialogDialogTb) do
                if v and v.close then
                    v:close()
                end
            end
        end
        if self ~= nil then
            self:close()
        end

    elseif self ~= nil and self.tv ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
      local recordPoint = self.tv:getRecordPoint()
      self.tv:reloadData()
      self.tv:recoverToRecordPoint(recordPoint)
    elseif self ~= nil and self.tv1 ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
      self.tv1:reloadData()
    elseif self ~= nil and self.tv2 ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
      local recordPoint = self.tv2:getRecordPoint()
      self.tv2:reloadData()
      self.tv2:recoverToRecordPoint(recordPoint)
    elseif self ~= nil and self.tv3 ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
      local recordPoint = self.tv3:getRecordPoint()
      self.tv3:reloadData()
      self.tv3:recoverToRecordPoint(recordPoint)
    end
  end
end

function acXinchunhongbaoDialog:dispose()
  CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/expeditionImage.plist")
  CCTextureCache:sharedTextureCache():removeTextureForKey("public/expeditionImage.png")
  

	self.tv = nil
	self.cellHeight=nil
  self.tv1 = nil 
  self.tv2 = nil 
  self.tv3 = nil 
  self.friendTb=nil
  self.reportList=nil
  self.smallDialogTick=nil
  self.acSmallDialog=nil
  if self.bgLayer1 then
    self.bgLayer1:removeFromParentAndCleanup(true)
    self.bgLayer1=nil
  end
  if self.bgLayer2 then
    self.bgLayer2:removeFromParentAndCleanup(true)
    self.bgLayer2=nil
  end
  if self.bgLayer3 then
    self.bgLayer3:removeFromParentAndCleanup(true)
    self.bgLayer3=nil
  end

  if self.bgLayer then
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
  end
end