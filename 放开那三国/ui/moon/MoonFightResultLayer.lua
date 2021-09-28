-- Filename：	MoonFightResultLayer.lua
-- Author：		bzx
-- Date：		2015-04-27
-- Purpose：		水月之镜战斗结算面板

module("MoonFightResultLayer", package.seeall)

require "script/utils/extern"
require "script/libs/LuaCCLabel"
btimport "script/ui/moon/STMoonFightResultLayer"

local _layer = nil
local _touchPriority = nil
local _smallCopyDb = nil
local _dropCellItemCount = 4
local _dropCellSize = nil
local _isFailure = nil
local _fightData = nil
local _gridIndex = nil
local _drop = nil
local _bossType = nil

function init(fightData, p_smallCopyId, p_gridIndex, p_bossType, p_touchPriority)
    _layer = nil
    _fightData = fightData
    _isFailure = fightData.appraise == "E" or fightData.appraise == "F"
    _smallCopyDb = DB_Treasure_smallcopy.getDataById(p_smallCopyId)
    _bossType = p_bossType
    _touchPriority = p_touchPriority or -888
    _gridIndex = p_gridIndex
end

function create(fightData, p_smallCopyId, p_gridIndex, p_bossType, p_touchPriority)
    init(fightData, p_smallCopyId, p_gridIndex, p_bossType, p_touchPriority)
    _layer = STMoonFightResultLayer:create()
    _layer:setSwallowTouch(true)
    _layer:setTouchPriority(p_touchPriority)
    _layer:setTouchEnabled(true)
    if _isFailure then 
        loadFailure()
    else
        if _gridIndex then
            loadSmallWin()
        else
            loadBossWin()
        end
    end
    return _layer
end


function loadSmallWin( ... )
    local smallWin = _layer:createSmallWin(true)
    smallWin:setScale(MainScene.elementScale)
    _layer:addChild(smallWin)
    loadUI("smallWin")
    loadProgressLabel()
end

function loadFailure( ... )
    local failure = _layer:createFailure(true)
    failure:setScale(MainScene.elementScale)
    _layer:addChild(failure)
    loadUI("failure")
    loadFailureBtn()
end

function loadBossWin( ... )
    local bossWin = _layer:createBossWin(true)
    bossWin:setScale(MainScene.elementScale)
    _layer:addChild(bossWin)
    loadUI("bossWin")
    loadDropTableView()
end

