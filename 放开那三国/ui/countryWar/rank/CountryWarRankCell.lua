-- FileName:CountryWarRankCell.lua
-- Author:FQQ
-- Data:2015-11-17
-- Purpose:国战积分排行榜Cell
CountryWarRankCell = class("CountryWarRankCell",function ( pInfo, p_index,pIsSupported )
    return CCTableViewCell:create()
end)

function CountryWarRankCell:ctor( pInfo, p_index,pIsSupported)
    local cellBg = nil
    local name_color = nil
    local rankInfo = pInfo
    -- 记录一些数据
    self._pid = pInfo.pid
    self._server_id = pInfo.server_id
    --一级背景，根据级别来选取背景
    if( p_index == 1 )then
        cellBg = CCSprite:create("images/rank/bg_1.png")
        name_color= ccc3(0xf9,0x59,0xff)
    elseif( p_index == 2 )then
        cellBg = CCSprite:create("images/rank/bg_2.png")
        name_color= ccc3(0x00,0xe4,0xff)
    elseif( p_index == 3 )then
        cellBg = CCSprite:create("images/rank/bg_3.png")
        name_color= ccc3(0x70, 0xff, 0x18)
    else
        cellBg = CCSprite:create("images/rank/bg_4.png")
        name_color= ccc3(0xff,0xff,0xff)
    end
    self:addChild(cellBg)
    --获取头像
    local icon_bg = CCSprite:create("images/match/head_bg.png")
    icon_bg:setAnchorPoint(ccp(0,0.5))
    icon_bg:setPosition(ccp(0,cellBg:getContentSize().height*0.5))
    cellBg:addChild(icon_bg)
    require "script/model/utils/HeroUtil"
    local dressId = nil
    local genderId = nil
    if( not table.isEmpty(rankInfo.dress) and (rankInfo.dress["1"])~= nil and tonumber(rankInfo.dress["1"]) > 0 )then
        dressId = rankInfo.dress["1"]
        genderId = HeroModel.getSex(rankInfo.htid)
    end
    local vip= rankInfo.vip or 0
    local heroIcon = HeroUtil.getHeroIconByHTID(rankInfo.htid, dressId, genderId, vip)
    local heroIconItem = CCMenuItemSprite:create(heroIcon,heroIcon)
    heroIconItem:setAnchorPoint(ccp(0.5,0.5))
    heroIconItem:setPosition(ccp(icon_bg:getContentSize().width*0.5,icon_bg:getContentSize().height*0.5))
    icon_bg:addChild(heroIconItem)
    --获取级别
    local lv_sprite = CCSprite:create("images/common/lv.png")
    lv_sprite:setAnchorPoint(ccp(0,1))
    lv_sprite:setPosition(ccp(150,cellBg:getContentSize().height-10))
    cellBg:addChild(lv_sprite)
    local lvStr = rankInfo.level or " "
    local lv_data = CCRenderLabel:create( lvStr , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lv_data:setAnchorPoint(ccp(0,1))
    lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
    lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+5,cellBg:getContentSize().height-4))
    cellBg:addChild(lv_data)
    --玩家名字
    local nameStr = rankInfo.uname or " "
    local name = CCRenderLabel:create( nameStr , g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    name:setColor(name_color)
    name:setAnchorPoint(ccp(0.5,0))
    name:setPosition(ccp(200,50))
    cellBg:addChild(name)
    --服务器名字
    local serverName = rankInfo.server_name or ""
    local serverNameLabel = CCRenderLabel:create( serverName , g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    serverNameLabel:setColor(name_color)
    serverNameLabel:setAnchorPoint(ccp(0.5,0))
    serverNameLabel:setPosition(ccp(200,20))
    cellBg:addChild(serverNameLabel)
    --国战积分
    local countryWarStr = CCRenderLabel:create(GetLocalizeStringBy("fqq_015"),g_sFontPangWa,22,1,ccc3(0x00, 0x00, 0x00),type_stroke)
    countryWarStr:setAnchorPoint(ccp(0.5,1))
    countryWarStr:setPosition(ccp(400,cellBg:getContentSize().height))
    cellBg:addChild(countryWarStr)
    local countryWarScoreLabel = CCRenderLabel:create(pInfo.audition_point, g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_shadow)
    countryWarScoreLabel:setPosition(ccpsprite(0.5,0,countryWarStr))
    countryWarScoreLabel:setAnchorPoint(ccp(0.5, 1))
    countryWarScoreLabel:setColor(ccc3(112.0, 255.0, 24.0))
    countryWarStr:addChild(countryWarScoreLabel)
    --战斗力
    local finghtPower = CCRenderLabel:create(GetLocalizeStringBy("fqq_016"),g_sFontPangWa,22,1,ccc3(0x00,0x00,0x00),type_stroke)
    finghtPower:setAnchorPoint(ccp(0.5,0))
    finghtPower:setPosition(ccp(400,30))
    cellBg:addChild(finghtPower)
    local fightForceLabel = CCRenderLabel:create(pInfo.fight_force, g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_shadow)
    fightForceLabel:setPosition(ccpsprite(0.5,0,finghtPower))
    fightForceLabel:setAnchorPoint(ccp(0.5, 1))
    fightForceLabel:setColor(ccc3(112.0, 255.0, 24.0))
    finghtPower:addChild(fightForceLabel)
    --助威
    local menu = CCMenu:create()
    menu:setTouchPriority(-760)
    menu:setPosition(ccp(0,0))
    cellBg:addChild(menu)
    --鼓舞按钮
    local normalSprite  = CCSprite:create("images/country_war/zhuwei.png")
    local selectSprite  = CCSprite:create("images/country_war/zhuwei2.png")
    local disabledSprite = BTGraySprite:create("images/country_war/zhuwei.png")
    local cheerBtn = CCMenuItemSprite:create(normalSprite,selectSprite,disabledSprite)
    cheerBtn:setAnchorPoint(ccp(0.5,0))
    cheerBtn:setPosition(ccp(510,40))
    menu:addChild(cheerBtn)
    if  pIsSupported then
        cheerBtn:setEnabled(false)
        return
    end
    local showCallfunc = function ( ... )
        self:cheerCallFunc(...)
    end
    cheerBtn:registerScriptTapHandler(function ( ... )
        AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
        AlertTip.showAlert( GetLocalizeStringBy("fqq_027"), showCallfunc, false, nil)
    end)
end

function CountryWarRankCell:cheerCallFunc()
    require "script/ui/countryWar/cheer/CountryWarCheerController"
    CountryWarCheerController.supportOneUser(self._pid,self._server_id,function ()
        CountryWarRankLayer.refreshAfterCheer()
        CountryWarCheerListLayer.updateSupportInfo()
    end)
 end

