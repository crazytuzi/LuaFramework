-- FileName: GuildWar4Layer.lua 
-- Author: bzx
-- Date: 15-1-13 
-- Purpose:  跨服军团战16强到4强

module("GuildWar4Layer", package.seeall)

require "script/ui/guildWar/promotion/GuildWarGuildPromotionSprite"
require "script/ui/guildWar/guildInfo/MyGuildWarInfoDialog"
require "script/ui/guildWar/promotion/GuildWarPromotionService"
require "script/ui/guildWar/GuildWarUtil"
require "script/ui/guildWar/promotion/GuildWarPromotionUtil"
require "script/ui/guildWar/promotion/GuildWarPromotionController"
require "script/ui/guildWar/GuildWarStageEvent"

local _layer 
local _zOrder						-- 本层Z轴
local _touchPriority				-- 本层触摸优先级
local _cellPositionData 			-- 军团Icon, 线条，按钮位置信息
local _isMenuVisible				-- 进入该界面之前主界面的菜单是否可见
local _isAvatarVisible				-- 进入该界面之前主界面的玩家信息面板是否可见
local _isBulletinVisible			-- 进入该界面之前主界面的跑马灯公告是否可见
local _topNode 						-- 顶部UI
local _bottomNode 					-- 底部UI
local _centerNodeSize				-- 中部节点的尺寸
local _centerNode                   -- 中部UI的父节点

--[[
	@desc: 				                显示本界面
	@param:    number p_touchPriority 	触摸优先级
	@param:    nubmer p_zOrder			z轴
    @param:    bool   p_isNoRequest     是否不需要请求数据
	@return:			                nil
--]]
 function show(p_touchPriority, p_zOrder, p_isNoRequest)
    require "script/ui/guildWar/promotion/GuildWar16Layer"
    _layer = create(p_touchPriority, p_zOrder)
    MainScene.changeLayer(_layer, "GuildWar4Layer")
    local requestCallback = function ( ... )
        refreshCenterNode()
    end
    if not p_isNoRequest then
        local requestCallback2 = function ( ... )
            GuildWarPromotionService.getGuildWarInfo(requestCallback)
        end
        GuildWarMainService.getUserGuildWarInfo(requestCallback2)
    else
        requestCallback()
    end
 end

 function init( ... )
 	_layer 					= nil
 	_zOrder 				= 0
 	_touchPriority  		= 0
 	_cellPositionData  		= {}
 	_isMenuVisible  		= false
 	_isAvatarVisible  		= false
 	_isBulletinVisible  	= false
 	_topNode 				= nil
 	_bottomNode 			= nil
    _centerNode             = nil
 end

 function initData( p_touchPriority, p_zOrder )
 	_touchPriority = p_touchPriority or -180
 	_zOrder = p_zOrder or 1
 	initPositions()
 end

--[[
	@desc:		初始化军团Icon，线条，按钮的位置信
	@return:	nil
--]]
 function initPositions( ... )
 	local l = function(position, scaleX, scaleY, rotation)
        return {["position"] = position, ["scaleX"] = scaleX, ["scaleY"] = scaleY, ["rotation"] = rotation}
    end
    _cellPositionData = {
        [4] = {
        	-- 军团Icon
            guildPositions = {
                ccp(128, 500), ccp(512, 500), ccp(128, 120), ccp(512, 120)
            },
            -- 晋级线
            lineDatas = {
                l(ccp(230, 500), 1.8), l(ccp(410, 500), 1.8, 1), l(ccp(230, 120), 1.8, 1), l(ccp(410, 120), 1.8, 1)
            },
            -- 助威，查看战报按钮
            btnPositions = {
                ccp(320, 500), ccp(320, 120)
            }
        },
        [2] = {
            lineDatas = {
                l(ccp(320, 420), 1.8, 1, 90), l(ccp(320, 180), 1.8, 1, 90)
            },
            btnPositions = {
                ccp(440, 301)
            }
        },
        [1] = {
            guildPositions = {
                ccp(319, 301)
            },
        }
    }
 end

--[[
	@desc:				                    创建本层
	@param:    number  p_touchPriority	    本层触摸优先级
	@p_zOrder			                    z轴	
--]]
 function create( p_touchPriority, p_zOrder )
 	init()
 	initData(p_touchPriority, p_zOrder)
 	_layer = CCLayer:create()
    _layer:registerScriptHandler(onNodeEvent)
 	loadBg()
 	loadTop()
 	loadBottom()
 	return _layer
 end

--[[
	@desc:		显示本界面的背景
	@return:	nil
--]]
function loadBg()
    local bg = CCSprite:create("images/lord_war/bg.jpg")
    _layer:addChild(bg)
    bg:setAnchorPoint(ccp(0.5, 0.5))
    bg:setPosition(ccpsprite(0.5, 0.5, _layer))
    bg:setScale(MainScene.bgScale)
