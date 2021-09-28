-- Filename：	FBUtil.lua
-- Author：		Cheng Liang
-- Date：		2013-5-22
-- Purpose：		封装lua层的menuItem，方便使用，及以后做修改

module("LuaMenuItem", package.seeall)



local  table_t = {}

local function buttonAction( tag, itemImage )
	for k,v_item_info in pairs(table_t) do
		if(v_item_info.itemImage == itemImage) then
			v_item_info.delegateAction(tag, itemImage)
			-- SimpleAudioEngine:sharedEngine():playEffect("audio/button_01.mp3")
			break
		end
	end
end

--创建一个带label的itemImage
function createItemImage( normalImageName, hightLightedImageName, delegateAction, music_id, title, fontSize, ccc3Color )
	local point = CCPointMake(0, 0)
	local itemImage = CCMenuItemImage:create(normalImageName, hightLightedImageName)
	itemImage:registerScriptTapHandler(buttonAction)
	if (title and #title >0) then
		local titleLabel = CCLabelTTF:create(title, g_sFontName, fontSize, itemImage:getContentSize(), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
		titleLabel:setAnchorPoint(point)
		itemImage:addChild(titleLabel, 0, 1)
	    if (ccc2Color) then
	        titleLabel:setColor(ccc3Color)
	    end
	end

	local isIn = false
	if(delegateAction) then
		local item_info = {}
		item_info.delegateAction = delegateAction
		item_info.music_id 		 = music_id
		item_info.itemImage 	 = itemImage

		for k,t_item_info in pairs(table_t) do
			if(t_item_info.itemImage == itemImage) then
				table_t[k] = item_info
				isIn = true
				break
			end
		end
		if(not isIn) then
			table.insert(table_t, item_info)
		end
	end

	return itemImage
end

--创建一个带label的itemImage
function createItemSprite( normalSprite, hightLightedSprite)

	local itemImage = CCMenuItemSprite:create(normalSprite, hightLightedSprite)

	return itemImage
end

-- 创建某个固定按钮
function createMenuItemSprite( fontText, fontSize_n, fontSize_h, fontColor_n, fontColor_h, p_size )
	
	local n_sprite = CCSprite:create("images/common/btn_title_n.png")
	if( p_size )then
		n_sprite:setContentSize(p_size)
	end
	local h_sprite = CCSprite:create("images/common/btn_title_h.png")
	if( p_size )then
		h_sprite:setContentSize(p_size)
	end
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" )then
		fontSize_n = fontSize_n or 33
		fontSize_h = fontSize_h or 29
	else
		fontSize_n = fontSize_n or 36
		fontSize_h = fontSize_h or 30
	end
	fontColor_n = fontColor_n or ccc3(0xff, 0xe4, 0x00)
	fontColor_h = fontColor_h or ccc3(0x48, 0x85, 0xb5)

	local n_label = LuaCCLabel.createShadowLabel(fontText, g_sFontPangWa, fontSize_n)
	n_label:setColor(fontColor_n)
    n_label:setAnchorPoint(ccp(0.5, 0.5))
    n_label:setPosition(ccp(n_sprite:getContentSize().width/2, n_sprite:getContentSize().height*0.45))
    n_sprite:addChild(n_label)

	local h_label = CCLabelTTF:create(fontText, g_sFontPangWa, fontSize_h)
    h_label:setColor(fontColor_h)
    h_label:setAnchorPoint(ccp(0.5, 0.5))
    h_label:setPosition(ccp(h_sprite:getContentSize().width/2, h_sprite:getContentSize().height*0.45))
    h_sprite:addChild(h_label)

    return CCMenuItemSprite:create(n_sprite, h_sprite)
end


