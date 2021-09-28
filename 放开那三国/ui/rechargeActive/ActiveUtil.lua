-- Filename：	ActiveUtil.lua
-- Author：		zhz
-- Date：		2013-9-29
-- Purpose：		方法

module ("ActiveUtil", package.seeall)

require "script/ui/hero/HeroPublicLua"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "db/DB_Heroes"	
require "script/utils/GoodTableView"




--------------------------- 神秘商店使用

function showDownMenu( ... )
	MainScene.setMainSceneViewsVisible(true, false, false)
end



--[[
    @des:       通过类型和 type 获得物品的 图标;   type = 1：物品ID ,type = 2：英雄ID , type=3 :宝物碎片
    @return:    icon
]]
function getItemIcon( itemType, item_temple_id, menu_priority, isHot)
    menu_priority = menu_priority or -665
	local itemSprite 
	if(itemType == 1) then
		-- 武魂的
		if(item_temple_id >= 400001 and item_temple_id <= 500000)then
			itemSprite= ItemSprite.getHeroFragIconByItemId(tonumber(item_temple_id), nil, menu_priority )
		else
			itemSprite= ItemSprite.getItemSpriteById(tonumber(item_temple_id), nil, showDownMenu, nil, menu_priority,nil,-1100)
		end
	elseif(itemType== 2) then
		itemSprite= ItemSprite.getHeroIconItemByhtid( tonumber(item_temple_id),  menu_priority,nil,-1100) --HeroPublicCC.getCMISHeadIconByHtid(tonumber(item_temple_id))
	elseif(itemType ==3) then
		itemSprite= ItemSprite.getItemSpriteById(tonumber(item_temple_id), nil, showDownMenu, nil, menu_prioritynil,nil,-1100)
	end
	if isHot then
		local hotSprite = CCSprite:create("images/weekendShop/hot_sell.png")
		itemSprite:addChild(hotSprite)
		hotSprite:setAnchorPoint(ccp(1, 1))
		hotSprite:setPosition(ccpsprite(1, 1, itemSprite))
	end
	return itemSprite
	
end

--[[
    @des:       通过类型和 type 获得物品的 名称
    @return:    Info
]]
function getItemInfo( itemType, item_temple_id )
	local itemInfo
	if(itemType == 1 or itemType== 3) then
		itemInfo=  ItemUtil.getItemById(item_temple_id)
	elseif(itemType == 2) then
		itemInfo= DB_Heroes.getDataById(item_temple_id)
		itemInfo.quality = itemInfo.star_lv
	end
	return itemInfo
end

--[[
    @des:      通过 itemTable 弹出奖励
    @return:   
]]
function showItemGift( item )
	local items = {}
	local itemTable= {}
	if(item.type==1 or item.type == 3) then
		itemTable.type = "item"
	elseif(item.type) then
		itemTable.type = "hero"
	end
	itemTable.tid = item.tid
	itemTable.num = item.num

	table.insert(items, itemTable)

	local layer = GoodTableView.ItemTableView:create(items)
	local alertContent = {}
	alertContent[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1248") , g_sFontPangWa, 36,1, ccc3(0x00,0,0),type_stroke)
	alertContent[1]:setColor(ccc3(0xff, 0xc0, 0x00))
	local alert = BaseUI.createHorizontalNode(alertContent)
	layer:setContentTitle(alert)
	CCDirector:sharedDirector():getRunningScene():addChild(layer,1111)

end

-- 限时神将
function getCardHeroDesc()
	require "script/ui/rechargeActive/ActiveCache"
	local c_data = ActiveCache.getCardData()

	if( c_data.reward_rank_num == nil or c_data.reward_rank_num == "" )then
        return nil
    end

    local t_text_arr = lua_string_split(c_data.reward_rank_num, ",") 


    local kaifu_num = 1
    if(UserModel.getUserInfo().mergeServerCount)then
    	kaifu_num = tonumber(UserModel.getUserInfo().mergeServerCount)
    end
    
    if(kaifu_num>1 and UserModel.getUserInfo().mergeServerTime )then
    	-- 换算成00:00:00点时间算
    	local startTime = TimeUtil.getCurDayZeroTime(tonumber( ActivityConfig.ConfigCache.heroShop.start_time) )
    	local endTime = TimeUtil.getCurDayZeroTime(tonumber( ActivityConfig.ConfigCache.heroShop.end_time) + 86400)
    	if(startTime <= tonumber(UserModel.getUserInfo().mergeServerTime) and  endTime >= tonumber(UserModel.getUserInfo().mergeServerTime))then
	    	if(kaifu_num >=5)then
				kaifu_num = 5
		    end
		else
			kaifu_num = 1
    	end
    else
    	kaifu_num = 1
    end

    -- 第一档
    local num_arr = lua_string_split(t_text_arr[1], "|")
    local f_rank = kaifu_num * tonumber(num_arr[1])
    local firstRewardText = {}
    if(f_rank>1)then
    	firstRewardText[1] = "1~" .. f_rank
    	firstRewardText[2] = num_arr[2]
    else
    	firstRewardText[1] = GetLocalizeStringBy("key_10262")
    	firstRewardText[2] = num_arr[2]
    end

    -- 第二档
    num_arr = lua_string_split(t_text_arr[2], "|")
    local s_rank = kaifu_num * tonumber(num_arr[1])
    local s_rewardText = {}
	s_rewardText[1] = (f_rank+1) .. "~" .. (f_rank + s_rank)
	s_rewardText[2] = num_arr[2]

	-- 第三档
	num_arr = lua_string_split(t_text_arr[3], "|")
	local t_rank = kaifu_num * tonumber(num_arr[1])
    local t_rewardText = {}
	t_rewardText[1] = (f_rank + s_rank +1) .. "~" .. (f_rank + s_rank + t_rank)
	t_rewardText[2] = num_arr[2]
    
    -- 第四档 超过100
    num_arr = lua_string_split(t_text_arr[4], "|")
    local forth_rank = kaifu_num * tonumber(num_arr[1])
    local forth_rewardText = {}
    if(f_rank + s_rank + t_rank>=100)then
		forth_rewardText = nil
	else
		local max_t = f_rank + s_rank + t_rank + forth_rank
		if(max_t>100 )then
			max_t = 100
		end
		forth_rewardText[1] = (f_rank + s_rank + t_rank + 1) .. "~" .. max_t
		forth_rewardText[2] = num_arr[2]
	end

	return firstRewardText, s_rewardText, t_rewardText, forth_rewardText
end





