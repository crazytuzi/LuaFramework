-- FileName: GuildListLayer.lua 
-- Author: Li Cong 
-- Date: 13-12-21 
-- Purpose: function description of module 

require "script/ui/guild/GuildDataCache"
require "script/ui/guild/GuildUtil"
require "script/model/user/UserModel"
module("GuildListLayer", package.seeall)

local _bgLayer 					= nil
local _btnFrameSp 				= nil   -- 按钮背景
local isHaveGuild 				= nil 	-- 自己是否加入军团
local _editBox 					= nil   -- 搜索编辑框
local tableView_width           = 0     -- 滑动列表的宽
local tableView_hight 			= 0 	-- 滑动列表的高
local _bottomSpite 				= nil 	-- 已经加入军团玩家的下排按钮
---------------------- 数据 -----------------------------------
local _guildListInfo 			= nil	-- 军团列表缓存信息
local _applyTab 				= {} 	-- 已经申请的军团tab
local _CDTime  					= 0     -- 军团操作CD时间
local scheduleId 				= nil   -- 定时器id
-----------------------------------------------------------
m_guildCount 					= 0 	-- 军团总个数
m_listTableView      			= nil 	-- 军团列表
m_listTabViewInfo 				= nil 	-- 创建军团列表用的数据
m_isSerch						= nil 	-- 是否是搜索
m_serchName						= nil 	-- 搜索名字
-- m_offset						= 0     -- 拉取军团列表的便宜量

-- 初始化
function init( ... )
	_bgLayer 					= nil
	_btnFrameSp 				= nil   -- 按钮背景
	_guildListInfo 				= nil	-- 军团列表信息
	m_listTableView      		= nil 	-- 军团列表
	m_listTabViewInfo 			= nil 	-- 创建军团列表用的数据
	isHaveGuild 				= nil 	-- 自己是否加入军团
	_editBox 					= nil   -- 搜索编辑框
	tableView_width          	= 0     -- 滑动列表的宽
	tableView_hight 			= 0 	-- 滑动列表的高
	m_guildCount 				= 0 	-- 军团总个数
	_applyTab 					= {} 	-- 已经申请的军团tab
	_bottomSpite 				= nil 	-- 已经加入军团玩家的下排按钮
	m_isSerch					= nil 	-- 是否是搜索
	m_serchName					= nil 	-- 搜索名字
	-- m_offset					= 0     -- 拉取军团列表的便宜量
end

