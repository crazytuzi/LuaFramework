-- Filename：	MineralGrabGuard.lua
-- Author：		bzx
-- Date：		2014-05-24
-- Purpose：		抢夺协助军

module ("MineralGrabGuard", package.seeall)

require "script/libs/LuaCCSprite"
require "script/model/utils/HeroUtil"
require "script/ui/active/mineral/MineralUtil"


local _layer
local _touch_priority = -600
local _mineral

function show(mineral)
    init(mineral)
    _layer = create()
    local running_scene = CCDirector:sharedDirector():getRunningScene()
	running_scene:addChild(_layer)
end

function init(mineral)
    _mineral = mineral
end

function create()
    local layer = CCLayerColor:create(ccc4(0x00, 0x00, 0x00, 100))
    _layer = layer
    layer:registerScriptHandler(onNodeEvent)
    local dialog_info = {}
    dialog_info.title = GetLocalizeStringBy("key_8035")
    dialog_info.callbackClose = callbackClose
    dialog_info.size = CCSizeMake(485, 438)
    dialog_info.priority = _touch_priority - 1
    _dialog = LuaCCSprite.createDialog_1(dialog_info)
    layer:addChild(_dialog)
    _dialog:setAnchorPoint(ccp(0.5, 0.5))
    _dialog:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
    _dialog:setScale(g_fScaleX)
    
    local tip_label = CCLabelTTF:create(GetLocalizeStringBy("key_8036"), g_sFontPangWa, 30)
    _dialog:addChild(tip_label)
    tip_label:setColor(ccc3(0x78, 0x25, 0x00))
    tip_label:setAnchorPoint(ccp(0.5, 0.5))
    tip_label:setPosition(ccp(241, 378))
    
    local scale9 = CCScale9Sprite:create(CCRectMake(30, 30, 15, 15),"images/common/bg/bg_ng_attr.png")
    _dialog:addChild(scale9)
    scale9:setContentSize(CCSizeMake(422, 316))
    scale9:setAnchorPoint(ccp(0, 0))
    scale9:setPosition(34, 44)

    local line = CCSprite:create("images/common/line01.png")
    scale9:addChild(line)
    line:setScaleX(3.5)
    line:setPosition(scale9:getContentSize().width * 0.5, scale9:getContentSize().height * 0.5)
    line:setAnchorPoint(ccp(0.5, 0.5))
    
    local menu = CCMenu:create()
    scale9:addChild(menu)
    menu:setTouchPriority(_touch_priority - 1)
    menu:setPosition(ccp(0, 0))
    menu:setContentSize(scale9:getContentSize())
    local guards = _mineral.guards
    for i = 1, #guards do
        local guard_info = guards[i]
        -- 新增幻化id, add by lgx 20160928
        local turnedId = tonumber(guard_info.turned_id)
        local head_icon = HeroUtil.getHeroIconByHTID(guard_info.htid, guard_info.dress[1], nil, nil, turnedId)
        local head_btn = CCMenuItemSprite:create(head_icon, head_icon)
        menu:addChild(head_btn)
        head_btn:registerScriptTapHandler(callbackGrab)
        head_btn:setTag(i)
        head_btn:setAnchorPoint(ccp(0.5, 0.5))
        head_btn:setPosition(ccp(102 + (i - 1) % 2 * 224, scale9:getContentSize().height - math.floor((i-1)  / 2) * 160 - 56))
        
        local level_and_name = {}
        level_and_name[1] = CCSprite:create("images/common/lv.png")
        level_and_name[2] = CCLabelTTF:create(tostring(guard_info.level), g_sFontName, 21)
        level_and_name[2]:setColor(ccc3(0xff, 0xf6, 0x00))
        local level_and_name_node = BaseUI.createHorizontalNode(level_and_name)
        head_btn:addChild(level_and_name_node)
        level_and_name_node:setAnchorPoint(ccp(0.5, 0.5))
        level_and_name_node:setPosition(ccp(head_btn:getContentSize().width * 0.5, -10))

        
        local name_label = CCLabelTTF:create(guard_info.uname, g_sFontName, 21)
        head_btn:addChild(name_label)
        name_label:setAnchorPoint(ccp(0.5, 0.5))
        name_label:setPosition(ccp(head_btn:getContentSize().width * 0.5, -30))
    end
    
    return layer
end

function callbackGrab(tag, menu)
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    if not MineralUtil.checkGrabGuard(_mineral) then
        return
    end
    local index = tag
    guard_id = tonumber(_mineral.guards[index].uid)
    require "script/ui/active/mineral/MineralLayer"
    local args = Network.argsHandler(_mineral.domain_id, _mineral.pit_id, guard_id)
    require "script/network/RequestCenter"
    RequestCenter.mineral_robGuards(handleGrab, args)
end

function handleGrab(cbFlag, dictData, bRet)
    if dictData.err ~= "ok" then
        return
    end
    if dictData.ret.errcode == "0" then
       UserModel.addEnergyValue(-2)
        if(dictData.ret.gold and tonumber(dictData.ret.gold)>0 ) then
            UserModel.addGoldNumber(-tonumber(dictData.ret.gold))
            MineralLayer.refreshTopUI()
        end
        if dictData.ret.battleRes.appraisal ~= "E" and dictData.ret.battleRes.appraisal~="F" then
            --MineralLayer.modifyMineralList( dictData.ret.pitInfo )
        end
        
        -- require "script/battle/BattleLayer"
        -- BattleLayer.showBattleWithString(dictData.ret.fight_ret, nil, AfterBattleLayer.createAfterBattleLayer( dictData.ret.appraisal, _curMineralInfo.uid, nil, nil, false ), "shandong.jpg")	
        local amf3_obj = Base64.decodeWithZip(dictData.ret.battleRes.client)
        local lua_obj = amf3.decode(amf3_obj)
        print(GetLocalizeStringBy("key_1606"))
        print_t(lua_obj)
        local appraisal = lua_obj.appraisal
        -- 敌人uid
        local uid1 = lua_obj.team1.uid
        local uid2 = lua_obj.team2.uid
        local enemyUid = 0
        if(tonumber(uid1) ==  UserModel.getUserUid() )then
            enemyUid = tonumber(uid2)
        end
        if(tonumber(uid2) ==  UserModel.getUserUid() )then
            enemyUid = tonumber(uid1)
        end
        require "script/ui/active/mineral/AfterMineral"
        print("1232=", dictData.ret.battleRes.appraisal)
        local layer = AfterMineral.createAfterMineralLayer( dictData.ret.battleRes.server.appraisal, enemyUid, MineralLayer.callbackBattleLayerEnd, dictData.ret.battleRes.client)
        BattleLayer.showBattleWithString(dictData.ret.battleRes.client, nil, layer, "shandong.jpg")
        --
        -- CCNotificationCenter:sharedNotificationCenter():postNotification("NC_FightOver")
    end
    _layer:removeFromParentAndCleanup(true)
end

function callbackClose()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    _layer:removeFromParentAndCleanup(true)
end

function onTouchesHandler(event, x, y)
    if event == "began" then
        return true
    end
end

function onNodeEvent(event)
	if (event == "enter") then
		_layer:registerScriptTouchHandler(onTouchesHandler, false, _touch_priority, true)
		_layer:setTouchEnabled(true)
	elseif (event == "exit") then
		_layer:unregisterScriptTouchHandler()
	end
end