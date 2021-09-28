
-- Filename：	MemberListLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-12-21
-- Purpose：		军团成员列表

module("MemberListLayer", package.seeall)

require "script/ui/guild/GuildMemberCell"
require "script/ui/guild/CheckSortLayer"

Tag_MemberList 		= 20001
Tag_CheckedList 	= 20002

-- 审核的排序规则
Type_Sort_Time		= 1 	-- 按时间排序
Type_Sort_Level		= 2 	-- 按等级排序
Type_Sort_Force		= 3 	-- 按战斗力排序
Type_Sort_Rank		= 4 	-- 按竞技排名排序


local _bgLayer 				= nil

local _memberMenuItem 		= nil 	-- 军团成员
local _checkedMenuItem 		= nil 	-- 审核

local _curMenuItem 			= nil 	-- 当前按钮

local _memberListInfo 		= nil 	-- 成员的相关信息
local _checkedListInfo 		= nil	-- 审核的列表

local _curMemberData 		= nil 	-- 成员信息数组
local _curMemberTableView 	= nil

local _cur_item_tag 		= nil 	-- 初始的按钮
local _bottomSpite 			= nil 	-- 底层
local _btnFrameSp			= nil 	-- 按钮层

local _sortAndRefuseBg 		= nil	-- 排序和拒绝的背景

local _curSortType 			= nil -- 默认时间排序

local t_menuBar 			= nil 	-- 中间的排序和一键拒绝按钮

local _lastTableViewContentOffset = nil

local function init()
	_bgLayer 			= nil
	_memberMenuItem 	= nil 	-- 军团成员
	_checkedMenuItem 	= nil 	-- 审核
	_curMenuItem 		= nil 	-- 当前按钮
	_memberListInfo 	= nil 	-- 成员的相关信息
	_curMemberData 		= nil	-- 成员信息数组
	_curMemberTableView = nil
	_cur_item_tag 		= nil 	-- 初始的按钮
	_checkedListInfo 	= nil	-- 审核的列表
	_bottomSpite 		= nil 	-- 底层
	_btnFrameSp			= nil 	-- 按钮层
	_sortAndRefuseBg 	= nil	-- 排序和拒绝的背景
	_curSortType 		= nil
	t_menuBar 			= nil 	-- 中间的排序和一键拒绝按钮
end

-- touch事件处理
local function onTouchesHandler(eventType, x, y)
   
    if (eventType == "began") then
    	print("began")
    	local touchBeganPoint = ccp(x, y)
    	local vPosition = _btnFrameSp:convertToNodeSpace(touchBeganPoint)
    	if ( vPosition.x >0 and  vPosition.y > 0  ) then
        	return true
        else
        	return false
        end

    	return true
	
    elseif (eventType == "moved") then
    	
		
    else
    	print("end")
	end
end

--@desc	 回调onEnter和onExit时间
local function onNodeEvent( event )
	if (event == "enter") then
		GuildDataCache.setIsInGuildFunc(true)
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -398, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		GuildDataCache.setIsInGuildFunc(false)
	end
end


-- 按钮响应
function menuAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	if(_curMenuItem ~= itemBtn)then
		_curMenuItem:setEnabled(true)
		_curMenuItem:unselected()

		_curMenuItem = itemBtn
		_curMenuItem:setEnabled(false)
		_curMenuItem:selected()

		if(_curMenuItem == _memberMenuItem)then
			_cur_item_tag = Tag_MemberList
			-- 成员列表
			GuildDataCache.sendRequestForMemberList(getMemberInfoDelegate)
		elseif(_curMenuItem == _checkedMenuItem)then
			-- 审核列表
			_cur_item_tag = Tag_CheckedList
			local args = Network.argsHandler(0, 99)
			RequestCenter.guild_getGuildApplyList(guildApplyListCallback, args)
		end

	end
end

-- 返回Action
function backAction( tag, itemBtn )
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	require "script/ui/guild/GuildMainLayer"
	local guildMainLayer = GuildMainLayer.createLayer(false)
	MainScene.changeLayer(guildMainLayer, "guildMainLayer")
end


