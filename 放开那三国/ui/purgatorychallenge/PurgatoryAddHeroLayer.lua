-- Filename：    PurgatoryAddHeroLayer.lua
-- Author：      LLP
-- Date：        2015-5-28
-- Purpose：     炼狱副本选择上阵英雄界面

require "script/ui/purgatorychallenge/PurgatoryEnemyLayer"
require "script/ui/purgatorychallenge/PurgatoryUnionLayer"
require "script/ui/purgatorychallenge/PurgatoryHeroInfoLayer"
require "db/DB_Lianyutiaozhan_rule"
require "script/fight/node/CardSprite"
require "script/model/user/UserModel"
require "script/ui/item/ItemUtil"
module("PurgatoryAddHeroLayer", package.seeall)

local _bgLayer                  = nil
local _OpponentInfo             = nil           --对手信息
local _copyInfo                 = nil           --副本信息
local _original_pos             = nil
local _desBg                    = nil
local _rightLine                = nil
local _downHeroSprite           = nil
local _refreshItem              = nil
local _pTable                   = nil
local _labelFresh               = nil
local _hardlv                   = 0             --难度
local _buyNum                   = 0
local _count                    = 0
local _chooseWhich              = 0
local _itemNum                  = 0
local cost                      = 0
local _zorder                   = 100
local _isItemBuy                = false
local _isChalleng               = false

local _began_pos                         --初始卡牌编号
local _touchBeganPoint                   --触摸位置
local _began_heroSprite                 --初始开牌
local _began_hero_position               --初始卡牌位置

local end_pos                           --卡牌结束位置
local end_sprite
local _inFormationInfo          = {}
local chooseData                = {}
local heroCardsTable            = {}

function init()
    _pTable                   = nil
    _bgLayer                  = nil
    _OpponentInfo             = nil
    _original_pos             = nil
    _touchBeganPoint          = nil
    _began_pos                = nil
    _began_heroSprite         = nil
    _began_hero_position      = nil
    end_pos                   = nil
    end_sprite                = nil
    _desBg                    = nil
    _rightLine                = nil
    _downHeroSprite           = nil
    _refreshItem              = nil
    _labelFresh               = nil

    _hardlv             = 0             --难度
    _count              = 0
    _buyNum             = 0
    _chooseWhich        = 0
    _zorder             = 100
    _isItemBuy          = false
    _isChalleng         = false

    chooseData          = {}
    heroCardsTable      = {}
    _inFormationInfo    = {}
end

-- 修改阵容 回调
function changeFormationCallback()
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
        if (tonumber(n_pos) ==  tonumber(_began_pos)) then
            tempHeroCards[n_pos] = heroCardsTable[end_pos]
        elseif (tonumber(n_pos) == tonumber(end_pos)) then
            tempHeroCards[n_pos] = heroCardsTable[_began_pos]
        else
            tempHeroCards[n_pos] = heroCardsTable[n_pos]
        end
    end
    heroCardsTable = tempHeroCards
    freshNewHero()
end

local function changeFormationAction(s_pos, e_pos)
    _began_pos = s_pos
    end_pos = e_pos

    local tempFormationInfo = {}

    local real_formation = DataCache.getFormationInfo()
    if(_requestFunc)then
        real_formation = PurgatoryData.getFormationInfo()
    end
    local have = false
    for f_pos, f_hid in pairs(_inFormationInfo) do
        if (tonumber(f_pos) ==  tonumber(_began_pos)) then
            if(_inFormationInfo[end_pos]~=nil)then
                tempFormationInfo[f_pos] = _inFormationInfo[end_pos]
            else
                tempFormationInfo[f_pos] = 0
            end
        elseif (tonumber(f_pos) == tonumber(end_pos)) then
            have = true
            tempFormationInfo[f_pos] = _inFormationInfo[_began_pos]
        else
            tempFormationInfo[f_pos] = f_hid
        end
        if(have==false)then
            tempFormationInfo[end_pos] = _inFormationInfo[_began_pos]
        end
    end

    _inFormationInfo = tempFormationInfo
    changeFormationCallback()
end

--判断上阵人数超没超
function canChange( p_began,p_end )
    -- body
    local _copyInfo = PurgatoryData.getCopyInfo()
    local heroCount = 0
    local haveSame = false
    local sameId = 0
    if(p_began>5 and p_end>5)then
        return true
    end
    for k,v in pairs(heroCardsTable)do
        if(tonumber(k)>5 and heroCardsTable[k]._model~=nil and heroCardsTable[p_began]._model~=nil)then
            if(heroCardsTable[k]._model:getName()==heroCardsTable[p_began]._model:getName())then
                haveSame = true
                break
            end
        end
    end
    if(haveSame==true and heroCardsTable[p_end]._model~=nil and heroCardsTable[p_began]._model~=nil and heroCardsTable[p_began]._model:getName()~=heroCardsTable[p_end]._model:getName())then
        return false
    else
        if(heroCardsTable[p_end]._model==nil and haveSame==true)then
            return false
        end
    end
    for i=6,11 do
        if(tonumber(_inFormationInfo[i])>0)then
            heroCount = heroCount+1
        end
    end
    local canUpNum = tonumber(_copyInfo.passed_stage)+1
    if(heroCount>=canUpNum)then
        if(heroCount==canUpNum and tonumber(_inFormationInfo[p_began])>0 and tonumber(_inFormationInfo[p_end])>0 or tonumber(_began_pos)>5)then
            return true
        else
            return false
        end
    else
        return true
    end
end

