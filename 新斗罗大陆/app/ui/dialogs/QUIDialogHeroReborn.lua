--
-- Author: qinyuanji
-- Date: 2015-04-02 17:14:49
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHeroReborn = class("QUIDialogHeroReborn", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUnlock = import("...utils.QUnlock")
local QScrollView = import("...views.QScrollView")
local QUIWidgetGemRecycle = import("..widgets.QUIWidgetGemRecycle")
local QUIWidgetMountReborn = import("..widgets.mount.QUIWidgetMountReborn")
local QUIWidgetSparRecycle = import("..widgets.spar.QUIWidgetSparRecycle")
local QUIWidgetGodarmReborn = import("..widgets.QUIWidgetGodarmReborn")

QUIDialogHeroReborn.GAP = 71

function QUIDialogHeroReborn:ctor(options)
	local ccbFile = "ccb/Dialog_HeroRecover.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerTabMaterial", callback = handler(self, self.onTriggerTabMaterial)},
		{ccbCallbackName = "onTriggerTabFragment", callback = handler(self, self.onTriggerTabFragment)},
		{ccbCallbackName = "onTriggerTabRecycle", callback = handler(self, self.onTriggerTabRecycle)},
        {ccbCallbackName = "onTriggerTabReborn", callback = handler(self, self.onTriggerTabReborn)},
        {ccbCallbackName = "onTriggerTabEnchant", callback = handler(self, self.onTriggerTabEnchant)},
        {ccbCallbackName = "onTriggerGemFragment", callback = handler(self, self.onTriggerGemFragment)},
        {ccbCallbackName = "onTriggerGemRecycle", callback = handler(self, self.onTriggerGemRecycle)},
        {ccbCallbackName = "onTriggerGemReborn", callback = handler(self, self.onTriggerGemReborn)},
        {ccbCallbackName = "onTriggerMountReborn", callback = handler(self, self.onTriggerMountReborn)},
        {ccbCallbackName = "onTriggerMountRecycle", callback = handler(self, self.onTriggerMountRecycle)},
        {ccbCallbackName = "onTriggerMountFragment", callback = handler(self, self.onTriggerMountFragment)}, 
        {ccbCallbackName = "onTriggerSparRecycle", callback = handler(self, self.onTriggerSparRecycle)}, 
        {ccbCallbackName = "onTriggerSparPieceRecycle", callback = handler(self, self.onTriggerSparPieceRecycle)},
        {ccbCallbackName = "onTriggerSparReborn", callback = handler(self, self.onTriggerSparReborn)}, 
        {ccbCallbackName = "onTriggerMagicHerbPiece", callback = handler(self, self.onTriggerMagicHerbPiece)}, 
        {ccbCallbackName = "onTriggerMagicHerbReborn", callback = handler(self, self.onTriggerMagicHerbReborn)}, 
        {ccbCallbackName = "onTriggerArtifactRecycle", callback = handler(self, self.onTriggerArtifactRecycle)}, 
        {ccbCallbackName = "onTriggerSoulSpiritPiece", callback = handler(self, self.onTriggerSoulSpiritPiece)}, 
        {ccbCallbackName = "onTriggerSoulSpiritReborn", callback = handler(self, self.onTriggerSoulSpiritReborn)}, 
        {ccbCallbackName = "onTriggerSoulSpiritFragment", callback = handler(self, self.onTriggerSoulSpiritFragment)}, 
        {ccbCallbackName = "onTriggerGodarmFragment", callback = handler(self, self.onTriggerGodarmFragment)}, 
        {ccbCallbackName = "onTriggerGodarmRecly", callback = handler(self, self.onTriggerGodarmRecly)}, 
        {ccbCallbackName = "onTriggerGodarmReborn", callback = handler(self, self.onTriggerGodarmReborn)}, 
        {ccbCallbackName = "onTriggerAwakeningRebirth", callback = handler(self, self.onTriggerAwakeningRebirth)}, 
	}

    QUIDialogHeroReborn.super.ctor(self,ccbFile,callBacks,options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page.topBar:showWithHeroReborn()

    self._outerOptions = options

    self._width = self._ccbOwner.sheet_layout:getContentSize().width
    self._height = self._ccbOwner.sheet_layout:getContentSize().height
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._width, self._height), {sensitiveDistance = 10})

    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self.onScrollViewMoving))
    -- self._scrollView:addEventListener(QScrollView.FREEZE, handler(self, self.onScrollViewFreeze))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self.onScrollViewBegan))

    self._ccbOwner.navNode:removeFromParent()
    self._scrollView:addItemBox(self._ccbOwner.navNode)
    self._ccbOwner.navNode:setPosition(7, 0)
    self._ccbOwner.frame_tf_title:setString("重生和分解")

    local tabType = {
        {id = "reborn", class = "QUIWidgetHeroReborn", ccb = "tab_reborn", button = "tab_reborn", bg = "reborn_bg", options = {type = 1}},
        {id = "awakeningRebirth", class = "QUIWidgetAwakeningRebirth", ccb = "tab_awakeningRebirth", button = "tab_awakeningRebirth", bg = "material_bg", topBar = "showWithEnchantOrient"},
        {id = "gemReborn", class = "QUIWidgetGemRecycle", ccb = "tab_gemReborn", button = "tab_gemReborn", bg = "reborn_bg", options = {type = 2}, unlock = "UNLOCK_GEMSTONE", topBar = "showWithGem"},
        {id = "mountReborn", class = "mount.QUIWidgetMountReborn", ccb = "tab_mountReborn", button = "tab_mountReborn", bg = "reborn_bg", options = {type = 4}, unlock = "UNLOCK_ZUOQI", topBar = "showWithMountReborn"},
        {id = "sparReborn", class = "spar.QUIWidgetSparRecycle", ccb = "tab_sparReborn", button = "tab_sparReborn", bg = "reborn_bg", options = {type = 2}, unlock = "UNLOCK_ZHUBAO", topBar = "showWithSparPieceRecycle"},
        {id = "magicHerbReborn", class = "QUIWidgetMagicHerbReborn", ccb = "tab_magicHerbReborn", button = "tab_magicHerbReborn", bg = "reborn_bg", options = {type = 2}, unlock = "UNLOCK_MAGIC_HERB", topBar = "showWithMagicHerb"},
        {id = "soulSpiritReborn", class = "QUIWidgetSoulSpiritReborn", ccb = "tab_soulSpiritReborn", button = "tab_soulSpiritReborn", bg = "reborn_bg", options = {type = 2}, unlock = "UNLOCK_SOUL_SPIRIT", topBar = "showWithSoulSpiritFragment"},
        {id = "godarmReborn", class = "QUIWidgetGodarmReborn", ccb = "tab_godarmReborn", button = "tab_godarmReborn", bg = "reborn_bg", options = {type = 2}, unlock = "UNLOCK_GOD_ARM", topBar = "showWithGodarm"},
        
        {id = "material", class = "QUIWidgetMaterialRecycle", ccb = "tab_material", button = "tab_material", bg = "material_bg", options = {type = 1}, unlock = "UNLOCK_MATERIAL_RECYCLE"},
        {id = "fragment", class = "QUIWidgetMaterialRecycle", ccb = "tab_fragment", button = "tab_fragment", bg = "material_bg", options = {type = 3}},
        {id = "gemFragment", class = "QUIWidgetGemFragmentRecycle", ccb = "tab_gemFragment", button = "tab_gemFragment", bg = "material_bg", options = {type = 2}, unlock = "UNLOCK_GEMSTONE", topBar = "showWithGem"},
        {id = "mountFragment", class = "mount.QUIWidgetMountFragmentRecycle", ccb = "tab_mountFragment", button = "tab_mountFragment", bg = "material_bg", options = {type = 2}, unlock = "UNLOCK_ZUOQI", topBar = "showWithMountReborn"},
        {id = "sparPieceReborn", class = "spar.QUIWidgetSparPieceRecycle", ccb = "tab_sparPiece", button = "tab_sparPiece", bg = "material_bg", options = {type = 2}, unlock = "UNLOCK_ZHUBAO", topBar = "showWithSparPieceRecycle"},
        {id = "soulSpiritFragment", class = "QUIWidgetSoulSpiritFragment", ccb = "tab_soulSpiritFragment", button = "tab_soulSpiritFragment", bg = "material_bg", options = {type = 3}, unlock = "UNLOCK_SOUL_SPIRIT", topBar = "showWithSoulSpiritFragment"},
        {id = "godarmFragment", class = "QUIWidgetGodarmFragment", ccb = "tab_godarmPiece", button = "tab_godarmPiece", bg = "material_bg", options = {type = 3}, unlock = "UNLOCK_GOD_ARM", topBar = "showWithGodarm"},
              
        {id = "recycle", class = "QUIWidgetHeroRecycle", ccb = "tab_recycle", button = "tab_recycle", bg = "material_bg"},
        {id = "enchant", class = "QUIWidgetEnchantRecycle", ccb = "tab_enchant", button = "tab_enchant", bg = "material_bg",unlock = "UNLOCK_ENCHANT", topBar = "showWithEnchantOrient"},
        {id = "gemRecycle", class = "QUIWidgetGemRecycleNew", ccb = "tab_gemRecycle", button = "tab_gemRecycle", bg = "material_bg", options = {type = 1}, unlock = "UNLOCK_GEMSTONE", topBar = "showWithGem"},
        {id = "mountRecycle", class = "mount.QUIWidgetMountRecycle", ccb = "tab_mountRecycle", button = "tab_mountRecycle", bg = "material_bg", options = {type = 1}, unlock = "UNLOCK_ZUOQI", topBar = "showWithMountReborn"},
        {id = "artifactRecycle", class = "artifact.QUIWidgetArtifactRecycle", ccb = "tab_artifactRecycle", button = "tab_artifactRecycle", bg = "material_bg", options = {type = 1}, unlock = "UNLOCK_ARTIFACT", topBar = "showWithArtifactReborn"},
        {id = "sparRecycle", class = "spar.QUIWidgetSparRecycle", ccb = "tab_sparRecycle", button = "tab_sparRecycle", bg = "material_bg", options = {type = 1}, unlock = "UNLOCK_ZHUBAO", topBar = "showWithSparPieceRecycle"},
        {id = "magicHerbPiece", class = "QUIWidgetMagicHerbPieceNew", ccb = "tab_magicHerbPiece", button = "tab_magicHerbPiece", bg = "material_bg", options = {type = 1}, unlock = "UNLOCK_MAGIC_HERB", topBar = "showWithMagicHerb"},
        {id = "soulSpiritPiece", class = "QUIWidgetSoulSpiritPiece", ccb = "tab_soulSpiritPiece", button = "tab_soulSpiritPiece", bg = "material_bg", options = {type = 1}, unlock = "UNLOCK_SOUL_SPIRIT", topBar = "showWithSoulSpiritFragment"},
        {id = "godarmRecly", class = "QUIWidgetGodarmRecly", ccb = "tab_godarmfenjie", button = "tab_godarmfenjie", bg = "material_bg", options = {type = 1}, unlock = "UNLOCK_GOD_ARM", topBar = "showWithGodarm"},
    }

    self._tabType = {}
    local x = -5 
    local y = 0
    for k, v in ipairs(tabType) do
        if not v.unlock or app.unlock:checkLock(v.unlock) then
            table.insert(self._tabType, v)
            self._ccbOwner[v.ccb]:setPosition(x, y)
            y = y - QUIDialogHeroReborn.GAP
        end
        self._ccbOwner[v.ccb]:setVisible(false)
    end
    self._scrollView:setRect(0, y, 0, self._width)

    local currentTab = options.tab or "reborn"
    self._currentTab = self._tabType[1].id
    for k, v in ipairs(self._tabType) do
        if v.id == currentTab then
            self._currentTab = v.id
            break
        end
    end
    if self._currentTab == "enchant" then
        page.topBar:showWithEnchantOrient()
    end 
