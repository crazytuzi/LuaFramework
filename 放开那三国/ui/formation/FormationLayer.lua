-- Filename：	NewFormationLayer.lua
-- Author：		bzx
-- Date：		2015-06-25
-- Purpose：		阵容

module ("FormationLayer", package.seeall)

btimport "script/ui/formation/STFormationLayer"
btimport "script/ui/formation/ChangeFormationLayer"
btimport "script/ui/formation/FormationUtil"
btimport "db/DB_Heroes"
btimport "script/ui/develop/DevelopData"
btimport "script/ui/formation/LittleFriendLayer"
btimport "script/ui/formation/secondfriend/SecondFriendLayer"
btimport "script/ui/formation/HeroSprite"


isNew = true

local OptionType = {
    HERO 			= 1,	-- 武将
    LITTLE_FRIEND 	= 2,	-- 小伙伴
    HELPER 			= 3,	-- 助战军
}

local ItemType = {
    EQUIP 		= 1, 		-- 装备
    FIGHTSOUL 	= 2,		-- 战魂
    GODWEAPON 	= 3, 		-- 神兵
}

local ARM_TYPE_WEAPON	= 1	-- 武器
local ARM_TYPE_ARMOR	= 2	-- 盔甲
local ARM_TYPE_HAT		= 3	-- 头盔
local ARM_TYPE_NECKLACE	= 4	-- 项链

local TREAS_TYPE_HORSE	= 1
local TREAS_TYPE_BOOK 	= 2
local equipPositions = { ARM_TYPE_HAT, ARM_TYPE_WEAPON, ARM_TYPE_NECKLACE, ARM_TYPE_ARMOR, TREAS_TYPE_BOOK, TREAS_TYPE_HORSE}



local God_TYPE_1 					= 1   -- 神兵1
local God_TYPE_2 					= 2   -- 神兵2
local God_TYPE_3 					= 3   -- 神兵3
local God_TYPE_4 					= 4   -- 神兵4
local God_TYPE_5					= 5	  -- 神兵5
local godWeaponPositions = { God_TYPE_1, God_TYPE_2, God_TYPE_3, God_TYPE_4, God_TYPE_5}

local _layer
local _touchPriority = -303
local _changeFormationLayer = nil
local _optionsInfo = {}						-- 上面选项的数据
local _centersInfo = {}						-- 中间cell的数据
local _formationInfo = {}					-- 阵容数据
local _optionTableView = nil 				-- 上面的tableView
local _topCellSize = CCSizeMake(105, 100)
local _topCellLight = nil 					-- 光圈
local _centerTableView = nil  				-- 中间的tableView
local _centerCellSize = nil   				-- 中间的Cellsize
local _curHeroInfo = nil 					-- 当前在页的武将信息
local _centerHeight = nil 					-- 中间部分的高度
local _curCenterLayer = nil   				-- 中间的Layer
local _curOptionIndex = 1 				 	-- 上面选项的index，默认为1
local _curItemType = ItemType.EQUIP 		-- 当前显示的类型，装备，战魂，神兵   默认为装备
local _lastHeroInfo = nil         			-- 上面tableView最后一个武将的数据
-- 战魂位置
local _fightSoulPosTable = { {1,3,5,7,9} , {2,4,6,8,10} }
local _isNeedDisplayAnimation = true
local _lockedOptionInfo = nil

local _bottomCellPosition = nil
local _bottomPosition = nil
local _bottomCurPosition = nil

local _leftFightSoulTableView = nil       	-- 左边战魂
local _rightFightSoulTableView = nil       	-- 右边战魂

local formationLayerDidLoadCallback = {}
local fromationLayerTouchHeroCallback = nil
local swapHeroCallback = nil
local _oldSuitInfo 					= nil       -- 一键装备前套装激活信息

local _extendSubLayer = nil
local _extendSubLayerBg = nil
local _extendSubLayerMenu = nil
local _extendSubLayerIsShow = false
local _extendMenu = nil
-- 新手引导相关
-- 马
local _horseBtn = nil
-- 武器
local _weaponBtn = nil

local _showSecondFriendPos = 1

function createLayer( p_displayHid, isAnimate, isShowLittleFriend, isDefaultLastIndex, formationType, isShowChangeFormation, p_isShowSecondFriend,p_showSecondFriendPos )
    -- 初始化羁绊信息
    -- 在这里是为了从新手引导第一次进入阵容
    -- added by Zhang Zihang
    require "script/model/utils/UnionProfitUtil"
    if table.isEmpty(UnionProfitUtil.getUnionProfitInfo()) then
        UnionProfitUtil.setUnionProfitInfo()
    end
    _showSecondFriendPos = p_showSecondFriendPos
    _curItemType = formationType or ItemType.EQUIP
    if isAnimate == nil then
        _isNeedDisplayAnimation = false
    end
    init()
    _layer = STFormationLayer:create()
    _layer:setVisible(false)
    checkInfoAndCreate()
    return _layer
end

function create( ... )
    _layer:setVisible(true)
    initOptionAndCenterInfo()
    initCurOptionIndex(p_displayHid, isShowLittleFriend, isDefaultLastIndex, isShowChangeFormation, p_isShowSecondFriend)
    adaptive()
    MainScene.setMainSceneViewsVisible(true, false, true)
    initCenterHeight()
    loadButton()
    loadCenterTableView()
    initBottomPosition()
    loadOptionTableView()
    sendLoadEndEvent()
    addLittleNewPosTip()
    --add by lichenyang  -- add new Guide
    local newGuideAction = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(addNewGuide))
    _layer:runAction(newGuideAction)
end

function init( ... )
    _developupBtn = nil
    _pocketBtn = nil
    _tallyBtn = nil
    _destinyBtn = nil
    _extendSubLayerIsShow = false
end

function sendLoadEndEvent( ... )
    local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
        if(formationLayerDidLoadCallback ~= nil) then
            for k,v in pairs(formationLayerDidLoadCallback) do
                v()
            end
        end
    end))
    _layer:runAction(seq)
end

function getOptionIndexByOptionType( p_optionType )
    for i = 1, #_optionsInfo do
        local optionInfo = _optionsInfo[i]
        if optionInfo.optionType == p_optionType then
            return optionInfo.optionIndex
        end
    end
    return 1
end

function getOptionIndexByHid( p_hid )
    for i = 1, #_optionsInfo do
        local optionInfo = _optionsInfo[i]
        if optionInfo.optionType == OptionType.HERO and not optionInfo.isLocked then
            local hid = tonumber(_formationInfo[tostring(optionInfo.optionIndex - 1)])
            if hid == tonumber(p_hid) then
                return optionInfo.optionIndex
            end
        else
            break
        end
    end
    return 1
end

function initCurOptionIndex(p_displayHid, isShowLittleFriend, isDefaultLastIndex, isShowChangeFormation, p_isShowSecondFriend)
    if(isShowLittleFriend == true) then
        _curOptionIndex = getOptionIndexByOptionType(OptionType.LITTLE_FRIEND)
    elseif(p_isShowSecondFriend == true)then
        _curOptionIndex = getOptionIndexByOptionType(OptionType.HELPER)
    else
        if(p_displayHid and tonumber(p_displayHid) > 0)then
            _curOptionIndex = getOptionIndexByHid(p_displayHid)
        end
    end
    _curOptionIndex = _curOptionIndex or 1
end

function loadButton( ... )
    -- 布阵 or 阵法
    local changeFormationBtn = _layer:getMemberNodeByName("changeFormationBtn")
    changeFormationBtn:setTouchPriority(_touchPriority - 30)
    changeFormationBtn:setClickCallback(changeFormationCallback)
    local changeWarcraftBtn = _layer:getMemberNodeByName("changeWarcraftBtn")
    changeWarcraftBtn:setClickCallback(changeWarcraftCallback)
    changeWarcraftBtn:setTouchPriority(_touchPriority - 30)
    -- 阵法功能节点开启
    if DataCache.getSwitchNodeState(ksSwitchWarcraft, false) then
        changeFormationBtn:removeFromParent()
    else
        changeWarcraftBtn:removeFromParent()
    end
end

-- 上面的tableView
function loadOptionTableView( ... )
    _optionTableView = _layer:getMemberNodeByName("optionTableView")
    local eventHandler = function ( functionName, tableView, index, cell )
        if functionName == "cellSize" then
            return _topCellSize
        elseif functionName == "cellAtIndex" then
            return createTopCell(index)
        elseif functionName == "numberOfCells" then
            return #_optionsInfo
        elseif functionName == "cellTouched" then
            _optionTableView:setTouchEnabled(true)
            optionCellClickCallback(index, cell)

            if(_formationInfo[tostring(index)] == 0) then
                -- 添加武将
                ---------------------新手引导---------------------------------
                --add by lichenyang 2013.08.29
                require "script/guide/FormationGuide"
                require "script/guide/NewGuide"
                if(NewGuide.guideClass ==  ksGuideFormation and FormationGuide.stepNum == 2) then
                    FormationGuide.changLayer()
                    local touchRect = CCRectMake(g_winSize.width * 0.5 - 120 * getScaleParm(), g_winSize.height * 0.5 - 180 * getScaleParm(), 240 * getScaleParm(), 450 * getScaleParm() )
                    FormationGuide.show(3, touchRect)
                end
                ---------------------end-------------------------------------

                ---[==[ 等级礼包第11步
                ---------------------新手引导---------------------------------
                --add by licong 2013.09.09
                require "script/guide/NewGuide"
                require "script/guide/LevelGiftBagGuide"
                if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 10) then
                    LevelGiftBagGuide.changLayer()
                    local touchRect = CCRectMake(g_winSize.width * 0.5 - 120 * getScaleParm(), g_winSize.height * 0.5 - 180 * getScaleParm(), 240 * getScaleParm(), 450 * getScaleParm() )
                    LevelGiftBagGuide.show(11, touchRect)
                end
                ---------------------end-------------------------------------
                --]==]
                ---[==[ 第4个上阵栏位开启 第3步
                ---------------------新手引导---------------------------------
                --add by licong 2013.09.09
                require "script/ui/level_reward/LevelRewardLayer"
                require "script/guide/NewGuide"
                require "script/guide/ForthFormationGuide"
                if(NewGuide.guideClass ==  ksGuideForthFormation and ForthFormationGuide.stepNum == 2) then
                    ForthFormationGuide.changLayer()
                    ForthFormationGuide.show(3, nil)
                end
                ---------------------end-------------------------------------
                --]==]
            end
            if(swapHeroCallback ~= nil)then
                swapHeroCallback()
            end
        end
    end
    _optionTableView:setEventHandler(eventHandler)
    _optionTableView:setTouchPriority(_touchPriority - 30)
    _optionTableView:reloadData()
    refreshOptionTableViewLight()
    updateCenterByOptionIndex(_curOptionIndex)
    if (BTUtil:getGuideState() == true) then
        _optionTableView:setTouchEnabled(false)
    end
end

-- 根据上面的index刷新中间的tableView
function updateCenterByOptionIndex( index )
    local optionInfo = _optionsInfo[index]
    local bottomBg = _layer:getMemberNodeByName("bottomBg")
    bottomBg:setVisible(true)
    _centerTableView:setVisible(true)
    if optionInfo.optionType == OptionType.HELPER then
        local centerLayer = _layer:getMemberNodeByName("centerLayer")
        if not tolua.isnull(_curCenterLayer) then
            _curCenterLayer:removeFromParentAndCleanup(true)
        end
        _centerTableView:setVisible(false)
        bottomBg:setVisible(false)
        local secondLayer = SecondFriendLayer.createSecondFriendLayer(g_winSize.width, _centerHeight, p_hid, _showSecondFriendPos)

        -- local maskLayer = CCLayerColor:create(ccc4(200, 0, 0, 100), centerLayer:getContentSize().width, centerLayer:getContentSize().height)
        -- secondLayer:addChild(maskLayer)
        centerLayer:addChild(secondLayer)
        secondLayer:ignoreAnchorPointForPosition(false)
        secondLayer:setAnchorPoint(ccp(0.5, 0.5))
        secondLayer:setPosition(ccpsprite(0.5, 0.5, centerLayer))
        refreshHeroButton()
        _curCenterLayer = secondLayer
    else
        if not tolua.isnull(_curCenterLayer) then
            _curCenterLayer:removeFromParentAndCleanup(true)
        end
        if not tolua.isnull(_centerTableView) then
            _centerTableView:setVisible(true)
        end
        checkAndChangeBottomBgParent()
        if not tolua.isnull(_centerTableView) then
            if _isNeedDisplayAnimation then
                _centerTableView:showCellByIndexInDuration(optionInfo.centerIndex, 0.1)
            else
                local offset = ccp(-_centerCellSize.width * (optionInfo.centerIndex - 1), 0)
                _centerTableView:setContentOffset(offset)
            end
            refreshHeroInfo()
        end
    end
end

-- 上面的tableViewCell点击回调
function optionCellClickCallback(index, cell )
    local optionInfo = _optionsInfo[index]
    if optionInfo.isLocked then
        -- 尚未解锁
        local nextLevel = FormationUtil.nextOpendFormationNumAndLevel()
        AnimationTip.showTip( nextLevel .. GetLocalizeStringBy("key_1526"))
        return
    end
    if optionInfo.optionType == OptionType.HELPER then
        if not DataCache.getSwitchNodeState(ksSecondFriend) then
            return
        end
    end
    _curOptionIndex = index
    updateCenterByOptionIndex(index)
    if cell ~= nil then
        lightCell(cell)
    end
end

-- 点亮某个Cell
function lightCell( cell )
    if not tolua.isnull(_topCellLight) then
        _topCellLight:retain()
        _topCellLight:removeFromParentAndCleanup(false)
        _topCellLight:autorelease()
    else
        _topCellLight = CCSprite:create("images/formation/potential/highlight.png")
    end
    cell.bgSprite:addChild(_topCellLight)
    _topCellLight:setAnchorPoint(ccp(0.5, 0.5))
    _topCellLight:setPosition(ccpsprite(0.5, 0.5, cell.bgSprite))
end