-- 获得英雄的信息
local function getHeroData( htid)
    value = {}

    value.htid = htid
    require "db/DB_Heroes"
    local db_hero = DB_Heroes.getDataById(htid)
    value.country_icon = HeroModel.getCiconByCidAndlevel(db_hero.country, db_hero.star_lv)
    value.name = db_hero.name
    value.level = db_hero.lv
    value.star_lv = db_hero.star_lv
    value.hero_cb = menu_item_tap_handler
    value.head_icon = "images/base/hero/head_icon/" .. db_hero.head_icon_id
    value.quality_bg = "images/hero/quality/"..value.star_lv .. ".png"
    value.quality_h = "images/hero/quality/highlighted.png"
    value.type = "HeroFragment"
    value.isRecruited = false
    value.evolve_level = 0

    return value
end

--界面起始结束
local function onTouchesHandler( eventType, x, y )
    if (eventType == "began") then

        if(_isOnAnimating == true)then
            return false
        end
        _began_pos = nil
        _began_heroSprite = nil
        _began_hero_position = nil
        _original_pos = nil

        _touchBeganPoint = ccp(x, y)
        local isTouch = false

        -- 更换阵型
        for pos, heroCard in pairs(heroCardsTable) do

            local bPosition = heroCard:convertToNodeSpace(_touchBeganPoint)
            if ( bPosition.x >0 and bPosition.x <  heroCard:getContentSize().width and bPosition.y > 0 and bPosition.y < heroCard:getContentSize().height ) then
                if(_inFormationInfo[pos]~=nil)then
                    if (_inFormationInfo[pos]>=0) then
                        local tempX, tempY  = heroCard:getPosition()
                        isTouch = true
                        _began_pos = pos
                        _began_heroSprite = heroCardsTable[_began_pos]

                        _began_hero_position = ccp(tempX, tempY)

                        _original_pos = ccp(tempX, tempY)
                        -- 修改 Z轴
                        local parent_node = _began_heroSprite:getParent()
                        parent_node:getParent():reorderChild(parent_node,9999)
                        parent_node:reorderChild(_began_heroSprite, 9999)
                    else
                        isTouch = false
                    end
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
        _began_heroSprite:setPosition(ccp( (x - _touchBeganPoint.x)/(g_fScaleY*0.7) + _began_hero_position.x , (y - _touchBeganPoint.y)/(g_fScaleY*0.7) + _began_hero_position.y))
    else
        local xOffset = x - _touchBeganPoint.x
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
            if(pos ~= _began_pos) then
                local bPosition = card_hero:convertToNodeSpace(e_position)
                if ( bPosition.x >0 and bPosition.x <  card_hero:getContentSize().width and bPosition.y > 0 and bPosition.y < card_hero:getContentSize().height ) then
                    if(pos>5 or _began_pos>5)then
                        isChanged = true and canChange(_began_pos,pos)
                        changedHero = card_hero
                        end_sprite = heroCardsTable[pos]
                        end_pos =  pos
                        break
                    end
                end
            end
        end

        if (isChanged == false) then
            _began_heroSprite:runAction(CCMoveTo:create(0.2, _original_pos))
            -- 修改 Z轴
            local parent_node = _began_heroSprite:getParent()
            if tonumber(_began_pos) >= 4 then
                parent_node:reorderChild(_began_heroSprite, 10)
            else
                parent_node:reorderChild(_began_heroSprite, 20)
            end
            if(xOffset<=10/(g_fScaleY*0.7) and xOffset>=-10/(g_fScaleY*0.7))then
                if(_inFormationInfo[_began_pos]~=0 and _inFormationInfo[_began_pos]~=nil)then
                    local data = getHeroData(_inFormationInfo[_began_pos])
                    HeroInfoLayer.createLayer(data, {isPanel=true})
                end
            end
        else
            changeFormationAction(_began_pos, end_pos)
        end
    end
end

-- 战斗结算面板的确定回调
function afterBattleCallback( isWin )

    if(PurgatoryData.isHavePass()==true)then
        local runningScene = CCDirector:sharedDirector():getRunningScene()
        PurgatoryMainLayer.setClick(false)
        runningScene:getChildByTag(911):setVisible(true)
    else
        PurgatoryMainLayer.setClick(true)
    end
    PurgatoryMainLayer.refreshFunc()
end

