-- FileName: GuildListCell.lua 
-- Author: Li Cong 
-- Date: 13-12-21 
-- Purpose: function description of module 

require "script/ui/guild/GuildDataCache"
module("GuildListCell", package.seeall)

-- 存放军团长性别tab
local tabArr = {}

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

-- 创建更多按钮
function createMoreButtonItem()
	local normalSprite = BaseUI.createYellowBg(CCSizeMake(640,212))
    local selectSprite = BaseUI.createYellowSelectBg(CCSizeMake(640,212))
    local item = CCMenuItemSprite:create(normalSprite,selectSprite)
    -- 红条
    local sprite = CCSprite:create("images/common/red_line.png")
	sprite:setAnchorPoint(ccp(0.5,0.5))
	sprite:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height*0.5))
	item:addChild(sprite)
    -- 字体
	local item_font = CCRenderLabel:create( GetLocalizeStringBy("key_2989") , g_sFontPangWa, 35,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	item_font:setAnchorPoint(ccp(0.5,0.5))
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setPosition(ccp(sprite:getContentSize().width*0.5,sprite:getContentSize().height*0.5))
   	sprite:addChild(item_font)
   	return item
end

-- 创建cell
function createCell( tCellValue, isHaveGuild )
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
		local moreMenuItem = createMoreButtonItem()
		moreMenuItem:setAnchorPoint(ccp(0.5,0))
	    moreMenuItem:setPosition(ccp(320,0))
	    moreMenu:addChild(moreMenuItem,1,tonumber(tCellValue.offset))
		-- 注册回调
		moreMenuItem:registerScriptTapHandler(moreMenuItemCallFun)
		return cell
	end
 	-- cell背景
 	local cell_bg = CCSprite:create("images/guild/guildList/list_bg_2.png")
 	cell_bg:setAnchorPoint(ccp(0.5,0))
	cell_bg:setPosition(ccp(320,0))
	cell:addChild(cell_bg)

	-- title
	local fullRect = CCRectMake(0, 0, 105, 44)
	local insetRect = CCRectMake(43, 17, 16, 4)
	local cell_bg_title = CCScale9Sprite:create("images/guild/guildList/list_bg_title.png",fullRect,insetRect)
	cell_bg_title:setContentSize(CCSizeMake(370,46))
 	cell_bg_title:setAnchorPoint(ccp(0.5,0.5))
	cell_bg_title:setPosition(ccp(cell_bg:getContentSize().width*0.5,cell_bg:getContentSize().height-23))
	cell:addChild(cell_bg_title,10)

	-- 军团名字 
	local str = tCellValue.guild_name or " "
	local guild_name = CCRenderLabel:create( str, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    guild_name:setColor(ccc3( 0xff, 0xff, 0xff))
    guild_name:setAnchorPoint(ccp(0,0.5))
   	cell_bg_title:addChild(guild_name)
	-- 军团等级
	local lv_sprite = CCSprite:create("images/common/lv.png")
	lv_sprite:setAnchorPoint(ccp(0,0.5))
	cell_bg_title:addChild(lv_sprite)
	local str = tCellValue.guild_level or " "
	local lv_data = CCRenderLabel:create(  str, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lv_data:setAnchorPoint(ccp(0,0.5))
    lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
   	cell_bg_title:addChild(lv_data)

   	local posX = (cell_bg_title:getContentSize().width-guild_name:getContentSize().width-lv_sprite:getContentSize().width-lv_data:getContentSize().width-15)*0.5
    guild_name:setPosition(ccp(posX,cell_bg_title:getContentSize().height*0.5))
	lv_sprite:setPosition(ccp(guild_name:getPositionX()+guild_name:getContentSize().width+10,cell_bg_title:getContentSize().height*0.5))
    lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+5,cell_bg_title:getContentSize().height*0.5))



   	-- 军团排名
   	local rank_data = " "
   	if(tCellValue.rank)then
   		rank_data = tonumber( tCellValue.rank )
   	end
   	local rank_font = CCRenderLabel:create(  rank_data, g_sFontPangWa, 28, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    rank_font:setAnchorPoint(ccp(0.5,0))
    rank_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    rank_font:setPosition(ccp(55,96))
   	cell_bg:addChild(rank_font)
   	
   	-- 按钮
   	local menu = BTSensitiveMenu:create()
   	if(menu:retainCount()>1)then
		menu:release()
		menu:autorelease()
	end
   	menu:setPosition(ccp(0,0))
	cell_bg:addChild(menu)

   	-- 军团长名字颜色  按钮
   	local leader_sprite = CCSprite:create("images/guild/guildList/commander_font.png")
   	leader_sprite:setAnchorPoint(ccp(1,0))
   	leader_sprite:setPosition(ccp(226,136))
   	cell_bg:addChild(leader_sprite)
   	-- 军团长名字按钮
	local name_color,stroke_color = getHeroNameColor( tCellValue.leader_utid or 1 )
	local str = tCellValue.leader_name or "xxx"
   	local leader_nameItem = CCMenuItemFont:create( str )
	leader_nameItem:setAnchorPoint(ccp(0,1))
	leader_nameItem:setFontNameObj(g_sFontName)
    leader_nameItem:setFontSizeObj(21)
    leader_nameItem:setColor(name_color)
	leader_nameItem:setPosition(ccp(239,cell_bg:getContentSize().height-50))
	menu:addChild(leader_nameItem,1,tonumber(tCellValue.leader_uid))
	-- 存放军团长的名字，性别，战斗力
	tabArr[tostring(tCellValue.leader_uid)] = {}
	local dressId = nil
	if( not table.isEmpty(tCellValue.leader_dress) and (tCellValue.leader_dress["1"])~= nil and tonumber(tCellValue.leader_dress["1"]) > 0 )then
		dressId = tCellValue.leader_dress["1"]
	end
	tabArr[tostring(tCellValue.leader_uid)].dressId = dressId
	tabArr[tostring(tCellValue.leader_uid)].htid = tCellValue.leader_htid 
	tabArr[tostring(tCellValue.leader_uid)].uname = tCellValue.leader_name or " "
	tabArr[tostring(tCellValue.leader_uid)].fight = tCellValue.leader_force or 0
	tabArr[tostring(tCellValue.leader_uid)].ulevel = tCellValue.leader_level or 1
	-- 注册回调
	leader_nameItem:registerScriptTapHandler(leader_nameItemCallFun)
    -- local leaderLv_sprite = CCSprite:create("images/common/lv.png")
	-- leaderLv_sprite:setAnchorPoint(ccp(0,1))
	-- leaderLv_sprite:setPosition(ccp(366,cell_bg:getContentSize().height-68))
	-- cell_bg:addChild(leaderLv_sprite)
	local leader_lvFont = CCRenderLabel:create( "Lv.", g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    leader_lvFont:setColor(ccc3( 0xff, 0xf6, 0x00))
    leader_lvFont:setAnchorPoint(ccp(0,1))
    leader_lvFont:setPosition(ccp(426,cell_bg:getContentSize().height-50))
   	cell_bg:addChild(leader_lvFont)
	local str = tCellValue.leader_level or " "
   	local leaderLv_data = CCRenderLabel:create( str , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    leaderLv_data:setAnchorPoint(ccp(0,1))
    leaderLv_data:setColor(ccc3(0xff, 0xf6, 0x00))
    leaderLv_data:setPosition(ccp(leader_lvFont:getPositionX()+leader_lvFont:getContentSize().width+5,cell_bg:getContentSize().height-50))
   	cell_bg:addChild(leaderLv_data)

	-- 成员
	local member_sprite = CCSprite:create("images/guild/guildList/member_font.png")
   	member_sprite:setAnchorPoint(ccp(1,0))
   	member_sprite:setPosition(ccp(226,100))
   	cell_bg:addChild(member_sprite)
   	local str1 = tCellValue.member_num or " "
   	local str2 = tCellValue.member_limit or " "
	local member_data = CCRenderLabel:create(  str1 .. "/" .. str2 , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    member_data:setAnchorPoint(ccp(0,0))
    member_data:setColor(ccc3(0x00, 0xff, 0x18))
    member_data:setPosition(ccp(239,104))
   	cell_bg:addChild(member_data) 

   	-- aded by zhz
   	-- 军团战斗力
   	local fightForce= CCSprite:create("images/guild/guildList/guild_force.png")
   	fightForce:setAnchorPoint(ccp(1,0))
   	fightForce:setPosition(ccp(226,60))
   	cell_bg:addChild(fightForce)

   	local fightForcedata = CCRenderLabel:create( tCellValue.fight_force or "0" , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fightForcedata:setAnchorPoint(ccp(0,0))
    fightForcedata:setColor(ccc3(0xff, 0xf6, 0x00))
    fightForcedata:setPosition(ccp(239,67))
   	cell_bg:addChild(fightForcedata) 

    -- 申请按钮
    -- 没有加入军团时显示申请按钮
    if(not isHaveGuild)then
		local applyMenuItem = CCMenuItemImage:create("images/guild/guildList/btn_bg_n.png","images/guild/guildList/btn_bg_h.png")
		applyMenuItem:setAnchorPoint(ccp(1,0.5))
		applyMenuItem:setPosition(ccp(cell_bg:getContentSize().width-28, 118))
		menu:addChild(applyMenuItem,1,tonumber(tCellValue.guild_id))
		-- 注册回调
		applyMenuItem:registerScriptTapHandler(applyMenuItemCallFun)
		-- 申请按钮上的字体
		local isHaveApply = GuildListLayer.isHaveApplyGuildByGuildID( tCellValue.guild_id )
		if( isHaveApply )then
			local item_font = CCRenderLabel:create( GetLocalizeStringBy("key_1646") , g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
		    item_font:setAnchorPoint(ccp(0.5,0.5))
		    item_font:setPosition(ccp(applyMenuItem:getContentSize().width*0.5,applyMenuItem:getContentSize().height*0.5))
		   	applyMenuItem:addChild(item_font)
		else
			local item_font = CCRenderLabel:create( GetLocalizeStringBy("key_2102") , g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
		    item_font:setAnchorPoint(ccp(0.5,0.5))
		    item_font:setPosition(ccp(applyMenuItem:getContentSize().width*0.5,applyMenuItem:getContentSize().height*0.5))
		   	applyMenuItem:addChild(item_font)
		end
	end

   	-- 军团宣言
   	local say_sprite = CCSprite:create("images/guild/guildList/guildSay.png")
   	say_sprite:setAnchorPoint(ccp(1,0.5))
   	say_sprite:setPosition(ccp(124,42))
   	cell_bg:addChild(say_sprite)
   	local str = tCellValue.slogan or " "
   	local say_font = CCRenderLabel:create( str , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    say_font:setAnchorPoint(ccp(0,0))
    say_font:setColor(ccc3(0xff, 0xff, 0xff))
    say_font:setPosition(ccp(153,32))
   	cell_bg:addChild(say_font)

 	return cell
end


-- 军团长名字回调
function leader_nameItemCallFun( tag, item_obj )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	print(GetLocalizeStringBy("key_1852") .. tag)
	local htid =  tabArr[tostring(tag)].htid 
	local uname =  tabArr[tostring(tag)].uname or " "
	local power =  tabArr[tostring(tag)].fight or 0
	local ulevel =  tabArr[tostring(tag)].ulevel or 0
	local dressId =  tabArr[tostring(tag)].dressId
	require "script/ui/guild/AddAndChat"
    require "script/model/utils/HeroUtil"
    local heroIcon = HeroUtil.getHeroIconByHTID(htid, dressId)
    AddAndChat.showAddAndChatLayer(uname,ulevel,power,heroIcon,tag,uGender)
end


-- 申请按钮回调
function applyMenuItemCallFun( tag, item_obj)
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    local isHaveApply = GuildListLayer.isHaveApplyGuildByGuildID( tag )
	if( isHaveApply )then
	    -- 取消接口参数
	    -- 取消申请军团请求回调
		local function getCancelApplyCallback(  cbFlag, dictData, bRet  )
			if(dictData.err == "ok")then
				print(GetLocalizeStringBy("key_1250"))
				print_t(dictData.ret)
				if( dictData.ret == "ok")then
					-- 军团请求回调
					local function getNewGuildListCallback(  cbFlag, dictData, bRet  )
						if(dictData.err == "ok")then
							print(GetLocalizeStringBy("key_2610"))
							print_t(dictData.ret)
							if(not table.isEmpty(dictData.ret))then
								-- 军团总个数
								GuildListLayer.m_guildCount = tonumber( dictData.ret.count )
								-- 军团前10条数据
								GuildListLayer.setGuildListData( dictData.ret.data, dictData.ret.offset )
								-- 设置已经申请的军团数据
								GuildListLayer.setApplyedGuildData( dictData.ret.appnum )
								-- 更新军团列表
								GuildListLayer.m_listTabViewInfo = GuildListLayer.getGuildListData()
								GuildListLayer.m_listTableView:reloadData()
							end
						end
					end
					-- 列表数据
					local args = CCArray:create()
					args:addObject(CCInteger:create(0))
					args:addObject(CCInteger:create(10))
					RequestCenter.guild_getGuildList(getNewGuildListCallback,args)
				end
			end
		end
		local args = CCArray:create()
		args:addObject(CCInteger:create(tag))
		RequestCenter.guild_cancelApply(getCancelApplyCallback,args)
	else
		-- 已经申请3个了不可以申请
		local applyTab = GuildListLayer.getApplyGuildData()
		if(table.count(applyTab) >= 3)then
			require "script/ui/tip/AnimationTip"
			local str = GetLocalizeStringBy("key_1122")
			AnimationTip.showTip(str)
			return
		end
		-- 冷却时间中 不能申请
		local myData = GuildDataCache.getMineSigleGuildInfo()
		-- 当前服务器时间  当前时间大于cd时间戳时是可以进行申请操作的
        local curServerTime = TimeUtil.getSvrTimeByOffset()
        print("冷却时间...",curServerTime)
        print_t(myData)
		if(myData)then
			print("0.0.0.",myData.rejoin_cd)
			if(myData.rejoin_cd)then
				if( curServerTime < tonumber(myData.rejoin_cd) ) then
					require "script/ui/tip/AnimationTip"
					local str = GetLocalizeStringBy("key_1426")
					AnimationTip.showTip(str)
					return
				end
			end
		end
		-- 申请军团请求回调
		local function getApplyCallback(  cbFlag, dictData, bRet  )
			if(dictData.err == "ok")then
				print(GetLocalizeStringBy("key_1540"))
				print_t(dictData.ret)
				if( dictData.ret == "ok")then
					-- 修改申请后列表数据
					GuildListLayer.AfterApplyServiceData( tag )
					-- 更新军团列表
					GuildListLayer.m_listTabViewInfo = GuildListLayer.getGuildListData()
					local contentOffset = GuildListLayer.m_listTableView:getContentOffset()
					GuildListLayer.m_listTableView:reloadData()
					print("contentOffset",contentOffset.y)
					GuildListLayer.m_listTableView:setContentOffset(contentOffset)
				end
			end
		end
		-- 申请接口参数
		local args = CCArray:create()
		args:addObject(CCInteger:create(tag))
		RequestCenter.guild_applyGuild(getApplyCallback,args)
	end
end


-- 军团请求回调
function getMoreGuildListCallback(  cbFlag, dictData, bRet  )
	if(dictData.err == "ok")then
		print(GetLocalizeStringBy("key_1474"))
		print_t(dictData.ret)
		if(not table.isEmpty(dictData.ret))then
			-- 军团总个数
			GuildListLayer.m_guildCount = tonumber( dictData.ret.count )
			-- 军团10条数据
			GuildListLayer.setGuildListData( dictData.ret.data, dictData.ret.offset )
			-- 更新军团列表
			GuildListLayer.m_listTabViewInfo = GuildListLayer.getGuildListData()
			local contentOffset = GuildListLayer.m_listTableView:getContentOffset()
			print("contentOffset",contentOffset.y)
			GuildListLayer.m_listTableView:reloadData()
			contentOffset.y = contentOffset.y - table.count(dictData.ret.data)*212
			GuildListLayer.m_listTableView:setContentOffset(contentOffset)
		end
	end
end

-- 更多军团按钮回调
function moreMenuItemCallFun( tag, item_obj )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	
	if(GuildListLayer.m_isSerch)then
		-- 搜索请求回调
		local function searchGuildCallback(  cbFlag, dictData, bRet  )
			if(dictData.err == "ok")then
				print(GetLocalizeStringBy("key_2657"))
				print_t(dictData.ret)
				if(not table.isEmpty(dictData.ret))then
					-- 军团总个数
					GuildListLayer.m_guildCount = tonumber( dictData.ret.count )
					-- 军团前10条数据
					GuildListLayer.setGuildListData( dictData.ret.data, dictData.ret.offset )
					-- 更新军团列表
					GuildListLayer.m_listTabViewInfo = GuildListLayer.getGuildListData()
					local contentOffset = GuildListLayer.m_listTableView:getContentOffset()
					print("contentOffset",contentOffset.y)
					GuildListLayer.m_listTableView:reloadData()
					contentOffset.y = contentOffset.y - table.count(dictData.ret.data)*212
					GuildListLayer.m_listTableView:setContentOffset(contentOffset)
				end
			end
		end
		-- 列表数据
		local args = CCArray:create()
		args:addObject(CCInteger:create(tag))
		args:addObject(CCInteger:create(10))
		args:addObject(CCString:create(GuildListLayer.m_serchName))
		RequestCenter.guild_getGuildListByName(searchGuildCallback,args)
	else
		-- 列表数据
		local args = CCArray:create()
		args:addObject(CCInteger:create(tag))
		args:addObject(CCInteger:create(10))
		RequestCenter.guild_getGuildList(getMoreGuildListCallback,args)
	end
end


