--
-- Author: Your Name
-- Date: 2014-10-21 18:30:20
--
local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogTipsInfo = class("QUIDialogTipsInfo", QUIDialog)
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetHeroPrompt = import("..widgets.QUIWidgetHeroPrompt")
local QUIWidgetCurrencyPrompt = import("..widgets.QUIWidgetCurrencyPrompt")
local QUIWidgetChipPrompt = import("..widgets.QUIWidgetChipPrompt")
local QUIWidgetItmePrompt = import("..widgets.QUIWidgetItmePrompt")
local QUIWidgetGemstonePrompt = import("..widgets.QUIWidgetGemstonePrompt")
local QUIWidgetGemstonePiecePrompt = import("..widgets.QUIWidgetGemstonePiecePrompt")
local QUIWidgetMountPrompt = import("..widgets.mount.QUIWidgetMountPrompt")
local QUIWidgetSparPrompt = import("..widgets.spar.QUIWidgetSparPrompt")
local QUIWidgetSoulSpritePrompt = import("..widgets.QUIWidgetSoulSpritePrompt")
local QUIWidgetWordsPrompt = import("..widgets.QUIWidgetWordsPrompt")

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogTipsInfo:ctor(options)
  	local ccbFile = nil
  	local callbacks = {}
  	QUIDialogTipsInfo.super.ctor(self, ccbFile, callbacks, options)
  	
  	local words = options.words
  	if words ~= nil then	--有文字传入直接显示文字的信息
  		self.prompt = QUIWidgetWordsPrompt.new({words = words})
		self:getView():addChild(self.prompt)
  		return
  	end

  	local itemType = options.itemType
  	local itemId = options.itemId
	local itemConfig = nil
	if itemType ~= ITEM_TYPE.HERO and itemId ~= nil then
		itemConfig = QStaticDatabase:sharedDatabase():getItemByID(itemId)
	end

  	if itemType == ITEM_TYPE.HERO or (itemConfig and itemConfig.type == ITEM_CONFIG_TYPE.SOUL) then
		if self.prompt == nil then
			self.prompt = QUIWidgetHeroPrompt.new({itemId = itemId, itemType = itemType})
			self:getView():addChild(self.prompt)
		end
	elseif itemType == ITEM_TYPE.VIP or itemType == ITEM_TYPE.ENERGY or itemType == ITEM_TYPE.TEAM_EXP or itemType == ITEM_TYPE.ACHIEVE_POINT or remote.items:getWalletByType(itemType) then
		if self.prompt == nil then
			self.prompt = QUIWidgetCurrencyPrompt.new({type = itemType})
			self:getView():addChild(self.prompt)
		end
  	elseif itemType == ITEM_TYPE.GEMSTONE then
  		self.prompt = QUIWidgetGemstonePrompt.new({gemstronSid = options.gemstronSid or itemId})
		self:getView():addChild(self.prompt)
  	elseif itemType == ITEM_TYPE.GEMSTONE_PIECE then
  		self.prompt = QUIWidgetGemstonePiecePrompt.new({itemId = itemId})
		self:getView():addChild(self.prompt)
  	elseif itemType == ITEM_TYPE.ZUOQI or itemConfig.type == 21 then
  		self.prompt = QUIWidgetMountPrompt.new({itemId = itemId, itemType = itemType})
		self:getView():addChild(self.prompt)
  	elseif itemType == ITEM_TYPE.SPAR or itemType == ITEM_TYPE.SPAR_PIECE then
  		self.prompt = QUIWidgetSparPrompt.new({itemId = itemId, itemType = itemType, sparInfo = options.sparInfo})
		self:getView():addChild(self.prompt)
	elseif itemConfig.type == ITEM_CONFIG_TYPE.SOULSPIRIT_PIECE then  --魂灵碎片介绍
		self.prompt = QUIWidgetSoulSpritePrompt.new({itemId = itemId,itemType = itemType})
		self:getView():addChild(self.prompt)
	else
		if itemConfig == nil then return end
		if self.prompt == nil then
			self.prompt = QUIWidgetItmePrompt.new({itemConfig = itemConfig, boxSize = size, scaleX = scaleX, scaleY = scaleY})
			self:getView():addChild(self.prompt)
		end
	end
end

function QUIDialogTipsInfo:viewDidAppear()
	QUIDialogTipsInfo.super.viewDidAppear(self)
end

function QUIDialogTipsInfo:viewWillDisappear()
	QUIDialogTipsInfo.super.viewWillDisappear(self)
end

function QUIDialogTipsInfo:_backClickHandler()
	self:popSelf()
end

return QUIDialogTipsInfo
