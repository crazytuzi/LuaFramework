-- Filename: CreateUI.lua
-- Author: zhangqiang
-- Date: 2014-08-05
-- Purpose: 创建一些常用的UI方法

module("CreateUI", package.seeall)
require "script/ui/star/StarSprite"

--[[
	@desc :	创建能够置灰的按钮
	@param:	p_normalImagePath 普通状态时的按钮图片路径
			p_highlightImagePath 选择状态时的按钮图片路径
			p_labelStr 按钮上显示的文字内容
			p_fontSize 按钮上文字的字体大小
	@ret  :	按钮
--]]
function createScale9MenuItem(p_normalImagePath, p_highlightImagePath, p_disableImagePath, p_btnSize, p_labelStr, p_fontSize, p_fontColor, p_fontType, p_fontOffsetX)
	if p_normalImagePath == nil or p_highlightImagePath == nil then
		error("image path is nil")
	end
	
	p_btnSize = p_btnSize or CCSprite:create(p_normalImagePath):getContentSize()
	p_fontSize = tonumber(p_fontSize) or 33
	p_fontColor = p_fontColor or ccc3(0xff,0xe4,0x00)
	p_fontType = g_fontType or g_sFontPangWa
	p_fontOffsetX = p_fontOffsetX or 0

	local spriteTable = {}
	local btnData = {}
	btnData[1] = {p_normalImagePath, p_fontSize, p_fontColor}
	btnData[2] = {p_highlightImagePath, p_fontSize, p_fontColor}
	if p_disableImagePath ~= nil then
		btnData[3] = {p_disableImagePath, p_fontSize, ccc3(0xe4,0xe4,0xe4)}
	end
	for k,v in ipairs(btnData) do
		local scaleSprite = CCScale9Sprite:create(v[1])
		scaleSprite:setPreferredSize(p_btnSize)

		if p_labelStr ~= nil then
			local label = CCRenderLabel:create(p_labelStr, p_fontType, v[2], 1, ccc3(0x00,0x00,0x00), type_shadow)
			label:setColor(v[3])
			label:setAnchorPoint(ccp(0.5,0.5))
			label:setPosition(p_btnSize.width*0.5+p_fontOffsetX,p_btnSize.height*0.5)
			scaleSprite:addChild(label)
		end

		spriteTable[k] = scaleSprite
	end

	return CCMenuItemSprite:create(spriteTable[1], spriteTable[2], spriteTable[3])
end

--[[
	@desc :	创建向左推出按钮
	@param:	p_labelStr 按钮上显示的文字内容
			p_fontSize 按钮上文字的字体大小
	@ret  :	按钮
--]]
function createPushLeftMenuItem(p_labelStr, p_fontSize)
	p_fontSize = p_fontSize or 33
	local imagePath = {"images/replaceskill/attribute_btn_n.png","images/replaceskill/attribute_btn_h.png"}
	local fontScale = {1,0.9}
	local menuItemSpriteTable = {}
	local tempSprite = nil
	for i = 1,2 do
		local tempSprite = CCSprite:create(imagePath[i])
		local tempLabel = CCRenderLabel:create(p_labelStr, g_sFontPangWa, p_fontSize*fontScale[i], 1, ccc3(0x00,0x00,0x00), type_stroke)
		tempLabel:setColor(ccc3(0xfe,0xdb,0x1c))
		tempLabel:setAnchorPoint(ccp(0.5,0.5))
		tempLabel:setPosition(61,70)
		tempSprite:addChild(tempLabel)
		table.insert(menuItemSpriteTable, tempSprite)
	end

	return CCMenuItemSprite:create(menuItemSpriteTable[1], menuItemSpriteTable[2])
end

--[[
	@desc :	创建主角属性栏(战斗力 耐力 银币 金币)
	@param:	
	@ret  :	属性栏
--]]
function createAttributeBarFourSprite(p_returnType)
	p_returnType = tonumber(p_returnType)
	--属性栏
	local attributeBar = CCSprite:create("images/star/intimate/top.png")

	-- 战斗力
    local fightValueLabel = CCRenderLabel:create(UserModel.getFightForceValue() , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    -- fightValueLabel:setSourceAndTargetColor(ccc3( 0x36, 0xff, 0x00), ccc3( 0x36, 0xff, 0x00));
    fightValueLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    fightValueLabel:setPosition(108, 34)
    attributeBar:addChild(fightValueLabel,1,1)

    -- 耐力
    local staminaLabel = CCLabelTTF:create(UserModel.getStaminaNumber() .. "/" .. UserModel.getMaxStaminaNumber(), g_sFontName, 20)
	staminaLabel:setColor(ccc3(0xff, 0xff, 0xff))
	staminaLabel:setAnchorPoint(ccp(0, 0))
	staminaLabel:setPosition(ccp(278, 10))
	attributeBar:addChild(staminaLabel,1,2)

	-- 银币
	local silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(UserModel.getSilverNumber()),g_sFontName,20)  -- modified by yangrui at 2015-12-03
	silverLabel:setColor(ccc3(0xe5, 0xf9, 0xff))
	silverLabel:setAnchorPoint(ccp(0, 0))
	silverLabel:setPosition(ccp(402, 10))
	attributeBar:addChild(silverLabel,1,3)

	-- 金币
	local goldLabel = CCLabelTTF:create(UserModel.getGoldNumber(), g_sFontName, 20)
	goldLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	goldLabel:setAnchorPoint(ccp(0, 0))
	goldLabel:setPosition(ccp(522, 10))
	attributeBar:addChild(goldLabel,1,4)

	return {parent = attributeBar, children = {fightValueLabel, staminaLabel, goldLabel}}
