-- FileName: CountryWarRankList.lua 
-- Author: licong 
-- Date: 15/12/1 
-- Purpose: 国战排行榜 


module("CountryWarRankList", package.seeall)
require "script/ui/countryWar/war/CountryWarPlaceData"
require "script/ui/purgatorychallenge/STPurgatoryRankLayer"

local _bgLayer = nil
local _layerSize = nil
local _touchPriority = nil
local _zOrder = nil
local _myKillLabel = nil
local _myRankLabel = nil
local _showButton = nil
local _hiddenButton = nil
local _rankInfo = nil
local _rankTable = nil
local _backGround = nil
local _listBg = nil
local _tableView = nil
local _fameLabel = nil
local _rankLabel = nil

function init( ... )
	_bgLayer = nil
	_layerSize = nil
	_touchPriority = nil
	_zOrder = nil
	_myKillLabel = nil
	_myRankLabel = nil
	_showButton = nil
	_hiddenButton = nil
	_rankInfo = nil
	_rankTable = nil
	_backGround = nil
	_listBg = nil
	_tableView = nil
    _fameLabel = nil
    _rankLabel = nil
end

-------------------------------[[ ui 创建方法 ]]---------------------------
function show( p_touchPriority,  p_zOrder, p_parentLayer)
	init()
	_bgLayer = p_parentLayer
	_touchPriority 	= p_touchPriority or -400
	_zOrder			= p_zOrder or 1

	createUI()			
end

--[[
	@des : 创建服务器列表
--]]
function createUI( ... )
	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0, 0))
	menu:setPosition(ccp(0, 0))
	_bgLayer:addChild(menu, _zOrder + 10)
	menu:setTouchPriority(-_touchPriority-10)

	_showButton = CCMenuItemImage:create("images/country_war/pai_n.png", "images/country_war/pai_h.png")
	_showButton:setAnchorPoint(ccp(1, 0.5))
	_showButton:setPosition(ccps(1, 0.5))
	_showButton:registerScriptTapHandler(showServerButtonCallback)
	menu:addChild(_showButton)
	_showButton:setScale(MainScene.elementScale)

	_hiddenButton = CCMenuItemImage:create("images/star/btn_hidden_n.png", "images/star/btn_hidden_h.png")
	_hiddenButton:setAnchorPoint(ccp(1, 0.5))
	_hiddenButton:setPosition(ccps(1, 0.5))
	_hiddenButton:registerScriptTapHandler(hiddenServerButtonCallback)
	menu:addChild(_hiddenButton)
	_hiddenButton:setScale(MainScene.elementScale)
	_hiddenButton:setVisible(false)

	_backGround = CCScale9Sprite:create("images/common/viewbg1.png")
	_backGround:setContentSize(CCSizeMake(630, 780))
	_backGround:setAnchorPoint(ccp(0, 0.5))
	_backGround:setPosition(ccpsprite(0.87, 0.5, _hiddenButton))
	_hiddenButton:addChild(_backGround, 10)
	_backGround:setScale(0.8)

	-- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(_backGround:getContentSize().width/2, _backGround:getContentSize().height-6.6 ))
	_backGround:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1746"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	_listBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_listBg:setContentSize(CCSizeMake(575, 580))
	_listBg:setAnchorPoint(ccp(0.5, 0))
	_listBg:setPosition(ccp( _backGround:getContentSize().width * 0.5, 45))
	_backGround:addChild(_listBg)
end


