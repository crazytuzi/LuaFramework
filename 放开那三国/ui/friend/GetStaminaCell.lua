-- FileName: GetStaminaCell.lua 
-- Author: Li Cong 
-- Date: 13-12-17 
-- Purpose: function description of module 


module("GetStaminaCell", package.seeall)


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

 	-- 根据好友uid获得好友数据
 	local thisFriendData = FriendData.getThisFriendDataByUid(tCellValue.uid)
 	print(GetLocalizeStringBy("key_1517"))
 	print_t(thisFriendData)
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
	local levelStr = thisFriendData.level or " " 
	local lv_data = CCRenderLabel:create(levelStr, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
    lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+5,name_bg:getContentSize().height-8))
   	name_bg:addChild(lv_data)
   	-- 名字
   	-- 玩家名字颜色
	local name_color,stroke_color = getHeroNameColor( thisFriendData.utid )
	local nameStr = thisFriendData.uname or " "
   	local name = CCRenderLabel:create(  nameStr, g_sFontName, 23, 1, stroke_color, type_stroke)
    name:setColor(name_color)
    name:setPosition(ccp(107,name_bg:getContentSize().height-6))
   	name_bg:addChild(name)

   	-- 战斗力
   	local fight_sprite = CCSprite:create(FriendLayer.COMMON_PATH .. "fight_value02.png")
   	fight_sprite:setAnchorPoint(ccp(0,0))
   	fight_sprite:setPosition(ccp(31,14))
   	cell_bg:addChild(fight_sprite)
   	-- 战斗力数据
   	local fightStr = thisFriendData.fight_force or " "
   	local fight_data = CCRenderLabel:create( fightStr, g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fight_data:setColor(ccc3(0xff, 0xf6, 0x00))
    fight_data:setPosition(ccp(133,43))
   	cell_bg:addChild(fight_data)

	-- 有效时间
	local timeStr = FriendData.getValidTime( tCellValue.time )
	local online_font = CCRenderLabel:create( timeStr , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    online_font:setColor(ccc3(0x70, 0xff, 0x18))
    online_font:setPosition(ccp(358,cell_bg:getContentSize().height-16))
    cell_bg:addChild(online_font)

   
    -- 点击领取按钮
	local menu = BTSensitiveMenu:create()
	if(menu:retainCount()>1)then
		menu:release()
		menu:autorelease()
	end
	menu:setPosition(ccp(0,0))
	cell_bg:addChild(menu,1,tonumber(tCellValue.time))
	local clickItem = CCMenuItemImage:create(FriendLayer.IMG_PATH .. "click_n.png",FriendLayer.IMG_PATH .. "click_h.png")
	clickItem:setAnchorPoint(ccp(1,0.5))
	clickItem:setPosition(ccp(cell_bg:getContentSize().width-40, cell_bg:getContentSize().height*0.5))
	menu:addChild(clickItem,1,tonumber(tCellValue.uid))
	-- 注册回调
	clickItem:registerScriptTapHandler(clickMenuItemCallFun)
	-- 赠送耐力数字
	local num = FriendData.getGiveStaminaNum() or " "
	local numStr = "x" .. num 
	local item_font = CCRenderLabel:create( numStr, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    item_font:setColor(ccc3(0xff, 0xff, 0xff))
    item_font:setAnchorPoint(ccp(1,1))
    item_font:setPosition(ccp(clickItem:getContentSize().width-6,clickItem:getContentSize().height-4))
   	clickItem:addChild(item_font)

 	return cell
end


-- 点击领取按钮回调
function clickMenuItemCallFun( tag, item_obj)
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- print(GetLocalizeStringBy("key_2970").. tag)
	local time = item_obj:getParent():getTag()
	print("time ---",time)
	-- 创建下一步UI
	local function createNext( ... )
		-- 更新可领取列表
		FriendData.receiveListInfo = FriendData.getReceiveList()
		GetStaminaLayer.reciveTableView:reloadData()
		-- 更新剩余次数
		GetStaminaLayer.upDateCanReciveNumFont()
		-- -- 刷新小红圈数字
		-- require "script/utils/ItemDropUtil"
		-- local times = FriendData.getTodayReceiveTimes()
		-- if(not table.isEmpty(FriendData.receiveListInfo))then
		-- 	if(times > 0)then
		-- 		-- 好友图标红圈
		-- 		FriendData.setShowTipSprite(true)
		-- 	else
		-- 		-- 好友图标红圈
		-- 		FriendData.setShowTipSprite(false)
		-- 	end
		-- 	-- 刷新小红圈数字
		-- 	ItemDropUtil.refreshNum( FriendLayer.m_tipSprite, table.count( FriendData.receiveListInfo ) )
		-- 	-- 设置小红圈数量
		-- 	FriendData.setReceiveListCount( table.count( FriendData.receiveListInfo ) )
		-- else
		-- 	FriendLayer.m_tipSprite:setVisible(false)
		-- 	-- 好友图标红圈
		-- 	FriendData.setShowTipSprite(false)
		-- 	-- 设置小红圈数量
		-- 	FriendData.setReceiveListCount( table.count( FriendData.receiveListInfo ) )
		-- end
	end
	FriendService.receiveStaminaService(time,tag,createNext)
end







