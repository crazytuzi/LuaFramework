-- Filename：	TreasRefineSelLayer.lua
-- Author：		zhz
-- Date：		2013-11-6
-- Purpose：		宝物选择列表

module("TreasRefineSelLayer", package.seeall)

require "script/ui/treasure/evolve/TreasRefineSelCell"
require "script/ui/treasure/evolve/TreasureEvolveUtil"
require "script/audio/AudioUtil"
require "script/ui/treasure/evolve/TreasureEvolveMainView"

local _bgLayer
local _treasureData= nil		-- 宝物的数据
local _selCheckedArr= nil		-- 
local _startItemId= nil
local _bottomSprite=nil
local _topTitleSprite= nil


local function init( )
	_bgLayer= nil
	_treasureData= {}
	_selCheckedArr= nil
	_bottomSprite=nil
	_topTitleSprite= nil
	_myTableView= nil
end

-- 返回按钮回调处理
local function closeAction(tag, item_obj)
	AudioUtil.playEffect("audio/effect/guanbi.mp3")

	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil

	local treaEvolveLayer = TreasureEvolveMainView.createLayer(tonumber(_startItemId))
	MainScene.changeLayer(treaEvolveLayer, "treaEvolveLayer")

end

function sureBtnAction( tag, item_obj)
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil

	local treaEvolveLayer = TreasureEvolveMainView.createLayer(tonumber(_selCheckedArr))
	MainScene.changeLayer(treaEvolveLayer, "treaEvolveLayer")
end



-- 创建标题面板
local function createTitleLayer( )

	-- 标题背景底图
	_topTitleSprite = CCSprite:create("images/hero/select/title_bg.png")
	_topTitleSprite:setScale(g_fScaleX)
	-- 加入背景标题底图进层
	-- 标题
	local ccSpriteTitle = CCSprite:create("images/treasure/treas_select.png")
	ccSpriteTitle:setPosition(ccp(45, 50))
	_topTitleSprite:addChild(ccSpriteTitle)

	local tItems = {
		{normal="images/common/close_btn_n.png", highlighted="images/common/close_btn_h.png", pos_x=493, pos_y=40, cb=closeAction},
	}
	local menu = LuaCC.createMenuWithItems(tItems)
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(-432)
	_topTitleSprite:addChild(menu)

	_topTitleSprite:setPosition(0, _layerSize.height)
	_topTitleSprite:setAnchorPoint(ccp(0, 1))
	_bgLayer:addChild(_topTitleSprite)
end


-- 创建底部面板
local function createBottomSprite()

	_bottomSprite = CCSprite:create("images/common/sell_bottom.png")
	_bottomSprite:setScale(g_fScaleX)
	_bottomSprite:setPosition(ccp(0, 0))
	_bottomSprite:setAnchorPoint(ccp(0,0))
	_bgLayer:addChild(_bottomSprite, 10)

	-- 已选择装备
	local equipLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1979"), g_sFontName, 25)
	equipLabel:setColor(ccc3(0xff, 0xff, 0xff))
	equipLabel:setAnchorPoint(ccp(0.5, 0.5))
	equipLabel:setPosition(ccp(_bottomSprite:getContentSize().width*0.33, _bottomSprite:getContentSize().height*0.4))
	_bottomSprite:addChild(equipLabel)

	-- 物品数量背景
	local fullRect = CCRectMake(0,0,34,32)
	local insetRect = CCRectMake(10,10,14,12)
	local itemNumSprite = CCScale9Sprite:create("images/common/checkbg.png", fullRect, insetRect)
	itemNumSprite:setPreferredSize(CCSizeMake(65, 38))
	itemNumSprite:setAnchorPoint(ccp(0.5,0.5))
	itemNumSprite:setPosition(ccp(_bottomSprite:getContentSize().width* 0.38125, _bottomSprite:getContentSize().height*0.4))
	_bottomSprite:addChild(itemNumSprite)

	-- -- 物品数量
	_itemNumLabel = CCLabelTTF:create("0", g_sFontName, 25)
	_itemNumLabel:setColor(ccc3(0xff, 0xff, 0xff))
	_itemNumLabel:setAnchorPoint(ccp(0.5, 0.5))
	_itemNumLabel:setPosition(ccp(itemNumSprite:getContentSize().width*0.5, itemNumSprite:getContentSize().height*0.4))
	itemNumSprite:addChild(_itemNumLabel)

	-- 出售按钮
	local sellMenuBar = CCMenu:create()
	sellMenuBar:setPosition(ccp(0,0))
	_bottomSprite:addChild(sellMenuBar)
	sellMenuBar:setTouchPriority(-433)
	local sellBtn =  LuaMenuItem.createItemImage("images/tip/btn_confirm_n.png", "images/tip/btn_confirm_h.png" )
	sellBtn:setAnchorPoint(ccp(0.5, 0.5))
    sellBtn:setPosition(ccp(_bottomSprite:getContentSize().width*560/640, _bottomSprite:getContentSize().height*0.4))
    sellBtn:registerScriptTapHandler(sureBtnAction)

	sellMenuBar:addChild(sellBtn)
