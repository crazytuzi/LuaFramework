-- Filename：	AddHeroLayer.lua
-- Author：		LLP
-- Date：		2014-12-12
-- Purpose：		选择对手界面

require "script/ui/godweapon/godweaponcopy/ChooseOtherHeroLayer"
require "db/DB_Affix"
require "script/battle/BattleCardUtil"
module("AddHeroLayer", package.seeall)

local _bgLayer 			        = nil
local _OpponentInfo 	        = nil			--对手信息
local _copyInfo 		        = nil			--副本信息
local original_pos              = nil
local _desBg                    = nil
local _unionTableView           = nil

local _hardlv 			        = 0 			--难度
local _buyNum 			        = 0
local _count                    = 0
local _chooseWhich              = 0
local _zorder                   = 100

local isVisibalMiddleUI         = false
local _isAttackBefore 	        = false 		--之前是不是已经打过，上一局平局的情况
local _isChalleng               = false

local began_pos                         --初始卡牌编号
local touchBeganPoint                   --触摸位置
local _began_heroSprite                 --初始开牌
local began_hero_ZOrder                 --初始卡牌z轴
local began_hero_position               --初始卡牌位置

local end_pos                           --卡牌结束位置
local end_sprite
local _inFormationInfo

local chooseData                = {}
local heroCardsTable            = {}
local _unionTable               = {}


function init()
	_bgLayer 			   = nil
    _unionTableView        = nil
	_OpponentInfo 		   = nil
    original_pos           = nil
    touchBeganPoint        = nil
    began_pos              = nil
    _began_heroSprite      = nil
    began_hero_position    = nil
    began_hero_ZOrder      = nil
    end_pos                = nil
    end_sprite             = nil
    _desBg                 = nil

	_hardlv 			= 0 			--难度
    _count              = 0
    _buyNum             = 0
    _chooseWhich        = 0
    _zorder             = 100
	_isAttackBefore 	= false 		--之前是不是已经打过，上一局平局的情况
    isVisibalMiddleUI   = false
    _isChalleng         = false

    chooseData          = {}
    heroCardsTable      = {}
    _inFormationInfo    = {}
    _unionTable         = {}
end

-- 修改阵容 回调
function changeFormationCallback()
    -- 更新缓存数据
    GodWeaponCopyData.setFormationInfo(_inFormationInfo)

    local _copyInfo = GodWeaponCopyData.getCopyInfo()

    local pBenchData = {}
    for i=6,7 do
        pBenchData[i-5] = _inFormationInfo[i]
    end
    GodWeaponCopyData.setBenchData(pBenchData)
    -- added by zhz
    if(_bgLayer== nil) then
        return
    end

    local t_heroIcon = heroCardsTable[end_pos]
    local t_x, t_y = end_sprite:getParent():getPosition()
    local t_position = nil
    local s_position = nil

    t_position = ccp(end_sprite:getParent():getPositionX(), end_sprite:getParent():getPositionY())
    s_position = ccp(_began_heroSprite:getParent():getPositionX(),_began_heroSprite:getParent():getPositionY())
    _began_heroSprite:setPosition(ccp(_began_heroSprite:getParent():getContentSize().width*0.5,_began_heroSprite:getParent():getContentSize().height*0.5))
    _began_heroSprite:getParent():runAction(CCMoveTo:create(0, t_position))
    t_heroIcon:getParent():runAction(CCMoveTo:create(0, s_position))

    -- 交换 英雄 卡牌
    local tempHeroCards = {}
    for n_pos, n_herpCard in pairs(heroCardsTable) do
        if (tonumber(n_pos) ==  tonumber(began_pos)) then
            tempHeroCards[n_pos] = heroCardsTable[end_pos]
        elseif (tonumber(n_pos) == tonumber(end_pos)) then
            tempHeroCards[n_pos] = heroCardsTable[began_pos]
        else
            tempHeroCards[n_pos] = heroCardsTable[n_pos]
        end
    end
    heroCardsTable = tempHeroCards
end