-- 显示装备
function showEquip( ... )
    local itemLayer = _layer:getMemberNodeByName("itemLayer")
    local equipMenuBar = CCMenu:create()
    equipMenuBar:setContentSize(CCSizeMake(640, 100))
    itemLayer:addChild(equipMenuBar)
    equipMenuBar:ignoreAnchorPointForPosition(false)
    equipMenuBar:setAnchorPoint(ccp(0.5, 0))
    equipMenuBar:setPosition(ccp(320, -200))
    equipMenuBar:setTouchPriority(_touchPriority - 20)
    equipMenuBar:setScale(1 / g_fScaleX * MainScene.elementScale)
    -- 顺序
    local btnXPositions = {0.15, 0.85, 0.15, 0.85, 0.15, 0.85}
    local btnYPositions = {0.7, 0.7, 0.53, 0.53, 0.35, 0.35}
    local emptyEquipIcons = {
        "images/formation/emptyequip/helmet.png",   "images/formation/emptyequip/weapon.png",
        "images/formation/emptyequip/necklace.png",	"images/formation/emptyequip/armor.png",
        "images/formation/emptyequip/book.png",		"images/formation/emptyequip/horse.png",
    }
    local heroInfo = _curHeroInfo
    local hid = nil
    local arming = nil
    local treas_infos = nil
    if heroInfo ~= nil then
        arming = heroInfo.equip.arming
        treas_infos = heroInfo.equip.treasure
        hid = tonumber(heroInfo.hid)
    end

    for btnIndex, xScale in pairs(btnXPositions) do
        local borderFileName = "images/common/equipborder.png"
        if(btnIndex >=5)then
            borderFileName = "images/common/t_equipborder.png"
        end
        local equipBorderSp = CCSprite:create(borderFileName)
        equipBorderSp:setAnchorPoint(ccp(0.5,0.5))

        local equipBtn = nil
        local redTipSprite = nil
        if( btnIndex < 5)then
            -- 装备
            if(table.isEmpty(arming) == false)then
                local equipInfo = arming[tostring(equipPositions[btnIndex])]
                if( table.isEmpty(equipInfo) == false and  tonumber(equipInfo.item_template_id) > 0) then
                    local equipSprite = ItemSprite.getItemSpriteById(tonumber(equipInfo.item_template_id), tonumber(equipInfo.item_id), FormationLayer.equipInfoDelegeate, true, _touchPriority - 20,nil,-550)
                    equipBtn = LuaMenuItem.createItemSprite(equipSprite, equipSprite)
                    -- 名称
                    local eQuality = ItemUtil.getEquipQualityByItemInfo( equipInfo )
                    local equipDesc = ItemUtil.getItemById(tonumber(equipInfo.item_template_id))
                    local e_nameLabel = ItemUtil.getEquipNameByItemInfo(equipInfo,g_sFontName,20)
                    e_nameLabel:setAnchorPoint(ccp(0,1))
                    e_nameLabel:setPosition(ccp( (equipBtn:getContentSize().width-e_nameLabel:getContentSize().width)/2, -equipBtn:getContentSize().height*0.1))
                    equipBtn:addChild(e_nameLabel)
                    -- 强化等级
                    local lvSprite = CCSprite:create("images/base/potential/lv_" .. eQuality .. ".png")
                    lvSprite:setAnchorPoint(ccp(0,1))
                    lvSprite:setPosition(ccp(-1, equipBtn:getContentSize().height))
                    equipBtn:addChild(lvSprite)
                    local lvLabel =  CCRenderLabel:create(equipInfo.va_item_text.armReinforceLevel , g_sFontName, 18, 1, ccc3( 0, 0, 0), type_stroke)
                    lvLabel:setColor(ccc3(255,255,255))
                    lvLabel:setAnchorPoint(ccp(0.5,0.5))
                    lvLabel:setPosition(ccp( lvSprite:getContentSize().width*0.5, lvSprite:getContentSize().height*0.5))
                    lvSprite:addChild(lvLabel)

                    if( HeroModel.isNecessaryHeroByHid(hid) == false and ItemUtil.hasBetterEquipBy( equipPositions[btnIndex], equipDesc.base_score ) == true )then
                        require "script/libs/LuaCCSprite"
                        redTipSprite = LuaCCSprite.createTipSpriteWithNum(0)
                    end
                else
                    -- 是否有更好的装备
                    if( HeroModel.isNecessaryHeroByHid(hid) == false and ItemUtil.hasBetterEquipBy( equipPositions[btnIndex], 0 ) )then
                        require "script/libs/LuaCCSprite"
                        redTipSprite = LuaCCSprite.createTipSpriteWithNum(0)
                    end
                end
                -- 新手引导用
                if(btnIndex == 2)then
                    _weaponBtn = equipBtn
                end
            end
        else
            -- 宝物
            if(table.isEmpty(treas_infos) == false)then
                local treasInfo = treas_infos["" .. equipPositions[btnIndex]]
                if( table.isEmpty(treasInfo) == false and  tonumber(treasInfo.item_template_id) > 0) then
                    local equipSprite = ItemSprite.getItemSpriteById(tonumber(treasInfo.item_template_id), tonumber(treasInfo.item_id), FormationLayer.equipInfoDelegeate, true, _touchPriority - 20,nil,-550)
                    equipBtn = LuaMenuItem.createItemSprite(equipSprite, equipSprite)

                    -- 名称
                    local equipDesc = ItemUtil.getItemById(tonumber(treasInfo.item_template_id))
                    local quality = ItemUtil.getTreasureQualityByItemInfo( treasInfo )
                    local e_nameLabel = ItemUtil.getTreasureNameByItemInfo( treasInfo, g_sFontName, 20 )
                    e_nameLabel:setAnchorPoint(ccp(0,1))
                    e_nameLabel:setPosition(ccp( (equipBtn:getContentSize().width-e_nameLabel:getContentSize().width)/2, -equipBtn:getContentSize().height*0.1))
                    equipBtn:addChild(e_nameLabel)
                    -- 强化等级
                    local lvSprite = CCSprite:create("images/base/potential/lv_" .. quality .. ".png")
                    lvSprite:setAnchorPoint(ccp(0,1))
                    lvSprite:setPosition(ccp(-1, equipBtn:getContentSize().height))
                    equipBtn:addChild(lvSprite)
                    local lvLabel =  CCRenderLabel:create(treasInfo.va_item_text.treasureLevel, g_sFontName, 18, 1, ccc3( 0, 0, 0), type_stroke)
                    lvLabel:setColor(ccc3(255,255,255))
                    lvLabel:setAnchorPoint(ccp(0.5,0.5))
                    lvLabel:setPosition(ccp( lvSprite:getContentSize().width*0.5, lvSprite:getContentSize().height*0.5))
                    lvSprite:addChild(lvLabel)
                end
            end
        end
        if(equipBtn == nil)then
            equipBtn = LuaMenuItem.createItemImage(emptyEquipIcons[btnIndex],  emptyEquipIcons[btnIndex])
            equipBtn:registerScriptTapHandler(changeEquipAction)
        end

        if(btnIndex == 6)then
            _horseBtn = equipBtn
        end

        -- equipBorderSp:setPosition(ccp(bgLayer:getContentSize().width*xScale,bgLayer:getContentSize().height*btnYPositions[btnIndex]))
        equipBorderSp:setPosition(ccp(equipBtn:getContentSize().width*0.5,equipBtn:getContentSize().height*0.5))
        equipBtn:addChild(equipBorderSp, -1)
        if math.mod(btnIndex, 2) == 0 then
            equipBtn:setAnchorPoint(ccp(0.18, 0.5))
        else
            equipBtn:setAnchorPoint(ccp(0.82, 0.5))
        end
        equipBtn:setPosition(ccp(640 * xScale, (_centerHeight / MainScene.elementScale+ 145) * btnYPositions[btnIndex] + 25))
        -- 加红圈提示
        if( redTipSprite )then
            redTipSprite:setAnchorPoint(ccp(0.5, 0.5))
            redTipSprite:setPosition(ccp(equipBtn:getContentSize().width, equipBtn:getContentSize().height))
            equipBtn:addChild(redTipSprite)
        end
        equipMenuBar:addChild(equipBtn, btnYPositions[btnIndex] * 10, 20000 + btnIndex)
    end
end

--[[
	@desc	6个换装备按钮 的Action
	@para 	
	@return void
--]]
function changeEquipAction(tag, menuItem )
    local heroInfo = _curHeroInfo
    if heroInfo ~= nil then
        local hid = tonumber(heroInfo.hid)
        if tag - 20000 >= 5 then
            require "script/ui/formation/ChangeEquipLayer"
            local changeEquipLayer = ChangeEquipLayer.createLayer( changeEquipCallback, hid, equipPositions[tag - 20000], true)
            require "script/ui/main/MainScene"
            MainScene.changeLayer(changeEquipLayer, "changeEquipLayer")
        else
            if isPushBox(equipPositions[tag-20000]) then
                require "script/ui/formation/ChangeEquipLayer"
                local changeEquipLayer = ChangeEquipLayer.createLayer( changeEquipCallback, hid, equipPositions[tag - 20000])
                require "script/ui/main/MainScene"
                MainScene.changeLayer(changeEquipLayer, "changeEquipLayer")
            end
        end
    end
end

--判断是否弹出没有物品的提示
--物品方面
--武器 1 护甲 2 头盔 3 项链 4
function isPushBox(posId)
    local isPush = false
    local bagInfo = DataCache.getBagInfo()
    for k, itemInfo in pairs(bagInfo.arm) do
        if(tonumber(itemInfo.itemDesc.type) == posId) then
            isPush = true
            break
        end
    end
    require "script/ui/tip/AnimationTip"
    if isPush == false then
        if posId == 1 then
            AnimationTip.showTip(GetLocalizeStringBy("key_2237"))
        elseif posId == 2 then
            AnimationTip.showTip(GetLocalizeStringBy("key_1998"))
        elseif posId == 3 then
            AnimationTip.showTip(GetLocalizeStringBy("key_1695"))
        elseif posId == 4 then
            AnimationTip.showTip(GetLocalizeStringBy("key_2089"))
        end
    end
    return isPush
end

--[[
	@desc	换完装备的回调
	@para 	hid 	 将领ID
			equipPos 装备位置
			itemId   itemId
			o_hid    是否是另一个将领的身上的装备
	@return void
--]]
function changeEquipCallback( hid, equipPos, itemId, o_hid )
-- refreshEquipMenu()
-- refreshBottomInfo()
end

-- 刷新中装备，神兵，战魂的显示
function refreshItemLayer( )
    local itemLayer = _layer:getMemberNodeByName("itemLayer")
    itemLayer:removeAllChildren()
    if _curItemType == ItemType.EQUIP then
        showEquip()
    elseif _curItemType == ItemType.FIGHTSOUL then
        showFightSoul()
    elseif _curItemType == ItemType.GODWEAPON then
        showGodWeapon()
    end
end

