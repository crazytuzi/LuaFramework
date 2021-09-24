acDouble11Dialog=commonDialog:new()

function acDouble11Dialog:new(layerNum)
    require "luascript/script/game/scene/gamedialog/activityAndNote/sellShowSureDialog"
    local ver = acDouble11VoApi:getVersion()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acDouble11.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acFirstRechargenew.plist")
    spriteController:addPlist("public/acLuckyCat.plist")  
    spriteController:addPlist("public/acNewYearsEva.plist")--acChunjiepansheng
    spriteController:addTexture("public/acNewYearsEva.png")
    spriteController:addPlist("public/acChunjiepansheng.plist")
    spriteController:addTexture("public/acChunjiepansheng.png")
    spriteController:addPlist("public/acRechargeBag_images.plist")
    spriteController:addTexture("public/acRechargeBag_images.png")
    spriteController:addPlist("public/acDouble11_NewImage.plist")
    spriteController:addTexture("public/acDouble11_NewImage.png")
    spriteController:addPlist("public/newDisplayImage.plist")
    spriteController:addTexture("public/newDisplayImage.png")
    if ver == 4 then
        spriteController:addPlist("public/acDouble11ver4Image.plist")
        spriteController:addTexture("public/acDouble11ver4Image.png")
    elseif ver >= 5 then
        spriteController:addPlist("public/acDouble11ver5Image.plist")
        spriteController:addTexture("public/acDouble11ver5Image.png")
        spriteController:addPlist("public/acSuperShopImage.plist")
        spriteController:addTexture("public/acSuperShopImage.png")
        spriteController:addTexture("public/acKafkaGift.pvr.ccz")
        spriteController:addPlist("public/acKafkaGift.plist")
        
        
    end
        if gDouble11rTb and SizeOfTable(gDouble11rTb) == 0 then --双11随机表 在base里创建好的空表
            acDouble11VoApi:setgDouble11rTb()
        end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum

    self.tab1 = nil
    self.tabLayer1 = nil
    self.tab2 = nil
    self.tabLayer2 = nil

    self.getTimes = 0

    self.url= ver ==4 and G_downloadUrl("active/".."double11NewBg.png") or nil
    return nc
end

function acDouble11Dialog:resetTab()
    local ver = acDouble11VoApi:getVersion()
    if ver == 4 then
        self.panelLineBg:setVisible(false)  
        print(" in resetTab~~~")
        local infoH=120
        if G_isIphone5()==true then
            infoH=150
        end
        local layerH=G_VisibleSizeHeight-infoH-180
        local scale=layerH/651
        local function onLoadIcon(fn,icon)
            if self and self.bgLayer then
                if self.bgLayer then
                    icon:setAnchorPoint(ccp(0.5,0))
                    icon:setScaleY((G_VisibleSizeHeight-120)/icon:getContentSize().height)
                    icon:setScaleX(G_VisibleSizeWidth/icon:getContentSize().width)
                    self.bgLayer:addChild(icon)
                    icon:setPosition(ccp(G_VisibleSizeWidth*0.5,40))
                end
            end
        end
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    elseif ver >= 5 then
        self.panelLineBg:setVisible(false)
    end
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
end
--设置对话框里的tableView
function acDouble11Dialog:initTableView()

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setVisible(false)

    self.tv:setMaxDisToBottomOrTop(120)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acDouble11Dialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 4

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize =CCSizeMake(400,180)
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()
       return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end



--点击tab页签 idx:索引
function acDouble11Dialog:tabClick(idx)
    if newGuidMgr:isNewGuiding() then --新手引导
      do return end
    end
    PlayEffect(audioCfg.mouseClick)

    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            -- self:doUserHandler()            
         else
            v:setEnabled(true)
         end
    end
    
    if idx==1 then

        if self.tabLayer2==nil then
            self.tab2=acDouble11Tab2:new()
            self.tabLayer2=self.tab2:init(self.layerNum)
            self.bgLayer:addChild(self.tabLayer2,1)
        else
            self.tabLayer2:setVisible(true)
             -- self.tab2.tv:updata()
        end
        
        
        if self.tabLayer1 ~= nil then
            self.tabLayer1:setVisible(false)
            self.tabLayer1:setPosition(ccp(10000,0))
        end
        
        self.tabLayer2:setPosition(ccp(0,0))
            
    elseif idx==0 then
            
        if self.tabLayer2~=nil then
            self.tabLayer2:setPosition(ccp(999333,0))
            self.tabLayer2:setVisible(false)
        end
        
        if self.tabLayer1==nil then
            self.tab1=acDouble11Tab1:new()
            self.tab1.dialog =self
            self.tabLayer1=self.tab1:init(self.layerNum)
            self.bgLayer:addChild(self.tabLayer1,1)
        else
             self.tabLayer1:setVisible(true)
             -- self.tab1:updata()
        end

        self.tabLayer1:setPosition(ccp(0,0))
    end
end


function acDouble11Dialog:tick()
  local vo=acDouble11VoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
  if self and self.bgLayer and self.tab1 and self.tabLayer1 then 
    self.tab1:tick()
  end
  if self and self.bgLayer and self.tab2 and self.tabLayer2 then 
    self.tab2:tick()
  end
end


function acDouble11Dialog:update()

end

function acDouble11Dialog:dispose()
    if self.tab1~=nil then
        self.tab1:dispose()
    end
    if self.tab2~=nil then
        self.tab2:dispose()
    end
    self.tab1 = nil
    self.tabLayer1 = nil
    self.tab2 = nil
    self.tabLayer2 = nil
    self.layerNum = nil
    self.getTimes = 0
    self=nil
    spriteController:removePlist("public/acLuckyCat.plist")  
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
    spriteController:removePlist("public/acRechargeBag_images.plist")
    spriteController:removeTexture("public/acRechargeBag_images.png")
    spriteController:removePlist("public/acDouble11_NewImage.plist")
    spriteController:removeTexture("public/acDouble11_NewImage.png")
    spriteController:removePlist("public/acChunjiepansheng.plist")
    spriteController:removeTexture("public/acChunjiepansheng.png")
    spriteController:removePlist("public/newDisplayImage.plist")
    spriteController:removeTexture("public/newDisplayImage.png")
    if(acDouble11VoApi and acDouble11VoApi.getVersion)then
        local ver = acDouble11VoApi:getVersion()
        if ver == 4 then
            spriteController:removePlist("public/acDouble11ver4Image.plist")
            spriteController:removeTexture("public/acDouble11ver4Image.png")
        elseif ver >= 5 then--acSuperShopImage
            spriteController:removePlist("public/acDouble11ver5Image.plist")
            spriteController:removeTexture("public/acDouble11ver5Image.png")
            spriteController:removePlist("public/acSuperShopImage.plist")
            spriteController:removeTexture("public/acSuperShopImage.png")
            spriteController:removePlist("public/acKafkaGift.plist")
            spriteController:removeTexture("public/acKafkaGift.pvr.ccz")
        end
    end
end