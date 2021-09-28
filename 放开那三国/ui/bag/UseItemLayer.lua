-- Filename：	UseItemLayer.lua
-- Author：		zhz
-- Date：		2013-9-24
-- Purpose：		物品Item

module ("UseItemLayer", package.seeall)

require "script/ui/item/ItemUtil"
require "script/utils/LuaUtil"
require "script/ui/item/ItemSprite"
require "script/utils/ItemDropUtil"
require "db/DB_Item_direct"
require "script/utils/ItemTableView"
require "script/model/user/UserModel"
require "script/utils/GoodTableView"
require "script/ui/shopall/MysteryMerchant/MysteryMerchantDialog"



local _bgLayer		 		-- 灰色的layer
local _itemNum 				-- 物品的数量
local _itemData				-- 物品的本地属性信息

local function init( )
	_bgLayer = nil
	_itemNum = 0
	_itemData = nil
end

--得到礼包物品数据
-- num参数 addby licong 支持批量使用道具
function getGiftInfo( item_template_id, num )
	local curNum = tonumber(num) or 1
	require "script/ui/item/ItemUtil"		
	local itemTableInfo = ItemUtil.getItemById(tonumber(item_template_id))
	local awardItemIds 	= string.split(itemTableInfo.award_item_id, ",")
	local items = {}
	-- if(itemTableInfo.award_item_id ~= nil) then
		for k,v in pairs(awardItemIds) do
			local tempStrTable = string.split(v, "|")
			local item = {}
			item.tid  = tempStrTable[1]
			item.num = tonumber(tempStrTable[2]) * curNum
			item.type = "item"
			print_t(item)
			table.insert(items, item)
		end
	    if(itemTableInfo.coins ~= nil) then
			local item = {}
			item.type = "silver"
			item.num  = tonumber(itemTableInfo.coins) * curNum
			table.insert(items, item)
		end
		if(itemTableInfo.gold ~= nil) then
			local item = {}
			item.type = "gold"
			item.num = tonumber(itemTableInfo.golds) * curNum
		end
		if(itemTableInfo.general_soul ~= nil) then
			local item = {}
			item.type = "soul"
			item.num  = tonumber(itemTableInfo.general_soul) * curNum
			table.insert(items, item)
		end
	return items
end

-- 显示使用物品的结果
function showResult(item_template_id )
	
	local itemTableInfo = ItemUtil.getItemById(tonumber(item_template_id))
	if(itemTableInfo.award_item_id ~= nil) then
		local itemData = getGiftInfo(item_template_id)
		print("itemData is : ")
		print_t(itemData)
		refreshUserInfo(itemData)
		local layer = GoodTableView.ItemTableView:create(itemData)
        ----------------------------------------- added by bzx
        layer.closeEvent = MysteryMerchantDialog.checkAndShow()
        -----------------------------------------
		local alertContent = {}
		alertContent[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1248") , g_sFontPangWa, 36,1, ccc3(0x00,0,0),type_stroke)
		alertContent[1]:setColor(ccc3(0xff, 0xc0, 0x00))
		local alert = BaseUI.createHorizontalNode(alertContent)
		layer:setContentTitle(alert)
		CCDirector:sharedDirector():getRunningScene():addChild(layer,1111)
	else
		local useResult = ItemUtil.getUseResultBy( item_template_id, 1, true)
		AnimationTip.showTip(  GetLocalizeStringBy("key_3311") ..  useResult.result_text )
	end
	-- refreshUserInfo(items)

end

-- -- 创建Layer, item_type == 8
-- function createRandGiftLayer( drop)
-- 	local items = {}
-- 	print(" showResult ")
-- 	print_t(drop)

-- 	items =  ItemDropUtil.getDropItem(drop)

-- 	local layer = ItemTableView:create(items)

-- 	local alertContent = {}
-- 	alertContent[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1248") , g_sFontPangWa, 36,1, ccc3(0x00,0,0),type_stroke)
-- 	alertContent[1]:setColor(ccc3(0xff, 0xc0, 0x00))
-- 	local alert = BaseUI.createHorizontalNode(alertContent)
-- 	layer:setContentTitle(alert)
-- 	--refreshUserInfo(items)

-- 	return layer
	
-- end

function refreshUserInfo( items ,exp)
	for i=1, #items do
		if(items[i].type == "silver" ) then
			UserModel.addSilverNumber(items[i].num)
			print("silver num is : ", items[i].num)
		end
		if(items[i].type == "soul") then
			UserModel.addSoulNum(items[i].num)
		end
		if(items[i].type == "gold") then
			UserModel.addGoldNumber(items[i].num)
		end
	end
	exp = exp or 0
	UserModel.addExpValue(tonumber(exp),"useitem")
end

function showDropResult( drop, m_type, exp ,isAddForce )
	local text = ""
	m_type = m_type or 1
	if( m_type == 1 )then
		-- 使用随即礼包
		text = GetLocalizeStringBy("key_1248")
	elseif(m_type == 2)then
		-- 比武
		text = GetLocalizeStringBy("key_1248")
	elseif(m_type == 3)then
		-- 复仇
		text = GetLocalizeStringBy("key_2159")
	elseif(m_type == 4)then
		-- 竞技场
		text = GetLocalizeStringBy("key_3343")
		-- 装备
	elseif(m_type == 5) then
		text = GetLocalizeStringBy("key_1682")

	end
	local items = {}
	print("  showDropResult  is :   ......    ", isAddForce)
	print_t(drop)
	items =  ItemDropUtil.getDropItem(drop)
	if(table.isEmpty(drop)) then
		return
	end

	exp = exp or 0
	isAddForce = isAddForce or false
	if(isAddForce == true) then
		-- 刷新 ui
		refreshUserInfo( items ,exp )
	end

	local layer = GoodTableView.ItemTableView:create(items, exp )
    ------------------------------------- added by bzx
    layer.closeEvent = MysteryMerchantDialog.checkAndShow
    -------------------------------------
	local alertContent = {}

	local zOrder = 4000
	-- zOrder = 11000
	-- layer:setNdeTouchProperty(-6011)
	-- layer:setTouchPriority(-5000)

	if(m_type == 5) then
		layer:setTitleVisible()
		zOrder = 11000
		layer:setNdeTouchProperty(-6011)
		layer:setTouchPriority(-5002)
		alertContent[1] = CCRenderLabel:create(text , g_sFontPangWa, 33,1, ccc3(0x00,0,0),type_stroke)
		alertContent[1]:setColor(ccc3(0xff, 0xfc, 0x00))
		local itemName = ""
		if(#items ==1 ) then
			itemName =  items[1].name or ""
		end 
		alertContent[2] = CCRenderLabel:create("  " .. itemName , g_sFontPangWa, 33,1, ccc3(0x00,0,0),type_stroke)
		alertContent[2]:setColor(ccc3(0x0b,0xe5,0x00))

	else
		alertContent[1] = CCRenderLabel:create(text , g_sFontPangWa, 36,1, ccc3(0x00,0,0),type_stroke)
		alertContent[1]:setColor(ccc3(0xff, 0xfc, 0x00))
	end

	local alert = BaseUI.createHorizontalNode(alertContent)
	layer:setContentTitle(alert)
	CCDirector:sharedDirector():getRunningScene():addChild(layer,zOrder)

end
