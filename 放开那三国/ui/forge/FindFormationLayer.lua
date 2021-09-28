-- Filename: FindFormationLayer.lua
-- Author: bzx
-- Date: 2014-06-13
-- Purpose: 寻龙探宝的阵型

module("FindFormationLayer", package.seeall)

require "script/libs/LuaCCSprite"
require "script/ui/forge/FindTreasureData"
require "script/ui/hero/HeroPublicCC"
require "script/ui/hero/HeroPublicLua"
require "script/model/hero/HeroModel"
require "script/model/user/UserModel"

local _layer
local _touch_priority   = -600      -- 本层的触摸优先级
local _z                = 20        -- 本层z轴
local _formation_info               -- 探宝的阵型
local _dialog

function show(formation_info)
    create(formation_info)
    CCDirector:sharedDirector():getRunningScene():addChild(_layer, _z)
end

function init(formation_info)
    _formation_info = formation_info
end

function create(formation_info)
    init(formation_info)
    print_t(_formation_info)
    _layer = CCLayerColor:create(ccc4(0, 0, 0, 100))
    _layer:registerScriptHandler(onNodeEvent)
    local dialog_info = {
        title = GetLocalizeStringBy("key_8099"),
        size = CCSizeMake(612, 644),
        callbackClose = closeCallback,
        priority = _touch_priority - 1,
    }
    _dialog = LuaCCSprite.createDialog_1(dialog_info)
    _layer:addChild(_dialog)
    _dialog:setAnchorPoint(ccp(0.5, 0.5))
    _dialog:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
    local menu = CCMenu:create()
    _dialog:addChild(menu)
    _dialog:setScale(MainScene.elementScale)
    menu:setPosition(ccp(0, 0))
    menu:setTouchPriority(_touch_priority - 1)
    local confirm_btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(195, 73), GetLocalizeStringBy("key_8100"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    menu:addChild(confirm_btn)
    confirm_btn:setAnchorPoint(ccp(0.5, 0.5))
    confirm_btn:setPosition(ccp(dialog_info.size.width * 0.5, 68))
    confirm_btn:registerScriptTapHandler(confirmCallback)
    createHeros()
    return _layer
end

-- 创建阵型里的英雄
function createHeros()
    --require "script/ui/formation/HeroSprite"
	for k, v in pairs(_formation_info.arrHero) do
        local hero_info = v
        local i = tonumber(hero_info.position)
        local position = ccp(122 + i % 3 * 186, 512 - math.floor(i / 3) * 266)
		local hero_bg = CCSprite:create("images/forge/hero_bg.png")
        _dialog:addChild(hero_bg)
		hero_bg:setAnchorPoint(ccp(0.5, 0.5))
		hero_bg:setPosition(position)
        local hero_sprite = createHeroSprite(hero_info)
        _dialog:addChild(hero_sprite)
        hero_sprite:setAnchorPoint(ccp(0.5, 0.5))
        hero_sprite:setPosition(ccp(position.x, position.y - 18))
        
        local name_bg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
        hero_sprite:addChild(name_bg)
        name_bg:setAnchorPoint(ccp(0.5, 0.5))
        name_bg:setPosition(ccp(hero_sprite:getContentSize().width * 0.5, 6))
        name_bg: setPreferredSize(CCSizeMake(150, 32))
        require "db/DB_Heroes"
        local hero_db = DB_Heroes.getDataById(tonumber(hero_info.htid))
        local name = nil
        if HeroModel.isNecessaryHero(tonumber(hero_info.htid)) then
            name = UserModel.getUserName()
        else
            name = hero_db.name
        end
        local name_labels = {}
        name_labels[1] = CCLabelTTF:create(name, g_sFontPangWa, 18)
        local name_color = HeroPublicLua.getCCColorByStarLevel(hero_db.star_lv)
        name_labels[1]:setColor(name_color)
        name_labels[2] = CCLabelTTF:create(" +" .. hero_info.evolve_level, g_sFontPangWa, 18)
        name_labels[2]:setColor(ccc3(0x00, 0xff, 0x18))
        local name_node = BaseUI.createHorizontalNode(name_labels)
        name_bg:addChild(name_node)
        name_node:setAnchorPoint(ccp(0.5, 0.5))
        name_node:setPosition(ccp(name_bg:getContentSize().width * 0.5, name_bg:getContentSize().height * 0.5))
        
        local hp_width_max = 94
        local hp_bg = CCSprite:create("images/battle/card/hpline_bg.png")
        hero_sprite:addChild(hp_bg)
        hp_bg:setAnchorPoint(ccp(0.5, 0.5))
        hp_bg:setPosition(ccp(hero_sprite:getContentSize().width * 0.5, 28))

        local progress = hero_info.currHp / hero_info.maxHp
        if progress > 0 then
            local hp_progress = CCSprite:create("images/battle/card/hpline.png", CCRectMake(0, 0, hp_width_max * progress, 5))
            hp_bg:addChild(hp_progress)
            hp_progress:setAnchorPoint(ccp(0, 0.5))
            hp_progress:setPosition(ccp(0, hp_bg:getContentSize().height * 0.5))
        end
	end
end

function onTouchesHandler(event)
    return true
end

function onNodeEvent(event)
    if (event == "enter") then
		_layer:registerScriptTouchHandler(onTouchesHandler, false, _touch_priority, true)
        _layer:setTouchEnabled(true)
	elseif (event == "exit") then
		_layer:unregisterScriptTouchHandler()
	end
end

function confirmCallback()
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    _layer:removeFromParentAndCleanup(true)
end

function closeCallback( ... )
    confirmCallback()
end

function createHeroSprite(hero_data)
	local heroBg = CCSprite:create()
	heroBg:setContentSize(CCSizeMake(124, 180))
	local heroBgSize = heroBg:getContentSize()
    local cardIcon = getFormationPlayerCard(hero_data)
    cardIcon:setAnchorPoint(ccp(0.5, 0.5))
    cardIcon:setPosition(ccp(heroBgSize.width/2, heroBgSize.height*0.6))
    heroBg:addChild(cardIcon)
	return heroBg
end

-- 创建单个英雄
function getFormationPlayerCard(hero_info)
    require "script/model/utils/HeroUtil"
    require "script/ui/formation/FormationUtil"
    require "script/battle/BattleCardUtil"
    require "script/battle/BattleLayer"
    local hid = tonumber(hero_info.hid)
    local htid = tonumber(hero_info.htid)
    local imageFile

    require "db/DB_Heroes"
    local hero = DB_Heroes.getDataById(htid)
    imageFile = hero.action_module_id
    local grade = hero.star_lv
    if(hid<10000000) then
        require "db/DB_Monsters"
        local monster = DB_Monsters.getDataById(hid)
        if(monster==nil) then
            monster = DB_Monsters.getDataById(1002011)
        end
        require "db/DB_Monsters_tmpl"
        local monsterTmpl = DB_Monsters_tmpl.getDataById(monster.htid)
        imageFile = monsterTmpl.action_module_id
        grade = monsterTmpl.star_lv
    end

    hero_info.turned_id = tonumber(hero_info.turned_id) or 0
    if hero_info.turned_id ~= 0 then
        imageFile = HeroTurnedData.getHeroCardImgById(hero_info.turned_id)
    end

    local CCSpriteTemp = nil
    if tonumber(hero_info.currHp) > 0 then
        CCSpriteTemp = CCSprite
    else
        CCSpriteTemp = BTGraySprite
    end
    local card = CCSpriteTemp:create("images/battle/card/card_" .. (grade) .. ".png")
    card:setAnchorPoint(ccp(0.5,0.5))
    
    local heroSprite = CCSpriteTemp:create("images/base/hero/action_module/" .. imageFile);
    heroSprite:setAnchorPoint(ccp(0.5,0))
    
    
    local changeY = BattleCardUtil.getDifferenceYByImageName(htid, imageFile,false)
    
    heroSprite:setPosition(card:getContentSize().width/2,card:getContentSize().height*0.17+changeY)
    card:addChild(heroSprite,2,1)
    
    local topSprint = CCSpriteTemp:create("images/battle/card/card_" .. (grade) .. "_top.png")
    topSprint:setAnchorPoint(ccp(0,1))
    topSprint:setPosition(0,card:getContentSize().height)
    card:addChild(topSprint,1,2)
    
    local heroBgSprite = CCSpriteTemp:create("images/battle/card/card_hero_bg.png");
    heroBgSprite:setAnchorPoint(ccp(0.5,0))
    heroBgSprite:setPosition(card:getContentSize().width/2,card:getContentSize().height*0.17)
    card:addChild(heroBgSprite,0,8)
    --]]
    
    return card
end
