-- Filename：	PurgatoryRankLayer.lua
-- Author：		bzx
-- Date：		2015-06-02
-- Purpose：		炼狱排行榜

module("PurgatoryRankLayer", package.seeall)

btimport "script/ui/purgatorychallenge/STPurgatoryRankLayer"
btimport "script/ui/purgatorychallenge/PurgatoryServes"
btimport "script/ui/purgatorychallenge/PurgatoryData"
btimport "db/DB_Lianyutiaozhan_reward"

local _layer
local _touchPriority
local _zOrder
local _cellSize
local _tableView
local _rankType
local RankType = {
	MULTIPLE = 1,
	INNER = 2,
}

function show(p_touchPriority, p_zOrder)
	-- btimport "script/ui/purgatorychallenge/PurgatoryRewardPreviewLayer"
	-- PurgatoryRewardPreviewLayer.show(p_touchPriority, p_zOrder)
	local requestCallback = function ( ... )
		local _layer = create(p_touchPriority, p_zOrder)
		CCDirector:sharedDirector():getRunningScene():addChild(_layer, _zOrder)
	end
	PurgatoryServes.getRankList(requestCallback)
end

function create( p_touchPriority, p_zOrder )
	init(p_touchPriority, p_zOrder)
	_layer = STPurgatoryRankLayer:create()
	_layer:setSwallowTouch(true)
	_layer:setTouchPriority(_touchPriority)
	_layer:setTouchEnabled(true)
	loadTableView()
	loadBtn()
	loadMyRank()
	adaptive()
	return _layer
end

function init( p_touchPriority, p_zOrder )
	_touchPriority = p_touchPriority or -800
	_zOrder = p_zOrder or 1000
	_rankType = RankType.MULTIPLE
end

function loadBtn( ... )
	local closeBtn = _layer:getMemberNodeByName("closeBtn")
	closeBtn:setClickCallback(closeCallback)
	closeBtn:setTouchPriority(_touchPriority - 1)

	local multipleBtn = _layer:getMemberNodeByName("multipleBtn")
	multipleBtn:setClickCallback(selectedCallback)
	multipleBtn:setTouchPriority(_touchPriority - 2)
	multipleBtn:getSelectedNode():setHeight(53)
	multipleBtn:getNormalLabel():setColor(ccc3(0xf4, 0xdf, 0xcb))
	multipleBtn:getNormalLabel():toNormal()

	local innerBtn = _layer:getMemberNodeByName("innerBtn")
	innerBtn:setClickCallback(selectedCallback)
	innerBtn:setTouchPriority(_touchPriority - 2)
	innerBtn:getSelectedNode():setHeight(53)
	innerBtn:getNormalLabel():setColor(ccc3(0xf4, 0xdf, 0xcb))
	innerBtn:getNormalLabel():toNormal()

	multipleBtn:addRadioPartner(innerBtn)
	multipleBtn:pushEvent(STButtonEvent.CLICKED)
end

function closeCallback( ... )
	_layer:removeFromParent()
end

function selectedCallback( p_tag, p_button )
	_rankType = p_tag
	_tableView:reloadData()	
end

function loadMyRank( ... )
	local rankData = PurgatoryData.getRankInfo()
	local myMultipleLabel = _layer:getMemberNodeByName("myMultipleLabel")
	local myInnerRankLabel = _layer:getMemberNodeByName("myInnerRankLabel")
	if tonumber(rankData.my_cross_rank) > 5000 then
		myMultipleLabel:setString(GetLocalizeStringBy("key_10267"))
	elseif tonumber(rankData.my_cross_rank) <= 0 then
		myMultipleLabel:setString(GetLocalizeStringBy("key_10096"))
	else
		myMultipleLabel:setString(rankData.my_cross_rank)
	end
	if tonumber(rankData.my_inner_rank) > 5000 then
		myInnerRankLabel:setString(GetLocalizeStringBy("key_10267"))
	elseif tonumber(rankData.my_inner_rank) <= 0 then
		myInnerRankLabel:setString(GetLocalizeStringBy("key_10096"))
	else
		myInnerRankLabel:setString(rankData.my_inner_rank)
	end
end

function getRankCount( ... )
	local rankData = PurgatoryData.getRankInfo()
	if _rankType == RankType.MULTIPLE then
		return #rankData.cross
	elseif _rankType == RankType.INNER then
		return #rankData.inner
	end
end

function loadTableView( ... )
	_tableView = _layer:getMemberNodeByName("tableView")
	local cell = _layer:getMemberNodeByName("cell")
	_cellSize = cell:getContentSize()
	cell:removeFromParent()

	local eventHandler = function ( functionName, tableView, index, cell )
		if functionName == "cellSize" then
			return _cellSize
		elseif functionName == "cellAtIndex" then
			return createCell(index)
		elseif functionName == "numberOfCells" then
			return getRankCount()
		end
	end
	_tableView:setEventHandler(eventHandler)
	_tableView:setTouchPriority(_touchPriority - 10)
end

