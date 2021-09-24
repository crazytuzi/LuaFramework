alienMinesTroopsDialog = commonDialog:new()

function alienMinesTroopsDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.acTab1=nil
    self.acTab2=nil
    self.layerTab1=nil
    self.layerTab2=nil
    return nc
end

function alienMinesTroopsDialog:resetTab()
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
	
    self.selectedTabIndex = 0
end

function alienMinesTroopsDialog:initTableView() 
    self:tabClick(0,false)
end

function alienMinesTroopsDialog:tabClick(idx,isEffect)
    if(isEffect)then
        PlayEffect(audioCfg.mouseClick)
    end
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
        else
            v:setEnabled(true)
        end
    end
    if(idx==0)then
        if(self.acTab1==nil)then            
            self.acTab1=alienMinesTroopsTab1:new()
            self.layerTab1=self.acTab1:init(self.layerNum)
            self.bgLayer:addChild(self.layerTab1)
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(0,0))
            self.layerTab1:setVisible(true)
        end
        if self.layerTab2 then
            self.layerTab2:setPosition(ccp(999333,0))
            self.layerTab2:setVisible(false)
        end
    elseif(idx==1)then
        if(self.acTab2==nil)then 
            require "luascript/script/game/scene/gamedialog/warDialog/tankDialogTab3"
			self.acTab2=tankDialogTab3:new()
			self.layerTab2=self.acTab2:init(self.layerNum)
			self.bgLayer:addChild(self.layerTab2)
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(999333,0))
            self.layerTab1:setVisible(false)
        end
        if self.layerTab2 then            
			self.layerTab2:setPosition(ccp(0,0))
			self.layerTab2:setVisible(true)
        end
    end
end

function alienMinesTroopsDialog:tick()
     local allSlots=SizeOfTable(attackTankSoltVoApi:getlienMinesTankSlots())
     if allSlots>0 then
        self:setTipsVisibleByIdx(true,1,allSlots)
     else
        self:setTipsVisibleByIdx(false,1)
     end
     local repairTanks=SizeOfTable(tankVoApi:getRepairTanks())
     if repairTanks>0 then
        self:setTipsVisibleByIdx(true,2,repairTanks)
     else
        self:setTipsVisibleByIdx(false,2)
     end

	if self and self.bgLayer and self.acTab1 and self.layerTab1 then
		self.acTab1:tick()		
	end

	if self and self.bgLayer and self.acTab2 and self.layerTab2 then
		self.acTab2:tick()		
	end
end

function alienMinesTroopsDialog:dispose()
    if self.layerTab1 then
        self.acTab1:dispose()
    end
    if self.layerTab2 then
        self.acTab2:dispose()
    end
    self.acTab1=nil
    self.acTab2=nil
    self.layerTab1=nil
    self.layerTab2=nil
end