end

--[[
	@desc:		显示顶部UI
	@return:	nil
--]]
function loadTop()
    _topNode = GuildWarPromotionUtil.createTopNode("GuildWar4Layer", _touchPriority - 1)
    _layer:addChild(_topNode)
    _topNode:setAnchorPoint(ccp(0.5, 1))
    _topNode:setPosition(ccpsprite(0.5, 1, _layer))
    _topNode:setScale(g_fScaleX)
end

--[[
	@desc:		显示底部UI
--]]
function loadBottom()
    _bottomNode = GuildWarPromotionUtil.createBottomNode("GuildWar4Layer", _touchPriority - 240)
    _layer:addChild(_bottomNode)
    _bottomNode:setScale(g_fScaleX)
    _bottomNode:setAnchorPoint(ccp(0.5, 0))
    _bottomNode:setPosition(ccpsprite(0.5, 0, _layer))
end

-- 显示中部UI
function refreshCenterNode()
    if _layer == nil then
        return
    end
    if _centerNode ~= nil then
        _centerNode:removeFromParentAndCleanup(true)
    end
    _centerNodeSize = CCSizeMake(g_winSize.width, g_winSize.height - _topNode:getContentSize().height * g_fScaleX - _bottomNode:getContentSize().height * g_fScaleX)
    _centerNode = CCNode:create()
    _layer:addChild(_centerNode)
    _centerNode:setScale(MainScene.elementScale)
    _centerNode:setAnchorPoint(ccp(0.5, 0.5))
    _centerNode:setContentSize(CCSizeMake(640, 602))
    _centerNode:setPosition(ccp(g_winSize.width * 0.5, _centerNodeSize.height * 0.5 + _bottomNode:getContentSize().height * g_fScaleX))
    local nodeMenu = BTSensitiveMenu:create()
    _centerNode:addChild(nodeMenu, 3)
    nodeMenu:setPosition(ccp(0, 0))
    nodeMenu:setContentSize(_centerNode:getContentSize())
    nodeMenu:setTouchPriority(_touchPriority - 1)

    for rank, positionData in pairs(_cellPositionData) do
    	-- 显示军团
        if positionData.guildPositions ~= nil then
            for i = 1, #positionData.guildPositions do
                local guildPosition = positionData.guildPositions[i]
                GuildWarPromotionUtil.loadGuildIcon(_centerNode, guildPosition, rank, i, "GuildWar4Layer")
            end
        end
        -- 显示晋级线
        if positionData.lineDatas ~= nil then
            for i = 1, #positionData.lineDatas do
                local lineData = positionData.lineDatas[i]
                GuildWarPromotionUtil.loadLine(_centerNode, lineData, rank, i)
            end 
        end
        -- 显示两条晋级线对应的按钮（助威，查看战报）
        if positionData.btnPositions ~= nil then
            for i = 1, #positionData.btnPositions do
                local btnPosition = positionData.btnPositions[i]
                GuildWarPromotionUtil.loadBtn(nodeMenu, btnPosition, rank, i)
            end
        end
    end
end

-- 记录进入该界面时主界面菜单，玩家信息面板和跑马灯公告的显示状态
function recordMainSceneViewsVisibleInfo( ... )
	_isMenuVisible = MainScene.isMenuVisible()
	_isAvatarVisible = MainScene.isAvatarVisible()
	_isBulletinVisible = MainScene.isBulletinVisible()
end

function onNodeEvent(p_event)
    if (p_event == "enter") then
        recordMainSceneViewsVisibleInfo()
        MainScene.setMainSceneViewsVisible(false, false, false)
        GuildWarStageEvent.registerListener(refresh)
    elseif (p_event == "exit") then
        _layer = nil
        MainScene.setMainSceneViewsVisible(_isMenuVisible, _isAvatarVisible, _isBulletinVisible)
        GuildWarStageEvent.removeListener(refresh)
        _title = nil
    end
end

function refresh(p_round, p_status, p_subRound, p_subStatus)
    print("4Layer=========", p_round, p_status, p_subRound, p_subStatus)
    if p_status == GuildWarDef.FIGHTEND then
        local requestCallback = function ( ... )
            refreshCenterNode()
        end
        GuildWarPromotionService.getGuildWarInfo(requestCallback)
    end
end

--[[
    @desc:                  得到本层触摸优先级
    @return:    number
--]]
function getTouchPriority( ... )
    return _touchPriority
end

--[[
    @desc:                  得到本层z轴
    @return:    number      
--]]
function getZOrder( ... )
    return _zOrder
end