function freshNewHero( ... )
    -- body
    local index      = 0
    local bgSprite   = _bgLayer:getChildByTag(1)
    local totalIndex = table.count(_inFormationInfo)

    for i=1,5 do
        _bgLayer:getChildByTag(1):removeChildByTag(i,true)
        local card = CCScale9Sprite:create("images/common/blank_card.png", CCRectMake(0, 0, 77, 82), CCRectMake(38, 39, 2, 3))
        card:setScale(g_fScaleY*0.7 )
        card:setPreferredSize(CCSizeMake(128, 150))
        card:setAnchorPoint(ccp(0.5,0))
        bgSprite:addChild(card,0,i)
        index = index + 1

        local heroSp = CCSprite:create()
        if(index <= totalIndex)then
            local htid = _inFormationInfo[(i)]
            if(tonumber(htid)~=0)then
                heroSp = CardSprite:createWithHtid(htid)
                heroSp:setNameVisible(true)
                heroSp._hpLineBg:setVisible(false)
                heroSp._nameLabel:setAnchorPoint(ccp(0.5,1))
                heroSp._nameLabel:setPosition(ccp(heroSp:getContentSize().width*0.5,0))
            else
                heroSp:ignoreAnchorPointForPosition(false)
                heroSp:setContentSize(CCSizeMake(128, 150))
            end
        end
        heroCardsTable[i] = heroSp
        heroSp:setAnchorPoint(ccp(0.5, 0.5))
        card:addChild(heroSp,0,i)
        heroSp:setPosition(ccp(card:getContentSize().width*0.5,card:getContentSize().height*0.5))

        card:setPosition(ccp(bgSprite:getContentSize().width*(0.1+0.2*(i-1)),_rightLine:getPositionY()+_downHeroSprite:getContentSize().height*g_fScaleY*0.5+card:getContentSize().height*g_fScaleY*0.7-50*g_fScaleY+_refreshItem:getContentSize().height*g_fScaleY))
    end
    for i=6,11 do
        _bgLayer:getChildByTag(1):removeChildByTag(i,true)
        local card = CCScale9Sprite:create("images/common/blank_card.png", CCRectMake(0, 0, 77, 82), CCRectMake(38, 39, 2, 3))
        card:setPreferredSize(CCSizeMake(128, 150))
        card:setScale(g_fScaleY*0.7 )
        card:setAnchorPoint(ccp(0.5,0))
        if(i<9)then
            card:setPosition(ccp(bgSprite:getContentSize().width*0.25*(i-5),bgSprite:getContentSize().height*0.32))
        else
            card:setPosition(ccp(bgSprite:getContentSize().width*0.25*(i-8),bgSprite:getContentSize().height*0.115))
        end
        bgSprite:addChild(card,0,i)

        local addItem = nil
        local bodySprite = CCSprite:create()
        if(_inFormationInfo[i]~=nil)then
            if(tonumber(_inFormationInfo[i])~=0)then
                bodySprite = CardSprite:createWithHtid(_inFormationInfo[i])
                for k,v in pairs(_copyInfo.formation)do
                    if(tonumber(_inFormationInfo[i])==tonumber(v))then
                        local sprite = CCSprite:create("images/purgatory/oldhero.png")
                        sprite:setAnchorPoint(ccp(0,0.5))
                        bodySprite:addChild(sprite)
                        sprite:setPosition(ccp(0,bodySprite:getContentSize().height*0.5))
                    end
                end
                bodySprite:setNameVisible(true)
                bodySprite._hpLineBg:setVisible(false)
                bodySprite._nameLabel:setAnchorPoint(ccp(0.5,1))
                bodySprite._nameLabel:setPosition(ccp(bodySprite:getContentSize().width*0.5,0))
                local str = "+"..getUnionNum(_inFormationInfo[i])
                local label = CCLabelTTF:create(GetLocalizeStringBy("llp_207",str),g_sFontName,25)
                bodySprite:addChild(label)
                label:setColor(ccc3(0,255,0))
                label:setAnchorPoint(ccp(0.5,1))
                label:setPosition(ccp(bodySprite:getContentSize().width*0.5,-bodySprite._nameLabel:getContentSize().height))
            else
                bodySprite:ignoreAnchorPointForPosition(false)
                bodySprite:setContentSize(CCSizeMake(128, 150))
            end
        end
        heroCardsTable[i] = bodySprite
        bodySprite:setAnchorPoint(ccp(0.5,0.5))
        card:addChild(bodySprite,0,i)
        bodySprite:setPosition(ccp(card:getContentSize().width*0.5,card:getContentSize().height*0.5))
    end
end

