-- Filename: PetIllustratedHandbookCell.lua
-- Author: ZQ
-- Date: 2014-07-08
-- Purpose: 创建宠物图鉴表格单元
module("PetIllustratedHandbookCell",package.seeall)
local kPetHeadIconTouchPriority = -551
local kPetHeadIconNameFontSize = 21
local kSpaceBetweenIconAndName = 3
local kHorizontalSpaceBetweenIcons = 10
local kVerticalSpaceBetweenIcons = 6		--上一行的名字底部与下一行icon的顶部距离
local kIconNumPerLine = 4

local _cellTotalHeight = nil

--[[
	@des:		通过模版id来获得宠物的头像
	@param:		p_tidNum 宠物的模版id
				p_tagNum 所获得头像的tag值
				p_clickBtnFunc 点击所获得头像的回调
				p_menuPriorityNum 所获得头像的优先级
	@return:	宠物头像（sprite）
--]]
function getPetHeadIconWithNameSprite(p_tidNum, p_tagNum, p_clickBtnFunc, p_menuPriorityNum)
	require "script/ui/pet/PetUtil"
	local petHeadIcon = PetUtil.getPetHeadIconByItid(p_tidNum, p_tagNum, p_clickBtnFunc,p_menuPriorityNum)

	require "script/ui/pet/description/PetDescriptionData"
	local nameString = PetDescriptionData.getValueByKeyForId(p_tidNum,"roleName")
	local nameLabel = CCRenderLabel:create(nameString, g_sFontName, kPetHeadIconNameFontSize, 1, ccc3(0x00,0x00,0x00), type_stroke)
	local quality = PetDescriptionData.getValueByKeyForId(p_tidNum,"quality")
	require "script/ui/hero/HeroPublicLua"
	local fontColor = HeroPublicLua.getCCColorByStarLevel(quality)
	nameLabel:setColor(fontColor)
	nameLabel:setAnchorPoint(ccp(0.5,1))
	local petHeadIconContentSize = petHeadIcon:getContentSize()
	nameLabel:setPosition(petHeadIconContentSize.width/2,-kSpaceBetweenIconAndName)
	petHeadIcon:addChild(nameLabel)

	return petHeadIcon
end

--[[
	@des:		创建宠物图鉴表中的cell
	@param:		p_cellDataTable cell中涉及的数据
	@return:	none
--]]
function createTableViewCell(p_cellDataTable)
	local cell = CCTableViewCell:create()

	-- 计算宠物头像行数
	local totalLineNum = math.ceil(table.count(p_cellDataTable) / kIconNumPerLine)

	-- -- 获取单元格高度
	-- require "script/ui/pet/description/PetDescriptionPanel"
	-- local cellTotalHeight = PetDescriptionPanel.getTableViewCellSize().height

	local columnCount = 0					--宠物头像图标所在列标
	local lineCount = 1						--宠物头像图标所在行标
	local petHeadIcon = nil
	local petHeadIconWithNameHeight = nil
	local petHeadIconWithNameWidth = nil
	for _,v in ipairs(p_cellDataTable) do
		petHeadIcon = getPetHeadIconWithNameSprite(v.id,v.id,tapPetHeadIconCb,kPetHeadIconTouchPriority)

		if petHeadIconWithNameHeight == nil or petHeadIconWithNameWidth == nil then
			local petHeadIconContentSize = petHeadIcon:getContentSize()
			petHeadIconWithNamewidth = petHeadIconContentSize.width
			petHeadIconWithNameheight = petHeadIconContentSize.height + kSpaceBetweenIconAndName + kPetHeadIconNameFontSize
			_cellTotalHeight = totalLineNum * (petHeadIconWithNameheight + kVerticalSpaceBetweenIcons)
		end

		-- 计算该图标的行、列标：lineCount 行标， columnCount 列标
		columnCount = columnCount + 1
		if columnCount > kIconNumPerLine then
			columnCount = 1
			lineCount = lineCount + 1
		else
			--columnCount = columnCount + 1
		end

		petHeadIcon:setAnchorPoint(ccp(0,1))
		--petHeadIcon:setPosition((columnCount-1)*(petHeadIconWithNamewidth+kHorizontalSpaceBetweenIcons), cellTotalHeight-(lineCount-1)*(petHeadIconWithNameheight+kVerticalSpaceBetweenIcons))
		petHeadIcon:setPosition((columnCount-1)*(petHeadIconWithNamewidth+kHorizontalSpaceBetweenIcons), _cellTotalHeight - (lineCount-1)*(petHeadIconWithNameheight+kVerticalSpaceBetweenIcons))
		cell:addChild(petHeadIcon)
	end

	return cell
end

--[[
	@des:		点击宠物头标回调
	@param:		p_tagNum 被点击头标tag
				p_itemObj 被点击头标对象
	@return:	none
--]]
function tapPetHeadIconCb(p_tagNum, p_itemObj)
	require "script/ui/pet/description/PetTipPanel"
	PetTipPanel.showLayer(p_tagNum)
end

--[[

--]]
function getIconNumPerLine()
	return kIconNumPerLine
end