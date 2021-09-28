--[[
    文件名: RichTextEx.lua
    描述: ccui.RichText 控件功能的扩展
    创建人: liaoyuangang
    创建时间: 2017.2.24
-- ]]

require("common.String")
require("common.Enums")

-- 内容格式信息
--[[
	{
		imageScale, 	-- 图片的缩放比例，默认为1

		font = nil,     -- 显示的字体, 默认为黑体粗体("Helvetica-Bold")
		fontSize = 22,	-- 显示字体的大小, 默认为22号字
		color = nil,	-- 显示的颜色，默认为 display.COLOR_WHITE

		opacity = 255, 	-- 透明度，默认为 255

		needBold = false, 			-- 是否需要粗体，默认为false，
		needUnderline = false, 		-- 是否需要下划线，默认为false
		needStrikethrough = false, 	-- 是否需要删除线，默认为false

		needUrl = false, 	-- 是否需要Url链接地址，默认为false
		url = "", 			-- url 链接地址, 默认为""

		needOutLine = false, 	-- 是否需要描边，默认为false，
		outlineColor = nil, 	-- 描边的颜色，可选设置，needOutLine为true时有效，默认为display.COLOR_BLACK
		outlineSize = 2,    	-- 描边的大小，可选设置，needOutLine为true时有效，默认为 2

		needShadow = false, 		-- 是否需要阴影，默认为false
		shadowColor = nil,  		-- 阴影的颜色，可选设置，needShadow为true是，该参数有效，默认为display.COLOR_BLACK
		shadowOffset = nil, 		-- 阴影偏移，可选设置，needShadow为true是，该参数有效，默认为Size(2.0, -2.0)
		shadowBlurRadius = nil, 	-- 阴影模糊半径，可选设置，needShadow为true是，该参数有效，默认为0

		needeGlow = false, 		-- 是否需要色彩渲染，默认为false
		glowColor = nil, 		-- 色彩渲染颜色，可选设置，needeGlow为true时有效，默认为 display.COLOR_WHITE
	}
]]

local RichTextEx = class("RichTextEx", function()
	local retRichText = ccui.RichText:create()
	retRichText.__default_insertElement = retRichText.insertElement
	retRichText.__default_setContentSize = retRichText.setContentSize
	retRichText.__default_getContentSize = retRichText.getContentSize
	retRichText.__default_stopAllActions = retRichText.stopAllActions
	retRichText.__default_setOpacity = retRichText.setOpacity

    return retRichText
end)

local FlagEnums = {
	eBold 			= cc.LightFlag.LIGHT1,  -- 粗体标志
	eUnderline 		= cc.LightFlag.LIGHT2,  -- 下划线标志
	eStrikethrough 	= cc.LightFlag.LIGHT3, -- 删除线标志
	eUrl 			= cc.LightFlag.LIGHT4,   -- url链接标志
	eOutline 		= cc.LightFlag.LIGHT5, -- 描边标志
	eShadow 		= cc.LightFlag.LIGHT6, -- 阴影标志
	eGlow 			= cc.LightFlag.LIGHT7, -- 色彩渲染标志
}

