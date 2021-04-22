

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMagicHerbExchange = class("QUIWidgetMagicHerbExchange", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetMagicHerbBox = import("..widgets.QUIWidgetMagicHerbBox")

QUIWidgetMagicHerbExchange.EVENT_QUICK_EXCHANGE = "EVENT_QUICK_EXCHANGE_MAGIC_HERB"



function QUIWidgetMagicHerbExchange:ctor(options)
	local ccbFile = "ccb/Widget_MagicHerb_Exchange.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerExchange", callback = handler(self, self._onTriggerExchange)},
    }
    QUIWidgetMagicHerbExchange.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._magicHerbBoxs = {}
	self._head = nil 
end

function QUIWidgetMagicHerbExchange:onEnter()
end

function QUIWidgetMagicHerbExchange:onExit()
end

function QUIWidgetMagicHerbExchange:initGLLayer()
	self._glLayerIndex = glLayerIndex or 1

	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_bg, self._glLayerIndex)

	local index = 0
    for i = 1, 3 do
		if self._magicHerbBoxs[i] ~= nil then
			index = self._magicHerbBoxs[i]:initGLLayer(self._glLayerIndex)
		end
	end
	self._glLayerIndex = index

	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp9_gemstone_select, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp9_spar_select, self._glLayerIndex)

	if self._head then
		self._glLayerIndex = self._head:initGLLayer(self._glLayerIndex)
	end

	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_name, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_select_bg_2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_exchange, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_btn_exchange, self._glLayerIndex)
end

function QUIWidgetMagicHerbExchange:setInfo(info)

	self._info = info
	self._heroInfo = info.heroInfo 
	self._heroConfig = db:getCharacterByID(self._heroInfo.actorId)
	self._heroUIModel = remote.herosUtil:getUIHeroByID(self._heroInfo.actorId)


	if not self._head then
		self._head = QUIWidgetHeroHead.new()
		self._ccbOwner.node_head:addChild(self._head)
	end
	self._head:setHeroInfo(self._heroInfo)	
	self._ccbOwner.tf_name:setString(string.format("LV.%s %s", self._heroInfo.level, self._heroConfig.name or ""))

    for i = 1, 3 do
		if self._magicHerbBoxs[i] == nil then
		    self._magicHerbBoxs[i] = QUIWidgetMagicHerbBox.new({pos = i})
		    self._magicHerbBoxs[i]:setScale(0.9)
		    self._ccbOwner["node_magicHerb_"..i]:addChild(self._magicHerbBoxs[i])
		end
		self._magicHerbBoxs[i]:setHeroId(self._heroInfo.actorId)
		local magicHerbWearedInfo = self._heroUIModel:getMagicHerbWearedInfoByPos(i)
        if magicHerbWearedInfo and magicHerbWearedInfo.sid then
            self._magicHerbBoxs[i]:setInfo(magicHerbWearedInfo.sid)
            self._magicHerbBoxs[i]:hideName()
        else
            self._magicHerbBoxs[i]:setInfo()
            self._magicHerbBoxs[i]:hideName()
        end		
		self._magicHerbBoxs[i]:hideSabc()


	end


    self:initGLLayer()

end

function QUIWidgetMagicHerbExchange:getContentSize()
	return self._ccbOwner.cellSize:getContentSize()
end


function QUIWidgetMagicHerbExchange:_onTriggerExchange()
	self:dispatchEvent({name = QUIWidgetMagicHerbExchange.EVENT_QUICK_EXCHANGE, info = self._info, heroInfo = self._heroInfo})
end

return QUIWidgetMagicHerbExchange