---------------------------------------------------------------------------
-- 创建上方UI
function createTop( ... )
	--按钮背景
    local fullRect = CCRectMake(0,0,58,99)
	local insetRect = CCRectMake(20,20,18,59)
	_btnFrameSp = CCScale9Sprite:create("images/common/menubg.png", fullRect, insetRect)
	_btnFrameSp:setPreferredSize(CCSizeMake(640, 100))
	_btnFrameSp:setAnchorPoint(ccp(0.5, 1))
	_btnFrameSp:setPosition(ccp(_bgLayer:getContentSize().width/2 , _bgLayer:getContentSize().height))
	_btnFrameSp:setScale(g_fScaleX/MainScene.elementScale)
	_bgLayer:addChild(_btnFrameSp,10)

	-- 上分界线
	local topSeparator = CCSprite:create( "images/common/separator_top.png" )
	topSeparator:setAnchorPoint(ccp(0.5,1))
	topSeparator:setPosition(ccp(_btnFrameSp:getContentSize().width*0.5,_btnFrameSp:getContentSize().height))
	_btnFrameSp:addChild(topSeparator)

	-- 创建按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0, 0))
	_btnFrameSp:addChild(menuBar)

	-- 军团列表按钮
	local listMenuItem = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("key_1386"),30,30)
	listMenuItem:setAnchorPoint(ccp(0, 0))
	listMenuItem:setPosition(ccp(_btnFrameSp:getContentSize().width*0.02, _btnFrameSp:getContentSize().height*0.1))
	listMenuItem:registerScriptTapHandler(menuBarItemAction)
	menuBar:addChild(listMenuItem, 1, 10001)
	-- 默认选中状态
	listMenuItem:setEnabled(false)
	listMenuItem:selected()

	-- 创建军团按钮
	local newGuildMenuItem = CCMenuItemImage:create("images/guild/guildList/newGuild_n.png","images/guild/guildList/newGuild_h.png")
	newGuildMenuItem:setAnchorPoint(ccp(0, 0))
	newGuildMenuItem:registerScriptTapHandler(menuBarItemAction)
	newGuildMenuItem:setAnchorPoint(ccp(1,0.5))
	newGuildMenuItem:setPosition(ccp(_btnFrameSp:getContentSize().width-135,_btnFrameSp:getContentSize().height*0.5))
	--创建军团按钮与军团排行榜按钮大小不一致，按照排行榜，缩小一些
	--add by dengjianan
	newGuildMenuItem:setScale(0.8)
	menuBar:addChild(newGuildMenuItem,1,10002)

	-- 创建军团按钮状态
	if( isHaveGuild )then
		newGuildMenuItem:setVisible(false)
	else
		newGuildMenuItem:setVisible(true)
	end
	
	-- 创建关闭按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(0, 0))
	closeMenuItem:registerScriptTapHandler(menuBarItemAction)
	closeMenuItem:setAnchorPoint(ccp(1,0.5))
	closeMenuItem:setPosition(ccp(_btnFrameSp:getContentSize().width-20,_btnFrameSp:getContentSize().height*0.5))
	menuBar:addChild(closeMenuItem,1,10003)

	--军团排行榜入口 
	--added by Zhang Zihang
	local rankMenuItem = CCMenuItemImage:create("images/match/paihang_n.png","images/match/paihang_h.png")
	rankMenuItem:setAnchorPoint(ccp(1,0.5))
	rankMenuItem:setPosition(ccp(_btnFrameSp:getContentSize().width-150-closeMenuItem:getContentSize().width,_btnFrameSp:getContentSize().height/2))
	rankMenuItem:registerScriptTapHandler(rankButtonCallBack)
	--图片略大，缩小些
	rankMenuItem:setScale(0.8)
	menuBar:addChild(rankMenuItem)

	-- 创建军团操作CD时间
	-- 冷却时间中 不能操作
	local myData = GuildDataCache.getMineSigleGuildInfo()
	-- 当前服务器时间  当前时间大于cd时间戳时是可以进行申请操作的
    local curServerTime = TimeUtil.getSvrTimeByOffset()
    -- print("冷却时间...",curServerTime)
    -- print_t(myData)
	if(myData)then
		print("0.0.0.",myData.rejoin_cd)
		if(myData.rejoin_cd)then
			if( curServerTime < tonumber(myData.rejoin_cd) ) then
				local timeDownFont = CCRenderLabel:create( GetLocalizeStringBy("key_1078") , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			    timeDownFont:setColor(ccc3(0x00, 0xff, 0x18))
			    timeDownFont:setAnchorPoint(ccp(0,0))
			    timeDownFont:setPosition(ccp(listMenuItem:getPositionX()+listMenuItem:getContentSize().width+15, 20))
			   	_btnFrameSp:addChild(timeDownFont)
			   	timeDown = CCLabelTTF:create( " ", g_sFontName, 20)
			    timeDown:setColor(ccc3(0x00, 0xff, 0x18))
			    timeDown:setAnchorPoint(ccp(0,0))
			    timeDown:setPosition(ccp(timeDownFont:getPositionX()+timeDownFont:getContentSize().width+5, 18))
			   	_btnFrameSp:addChild(timeDown)
			   	-- 倒计时数据
			   	local downTimeData = tonumber(myData.rejoin_cd) - curServerTime
				-- 倒计时时间小于等于0 不在cd中
				if( downTimeData <= 0 )then
					-- 不在cd中不显示
					timeDownFont:setVisible(false)
					timeDown:setVisible(false)
				else
					-- 倒计时大于0 在cd中 显示倒计时
					local timeStr = TimeUtil.getTimeString(downTimeData)
					timeDown:setString(timeStr)
				end
				-- 更新倒计时
				local function updateTime()
					-- print("updateTime")
					downTimeData = downTimeData - 1
					if( downTimeData <= 0) then 
						-- cd结束不显示
						timeDownFont:setVisible(false)
						timeDown:setVisible(false)
						-- 到期取消定时器
						if(scheduleId ~= nil)then
							CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleId)
							scheduleId = nil
						end
						return
					end
					local timeStr = TimeUtil.getTimeString(downTimeData)
					-- print(timeStr)
					timeDown:setString(timeStr)
				end
				timeDown:registerScriptHandler(function ( eventType,node )
			   		if(eventType == "enter") then
			   			if (downTimeData > 0 ) then 
					   		-- 启动定时器 只能启动一次
					   		if( scheduleId == nil )then
					   			scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTime, 1, false)
					   		end
			   			end
			   		end
					if(eventType == "exit") then
						if(scheduleId ~= nil)then
			   				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleId)
			   				scheduleId = nil
				   		end
					end
				end)
			end
		end
	end