-- 显示神兵
function showGodWeapon( ... )
    local itemLayer = _layer:getMemberNodeByName("itemLayer")
    --按钮Bar
    local godWeaponMenu = CCMenu:create()
    godWeaponMenu:setPosition(ccp(0, -200))
    godWeaponMenu:setTouchPriority(_touchPriority - 30)
    itemLayer:addChild(godWeaponMenu)

    -- 顺序
    -- local btnXPositions = {0.15, 0.85, 0.15, 0.85}
    -- local btnYPositions = {0.64, 0.64, 0.35, 0.35}
    local btnXPositions = {0.84, 0.15, 0.15, 0.84, 0.15}
    local btnYPositions = {0.62, 0.71, 0.53, 0.445, 0.36}
    local heroInfo = _curHeroInfo

    local godWeaponData = nil
    if heroInfo ~= nil then
        godWeaponData = heroInfo.equip.godWeapon
    end

    for btnIndex,xScale in pairs(btnXPositions) do
        -- 装备底框
        local equipBorderSp = CCSprite:create("images/common/equipborder.png")
        equipBorderSp:setAnchorPoint(ccp(0.5,0.5))
        -- 印章 神兵类型 金木水火土
        local sealSprite = CCSprite:create("images/god_weapon/godtype/" .. btnIndex .. ".png" )
        --如果btnIndex为偶数，图标在右边
        if(btnIndex == 1 or btnIndex == 4)then
            sealSprite:setAnchorPoint(ccp(1, 0.5))
            sealSprite:setPosition(ccp(154, equipBorderSp:getContentSize().height*0.5))
        else
            sealSprite:setAnchorPoint(ccp(0, 0.5))
            sealSprite:setPosition(ccp(-50, equipBorderSp:getContentSize().height*0.5))
        end
        
        equipBorderSp:addChild(sealSprite)
        local equipBtn = nil
        local redTipSprite = nil
        -- 神兵
        if(table.isEmpty(godWeaponData) == false)then
            local hid = tonumber(heroInfo.hid)
            local equipInfo = godWeaponData[tostring(godWeaponPositions[btnIndex])]
            if( table.isEmpty(equipInfo) == false and  tonumber(equipInfo.item_template_id) > 0) then
                local equipSprite = ItemSprite.getItemSpriteById(tonumber(equipInfo.item_template_id), tonumber(equipInfo.item_id), FormationLayer.equipInfoDelegeate, true,_touchPriority - 30,nil,-550)
                equipBtn = LuaMenuItem.createItemSprite(equipSprite, equipSprite)

                -- 名称
                local equipDesc = ItemUtil.getItemById(tonumber(equipInfo.item_template_id))
                local quality,_,showEvolveNum = GodWeaponItemUtil.getGodWeaponQualityAndEvolveNum(tonumber(equipInfo.item_template_id), tonumber(equipInfo.item_id))
                local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
                local e_nameLabel =  CCRenderLabel:create(equipDesc.name , g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
                e_nameLabel:setAnchorPoint(ccp(0,0.5))
                e_nameLabel:setColor(nameColor)
                equipBtn:addChild(e_nameLabel)
                -- 进阶数
                local evolveLabel = CCRenderLabel:create(GetLocalizeStringBy("lic_1446",showEvolveNum), g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
                evolveLabel:setColor(ccc3(0x00,0xff,0x18))
                evolveLabel:setAnchorPoint(ccp(0,0.5))
                equipBtn:addChild(evolveLabel)
                -- 居中
                local posx = (equipBtn:getContentSize().width-e_nameLabel:getContentSize().width-evolveLabel:getContentSize().width-3)/2
                e_nameLabel:setPosition(ccp( posx, -equipBtn:getContentSize().height*0.2))
                evolveLabel:setPosition(ccp(e_nameLabel:getPositionX()+e_nameLabel:getContentSize().width + 3, e_nameLabel:getPositionY()))

                -- 强化等级
                local lvSprite = CCSprite:create("images/base/potential/lv_" .. quality .. ".png")
                lvSprite:setAnchorPoint(ccp(0,1))
                lvSprite:setPosition(ccp(-1, equipBtn:getContentSize().height))
                equipBtn:addChild(lvSprite,3)
                local lvLabel =  CCRenderLabel:create(equipInfo.va_item_text.reinForceLevel , g_sFontName, 18, 1, ccc3( 0, 0, 0), type_stroke)
                lvLabel:setColor(ccc3(255,255,255))
                lvLabel:setAnchorPoint(ccp(0.5,0.5))
                lvLabel:setPosition(ccp( lvSprite:getContentSize().width*0.5, lvSprite:getContentSize().height*0.5))
                lvSprite:addChild(lvLabel)

                -- 激活装备特效
                local itemInfo = GodWeaponItemUtil.getGodWeaponInfo(tonumber(equipInfo.item_template_id), tonumber(equipInfo.item_id))
                local unionInfo = GodWeaponItemUtil.getGodWeaponUnionInfo(itemInfo.item_template_id,hid,itemInfo)
                local isShow = false
                for m,un_info in pairs(unionInfo) do
                    if(un_info.isOpen == true)then
                        isShow = true
                    end
                end
                if(isShow == true)then
                    local effectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/suit/lzpurple"), -1,CCString:create(""))
                    effectSprite:setPosition(ccp(equipBtn:getContentSize().width*0.5, equipBtn:getContentSize().height*0.5))
                    equipBtn:addChild(effectSprite)
                end

                -- -- 印章 神兵类型 金木水火土
                --    local sealSprite = CCSprite:create("images/god_weapon/godtype/" .. equipDesc.type .. ".png" )
                --    sealSprite:setAnchorPoint(ccp(0.5, 0))
                --    sealSprite:setPosition(ccp(equipBtn:getContentSize().width*0.5, equipBtn:getContentSize().height*1.1))
                --    equipBtn:addChild(sealSprite)

                -- if( HeroModel.isNecessaryHeroByHid(hid) == false and ItemUtil.hasBetterEquipBy( godWeaponPositions[btnIndex], equipDesc.base_score ) == true )then
                -- 	require "script/libs/LuaCCSprite"
                -- 	redTipSprite = LuaCCSprite.createTipSpriteWithNum(0)
                -- end
            else
            -- -- 是否有更好的装备
            -- if( HeroModel.isNecessaryHeroByHid(hid) == false and ItemUtil.hasBetterEquipBy( godWeaponPositions[btnIndex], 0 ) )then
            -- 	require "script/libs/LuaCCSprite"
            -- 	redTipSprite = LuaCCSprite.createTipSpriteWithNum(0)
            -- end
            end
        end

        if(equipBtn == nil)then
            equipBtn = LuaMenuItem.createItemImage("images/formation/emptyequip/weapon.png", "images/formation/emptyequip/weapon.png")
            equipBtn:registerScriptTapHandler(changeEquipGodWeaponAction)
        end

        equipBorderSp:setPosition(ccp(equipBtn:getContentSize().width*0.5,equipBtn:getContentSize().height*0.5))
        equipBtn:addChild(equipBorderSp, -1,btnIndex+20000)
        equipBtn:setAnchorPoint(ccp(0.5, 0.5))
        equipBtn:setPosition(ccp(640 * xScale, (_centerHeight / MainScene.elementScale + 145) * btnYPositions[btnIndex] - 20))

        -- 神兵位置是否开启
        local isOpen,needLv = FormationUtil.getGodWeaponIsOpen(btnIndex)
        if(isOpen == false)then
            local lockIcon = CCSprite:create("images/formation/potential/newlock.png")
            lockIcon:setAnchorPoint(ccp(0.5,0.5))
            lockIcon:setPosition(ccp(equipBtn:getContentSize().width*0.5,equipBtn:getContentSize().height*0.5))
            equipBtn:addChild(lockIcon)
            local tipLv = CCRenderLabel:create( needLv , g_sFontPangWa, 28, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
            tipLv:setColor(ccc3(0x45, 0xe7, 0xf1))
            tipLv:setAnchorPoint(ccp(0.5,0.5))
            tipLv:setPosition(ccp(equipBtn:getContentSize().width*0.5,equipBtn:getContentSize().height*0.5+5))
            equipBtn:addChild(tipLv,3)
            local tipLvSprite = CCSprite:create("images/formation/potential/jikaifang.png")
            tipLvSprite:setAnchorPoint(ccp(0.5,0))
            tipLvSprite:setPosition(ccp(equipBtn:getContentSize().width*0.5,6))
            equipBtn:addChild(tipLvSprite,3)
        end

        -- -- 加红圈提示
        -- if( redTipSprite )then
        -- 	redTipSprite:setAnchorPoint(ccp(0.5, 0.5))
        -- 	redTipSprite:setPosition(ccp(equipBtn:getContentSize().width, equipBtn:getContentSize().height))
        -- 	equipBtn:addChild(redTipSprite)
        -- end

        godWeaponMenu:addChild(equipBtn, 1, 20000+btnIndex)
    end
end

--[[
	@desc	4个神兵按钮 的Action
	@para 	
	@return void
--]]
function changeEquipGodWeaponAction(tag, menuItem )
    local heroInfo = _curHeroInfo
    local isOpen,needLv = FormationUtil.getGodWeaponIsOpen(godWeaponPositions[tag-20000])
    if(isOpen == false)then
        AnimationTip.showTip(GetLocalizeStringBy("lic_1437",needLv))
        return
    end
    require "script/ui/formation/ChangeEquipLayer"
    print("tag-20000",tag-20000)
    local changeEquipLayer = ChangeEquipLayer.createLayer( nil, tonumber(heroInfo.hid) , godWeaponPositions[tag-20000],nil,nil,true)
    require "script/ui/main/MainScene"
    MainScene.changeLayer(changeEquipLayer, "changeEquipLayer")
end

-- 显示战魂
function showFightSoul( ... )
    local itemLayer = _layer:getMemberNodeByName("itemLayer")
    --创建两个tableView
    local viewPosX = {0.15,0.85}
    for i = 1,2 do
        local fightSoul9Sprite = createFightSoul9Sprite(i)
        itemLayer:addChild(fightSoul9Sprite)
        fightSoul9Sprite:ignoreAnchorPointForPosition(false)
        fightSoul9Sprite:setAnchorPoint(ccp(0.5,0.5))
        fightSoul9Sprite:setPosition(ccp(640*viewPosX[i], (_centerHeight / MainScene.elementScale - 145) * 0.37))
    end
end

--[[
	@des 	:战魂按钮滑动tebleview
	@param 	:p_index:左1右2
	@return :
--]]
function createFightSoul9Sprite(p_index)
    local fightSoulNum = table.count(_fightSoulPosTable[p_index])
    local cellHeightY = 110

    local h = function(fn,table,a1,a2)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(110,cellHeightY)
        elseif fn == "cellAtIndex" then
            a2 = createInnerCell(p_index, a1)
            r = a2
        elseif fn == "numberOfCells" then
            r = fightSoulNum
        else
            print("other function")
        end

        return r
    end
    local fightSoul9Sprite = STFormationLayer:createFightSoul9Sprite()
    local fightSoulView = fightSoul9Sprite:getChildByName("fightSoulTableView")
    fightSoulView:setEventHandler(h)
    fightSoulView:setTouchPriority(_touchPriority - 20)
    fightSoulView:reloadData()

    local swallowTouchLayer = fightSoul9Sprite:getChildByName("swallowTouchLayer")
    swallowTouchLayer:setSwallowTouch(true)
    swallowTouchLayer:setTouchPriority(_touchPriority - 11)
    swallowTouchLayer:setTouchEnabled(true)

    local downArrowSprite = fightSoul9Sprite:getChildByName("downArrowSprite")
    downArrowSprite:runAction(getArrowAction())
    local upArrowSprite = fightSoul9Sprite:getChildByName("upArrowSprite")
    upArrowSprite:runAction(getArrowAction())
    local borderListener = function (left, right, up, down)
        downArrowSprite:setVisible(down)
        upArrowSprite:setVisible(up)
    end
    fightSoulView:setBorderListener(borderListener)
    return fightSoul9Sprite
end

-- 箭头的动画
function getArrowAction()
    local arrActions = CCArray:create()
    arrActions:addObject(CCFadeOut:create(1))
    arrActions:addObject(CCFadeIn:create(1))
    local sequence = CCSequence:create(arrActions)
    local action = CCRepeatForever:create(sequence)
    return action
end



--[[
	@des 	:战魂按钮滑动cell
	@param 	:p_index:左1右2，p_pos位置
	@return :
--]]
function createInnerCell(p_index,p_pos)
    local innerCell = STTableViewCell:create()

    local bgSprite = CCSprite:create("images/common/f_bg.png")
    bgSprite:setAnchorPoint(ccp(0,0))
    bgSprite:setPosition(ccp(0,10))
    innerCell:addChild(bgSprite)

    local innerMenu = BTSensitiveMenu:create()
    innerMenu:setPosition(ccp(0,0))
    innerMenu:setTouchPriority(_touchPriority - 15)
    bgSprite:addChild(innerMenu)

    local item = getFightSoulPositionIcon(_fightSoulPosTable[p_index][p_pos])
    item:setAnchorPoint(ccp(0.5,0.5))
    item:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height/2))
    innerMenu:addChild(item,1,_fightSoulPosTable[p_index][p_pos])

    return innerCell
end

--[[
	@des 	:战魂按钮item
	@param 	:p_pos位置
	@return :
--]]
function getFightSoulPositionIcon( p_pos )
    local heroInfo = _curHeroInfo
    local menuItem = CCMenuItemImage:create("images/common/f_bg.png", "images/common/f_bg.png")
    if heroInfo ~= nil then
        local hid = tonumber(heroInfo.hid)
        local isOpen, openLv = FormationUtil.isFightSoulOpenByPos(p_pos)
        if( isOpen == true)then
            local fightSoulInfos = heroInfo.equip.fightSoul
            if( (not table.isEmpty(fightSoulInfos) ) and ( not table.isEmpty(fightSoulInfos[tostring(p_pos)]) ) )then
                -- 有战魂
                local fightSoulInfo = fightSoulInfos[tostring(p_pos)]
                local t_menuItem = ItemSprite.getItemSpriteById(tonumber(fightSoulInfo.item_template_id), tonumber(fightSoulInfo.item_id), FormationLayer.equipInfoDelegeate, true, _touchPriority - 15,nil, -550, nil, true, tonumber(fightSoulInfo.va_item_text.fsLevel))
                -- 名称
                local equipDesc = ItemUtil.getItemById(tonumber(fightSoulInfo.item_template_id))
                local nameColor = HeroPublicLua.getCCColorByStarLevel(equipDesc.quality)
                local e_nameLabel =  CCRenderLabel:create(equipDesc.name , g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
                e_nameLabel:setColor(nameColor)
                e_nameLabel:setAnchorPoint(ccp(0.5, 0))
                e_nameLabel:setPosition(ccp( t_menuItem:getContentSize().width/2, -t_menuItem:getContentSize().height*0.1))
                t_menuItem:addChild(e_nameLabel, 4)

                menuItem:addChild(t_menuItem)
            else
                -- 未添加战魂
                menuItem:registerScriptTapHandler(fightSoulAction)

                local iconSp = CCSprite:create("images/formation/potential/newadd.png")
                iconSp:setAnchorPoint(ccp(0.5, 0.5))
                iconSp:setPosition(ccp(menuItem:getContentSize().width*0.5, menuItem:getContentSize().height*0.5))
                menuItem:addChild(iconSp)

                local arrActions_2 = CCArray:create()
                arrActions_2:addObject(CCFadeOut:create(1))
                arrActions_2:addObject(CCFadeIn:create(1))
                local sequence_2 = CCSequence:create(arrActions_2)
                local action_2 = CCRepeatForever:create(sequence_2)
                iconSp:runAction(action_2)
            end
        else
            local lockSp = CCSprite:create("images/formation/potential/newlock.png")
            lockSp:setAnchorPoint(ccp(0.5, 0.5))
            lockSp:setPosition(ccp(menuItem:getContentSize().width/2, menuItem:getContentSize().height*0.5))
            menuItem:addChild(lockSp)

            local tipLabel = CCRenderLabel:create( openLv, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            tipLabel:setAnchorPoint(ccp(0.5, 0.5))
            tipLabel:setColor(ccc3(0xff, 0xff, 0xff))
            tipLabel:setPosition(ccp( menuItem:getContentSize().width* 0.5, menuItem:getContentSize().height*0.7))
            menuItem:addChild(tipLabel)
            menuItem:registerScriptTapHandler(fightSoulAction)

            local openLvSp = CCSprite:create("images/formation/potential/jikaifang.png")
            openLvSp:setAnchorPoint(ccp(0.5, 0.5))
            openLvSp:setPosition(ccp(menuItem:getContentSize().width*0.5, menuItem:getContentSize().height*0.4))
            menuItem:addChild(openLvSp)
        end
    else
        menuItem:registerScriptTapHandler(fightSoulAction)
    end
    return menuItem
end

-- 战魂
function fightSoulAction( tag, btnItem )
    local heroInfo = _curHeroInfo
    local hid = tonumber(heroInfo.hid)
    local isOpen, openLv = FormationUtil.isFightSoulOpenByPos(tag)
    if(isOpen == true)then
        if not DataCache.getSwitchNodeState(ksSwitchBattleSoul) then
            return
        end
        require "script/ui/formation/ChangeEquipLayer"
        local changeEquipLayer = ChangeEquipLayer.createLayer( changeEquipCallback, hid , tag, false, true)
        require "script/ui/main/MainScene"
        MainScene.changeLayer(changeEquipLayer, "changeEquipLayer")
    else
        AnimationTip.showTip( openLv .. GetLocalizeStringBy("key_1526"))
    end
end


function getTopCellBgSprite( p_index )
    local bgFilename = nil
    local optionInfo = _optionsInfo[p_index]
    if optionInfo.optionType == OptionType.HERO and not optionInfo.isLocked then
        local hid = _formationInfo[tostring(p_index - 1)]
        if hid ~= 0 then
            local heroInfo = HeroModel.getHeroByHid(hid)
            local heroDb = DB_Heroes.getDataById(heroInfo.htid)
            bgFilename = "images/base/potential/officer_" .. heroDb.potential .. ".png"
        end
    end
    bgFilename = bgFilename or "images/formation/potential/officer_11.png"
    return CCSprite:create(bgFilename)
end


function createTopCell( p_index )
    local cell = STTableViewCell:create()
    cell:setContentSize(_topCellSize)

    local bgSprite = getTopCellBgSprite(p_index)
    cell:addChild(bgSprite)
    bgSprite:setAnchorPoint(ccp(0.5, 0.5))
    bgSprite:setPosition(ccpsprite(0.5, 0.5, cell))

    local iconSprite = nil
    local optionInfo = _optionsInfo[p_index]
    if optionInfo.optionType == OptionType.HERO then
        if optionInfo.isLocked then
            iconSprite = CCSprite:create("images/formation/potential/newlock.png")

            local nextLv = FormationUtil.nextOpendFormationNumAndLevel()
            local tishi = CCRenderLabel:create( tostring(nextLv) , g_sFontPangWa, 28, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
            tishi:setColor(ccc3(0x45, 0xe7, 0xf1))
            tishi:setAnchorPoint(ccp(0.5,0.5))
            tishi:setPosition(ccp(iconSprite:getContentSize().width * 0.5, iconSprite:getContentSize().height * 0.5 + 10))

            local tishiSprite = CCSprite:create("images/formation/potential/jikaifang.png")
            tishiSprite:setAnchorPoint(ccp(0.5, 0))
            tishiSprite:setPosition(ccp(iconSprite:getContentSize().width * 0.5, -5))
            iconSprite:addChild(tishiSprite)
            iconSprite:addChild(tishi)
        else
            local hid = _formationInfo[tostring(p_index - 1)]
            if hid == 0 then
                iconSprite = CCSprite:create("images/formation/potential/newadd.png")
                local arrActions = CCArray:create()
                arrActions:addObject(CCFadeOut:create(1))
                arrActions:addObject(CCFadeIn:create(1))
                local sequence = CCSequence:create(arrActions)
                local action = CCRepeatForever:create(sequence)
                iconSprite:runAction(action)
            else
                local heroInfo = HeroModel.getHeroByHid(hid)
                local heroDb = DB_Heroes.getDataById(heroInfo.htid)
                local headIconName = ""
                if HeroModel.isNecessaryHero(heroInfo.htid) and UserModel.getDressIdByPos(1) ~= nil then
                    local dressInfo = ItemUtil.getItemById(UserModel.getDressIdByPos(1))
                    if(dressInfo.changeHeadIcon ~= nil)then
                        headIconName = "images/base/hero/head_icon/" .. ItemSprite.getStringByFashionString(dressInfo.changeHeadIcon)
                    else
                        headIconName = "images/base/hero/head_icon/" .. heroDb.head_icon_id
                    end
                else
                    local dressId = heroInfo.dress and heroInfo.dress["1"] or nil
                    headIconName = HeroUtil.getHeroIconImgByHTID( heroInfo.htid, dressId, heroInfo.turned_id )
                end
                iconSprite = CCSprite:create(headIconName)
                local vip= UserModel.getVipLevel()
                local effectNeedVipLevel = DB_Normal_config.getDataById(1).vipEffect
                if HeroModel.isNecessaryHeroByHid(hid) and vip >= effectNeedVipLevel then
                    local openEffect=  XMLSprite:create("images/base/effect/txlz/txlz")
                    openEffect:setPosition(ccpsprite(0.5, 0.5, iconSprite))
                    openEffect:setAnchorPoint(ccp(0.5,0.5))
                    iconSprite:addChild(openEffect)
                end
            end
        end
    elseif optionInfo.optionType == OptionType.LITTLE_FRIEND then
        iconSprite = CCSprite:create("images/formation/littlef_icon.png")
    elseif optionInfo.optionType == OptionType.HELPER then
        iconSprite = CCSprite:create("images/formation/second_icon.png")
    end
    bgSprite:addChild(iconSprite)
    iconSprite:setAnchorPoint(ccp(0.5, 0.5))
    iconSprite:setPosition(ccpsprite(0.5, 0.5, bgSprite))
    cell.bgSprite = bgSprite
    if p_index == _curOptionIndex then
        lightCell(cell)
    end
    return cell
end

-- 中间的tableView
function loadCenterTableView()
    _centerTableView = _layer:getMemberNodeByName("centerTableView")
    _centerLayer = _layer:getMemberNodeByName("centerLayer")
    local eventHandler = function ( functionName, tableView, index, cell )
        if functionName == "cellSize" then
            return _centerCellSize
        elseif functionName == "cellAtIndex" then
            return createCenterCell(index)
        elseif functionName == "numberOfCells" then
            return #_centersInfo
        elseif functionName == "cellTouched" then
        --changeOfficeLayerAction()
        elseif functionName == "scroll" then
            local optionInfo = _optionsInfo[_curOptionIndex]
            if optionInfo.optionType == OptionType.HELPER then
                return
            end
            local nextCenterInfo = _centersInfo[optionInfo.centerIndex + 1]
            if nextCenterInfo ~= nil then
                local nextOptionInfo = _optionsInfo[nextCenterInfo.optionIndex]
                if nextOptionInfo.optionType == OptionType.LITTLE_FRIEND then
                    local bottomBg = _layer:getMemberNodeByName("bottomBg")
                    local bottomWorldPosition = bottomBg:getParent():convertToWorldSpace(bottomBg:getPosition())
                    local cell = _centerTableView:cellAtIndex(optionInfo.centerIndex)
                    if not tolua.isnull(cell) then
                        local cellWorldPosition = cell:getParent():convertToWorldSpace(ccp(cell:getPositionX(), cell:getPositionY()))
                        if cellWorldPosition.x < 0 then
                            changeBottomBgParent(_centerTableView:getContainer(), _bottomCellPosition)
                        else
                            changeBottomBgParent(_layer, _bottomPosition)
                        end
                    end
                end
            end
        elseif functionName == "moveEnd" then
            local optionInfo = getOptionInfoByCenterIndex(index)
            local optionIndex = optionInfo.optionIndex
            if optionIndex ~= _curOptionIndex then
                _curOptionIndex = optionIndex
                refreshOptionTableViewLight()
                refreshHeroInfo()
            end
        end
    end
    _centerTableView:setContentSize(_centerCellSize)
    _centerTableView:setEventHandler(eventHandler)
    _centerTableView:setPageViewEnabled(true)
    _centerTableView:setTouchPriority(_touchPriority - 10)
    _centerTableView:reloadData()
    if (BTUtil:getGuideState() == true) then
        _centerTableView:setTouchEnabled(false)
    end
end


-- 切换到更换将领界面
function changeOfficeLayerAction( ... )
    local optionInfo = _optionsInfo[_curOptionIndex]
    if optionInfo.optionType ~= OptionType.HERO then
        return
    end

    local t_hid = _formationInfo[tostring(optionInfo.optionIndex - 1)]

    local squadInfo = DataCache.getSquad()

    if _curHeroInfo ~= nil then
        local t_index = 0
        for i=1,6 do
            c_hid = squadInfo[tostring(i)]
            if (c_hid == t_hid) then
                t_index = i
                break
            end
        end
        require "script/ui/hero/HeroInfoLayer"
        require "script/ui/hero/HeroPublicLua"
        local data = HeroPublicLua.getHeroDataByHid(t_hid)
        local tArgs = {}
        tArgs.sign = "formationLayer"
        tArgs.fnCreate = FormationLayer.createLayer
        tArgs.reserved = t_hid
        tArgs.reserved2 = t_index
        -- if(HeroModel.isNecessaryHeroByHid(t_hid) and tonumber(UserModel.getHeroLevel())<30)then
        -- 	tArgs.needChangeHeroBtn=false
        -- else
        tArgs.needChangeHeroBtn=true
        -- end
        ---[==[等级礼包新手引导屏蔽层
        ---------------------新手引导---------------------------------
        --add by licong 2013.09.09
        require "script/guide/NewGuide"
        if(NewGuide.guideClass == ksGuideFiveLevelGift) then
            require "script/guide/LevelGiftBagGuide"
            LevelGiftBagGuide.changLayer()
        end
        ---------------------end-------------------------------------
        --]==]

        if(HeroModel.isNecessaryHero(data.htid)) then
            data.dressId = UserModel.getDressIdByPos(1)
        else
            data.heroInfo = _curHeroInfo
        end
        data.turned_id = _curHeroInfo.turned_id
        data.addPos = HeroInfoLayer.kFormationPos
        MainScene.changeLayer(HeroInfoLayer.createLayer(data, tArgs), "HeroInfoLayer")


        ---[==[ 等级礼包第14步 显示将领信息
        ---------------------新手引导---------------------------------
        --add by licong 2013.09.09
        require "script/guide/NewGuide"
        require "script/guide/LevelGiftBagGuide"
        if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 13) then
            local levelGiftBagGuide_button = HeroInfoLayer.getStrengthenButton()
            local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
            LevelGiftBagGuide.show(14, touchRect)
        end
        ---------------------end-------------------------------------
        --]==]
    else

        -- 添加武将
        ---------------------新手引导---------------------------------
        --add by lichenyang 2013.08.29
        require "script/guide/NewGuide"
        if(NewGuide.guideClass ==  ksGuideFormation) then
            require "script/guide/FormationGuide"
            FormationGuide.changLayer()
        end
        ---------------------end-------------------------------------

        ---[==[等级礼包新手引导屏蔽层
        ---------------------新手引导---------------------------------
        --add by licong 2013.09.09
        require "script/guide/NewGuide"
        if(NewGuide.guideClass == ksGuideFiveLevelGift) then
            require "script/guide/LevelGiftBagGuide"
            LevelGiftBagGuide.changLayer()
        end
        ---------------------end-------------------------------------
        --]==]

        require "script/ui/formation/ChangeOfficerLayer"
        -- for k,v in pairs(c_formationInfo) do
        -- 	if(v == 0)then
        -- 		t_index = k
        -- 		break
        -- 	end
        -- end
        local t_index = 0
        for i=1,6 do
            c_hid = squadInfo[tostring(i)]
            if ( tonumber(c_hid) == tonumber(t_hid)) then
                t_index = i
                break
            end
        end
        local changeOfficerLayer = ChangeOfficerLayer.createLayer(t_index, t_hid)
        require "script/ui/main/MainScene"
        MainScene.changeLayer(changeOfficerLayer, "changeOfficerLayer")
    end
end

function checkAndChangeBottomBgParent( ... )
    local optionInfo = _optionsInfo[_curOptionIndex]
    local bottomBg = _layer:getMemberNodeByName("bottomBg")
    if optionInfo.optionType == OptionType.LITTLE_FRIEND then
        changeBottomBgParent(_centerTableView:getContainer(), _bottomCellPosition)
    else
        changeBottomBgParent(_layer, _bottomPosition)
    end
end

function changeBottomBgParent( p_parent, p_position )
    local bottomBg = _layer:getMemberNodeByName("bottomBg")
    if _bottomCurPosition ~= p_position then
        bottomBg:setPosition(p_position)
        changeParent(bottomBg, p_parent)
        _bottomCurPosition = p_position
    end
end

function changeParent(p_node, p_parent)
    p_node:retain()
    p_node:removeFromParentAndCleanup(true)
    p_node:autorelease()
    p_parent:addChild(p_node, 10)
end


function checkAndLoadNextCell( ... )
    local nextOptionInfo = _optionsInfo[_curOptionIndex + 1]
    if nextOptionInfo ~= nil and nextOptionInfo.optionType == OptionType.LITTLE_FRIEND then
        _centerTableView:updateCellAtIndex(nextOptionInfo.centerIndex)
    end
end

function refreshOptionTableViewLight( ... )
    _optionTableView:updateCellAtIndex(_curOptionIndex)
    local cell = _optionTableView:cellAtIndex(_curOptionIndex)
    local offset = _optionTableView:getContentOffset()
    local targetPositionX = offset.x + _curOptionIndex * _topCellSize.width
    if targetPositionX < _topCellSize.width then
        offset.x = offset.x + _topCellSize.width - targetPositionX
    elseif targetPositionX > _optionTableView:getViewSize().width then
        offset.x = offset.x - (targetPositionX - _optionTableView:getViewSize().width)
    end
    if _isNeedDisplayAnimation then
        _optionTableView:setContentOffsetInDuration(offset, 0.1)
    else
        _optionTableView:setContentOffset(offset)
    end
    if not tolua.isnull(cell) then
        lightCell(cell)
    end
end

function refreshHeroInfo( ... )
    initCurHeroInfo()
    refreshTitleSprite()
    refreshLevel()
    refreshHeroName()
    refreshSkill()
    refreshAttribute()
    refreshHeroButton()
    refreshItemLayer()
    checkAndLoadNextCell()
end

-- 等级/等级上限
function refreshLevel( ... )
    local heroLevelLabel = _layer:getMemberNodeByName("heroLevelLabel")
    if _curHeroInfo == nil then
        heroLevelLabel:setString("")
    else
        heroLevelLabel:setString(_curHeroInfo.level .. "/" .. UserModel.getHeroLevel())
    end
end

-- 羁绊
function refreshSkill( ... )
    local skillLabelArr = {}
    for i = 1, 6 do
        local label = _layer:getMemberNodeByName("tempLabel_" .. i)
        table.insert(skillLabelArr, label)
    end
    local linkGroup = nil
    if _curHeroInfo ~= nil then
        linkGroup = _curHeroInfo.localInfo.link_group1
    end
    if linkGroup ~= nil then
        require "db/DB_Union_profit"
        local s_name_arr = string.split(linkGroup, ",")
        for k, m_skill_label in pairs(skillLabelArr) do
            if(k <= #s_name_arr)then
                local t_union_profit = DB_Union_profit.getDataById(s_name_arr[k])
                if( not table.isEmpty(t_union_profit) and t_union_profit.union_arribute_name)then
                    m_skill_label:setString(t_union_profit.union_arribute_name)
                    if( not UnionProfitUtil.isHeroParticularUnionOpen( s_name_arr[k], _curHeroInfo.hid)) then
                        m_skill_label:setColor(ccc3(155,155,155))
                    else
                        m_skill_label:setColor(ccc3(0x78, 0x25, 0x00))
                    end
                end
            else
                m_skill_label:setString("")
            end
        end
    else
        for k, m_skill_label in pairs(skillLabelArr) do
            m_skill_label:setString("")
        end
    end
end

function refreshExtendBtn( ... )
    local extendButtons = getExtendButtons()
    local extendLayer = _layer:getMemberNodeByName("extendLayer")
    local extendButtonsCount = #extendButtons
    if not tolua.isnull(_extendMenu) then
        _extendMenu:removeAllChildrenWithCleanup(true)
    end
    _extendMenu = CCMenu:create()
    extendLayer:addChild(_extendMenu)
    _extendMenu:setAnchorPoint(ccp(0, 0))
    _extendMenu:setPosition(ccp(0, 0))
    _extendMenu:setTouchPriority(_touchPriority - 20)
    if extendButtonsCount == 1 then
        local btn = extendButtons[1]
        _extendMenu:addChild(btn)
        btn:setAnchorPoint(ccp(0.5, 0.5))
        btn:setPosition(ccpsprite(0.5, 0.5, extendLayer))
    elseif extendButtonsCount > 1 then
        local btn = CCMenuItemImage:create("images/formation/extend_n.png", "images/formation/extend_h.png")
        _extendMenu:addChild(btn)
        btn:setAnchorPoint(ccp(0.5, 0.5))
        btn:setPosition(ccpsprite(0.5, 0.5, extendLayer))
        btn:registerScriptTapHandler(extendCallback)
    end
    refreshExtendSubLayer()
end

function extendCallback( ... )
    _extendSubLayerIsShow = not _extendSubLayerIsShow
    local extendLayer = _layer:getMemberNodeByName("extendLayer")
    refreshExtendSubLayer()
end

function refreshExtendSubLayer( ... )
    if not _extendSubLayerIsShow then
        if not tolua.isnull(_extendSubLayer) then
            _extendSubLayer:stopAllActions()
            local action = CCScaleTo:create(0.2, 0)
            _extendSubLayer:runAction(action)
        end
        return
    end
    local extendLayer = _layer:getMemberNodeByName("extendLayer")
    if tolua.isnull(_extendSubLayer) then
        _extendSubLayer = CCLayer:create()
        extendLayer:addChild(_extendSubLayer, -1)
        _extendSubLayer:setAnchorPoint(ccp(0, 0))
        _extendSubLayer:setPosition(ccpsprite(0.5, 0.5, extendLayer))
        _extendSubLayer:setScale(0)
        
        _extendSubLayerBg = CCScale9Sprite:create("images/main/sub_icons/menu_bg.png")
        _extendSubLayer:addChild(_extendSubLayerBg)
        _extendSubLayerBg:setAnchorPoint(ccp(0, 0))
        _extendSubLayerBg:setPosition(ccp(0, 0))

        _extendSubLayerMenu = CCMenu:create()
        _extendSubLayerMenu:setAnchorPoint(ccp(0,0))
        _extendSubLayerMenu:setPosition(ccp(0,0))
        _extendSubLayer:addChild(_extendSubLayerMenu)
        _extendSubLayerMenu:setTouchPriority(_touchPriority - 20)
    end
    _extendSubLayerMenu:removeAllChildrenWithCleanup(true)
    local extendButtons = getExtendButtons()
    local extendButtonsCount = #extendButtons
    local xoffset = 0
    if extendButtonsCount <= 3 then
        xoffset = 10
        _extendSubLayerBg:setContentSize(CCSizeMake(10 + 70 * extendButtonsCount + xoffset, 80 + 65 * math.floor((extendButtonsCount - 1) / 3)))
    else
        _extendSubLayerBg:setContentSize(CCSizeMake(220,145))
    end
    for i = 1, extendButtonsCount do
        local extendButton = extendButtons[i]
        _extendSubLayerMenu:addChild(extendButton, 1, tonumber(_curHeroInfo.hid))
        extendButton:setAnchorPoint(ccp(0.5, 0.5))
        if i <= 3 then
            extendButton:setPosition(ccp(i * 70 - 30 + xoffset, 40 + 65 * math.floor((extendButtonsCount - 1) / 3)))
        else
            extendButton:setPosition(ccp(180 - (i - 1) % 3 * 70, 40))
        end
    end

    if _extendSubLayer:getScale() == 0 then
        _extendSubLayer:stopAllActions()
        local action = CCScaleTo:create(0.2, 1)
        _extendSubLayer:runAction(action)
    end
end

function getExtendButtons( ... )
    local extendButtons = {}
    if _curHeroInfo == nil then
        return extendButtons
    end
    -- 锦囊
    require "script/ui/pocket/PocketData"
    if PocketData.isOpen() then
        local btn = CCMenuItemImage:create("images/formation/pocket_n.png", "images/formation/pocket_h.png")
        btn:registerScriptTapHandler(tapPocketBtnCb)
        btn:setTag(tonumber(_curHeroInfo.hid))
        table.insert(extendButtons, btn)
    end
    -- 兵符
    if DataCache.getSwitchNodeState(ksSwitchTally, false) then
        local btn = CCMenuItemImage:create("images/formation/tally_n.png", "images/formation/tally_h.png")
        btn:registerScriptTapHandler(tallyBtnCb)
        btn:setTag(tonumber(_curHeroInfo.hid))
        table.insert(extendButtons, btn)
    end

    -- 天命
    if tonumber(_curHeroInfo.localInfo.star_lv)>=7 and not HeroModel.isNecessaryHeroByHid(_curHeroInfo.hid) then
        local btn = CCMenuItemImage:create("images/formation/destiny_n.png", "images/formation/destiny_h.png")
        btn:registerScriptTapHandler(destinyBtnCb)
        btn:setTag(tonumber(_curHeroInfo.hid))
        table.insert(extendButtons, btn)
    end

    -- 丹药
    if _curHeroInfo.localInfo.potential >= 5 then
        local btn = CCMenuItemImage:create("images/pill/pill_icon_n.png", "images/pill/pill_icon_h.png")
        btn:registerScriptTapHandler(toDrugBtnCallBack)
        table.insert(extendButtons, btn)
        -- 丹药红点
        PillData.transferPillInfo(_curHeroInfo)
        local pillInBag = DataCache.getPillInBag()
        if not table.isEmpty(pillInBag) then
            if tonumber(_curHeroInfo.evolve_level) < 1 and _curHeroInfo.localInfo.star_lv < 6 then
            else
                for k,v in pairs(pillInBag)do
                    local pillDbInfo = DB_Pill.getArrDataByField("Pill_id",tostring(v.item_template_id))[1]
                    if(pillDbInfo ~= nil)then
                        local curHaveNum = PillData.getHaveNumByTypeAndPage(pillDbInfo.Pill_type,pillDbInfo.Star-1)
                        if curHaveNum < pillDbInfo.Pill_number then
                            local drugTipSprite = CCSprite:create("images/common/tip_2.png")
                            btn:addChild(drugTipSprite)
                            drugTipSprite:setPosition(ccp(25, 25))
                            break
                        end
                    end
                end
            end
        end
    end
    -- 幻化
    require "script/ui/turnedSys/HeroTurnedData"
    local isCanTurned = HeroTurnedData.isCanTurned(_curHeroInfo.hid)
    if isCanTurned then
        local btn = CCMenuItemImage:create("images/formation/turned_n.png", "images/formation/turned_h.png")
        btn:registerScriptTapHandler(turnedCallback)
        btn:setTag(tonumber(_curHeroInfo.hid))
        table.insert(extendButtons, btn)
    end
    return extendButtons
end

function turnedCallback( p_tag, p_item )
    require "script/ui/turnedSys/HeroTurnedLayer"
    HeroTurnedLayer.showLayer(_curHeroInfo.hid,"FormationLayer")
end

-- 名字
function refreshHeroName( ... )
    local heroNameLabel = _layer:getMemberNodeByName("heroNameLabel")
    if _curHeroInfo == nil then
        heroNameLabel:setString("")
        return
    end
    local richInfo = heroNameLabel:getRichInfo()
    richInfo.elements = {}
    -- 名字
    local element = {}
    if HeroModel.isNecessaryHeroByHid(_curHeroInfo.hid) then
        element.text = UserModel.getUserName()
    else
        element.text = _curHeroInfo.localInfo.name
    end

    element.text = HeroModel.getHeroName(_curHeroInfo)
    element.color = HeroPublicLua.getCCColorByStarLevel(_curHeroInfo.localInfo.potential)
    table.insert(richInfo.elements, element)
    -- 进阶等级
    local element = {}
    if _curHeroInfo.localInfo.star_lv >= 6 then
        element.text = GetLocalizeStringBy("zz_99", _curHeroInfo.evolve_level)
    else
        element.text = "+" .. _curHeroInfo.evolve_level
    end
    element.color = ccc3(0x00, 0xff, 0x18)
    table.insert(richInfo.elements, element)
    heroNameLabel:setRichInfo(richInfo)
end

function refreshHeroButton()
    local touchPriority = _touchPriority - 20
    -- 换将
    local changeHeroBtn = _layer:getMemberNodeByName("changeHeroBtn")
    changeHeroBtn:setTouchPriority(touchPriority)
    changeHeroBtn:setClickCallback(changeOfficerBtnCb)
    if _curHeroInfo == nil or HeroModel.isNecessaryHeroByHid(_curHeroInfo.hid) then
        changeHeroBtn:setVisible(false)
    else
        changeHeroBtn:setVisible(true)
    end
    -- 时装
    local fashionBtn = _layer:getMemberNodeByName("fashionBtn")
    fashionBtn:setTouchPriority(touchPriority)
    fashionBtn:setClickCallback(toFashionBtnCallBack)
    if _curHeroInfo ~= nil and HeroModel.isNecessaryHeroByHid(_curHeroInfo.hid) then
        fashionBtn:setVisible(true)
    else
        fashionBtn:setVisible(false)
    end
    -- 进化
    local developupBtn = _layer:getMemberNodeByName("developupBtn")
    developupBtn:setTouchPriority(touchPriority)
    developupBtn:setClickCallback(tapDevelopBtnCb)
    if _curHeroInfo ~= nil and DevelopData.doOpenDevelopByHid(_curHeroInfo.hid) then
        developupBtn:setVisible(true)
        developupBtn:setTag(tonumber(_curHeroInfo.hid))
    else
        developupBtn:setVisible(false)
    end

    refreshExtendBtn()
    -- 神兵
    local godWeaponBtn = _layer:getMemberNodeByName("godWeaponBtn")
    godWeaponBtn:setTouchPriority(touchPriority)
    godWeaponBtn:setClickCallback(godWeaponCallback)
    if DataCache.getSwitchNodeState(ksSwitchGodWeapon,false) then
        godWeaponBtn:setVisible(true)
    else
        godWeaponBtn:setVisible(false)
    end
    -- 装备
    local equipBtn = _layer:getMemberNodeByName("equipBtn")
    equipBtn:setClickCallback(equipCallback)
    equipBtn:setTouchPriority(touchPriority)
    -- 战魂
    local fightSoulBtn = _layer:getMemberNodeByName("fightSoulBtn")
    fightSoulBtn:setClickCallback(fightSoulCallback)
    fightSoulBtn:setTouchPriority(touchPriority)
    -- 一键装备

    local onekeyEquipBtn = _layer:getMemberNodeByName("onekeyEquipBtn")
    onekeyEquipBtn:setTouchPriority(touchPriority)
    onekeyEquipBtn:setClickCallback(onekeyEquip)

    -- 一键强化
    local onekeyStrengthenBtn = _layer:getMemberNodeByName("onekeyStrengthenBtn")
    onekeyStrengthenBtn:setTouchPriority(touchPriority)
    onekeyStrengthenBtn:setClickCallback(onekeyStrengthenCallback)
    if onekeyEquipBtn:isVisible() and onekeyStrengthenBtn:isVisible() then
        onekeyStrengthenBtn:setVisible(false)
    end
    -- 切换一键
    local changeOnekeyBtn = _layer:getMemberNodeByName("changeOnekeyBtn")
    changeOnekeyBtn:setTouchPriority(touchPriority)
    changeOnekeyBtn:setClickCallback(changeOnekeyCallback)

    local onekeybg = _layer:getMemberNodeByName("onekeybg")
    if _curHeroInfo == nil or _curItemType == ItemType.GODWEAPON then
        onekeybg:setVisible(false)
    else
        onekeybg:setVisible(true)
    end
end

-- 切换一键
function changeOnekeyCallback( ... )
    local limitNum = tonumber(DB_Normal_config.getDataById(1).strengthen)
    local userLevel = UserModel.getAvatarLevel()
    if userLevel < limitNum then
        AnimationTip.showTip(string.format("%d级开启", limitNum))
        return
    end
    local onekeyEquipBtn = _layer:getMemberNodeByName("onekeyEquipBtn")
    local onekeyStrengthenBtn = _layer:getMemberNodeByName("onekeyStrengthenBtn")
    onekeyEquipBtn:setVisible(not onekeyEquipBtn:isVisible())
    onekeyStrengthenBtn:setVisible(not onekeyStrengthenBtn:isVisible())
end

-- 一键强化
function onekeyStrengthenCallback( ... )
end


----------------------------------------------------------------add by DJN
----------------------------------------------------------------换将按钮回调
----------------------------------------------------------------完全按照changeOfficeLayerAction的逻辑
function changeOfficerBtnCb( ... )
    local squadInfo = DataCache.getSquad()
    if _curHeroInfo ~= nil then
        local t_hid = tonumber(_curHeroInfo.hid)
        local t_index = 0
        for i=1,6 do
            c_hid = squadInfo[tostring(i)]
            if (c_hid == t_hid) then
                t_index = i
                break
            end
        end
        require "script/ui/hero/HeroInfoLayer"
        require "script/ui/hero/HeroPublicLua"
        local data = HeroPublicLua.getHeroDataByHid(t_hid)
        local tArgs = {}
        tArgs.sign = "formationLayer"
        tArgs.fnCreate = FormationLayer.createLayer
        tArgs.reserved = t_hid
        tArgs.reserved2 = t_index
        tArgs.needChangeHeroBtn=true

        if(HeroModel.isNecessaryHero(data.htid)) then
            data.dressId = UserModel.getDressIdByPos(1)
        end
        require "script/ui/formation/ChangeOfficerLayer"
        MainScene.changeLayer(ChangeOfficerLayer.createLayer(tArgs.reserved2, tArgs.reserved), "ChangeOfficerLayer")

    else
        -- 添加武将
        require "script/ui/formation/ChangeOfficerLayer"
        local t_index = 0
        for i=1,6 do
            c_hid = squadInfo["" .. i]
            if ( tonumber(c_hid) == 0) then
                t_index = i
                break
            end
        end
        local changeOfficerLayer = ChangeOfficerLayer.createLayer(t_index, nil)
        require "script/ui/main/MainScene"
        MainScene.changeLayer(changeOfficerLayer, "changeOfficerLayer")
    end
end
----------------------------------------------------------------

--[[
	@des 	:切换到时装屋
	@param 	:
	@return :
--]]
function toFashionBtnCallBack( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    print("toFashionBtnCallBack")

    --进入时装场景
    print("enter dress scene")
    MainScene.setMainSceneViewsVisible(true, false, true)
    require "script/ui/fashion/FashionLayer"
    local fashionLayer = FashionLayer:createFashion()
    MainScene.changeLayer(fashionLayer, "FashionLayer")
    -- 返回标记
    FashionLayer.setMark(true)
end

--武将(紫卡＋7)进化橙卡按钮回调 by zhangqiang
function tapDevelopBtnCb( p_tag, p_item )
    require "script/ui/develop/DevelopLayer"
    DevelopLayer.showLayer(p_tag, DevelopLayer.kOldLayerTag.kFormationTag)
end

-- 兵符回调
function tallyBtnCb(p_tag, p_item)
    -- p_tag  当前英雄的hid
    require "script/ui/tally/TallyMainLayer"
    local backBtnCallback = function( ... )
        require "script/ui/formation/FormationLayer"
        local formationLayer = FormationLayer.createLayer(p_tag)
        MainScene.changeLayer(formationLayer,"formationLayer")
    end
    local tallyLayer = TallyMainLayer.createLayer(p_tag,true,backBtnCallback,-100)
    require "script/ui/main/MainScene"
    MainScene.changeLayer(tallyLayer,"tallyLayer")
end

function destinyBtnCb( p_tag, p_item )
    print("p_tag====",p_tag)
    require "script/ui/redcarddestiny/RedCardDestinyLayer"
    local layer = RedCardDestinyLayer.createLayer(2,p_tag,-1000)
    MainScene.changeLayer(layer, "RedCardDestinyLayer")
    MainScene.setMainSceneViewsVisible(false,false,false)
end

-- 锦囊回调
function tapPocketBtnCb( p_tag, p_item )
    -- test
    -- if true then
    -- 	return
    -- end
    require "script/ui/pocket/PocketMainLayer"
    local cur_hid = _curHeroInfo.hid
    local backCallback = function ( ... )
        require "script/ui/formation/FormationLayer"
        local formationLayer = FormationLayer.createLayer(cur_hid)
        MainScene.changeLayer(formationLayer, "formationLayer")
    end
    local layer = PocketMainLayer.createLayer(cur_hid, backCallback)
    MainScene.changeLayer(layer,"PocketMainLayer")
end
--[[
	@des 	:切换到丹药界面
	@param 	:
	@return :
--]]
function toDrugBtnCallBack( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    --print("toDrugBtnCallBack")
    local canEnter = DataCache.getSwitchNodeState( ksSwitchDrug,true )
    if(not canEnter)then
        return
    end

    local cur_Hid = _curHeroInfo.hid
    local allhero = HeroModel.getAllHeroes()
    if tonumber(allhero[cur_Hid].evolve_level) < 1  and tonumber(allhero[cur_Hid].localInfo.star_lv) < 6 then
        AnimationTip.showTip(GetLocalizeStringBy("djn_181"))
        return
    end

    --进入丹药场景
    print("enter Drug scene")
    require "script/ui/pill/PillLayer"
    local pillCb = function ( ... )
        require "script/ui/formation/FormationLayer"
        local formationLayer = FormationLayer.createLayer(cur_Hid)
        MainScene.changeLayer(formationLayer, "formationLayer")
    end
    --local PillLayer = PillLayer.createLayer(allhero[cur_Hid],pillCb)
    local PillLayer = PillLayer.createLayer(_curOptionIndex,pillCb)
    MainScene.changeLayer(PillLayer, "PillLayer")
end

--[[
	@desc	一键装备按钮
	@para 	
	@return void
--]]
function onekeyEquip( ... )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    ---[==[铁匠铺 新手引导屏蔽层
    ---------------------新手引导---------------------------------
    --add by licong 2013.09.26
    require "script/guide/NewGuide"
    if(NewGuide.guideClass == ksGuideSmithy) then
        require "script/guide/EquipGuide"
        EquipGuide.changLayer()
    end
    ---------------------end-------------------------------------
    --]==]

    if _curHeroInfo ~= nil then
        local hid = tonumber(_curHeroInfo.hid)
        local args = Network.argsHandler(hid)
        if( _curItemType == ItemType.EQUIP )then
            -- 记录更换装备之前的套装个数
            _oldSuitInfo = ItemUtil.getSuitActivateNumByHid(hid)
            RequestCenter.hero_equipBestArming(onekeyEquipCallback, args)
        elseif( _curItemType == ItemType.FIGHTSOUL )then
            if not DataCache.getSwitchNodeState(ksSwitchBattleSoul) then
                return
            end
            RequestCenter.hero_equipBestFightSoul(oneKeyFightSoulCallback, args)
        end
    end
end

-- 一键装备装备
function onekeyEquipCallback( cbFlag, dictData, bRet )
    if(dictData.err ~= "ok" or table.isEmpty(dictData.ret) )then
        AnimationTip.showTip(GetLocalizeStringBy("key_1691"))
        return
    end

    --战斗力信息
    --added by Zhang Zihang
    require "script/model/utils/UnionProfitUtil"

    require "script/model/hero/HeroAffixFlush"
    local hid = tonumber(_curHeroInfo.hid)
    local _lastFightForce = FightForceModel.dealParticularValues(hid)

    local allHeros = HeroModel.getAllHeroes()
    local hid = tonumber(_curHeroInfo.hid)
    -- 宝物
    if(not table.isEmpty(dictData.ret.treasure))then
        -- 更换装备
        for m_pos,m_treasInfo in pairs(dictData.ret.treasure) do
            _curHeroInfo.equip.treasure[tostring(m_pos)] = m_treasInfo
        end

        --刷新宝物属性
        HeroAffixFlush.onChangeTreas(hid)

        if table.isEmpty(dictData.ret.arming) then
            --战斗力信息
            --added by Zhang Zihang
            local _nowFightForce = FightForceModel.dealParticularValues(hid)
            -- require "script/model/utils/UnionProfitUtil"
            -- UnionProfitUtil.prepardUnionFly()
            local param_1_table = UnionProfitUtil.prepardUnionFly(nil,true)
            if table.isEmpty(param_1_table) then
                ItemUtil.showAttrChangeInfo(_lastFightForce, _nowFightForce)
            else
                local param_2_table = ItemUtil.showAttrChangeInfo(_lastFightForce, _nowFightForce,nil,true)
                local paramTable = {[1] = param_1_table,[2] = param_2_table}
                local connectTable = table.connect(paramTable)

                LevelUpUtil.showConnectFlyTip(connectTable)
            end
        end
    end

    -- 装备
    if( not table.isEmpty(dictData.ret.arming))then
        -- 计算数值
        local last_numerial = {}
        for k, equipInfo in pairs(_curHeroInfo.equip.arming) do
            if(not table.isEmpty(equipInfo)) then
                local  t_numerial_last = ItemUtil.getTop2NumeralByIID( tonumber(equipInfo.item_id))
                for l_key, l_num in pairs(t_numerial_last) do
                    last_numerial[l_key] = last_numerial[l_key] or 0
                    last_numerial[l_key] = last_numerial[l_key] + tonumber(l_num)
                end
            end
        end

        -- 更换装备
        for m_pos,m_equipInfo in pairs(dictData.ret.arming) do
            _curHeroInfo.equip.arming[tostring(m_pos)] = m_equipInfo
        end

        --刷新装备属性
        HeroAffixFlush.onChangeEquip(hid)

        local cur_numerial = {}
        for k, equipInfo in pairs(_curHeroInfo.equip.arming) do
            if(not table.isEmpty(equipInfo)) then
                local  t_numerial_last = ItemUtil.getTop2NumeralByIID( tonumber(equipInfo.item_id))
                for l_key, l_num in pairs(t_numerial_last) do
                    cur_numerial[l_key] = cur_numerial[l_key] or 0
                    cur_numerial[l_key] = cur_numerial[l_key] + tonumber(l_num)
                end
            end
        end

        -- 更换完装备后套装最新信息 飘套装激活属性
        local newSuitInfo = ItemUtil.getSuitActivateNumByHid(hid)
        require "script/ui/tip/AttrTip"
        local flyTipCallBack = function ( ... )
            local showDevelopTip = function ( ... )
                local developActivateInfo = ItemUtil.getEquipDevelopActivateInfoByHid(hid)
                if developActivateInfo ~= nil then
                    AttrTip.showActivateEquipDevelopTip(developActivateInfo)
                end
            end
            if newSuitInfo ~= nil and _oldSuitInfo ~= nil then
                local isShow = AttrTip.showAtrrTipCallBack(newSuitInfo, _oldSuitInfo, showDevelopTip)
                if not isShow then
                    showDevelopTip()
                end
            else
                showDevelopTip()
            end

        end


        --战斗力信息
        --added by Zhang Zihang
        local _nowFightForce = FightForceModel.dealParticularValues(hid)

        local unionCallBack = function()
            --ItemUtil.showAttrChangeInfo(last_numerial, cur_numerial, flyTipCallBack)
            ItemUtil.showAttrChangeInfo(_lastFightForce,_nowFightForce,flyTipCallBack)
        end

        require "script/model/hero/HeroModel"
        local heroInfo = HeroModel.getHeroByHid(hid)
        --如果是主角
        if(HeroModel.isNecessaryHero(heroInfo.htid))then
            -- require "script/model/utils/UnionProfitUtil"
            -- UnionProfitUtil.prepardUnionFly(unionCallBack)
            require "script/model/utils/UnionProfitUtil"
            local param_1_table = UnionProfitUtil.prepardUnionFly(nil,true)
            if table.isEmpty(param_1_table) then
                unionCallBack()
            else
                --local param_2_table = ItemUtil.showAttrChangeInfo(last_numerial, cur_numerial,nil,true)
                local param_2_table = ItemUtil.showAttrChangeInfo(_lastFightForce,_nowFightForce,nil,true)
                local paramTable = {[1] = param_1_table,[2] = param_2_table}
                local connectTable = table.connect(paramTable)

                LevelUpUtil.showConnectFlyTip(connectTable,flyTipCallBack)
            end
        else
            unionCallBack()
        end
    end

    HeroModel.setAllHeroes(allHeros)
    refreshEquipAndBottom()
    AnimationTip.showTip(GetLocalizeStringBy("key_1537"))

    -- 铁匠铺 第3步 显示点击武器
    local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
        addGuideEquipGuide3()
    end))
    _layer:runAction(seq)
end

function oneKeyUpgradeCallBack( cbFlag, dictData, bRet )
    if(dictData.err ~= "ok" or table.isEmpty(dictData.ret) )then
        return
    end
    local isFull = true
    for k,v in pairs(dictData.ret) do
        if(tonumber(v)>0)then
            isFull = false
            break
        end
    end
    if(isFull)then
        -- AnimationTip.showTip(GetLocalizeStringBy("llp_524"))
        return
    else
        AnimationTip.showTip(GetLocalizeStringBy("llp_525"))
    end
    local totalData = dictData.ret
    local totalCost = tonumber(totalData["0"])
    for k,v in pairs(totalData) do
        if(tonumber(k)>1)then
            local _equipInfo = ItemUtil.getEquipInfoFromHeroByItemId(k)
            add_lv = tonumber(v)
            HeroModel.changeHeroEquipReinforceBy(_equipInfo.hid, tonumber(k), add_lv )
        end
    end
    UserModel.changeSilverNumber(-totalCost)
    refreshEquipAndBottom()
end

function onekeyStrengthenCallback( ... )
    local isFull = false
    local isEmpty = true
    for k,v in pairs(_curHeroInfo.equip.arming) do
        local _equipInfo = ItemUtil.getEquipInfoFromHeroByItemId(v.item_id)
        if(_equipInfo~=nil)then
            isEmpty = false
            break
        end
    end
    if(isEmpty)then
        AnimationTip.showTip(GetLocalizeStringBy("llp_526"))
        return
    end
    local userLevel = UserModel.getAvatarLevel()
    for k,v in pairs(_curHeroInfo.equip.arming) do
        local _equipInfo = ItemUtil.getEquipInfoFromHeroByItemId(v.item_id)
        if(_equipInfo~=nil and (2*userLevel)<=tonumber(_equipInfo.va_item_text.armReinforceLevel))then
            isFull = true
            break
        end
    end
    if(isFull)then
        AnimationTip.showTip(GetLocalizeStringBy("key_2095"))
        return
    end
    for k,v in pairs(_curHeroInfo.equip.arming) do
        local _equipInfo = ItemUtil.getEquipInfoFromHeroByItemId(v.item_id)
        if(_equipInfo~=nil)then
            -- 获取装备数据
            require "db/DB_Item_arm"
            local _equip_desc = DB_Item_arm.getDataById(_equipInfo.item_template_id)

            -- 获取强化相关数值
            local fee_id = "" .. _equip_desc.quality .. _equip_desc.type
            require "db/DB_Reinforce_fee"
            local _fee_data = DB_Reinforce_fee.getDataById( tonumber(fee_id) )
            local cost = _fee_data["coin_lv" .. (_equipInfo.va_item_text.armReinforceLevel+1)]
            local silver = UserModel.getSilverNumber()
            if(tonumber(cost)>silver)then
                AnimationTip.showTip(GetLocalizeStringBy("llp_511"))
                return
            end
        end
    end
    local hid = tonumber(_curHeroInfo.hid)
    local args = Network.argsHandler(hid)
    RequestCenter.oneKeyUpgradeOnHero(oneKeyUpgradeCallBack,args)
end

function getLastSelectHeroId()
    if _curHeroInfo ~= nil then
        return tonumber(_curHeroInfo.hid)
    end
    return nil
end

function refreshEquipAndBottom( ... )
    if tolua.isnull(_layer) then
        return
    end
    refreshSkill()
    refreshAttribute()
    refreshItemLayer()
end

function refreshGodWeaponAndBottom( ... )
    refreshAttribute()
    refreshItemLayer()
end

-- 一键装备战魂
function oneKeyFightSoulCallback( cbFlag, dictData, bRet )
    if(dictData.err ~= "ok" or table.isEmpty(dictData.ret) )then
        AnimationTip.showTip(GetLocalizeStringBy("key_2568"))
        return
    end
    local allHeros = HeroModel.getAllHeroes()
    if(not table.isEmpty(dictData.ret.fightSoul) )then
        -- 计算数值
        local last_numerial = {}

        if( not table.isEmpty(_curHeroInfo.equip.fightSoul) )then
            last_numerial = getShowFightSoulData(_curHeroInfo.equip.fightSoul)
        end

        -- 更换装备
        for m_pos,m_equipInfo in pairs(dictData.ret.fightSoul) do
            _curHeroInfo.equip.fightSoul[tostring(m_pos)] = m_equipInfo
        end

        --刷新战魂属性
        require "script/model/hero/HeroAffixFlush"
        HeroAffixFlush.onChangeFightSoul(_curHeroInfo.hid)

        -- 装备后的数值
        local cur_numerial = getShowFightSoulData(_curHeroInfo.equip.fightSoul)
        ItemUtil.showFightSoulAttrChangeInfo( last_numerial, cur_numerial )

        refreshFightSoulAndBottom()
    end
end


function getShowFightSoulData( t_fightSoul)
    local t_numerial = {}

    if( not table.isEmpty(t_fightSoul) )then
        for k,soulData in pairs(t_fightSoul) do
            if(not table.isEmpty(soulData)) then
                local  t_numerial_last = HuntSoulData.getFightSoulAttrByItem_id(soulData.item_id, nil, soulData)
                for l_key, l_data in pairs(t_numerial_last) do
                    if( not table.isEmpty(t_numerial[l_key]) )then
                        t_numerial[l_key].displayNum = t_numerial[l_key].displayNum + l_data.displayNum
                    else
                        t_numerial[l_key] = l_data
                    end
                end
            end
        end
    end

    return t_numerial
end

function refreshFightSoulAndBottom( ... )
    refreshAttribute()
    refreshItemLayer()
end

-- 装备
function equipCallback( ... )
    _curItemType = ItemType.EQUIP
    refreshItemLayer()
    refreshHeroButton()
end

-- 战魂
function fightSoulCallback( ... )
    if not DataCache.getSwitchNodeState(ksSwitchBattleSoul) then
       return
    end
    _curItemType = ItemType.FIGHTSOUL
    refreshItemLayer()
    refreshHeroButton()
end

function godWeaponCallback( ... )
    _curItemType = ItemType.GODWEAPON
    refreshItemLayer()
    refreshHeroButton()
end

-- 有新的小伙伴位置时提示
function addLittleNewPosTip( ... )
    require "script/ui/formation/LittleFriendData"
    local isShow,b = LittleFriendData.getIsShowTipNewLittle()
    if(isShow)then
        require "script/ui/tip/AlertTip"
        local str = GetLocalizeStringBy("key_1658")
        AlertTip.showAlert(str,LittleFriendData.afterLittleTipCallFun,nil,nil,nil,nil,LittleFriendData.afterLittleTipCallFun)
    end
end

-- 属性
function refreshAttribute( ... )
    -- 资质
    local heroQualityLabel = _layer:getMemberNodeByName("heroQualityLabel")
    -- 生命
    local phyAttValueLabel = _layer:getMemberNodeByName("phyAttValueLabel")
    -- 攻击
    local magAttValueLabel = _layer:getMemberNodeByName("magAttValueLabel")
    -- 物防
    local phyDefValueLabel = _layer:getMemberNodeByName("phyDefValueLabel")
    -- 法防
    local magDefValueLabel = _layer:getMemberNodeByName("magDefValueLabel")
    local fightDict = {}
    if _curHeroInfo ~= nil then
        fightDict = FightForceModel.getHeroDisplayAffix(_curHeroInfo.hid)
    end
    if table.isEmpty(fightDict) then
        heroQualityLabel:setString("")
        phyAttValueLabel:setString("")
        magAttValueLabel:setString("")
        phyDefValueLabel:setString("")
        magDefValueLabel:setString("")
    else
        heroQualityLabel:setString(_curHeroInfo.localInfo.heroQuality)
        phyDefValueLabel:setString(fightDict[AffixDef.PHYSICAL_DEFEND])
        phyAttValueLabel:setString(fightDict[AffixDef.LIFE])
        magDefValueLabel:setString(fightDict[AffixDef.MAGIC_DEFEND])
        magAttValueLabel:setString(fightDict[AffixDef.GENERAL_ATTACK])
    end
end

function getHeroInfoByOptionIndex( p_optionIndex )
    local optionInfo = _optionsInfo[p_optionIndex]
    if optionInfo.optionType == OptionType.HERO then
        local hid = _formationInfo[tostring(p_optionIndex - 1)]
        if hid == 0 then
            return nil
        else
            return HeroUtil.getHeroInfoByHid(hid)
        end
    else
        return _lastHeroInfo
    end
end

function getCenterInfoByOptionIndex ( p_optionIndex )
    local optionInfo = _optionsInfo[p_optionIndex]
    local centerInfo = _centersInfo[optionInfo.centerIndex]
    return centerInfo
end


function getOptionInfoByCenterIndex( p_centerIndex )
    local centerInfo = _centersInfo[p_centerIndex]
    local optionInfo = _optionsInfo[centerInfo.optionIndex]
    return optionInfo
end

function refreshTitleSprite()
    local titleLayer = _layer:getMemberNodeByName("titleLayer")
    titleLayer:removeAllChildren();

    local point = _layer:convertToWorldSpace(ccp(_layer:getContentSize().width * 0.5, 300 * g_fScaleX + (_layer:getContentSize().height - 480 * g_fScaleX) * 0.5 + 200 * g_fScaleX))
    point = titleLayer:getParent():convertToNodeSpace(point)
    titleLayer:setPosition(point)
    --titleLayer:setPositionY((_centerHeight / MainScene.elementScale + 145) * 0.72 + 50 * g_fScaleY / g_fScaleX)
    if _curHeroInfo ~= nil and HeroModel.isNecessaryHero(_curHeroInfo.htid) then
        require "script/ui/title/TitleUtil"
        local titleSprite = TitleUtil.createTitleNormalSpriteById(UserModel.getTitleId())
        if titleSprite ~= nil then
            titleLayer:addChild(titleSprite);
            titleSprite:setAnchorPoint(ccp(0.5, 0.5))
            titleSprite:setPosition(ccpsprite(0.5, 0.5, titleLayer))
        end
    end
end

-- function refreshStar( ... )
--     local starBgSprite = _layer:getMemberNodeByName("starBgSprite")
--     starBgSprite:setPositionY((_centerHeight / MainScene.elementScale + 145) * 0.72 + 50 * g_fScaleY / g_fScaleX)
--     --starBgSprite:setPositionY((_centerHeight / g_fScaleX - (_centerHeight - 185 * g_fScaleX - 440 * MainScene.elementScale ) * 0.5))
--     starBgSprite:removeAllChildren()
--     if _curHeroInfo == nil then
--         return
--     end
--     local starsXPositions = nil
--     local starsYPositions = nil
--     if _curHeroInfo.localInfo.potential % 2 == 0 then
--         starsXPositions = {0.45,0.55,0.35,0.65,0.25,0.75,0.8}
--         starsYPositions = {0.745,0.745,0.72,0.72,0.7,0.7,0.68}
--     else
--         starsXPositions = {0.5, 0.4, 0.6, 0.3, 0.7, 0.2, 0.8}
--         starsYPositions = {0.75, 0.74, 0.74, 0.71, 0.71, 0.68, 0.68}
--     end
--     for i = 1, _curHeroInfo.localInfo.potential do
--         local star = CCSprite:create("images/formation/star.png")
--         starBgSprite:addChild(star)
--         star:setAnchorPoint(ccp(0.5, 0.5))
--         star:setPosition(ccpsprite(starsXPositions[i], starsYPositions[i], starBgSprite))
--     end
-- end

-- 装备回调
function equipInfoDelegeate( )
    print("here:equipInfoDelegeate")
    MainScene.setMainSceneViewsVisible(true, false, true)
    refreshEquipAndBottom()
end

function createCenterCell( p_index )
    local cell = STTableViewCell:create()
    cell:setContentSize(_centerCellSize)
    local normalSprite = CCSprite:create()
    normalSprite:setContentSize(_centerCellSize)
    local menu = BTSensitiveMenu:create()
    cell:addChild(menu)
    menu:setPosition(ccp(0, 0))
    menu:setTouchPriority(_touchPriority - 5)
    local clickItem = CCMenuItemSprite:create(normalSprite, normalSprite)
    menu:addChild(clickItem)
    clickItem:registerScriptTapHandler(changeOfficeLayerAction)

    local centerInfo = _centersInfo[p_index]
    local optionInfo = _optionsInfo[centerInfo.optionIndex]
    if optionInfo.optionType == OptionType.HERO then
        local bodyOffset = 0
        local hid = _formationInfo[tostring(centerInfo.optionIndex - 1)]
        local cardSprite = nil
        if hid ~= 0 then
            local heroInfo = HeroModel.getHeroByHid(hid)
            local dressId = nil
            if HeroModel.isNecessaryHero(heroInfo.htid) then
                dressId = UserModel.getDressIdByPos(1)
            end
            cardSprite = HeroUtil.getHeroBodySpriteByHTID(heroInfo.htid, dressId, UserModel.getUserSex(), heroInfo.turned_id)
            bodyOffset = HeroUtil.getHeroBodySpriteOffsetByHTID(heroInfo.htid, dressId, heroInfo.turned_id)
        else
            cardSprite = CCSprite:create("images/formation/testselect.png")
        end
        cell:addChild(cardSprite)
        cardSprite:setAnchorPoint(ccp(0.5, 0))

        cardSprite:setPosition(ccp(_centerCellSize.width * 0.5, (_centerHeight - 185 * g_fScaleX - 440 * MainScene.elementScale ) * 0.5 + 185 * g_fScaleX - bodyOffset))
        cardSprite:setScale(MainScene.elementScale)
    elseif optionInfo.optionType == OptionType.LITTLE_FRIEND then
        local littleFriendLayer = LittleFriendLayer.createLittleFriendLayer(g_winSize.width, _centerHeight)
        cell:addChild(littleFriendLayer)
        littleFriendLayer:ignoreAnchorPointForPosition(false)
        littleFriendLayer:setAnchorPoint(ccp(0.5, 0.5))
        littleFriendLayer:setPosition(ccpsprite(0.5, 0.5, cell))
    end
    return cell
end

function initBottomPosition( ... )
    local bottomBg = _layer:getMemberNodeByName("bottomBg")

    local bottomSwallowTouchLayer = _layer:getMemberNodeByName("bottomSwallowTouchLayer")
    bottomSwallowTouchLayer:setSwallowTouch(true)
    bottomSwallowTouchLayer:setTouchPriority(_touchPriority - 18)
    bottomSwallowTouchLayer:setTouchEnabled(true)

    local menu = CCMenu:create()
    bottomBg:addChild(menu)
    menu:setPosition(ccp(0, 0))
    menu:setContentSize(bottomBg:getContentSize())
    menu:setTouchPriority(_touchPriority - 19)

    local normalSprite = CCSprite:create()
    normalSprite:setContentSize(CCSizeMake(295, 90))
    local selectedSprite = CCSprite:create()
    selectedSprite:setContentSize(CCSizeMake(295, 90))

    local bottomBtn = CCMenuItemSprite:create(normalSprite, selectedSprite)
    menu:addChild(bottomBtn)
    bottomBtn:setPosition(ccp(25, 25))
    bottomBtn:setAnchorPoint(ccp(0, 0))
    bottomBtn:registerScriptTapHandler(changeOfficeLayerAction)

    _bottomPosition = bottomBg:getPosition()
    _bottomCurPosition = _bottomPosition
    local centerTableView = _layer:getMemberNodeByName("centerTableView")
    local bottomWorldPosition = bottomBg:getParent():convertToWorldSpace(ccp(bottomBg:getPositionX(), bottomBg:getPositionY()))
    _bottomCellPosition = centerTableView:getContainer():convertToNodeSpace(bottomWorldPosition)
    local lastHeroOptionInfo = nil
    for i = 1, #_optionsInfo do
        local optionInfo = _optionsInfo[i]
        if optionInfo.optionType == OptionType.LITTLE_FRIEND then
            lastHeroOptionInfo = _optionsInfo[i - 1]
            if lastHeroOptionInfo.isLocked then
                lastHeroOptionInfo = _optionsInfo[i - 2]
            end
            break
        end
    end
    _bottomCellPosition.x = _centerCellSize.width * (lastHeroOptionInfo.centerIndex - 1) + _centerCellSize.width * 0.5
end

function initCenterHeight( ... )
    local menuHeight = MenuLayer.getHeight()
    local bulletinHeight = BulletinLayer.getLayerHeight() * g_fScaleX
    local topBg = _layer:getMemberNodeByName("topBg")
    local topBgHeight = topBg:getContentSize().height * g_fScaleX
    _centerHeight = g_winSize.height - menuHeight - bulletinHeight - topBgHeight
    local centerLayer = _layer:getMemberNodeByName("centerLayer")
    centerLayer:setContentSize(CCSizeMake(g_winSize.width, _centerHeight))
    _centerCellSize = CCSizeMake(g_winSize.width, _centerHeight)
end


function changeWarcraftCallback( ... )
    ---[==[阵法 新手引导屏蔽层
    ---------------------新手引导---------------------------------
    require "script/guide/NewGuide"
    require "script/guide/WarcraftGuide"
    if(NewGuide.guideClass == ksGuideWarcraft and WarcraftGuide.stepNum == 2) then
        WarcraftGuide.changLayer()
    end
    ---------------------end-------------------------------------
    --]==]
    showChangeFormation()
end


function changeFormationCallback()
    showChangeFormation()
end

function showChangeFormation( ... )
    if not tolua.isnull(_changeFormationLayer) then
        return
    end
    _centerTableView:setVisible(false)
    local bottomBg = _layer:getMemberNodeByName("bottomBg")
    bottomBg:setVisible(false)
    if DataCache.getSwitchNodeState(ksSwitchWarcraft, false) then
        require "script/ui/warcraft/WarcraftLayer"
        _changeFormationLayer = WarcraftLayer.create(_touchPriority - 20)
        local scaleX = g_winSize.width / _changeFormationLayer:getContentSize().width
        local scaleY = _centerHeight / _changeFormationLayer:getContentSize().height
        local scale = math.min(scaleX, scaleY)
        _changeFormationLayer:setScale(scale * 0.94)
    else
        require "script/ui/formation/ChangeFormationLayer"
        local changeFormationBackCallback = function ( ... )
            _centerTableView:setVisible(true)
            bottomBg:setVisible(true)
        end
        _changeFormationLayer = ChangeFormationLayer.create(changeFormationBackCallback, CCSizeMake(g_winSize.width, _centerHeight))
        _changeFormationLayer:setPositionY(-20)
    end

    local centerLayer = _layer:getMemberNodeByName("centerLayer")
    if not tolua.isnull(_curCenterLayer) then
        _curCenterLayer:removeFromParentAndCleanup(true)
    end
    centerLayer:addChild(_changeFormationLayer)
    _curCenterLayer = _changeFormationLayer
end


-- 阵容信息
function formationCallback( cbFlag, dictData, bRet )
    if(dictData.err == "ok") then
        local formationInfo = {}
        if(dictData.ret) then
            for k,v in pairs(dictData.ret) do
                formationInfo["" .. (tonumber(k)-1)] = tonumber(v)
            end
            DataCache.setSquad(formationInfo)
        end
        RequestCenter.getFormationInfo(realFormationCallback)
    end
end

-- 阵型信息
function realFormationCallback( cbFlag, dictData, bRet )
    if(dictData.err == "ok") then
        local real_formationInfo = {}
        if(dictData.ret) then
            for k,v in pairs(dictData.ret) do
                real_formationInfo["" .. (tonumber(k)-1)] = tonumber(v)
            end
            DataCache.setFormationInfo(real_formationInfo)
        end

        local requestCallback = function ( ... )
            create()
        end
        LittleFriendService.getLittleFriendInfoService(requestCallback)
    end
end



function checkInfoAndCreate( ... )
    local formationInfo = DataCache.getSquad()
    if table.isEmpty(formationInfo) then
        RequestCenter.getSquadInfo(formationCallback)
    else
        create()
    end
end

function initOptionAndCenterInfo( ... )
    _lockedOptionInfo = nil
    require "script/ui/formation/FormationUtil"
    local openNum = FormationUtil.getFormationOpenedNum()
    _formationInfo = DataCache.getSquad()
    _optionsInfo = {}
    _centersInfo = {}
    for i = 1, openNum do
        local optionInfo = {}
        optionInfo.optionType = OptionType.HERO
        optionInfo.optionIndex = #_optionsInfo + 1
        optionInfo.centerIndex = #_centersInfo + 1
        table.insert(_optionsInfo, optionInfo)

        local centerInfo = {}
        centerInfo.optionIndex = #_optionsInfo
        table.insert(_centersInfo, centerInfo)
        if i == openNum then
            local hid = _formationInfo[tostring(i - 1)]
            if hid > 0 then
                _lastHeroInfo = HeroUtil.getHeroInfoByHid(hid)
            else
                _lastHeroInfo = nil
            end
        end
    end
    if openNum < g_limitedHerosOnFormation then
        local optionInfo = {}
        optionInfo.optionType = OptionType.HERO
        optionInfo.optionIndex = #_optionsInfo + 1
        optionInfo.isLocked = true
        table.insert(_optionsInfo, optionInfo)
        _lockedOptionInfo = optionInfo
    end

    -- 小伙伴
    local optionInfo = {}
    optionInfo.optionType = OptionType.LITTLE_FRIEND
    optionInfo.optionIndex = #_optionsInfo + 1
    optionInfo.centerIndex = #_centersInfo + 1
    table.insert(_optionsInfo, optionInfo)
    local centerInfo = {}
    centerInfo.optionIndex = #_optionsInfo
    table.insert(_centersInfo, centerInfo)
    -- 助战军
    local optionInfo = {}
    optionInfo.optionType = OptionType.HELPER
    optionInfo.optionIndex = #_optionsInfo + 1
    table.insert(_optionsInfo, optionInfo)
end

function initCurHeroInfo( ... )
    _curHeroInfo = getHeroInfoByOptionIndex(_curOptionIndex)
end

function isInLittleFriendFunc()
    local curOptionInfo = _optionsInfo[_curOptionIndex]
    return curOptionInfo.optionType == OptionType.LITTLE_FRIEND
end

--add by lichenyang
function registerFormationLayerDidLoadCallback( p_callback )
    table.insert(formationLayerDidLoadCallback, p_callback)
end

function registerFormationLayerTouchHeroCallback( p_callback )
    fromationLayerTouchHeroCallback = p_callback
end

function registerSwapHeroCallback( p_callback )
    swapHeroCallback = p_callback
end

-- 是否正在动画
function isOnAnimatingFunc()
    return false
        -- return _isOnAnimating
end



function adaptive( ... )
    local bulletinHeight = BulletinLayer.getLayerHeight() * g_fScaleX
    local menuHeight = MenuLayer.getHeight()

    _layer:setContentSize(g_winSize)

    local bgSprite = _layer:getMemberNodeByName("bgSprite")
    bgSprite:setScale(g_fBgScaleRatio)

    local topBg = _layer:getMemberNodeByName("topBg")
    topBg:setPositionY(g_winSize.height - bulletinHeight)
    topBg:setScale(g_fScaleX)

    local bottomBg = _layer:getMemberNodeByName("bottomBg")
    bottomBg:setScale(g_fScaleX)
    bottomBg:setPositionY(bottomBg:getPositionY() * g_fScaleX)

    local centerLayer = _layer:getMemberNodeByName("centerLayer")
    centerLayer:setPositionY(menuHeight)

    local heroNameBg = _layer:getMemberNodeByName("heroNameBg")
    heroNameBg:setScale(1.2)
end

function addNewGuide(  )
    ---------------------新手引导---------------------------------
    require "script/guide/NewGuide"
    if(NewGuide.guideClass ==  ksGuideFormation and FormationGuide.stepNum == 1) then
        --add by lichenyang 2013.08.29
        require "script/guide/FormationGuide"
        local formationButton = getGuideTopCell()
        local touchRect       = getSpriteScreenRect(formationButton)
        FormationGuide.show(2, touchRect)
    end
    if(NewGuide.guideClass ==  ksGuideFormation and FormationGuide.stepNum == 4) then
        --add by lichenyang 2013.08.29
        require "script/guide/FormationGuide"
        local formationButton = MenuLayer.getMenuItemNode(3)
        local touchRect       = getSpriteScreenRect(formationButton)
        FormationGuide.show(5, touchRect)
    end
    ---------------------end-------------------------------------

    ---[==[ 等级礼包第10步
    ---------------------新手引导---------------------------------
    --add by licong 2013.09.09
    require "script/guide/NewGuide"
    require "script/guide/LevelGiftBagGuide"
    if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 9) then
        local levelGiftBagGuide_button = getGuideTopCell(2)
        local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
        LevelGiftBagGuide.show(10, touchRect)
    end
    ---------------------end-------------------------------------
    --]==]

    ---[==[ 等级礼包第13步
    ---------------------新手引导---------------------------------
    --add by licong 2013.09.09
    require "script/guide/NewGuide"
    require "script/guide/LevelGiftBagGuide"
    if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 12) then
        LevelGiftBagGuide.changLayer()
        local x = g_winSize.width * 0.5 - 120 * getScaleParm()
        local y = g_winSize.height * 0.5 - 180 * getScaleParm()
        local w = 240 * getScaleParm()
        local h = 450 * getScaleParm()
        local touchRect = CCRectMake(x, y, w, h)
        LevelGiftBagGuide.show(13, touchRect)
    end
    ---------------------end-------------------------------------
    --]==]

    ---[==[ 第4个上阵栏位开启 第四个加号
    ---------------------新手引导---------------------------------
    --add by licong 2013.09.09
    require "script/ui/level_reward/LevelRewardLayer"
    require "script/guide/NewGuide"
    require "script/guide/ForthFormationGuide"
    if(NewGuide.guideClass ==  ksGuideForthFormation and ForthFormationGuide.stepNum == 1) then
        local forthFormationGuide_button = getGuideTopCell(3)
        local touchRect = getSpriteScreenRect(forthFormationGuide_button)
        ForthFormationGuide.show(2, touchRect)
    end
    ---------------------end-------------------------------------
    --]==]

    ---[==[铁匠铺 第2步 一键装备按钮
    ---------------------新手引导---------------------------------
    require "script/guide/NewGuide"
    require "script/guide/EquipGuide"
    if(NewGuide.guideClass ==  ksGuideSmithy and EquipGuide.stepNum == 1) then
        local equipButton = getGuideObject()
        local touchRect   = getSpriteScreenRect(equipButton)
        EquipGuide.show(2, touchRect)
    end
    ---------------------end-------------------------------------
    --]==]

    --[[夺宝新手引导]]
    local guideFunc = function ( ... )
        require "script/guide/RobTreasureGuide"
        if(NewGuide.guideClass ==  ksGuideRobTreasure and RobTreasureGuide.stepNum == 8) then
            RobTreasureGuide.changLayer()
            local robTreasure = getGuideObject_3()
            local touchRect   = getSpriteScreenRect(robTreasure)
            RobTreasureGuide.show(9, touchRect)
        end
    end
    local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0),CCCallFunc:create(function ( ... )
        guideFunc()
    end))
    _layer:runAction(seq)

    local guideFunc = function ( ... )
        require "script/guide/RobTreasureGuide"
        if(NewGuide.guideClass ==  ksGuideRobTreasure and RobTreasureGuide.stepNum == 10) then
            local robTreasure = MenuLayer.getMenuItemNode(4)
            local touchRect   = getSpriteScreenRect(robTreasure)
            RobTreasureGuide.show(11, touchRect)
        end
    end
    local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0),CCCallFunc:create(function ( ... )
        guideFunc()
    end))
    _layer:runAction(seq)

    -- 阵法新手引导2
    addGuideWarcraftGuide2()
