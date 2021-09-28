-- Filename：    GodWeaponRankCell.lua
-- Author：      DJN
-- Date：        2014-12-15
-- Purpose：     神兵副本排行榜cell

require "script/ui/guild/rank/GuildRankLayer"
-- require "script/ui/guild/rank/GuildRankService"
-- require "script/ui/guild/rank/GuildRankData"
require "script/ui/godweapon/godweaponcopy/GodWeaponCopyData"

module("GodWeaponRankCell", package.seeall)

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
function createCell( tCellValue,lineNum)
  
    local cell = CCTableViewCell:create()
    -- 获取军团长名字颜色、cell背景、名次背景
    local name_color,cell_bg,rank_font= getHeroNameColor( tCellValue )
    -- 获取当前玩家所在军团排行和战力
    local user_guild_rank , user_guild_fight_force= GuildRankData.getUserGuildRankInfo()
    -- cell背景
    cell_bg:setAnchorPoint(ccp(0,0))
    cell_bg:setPosition(ccp(0,0))
    cell:addChild(cell_bg)
   
    -- 名次不在前三的情况
    if( rank_font ==nil )then
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
   
    --头像
    local icon_bg = CCSprite:create("images/match/head_bg.png")
    icon_bg:setAnchorPoint(ccp(0,0.5))
    icon_bg:setPosition(ccp(138,cell_bg:getContentSize().height*0.5))
    cell_bg:addChild(icon_bg)
    local iconMenu = CCMenu:create()
    iconMenu:setTouchPriority(GodWeaponRankLayer.getTouchPriority()-10)
    iconMenu:setPosition(ccp(0,0))
    icon_bg:addChild(iconMenu)
    require "script/model/utils/HeroUtil"
    local dressId = nil
    local genderId = nil
    if( not table.isEmpty(tCellValue.dress) and (tCellValue.dress["1"])~= nil and tonumber(tCellValue.dress["1"]) > 0 )then
        dressId = tCellValue.dress["1"]
        genderId = HeroModel.getSex(tCellValue.htid)
    end

    --vip 特效
    local vip = tCellValue.vip or 0
    --print("创建前输出参数",tCellValue.htid,"**",dressId,"**",dressId)
    local heroIcon = HeroUtil.getHeroIconByHTID(tCellValue.htid, dressId, dressId,vip)
    local heroIconItem = CCMenuItemSprite:create(heroIcon,heroIcon)
    heroIconItem:setAnchorPoint(ccp(0.5,0.5))
    heroIconItem:setPosition(ccp(icon_bg:getContentSize().width*0.5,icon_bg:getContentSize().height*0.5))
    iconMenu:addChild(heroIconItem,1,lineNum)    
    heroIconItem:registerScriptTapHandler(userFormationItemFun)

    -- lv.
    local lv_sprite = CCSprite:create("images/common/lv.png")
    lv_sprite:setAnchorPoint(ccp(0,1))
    lv_sprite:setPosition(ccp(300,cell_bg:getContentSize().height-10))
    cell_bg:addChild(lv_sprite)
    -- 等级
    local lvStr = tCellValue.level or " "
    local lv_data = CCRenderLabel:create( lvStr , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lv_data:setAnchorPoint(ccp(0,1))
    lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
    lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+5,cell_bg:getContentSize().height-4))
    cell_bg:addChild(lv_data)
    -- 名字
    local nameStr = tCellValue.uname or " "
    local name = CCRenderLabel:create( nameStr , g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    name:setColor(name_color)
    name:setAnchorPoint(ccp(0.5,0))
    name:setPosition(ccp(341,42))
    cell_bg:addChild(name)
    -- 军团名字
    -- print("guildname")
    -- print_t(tCellValue.guild_name)
    if(tCellValue.guild_name ~= nil )then
        local guildStr = tCellValue.guild_name
        local guildname = CCRenderLabel:create("("..guildStr..")" , g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        guildname:setColor(ccc3(0xff, 0xf6, 0x00))
        guildname:setAnchorPoint(ccp(0.5,0))
        guildname:setPosition(ccp(341,10))
        cell_bg:addChild(guildname)
    end

    
    -- 积分
    local myScore_font = CCRenderLabel:create( GetLocalizeStringBy("key_2248"), g_sFontPangWa, 20, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myScore_font:setAnchorPoint(ccp(0.5,1))
    myScore_font:setColor(ccc3(0xff,0xff,0xff))
    myScore_font:setPosition(ccp(515,cell_bg:getContentSize().height-5))
    cell_bg:addChild(myScore_font)
    local scoreStr = tCellValue.point or " "
    local myScore_Data = CCRenderLabel:create( scoreStr, g_sFontPangWa, 20, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myScore_Data:setAnchorPoint(ccp(0.5,0))
    myScore_Data:setColor(ccc3(0x70,0xff,0x18))
    myScore_Data:setPosition(ccp(500,55))
    cell_bg:addChild(myScore_Data)


    -- 最高通关
    local myPass_font = CCRenderLabel:create( GetLocalizeStringBy("djn_117"), g_sFontPangWa, 20, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myPass_font:setAnchorPoint(ccp(0.5,1))
    myPass_font:setColor(ccc3(0xff,0xff,0xff))
    myPass_font:setPosition(ccp(515,55))
    cell_bg:addChild(myPass_font)
    local passStr = tCellValue.pass_num or " "
    local myPass_Data = CCRenderLabel:create(passStr, g_sFontPangWa, 20, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myPass_Data:setAnchorPoint(ccp(0.5,0))
    myPass_Data:setColor(ccc3(0x70,0xff,0x18))
    myPass_Data:setPosition(ccp(500,5))
    cell_bg:addChild(myPass_Data)

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
    local allInfo  = (GodWeaponCopyData.getRankInfo().top)[tag]
    local uname = allInfo.uname
    local ulevel = allInfo.level
    local power = allInfo.fight_force
    local uid = allInfo.uid
    local uGender = HeroModel.getSex(allInfo.htid)
    local htid = allInfo.htid
    local dressInfo = allInfo.dress
    local hero = DB_Heroes.getDataById(htid)
    local imageFile = hero.head_icon_id
    ChatUserInfoLayer.showChatUserInfoLayer(uname,ulevel,power,"images/base/hero/head_icon/" .. imageFile,uid,uGender,htid,dressInfo,GodWeaponRankLayer.getTouchPriority()-50)
end