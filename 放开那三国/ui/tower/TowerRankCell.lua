-- FileName: TowerRankCell.lua 
-- Author: Li Cong 
-- Date: 14-1-7 
-- Purpose: function description of module 


module("TowerRankCell", package.seeall)

-- 创建单元格
function createCell( tCellValue )
    local cell = CCTableViewCell:create()
    -- 背景
    local cellBg = nil
    if( tonumber(tCellValue.rank) == 1 )then
        cellBg = CCSprite:create("images/match/first_bg.png")
    elseif( tonumber(tCellValue.rank) == 2 )then
        cellBg = CCSprite:create("images/match/second_bg.png")
    elseif( tonumber(tCellValue.rank) == 3 )then
        cellBg = CCSprite:create("images/match/third_bg.png")
    else
        cellBg = CCSprite:create("images/match/rank_bg.png")
    end
    cellBg:setAnchorPoint(ccp(0,0))
    cellBg:setPosition(ccp(0,0))
    cell:addChild(cellBg,1)

    -- 名次图标
    local rank_font = nil
    if( tonumber(tCellValue.rank) == 1 )then
        rank_font = CCSprite:create("images/match/one.png")
    elseif( tonumber(tCellValue.rank) == 2 )then
        rank_font = CCSprite:create("images/match/two.png")
    elseif( tonumber(tCellValue.rank) == 3 )then
        rank_font = CCSprite:create("images/match/three.png")
    else
    	local rankStr = tCellValue.rank or " "
        rank_font = CCRenderLabel:create( rankStr, g_sFontPangWa, 50, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
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
    local iconMenu = CCMenu:create()
    iconMenu:setTouchPriority(-420)
    iconMenu:setPosition(ccp(0,0))
    icon_bg:addChild(iconMenu)
    require "script/model/utils/HeroUtil"
    local dressId = nil
    local genderId = nil
    if( not table.isEmpty(tCellValue.dress) and (tCellValue.dress["1"])~= nil and tonumber(tCellValue.dress["1"]) > 0 )then
        dressId = tCellValue.dress["1"]
        genderId = HeroModel.getSex(tCellValue.htid)
    end

    -- added by zhz , vip 特效
    local vip = tCellValue.vip or 0
    --print("输出爬塔中得htid****------*******----",tCellValue.htid)
    local heroIcon = HeroUtil.getHeroIconByHTID(tCellValue.htid, dressId, genderId, vip)
    local heroIconItem = CCMenuItemSprite:create(heroIcon,heroIcon)
    heroIconItem:setAnchorPoint(ccp(0.5,0.5))
    heroIconItem:setPosition(ccp(icon_bg:getContentSize().width*0.5,icon_bg:getContentSize().height*0.5))
    iconMenu:addChild(heroIconItem,1,tonumber( tCellValue.uid ))
    heroIconItem:registerScriptTapHandler(userFormationItemFun)

    -- lv.
    local lv_sprite = CCSprite:create("images/common/lv.png")
    lv_sprite:setAnchorPoint(ccp(0,1))
    lv_sprite:setPosition(ccp(290,cellBg:getContentSize().height-18))
    cellBg:addChild(lv_sprite)
    -- 等级
    local lvStr = tCellValue.level or " "
    local lv_data = CCRenderLabel:create( lvStr , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lv_data:setAnchorPoint(ccp(0,1))
    lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
    lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+5,cellBg:getContentSize().height-12))
    cellBg:addChild(lv_data)
    -- 名字
    local nameStr = tCellValue.uname or " "
    local name = CCRenderLabel:create( nameStr , g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
     if( tonumber(tCellValue.rank) == 1 )then
        name:setColor(ccc3(0xf9, 0x59, 0xff))
    elseif( tonumber(tCellValue.rank) == 2 )then
        name:setColor(ccc3(0x00, 0xe4, 0xff))
    elseif( tonumber(tCellValue.rank) == 3 )then
        name:setColor(ccc3(0x70, 0xff, 0x18))
    else
        name:setColor(ccc3(0xff, 0xff, 0xff))
    end
    name:setAnchorPoint(ccp(0.5,0))
    name:setPosition(ccp(331,34))
    cellBg:addChild(name)

     -- 军团名字
    if(tCellValue.guild_name)then
        local guildNameStr = tCellValue.guild_name or " "
        local guildNameFont = CCRenderLabel:create( "[" .. guildNameStr .. "]" , g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        guildNameFont:setAnchorPoint(ccp(0.5,0))
        guildNameFont:setColor(ccc3(0xff, 0xf6, 0x00))
        guildNameFont:setPosition(ccp(cellBg:getContentSize().width*0.6,cellBg:getContentSize().height*0.05))
        cellBg:addChild(guildNameFont)
    end

    -- 爬塔进度
    local myScore_font = CCRenderLabel:create( GetLocalizeStringBy("key_2317"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myScore_font:setAnchorPoint(ccp(1,1))
    myScore_font:setColor(ccc3(0xff,0xff,0xff))
    myScore_font:setPosition(ccp(555,cellBg:getContentSize().height-20))
    cellBg:addChild(myScore_font)
    local max_levelStr = tCellValue.max_level or " "
    local myScore_Data = CCRenderLabel:create( max_levelStr .. GetLocalizeStringBy("key_2400"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myScore_Data:setAnchorPoint(ccp(0.5,0))
    myScore_Data:setColor(ccc3(0x70,0xff,0x18))
    myScore_Data:setPosition(ccp(500,23))
    cellBg:addChild(myScore_Data)

    return cell
end


-- 对方阵容回调
function userFormationItemFun( tag, item_obj )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2710") .. tag )
    -- local str1 = GetLocalizeStringBy("key_3038")
    -- require "script/ui/tip/AnimationTip"
    -- AnimationTip.showTip(str1)
    require "script/ui/active/RivalInfoLayer"
    RivalInfoLayer.createLayer(tonumber(tag))
end