end


function QUIDialogHeroReborn:viewDidAppear()
    self:addBackEvent()
    
    self:update(self._currentTab)
    QUIDialogHeroReborn.super.viewDidAppear(self)

    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetGemRecycle.GEM_SELECTED, self.onGemSelected, self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetSparRecycle.SPAR_SELECTED, self.onSparSelected, self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetMountReborn.MOUNT_SELECTED, self.onMountSelected, self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetGodarmReborn.GODARM_SELECTED, self.onGodarmSelected, self)
end

function QUIDialogHeroReborn:viewWillDisappear()
	self:removeBackEvent()

    QUIDialogHeroReborn.super.viewWillDisappear(self)

    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetGemRecycle.GEM_SELECTED, self.onGemSelected, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetSparRecycle.SPAR_SELECTED, self.onSparSelected, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetMountReborn.MOUNT_SELECTED, self.onMountSelected, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetGodarmReborn.GODARM_SELECTED, self.onGodarmSelected, self)
end

function QUIDialogHeroReborn:update(id, eventType)
    if eventType ~= nil then app.sound:playSound("common_switch") end

    if self._currentTab ~= id or not self._widget then
        self._ccbOwner.center:removeAllChildren()
        for k, v in ipairs(self._tabType) do
            if v.id == id then
                local widgetClass = import(app.packageRoot .. ".ui.widgets." .. v.class)
                self._widget = widgetClass.new(v.options, self._outerOptions)
                self._ccbOwner.center:addChild(self._widget)

                if self._outerOptions then 
                    local posY = self._ccbOwner[v.ccb]:getPositionY()
                    self._scrollView:moveTo(0, -posY, false)
                end
                self._outerOptions = nil
                break
            end
        end
    end

    self:updateTab(id)
    self._currentTab = id
