--[[	
	文件名称：QUIWidgetSocietyUnionLogSheet2.lua
	创建时间：2016-03-25 18:47:12
	作者：nieming
	描述：QUIWidgetSocietyUnionLogSheet2
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetSocietyUnionLogSheet2 = class("QUIWidgetSocietyUnionLogSheet2", QUIWidget)
local QRichText = import("...utils.QRichText")
local QStaticDatabase = import("...controllers.QStaticDatabase")
--初始化
function QUIWidgetSocietyUnionLogSheet2:ctor(options)
	local ccbFile = "Widget_society_union_log_sheet2.ccbi"
	local callBacks = {
	}
	QUIWidgetSocietyUnionLogSheet2.super.ctor(self,ccbFile,callBacks,options)
	--代码
end

--describe：onEnter 
--function QUIWidgetSocietyUnionLogSheet2:onEnter()
	----代码
--end

--describe：onExit 
--function QUIWidgetSocietyUnionLogSheet2:onExit()
	----代码
--end

--describe：setInfo 
function QUIWidgetSocietyUnionLogSheet2:setInfo(info)
	--代码
	self._info = info
	local id = info.value.type or 0

	if not self._richText then
		self._richText = QRichText.new(nil,650,{stringType = 1,defaultColor = COLORS.j,fontName = global.font_name})
		self._richText:setAnchorPoint(0,1)
		self._ccbOwner.content:addChild(self._richText)
	end

	local time = q.date("%H:%M", info.value.createdAt/1000)
	local content = ""
	local logs = string.split(info.value.content, "#")

	
	local textCfg = ""

	local config = QStaticDatabase:sharedDatabase():getUnionLogByID(id) ;
	if config then
		if #logs < config.param_num then
			printError("#logs ~= config.paramNum  #logs = %d config.paramNum = %d", #logs, config.param_num)
		else
			textCfg = string.format(config.content, unpack(logs))
		end
		self._richText:setString(textCfg)
	end

	self._ccbOwner.time:setString(time)
	

	
end

--describe：getContentSize 
function QUIWidgetSocietyUnionLogSheet2:getContentSize()
	--代码
	local size = self._richText:getContentSize()

	return CCSizeMake(size.width + 8, size.height + 8)
end

return QUIWidgetSocietyUnionLogSheet2
