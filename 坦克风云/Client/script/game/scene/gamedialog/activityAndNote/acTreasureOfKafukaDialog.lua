acTreasureOfKafukaDialog=commonDialog:new()
--vo/voapi 全部使用：acEquipSearchVo/VoApi
function acTreasureOfKafukaDialog:new(layerNum)
	local nc = {}
	setmetatable(nc,self)
	self.__index=self
	self.layerNum=layerNum

	self.layerTab1=nil
	self.layerTab2=nil

	self.treasureTab1=nil
	self.treasureTab2=nil

	self.isStop = false
	self.isToday =true

	return nc
end

--设置或修改每个Tab页签
function acTreasureOfKafukaDialog:resetTab(  )
    spriteController:addPlist("public/acthreeyear_images.plist")
    spriteController:addTexture("public/acthreeyear_images.png")
	local index = 0
	for k,v in pairs(self.allTabs) do
		local tabBtnItem = v

		if index ==0 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		elseif index ==1 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		end
		if index ==self.selectedTabIndex then
			tabBtnItem:setEnabled(false)
		end
		index = index+1
	end
	self.selectedTabIndex =0
end

function acTreasureOfKafukaDialog:initTableView( )
	local hd = LuaEventHandler:createHandler(function ( ... ) return self:eventHandler(...) end)
	self.tv = LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)
	self:switchTab(1)

end

function acTreasureOfKafukaDialog:hideAllTab( )
	if self.layerTab1 then
		self.layerTab1:setPosition(ccp(999333,0))
		self.layerTab1:setVisible(false)
	elseif self.layerTab2 then
		self.layerTab1:setPosition(ccp(999333,0))
		self.layerTab2:setVisible(false)
	end

end

function acTreasureOfKafukaDialog:getDataByType( typpe )
	if typpe == nil then
		typpe = 1
	end

	local function equipSearchListCallback( fn,data )
		local ret,sData = base:checkServerData(data)
		if ret== true then
			if self and self.bgLayer then
				local rankList 
				if sData.data and sData.data.equipSearchII and sData.data.equipSearchII.rankList then
					rankList =sData.data.equipSearchII
					acEquipSearchIIVoApi:updateData(rankList)
					self:switchTab(typpe)
					self:refresh(typpe)
					acEquipSearchIIVoApi:setFlag(2,1)
				end
			end
		end
	end 

	if typpe ==2 and acEquipSearchIIVoApi:getFlag(2) == -1 then
		acEquipSearchIIVoApi:clearRankList()
		self:hideAllTab()
		socketHelper:activeEquipsearchII(2,equipSearchListCallback)
	else
		if self and self.bgLayer then
			self:switchTab(typpe)
		end
	end

end

function acTreasureOfKafukaDialog:tabClickColor(idx)

end

--点击tab页签 idx:索引
function acTreasureOfKafukaDialog:tabClick(idx )
	for k,v in pairs(self.allTabs) do
		if v:getTag() ==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
			local tabBtnItem = v
			local tabBtnLabel = tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
			tabBtnLabel:setColor(G_ColorWhite)
			self:getDataByType(idx+1)
		else
			v:setEnabled(true)
			local tabBtnItem = v
			local tabBtnLabel = tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
			tabBtnLabel:setColor(G_ColorGreen)
		end
	end
end

function acTreasureOfKafukaDialog:switchTab( typpe )
	if typpe ==nil then
		typpe =1
	end
	if typpe ==1 then
		if self.treasureTab1 ==nil then
			self.treasureTab1 =acTreasureOfKafukaTab1:new()
			self.layerTab1 = self.treasureTab1:init(self.layerNum,0,self)
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
	elseif typpe ==2 then
		if self.treasureTab2 ==nil then
			self.treasureTab2 =acEquipSearchIITab2:new(self)
			self.layerTab2 = self.treasureTab2:init(self.layerNum,1,self)
			self.bgLayer:addChild(self.layerTab2)
		end
		if self.layerTab2 then
			self.layerTab2:setPosition(ccp(0,0))
			self.layerTab2:setVisible(true)
			self.treasureTab2:refresh()
		end
		if self.layerTab1 then
			self.layerTab1:setPosition(ccp(999333,0))
			self.layerTab1:setVisible(false)
		end
	end
end

function acTreasureOfKafukaDialog:tick( )
	local vo = acEquipSearchIIVoApi:getAcVo()
	if activityVoApi:isStart(vo)==false then
		if self then
			self:close()
			do return end
		end
	end

	local isSearchToday = acEquipSearchIIVoApi:isSearchToday()
	local acIsStop = acEquipSearchIIVoApi:acIsStop()

	if self.isStop ~=acIsStop or self.isToday ~= isSearchToday then
		self:refresh()
		self.isStop =acIsStop
		self.isToday =isSearchToday
	end
end

function acTreasureOfKafukaDialog:refresh(typpe)
	 if self then
		if typpe ==nil then
			if self.treasureTab1 then
				self.treasureTab1:refresh()
			end
			if self.treasureTab2 then
				self.treasureTab2:refresh()
			end
		else
			if typpe ==1 and self.treasureTab1 then
				self.treasureTab1:refresh()
			elseif typpe ==2 and self.treasureTab2 then
				self.treasureTab2:refresh()
			end
		end
	    end
end
function acTreasureOfKafukaDialog:fastTick( )
	if self.treasureTab1 then
		self.treasureTab1:fastTick()
	end
end
function acTreasureOfKafukaDialog:tick( )
	if self.treasureTab1 then
		self.treasureTab1:tick()
	end
    local vo=acEquipSearchIIVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end

    local isSearchToday=acEquipSearchIIVoApi:isSearchToday()
    local acIsStop=acEquipSearchIIVoApi:acIsStop()

    if self.isStop~=acIsStop or self.isToday~=isSearchToday then
        self:refresh()
        self.isStop=acIsStop
        self.isToday=isSearchToday
    end

end
function acTreasureOfKafukaDialog:dispose( )
    spriteController:removePlist("public/acthreeyear_images.plist")
    spriteController:removeTexture("public/acthreeyear_images.png")
	if self.treasureTab1 then
		self.treasureTab1:dispose()
	end
	if self.treasureTab2 then
		self.treasureTab2:dispose()
	end
	self.treasureTab1 =nil
	self.treasureTab2 =nil
	self.layerTab1 =nil
	self.layerTab2 =nil
	self.bgLayer=nil
	self.layerNum=nil
	self=nil

end



