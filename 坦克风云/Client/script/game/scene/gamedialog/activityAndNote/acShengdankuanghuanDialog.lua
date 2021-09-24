acShengdankuanghuanDialog=commonDialog:new()

function acShengdankuanghuanDialog:new( )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self

	self.eggTab=nil
	self.eggLayer=nil
	self.treeTab=nil
	self.treeLayer=nil
	self.getTimes=0


	return nc
end

function acShengdankuanghuanDialog:resetTab( )
	local index = 0
	for k,v in pairs(self.allTabs) do
		local tabBtnItem = v
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
	self.selectedTabIndex=0

    if G_curPlatName()~="3" and G_curPlatName()~="efunandroidtw" and G_curPlatName()~="efunandroid360" and G_curPlatName()~="efunandroidmemoriki" and G_curPlatName()~="androidlongzhong" and G_curPlatName()~="androidlongzhong2"  and G_curPlatName()~="androidom2"  then
    	local ver = acShengdankuanghuanVoApi:getVersion()
    	if ver ~=3 then
	        local particleS2 = CCParticleSystemQuad:create("public/snow2.plist")
	        particleS2.positionType=kCCPositionTypeFree
	        particleS2:setPosition(ccp(320,G_VisibleSizeHeight+20))
	        self.bgLayer:addChild(particleS2,10)
	    end
    end
end

function acShengdankuanghuanDialog:initTableView( )
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
	--数据交互

	self:tabClick(0,false)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acShengdankuanghuanDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 1

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

function acShengdankuanghuanDialog:tabClick( idx )
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
		if self.treeLayer==nil then
			self.treeTab=acShengdankuanghuanTab2:new()
			self.treeLayer=self.treeTab:init(self.layerNum)
			self.bgLayer:addChild(self.treeLayer)
		else
			self.treeLayer:setVisible(true)
		end
		if self.treeLayer then
			self.treeTab:update()
		end

		if self.eggLayer~=nil then
			self.eggLayer:removeFromParentAndCleanup(true)
			self.eggLayer=nil
		end
	elseif idx==0 then
		if self.treeLayer~=nil then
			self.treeLayer:removeFromParentAndCleanup(true)
			self.treeLayer=nil
		end
		if self.eggLayer==nil then
			self.eggTab=acShengdankuanghuanTab1:new()
			self.eggLayer=self.eggTab:init(self.layerNum)
			self.bgLayer:addChild(self.eggLayer)
		else
			self.eggLayer:setVisible(true)
		end
	end
end

function acShengdankuanghuanDialog:tick( )
	local acVo=acShengdankuanghuanVoApi:getAcVo()
	if acVo then 
		if activityVoApi:isStart(acVo) == false then --活动结束 板子还开着，就要强制关板子
			if self~=nil then
				self:close()
			end
		end
	end
	if acShengdankuanghuanVoApi.lastSt + 300 < base.serverTime and self.getTimes <= 2 then
		if self.treeLayer then
			self.treeTab:update()
		end
      self.getTimes = self.getTimes + 1
      if self.getTimes > 2 then
        self.getTimes = 0
        acShengdankuanghuanVoApi:setLastSt()
      end
  end
  if(self.eggTab and self.eggTab.tick)then
  	self.eggTab:tick()
  end
end

function acShengdankuanghuanDialog:update( )
	local acVo=acShengdankuanghuanVoApi:getAcVo()
	if acVo then 
		if self.eggLayer then 
			self.eggTab:updata()
		end
	end

end

function acShengdankuanghuanDialog:dispose( )
	if self.treeLayer then
		self.treeTab:dispose()
	end
	if self.eggLayer then 
		self.eggTab:dispose()
	end
	self.treeLayer=nil
	self.treeTab=nil
	self.eggLayer=nil
	self.eggTab=nil
	self.getTimes=nil

	self=nil
end
