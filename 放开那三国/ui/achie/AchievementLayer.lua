-- Filename: AchievementLayer.lua
-- Author: LLP
-- Date: 2014-2-17
-- Purpose: 该文件用于: 成就系统

module("AchievementLayer", package.seeall)

require "script/ui/item/ItemUtil"
require "script/ui/main/MainScene"
require "script/ui/common/LuaMenuItem"
require "db/DB_Achie_table"
require "script/ui/achie/AchieItem"

require "script/audio/AudioUtil"

local IMG_PATH = "images/main/"				-- 主城场景图片主路径
local IMG_PATH_MENU = IMG_PATH .. "menu/"	-- 主城场景菜单图片路径

local _bgLayer 				= nil
local bgSprite 				= nil
local bulletinLayerSize		= nil
local dataCpy 				= nil

local _menu_priority 		= -410
local kindCount				= 1
local sameIndex 			= 1
local sameJ 				= 1
local tagCpy 				= 0
local scrollViewHeight 		= 0
local downDis 				= 0
local layerHeight 			= 800
local status1 				= 0
local haveNum				=0
local totalNum 				=0

local showRedTable 			= {}
local totalArry				= {}
local totalArryAll			= {}
local countTable 			= {}
local tableClick 			= {}
local scaleTable 			= {}
local menuPosTable 			= {}
childTable  				= {}
local childCountTable 		= {}
local firstIn 				= true

local function init()
	_bgLayer 				= nil
	bgSprite 				= nil
	bulletinLayerSize		= nil
	dataCpy 				= nil

	_menu_priority 			= -410
	 kindCount				= 1
	 sameIndex 				= 1
	 sameJ 					= 1
	 tagCpy 				= 0
	 scrollViewHeight 		= 0
	 downDis 				= 0
	 layerHeight 			= 800
	 status1 				= 0
	 haveNum				=0
	 totalNum 				=0
	 firstIn 				= true
	countTable 				= {}
	tableClick 				= {}
	totalArry				= {}
	totalArryAll			= {}
	scaleTable 				= {}
	menuPosTable 			= {}
	childTable  			= {}
	childCountTable 		= {}
	showRedTable 			= {false,false,false,false}
end

local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
	    return true
    elseif (eventType == "moved") then
    	print("moved")
    else
        print("end")
	end
end

local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _menu_priority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer 				= nil
		bgSprite 				= nil
		bulletinLayerSize		= nil
		dataCpy 				= nil

		_menu_priority 			= -410
		kindCount				= 1
		sameIndex 				= 1
		sameJ 					= 1
		tagCpy 				= 0
		scrollViewHeight 		= 0
		downDis 				= 0
		layerHeight 			= 800
		status1 				= 0
		status2 				= 0

		countTable 				= {}
		tableClick 				= {}
		totalArry				= {}
		scaleTable 				= {}
		menuPosTable 			= {}
		childTable  			= {}
		childCountTable 		= {}
	end
end


local function MenuItemCallFun(tag, itemBtn)
	-- body
	require "script/ui/achie/AchieInfoLayer"
	showLayer = AchieInfoLayer.show(dataCpy,haveNum,totalNum)
	closeAction()
end