function sureUpgrade( is_confirmed, arg )
    _isItemBuy = true
    if is_confirmed == true then
        local goldCostData = DB_Lianyutiaozhan_rule.getDataById(1)
        local buyTimeData = string.split(goldCostData.callHeroBuy,",")
        local buyTimes = string.split(buyTimeData[table.count(buyTimeData)],"|")
        local _copyInfo = PurgatoryData.getCopyInfo()
        if(tonumber(buyTimes[1])<=tonumber(_copyInfo.refresh_num))then
            AnimationTip.showTip(GetLocalizeStringBy("llp_206"))
        else
            local itemNum = tonumber(ItemUtil.getCacheItemNumBy(tonumber(goldCostData.item_id)))
            if(itemNum<=0)then
                _isItemBuy = false
                local tab = string.split(goldCostData.callHeroBuy,",")
                cost = 0
                for k,v in pairs(tab) do
                    local t_data = string.split(v,"|")
                    if(tonumber(_copyInfo.refresh_num) <= tonumber(t_data[1]))then
                        cost = tonumber(t_data[2])
                        break
                    end
                end
                if(tonumber(cost)>UserModel.getGoldNumber())then
                    LackGoldTip.showTip()
                    return
                end
            end
            local function freshBack( pInfo )
                -- body
                _bgLayer:getChildByTag(1):getChildByTag(100):removeChildByTag(1,true)
                if(_isItemBuy==false)then
                    UserModel.addGoldNumber(-cost)
                    PurgatoryData.addFreshTimes()
                else
                    _itemNum = _itemNum-1
                end
                PurgatoryData.setChoice(pInfo)
                dealWithData()

                local goldCostData = DB_Lianyutiaozhan_rule.getDataById(1)
                local tab = string.split(goldCostData.callHeroBuy,",")
                cost = 0
                for k,v in pairs(tab) do
                    local t_data = string.split(v,"|")
                    if(tonumber(_copyInfo.refresh_num) < tonumber(t_data[1]))then
                        cost = tonumber(t_data[2])
                        break
                    end
                end
                --刷新按钮
                local occupy_btn_info = {
                    normal = "images/common/btn/btn1_d.png",
                    selected = "images/common/btn/btn1_n.png",
                    size = CCSizeMake(200, 73),
                    icon = "images/common/gold.png",
                    text = GetLocalizeStringBy("lic_1011"),
                    number = tostring(cost)
                }
                if(_itemNum>0)then
                    occupy_btn_info.icon = "images/common/freshsmall.png"
                    occupy_btn_info.number = 1
                else
                    occupy_btn_info.icon = "images/common/gold.png"
                    occupy_btn_info.number = tostring(cost)
                end
                _refreshItem= LuaCCSprite.createNumberMenuItem(occupy_btn_info)
                _refreshItem:setAnchorPoint(ccp(0.5,0))
                _refreshItem:setPosition(_bgLayer:getContentSize().width*0.5, _labelFresh:getContentSize().height*g_fScaleY+_rightLine:getPositionY()+_downHeroSprite:getContentSize().height*g_fScaleY*0.5+_refreshItem:getContentSize().height*g_fScaleY-65*g_fScaleY)
                _refreshItem:setScale(g_fScaleY )
                _refreshItem:registerScriptTapHandler(freshHero)
                _bgLayer:getChildByTag(1):getChildByTag(100):addChild(_refreshItem,0,1)

                local index = 0
                local bgSprite = _bgLayer:getChildByTag(1)
                local totalIndex = table.count(_inFormationInfo)

                for i=1,5 do
                    _bgLayer:getChildByTag(1):removeChildByTag(i,true)
                    _inFormationInfo[i] = tonumber(pInfo[i])
                    local card = CCScale9Sprite:create("images/common/blank_card.png", CCRectMake(0, 0, 77, 82), CCRectMake(38, 39, 2, 3))
                    card:setScale(g_fScaleY*0.7 )
                    card:setPreferredSize(CCSizeMake(128, 150))
                    card:setAnchorPoint(ccp(0.5,0))
                    bgSprite:addChild(card,0,i)
                    index = index + 1

                    local heroSp = CCSprite:create()
                    if(index <= totalIndex)then
                        local htid = _inFormationInfo[(i)]
                        if(tonumber(htid)~=0)then
                            heroSp = CardSprite:createWithHtid(htid)
                            heroSp:setNameVisible(true)
                            heroSp._hpLineBg:setVisible(false)
                            heroSp._nameLabel:setAnchorPoint(ccp(0.5,1))
                            heroSp._nameLabel:setPosition(ccp(heroSp:getContentSize().width*0.5,0))
                        else
                            heroSp:ignoreAnchorPointForPosition(false)
                            heroSp:setContentSize(CCSizeMake(128, 150))
                        end
                    end
                    heroCardsTable[i] = heroSp
                    heroSp:setAnchorPoint(ccp(0.5, 0.5))
                    card:addChild(heroSp,0,i)
                    heroSp:setPosition(ccp(card:getContentSize().width*0.5,card:getContentSize().height*0.5))

                    card:setPosition(ccp(bgSprite:getContentSize().width*(0.1+0.2*(i-1)),_rightLine:getPositionY()+_downHeroSprite:getContentSize().height*g_fScaleY*0.5+card:getContentSize().height*g_fScaleY*0.7-50*g_fScaleY+_refreshItem:getContentSize().height*g_fScaleY))
                end
                for i=6,11 do
                    _bgLayer:getChildByTag(1):removeChildByTag(i,true)
                    local card = CCScale9Sprite:create("images/common/blank_card.png", CCRectMake(0, 0, 77, 82), CCRectMake(38, 39, 2, 3))
                    card:setPreferredSize(CCSizeMake(128, 150))
                    card:setScale(g_fScaleY*0.7 )
                    card:setAnchorPoint(ccp(0.5,0))
                    if(i<9)then
                        card:setPosition(ccp(bgSprite:getContentSize().width*0.25*(i-5),bgSprite:getContentSize().height*0.32))
                    else
                        card:setPosition(ccp(bgSprite:getContentSize().width*0.25*(i-8),bgSprite:getContentSize().height*0.115))
                    end
                    bgSprite:addChild(card,0,i)

                    local addItem = nil
                    local bodySprite = CCSprite:create()
                    if(_inFormationInfo[i]~=nil)then
                        if(tonumber(_inFormationInfo[i])~=0)then
                            bodySprite = CardSprite:createWithHtid(_inFormationInfo[i])
                            for k,v in pairs(_copyInfo.formation)do
                                if(tonumber(_inFormationInfo[i])==tonumber(v))then
                                    local sprite = CCSprite:create("images/purgatory/oldhero.png")
                                    sprite:setAnchorPoint(ccp(0,0.5))
                                    bodySprite:addChild(sprite)
                                    sprite:setPosition(ccp(0,bodySprite:getContentSize().height*0.5))
                                end
                            end
                            bodySprite:setNameVisible(true)
                            bodySprite._hpLineBg:setVisible(false)
                            bodySprite._nameLabel:setAnchorPoint(ccp(0.5,1))
                            bodySprite._nameLabel:setPosition(ccp(bodySprite:getContentSize().width*0.5,0))
                            local str = "+"..getUnionNum(_inFormationInfo[i])
                            local label = CCLabelTTF:create(GetLocalizeStringBy("llp_207",str),g_sFontName,25)
                            label:setColor(ccc3(0,255,0))
                            bodySprite:addChild(label)
                            label:setAnchorPoint(ccp(0.5,1))
                            label:setPosition(ccp(bodySprite:getContentSize().width*0.5,-bodySprite._nameLabel:getContentSize().height))
                        else
                            bodySprite:ignoreAnchorPointForPosition(false)
                            bodySprite:setContentSize(CCSizeMake(128, 150))
                        end
                    end
                    heroCardsTable[i] = bodySprite
                    bodySprite:setAnchorPoint(ccp(0.5,0.5))
                    card:addChild(bodySprite,0,i)
                    bodySprite:setPosition(ccp(card:getContentSize().width*0.5,card:getContentSize().height*0.5))
                end
            end
            PurgatoryServes.refreshHeros(freshBack)
        end
    end
    AlertTip.closeAction()
