acChrisEveDialog=commonDialog:new()

function acChrisEveDialog:new( layerNum )
  local nc = {}
  setmetatable(nc,self)
  self.__index =self
  self.acTab1=nil
  self.acTab2=nil
  self.acTab3=nil

  self.layerTab1=nil
  self.layerTab2=nil
  self.layerTab3=nil
  self.url = G_downloadUrl("active/".."acChrisEve_v5.jpg") or nil
  self.layerNum=layerNum
  return nc
end

function acChrisEveDialog:resetTab( )--acChrisEve_v5.jpg
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

    if(acChrisEveVoApi:isNormalVersion()==false) and acChrisEveVoApi:getVersion() ~= 5 then
      if G_curPlatName()~="3" and G_curPlatName()~="efunandroidtw" and G_curPlatName()~="efunandroid360" and G_curPlatName()~="efunandroidmemoriki" and G_curPlatName()~="androidlongzhong" and G_curPlatName()~="androidlongzhong2" and G_curPlatName()~="androidom2"  then
          local particleS2 = CCParticleSystemQuad:create("public/snow2.plist")
          particleS2.positionType=kCCPositionTypeFree
          particleS2:setPosition(ccp(320,G_VisibleSizeHeight+20))
          self.bgLayer:addChild(particleS2,10)
      end
    else
      spriteController:addPlist("public/acChrisEveImage2.plist")
      spriteController:addTexture("public/acChrisEveImage2.png")
    end
    if acChrisEveVoApi:getVersion() == 5 then
        spriteController:addPlist("public/acChrisEve_v5_image.plist")
        spriteController:addTexture("public/acChrisEve_v5_image.png")
        spriteController:addPlist("public/newTopBgImage1.plist")
        spriteController:addTexture("public/newTopBgImage1.png")
        spriteController:addPlist("public/packsImage.plist")
        spriteController:addTexture("public/packsImage.png")
        self.panelLineBg:setVisible(false)
        self.upPosY = G_VisibleSizeHeight-157
        local tabLine=LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png",CCRect(4,3,1,1),function()end)
        tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,tabLine:getContentSize().height))
        tabLine:setAnchorPoint(ccp(0.5,1))
        tabLine:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-157)
        self.bgLayer:addChild(tabLine,5)
        
        self.panelBg_Shade=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
        self.panelBg_Shade:setAnchorPoint(ccp(0.5,0))
        self.panelBg_Shade:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
        self.panelBg_Shade:setPosition(G_VisibleSizeWidth * 0.5,5)
        self.bgLayer:addChild(self.panelBg_Shade)


        
        if self.url then
          local function onLoadIcon(fn,icon)
            if self and self.bgLayer and icon then
                icon:setAnchorPoint(ccp(0.5,1))
                icon:setPosition(G_VisibleSizeWidth * 0.5,G_VisibleSizeHeight-157)
                icon:setScaleX(G_VisibleSizeWidth/icon:getContentSize().width)
                icon:setScaleY((G_VisibleSizeHeight-157)/icon:getContentSize().height)
                self.bgLayer:addChild(icon)
                self:tabClick(0,false)
            end
          end
          CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
          CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
          local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)
          CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
          CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        end
    end
end

function acChrisEveDialog:tabClick(idx,isEffect)
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
function acChrisEveDialog:getDataByType(type)
  if(type==nil)then
      type=1
  end 
  if type==1 then
        if self.layerTab1 ==nil then
          local function sendRequestCallBack(fn,data)
              local ret,sData=base:checkServerData(data)
              if ret ==true then
                  if(self and self.bgLayer)then
                    if sData.data and sData.data and sData.data.list then
                      acChrisEveVoApi:setRecGiftTb(sData.data.list)
                    end
  
                    self.acTab1=acChrisEveTab1:new(self.layerNum)
                    self.layerTab1=self.acTab1:init()
                    self.bgLayer:addChild(self.layerTab1,1);
                    self.layerTab1:setPosition(ccp(0,0))
                    -- self.layerTab1:setVisible(true)
                  end
              end
          end
          socketHelper:chrisEveSend(sendRequestCallBack,"get")
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
            self.acTab2=acChrisEveTab2:new(self.layerNum)
            self.layerTab2=self.acTab2:init()
            self.bgLayer:addChild(self.layerTab2,1);
            -- self.layerTab2:setPosition(ccp(10000,0))
            -- self.layerTab2:setVisible(false)
        else
          self.acTab2:refresh()
        end
        self.layerTab2:setVisible(true)
        self.layerTab2:setPosition(ccp(0,0))

        if self.layerTab3~=nil then
           self.layerTab3:setVisible(false)
           self.layerTab3:setPosition(ccp(99930,0))
        end    
    elseif type==3 then
        if self.layerTab3 ==nil then
          local function sendRequestCallBack(fn,data)
              local ret,sData=base:checkServerData(data)
              if ret ==true then
                  if sData.data and sData.ranklist then
                    acChrisEveVoApi:setRankList(sData.ranklist)
                  end
                  acChrisEveVoApi:setCurrTime( sData.ts)
                  acChrisEveVoApi:setCurrType(false)
                  print("ts~~~~~~----->",sData.ts)
                  self.acTab3=acChrisEveTab3:new(self.layerNum)
                  self.layerTab3=self.acTab3:init()
                  self.bgLayer:addChild(self.layerTab3,1)
                  self.layerTab3:setPosition(ccp(0,0))
                  -- self.layerTab3:setVisible(true)
              end
          end
          socketHelper:chrisEveSend(sendRequestCallBack,"ranklist")
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



function acChrisEveDialog:initTableView()
  
  local function callback( ... )
  end
  local hd= LuaEventHandler:createHandler(callback)
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)
  if acChrisEveVoApi:getVersion() ~= 5 then
    self:tabClick(0,false)
  end
end

function acChrisEveDialog:tick()
  local vo=acChrisEveVoApi:getAcVo()
  if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self then
          self:close()
          do return end
      end
  end


  if self and self.bgLayer and self.acTab3 and self.layerTab3 then 
    self.acTab3:tick()
  end
  if self and self.bgLayer and self.acTab1 and self.layerTab1 then 
    self.acTab1:tick()
  end
  if self and self.bgLayer and self.acTab2 and self.layerTab2 then 
    self.acTab2:tick()
  end
end

function acChrisEveDialog:update()

end

function acChrisEveDialog:dispose()
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
  spriteController:removePlist("public/acChrisEveImage2.plist")
  spriteController:removeTexture("public/acChrisEveImage2.png")
  if acChrisEveVoApi:getVersion() == 5 then
      spriteController:removePlist("public/acChrisEve_v5_image.plist")
      spriteController:removeTexture("public/acChrisEve_v5_image.png")
      spriteController:removePlist("public/newTopBgImage1.plist")
      spriteController:removeTexture("public/newTopBgImage1.png")
      spriteController:removePlist("public/packsImage.plist")
      spriteController:removeTexture("public/packsImage.png")
  end
end