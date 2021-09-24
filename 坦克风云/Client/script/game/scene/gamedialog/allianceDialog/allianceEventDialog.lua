--require "luascript/script/componet/commonDialog"
allianceEventDialog=commonDialog:new()

function allianceEventDialog:new(tabType,layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.layerNum=layerNum
   
    return nc
end

--设置或修改每个Tab页签
function allianceEventDialog:resetTab()

    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==2 then
         tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)

         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end    
    
end


function allianceEventDialog:initTableView()

    local function callBack3(...)
       return self:eventHandler3(...)
    end
    local hd3= LuaEventHandler:createHandler(callBack3)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd3,CCSizeMake(self.bgLayer:getContentSize().width-40,G_VisibleSize.height-130-40),nil)
    --self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,25))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)

    local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(60, 20, 1, 1)
    local function touch(hd,fn,idx)

    end

    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),touch)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,G_VisibleSizeHeight-80-40))
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-80-15))
    self.bgLayer:addChild(backSprie)

    local wholeBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdzNameBg.png",CCRect(4, 4, 1, 1),function () end)
    wholeBgSp:setContentSize(CCSizeMake(backSprie:getContentSize().width,40))
    wholeBgSp:setAnchorPoint(ccp(0.5,1))
    wholeBgSp:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height-10))
    backSprie:addChild(wholeBgSp)

    local timeLb=GetTTFLabel(getlocal("alliance_event_time"),22,true)
    timeLb:setPosition(75,wholeBgSp:getContentSize().height/2)
    timeLb:setAnchorPoint(ccp(0.5,0.5))
    wholeBgSp:addChild(timeLb)
    timeLb:setColor(G_ColorYellowPro2)

    local eventLb=GetTTFLabel(getlocal("alliance_event_event"),22,true)
    eventLb:setPosition(340,wholeBgSp:getContentSize().height/2)
    eventLb:setAnchorPoint(ccp(0.5,0.5))
    wholeBgSp:addChild(eventLb)
    eventLb:setColor(G_ColorYellowPro2)

    if allianceVoApi:getUnReadEventNum()>0 then
      allianceEventVoApi:clear()
    end
    if allianceEventVoApi:getEventNum()<=0 then
      local function GeteventsCallback(fn,data)
          local ret,sData=base:checkServerData(data)
          if ret==true then
              if sData and sData.data and sData.data.alliance and sData.data.alliance.events then
                  allianceEventVoApi:formatData(sData.data.alliance.events)

                  if self.tv then
                      self.tv:reloadData()
                  end
                  if allianceEventVoApi:getEventNum()<=0 then
                      if self.noEventLabel then
                          self.noEventLabel:setVisible(true)
                      else
                          self.noEventLabel=GetTTFLabel(getlocal("noEventDesc"),30)
                          self.noEventLabel:setAnchorPoint(ccp(0.5,0.5))
                          self.noEventLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-550))
                          self.bgLayer:addChild(self.noEventLabel,1)
                          self.noEventLabel:setColor(G_ColorGray)
                      end
                  end
                  allianceVoApi:setUnReadEventNum(0)
              end
          end
      end
      local page=allianceEventVoApi:getPage()
      socketHelper:allianceGetevents(page,GeteventsCallback)
   else
      if self.noEventLabel then
          self.noEventLabel:setVisible(false)
      end
   end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function allianceEventDialog:eventHandler3(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local num=allianceEventVoApi:getEventNum()
        local isHasMore=allianceEventVoApi:isHasMore()
        if isHasMore then
            num=num+1
        end
        return num
    elseif fn=="tableCellSizeForIndex" then
        local allEvent=allianceEventVoApi:getAllEvent()
        local eventVo=allEvent[idx+1]
        local isHasMore=allianceEventVoApi:isHasMore()
        local tmpSize
        if eventVo then
            tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,eventVo.height)
        end
        if isHasMore then
            local num=allianceEventVoApi:getEventNum()
            if idx==num then
                tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,80)
            end
        end
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()




        local num=allianceEventVoApi:getEventNum()
        if num<=0 then
            do return end
        end
        local isHasMore=allianceEventVoApi:isHasMore()
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                PlayEffect(audioCfg.mouseClick)
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end

                local function GeteventsCallback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        if sData and sData.data and sData.data.alliance and sData.data.alliance.events then
                            local addHeight=allianceEventVoApi:formatData(sData.data.alliance.events)
                            local newHasMore=allianceEventVoApi:isHasMore()
                            if allianceEventVoApi:getPage()>=1 then
                                local recordPoint = self.tv:getRecordPoint()
                                recordPoint.y=recordPoint.y-addHeight
                                if newHasMore==false then
                                    recordPoint.y=recordPoint.y+80
                                end
                                self.tv:reloadData()
                                self.tv:recoverToRecordPoint(recordPoint)
                            else
                                self.tv:reloadData()
                            end
                        end
                    end
                end
                local page=allianceEventVoApi:getPage()
                socketHelper:allianceGetevents(page,GeteventsCallback)
            end
        end
        local backSprie
        if isHasMore and idx==num then
            backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSet,cellClick)
            backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, 80))
            backSprie:ignoreAnchorPointForPosition(false);
            backSprie:setAnchorPoint(ccp(0.5,0.5));
            backSprie:setTag(idx)
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
            backSprie:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2,40))
            -- cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, 80))
            cell:addChild(backSprie,1)
            
            local moreLabel=GetTTFLabel(getlocal("showMore"),22)
            moreLabel:setPosition(getCenterPoint(backSprie))
            backSprie:addChild(moreLabel,2)
            
            do return cell end
        end
        


        local allEvent=allianceEventVoApi:getAllEvent()
        local eventVo=allEvent[idx+1]
        if eventVo==nil then
            do return end
        end
        local height=eventVo.height
        local message=eventVo.message
        cell:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,height))
        local grayBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png",CCRect(4,4,1,1),function ()end)
        grayBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,height))
        grayBgSp:setAnchorPoint(ccp(0.5,1))
        grayBgSp:setPosition(ccp(cell:getContentSize().width/2,cell:getContentSize().height))
        cell:addChild(grayBgSp) 
        if (idx+1)%2 == 1 then
          grayBgSp:setOpacity(0)
        end

        local timeStr=allianceEventVoApi:getTimeStr(eventVo.time)
        local timeLabel=GetTTFLabel(timeStr,22)
        timeLabel:setAnchorPoint(ccp(0.5,0.5))
        timeLabel:setPosition(ccp(79,height/2))
        grayBgSp:addChild(timeLabel,1)

        local textLabel=GetTTFLabelWrap(message,22,CCSizeMake(eventVo.width,height),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        textLabel:setAnchorPoint(ccp(0.5,0.5))
        textLabel:setPosition(ccp(370,height/2))
        grayBgSp:addChild(textLabel,1)

        if eventVo.isFight then
            timeLabel:setColor(G_ColorYellowPro2)
            textLabel:setColor(G_ColorYellowPro2)
        end

        return cell

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

--点击tab页签 idx:索引
function allianceEventDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            self:tabClickColor(idx)
            self:doUserHandler()
         else
            v:setEnabled(true)
         end
    end
    self:resetForbidLayer()
end

--用户处理特殊需求,没有可以不写此方法
function allianceEventDialog:doUserHandler()
  if self.panelLineBg then
    self.panelLineBg:setVisible(false)
  end
  
  if self.panelTopLine then
    self.panelTopLine:setVisible(false)
  end
  -- 去渐变线
  local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
  panelBg:setAnchorPoint(ccp(0.5,0))
  panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
  panelBg:setPosition(G_VisibleSizeWidth/2,2)
  self.bgLayer:addChild(panelBg)

end

--点击了cell或cell上某个按钮
function allianceEventDialog:cellClick(idx)
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

function allianceEventDialog:tick()
    

    
end

function allianceEventDialog:dispose()
    local data={key="alliance_scene_event_title"}
    eventDispatcher:dispatchEvent("allianceFunction.numChanged",data)
    self.expandIdx=nil
    self=nil
end