end

function QUIDialogHeroReborn:updateTab(id)
    self._ccbOwner.material_bg:setVisible(false)
    self._ccbOwner.reborn_bg:setVisible(false)

    for k, v in ipairs(self._tabType) do
        if v.id == id then
            self._ccbOwner[v.button]:setHighlighted(true)
            self._ccbOwner[v.bg]:setVisible(true)

            local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
            page.topBar[v.topBar or "showWithHeroReborn"](page.topBar)
        else
            self._ccbOwner[v.button]:setHighlighted(false)
        end
        self._ccbOwner[v.ccb]:setVisible(true)
    end
end

function QUIDialogHeroReborn:onTriggerTabMaterial(eventType)
    if self._widget._playing then return end

    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then  
        if self._currentTab == "material" then 
            self._ccbOwner.tab_material:setHighlighted(true)
        end
    else    
        self:update("material", eventType)
        self._options.tab = "material"
    end
end

function QUIDialogHeroReborn:onTriggerTabFragment(eventType)
    if self._widget._playing then return end

    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then         
        if self._currentTab == "fragment" then 
            self._ccbOwner.tab_fragment:setHighlighted(true)
        end
    else    
        self:update("fragment", eventType)
        self._options.tab = "fragment"
    end
end

function QUIDialogHeroReborn:onTriggerTabRecycle(eventType)
    if self._widget._playing then return end

    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then         
        if self._currentTab == "recycle" then 
            self._ccbOwner.tab_recycle:setHighlighted(true)
        end
    else    
        self:update("recycle", eventType)
        self._options.tab = "recycle"
    end
