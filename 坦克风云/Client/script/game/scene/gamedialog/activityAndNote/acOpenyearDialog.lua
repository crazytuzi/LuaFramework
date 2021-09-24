acOpenyearDialog=commonDialog:new()
function acOpenyearDialog:new( layerNum )
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

    spriteController:addPlist("public/acChunjiepansheng.plist")
    spriteController:addTexture("public/acChunjiepansheng.png")
    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
    spriteController:addPlist("public/acBlessWords.plist")
    spriteController:addTexture("public/acBlessWords.png")
    spriteController:addPlist("public/acMonthlySign.plist")
    spriteController:addTexture("public/acMonthlySign.png")
    

    local function addPlist()
        spriteController:addPlist("public/wsjdzzImage.plist")
        spriteController:addTexture("public/wsjdzzImage.png")
        spriteController:addPlist("public/acRadar_images.plist")
        spriteController:addTexture("public/acRadar_images.png")
    end
    G_addResource8888(addPlist)

    return nc
end

function acOpenyearDialog:resetTab( )
    -- resetTab 这个方法最先执行，跨天刷数据，防止首次打开板子，创建后再刷新
    local vo=acOpenyearVoApi:getAcVo()
    if not G_isToday(vo.lastTime) then
        acOpenyearVoApi:refreshClear()
    end

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

function acOpenyearDialog:tabClick(idx,isEffect)
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
function acOpenyearDialog:getDataByType(type)
    if(type==nil)then
      type=1
    end 
    if type==1 then
        if self.layerTab1 ==nil then
            self.acTab1=acOpenyearTab1:new(self.layerNum)
            self.layerTab1=self.acTab1:init()
            self.bgLayer:addChild(self.layerTab1,1);
        else
            self.acTab1:refresh()
        end
        self.layerTab1:setVisible(true)
        self.layerTab1:setPosition(ccp(0,0))
        
        if self.layerTab2 then
            self.layerTab2:setVisible(false)
            self.layerTab2:setPosition(ccp(99930,0))
        end
        if self.layerTab3~=nil then
            self.layerTab3:setVisible(false)
            self.layerTab3:setPosition(ccp(99930,0))
        end
    elseif type==2 then

        if self.layerTab2 ==nil then
            self.acTab2=acOpenyearTab2:new(self.layerNum)
            self.layerTab2=self.acTab2:init()
            self.bgLayer:addChild(self.layerTab2,1);
        end
        self.layerTab2:setVisible(true)
        self.layerTab2:setPosition(ccp(0,0))

        if self.layerTab1 then
            self.layerTab1:setVisible(false)
            self.layerTab1:setPosition(ccp(10000,0))
        end

        if self.layerTab3~=nil then
            self.layerTab3:setVisible(false)
            self.layerTab3:setPosition(ccp(99930,0))
        end    
    elseif type==3 then
        if self.layerTab3 ==nil then
            self.acTab3=acOpenyearTab3:new(self.layerNum)
            self.layerTab3=self.acTab3:init()
            self.bgLayer:addChild(self.layerTab3,1)
        end
        self.layerTab3:setVisible(true)
        self.layerTab3:setPosition(ccp(0,0))

        if self.layerTab1 then
            self.layerTab1:setVisible(false)
            self.layerTab1:setPosition(ccp(10000,0))
        end

        if self.layerTab2 then
            self.layerTab2:setVisible(false)
            self.layerTab2:setPosition(ccp(99930,0))
        end
        
    end
end



function acOpenyearDialog:initTableView()
    local function callback( ... )
    end
    local hd= LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-65-120),nil)

    self:tabClick(0,false)

    -- 蓝底背景
    local function addBlueBg()
        local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
        blueBg:setAnchorPoint(ccp(0.5,0))
        blueBg:setScaleX(600/blueBg:getContentSize().width)
        blueBg:setScaleY((G_VisibleSizeHeight-180)/blueBg:getContentSize().height)
        blueBg:setPosition(G_VisibleSizeWidth/2,20)
        blueBg:setOpacity(200)
        self.bgLayer:addChild(blueBg)
    end
    G_addResource8888(addBlueBg)
 

    -- 三个页签都要用，写到总板子中
    local pos=ccp(self.bgLayer:getContentSize().width-80,self.bgLayer:getContentSize().height-210)
    local tabStr={" ",getlocal("activity_openyear_tip5"),getlocal("activity_openyear_tip4"),getlocal("activity_openyear_tip3"),getlocal("activity_openyear_tip2"),getlocal("activity_openyear_tip1")," "}
    -- local _isNewBtn=false
    -- if acOpenyearVoApi:getAcShowType()==acOpenyearVoApi.acShowType.TYPE_2 then
        _isNewBtn=true
    -- end
    G_addMenuInfo(self.bgLayer,self.layerNum,pos,tabStr,nil,nil,nil,nil,_isNewBtn)

    -- 烟花
    local fireH=self.bgLayer:getContentSize().height-300
    local fireW=150
    for i=1,2 do
        local fireSp=CCSprite:createWithSpriteFrameName("openyear_fire.png")
        self.bgLayer:addChild(fireSp)
        local widht=fireW
        if i==2 then
            widht=G_VisibleSizeWidth-fireW
        else
            fireSp:setFlipX(true)
        end
        fireSp:setPosition(widht,fireH)
    end



end

function acOpenyearDialog:tick()
    local vo=acOpenyearVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end

    self:refresh()

    self:setIconTipVisibleByIdx(acOpenyearVoApi:checkTab2Tip(),2)
    self:setIconTipVisibleByIdx(acOpenyearVoApi:checkTab3Tip(),3)
end

function acOpenyearDialog:refresh()
    local vo=acOpenyearVoApi:getAcVo()
    if not G_isToday(vo.lastTime) then
        acOpenyearVoApi:refreshClear()
        if self.acTab1 then
            self.acTab1:refresh()
        end
        if self.acTab2 then
            self.acTab2:refresh()
        end
        if self.acTab3 then
            self.acTab3:refresh()
        end
    end
end

function acOpenyearDialog:update()

end

function acOpenyearDialog:dispose()
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
    
    spriteController:removePlist("public/acRadar_images.plist")
    spriteController:removeTexture("public/acRadar_images.png")
    spriteController:removePlist("public/acChunjiepansheng.plist")
    spriteController:removeTexture("public/acChunjiepansheng.png")
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
    spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
    spriteController:removePlist("public/acBlessWords.plist")
    spriteController:removeTexture("public/acBlessWords.png")
    spriteController:removePlist("public/acMonthlySign.plist")
    spriteController:removeTexture("public/acMonthlySign.png")
    spriteController:removePlist("public/wsjdzzImage.plist")
    spriteController:removeTexture("public/wsjdzzImage.png")
end