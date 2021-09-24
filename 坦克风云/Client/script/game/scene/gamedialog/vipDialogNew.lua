--require "luascript/script/componet/commonDialog"
vipDialogNew=commonDialog:new()

function vipDialogNew:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.vipDescLabel=nil
    self.rechargeBtn=nil
    self.menuRecharge=nil
	self.buygems=nil
	self.timerSprite=nil
	self.vipBgSprie=nil
	self.vipLevelLabel=nil
	self.vipIcon=nil

  self.expandIdx={}
  self.normalHeight=60
  self.lbTab={}

  self.tv2CellHeight= nil
  self.tv2CellBsHeight=nil
  self.tv2CellBtnUpStrHeight =nil
  self.tv2cellBtnHeight =nil
	self.heightTab={}
    self.vipNum=playerVoApi:getMaxLvByKey("maxVip")+1
    self.showVip=self.vipNum
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
    return nc
end


--设置对话框里的tableView
function vipDialogNew:initTableView()
    if platCfg.platCfgShowVip[G_curPlatName()]~=nil then
        if playerVoApi:getVipLevel()==0 then
            self.showVip=2
        elseif playerVoApi:getVipLevel()>=1 and playerVoApi:getVipLevel()<5 then
            self.showVip=6
        elseif playerVoApi:getVipLevel()>=5 then
            self.showVip=playerVoApi:getVipLevel()+2
            if self.showVip>=self.vipNum then
                self.showVip=self.vipNum
            end
        end
    end
	self.panelLineBg:setContentSize(CCSizeMake(580,G_VisibleSize.height-430))
	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-127))
    --self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-5)
    
    local vipLevel=playerVoApi:getVipLevel()
    if vipLevel>=0 then
        if vipLevel<=self.showVip then
            self.expandIdx["k"..vipLevel]=self:getCellHeight(vipLevel)
        end
        -- if vipLevel+1<=self.showVip then
        --     self.expandIdx["k"..vipLevel+1]=self:getCellHeight(vipLevel+1)
        -- end
    end

    local function callBack(...)
       return self:eventHandler(...)
    end
    self.bgy=self.panelLineBg:getPositionY()-self.panelLineBg:getContentSize().height/2+5
    local hd= LuaEventHandler:createHandler(callBack)
self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.panelLineBg:getContentSize().width-20,self.panelLineBg:getContentSize().height-10),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    -- self.tv:setAnchorPoint(ccp(0.5,1))
    -- self.tv:setPosition(ccp(self.panelLineBg:getContentSize().width/2-self.tv:getContentSize().width/2,5))
    -- self.tv:setPosition(ccp(self.bgLayer:getContentSize().width/2-self.tv:getContentSize().width/2,self.bgy))
    self.tv:setPosition(ccp(40,92))

    -- self.panelLineBg:addChild(self.tv)
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(80)

--     local function callBack2(...)
--        return self:eventHandler2(...)
--     end
--     local hd= LuaEventHandler:createHandler(callBack2)
-- self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.panelLineBg:getContentSize().width-20,self.panelLineBg:getContentSize().height-10),nil)
--     self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
--     self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
--     self.tv2:setAnchorPoint(ccp(0.5,1))
--     self.tv2:setPosition(ccp(9000,0))

--     -- self.panelLineBg:addChild(self.tv2)
--     self.bgLayer:addChild(self.tv2)
--     self.tv2:setMaxDisToBottomOrTop(80)
--     self.tv2:setVisible(false)

--      if self.cellNum==0 and playerVoApi:getVipLevel() == self.vipNum-1 then
--           local  showAllLb= GetTTFLabelWrap(getlocal("vip_tequanlibao_allready_des"),30,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
--           showAllLb:setColor(G_ColorYellow)
--          showAllLb:setAnchorPoint(ccp(0.5,0.5))
--           showAllLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.panelLineBg:getContentSize().height/2))
--           self.panelLineBg:addChild(showAllLb)
--           self.showAllLb=showAllLb
--           if self.tv2:isVisible()==true then
--             self.showAllLb:setVisible(true)
--           else
--             self.showAllLb:setVisible(false)
--           end
       
--     end
	
	
    local function touch(hd,fn,idx)
    end
    self.vipBgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("VipLineYellow.png",CCRect(20, 20, 10, 10),touch)
    self.vipBgSprie:setContentSize(CCSizeMake(580,150))
    self.vipBgSprie:ignoreAnchorPointForPosition(false)
    self.vipBgSprie:setAnchorPoint(ccp(0.5,1))
    self.vipBgSprie:setIsSallow(false)
    self.vipBgSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    self.vipBgSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-115))
    self.bgLayer:addChild(self.vipBgSprie,1)

  local function touch1(hd,fn,idx)

  end
	self.vipIcon=LuaCCScale9Sprite:createWithSpriteFrameName("VipIconYellow.png",CCRect(110, 60, 1, 1),touch1)
  self.vipIcon:setContentSize(CCSizeMake(300,74))
    self.vipIcon:setAnchorPoint(ccp(0.5,0.5))
    self.vipIcon:setPosition(ccp(self.vipBgSprie:getContentSize().width/2,self.vipBgSprie:getContentSize().height))
    self.vipBgSprie:addChild(self.vipIcon,1)
	
	self:updateVipSchedule()
	
  self:setTvPos()
	-- local vipLevel=playerVoApi:getVipLevel()
	-- if vipLevel>0 then
	-- 	local recordPoint = self.tv:getRecordPoint()
	-- 	if vipLevel<=9 then
	-- 		local diffHeight=0
	-- 		for i=1,vipLevel do
	-- 			-- if i==1 then
	-- 			-- 	diffHeight=diffHeight+40*4+60-10
	-- 			-- elseif i<6 then
	-- 			-- 	diffHeight=diffHeight+40*5+60-5*(i-1)
 --    --     else
 --    --       diffHeight=diffHeight+40*5+60-10
	-- 			-- end
 --        diffHeight = diffHeight + self.heightTab[i]+120--60
	-- 		end
	-- 		recordPoint.y=recordPoint.y+diffHeight-5
	-- 	else
	-- 		recordPoint.y=0
	-- 	end
	-- 	self.tv:recoverToRecordPoint(recordPoint)
	-- end
end

function vipDialogNew:setTvPos()
    local vipLevel=playerVoApi:getVipLevel()
    if vipLevel>=0 and vipLevel<=self.showVip then
      local recordPoint=self.tv:getRecordPoint()
      if self.tv:getContentSize().height>self.panelLineBg:getContentSize().height-10 then
          recordPoint.y=recordPoint.y+vipLevel*self.normalHeight
          self.tv:recoverToRecordPoint(recordPoint)
      end
    end
end

function vipDialogNew:resetTab()
    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v
         if index==0 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24,self.bgSize.height-tabBtnItem:getContentSize().height/2-266)
          tabBtnItem:setScale(0.96)
         elseif index==1 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-266)
            tabBtnItem:setScale(0.96)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end 
         index=index+1
    end
end

