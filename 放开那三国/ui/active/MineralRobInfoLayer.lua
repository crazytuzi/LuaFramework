-- Filename：	MineralRobInfoLayer.lua
-- Author：		bzx
-- Date：		2013-9-26
-- Purpose：		资源矿抢夺信息

module ("MineralRobInfoLayer", package.seeall)

require "script/libs/LuaCCSprite"
require "script/utils/TimeUtil"

local _layer
local _touchPriority
local _zOrder
local _dialogInfo
local _allPushMineralRobs
local _tableView

function show(touchPriority, zOrder)
    _touchPriority = touchPriority
    _zOrder = zOrder
    if _allPushMineralRobs == nil then
        Network.rpc(handleGetRobLog, "mineral.getRobLog", "mineral.getRobLog")
    else
        showWithInfo()
    end
end

function showWithInfo()
    local layer = create(_touchPriority, _zOrder)
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(layer)
end

function handleGetRobLog( cbFlag, dictData, bRet )
    if dictData.err ~= "ok" then
        return
    end
    _allPushMineralRobs = dictData.ret or {}
    showWithInfo()
end

function init(touchPriority, zOrder)
    _touchPriority = touchPriority
    _zOrder = zOrder
    --[[
    _allPushMineralRobs = {
        {
          domain_id = "50001",
          pit_id = "3",
          pre_capture = "12341",
          now_capture = "扶曼洁",
          time = tostring(os.time())
        },
        {
          domain_id = "50001",
          pit_id = "3",
          pre_capture = "12341",
          now_capture = "扶曼洁",
          time = tostring(os.time())
        }
    }
    --]]
end



function create(touchPriority, zOrder)
    init(touchPriority, zOrder)
    _dialogInfo = {
        title = GetLocalizeStringBy("key_8341"),
        size = CCSizeMake(640, 800),
        priority = _touchPriority,
        swallowTouch = true,
    }
    _layer = LuaCCSprite.createDialog_1(_dialogInfo)
    _dialogInfo.dialog:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
    _dialogInfo.dialog:setAnchorPoint(ccp(0.5, 0.5))
    _dialogInfo.dialog:setScale(MainScene.elementScale)
    loadTableView()
    return _layer
end

function loadTableView()
    local tableViewBg = BaseUI.createContentBg(CCSizeMake(584, 710))
    _dialogInfo.dialog:addChild(tableViewBg)
    tableViewBg:setAnchorPoint(ccp(0.5, 1))
    tableViewBg:setPosition(ccp(_dialogInfo.dialog:getContentSize().width * 0.5, _dialogInfo.dialog:getContentSize().height - 55))
    
    local handler = LuaEventHandler:create(function(fn, table, a1, a2)
        print(fn)
		local r
        local count = #_allPushMineralRobs
		if (fn == "cellSize") then
			-- 显示单元格的间距
			r = CCSizeMake(580, 137)
		elseif (fn == "cellAtIndex") then
			r = createCell(_allPushMineralRobs[count - a1])
		elseif (fn == "numberOfCells") then
			r = count
		elseif (fn == "cellTouched") then
		elseif (fn == "scroll") then
		else
		end
		return r
	end)

	_tableView = LuaTableView:createWithHandler(handler, CCSizeMake(580, 690))
    _tableView:setBounceable(true)
	_tableView:ignoreAnchorPointForPosition(false)
	_tableView:setAnchorPoint(ccp(0.5, 0.5))
	_tableView:setPosition(ccpsprite(0.5, 0.5, tableViewBg))
	tableViewBg:addChild(_tableView)
	-- 设置单元格升序排列
	_tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	-- 设置滑动列表的优先级
	_tableView:setTouchPriority(_touchPriority - 10)
end

function createCell(robInfo)
    print_t(robInfo)
    local cell = CCTableViewCell:create()
    -- 黄色底背景
	local sprite_bg = BaseUI.createYellowBg(CCSizeMake(580,137))
	-- 文字背景
	local text_bg = BaseUI.createContentBg(CCSizeMake(560,80))
	text_bg:setAnchorPoint(ccp(0,0))
	text_bg:setPosition(ccp(10,15))
	sprite_bg:addChild(text_bg,1,1)
    sprite_bg:setAnchorPoint(ccp(0, 0))
    sprite_bg:setPosition(ccp(0, 0))
    cell:addChild(sprite_bg)
    
    local resDb = DB_Res.getDataById(tonumber(robInfo.domain_id))
    local names = {GetLocalizeStringBy("key_1427"), GetLocalizeStringBy("key_2722"), GetLocalizeStringBy("key_8312")}
    local colors = {ccc3(0xff, 0, 0xe1), ccc3(26, 175, 84), ccc3(252, 13, 27)}
    local number = 0
    if resDb.type == 1 then
        number = resDb.id - 50000
    elseif resDb.type == 2 then
        number = resDb.id - 10000
    elseif resDb.type == 3 then
        number = resDb.id - 60000
    else
        print("resDb.type有误")
    end
    local richInfo = {}
    richInfo.width = 500
    richInfo.alignment = 1
    richInfo.labelDefaultFont = g_sFontName
    richInfo.labelDefaultSize = 21
    richInfo.elements = 
    {
        {
            type = "CCLabelTTF",
            text = robInfo.now_capture,
            color = ccc3(0x00,0xe4,0xff)
        },
        {
            type = "CCLabelTTF",
            text = GetLocalizeStringBy("key_8313")
        },
        {
            type = "CCLabelTTF",
            text = robInfo.pre_capture,
            color = ccc3(0x00,0xe4,0xff)
        },
        {
            type = "CCLabelTTF",
            text = GetLocalizeStringBy("key_8314")
        },
        {
            type = "CCLabelTTF",
            text = string.format(GetLocalizeStringBy("key_8316"), names[resDb.type], number),
            color = colors[resDb.type]
        },
        {
            type = "CCLabelTTF",
            text = GetLocalizeStringBy("key_8315")
        },
        {
            type = "CCLabelTTF",
            text = resDb["res_name" .. robInfo.pit_id],
            color = ccc3(0x2a, 0xff, 0x00)
        }
    }
    require "script/libs/LuaCCLabel"
    local richLabel = LuaCCLabel.createRichLabel(richInfo)
    text_bg:addChild(richLabel)
    richLabel:setAnchorPoint(ccp(0, 1))
    richLabel:setPosition(ccp(10, text_bg:getContentSize().height - 10))
    local timeString = TimeUtil.getTimeStringWords(tonumber(robInfo.rob_time))
    local timeLabel = CCRenderLabel:create(timeString, g_sFontName, 21, 1, ccc3(0, 0, 0), type_stroke)
    sprite_bg:addChild(timeLabel)
    timeLabel:setAnchorPoint(ccp(0, 1))
    timeLabel:setPosition(ccp(25, sprite_bg:getContentSize().height - 13))
    timeLabel:setColor(ccc3(0x2a, 0xff, 0x00))
	return cell
end

function refresh()
    if _dialogInfo ~= nil and _dialogInfo.isRunning == true then
        _tableView:reloadData()
    end
end

function getAllPushMineralRobs()
    return _allPushMineralRobs
end

function addMineralRobInfo(mineralRobInfo)
    if _allPushMineralRobs == nil then
        return
    end
    table.insert(_allPushMineralRobs, mineralRobInfo)
    if #_allPushMineralRobs > 20 then
        table.remove(_allPushMineralRobs, 1)
    end
    refresh()
end