local function changeFormationAction(s_pos, e_pos)
    began_pos = s_pos
    end_pos = e_pos

    local tempFormationInfo = {}

    local real_formation = DataCache.getFormationInfo()
    if(_requestFunc)then
        real_formation = GodWeaponCopyData.getFormationInfo()
    end
    local have = false
    for f_pos, f_hid in pairs(_inFormationInfo) do
        if (tonumber(f_pos) ==  tonumber(began_pos)) then
            if(_inFormationInfo[end_pos]~=nil)then
                tempFormationInfo[f_pos] = _inFormationInfo[end_pos]
            else
                tempFormationInfo[f_pos] = 0
            end
        elseif (tonumber(f_pos) == tonumber(end_pos)) then
            have = true
            tempFormationInfo[f_pos] = _inFormationInfo[began_pos]
        else
            tempFormationInfo[f_pos] = f_hid
        end
        if(have==false)then
            tempFormationInfo[end_pos] = _inFormationInfo[began_pos]
        end
    end

    _inFormationInfo = tempFormationInfo

    if(_isAttackBefore==true)then
        local mainPlayer = CCDictionary:create()
        local otherPlayer = CCDictionary:create()
        for i=0, 5 do
            if(tempFormationInfo[i]~=nil)then
                mainPlayer:setObject(CCInteger:create(tempFormationInfo[i]), i)
            end
        end
        local args1 = CCArray:create()
        for i=6, 7 do
            if(tempFormationInfo[i]~=nil)then
                if (tempFormationInfo[i] > 0) then
                    otherPlayer:setObject(CCInteger:create(tempFormationInfo[i]), i-6)
                end
            end
        end

        require "script/network/RequestCenter"

        local args = CCArray:create()
        args:addObject(mainPlayer)
        args:addObject(otherPlayer)

        GodWeaponCopyService.changePosCommond(changeFormationCallback,args)
    else
        changeFormationCallback()
    end
end

--界面起始结束
local function onTouchesHandler( eventType, x, y )
    if (eventType == "began") then

        if(_isOnAnimating == true)then
            return false
        end
        began_pos = nil
        _began_heroSprite = nil
        began_hero_position = nil
        began_hero_ZOrder = nil
        original_pos = nil

        touchBeganPoint = ccp(x, y)
        local isTouch = false

        -- 更换阵型
        for pos, heroCard in pairs(heroCardsTable) do
            local bPosition = heroCard:convertToNodeSpace(touchBeganPoint)
            if ( bPosition.x >0 and bPosition.x <  heroCard:getContentSize().width and bPosition.y > 0 and bPosition.y < heroCard:getContentSize().height ) then
                if(_inFormationInfo[pos]~=nil)then
                    if (_inFormationInfo[pos]>0) then
                        local tempX, tempY  = heroCard:getPosition()
                        isTouch = true
                        began_pos = pos
                        _began_heroSprite = heroCardsTable[began_pos]

                        began_hero_position = ccp(tempX, tempY)

                        original_pos = ccp(tempX, tempY)
                        -- 修改 Z轴
                        began_hero_ZOrder = heroCard:getZOrder()
                        local parent_node = _began_heroSprite:getParent()
                        parent_node:getParent():reorderChild(parent_node,9999)
                        parent_node:reorderChild(_began_heroSprite, 9999)
                    else
                        isTouch = false
                    end
                end
                if(tonumber(pos)>5 and _isAttackBefore==false)then
                    addAction(pos-5,nil)
                end
                break
            else
                isTouch = false
            end
        end

        return isTouch
    elseif (eventType == "moved") then
        if (BTUtil:getGuideState() == true) then
            return
        end
        if(_isAttackBefore==false)then
            return
        end
        _began_heroSprite:setPosition(ccp( (x - touchBeganPoint.x)/MainScene.elementScale + began_hero_position.x , (y - touchBeganPoint.y)/MainScene.elementScale + began_hero_position.y))
    else
        local xOffset = x - touchBeganPoint.x
        if (BTUtil:getGuideState() == true) then
            xOffset = 0
            _isInLittleFriend = false
        end

        -- 移动修改阵容界面的 hero
        local isChanged = false
        local changedHero = nil

        local temp = ccp(_began_heroSprite:getContentSize().width/2,_began_heroSprite:getContentSize().height/2 )
        local e_position = _began_heroSprite:convertToWorldSpace(ccp(temp.x,temp.y))
        for pos, card_hero in pairs(heroCardsTable) do
            if(pos ~= began_pos) then
                local bPosition = card_hero:convertToNodeSpace(e_position)
                if ( bPosition.x >0 and bPosition.x <  card_hero:getContentSize().width and bPosition.y > 0 and bPosition.y < card_hero:getContentSize().height ) then
                    isChanged = true
                    if(tonumber(pos)<6 and tonumber(began_pos)>5)then
                        local _copyInfo = GodWeaponCopyData.getCopyInfo()
                        if(_copyInfo["va_pass"]["heroInfo"][tostring(_inFormationInfo[began_pos])]~=nil)then
                            local hp = _copyInfo["va_pass"]["heroInfo"][tostring(_inFormationInfo[began_pos])]["currHp"]
                            if(tonumber(hp)<=0)then
                                AnimationTip.showTip(GetLocalizeStringBy("llp_168"))
                                isChanged = false
                            end
                        end
                    end

                    if(tonumber(pos)>5 and tonumber(began_pos)<6)then
                        local _copyInfo = GodWeaponCopyData.getCopyInfo()
                        if(_copyInfo["va_pass"]["heroInfo"][tostring(_inFormationInfo[pos])]~=nil)then
                            local hp = _copyInfo["va_pass"]["heroInfo"][tostring(_inFormationInfo[pos])]["currHp"]
                            if(tonumber(hp)<=0)then
                                AnimationTip.showTip(GetLocalizeStringBy("llp_168"))
                                isChanged = false
                            end
                        end
                        local noAllDead = false
                        for k,v in pairs(_inFormationInfo)do
                            if(tonumber(_inFormationInfo[k])~=0)then
                                if(tonumber(k)<6)then
                                    local eachHp = tonumber(_copyInfo["va_pass"]["heroInfo"][tostring(_inFormationInfo[k])]["currHp"])
                                    if(tonumber(v)~=tonumber(_inFormationInfo[began_pos]) and eachHp~=0)then
                                        noAllDead = true
                                    end
                                end
                            end
                        end
                        if(noAllDead==false)then
                            isChanged = false
                        end
                    end
                    changedHero = card_hero
                    end_sprite = heroCardsTable[pos]
                    end_pos =  pos
                    break
                end
            else
                if(_isAttackBefore == true)then

                else
                    if(tonumber(began_pos)==6 or tonumber(began_pos)==7)then
                        addAction(began_pos-5,nil)
                    end
                end
            end
        end

        if (isChanged == false) then
            _began_heroSprite:runAction(CCMoveTo:create(0.2, original_pos))
            -- 修改 Z轴
            local parent_node = _began_heroSprite:getParent()
            if tonumber(began_pos) >= 4 then
                parent_node:reorderChild(_began_heroSprite, 10)
            else
                parent_node:reorderChild(_began_heroSprite, 20)
            end

        else
            changeFormationAction(began_pos, end_pos)
        end
    end
