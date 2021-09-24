acMjcsDialog=commonDialog:new()

function acMjcsDialog:new( )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self
	nc.acTab1=nil
    nc.acTab2=nil

    nc.layerTab1=nil
    nc.layerTab2=nil
    nc.layerNum=layerNum
	return nc
end

function acMjcsDialog:resetTab()
	self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(true)
    self.panelShadeBg:setVisible(true)

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	spriteController:addPlist("public/acMjcsIconImage.plist")
	spriteController:addTexture("public/acMjcsIconImage.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)


    self:setIconTipVisibleByIdx(acMjcsVoApi:tab1Reward(),1)
    self:setIconTipVisibleByIdx(acMjcsVoApi:tab2Reward(),2)


    local index=0
    local tabHeight=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==1 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+23+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)

         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
    self:tabClick(0)
end

function acMjcsDialog:tabClick(idx,isEffect)
    if(isEffect)then
        PlayEffect(audioCfg.mouseClick)
    end
    self:tabClickColor(idx)
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
        else
            v:setEnabled(true)
        end
    end
    self:getDataByType(idx + 1)

    if self["acTab"..(idx+1)] and self["acTab"..(idx+1)].updateUI then
        self["acTab"..(idx+1)]:updateUI()
    end
end

function acMjcsDialog:getDataByType(type)
    if(type==nil)then
      type=1
    end 
    if type==1 then
        if self.layerTab1 ==nil then
            self.acTab1=acMjcsTab1:new(self.layerNum)
            self.layerTab1=self.acTab1:init(self)
            self.bgLayer:addChild(self.layerTab1,1);
        end
        self.layerTab1:setVisible(true)
        self.layerTab1:setPosition(ccp(0,0))
        
        if self.layerTab2 then
            self.layerTab2:setVisible(false)
            self.layerTab2:setPosition(ccp(99930,0))
        end
    elseif type==2 then
        if self.layerTab2 ==nil then
            self.acTab2=acMjcsTab2:new(self.layerNum,self)
            self.layerTab2=self.acTab2:init(self)
            self.bgLayer:addChild(self.layerTab2,1);
        end
        self.layerTab2:setVisible(true)
        self.layerTab2:setPosition(ccp(0,0))

        if self.layerTab1 then
            self.layerTab1:setVisible(false)
            self.layerTab1:setPosition(ccp(99930,0))
        end
    end
end

function acMjcsDialog:initTableView( )
	-- body
end

function acMjcsDialog:tick()
    local vo=acMjcsVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end

    -- self:refresh()
    if self.acTab1 then
        self.acTab1:tick()
    end
    if self.acTab2 then
        self.acTab2:tick()
    end

end


function acMjcsDialog:dispose()
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
    spriteController:removePlist("public/acMjcsIconImage.plist")
    spriteController:removeTexture("public/acMjcsIconImage.png")
end