end

--[[
	@desc :	创建表格
	@param:	p_directionTag 滑动方向 0 垂直滑动 1 水平滑动
			p_tableViewSize 表格大小
			p_cellSize 表格单元大小
			p_cellNum 表格单元数目
			p_createCellFunc 创建表格得单元得函数
	@ret  :	表格
--]]
function createTableView(p_directionTag, p_tableViewSize, p_cellSize, p_cellNum, p_createCellFunc, p_cellNumFunc)
	local createTableFunc = function ( p_funcName, p_table, p_a1, p_a2 )
		local ret = nil
		if p_funcName == "cellSize" then
			ret = p_cellSize
		elseif p_funcName == "cellAtIndex" then
			ret = p_createCellFunc(p_a1+1)
		elseif p_funcName == "numberOfCells" then
			p_cellNum = p_cellNum or 0
			ret = p_cellNumFunc == nil and p_cellNum or p_cellNumFunc()
		elseif p_funcName == "cellTouched" then

		elseif p_funcName == "scroll" then

		else

		end
		return ret
	end
	local funcEvent = LuaEventHandler:create(createTableFunc)
	local tableView = LuaTableView:createWithHandler(funcEvent, p_tableViewSize)
	if p_directionTag == 0 then
		tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	elseif p_directionTag == 1 then
		tableView:setDirection(kCCScrollViewDirectionHorizontal)
		tableView:reloadData()
	else
		error("Wrong direction, not surpported!")
	end
	return tableView
end

--[[
	@des:		指定每行字数(或确定的文本框宽度及字体大小)获取字符串显示在文本框中时的行数
	@param:		p_descStr 需要显示的字符串
				p_wordsPerLineNum 指定每行字数
				p_wordSizeNum 指定字体大小
				p_fixedLineWidthNum 指定文本框的宽
	@return:	字符串显示在文本框中时的行数
--]]
function getStringLineNumber(p_descStr, p_wordsPerLineNum, p_wordSizeNum, p_fixedLineWidthNum)
	-- 确定每行字数：p_fixedLineWidthNum / p_wordSizeNum 优先级高于 p_wordsPerLineNum
	local wordsPerLine = p_wordsPerLineNum
	if p_wordSizeNum ~= nil and p_fixedLineWidthNum ~= nil then
		wordsPerLine = math.floor(p_fixedLineWidthNum / p_wordSizeNum)
	end

	-- 每行字数默认为1
	if wordsPerLine < 1 then wordsPerLine = 1 end

	-- 统计行数
	local lineNumber = 0
	local wordNum = 0
	local wordIndex = 1
	while wordIndex <= #p_descStr do
		if string.byte(p_descStr,wordIndex) >127 then
			--汉字
			wordNum = wordNum + 1
			wordIndex = wordIndex + 3
		elseif string.byte(p_descStr,wordIndex) == 10 then
			--换行符
			wordNum = 0
			wordIndex = wordIndex + 1
			lineNumber = lineNumber + 1
		elseif string.byte(p_descStr,wordIndex) == 32 then
			--空格
			wordNum = wordNum + 1/3
			wordIndex = wordIndex + 1
		else
			--英文
			wordNum = wordNum + 1
			wordIndex = wordIndex +1
		end
	end

	lineNumber = lineNumber + math.ceil(wordNum / wordsPerLine)
	print("getStringLineNumber:",lineNumber)

	return lineNumber
end

--[[
	@des:		指定每行字数及字体大小获取显示字符串所需的文本框尺寸
	@param:		p_descStr 需要显示的字符串
				p_wordsPerLineNum 指定每行字数
				p_wordSizeNum 指定字体大小
				p_lineSpaceNum 指定行间距
	@return:	显示字符串所需的文本框尺寸
--]]
function getStringDimensions(p_descStr, p_wordsPerLineNum, p_wordSizeNum)
	local lineNum = getStringLineNumber(p_descStr, p_wordsPerLineNum)
	local width = p_wordsPerLineNum * p_wordSizeNum
	--local height = (p_wordSizeNum + 2) * lineNum
	local height = (p_wordSizeNum+2) * lineNum
	return CCSizeMake(width,height)
end