end

-- 战斗结算面板的确定回调
function afterBattleCallback( isWin )

    if( isWin == true and GodWeaponCopyData.isHavePass() )then
        GodCopyUtil.showPassAllEffect()
    end
    if(isWin == true and GodWeaponCopyData.justRemainOnce() == true )then
        -- 如果战斗胜利 且 已经完成所有
        GodWeaponCopyMainLayer.nextSenceEffect()
    else
        GodWeaponCopyMainLayer.refreshFunc()
    end
end


--战斗命令回调
function attackCommondCallBack( attackInfo )
    -- body

    require "script/battle/BattleLayer"
    require "script/ui/godweapon/godweaponcopy/CopyAfterBattleLayer"

    local base64Data = Base64.decodeWithZip(attackInfo.fightStr)
    local data = amf3.decode(base64Data)

    GodWeaponCopyData.setEnterInfo(attackInfo.va_pass,attackInfo.cur_base,attackInfo.pass_num,attackInfo.point,attackInfo.star_star,attackInfo.lose_num,attackInfo.buy_num)
    local layer = CopyAfterBattleLayer.createAfterBattleLayer(attackInfo,data,_chooseWhich  , afterBattleCallback)
    BattleLayer.showBattleWithString(attackInfo.fightStr, nil,layer, "ducheng.jpg",nil,nil,nil,nil,true)

    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
end

function sureUpgrade(sureUp)
    local _copyInfo = GodWeaponCopyData.getCopyInfo()
    if sureUp == true then
        local args = CCArray:create()
        local args1 = CCArray:create()
        args:addObject(CCInteger:create(tonumber(_copyInfo.cur_base)))
        args:addObject(CCInteger:create(_chooseWhich))
        if(chooseData~=nil)then
            for k,v in pairs(chooseData)do
                args1:addObject(CCInteger:create(v))
                print("wojinlaile")
            end
        end
        args:addObject(args1)
        GodWeaponCopyService.attack(attackCommondCallBack,args)


        local attackData = {}
        if(_isAttackBefore==false)then
            GodWeaponCopyData.setChooseHeroData(attackData)
        end
    end