function vipDialogNew:tabClick(idx)
    if newGuidMgr:isNewGuiding() then --新手引导
      do
          return
      end
    end
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx         
         else
            v:setEnabled(true)
         end
    end
    
    if idx==1 then
      if self.tv2==nil then
          local function callBack2(...)
             return self:eventHandler2(...)
          end
          local hd= LuaEventHandler:createHandler(callBack2)
          self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.panelLineBg:getContentSize().width-20,self.panelLineBg:getContentSize().height-10),nil)
          self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
          self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
          self.tv2:setAnchorPoint(ccp(0.5,1))
          self.tv2:setPosition(ccp(9000,0))

          -- self.panelLineBg:addChild(self.tv2)
          self.bgLayer:addChild(self.tv2)
          self.tv2:setMaxDisToBottomOrTop(80)
          self.tv2:setVisible(false)

          if self.cellNum==0 and playerVoApi:getVipLevel() == self.vipNum-1 then
                local  showAllLb= GetTTFLabelWrap(getlocal("vip_tequanlibao_allready_des"),30,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                showAllLb:setColor(G_ColorYellow)
               showAllLb:setAnchorPoint(ccp(0.5,0.5))
                showAllLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.panelLineBg:getContentSize().height/2))
                self.panelLineBg:addChild(showAllLb)
                self.showAllLb=showAllLb
                if self.tv2:isVisible()==true then
                  self.showAllLb:setVisible(true)
                else
                  self.showAllLb:setVisible(false)
                end
          end
      end

      self.tv:setVisible(false)
      self.tv2:setVisible(true)
      -- self.tv2:setPosition(ccp(self.panelLineBg:getContentSize().width/2-self.tv2:getContentSize().width/2,5))
      self.tv2:setPosition(ccp(self.bgLayer:getContentSize().width/2-self.tv2:getContentSize().width/2,self.bgy))
      self.tv:setPosition(ccp(9000,0))
      self:refreshVisible()
    elseif idx==0 then
      self.tv:setVisible(true)
      -- self.tv:setPosition(ccp(self.panelLineBg:getContentSize().width/2-self.tv:getContentSize().width/2,5))
      -- self.tv:setPosition(ccp(self.bgLayer:getContentSize().width/2-self.tv:getContentSize().width/2,self.bgy))
      self.tv:setPosition(ccp(40,92))
      if self.tv2 then
          self.tv2:setVisible(false)
          self.tv2:setPosition(ccp(9000,0))
      end
      self:refreshVisible()
    end
end

function vipDialogNew:refreshVisible()
  if self.tv2 then
      if self.cellNum==0 and playerVoApi:getVipLevel() == self.vipNum-1 and self.tv2:isVisible()==true then
        if self.showAllLb then
          self.showAllLb:setVisible(true)
        else
           local  showAllLb= GetTTFLabelWrap(getlocal("vip_tequanlibao_allready_des"),30,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
              showAllLb:setColor(G_ColorYellow)
             showAllLb:setAnchorPoint(ccp(0.5,0.5))
              showAllLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.panelLineBg:getContentSize().height/2))
              self.panelLineBg:addChild(showAllLb)
              self.showAllLb=showAllLb
        end             
      end
      if self.tv2:isVisible()==false then
        if self.showAllLb then
          self.showAllLb:setVisible(false)
        end
      end
  end
end