-- 显示内容提供默认的显示格式信息，由于同一个RichText中可以包含多个RichElement，
-- 所以单个RichElement可以相应的格式信息，但需要使用相应的特殊接口实现
--[[
-- 参数 params中的各项为:
	{
		text = "",          -- 显示的内容
		align = nil,        -- 水平对齐方式, 默认为 cc.TEXT_ALIGNMENT_LEFT
		valign = nil,       -- 垂直对齐方式，默认为 cc.VERTICAL_TEXT_ALIGNMENT_CENTER
		dimensions = nil,   -- 显示区域大小，默认不设置大小, dimensions.height = 0 的时候，自动计算高度

		formatInfo = {}, -- 参考文件头处“内容格式信息”相应注释	
	}
]]
function RichTextEx:ctor(params)
	params = params or {}

	self.mContentStr = params.text  -- 解析前的显示内容信息
	self.mContentList = self:analysisString(params.text) -- 解析后的显示内容信息
	self:setAlignment(params.align or cc.TEXT_ALIGNMENT_LEFT, params.valign or cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	if params.dimensions then
		self:setContentSize(params.dimensions)
	end
	local formatInfo = params.formatInfo or {}
	self.mDefFormat = {
		imageScale = formatInfo.imageScale or 1,

		font = formatInfo.font or "Helvetica-Bold",
		fontSize = formatInfo.fontSize or 22,
		color = formatInfo.color or display.COLOR_WHITE,

		opacity = 255, -- formatInfo.opacity or 

		needBold = formatInfo.needBold,
		needUnderline = formatInfo.needUnderline,
		needStrikethrough = formatInfo.needStrikethrough,

		needUrl = formatInfo.needUrl,
		url = formatInfo.url or "",

		needOutLine = formatInfo.needOutLine,
		outlineColor = formatInfo.outlineColor or Enums.Color.eOutlineColor,
		outlineSize = formatInfo.outlineSize or 2,

		needShadow = formatInfo.needShadow,
		shadowColor = formatInfo.shadowColor or Enums.Color.eShadowColor,
		shadowOffset = formatInfo.shadowOffset or cc.size(2, -2),
		shadowBlurRadius = formatInfo.shadowBlurRadius or 0,

		needeGlow = formatInfo.needeGlow,
		glowColor = formatInfo.glowColor or display.COLOR_WHITE,
	}

	-- 刷新显示内容
	self:refresh()
end

-- 字符串格式的内容为表结构的内容，目前字符串中只支持颜色、图片、换行等信息，如果需要更丰富的格式需要使用 RichTextEx:setContent 函数
--[[
-- 参数
	srcStr: 字符串格式的内容，如 “#FFFFFF游戏{1.png}是什么”
-- 解析后的表机构为:
	{
		{  -- 这几个字段选择一个： "text、imageStr、customCb、newLine"
			text: -- 显示字符串内容
			imageStr: -- 图片名
			customCb: 自定义node的回调函数
			newLine: 新的一行，取值为bool

			formatInfo: -- 格式信息, 参考文件头处“内容格式信息”相应注释
		},
		
		...
	}
]]
function RichTextEx:analysisString(srcStr)
	srcStr = srcStr or ""
	local ret = {}

	-- 根据分隔符分割字符串
	local function splitString(str, sep, splitCb)
		while string.len(str) > 0 do
			local i, j = string.find(str, sep)
	        if not i then
	        	splitCb(str)
	            break
	        end

	        local befStr = (i > 1) and string.sub(str, 1, i - 1) or nil
	        local foundStr = (i > 0) and string.sub(str, i, j) or nil
	        splitCb(befStr, foundStr)

	        if (string.len(str) <= j) then
	            str = ""
	        else
	            str = string.sub(str, j + 1, string.len(str))
	        end
		end
	end

	-- 颜色匹配字符串
	local colorPattern = "#%x%x%x%x%x%x"
	-- 图片匹配字符串 
	local imagePattern = "{[%w_/]+%.[jpngJPNG]+}"
	-- 换行字符串
	local newLinePattern = "[\r\n]+"

	local lastColor = self.mColor
	-- 第一层解析颜色字符串串
	splitString(srcStr, colorPattern, function(subStr, colorStr)
		if subStr and subStr ~= "" then
			-- 第二层解析图片字符串
			splitString(subStr, imagePattern, function(textStr, imgStr)
				if textStr and textStr ~= "" then
					-- 第三层解析换行符
					splitString(textStr, newLinePattern, function(viewStr, newLineStr)
						if viewStr and viewStr ~= "" then
							table.insert(ret, {
				        		text = viewStr,
				        		formatInfo = {
				        			color = lastColor,
				        		},
				        	})
						end
						if newLineStr and newLineStr ~= "" then
							table.insert(ret, {
				        		newLine = true,
				        	})
						end
					end)
				end

				if imgStr and imgStr ~= "" then
					-- 添加图片信息
			        table.insert(ret, {
		        		imageStr = string.sub(imgStr, 2, string.len(imgStr) - 1)
		        	})
				end
			end)
		end

		lastColor = colorStr and self:strToColor(string.sub(colorStr, 2, string.len(colorStr))) or lastColor
	end)

	return ret
end

-- 6位字符串颜色转成cocos color
function RichTextEx:strToColor(text)
    local ret = cc.c3b(0xFF, 0xFF, 0xFF)
    if string.len(text or "") >= 6 then
        ret.r = tonumber(string.sub(text, 1, 2), 16)
        ret.g = tonumber(string.sub(text, 3, 4), 16)
        ret.b = tonumber(string.sub(text, 5, 6), 16)
    end
    return ret
end

-- 设置字符串
function RichTextEx:setString(srcStr)
	self.mContentStr = srcStr
	self.mContentList = self:analysisString(srcStr)

	-- 刷新显示内容
	self:refresh()
end

-- 获取字符串
function RichTextEx:getString()
	return self.mContentStr
end

-- 设置包含格式信息的显示内容
--[[
-- 参数
	contentList:
	{
		{  -- 这几个字段选择一个： "text、imageStr、customCb、newLine"  
			text: -- 显示字符串内容
			imageStr: -- 图片名
			customCb: 自定义node的回调函数
			newLine: 新的一行，取值为bool

			formatInfo: -- 格式信息, 参考文件头处“内容格式信息”相应注释
		},

		...
	}
]]
function RichTextEx:setContent(contentList)
	self.mContentList = contentList or {}

	-- 刷新显示内容
	self:refresh()
end

-- 刷新显示
function RichTextEx:refresh(immediately)
	-- 具体的刷新函数
	local function refreshElement()
		self:clearElement()
		for index, item in ipairs(self.mContentList) do
			local formatInfo = item.formatInfo or self.mDefFormat
			if item.newLine then
				local opacity = formatInfo.opacity or self.mDefFormat.opacity
				local elementNewLine = ccui.RichElementNewLine:create(index, cc.c3b(255,255,255), opacity)
				self:pushBackElement(elementNewLine)
			elseif item.customCb then
				local tempNode = item.customCb()
				local opacity = formatInfo.opacity or self.mDefFormat.opacity
				local elementNode = ccui.RichElementCustomNode:create(index, cc.c3b(255,255,255), opacity, tempNode)
				self:pushBackElement(elementNode)
			elseif item.imageStr and item.imageStr ~= "" then -- 图片
				local opacity = formatInfo.opacity or self.mDefFormat.opacity
				local richImage = ccui.RichElementImage:create(index, display.COLOR_WHITE, opacity, item.imageStr)
		        if richImage then
		        	local tempScale = formatInfo.imageScale or self.mDefFormat.imageScale
					local tempSize = ui.getImageSize(item.imageStr)
					richImage:setWidth(tempSize.width * tempScale)
					richImage:setHeight(tempSize.height * tempScale)

	                self:pushBackElement(richImage)
	            end
			else
				local tempFlag = 0
				if formatInfo.needBold or formatInfo.needBold == nil and self.mDefFormat.needBold then
					tempFlag = tempFlag + FlagEnums.eBold
				end
				if formatInfo.needUnderline or formatInfo.needUnderline == nil and self.mDefFormat.needUnderline then
					tempFlag = tempFlag + FlagEnums.eUnderline
				end
				if formatInfo.needStrikethrough or formatInfo.needStrikethrough == nil and self.mDefFormat.needStrikethrough then
					tempFlag = tempFlag + FlagEnums.eStrikethrough
				end
				if formatInfo.needUrl or formatInfo.needUrl == nil and self.mDefFormat.needUrl then
					tempFlag = tempFlag + FlagEnums.eUrl
				end
				if formatInfo.needOutLine or formatInfo.needOutLine == nil and self.mDefFormat.needOutLine then
					tempFlag = tempFlag + FlagEnums.eOutline
				end
				if formatInfo.needShadow or formatInfo.needShadow == nil and self.mDefFormat.needShadow then
					tempFlag = tempFlag + FlagEnums.eShadow
				end
				if formatInfo.needeGlow or formatInfo.needeGlow == nil and self.mDefFormat.needeGlow then
					tempFlag = tempFlag + FlagEnums.eGlow
				end

				local richLabel = ccui.RichElementText:create(
					index, 
					formatInfo.color or self.mDefFormat.color, 
					formatInfo.opacity or self.mDefFormat.opacity, 
					item.text, 
					formatInfo.font or self.mDefFormat.font, 
					formatInfo.fontSize or self.mDefFormat.fontSize,
					tempFlag, 
					formatInfo.url or self.mDefFormat.url, 
					formatInfo.outlineColor or self.mDefFormat.outlineColor, 
					formatInfo.outlineSize or self.mDefFormat.outlineSize,
					formatInfo.shadowColor or self.mDefFormat.shadowColor, 
					formatInfo.shadowOffset or self.mDefFormat.shadowOffset, 
					formatInfo.shadowBlurRadius or self.mDefFormat.shadowBlurRadius,
					formatInfo.glowColor or self.mDefFormat.glowColor
				)
	            self:pushBackElement(richLabel)
			end
		end
	end

	if self.mNeedRefresh then
		if immediately then
			self:stopAction(self.mRefAction)
			refreshElement()
			self.mNeedRefresh = false
		end

		return 
	end

	self.mNeedRefresh = true
    self.mRefAction = self:runAction(cc.CallFunc:create(function()
    	refreshElement()
    	self.mNeedRefresh = false
    end))
end

-- 重写插入函数
function RichTextEx:insertElement(customCb, index)
	index = (index or #self.mContentList) + 1
	local tempIndex = math.min(index, #self.mContentList + 1)
	table.insert(self.mContentList, tempIndex, {
		customCb = customCb
	})
	self:refresh()
end

-- 重写停止控件动作函数
function RichTextEx:stopAllActions()
	self:__default_stopAllActions()

	if self.mNeedRefresh then
		self.mNeedRefresh = false
		self:refresh()
	end
end

-- 重写设置控件的大小的函数，目的是设置空间的大小是否需要根据显示内容计算
--[[
-- 参数：
	newSize 
	{
		width: 控件的宽度
		height: 控件的高度，如果为0， 表示控件的实际大小需要根据显示内容计算，否则不需要
	}
]]
function RichTextEx:setContentSize(newSize)
	if newSize.height > 0.005 then
		self:setMaxLineWidth(0)
		self:ignoreContentAdaptWithSize(false)
		self:__default_setContentSize(newSize)
	else
		self:setMaxLineWidth(newSize.width)
	end
end

-- 重写获取控件大小的函数，目的是在获取大小之前，确保计算了其中子控件的大小和位置
function RichTextEx:getContentSize()
	self:refresh(true)
	self:formatText()
	return self:__default_getContentSize()
end

-- 
function RichTextEx:setDimensions(dimensions)
	self:setContentSize(dimensions)
end

-- 
function RichTextEx:setLineSpacing(space)
	self:setVerticalSpace(space or 0)
end

-- 
function RichTextEx:enableShadow(shadowColor, offset, blurRadius)
	self.mDefFormat.needShadow = true
	if shadowColor then
		self.mDefFormat.shadowColor = shadowColor
	end
	if offset then
		self.mDefFormat.shadowOffset = offset
	end
	if blurRadius then
		self.mDefFormat.shadowBlurRadius = blurRadius
	end
	
	-- 刷新显示内容
	self:refresh()
end

-- 
function RichTextEx:enableOutline(outlineColor, outlineSize)
	self.mDefFormat.needOutLine = true

	if outlineColor then
		self.mDefFormat.outlineColor = outlineColor
	end
	if outlineSize then
		self.mDefFormat.outlineSize = outlineSize
	end

	-- 刷新显示内容
	self:refresh()
end

--
function RichTextEx:enableBold()
	self.mDefFormat.needBold = true

	-- 刷新显示内容
	self:refresh()
end

-- 
function RichTextEx:enableUnderline()
	self.mDefFormat.needUnderline = true

	-- 刷新显示内容
	self:refresh()
end

function RichTextEx:setColor(c3bColor)
	self.mDefFormat.color = c3bColor or display.COLOR_WHITE

	-- 刷新显示内容
	self:refresh()
end

-- 
function RichTextEx:setTextColor(c3bColor)
	self.mDefFormat.color = c3bColor or display.COLOR_WHITE

	-- 刷新显示内容
	self:refresh()
end

-- 重截设置setSystemFontSize方法
function RichTextEx:setSystemFontSize(fontSize)
    self.mDefFormat.fontSize = fontSize or 22

    -- 刷新显示内容
	self:refresh()
end

-- 重截设置setSystemFontSize方法
function RichTextEx:setFontSize(fontSize)
    self:setSystemFontSize(fontSize)
end

-- 设置图片的缩放比例
function RichTextEx:setImageElementScale(scale)
	self.mDefFormat.imageScale = scale or 1
	print("RichTextEx:setImageElementScale")

	-- 刷新显示内容
	self:refresh()
end

-- 设置透明度
function RichTextEx:setOpacity(opacity)
	self:__default_setOpacity(opacity)
	-- self.mDefFormat.opacity = opacity

	-- 刷新显示内容
	self:refresh()
end

return RichTextEx