end

-- 上方按钮背景 按钮action
function menuBarItemAction( tag, item )
	if( tag == 10001 )then
		print(GetLocalizeStringBy("key_1386"))
	elseif( tag == 10002 )then
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		-- 是否够创建军团等级
		local needLv = GuildUtil.getCreateGuildNeedLevel()
		if( UserModel.getHeroLevel() < needLv)then
			require "script/ui/tip/AnimationTip"
			local str = GetLocalizeStringBy("key_2313") .. needLv .. GetLocalizeStringBy("key_1301")
			AnimationTip.showTip(str)
			return
		end
		-- 冷却时间中 不能操作
		local myData = GuildDataCache.getMineSigleGuildInfo()
		-- 当前服务器时间  当前时间大于cd时间戳时是可以进行申请操作的
        local curServerTime = TimeUtil.getSvrTimeByOffset()
        -- print("冷却时间...",curServerTime)
        -- print_t(myData)
		if(myData)then
			print("0.0.0.",myData.rejoin_cd)
			if(myData.rejoin_cd)then
				if( curServerTime < tonumber(myData.rejoin_cd) ) then
					require "script/ui/tip/AnimationTip"
					local str = GetLocalizeStringBy("key_2216")
					AnimationTip.showTip(str)
					return
				end
			end
		end
		print(GetLocalizeStringBy("key_2941"))
		require "script/ui/guild/ShowGuildLayer"
		ShowGuildLayer.showLayer()
	elseif( tag == 10003 )then
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/guanbi.mp3")
		print(GetLocalizeStringBy("key_1868"))
		if(isHaveGuild)then
			require "script/ui/guild/GuildMainLayer"
			local guildMainLayer = GuildMainLayer.createLayer(false)
			MainScene.changeLayer(guildMainLayer, "guildMainLayer")
		else
			-- 打开主界面
			require "script/ui/main/MainBaseLayer"
			local main_base_layer = MainBaseLayer.create()
			MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
			MainScene.setMainSceneViewsVisible(true,true,true)
		end
	else
		return
	end
end


