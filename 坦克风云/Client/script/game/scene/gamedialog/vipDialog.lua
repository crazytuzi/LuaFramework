--require "luascript/script/componet/commonDialog"
vipDialog=commonDialog:new()

function vipDialog:new()
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

	self.heightTab={}
    self.vipNum=playerVoApi:getMaxLvByKey("maxVip")+1
    self.showVip=self.vipNum
    return nc
end


--设置对话框里的tableView
function vipDialog:initTableView()


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
	self.panelLineBg:setContentSize(CCSizeMake(580,G_VisibleSize.height-355))
	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-92))
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
    local hd= LuaEventHandler:createHandler(callBack)
self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.panelLineBg:getContentSize().width-20,self.panelLineBg:getContentSize().height-10),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    --self.tv:setPosition(ccp(30,20))
    -- self.tv:setAnchorPoint(ccp(0.5,1))
    -- self.tv:setPosition(ccp(self.panelLineBg:getContentSize().width/2-self.tv:getContentSize().width/2,5))
    self.tv:setPosition(ccp(40,92))

    -- self.panelLineBg:addChild(self.tv)
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)

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
end

function vipDialog:setTvPos()
    local vipLevel=playerVoApi:getVipLevel()
    if vipLevel>=0 and vipLevel<=self.showVip then
      local recordPoint=self.tv:getRecordPoint()
      if self.tv:getContentSize().height>self.panelLineBg:getContentSize().height-10 then
          recordPoint.y=recordPoint.y+vipLevel*self.normalHeight
          self.tv:recoverToRecordPoint(recordPoint)
      end
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function vipDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
        local n = self.showVip+5
        return n
   elseif fn=="tableCellSizeForIndex" then
   		-- local num=self:getCellHeight(idx)
       --if idx>0 and idx<6 then
	   -- if idx>0 then
    --         num = 5
    --    else
    --         num = 4
    --    end
       -- local tmpSize=CCSizeMake(400,60+35*num)
       -- local tmpSize=CCSizeMake(400,num)
       if idx+1<=self.showVip and self.expandIdx["k"..idx]~=nil then
          local num=self:getCellHeight(idx)
          tmpSize=CCSizeMake(400,num)
       else
          tmpSize=CCSizeMake(400,self.normalHeight)
       end
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
           cell:setContentSize(CCSizeMake(400,cellHeight))
           -- cell:setAnchorPoint(ccp(0,0))
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

           -- cell:setContentSize(CCSizeMake(400,cellHeight))
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

--用户处理特殊需求,没有可以不写此方法
function vipDialog:doUserHandler()
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

function vipDialog:tick()
	self:doUserHandler()
end

function vipDialog:updateVipSchedule()
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
function vipDialog:cellClick(idx)
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

function vipDialog:getCellHeight(idx)
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

function vipDialog:getFreeTimeStr(freeTime)
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

function vipDialog:dispose()
  self.lbTab={}
  self.expandIdx={}
    self.vipDescLabel=nil
    self.rechargeBtn=nil
    self.menuRecharge=nil
	self.buygems=nil
	self.timerSprite=nil
	self.vipBgSprie=nil
	self.vipLevelLabel=nil
	self.vipIcon=nil
	self.heightTab={}
  self.normalHeight=60
    self=nil
end



