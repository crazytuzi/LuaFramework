exerWarDialog = commonDialog:new()

function exerWarDialog:new(layerNum)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    self.curShowDialog = nil
    return nc
end

function exerWarDialog:initTableView()
    self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    self.panelTopLine:setVisible(true)
    self.topShadeBg:setVisible(false)
    self.panelTopLine:setPositionY(G_VisibleSizeHeight - 80)
    self.panelShadeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    if self.panelBottomLine then
        self.panelBottomLine:setVisible(false)
    end
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/exerwar_images.plist")
    spriteController:addTexture("public/exerwar_images.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    self:initBottom()
end

function exerWarDialog:initBottom()
    local bottomBg = LuaCCScale9Sprite:createWithSpriteFrameName("exerwar_bkuang.png", CCRect(18, 25, 2, 2), function ()end)
    bottomBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, bottomBg:getContentSize().height))
    bottomBg:setAnchorPoint(ccp(0.5, 0))
    bottomBg:setPosition(G_VisibleSizeWidth / 2, 0)
    self.bgLayer:addChild(bottomBg, 2)
    
    local menuCfg = {
        {   --演习页面
            name = getlocal("exerwar_title"),
            menuPic = "exer_warBtn.png", menuPicFocus = "exer_warBtnDown.png",
            createDialog = function()
                require "luascript/script/game/scene/gamedialog/exerwar/exerManeuverDialog"
                return exerManeuverDialog:new(self.layerNum)
            end,
        },
        {   --排名页面
            name = getlocal("exerwar_title3"),
            menuPic = "exer_rankBtn.png", menuPicFocus = "exer_rankBtnDown.png",
            createDialog = function()
                exerWarVoApi:setRedPointStatus()
                require "luascript/script/game/scene/gamedialog/exerwar/exerWarRankDialog"
                return exerWarRankDialog:new(self.layerNum)
            end
        },
        {   --商店页面
            name = getlocal("serverwar_shop"),
            menuPic = "exer_shopBtn.png", menuPicFocus = "exer_shopBtnDown.png",
            createDialog = function()
                require "luascript/script/game/scene/gamedialog/exerwar/exerShopDialog"
                return exerShopDialog:new(self.layerNum)
            end,
        },
        {   --帮助页面
            name = getlocal("exerwar_title5"),
            menuPic = "exer_helpBtn.png", menuPicFocus = "exer_helpBtnDown.png",
            createDialog = function()
                require "luascript/script/game/scene/gamedialog/exerwar/exerHelpDialog"
                return exerHelpDialog:new(self.layerNum)
            end,
        },
        {   --切磋页面（敬请期待 二期工作）
            name = getlocal("exerwar_title2"),
            menuPic = "exer_qiecBtn.png", menuPicFocus = "exer_qiecBtnDown.png",
        },
    }

    self.menuItemTb = {}
    local function switchTab(index)
        if type(menuCfg[index].createDialog) ~= "function" then
            G_showTipsDialog(menuCfg[index].name .. getlocal("exerwar_functionText") .. getlocal("alliance_notOpen"))
            do return end
        end
        if self.curShowDialog and self.curShowDialog.showDia and type(self.curShowDialog.showDia.isCanClose) == "function" and self.curShowDialog.showDia:isCanClose() == false then
            smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), function()
                self.curShowDialog.showDia.closeFlag = nil
                switchTab(index)
            end, getlocal("dialog_title_prompt"), getlocal("exerwar_troopsChangeTipsText"), nil, self.layerNum + 1, nil, nil, function()end)
            do return end
        end
        for k, v in pairs(self.menuItemTb) do
            if v:getTag() == index then
                v:setEnabled(false)
            else
                v:setEnabled(true)
            end
        end
        if self.curShowDialog then
            if tolua.cast(self.curShowDialog.bgLayer, "CCLayer") then
                self.curShowDialog.bgLayer:removeFromParentAndCleanup(true)
                self.curShowDialog.bgLayer = nil
            end
            if self.curShowDialog.dispose then
                self.curShowDialog:dispose()
            end
            self.curShowDialog = nil
        end
        self.curShowDialog = menuCfg[index].createDialog()
        if self.curShowDialog then
            if self.curShowDialog.initTableView then
                self.curShowDialog:initTableView()
            end
            if self.curShowDialog.bgLayer then
                self.bgLayer:addChild(self.curShowDialog.bgLayer)
            end
        end
        local titleLb = tolua.cast(self.titleLabel, "CCLabelTTF")
        if titleLb then
            titleLb:setString(menuCfg[index].name)
        end
    end
    local menu = CCMenu:create()
    for k, v in pairs(menuCfg) do
        local tabItem = CCMenuItemImage:create(v.menuPic, v.menuPicFocus, v.menuPicFocus)
        tabItem:setAnchorPoint(ccp(0.5, 0.5))
        tabItem:setPosition(8 + tabItem:getContentSize().width / 2 + (k - 1) * tabItem:getContentSize().width, bottomBg:getContentSize().height / 2)
        menu:addChild(tabItem)
        tabItem:setTag(k)
        tabItem:registerScriptTapHandler(function(...)
                PlayEffect(audioCfg.mouseClick)
                return switchTab(...)
        end)
        self.menuItemTb[k] = tabItem
    end
    menu:setPosition(0, 0)
    menu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    bottomBg:addChild(menu)
    local peroid, status = exerWarVoApi:getWarPeroid()
    if peroid >= 7 and status >= 40 then
        peroid = 8
        switchTab(3)
    else
        switchTab(1)
    end
    if peroid ~= 5 then
        exerWarVoApi:setRedPointStatus()
    end