local function createBottomPanel()
	local bg = CCSprite:create("images/common/sell_bottom.png")
	bg:setAnchorPoint(ccp(0,0))
	bg:setScale(g_fScaleX)
	bg:setPosition(ccp(0,0))

	_bgLayer:addChild(bg,1)

	bottomBgSize = bg:getContentSize()
	local actionMenuBar = CCMenu:create()

	local skipMenuItem = CCMenuItemImage:create("images/common/btn/btn_bg_n.png","images/common/btn/btn_bg_h.png")
	skipMenuItem:setAnchorPoint(ccp(0.5,0.5))
	skipMenuItem:setPosition(ccp(bottomBgSize.width*0.5,bottomBgSize.height*0.4))
	actionMenuBar:setPosition(ccp(0, 0))
	actionMenuBar:addChild(skipMenuItem,10)
	-- 注册挑战回调
	skipMenuItem:registerScriptTapHandler(MenuItemCallFun)
	-- 阵容字体
	local item_font = CCRenderLabel:create( GetLocalizeStringBy("llp_32") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setAnchorPoint(ccp(0.5,0.5))
    item_font:setPosition(ccp(skipMenuItem:getContentSize().width*0.5,skipMenuItem:getContentSize().height*0.5))
   	skipMenuItem:addChild(item_font)

	actionMenuBar:setTouchPriority(_menu_priority - 401)
	bg:addChild(actionMenuBar,10)
end


function closeAction( ... )
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	AchieveInfoData.getServiceAchieveData()
	MainBaseLayer.refreshRedBtn()
	if(_bgLayer)then
		MainScene.setMainSceneViewsVisible(true,true,true)
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer=nil
	end
end

local function createBackGround()
	bulletinLayerSize = BulletinLayer.getLayerContentSize()
	bottomBg = CCSprite:create("images/common/sell_bottom.png")

	local fullRect = CCRectMake(0,0,196, 198)
	local insetRect = CCRectMake(50,50,96,98)
	bgSprite = CCScale9Sprite:create("images/item/equipinfo/bg_9s.png")
	bgSprite:setContentSize(CCSizeMake(g_winSize.width, g_winSize.height-bulletinLayerSize.height-bottomBg:getContentSize().height*g_fScaleX*0.85))
	bgSprite:setAnchorPoint(ccp(0.5, 1))
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, bgSprite:getContentSize().height+bottomBg:getContentSize().height*g_fScaleX*0.85))

	_bgLayer:addChild(bgSprite, 1)

	local topSprite = CCSprite:create("images/item/equipinfo/topbg.png")
	topSprite:setScale(bgSprite:getContentSize().width/topSprite:getContentSize().width)
	topSprite:setAnchorPoint(ccp(0.5, 1))
	topSprite:setPosition(ccp(g_winSize.width*0.5, bgSprite:getContentSize().height))
	bgSprite:addChild(topSprite, 2)

	topSpriteSize = topSprite:getContentSize()

	-- 正常
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_31"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(ccp( ( topSprite:getContentSize().width)/2, topSprite:getContentSize().height*0.5))
    topSprite:addChild(titleLabel)

	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	topSprite:addChild(closeMenuBar)

	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(1, 0.5))
    closeBtn:setPosition(ccp(topSprite:getContentSize().width*1.01, topSprite:getContentSize().height*0.54))
    closeBtn:registerScriptTapHandler(closeAction)
	closeMenuBar:addChild(closeBtn)
	closeMenuBar:setTouchPriority(_menu_priority-50)
	MainScene.setMainSceneViewsVisible(false,false,true)

	createBottomPanel()
end

