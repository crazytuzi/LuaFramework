local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetNightmareInstance = class("QUIWidgetNightmareInstance", QUIWidget)
local QUIWidgetNightmareInstanceLayer = import("..widgets.QUIWidgetNightmareInstanceLayer")

QUIWidgetNightmareInstance.EVENT_CLICK_CHEST = "EVENT_CLICK_CHEST"
QUIWidgetNightmareInstance.EVENT_CLICK_FIGHT = "EVENT_CLICK_FIGHT"
QUIWidgetNightmareInstance.EVENT_CLICK_RECORD = "EVENT_CLICK_RECORD"

function QUIWidgetNightmareInstance:ctor(options)
	local ccbFile = options.ccbFile
	local callbacks = {}
	QUIWidgetNightmareInstance.super.ctor(self, ccbFile, callbacks, options)

  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._infoWidget1 = QUIWidgetNightmareInstanceLayer.new()
	self._infoWidget1:addEventListener(QUIWidgetNightmareInstanceLayer.EVENT_CLICK_CHEST, handler(self, self.onLayerClickHandler))
	self._infoWidget1:addEventListener(QUIWidgetNightmareInstanceLayer.EVENT_CLICK_FIGHT, handler(self, self.onLayerClickHandler))
	self._infoWidget1:addEventListener(QUIWidgetNightmareInstanceLayer.EVENT_CLICK_RECORD, handler(self, self.onLayerClickHandler))

	self._infoWidget2 = QUIWidgetNightmareInstanceLayer.new()
	self._infoWidget2:addEventListener(QUIWidgetNightmareInstanceLayer.EVENT_CLICK_CHEST, handler(self, self.onLayerClickHandler))
	self._infoWidget2:addEventListener(QUIWidgetNightmareInstanceLayer.EVENT_CLICK_FIGHT, handler(self, self.onLayerClickHandler))
	self._infoWidget2:addEventListener(QUIWidgetNightmareInstanceLayer.EVENT_CLICK_RECORD, handler(self, self.onLayerClickHandler))

	self:addChild(self._infoWidget1)
	self:addChild(self._infoWidget2)
	self._infoWidget1:setPositionY(-330 + 70)
	self._infoWidget2:setPositionY(70)
	self._colorLayer = CCLayerGradient:create(ccc4(0, 0, 0, 0), ccc4(0, 0, 0, 255), ccp(0, 1))
	self._colorLayer:setContentSize(CCSize(1136, 660))
	self._colorLayer:setPositionY(-330)
	self._colorLayer:setPositionX(-1136/2)
	self:addChild(self._colorLayer)
	self._colorLayer:setVisible(false)
end

function QUIWidgetNightmareInstance:setInfo(info, progress, totalCount)
	self._info = info
	self._progress = progress + 1
	self._infoWidget1:resetAll()
	if self._info.layer1 ~= nil then
		self._infoWidget1:setInfo(self._info.layer1, self._progress)
	end
	self._infoWidget2:resetAll()
	if self._info.layer2 ~= nil then
		self._infoWidget2:setInfo(self._info.layer2, self._progress)
	end
	self:setScaleX(info.mirror)
	self._infoWidget1:setScaleX(info.mirror)
	self._infoWidget2:setScaleX(info.mirror)
end

function QUIWidgetNightmareInstance:onLayerClickHandler(e)
	if e.name == QUIWidgetNightmareInstanceLayer.EVENT_CLICK_CHEST then
		self:dispatchEvent({name = QUIWidgetNightmareInstance.EVENT_CLICK_CHEST, dungeonId = e.dungeonId})
	elseif e.name == QUIWidgetNightmareInstanceLayer.EVENT_CLICK_FIGHT then
		self:dispatchEvent({name = QUIWidgetNightmareInstance.EVENT_CLICK_FIGHT, dungeonId = e.dungeonId})
	elseif e.name == QUIWidgetNightmareInstanceLayer.EVENT_CLICK_RECORD then
		self:dispatchEvent({name = QUIWidgetNightmareInstance.EVENT_CLICK_RECORD, dungeonId = e.dungeonId})
	end
end

--播放自己出现的动画
function QUIWidgetNightmareInstance:avatarAnimationForSelf()
	if self._info.layer1 ~= nil then
		self._infoWidget1:avatarAnimationForSelf()
	end
	if self._info.layer2 ~= nil then
		self._infoWidget2:avatarAnimationForSelf()
	end
end

function QUIWidgetNightmareInstance:getChildWidgetByIndex(index)
	return self["_infoWidget"..index]
end

return QUIWidgetNightmareInstance