--[[
    @des:排名列表
--]]
function createTableView( ... )
    -- 当前阶段
    local curStage = CountryWarMainData.getCurStage()

    if not tolua.isnull(_tableView) then 
        -- 我的排名
        local myRankInfo = CountryWarPlaceData.getMyRankInfo(_rankListData)
        local mineRank = myRankInfo and myRankInfo.rank or 0
        local rank = mineRank <=0 and GetLocalizeStringBy("lcyx_1969") or mineRank
        _rankLabel:setString(rank)
        -- 我的国战积分
        local fameNum = 0
        if( curStage < CountryWarDef.SUPPORT )then
            fameNum = myRankInfo and tonumber(myRankInfo.audition_point) or 0
        else
            fameNum = myRankInfo and tonumber(myRankInfo.final_point) or 0
        end
        local fame = fameNum
        _fameLabel:setString(fame)

        -- 刷新列表
        _tableView:reloadData()
        return
    end

    if( curStage < CountryWarDef.SUPPORT )then
        local jionRank = CountryWarPlaceData.getCanJoinFinalsRank()
        local rankDesLabel = CCRenderLabel:create(GetLocalizeStringBy("lic_1756",tostring(jionRank)), g_sFontPangWa, 25, 1, ccc3(0,0,0))
        rankDesLabel:setAnchorPoint(ccp(0.5, 0.5))
        rankDesLabel:setPosition(ccpsprite(0.5 , 0.93, _backGround))
        rankDesLabel:setColor(ccc3(0xf9, 0x59, 0xff))
        _backGround:addChild(rankDesLabel)
    end

	-- 我的排行
	local rankDes = GetLocalizeStringBy("lic_1748")
    local rankDesLabel = CCLabelTTF:create(rankDes, g_sFontPangWa, 25)
    rankDesLabel:setAnchorPoint(ccp(0, 0.5))
    rankDesLabel:setPosition(ccpsprite(0.08 , 0.89, _backGround))
    rankDesLabel:setColor(ccc3(0x78, 0x25, 0x00))
    _backGround:addChild(rankDesLabel)

    local myRankInfo = CountryWarPlaceData.getMyRankInfo(_rankListData)
    local mineRank = myRankInfo and myRankInfo.rank or 0
    local rank = mineRank <=0 and GetLocalizeStringBy("lcyx_1969") or mineRank
    _rankLabel = CCRenderLabel:create(rank, g_sFontPangWa, 25, 1, ccc3(0,0,0))
    _rankLabel:setAnchorPoint(ccp(0, 0.5))
    _rankLabel:setPosition(ccpsprite(1.1 , 0.5, rankDesLabel))
    _rankLabel:setColor(ccc3(113, 246, 47))
    rankDesLabel:addChild(_rankLabel)

    local fameDesLabel = CCLabelTTF:create( GetLocalizeStringBy("lic_1749"), g_sFontPangWa, 25)
    fameDesLabel:setAnchorPoint(ccp(0, 0.5))
    fameDesLabel:setPosition(ccpsprite(0.08 , 0.85, _backGround))
    fameDesLabel:setColor(ccc3(0x78, 0x25, 0x00))
    _backGround:addChild(fameDesLabel)

    local fameNum = 0
    if( curStage < CountryWarDef.SUPPORT )then
        fameNum = myRankInfo and tonumber(myRankInfo.audition_point) or 0
    else
        fameNum = myRankInfo and tonumber(myRankInfo.final_point) or 0
    end
    local fame = fameNum
    _fameLabel = CCRenderLabel:create(fame, g_sFontPangWa, 25, 1, ccc3(0,0,0))
    _fameLabel:setAnchorPoint(ccp(0, 0.5))
    _fameLabel:setPosition(ccpsprite(1.1 , 0.5, fameDesLabel))
    _fameLabel:setColor(ccc3(113, 246, 47))
    fameDesLabel:addChild(_fameLabel)

    local createTableCallback = function(fn, t_table, a1, a2)
        require "script/ui/rewardCenter/RewardTableCell"
        local r
        if fn == "cellSize" then
            r = CCSizeMake(500, 115)
        elseif fn == "cellAtIndex" then
            a2 = createCell(_rankListData[a1 + 1], a1 + 1)
            r = a2
        elseif fn == "numberOfCells" then
            r = #_rankListData
        elseif fn == "cellTouched" then
        end
        return r
    end
    _tableView = LuaTableView:createWithHandler(LuaEventHandler:create(createTableCallback), CCSizeMake(570,570))
    _tableView:setBounceable(true)
    _tableView:ignoreAnchorPointForPosition(false)
    _tableView:setAnchorPoint(ccp(0.5, 0.5))
    _tableView:setPosition(ccp(_listBg:getContentSize().width*0.5, _listBg:getContentSize().height*0.5))
    _tableView:setTouchPriority(_touchPriority-20)
    _listBg:addChild(_tableView)
    _tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
end