local function menu_item_tap_handler(tag, item)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	itemCpy = item
	tolua.cast(itemCpy,"CCMenuItemImage")
	local normal = CCSprite:create("images/achie/0.png")
	local selected = CCSprite:create("images/achie/1.png")
	status1 = 0
	if(not tableClick[tag])then
		tableClick[tag] = true
		local pushNum = 0

		scaleTable[tag] = 0

		for i=1,kindCount do
			if(scaleTable[i]==1)then
				pushNum = 1
			end
		end

		itemCpy:setNormalImage(normal)
		itemCpy:setSelectedImage(selected)
		itemCpy:getChildByTag(tag):removeAllChildrenWithCleanup(true)

		layerHeight = layerHeight-150*(childCountTable[tag])*(bgSprite:getContentSize().width/itemCpy:getContentSize().width)
		layer:setContentSize(CCSizeMake(640,layerHeight))

		for i=1,tag do
			layer:getChildByTag(i):setPosition(ccp(bgSprite:getContentSize().width*0.5,menuPosTable[i].y-150*(childCountTable[tag])*(bgSprite:getContentSize().width/itemCpy:getContentSize().width)))
			menuPosTable[i]=ccp(bgSprite:getContentSize().width*0.5,menuPosTable[i].y-150*(childCountTable[tag])*(bgSprite:getContentSize().width/itemCpy:getContentSize().width))
		end

		layer:setPosition(ccp(0,layer:getPositionY()+150*childCountTable[tag]*(bgSprite:getContentSize().width/itemCpy:getContentSize().width)))
		childCountTable = nil
		childCountTable = {}
		for i=1,kindCount do
			table.insert(childCountTable,table.count(childTable[i]))
		end
	else
		tableClick[tag] = false
		scaleTable[tag] = 1
		itemCpy:setNormalImage(selected)
		itemCpy:setSelectedImage(normal)

		for j = 1,table.count(childTable[tag]) do
			for k = 1,table.count(childTable[tag][j]) do
				if(childTable[tag][j][k].status == 1)then
					status1 = status1+1
					break
				end
			end
		end

		local index = 1
		for j=1, childCountTable[tag] do
			local isFirst = false
			local sprite = AchieItem.createCell(childTable[tag][j][1],tag,j)

			sprite:setAnchorPoint(ccp(0.5,1))
			itemCpy:getChildByTag(tag):addChild(sprite)
			sprite:setTag(childTable[tag][j][1].id)
			sprite:setPosition(ccp(sprite:getContentSize().width*0.5+10,-150*index))
			index = index+1
			isFirst = true
		end

		layerHeight = layerHeight+150*(childCountTable[tag])*(bgSprite:getContentSize().width/itemCpy:getContentSize().width)
		layer:setContentSize(CCSizeMake(640,layerHeight))

		for i=1,tag do
			if(menuPosTable[i]~=nil)then
				layer:getChildByTag(i):setPosition(ccp(menuPosTable[i].x,menuPosTable[i].y+150*childCountTable[tag]*(bgSprite:getContentSize().width/itemCpy:getContentSize().width)))
				menuPosTable[i] = ccp(menuPosTable[i].x,menuPosTable[i].y+150*childCountTable[tag]*(bgSprite:getContentSize().width/itemCpy:getContentSize().width))
			else
				layer:getChildByTag(i):setPosition(ccp(bgSprite:getContentSize().width*0.5,layerHeight-itemCpy:getContentSize().height*(bgSprite:getContentSize().width/itemCpy:getContentSize().width)*(i-1)))
				menuPosTable[i] = ccp(bgSprite:getContentSize().width*0.5,layerHeight-itemCpy:getContentSize().height*(bgSprite:getContentSize().width/itemCpy:getContentSize().width)*(i-1))
			end
		end
		layer:setPosition(ccp(0,layer:getPositionY()-150*(bgSprite:getContentSize().width/itemCpy:getContentSize().width)*childCountTable[tag]))
		for push=tag+1,kindCount do
			local position = CCPointMake(bgSprite:getContentSize().width*0.5,menuPosTable[push].y)
			layer:getChildByTag(push):setPosition(position)
			menuPosTable[push]=position
		end

	end
end

-- 按钮上边的提示小红圈
-- 添加对象  item
-- isVisible 是否显示
function showTipSprite( item, isVisible )
	if(item == nil)then
		return
	end
	if( item:getChildByTag(1915) ~= nil )then
		local tipSprite = tolua.cast(item:getChildByTag(1915),"CCSprite")
		tipSprite:setVisible(isVisible)
	else
		local tipSprite = CCSprite:create("images/common/tip_2.png")
	    tipSprite:setAnchorPoint(ccp(0.5,0.5))
	    tipSprite:setPosition(ccp(item:getContentSize().width*0.95,item:getContentSize().height*0.8))
	    item:addChild(tipSprite,1,1915)
	    tipSprite:setVisible(isVisible)
	end
end

