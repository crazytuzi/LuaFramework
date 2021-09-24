--require "luascript/script/componet/commonDialog"
acFbRewardDialog=commonDialog:new()

function acFbRewardDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum
    
    self.layerTab1=nil
    self.layerTab2=nil
    self.playerTab1=nil
    self.playerTab2=nil

    self.getTimes = 0-- 如果获取list请求失败，可以连续获取3次List，若3次以后还是失败，那就等5分钟以后再获取
    return nc
end

function acFbRewardDialog:resetTab()
    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v
         if index==0 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end 
         index=index+1
    end
end

--设置对话框里的tableView
function acFbRewardDialog:initTableView()
    
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setVisible(false)

    self.tv:setMaxDisToBottomOrTop(120)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acFbRewardDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 4

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize =CCSizeMake(400,180)
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

--点击tab页签 idx:索引
function acFbRewardDialog:tabClick(idx)
    if newGuidMgr:isNewGuiding() then --新手引导
      if newGuidMgr.curStep==39 and idx~=1 then
            do
                return
            end
      end
    end
    PlayEffect(audioCfg.mouseClick)
    if idx == 1 then
      local willReturn = false
      local buildVo=buildingVoApi:getBuildingVoByBtype(15)[1]--军团建筑
      if base.isAllianceSwitch==0 then
        -- 军团功能未开放
        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("alliance_willOpen"),nil,self.layerNum + 1)
        willReturn = true
      elseif buildVo == nil or buildVo.status > 0  then
        -- 军团等级不足
        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("activity_fbReward_lvLowTip"),nil,self.layerNum + 1)
        willReturn = true
      elseif allianceVoApi:isHasAlliance()==false then
        -- 玩家没有军团
        local function gotoAlliancePanel( ... )
          activityAndNoteDialog:gotoAlliance(false)
        end
        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("activity_fbReward_noAllianceTip"),nil,self.layerNum + 1, nil, gotoAlliancePanel)
        willReturn = true
      end
      if willReturn == true then
        do
          self:tabClickColor(0) 
          return
        end
      end
    end

    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            self:doUserHandler()            
         else
            v:setEnabled(true)
         end
    end
    
    if idx==1 then
        if newGuidMgr:isNewGuiding() then --新手引导
             newGuidMgr:toNextStep()
        end
        
        if self.layerTab2==nil then
            self.playerTab2=acFbRewardTab2:new(self)
            self.layerTab2=self.playerTab2:init(self.layerNum)
            self.bgLayer:addChild(self.layerTab2);
            self.layerTab2:setPosition(ccp(999333,0))
        else
            self.layerTab2:setVisible(true)
        end
        
        
        if self.layerTab1 ~= nil then
            self.layerTab1:setVisible(false)
        self.layerTab1:setPosition(ccp(10000,0))
        end
        
        self.layerTab2:setPosition(ccp(0,0))
            
    elseif idx==0 then
            
        if self.layerTab2~=nil then
            self.layerTab2:setPosition(ccp(999333,0))
            self.layerTab2:setVisible(false)
        end
        
        if self.playerTab1==nil then
            self.playerTab1=acFbRewardTab1:new()
            self.layerTab1=self.playerTab1:init(self.layerNum)
            self.bgLayer:addChild(self.layerTab1)
        else
             self.layerTab1:setVisible(true)
        end

        self.layerTab1:setPosition(ccp(0,0))
    end
end


function acFbRewardDialog:tick()
  if allianceVoApi:isHasAlliance() == true then
    local vo = acFbRewardVoApi:getAcVo()
    if acFbRewardVoApi.lastSt + 300 < base.serverTime and self.getTimes <= 2 then

      local function getList(fn,data)
        local ret,sData=base:checkServerData(data)

        if ret==true then
           PlayEffect(audioCfg.mouseClick)

           if sData.data.unlockranking ~= nil then
              acFbRewardVoApi:updateRankList(sData.data.unlockranking)
              acFbRewardVoApi:setLastSt()
              self.getTimes = 0
              self:update()
           end
          
        end
      end
      self.getTimes = self.getTimes + 1
      if self.getTimes > 2 then
        self.getTimes = 0
        acFbRewardVoApi:setLastSt()
      end
      socketHelper:getFbRewardRankList(getList)
    end
  end

  if self and self.playerTab1 and self.playerTab1.tick then
      self.playerTab1:tick()
  end
end


function acFbRewardDialog:update()
  if self.playerTab1 ~= nil then
     self.playerTab1:updateRewardBtn() -- 更新领奖按钮
  end

  if self.playerTab2 ~= nil then
     self.playerTab2.tv:reloadData()
  end
end

function acFbRewardDialog:dispose()
    if self.playerTab1~=nil then
        self.playerTab1:dispose()
    end
    if self.playerTab2~=nil then
        self.playerTab2:dispose()
    end
    self.layerTab1=nil
    self.layerTab2=nil
    self.playerTab1=nil
    self.playerTab2=nil
    self.layerNum = nil
    self.getTimes = 0
    self=nil

end