----------------------------------------------------------------------------------------
-- 创建中间 军团列表
function createMainUI( ... )

	-- 搜索输入框
    local editBox_bg = CCScale9Sprite:create("images/guild/guildList/search_bg.png")
    editBox_bg:setContentSize(CCSizeMake(415,37))
    -- 编辑框
    _editBox = CCEditBox:create(CCSizeMake(406,37), editBox_bg)
    _editBox:setMaxLength(40)
    _editBox:setReturnType(kKeyboardReturnTypeDone)
    _editBox:setInputFlag(kEditBoxInputFlagInitialCapsWord)
    _editBox:setPlaceHolder(GetLocalizeStringBy("key_1721"))
    _editBox:setFont(g_sFontName, 23)
    _editBox:setFontColor(ccc3(0xc3,0xc3,0xc3))
    _editBox:setAnchorPoint(ccp(0,0.5))
    _editBox:setPosition(ccp(20*MainScene.elementScale, _bgLayer:getContentSize().height-_btnFrameSp:getContentSize().height*MainScene.elementScale-30*MainScene.elementScale))
    _bgLayer:addChild(_editBox)
    _editBox:setScale(g_fScaleX/MainScene.elementScale)
    -- 搜索按钮
    local searchMenu = CCMenu:create()
    searchMenu:setTouchPriority(-133)
    searchMenu:setPosition(ccp(0,0))
    searchMenu:setAnchorPoint(ccp(0, 0))
    _bgLayer:addChild(searchMenu)
    local searchMenuItem = CCMenuItemImage:create("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png")
	searchMenuItem:setAnchorPoint(ccp(1,0.5))
	searchMenuItem:setPosition(MainScene.getMenuPositionInTruePoint(_bgLayer:getContentSize().width-42*MainScene.elementScale, _bgLayer:getContentSize().height-_btnFrameSp:getContentSize().height*MainScene.elementScale-30*MainScene.elementScale))
	searchMenu:addChild(searchMenuItem)
	-- 注册挑战回调
	searchMenuItem:registerScriptTapHandler(searchMenuItemCallFun)
	-- 搜索字体
	--兼容东南亚英文版
	local item_font
    if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    	item_font = CCRenderLabel:create( GetLocalizeStringBy("key_2908") , g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    else
    	item_font = CCRenderLabel:create( GetLocalizeStringBy("key_2908") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    end
	item_font:setAnchorPoint(ccp(0.5,0.5))
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setPosition(ccp(searchMenuItem:getContentSize().width*0.5,searchMenuItem:getContentSize().height*0.5))
   	searchMenuItem:addChild(item_font)

   	-- 分界线
	local topSeparator = CCSprite:create( "images/common/separator_top.png" )
	topSeparator:setAnchorPoint(ccp(0.5,1))
	topSeparator:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height-_btnFrameSp:getContentSize().height*MainScene.elementScale-65*MainScene.elementScale)) ---searchMenuItem:getContentSize().height*0.5*searchMenuItem:getScale()/MainScene.elementScale))
	_bgLayer:addChild(topSeparator,3)
	topSeparator:setScale(g_fScaleX/MainScene.elementScale)

	tableView_width = _bgLayer:getContentSize().width/MainScene.elementScale
	tableView_hight = topSeparator:getPositionY()/MainScene.elementScale-10*MainScene.elementScale
end

-- 搜索军团按钮回调
function searchMenuItemCallFun( ... )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local name = _editBox:getText()
	if(name == "")then
		require "script/ui/tip/AnimationTip"
		local str = GetLocalizeStringBy("key_2221")
		AnimationTip.showTip(str)
		return
	end
	m_isSerch = true
	-- 搜索请求回调
	local function searchGuildCallback(  cbFlag, dictData, bRet  )
		if(dictData.err == "ok")then
			-- print(GetLocalizeStringBy("key_2657"))
			-- print_t(dictData.ret)
			-- 军团总个数
			GuildListLayer.m_guildCount = tonumber( dictData.ret.count )
			-- 军团前10条数据
			GuildListLayer.setGuildListData( dictData.ret.data, dictData.ret.offset )
			-- 更新军团列表
			GuildListLayer.m_listTabViewInfo = GuildListLayer.getGuildListData()
			GuildListLayer.m_listTableView:reloadData()
			if(table.isEmpty(dictData.ret.data))then
				require "script/ui/tip/AnimationTip"
				local str = GetLocalizeStringBy("key_2259")
				AnimationTip.showTip(str)
			end
		end
	end
	-- 列表数据
	local args = CCArray:create()
	args:addObject(CCInteger:create(0))
	args:addObject(CCInteger:create(10))
	m_serchName = name
	args:addObject(CCString:create(name))
	RequestCenter.guild_getGuildListByName(searchGuildCallback,args)
end

