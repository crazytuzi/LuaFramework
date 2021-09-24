require "luascript/script/game/scene/gamedialog/allianceDialog/allianceCity/cityBuildTab"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceCity/personalSkillTab"

allianceCityDialog=commonDialog:new()

function allianceCityDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.expandIdx={}
    self.layerNum=layerNum
    
    self.cityTab1=nil
    self.cityTab2=nil
    self.layerTab1=nil
    self.layerTab2=nil

    return nc
end

function allianceCityDialog:resetTab()
  spriteController:addPlist("scene/allianceCityImages.plist")
  spriteController:addTexture("scene/allianceCityImages.png")
  spriteController:addPlist("public/juntuanCityBtns.plist")
  spriteController:addTexture("public/juntuanCityBtns.png")
  spriteController:addPlist("public/resource_youhua.plist")
  spriteController:addTexture("public/resource_youhua.png")
  spriteController:addPlist("public/allianceSkills.plist")
  spriteController:addTexture("public/allianceSkills.png")
  spriteController:addPlist("public/youhuaUI3.plist")
  spriteController:addTexture("public/youhuaUI3.png")
  CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acYijizaitan.plist")


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
  self:tabClick(0)
end

--点击tab页签 idx:索引
function allianceCityDialog:tabClick(idx)
  PlayEffect(audioCfg.mouseClick)
  local tabType=idx+1
  if self["cityTab"..tabType]==nil then
    local tab
    if idx==0 then
      tab=cityBuildTab:new()
    elseif idx==1 then
      tab=personalSkillTab:new()
    end
    if tab then
      self["cityTab"..tabType]=tab
      self["layerTab"..tabType]=tab:init(self.layerNum,self)
      self.bgLayer:addChild(self["layerTab"..tabType],1)
    end
  end

  for k,v in pairs(self.allTabs) do
    local layerTab=self["layerTab"..k]
    local cityTab=self["cityTab"..k]
    if v:getTag()==idx then
      v:setEnabled(false)
      self.selectedTabIndex=idx
      if(layerTab and cityTab)then
        layerTab:setPosition(ccp(0,0))
        layerTab:setVisible(true)
        if cityTab.updateUI then
          cityTab:updateUI()
        end
      end
    else
      v:setEnabled(true)
      if(layerTab)then
        layerTab:setPosition(ccp(999333,0))
        layerTab:setVisible(false)
      end
    end
  end
end

function allianceCityDialog:doUserHandler()
    self.panelLineBg:setVisible(false)
    G_addCommonGradient(self.bgLayer,G_VisibleSizeHeight-155)
    -- self:playEnemyAttackEffect()
    local tipFlag=allianceCityVoApi:isGloryEnoughToUpgrade()
    self:setIconTipVisibleByIdx(tipFlag,2)
    
    local function refreshTip(event,data)
      local tipFlag=allianceCityVoApi:isGloryEnoughToUpgrade()
      self:setIconTipVisibleByIdx(tipFlag,2)
    end
    self.refreshTipListener=refreshTip
    eventDispatcher:addEventListener("alliancecity.tipRefresh",refreshTip)
end

function allianceCityDialog:cellClick(idx)
    -- if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
    --     if self.expandIdx["k"..(idx-1000)]==nil then
    --             self.expandIdx["k"..(idx-1000)]=idx-1000
    --             self.tv:openByCellIndex(idx-1000,120)
    --     else
    --         self.expandIdx["k"..(idx-1000)]=nil
    --         self.tv:closeByCellIndex(idx-1000,800)
    --     end
    -- end
end

function allianceCityDialog:playEnemyAttackEffect()
  if self.redKuangSp==nil then
    local redKuangSp=LuaCCScale9Sprite:createWithSpriteFrameName("enemyAttackKuang.png",CCRect(59,59,1,1),function () end)
    redKuangSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    redKuangSp:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(redKuangSp,99)
    self.redKuangSp=redKuangSp

    local acArr=CCArray:create()
    local fadeIn=CCFadeIn:create(0.8)
    local fadeOut=CCFadeOut:create(0.8)
    acArr:addObject(fadeIn)
    acArr:addObject(fadeOut)
    local seq=CCSequence:create(acArr)
    local repeatForever=CCRepeatForever:create(seq)
    self.redKuangSp:runAction(repeatForever)
  end
end

function allianceCityDialog:removeEnemyAttackEffect()
  if self.redKuangSp then
    self.redKuangSp:stopAllActions()
    self.redKuangSp:removeFromParentAndCleanup(true)
    self.redKuangSp=nil
  end
end

function allianceCityDialog:tick()
  if allianceCityVoApi:ishasAttackList()==true then --有进敌军来袭队列时显示敌军来袭红色警告效果
    self:playEnemyAttackEffect()
  else
    self:removeEnemyAttackEffect()
  end
  for i=1,2 do
    local cityTab=self["cityTab"..i]
    if cityTab and cityTab.tick then
      cityTab:tick()
    end
  end
end

function allianceCityDialog:dispose()
  for i=1,2 do
    local cityTab=self["cityTab"..i]
    if cityTab and cityTab.dispose then
      cityTab:dispose()
    end
  end
  self.cityTab1=nil
  self.cityTab2=nil
  self.layerTab1=nil
  self.layerTab2=nil
  
  spriteController:removePlist("scene/allianceCityImages.plist")
  spriteController:removeTexture("scene/allianceCityImages.png")
  spriteController:removePlist("public/juntuanCityBtns.plist")
  spriteController:removeTexture("public/juntuanCityBtns.png")
  spriteController:removePlist("public/resource_youhua.plist")
  spriteController:removeTexture("public/resource_youhua.png")
  spriteController:removePlist("public/allianceSkills.plist")
  spriteController:removeTexture("public/allianceSkills.png")
  spriteController:removePlist("public/youhuaUI3.plist")
  spriteController:removeTexture("public/youhuaUI3.png")
  CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acYijizaitan.plist")
  self:removeEnemyAttackEffect()
  if self.refreshTipListener then
      eventDispatcher:removeEventListener("alliancecity.tipRefresh",self.refreshTipListener)
      self.refreshTipListener=nil
  end
end