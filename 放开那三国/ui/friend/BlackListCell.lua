-- FileName: BlackListCell.lua 
-- Author: licong 
-- Date: 14-6-10 
-- Purpose: 黑名单cell


module("BlackListCell", package.seeall)

-- 玩家名字的颜色
local function getHeroNameColor( utid )
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

-- 发请求
local function sendService( isConfirm, uid )
	if(isConfirm == false)then
		return 
	end
	-- 创建下一步UI
	local function createNext( ... )
		-- 从黑名单删除
		FriendData.deleteBlacekDataByUid(uid)
		-- 刷新黑名单列表
		BlackListLayer.refreshTableView()
		-- 刷新黑名单数量
		BlackListLayer.refreshCurNumFont()
	end
	FriendService.unBlackYou(uid,createNext)
end

-- 解除黑名单
local function menuBarItemCallFun( tag, item_obj )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	print("解除 uid".. tag)

	require "script/ui/tip/AlertTip"
	local str = GetLocalizeStringBy("lic_1054")
	AlertTip.showAlert(str,sendService,true,tag)
end

-- 创建cell
function createCell( tCellValue )
	-- print("cell数据tCellValue:")
	-- print_t(tCellValue)
	-- 创建cell
 	local cell = CCTableViewCell:create()

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
    fight_data:setPosition(ccp(133,43))
   	cell_bg:addChild(fight_data)

	-- 在线 or 离线
	local status = tonumber(tCellValue.status)
	if(status == 1)then
		-- 在线
		local online_font = CCRenderLabel:create( GetLocalizeStringBy("key_2667") , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    online_font:setColor(ccc3(0x70, 0xff, 0x18))
	    online_font:setAnchorPoint(ccp(0,0))
	    online_font:setPosition(ccp(268,18))
	    cell_bg:addChild(online_font)
    elseif(status == 2)then
    	-- 离线
	    local offline_font = CCRenderLabel:create( GetLocalizeStringBy("key_1192") , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    offline_font:setColor(ccc3(0xad, 0xad, 0xad))
	    offline_font:setAnchorPoint(ccp(0,0))
	    offline_font:setPosition(ccp(268,18))
	    cell_bg:addChild(offline_font)
	else
		print("status error")
    end

    -- 解除按钮
	local menuBar = BTSensitiveMenu:create()
	if(menuBar:retainCount()>1)then
		menuBar:release()
		menuBar:autorelease()
	end
	menuBar:setPosition(ccp(0,0))
	cell_bg:addChild(menuBar)
	local menuBarItem = CCMenuItemImage:create(FriendLayer.IMG_PATH .. "friend_btn_n.png",FriendLayer.IMG_PATH .. "friend_btn_h.png")
	menuBarItem:setAnchorPoint(ccp(1,0.5))
	menuBarItem:setPosition(ccp(cell_bg:getContentSize().width-30, cell_bg:getContentSize().height*0.5))
	menuBar:addChild(menuBarItem,1,tonumber(tCellValue.uid))
	-- 注册回调
	menuBarItem:registerScriptTapHandler(menuBarItemCallFun)
	-- 解除字体
	local item_font = CCRenderLabel:create( GetLocalizeStringBy("lic_1051") , g_sFontPangWa, 38, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setPosition(ccp(21,menuBarItem:getContentSize().height-15))
   	menuBarItem:addChild(item_font)

 	return cell
end
















