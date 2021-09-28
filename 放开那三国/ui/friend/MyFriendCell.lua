-- FileName: MyFriendCell.lua 
-- Author: Li Cong 
-- Date: 13-8-27 
-- Purpose: function description of module 


module("MyFriendCell", package.seeall)


-- 玩家名字的颜色
function getHeroNameColor( utid )
	local name_color = nil
	local stroke_color = nil
	if(tonumber(utid) == 1)then
		-- 女性玩家
		name_color = ccc3(0xf9,0x59,0xff)
		-- stroke_color = ccc3(0x5c,0x00,0x7a)
		stroke_color = ccc3(0x00,0x00,0x00)
	elseif(tonumber(utid) == 2)then
		-- 男性玩家 
		name_color = ccc3(0x00,0xe4,0xff)
		-- stroke_color = ccc3(0x00,0x2e,0x7a)
		stroke_color = ccc3(0x00,0x00,0x00)
	end
	return name_color, stroke_color
end


-- 创建cell
function createCell( tCellValue )
	-- print("cell数据tCellValue:")
	-- print_t(tCellValue)
	-- 创建cell
 	local cell = CCTableViewCell:create()
	-- 添加更多好友按钮
	-- print("more:",tCellValue.more,type(tCellValue.more))
	if(tCellValue.more == true)then
		-- 创建更多好友按钮
		local moreMenu = BTSensitiveMenu:create()
		if(moreMenu:retainCount()>1)then
			moreMenu:release()
			moreMenu:autorelease()
		end
		moreMenu:setPosition(ccp(0,0))
		cell:addChild(moreMenu)
		local moreMenuItem = FriendLayer.createMoreButtonItem()
		moreMenuItem:setAnchorPoint(ccp(0.5,0))
	    moreMenuItem:setPosition(ccp(302,0))
	    moreMenu:addChild(moreMenuItem)
		-- 注册回调
		moreMenuItem:registerScriptTapHandler(moreMenuItemCallFun)
		return cell
	end
 	-- cell背景
 	local cell_bg = BaseUI.createYellowBg(CCSizeMake(584,110))
 	cell_bg:setAnchorPoint(ccp(0.5,0))
	cell_bg:setPosition(ccp((MyFriendLayer.set_width)/g_fScaleX/2,0))
	cell:addChild(cell_bg)
	-- 名字背景
	local name_bg = CCScale9Sprite:create( FriendLayer.IMG_PATH .. "friend_name_bg.png")
	name_bg:setContentSize(CCSizeMake(330,36))
	name_bg:setAnchorPoint(ccp(0,1))
	name_bg:setPosition(ccp(10,cell_bg:getContentSize().height-10))
	cell_bg:addChild(name_bg)
	-- 名字等级
	-- lv.
	local lv_sprite = CCSprite:create(FriendLayer.COMMON_PATH .. "lv.png")
	lv_sprite:setAnchorPoint(ccp(0,1))
	lv_sprite:setPosition(ccp(16,name_bg:getContentSize().height-10))
	name_bg:addChild(lv_sprite)
	-- 等级
	local lv_data = CCRenderLabel:create( tCellValue.level , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
    lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+5,name_bg:getContentSize().height-8))
   	name_bg:addChild(lv_data)
   	-- 名字
   	-- 玩家名字颜色
	local name_color,stroke_color = getHeroNameColor( tCellValue.utid )
   	local name = CCRenderLabel:create( tCellValue.uname , g_sFontName, 23, 1, stroke_color, type_stroke)
    name:setColor(name_color)
    name:setPosition(ccp(107,name_bg:getContentSize().height-6))
   	name_bg:addChild(name)

   	-- 战斗力
   	local fight_sprite = CCSprite:create(FriendLayer.COMMON_PATH .. "fight_value02.png")
   	fight_sprite:setAnchorPoint(ccp(0,0))
   	fight_sprite:setPosition(ccp(31,14))
   	cell_bg:addChild(fight_sprite)
   	-- 战斗力数据
   	local fight_data = CCRenderLabel:create( tCellValue.fight_force , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fight_data:setColor(ccc3(0xff, 0xf6, 0x00))
    fight_data:setAnchorPoint(ccp(0,0))
    fight_data:setPosition(ccp(133,18))
   	cell_bg:addChild(fight_data)

	-- 在线 or 离线
	local status = tonumber(tCellValue.status)
	if(status == 1)then
		local online_font = CCRenderLabel:create( GetLocalizeStringBy("key_2667") , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    online_font:setColor(ccc3(0x70, 0xff, 0x18))
	    online_font:setAnchorPoint(ccp(0,0))
	    online_font:setPosition(ccp(268,18))
	    cell_bg:addChild(online_font)
	end
    -- 离线
    if(status == 2)then
	    local offline_font = CCRenderLabel:create( GetLocalizeStringBy("key_1192") , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    offline_font:setColor(ccc3(0xad, 0xad, 0xad))
	    offline_font:setAnchorPoint(ccp(0,0))
	    offline_font:setPosition(ccp(268,18))
	    cell_bg:addChild(offline_font)
    end

    -- 交流按钮
	local talkMenu = BTSensitiveMenu:create()
	if(talkMenu:retainCount()>1)then
		talkMenu:release()
		talkMenu:autorelease()
	end
	talkMenu:setPosition(ccp(0,0))
	cell_bg:addChild(talkMenu)
	local talkMenuItem = CCMenuItemImage:create(FriendLayer.IMG_PATH .. "friend_btn_n.png",FriendLayer.IMG_PATH .. "friend_btn_h.png")
	talkMenuItem:setAnchorPoint(ccp(1,0.5))
	talkMenuItem:setPosition(ccp(cell_bg:getContentSize().width-10, cell_bg:getContentSize().height*0.5))
	talkMenu:addChild(talkMenuItem,1,tonumber(tCellValue.uid))
	-- 注册回调
	talkMenuItem:registerScriptTapHandler(talkMenuItemCallFun)
	-- 交流字体
	local item_font = CCRenderLabel:create( GetLocalizeStringBy("key_3339") , g_sFontPangWa, 38, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setAnchorPoint(ccp(0.5,0.5))
    item_font:setPosition(ccp(talkMenuItem:getContentSize().width*0.5,talkMenuItem:getContentSize().height*0.5))
   	talkMenuItem:addChild(item_font)

   	-- 赠送耐力按钮
   	local normalSprite = CCSprite:create(FriendLayer.IMG_PATH .. "give_button_n.png")
	local selectedSprite = CCSprite:create(FriendLayer.IMG_PATH .. "give_button_h.png")
	local disabledSprite = BTGraySprite:create(FriendLayer.IMG_PATH .. "give_button_d.png")
	-- 已赠送字体
	local zeng_sprite = CCSprite:create(FriendLayer.IMG_PATH .. "zeng.png")
	zeng_sprite:setAnchorPoint(ccp(0.5,0))
	zeng_sprite:setPosition(ccp(disabledSprite:getContentSize().width*0.5,0))
	disabledSprite:addChild(zeng_sprite)
	-- 创建MenuItem
	local giveMenuItem = CCMenuItemSprite:create(normalSprite, selectedSprite, disabledSprite)
	giveMenuItem:setAnchorPoint(ccp(1,0.5))
	giveMenuItem:setPosition(ccp(cell_bg:getContentSize().width-144, cell_bg:getContentSize().height*0.5))
	talkMenu:addChild(giveMenuItem,1,tonumber(tCellValue.uid))
	-- 注册回调
	giveMenuItem:registerScriptTapHandler(giveMenuItemCallFun)
	
	-- -- 赠送耐力数字
	-- local num = FriendData.getGiveStaminaNum()
	-- local numStr = "x" .. num
	-- local item_font = CCRenderLabel:create( numStr, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
 	-- item_font:setColor(ccc3(0xff, 0xff, 0xff))
 	-- item_font:setAnchorPoint(ccp(1,1))
	-- item_font:setPosition(ccp(giveMenuItem:getContentSize().width-6,giveMenuItem:getContentSize().height-4))
 	--  giveMenuItem:addChild(item_font)

   	-- 根据时间判断今天是否赠送过
   	local isGive = FriendData.isGiveTodayByTime( tCellValue.lovedTime )
   	if(isGive)then
   		giveMenuItem:setEnabled(false)
   	end
 	return cell
end



-- 交流按钮回调
function talkMenuItemCallFun( tag, item_obj)
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- print(GetLocalizeStringBy("key_2970").. tag)
	require "script/ui/friend/ExchangeLayer"
	ExchangeLayer.showExchangeLayer(tag)
end


-- 更多好友按钮回调
function moreMenuItemCallFun( tag, item_obj )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- print(GetLocalizeStringBy("key_1661"))
	FriendData.friendPage = FriendData.friendPage + 1
	FriendData.showFriendData = FriendData.getShowMyFriendData( FriendData.friendPage )
	local contentOffset = MyFriendLayer.friendTableView:getContentOffset()
	MyFriendLayer.friendTableView:reloadData()
	contentOffset.y = contentOffset.y - (table.count(FriendData.showFriendData)-(FriendData.friendPage-1)*10)*110
	MyFriendLayer.friendTableView:setContentOffset(contentOffset)
end


-- 赠送好友耐力按钮
function giveMenuItemCallFun( tag, item_obj )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	print(GetLocalizeStringBy("key_3359").. tag)
	-- 创建下一步UI
	local function createNext( ... )
		item_obj:setEnabled(false)
	end
	FriendService.giveStaminaService(tag,createNext)
end