end

-- 
function refreshBottomUI( )
	local selectArr= getSelCheckedArr()
	if(selectArr== nil) then
		_itemNumLabel:setString("0")
	else
		_itemNumLabel:setString("1")
	end
end

-- 获得可以精炼的宝物数据
function getSelTreasureData(  )
	
	bagInfo = DataCache.getBagInfo()
	curData = {}
	if (bagInfo) then
		for i=1,#bagInfo.treas do 
			if(TreasureEvolveUtil.isUpgrade(bagInfo.treas[i].item_id)) then
				table.insert(curData, bagInfo.treas[i])
			end
		end
	end

	local herosTreas = ItemUtil.getTreasOnFormation()

	for k,v in pairs(herosTreas) do
		if(TreasureEvolveUtil.isUpgrade(v.item_id)) then
				table.insert(curData, v)
		end
	end
	return curData
end

---- 获得选中的材料item_id
function getSelCheckedArr()
	return _selCheckedArr
end

-- 保存选中的材料item_id
function setSelCheckedArr(selCheckArr )
	_selCheckedArr=selCheckArr
end

-- 创建TableView  
function createTableView()
	_treasureData= getSelTreasureData()

	local cellSize = CCSizeMake(640*g_fScaleX,170*g_fScaleX)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif fn == "cellAtIndex" then
            a2 = TreasRefineSelCell.createCell(_treasureData[a1 + 1], refreshBottomUI)
            a2:setScale(g_fScaleX)
			r = a2
		elseif fn == "numberOfCells" then
			r = #curData
		elseif fn == "cellTouched" then
			
			-- local m_data = curData[a1:getIdx()+1]

			-- local cellBg = tolua.cast(a1:getChildByTag(1), "CCSprite")
			-- local menubar_m = tolua.cast(cellBg:getChildByTag(9898), "CCMenu")
			-- local menuBtn_M = tolua.cast(menubar_m:getChildByTag(tonumber(m_data.item_id)), "CCMenuItemSprite")
			
			-- local isIn = checkedSelectCell(tonumber(m_data.item_id))
			-- if(isIn == true) then
			-- 	menuBtn_M:unselected()
			-- else
			-- 	menuBtn_M:selected()
			-- end
			-- refreshBottomSprite()
		elseif (fn == "scroll") then
			
		end
		return r
	end)
	local height = _layerSize.height- (_topTitleSprite:getContentSize().height - 12)*(_topTitleSprite:getScale())- _bottomSprite:getContentSize().height*(_bottomSprite:getScale())
	_myTableView = LuaTableView:createWithHandler(h, CCSizeMake(_layerSize.width,height))
    _myTableView:setAnchorPoint(ccp(0,0))
	_myTableView:setBounceable(true)
	-- _myTableView:setScale(g_fScaleX)
	_myTableView:setTouchPriority(-433)
	_myTableView:setPosition(ccp(0,(_bottomSprite:getContentSize().height-5)*(_bottomSprite:getScale())))
	-- myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_bgLayer:addChild(_myTableView, 9)

end

-- 刷新物品的
function updateIndexCellByTid(item_id )
	if(item_id == nil) then
		return
	end
	local index= #_treasureData
	for i=1,#_treasureData do
		if(tonumber(item_id) == tonumber(_treasureData[i].item_id)) then
			index= i-1
			break
		end
	end
	-- print("item_id is :", item_id)
	-- print_t(tid)
	print("selectArr  is :", getSelCheckedArr() )
	-- print("index  is : ", index)
	local curCell = tolua.cast(_myTableView:cellAtIndex(index),"CCTableViewCell")
	if(curCell== nil ) then
		return
	else
		_myTableView:updateCellAtIndex(index)
	end
end

function createLayer( item_id )
	init()

	_selCheckedArr = item_id
	_startItemId= item_id
	_bgLayer = CCLayer:create()

	local bg = CCSprite:create("images/main/module_bg.png")
	bg:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bg)

	require "script/ui/main/BulletinLayer"
	require "script/ui/main/MainScene"
	require "script/ui/main/MenuLayer"
	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
	
	MainScene.getAvatarLayerObj():setVisible(false)
	MenuLayer.getObject():setVisible(false)
	BulletinLayer.getLayer():setVisible(true)

	_layerSize = {width= 0, height=0}
	_layerSize.width= g_winSize.width 
	_layerSize.height =g_winSize.height - (bulletinLayerSize.height)*g_fScaleX

	createTitleLayer()
	createBottomSprite()
	createTableView()

	return _bgLayer

end

