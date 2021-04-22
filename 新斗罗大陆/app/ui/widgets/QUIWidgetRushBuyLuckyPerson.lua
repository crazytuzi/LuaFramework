--[[	
	文件名称：QUIWidgetRushBuyLuckyPerson.lua
	创建时间：2017-02-15 11:31:57
	作者：nieming
	描述：QUIWidgetRushBuyLuckyPerson
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetRushBuyLuckyPerson = class("QUIWidgetRushBuyLuckyPerson", QUIWidget)
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
--初始化
function QUIWidgetRushBuyLuckyPerson:ctor(options)
	local ccbFile = "Widget_SixYuan_list.ccbi"
	local callBacks = {
	}
	QUIWidgetRushBuyLuckyPerson.super.ctor(self,ccbFile,callBacks,options)

end

function QUIWidgetRushBuyLuckyPerson:setInfo(info)
	local imp = remote.activityRounds:getRushBuy()
	if not imp then
		return
	end
	local curData = {}
	local goodInfo = imp:getGoodInfo()
	for k ,v in pairs(goodInfo) do
		if info.roundId == v.roundId then
			curData = v
			break;
		end
	end
	
	self._ccbOwner.issue:setString(info.issue)
	self._ccbOwner.time:setString(q.timeToMonthDayHourMin(info.luckyAt/1000))

	self._ccbOwner.buyCount:setString(info.myBuyCount)

	self._ccbOwner.nickName:setString(info.fighter.name or "")
	self._ccbOwner.level:setString(string.format("LV.%d",info.fighter.level or 1))
	self._ccbOwner.area:setString(info.fighter.game_area_name or "")
	self._ccbOwner.vip:setString("VIP "..info.fighter.vip)

	if not self._avatar then
		self._avatar = QUIWidgetAvatar.new(info.fighter.avatar)
		self._avatar:setSilvesArenaPeak(info.fighter.championCount)
	    self._ccbOwner.node_headPicture:addChild(self._avatar)
	else
		self._avatar:setInfo(info.fighter.avatar)
		self._avatar:setSilvesArenaPeak(info.fighter.championCount)
	end


	if not self._itembox then
		self._itembox = QUIWidgetItemsBox.new()
		self._ccbOwner.item:addChild(self._itembox)
	end
	self._itembox:setGoodsInfoByID(curData.item, curData.num)

	self:setSoulTrial(info.fighter.soulTrial)
	self:autoLayout()
end

function QUIWidgetRushBuyLuckyPerson:setSoulTrial(soulTrial)
	local sp = self._ccbOwner.sp_soulTrial
	if not sp then return end

	local _, frame = remote.soulTrial:getSoulTrialTitleSpAndFrame(soulTrial)
	
    if frame then
        sp:setDisplayFrame(frame)
        sp:setVisible(true)
    else
        sp:setVisible(false)
    end
end

function QUIWidgetRushBuyLuckyPerson:autoLayout()
	local nodes = {}
	table.insert(nodes, self._ccbOwner.sp_soulTrial)
	table.insert(nodes, self._ccbOwner.level)
	table.insert(nodes, self._ccbOwner.nickName)
	q.autoLayerNode(nodes, "x", 5)
end

function QUIWidgetRushBuyLuckyPerson:getContentSize()
	return self._ccbOwner.cellsize:getContentSize()
end

return QUIWidgetRushBuyLuckyPerson