end

function QUIDialogHeroReborn:onTriggerTabReborn(eventType)
    if self._widget._playing then return end

    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then         
        if self._currentTab == "reborn" then 
            self._ccbOwner.tab_reborn:setHighlighted(true)
        end
    else    
        self:update("reborn", eventType)
        self._options.tab = "reborn"
    end
end

--觉醒分解
function QUIDialogHeroReborn:onTriggerTabEnchant(eventType )
    if self._widget._playing then return end

    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then         
        if self._currentTab == "enchant" then 
            self._ccbOwner.tab_enchant:setHighlighted(true)
        end
    else    
        self:update("enchant", eventType)
        self._options.tab = "enchant"
    end
end

function QUIDialogHeroReborn:onTriggerGemFragment(eventType)
    if self._widget._playing then return end

    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then         
        if self._currentTab == "gemFragment" then 
            self._ccbOwner.tab_gemFragment:setHighlighted(true)
        end
    else    
        self:update("gemFragment", eventType)
        self._options.tab = "gemFragment"
    end
end

function QUIDialogHeroReborn:onTriggerGemRecycle(eventType)
    if self._widget._playing then return end

    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then         
        if self._currentTab == "gemRecycle" then 
            self._ccbOwner.tab_gemRecycle:setHighlighted(true)
        end
    else    
        self:update("gemRecycle", eventType)
        self._options.tab = "gemRecycle"
    end
