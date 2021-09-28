-- Filename：    GuildRankCell.lua
-- Author：      DJN
-- Date：        2014-7-8
-- Purpose：     军团排行榜cell

require "script/ui/guild/rank/GuildRankLayer"
require "script/ui/guild/rank/GuildRankService"
require "script/ui/guild/rank/GuildRankData"
module("GuildRankCell", package.seeall)

-- 军团长名字颜色、cell背景、名次背景
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
    end

    return name_color, cellBg , rank_font
end

--[[
    @des    :创建cell
    @param  :军团信息
    @return :
--]]
function createCell( tCellValue)
    -- print("cell数据tCellValue:")
    -- print_t(tCellValue)
    -- 创建cell
    local cell = CCTableViewCell:create()
    -- 获取军团长名字颜色、cell背景、名次背景
    local name_color,cell_bg,rank_font= getHeroNameColor( tCellValue )
    -- 获取当前玩家所在军团排行和战力
    local user_guild_rank , user_guild_fight_force= GuildRankData.getUserGuildRankInfo()
    -- cell背景
    cell_bg:setAnchorPoint(ccp(0,0))
    cell_bg:setPosition(ccp(0,0))
    cell:addChild(cell_bg)

    -- 军团名字icon
    local guild_name_sprite = CCSprite:create("images/guild/rank/guild_font.png")
    guild_name_sprite:setAnchorPoint(ccp(1,0.5))
    guild_name_sprite:setPosition(ccp(225,cell_bg:getContentSize().height-52))
    cell_bg:addChild(guild_name_sprite)

    -- 军团名字 
    local str_guild_name= tCellValue.guild_name or " "
    local guild_name = CCRenderLabel:create( str_guild_name, g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    guild_name:setColor(name_color)
    guild_name:setAnchorPoint(ccp(0,0.5))
    guild_name:setPosition(ccp(guild_name_sprite:getPositionX()+18,guild_name_sprite:getPositionY()))
    cell_bg:addChild(guild_name)

    -- 军团长名字icon
    local leader_name_sprite = CCSprite:create("images/guild/rank/guild_leader.png")
    leader_name_sprite:setAnchorPoint(ccp(1,0.5))
    leader_name_sprite:setPosition(ccp(225,cell_bg:getContentSize().height-90))
    cell_bg:addChild(leader_name_sprite)

    -- 军团长名字 
    local str_leader_name= tCellValue.leader_name or " "
    local leader_name = CCRenderLabel:create( str_leader_name, g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    leader_name:setColor(name_color)
    leader_name:setAnchorPoint(ccp(0,0.5))
    leader_name:setPosition(ccp(leader_name_sprite:getPositionX()+18,leader_name_sprite:getPositionY()))
    cell_bg:addChild(leader_name)

   
    -- 名次不在前三的情况
    if( rank_font==nil )then
    -- 军团排名
    local rank_data = " "
    if(tCellValue.rank)then
        rank_data = tonumber( tCellValue.rank )
    end
    
    rank_font = CCRenderLabel:create( rank_data, g_sFontPangWa, 50, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    rank_font:setColor(ccc3(0xff, 0xf6, 0x00))
    end
    rank_font:setAnchorPoint(ccp(0.5,0.5))
    rank_font:setPosition(ccp(53,cell_bg:getContentSize().height*0.5))
    cell_bg:addChild(rank_font)

    --“名”汉字
    local ming = CCSprite:create("images/match/ming.png")
    ming:setAnchorPoint(ccp(0,0))
    ming:setPosition(ccp(90,20))
    cell_bg:addChild(ming)

    -- 军团等级
    local lv_sprite = CCSprite:create("images/common/lv.png")
    lv_sprite:setAnchorPoint(ccp(0,0.5))
    lv_sprite:setPosition(ccp(157,cell_bg:getContentSize().height-15))
    cell_bg:addChild(lv_sprite)

    --军团等级数据
    local str_lv= tCellValue.guild_level or " "
    local lv_data = CCRenderLabel:create(str_lv, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lv_data:setAnchorPoint(ccp(0,0.5))
    lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
    lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+5,cell_bg:getContentSize().height-15))
    cell_bg:addChild(lv_data)
    
    -- aded by zhz
    -- 军团战斗力
    local fightForce= CCSprite:create("images/guild/rank/total_fight_force.png")
    fightForce:setAnchorPoint(ccp(0.5,0))
    fightForce:setPosition(ccp(508,cell_bg:getContentSize().height-49))
    fightForce:setScale(0.9)
    cell_bg:addChild(fightForce)

    local fightForcedata = CCRenderLabel:create( tCellValue.fight_force or "0" , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fightForcedata:setAnchorPoint(ccp(0.5,1))
    fightForcedata:setColor(ccc3(0x00, 0xff, 0x18))
    fightForcedata:setPosition(ccp(fightForce:getPositionX()-4,fightForce:getPositionY()-15))
    cell_bg:addChild(fightForcedata) 

     -- 按钮
    local menu = BTSensitiveMenu:create()
    if(menu:retainCount()>1)then
        menu:release()
        menu:autorelease()
    end
    menu:setPosition(ccp(0,0))
    cell_bg:addChild(menu)

    return cell
end