-- 创建上部按钮
function createTopMenu()
	--按钮背景
	_btnFrameSp = CCScale9Sprite:create("images/common/menubg.png")
	_btnFrameSp:setContentSize(CCSizeMake(640, 100))
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
	menuBar:setTouchPriority(-400)
	_btnFrameSp:addChild(menuBar)

	-- 成员按钮
	_memberMenuItem = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("key_1196"),30,30)
	_memberMenuItem:setAnchorPoint(ccp(0, 0))
	_memberMenuItem:setPosition(ccp(_btnFrameSp:getContentSize().width*0.02, _btnFrameSp:getContentSize().height*0.08))
	_memberMenuItem:registerScriptTapHandler(menuAction)
	menuBar:addChild(_memberMenuItem, 1, Tag_MemberList)
	-- 默认选中状态
	_memberMenuItem:setEnabled(false)
	_memberMenuItem:selected()

	_curMenuItem = _memberMenuItem

	-- 审核按钮
	_checkedMenuItem = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("key_3208"),30,30)
	_checkedMenuItem:setAnchorPoint(ccp(0, 0))
	_checkedMenuItem:setPosition(ccp(_btnFrameSp:getContentSize().width*0.3, _btnFrameSp:getContentSize().height*0.08))
	_checkedMenuItem:registerScriptTapHandler(menuAction)
	menuBar:addChild(_checkedMenuItem, 1, Tag_CheckedList)

	if(tonumber(GuildDataCache.getMineSigleGuildInfo().member_type) == 0)then
		_checkedMenuItem:setVisible(false)
	end


	-- 创建关闭按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(0, 0))
	closeMenuItem:registerScriptTapHandler(backAction)
	closeMenuItem:setAnchorPoint(ccp(1,0.5))
	closeMenuItem:setPosition(ccp(_btnFrameSp:getContentSize().width-20,_btnFrameSp:getContentSize().height*0.5))
	menuBar:addChild(closeMenuItem)

end

-- 创建底部
function createBottom()
	if(_bottomSpite)then
		_bottomSpite:removeFromParentAndCleanup(true)
		_bottomSpite = nil
	end
	_bottomSpite = GuildBottomSprite.createBottomSprite(false)
	_bgLayer:addChild(_bottomSpite, 99)
	local myScale = _bgLayer:getContentSize().width/_bottomSpite:getContentSize().width/_bgLayer:getElementScale()
	_bottomSpite:setScale(myScale)
end

-- 创建成员TableView
function createMembertableView()
	-- cellSize = cellBg:getContentSize()			--计算cell大小
	local cellSize = CCSizeMake(640, 186)
	if( _curMenuItem == _checkedMenuItem )then
		cellSize = CCSizeMake(640, 186)
	else
		cellSize = CCSizeMake(640, 230)
	end

	if(_curMemberTableView)then
		_curMemberTableView:removeFromParentAndCleanup(true)
		_curMemberTableView = nil
	end
	if(_sortAndRefuseBg)then
		_sortAndRefuseBg:removeFromParentAndCleanup(true)
		_sortAndRefuseBg = nil
	end
	if(t_menuBar)then
		t_menuBar:removeFromParentAndCleanup(true)
		t_menuBar = nil
	end
	print("sssss")
	print_t(_curMemberData)
    local myScale = _bgLayer:getContentSize().width/cellSize.width/_bgLayer:getElementScale()
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width*myScale, cellSize.height*myScale)
		elseif fn == "cellAtIndex" then
			if(_curMenuItem == _memberMenuItem)then
	            a2 = GuildMemberCell.createMemberCell(_curMemberData[a1 + 1], false, refreshMemberTableView)
	        elseif(_curMenuItem == _checkedMenuItem)then
	        	a2 = GuildMemberCell.createMemberCell(_curMemberData[a1 + 1], true, refreshMemberTableView)
	        end
            a2:setScale(myScale)
			r = a2
		elseif fn == "numberOfCells" then
			r = #_curMemberData
		elseif fn == "cellTouched" then
		elseif (fn == "scroll") then
			if(_curMenuItem == _memberMenuItem and _curMemberTableView ~= nil)then
				_lastTableViewContentOffset = _curMemberTableView:getContentOffset()
			end
		end
		return r
	end)
	local checkedUIHeight = 0
	if( _curMenuItem == _checkedMenuItem )then
		checkedUIHeight = 75
		_sortAndRefuseBg = CCSprite:create("images/common/separator_top.png")
		_sortAndRefuseBg:setAnchorPoint(ccp(0, 1))
		_sortAndRefuseBg:setPosition(ccp(0, ( _bgLayer:getContentSize().height-(85 + checkedUIHeight)*g_fScaleX) ) )
		_sortAndRefuseBg:setScale(myScale)
		_bgLayer:addChild(_sortAndRefuseBg, 2)
	end

	local bottomSpiteSize = _bottomSpite:getContentSize()
	_curMemberTableView = LuaTableView:createWithHandler(h, CCSizeMake(_bgLayer:getContentSize().width/_bgLayer:getElementScale(), (_bgLayer:getContentSize().height-(bottomSpiteSize.height + 100 + checkedUIHeight)*g_fScaleX)  /_bgLayer:getElementScale()  ) )
    _curMemberTableView:setAnchorPoint(ccp(0,0))
    _curMemberTableView:setPosition(ccp(0, bottomSpiteSize.height*g_fScaleX))
	_curMemberTableView:setBounceable(true)
	-- _curMemberTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_bgLayer:addChild(_curMemberTableView)

	if(_curMenuItem == _checkedMenuItem)then
		_curSortType = nil
		-- 创建中间排序和一键拒绝的按钮
		setSortTypeAndRefreshDelegate(Type_Sort_Time)
	elseif(_curMenuItem == _memberMenuItem and _lastTableViewContentOffset ~= nil)then
		_curMemberTableView:setContentOffset(_lastTableViewContentOffset)
	end

end

-- 选择排序方式
function selectSortAction(tag , itemBtn)
	if(table.isEmpty(_curMemberData) == true)then
		AnimationTip.showTip(GetLocalizeStringBy("key_2438"))
		return
	end
	CheckSortLayer.showLayer(_curSortType)
end

-- 一键拒绝网络回调
function guildRefuseAllApplyCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok" or dictData.err == "failed")then
		_curMemberData = {}
		_curMemberTableView:reloadData()
	end
end

-- 一键拒绝代理
function confirmCBFunc( isConfirm )
	if(isConfirm and isConfirm == true)then
		RequestCenter.guild_refuseAllApply(guildRefuseAllApplyCallback)
	end
end

-- 一键拒绝
function oneRefuseAction( tag, itemBtn )
	if(table.isEmpty(_curMemberData) == true)then
		AnimationTip.showTip(GetLocalizeStringBy("key_2438"))
		return
	end
	AlertTip.showAlert( GetLocalizeStringBy("key_1338"), confirmCBFunc, true)
end

-- 设置排序规则
function setSortTypeAndRefreshDelegate( sort_type )
	if(_curSortType == sort_type)then
		return	
	end
	_curSortType = sort_type
	if(_curSortType == Type_Sort_Time)then
		-- 按时间
		_curMemberData = GuildUtil.sortCheckByTime(_curMemberData)
	elseif(_curSortType == Type_Sort_Level)then
		-- 按等级
		_curMemberData = GuildUtil.sortCheckByLevel(_curMemberData)
	elseif(_curSortType == Type_Sort_Force)then
		-- 按战斗力
		_curMemberData = GuildUtil.sortCheckByForce(_curMemberData)
	elseif(_curSortType == Type_Sort_Rank)then
		-- 按竞技排名
		_curMemberData = GuildUtil.sortCheckByRank(_curMemberData)
	end

	_curMemberTableView:reloadData()
	-- 创建中间排序和一键拒绝的按钮
	createSortAndOneChecked()
end

-- 创建中间排序和一键拒绝的按钮
function createSortAndOneChecked()
	local tittle_arr = {GetLocalizeStringBy("key_2630"), GetLocalizeStringBy("key_1681"), GetLocalizeStringBy("key_2045"), GetLocalizeStringBy("key_1514")}
	if(t_menuBar)then
		t_menuBar:removeFromParentAndCleanup(true)
		t_menuBar = nil
	end
	t_menuBar = CCMenu:create()
	t_menuBar:setAnchorPoint(ccp(0,0))
	t_menuBar:setPosition(ccp(0,0))
	_bgLayer:addChild(t_menuBar)

	-- 排序按钮
	require "script/libs/LuaCC"
	local selectSortBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_violet_n.png", "images/common/btn/btn_violet_h.png",CCSizeMake(240, 64), tittle_arr[_curSortType],ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	selectSortBtn:setAnchorPoint(ccp(0.5, 0.5))
	selectSortBtn:registerScriptTapHandler(selectSortAction)
	selectSortBtn:setPosition(ccp(_bgLayer:getContentSize().width*0.3/_bgLayer:getElementScale(), ( _bgLayer:getContentSize().height-(85 + 45)*g_fScaleX)/_bgLayer:getElementScale() ))
	t_menuBar:addChild(selectSortBtn )

	-- 一键拒绝
	require "script/libs/LuaCC"
	local oneRefuseBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_violet_n.png", "images/common/btn/btn_violet_h.png",CCSizeMake(240, 64), GetLocalizeStringBy("key_1908"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	oneRefuseBtn:setAnchorPoint(ccp(0.5, 0.5))
	oneRefuseBtn:registerScriptTapHandler(oneRefuseAction)
	oneRefuseBtn:setPosition(ccp(_bgLayer:getContentSize().width*0.7/_bgLayer:getElementScale(), ( _bgLayer:getContentSize().height-(85 + 45)*g_fScaleX)/_bgLayer:getElementScale() ))
	t_menuBar:addChild(oneRefuseBtn )
