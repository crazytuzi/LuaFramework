-- Filename：	StarAchieveLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-11-26
-- Purpose：		名将成就

module ("StarAchieveLayer", package.seeall)


require "script/ui/star/StarAchieveCell"


local _bgLayer = nil
local _bgSprite = nil

function init()
	_bgLayer = nil
	_bgSprite = nil
end

-- 
function closeAction( tag, itenBtn )
	local starLayer = StarLayer.createLayer()
	MainScene.changeLayer(starLayer, "starLayer")
end

-- 属性总览
function showAllAttrAction( tag, itemBtn )
	local  starAllAttrLayer= StarAllAttrLayer.createLayer()
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(starAllAttrLayer,9999)
end

--对二分查找的一个扩展
function binarySearch(p_table,p_value)
    --第一个元素下标
    local lowIndex = 1
    --最后一个元素下标
    local highIndex = #p_table
    --进入循环
    while lowIndex <= highIndex do
        --中间下标
        local middleIndex = math.floor((lowIndex + highIndex)*0.5)
        local middleValue = tonumber(p_table[middleIndex].completeArray)
        --如果到元素则返回下标
        if middleValue == p_value then
            return middleIndex
        elseif middleValue > p_value then
            lowIndex = middleIndex + 1
        else
            highIndex = middleIndex - 1
        end
    end

    return highIndex + 1
end

-- 创建tableView背景
function createTableView()
	local myScale = _bgLayer:getContentSize().width/640/MainScene.elementScale

	local cellBg = CCSprite:create("images/star/star_achieve_bg.png")
	cellSize = cellBg:getContentSize()			--计算cell大小

	local t_ability, all_levels = StarUtil.getTotalStarAttr()

	local achieveData_arr = StarUtil.getStarAchieveDBData()

	-- tableView
	local tableViewBgSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")

	local spHeight = _bgSprite:getContentSize().height - (70+85)*myScale
	tableViewBgSprite:setContentSize(CCSizeMake(_bgSprite:getContentSize().width*0.93, spHeight))
	tableViewBgSprite:setAnchorPoint(ccp(0.5, 1))
	tableViewBgSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5, _bgSprite:getContentSize().height-70*myScale))
	_bgSprite:addChild(tableViewBgSprite)

	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width*myScale, cellSize.height*myScale)
		elseif fn == "cellAtIndex" then

            a2 = StarAchieveCell.createCell(achieveData_arr[a1 + 1], all_levels )
            a2:setScale(myScale)
			r = a2
		elseif fn == "numberOfCells" then
			r = #achieveData_arr
		elseif fn == "cellTouched" then

		elseif (fn == "scroll") then
			
		end
		return r
	end)
	
	local findIndex = binarySearch(achieveData_arr,all_levels)
	-- local indexFunction = function(table,key)
	-- 	print("matatable,deng deng deng deng deng")
	-- 	return tonumber(achieveData_arr[key].completeArray)
	-- end
	-- local findIndex = table.binarySearch(achieveData_arr,all_levels,true,nil,nil,indexFunction)
	local beyondNum = #achieveData_arr + 1 - findIndex

	local myTableView = LuaTableView:createWithHandler(h, CCSizeMake(tableViewBgSprite:getContentSize().width, tableViewBgSprite:getContentSize().height-20))
    myTableView:setAnchorPoint(ccp(0,0))
	myTableView:setBounceable(true)
	myTableView:setPosition(ccp(0, 10)) 
	-- myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	tableViewBgSprite:addChild(myTableView)

	local oriOffset = myTableView:getContentOffset()
	local visibleNum = beyondNum == 0 and 0 or beyondNum - 1
	local newY = oriOffset.y + visibleNum*cellSize.height*myScale
	myTableView:setContentOffset(ccp(oriOffset.x,newY))
end


-- 创建背景Sprite
function createBgSprite()
	local bgSize = _bgLayer:getContentSize()
	local myScale = _bgLayer:getContentSize().width/640/MainScene.elementScale

	-- 背景sprite
	local contengSize = CCSizeMake(_bgLayer:getContentSize().width/MainScene.elementScale,  _bgLayer:getContentSize().height/MainScene.elementScale)

	_bgSprite = CCScale9Sprite:create("images/item/equipinfo/bg_9s.png")
	_bgSprite:setContentSize(contengSize)
	_bgSprite:setAnchorPoint(ccp(0,0))
	_bgSprite:setPosition(ccp(0,0))
	_bgLayer:addChild(_bgSprite, 1)

	-- 上部标题
	-- 顶部
	local topSprite = CCSprite:create("images/item/equipinfo/topbg.png")
	topSprite:setAnchorPoint(ccp(0.5, 1))
	topSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5, _bgSprite:getContentSize().height))
	topSprite:setScale(myScale)
	_bgSprite:addChild(topSprite, 2)

	-- 标题
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1378"), g_sFontPangWa, 33, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(ccp( ( topSprite:getContentSize().width )/2, topSprite:getContentSize().height*0.6))
    topSprite:addChild(titleLabel)

    -- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	topSprite:addChild(closeMenuBar)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(1, 0.5))
    closeBtn:setPosition(ccp(topSprite:getContentSize().width*1.01, topSprite:getContentSize().height*0.54))
    closeBtn:registerScriptTapHandler(closeAction)
	closeMenuBar:addChild(closeBtn)
	-- closeMenuBar:setTouchPriority(_menu_priority-1)

    -- 属性总览
 --    require "script/libs/LuaCC"
	-- local attrMenuBar = CCMenu:create()
	-- attrMenuBar:setPosition(ccp(0, 0))
	-- _bgSprite:addChild(attrMenuBar)
 --    local m_backButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(210,73),GetLocalizeStringBy("key_3070"),ccc3(255,222,0))
 --    m_backButton:setAnchorPoint(ccp(0.5,0))
 --    m_backButton:setPosition(ccp(_bgSprite:getContentSize().width*0.5, 10))
 --    m_backButton:registerScriptTapHandler(showAllAttrAction)
 --    -- m_backButton:setScale(MainScene.elementScale)
 --    attrMenuBar:addChild(m_backButton)


end



function createLayer()
	init()
	_bgLayer = MainScene.createBaseLayer("images/main/module_bg.png", true, false,true)

-- 创建背景Sprite
	createBgSprite()
-- 创建tableView背景
	createTableView()

	return _bgLayer
end
