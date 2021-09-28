-- FileName: MissionAfterBattle.lua
-- Author: licong
-- Date: 14-4-23
-- Purpose: 城池战结算面板

module("MissionAfterBattle", package.seeall)

local _allData
local afterOKCallFun
local _isReplay
local backAnimSprite
local animSprite
local isDestoryCpy = true
local guildName

local function init()
    _allData = nil
    afterOKCallFun = nil
    _isReplay = nil
    backAnimSprite = nil
    animSprite = nil
    isDestoryCpy = true
    guildName = nil
end

local function cardLayerTouch(eventType, x, y)
    return true
end

local function getHeroNameColor( utid )
    local name_color = nil
    local stroke_color = nil
    if(tonumber(utid) == 1)then
        -- 女性玩家
        name_color = ccc3(0xf9,0x59,0xff)
        stroke_color = ccc3(0x00,0x00,0x00)
    elseif(tonumber(utid) == 2)then
        -- 男性玩家
        name_color = ccc3(0x00,0xe4,0xff)
        stroke_color = ccc3(0x00,0x00,0x00)
    end
    return name_color, stroke_color
end

-- 查看战报回调
local function userFormationItemFun( tag, item_obj )
    -- 音效
    -- if table.count(_allData.server.team1.memberList) == 0 or table.count(_allData.server.team2.memberList) == 0 then
    --     require "script/ui/tip/AnimationTip"
    --     AnimationTip.showTip(GetLocalizeStringBy("key_2383"))
    -- else
        require "script/audio/AudioUtil"
        AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
        print(GetLocalizeStringBy("key_1742") .. tag )

        require "script/ui/guild/copy/GuildBattleReportLayer"
        local fightData = {}
        fightData.server = _allData.atk.fightRet
        GuildBattleReportLayer.showLayer(fightData,false,-493)
    -- end
end

local function replayItemFun( tag, item_obj )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2460") .. tag )
    -- require "script/battle/BattleLayer"
    -- BattleLayer.replay()
end

local function okItemFun( tag, item_obj )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2060") .. tag )
    mainLayer:unregisterScriptTouchHandler()
    require "script/battle/BattleLayer"
    BattleLayer.closeLayer()
    mainLayer:removeFromParentAndCleanup(true)
    mainLayer = nil
    -- 点确定后 调用回调
    if(afterOKCallFun ~= nil)then
        afterOKCallFun()
    end
end


-- added by zhz 发送战报的回调
function sendMegFun( tag, item )
    -- -- 音效
    -- require "script/audio/AudioUtil"
    -- AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    -- require "script/ui.chat/ChatUtil"
    -- local function sendClickCallback( )
    --     _sendMsgItem:setEnabled(false)
    --     _sendMsgItem_font:setColor(ccc3(0xf1,0xf1,0xf1))
    --     AnimationTip.showTip( GetLocalizeStringBy("key_4001") )
    -- end

    -- local fightStr = _allData.server
    -- ChatUtil.sendChatinfo(fightStr, ChatCache.ChatInfoType.battle_report_player, ChatCache.ChannelType.world, sendClickCallback)
end


local function createButtonItem()
    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_green_n.png")
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_green_h.png")
    local disabledSprite = CCScale9Sprite:create("images/common/btn/btn_hui.png")
    local item = CCMenuItemSprite:create(normalSprite,selectSprite,disabledSprite)
    return item
end

function animationEnd( ... )
    if(backAnimSprite~=nil)then
        backAnimSprite:cleanup()
    end
    if(animSprite~=nil)then
        animSprite:cleanup()
    end
end

function animationFrameChanged()
end

-- 创建白色的背景
function createWhiteBg( )
    local levelBg = CCScale9Sprite:create("images/common/labelbg_white.png")
    levelBg:setContentSize( CCSizeMake(420,30))
    return levelBg
end

