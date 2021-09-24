platformAwardsDialog=smallDialog:new()

function platformAwardsDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogHeight=450
	self.dialogWidth=550

	self.parent=parent
	return nc
end

function platformAwardsDialog:create(layerNum,list)
	--self.rewardIDList = list
    self.rewardIDList=playerVoApi:getPlatformCanReward()
    local sd=platformAwardsDialog:new()
    self.layerNum = layerNum
    sd:init(layerNum)
    return sd

end
function platformAwardsDialog:init(layerNum)
    self.isTouch=false
    self.isUseAmi=false
    local function touchHandler()
    
    end
    
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),touchHandler)
    self.dialogLayer=CCLayer:create()
    
    self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(550,450)
    self.bgLayer:setContentSize(self.bgSize)
    self:show()

    
    
    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);
    sceneGame:addChild(self.dialogLayer,layerNum)
    
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);

    if self.rewardIDList then
        local totalH =0
        for k,v in pairs(self.rewardIDList) do
            if activityCfg.newPlatGift[v[1]] and activityCfg.newPlatGift[v[1]]["reward"] then
                local reward = activityCfg.newPlatGift[v[1]]["reward"]
                local award=FormatItem(reward) or {}
                totalH= totalH+math.ceil(SizeOfTable(award)/3)*120
            end
        end
        if totalH>550 then
            totalH = 550
        end
        if totalH>self.bgSize.height-100 then
            self.bgLayer:setContentSize(CCSizeMake(self.bgSize.width,totalH+100))
        end
    end
    local function close()
    	if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end 
        PlayEffect(audioCfg.mouseClick)

        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-6)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgLayer:getContentSize().height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)

    local titleLb=GetTTFLabel(getlocal("award"),40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)

    if self.rewardIDList and SizeOfTable(self.rewardIDList)<=0 then
        local descLb = GetTTFLabelWrap(getlocal("platformRewardAll"),30,CCSizeMake(self.bgLayer:getContentSize().width-60,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter)
        descLb:setAnchorPoint(ccp(0.5,0.5))
        descLb:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2)
        self.bgLayer:addChild(descLb)
    else
        local function callBack(...)
            return self:eventHandler(...)
      end
      local hd= LuaEventHandler:createHandler(callBack)
      self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width,self.bgLayer:getContentSize().height-120),nil)
      self.bgLayer:addChild(self.tv,1)
      self.tv:setAnchorPoint(ccp(0,0))
      self.tv:setPosition(ccp(0,20))
      self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
      self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
      self.tv:setMaxDisToBottomOrTop(120)
    end


    

end

