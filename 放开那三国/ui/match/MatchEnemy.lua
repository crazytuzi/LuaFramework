-- FileName: MatchEnemy.lua 
-- Author: Li Cong 
-- Date: 13-11-7 
-- Purpose: function description of module 


module("MatchEnemy", package.seeall)

local _bgLayer 					= nil	-- 仇人层
_enemyTableView 				= nil   -- 仇人列表
local _layerSize 				= nil   -- 仇人层大小

function init( ... )
	_bgLayer 						= nil	-- 仇人层
	_enemyTableView 				= nil   -- 仇人列表
end

-- 初始化仇人界面
function initMatchEnemyLayer( ... )
	print(GetLocalizeStringBy("key_3246"))
	print_t(MatchData.m_enemyData)
	if( table.count(MatchData.m_enemyData) == 0)then
		require "script/ui/tip/AnimationTip"
		local str = GetLocalizeStringBy("key_1652")
		AnimationTip.showTip(str)
		return
	end
	_layerSize = _bgLayer:getContentSize()
	-- cellBg的size
	local cellBg = CCSprite:create("images/match/enemy_bg.png")
	local cellSize = cellBg:getContentSize() 

	require "script/ui/match/MatchEnemyCell"
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			r = CCSizeMake(cellSize.width*g_fScaleX, (cellSize.height+10)*g_fScaleX)
		elseif (fn == "cellAtIndex") then
			r = MatchEnemyCell.createCell( MatchData.m_enemyData[a1+1] )
			r:setScale(g_fScaleX)
		elseif (fn == "numberOfCells") then
			r = #MatchData.m_enemyData
		elseif (fn == "cellTouched") then
			-- print ("a1: ", a1, ", a2: ", a2)
			-- print ("cellTouched, index is: ", a1:getIdx())
		else
			-- print (fn, " event is not handled.")
		end
		return r
	end)

	_enemyTableView  = LuaTableView:createWithHandler(handler, CCSizeMake(_layerSize.width,_layerSize.height+5))
	_enemyTableView:setBounceable(true)
	_enemyTableView:setAnchorPoint(ccp(0, 0))
	_enemyTableView:setPosition(ccp(0, 0))
	_bgLayer:addChild(_enemyTableView,2)
	-- 设置滑动列表的优先级
	_enemyTableView:setTouchPriority(-130)

end


-- 创建仇人层
function createMatchEnemyLayer( layerSize )
	init()
	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(function ( eventType,node )
        if(eventType == "enter") then
            
        end
        if(eventType == "exit") then
            init()
        end
    end)
	_bgLayer:setContentSize(layerSize)
	local bg = CCSprite:create("images/main/module_bg.png")
	bg:setAnchorPoint(ccp(0.5,0.5))
	bg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	_bgLayer:addChild(bg)
	bg:setScale( MainScene.bgScale )
	-- 初始化界面
	initMatchEnemyLayer()

	return _bgLayer
end