function createAfterBattleLayer( tAllData, isReplay, CallFun,isDestory,cityName)
    print("shitshitshit")
    print_t(tAllData)
    print("shitshitshit")
    init()
    isDestoryCpy = isDestory
    _allData = tAllData
    afterOKCallFun = CallFun
    _isReplay = isReplay

    local cityNameCpy = cityName

    local amf3_obj = Base64.decodeWithZip(tAllData.atk.fightRet)
    local lua_obj = amf3.decode(amf3_obj)

    --add
    require "script/ui/guild/GuildDataCache"
    local data = GuildDataCache.getMineSigleGuildInfo()
    local userGuildId =  data.guild_id

    local attackGuildId = UserModel.getUserUid()
    local defendGuildId = tAllData.atk.uid
    local appraisal = tAllData.atk.appraisal
    local isWin = nil
    require "script/ui/battlemission/MissionData"

    local des = DB_Corps_quest.getDataById(MissionData.getNowTaskId())
    local tab = string.split(des.completeConditions,",")
    print_t(des)

    -- AnimationTip:getParent():reorderChild(AnimationTip,100)
    if( appraisal ~= "E" and appraisal ~= "F" )then
        isWin = true
        if(isDestory==true)then
            AnimationTip.showTip(GetLocalizeStringBy("llp_55")..GetLocalizeStringBy("llp_60")..cityNameCpy..GetLocalizeStringBy("llp_56")..GetLocalizeStringBy("llp_57")..tab[1]..GetLocalizeStringBy("llp_58"))
        else
            AnimationTip.showTip(GetLocalizeStringBy("llp_55")..GetLocalizeStringBy("llp_61")..cityNameCpy..GetLocalizeStringBy("llp_56")..GetLocalizeStringBy("llp_62")..tab[1]..GetLocalizeStringBy("llp_58"))
        end
    else

        isWin = false
        if(isDestory==true)then
            AnimationTip.showTip(GetLocalizeStringBy("llp_59")..GetLocalizeStringBy("llp_60")..cityNameCpy..GetLocalizeStringBy("llp_56")..GetLocalizeStringBy("llp_63"))
        else
            AnimationTip.showTip(GetLocalizeStringBy("llp_59")..GetLocalizeStringBy("llp_61")..cityNameCpy..GetLocalizeStringBy("llp_56")..GetLocalizeStringBy("llp_63"))
        end
    end

    --add over

    local winSize = CCDirector:sharedDirector():getWinSize()
    mainLayer = CCLayerColor:create(ccc4(11,11,11,200))
    mainLayer:setTouchEnabled(true)
    mainLayer:registerScriptTouchHandler(cardLayerTouch,false,-1000,true)

    local bg_sprite = BaseUI.createViewBg(CCSizeMake(515,450))
    bg_sprite:setAnchorPoint(ccp(0.5,0.5))
    bg_sprite:setPosition(ccp(winSize.width/2,winSize.height*0.4))
    mainLayer:addChild(bg_sprite)

    setAdaptNode(bg_sprite)

    local brownBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    brownBg:setContentSize(CCSizeMake(470,160))
    brownBg:setAnchorPoint(ccp(0.5,0))
    brownBg:setPosition(ccp(bg_sprite:getContentSize().width/2,220))
    bg_sprite:addChild(brownBg)

    -- 我方名字
    local fullRect = CCRectMake(0,0,31,41)
    local insetRect = CCRectMake(8,17,2,2)
    local myName_bg = CCScale9Sprite:create("images/common/b_name_bg.png", fullRect, insetRect)
    myName_bg:setContentSize(CCSizeMake(195,44))
    myName_bg:setAnchorPoint(ccp(0,0.5))
    myName_bg:setPosition(ccp(3,brownBg:getContentSize().height-35))
    brownBg:addChild(myName_bg)
    -- 我方姓名的颜色
    local myNameStr = lua_obj.team1.name
    local name_color,stroke_color = getHeroNameColor(2)
    local myName_font = CCRenderLabel:create( myNameStr, g_sFontPangWa, 25, 1, stroke_color, type_stroke)
    myName_font:setColor(name_color)
    myName_font:setAnchorPoint(ccp(0.5,0.5))
    myName_font:setPosition(ccp(myName_bg:getContentSize().width*0.5,myName_bg:getContentSize().height*0.5))
    myName_bg:addChild(myName_font)

    -- 敌方名字
    local fullRect = CCRectMake(0,0,31,41)
    local insetRect = CCRectMake(8,17,2,2)
    local enemyName_bg = CCScale9Sprite:create("images/common/b_name_bg.png", fullRect, insetRect)
    enemyName_bg:setContentSize(CCSizeMake(195,44))
    enemyName_bg:setAnchorPoint(ccp(0,0.5))
    enemyName_bg:setPosition(ccp(brownBg:getContentSize().width-3,brownBg:getContentSize().height-35))
    brownBg:addChild(enemyName_bg)
    enemyName_bg:setScale(enemyName_bg:getScaleX()*-1)
    -- 敌方姓名的颜色
    local enemyNameStr = nil
    if(tonumber(tAllData.atk.uid)~=0)then
        enemyNameStr = lua_obj.team2.name
    else
        require "db/DB_Army"
        local des = DB_Army.getDataById(tonumber(lua_obj.team2.name))
        enemyNameStr = des.display_name
    end
    local name_color,stroke_color = getHeroNameColor( 1 )
    local enemyName_font = CCRenderLabel:create( enemyNameStr, g_sFontPangWa, 25, 1, stroke_color, type_stroke)
    enemyName_font:setColor(name_color)
    enemyName_font:setAnchorPoint(ccp(0.5,0.5))
    enemyName_font:setPosition(ccp(enemyName_bg:getContentSize().width*0.5,enemyName_bg:getContentSize().height*0.5))
    enemyName_bg:addChild(enemyName_font)
    enemyName_font:setScale(enemyName_font:getScaleX()*-1)

    local vs_sprite = CCSprite:create("images/arena/vs.png")
    vs_sprite:setAnchorPoint(ccp(0.5,0.5))
    vs_sprite:setPosition(ccp(brownBg:getContentSize().width*0.5,brownBg:getContentSize().height-20-enemyName_bg:getContentSize().height/2))
    brownBg:addChild(vs_sprite)

    local winFlag = CCSprite:create("images/battle/battlefield_report/sheng.png")
    winFlag:setAnchorPoint(ccp(0.5,0))
    brownBg:addChild(winFlag)

    local lostFlag = CCSprite:create("images/battle/battlefield_report/fu.png")
    lostFlag:setAnchorPoint(ccp(0.5,0))
    brownBg:addChild(lostFlag)

    if tostring(isWin) == "false" or isWin == false then
        lostFlag:setPosition(ccp(75,30))
        winFlag:setPosition(ccp(brownBg:getContentSize().width-75,30))
    else
        winFlag:setPosition(ccp(75,30))
        lostFlag:setPosition(ccp(brownBg:getContentSize().width-75,30))
    end

    -- 三个按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-1000)
    bg_sprite:addChild(menu)

    -- 查看战报
    local userFormationItem = createButtonItem()
    userFormationItem:setAnchorPoint(ccp(0.5,0))
    userFormationItem:registerScriptTapHandler(userFormationItemFun)
    menu:addChild(userFormationItem)
    userFormationItem:setVisible(false)
    -- 字体
    local userFormationItem_font = CCRenderLabel:create( GetLocalizeStringBy("key_2849") , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    userFormationItem_font:setAnchorPoint(ccp(0.5,0.5))
    userFormationItem_font:setPosition(ccp(userFormationItem:getContentSize().width*0.5,userFormationItem:getContentSize().height*0.5))
    userFormationItem:addChild(userFormationItem_font)
    userFormationItem_font:setColor(ccc3(0xfe, 0xdb, 0x1c))

    userFormationItem:setPosition(ccp(bg_sprite:getContentSize().width*0.5,135))

     -- 重播
    local replayItem = createButtonItem()
    replayItem:setAnchorPoint(ccp(0.5,0))
    replayItem:registerScriptTapHandler(replayItemFun)
    menu:addChild(replayItem)
    -- 字体
    local replayItem_font = CCRenderLabel:create( GetLocalizeStringBy("key_2184") , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    replayItem_font:setAnchorPoint(ccp(0.5,0.5))
    replayItem_font:setPosition(ccp(replayItem:getContentSize().width*0.5,replayItem:getContentSize().height*0.5))
    replayItem:addChild(replayItem_font)
    -- 重播功能暂未开放
    replayItem:setEnabled(false)
    replayItem_font:setColor(ccc3(0xf1,0xf1,0xf1))

    replayItem:setPosition(ccp(bg_sprite:getContentSize().width*0.3,25))

    -- 确定
    local okItem = createButtonItem()
    okItem:setAnchorPoint(ccp(0.5,0))
    okItem:registerScriptTapHandler(okItemFun)
    menu:addChild(okItem)
    -- 字体
    local okItem_font = CCRenderLabel:create( GetLocalizeStringBy("key_1985") , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    okItem_font:setAnchorPoint(ccp(0.5,0.5))
    okItem_font:setPosition(ccp(okItem:getContentSize().width*0.5,okItem:getContentSize().height*0.5))
    okItem:addChild(okItem_font)
    okItem_font:setColor(ccc3(0xfe, 0xdb, 0x1c))

    okItem:setPosition(ccp(bg_sprite:getContentSize().width*0.7,25))

    --------------------------------
    local cityInfoData =CityData.getLookingCityInfo()

    if(cityInfoData~=nil)then
        if( cityInfoData and not table.isEmpty(cityInfoData))then
            -- 不为空 则被军团占领
            guildName = cityInfoData.serData.guild_name
            if(tonumber(guildName) == 0 and tonumber(levelNum) == 0 and tonumber(guildFightNum) == 0 )then
                -- 隐藏NPC 不显示
                guildName = nil
            end
        else
            if( cityInfoData.dbData.defendEnemy == nil)then
                guildName = nil
            else
                -- 则显示npc
                require "db/DB_Copy_team"
                local npcData = DB_Copy_team.getDataById(cityInfoData.dbData.defendEnemy)
                guildName = GetLocalizeStringBy("zzh_1282")
            end
        end
    end
    --------------------------------

    if isWin then
        -- 红条
        local sprite = CCSprite:create("images/common/red_line.png")
        sprite:setAnchorPoint(ccp(0.5,0.5))
        sprite:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height*0.5-20))
        bg_sprite:addChild(sprite)
        -- 字体
        local item_font = nil
        if(isDestoryCpy)then
            if(tonumber(guildName)~=0)then
                item_font = CCRenderLabel:create( guildName , g_sFontPangWa, 25,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            else
                item_font = CCRenderLabel:create( GetLocalizeStringBy("zzh_1282") , g_sFontPangWa, 25,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            end
        else
            item_font = CCRenderLabel:create( guildName , g_sFontPangWa, 25,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        end
        item_font:setAnchorPoint(ccp(0.5,0.5))
        item_font:setColor(ccc3(0xff,0xf6,0x00))
        item_font:setPosition(ccp(sprite:getContentSize().width*0.5,sprite:getContentSize().height*0.5))
        sprite:addChild(item_font)
        --白底
        local upWhiteSprite = createWhiteBg()
        bg_sprite:addChild(upWhiteSprite)
        upWhiteSprite:setAnchorPoint(ccp(0.5,1))
        upWhiteSprite:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height*0.5-item_font:getContentSize().height-10))

        --城池名
        local cityName = cityInfoData.dbData.name or GetLocalizeStringBy("key_3392")
        local cityNameLabel = CCLabelTTF:create(cityName,g_sFontPangWa,21)
        cityNameLabel:setAnchorPoint(ccp(1,0.5))
        cityNameLabel:setColor(ccc3(0x78,0x25,0x00))
        upWhiteSprite:addChild(cityNameLabel)
        cityNameLabel:setPosition(ccp(upWhiteSprite:getContentSize().width*0.2,upWhiteSprite:getContentSize().height*0.5))
        --城防：
        local cityDefendLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_100"),g_sFontPangWa,21)
        cityDefendLabel:setColor(ccc3(0x78,0x25,0x00))
        cityDefendLabel:setAnchorPoint(ccp(0,0.5))
        upWhiteSprite:addChild(cityDefendLabel)
        cityDefendLabel:setPosition(ccp(upWhiteSprite:getContentSize().width*0.2,upWhiteSprite:getContentSize().height*0.5))
        --   +/-40
        local cityDefendNumStr = nil
        local cityDefendNumLabel = nil
        if(isDestoryCpy)then
            cityDefendNumStr = "-".._allData.subdefence
            cityDefendNumLabel = CCLabelTTF:create(cityDefendNumStr,g_sFontPangWa,21)
            cityDefendNumLabel:setColor(ccc3(0xff,0x00,0x00))
        else
            cityDefendNumStr = "+".._allData.adddefence
            cityDefendNumLabel = CCLabelTTF:create(cityDefendNumStr,g_sFontPangWa,21)
            cityDefendNumLabel:setColor(ccc3(0x00,0x6d,0x2f))
        end
        -- cityDefendNumLabel = CCLabelTTF:create(cityDefendNumStr,g_sFontPangWa,21)
        -- cityDefendNumLabel:setColor(ccc3(0xff,0x00,0x00))
        cityDefendNumLabel:setAnchorPoint(ccp(0,0.5))
        upWhiteSprite:addChild(cityDefendNumLabel)
        cityDefendNumLabel:setPosition(ccp(cityDefendLabel:getContentSize().width+upWhiteSprite:getContentSize().width*0.2,upWhiteSprite:getContentSize().height*0.5))
        --城防上升或者下降至
        local fightResultLabel = nil
        if(isDestoryCpy)then
            fightResultLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_102"),g_sFontPangWa,21)
        else
            fightResultLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_101"),g_sFontPangWa,21)
        end

        fightResultLabel:setAnchorPoint(ccp(0,0.5))
        fightResultLabel:setColor(ccc3(0x78,0x25,0x00))
        upWhiteSprite:addChild(fightResultLabel)
        fightResultLabel:setPosition(ccp(cityDefendLabel:getContentSize().width+upWhiteSprite:getContentSize().width*0.2+cityDefendNumLabel:getContentSize().width,upWhiteSprite:getContentSize().height*0.5))

        --8510新的城防值
        local fightValueLabel = CCLabelTTF:create(_allData.defence,g_sFontPangWa,21)
        if(isDestoryCpy)then
            fightValueLabel:setColor(ccc3(0xff,0x00,0x00))
        else
            fightValueLabel:setColor(ccc3(0x00,0x6d,0x2f))
        end
        upWhiteSprite:addChild(fightValueLabel)
        fightValueLabel:setAnchorPoint(ccp(0,0.5))
        fightValueLabel:setPosition(ccp(cityDefendLabel:getContentSize().width+upWhiteSprite:getContentSize().width*0.2+cityDefendNumLabel:getContentSize().width+fightResultLabel:getContentSize().width,upWhiteSprite:getContentSize().height*0.5))

        --)
        local upEndLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_106"),g_sFontPangWa,21)
        upEndLabel:setColor(ccc3(0x78,0x25,0x00))
        upEndLabel:setAnchorPoint(ccp(0,0.5))
        upEndLabel:setPosition(ccp(fightValueLabel:getPositionX()+fightValueLabel:getContentSize().width,upWhiteSprite:getContentSize().height*0.5))
        upWhiteSprite:addChild(upEndLabel)

        local downWhiteSprite = createWhiteBg()
        bg_sprite:addChild(downWhiteSprite)
        downWhiteSprite:setAnchorPoint(ccp(0.5,1))
        downWhiteSprite:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height*0.5-item_font:getContentSize().height-upWhiteSprite:getContentSize().height*1.5))

        --城池攻击力：
        local cityAttackLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_103"),g_sFontPangWa,21)
        cityAttackLabel:setColor(ccc3(0x78,0x25,0x00))
        cityAttackLabel:setAnchorPoint(ccp(0,0.5))
        downWhiteSprite:addChild(cityAttackLabel)
        cityAttackLabel:setPosition(ccp(0,downWhiteSprite:getContentSize().height*0.5))
        --   +/-5%
        local cityDefendNumStr = nil
        local cityAttackNumLabel = nil
        if(isDestoryCpy)then
            cityDefendNumStr = "-"..string.format("%.2f",_allData.subforce).."%"
            cityAttackNumLabel = CCLabelTTF:create(cityDefendNumStr,g_sFontPangWa,21)
            cityAttackNumLabel:setColor(ccc3(0xff,0x00,0x00))
        else
            cityDefendNumStr = "+"..string.format("%.2f",_allData.addforce).."%"
            cityAttackNumLabel = CCLabelTTF:create(cityDefendNumStr,g_sFontPangWa,21)
            cityAttackNumLabel:setColor(ccc3(0x00,0x6d,0x2f))
        end
        -- cityAttackNumLabel = CCLabelTTF:create(cityDefendNumStr,g_sFontPangWa,21)
        -- cityAttackNumLabel:setColor(ccc3(0xff,0x00,0x00))
        cityAttackNumLabel:setAnchorPoint(ccp(0,0.5))
        downWhiteSprite:addChild(cityAttackNumLabel)
        cityAttackNumLabel:setPosition(ccp(cityAttackLabel:getContentSize().width,downWhiteSprite:getContentSize().height*0.5))
        --城池战斗力上升或者下降至
        local powerResultLabel = nil
        if(isDestoryCpy)then
            powerResultLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_105"),g_sFontPangWa,21)
        else
            powerResultLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_104"),g_sFontPangWa,21)
        end

        powerResultLabel:setAnchorPoint(ccp(0,0.5))
        powerResultLabel:setColor(ccc3(0x78,0x25,0x00))
        downWhiteSprite:addChild(powerResultLabel)
        powerResultLabel:setPosition(ccp(cityAttackLabel:getContentSize().width+cityAttackNumLabel:getContentSize().width,downWhiteSprite:getContentSize().height*0.5))

        --8510新的战斗力
        local powerValueLabel = CCLabelTTF:create(_allData.force.."%",g_sFontPangWa,21)
        if(isDestoryCpy)then
            powerValueLabel:setColor(ccc3(0xff,0x00,0x00))
        else
            powerValueLabel:setColor(ccc3(0x00,0x6d,0x2f))
        end
        downWhiteSprite:addChild(powerValueLabel)
        powerValueLabel:setAnchorPoint(ccp(0,0.5))
        powerValueLabel:setPosition(ccp(cityAttackLabel:getContentSize().width+cityAttackNumLabel:getContentSize().width+powerResultLabel:getContentSize().width,downWhiteSprite:getContentSize().height*0.5))

        --)
        local downEndLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_106"),g_sFontPangWa,21)
        downEndLabel:setColor(ccc3(0x78,0x25,0x00))
        downEndLabel:setAnchorPoint(ccp(0,0.5))
        downEndLabel:setPosition(ccp(powerValueLabel:getPositionX()+powerValueLabel:getContentSize().width,downWhiteSprite:getContentSize().height*0.5))
        downWhiteSprite:addChild(downEndLabel)
    else
        -- 红条
        local sprite = CCSprite:create("images/common/red_line.png")
        sprite:setAnchorPoint(ccp(0.5,0.5))
        sprite:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height*0.5-20))
        bg_sprite:addChild(sprite)
        -- 字体
        local item_font = nil
        if(isDestoryCpy)then
            item_font = CCRenderLabel:create( guildName , g_sFontPangWa, 25,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        else
            item_font = CCRenderLabel:create( myNameStr , g_sFontPangWa, 25,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        end
        item_font:setAnchorPoint(ccp(0.5,0.5))
        item_font:setColor(ccc3(0xff,0xf6,0x00))
        item_font:setPosition(ccp(sprite:getContentSize().width*0.5,sprite:getContentSize().height*0.5))
        sprite:addChild(item_font)
        --白底
        local upWhiteSprite = createWhiteBg()
        bg_sprite:addChild(upWhiteSprite)
        upWhiteSprite:setAnchorPoint(ccp(0.5,1))
        upWhiteSprite:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height*0.5-item_font:getContentSize().height-10))

        --城池名
        local cityName = cityInfoData.dbData.name or GetLocalizeStringBy("key_3392")
        local cityNameLabel = CCLabelTTF:create(cityName,g_sFontPangWa,21)
        cityNameLabel:setColor(ccc3(0x78,0x25,0x00))
        cityNameLabel:setAnchorPoint(ccp(1,0.5))
        upWhiteSprite:addChild(cityNameLabel)
        cityNameLabel:setPosition(ccp(upWhiteSprite:getContentSize().width*0.2,upWhiteSprite:getContentSize().height*0.5))
        --城防：
        local cityDefendLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_100"),g_sFontPangWa,21)
        cityDefendLabel:setColor(ccc3(0x78,0x25,0x00))
        cityDefendLabel:setAnchorPoint(ccp(0,0.5))
        upWhiteSprite:addChild(cityDefendLabel)
        cityDefendLabel:setPosition(ccp(upWhiteSprite:getContentSize().width*0.2,upWhiteSprite:getContentSize().height*0.5))
        --   +/-40
        local cityDefendNumStr = nil
        local cityDefendNumLabel = nil
        cityDefendNumStr = 0
        cityDefendNumLabel = CCLabelTTF:create(cityDefendNumStr,g_sFontPangWa,21)
        if(isDestoryCpy)then
            cityDefendNumLabel:setColor(ccc3(0xff,0x00,0x00))
        else
            cityDefendNumLabel:setColor(ccc3(0x00,0x6d,0x2f))
        end
        cityDefendNumLabel:setAnchorPoint(ccp(0,0.5))
        upWhiteSprite:addChild(cityDefendNumLabel)
        cityDefendNumLabel:setPosition(ccp(cityDefendLabel:getContentSize().width+upWhiteSprite:getContentSize().width*0.2,upWhiteSprite:getContentSize().height*0.5))
        --城防上升或者下降至
        local fightResultLabel = nil

        fightResultLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_107"),g_sFontPangWa,21)

        fightResultLabel:setAnchorPoint(ccp(0,0.5))
        fightResultLabel:setColor(ccc3(0x78,0x25,0x00))
        upWhiteSprite:addChild(fightResultLabel)
        fightResultLabel:setPosition(ccp(cityDefendLabel:getContentSize().width+upWhiteSprite:getContentSize().width*0.2+cityDefendNumLabel:getContentSize().width,upWhiteSprite:getContentSize().height*0.5))

        --)
        local upEndLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_106"),g_sFontPangWa,21)
        upEndLabel:setColor(ccc3(0x78,0x25,0x00))
        upEndLabel:setAnchorPoint(ccp(0,0.5))
        upEndLabel:setPosition(ccp(cityDefendLabel:getContentSize().width+upWhiteSprite:getContentSize().width*0.2+cityDefendNumLabel:getContentSize().width+fightResultLabel:getContentSize().width,upWhiteSprite:getContentSize().height*0.5))
        upWhiteSprite:addChild(upEndLabel)

        local downWhiteSprite = createWhiteBg()
        bg_sprite:addChild(downWhiteSprite)
        downWhiteSprite:setAnchorPoint(ccp(0.5,1))
        downWhiteSprite:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height*0.5-item_font:getContentSize().height-upWhiteSprite:getContentSize().height*1.5))

        --城池攻击力：
        local cityAttackLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_103"),g_sFontPangWa,21)
        cityAttackLabel:setColor(ccc3(0x78,0x25,0x00))
        cityAttackLabel:setAnchorPoint(ccp(0,0.5))
        downWhiteSprite:addChild(cityAttackLabel)
        cityAttackLabel:setPosition(ccp(0,downWhiteSprite:getContentSize().height*0.5))
        --   +/-5%
        local cityDefendNumStr = nil
        local cityAttackNumLabel = nil

        cityDefendNumStr = 0

        cityAttackNumLabel = CCLabelTTF:create(cityDefendNumStr,g_sFontPangWa,21)
        if(isDestoryCpy)then
            cityAttackNumLabel:setColor(ccc3(0xff,0x00,0x00))
        else
            cityAttackNumLabel:setColor(ccc3(0x00,0x6d,0x2f))
        end
        cityAttackNumLabel:setAnchorPoint(ccp(0,0.5))
        downWhiteSprite:addChild(cityAttackNumLabel)
        cityAttackNumLabel:setPosition(ccp(cityAttackLabel:getContentSize().width,downWhiteSprite:getContentSize().height*0.5))
        --城池战斗力上升或者下降至
        local powerResultLabel = nil
        powerResultLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_108"),g_sFontPangWa,21)

        powerResultLabel:setAnchorPoint(ccp(0,0.5))
        powerResultLabel:setColor(ccc3(0x78,0x25,0x00))
        downWhiteSprite:addChild(powerResultLabel)
        powerResultLabel:setPosition(ccp(cityAttackLabel:getContentSize().width+cityAttackNumLabel:getContentSize().width,downWhiteSprite:getContentSize().height*0.5))

        --)
        local downEndLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_106"),g_sFontPangWa,21)
        downEndLabel:setColor(ccc3(0x78,0x25,0x00))
        downEndLabel:setAnchorPoint(ccp(0,0.5))
        downEndLabel:setPosition(ccp(cityAttackLabel:getContentSize().width+cityAttackNumLabel:getContentSize().width+powerResultLabel:getContentSize().width,downWhiteSprite:getContentSize().height*0.5))
        downWhiteSprite:addChild(downEndLabel)
    end

    if isWin then
        -- 胜利特效
        local backAnimSprite2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli03"), -1,CCString:create(""))
        backAnimSprite2:setAnchorPoint(ccp(0.5, 0.5))
        backAnimSprite2:setPosition(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height)
        bg_sprite:addChild(backAnimSprite2,-1)
        backAnimSprite2:setVisible(false)

        local function showBg2()
            backAnimSprite2:setVisible(true)
        end

        local layerActionArray = CCArray:create()
        layerActionArray:addObject(CCDelayTime:create(0.1))
        layerActionArray:addObject(CCCallFunc:create(showBg2))
        backAnimSprite2:runAction(CCSequence:create(layerActionArray))

        backAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli02"), -1,CCString:create(""))
        backAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
        backAnimSprite:setPosition(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-10)
        bg_sprite:addChild(backAnimSprite,0)

        animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli01"), -1,CCString:create(""))
    else
        animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushibai"), -1,CCString:create(""))
    end

    animSprite:setAnchorPoint(ccp(0.5, 0.5));
    animSprite:setPosition(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-20)
    bg_sprite:addChild(animSprite)



    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    animSprite:setDelegate(delegate)

    return mainLayer
end
