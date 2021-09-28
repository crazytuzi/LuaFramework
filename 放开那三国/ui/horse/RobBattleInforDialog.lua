-- Filename：	RobBattleInforDialog.lua
-- Author：		llp
-- Date：		2016-4-14
-- Purpose：		拦截战报

module ("RobBattleInforDialog", package.seeall)

require "script/libs/LuaCCSprite"
require "script/utils/TimeUtil"
require "script/ui/horse/HorseController"
local _layer
local _touchPriority
local _zOrder
local _dialogInfo
local _allPushRobInfos
local _tableView
local _tableViewBg
local _curIndex = 4
local horseNameTable = {GetLocalizeStringBy("llp_361"),GetLocalizeStringBy("llp_362"),GetLocalizeStringBy("llp_363"),GetLocalizeStringBy("llp_364")}
local horseColorTable = {ccc3(0, 0xeb, 0x21),ccc3(0x51, 0xfb, 0xff),ccc3(255, 0, 0xe1),ccc3(255, 0x84, 0)}

function show(touchPriority, zOrder,pStage)
    _touchPriority = touchPriority
    _zOrder = zOrder
    showWithInfo()
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
    _allPushRobInfos = dictData.ret or {}
    showWithInfo()
end

function init(touchPriority, zOrder)
    _tableViewBg = nil
    _tableView = nil
    _touchPriority = touchPriority
    _zOrder = zOrder
end