end

function challengeAction( p_tag,p_itemBtn )
    -- 背包满了
    print("_isAttackBefore=====",tostring(_isAttackBefore))
    if(ItemUtil.isBagFull() == true )then
        return
    end
    local _copyInfo = GodWeaponCopyData.getCopyInfo()
    _chooseWhich = GodWeaponCopyData.getChooseWhich()
    if(_isAttackBefore==false)then
        chooseData = GodWeaponCopyData.getChooseHeroData()
        if(table.isEmpty(chooseData))then
            AlertTip.showAlert(GetLocalizeStringBy("llp_157"), sureUpgrade, true, nil, GetLocalizeStringBy("key_1985"),GetLocalizeStringBy("key_1202"))
            return
        end

        if(table.count(chooseData)<2)then
            AlertTip.showAlert(GetLocalizeStringBy("llp_158"), sureUpgrade, true, nil, GetLocalizeStringBy("key_1985"),GetLocalizeStringBy("key_1202"))
            return
        end

        AlertTip.showAlert(GetLocalizeStringBy("llp_159"), sureUpgrade, true, nil, GetLocalizeStringBy("key_1985"),GetLocalizeStringBy("key_1202"))
    else
        chooseData = {}
        local args = CCArray:create()
        local args1 = CCArray:create()
        args:addObject(CCInteger:create(tonumber(_copyInfo.cur_base)))
        args:addObject(CCInteger:create(_chooseWhich))

        args:addObject(args1)
        GodWeaponCopyService.attack(attackCommondCallBack,args)


        local attackData = {}
        if(_isAttackBefore==false)then
            GodWeaponCopyData.setChooseHeroData(attackData)
        end
    end
end

--layer点击事件
local function onNodeEvent( event )
	if (event == "enter") then
        GodWeaponCopyMainLayer.setClick(false)
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -550, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
        GodWeaponCopyMainLayer.setClick(true)
		_bgLayer:unregisterScriptTouchHandler()
	end
end

--返回事件
function backAction(tag,itembtn)
	-- 隐藏中间
	GodWeaponCopyMainLayer.setMiddleItemVisible(true)
    GodWeaponCopyMainLayer.refreshFunc()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
    local attackData = {}
    if(_isAttackBefore==false)then
        GodWeaponCopyData.setChooseHeroData(attackData)
    end
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil

end

function dealWithData()
    --选了的英雄的数据
    local _copyInfo = GodWeaponCopyData.getCopyInfo()
    if(_isAttackBefore==false)then
        chooseData = GodWeaponCopyData.getChooseHeroData()
    else
        if(not table.isEmpty(_copyInfo.va_pass.bench))then
            for i=1,2 do
                chooseData[i] = tonumber(_copyInfo.va_pass.bench[i])
            end
        end
    end

    local pData = GodWeaponCopyData.getCopyInfo()

    require "script/ui/formation/FormationUtil"
    local real_formation = DataCache.getFormationInfo()

    local index = 0

    local formationData = GodWeaponCopyData.getFormationInfo()
    if(not table.isEmpty(pData.va_pass.formation))then
        for h_id,v in pairs(pData.va_pass.formation) do
            index = index + 1
            if(tonumber(v)>0)then
                _inFormationInfo[index-1] = tonumber(v)
            elseif(FormationUtil.isOpenedByPosition(index-1))then
                _inFormationInfo[index-1] = 0
            else
                _inFormationInfo[index-1] = -1
            end
        end
        if(not table.isEmpty(pData.va_pass.bench))then
            for i=1,2 do
                _inFormationInfo[tonumber(index+i-1)] = tonumber(pData.va_pass.bench[i])
            end
        end
    else
        local haveSame = false

        for f_pos, f_hid in pairs(real_formation) do
            if(tonumber(f_hid)>0)then
                _inFormationInfo[tonumber(f_pos)] = tonumber(f_hid)
            elseif(FormationUtil.isOpenedByPosition(f_pos))then
                _inFormationInfo[tonumber(f_pos)] = 0
            else
                _inFormationInfo[tonumber(f_pos)] = -1
            end
            index = index + 1
        end

        if(not table.isEmpty(chooseData))then
            for k,v in pairs(chooseData)do
                for i,j in pairs(_inFormationInfo)do
                    if(tonumber(j)==tonumber(v))then
                        haveSame = true
                    end
                end
                if(haveSame == false)then
                    table.insert(_inFormationInfo,v)
                end
            end
        end
        if(not table.isEmpty(pData.va_pass.bench))then
            for k,v in pairs(pData.va_pass.bench) do
                if(tonumber(v)~=0)then
                    for k,v in pairs(pData.va_pass.bench) do
                        _inFormationInfo[tonumber(k+1)]=pData.va_pass.bench[tonumber(k+1)]
                    end
                end
            end
        end
    end
