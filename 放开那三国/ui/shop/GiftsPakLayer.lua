-- Filename：	GiftsPakLayer.lua
-- Author：		lichenyang
-- Date：		2013-8-22
-- Purpose：		商店礼包

module ("GiftsPakLayer", package.seeall)

require "script/ui/shop/GiftsTableCell"
require "script/ui/rewardCenter/AdaptTool"
require "db/DB_Vip"
require "db/DB_Item_direct"
require "script/model/user/UserModel"
require "script/ui/item/ItemUtil"
require "script/model/DataCache"

local  giftsPackageInfo = nil

local _bgLayer = nil

local function init()
	_bgLayer = nil
	giftsPackageInfo = nil
end

function createRecruitMenu(layerSize)
	local  function rewardTableCallback(fn, t_table, a1, a2)
		local r
		-- add by zhz
		local myScale = _bgLayer:getContentSize().width/640
		if fn == "cellSize" then
			r = CCSizeMake(640*myScale, 235*myScale)
		elseif fn == "cellAtIndex" then
			a2 = GiftsTableCell:create( giftsPackageInfo[a1 + 1], _bgLayer:getContentSize())
			r = a2
			a2:setScale(myScale)
		elseif fn == "numberOfCells" then
			r = #giftsPackageInfo
		elseif fn == "cellTouched" then
			
		end
		return r
	end
	giftsPackageTable = LuaTableView:createWithHandler(LuaEventHandler:create(rewardTableCallback), layerSize)
	giftsPackageTable:setVerticalFillOrder(kCCTableViewFillTopDown)
	giftsPackageTable:setBounceable(true)
	giftsPackageTable:setAnchorPoint(ccp(0, 0))
	giftsPackageTable:setPosition(ccp(0, 0))
	_bgLayer:addChild(giftsPackageTable,30)


end


function createLayerBySize( layerSize )
	init()
	print("select time:",os.time())
	giftsPackageInfo = getGiftsPackageInfo()
	print("selected time:",os.time())
	_bgLayer = CCLayer:create()
	_bgLayer:setContentSize(layerSize)
	createRecruitMenu(layerSize)

	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addGuideSignInGuide9()
			-- print("getTableCellIcon()", getTableCellIcon())
		end))
	_bgLayer:runAction(seq)
	

	return _bgLayer
end

----------------------------------[[ 数据查询方法 ]]-----------------------------------------------

function getGiftsPackageInfo( ... )

	local vip = UserModel.getVipLevel()
	local giftsInfos = {}

	for i=1,vip+4 do
		if(i > table.count(DB_Vip.Vip)) then
			break
		end
		local vipData = DB_Vip.getDataById(i)
		local giftsData  = {}
        print("getGiftsPackageInfo", i)
        print_t(vipData)
        print(vipData.vip_gift_ids)

        -- 对 vipData.vip_gift_ids 做特殊处理 added by zhz
        if(vipData.vip_gift_ids == nil) then
        	break
        end

		local vip_gift_ids = string.split(vipData.vip_gift_ids, "|")
		giftsData.id 		= vip_gift_ids[1]
		giftsData.oldPrice 	= vip_gift_ids[2]
		giftsData.newPrice 	= vip_gift_ids[3]
		giftsData.level 	= vipData.level 

		print("giftsData.id", giftsData.id)
		--print_t(itemInfo)

		local itemInfo = ItemUtil.getItemById(tonumber(giftsData.id))
		giftsData.desc = itemInfo.desc
		giftsData.name = itemInfo.name
		table.insert(giftsInfos, giftsData)
		-- print("giftsData")
		-- print_t(giftsData)
	end
	print("giftsInfos")
	print_t(giftsInfos)
	return giftsInfos
end

-- added by zhz
-- 获得首冲礼包的数据
 function getFirstVipData( ... )
	require "db/DB_First_gift"
	local items ={}
	-- 第一个为金币 , 首冲
	-- 金币重置 金币3倍显示去掉 20160530 by lgx
	-- local item = {}
	-- item.type = "gold"
	-- item.num = 1
	-- item.desc = GetLocalizeStringBy("key_2385")
	-- table.insert(items,item)
	require "script/ui/shop/RecharData"
	local itemInfo = RecharData.getFirstDataInfo()
	-- item
	local reward_item_ids 	= string.split(itemInfo.reward_item_ids, ",")
	for k ,v in pairs(reward_item_ids) do
		local tempStrTable = string.split(v, "|")
		local item = {}
		item.tid  = tempStrTable[1]
		item.num = tempStrTable[2]
		item.type = "item"
		print_t(item)
		table.insert(items, item)
	end
	if(itemInfo.reward_coin ~= nil ) then
		local item = {}
		item.type = "silver"
		item.num = itemInfo.reward_coin
		table.insert(items,item)
	end

	return items

end

-- added by zhz
-- 通过 vip等级来获得vip礼包的信息,同时要判断是否为首冲礼包
function getVipItemInfo( _boolCharge, level)
	
	local items = {}
	-- 首冲
	if(_boolCharge == false) then
		local items = {}
		-- require "db/DB_First_gift"
		-- local itemInfo = DB_First_gift.getDataById(1)
		items = getFirstVipData()
		return items
	end

	-- 不是首冲 
	local vipData = DB_Vip.getDataById(tonumber(level)+1)

	if(vipData.vip_gift_ids== nil) then
		return {}
	end

	local vip_gift_ids = string.split(vipData.vip_gift_ids, "|")[1]
	-- local vip_Item_id= vip_gift_ids[1]
	-- getGiftInfo() 调用 ，GiftTableCell 中的方法，这是一个坑吖
	items = getGiftInfo(vip_gift_ids)
	return items
end

function getGuideButton( ... )
	local tableCell = giftsPackageTable:cellAtIndex(0)
	print("tableCell", tableCell)
	local cellback 	= tolua.cast(tableCell:getChildByTag(100), "CCSprite")
	local cellMenu 	= tolua.cast(cellback:getChildByTag(101), "CCMenu")
	local button 	= tolua.cast(cellMenu:getChildByTag(102), "CCMenuItem")
	return button
end

-- 签到第9步 购买
function addGuideSignInGuide9( ... )
	require "script/guide/NewGuide"
	require "script/guide/SignInGuide"
    if(NewGuide.guideClass ==  ksGuideSignIn and SignInGuide.stepNum == 8) then
        local button = getTableCellIcon()
        local touchRect   = getSpriteScreenRect(button)
        SignInGuide.show(9, touchRect)
    end
end


function getTableCellIcon( ... )
	local tableCell = giftsPackageTable:cellAtIndex(0)
	print("tableCell", tableCell)
	local cellback 	= tolua.cast(tableCell:getChildByTag(100), "CCNode")
	local menuback 	= tolua.cast(cellback:getChildByTag(201), "CCNode")
	local cellMenu 	= tolua.cast(menuback:getChildByTag(202), "CCMenu")
	local button 	= tolua.cast(cellMenu:getChildByTag(203), "CCMenuItem")
	return button
end