end

function QUIDialogHeroReborn:onTriggerGemReborn(eventType)
    if self._widget._playing then return end

    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then         
        if self._currentTab == "gemReborn" then 
            self._ccbOwner.tab_gemReborn:setHighlighted(true)
        end
    else    
        self:update("gemReborn", eventType)
        self._options.tab = "gemReborn"
    end
end

function QUIDialogHeroReborn:onTriggerMountReborn(eventType)
    if self._widget._playing then return end

    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then         
        if self._currentTab == "mountReborn" then 
            self._ccbOwner.tab_mountReborn:setHighlighted(true)
        end
    else    
        self:update("mountReborn", eventType)
        self._options.tab = "mountReborn"
    end
end

function QUIDialogHeroReborn:onTriggerMountRecycle(eventType)
    if self._widget._playing then return end

    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then         
        if self._currentTab == "mountRecycle" then 
            self._ccbOwner.tab_mountRecycle:setHighlighted(true)
        end
    else    
        self:update("mountRecycle", eventType)
        self._options.tab = "mountRecycle"
    end
end

function QUIDialogHeroReborn:onTriggerMountFragment(eventType)
    if self._widget._playing then return end

    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then         
        if self._currentTab == "mountFragment" then 
            self._ccbOwner.tab_mountFragment:setHighlighted(true)
        end
    else    
        self:update("mountFragment", eventType)
        self._options.tab = "mountFragment"
    end
end

function QUIDialogHeroReborn:onTriggerSparRecycle(eventType)
    if self._widget._playing then return end

    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then         
        if self._currentTab == "sparRecycle" then 
            self._ccbOwner.tab_sparRecycle:setHighlighted(true)
        end
    else    
        self:update("sparRecycle", eventType)
        self._options.tab = "sparRecycle"
    end
end

function QUIDialogHeroReborn:onTriggerSparPieceRecycle(eventType)
    if self._widget._playing then return end

    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then         
        if self._currentTab == "sparPieceReborn" then 
            self._ccbOwner.tab_sparPiece:setHighlighted(true)
        end
    else    
        self:update("sparPieceReborn", eventType)
        self._options.tab = "sparPieceReborn"
    end
end

function QUIDialogHeroReborn:onTriggerSparReborn(eventType)
    if self._widget._playing then return end

    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then         
        if self._currentTab == "sparReborn" then 
            self._ccbOwner.tab_sparReborn:setHighlighted(true)
        end
    else    
        self:update("sparReborn", eventType)
        self._options.tab = "sparReborn"
    end
end

function QUIDialogHeroReborn:onTriggerMagicHerbPiece(eventType)
    if self._widget._playing then return end

    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then         
        if self._currentTab == "magicHerbPiece" then 
            self._ccbOwner.tab_magicHerbPiece:setHighlighted(true)
        end
    else    
        self:update("magicHerbPiece", eventType)
        self._options.tab = "magicHerbPiece"
    end
end

function QUIDialogHeroReborn:onTriggerMagicHerbReborn(eventType)
    if self._widget._playing then return end

    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then         
        if self._currentTab == "magicHerbReborn" then 
            self._ccbOwner.tab_magicHerbReborn:setHighlighted(true)
        end
    else    
        self:update("magicHerbReborn", eventType)
        self._options.tab = "magicHerbReborn"
    end
end

