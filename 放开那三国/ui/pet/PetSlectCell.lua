-- Filename：	PetSelectCell.lua
-- Author：		zhz
-- Date：		2014-3-31
-- Purpose：		宠物的主界面

module("PetSelectCell", package.seeall)

require "db/DB_Pet"
require "db/DB_Normal_config"
require "script/utils/BaseUI"
require "script/ui/common/CheckBoxItem"
require "script/utils/LuaUtil"




-- 处理检查checked 的宝物
function handleSelectedCheckedBtn( checkedBtn )
	require "script/ui/treasure/evolve/TreasRefineSelLayer"

	local selecedList = TreasRefineSelLayer.getSelCheckedArr()
	if ( selecedList== nil ) then
		checkedBtn:unselected()
	else
		local isIn = false
		if ( tonumber(selecedList)== tonumber(checkedBtn:getTag()) ) then
			isIn = true
		end
		if (isIn) then
			checkedBtn:selected()
		else
			checkedBtn:unselected()
		end
	end
end


function createCell(cellValues )
	local tCell = CCTableViewCell:create()
	
	local fullRect = CCRectMake(0,0,80,118)
	local insetRect = CCRectMake(32,49,8,0)
	local itemNumSprite = CCScale9Sprite:create("images/common/checkbg.png", fullRect, insetRect)
	local cellBg= CCScale9Sprite:create("images/pet/pet/bag_bg.png")
	cellBg:setPreferredSize(CCSizeMake(640,152))
	tCell:addChild(cellBg)

	local petTid= cellValues.tid
	local headIcon = PetUtil.getPetHeadIconByItid(petTid)

		-- 等级
	local nameBg = CCSprite:create("images/pet/pet/name_bg.png")
	nameBg:setPosition(cellBg:getContentSize().width/2, 111)
	nameBg:setAnchorPoint(ccp(0.5,0))
	cellBg:addChild(nameBg)

	-- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	cellBg:addChild(menuBar,1, 9898)

	local checkedBtn = CheckBoxItem.create()
	checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
    checkedBtn:registerScriptTapHandler(checkedAction)
    menuBar:addChild(checkedBtn, 1, tonumber(cellValues.item_id) )
	handleSelectedCheckedBtn(checkedBtn)

	return tCell
end
