


local QBattleDialog = import(".QBattleDialog")
local QBattleDialogMetalAbyssResult = class("QBattleDialogMetalAbyssResult", QBattleDialog)
local QBattleDialogMetalAbyssFightDataRecord = import("...QBattleDialogMetalAbyssFightDataRecord")
local QUIWidgetAvatar = import("....widgets.QUIWidgetAvatar")
local QRichText = import("...utils.QRichText")
local QUIWidgetItemsBox = import("....widgets.QUIWidgetItemsBox")


function QBattleDialogMetalAbyssResult:ctor(options, owner)
	local ccbFile = "ccb/Dialog_MetalAbyss_BattleResult.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerNext", callback = handler(self, self._onTriggerNext)},
		{ccbCallbackName = "onTriggerData", callback = handler(self, self._onTriggerData)},
	}
	if owner == nil then 
		owner = {}
	end

	self:setNodeEventEnabled(true)
	QBattleDialogMetalAbyssResult.super.ctor(self,ccbFile,owner,callBacks)

    CalculateUIBgSize(self._ccbOwner.ly_bg)
	
	self._isWin = options.isWin
	self._winNum = options.winNum
	self._loseNum = options.loseNum
	local awards = options.extAward
	local difficult = options.difficult or 1
	self._callback = options.callback

    local dungeonConfig = app.battle:getDungeonConfig()
    local teamInfo = {hero = {}, enemy = {}}

	self._ccbOwner.node_title_win:setVisible(self._isWin)
	self._ccbOwner.node_title_lose:setVisible(not self._isWin)

	self._ccbOwner.firstCup:setString(self._winNum)
	self._ccbOwner.secondCup:setString(self._loseNum)	
	self._ccbOwner.team1Name:setString(dungeonConfig.team1Name or "")
	self._ccbOwner.team2Name:setString(dungeonConfig.team2Name or "")


    local head1 = QUIWidgetAvatar.new(dungeonConfig.team1Icon)
    local head2 = QUIWidgetAvatar.new(dungeonConfig.team2Icon)
	self._ccbOwner.team1Head1:addChild(head1)
	self._ccbOwner.team2Head1:addChild(head2)

	local  totalNum = #awards
	local width = 100

	for i=1,3 do
		self._ccbOwner["star"..i]:setVisible(i <= difficult)
	end

	local start = - (totalNum - 1) * width * 0.5

	for i, data in ipairs(awards or {}) do
		local itemIcon = QUIWidgetItemsBox.new()
		itemIcon:setPromptIsOpen(true)
		itemIcon:setGoodsInfo(data.id or 0 ,data.typeName ,data.count)
		itemIcon:setPositionX(start + (i - 1) * width)
		self._ccbOwner.node_rtf_score:addChild(itemIcon)
	end

  	if self._isWin then
		self._audioHandler = app.sound:playSound("battle_complete")
	else
		self._audioHandler = app.sound:playSound("battle_failed")
	end

    audio.stopBackgroundMusic()
	
	self._openTime = q.time()
end

function QBattleDialogMetalAbyssResult:onEnter()
end

function QBattleDialogMetalAbyssResult:onExit()
end

function QBattleDialogMetalAbyssResult:_onTriggerNext(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_next) == false then return end
  	app.sound:playSound("common_item")
	self:onClose()
end

function QBattleDialogMetalAbyssResult:_backClickHandler()
	if q.time() - self._openTime > 3.5 then
		self:onClose()
  	end
end

function QBattleDialogMetalAbyssResult:onClose()
	if self._callback then
		print("QBattleDialogMetalAbyssResult:onClose()")
		self._callback()
	end
	self._ccbOwner:onNext()
	audio.stopSound(self._audioHandler)
end

function QBattleDialogMetalAbyssResult:_onTriggerData(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_data) == false then return end
    app.sound:playSound("common_small")
    QBattleDialogMetalAbyssFightDataRecord.new() 
end


return QBattleDialogMetalAbyssResult