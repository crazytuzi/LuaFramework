require "luascript/script/game/scene/gamedialog/plane/planeEquipedDialog"
require "luascript/script/game/scene/gamedialog/plane/planeSkillDialog"
require "luascript/script/game/scene/gamedialog/plane/planeSkillTreeTab"

planeAttackDialog=commonDialog:new()

function planeAttackDialog:new(planeId,studySid)
  local nc={}
  setmetatable(nc,self)
  self.__index=self
  self.tab1=nil
  self.tab2=nil
  self.tab3=nil
  self.layerTab1=nil
  self.layerTab2=nil
  self.layerTab3=nil
  self.planeId=planeId
  self.studySid=studySid
  return nc
end

function planeAttackDialog:resetTab()
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(true)
    self.panelTopLine:setPositionY(G_VisibleSizeHeight-158)
    spriteController:addPlist("public/serverWarLocal/serverWarLocal2.plist")
    spriteController:addTexture("public/serverWarLocal/serverWarLocal2.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/plane/planeAttackImages.plist")
    spriteController:addTexture("public/plane/planeAttackImages.png")
    spriteController:addPlist("public/emblem/emblemImage.plist")
    spriteController:addTexture("public/emblem/emblemImage.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
    panelBg:setAnchorPoint(ccp(0.5,0))
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-165))
    panelBg:setPosition(G_VisibleSizeWidth/2,5)
    self.bgLayer:addChild(panelBg)
    
    local index=0
    local tabHeight=0
    for k,v in pairs(self.allTabs) do
        local  tabBtnItem=v
        local tabPosY=self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight
        if index==0 then
            tabBtnItem:setPosition(119,tabPosY)
        elseif index==1 then
            tabBtnItem:setPosition(320,tabPosY)
        elseif index==2 then
            tabBtnItem:setPosition(521,tabPosY)
        end
        if index==self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end
        index=index+1
    end
    self.tabNum=SizeOfTable(self.allTabs)
    self.skillTreeOpenFlag=planeVoApi:isSkillTreeSystemOpen()
    self.panelLineBg:setAnchorPoint(ccp(0.5,0))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))

    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self:initBottom()

    self:tabClick(0,false)
end

function planeAttackDialog:tabClick(idx,eFlag)
    if eFlag==nil then
        eFlag=true
    end
    if eFlag then
        PlayEffect(audioCfg.mouseClick)
    end
    if idx==2 then --点击战机革新页签，需要判断该功能是否开启
        if self.skillTreeOpenFlag==false then
            self.selectedTabIndex=self.oldSelectedTabIndex
            self:tabClickColor(self.selectedTabIndex)
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("plane_skilltree_unlock"),28)   
            do return end
        end
    end
    
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
        else
            v:setEnabled(true)
        end
    end
    self:getDataByType1(idx+1)
end

function planeAttackDialog:getDataByType1(type)
    if(type==nil)then
        type=1
    end
    if(type==1)then
        if(self.tab1==nil)then
            self.tab1=planeEquipedDialog:new()
            self.layerTab1=self.tab1:init(self.layerNum,self,self.planeId)
            self.bgLayer:addChild(self.layerTab1)
            if(self.selectedTabIndex==0)then
                self:switchTab(1)
            end
        else
            self:switchTab(1)
        end
    elseif(type==2)then
        if(self.tab2==nil)then
            self.tab2=planeSkillDialog:new()
            self.layerTab2=self.tab2:init(self.layerNum,self)
            self.bgLayer:addChild(self.layerTab2)
            if(self.selectedTabIndex==1)then
                self:switchTab(2)
            end
        else
            self:switchTab(2)
        end
    elseif(type==3) then
        if(self.tab3==nil)then
            self.tab3=planeSkillTreeTab:new()
            self.layerTab3=self.tab3:init(self.layerNum,self,self.studySid)
            self.bgLayer:addChild(self.layerTab3)
            if(self.selectedTabIndex==2)then
                self:switchTab(3)
            end
        else
            self:switchTab(3)
        end  
    end
end

function planeAttackDialog:switchTab(tabType)
    if tabType==nil then
        tabType=1
    end
    for i=1,self.tabNum do
        if(i==tabType)then
            if(self["layerTab"..i]~=nil)then
                self["layerTab"..i]:setPosition(ccp(0,0))
                self["layerTab"..i]:setVisible(true)
            end
        else
            if(self["layerTab"..i]~=nil)then
                self["layerTab"..i]:setPosition(ccp(999333,0))
                self["layerTab"..i]:setVisible(false)
            end
        end
        if self["tab"..i] and self["tab"..i].updateUI and (i==tabType) then
            self["tab"..i]:updateUI()
        end
    end
    if self.menu then
        if tabType==3 then
            self.menu:setVisible(false)
        else
            self.menu:setVisible(true)
        end
    end
end

