acImminentDialog=commonDialog:new()

function acImminentDialog:new( layerNum )
	local nc = {}
	setmetatable(nc,self)
	self.__index =self
	self.acTab1=nil
	self.acTab2=nil
	self.acTab3=nil

	self.layerTab1=nil
	self.layerTab2=nil
	self.layerTab3=nil

	self.layerNum=layerNum
	return nc
end

function acImminentDialog:resetTab( )
	local index=0
    local tabHeight=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==1 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+23+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==2 then
         tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)

         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
end

function acImminentDialog:tabClick(idx,isEffect)
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
    self:getDataByType(idx + 1)

    
end
function acImminentDialog:getDataByType(type)
  if(type==nil)then
      type=1
  end 
  if type==1 then
        if self.layerTab1 ==nil then
          self.acTab1=acImminentTab1:new(self.layerNum)
          self.layerTab1=self.acTab1:init()
          self.bgLayer:addChild(self.layerTab1);
          self.layerTab1:setPosition(ccp(0,0))
        else
          self.layerTab1:setVisible(true)
          self.layerTab1:setPosition(ccp(0,0))
        end
        
        if self.layerTab2 then
          self.layerTab2:setVisible(false)
          self.layerTab2:setPosition(ccp(99930,0))
        end
        if self.layerTab3~=nil then
           self.layerTab3:setVisible(false)
           self.layerTab3:setPosition(ccp(99930,0))
        end
    elseif type==2 then
        self.layerTab1:setVisible(false)
        self.layerTab1:setPosition(ccp(10000,0))
        
        if self.layerTab2 ==nil then
            self.acTab2=acImminentTab2:new(self.layerNum)
            self.layerTab2=self.acTab2:init()
            self.bgLayer:addChild(self.layerTab2);
            -- self.layerTab2:setPosition(ccp(10000,0))
            -- self.layerTab2:setVisible(false)
        else
          -- self.acTab2:refresh()
        end
        self.layerTab2:setVisible(true)
        self.layerTab2:setPosition(ccp(0,0))

        if self.layerTab3~=nil then
           self.layerTab3:setVisible(false)
           self.layerTab3:setPosition(ccp(99930,0))
        end    
    elseif type==3 then
        if self.layerTab3 ==nil then
          self.acTab3=acImminentTab3:new(self.layerNum)
          self.layerTab3=self.acTab3:init()
          self.bgLayer:addChild(self.layerTab3)
          self.layerTab3:setPosition(ccp(0,0))
          -- self.layerTab3:setVisible(true)
        else
          self.layerTab3:setVisible(true)
          self.layerTab3:setPosition(ccp(0,0))
        end


        self.layerTab1:setVisible(false)
        self.layerTab1:setPosition(ccp(99930,0))
        if self.layerTab2 then
          self.layerTab2:setVisible(false)
          self.layerTab2:setPosition(ccp(99930,0))
        end
        
    end
end



function acImminentDialog:initTableView()
	
	local function callback( ... )
	end
	local hd= LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-65-120),nil)

	self:tabClick(0,false)
end

function acImminentDialog:tick()
	local vo=acImminentVoApi:getAcVo()
  if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self then
          self:close()
          do return end
      end
  end


	-- if self and self.bgLayer and self.acTab3 and self.layerTab3 then 
	-- 	self.acTab3:tick()
	-- end
  if self and self.bgLayer and self.acTab1 and self.layerTab1 then 
    self.acTab1:tick()
  end
 --  if self and self.bgLayer and self.acTab2 and self.layerTab2 then 
 --    self.acTab2:tick()
 --  end
end

function acImminentDialog:update()

end

function acImminentDialog:dispose()
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
	self.layerTab1=nil
	self.layerTab2=nil

end