end

---[==[铁匠铺 第3步
---------------------新手引导---------------------------------
function addGuideEquipGuide3( ... )
    require "script/guide/NewGuide"
    require "script/guide/EquipGuide"
    if(NewGuide.guideClass ==  ksGuideSmithy and EquipGuide.stepNum == 2) then
        local equipButton = getGuideObject_2()
        local touchRect   = getSpriteScreenRect(equipButton)
        EquipGuide.show(3, touchRect)
    end
end
---------------------end-------------------------------------
--]==]

-- 新手引导 start 0
function getGuideTopCell(cellIndex)
    if(cellIndex == nil)then
        cellIndex = 1
    end
    if(_optionTableView)then
        return _optionTableView:cellAtIndex(cellIndex + 1)
    end
    return nil
end

-- 一键装备
function getGuideObject()
    local onekeyEquipBtn = _layer:getMemberNodeByName("onekeyEquipBtn")
    return onekeyEquipBtn
end

-- 武器
function getGuideObject_2()
    return _weaponBtn
end

-- 战马
function getGuideObject_3()
    return _horseBtn
end

-- 得到阵法按钮
function getWarcraftBtn( ... )
    local warcraftBtn = _layer:getMemberNodeByName("changeWarcraftBtn")
    return warcraftBtn
end

---[==[阵法 第2步
---------------------新手引导---------------------------------
function addGuideWarcraftGuide2( ... )
    require "script/guide/NewGuide"
    require "script/guide/WarcraftGuide"
    if(NewGuide.guideClass ==  ksGuideWarcraft and WarcraftGuide.stepNum == 1) then
        local button = getWarcraftBtn()
        local touchRect   = getSpriteScreenRect(button)
        WarcraftGuide.show(2, touchRect)
    end
end
---------------------end-------------------------------------
--]==]