function QUIDialogHeroReborn:onTriggerArtifactRecycle(eventType)
    if self._widget._playing then return end

    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then         
        if self._currentTab == "mountRecycle" then 
            self._ccbOwner.tab_artifactRecycle:setHighlighted(true)
        end
    else    
        self:update("artifactRecycle", eventType)
        self._options.tab = "artifactRecycle"
    end
end

function QUIDialogHeroReborn:onTriggerSoulSpiritPiece(eventType)
    if self._widget._playing then return end

    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then         
        if self._currentTab == "soulSpiritPiece" then 
            self._ccbOwner.tab_soulSpiritPiece:setHighlighted(true)
        end
    else    
        self:update("soulSpiritPiece", eventType)
        self._options.tab = "soulSpiritPiece"
    end
end

function QUIDialogHeroReborn:onTriggerSoulSpiritReborn(eventType)
    if self._widget._playing then return end

    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then         
        if self._currentTab == "soulSpiritReborn" then 
            self._ccbOwner.tab_soulSpiritReborn:setHighlighted(true)
        end
    else    
        self:update("soulSpiritReborn", eventType)
        self._options.tab = "soulSpiritReborn"
    end
end

function QUIDialogHeroReborn:onTriggerSoulSpiritFragment(eventType)
    if self._widget._playing then return end

    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then         
        if self._currentTab == "soulSpiritFragment" then 
            self._ccbOwner.tab_soulSpiritFragment:setHighlighted(true)
        end
    else    
        self:update("soulSpiritFragment", eventType)
        self._options.tab = "soulSpiritFragment"
    end
end

function QUIDialogHeroReborn:onTriggerGodarmFragment( eventType)
    if self._widget._playing then return end
    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then
        if self._currentTab == "godarmFragment" then 
            self._ccbOwner.tab_godarmPiece:setHighlighted(true)
        end        
    else
        self:update("godarmFragment", eventType)
        self._options.tab = "godarmFragment"        
    end
end

function QUIDialogHeroReborn:onTriggerGodarmReborn( eventType)
    if self._widget._playing then return end
    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then
        if self._currentTab == "godarmReborn" then 
            self._ccbOwner.tab_godarmReborn:setHighlighted(true)
        end        
    else
        self:update("godarmReborn", eventType)
        self._options.tab = "godarmReborn"        
    end
end

function QUIDialogHeroReborn:onTriggerAwakeningRebirth( eventType)
    if self._widget._playing then return end
    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then
        if self._currentTab == "awakeningRebirth" then 
            self._ccbOwner.tab_godarmReborn:setHighlighted(true)
        end        
    else
        self:update("awakeningRebirth", eventType)
        self._options.tab = "awakeningRebirth"        
    end
end

function QUIDialogHeroReborn:onTriggerGodarmRecly( eventType)
    if self._widget._playing then return end
    if self._isMoving == true or (eventType and tonumber(eventType) ~= CCControlEventTouchUpInside) then
        if self._currentTab == "godarmRecly" then 
            self._ccbOwner.tab_godarmfenjie:setHighlighted(true)
        end        
    else
        self:update("godarmRecly", eventType)
        self._options.tab = "godarmRecly"        
    end
end

function QUIDialogHeroReborn:onGemSelected(event)
    self._options.gemStone = event.gemstone
end

function QUIDialogHeroReborn:onMountSelected(event)
    self._options.mount = event.mount
end

function QUIDialogHeroReborn:onGodarmSelected(event)
    self._options.godarmId = event.godarmId
end

function QUIDialogHeroReborn:onSparSelected(event)
    self._options.sparInfo = event.sparInfo
end

-- scroll view event
function QUIDialogHeroReborn:onScrollViewMoving()
    self._isMoving = true
end

function QUIDialogHeroReborn:onScrollViewBegan( ... )
    self._isMoving = false
end

function QUIDialogHeroReborn:onTriggerBackHandler(tag)
	if self._widget._playing then return end
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogHeroReborn:onTriggerHomeHandler(tag)
	if self._widget._playing then return end
    
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogHeroReborn
