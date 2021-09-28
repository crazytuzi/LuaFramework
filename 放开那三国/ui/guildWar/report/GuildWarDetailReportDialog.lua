-- FileName: GuildWarReportService.lua 
-- Author: licong 
-- Date: 13-12-31 
-- Purpose:  GuildWarDetailReportDialog 跨服军团战晋级赛查看两个军团直接的战报

module("GuildWarDetailReportDialog", package.seeall)
require "script/ui/guild/GuildUtil"
require "script/ui/guildWar/report/GuildWarReportService"
require "script/ui/guildWar/report/GuildWarReportData"

local _bgLayer                  		= nil
local _bgSprite 						= nil -- 大背景
local _desFont 							= nil -- 中间描述文字
local _contentBg 						= nil -- 内容背景
local _curRadioMenuItem 				= nil -- 当前选择按钮


local _layer_priority 					= nil -- 界面优先级
local _zOrder 							= nil -- 界面z轴
local _guildId1   						= nil -- 左边军团id
local _serverId1  						= nil -- 左边服务器id
local _guildId2   						= nil -- 右边军团id
local _serverId2  						= nil -- 右边服务器id
local _leftGuildData 					= nil -- 左边军团数据
local _rightGuildData 					= nil -- 左边军团数据
local _curIndex 						= nil -- 当前显示小组

--[[
    @des    :init
--]]
function init( ... )
	_bgLayer                    		= nil
	_bgSprite 							= nil
	_desFont 							= nil
	_contentBg 							= nil

	_layer_priority 					= nil
	_zOrder 							= nil 
	_guildId1   						= nil
	_serverId1  						= nil
	_guildId2   						= nil
	_serverId2  						= nil
	_leftGuildData 						= nil
 	_rightGuildData 					= nil
 	_curIndex 							= nil
end

-------------------------------------------------------- 按钮事件 ---------------------------------------------------------
--[[
	@des 	:touch事件处理
--]]
function layerTouch(eventType, x, y)
    return true
end

--[[
    @des    :回调onEnter和onExit事件
--]]
function onNodeEvent( event )
    if (event == "enter") then
        _bgLayer:registerScriptTouchHandler(layerTouch,false,_layer_priority,true)
        _bgLayer:setTouchEnabled(true)
    elseif (event == "exit") then
    end
end

--[[
	@des 	:关闭按钮回调
--]]
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

--[[
	@des 	:小组按钮回调
--]]
function changeMenuItemCallBack( tag, itemBtn )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

    print("changeMenuItemCallBack .. tag",tag)

    itemBtn:selected()
	if(itemBtn ~= _curRadioMenuItem) then
		_curRadioMenuItem:unselected()
		_curRadioMenuItem = itemBtn
		_curIndex = tag

		print("_curIndex == ",_curIndex)

		-- 刷新界面
		createContentUI()
	end

end

------------------------------------------------------------- 创建UI ----------------------------------------------
--[[
	@des 	: 创建内容UI
--]]
function createContentUI()

	if( _contentBg ~= nil )then
		_contentBg:removeFromParentAndCleanup(true)
		_contentBg = nil
	end

	-- 背景
	local inset_rect = CCRectMake(30,30,15,15)
	local full_rect = CCRectMake(0,0,75, 75)
	_contentBg  = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", full_rect, inset_rect)
	_contentBg:setContentSize(CCSizeMake(570,343))
	_contentBg:setAnchorPoint(ccp(0.5,0))
	_contentBg:setPosition(ccp(_bgSprite:getContentSize().width*0.5,115))
	_bgSprite:addChild(_contentBg)


	local titleInfo 			= nil -- 标题
	local tipText 				= nil -- 提示文字信息
	local curReportData 		= nil -- 战报数据
	local curContentData1 		= nil -- 玩家1
	local curContentData2 		= nil -- 玩家2
	local line 					= nil -- 分割线
	local curIsOver,_ = GuildWarReportData.getIsOverAndReportDataByIndex( _curIndex ) -- 当前组是否结束

	if(curIsOver)then
		curReportData = GuildWarReportData.getShowDataByIndex( _guildId1, _serverId1, _curIndex, true )

		-- 标题信息 场次、对战双方、战报
	 	titleInfo = {
			width = 576,
			colInfos = {
				{
					image = "images/lord_war/battlereport/round.png",
					width = 107,
				},
				{
					image = "images/guild_war/duizhan.png",
					width = 360,
				},
				{
					image = "images/guild_war/zhanbao.png",
					width = 110,
				}
			}	
		}
		-- 刷新描述
		_desFont:setString(GetLocalizeStringBy("lic_1486"))
		-- 提示文字
		tipText = " "
	else
		curContentData1 = GuildWarReportData.getShowDataByIndex( _guildId1, _serverId1, _curIndex, true)
 		curContentData2 = GuildWarReportData.getShowDataByIndex( _guildId2, _serverId2, _curIndex, false )

 		-- 标题信息 场次、名字、场次、名字
	 	titleInfo = {
			width = 576,
			colInfos = {
				{
					image = "images/lord_war/battlereport/round.png",
					width = 107,
				},
				{
					image = "images/guild_war/fight_info/name.png",
					width = 180,
				},
				{
					image = "images/lord_war/battlereport/round.png",
					width = 100,
				},
				{
					image = "images/guild_war/fight_info/name.png",
					width = 188,
				}
			}	
		}
		-- 刷新描述
		_desFont:setString(GetLocalizeStringBy("lic_1485"))
		-- 提示文字
		tipText = GetLocalizeStringBy("lic_1487")
		-- 分割线
		line = CCScale9Sprite:create("images/common/line5.png")
		line:setContentSize(CCSizeMake(4,385))
	end
	print("_curIndex",_curIndex,"curIsOver",curIsOver)
 	print("curContentData1")
 	print_t(curContentData1)
 	print("curContentData2")
 	print_t(curContentData2)
 	print("curReportData")
 	print_t(curReportData)

	-- 标题
	local titleBar = LuaCCSprite.createTableTitleBar(titleInfo)
	titleBar:setAnchorPoint(ccp(0.5, 0))
	titleBar:setPosition(ccp(_contentBg:getContentSize().width * 0.5, _contentBg:getContentSize().height-20 ))
	_contentBg:addChild(titleBar, 2)

	-- tableView
	local cellSize = CCSizeMake(570, 113)
	require "script/ui/guildWar/report/GuildWarDetailReportCell"
    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = cellSize
        elseif fn == "cellAtIndex" then
        	if(curIsOver)then
        		a2 = GuildWarDetailReportCell.createCellTwo(curReportData[a1+1],_layer_priority-2)
        	else
            	a2 = GuildWarDetailReportCell.createCellOne(curContentData1[a1+1],curContentData2[a1+1])
        	end
            r = a2
        elseif fn == "numberOfCells" then
            if(curIsOver)then
            	r = #curReportData
            else
            	if( #curContentData1 >= #curContentData2)then
            		r = #curContentData1
            	else
            		r = #curContentData2
            	end
            end
        else
        end
        return r
    end)
    local contentTableView = LuaTableView:createWithHandler(h, CCSizeMake(_contentBg:getContentSize().width,_contentBg:getContentSize().height-10))
    contentTableView:setTouchPriority(_layer_priority-3)
    contentTableView:setBounceable(true)
    contentTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    contentTableView:ignoreAnchorPointForPosition(false)
    contentTableView:setAnchorPoint(ccp(0.5,0.5))
    contentTableView:setPosition(ccpsprite(0.5,0.5,_contentBg))
    _contentBg:addChild(contentTableView)

    -- 分割线
    if( line ~= nil )then
    	line:setContentSize(CCSizeMake(4,383))
	    line:setAnchorPoint(ccp(0.5, 0))
		line:setPosition(ccp(_contentBg:getContentSize().width*0.5,1))
	    _contentBg:addChild(line,100)
	end

    -- 描述
    local textInfo = {
 		width = 400, -- 宽度
        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
        labelDefaultFont = g_sFontPangWa,      -- 默认字体
        labelDefaultSize = 21,          -- 默认字体大小
        linespace = 8, -- 行间距
        elements =
        {	
            {
            	type = "CCLabelTTF", 
            	text = tipText,
            	color = ccc3(0x78,0x25,0x00)
        	}
        }
	}
 	local desFont = LuaCCLabel.createRichLabel(textInfo)
 	desFont:setAnchorPoint(ccp(0.5, 1))
 	desFont:setPosition(ccp(_contentBg:getContentSize().width*0.5,-25))
 	_contentBg:addChild(desFont)
end

--[[
	@des 	: 创建UI
--]]
function createUI()
	-- 创建背景
	_bgSprite = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _bgSprite:setContentSize(CCSizeMake(632, 855))
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_bgSprite)
    -- 适配
    setAdaptNode(_bgSprite)

	-- 关闭按钮
	local menuBar = CCMenu:create()
    menuBar:setTouchPriority(_layer_priority-4)
	menuBar:setPosition(ccp(0, 0))
	menuBar:setAnchorPoint(ccp(0, 0))
	_bgSprite:addChild(menuBar)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(_bgSprite:getContentSize().width * 0.955, _bgSprite:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menuBar:addChild(closeButton)

	-- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(_bgSprite:getContentSize().width/2, _bgSprite:getContentSize().height-6.6 ))
	_bgSprite:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1482"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	--五组切换按钮
	local firstMenuItem = nil
	for i = 1,5 do
		local changeMenuItem = LuaCC.create9ScaleMenuItem("images/recycle/btn_title_h.png","images/recycle/btn_title_n.png",CCSizeMake(163,66),GetLocalizeStringBy("zzh_1266",i),ccc3(0xfe,0xdb,0x1c),28,g_sFontPangWa,1,ccc3(0x00,0x00,0x00),ccp(0,-8))
		changeMenuItem:setAnchorPoint(ccp(0.5,0))
		changeMenuItem:setScale(menuBar:getScale()*0.7)
		changeMenuItem:setPosition(ccp( (27 + changeMenuItem:getContentSize().width*changeMenuItem:getScale()*0.5) + (i-1)*(changeMenuItem:getContentSize().width*changeMenuItem:getScale()+2), _bgSprite:getContentSize().height - 94))
		changeMenuItem:registerScriptTapHandler(changeMenuItemCallBack)
		menuBar:addChild(changeMenuItem,1,i)
		if(i == 1)then
			firstMenuItem = changeMenuItem
		end
	end

	-- 创建双方军团
	local fullRect = CCRectMake(0,0,469,89)
	local insetRect = CCRectMake(210,56,1,1)
    local vsBg = CCScale9Sprite:create("images/arena/vs_bg.png",fullRect, insetRect)
    vsBg:setContentSize(CCSizeMake(586,210))
    vsBg:setAnchorPoint(ccp(0.5,1))
    vsBg:setPosition(ccp(_bgSprite:getContentSize().width*0.5,_bgSprite:getContentSize().height-94))
    _bgSprite:addChild(vsBg,2)

    -- 左边军团名字
    local leftGuildName = CCRenderLabel:create(_leftGuildData.guild_name ,g_sFontPangWa,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	leftGuildName:setColor(ccc3(0x00,0xe4,0xff))
	leftGuildName:setAnchorPoint(ccp(0.5,1))
	leftGuildName:setPosition(ccp(98,vsBg:getContentSize().height-5))
	vsBg:addChild(leftGuildName)
	-- 左边军团头像
	local leftGuildIcon = GuildUtil.getGuildIcon(_leftGuildData.guild_badge)
    leftGuildIcon:setAnchorPoint(ccp(0.5, 0.5))
    leftGuildIcon:setPosition(ccp(112,vsBg:getContentSize().height-95))
    vsBg:addChild(leftGuildIcon)
    -- 左边服务器
    local leftServiceName = CCRenderLabel:create("(" .. _leftGuildData.guild_server_name ..")" ,g_sFontName,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	leftServiceName:setColor(ccc3(0xff,0xff,0xff))
	leftServiceName:setAnchorPoint(ccp(0.5,0.5))
	leftServiceName:setPosition(ccp(leftGuildIcon:getContentSize().width*0.5,-10))
	leftGuildIcon:addChild(leftServiceName)

	local isHaveResult = GuildWarReportData.getIsHaveResult()
	if(isHaveResult)then
		-- 有结果了显示晋级或者淘汰
		local isWin = GuildWarReportData.getIsWinBy( _guildId1, _serverId1 )
		local fileStr = nil
		if(isWin)then
			fileStr = "images/lord_war/pass.png" 
		else
			fileStr = "images/lord_war/notpass.png"
		end
		local leftResultSprite = CCSprite:create(fileStr)
		leftResultSprite:setAnchorPoint(ccp(0.5,0.5))
		leftResultSprite:setPosition(ccp(112,22))
		vsBg:addChild(leftResultSprite)
	else
		-- 左边剩余人数
		local richInfo = {}
	    richInfo.defaultType = "CCRenderLabel"
	    richInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
	   	richInfo.labelDefaultSize = 18
	   	richInfo.labelDefaultFont = g_sFontPangWa
	    richInfo.elements = {
	    	{
	    		text = GuildWarReportData.getSurplusMemberNum(_guildId1,_serverId1),
	    		color = ccc3(0x00, 0xff, 0x18)
	    	}
		}
		local leftSurplusNumFont = GetLocalizeLabelSpriteBy_2("lic_1483", richInfo)
		leftSurplusNumFont:setAnchorPoint(ccp(0, 0.5))
		leftSurplusNumFont:setPosition(ccp(63,24))
		vsBg:addChild(leftSurplusNumFont)
	end

	-- 右边军团名字
    local rightGuildName = CCRenderLabel:create(_rightGuildData.guild_name ,g_sFontPangWa,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	rightGuildName:setColor(ccc3(0x00,0xe4,0xff))
	rightGuildName:setAnchorPoint(ccp(0.5,1))
	rightGuildName:setPosition(ccp(vsBg:getContentSize().width-98,leftGuildName:getPositionY()))
	vsBg:addChild(rightGuildName)
	-- 右边军团头像
	local rightGuildIcon = GuildUtil.getGuildIcon(_rightGuildData.guild_badge)
    rightGuildIcon:setAnchorPoint(ccp(0.5, 0.5))
    rightGuildIcon:setPosition(ccp(vsBg:getContentSize().width-112,leftGuildIcon:getPositionY()))
    vsBg:addChild(rightGuildIcon)
    -- 右边服务器
    local rightServiceName = CCRenderLabel:create("(" .. _rightGuildData.guild_server_name ..")" ,g_sFontName,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	rightServiceName:setColor(ccc3(0xff,0xff,0xff))
	rightServiceName:setAnchorPoint(ccp(0.5,0.5))
	rightServiceName:setPosition(ccp(rightGuildIcon:getContentSize().width*0.5,-10))
	rightGuildIcon:addChild(rightServiceName)

	if(isHaveResult)then
		-- 有结果了显示晋级或者淘汰
		local isWin = GuildWarReportData.getIsWinBy( _guildId2, _serverId2 )
		local fileStr = nil
		if(isWin)then
			fileStr = "images/lord_war/pass.png" 
		else
			fileStr = "images/lord_war/notpass.png"
		end
		local rightResultSprite = CCSprite:create(fileStr)
		rightResultSprite:setAnchorPoint(ccp(0.5,0.5))
		rightResultSprite:setPosition(ccp(vsBg:getContentSize().width-112,22))
		vsBg:addChild(rightResultSprite)
	else
		-- 右边剩余人数
		local richInfo = {}
	    richInfo.defaultType = "CCRenderLabel"
	    richInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
	   	richInfo.labelDefaultSize = 18
	   	richInfo.labelDefaultFont = g_sFontPangWa
	    richInfo.elements = {
	    	{
	    		text = GuildWarReportData.getSurplusMemberNum(_guildId2,_serverId2),
	    		color = ccc3(0x00, 0xff, 0x18)
	    	}
		}
		local rightSurplusNumFont = GetLocalizeLabelSpriteBy_2("lic_1483", richInfo)
		rightSurplusNumFont:setAnchorPoint(ccp(0, 0.5))
		rightSurplusNumFont:setPosition(ccp(424,24))
		vsBg:addChild(rightSurplusNumFont)
	end

	-- 中间大VS
	local vsSp = CCSprite:create("images/arena/vs.png")
    vsSp:setAnchorPoint(ccp(0.5,0.5))
    vsSp:setPosition(ccp(vsBg:getContentSize().width*0.5,vsBg:getContentSize().height*0.5))
    vsBg:addChild(vsSp)

    -- 预计出战顺序 or 对战结果
    local fullRect = CCRectMake(0,0,209,49)
	local insetRect = CCRectMake(86,14,45,20)
    local desBg = CCScale9Sprite:create("images/common/bg/hui_bg.png",fullRect, insetRect)
    desBg:setContentSize(CCSizeMake(238,33))
    desBg:setAnchorPoint(ccp(0.5,1))
    desBg:setPosition(ccp(_bgSprite:getContentSize().width*0.5,vsBg:getPositionY()-vsBg:getContentSize().height-10))
    _bgSprite:addChild(desBg)
    -- 描述
    _desFont = CCRenderLabel:create(" " ,g_sFontPangWa,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_desFont:setColor(ccc3(0xff,0xf6,0x00))
	_desFont:setAnchorPoint(ccp(0.5,0.5))
	_desFont:setPosition(ccp(desBg:getContentSize().width*0.5,desBg:getContentSize().height*0.5))
	desBg:addChild(_desFont,10)


	
	-- 当前显示组
	_curIndex = 1
	_curRadioMenuItem = firstMenuItem
	_curRadioMenuItem:selected()

	-- 内容界面
	createContentUI()
end

--[[
	@des 	: 显示对战情况界面
	@param 	:p_godWeaponItemId:神兵itemid, p_layer_priority:界面优先级, p_zOrder:界面Z轴
	@return :
--]]
function createLayer()
	_bgLayer = CCLayerColor:create(ccc4(8,8,8,150))
    _bgLayer:registerScriptHandler(onNodeEvent) 

    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder,1)

    -- 创建ui
    createUI()
end


--[[
	@des 	: 显示对战情况界面
	@param 	: p_guildId01, p_serverId01, p_guildId02,p_serverId02, p_layer_priority:界面优先级, p_zOrder:界面Z轴
	@return :
--]]
function showLayer( p_guildId01, p_serverId01, p_guildId02, p_serverId02, p_layer_priority, p_zOrder )
	-- 初始化
	init()

	_layer_priority = p_layer_priority or -600
	_zOrder = p_zOrder or 1000
	
	_guildId1 	= p_guildId01
	_serverId1 	= p_serverId01
	_guildId2 	= p_guildId02
	_serverId2 	= p_serverId02

 	local nextCallBack = function ( ... )
 		-- 左边军团数据
 		_leftGuildData = GuildWarReportData.getGuildDataBy( _guildId1, _serverId1 )
 		-- 右边军团数据
 		_rightGuildData = GuildWarReportData.getGuildDataBy( _guildId2, _serverId2 )

		-- 创建layer
	 	createLayer()
 	end
 	GuildWarReportService.getReplay(p_guildId01, p_serverId01, p_guildId02, p_serverId02, nextCallBack)
end





















