-- 创建军团列表
function createGuildListTabView( ... )
	-- 显示单元格背景的size
	local cell_bg_size = { width = 640, height = 212 } 
	-- 得到列表数据
	m_listTabViewInfo = getGuildListData() or {}
	-- print(GetLocalizeStringBy("key_2241"))
	-- print_t(m_listTabViewInfo)
	require "script/ui/guild/GuildListCell"
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			-- 显示单元格的间距
			local interval = 10
			r = CCSizeMake(cell_bg_size.width * g_fScaleX/MainScene.elementScale, (cell_bg_size.height + interval)*g_fScaleX/MainScene.elementScale)
		elseif (fn == "cellAtIndex") then
			r = GuildListCell.createCell(m_listTabViewInfo[a1+1],isHaveGuild)
			r:setScale(g_fScaleX/MainScene.elementScale)
		elseif (fn == "numberOfCells") then
			r = #m_listTabViewInfo
		elseif (fn == "cellTouched") then
			-- print ("a1: ", a1, ", a2: ", a2)
			-- print ("cellTouched, index is: ", a1:getIdx())
		elseif (fn == "scroll") then
			-- print ("scroll, index is: ")
		else
			-- print (fn, " event is not handled.")
		end
		return r
	end)

	m_listTableView = LuaTableView:createWithHandler(handler, CCSizeMake(tableView_width,tableView_hight))
	m_listTableView:setBounceable(true)
	m_listTableView:setAnchorPoint(ccp(0, 0))
	m_listTableView:setPosition(ccp(0,0))
	_bgLayer:addChild(m_listTableView)
	-- 设置单元格升序排列
	m_listTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	-- 设置滑动列表的优先级
	m_listTableView:setTouchPriority(-130)
end


------------------------------------------------------------------------------------------
-- 创建下方UI
function createBottom( ... )
	if( isHaveGuild )then
		-- 有军团 隐藏下排按钮
		MainScene.setMainSceneViewsVisible(false, false, true)
		-- 有军团显示军团操作
		require "script/ui/guild/GuildBottomSprite"
		_bottomSpite = GuildBottomSprite.createBottomSprite()
		_bottomSpite:setAnchorPoint(ccp(0,1))
		_bottomSpite:setPosition(ccp(0,10))
		_bgLayer:addChild(_bottomSpite)
		local myScale = _bgLayer:getContentSize().width/_bottomSpite:getContentSize().width/_bgLayer:getElementScale()
		_bottomSpite:setScale(myScale)
	else
		-- 没有军团 显示下排按钮
		MainScene.setMainSceneViewsVisible(true, false, true)
	end
end


-- 创建UI
function createUI()
-- 创建Top
	createTop()
-- 创建Bottom
	createBottom()
-- 创建主场景, 列表 UI	
	createMainUI()
end

--@desc	 回调onEnter和onExit时间
local function onNodeEvent( event )
	if (event == "enter") then
		GuildDataCache.setIsInGuildFunc(true)
	elseif (event == "exit") then
		GuildDataCache.setIsInGuildFunc(false)
	end
end


-- 军团请求回调
function getGuildListCallback(  cbFlag, dictData, bRet  )
	if(dictData.err == "ok")then
		-- print(GetLocalizeStringBy("key_1474"))
		-- print_t(dictData.ret)
		if(not table.isEmpty(dictData.ret))then
			-- 军团总个数
			m_guildCount = tonumber( dictData.ret.count )
			-- 军团10条数据
			setGuildListData( dictData.ret.data, dictData.ret.offset )
			-- 设置已经申请的军团数据
			setApplyedGuildData( dictData.ret.appnum )
			-- 创建军团列表
			createGuildListTabView()
		end
	end
end


-- 创建
-- 参数1: 该玩家是否有军团 有true 没有false
function createLayer( b_isHaveGuild )
	init() 
	isHaveGuild = b_isHaveGuild or false
	_bgLayer = MainScene.createBaseLayer("images/main/module_bg.png", true, false, true)
	_bgLayer:registerScriptHandler(onNodeEvent)
	-- 创建UI
	createUI()
	-- 列表数据
	local args = CCArray:create()
	args:addObject(CCInteger:create(0))
	args:addObject(CCInteger:create(10))
	RequestCenter.guild_getGuildList(getGuildListCallback,args)

	return _bgLayer