function createCell( p_index )
	local rankInfo = nil
	if _rankType == RankType.MULTIPLE then
		rankInfo = PurgatoryData.getRankInfo().cross[p_index]
	else
		rankInfo = PurgatoryData.getRankInfo().inner[p_index]
	end
	local cell = STPurgatoryRankLayer:createCell()
	cell:setAnchorPoint(ccp(0, 0))
	cell:setPosition(ccp(0, 0))
	local cellBg = cell:getChildByName("cellBg")
	local rankSprite = cellBg:getChildByName("rankSprite")
	local rankLabel = cellBg:getChildByName("rankLabel")
	local bgFilenames = {"first_bg.png", "second_bg.png", "third_bg.png", "rank_bg.png"}
	local bgIndex = p_index
	if bgIndex > 4 then
		bgIndex = 4
	end
	cellBg:setFilename("images/match/" .. bgFilenames[bgIndex])
	-- 名字
	local playerNameLabel = cellBg:getChildByName("playerNameLabel")
	playerNameLabel:setString(rankInfo.uname)
	if p_index <= 3 then
		local filenames = {"one.png", "two.png", "three.png"}
		rankSprite:setFilename("images/match/" .. filenames[p_index])
		rankLabel:removeFromParent()
		local nameColors = {ccc3(0xf9, 0x59, 0xff), ccc3(0x00, 0xe4, 0xff), ccc3(0xff, 0xfb, 0xd9)}
		playerNameLabel:setColor(nameColors[p_index])
	else
		rankLabel:setString(tostring(p_index))
		rankSprite:removeFromParent()
	end
	-- 服务器名字
	local serverNameLabel = cellBg:getChildByName("serverNameLabel")
	if _rankType == RankType.MULTIPLE then
		serverNameLabel:setString(rankInfo.server_name)
		serverNameLabel:setColor(playerNameLabel:getColor())
	else
		serverNameLabel:removeFromParent()
	end
	-- 头像
	local headBg = cellBg:getChildByName("headBg")
    require "script/model/utils/HeroUtil"
    local dressId = nil
    local genderId = nil
    if not table.isEmpty(rankInfo.dress) and (rankInfo.dress["1"] ~= nil and tonumber(rankInfo.dress["1"]) > 0) then
        dressId = rankInfo.dress["1"]
        genderId = HeroModel.getSex(rankInfo.htid)
    end
    --vip 特效
    local vip = rankInfo.vip or 0
    local heroIcon = HeroUtil.getHeroIconByHTID(rankInfo.htid, dressId, dressId,vip)
    local heroIconNode = STNode:create()
    heroIconNode:addChild(heroIcon)
    heroIcon:setAnchorPoint(ccp(0.5, 0.5))
    heroIconNode:setContentSize(heroIcon:getContentSize())
    heroIcon:setPosition(ccpsprite(0.5, 0.5, heroIconNode))

    local heroBtn = STButton:createWithNode(heroIconNode)
    headBg:addChild(heroBtn, 1, p_index)
    heroBtn:setAnchorPoint(ccp(0.5,0.5))
    heroBtn:setPosition(ccpsprite(0.5, 0.5, headBg))
    if _rankType == RankType.INNER then
    	heroBtn:setClickCallback(userFormationItemFun)
	end
    heroBtn:setTouchPriority(_touchPriority - 1)

	-- 等级
	local levelLabel = cellBg:getChildByName("levelLabel")
	levelLabel:setString(rankInfo.level)
	-- 积分数量
	local pointLabel = cellBg:getChildByName("pointLabel")
	pointLabel:setString(rankInfo.max_point)
	return cell
end

function createRewardCell( p_rewardItems, p_index )
	local cell = STTableViewCell:create()
    cell:setContentSize(CCSizeMake(125, 125))

	local icon, itemName, itemColor = ItemUtil.createGoodsIcon(p_rewardItems[p_index], _touchPriority - 1, 9999, _touchPriority - 50, nil,nil,nil,false)
    icon:setAnchorPoint(ccp(0.5, 0.5))
    cell:addChild(icon)
    icon:setPosition(ccpsprite(0.5, 0.58, cell))

 	local itemNameLabel = CCRenderLabel:create(itemName, g_sFontName, 18, 1, ccc3( 0x10, 0x10, 0x10), type_stroke)
    itemNameLabel:setColor(itemColor)
    itemNameLabel:setAnchorPoint(ccp(0.5,0.5))
    itemNameLabel:setPosition(icon:getContentSize().width*0.5,-icon:getContentSize().height*0.15)
    icon:addChild(itemNameLabel)

    return cell
end

--[[
    @des    :点击user头像回调
    @param  :
    @return :
--]]
function userFormationItemFun(tag)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui/chat/ChatUserInfoLayer"
    require "db/DB_Heroes"
    local allInfo  = nil
    if _rankType == RankType.MULTIPLE then
    	allInfo = PurgatoryData.getRankInfo().cross[tag]
    else
    	allInfo = PurgatoryData.getRankInfo().inner[tag]
    end
    local uname = allInfo.uname
    local ulevel = allInfo.level
    local power = allInfo.fight_force
    local uid = allInfo.uid
    local uGender = HeroModel.getSex(allInfo.htid)
    local htid = allInfo.htid
    local dressInfo = allInfo.dress
    local hero = DB_Heroes.getDataById(htid)
    local imageFile = hero.head_icon_id
    ChatUserInfoLayer.showChatUserInfoLayer(uname,ulevel,power,"images/base/hero/head_icon/" .. imageFile,uid,uGender,htid,dressInfo,_touchPriority - 10)
end

function adaptive( ... )
	_layer:setContentSize(g_winSize)
	local bgLayer = _layer:getMemberNodeByName("bgLayer")
	bgLayer:setContentSize(g_winSize)
	local bgSprite = _layer:getMemberNodeByName("bgSprite")
	bgSprite:setScale(MainScene.elementScale)
end