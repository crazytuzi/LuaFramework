acXssd2019Dialog=commonDialog:new()

function acXssd2019Dialog:new( )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self
	nc.acTab1=nil
    nc.acTab2=nil

    nc.layerTab1=nil
    nc.layerTab2=nil
    nc.layerNum=layerNum
    nc.isTodayFlag = acXssd2019VoApi:isToday()
	return nc
end

function acXssd2019Dialog:resetTab()
	self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(true)
    self.panelShadeBg:setVisible(true)

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acXssd2019Icon_1.plist")
    spriteController:addTexture("public/acXssd2019Icon_1.png")
    spriteController:addPlist("public/acXssd2019Icon_2.plist")
    spriteController:addTexture("public/acXssd2019Icon_2.png")
    spriteController:addPlist("public/acXssd2019Flicker.plist")
    spriteController:addTexture("public/acXssd2019Flicker.png")
    spriteController:addPlist("public/acXssd2019Flicker_tab3.plist")
    spriteController:addTexture("public/acXssd2019Flicker_tab3.png")
    spriteController:addPlist("public/commonBtn1.plist")
    spriteController:addTexture("public/commonBtn1.png")
    spriteController:addPlist("public/acSuperShopImage.plist")
    spriteController:addTexture("public/acSuperShopImage.png")
    spriteController:addPlist("public/youhuaUI7.plist")
    spriteController:addTexture("public/youhuaUI7.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)


    self:setIconTipVisibleByIdx(acXssd2019VoApi:tab1Reward(),1)
    self:setIconTipVisibleByIdx(acXssd2019VoApi:tab2Reward(),2)
    self:setIconTipVisibleByIdx(acXssd2019VoApi:tab3Reward(),3)

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
    self:tabClick(0)
end

function acXssd2019Dialog:tabClick(idx,isEffect)
    if(isEffect)then
        PlayEffect(audioCfg.mouseClick)
    end
    self:tabClickColor(idx)

    local function showTabHandle()
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
        self:refresh(idx)
    end

    if idx == 0 then
        local function getNewData()
            showTabHandle()
        end
        acXssd2019VoApi:getNewDataSocket(getNewData)
    else
        showTabHandle()
    end
end

function acXssd2019Dialog:getDataByType(type)
    if(type==nil)then
      type=1
    end 
    if type==1 then
        if self.layerTab1 ==nil then
            self.acTab1=acXssd2019Tab1:new(self.layerNum)
            self.layerTab1=self.acTab1:init(self)
            self.bgLayer:addChild(self.layerTab1,1);
        end
        self.layerTab1:setVisible(true)
        self.layerTab1:setPosition(ccp(0,0))
        
        if self.layerTab2 then
            self.layerTab2:setVisible(false)
            self.layerTab2:setPosition(ccp(99930,0))
        end
        if self.layerTab3 then
            self.layerTab3:setVisible(false)
            self.layerTab3:setPosition(ccp(99930,0))
        end
    elseif type==2 then
        if self.layerTab2 ==nil then
            self.acTab2=acXssd2019Tab2:new(self.layerNum,self)
            self.layerTab2=self.acTab2:init(self)
            self.bgLayer:addChild(self.layerTab2,1);
        end
        self.layerTab2:setVisible(true)
        self.layerTab2:setPosition(ccp(0,0))

        if self.layerTab1 then
            self.layerTab1:setVisible(false)
            self.layerTab1:setPosition(ccp(99930,0))
        end
        if self.layerTab3 then
            self.layerTab3:setVisible(false)
            self.layerTab3:setPosition(ccp(99930,0))
        end
    elseif type==3 then
        if self.layerTab3 ==nil then
            self.acTab3=acXssd2019Tab3:new(self.layerNum,self)
            self.layerTab3=self.acTab3:init(self)
            self.bgLayer:addChild(self.layerTab3,1);
        end
        self.layerTab3:setVisible(true)
        self.layerTab3:setPosition(ccp(0,0))

        if self.layerTab1 then
            self.layerTab1:setVisible(false)
            self.layerTab1:setPosition(ccp(99930,0))
        end
        if self.layerTab2 then
            self.layerTab2:setVisible(false)
            self.layerTab2:setPosition(ccp(99930,0))
        end
    end
end

function acXssd2019Dialog:initTableView( )
	-- body
end

function acXssd2019Dialog:tick()
    local vo=acXssd2019VoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end

    local todayFlag=acXssd2019VoApi:isToday()
    if self.isTodayFlag == true and todayFlag == false then
        self.isTodayFlag=false
        --重置免费次数
        local function showRefresh() 
            self:refresh()
        end
         local function getNewData()
            showRefresh()
        end
        acXssd2019VoApi:getNewDataSocket(getNewData)
    end

    -- self:refresh()
    if self.acTab1 then
        self.acTab1:tick()
    end
    if self.acTab2 then
        self.acTab2:tick()
    end

    if self.acTab3 then
        self.acTab3:tick()
    end

end

function acXssd2019Dialog:refresh(idx)
    if idx and idx == 0 then
        if self.acTab1 and self.acTab1.refresh then
            self.acTab1:refresh()
        end
    elseif not idx then
        if self.acTab1 and self.acTab1.refresh then
            self.acTab1:refresh(true)
        end
        if self.acTab2 and self.acTab2.refresh then
            self.acTab2:refresh()
        end
        if self.acTab3 and self.acTab3.refresh then
            self.acTab3:refresh()
        end
    end
end


function acXssd2019Dialog:dispose()
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
    spriteController:removePlist("public/acXssd2019Icon_1.plist")
    spriteController:removeTexture("public/acXssd2019Icon_1.png")
    spriteController:removePlist("public/acXssd2019Icon_2.plist")
    spriteController:removeTexture("public/acXssd2019Icon_2.png")
    spriteController:removePlist("public/acXssd2019Flicker.plist")
    spriteController:removeTexture("public/acXssd2019Flicker.png")
    spriteController:removePlist("public/acSuperShopImage.plist")
    spriteController:removeTexture("public/acSuperShopImage.png")
    spriteController:removePlist("public/acXssd2019Flicker_tab3.plist")
    spriteController:removeTexture("public/acXssd2019Flicker_tab3.png")
end