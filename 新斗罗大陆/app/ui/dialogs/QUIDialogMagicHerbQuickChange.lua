

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMagicHerbQuickChange = class("QUIDialogMagicHerbQuickChange", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView") 
local QUIWidgetMagicHerbBox = import("..widgets.QUIWidgetMagicHerbBox")
local QUIWidgetMagicHerbExchange = import("..widgets.QUIWidgetMagicHerbExchange")




function QUIDialogMagicHerbQuickChange:ctor(options)
	local ccbFile = "ccb/Dialog_MagicHerb_exchange.ccbi" 
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogMagicHerbQuickChange.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._actorId = options.actorId
    	self._callBack = options.callBack
    end

    self._ccbOwner.frame_btn_close:setVisible(false)
    q.setButtonEnableShadow(self._ccbOwner.frame_btn_close_upper)
	self._isShowEffect = 0
	self._data = {}
	self._magicHerbBoxs = {}
end

function QUIDialogMagicHerbQuickChange:viewDidAppear()
	QUIDialogMagicHerbQuickChange.super.viewDidAppear(self)

	self:setInfo()
	self:handleData()
	self:initListView()

end

function QUIDialogMagicHerbQuickChange:viewAnimationInHandler()
	QUIDialogMagicHerbQuickChange.super.viewDidAppear(self)
	self:initListView()
end

function QUIDialogMagicHerbQuickChange:viewWillDisappear()
  	QUIDialogMagicHerbQuickChange.super.viewWillDisappear(self)
end

function QUIDialogMagicHerbQuickChange:handleData()
	self._data = {}
	local heroIds = remote.herosUtil:getHaveHero()
	for _, actorId in pairs(heroIds) do
		if actorId ~= self._actorId then
			local heroInfo = remote.herosUtil:getHeroByID(actorId)
			-- QPrintTable(heroInfo)
			if heroInfo.magicHerbs then
				table.insert(self._data, {heroInfo = heroInfo})
			end
		end
	end
end

function QUIDialogMagicHerbQuickChange:setInfo()
	local uiHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
    for i = 1, 3 do
		if self._magicHerbBoxs[i] == nil then
		    self._magicHerbBoxs[i] = QUIWidgetMagicHerbBox.new({pos = i})
		    self._magicHerbBoxs[i]:setScale(0.9)
		    self._ccbOwner["node_magicherb_"..i]:addChild(self._magicHerbBoxs[i])
		end
		self._magicHerbBoxs[i]:setHeroId(self._actorId)
		local magicHerbWearedInfo = uiHeroModel:getMagicHerbWearedInfoByPos(i)
        if magicHerbWearedInfo and magicHerbWearedInfo.sid then
            self._magicHerbBoxs[i]:setInfo(magicHerbWearedInfo.sid)
            self._magicHerbBoxs[i]:hideName()

        else
            self._magicHerbBoxs[i]:setInfo()
            self._magicHerbBoxs[i]:hideName()
        end		
	end
end


function QUIDialogMagicHerbQuickChange:initListView()

    local totalNumber = #self._data
    if not self._listView then
        local cfg = {
            renderItemCallBack = handler(self, self._renderItemCallBack),
            enableShadow = false,
            ignoreCanDrag = true,
            curOriginOffset = 3,
            curOffset = 5,
            contentOffsetX = 6,
            spaceY = 0,
            totalNumber = totalNumber,
        }
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:resetTouchRect()
        self._listView:reload({totalNumber = totalNumber})
    end
end

function QUIDialogMagicHerbQuickChange:_renderItemCallBack(list, index, info )
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache(self._selectTab)
    if not item then
        isCacheNode = false
		item = QUIWidgetMagicHerbExchange.new()
		item:addEventListener(QUIWidgetMagicHerbExchange.EVENT_QUICK_EXCHANGE, handler(self, self._onClickEvent))
    end

    item:setInfo(itemData)
    info.item = item
    info.size = item:getContentSize()
    info.tag = self._selectTab
	list:registerBtnHandler(index,"btn_exchange", "_onTriggerExchange", nil, true)

    return isCacheNode
end

function QUIDialogMagicHerbQuickChange:_onClickEvent(event)
	local heroInfo = event.heroInfo or {}
	-- QPrintTable(heroInfo)

    remote.magicHerb:magicHerbExchangeRequest( self._actorId , heroInfo.actorId, function()
            if self:safeCheck() then
                app.tip:floatTip("仙品一键交换成功")
                self:_onTriggerClose()
            end
        end)
end


function QUIDialogMagicHerbQuickChange:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMagicHerbQuickChange:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMagicHerbQuickChange:viewAnimationOutHandler()
	local callback = self._callBack
	local isShowEffect = self._isShowEffect

	self:popSelf()

	if isShowEffect > 0 and callback then
		callback(isShowEffect)
	end
end


return QUIDialogMagicHerbQuickChange