--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function vipDialogNew:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
        local n = self.showVip+5
        return n
   elseif fn=="tableCellSizeForIndex" then
   		local num
      if idx+1<=self.showVip and self.expandIdx["k"..idx]~=nil then
          local num=self:getCellHeight(idx)
          tmpSize=CCSizeMake(400,num)
      else
          tmpSize=CCSizeMake(400,self.normalHeight)
      end

   	-- 	if self.heightTab[idx+1] then
   	-- 		num=self.heightTab[idx+1]
   	-- 	else
   	-- 		local function getVipLocal(str,value,prop,idxProp)
    --         if prop==nil then prop=0 end
    --         if idxProp==nil then idxProp=0 end
    --         if value then
    --             return getlocal(str,{Split(value,",")[idx+1+idxProp]+prop})
    --         end
    --         return getlocal(str)
    --    		end
   	-- 		local data = {}
   	-- 		if idx==0 then
	   --          -- data = {getVipLocal("VIPStr2"),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueuevip4DailyBuyEnergyQueue),getVipLocal("VIPStr5"),getVipLocal("VIPStr7",playerCfg.actionFleets),getVipLocal("VIPStr9",playerCfg.vip4TaskRestQueue)}
    --           data = {getVipLocal("VIPStr2"),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueuevip4DailyBuyEnergyQueue),getVipLocal("VIPStr5"),getVipLocal("VIPStr7",playerCfg.actionFleets)}
	   --     elseif idx>0 then
    --       if G_getCurChoseLanguage()=="ru" then
    --           -- data = {getVipLocal("VIPStr3",playerCfg.vip4BuildQueue,-2),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue),getVipLocal("VIPStr6",playerCfg.vip4BuildQueue),getVipLocal("VIPStr7",playerCfg.actionFleets),getVipLocal("VIPStr9",playerCfg.vip4TaskRestQueue)}
    --           data = {getVipLocal("VIPStr3",playerCfg.vip4BuildQueue,-2),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue),getVipLocal("VIPStr6",playerCfg.vip4BuildQueue),getVipLocal("VIPStr7",playerCfg.actionFleets)}
    --       else
	   --          -- data = {getVipLocal("VIPStr3",playerCfg.vip4BuildQueue,-2),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue),getVipLocal("VIPStr6",playerCfg.vip4BuildQueue),getVipLocal("VIPStr7",playerCfg.actionFleets),getVipLocal("VIPStr8",playerCfg.gem4vip,0,-1),getVipLocal("VIPStr9",playerCfg.vip4TaskRestQueue)}
    --           data = {getVipLocal("VIPStr3",playerCfg.vip4BuildQueue,-2),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue),getVipLocal("VIPStr6",playerCfg.vip4BuildQueue),getVipLocal("VIPStr7",playerCfg.actionFleets)}
		  --     end
    --    end
    --    if eliteChallengeCfg and base.ifAccessoryOpen==1 then
    --       if eliteChallengeCfg.resetNum and eliteChallengeCfg.resetNum[idx+1] then
    --           local ecResetNum=eliteChallengeCfg.resetNum[idx+1]
    --           if ecResetNum and ecResetNum>0 then
    --               table.insert(data,getlocal("VIPStr10",{ecResetNum}))
    --           end
    --       end
    --    end

    --    --vip相关的其他配置
    --    -- vipRelatedCfg={
    --    --     createAllianceGems={1,0},   --vip1以上:用金币建立军团免费
    --    --     addCreateProps={2,6},       -- vip2以上:装置车间增加可制作物品：5种中型资源开采，急速前行
    --    --     raidEliteChallenge={4,1},   --vip4以上:自动扫荡补给线
    --    --     freeSeniorLotteryNum={5,1}, --vip5以上:高级抽奖每日免费一次
    --    --     protectResources={7,2},     --vip7以上:仓库资源保护量加倍*2
    --    --     donateAddNum={9,2},         --vip9以上:每日捐献次数上限增加2次
    --    -- },
    --    local vipRelatedCfg=playerCfg.vipRelatedCfg or {}
    --    local createAllianceGems=vipRelatedCfg.createAllianceGems or {}
    --    local addCreateProps=vipRelatedCfg.addCreateProps or {}
    --    local raidEliteChallenge=vipRelatedCfg.raidEliteChallenge or {}
    --    local freeSeniorLotteryNum=vipRelatedCfg.freeSeniorLotteryNum or {}
    --    local protectResources=vipRelatedCfg.protectResources or {}
    --    local donateAddNum=vipRelatedCfg.donateAddNum or {}

    --    local vipPrivilegeSwitch=base.vipPrivilegeSwitch or {}
    --    if idx==1 then
    --      table.insert(data,getlocal("VIPStr29"))
    --    end
    --    --创建军团不花金币
    --    if vipPrivilegeSwitch.vca==1 then
    --        if createAllianceGems[1] and idx==createAllianceGems[1] then
    --           table.insert(data,getlocal("VIPStr12"))
    --        end
    --    end
    --    -- vip 增加战斗经验
    --    if vipPrivilegeSwitch.vax==1 then
    --        if playerCfg.vipForAddExp[idx+1] and playerCfg.vipForAddExp[idx+1]>0 then
    --           table.insert(data,getlocal("VIPStr13",{(playerCfg.vipForAddExp[idx+1]*100).."%%"}))
    --        end
    --    end
    --    --装置车间增加可制造物品
    --    if vipPrivilegeSwitch.vap==1 then
    --        if idx==addCreateProps[1] then
    --           table.insert(data,getlocal("VIPStr14"))
    --        end
    --    end
    --    --配件合成概率提高
    --    if vipPrivilegeSwitch.vea==1 then
    --        if playerCfg.vipForEquipStrengthenRate[idx+1] and playerCfg.vipForEquipStrengthenRate[idx+1]>0 then
    --           table.insert(data,getlocal("VIPStr15",{(playerCfg.vipForEquipStrengthenRate[idx+1]*100).."%%"}))
    --        end
    --    end
    --    --精英副本扫荡
    --    if vipPrivilegeSwitch.vec==1 then
    --        if idx==raidEliteChallenge[1] and base.ifAccessoryOpen==1 then
    --           table.insert(data,getlocal("VIPStr16"))
    --        end
    --    end
    --    --高级抽奖每日免费1次
    --    if vipPrivilegeSwitch.vfn==1 then
    --        if idx==freeSeniorLotteryNum[1] then
    --           local str = getlocal("VIPStr17")
    --           if G_getBHVersion()==2 then
    --             str = getlocal("newVIPStr17")
    --           end
    --           table.insert(data,str)
    --        end
    --    end
    --    --仓库保护资源量*2
    --    if vipPrivilegeSwitch.vps==1 then
    --        if idx==protectResources[1] then
    --           table.insert(data,getlocal("VIPStr18"))
    --        end
    --    end
    --    --每日捐献次数上限+2
    --    if vipPrivilegeSwitch.vdn==1 then
    --        if idx==donateAddNum[1] and base.isAllianceSkillSwitch==1 then
    --           local addNum=donateAddNum[2]
    --           if addNum>0 then
    --               table.insert(data,getlocal("VIPStr19",{addNum}))
    --           end
    --        end
    --    end

    --    local productTankSpeed=playerCfg.productTankSpeed[idx+1]
    --    if productTankSpeed>0 then
    --       local productTankSpeedStr = productTankSpeed*100
    --       table.insert(data,getlocal("VIPStr20",productTankSpeedStr.."%"))
    --    end

    --    local refitTankSpeed=playerCfg.refitTankSpeed[idx+1]
    --    if refitTankSpeed>0 then
    --       local refitTankSpeedStr = refitTankSpeed*100
    --       table.insert(data,getlocal("VIPStr21",refitTankSpeedStr.."%"))
    --    end

    --    local tecSpeed=playerCfg.tecSpeed[idx+1]
    --    if tecSpeed>0 then
    --       local tecSpeedStr = tecSpeed*100
    --       table.insert(data,getlocal("VIPStr22",tecSpeedStr.."%"))
    --    end

    --    local commandedSpeed=playerCfg.commandedSpeed[idx+1]
    --    if commandedSpeed>0 then
    --       local commandedSpeedStr = commandedSpeed*100
    --       table.insert(data,getlocal("VIPStr23",commandedSpeedStr.."%"))
    --    end

    --    local marchSpeed=playerCfg.marchSpeed[idx+1]
    --    if marchSpeed>0 then
    --       local marchSpeedStr = marchSpeed*100
    --       table.insert(data,getlocal("VIPStr24",marchSpeedStr.."%"))
    --    end

    --    local warehouseStorage=playerCfg.warehouseStorage[idx+1]
    --    if warehouseStorage>0 then
    --       local warehouseStorageStr = warehouseStorage*100
    --       table.insert(data,getlocal("VIPStr25",warehouseStorageStr.."%"))
    --    end

    --    if  idx==playerCfg.vipRelatedCfg.allianceDuplicateNum[1] then
    --        table.insert(data,getlocal("VIPStr28"))
    --    end

    --    if  idx==playerCfg.vipRelatedCfg.storyLoss[1] then
    --       local storyLoss= playerCfg.vipRelatedCfg.storyLoss[2]*100
    --       table.insert(data,getlocal("VIPStr26",{storyLoss.."%%"}))
    --    end
       
    --    if  idx==playerCfg.vipRelatedCfg.storyPhysical[1] then
    --       table.insert(data,getlocal("VIPStr27"))
    --    end

    --    if  idx>=9 and base.heroSwitch==1 and base.expeditionSwitch==1 then
    --       table.insert(data,getlocal("VIPStr30"))
    --    end

       
       
    --    if idx>=2 then
    --       table.insert(data,getlocal("VIPStrInclude",{idx-1}))
    --    end

    --    if idx>=1 then
    --     table.insert(data,getVipLocal("VIPStr8",playerCfg.gem4vip,0,-1))
    --    end

		  --  local vipStr = ""
	   --     -- local cellHeight = vipSprie:getContentSize().height
	   --     local vipCellLabel
	   --     for k,v in pairs(data) do
	   --          vipStr = vipStr .. "\n" .. v
	   --          -- cellHeight = cellHeight + 38
	   --     end
    --    		vipCellLabel=GetTTFLabelWrap(vipStr,25,CCSizeMake(30*18, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    --    		num=vipCellLabel:getContentSize().height
    --    		self.heightTab[idx+1]=num
   	-- 	end
    --    --if idx>0 and idx<6 then
	   -- -- if idx>0 then
    -- --         num = 5
    -- --    else
    -- --         num = 4
    -- --    end
    --    -- local tmpSize=CCSizeMake(400,60+35*num)
    --    local tmpSize=CCSizeMake(400,num+120)
       return tmpSize
   elseif fn=="tableCellAtIndex" then
        if idx+1>self.showVip then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            do return cell end
        end
        if self.expandIdx["k"..idx]~=nil then
        --    local function getVipLocal(str,value,prop,idxProp)
        --         if prop==nil then prop=0 end
        --         if idxProp==nil then idxProp=0 end
        --         if value then
        --             return getlocal(str,{Split(value,",")[idx+1+idxProp]+prop})
        --         end
        --         return getlocal(str)
        --    end

        --    local data={}
        --    if idx==0 then
        --         -- data = {getVipLocal("VIPStr2"),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue),getVipLocal("VIPStr5"),getVipLocal("VIPStr7",playerCfg.actionFleets),getVipLocal("VIPStr9",playerCfg.vip4TaskRestQueue)}
        --         data = {getVipLocal("VIPStr2"),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue),getVipLocal("VIPStr5"),getVipLocal("VIPStr7",playerCfg.actionFleets)}
        --    elseif idx>0 then
    	   -- --elseif idx>0 and idx<6 then
        --       if G_getCurChoseLanguage()=="ru" then
        --           -- data = {getVipLocal("VIPStr3",playerCfg.vip4BuildQueue,-2),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue),getVipLocal("VIPStr6",playerCfg.vip4BuildQueue),getVipLocal("VIPStr7",playerCfg.actionFleets),getVipLocal("VIPStr9",playerCfg.vip4TaskRestQueue)}
        --           data = {getVipLocal("VIPStr3",playerCfg.vip4BuildQueue,-2),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue),getVipLocal("VIPStr6",playerCfg.vip4BuildQueue),getVipLocal("VIPStr7",playerCfg.actionFleets)}
        --       else
        --           -- data = {getVipLocal("VIPStr3",playerCfg.vip4BuildQueue,-2),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue),getVipLocal("VIPStr6",playerCfg.vip4BuildQueue),getVipLocal("VIPStr7",playerCfg.actionFleets),getVipLocal("VIPStr8",playerCfg.gem4vip,0,-1),getVipLocal("VIPStr9",playerCfg.vip4TaskRestQueue)}
        --           data = {getVipLocal("VIPStr3",playerCfg.vip4BuildQueue,-2),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue),getVipLocal("VIPStr6",playerCfg.vip4BuildQueue),getVipLocal("VIPStr7",playerCfg.actionFleets),}
        --       end       --else
        --    --     data = {getVipLocal("VIPStr3",playerCfg.vip4BuildQueue,-2),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue),getVipLocal("VIPStr6",playerCfg.vip4BuildQueue),getVipLocal("VIPStr7",playerCfg.actionFleets),getVipLocal("VIPStr9",playerCfg.vip4TaskRestQueue)}
    	   -- end
        --    if eliteChallengeCfg and base.ifAccessoryOpen==1 then
        --       if eliteChallengeCfg.resetNum and eliteChallengeCfg.resetNum[idx+1] then
        --           local ecResetNum=eliteChallengeCfg.resetNum[idx+1]
        --           if ecResetNum and ecResetNum>0 then
        --               table.insert(data,getlocal("VIPStr10",{ecResetNum}))
        --           end
        --       end
        --    end

        --    if arenaCfg and base.ifMilitaryOpen==1 then
        --       local key = "vip"..idx
        --       local num =arenaCfg.buyChallengingTimes[key]
        --       table.insert(data,getlocal("VIPStr11",{num}))
        --    end

        --    --vip相关的其他配置
        --    -- vipRelatedCfg={
        --    --     createAllianceGems={1,0},   --vip1以上:用金币建立军团免费
        --    --     addCreateProps={2,6},       -- vip2以上:装置车间增加可制作物品：5种中型资源开采，急速前行
        --    --     raidEliteChallenge={4,1},   --vip4以上:自动扫荡补给线
        --    --     freeSeniorLotteryNum={5,1}, --vip5以上:高级抽奖每日免费一次
        --    --     protectResources={7,2},     --vip7以上:仓库资源保护量加倍*2
        --    --     donateAddNum={9,2},         --vip9以上:每日捐献次数上限增加2次
        --    -- },
        --    local vipRelatedCfg=playerCfg.vipRelatedCfg or {}
        --    local createAllianceGems=vipRelatedCfg.createAllianceGems or {}
        --    local addCreateProps=vipRelatedCfg.addCreateProps or {}
        --    local raidEliteChallenge=vipRelatedCfg.raidEliteChallenge or {}
        --    local freeSeniorLotteryNum=vipRelatedCfg.freeSeniorLotteryNum or {}
        --    local protectResources=vipRelatedCfg.protectResources or {}
        --    local donateAddNum=vipRelatedCfg.donateAddNum or {}

        --    local vipPrivilegeSwitch=base.vipPrivilegeSwitch or {}
        --    if idx==1 then
        --      table.insert(data,getlocal("VIPStr29"))
        --    end
           
        --    --创建军团不花金币
        --    if vipPrivilegeSwitch.vca==1 then
        --        if createAllianceGems[1] and idx==createAllianceGems[1] then
        --           table.insert(data,getlocal("VIPStr12"))
        --        end
        --    end
        --    -- vip 增加战斗经验
        --    if vipPrivilegeSwitch.vax==1 then
        --        if playerCfg.vipForAddExp[idx+1] and playerCfg.vipForAddExp[idx+1]>0 then
        --           table.insert(data,getlocal("VIPStr13",{(playerCfg.vipForAddExp[idx+1]*100).."%%"}))
        --        end
        --    end
        --    --装置车间增加可制造物品
        --    if vipPrivilegeSwitch.vap==1 then
        --        if idx==addCreateProps[1] then
        --           table.insert(data,getlocal("VIPStr14"))
        --        end
        --    end
        --    --配件合成概率提高
        --    if vipPrivilegeSwitch.vea==1 then
        --        if playerCfg.vipForEquipStrengthenRate[idx+1] and playerCfg.vipForEquipStrengthenRate[idx+1]>0 then
        --           table.insert(data,getlocal("VIPStr15",{(playerCfg.vipForEquipStrengthenRate[idx+1]*100).."%%"}))
        --        end
        --    end
        --    --精英副本扫荡
        --    if vipPrivilegeSwitch.vec==1 then
        --        if idx==raidEliteChallenge[1] and base.ifAccessoryOpen==1 then
        --           table.insert(data,getlocal("VIPStr16"))
        --        end
        --    end
        --    --高级抽奖每日免费1次
        --    if vipPrivilegeSwitch.vfn==1 then
        --        if idx==freeSeniorLotteryNum[1] then
        --           local str = getlocal("VIPStr17")
        --           if G_getBHVersion()==2 then
        --             str = getlocal("newVIPStr17")
        --           end
        --           table.insert(data,str)
        --        end
        --    end
        --    --仓库保护资源量
        --    if vipPrivilegeSwitch.vps==1 then
        --        if idx==protectResources[1] then
        --           table.insert(data,getlocal("VIPStr18"))
        --        end
        --    end
        --    --每日捐献次数上限
        --    if vipPrivilegeSwitch.vdn==1 then
        --        if idx==donateAddNum[1] and base.isAllianceSkillSwitch==1 then
        --           local addNum=donateAddNum[2]
        --           if addNum>0 then
        --               table.insert(data,getlocal("VIPStr19",{addNum}))
        --           end
        --        end
        --    end
        --    local productTankSpeed=playerCfg.productTankSpeed[idx+1]
        --    if productTankSpeed>0 then
        --       local productTankSpeedStr = productTankSpeed*100
        --       table.insert(data,getlocal("VIPStr20",{productTankSpeedStr.."%%"}))
        --    end

        --    local refitTankSpeed=playerCfg.refitTankSpeed[idx+1]
        --    if refitTankSpeed>0 then
        --       local refitTankSpeedStr = refitTankSpeed*100
        --       table.insert(data,getlocal("VIPStr21",{refitTankSpeedStr.."%%"}))
        --    end

        --    local tecSpeed=playerCfg.tecSpeed[idx+1]
        --    if tecSpeed>0 then
        --       local tecSpeedStr = tecSpeed*100
        --       table.insert(data,getlocal("VIPStr22",{tecSpeedStr.."%%"}))
        --    end

        --    local commandedSpeed=playerCfg.commandedSpeed[idx+1]
        --    if commandedSpeed>0 then
        --       local commandedSpeedStr = commandedSpeed*100
        --       table.insert(data,getlocal("VIPStr23",{commandedSpeedStr.."%%"}))
        --    end

        --    local marchSpeed=playerCfg.marchSpeed[idx+1]
        --    if marchSpeed>0 then
        --       local marchSpeedStr = marchSpeed*100
        --       table.insert(data,getlocal("VIPStr24",{marchSpeedStr.."%%"}))
        --    end

        --    local warehouseStorage=playerCfg.warehouseStorage[idx+1]
        --    if warehouseStorage>0 then
        --       local warehouseStorageStr = warehouseStorage*100
        --       table.insert(data,getlocal("VIPStr25",{warehouseStorageStr.."%%"}))
        --    end

        --    if  idx==playerCfg.vipRelatedCfg.allianceDuplicateNum[1] then
        --        table.insert(data,getlocal("VIPStr28"))
        --    end

        --    if  idx==playerCfg.vipRelatedCfg.storyLoss[1] then
        --       local storyLoss= playerCfg.vipRelatedCfg.storyLoss[2]*100
        --       table.insert(data,getlocal("VIPStr26",{storyLoss.."%%"}))
        --    end
           
        --    if  idx==playerCfg.vipRelatedCfg.storyPhysical[1] then
        --       table.insert(data,getlocal("VIPStr27"))
        --    end

        --    if  idx>=9 and base.heroSwitch==1 and base.expeditionSwitch==1 then
        --       table.insert(data,getlocal("VIPStr30"))
        --    end
           
        --    if idx>=2 then
        --       table.insert(data,getlocal("VIPStrInclude",{idx-1}))
        --    end

        --    if idx>=1 then
        --     table.insert(data,getVipLocal("VIPStr8",playerCfg.gem4vip,0,-1))
        --    end

           local cellHeight,data=self:getCellHeight(idx)

           local cell=CCTableViewCell:new()
           cell:autorelease()
           cell:setAnchorPoint(ccp(0,0))
           cell:setContentSize(CCSizeMake(400,cellHeight))
           local rect = CCRect(0, 0, 50, 50)
           local capInSet = CCRect(20, 20, 10, 10)
           local function cellClick(hd,fn,idx)
              self:cellClick(idx)
           end
           local vipSprie=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
           vipSprie:setContentSize(CCSizeMake(self.panelLineBg:getContentSize().width-20, 50))
           vipSprie:ignoreAnchorPointForPosition(false)
           vipSprie:setAnchorPoint(ccp(0.5,1))
           vipSprie:setIsSallow(false)
           vipSprie:setTouchPriority(-(self.layerNum-1)*20-2)
           cell:addChild(vipSprie,1)
           vipSprie:setPosition(ccp(self.panelLineBg:getContentSize().width/2-10,cellHeight))
           vipSprie:setTag(1000+idx)

           local vipLevel=GetTTFLabel(getlocal("VIPStr1",{Split(playerCfg.vipLevel,",")[idx+1]}),30)
           vipLevel:setAnchorPoint(ccp(0,0.5))
           -- cell:addChild(vipLevel,1)
           vipSprie:addChild(vipLevel,1)
           vipLevel:setPosition(ccp(20,vipSprie:getContentSize().height/2))

           local scale=0.8
           local lessbtn=CCSprite:createWithSpriteFrameName("lessBtn.png")
           lessbtn:setScale(scale)
           lessbtn:setPosition(ccp(vipSprie:getContentSize().width-lessbtn:getContentSize().width/2*scale-10,vipSprie:getContentSize().height/2))
           vipSprie:addChild(lessbtn,1)
           
           local str = ""
           -- local cellHeight = vipSprie:getContentSize().height
           local vipLabel
           for k,v in pairs(data) do
                str = str .. "\n" .. v
                -- cellHeight = cellHeight + 38
           end

           --cell:setContentSize(CCSizeMake(self.panelLineBg:getContentSize().width-50, cellHeight))
           -- vipLabel=GetTTFLabelWrap(str,25,CCSizeMake(30*18, 30*8),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
           --print(str)
           vipLabel=GetTTFLabelWrap(str,25,CCSizeMake(30*18, 1000),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
           vipLabel:setAnchorPoint(ccp(0,1))
           vipLabel:setColor(G_ColorYellow)
           cell:addChild(vipLabel,1)
           vipLabel:setPosition(ccp(20,cellHeight-25))
           vipLabel:setVisible(true)

           self.lbTab[idx+1]=vipLabel

           -- local vipLabel2=GetTTFLabelWrap(str,25,CCSizeMake(30*18, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

           -- local cellHeight=vipLabel2:getContentSize().height+60
           -- vipSprie:setPosition(ccp(self.panelLineBg:getContentSize().width/2-10,cellHeight))
           
           -- vipLevel:setPosition(ccp(20,cellHeight-10))
           -- vipLabel:setPosition(ccp(20,cellHeight-25))
           
           return cell
        else
           local cell=CCTableViewCell:new()
           cell:autorelease()
           cell:setContentSize(CCSizeMake(400,self.normalHeight))

           local rect = CCRect(0, 0, 50, 50)
           local capInSet = CCRect(20, 20, 10, 10)
           local function cellClick(hd,fn,idx)
              self:cellClick(idx)
           end
           local vipSprie=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
           vipSprie:setContentSize(CCSizeMake(self.panelLineBg:getContentSize().width-20, 50))
           vipSprie:ignoreAnchorPointForPosition(false)
           vipSprie:setAnchorPoint(ccp(0.5,1))
           vipSprie:setIsSallow(false)
           vipSprie:setTouchPriority(-(self.layerNum-1)*20-2)
           cell:addChild(vipSprie,1)
           vipSprie:setPosition(ccp(self.panelLineBg:getContentSize().width/2-10,self.normalHeight))
           vipSprie:setTag(1000+idx)

           local vipLevel=GetTTFLabel(getlocal("VIPStr1",{Split(playerCfg.vipLevel,",")[idx+1]}),30)
           vipLevel:setAnchorPoint(ccp(0,0.5))
           vipSprie:addChild(vipLevel,1)
           vipLevel:setPosition(ccp(20,vipSprie:getContentSize().height/2))

           local scale=0.8
           local morebtn=CCSprite:createWithSpriteFrameName("moreBtn.png")
           morebtn:setScale(scale)
           morebtn:setPosition(ccp(vipSprie:getContentSize().width-morebtn:getContentSize().width/2*scale-10,vipSprie:getContentSize().height/2))
           vipSprie:addChild(morebtn,1)

           return cell
        end
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

function vipDialogNew:eventHandler2(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local vipLevel=playerVoApi:getVipLevel()
        local vf = vipVoApi:getVf()
        local subNum = SizeOfTable(vf)
        self.cellNum = 0
        if vipLevel+1>(self.vipNum-1) then
          self.cellNum = vipLevel*2+2-subNum
        elseif vipLevel+2>(self.vipNum-1) then
           self.cellNum = (vipLevel+1)*2+2-subNum
        else
           self.cellNum = (vipLevel+2)*2+2-subNum
        end
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        self.tv2CellHeight = 250
        self.tv2CellBsHeight =0.6
        self.tv2CellBtnUpStrHeight =50
        self.tv2cellBtnHeight =0
        if G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
          self.tv2CellHeight =270
        elseif G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="fr" or G_getCurChoseLanguage() =="tu" then
          self.tv2CellHeight =380
          self.tv2CellBsHeight =0.7
          self.tv2CellBtnUpStrHeight =80
          self.tv2cellBtnHeight =50
        end
        local tempSize = CCSizeMake(400,self.tv2CellHeight)
        return tempSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease() 
        local function touch(hd,fn,idx)
        end
        local vipBgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("VipLineYellow.png",CCRect(20, 20, 10, 10),touch)
        local strHeight = self.tv2CellHeight-10
        vipBgSprie:setContentSize(CCSizeMake(560,strHeight))
        vipBgSprie:ignoreAnchorPointForPosition(false)
        vipBgSprie:setAnchorPoint(ccp(0.5,0))
        vipBgSprie:setTouchPriority(-(self.layerNum-1)*20-1)
        vipBgSprie:setPosition(ccp(G_VisibleSize.width/2-40,0))
        cell:addChild(vipBgSprie,1)

        local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
        lightSp:setAnchorPoint(ccp(0.5,0.5))
        lightSp:setPosition(ccp(vipBgSprie:getContentSize().width*0.15,vipBgSprie:getContentSize().height*0.5))
        vipBgSprie:addChild(lightSp,1)

        local bigGiftBg =CCSprite:createWithSpriteFrameName("Icon_BG.png")
        bigGiftBg:setAnchorPoint(ccp(0.5,0.5))
        bigGiftBg:setPosition(ccp(vipBgSprie:getContentSize().width*0.15,vipBgSprie:getContentSize().height*0.5))
        bigGiftBg:setScale(1.5)
        vipBgSprie:addChild(bigGiftBg,1)

        local frames=CCArray:create()
        for i=1 ,20 do
          local nameStr = "RotatingEffect"..i..".png"
          local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
          frames:addObject(frame)
        end
        local pBAnimation = CCAnimation:createWithSpriteFrames(frames,0.05)
        local pBAnimate = CCAnimate:create(pBAnimation)
        self.pBSprite = CCSprite:createWithSpriteFrameName("RotatingEffect1.png")
        self.pBSprite:runAction(CCRepeatForever:create(pBAnimate))
        self.pBSprite:setScale(1.1)
        self.pBSprite:setPosition(ccp(bigGiftBg:getContentSize().width*0.5,bigGiftBg:getContentSize().height*0.5))
        bigGiftBg:addChild(self.pBSprite,1)

        local function showClick( ... )
          if self.tv2:getIsScrolled()==true then
            do return end
          end
          PlayEffect(audioCfg.mouseClick)
          local RewardList = vipVoApi:getVipContent(idx+1)
          local reward=FormatItem(RewardList) or {}
          local content={}        
          for k,v in pairs(reward) do
           table.insert(content,{award=v,})
          end
          smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_tankjianianhua_awardContent"),content,true,true,self.layerNum+1,nil,false,false,nil,nil,nil,nil,nil,nil,nil,nil,true)
        end
        local addIcon = LuaCCSprite:createWithSpriteFrameName("mainBtnGift.png",showClick)  
        addIcon:setScale(1.4) 
        addIcon:setAnchorPoint(ccp(0.5,0.5))
        addIcon:setPosition(ccp(bigGiftBg:getPositionX(),vipBgSprie:getContentSize().height*0.5))
        addIcon:setTouchPriority(-(self.layerNum-1)*20-2)
        vipBgSprie:addChild(addIcon,1)

        local RewardList = vipVoApi:getVipReward(idx+1)
        local reward=FormatItem(RewardList) or {}

        local str =  reward[1].name 
        local titleLb = GetTTFLabelWrap(str,25,CCSizeMake(360,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        titleLb:setAnchorPoint(ccp(0,0.5))
        titleLb:setPosition(ccp(170,vipBgSprie:getContentSize().height*0.88))
        titleLb:setColor(G_ColorYellow)
        vipBgSprie:addChild(titleLb)

        local capInSet = CCRect(20, 20, 10, 10)
        local function cellClick(hd,fn,idx)
        end
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
        backSprie:setContentSize(CCSizeMake(240, vipBgSprie:getContentSize().height*self.tv2CellBsHeight))
        backSprie:ignoreAnchorPointForPosition(false);
        backSprie:setAnchorPoint(ccp(0,0));
        backSprie:setIsSallow(true)
        backSprie:setPosition(ccp(170,50))
        backSprie:setTouchPriority(-(self.layerNum-1)*20-5)
        vipBgSprie:addChild(backSprie,1)
        --cell:addChild(backSprie,1)

        local function onConfirmSell()
          if self.tv2:getIsScrolled()==true then
            do return end
          end
          PlayEffect(audioCfg.mouseClick)
          if vipVoApi:getVip(idx+1)> playerVoApi:getVipLevel() then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("vip_tequanlibao_tip1"),30)
            return
          end

          if playerVoApi:getGems()<vipVoApi:getPrice(idx+1) then
            GemsNotEnoughDialog(nil,nil,vipVoApi:getPrice(idx+1)-playerVoApi:getGems(),self.layerNum+1,vipVoApi:getPrice(idx+1))
            return
          else
            local function goumaiOrLingquCallback(fn,data)
              local ret,sData=base:checkServerData(data)
              if ret==true then
                -- local RewardList = vipVoApi:getVipContent(idx+1)
                -- local reward=FormatItem(RewardList) or {}     
                -- for k,v in pairs(reward) do
                --   G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                -- end
                local libaoList = vipVoApi:getVipReward(idx+1)
                local libaoReward = FormatItem(libaoList) or {} 
                for k,v in pairs(libaoReward) do
                  G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                end

                if vipVoApi:getPrice(idx+1)==0 then
                  smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),30)
                else
                   smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("vip_tequanlibao_goumai_success"),30)
                end
                 
                 playerVoApi:setValue("gems",playerVoApi:getGems()-vipVoApi:getPrice(idx+1))
                 vipVoApi:InsertVf(vipVoApi:getId(idx+1))
                 local vf = vipVoApi:getVf(vf)
                  for k,v in pairs(vf) do
                    vipVoApi:setRealReward(v)
                  end 
                  self.tv2:reloadData()
                  self:refreshVisible()
              end
            end
            socketHelper:vipgiftLingquOrGoumai(vipVoApi:getId(idx+1),goumaiOrLingquCallback)
            return
            end          
                 
        end
        local okItem
        local str=getlocal("buy")
        if vipVoApi:getPrice(idx+1)==0 then
          str=getlocal("daily_scene_get")
        end

        if vipVoApi:getVip(idx+1)<= playerVoApi:getVipLevel() then
          okItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onConfirmSell,nil,str,25)
          self.tv2cellBtnHeight =0
        else
          okItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",onConfirmSell,nil,str,25)
        end
        
        okItem:setScale(0.8)
        local okBtn=CCMenu:createWithItem(okItem)
        okBtn:setTouchPriority(-(self.layerNum-1)*20-2)
        okBtn:setAnchorPoint(ccp(1,0.5))
        okBtn:setPosition(vipBgSprie:getContentSize().width-70,vipBgSprie:getContentSize().height*0.5-self.tv2cellBtnHeight)
        vipBgSprie:addChild(okBtn)


        local desTv, desLabel = G_LabelTableView(CCSizeMake(230, backSprie:getContentSize().height*0.9),getlocal(reward[1].desc),25,kCCTextAlignmentLeft)
        backSprie:addChild(desTv,1)
        desTv:setPosition(ccp(5,10))
        desTv:setAnchorPoint(ccp(0.5,1))
        desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
        desTv:setMaxDisToBottomOrTop(100)

        if vipVoApi:getPrice(idx+1)~=0 then --30,310,50
          local realLbWidthPos =30
          local dazheLbWidthPos = 310
          local redlineXSize = 50
          if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="tw" then
              realLbWidthPos =170
              dazheLbWidthPos =360
              redlineXSize =40
          end
          local realLb = GetTTFLabel(getlocal("vip_tequanlibao_realCost",{vipVoApi:getRealPrice(idx+1)}),20)
          realLb:setAnchorPoint(ccp(0,0))
          realLb:setPosition(ccp(realLbWidthPos,15))
          vipBgSprie:addChild(realLb)

          local realCost = CCSprite:createWithSpriteFrameName("IconGold.png")
          realCost:setAnchorPoint(ccp(0,0))
          realCost:setPosition(realLb:getPositionX()+realLb:getContentSize().width+5,10)
          vipBgSprie:addChild(realCost)

          local redLine = CCSprite:createWithSpriteFrameName("redline.jpg")
          redLine:setAnchorPoint(ccp(0,0))
          redLine:setScaleX(redlineXSize)
          redLine:setPosition(ccp(realLb:getPositionX(),23))
          vipBgSprie:addChild(redLine)

          local dazheLb = GetTTFLabel(getlocal("vip_tequanlibao_dazheCost",{vipVoApi:getPrice(idx+1)}),20)
         dazheLb:setAnchorPoint(ccp(0,0))
          dazheLb:setPosition(ccp(dazheLbWidthPos,15))
          dazheLb:setColor(G_ColorYellow)
          vipBgSprie:addChild(dazheLb)

          local dazheCost = CCSprite:createWithSpriteFrameName("IconGold.png")
          dazheCost:setAnchorPoint(ccp(0,0))
          dazheCost:setPosition(dazheLb:getPositionX()+dazheLb:getContentSize().width+5,10)
          vipBgSprie:addChild(dazheCost)
        end
          

         

          
          if vipVoApi:getVip(idx+1)> playerVoApi:getVipLevel() then
            local str =getlocal("vip_tequanlibao_goumai",{vipVoApi:getVip(idx+1)})
            if vipVoApi:getPrice(idx+1)==0 then
              str = getlocal("vip_tequanlibao_lingqu",{vipVoApi:getVip(idx+1)})
            end            
            local keGoumaiLb = GetTTFLabelWrap(str,20,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            keGoumaiLb:setPosition(vipBgSprie:getContentSize().width-70,vipBgSprie:getContentSize().height*0.5+self.tv2CellBtnUpStrHeight-self.tv2cellBtnHeight)
            vipBgSprie:addChild(keGoumaiLb)
            keGoumaiLb:setColor(G_ColorYellow)
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

--用户处理特殊需求,没有可以不写此方法
function vipDialogNew:doUserHandler()
	--[[
	if self.buygems==nil then
		self.buygems=playerVoApi:getBuygems()
	end
	]]
	if self.buygems~=playerVoApi:getVipExp() then
		self.buygems=playerVoApi:getVipExp()	
	    
		self:updateVipSchedule()
	end
		
	if self.rechargeBtn==nil or self.menuRecharge==nil then
	    local function touch1(tag,object)
	                if G_checkClickEnable()==false then
	                    do
	                        return
	                    end
	                end
	        PlayEffect(audioCfg.mouseClick)
	       vipVoApi:showRechargeDialog(self.layerNum+1)
			self:close()
	    end
		self.rechargeBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge.png",touch1,nil,getlocal("moreMoney"),30)
	    self.menuRecharge=CCMenu:createWithItem(self.rechargeBtn);
	    self.menuRecharge:setPosition(ccp(self.bgLayer:getContentSize().width/2,45))
	    self.menuRecharge:setTouchPriority(-(self.layerNum-1)*20-4)
	    self.bgLayer:addChild(self.menuRecharge,2)
	end
end

function vipDialogNew:tick()
	self:doUserHandler()
end

function vipDialogNew:updateVipSchedule()
    local vipLevel=playerVoApi:getVipLevel()
    local vipLevelCfg=Split(playerCfg.vipLevel,",")
    local gem4vipCfg=Split(G_getPlatVipCfg(),",")
	if self.vipIcon then
		if self.vipLevelLabel==nil then
            local textSize = 30
            if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
                textSize=25
            end
		    self.vipLevelLabel=GetTTFLabel(getlocal("VIPStr1",{vipLevel}),textSize)
		    self.vipLevelLabel:setAnchorPoint(ccp(0.5,0.5))
			self.vipLevelLabel:setPosition(getCenterPoint(self.vipIcon))
		    self.vipIcon:addChild(self.vipLevelLabel,1)
		else
			self.vipLevelLabel:setString(getlocal("VIPStr1",{vipLevel}))
		end
	end
	local offHeight = 10
	--[[if G_country == "tw" then
		offHeight = 10
		end]]
	if self.timerSprite==nil and self.vipBgSprie then
		AddProgramTimer(self.vipBgSprie,ccp(self.vipBgSprie:getContentSize().width/2,self.vipBgSprie:getContentSize().height-55+offHeight),10,nil,nil,"VipIconYellowBarBg.png","VipIconYellowBar.png",11)
		self.timerSprite = tolua.cast(self.vipBgSprie:getChildByTag(10),"CCProgressTimer")
	end
	if self.timerSprite then
		local percentage=0
		if tostring(vipLevel) == tostring(vipLevelCfg[SizeOfTable(vipLevelCfg)]) then
			percentage=1
		else
			local curLevelGems=0
			if vipLevel>0 then
				curLevelGems=gem4vipCfg[vipLevel]
			end
			local nextLevelGems=gem4vipCfg[vipLevel+1]
      if(nextLevelGems)then
			   local needGems=nextLevelGems-curLevelGems
			   local buyGems=playerVoApi:getVipExp()-curLevelGems
			   percentage=buyGems/needGems
      else
          percentage=1
      end
		end
		if percentage<0 then
			percentage=0
		end
		if percentage>1 then
			percentage=1
		end
		self.timerSprite:setPercentage(percentage*100)
    if tonumber(vipLevel) >= tonumber(playerVoApi:getMaxLvByKey("maxVip")) then
       self.timerSprite:setPercentage(100)
    end
	end
	
    local vipStr = ""
    if tonumber(vipLevel) >= tonumber(playerVoApi:getMaxLvByKey("maxVip")) then
        vipStr = getlocal("richMan")

    else
        local nextVip=vipLevel+1
        local nextGem=gem4vipCfg[nextVip]
        local needGem=nextGem-self.buygems
        --vipStr = getlocal("currentVip",{vipLevel})
        vipStr = vipStr..getlocal("nextVip",{needGem,nextVip}).."\n"..getlocal("notInclude")
    end
	if self.vipBgSprie then
		if self.vipDescLabel==nil then
            local textSize
            if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" then
                textSize = 25
            else
                textSize = 23
            end
		    self.vipDescLabel=GetTTFLabelWrap(vipStr,textSize,CCSizeMake(self.vipBgSprie:getContentSize().width-20, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
		    self.vipDescLabel:setAnchorPoint(ccp(0.5,1))
		    self.vipDescLabel:setPosition(ccp(self.vipBgSprie:getContentSize().width/2,self.vipBgSprie:getContentSize().height-75+offHeight+5))
		    self.vipBgSprie:addChild(self.vipDescLabel,1)
		else
 		   self.vipDescLabel:setString(vipStr)
		end
	end
end

--点击了cell或cell上某个按钮
function vipDialogNew:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if self.expandIdx["k"..(idx-1000)]==nil then
            self.expandIdx["k"..(idx-1000)]=idx-1000
            self.tv:openByCellIndex(idx-1000,self.normalHeight)
        else
            self.expandIdx["k"..(idx-1000)]=nil
            local num=self:getCellHeight(idx-1000)
            self.tv:closeByCellIndex(idx-1000,num)
            if self.lbTab and self.lbTab[idx-1000+1] then
                local lb=tolua.cast(self.lbTab[idx-1000+1],"CCLabelTTF")
                if lb then
                    lb:setVisible(false)
                end
            end
        end
    end
end

function vipDialogNew:getCellHeight(idx)
    local num,strData
    if self.heightTab[idx+1] then
        num=self.heightTab[idx+1].num
        strData=self.heightTab[idx+1].data
    else
        self.heightTab[idx+1]={}
        local function getVipLocal(str,value,prop,idxProp)
              if prop==nil then prop=0 end
              if idxProp==nil then idxProp=0 end
              if value then
                  return getlocal(str,{Split(value,",")[idx+1+idxProp]+prop})
              end
              return getlocal(str)
        end

        local data={}
        if idx==0 then
            -- data = {getVipLocal("VIPStr2"),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue),getVipLocal("VIPStr5"),getVipLocal("VIPStr7",playerCfg.actionFleets),getVipLocal("VIPStr9",playerCfg.vip4TaskRestQueue)}
            data = {getVipLocal("VIPStr2"),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue),getVipLocal("VIPStr5"),getVipLocal("VIPStr7",playerCfg.actionFleets)}
        elseif idx>0 then
        -- elseif idx>0 and idx<6 then
            if G_getCurChoseLanguage()=="ru" then
                -- data = {getVipLocal("VIPStr3",playerCfg.vip4BuildQueue,-2),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue),getVipLocal("VIPStr6",playerCfg.vip4BuildQueue),getVipLocal("VIPStr7",playerCfg.actionFleets),getVipLocal("VIPStr9",playerCfg.vip4TaskRestQueue)}
                data = {getVipLocal("VIPStr3",playerCfg.vip4BuildQueue,-2),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue),getVipLocal("VIPStr6",playerCfg.vip4BuildQueue),getVipLocal("VIPStr7",playerCfg.actionFleets)}
            else
                -- data = {getVipLocal("VIPStr3",playerCfg.vip4BuildQueue,-2),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue),getVipLocal("VIPStr6",playerCfg.vip4BuildQueue),getVipLocal("VIPStr7",playerCfg.actionFleets),getVipLocal("VIPStr8",playerCfg.gem4vip,0,-1),getVipLocal("VIPStr9",playerCfg.vip4TaskRestQueue)}
                data = {getVipLocal("VIPStr3",playerCfg.vip4BuildQueue,-2),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue),getVipLocal("VIPStr6",playerCfg.vip4BuildQueue),getVipLocal("VIPStr7",playerCfg.actionFleets),}
            end       --else
                -- data = {getVipLocal("VIPStr3",playerCfg.vip4BuildQueue,-2),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue),getVipLocal("VIPStr6",playerCfg.vip4BuildQueue),getVipLocal("VIPStr7",playerCfg.actionFleets),getVipLocal("VIPStr9",playerCfg.vip4TaskRestQueue)}
         end
         if eliteChallengeCfg and base.ifAccessoryOpen==1 then
            if eliteChallengeCfg.resetNum and eliteChallengeCfg.resetNum[idx+1] then
                local ecResetNum=eliteChallengeCfg.resetNum[idx+1]
                if ecResetNum and ecResetNum>0 then
                    table.insert(data,getlocal("VIPStr10",{ecResetNum}))
                end
            end
         end

         if arenaCfg and base.ifMilitaryOpen==1 then
            local key = "vip"..idx
            local num
            if base.ma==1 then
                num =arenaCfg.buyChallengingTimes2[key]
            else
                num =arenaCfg.buyChallengingTimes[key]
            end
            table.insert(data,getlocal("VIPStr11",{num}))
         end

         --vip相关的其他配置
         -- vipRelatedCfg={
         --     createAllianceGems={1,0},   --vip1以上:用金币建立军团免费
         --     addCreateProps={2,6},       -- vip2以上:装置车间增加可制作物品：5种中型资源开采，急速前行
         --     raidEliteChallenge={4,1},   --vip4以上:自动扫荡补给线
         --     freeSeniorLotteryNum={5,1}, --vip5以上:高级抽奖每日免费一次
         --     protectResources={7,2},     --vip7以上:仓库资源保护量加倍*2
         --     donateAddNum={9,2},         --vip9以上:每日捐献次数上限增加2次
         -- },
         local vipRelatedCfg=playerCfg.vipRelatedCfg or {}
         local createAllianceGems=vipRelatedCfg.createAllianceGems or {}
         local addCreateProps=vipRelatedCfg.addCreateProps or {}
         local raidEliteChallenge=vipRelatedCfg.raidEliteChallenge or {}
         local freeSeniorLotteryNum=vipRelatedCfg.freeSeniorLotteryNum or {}
         local protectResources=vipRelatedCfg.protectResources or {}
         local donateAddNum=vipRelatedCfg.donateAddNum or {}
         local dailySign=vipRelatedCfg.dailySign or {}

         local vipPrivilegeSwitch=base.vipPrivilegeSwitch or {}
         if idx==1 then
           table.insert(data,getlocal("VIPStr29"))
         end
         
         --创建军团不花金币
         if vipPrivilegeSwitch.vca==1 then
             if createAllianceGems[1] and idx==createAllianceGems[1] then
                table.insert(data,getlocal("VIPStr12"))
             end
         end
         -- vip 增加战斗经验
         if vipPrivilegeSwitch.vax==1 then
             if playerCfg.vipForAddExp[idx+1] and playerCfg.vipForAddExp[idx+1]>0 then
                table.insert(data,getlocal("VIPStr13",{(playerCfg.vipForAddExp[idx+1]*100).."%%"}))
             end
         end
         --装置车间增加可制造物品
         if vipPrivilegeSwitch.vap==1 then
             if idx==addCreateProps[1] then
                table.insert(data,getlocal("VIPStr14"))
             end
         end
         --配件合成概率提高
         if vipPrivilegeSwitch.vea==1 then
             if playerCfg.vipForEquipStrengthenRate[idx+1] and playerCfg.vipForEquipStrengthenRate[idx+1]>0 then
                table.insert(data,getlocal("VIPStr15",{(playerCfg.vipForEquipStrengthenRate[idx+1]*100).."%%"}))
             end
         end
         --精英副本扫荡
         if vipPrivilegeSwitch.vec==1 then
             if idx==raidEliteChallenge[1] and base.ifAccessoryOpen==1 then
                table.insert(data,getlocal("VIPStr16"))
             end
         end
         --高级抽奖每日免费1次
         if vipPrivilegeSwitch.vfn==1 then
             if idx==freeSeniorLotteryNum[1] then
                local str = getlocal("VIPStr17")
                if G_getBHVersion()==2 then
                  str = getlocal("newVIPStr17")
                end
                table.insert(data,str)
             end
         end
         --仓库保护资源量
         if vipPrivilegeSwitch.vps==1 then
             if idx==protectResources[1] then
                table.insert(data,getlocal("VIPStr18"))
             end
         end
         --每日捐献次数上限
         if vipPrivilegeSwitch.vdn==1 then
             if idx==donateAddNum[1] and base.isAllianceSkillSwitch==1 then
                local addNum=donateAddNum[2]
                if addNum>0 then
                    table.insert(data,getlocal("VIPStr19",{addNum}))
                end
             end
         end
         --每日签到双倍奖励
         if(vipPrivilegeSwitch.vsr==1)then
              if base.isSignSwitch==1 and idx==dailySign[1] then
                  local addNum=dailySign[2]
                  if(addNum>1)then
                      table.insert(data,getlocal("VIPStr34",{addNum}))
                  end
              end
         end
         local productTankSpeed=playerCfg.productTankSpeed[idx+1]
         if productTankSpeed>0 then
            local productTankSpeedStr = productTankSpeed*100
            table.insert(data,getlocal("VIPStr20",{productTankSpeedStr.."%%"}))
         end

         local refitTankSpeed=playerCfg.refitTankSpeed[idx+1]
         if refitTankSpeed>0 then
            local refitTankSpeedStr = refitTankSpeed*100
            table.insert(data,getlocal("VIPStr21",{refitTankSpeedStr.."%%"}))
         end

         local tecSpeed=playerCfg.tecSpeed[idx+1]
         if tecSpeed>0 then
            local tecSpeedStr = tecSpeed*100
            table.insert(data,getlocal("VIPStr22",{tecSpeedStr.."%%"}))
         end

         local commandedSpeed=playerCfg.commandedSpeed[idx+1]
         if commandedSpeed>0 then
            local commandedSpeedStr = commandedSpeed*100
            table.insert(data,getlocal("VIPStr23",{commandedSpeedStr.."%%"}))
         end

         local marchSpeed=playerCfg.marchSpeed[idx+1]
         if marchSpeed>0 then
            local marchSpeedStr = marchSpeed*100
            table.insert(data,getlocal("VIPStr24",{marchSpeedStr.."%%"}))
         end

         local warehouseStorage=playerCfg.warehouseStorage[idx+1]
         if warehouseStorage>0 then
            local warehouseStorageStr = warehouseStorage*100
            table.insert(data,getlocal("VIPStr25",{warehouseStorageStr.."%%"}))
         end

         if  idx==playerCfg.vipRelatedCfg.allianceDuplicateNum[1] then
             table.insert(data,getlocal("VIPStr28"))
         end

         if  idx==playerCfg.vipRelatedCfg.storyLoss[1] then
            local storyLoss= playerCfg.vipRelatedCfg.storyLoss[2]*100
            table.insert(data,getlocal("VIPStr26",{storyLoss.."%%"}))
         end
         
         if  idx==playerCfg.vipRelatedCfg.storyPhysical[1] then
            table.insert(data,getlocal("VIPStr27"))
         end

         if  idx>=9 and base.heroSwitch==1 and base.expeditionSwitch==1 then
            table.insert(data,getlocal("VIPStr30"))
         end

         if base.ifSuperWeaponOpen==1 then
            local resetTab=swChallengeCfg.resetNum
            local maxResetNum=resetTab[idx+1]
            table.insert(data,getlocal("VIPStr31",{maxResetNum}))
            local buyTab=swChallengeCfg.challengeBuyNum
            local maxBuyNum=buyTab[idx+1]
            table.insert(data,getlocal("VIPStr32",{maxBuyNum}))
            local energyBuyNumTab=weaponrobCfg.energyGemsBuyNum
            local energyBuyNum=energyBuyNumTab[idx+1]
            table.insert(data,getlocal("VIPStr33",{energyBuyNum}))
         end
         if idx>=playerCfg.vipRelatedCfg.hchallengeSweepNeedVip and base.he==1 then
            table.insert(data,getlocal("VIPStr35"))
         end
         if base.he==1 then
            local resetNum=hChallengeCfg.resetNum[idx+1]
            table.insert(data,getlocal("VIPStr36",{resetNum}))
         end
         if idx>=2 then
            table.insert(data,getlocal("VIPStrInclude",{idx-1}))
         end

         if idx>=1 then
          table.insert(data,getVipLocal("VIPStr8",playerCfg.gem4vip,0,-1))
         end

         if base.fs==1 then
          local freeTime = playerVoApi:getFreeTime(idx)
          if freeTime>0 then
            local str = self:getFreeTimeStr(freeTime)
            table.insert(data,1,str)
          end
         end

         local vipStr = ""
           -- local cellHeight = vipSprie:getContentSize().height
         local vipCellLabel
         for k,v in pairs(data) do
              vipStr = vipStr .. "\n" .. v
              -- cellHeight = cellHeight + 38
         end
        vipCellLabel=GetTTFLabelWrap(vipStr,25,CCSizeMake(30*18, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        num=vipCellLabel:getContentSize().height+90
        self.heightTab[idx+1].num=num
        self.heightTab[idx+1].data=data
        strData=data
    end
    return num,strData
end

function vipDialogNew:getFreeTimeStr(freeTime)
  local freeStr=""
  if freeTime<60 then
    freeStr=getlocal("VIPStr39",{freeTime})
  elseif freeTime%60==0 then
    freeStr=getlocal("VIPStr37",{freeTime/60})
  else
    local fen = math.floor(freeTime/60)
    local miao = freeTime%60
    freeStr=getlocal("VIPStr38",{fen,miao})
  end
  return freeStr
end

function vipDialogNew:dispose()
    self.vipDescLabel=nil
    self.rechargeBtn=nil
    self.menuRecharge=nil
	self.buygems=nil
	self.timerSprite=nil
	self.vipBgSprie=nil
	self.vipLevelLabel=nil
	self.vipIcon=nil
  self.expandIdx={}
  self.normalHeight=60
  self.lbTab={}
	self.heightTab={}
    self=nil
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage.plist")
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage2.plist")
end