function planeAttackDialog:initBottom()
    local function refreshFreeFlag(event,data)
        if self.freeGetFlagIcon then
            if planeVoApi:checkIfHadFreeCost()==true then
                self.freeGetFlagIcon:setVisible(true)
            else
                self.freeGetFlagIcon:setVisible(false)
            end
        end
    end
    self.refreshListener=refreshFreeFlag
    eventDispatcher:addEventListener("skill.freeget.refresh",self.refreshListener)

    local btnScale=0.8
    local strSize2=22
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ko" then
        strSize2=24
    end
    local function getHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        planeVoApi:showGetDialog(self.layerNum+1)
    end
    -- 技能获取
    local itemGet=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",getHandler,2,getlocal("skill_lottery"),strSize2/btnScale)
    itemGet:setScale(btnScale)
    itemGet:setPosition(ccp(120,60))
    local capInSet1=CCRect(17, 17, 1, 1)
    local function touchClick()
    end
    self.freeGetFlagIcon=LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
    self.freeGetFlagIcon:setPosition(ccp(190,55))
    itemGet:addChild(self.freeGetFlagIcon)
    if planeVoApi:checkIfHadFreeCost() == true then
        self.freeGetFlagIcon:setVisible(true)
    else
        self.freeGetFlagIcon:setVisible(false)
    end
    local function bulkSaleHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if planeRefitVoApi:isOpen() == true then
            if planeRefitVoApi:isCanEnter(true) == true then
                print("cjl ------->>> 战机聚能")
                planeRefitVoApi:showMainDialog(self.layerNum + 1)
            end
        else
            planeVoApi:showBulkSaleDialog(self.layerNum+1)
        end
    end
    -- 技能分解
    local itemDecompose=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",bulkSaleHandler,3,getlocal(planeRefitVoApi:isOpen() and "planeRefit_text" or "skill_decompose"),strSize2/btnScale)
    itemDecompose:setScale(btnScale)
    itemDecompose:setPosition(ccp(planeRefitVoApi:isOpen() and (G_VisibleSizeWidth - 120) or (G_VisibleSizeWidth/2),60))

    local function advanceHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        planeVoApi:showAdvanceDialog(self.layerNum+1)
    end
    -- 技能融合
    local itemAdvance=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",advanceHandler,4,getlocal("skill_merge"),strSize2/btnScale)
    itemAdvance:setScale(btnScale)
    itemAdvance:setPosition(ccp(planeRefitVoApi:isOpen() and (G_VisibleSizeWidth / 2) or (G_VisibleSizeWidth-120),60))

    local menu=CCMenu:create()
    menu:addChild(itemGet)
    menu:addChild(itemDecompose)
    menu:addChild(itemAdvance)
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority((-(self.layerNum-1)*20-4))
    self.bgLayer:addChild(menu)
    self.menu=menu

    otherGuideMgr:setGuideStepField(34,itemGet,true)
    if planeRefitVoApi:isCanEnter() == true then
        otherGuideMgr:setGuideStepField(85, itemDecompose,true)
    end
end

function planeAttackDialog:tick()
    for i=1,self.tabNum do
          if self["tab"..i]~=nil and self["tab"..i].tick and self.selectedTabIndex+1==i then
            self["tab"..i]:tick()
        end
    end
end

function planeAttackDialog:fastTick()
	for i=1,self.tabNum do
          if self["tab"..i]~=nil and self["tab"..i].fastTick and self.selectedTabIndex+1==i then
            self["tab"..i]:fastTick()
        end
    end
end

function planeAttackDialog:dispose()
	for i=1,self.tabNum do
		if (self["tab"..i]~=nil and self["tab"..i].dispose) then
			self["tab"..i]:dispose()
		end
	end
	self.tab1=nil
	self.tab2=nil
    self.tab3=nil
	self.layerTab1=nil
	self.layerTab2=nil
    self.layerTab3=nil
    self.tabNum=nil
    self.skillTreeOpenFlag=nil
    self.menu=nil
    self.studySid=nil
    eventDispatcher:removeEventListener("skill.freeget.refresh",self.refreshListener)
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/emblem/emblemBlackBg.jpg")
	spriteController:removePlist("public/serverWarLocal/serverWarLocal2.plist")
	spriteController:removeTexture("public/serverWarLocal/serverWarLocal2.png")
    spriteController:addPlist("public/plane/planeAttackImages.plist")
    spriteController:addTexture("public/plane/planeAttackImages.png")
    spriteController:removePlist("public/emblem/emblemImage.plist")
    spriteController:removeTexture("public/emblem/emblemImage.png")
    if otherGuideMgr.isGuiding and otherGuideMgr.curStep==38 then
        require "luascript/script/game/scene/gamedialog/warDialog/tankDefenseDialog"
        local td=tankDefenseDialog:new(self.layerNum+1)
        local tbArr={getlocal("fleetCard"),getlocal("dispatchCard"),getlocal("repair")}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("defenceSetting"),true,self.layerNum+1)
        sceneGame:addChild(dialog,self.layerNum+1)
        otherGuideMgr:toNextStep()
    elseif otherGuideMgr.isGuiding and otherGuideMgr.curStep<39 then
        planeVoApi:endPlaneGuide()
    end
end