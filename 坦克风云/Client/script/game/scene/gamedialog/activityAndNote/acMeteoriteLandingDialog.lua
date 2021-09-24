acMeteoriteLandingDialog=commonDialog:new()

function acMeteoriteLandingDialog:new( )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self

	self.acTab1=nil
    self.acTab2=nil
    self.acTab3=nil
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil

    self.isStop=false
    self.isToday=true

    self.tv=nil
    --在这里加载图片
    return nc
end

function acMeteoriteLandingDialog:resetTab( )
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

function acMeteoriteLandingDialog:initTableView()
    local function callback( ... )
    end

    local hd= LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-360),nil)
    self.tv:setPosition(30, 30)
    self:tabClick(0,true)
end
function acMeteoriteLandingDialog:tabClick(idx,isEffect)
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
    if idx==0 then
        if self.acTab1==nil then            
            self.acTab1=acMeteoriteLandingTab1:new()
            self.layerTab1=self.acTab1:init(self.layerNum)
            self.bgLayer:addChild(self.layerTab1)
            self:refresh(1)

        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(0,0))
            self.layerTab1:setVisible(true)
            self:refresh(1)
        end
        if self.layerTab2 then
            self.layerTab2:setPosition(ccp(999333,0))
            self.layerTab2:setVisible(false)
        end
        if self.layerTab3 then
            self.layerTab3:setPosition(ccp(999333,0))
            self.layerTab3:setVisible(false)
          
        end
    elseif idx==1 then
        if self.acTab2==nil then 
            local function callback()
    			self.acTab2=acMeteoriteLandingTab2:new()
    			self.layerTab2=self.acTab2:init(self.layerNum)
    			self.bgLayer:addChild(self.layerTab2)
            end
            alienTechVoApi:getTechData(callback)
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
    elseif idx==2 then
        if self.acTab3==nil then 
            local function callback()
    			self.acTab3=acMeteoriteLandingTab3:new()
    			self.layerTab3=self.acTab3:init(self.layerNum)
    			self.bgLayer:addChild(self.layerTab3)
                self:refresh(3)
            end
            acMeteoriteLandingVoApi:getSocketRankList(callback)
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
            local function callback()         
    			self.layerTab3:setPosition(ccp(0,0))
    			self.layerTab3:setVisible(true)
                self:refresh(3)
            end
             acMeteoriteLandingVoApi:getSocketRankList(callback)
        end
    end
end
function acMeteoriteLandingDialog:refresh(tab)
    if tab ==3 then
        if self.acTab3 then
            self.acTab3:refresh()
        end
    end
     if tab ==1 then
        if self.acTab1 then
            self.acTab1:refresh()
        end
    end
end
function acMeteoriteLandingDialog:tick( )
    local vo=acMeteoriteLandingVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end


    local isSearchToday=acMeteoriteLandingVoApi:isSearchToday()
    local acIsStop=acMeteoriteLandingVoApi:acIsStop()
    if self.isStop~=acIsStop or self.isToday~=isSearchToday then
        self:refresh(1)
        self:refresh(3)
        self.isStop=acIsStop
        self.isToday=isSearchToday
    end
end


function acMeteoriteLandingDialog:dispose( )
	
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
    self.isStop=nil
    self.isToday=nil

    self.tv =nil
    self =nil
end