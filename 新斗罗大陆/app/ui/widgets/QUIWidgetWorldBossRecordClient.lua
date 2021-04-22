-- @Author: xurui
-- @Date:   2016-10-21 16:14:31
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-01 10:10:17
local  QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetWorldBossRecordClient = class("QUIWidgetWorldBossRecordClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QRichText = import("...utils.QRichText")


function QUIWidgetWorldBossRecordClient:ctor(options)
	local ccbFile = "ccb/Widget_Panjun_Boss_zhanbao.ccbi"
	local callBack = {}
	QUIWidgetWorldBossRecordClient.super.ctor(self, ccbFile, callBack, options)
end

function QUIWidgetWorldBossRecordClient:onEnter()
end

function QUIWidgetWorldBossRecordClient:onExit()
end

function QUIWidgetWorldBossRecordClient:setInfo(param)
	--set background
	if param.index then
		self._ccbOwner.node_background:setVisible(param.index%2 ~= 0)
	end

	self._richText1 = nil
	self._richText2 = nil
	self._ccbOwner.node_content1:removeAllChildren()
	self._ccbOwner.node_content2:removeAllChildren()
	if self._richText1 == nil then
		self._richText1 = QRichText.new(nil,500,{stringType = 1, defaultColor = COLORS.a, defaultSize = 20, fontName = global.font_name})
		self._richText1:setAnchorPoint(0,1)
		self._ccbOwner.node_content1:addChild(self._richText1)
	end
	if self._richText2 == nil then
		self._richText2 = QRichText.new(nil,500,{stringType = 1, defaultColor = COLORS.a, defaultSize = 20, fontName = global.font_name})
		self._richText2:setAnchorPoint(0,1)
		self._ccbOwner.node_content2:addChild(self._richText2)
	end

	local logInfo = param.logInfos
	local killInfo = logInfo.killParams
	local luckyInfo = string.split(logInfo.luckyParams or {}, "#")
	if luckyInfo[1] == "" or luckyInfo[1] == nil then return end
	killInfo = string.split(killInfo, ";")
	luckyInfo[1] = string.split(luckyInfo[1], ";")

	local connectWord = function(info)
			local word = ""
			for i = 1, #info do
				if word == "" then
					word = info[i]
				else
					word = word.."、"..info[i]
				end
			end
			return word
		end
	local killUser = connectWord(killInfo)
	local luckUser = connectWord(luckyInfo[1])

	local luckAward = string.split(luckyInfo[2], "^")
	if tonumber(luckAward[1]) == nil then
		luckAward[1] = remote.items:getWalletByType(luckAward[1]).nativeName
	else
		luckAward[1] = QStaticDatabase:sharedDatabase():getItemByID(luckAward[1]).name
	end

	local stringFormat1 = "##e%s ##d击杀了BOSS"
	local stringFormat2 = "##e%s ##d对BOSS造成了幸运一击获得了##O %s"
	local tmpStringFormat2 = "%s 对BOSS造成了幸运一击获得了"

	if killUser ~= nil then
		stringFormat1 = string.format(stringFormat1, killUser)
	end
	if luckUser ~= nil and luckAward[1] ~= "" and luckAward[2] ~= nil then
		stringFormat2 = string.format(stringFormat2, luckUser, luckAward[1].."x"..luckAward[2])
		tmpStringFormat2 = string.format(tmpStringFormat2, luckUser)
	end
	self._richText1:setString(stringFormat1)
	local len = string.len(tmpStringFormat2)
	while len < 64 do
		stringFormat2 = string.gsub(stringFormat2, "获得了", "获得了 ")
		tmpStringFormat2 = string.gsub(tmpStringFormat2, "获得了", "获得了 ")
		len = string.len(tmpStringFormat2)
	end
	self._richText2:setString(stringFormat2)

	self._ccbOwner.tf_boss_name:setString("【"..logInfo.bossLevel.."级BOSS】")
end

function QUIWidgetWorldBossRecordClient:getContentSize(tag)
	return self._ccbOwner.layer_bg:getContentSize()
end

return QUIWidgetWorldBossRecordClient