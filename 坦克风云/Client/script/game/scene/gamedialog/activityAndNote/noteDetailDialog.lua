--require "luascript/script/componet/commonDialog"
noteDetailDialog=commonDialog:new()

function noteDetailDialog:new(note)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.note = note
    self.des = nil
    self.desH = nil
    self.rewardBtn=nil
    return nc
end

--点击tab页签 idx:索引
function noteDetailDialog:initTableView()
  
  local h, title=self:getTitle(self.note.title,30)
  local titleX = G_VisibleSizeWidth/2
  local titleY = G_VisibleSizeHeight - 70 - h
  title:setAnchorPoint(ccp(0.5, 0))
  title:setPosition(ccp(titleX, titleY))
  title:setColor(G_ColorYellowPro)
  self.bgLayer:addChild(title)

  local timeH, timeLabel = self:getTitle(G_getDataTimeStr(self.note.st, true), 26)
  local timeY = titleY - timeH
  timeLabel:setAnchorPoint(ccp(0.5, 0))
  timeLabel:setPosition(ccp(titleX, timeY))
  self.bgLayer:addChild(timeLabel)
  
  self.desH,self.des = self:getDes(self.note.des)
  if self.note.isReward and self.note.isReward>0 then
      self.desH=self.desH+120
  end

  local function callBack(...)
       return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
  self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, timeY - 20))
  self.panelLineBg:setPosition(ccp(titleX, 10))

 
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 20, timeY - 40),nil)
  self.bgLayer:addChild(self.tv)
  self.tv:setPosition(ccp(10,20))
  self.tv:setAnchorPoint(ccp(0,0))
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setMaxDisToBottomOrTop(120)
end

function noteDetailDialog:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
     local tmpSize=CCSizeMake(G_VisibleSizeWidth - 40,self.desH)
     return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    local posY=self.desH - 5
    local width=G_VisibleSizeWidth - 40
    for k,v in pairs(self.des) do
      local msgLb=GetTTFLabelWrap(v[1],20,CCSizeMake(width,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
      msgLb:setAnchorPoint(ccp(0,1))
      msgLb:setPosition(20,posY)
      cell:addChild(msgLb,1)
      if(v[2]==1)then
          msgLb:setColor(G_ColorYellowPro)
          local function onClick()
            if(v[1] and v[1]~="")then
              local tmpTb={}
              tmpTb["action"]="openUrl"
              tmpTb["parms"]={}
              tmpTb["parms"]["url"]=v[1]
              local cjson=G_Json.encode(tmpTb)
              G_accessCPlusFunction(cjson)
            end
          end
          local clickSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),onClick)
          clickSp:setTouchPriority(-(self.layerNum-1)*20-2)
          clickSp:setContentSize(CCSizeMake(width,msgLb:getContentSize().height))
          clickSp:setAnchorPoint(ccp(0,1))
          clickSp:setPosition(20,posY)
          clickSp:setOpacity(0)
          cell:addChild(clickSp)
      end
      posY=posY - msgLb:getContentSize().height - 10
    end

    if self.note and self.note.isReward and self.note.isReward>0 then
        local zoneId=tostring(base.curZoneID)
        local gameUid=tostring(playerVoApi:getUid())
        local nid=self.note.id
        local key=tostring("note_"..zoneId.."_"..gameUid.."_"..nid)

        local function rewardHandler(tag,object)
            local value=CCUserDefault:sharedUserDefault():getIntegerForKey(key)
            local isReward=noteVoApi:isReward(self.note)
            if value==1 or isReward==true then
                -- do return end
            end
            if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                PlayEffect(audioCfg.mouseClick)
                local function rewardCallback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then

                        noteVoApi:setIsReward(self.note)

                        CCUserDefault:sharedUserDefault():setIntegerForKey(key,1)
                        CCUserDefault:sharedUserDefault():flush()

                        if self and self.rewardBtn then
                            self.rewardBtn:setEnabled(false)
                            tolua.cast(self.rewardBtn:getChildByTag(101),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
                        end
                        
                        if sData.data and sData.data.noticereward and sData.data.noticereward.reward then
                            local award=FormatItem(sData.data.noticereward.reward) or {}
                            for k,v in pairs(award) do
                                G_addPlayerAward(v.type,v.key,v.id,v.num)
                            end
                            G_showRewardTip(award)
                        end
                    end
                end
                socketHelper:noticeReward(self.note.id,rewardCallback)
            end
        end
        self.rewardBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rewardHandler,11,getlocal("activity_hadReward"),25,101)
        self.rewardBtn:setAnchorPoint(ccp(0.5,0))
        local rewardMenu=CCMenu:createWithItem(self.rewardBtn)
        rewardMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2-10, 10))
        rewardMenu:setTouchPriority(-(self.layerNum-1)*20-2)
        self.rewardBtn:setScale(0.8)
        cell:addChild(rewardMenu,2)
        self.rewardBtn:setEnabled(false)

        local value=CCUserDefault:sharedUserDefault():getIntegerForKey(key)

        local isReward=noteVoApi:isReward(self.note)
        -- print("value",value)
        -- print("isReward",isReward)

        if isReward==false and value==0 then
            self.rewardBtn:setEnabled(true)
            tolua.cast(self.rewardBtn:getChildByTag(101),"CCLabelTTF"):setString(getlocal("daily_scene_get"))
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

function noteDetailDialog:getDes(content)
  local desTb={}
  local showMsg=content or ""
  local width=G_VisibleSizeWidth - 40
  local strLen=string.len(showMsg)
  local wz=showMsg
  local endMsg=showMsg
  local startIdx,endIdx=string.find(wz,"#(.-)#")
  while startIdx~=nil do
    local firstStr=""
    local endStr=""
    if startIdx>1 then
      firstStr=string.sub(wz,1,startIdx-1)
    end
    if endIdx<strLen then
      endStr=string.sub(wz,endIdx+1)
    end
    if endIdx-startIdx>1 then
      local newKey=string.sub(wz,startIdx+1,endIdx-1)
      table.insert(desTb,{firstStr,0})
      table.insert(desTb,{newKey,1})
    end
    wz=endStr
    endMsg=endStr
    startIdx,endIdx=string.find(wz,"#(.-)#")
  end
  if endMsg and endMsg~="" then
    table.insert(desTb,{endMsg,0})
  end
  local height=0
  for k,v in pairs(desTb) do
    local msgLb=GetTTFLabelWrap(v[1],24,CCSizeMake(width,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    height=height + msgLb:getContentSize().height + 10
  end
  return height,desTb
end

function noteDetailDialog:getTitle(content, size)
  local showMsg=content or ""
  local width=G_VisibleSizeWidth - 20
  local messageLabel=GetTTFLabelWrap(showMsg,size,CCSizeMake(width, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
  local height=messageLabel:getContentSize().height+20
  -- messageLabel:setDimensions(CCSizeMake(width, height+50))
  return height, messageLabel
end

function noteDetailDialog:dispose()
  self.note = nil
  self.des = nil
  self.desH = nil
  self.rewardBtn=nil
  self=nil
end