function platformAwardsDialog:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return SizeOfTable(self.rewardIDList)
  elseif fn=="tableCellSizeForIndex" then
    local cellHeight=200
    if activityCfg.newPlatGift[self.rewardIDList[idx+1][1]] and activityCfg.newPlatGift[self.rewardIDList[idx+1][1]]["reward"] then
        local reward = activityCfg.newPlatGift[self.rewardIDList[idx+1][1]]["reward"]
        local award=FormatItem(reward) or {}
        cellHeight= math.ceil(SizeOfTable(award)/3)*120
    end
    return  CCSizeMake(self.bgLayer:getContentSize().width,cellHeight)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    -- local function rewardList(fn,data)
    --  local ret,sData=base:checkServerData(data)
    --         if ret==true then

    --          if sData.data~=nil and sData.data.reward~=nil then
    --                 
    -- local httpUrl=self:getFriendUrlPrefix().."invite/reward"
    -- local reqStr="zoneid="..base.curZoneID.."&uid="..playerVoApi:getUid().."&box="..data["rewardIndex"]

    -- if(retStr~="")then

        --local reward={p={{p5=2,index=1},{p5=13,index=1},{p5=3,index=1},{p5=4,index=1},{p5=5,index=1},{p5=10,index=1},{p5=1,index=1},{p13=1,index=2},{p12=1,index=2},{p11=1,index=3},{p15=1,index=4},},}
        local cellHeight = 200
        local pIconX=0
        local pIconY=0
        if activityCfg.newPlatGift[self.rewardIDList[idx+1][1]] and activityCfg.newPlatGift[self.rewardIDList[idx+1][1]]["reward"] then
            local reward = activityCfg.newPlatGift[self.rewardIDList[idx+1][1]]["reward"]
            local award=FormatItem(reward) or {}
            cellHeight= math.ceil(SizeOfTable(award)/3)*120
            for k,v in pairs(award) do
                local icon,iconScale = G_getItemIcon(v,100,true,self.layerNum)
                icon:setTouchPriority(-(self.layerNum-1)*20-3)
                icon:setAnchorPoint(ccp(0,1))
                pIconX = 45+((k-1)%3)*120
                pIconY = cellHeight -(math.floor((k-1)/3))*120
                icon:setPosition(pIconX,pIconY)
                cell:addChild(icon)

                local num = GetTTFLabel("x"..v.num,25/iconScale)
                num:setAnchorPoint(ccp(1,0))
                num:setPosition(icon:getContentSize().width-10,10)
                icon:addChild(num)

            end
        end
        
    -- end

        

    --             end

    --         end
    --      end

    -- end

    -- socketHelper:platformAwardsList(rewardList)


    
    
    local function reward()

        if G_checkClickEnable()==false then
          do
              return
          end
        else
          base.setWaitTime=G_getCurDeviceMillTime()
        end 
        PlayEffect(audioCfg.mouseClick)

        -- local function callback(fn,data)
        --     local ret,sData=base:checkServerData(data)
        --     if ret==true then
        --         if sData.data~=nil and sData.data.reward~=nil then
        --             local award=FormatItem(sData.data.reward) or {}
        --             for k,v in pairs(award) do
        --                 G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
        --             end
        --             G_showRewardTip(award)

        --         end
                
        --     end


        local httpUrl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidtencentaddawards"

        local reqStr="pid="..base.platformUserId.."&token="..base.token.."&rewardid="..self.rewardIDList[idx+1][1].."&taskid="..self.rewardIDList[idx+1][2].."&zoneid="..base.curZoneID.."&uid="..playerVoApi:getUid()
        --local reqStr="pid=".."TX_225689C9BBBCC131C7A1967FF6E10B0A".."&token=".."A4F5D01440308509035AA79A38766F7D".."&rewardid="..self.rewardIDList[idx+1][1].."&taskid="..self.rewardIDList[idx+1][2].."&zoneid="..base.curZoneID.."&uid="..playerVoApi:getUid()

         deviceHelper:luaPrint("libaoparm:"..reqStr)
            local retStr=G_sendHttpRequestPost(httpUrl,reqStr)
         deviceHelper:luaPrint("libaoret:"..retStr)
        print(retStr)
        if(retStr~="")then
            playerVoApi:addPlatformCanRewardByID(self.rewardIDList[idx+1][1],self.rewardIDList[idx+1][2])
            self.rewardIDList=playerVoApi:getPlatformCanReward()
            self.tv:reloadData()
            if SizeOfTable(self.rewardIDList)<=0 then
                self:close()
                mainUI.isShowplatformAwards = false
            end
        end
        -- socketHelper:platformAwardsReward(callback)
    end
    local rewardItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnCancleSmall.png",reward,nil,getlocal("newGiftsReward"),25)
    local rewardMenu=CCMenu:createWithItem(rewardItem);
    rewardMenu:setPosition(ccp(self.bgLayer:getContentSize().width-100,pIconY-50))
    rewardMenu:setTouchPriority((-(self.layerNum-1)*20-4));
    if activityCfg.newPlatGift[self.rewardIDList[idx+1][1]] and activityCfg.newPlatGift[self.rewardIDList[idx+1][1]]["reward"] then
        cell:addChild(rewardMenu)
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