end

function exerWarDialog:tick()
    local warSt, warEt = exerWarVoApi:getWarTime()
    if warEt and base.serverTime > warEt then
        self:close()
        G_closeAllSmallDialog()
        do return end
    end
    if self.curShowDialog then
        if self.curShowDialog.tick then
            self.curShowDialog:tick()
        end
    end
    if self.menuItemTb and self.menuItemTb[2] then
        local tipsIcon = tolua.cast(self.menuItemTb[2]:getChildByTag(-100), "CCSprite")
        local flag, peroid = exerWarVoApi:isShowRedPoint()
        if tipsIcon == nil and flag == true and peroid == 5 then
            tipsIcon = CCSprite:createWithSpriteFrameName("IconTip.png")
            tipsIcon:setAnchorPoint(ccp(1, 1))
            tipsIcon:setPosition(self.menuItemTb[2]:getContentSize().width, self.menuItemTb[2]:getContentSize().height)
            tipsIcon:setTag(-100)
            self.menuItemTb[2]:addChild(tipsIcon)
        end
        if tipsIcon and ((flag == false and peroid == 5) or (peroid > 5)) then
            tipsIcon:removeFromParentAndCleanup(true)
            tipsIcon = nil
        end
    end
end

function exerWarDialog:checkCloseHandler()
    if self.curShowDialog and self.curShowDialog.showDia and type(self.curShowDialog.showDia.isCanClose) == "function" and self.curShowDialog.showDia:isCanClose() == false then
        smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), function()
            self.curShowDialog.showDia.closeFlag = nil
            self:checkCloseHandler()
        end, getlocal("dialog_title_prompt"), getlocal("exerwar_troopsChangeTipsText"), nil, self.layerNum + 1, nil, nil, function()end)
        do return end
    end
    self:close()
end

function exerWarDialog:dispose()
    if self.curShowDialog then
        if self.curShowDialog.dispose then
            self.curShowDialog:dispose()
        end
        self.curShowDialog = nil
    end
    self = nil
    spriteController:removePlist("public/exerwar_images.plist")
    spriteController:removeTexture("public/exerwar_images.png")
end
