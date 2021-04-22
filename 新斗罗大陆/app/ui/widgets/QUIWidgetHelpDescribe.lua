--[[	
	文件名称：QUIWidgetQlistviewItem.lua
	创建时间：2016-03-10 20:49:28
	作者：nieming
	描述：QUIWidgetQlistviewItem
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetHelpDescribe = class("QUIWidgetHelpDescribe", QUIWidget)
local QRichText = import("...utils.QRichText")
local QStaticDatabase = import("...controllers.QStaticDatabase")

--初始化
function QUIWidgetHelpDescribe:ctor(options)
	local ccbFile = "Widget_QListView_Item.ccbi"
	local callBacks = {
	}
	QUIWidgetHelpDescribe.super.ctor(self,ccbFile,callBacks,options)
	--代码

	if options and type(options) == "table" then
		self._fontName = options.fontName
	end
end


function QUIWidgetHelpDescribe:_setRichTextContent()
	-- body

	local str 
	if self._strData then
		str = self._strData
	else
		local t = QStaticDatabase:sharedDatabase():getHelpDescribeByType(self._helpType) or {}
		str = t.content or ""
	end

	if self._paramArr then
		str = string.format(str, unpack(self._paramArr))
	end
	local strArr  = string.split(str,"\n") or {}

	local richTextCfg = {}
	for k,v in pairs(strArr) do
		if v and v ~= "" then
			if string.match(v,"^$(%u*).*") then
				string.gsub(v, "^$(%u*)(.*)",function ( typeName, content )
					-- body
					if typeName == "T" then
						local tempRichText = QRichText.new({{oType = "bmfont", content = content or "",fontName = "font/FontAchievement.fnt", scale = 0.75, gap = -5}},self._richTextWidthLimit)
						table.insert(richTextCfg, {oType = "node", node = tempRichText})
					end
					if typeName == "H" then
						local tbls = self._richText:parseHTML(content)
						for _,tbl in ipairs(tbls) do
							table.insert(richTextCfg, tbl)
						end
					end
				end)
			else
				local tempRichText = QRichText.new(v,self._richTextWidthLimit,self._richTextFontOptions)
				table.insert(richTextCfg, {oType = "node", node = tempRichText})
			end
			if k ~= #strArr then
				table.insert(richTextCfg,{oType = "wrap"}) 
			end
		end
	end

	self._richText:setString(richTextCfg)
end

--describe：onEnter 
--function QUIWidgetHelpDescribe:onEnter()
	----代码
--end

--describe：onExit 
--function QUIWidgetHelpDescribe:onExit()
	----代码
--end

--describe：setInfo 
function QUIWidgetHelpDescribe:setInfo(info, customStr)
	--代码
	self._isNotHelp = isNotHelp
	self._ccbOwner.parentNode:removeAllChildren()

	self._paramArr = info.paramArr;
	self._helpType = info.helpType;
	self._offsetX = info.offsetX or 30
	self._lineSpace = info.lineSpace or 0

	self._richTextLineSpacing = info.lineSpacing or 8
	self._richTextWidthLimit = info.widthLimit or 720
	self._richTextFontOptions = {}
	-- ccc3(243,222,191)
	self._richTextFontOptions.defaultColor = info.defaultColor or ccc3(134,85,55)
	self._richTextFontOptions.defaultSize = info.defaultSize or 20
	self._richTextFontOptions.stringType = 1
	self._richTextFontOptions.fontName = self._fontName
	self._richTextFontOptions.lineSpacing = self._lineSpace
	self._richTextFontOptions.lineHeight = info.lineHeight 

	self._richText = QRichText.new(nil,self._richTextWidthLimit, {lineSpacing = self._richTextLineSpacing, fontName = self._fontName})
	self._ccbOwner.parentNode:addChild(self._richText)
	self._richText:setAnchorPoint(ccp(0,1))
	self._richText:setPosition(ccp(self._offsetX,80))

	self._strData = customStr 

	self:_setRichTextContent()

end

--describe：getContentSize 
function QUIWidgetHelpDescribe:getContentSize()
	--代码
	return self._richText:getContentSize()

end

return QUIWidgetHelpDescribe