function loadUI( p_parentName )
    local bgSprite = _layer:getMemberNodeByName(p_parentName)
    if _isFailure then
        -- 战斗失败特效
        animSprite = XMLSprite:create("images/battle/xml/report/zhandoushibai")
        animSprite:setAnchorPoint(ccp(0.5, 0.5));
        animSprite:setPosition(ccpsprite(0.5, 0.95, bgSprite));
        animSprite:setReplayTimes(1, false)
        bgSprite:addChild(animSprite, 5)
        AudioUtil.playEffect("audio/effect/zhandoushibai.mp3")
    else
        -- 战斗胜利特效
        local backAnimSprite = XMLSprite:create("images/battle/xml/report/zhandoushengli02")    
        backAnimSprite:setPosition(ccs.point(0.5, bgSprite:getContentSize().height - 10, bgSprite))
        backAnimSprite:setReplayTimes(1, false)
        bgSprite:addChild(backAnimSprite,-1)
        
        local showBg2 = function()
            local backAnimSprite2 = XMLSprite:create("images/battle/xml/report/zhandoushengli03")        
            backAnimSprite2:setAnchorPoint(ccp(0.5, 0.5))
            backAnimSprite2:setPosition(ccpsprite(0.5, 0.9, bgSprite))
            bgSprite:addChild(backAnimSprite2,-2)
            -- -- 这是遇到了很奇葩的问题才加的，播放zhandoushengli03这个特效时会改变flower的位置，所以重新设置一下
            if p_parentName ~= "smallWin" then
                loadFlower(p_parentName)
            end
        end

        local layerActionArray = CCArray:create()
        layerActionArray:addObject(CCDelayTime:create(1.5))
        layerActionArray:addObject(CCCallFunc:create(showBg2))
        backAnimSprite:runAction(CCSequence:create(layerActionArray))
        
        animSprite = XMLSprite:create("images/battle/xml/report/zhandoushengli01")
        animSprite:setAnchorPoint(ccp(0.5, 0.5));
        animSprite:setPosition(ccpsprite(0.5, 0.95, bgSprite));
        animSprite:setReplayTimes(1)
        bgSprite:addChild(animSprite, 5)

        if(file_exists("audio/effect/zhandoushengli.mp3")) then
            AudioUtil.playEffect("audio/effect/zhandoushengli.mp3")
        end
    end
    -- 按钮
    loadBtn(p_parentName)
    -- 战斗力
    local fightForceLabel = _layer:getMemberNodeByName(p_parentName .. "FightForceLabel")
    fightForceLabel:setString(tostring(UserModel.getFightForceValue()))
    local forceTitleSprite = _layer:getMemberNodeByName(p_parentName .. "ForceTitleSprite")
    local forceLayer = _layer:getMemberNodeByName(p_parentName .. "ForceLayer")
    forceLayer:setWidth(forceTitleSprite:getContentSize().width + fightForceLabel:getContentSize().width)

    local strongholdDb = nil
    if _gridIndex then
        local gridDbs = parseField(_smallCopyDb.copy_nine, 2)
        local gridDb = gridDbs[_gridIndex]
        strongholdDb = DB_Stronghold.getDataById(gridDb[2])
    else
        strongholdDb = DB_Stronghold.getDataById(_smallCopyDb.boss_id)
    end

    --名字
    local nameLabel = _layer:getMemberNodeByName(p_parentName .. "NameLabel")
    nameLabel:setString(strongholdDb.name)
    nameLabel:setColor(MoonLayer.getSmallCopyNameColor(strongholdDb.strongholdLevel))
    -- 星
    local starLayer = _layer:getMemberNodeByName(p_parentName .. "StarLayer")
    local starCount = strongholdDb.strongholdLevel
    local starLayerWidth = (starCount - 1) * 40
    for i = 1, starCount do
        local star = _layer:createStar()
        starLayer:addChild(star)
        star:setPositionX((i - 1) * 40)
        if i == starCount then
            starLayerWidth = starLayerWidth + star:getContentSize().width
        end
    end
    starLayer:setWidth(starLayerWidth)

    if p_parentName ~= "smallWin" then
        loadFlower(p_parentName)
    end
end

function loadBtn(parentName)
    -- 分享
    local shareBtn = _layer:getMemberNodeByName(parentName .. "ShareBtn")
    if shareBtn ~= nil then
        shareBtn:setTouchPriority(_touchPriority - 1)
        shareBtn:setClickCallback(shareCallback)
    end
    -- 确定
    local confirmBtn = _layer:getMemberNodeByName(parentName .. "ConfirmBtn")
    confirmBtn:setTouchPriority(_touchPriority - 1)
    confirmBtn:setClickCallback(confirmCallback)
end

-- 探索度
function loadProgressLabel( ... )
    local progressLabel = _layer:getMemberNodeByName("progressLabel")
    local moonInfo = MoonData.getMoonInfo()
    local maxPassCopy = tonumber(moonInfo.max_pass_copy)
    local curSmallCopyId = maxPassCopy + 1
    local treasureSmallcopyDb = DB_Treasure_smallcopy.getDataById(curSmallCopyId)
    local gridDbs = parseField(treasureSmallcopyDb.copy_nine, 2)
    local gridCount = #gridDbs
    local progress = 0
    for gridIndex, gridStatus in pairs(moonInfo.grid) do
        if gridStatus == MoonData.GridStatus.PASSED then
            progress = progress + 1
        end
    end
    progressLabel:setString(string.format(GetLocalizeStringBy("key_10217"), progress, gridCount))