end



---------------------------------------------------------------------------------------
-- 军团列表数据

-- 得到军团列表数据
function getGuildListData( ... )
	print(GetLocalizeStringBy("key_2404"))
	print_t(_guildListInfo)
	return _guildListInfo
end

-- 设置军团列表数据
function setGuildListData( listData, offset )
	local _offset = tonumber(offset)
	-- 总数
	local all_count = m_guildCount
	-- 如果数量不超过10个则不用添加更多按钮
	if( all_count <= 10 )then
		_guildListInfo = listData
	else
		if( (_offset+10) >= all_count )then
			-- 当数据不满_offset+10时不用加更多按钮
			-- 删除tab中最后位置的更多按钮
			table.remove(_guildListInfo)
			for i,v in ipairs(listData) do
				table.insert( _guildListInfo, v)
			end
		else
			if(_offset <= 0)then
				_guildListInfo = listData
				-- 在数据最后添加 更多好友 标识
				local temTab = { more = true, offset = _offset+10 }
				table.insert(_guildListInfo,temTab)
				-- print(" _guildListInfo 1111")
				-- print_t(_guildListInfo)
			else
				-- 删除tab中最后位置的更多按钮
				table.remove(_guildListInfo)
				for i,v in ipairs(listData) do
					table.insert( _guildListInfo, v)
				end
				-- 在数据最后添加 更多好友 标识
				local temTab = { more = true, offset = _offset+10 }
				table.insert(_guildListInfo,temTab)
			end
		end
	end
end


-- 设置已经申请的军团
function setApplyedGuildData( num )
	_applyTab = {}
	local data = getGuildListData()
	if( tonumber(num) <= 0  )then
		return
	end
	for i=1,tonumber(num) do
		_applyTab[#_applyTab+1] = data[i]
	end
end

-- 添加申请军团的数据
function addApplyedGuildData( data )
	if(data)then
		table.insert(_applyTab,1,data)
	end
end

-- 得到已经申请的军团数据
function getApplyGuildData( ... )
	return _applyTab
end

-- 判断是否已申请改军团
function isHaveApplyGuildByGuildID( id )
	local isHaveApply = false
	local applyTab = getApplyGuildData()
	if(not table.isEmpty(applyTab))then
		for k,v in pairs(applyTab) do
			if( tonumber(v.guild_id) == tonumber(id) )then
				isHaveApply = true
				break
			end
		end
	end
	return isHaveApply
end

-- 根据军团id得到该军团在列表数据中的位置和数据
function getGuildDataAndPosByGuildID( id )
	-- print("id++++++++++++++" ..  id)
	local data = {}
	local pos = nil
	local guildData = getGuildListData()
	local count = 0
	for i = 1,#guildData do
		-- print("i...........",i)
		-- print_t(guildData[i])
		if(tonumber(id) == tonumber(guildData[i].guild_id))then
			data = guildData[i]
			pos = i
			break
		end
	end
	return data,pos
end

-- 申请军团后数据修改
-- 根据军团id把申请的军团放到列表第一个
function AfterApplyServiceData( id )
	local thisData,tishPos = getGuildDataAndPosByGuildID(id)
	print("tishPos",tishPos)
	-- 添加到军团已申请表中
	addApplyedGuildData(thisData)
	-- 先删除原来位置上的数据
	table.remove(_guildListInfo,tishPos)
	-- print_t(_guildListInfo)
	-- 把申请的数据放到顶层
	table.insert(_guildListInfo,1,thisData)
	-- print("--------------")
	print_t(_guildListInfo)
end

--[[
	@des 	:军团排行榜按钮回调
	@param  :
	@return :
--]]
--added by DJN
function rankButtonCallBack()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/guild/rank/GuildRankLayer"
	GuildRankLayer.showLayer()

end