end

--刷新英雄if(table.isEmpty(chooseData))then
        --     AlertTip.showAlert(GetLocalizeStringBy("llp_157"), sureUpgrade, true, nil, GetLocalizeStringBy("key_1985"),GetLocalizeStringBy("key_1202"))
        --     return
        -- end
function freshHero( ... )
    for k,v in pairs(_copyInfo.choice) do
        local heroInfo = DB_Heroes.getDataById(tonumber(v))
        if(tonumber(heroInfo.potential)==6 or tonumber(heroInfo.potential)==7)then
            AlertTip.showAlert(GetLocalizeStringBy("llp_215"), sureUpgrade, true, nil, GetLocalizeStringBy("key_1985"),GetLocalizeStringBy("key_1202"))
            return
        end
    end
    sureUpgrade(true)
end

--获取联协数量
function getUnionNum( pHtid )
    -- body
    _pTable = {}
    local pHtidTable = {}
    for i=6,11 do
        if(_inFormationInfo[i]~=0)then
            table.insert(pHtidTable,_inFormationInfo[i])
        end
    end
    local hero_union_infos = UnionProfitUtil.getHeroUniosByHtids(pHtidTable)
    for k,v in pairs(hero_union_infos)do
        local pData = {}
        pData.htid = k
        pData.value = v
        table.insert(_pTable,pData)
    end
    local unionNum = 0
    for k,v in pairs (_pTable) do
        if(tonumber(v.htid)==pHtid)then
            for key,val in pairs(v.value["union_infos"])do
                if(val.is_active==true)then
                    unionNum = unionNum+1
                end
            end
            return unionNum
        end
    end
end

--战斗命令回调
function attackCommondCallBack( attackInfo )
    -- body
    PurgatoryData.setFormationInfo(_inFormationInfo)
    require "script/battle/BattleLayer"
    require "script/ui/purgatorychallenge/PurgatoryAfterBattleLayer"

    local base64Data = Base64.decodeWithZip(attackInfo.fightRet)
    local data = amf3.decode(base64Data)

    PurgatoryData.setEnterInfo(attackInfo.point,attackInfo.hell_point,attackInfo.choice)

    local layer = PurgatoryAfterBattleLayer.createAfterBattleLayer(attackInfo,nil,nil, afterBattleCallback)
    if(PurgatoryData.isHavePass()==true)then
        require "script/ui/purgatorychallenge/PurgatoryFinishLayer"
        local player = PurgatoryFinishLayer.createAfterBattleLayer(attackInfo.hell_point)
        local runningScene = CCDirector:sharedDirector():getRunningScene()
        runningScene:addChild(player,100,911)
        player:setVisible(false)
    end
    local copyData = DB_Lianyutiaozhan_copy.getDataById(tonumber(_copyInfo.passed_stage))
    local pic = copyData.picture or "ducheng.jpg"
    local music = copyData.music
    local monsterId = tonumber(_copyInfo.passed_stage)
    local armyId = _copyInfo.monster[tostring(monsterId)]

    BattleLayer.showBattleWithString(attackInfo.fightRet, nil,layer, pic,music,armyId,nil,nil,false)

    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
end

function challengeAction( p_tag,p_itemBtn )

    local heroCount = 0
    local _copyInfo = PurgatoryData.getCopyInfo()
    local formation = CCDictionary:create()
    for i=6,11 do
        if(tonumber(_inFormationInfo[i])~=0) then
            heroCount = heroCount+1
            formation:setObject(CCInteger:create(tonumber(_inFormationInfo[i])), "" .. i-6);
        else
            formation:setObject(CCInteger:create(0), "" .. i-6);
        end
    end

    if(heroCount<tonumber(_copyInfo.passed_stage)+1)then
        AnimationTip.showTip(GetLocalizeStringBy("llp_188"))
        return
    end
    local args = CCArray:create()
    args:addObject(CCInteger:create(tonumber(_copyInfo.passed_stage)+1))
    args:addObject(formation)
    PurgatoryServes.attack(attackCommondCallBack,args)
end

function unionAction( ... )
    -- body
    local heroCount = 0
    local _copyInfo = PurgatoryData.getCopyInfo()
    local formation = CCDictionary:create()
    for i=6,11 do
        if(tonumber(_inFormationInfo[i])~=0) then
            heroCount = heroCount+1
        end
    end

    if(heroCount==0)then
        AnimationTip.showTip(GetLocalizeStringBy("llp_211"))
        return
    end
    _pTable = {}
    local pHtidTable = {}
    for i=6,11 do
        if(_inFormationInfo[i]~=0)then
            table.insert(pHtidTable,_inFormationInfo[i])
        end
    end
    local hero_union_infos = UnionProfitUtil.getHeroUniosByHtids(pHtidTable)
    for k,v in pairs(hero_union_infos)do
        local pData = {}
        pData.htid = k
        pData.value = v
        table.insert(_pTable,pData)
    end
    if(table.isEmpty(_pTable))then
        return
    else
        PurgatoryUnionLayer.showTip(_pTable,-560)
    end
end

--layer点击事件
local function onNodeEvent( event )
    if (event == "enter") then
        PurgatoryMainLayer.setClick(false)
        _bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -550, true)
        _bgLayer:setTouchEnabled(true)
    elseif (event == "exit") then
        PurgatoryMainLayer.setClick(true)
        _bgLayer:unregisterScriptTouchHandler()
    end
end

