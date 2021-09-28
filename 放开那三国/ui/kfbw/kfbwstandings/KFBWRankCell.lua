-- FileName: KFBWRankCell.lua
-- Author: shengyixian
-- Date: 2015-10-12
-- Purpose: 跨服排行榜表单元
module("KFBWRankCell",package.seeall)

local _touchPriority = -555
local _cell = nil
local _tableView = nil
local _currData = nil
function init( ... )
	-- body
	_cell = nil
	_tableView = nil
end

function initView( ... )
    -- 背景
    local cellSprite = STPurgatoryRankLayer:createCell()
    cellSprite:setAnchorPoint(ccp(0, 0))
    cellSprite:setPosition(ccp(0, 0))
    _cell:addChild(cellSprite)
    local cellBg = cellSprite:getChildByName("cellBg")
    local rankSprite = cellBg:getChildByName("rankSprite")
    local rankLabel = cellBg:getChildByName("rankLabel")
    local bgFilenames = {"first_bg.png", "second_bg.png", "third_bg.png", "rank_bg.png"}
    local bgIndex = tonumber(_currData.rank)
    if bgIndex > 4 then
        bgIndex = 4
    end
    cellBg:setFilename("images/match/" .. bgFilenames[bgIndex])
    -- 名字
    local playerNameLabel = cellBg:getChildByName("playerNameLabel")
    playerNameLabel:setString(_currData.uname)
    if tonumber(_currData.rank) <= 3 then
        local filenames = {"one.png", "two.png", "three.png"}
        rankSprite:setFilename("images/match/" .. filenames[tonumber(_currData.rank)])
        rankLabel:removeFromParent()
        local nameColors = {ccc3(0xf9, 0x59, 0xff), ccc3(0x00, 0xe4, 0xff), ccc3(0xff, 0xfb, 0xd9)}
        playerNameLabel:setColor(nameColors[bgIndex])
    else
        rankLabel:setString(tostring(_currData.rank))
        rankSprite:removeFromParent()
    end
    -- 服务器名字
    local serverName = _currData.server_name or ""
    local serverNameLabel = cellBg:getChildByName("serverNameLabel")
    serverNameLabel:setString(serverName)
    serverNameLabel:setColor(playerNameLabel:getColor())
    -- 头像
    local headBg = cellBg:getChildByName("headBg")
    require "script/model/utils/HeroUtil"
    local dressId = nil
    local genderId = nil
    if not table.isEmpty(_currData.dress) and (_currData.dress["1"] ~= nil and tonumber(_currData.dress["1"]) > 0) then
        dressId = _currData.dress["1"]
        genderId = HeroModel.getSex(_currData.htid)
    end
    --vip 特效
    local vip = _currData.vip or 0
    local heroIcon = HeroUtil.getHeroIconByHTID(_currData.htid, dressId, dressId,vip)
    local heroIconNode = STNode:create()
    heroIconNode:addChild(heroIcon)
    heroIcon:setAnchorPoint(ccp(0.5, 0.5))
    heroIconNode:setContentSize(heroIcon:getContentSize())
    heroIcon:setPosition(ccpsprite(0.5, 0.5, heroIconNode))

    local heroBtn = STButton:createWithNode(heroIconNode)
    headBg:addChild(heroBtn, 1, _currData.rank)
    heroBtn:setAnchorPoint(ccp(0.5,0.5))
    heroBtn:setPosition(ccpsprite(0.5, 0.5, headBg))
    heroBtn:setTouchPriority(_touchPriority - 1)

    -- 等级
    local levelLabel = cellBg:getChildByName("levelLabel")
    levelLabel:setString(_currData.level)

    local fameDes = cellBg:getChildByName("Text_17_0_0")
    fameDes:setPosition(ccp(fameDes:getPositionX()-fameDes:getContentSize().width*0.5,fameDes:getPositionY()))
    fameDes:setString(GetLocalizeStringBy("lcyx_1961"))

    -- 积分数量
    local pointLabel = cellBg:getChildByName("pointLabel")
    pointLabel:setString(_currData.max_honor)
end

function create( data )
	-- body
	_cell = CCTableViewCell:create()
	_currData = data
	initView()
	return _cell
end