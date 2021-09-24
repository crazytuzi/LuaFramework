acYijizaitanDialog=commonDialog:new()

function acYijizaitanDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.acTab1=nil
	self.acTab2=nil
	self.layerTab1=nil
	self.layerTab2=nil

	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acFeixutansuo.plist")
	return nc
end

function acYijizaitanDialog:resetTab()
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

function acYijizaitanDialog:initTableView()
	
	local function callback( ... )
    end

    local hd= LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
  
    local function callback(fn,data)
    	  local ret,sData=base:checkServerData(data)
	      if ret==true then
	      	if sData.data["yijizaitan"]["list"] then
	      		acYijizaitanVoApi:setRewardList(sData.data["yijizaitan"]["list"])
	      		self:update()
	      	end
	      end
    end

    if acYijizaitanVoApi:getRewardList()==nil then
    	socketHelper:activityYijizaitanRewardList(callback)
    end
	self:tabClick(0,false)
end
function acYijizaitanDialog:tabClick(idx,isEffect)
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
			print("+++++++base.mustmodel,acYijizaitanVoApi:getMustMode()",base.mustmodel,acYijizaitanVoApi:getMustMode())
			if base.mustmodel==1 and acYijizaitanVoApi:getMustMode() then
				self.acTab1=acYijizaitanTab1New:new()
			else
				self.acTab1=acYijizaitanTab1:new()
			end
			
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
			self.acTab2=acYijizaitanTab2:new()
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
			self.acTab2:refresh()
		end
	end
end
function acYijizaitanDialog:tick()
	local vo=acYijizaitanVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
	if self and self.bgLayer and self.acTab1 and self.layerTab1 then 
		self.acTab1:tick()
	end
end
function acYijizaitanDialog:fastTick()
    if self.acTab1 then
        self.acTab1:fastTick()
    end
end
function acYijizaitanDialog:update()
	if self and self.bgLayer and self.acTab1 and self.layerTab1 then 
		self.acTab1:updateShowTv()
	end
end
function acYijizaitanDialog:dispose()
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
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acFeixutansuo.plist")
end