--[[
    @des:名字颜色、cell背景、名次背景
--]]
function getHeroNameColor( tCellValue )
    local cellBg = nil
    local name_color = nil
    local rank_font = nil
    if( tonumber(tCellValue.rank) == 1 )then
        cellBg = CCSprite:create("images/match/first_bg.png")
        name_color= ccc3(0xf9,0x59,0xff)
        rank_font = CCSprite:create("images/match/one.png")
    elseif( tonumber(tCellValue.rank) == 2 )then
        cellBg = CCSprite:create("images/match/second_bg.png")
        name_color= ccc3(0x00,0xe4,0xff)
        rank_font = CCSprite:create("images/match/two.png")
    elseif( tonumber(tCellValue.rank) == 3 )then
        cellBg = CCSprite:create("images/match/third_bg.png")
        name_color= ccc3(0xff,0xff,0xff)
        rank_font = CCSprite:create("images/match/three.png")
    else
        cellBg = CCSprite:create("images/match/rank_bg.png")
        name_color= ccc3(0xff,0xff,0xff)
        rank_font = CCRenderLabel:create( tCellValue.rank, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        rank_font:setColor(ccc3(0xff, 0xf6, 0x00))
    end

    return name_color, cellBg , rank_font
end

--[[
    @des:创建cell
--]]
function createCell(p_info, p_index )
    local rankInfo = p_info
    print("rankInfo")
    print_t(rankInfo)
     local cell = CCTableViewCell:create()

    -- 获取军团长名字颜色、cell背景、名次背景
    local name_color,cell_bg,rank_font= getHeroNameColor( rankInfo )
    cell_bg:setAnchorPoint(ccp(0,0))
    cell_bg:setPosition(ccp(0,0))
    cell:addChild(cell_bg)

    -- 排名
    rank_font:setAnchorPoint(ccp(0.5,0.5))
    rank_font:setPosition(ccp(53,cell_bg:getContentSize().height*0.5))
    cell_bg:addChild(rank_font)

    --“名”汉字
    local ming = CCSprite:create("images/match/ming.png")
    ming:setAnchorPoint(ccp(0,0))
    ming:setPosition(ccp(90,20))
    cell_bg:addChild(ming)
   
    --头像
    local icon_bg = CCSprite:create("images/match/head_bg.png")
    icon_bg:setAnchorPoint(ccp(0,0.5))
    icon_bg:setPosition(ccp(138,cell_bg:getContentSize().height*0.5))
    cell_bg:addChild(icon_bg)

    require "script/model/utils/HeroUtil"
    local dressId = nil
    local genderId = nil
    if not table.isEmpty(rankInfo.dress) and (rankInfo.dress["1"] ~= nil and tonumber(rankInfo.dress["1"]) > 0) then
        dressId = rankInfo.dress["1"]
        genderId = HeroModel.getSex(rankInfo.htid)
    end
    --vip 特效
    local vip = rankInfo.vip or 0
    local heroIcon = HeroUtil.getHeroIconByHTID(rankInfo.htid, dressId, genderId,vip)
    heroIcon:setAnchorPoint(ccp(0.5,0.5))
    heroIcon:setPosition(ccp(icon_bg:getContentSize().width*0.5,icon_bg:getContentSize().height*0.5))
    icon_bg:addChild(heroIcon)    

    -- lv.
    local lv_sprite = CCSprite:create("images/common/lv.png")
    lv_sprite:setAnchorPoint(ccp(0,1))
    lv_sprite:setPosition(ccp(300,cell_bg:getContentSize().height-10))
    cell_bg:addChild(lv_sprite)
    -- 等级
    local lv_data = CCRenderLabel:create( rankInfo.level , g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lv_data:setAnchorPoint(ccp(0,1))
    lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
    lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+5,cell_bg:getContentSize().height-4))
    cell_bg:addChild(lv_data)
    -- 名字
    local name = CCRenderLabel:create( rankInfo.uname , g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    name:setColor(name_color)
    name:setAnchorPoint(ccp(0.5,0.5))
    name:setPosition(ccp(341,cell_bg:getContentSize().height*0.5))
    cell_bg:addChild(name)

    -- 服务器名字
    local serviceName = CCRenderLabel:create( rankInfo.server_name , g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    serviceName:setColor(name_color)
    serviceName:setAnchorPoint(ccp(0.5,0))
    serviceName:setPosition(ccp(341,15))
    cell_bg:addChild(serviceName)

    -- 积分
    local myScore_font = CCRenderLabel:create( GetLocalizeStringBy("lic_1747"), g_sFontPangWa, 20, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myScore_font:setAnchorPoint(ccp(0.5,1))
    myScore_font:setColor(ccc3(0xff,0xff,0xff))
    myScore_font:setPosition(ccp(500,cell_bg:getContentSize().height-15))
    cell_bg:addChild(myScore_font)

    local fameNum = nil
    local curStage = CountryWarMainData.getCurStage()
    if( curStage < CountryWarDef.SUPPORT )then
        fameNum = rankInfo.audition_point
    else
        fameNum = rankInfo.final_point
    end
    local fame = fameNum or 0
    local myScore_Data = CCRenderLabel:create( fame, g_sFontPangWa, 20, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myScore_Data:setAnchorPoint(ccp(0.5,0))
    myScore_Data:setColor(ccc3(0x70,0xff,0x18))
    myScore_Data:setPosition(ccp(500,15))
    cell_bg:addChild(myScore_Data)

    return cell
end

--[[
	@des: 显示按钮回调事件
--]]
function showServerButtonCallback( ... )
	
	local getRankListCallFun = function ( p_retInfo )
        _rankListData = CountryWarPlaceData.getRankInfo(p_retInfo)
		createTableView()
		_showButton:setVisible(false)
		_hiddenButton:setVisible(true)
	    local position = ccps(1, 0.5)
	    position.x = position.x - _backGround:getContentSize().width*_backGround:getScale()* MainScene.elementScale
		local action = CCMoveTo:create(0.5, position)
	    _hiddenButton:stopAllActions()
		_hiddenButton:runAction(action)		
	end
	-- 拉排行
	CountryWarPlaceService.getRankList(getRankListCallFun)
end

--[[
	@des: 隐藏按钮回调事件
--]]
function hiddenServerButtonCallback( ... )
	local position = ccps(1, 0.5)
    position.x = position.x + _backGround:getContentSize().width*_backGround:getScale()* MainScene.elementScale
	local actionArray = CCArray:create()
	actionArray:addObject(CCMoveTo:create(0.5, position))
	actionArray:addObject(CCCallFunc:create(function ( ... )
		_showButton:setVisible(true)
		_hiddenButton:setVisible(false)
	end))
	local seqAction = CCSequence:create(actionArray)
    _hiddenButton:stopAllActions()
	_hiddenButton:runAction(seqAction)
end