end
--添加武将内个加号
function addAction( tag,itembtn )
    -- body
    if(_isChalleng==true)then
        local layer = ChooseOtherHeroLayer.createLayer(tonumber(tag))
        local scene = CCDirector:sharedDirector():getRunningScene()
        scene:addChild(layer,200,1500)

        require "script/audio/AudioUtil"
        AudioUtil.playEffect("audio/effect/guanbi.mp3")

        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer = nil
    end
end

function isAttackBefore( ... )
    -- body
    local _copyInfo = GodWeaponCopyData.getCopyInfo()

    local attackBefore = false

    if(not table.isEmpty(_copyInfo.va_pass.heroInfo))then
        attackBefore = true
    end
    return attackBefore
end

function createCell( p_Index )
    local cell = CCTableViewCell:create()
    local str = _unionTable[p_Index].name.."+".._unionTable[p_Index].value.."%"

    local unionLabel = CCLabelTTF:create(str,g_sFontName,23)
    cell:addChild(unionLabel)
    unionLabel:setAnchorPoint(ccp(0,0.5))
    local y = p_Index%2

    if(y==0)then
        unionLabel:setPosition(ccp(_desBg:getContentSize().width*0.50,20))
    else
        unionLabel:setPosition(ccp(_desBg:getContentSize().width*0.12,0))
    end

    return cell
end

function handleUnionData( ... )
    -- body
    local index = 0
    local _copyInfo = GodWeaponCopyData.getCopyInfo()
    if(not table.isEmpty(_copyInfo.va_pass.unionInfo))then
        for k,v in pairs(_copyInfo.va_pass.unionInfo)do
            index = index + 1
            local unionData = DB_Affix.getDataById(tonumber(k))
            local value = tonumber(v)/100
            local str = unionData.displayName.."+"..value.."%"
            _unionTable[index] = {}
            _unionTable[index].name = unionData.displayName
            _unionTable[index].value = value
        end
    end
    if(_copyInfo.va_pass.unionInfo~=nil)then
        for k,v in pairs(_copyInfo.va_pass.unionInfo)do
            _count = _count+1
        end
    end
end

-- 创建联协的tableview
local function createGiftTableView( )
    local cellSize = CCSizeMake(100, 20)
    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = cellSize
        elseif fn == "cellAtIndex" then
            a2 = createCell(a1+1)
            r = a2
        elseif fn == "numberOfCells" then
            r = _count
        elseif fn == "cellTouched" then
        elseif (fn == "scroll") then

        end
        return r
    end)

    _unionTableView = LuaTableView:createWithHandler(h, CCSizeMake(550, 100))
    _unionTableView:setBounceable(true)
    _unionTableView:setDirection(kCCScrollViewDirectionVertical)
    _unionTableView:setPosition(ccp(22, 10))
    _unionTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _desBg:addChild(_unionTableView,1)
    _unionTableView:reloadData()
end