--返回事件
function backAction(tag,itembtn)
    -- 隐藏中间
    PurgatoryMainLayer.refreshFunc()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
end

--查看对方阵容
function lookAction( ... )
    -- body
    PurgatoryEnemyLayer.showLayer()
end

function dealWithData()
    --选了的英雄的数据
    _copyInfo = PurgatoryData.getCopyInfo()

    require "script/ui/formation/FormationUtil"
    local index = 0

    if(not table.isEmpty(_copyInfo.choice))then
        for k,v in pairs(_copyInfo.choice)do
            table.insert(_inFormationInfo,tonumber(v))
        end
    end

    if(not table.isEmpty(_copyInfo.formation))then
        for i=6,11 do
            if(_copyInfo.formation[tonumber(i-6)]~=nil)then
                _inFormationInfo[i] = tonumber(_copyInfo.formation[tonumber(i-6)])
            else
                _inFormationInfo[i] = 0
            end
        end
    else
        for i=6,11 do
            _inFormationInfo[i] = 0
        end
    end

    _pTable = {}
    local pHtidTable = {}
    for i=6,11 do
        if(_inFormationInfo[i]~=0)then
            table.insert(pHtidTable,_inFormationInfo[i])
        end
    end
    local hero_union_infos = UnionProfitUtil.getHeroUniosByHtids(pHtidTable)
    for k,v in pairs(hero_union_infos)do
        local pData = {}
        pData.htid = k
        pData.value = v
        table.insert(_pTable,pData)
    end
end