local function createParentMenu()
	for i=1,kindCount do
		local menu = BTSensitiveMenu:create()
		if(menu:retainCount()>1)then
			menu:release()
			menu:autorelease()
		end
		local itemNormal = CCMenuItemImage:create("images/achie/0.png", "images/achie/1.png")
		local showTip = false
		for k,v in pairs(totalArry[i])do
			if(tonumber(v.status)==1)then
				showTip = true
				break
			end
		end

		showTipSprite(itemNormal,showTip)

		local node = CCNode:create()
		local achieLabel = CCRenderLabel:create("", g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		if(i==1)then
			achieLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_27"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		elseif(i==2)then
			achieLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_28"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		elseif(i==3)then
			achieLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_29"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		elseif(i==4)then
			achieLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_30"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		end
		achieLabel:setColor(ccc3(0xff, 0xf6, 0x00))
		achieLabel:setAnchorPoint(ccp(0.5,0.5))
		achieLabel:setPosition(ccp(itemNormal:getContentSize().width*0.5,itemNormal:getContentSize().height*0.5))
		itemNormal:addChild(achieLabel,1)

		itemNormal:setPosition(0, 0 )
		itemNormal:setAnchorPoint(ccp(0.5, 1))
		itemNormal:addChild(node,0,i)
		itemNormal:registerScriptTapHandler(menu_item_tap_handler)
		itemNormal:setScale(bgSprite:getContentSize().width/itemNormal:getContentSize().width)
		node:setAnchorPoint(ccp(0,0))
		node:setPosition(ccp(0,0))

		menu:setAnchorPoint(ccp(0.5,1))
		menu:setTouchPriority(_menu_priority-1)
		menu:setPosition(ccp(bgSprite:getContentSize().width*0.5,layer:getContentSize().height-itemNormal:getContentSize().height*(bgSprite:getContentSize().width/itemNormal:getContentSize().width)*(i-1)))
		menu:addChild(itemNormal,0,i)
		menuPosTable[i] = ccp(bgSprite:getContentSize().width*0.5,layer:getContentSize().height-itemNormal:getContentSize().height*(bgSprite:getContentSize().width/itemNormal:getContentSize().width)*(i-1))
		layer:addChild(menu,0,i)
	end
end

local function fnCreateDetailContentLayer()
	--创建ScrollView
	local contentScrollView = CCScrollView:create()
	contentScrollView:setTouchPriority(_menu_priority-3 or -703)
	scrollViewHeight = bgSprite:getContentSize().height-topSpriteSize.height*(bgSprite:getContentSize().width/topSpriteSize.width)+5
	contentScrollView:setViewSize(CCSizeMake(g_winSize.width, scrollViewHeight))
	contentScrollView:setDirection(kCCScrollViewDirectionVertical)

	layer = CCLayer:create()

	contentScrollView:setContainer(layer)

	local itemNormal = CCSprite:create("images/achie/0.png")
	itemNormal:setScale(bgSprite:getContentSize().width/itemNormal:getContentSize().width)
	layerHeight = itemNormal:getContentSize().height*kindCount*(bgSprite:getContentSize().width/itemNormal:getContentSize().width)

	layer:setContentSize(CCSizeMake(640,layerHeight))
	layer:setPosition(ccp(0,scrollViewHeight-layerHeight))

	contentScrollView:setPosition(ccp(0,0))
	bottomBg:release()

	bgSprite:addChild(contentScrollView)
	createParentMenu()
end

local function createUI()
	sendAchieCommond()
	--在命令回调里创建ui
end

function createLayer()
	init()

	_bgLayer = CCLayer:create()

	_bgLayer:registerScriptHandler(onNodeEvent)

	--创建UI
	createUI()

	return _bgLayer
end

--- 发送获取成就命令
function sendAchieCommond()
	RequestCenter.getAchieInfo(getAchieInfoCallBack)
end

--- 获取成就数据并处理
function getAchieInfoCallBack( cbFlag, dictData, bRet )
	-- body
	if(dictData.err == "ok")then
		dataCpy = dictData
		for id,value in pairs(dictData.ret)do
			print("id====",id)
			local achieData = DB_Achie_table.getDataById(id)
			local mainKey = tonumber(achieData.parent_type)

			if(totalArry[mainKey]==nil or table.isEmpty(totalArry[mainKey]))then
				totalArry[mainKey] = {}
			end
			if(totalArryAll[mainKey]==nil or table.isEmpty(totalArryAll[mainKey]))then
				totalArryAll[mainKey] = {}
			end
			achieData.finishNum = tonumber(value.finish_num)
			achieData.status = tonumber(value.status)
			if(achieData.status==1)then
				achieData.point=1
			else
				achieData.point=0
			end
			if(achieData.status~=0)then
				haveNum = haveNum+1
			end
			totalNum = totalNum+1
			table.insert(totalArryAll[mainKey],achieData)
			if(tonumber(value.status)~=2)then
				table.insert(totalArry[mainKey],achieData)
			end

			if(mainKey>kindCount)then
				kindCount = mainKey
			end
		end

		for i=1,kindCount do
				local dataCache = totalArry[i]
				local function keySort ( dataCache1, dataCache2 )

		   			return tonumber(dataCache1.id) < tonumber(dataCache2.id)
				end
				table.sort( dataCache, keySort )
				local dataCacheAll = totalArryAll[i]
				local function keySort ( dataCache1, dataCache2 )
		   			return tonumber(dataCache1.id) < tonumber(dataCache2.id)
				end
				table.sort( dataCacheAll, keySort )
		end
		dataCpy = totalArryAll
		for i=1,kindCount do
			sameJ = 1
			sameIndex = 1
			for j=1,table.count(totalArry[i]) do
				if(table.isEmpty(childTable[i])==true)then
					childTable[i] = {}
				end
				if(table.isEmpty(childTable[i][sameJ])==true)then
					childTable[i][sameJ] = {}
				end

				if(j>1)then
					if(totalArry[i][j].sort==totalArry[i][j-1].sort)then
						sameIndex = sameIndex + 1
						childTable[i][sameJ][sameIndex] = totalArry[i][j]
					else
						sameJ = sameJ+1
						sameIndex = 1
						childTable[i][sameJ] = {}
						childTable[i][sameJ][sameIndex] = totalArry[i][j]
					end
				else
					childTable[i][j] = {}
					childTable[i][j][1] = totalArry[i][1]
				end
			end
			table.insert(childCountTable,table.count(childTable[i]))
			local function keySort ( dataCache1, dataCache2 )
	   			return tonumber(dataCache1[1].point)>tonumber(dataCache2[1].point)
			end
			if childTable[i] == nil then
				childTable[i] = {}
			end
			table.sort( childTable[i], keySort )
			table.insert(tableClick,true)
			table.insert(scaleTable,0)
		end

	if(firstIn == true)then
		--创建底层
		firstIn = false

		createBackGround()

		--创建滑动信息
		fnCreateDetailContentLayer()
	end

	end
end

function freshMainLayer(tag,j,id,key)
	-- body
	if(table.count(childTable[tag][j])>1)then
		if(childTable[tag][j][key+1]~=nil)then
			local pos = itemCpy:getChildByTag(tag):getChildByTag(id):getPositionY()
			itemCpy:getChildByTag(tag):removeChildByTag(id,true)
			table.remove(childTable[tag][j],key)
			local sprite = AchieItem.createCell(childTable[tag][j][key],tag,j)
			sprite:setAnchorPoint(ccp(0.5,1))
			sprite:setPosition(ccp(sprite:getContentSize().width*0.5,pos))
			itemCpy:getChildByTag(tag):addChild(sprite)
			sprite:setTag(childTable[tag][j][key].id)
		end
	else
		table.remove(childTable[tag],j)
	end
	for i=1,4 do
		local show = false
		for j=1,table.count(childTable[i])do
			for k,v in pairs(childTable[i][j])do
				if(tonumber(v.status)==1)then
					show = true
					break
				end
			end
		end
		showRedTable[i] = show
		local item = layer:getChildByTag(i):getChildByTag(i)
		showTipSprite(item,showRedTable[i])
	end
end