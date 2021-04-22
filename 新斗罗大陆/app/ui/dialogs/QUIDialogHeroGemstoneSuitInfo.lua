--
-- Author: Qinsiyang
-- Date: 2019-10-28
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHeroGemstoneSuitInfo = class("QUIDialogHeroGemstoneSuitInfo", QUIDialog)
local QUIWidgetHeroGemstoneSuitInfo = import("..widgets.QUIWidgetHeroGemstoneSuitInfo")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QQuickWay = import("...utils.QQuickWay")
local QColorLabel = import("...utils.QColorLabel")
local QRichText = import("...utils.QRichText")

local QListView = import("...views.QListView")



function QUIDialogHeroGemstoneSuitInfo:ctor(options)
	local ccbFile = "ccb/Dialog_Baoshi_SuitInfo.ccbi"
	local callBacks = {
			{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		}
	QUIDialogHeroGemstoneSuitInfo.super.ctor(self,ccbFile,callBacks,options)

	self._gemstoneSid = options._gemstoneSid

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    q.setButtonEnableShadow(self._ccbOwner.frame_btn_close)
	self._ccbOwner.frame_tf_title:setString("魂骨套装预览")

	self:setInfo()
	self:initListView()
end


function QUIDialogHeroGemstoneSuitInfo:setSABC(node)
    local nodeOwner = {}
    local pingzhiNode = CCBuilderReaderLoad("ccb/Widget_Hero_pingzhi.ccbi", CCBProxy:create(), nodeOwner)
    node:addChild(pingzhiNode)

    q.setAptitudeShow(nodeOwner, "ss")
end

function QUIDialogHeroGemstoneSuitInfo:viewDidAppear()
    QUIDialogHeroGemstoneSuitInfo.super.viewDidAppear(self)
end

function QUIDialogHeroGemstoneSuitInfo:viewWillDisappear()
    QUIDialogHeroGemstoneSuitInfo.super.viewWillDisappear(self)
end


function QUIDialogHeroGemstoneSuitInfo:initListView()
	if self._listViewLayout then
		self._listViewLayout:setContentSize(self._ccbOwner.sheet_layout:getContentSize())
		self._listViewLayout:resetTouchRect()
	end
	
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = handler(self, self._renderCallBack),
	        curOriginOffset = 0,
	        contentOffsetX = 0,
	        curOffset = 0,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	      	spaceY = 10,
	      	spaceX = 0,
	      	isVertical = true,
	        totalNumber = #self._items,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listViewLayout:reload({totalNumber = #self._items})
	end
end

function QUIDialogHeroGemstoneSuitInfo:_renderCallBack(list, index, info )
    local isCacheNode = true
    local itemData = self._items[index]
    local item = list:getItemFromCache()
    if not item then
		item = QUIWidgetHeroGemstoneSuitInfo.new()
    	isCacheNode = false
    end
    item:setInfo(itemData)
    info.item = item
    info.size = item:getContentSize()
    -- list:registerTouchHandler(index, "onTouchListView")
    return isCacheNode
end


function QUIDialogHeroGemstoneSuitInfo:setInfo()

	local gemstone = remote.gemstone:getGemstoneById(self._gemstoneSid)
	self._items = {}


	local qualityList = {APTITUDE.S,APTITUDE.SS,APTITUDE.SSR }
	local itemId = gemstone.itemId
	local itemConfig = db:getItemByID(itemId)
	local curGemstoneQuality = itemConfig.gemstone_quality


    local advancedLevel = gemstone.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST
	if curGemstoneQuality == APTITUDE.S then
		if gemstone.mix_level and gemstone.mix_level > 0 then
			curGemstoneQuality =  APTITUDE.SSR
		elseif advancedLevel >= GEMSTONE_MAXADVANCED_LEVEL then
			curGemstoneQuality =  APTITUDE.SS
		end
	end

	for i,v in ipairs(qualityList) do
		if curGemstoneQuality <= v then
			table.insert(self._items , {itemId = itemId ,curGemstoneQuality = curGemstoneQuality ,gemstoneQuality = v })
		end
	end

end

function QUIDialogHeroGemstoneSuitInfo:godGemstoneBoxClickHandler(e)
	if e ~= nil then
		app.sound:playSound("common_small")
	end

	QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, e.itemID)
end

function QUIDialogHeroGemstoneSuitInfo:_onTriggerClose(event)
	if q.buttonEventShadow(event,self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()

end

return QUIDialogHeroGemstoneSuitInfo