end

-- 确定回调
function confirmCallback( ... )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    closeLayer()
end

-- 分享回调
function shareCallback( ... )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/utils/BaseUI"
    local shareImagePath = BaseUI.getScreenshots()
    require "script/ui/share/ShareLayer"
    ShareLayer.show(nil, shareImagePath, 9999, _touchPriority - 50, shareCallBack)
end

function closeLayer( ... )
    require "script/battle/BattleLayer"
    BattleLayer.closeLayer()
end

-- 掉落物品展示
function loadDropTableView( ... )
    _drop = {}
    if _fightData.drop ~= nil then
        for k, v in pairs(_fightData.drop) do
            local itemType = 7
            local itemId = tonumber(k)
            local itemNum = tonumber(v)
            local itemsData = ItemUtil.getItemsDataByStr(string.format("%d|%d|%d", itemType, itemId, itemNum))
            table.insert(_drop, itemsData[1])
        end
    end
    local itemsData = nil
    if _bossType == MoonData.kNormal then
        itemsData = ItemUtil.getItemsDataByStr(_smallCopyDb.reward)
    else
        itemsData = ItemUtil.getItemsDataByStr(_smallCopyDb.reward2)
    end
    for i = 1, #itemsData do
        table.insert(_drop, itemsData[i])
    end
    local bossWinTableView = _layer:getMemberNodeByName("bossWinTableView")
    local cell = _layer:getMemberNodeByName("copyCell")
    _dropCellSize = CCSizeMake(bossWinTableView:getContentSize().width / _dropCellItemCount, 135)
    local eventHandler = function ( functionName, tableView, index, cell )
        if functionName == "cellSize" then
            return _dropCellSize
        elseif functionName == "cellAtIndex" then
            return createDropCell(index)
        elseif functionName == "numberOfCells" then
            return math.ceil(#_drop / 4)
        end
    end
    bossWinTableView:setEventHandler(eventHandler)
    bossWinTableView:setTouchPriority(_touchPriority - 10)
    bossWinTableView:reloadData()
end

-- 掉落物品列表cell
function createDropCell( index )
    local cell = STTableViewCell:create()
    cell:setContentSize(_dropCellSize)
    local startIndex = (index - 1) * 4 + 1
    local endIndex = startIndex + 3
    if endIndex > #_drop then
        endIndex = #_drop
    end
    for i = startIndex, endIndex do
        local itemData = _drop[i]
        local icon, itemName, itemColor = ItemUtil.createGoodsIcon(itemData, _touchPriority - 1, 9999, _touchPriority - 50, nil,nil,nil,false)
        cell:addChild(icon)
        icon:setAnchorPoint(ccp(0, 0.5))
        icon:setPosition(ccs.point(20 + (icon:getContentSize().width + 21)* math.floor((i - 1) % _dropCellItemCount), 0.51, cell))

        local itemNameLabel = CCRenderLabel:create(itemName, g_sFontName, 18, 1, ccc3( 0x10, 0x10, 0x10), type_stroke)
        itemNameLabel:setColor(itemColor)
        itemNameLabel:setAnchorPoint(ccp(0.5,0.5))
        itemNameLabel:setPosition(icon:getContentSize().width*0.5,-icon:getContentSize().height*0.15)
        icon:addChild(itemNameLabel)
    end
    return cell
end

-- 面板上的花
function loadFlower( p_parentName )
    local nameLabel = _layer:getMemberNodeByName(p_parentName .. "NameLabel")
    local leftFlowerSprite = _layer:getMemberNodeByName(p_parentName .. "LeftFlowerSprite")
    leftFlowerSprite:setPositionX(nameLabel:getPositionX() - nameLabel:getContentSize().width * 0.5 - 10)
    local rightFlowerSprite = _layer:getMemberNodeByName(p_parentName .. "RightFlowerSprite")    
    rightFlowerSprite:setPositionX(nameLabel:getPositionX() + nameLabel:getContentSize().width * 0.5 + 10)
end

function loadFailureBtn( ... )
    -- 武将强化
    local strengthenHeroBtn = _layer:getMemberNodeByName("strengthenHeroBtn")
    strengthenHeroBtn:setTouchPriority(_touchPriority - 1)
    strengthenHeroBtn:setClickCallback(strengthenHeroCallback)

    -- 调整阵容
    local formationBtn = _layer:getMemberNodeByName("formationBtn")
    formationBtn:setTouchPriority(_touchPriority - 1)
    formationBtn:setClickCallback(formationCallback)

    -- 装备强化
    local strengthenEquipBtn = _layer:getMemberNodeByName("strengthenEquipBtn")
    strengthenEquipBtn:setTouchPriority(_touchPriority - 1)
    strengthenEquipBtn:setClickCallback(strengthenEquipCallback)

    -- 培养名将
    local trainStarBtn = _layer:getMemberNodeByName("trainStarBtn")
    trainStarBtn:setTouchPriority(_touchPriority - 1)
    trainStarBtn:setClickCallback(trainStarCallback)

    -- 喂养宠物
    local feedPetBtn = _layer:getMemberNodeByName("feedPetBtn")
    feedPetBtn:setTouchPriority(_touchPriority - 1)
    feedPetBtn:setClickCallback(feedPetCallback)

    -- 战魂升级
    local fightSoulBtn = _layer:getMemberNodeByName("fightSoulBtn")
    fightSoulBtn:setTouchPriority(_touchPriority - 1)
    fightSoulBtn:setClickCallback(fightSoulCallback)
end

-- 武将强化回调
function strengthenHeroCallback()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2409"))
    -- 先关闭战斗场景
    closeLayer()
    if not DataCache.getSwitchNodeState(ksSwitchGeneralForge) then
        return
    end
    require "script/ui/hero/HeroLayer"
    MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
    AudioUtil.playBgm("audio/main.mp3")
end

-- 装备强化回调
function strengthenEquipCallback()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_1244"))
    -- 先关闭战斗场景
    closeLayer()
    if not DataCache.getSwitchNodeState(ksSwitchWeaponForge) then
        return
    end
    require "script/ui/bag/BagLayer"
    local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Arming)
    MainScene.changeLayer(bagLayer, "bagLayer")
    AudioUtil.playBgm("audio/main.mp3")