end

-- 刷新table
function refreshMemberTableView(isForceRequest)
	
	if(tonumber(GuildDataCache.getMineSigleGuildInfo().member_type) == 0)then
		_checkedMenuItem:setVisible(false)
	end

	if(isForceRequest == true)then
		if(_curMenuItem == _memberMenuItem)then
			-- 军团成员
			GuildDataCache.sendRequestForMemberList(getMemberInfoDelegate)
		elseif(_curMenuItem == _checkedMenuItem)then
			-- 审核
			local args = Network.argsHandler(0, 99)
			RequestCenter.guild_getGuildApplyList(guildApplyListCallback, args)
		end
	else
		if(_curMemberTableView)then
			handleData()
			local contentOffset = _curMemberTableView:getContentOffset() 
			_curMemberTableView:reloadData()
			if(_curMenuItem == _memberMenuItem)then
				_curMemberTableView:setContentOffset(contentOffset) 
			end
		end
	end

	createBottom()
end


-- 创建UI
function createUI()
	createTopMenu()
	createBottom()
	-- 创建成员TableView
	-- createMembertableView()
end

-- 等待有数据回调
function getMemberInfoDelegate()
	_memberListInfo = GuildDataCache.getMemberInfoList()
	handleData()
	createMembertableView()
	-- if(not table.isEmpty(_curMemberData))then
		
	-- end
end

-- 删除审核表中的一条
function deleteCheckedDataBy( uid )
	uid = tonumber(uid)
	for k,v in pairs(_checkedListInfo.data) do
		if(tonumber(v.uid) == uid)then
			_checkedListInfo.data[k] = nil
			break
		end
	end
end

-- 获取审核列表
function guildApplyListCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok")then
		_checkedListInfo = dictData.ret
		handleData()
		createMembertableView()
		-- if(not table.isEmpty(_curMemberData))then
			
		-- end
	end
end

-- 排序倒序
function sortDataSource( memberData )
	
	local function keySort ( data_1, data_2 )
		if(tonumber(data_1.uid) == UserModel.getUserUid() )then
			return false
		elseif(tonumber(data_2.uid) == UserModel.getUserUid() )then
			return true
		end

		if(tonumber(data_1.status) < tonumber(data_2.status))then
			-- 按在线
			return false
		elseif(tonumber(data_1.status) == tonumber(data_2.status))then
			-- 按贡献度
			if(tonumber(data_1.contri_total) > tonumber(data_2.contri_total))then
				return false
			elseif(tonumber(data_1.contri_total) == tonumber(data_2.contri_total))then
				-- 按战斗力
				if(tonumber(data_1.fight_force) >= tonumber(data_2.fight_force))then
					return false
				else
					return true
				end
			else
				return true
			end
		else
			return true
		end

	end
	table.sort( memberData, keySort )
	return memberData
end


-- 处理数据
function handleData()
	local dataSource = nil
	if(_cur_item_tag == Tag_MemberList)then
		dataSource = _memberListInfo.data
	elseif(_cur_item_tag == Tag_CheckedList)then
		dataSource = _checkedListInfo.data
	end
	_curMemberData = {}
	if(not table.isEmpty(dataSource))then
		
		for k, m_memberInfo in pairs(dataSource) do
			table.insert(_curMemberData, m_memberInfo)
		end
		if(_cur_item_tag == Tag_MemberList)then
			-- 排序
			_curMemberData = sortDataSource(_curMemberData)
			-- 设置官阶
			GuildDataCache.updateMemberGrade()
		end
	end
end

--
function createLayer( init_tag)
	init()

	if(init_tag)then
		_cur_item_tag = init_tag
	else
		_cur_item_tag = Tag_MemberList
	end

	-- 权限
	if(_cur_item_tag == Tag_CheckedList and tonumber(GuildDataCache.getMineSigleGuildInfo().member_type) == 0 )then
		_cur_item_tag = Tag_MemberList
	end

	_bgLayer = MainScene.createBaseLayer("images/main/module_bg.png", false, false, true)
	_bgLayer:registerScriptHandler(onNodeEvent)
	createUI()

	if(_cur_item_tag == Tag_MemberList)then
		-- 成员列表
		GuildDataCache.sendRequestForMemberList(getMemberInfoDelegate)

	elseif(_cur_item_tag == Tag_CheckedList)then
		-- 如果是审核列表
		menuAction( Tag_CheckedList, _checkedMenuItem )
	end

	return _bgLayer
end




