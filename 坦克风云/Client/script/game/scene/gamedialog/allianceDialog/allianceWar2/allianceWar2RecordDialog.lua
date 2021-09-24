allianceWar2RecordDialog=commonDialog:new()

function allianceWar2RecordDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.acTab1=nil
    self.acTab2=nil
    self.acTab3=nil
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    return nc
end

function allianceWar2RecordDialog:resetTab()
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
    self.selectedTabIndex = 0
end


function allianceWar2RecordDialog:initTableView() 
    self:tabClick(0,false)
    G_AllianceWarDialogTb["allianceWar2RecordDialog"]=self
end

function allianceWar2RecordDialog:tabClick(idx,isEffect)
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
            self.acTab1=allianceWar2RecordTab1:new()
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
        if self.layerTab3 then
            self.layerTab3:setPosition(ccp(999333,0))
            self.layerTab3:setVisible(false)
        end
    elseif(idx==1)then
        if(self.acTab2==nil)then 
			self.acTab2=allianceWar2RecordTab2:new()
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
         if self.layerTab3 then
            self.layerTab3:setPosition(ccp(999333,0))
            self.layerTab3:setVisible(false)
        end
    elseif(idx==2)then
        if(self.acTab3==nil)then 
			self.acTab3=allianceWar2RecordTab3:new()
			self.layerTab3=self.acTab3:init(self.layerNum)
			self.bgLayer:addChild(self.layerTab3)
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(999333,0))
            self.layerTab1:setVisible(false)
        end
        if self.layerTab2 then            
			self.layerTab2:setPosition(ccp(999333,0))
			self.layerTab2:setVisible(false)
        end
        if self.layerTab3 then            
			self.layerTab3:setPosition(ccp(0,0))
			self.layerTab3:setVisible(true)
        end
    end
end

function allianceWar2RecordDialog:tick()
	-- if self and self.bgLayer and self.acTab1 and self.layerTab1 then
	-- 	self.acTab1:tick()		
	-- end

	-- if self and self.bgLayer and self.acTab2 and self.layerTab2 then
	-- 	self.acTab2:tick()		
	-- end
end
function allianceWar2RecordDialog:refresh( tab )
 
end
function allianceWar2RecordDialog:dispose()
    if self.layerTab1 then
        self.acTab1:dispose()
    end
    if self.layerTab2 then
        self.acTab2:dispose()
    end
    if self.layerTab3 then
        self.acTab3:dispose()
    end
    self.acTab1=nil
    self.acTab2=nil
    self.acTab3=nil
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    G_AllianceWarDialogTb["allianceWar2RecordDialog"]=nil
end