function createLayOut( ... )

    local _copyInfo = PurgatoryData.getCopyInfo()

    dealWithData()

    -- 当前阵型图片
    local styleSprite = CCScale9Sprite:create("images/purgatory/choosehero.png")
    local _battleItem= LuaCC.create9ScaleMenuItem("images/common/btn/btn_red_n.png","images/common/btn/btn_red_h.png",CCSizeMake(213, 73),GetLocalizeStringBy("key_2565"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    local _backItem= CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")

    local fullRect = CCRectMake(0,0,187,30)
    local insetRect = CCRectMake(84,10,12,18)
    local bgSprite = CCScale9Sprite:create("images/godweaponcopy/blackred.png", fullRect, insetRect)
    bgSprite:setContentSize(CCSizeMake(g_winSize.width, g_winSize.height-_battleItem:getContentSize().height*g_fScaleY-8*g_fScaleY-styleSprite:getContentSize().height*g_fScaleY*0.5-_backItem:getContentSize().height*g_fScaleY))
    _bgLayer:addChild(bgSprite,0,1)
    bgSprite:setAnchorPoint(ccp(0.5,0))

    -- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-551)
    bgSprite:addChild(menu,0,100)

    --  返回
    _backItem:setAnchorPoint(ccp(1,1))
    _backItem:setScale(g_fScaleY )
    _backItem:setPosition(bgSprite:getContentSize().width, bgSprite:getContentSize().height+_backItem:getContentSize().height*g_fScaleY)
    _backItem:registerScriptTapHandler(backAction)
    menu:addChild(_backItem,1)

    --  查看
    local _lookItem= CCMenuItemImage:create("images/purgatory/look1.png","images/purgatory/look2.png")
    _lookItem:setAnchorPoint(ccp(0,1))
    _lookItem:setScale(g_fScaleY )
    _lookItem:setPosition(0, bgSprite:getContentSize().height+_lookItem:getContentSize().height*g_fScaleY)
    _lookItem:registerScriptTapHandler(lookAction)
    menu:addChild(_lookItem,1)

    --  战斗
    _battleItem:setAnchorPoint(ccp(0.5,1))
    _battleItem:setPosition(_bgLayer:getContentSize().width*0.5, -8)
    _battleItem:setScale(g_fScaleY )
    _battleItem:registerScriptTapHandler(challengeAction)
    menu:addChild(_battleItem)

    local bottomLineSprite = CCSprite:create("images/godweaponcopy/21.png")
    bottomLineSprite:setScale(g_fScaleY )
    bottomLineSprite:setAnchorPoint(ccp(0.5,0))
    bgSprite:addChild(bottomLineSprite)
    bottomLineSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5,0))

    styleSprite:setAnchorPoint(ccp(0.5,0.5))
    styleSprite:setScale(g_fScaleY )
    styleSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height))
    bgSprite:addChild(styleSprite)

    bgSprite:setPosition(ccp(g_winSize.width*0.5, _battleItem:getContentSize().height*g_fScaleY))

    local leftFlower = CCScale9Sprite:create("images/god_weapon/flower.png")
    leftFlower:setScale(g_fScaleY )
    leftFlower:setAnchorPoint(ccp(1,0.5))
    leftFlower:setPosition(ccp(bgSprite:getContentSize().width*0.5-styleSprite:getContentSize().width*g_fScaleY*0.5,bgSprite:getContentSize().height))
    bgSprite:addChild(leftFlower)

    local rightFlower = CCScale9Sprite:create("images/god_weapon/flower.png")
    rightFlower:setScale(-g_fScaleY)
    rightFlower:setAnchorPoint(ccp(1,0.5))
    rightFlower:setPosition(ccp(bgSprite:getContentSize().width*0.5+styleSprite:getContentSize().width*g_fScaleY*0.5,bgSprite:getContentSize().height))
    bgSprite:addChild(rightFlower)

    local desLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_182"),g_sFontName,18)
    desLabel:setScale(g_fScaleY )
    bgSprite:addChild(desLabel)
    desLabel:setAnchorPoint(ccp(0.5,0))
    desLabel:setColor(ccc3(255,255,0))
    desLabel:setPosition(ccp(bgSprite:getContentSize().width*0.5,bottomLineSprite:getContentSize().height*g_fScaleY))

    _desBg= CCScale9Sprite:create("images/common/bg/9s_1.png")
    _desBg:setScale(g_fScaleY)
    _desBg:setContentSize(CCSizeMake(500,360))
    _desBg:setPosition(bgSprite:getContentSize().width/2, desLabel:getPositionY()+desLabel:getContentSize().height*2*g_fScaleY)
    _desBg:setAnchorPoint(ccp(0.5,0))

    bgSprite:addChild(_desBg,0,20)

    for i=6,11 do
        local card = CCScale9Sprite:create("images/common/blank_card.png", CCRectMake(0, 0, 77, 82), CCRectMake(38, 39, 2, 3))
        card:setPreferredSize(CCSizeMake(128, 150))
        card:setScale(g_fScaleY*0.7 )
        card:setAnchorPoint(ccp(0.5,0))
        if(i<9)then
            card:setPosition(ccp(bgSprite:getContentSize().width*0.25*(i-5),bgSprite:getContentSize().height*0.32))
        else
            card:setPosition(ccp(bgSprite:getContentSize().width*0.25*(i-8),bgSprite:getContentSize().height*0.115))
        end
        bgSprite:addChild(card,0,i)

        local addItem = nil
        local bodySprite = CCSprite:create()
        if(_inFormationInfo[i]~=nil)then
            if(tonumber(_inFormationInfo[i])~=0)then
                bodySprite = CardSprite:createWithHtid(_inFormationInfo[i])
                local sprite = CCSprite:create("images/purgatory/oldhero.png")
                sprite:setAnchorPoint(ccp(0,0.5))
                bodySprite:addChild(sprite)
                sprite:setPosition(ccp(0,bodySprite:getContentSize().height*0.5))
                bodySprite:setNameVisible(true)
                bodySprite._nameLabel:setAnchorPoint(ccp(0.5,1))
                bodySprite._nameLabel:setPosition(ccp(bodySprite:getContentSize().width*0.5,0))
                bodySprite._hpLineBg:setVisible(false)
                local str = "+"..getUnionNum(_inFormationInfo[i])
                local label = CCLabelTTF:create(GetLocalizeStringBy("llp_207",str),g_sFontName,25)
                bodySprite:addChild(label)
                label:setColor(ccc3(0,255,0))
                label:setAnchorPoint(ccp(0.5,1))
                label:setPosition(ccp(bodySprite:getContentSize().width*0.5,-bodySprite._nameLabel:getContentSize().height))
            else
                bodySprite:ignoreAnchorPointForPosition(false)
                bodySprite:setContentSize(CCSizeMake(128, 150))
            end
        end
        heroCardsTable[i] = bodySprite
        bodySprite:setAnchorPoint(ccp(0.5,0.5))
        card:addChild(bodySprite,0,i)
        bodySprite:setPosition(ccp(card:getContentSize().width*0.5,card:getContentSize().height*0.5))
    end
    --战斗前和战斗后 阵下武将或者副将
    _downHeroSprite = nil
    _downHeroSprite = CCSprite:create("images/purgatory/uphero.png")
    _downHeroSprite:setScale(g_fScaleX )

    local leftLine = CCScale9Sprite:create("images/god_weapon/cut_line.png")
    leftLine:setScale(g_fScaleY )
    leftLine:setAnchorPoint(ccp(1,0.5))
    leftLine:setPosition(ccp(bgSprite:getContentSize().width*0.5-styleSprite:getContentSize().width*g_fScaleY*0.5,bgSprite:getChildByTag(6):getPositionY()+bgSprite:getChildByTag(6):getContentSize().height*g_fScaleY+_downHeroSprite:getContentSize().height*g_fScaleX*0.5+70*g_fScaleY))
    bgSprite:addChild(leftLine)

    _rightLine = CCScale9Sprite:create("images/god_weapon/cut_line.png")
    local scale = tonumber(g_fScaleY)
    _rightLine:setScale(-scale )
    _rightLine:setAnchorPoint(ccp(1,0.5))
    _rightLine:setPosition(ccp(bgSprite:getContentSize().width*0.5+styleSprite:getContentSize().width*g_fScaleY*0.5,bgSprite:getChildByTag(6):getPositionY()+bgSprite:getChildByTag(6):getContentSize().height*g_fScaleY+_downHeroSprite:getContentSize().height*g_fScaleX*0.5+70*g_fScaleY))
    bgSprite:addChild(_rightLine)

    bgSprite:addChild(_downHeroSprite)
    _downHeroSprite:setAnchorPoint(ccp(0.5,0.5))
    _downHeroSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getChildByTag(6):getPositionY()+bgSprite:getChildByTag(6):getContentSize().height*g_fScaleY+_downHeroSprite:getContentSize().height*g_fScaleY*0.5+70*g_fScaleY))
    --可上场武将数label前半段
    local upHeroLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_181"),g_sFontPangWa,21)
    upHeroLabel:setAnchorPoint(ccp(0,1))
    upHeroLabel:setScale(g_fScaleY)
    bgSprite:addChild(upHeroLabel)
    upHeroLabel:setColor(ccc3(255,255,0))
    upHeroLabel:setPosition(ccp(bgSprite:getContentSize().width*0.5+styleSprite:getContentSize().width*g_fScaleY*0.5,bgSprite:getChildByTag(6):getPositionY()+bgSprite:getChildByTag(6):getContentSize().height*g_fScaleY+_downHeroSprite:getContentSize().height*g_fScaleY*0.5+35*g_fScaleY))
    --后半段
    local upNumLable = CCLabelTTF:create(tostring(tonumber(_copyInfo.passed_stage)+1),g_sFontPangWa,21)
    upNumLable:setAnchorPoint(ccp(0,1))
    upNumLable:setScale(g_fScaleY)
    bgSprite:addChild(upNumLable)
    upNumLable:setPosition(ccp(upHeroLabel:getPositionX()+upHeroLabel:getContentSize().width*g_fScaleY,upHeroLabel:getPositionY()))
    upNumLable:setColor(ccc3(0,255,0))

    --  联协
    local _unionItem= CCMenuItemImage:create("images/purgatory/union1.png","images/purgatory/union2.png")
    _unionItem:setAnchorPoint(ccp(0,1))
    _unionItem:setScale(g_fScaleY )
    _unionItem:setPosition(0, bgSprite:getChildByTag(6):getPositionY()+bgSprite:getChildByTag(6):getContentSize().height*g_fScaleY+_downHeroSprite:getContentSize().height*g_fScaleY*0.5+65*g_fScaleY)
    _unionItem:registerScriptTapHandler(unionAction)
    menu:addChild(_unionItem,1)

    local goldCostData = DB_Lianyutiaozhan_rule.getDataById(1)
    local tab = string.split(goldCostData.callHeroBuy,",")
    cost = 0
    for k,v in pairs(tab) do
        local t_data = string.split(v,"|")
        if(tonumber(_copyInfo.refresh_num) < tonumber(t_data[1]))then
            cost = tonumber(t_data[2])
            break
        end
    end

    _labelFresh = CCLabelTTF:create(GetLocalizeStringBy("llp_213"),g_sFontPangWa,22)
    bgSprite:addChild(_labelFresh)
    _labelFresh:setScale(g_fScaleY )
    _labelFresh:setColor(ccc3(0,255,0))
    _labelFresh:setAnchorPoint(ccp(0.5,0))

    --刷新按钮
    local occupy_btn_info = {
        normal = "images/common/btn/btn1_d.png",
        selected = "images/common/btn/btn1_n.png",
        size = CCSizeMake(200, 73),
        icon = "images/common/gold.png",
        text = GetLocalizeStringBy("lic_1011"),
        number = tostring(cost)
    }
    local goldCostData = DB_Lianyutiaozhan_rule.getDataById(1)
    _itemNum = tonumber(ItemUtil.getCacheItemNumBy(tonumber(goldCostData.item_id)))
    if(_itemNum>0)then
        occupy_btn_info.icon = "images/common/freshsmall.png"
        occupy_btn_info.number = 1
    end
    _refreshItem= LuaCCSprite.createNumberMenuItem(occupy_btn_info)
    _refreshItem:setAnchorPoint(ccp(0.5,0))
    _refreshItem:setPosition(_bgLayer:getContentSize().width*0.5, _labelFresh:getContentSize().height*g_fScaleY+_rightLine:getPositionY()+_downHeroSprite:getContentSize().height*g_fScaleY*0.5+_refreshItem:getContentSize().height*g_fScaleY-65*g_fScaleY)
    _refreshItem:setScale(g_fScaleY )
    _refreshItem:registerScriptTapHandler(freshHero)
    menu:addChild(_refreshItem,0,1)
    _labelFresh:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _rightLine:getPositionY()+_downHeroSprite:getContentSize().height*g_fScaleY*0.5+_refreshItem:getContentSize().height*g_fScaleY-65*g_fScaleY))
    --当前阵型
    local index = 0
    local totalIndex = table.count(_inFormationInfo)

    for i=1,5 do
        local card = CCScale9Sprite:create("images/common/blank_card.png", CCRectMake(0, 0, 77, 82), CCRectMake(38, 39, 2, 3))
        card:setScale(g_fScaleY*0.7 )
        card:setPreferredSize(CCSizeMake(128, 150))
        card:setAnchorPoint(ccp(0.5,0))
        bgSprite:addChild(card,0,i)
        index = index + 1

        local heroSp = CCSprite:create()
        if(index <= totalIndex)then
            local htid = _inFormationInfo[(i)]
            if(tonumber(htid)~=0)then
                heroSp = CardSprite:createWithHtid(htid)
                heroSp:setNameVisible(true)
                heroSp._hpLineBg:setVisible(false)
                heroSp._nameLabel:setAnchorPoint(ccp(0.5,1))
                heroSp._nameLabel:setPosition(ccp(heroSp:getContentSize().width*0.5,0))
            else
                heroSp:ignoreAnchorPointForPosition(false)
                heroSp:setContentSize(CCSizeMake(128, 150))
            end
        end
        heroCardsTable[i] = heroSp
        heroSp:setAnchorPoint(ccp(0.5, 0.5))
        card:addChild(heroSp,0,i)
        heroSp:setPosition(ccp(card:getContentSize().width*0.5,card:getContentSize().height*0.5))

        card:setPosition(ccp(bgSprite:getContentSize().width*(0.1+0.2*(i-1)),_rightLine:getPositionY()+_downHeroSprite:getContentSize().height*g_fScaleY*0.5+card:getContentSize().height*g_fScaleY*0.7-50*g_fScaleY+_refreshItem:getContentSize().height*g_fScaleY))
    end
end

function createLayer( ... )
    -- 底层
    _bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
    _bgLayer:registerScriptHandler(onNodeEvent)

    createLayOut()

    return _bgLayer
end

function showLayer(p_touch,p_zorder)
    init()
    p_touch = p_touch or -400
    p_zorder = p_zorder or 100

    local pLayer = createLayer()

    --把layer加到runningScene上
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(pLayer,p_zorder,87)
end