function createLayOut( ... )
    -- body
    -- body
    _isAttackBefore = isAttackBefore()
    local _copyInfo = GodWeaponCopyData.getCopyInfo()


    dealWithData()
    handleUnionData()

    -- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-551)
    _bgLayer:addChild(menu,99)

    --  返回
    local _BackItem= LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(213,73),GetLocalizeStringBy("key_3290"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _BackItem:setAnchorPoint(ccp(0.5,0))
    _BackItem:setPosition(_bgLayer:getContentSize().width*0.25, 8)
    _BackItem:setScale(g_fScaleY )
    _BackItem:registerScriptTapHandler(backAction)
    menu:addChild(_BackItem,1)

    --  战斗
    local _battleItem= LuaCC.create9ScaleMenuItem("images/common/btn/btn_red_n.png","images/common/btn/btn_red_h.png",CCSizeMake(213, 73),GetLocalizeStringBy("key_2565"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _battleItem:setAnchorPoint(ccp(0.5,0))
    _battleItem:setPosition(_bgLayer:getContentSize().width*0.75, 8)
    _battleItem:setScale(g_fScaleY )
    _battleItem:registerScriptTapHandler(challengeAction)
    menu:addChild(_battleItem,1)

    -- 判断是否是挑战界面进来的
    if(_isChalleng==false)then
        _battleItem:setVisible(false)
        _BackItem:setPosition(ccp(_bgLayer:getContentSize().width*0.5, 8))
    end
    -- 当前阵型图片
    local styleSprite = CCScale9Sprite:create("images/godweaponcopy/now.png")

    local fullRect = CCRectMake(0,0,187,30)
    local insetRect = CCRectMake(84,10,12,18)
    local bgSprite = CCScale9Sprite:create("images/godweaponcopy/blackred.png", fullRect, insetRect)
    bgSprite:setContentSize(CCSizeMake(g_winSize.width, g_winSize.height-_battleItem:getContentSize().height*g_fScaleY-8*g_fScaleY-styleSprite:getContentSize().height*g_fScaleY*0.5))
    _bgLayer:addChild(bgSprite,0,1)
    bgSprite:setAnchorPoint(ccp(0.5,1))

    local bottomLineSprite = CCSprite:create("images/godweaponcopy/21.png")
    bottomLineSprite:setScale(g_fScaleY )
    bottomLineSprite:setAnchorPoint(ccp(0.5,0))
    bgSprite:addChild(bottomLineSprite)
    bottomLineSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5,0))

    styleSprite:setAnchorPoint(ccp(0.5,0.5))
    styleSprite:setScale(g_fScaleY )
    styleSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height))
    bgSprite:addChild(styleSprite)

    bgSprite:setPosition(ccp(g_winSize.width*0.5, g_winSize.height-styleSprite:getContentSize().height*g_fScaleY*0.5))

    local leftFlower = CCScale9Sprite:create("images/god_weapon/flower.png")
    leftFlower:setScale(g_fScaleY )
    leftFlower:setAnchorPoint(ccp(1,0.5))
    leftFlower:setPosition(ccp(bgSprite:getContentSize().width*0.5-styleSprite:getContentSize().width*g_fScaleY*0.5,bgSprite:getContentSize().height))
    bgSprite:addChild(leftFlower)

    local rightFlower = CCScale9Sprite:create("images/god_weapon/flower.png")
    -- rightFlower:setScale(MainScene.elementScale )
    rightFlower:setScale(-g_fScaleY)
    rightFlower:setAnchorPoint(ccp(1,0.5))
    rightFlower:setPosition(ccp(bgSprite:getContentSize().width*0.5+styleSprite:getContentSize().width*g_fScaleY*0.5,bgSprite:getContentSize().height))
    bgSprite:addChild(rightFlower)

    local desLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_155"),g_sFontName,18)
    desLabel:setScale(g_fScaleY )
    bgSprite:addChild(desLabel)
    desLabel:setAnchorPoint(ccp(0.5,0))
    desLabel:setPosition(ccp(bgSprite:getContentSize().width*0.5,bottomLineSprite:getContentSize().height*g_fScaleY))

    _desBg= CCScale9Sprite:create("images/common/bg/9s_1.png")
    _desBg:setScale(g_fScaleX)
    _desBg:setContentSize(CCSizeMake(581,114))
    _desBg:setPosition(bgSprite:getContentSize().width/2, desLabel:getPositionY()+desLabel:getContentSize().height*g_fScaleY)
    _desBg:setAnchorPoint(ccp(0.5,0))
    createGiftTableView()

    bgSprite:addChild(_desBg,11,10)

    local buffAddSprite = CCScale9Sprite:create("images/godweaponcopy/buffadd.png")
    buffAddSprite:setAnchorPoint(ccp(0.5,0.5))
    buffAddSprite:setPosition(ccp(_desBg:getContentSize().width*0.5,_desBg:getContentSize().height))
    _desBg:addChild(buffAddSprite,0,10)

    --阵下武将 如果选择了 就是英雄图片 没选择 就是一个闪烁的加号
    for i=6,7 do
        local card = CCScale9Sprite:create("images/common/blank_card.png", CCRectMake(0, 0, 77, 82), CCRectMake(38, 39, 2, 3))
        card:setPreferredSize(CCSizeMake(128, 150))
        card:setScale(g_fScaleY )
        card:setAnchorPoint(ccp(0.5,0))
        card:setPosition(ccp(bgSprite:getContentSize().width*0.25+bgSprite:getContentSize().width*(i-6)*0.5,_desBg:getPositionY()+_desBg:getContentSize().height*g_fScaleX+buffAddSprite:getContentSize().height*0.5*g_fScaleY))
        bgSprite:addChild(card,0,i)

        local addItem = nil

        if(not table.isEmpty(chooseData) and chooseData[i-5]~=nil)then
            if(tonumber(chooseData[i-5])~=0)then
                local bodySprite = BattleCardUtil.getBattlePlayerCardImage(chooseData[i-5], false)
                --设置血量
                --setCardHp
                if(_copyInfo["va_pass"]["heroInfo"]~=nil)then
                    local currHp = tonumber(_copyInfo["va_pass"]["heroInfo"][tostring(chooseData[i-5])]["currHp"])
                    local totalHp = tonumber(_copyInfo["percentBase"])
                    local scale = currHp/totalHp

                    BattleCardUtil.setCardHp(bodySprite,scale)
                    if(currHp == 0)then
                        local deadSprite = CCSprite:create("images/godweaponcopy/dead.png")
                        bodySprite:addChild(deadSprite,1000,chooseData[i-5])
                        deadSprite:setAnchorPoint(ccp(0,1))
                        deadSprite:setPosition(ccp(-30,bodySprite:getContentSize().height+40))
                    end
                else
                    BattleCardUtil.setCardHp(bodySprite,1)
                end
                heroCardsTable[i] = bodySprite
                bodySprite:setAnchorPoint(ccp(0.5,0.5))
                card:addChild(bodySprite,0,i)
                bodySprite:setPosition(ccp(card:getContentSize().width*0.5,card:getContentSize().height*0.5))
            else
                local bodySprite = CCNode:create()
                bodySprite:ignoreAnchorPointForPosition(false)
                bodySprite:setContentSize(CCSizeMake(128, 150))
                heroCardsTable[i] = bodySprite
                bodySprite:setAnchorPoint(ccp(0.5,0.5))
                card:addChild(bodySprite,0,i)
                bodySprite:setPosition(ccp(card:getContentSize().width*0.5,card:getContentSize().height*0.5))
            end
        else
            addItem = CCSprite:create("images/common/add.png")
            heroCardsTable[i] = addItem
            local arrActions_2 = CCArray:create()
            arrActions_2:addObject(CCFadeOut:create(1))
            arrActions_2:addObject(CCFadeIn:create(1))
            local sequence_2 = CCSequence:create(arrActions_2)
            local action_2 = CCRepeatForever:create(sequence_2)
            addItem:runAction(action_2)
            addItem:setAnchorPoint(ccp(0.5,0.5))
            card:addChild(addItem,0,i)
            addItem:setPosition(ccp(card:getContentSize().width*0.5,card:getContentSize().height*0.5))

            if(_isAttackBefore ==true or _isChalleng == false)then
                addItem:setVisible(false)
            end
        end
    end
    --战斗前和战斗后 阵下武将或者副将
    local downHeroSprite = nil
    if(_isAttackBefore==true)then
        downHeroSprite = CCSprite:create("images/godweaponcopy/downhero.png")
    else
        downHeroSprite = CCSprite:create("images/godweaponcopy/fujiang.png")
    end
    downHeroSprite:setScale(g_fScaleY )

    local leftLine = CCScale9Sprite:create("images/god_weapon/cut_line.png")
    leftLine:setScale(g_fScaleY )
    leftLine:setAnchorPoint(ccp(1,0.5))
    leftLine:setPosition(ccp(bgSprite:getContentSize().width*0.5-styleSprite:getContentSize().width*g_fScaleY*0.5,bgSprite:getChildByTag(6):getPositionY()+bgSprite:getChildByTag(6):getContentSize().height*g_fScaleY+downHeroSprite:getContentSize().height*g_fScaleY*0.5+25))
    bgSprite:addChild(leftLine)

    local rightLine = CCScale9Sprite:create("images/god_weapon/cut_line.png")
    local scale = tonumber(g_fScaleY)
    rightLine:setScale(-scale )
    rightLine:setAnchorPoint(ccp(1,0.5))
    rightLine:setPosition(ccp(bgSprite:getContentSize().width*0.5+styleSprite:getContentSize().width*g_fScaleY*0.5,bgSprite:getChildByTag(6):getPositionY()+bgSprite:getChildByTag(6):getContentSize().height*g_fScaleY+downHeroSprite:getContentSize().height*g_fScaleY*0.5+25))
    bgSprite:addChild(rightLine)

    bgSprite:addChild(downHeroSprite)
    downHeroSprite:setAnchorPoint(ccp(0.5,0.5))
    downHeroSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getChildByTag(6):getPositionY()+bgSprite:getChildByTag(6):getContentSize().height*g_fScaleY+downHeroSprite:getContentSize().height*g_fScaleY*0.5+25))

    --当前阵型
    local index = 0
    local totalIndex = table.count(_inFormationInfo)

    for i=0,5 do
        local card = CCScale9Sprite:create("images/common/blank_card.png", CCRectMake(0, 0, 77, 82), CCRectMake(38, 39, 2, 3))
        card:setScale(g_fScaleY )
        card:setPreferredSize(CCSizeMake(128, 150))
        card:setAnchorPoint(ccp(0.5,0))
        bgSprite:addChild(card,0,i)
        index = index + 1
        if(index <= totalIndex)then
            local hid = _inFormationInfo[(i)]
            if(tonumber(hid)~=0)then
                local heroSp = BattleCardUtil.getBattlePlayerCardImage(hid, false)
                --设置血量
                --setCardHp
                if(_copyInfo["va_pass"]["heroInfo"]~=nil)then
                    local currHp = tonumber(_copyInfo["va_pass"]["heroInfo"][tostring(hid)]["currHp"])
                    local totalHp = tonumber(_copyInfo["percentBase"])
                    local scale = currHp/totalHp
                    BattleCardUtil.setCardHp(heroSp,scale)
                    if(currHp == 0)then
                        local deadSprite = CCSprite:create("images/godweaponcopy/dead.png")
                        heroSp:addChild(deadSprite,1000,hid)
                        deadSprite:setAnchorPoint(ccp(0,1))
                        deadSprite:setPosition(ccp(-30,heroSp:getContentSize().height+40))
                    end
                else
                    BattleCardUtil.setCardHp(heroSp,1)
                end


                heroSp:reorderChild(heroSp:getChildByTag(6),2)
                heroCardsTable[i] = heroSp
                heroSp:setAnchorPoint(ccp(0.5, 0.5))
                card:addChild(heroSp,0,i)
                heroSp:setPosition(ccp(card:getContentSize().width*0.5,card:getContentSize().height*0.5))
            else
                local heroSp = CCNode:create()
                heroSp:ignoreAnchorPointForPosition(false)
                heroSp:setContentSize(CCSizeMake(128, 150))
                heroCardsTable[i] = heroSp
                heroSp:setAnchorPoint(ccp(0.5, 0.5))
                card:addChild(heroSp,0,i)
                heroSp:setPosition(ccp(card:getContentSize().width*0.5,card:getContentSize().height*0.5))
            end
        end
        if(i<3)then
            card:setPosition(ccp(bgSprite:getContentSize().width*(0.2+0.3*i),rightLine:getPositionY()+downHeroSprite:getContentSize().height*g_fScaleY*0.5+card:getContentSize().height*g_fScaleY+135*g_fScaleY))
        else
            card:setPosition(ccp(bgSprite:getContentSize().width*(0.2+0.3*(i-3)),rightLine:getPositionY()+downHeroSprite:getContentSize().height*g_fScaleY*0.5+70*g_fScaleY))
        end
    end

    local midDesLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_156"),g_sFontName,18)
    midDesLabel:setScale(g_fScaleY )
    midDesLabel:setColor(ccc3(0xff,0xf6,0x00))
    bgSprite:addChild(midDesLabel)
    midDesLabel:setAnchorPoint(ccp(0.5,0))
    midDesLabel:setPosition(ccp(bgSprite:getContentSize().width*0.5,rightLine:getPositionY()+downHeroSprite:getContentSize().height*g_fScaleY*0.5+15))

end

function createLayer( ... )
	-- 底层
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

    createLayOut()

	return _bgLayer
end

function showLayer(p_Challenge)
	init()

    _chooseWhich = p_tag
    _isChalleng  = p_Challenge
	local pLayer = createLayer()

	--把layer加到runningScene上
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(pLayer,_zorder)
end