end

-- 培养名将回调
function trainStarCallback()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2827"))
    -- 先关闭战斗场景
    closeLayer()
    if not DataCache.getSwitchNodeState(ksSwitchGreatSoldier) then
        return
    end
    require "script/ui/star/StarLayer"
    local starLayer = StarLayer.createLayer()
    MainScene.changeLayer(starLayer, "starLayer")
    AudioUtil.playBgm("audio/main.mp3")
end

-- 喂养宠物回调
function feedPetCallback()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2236"))
    -- 先关闭战斗场景
    closeLayer()
    if not DataCache.getSwitchNodeState(ksSwitchPet) then
        return
    end
    require "script/ui/pet/PetMainLayer"
    local layer= PetMainLayer.createLayer()
    MainScene.changeLayer(layer, "PetMainLayer")
end

-- 跳到阵容的回调函数 
function formationCallback(  )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2236"))
    -- 先关闭战斗场景
    closeLayer()
    require("script/ui/formation/FormationLayer")
    local formationLayer = FormationLayer.createLayer()
    MainScene.changeLayer(formationLayer, "formationLayer")

end

-- 猎魂的回调函数 
function fightSoulCallback( )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    -- 先关闭战斗场景
    closeLayer()
    if not DataCache.getSwitchNodeState(ksSwitchBattleSoul) then
        return
    end
    require "script/ui/huntSoul/HuntSoulLayer"
    local layer = HuntSoulLayer.createHuntSoulLayer()
    MainScene.changeLayer(layer, "huntSoulLayer")
end