function create(touchPriority, zOrder)
    init(touchPriority, zOrder)
    _dialogInfo = {
        title = GetLocalizeStringBy("llp_389"),
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

function buttonClick( tag,item )
    -- body
    print("tag====",tag)
    _curIndex = tag
    if(tag==3)then
        HorseController.getAllMyInfo(freshView)
    elseif(tag==1)then
        HorseController.getStageInfo(3,freshView)
    elseif(tag==2)then
        HorseController.getStageInfo(4,freshView)
    end
end

function loadTableView()
    _tableViewBg = BaseUI.createContentBg(CCSizeMake(584, 660))

    require "script/libs/LuaCCMenuItem"
    
    local image_n = "images/common/bg/button/ng_tab_n.png"
    local image_h = "images/common/bg/button/ng_tab_h.png"
    local rect_full_n   = CCRectMake(0,0,63,43)
    local rect_inset_n  = CCRectMake(25,20,13,3)
    local rect_full_h   = CCRectMake(0,0,73,53)
    local rect_inset_h  = CCRectMake(35,25,3,3)
    local btn_size_n    = CCSizeMake(225, 60)
    local btn_size_n2   = CCSizeMake(165, 60)
    local btn_size_h    = CCSizeMake(230, 65)
    local btn_size_h2   = CCSizeMake(170, 65)
    
    local text_color_n  = ccc3(0x78, 0x25, 0x00)
    local text_color_h  = ccc3(0x78, 0x25, 0x00)
    local font          = g_sFontName
    local font_size     = 30
    local strokeCor_n   = ccc3(0xff, 0xff, 0xff)
    local strokeCor_h   = ccc3(0xff, 0xff, 0xff)
    local stroke_size_n = 0
    local stroke_size_h = 1
    
    -- 原来的数据结构整理完才发现封装的方法不支持九宫格。。。。气哭了。。。哭了一下午。。。

    --创建menubar用的参数table
    local radio_data = {}
    radio_data.touch_priority = _touchPriority - 50
    radio_data.space = 15
    radio_data.callback = buttonClick
    radio_data.direction = 1
    radio_data.defaultIndex = 1
    radio_data.items = {}

    local orangeButton = LuaCCMenuItem.createMenuItemOfRender2(  image_n, image_h,image_h,
          rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
          btn_size_n2, btn_size_h2,btn_size_h2,
          GetLocalizeStringBy("llp_390"), text_color_n, text_color_h, text_color_h, font, font_size, 
          strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)

    
    local redButton = LuaCCMenuItem.createMenuItemOfRender2(  image_n, image_h,image_h,
          rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
          btn_size_n2, btn_size_h2,btn_size_h2,
          GetLocalizeStringBy("llp_391"), text_color_n, text_color_h, text_color_h, font, font_size, 
          strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)


    local myButton = LuaCCMenuItem.createMenuItemOfRender2(  image_n, image_h,image_h,
          rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
          btn_size_n2, btn_size_h2,btn_size_h2,
          GetLocalizeStringBy("llp_392"), text_color_n, text_color_h, text_color_h, font, font_size, 
          strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)
    table.insert(radio_data.items,orangeButton)
    table.insert(radio_data.items,redButton)
    table.insert(radio_data.items,myButton)

    _menuBar = LuaCCSprite.createRadioMenuWithItems(radio_data)
    _menuBar:setAnchorPoint(ccp(0.5,0))
    _menuBar:setPosition(ccp(_tableViewBg:getContentSize().width * 0.5,_tableViewBg:getContentSize().height))
    _tableViewBg:addChild(_menuBar)

    _dialogInfo.dialog:addChild(_tableViewBg)
    _tableViewBg:setAnchorPoint(ccp(0.5, 1))
    _tableViewBg:setPosition(ccp(_dialogInfo.dialog:getContentSize().width * 0.5, _dialogInfo.dialog:getContentSize().height - 95))
end

function createTableView( ... )
    -- body
    local handler = LuaEventHandler:create(function(fn, table, a1, a2)
        print(fn)
        local r
        local count = #_allPushRobInfos
        if (fn == "cellSize") then
            -- 显示单元格的间距
            r = CCSizeMake(580, 137)
        elseif (fn == "cellAtIndex") then
            r = createCell(_allPushRobInfos[count - a1])
            r.type = a1+1
        elseif (fn == "numberOfCells") then
            r = count
        elseif (fn == "cellTouched") then
            print("index====",a1.type)
        elseif (fn == "scroll") then
        else
        end
        return r
    end)

    _tableView = LuaTableView:createWithHandler(handler, CCSizeMake(580, 640))
    _tableView:setBounceable(true)
    _tableView:ignoreAnchorPointForPosition(false)
    _tableView:setAnchorPoint(ccp(0.5, 0.5))
    _tableView:setPosition(ccpsprite(0.5, 0.5, _tableViewBg))
    _tableViewBg:addChild(_tableView)
    -- 设置单元格升序排列
    -- _tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    -- 设置滑动列表的优先级
    _tableView:setTouchPriority(_touchPriority - 10)
end

function freshView( pData )
    -- body
    _allPushRobInfos = pData or {}
    if(_tableView==nil)then
        createTableView()
    end
    refresh()
end

function getBattleInfoNode( pData )
    -- body
    local richInfo = {}
    local userId = UserModel.getUserUid()
    local isSucceed = tonumber(pData.success)
    if(userId==tonumber(pData.uid))then
        if(isSucceed==1)then
            richInfo.elements = 
                {
                    {
                        type = "CCLabelTTF",
                        text = GetLocalizeStringBy("llp_403"),
                    },
                    {
                        type = "CCLabelTTF",
                        text = pData.beUname,
                        color = ccc3(0x00,0xe4,0xff)
                    },
                    {
                        type = "CCLabelTTF",
                        text = horseNameTable[tonumber(pData.stage_id)],
                        color = horseColorTable[tonumber(pData.stage_id)]
                    },
                }
        else
            richInfo.elements = 
                {
                    {
                        type = "CCLabelTTF",
                        text = GetLocalizeStringBy("llp_405"),
                    },
                    {
                        type = "CCLabelTTF",
                        text = pData.beUname,
                        color = ccc3(0x00,0xe4,0xff)
                    },
                    {
                        type = "CCLabelTTF",
                        text = horseNameTable[tonumber(pData.stage_id)],
                        color = horseColorTable[tonumber(pData.stage_id)]
                    },
                    {
                        type = "CCLabelTTF",
                        text = GetLocalizeStringBy("llp_406")
                    }
                }
        end
    else
        if(isSucceed==1)then
            richInfo.elements = 
                {
                    {
                        type = "CCLabelTTF",
                        text = pData.uname,
                        color = ccc3(0x00,0xe4,0xff)
                    },
                    {
                        type = "CCLabelTTF",
                        text = GetLocalizeStringBy("llp_407")
                    },
                    {
                        type = "CCLabelTTF",
                        text = horseNameTable[tonumber(pData.stage_id)],
                        color = horseColorTable[tonumber(pData.stage_id)]
                    },
                    
                }
        else
            richInfo.elements = 
            {
                {
                    type = "CCLabelTTF",
                    text = pData.uname,
                    color = ccc3(0x00,0xe4,0xff)
                },
                {
                    type = "CCLabelTTF",
                    text = GetLocalizeStringBy("llp_447")
                },
                {
                    type = "CCLabelTTF",
                    text = horseNameTable[tonumber(pData.stage_id)],
                    color = horseColorTable[tonumber(pData.stage_id)]
                },
                {
                    type = "CCLabelTTF",
                    text = GetLocalizeStringBy("llp_448")
                },
            }
        end
    end
    return richInfo.elements
end

function getWatchInfoNode( pData )
    -- body
    local richInfo = {}
    richInfo.elements = 
            {
                {
                    type = "CCLabelTTF",
                    text = pData.uname,
                    color = ccc3(0x00,0xe4,0xff)
                },
                {
                    type = "CCLabelTTF",
                    text = GetLocalizeStringBy("llp_409")
                }
            }
    return richInfo.elements
end

function getReachInfoNode( pData )
    -- body
    local richInfo = {}
    local userId = UserModel.getUserUid()
    local isSucceed = tonumber(pData.success)
    if(userId==tonumber(pData.uid))then
        richInfo.elements = 
            {
                {
                    type = "CCLabelTTF",
                    text = GetLocalizeStringBy("llp_410"),
                },
            }
    else
        richInfo.elements = 
            {
                {
                    type = "CCLabelTTF",
                    text = GetLocalizeStringBy("llp_411"),
                },
                {
                    type = "CCLabelTTF",
                    text = pData.uname,
                    color = ccc3(0x00,0xe4,0xff)
                },
                {
                    type = "CCLabelTTF",
                    text = GetLocalizeStringBy("llp_412"),
                }
            }
    end
    return richInfo.elements
end

function createNormalInfoNode( pData )
    -- body
    local richInfo = {}
    richInfo.elements = 
            {
                {
                    type = "CCLabelTTF",
                    text = pData.uname,
                    color = ccc3(0x00,0xe4,0xff)
                },
                {
                    type = "CCLabelTTF",
                    text = GetLocalizeStringBy("llp_451"),
                },
                {
                    type = "CCLabelTTF",
                    text = pData.beUname,
                    color = ccc3(0x00,0xe4,0xff)
                },
                {
                    type = "CCLabelTTF",
                    text = horseNameTable[_curIndex+2],
                    color = horseColorTable[_curIndex+2]
                },
            }
    return richInfo.elements
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
    
    local colors = {ccc3(0xff, 0, 0xe1), ccc3(26, 175, 84), ccc3(252, 13, 27)}
    local number = 0
    
    local richInfo = {}
    richInfo.width = 500
    richInfo.alignment = 1
    richInfo.labelDefaultFont = g_sFontName
    richInfo.labelDefaultSize = 21

    local robType = tonumber(robInfo.type) 
    if(_curIndex == 3)then
        if(robType==1)then
            richInfo.elements = getBattleInfoNode(robInfo)
        elseif(robType==2)then
            richInfo.elements = getWatchInfoNode(robInfo)
        elseif(robType==3)then
            richInfo.elements = getReachInfoNode(robInfo)
        end
    else
        richInfo.elements = createNormalInfoNode(robInfo)
    end
    require "script/libs/LuaCCLabel"
    local richLabel = LuaCCLabel.createRichLabel(richInfo)
    text_bg:addChild(richLabel)
    richLabel:setAnchorPoint(ccp(0, 1))
    richLabel:setPosition(ccp(10, text_bg:getContentSize().height - 10))
    local timeString = TimeUtil.getTimeStringWords(tonumber(robInfo.time))
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