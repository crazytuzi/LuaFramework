-- FileName: WorldArenaRankCell.lua 
-- Author: licong 
-- Date: 15/7/3 
-- Purpose: 排行榜 cell


module("WorldArenaRankCell", package.seeall)

require "script/model/utils/HeroUtil"

--[[
	@des 	: 创建tableview cell
	@param 	: 
	@return : 
--]]
function createCell( p_data, p_type )
	-- print("p_type==>",p_type)
	-- print_t(p_data)
	
 	local cell = CCTableViewCell:create()
    -- 背景
    local cellBg = nil
    if( tonumber(p_data.rank) == 1 )then
        cellBg = CCSprite:create("images/match/first_bg.png")
    elseif( tonumber(p_data.rank) == 2 )then
        cellBg = CCSprite:create("images/match/second_bg.png")
    elseif( tonumber(p_data.rank) == 3 )then
        cellBg = CCSprite:create("images/match/third_bg.png")
    else
        cellBg = CCSprite:create("images/match/rank_bg.png")
    end
    cellBg:setAnchorPoint(ccp(0,0))
    cellBg:setPosition(ccp(0,0))
    cell:addChild(cellBg,1)

    -- 名次图标
    local rank_font = nil
    if( tonumber(p_data.rank) == 1 )then
        rank_font = CCSprite:create("images/match/one.png")
    elseif( tonumber(p_data.rank) == 2 )then
        rank_font = CCSprite:create("images/match/two.png")
    elseif( tonumber(p_data.rank) == 3 )then
        rank_font = CCSprite:create("images/match/three.png")
    else
        rank_font = CCRenderLabel:create( p_data.rank , g_sFontPangWa, 50, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        rank_font:setColor(ccc3(0xff, 0xf6, 0x00))
    end
    rank_font:setAnchorPoint(ccp(0.5,0.5))
    rank_font:setPosition(ccp(53,cellBg:getContentSize().height*0.5))
    cellBg:addChild(rank_font)
    -- 名
    local ming = CCSprite:create("images/match/ming.png")
    ming:setAnchorPoint(ccp(0,0))
    ming:setPosition(ccp(90,20))
    cellBg:addChild(ming)
    -- 头像
    local icon_bg = CCSprite:create("images/match/head_bg.png")
    icon_bg:setAnchorPoint(ccp(0,0.5))
    icon_bg:setPosition(ccp(138,cellBg:getContentSize().height*0.5))
    cellBg:addChild(icon_bg)

    local dressId = nil
    local genderId = nil
    if( not table.isEmpty(p_data.dress) and (p_data.dress["1"])~= nil and tonumber(p_data.dress["1"]) > 0 )then
        dressId = p_data.dress["1"]
        genderId = HeroModel.getSex(p_data.htid)
    end
    -- added by zhz , VIP等级产生的特效
    local vip= p_data.vip or 0
    local heroIcon = HeroUtil.getHeroIconByHTID(p_data.htid, dressId, genderId, vip)
    heroIcon:setAnchorPoint(ccp(0.5,0.5))
    heroIcon:setPosition(ccp(icon_bg:getContentSize().width*0.5,icon_bg:getContentSize().height*0.5))
    icon_bg:addChild(heroIcon)
  
    -- lv.
    local lv_sprite = CCSprite:create("images/common/lv.png")
    lv_sprite:setAnchorPoint(ccp(0,1))
    cellBg:addChild(lv_sprite)
    -- 等级
    local lv_data = CCRenderLabel:create( p_data.level , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lv_data:setAnchorPoint(ccp(0,1))
    lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
    cellBg:addChild(lv_data)
    -- 居中
    local posX = (cellBg:getContentSize().width-lv_sprite:getContentSize().width-lv_data:getContentSize().width)*0.6
    lv_sprite:setPosition(ccp(posX,cellBg:getContentSize().height*0.9))
    lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+2,cellBg:getContentSize().height*0.9))
    -- 名字
    local name = CCRenderLabel:create( p_data.uname , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
     if( tonumber(p_data.rank) == 1 )then
        name:setColor(ccc3(0xf9, 0x59, 0xff))
    elseif( tonumber(p_data.rank) == 2 )then
        name:setColor(ccc3(0x00, 0xe4, 0xff))
    elseif( tonumber(p_data.rank) == 3 )then
        name:setColor(ccc3(0x70, 0xff, 0x18))
    else
        name:setColor(ccc3(0xff, 0xff, 0xff))
    end
    name:setAnchorPoint(ccp(0.5,0.5))
    name:setPosition(ccp(cellBg:getContentSize().width*0.6,cellBg:getContentSize().height*0.5))
    cellBg:addChild(name)

    -- 战斗力
    local fightSp = CCSprite:create("images/lord_war/fight_bg.png")
    fightSp:setAnchorPoint(ccp(0.5,0))
    fightSp:setPosition(ccp(cellBg:getContentSize().width*0.6,7))
    cellBg:addChild(fightSp)
    -- 战斗力数值
    local fightLabel = CCRenderLabel:create( tonumber(p_data.fight_force), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fightLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    fightLabel:setAnchorPoint(ccp(0,0.5))
    fightLabel:setPosition(ccp(38,fightSp:getContentSize().height*0.5))
    fightSp:addChild(fightLabel)


    -- p_type:1击杀 2连杀 3排行
    local str = nil
    if( p_type == 1)then
        str = GetLocalizeStringBy("lic_1607")
    elseif( p_type == 2)then
        str = GetLocalizeStringBy("lic_1608")
    else
        str = GetLocalizeStringBy("lic_1609")
    end
    local myScore_font = CCRenderLabel:create( str, g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myScore_font:setAnchorPoint(ccp(0.5,1))
    myScore_font:setColor(ccc3(0xff,0xff,0xff))
    myScore_font:setPosition(ccp(490,cellBg:getContentSize().height-10))
    cellBg:addChild(myScore_font)

    local num = nil
    if( p_type == 1)then
        num = p_data.kill_num
    elseif( p_type == 2)then
        num = p_data.max_conti_num
    else
        num = p_data.rank
    end
    local myScore_Data = CCRenderLabel:create( num, g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myScore_Data:setAnchorPoint(ccp(0.5,0))
    myScore_Data:setColor(ccc3(0x70,0xff,0x18))
    myScore_Data:setPosition(ccp(490,33))
    cellBg:addChild(myScore_Data)

    -- 服务器名字
    local serNameLabel = CCRenderLabel:create(p_data.server_name,g_sFontName, 18, 1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    serNameLabel:setColor(ccc3(0xff, 0xff, 0xff))
    serNameLabel:setAnchorPoint(ccp(0.5,0))
    serNameLabel:setPosition(ccp(490,7))
    cellBg:addChild(serNameLabel)

    return cell
end














