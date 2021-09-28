-- Filename: BattleLayer.lua
-- Author: k
-- Date: 2013-05-27
-- Purpose: 战斗场景

module("BattleCardUtil", package.seeall)

require "script/utils/extern"
require "script/utils/LuaUtil"
require "db/DB_Heroes"
require "db/DB_Monsters_tmpl"
require "db/DB_Monsters"
require "script/model/hero/HeroModel"
require "script/utils/LuaUtil"
require "script/model/user/UserModel"
require "db/DB_Item_dress"
require "db/DB_Heroes"
require "db/DB_Army"
require "db/DB_Team"
require "script/ui/turnedSys/HeroTurnedData"

kHeroNameLabelTag =   10
kAngerSprteTag    =   8881
kHpBgTag          =   6
kHpTag            =   7

local IMG_PATH        = "images/battle/"                -- 图片主路径
local _nameLabelArray = {}
local _battleData     = nil
local _isNameVisble   = true

function getBattlePlayerCardImage( hid, isBoss, htid, isBigCard, replaceImage)
    hid = tonumber(hid)
    isBoss = isBoss or false
    isBigCard = isBigCard or false

    local cardPath = isBoss==true and IMG_PATH .. "bigcard/" or IMG_PATH .. "card/"
    local cardName = "nil"
    local imageFile
    local grade
    local myHtid   = htid
    local heroInfo = nil
    local turnedId = nil
    if(htid~=nil)then
        local hero = DB_Heroes.getDataById(htid)
        if(hero==nil)then
            hero = DB_Monsters_tmpl.getDataById(htid)
        end
        grade = hero.star_lv
        imageFile = hero.action_module_id
        cardName  = hero.name
        heroInfo  = hero
        print("hid===",hid)
        if hid then
            local info = getBattleHeroInfo(hid)
            print("-=-=-=-=--")
            print_t(info)
            if(info~=nil)then
                cardName = HeroModel.getHeroName(info)
                info.turned_id = tonumber(info.turned_id) or 0
                if info.turned_id ~= 0 then
                    turnedId = info.turned_id
                    imageFile = HeroTurnedData.getHeroCardImgById(info.turned_id)    
                end
            end
        end
    elseif(hid<10000000) then
        local monster = DB_Monsters.getDataById(hid)
        if(monster==nil) then
           monster = DB_Monsters.getDataById(3014201)
        end
        local monsterTmpl = DB_Monsters_tmpl.getDataById(monster.htid)
        grade     = monsterTmpl.star_lv
        imageFile = monsterTmpl.action_module_id
        cardName  = monsterTmpl.name
        myHtid    = monster.htid
        heroInfo  = monsterTmpl
    else
        local allHeros = HeroModel.getAllHeroes()
        if(allHeros==nil or allHeros[hid..""] == nil)then
            grade = hid%6+1
            imageFile = "zhan_jiang_guojia.png"
        else
            local info = getBattleHeroInfo(hid)
            local htid = allHeros[hid..""].htid
            if info then
                htid = info.htid
            end
            local hero = DB_Heroes.getDataById(htid)
            myHtid     = htid
            grade      = hero.star_lv
            imageFile  = hero.action_module_id
            cardName   = HeroModel.getHeroName(allHeros[hid..""])
            heroInfo   = hero
            if info then
                info.turned_id = tonumber(info.turned_id) or 0
                if info.turned_id ~= 0 then
                    turnedId = info.turned_id
                    imageFile = HeroTurnedData.getHeroCardImgById(info.turned_id)    
                end
            else
                info = allHeros[hid..""]
                info.turned_id = tonumber(info.turned_id) or 0
                if info.turned_id ~= 0 then
                    turnedId = info.turned_id
                    imageFile = HeroTurnedData.getHeroCardImgById(info.turned_id)    
                end
            end
        end
    end
    
    if(replaceImage~=nil)then
        imageFile = replaceImage
    end
    
    if(isBigCard==true)then
        grade = 99
        cardPath = IMG_PATH .. "bigcard/"
        isBoss = true
    end
    
    local card = CCXMLSprite:create(cardPath .. "card_" .. (grade) .. ".png")
    card:initXMLSprite(CCString:create(cardPath .. "card_" .. (grade) .. ".png"));
    card:setAnchorPoint(ccp(0.5,0.5))
    card:setCascadeOpacityEnabled(true)
    card:setCascadeColorEnabled(true)
    
    local heroSprite = nil
    if((isBoss==true or isBigCard==true) and file_exists("images/base/hero/action_module_b/" .. imageFile)==true)then
        heroSprite = CCSprite:create("images/base/hero/action_module_b/" .. imageFile);
    else
        heroSprite = CCSprite:create("images/base/hero/action_module/" .. imageFile);
    end
    heroSprite:setAnchorPoint(ccp(0.5,0))
    

    local changeY = getDifferenceYByImageName(myHtid,imageFile,isBoss, turnedId)
    if(isBigCard==true)then
        changeY = changeY - card:getContentSize().height*0.027
    end
    print("turnedId 1", turnedId, changeY)    

    heroSprite:setPosition(card:getContentSize().width/2,card:getContentSize().height*0.17+changeY)
    card:addChild(heroSprite,2,1)
    --顶部花纹
    local topSprint = CCSprite:create(cardPath .. "card_" .. (grade) .. "_top.png")
    topSprint:setAnchorPoint(ccp(0,1))
    topSprint:setPosition(0,card:getContentSize().height)
    card:addChild(topSprint,1,2)
    --阴影背景
    local shadowSprint = CCSprite:create(cardPath .. "card_shadow.png")
    shadowSprint:setAnchorPoint(ccp(0,1))
    shadowSprint:setPosition(-6,card:getContentSize().height+5)
    card:addChild(shadowSprint,-1,5)
    --血条背景
    local hpLineBg = CCSprite:create(cardPath .. "hpline_bg.png")
    hpLineBg:setAnchorPoint(ccp(0.5,0.5))
    hpLineBg:setPosition(card:getContentSize().width*0.5,card:getContentSize().height*-0.05)
    card:addChild(hpLineBg,1,kHpBgTag)
    hpLineBg:setCascadeOpacityEnabled(true)
    hpLineBg:setCascadeColorEnabled(true)
    --血条
    local hpLine = CCSprite:create(cardPath .. "hpline.png")
    hpLine:setAnchorPoint(ccp(0,0.5))
    hpLine:setPosition(0,hpLineBg:getContentSize().height*0.5)
    hpLineBg:addChild(hpLine,1,kHpTag)
    --卡牌背景
    local heroBgSprite = CCSprite:create(cardPath .. "card_hero_bg.png");
    heroBgSprite:setAnchorPoint(ccp(0.5,0))
    heroBgSprite:setPosition(card:getContentSize().width/2,card:getContentSize().height*0.17)
    card:addChild(heroBgSprite,0,8)

    --卡牌名称
    if(myHtid~=nil and HeroModel.isNecessaryHero(myHtid)) then
        cardName = getNecessaryName(hid)
        if(cardName == nil) then
            cardName = UserModel.getUserName()
        end
    end
    local nameColor = HeroPublicLua.getCCColorByStarLevel(heroInfo.potential)
    local heroName  = CCRenderLabel:create(cardName, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    heroName:setPosition(ccp(card:getContentSize().width/2, card:getContentSize().height))
    heroName:setAnchorPoint(ccp(0.5, 0))
    heroName:setColor(nameColor)
    card:addChild(heroName, 1000, kHeroNameLabelTag)
    heroName:setVisible(_isNameVisble)
    table.insert(_nameLabelArray, heroName)
    heroName:registerScriptHandler(function ( eventType )
        if(eventType == "exit") then
            for k,v in pairs(_nameLabelArray) do
                if(v == heroName) then
                    _nameLabelArray[k] = nil
                end
            end
        end
    end)
    return card
end

function setCardHp(card,scale)
    --判断是否为标准卡牌
    if(card~=nil and card:getChildByTag(6)~=nil and card:getChildByTag(6):getChildByTag(7)~=nil)then
        local hpLine = tolua.cast(card:getChildByTag(6):getChildByTag(7), "CCSprite")
        local textureSize = hpLine:getTexture():getContentSize()
        scale = scale>1 and 1 or scale
        scale = scale<0 and 0 or scale
        hpLine:setTextureRect(CCRectMake(0,0,textureSize.width*scale,textureSize.height))
    end
end

function setCardAnger(card,angerPoint,hid)

    if angerPoint == nil then
        return
    end
    if card==nil or card:getChildByTag(6)==nil or card:getChildByTag(6):getChildByTag(7)==nil then
        return
    end

    local angerPerPoint = 1
    local angerNumber = math.floor( angerPoint/angerPerPoint)
    local openGodUnion = isOpenGodUnion(hid)
    
    if(angerNumber>4)then
        if(card:getChildByTag(8881)==nil or card:getChildByTag(8881):getChildByTag(1290)==nil)then
            if(card:getContentSize().width>150)then
                local angerSprite = CCSprite:create(IMG_PATH .. "anger/big.png")
                angerSprite:setAnchorPoint(ccp(0.5,0.5))
                angerSprite:setPosition(card:getContentSize().width*0.7,21)
                card:addChild(angerSprite,10,8881)
                angerSprite:setCascadeOpacityEnabled(true)
                angerSprite:setCascadeColorEnabled(true)
                
                local xSprite = CCSprite:create(IMG_PATH .. "anger/X.png")
                xSprite:setAnchorPoint(ccp(0,0))
                xSprite:setPosition(angerSprite:getContentSize().width,0)
                angerSprite:addChild(xSprite,1,1299)
                
                local numberSprite = LuaCC.createNumberSprite02(IMG_PATH .. "anger","" .. angerNumber,0)
                numberSprite:setAnchorPoint(ccp(0,0))
                numberSprite:setPosition(angerSprite:getContentSize().width+xSprite:getContentSize().width,-13)
                angerSprite:addChild(numberSprite,1,1290)
                
            else
                local angerSprite = CCSprite:create(IMG_PATH .. "anger/nomal.png")
                angerSprite:setAnchorPoint(ccp(0.5,0.5))
                angerSprite:setPosition(card:getContentSize().width*0.7,12)
                card:addChild(angerSprite,10,8881)
                angerSprite:setCascadeOpacityEnabled(true)
                angerSprite:setCascadeColorEnabled(true)
                
                local xSprite = CCSprite:create(IMG_PATH .. "anger/X.png")
                xSprite:setAnchorPoint(ccp(0,0))
                xSprite:setPosition(angerSprite:getContentSize().width,0)
                angerSprite:addChild(xSprite,1,1299)
                
                local numberSprite = LuaCC.createNumberSprite02(IMG_PATH .. "anger","" .. angerNumber,0)
                numberSprite:setAnchorPoint(ccp(0,0))
                numberSprite:setPosition(angerSprite:getContentSize().width+xSprite:getContentSize().width,-13)
                angerSprite:addChild(numberSprite,1,1290)
            end
        else
            local angerSprite = card:getChildByTag(8881)
            angerSprite:removeChildByTag(1290,true)
            
            if(card:getContentSize().width>150)then
                local numberSprite = LuaCC.createNumberSprite02(IMG_PATH .. "anger","" .. angerNumber,20)
                numberSprite:setAnchorPoint(ccp(0,0))
                numberSprite:setPosition(angerSprite:getContentSize().width+angerSprite:getChildByTag(1299):getContentSize().width,-13)
                angerSprite:addChild(numberSprite,1,1290)
            else
                local numberSprite = LuaCC.createNumberSprite02(IMG_PATH .. "anger","" .. angerNumber,20)
                numberSprite:setAnchorPoint(ccp(0,0))
                numberSprite:setPosition(angerSprite:getContentSize().width+angerSprite:getChildByTag(1299):getContentSize().width,-13)
                angerSprite:addChild(numberSprite,1,1290)
            end
        end
    else
        if(card:getChildByTag(8881)==nil or card:getChildByTag(8881):getChildByTag(1290)==nil)then
            
        else
            local angerSprite = card:getChildByTag(8881)
            angerSprite:setVisible(false)
        end
    end
    local openGodUnionAngerEffectPath = "images/battle/effect/honggouyu"   
    for j=1,4 do
        local sp = tolua.cast(card:getChildByTag(10+j),"CCSprite")
        if(angerNumber>=j)then
            if(sp==nil)then
                if(card:getContentSize().width>150)then
                    
                    local angerStar = nil
                    if openGodUnion then
                        local angerStar = CCLayerSprite:layerSpriteWithName(CCString:create(openGodUnionAngerEffectPath), -1,CCString:create(""))
                        angerStar:setAnchorPoint(ccp(0.5,0.5))
                        angerStar:setPosition(22+(j-1)*20,21)
                    else
                        angerStar = CCSprite:create(IMG_PATH .. "bigcard/anger.png")
                        angerStar:setAnchorPoint(ccp(0.5,0.5))
                        angerStar:setPosition(22+(j-1)*20,21)
                    end
                    card:addChild(angerStar,3,10+j)
                else
                    local angerStar = nil
                    if openGodUnion then
                        angerStar = CCLayerSprite:layerSpriteWithName(CCString:create(openGodUnionAngerEffectPath), -1,CCString:create(""))
                        angerStar:setAnchorPoint(ccp(0.5,0.5))
                        angerStar:setPosition(17+(j-1)*14,13.5)
                    else
                        angerStar = CCSprite:create(IMG_PATH .. "card/anger.png")
                        angerStar:setAnchorPoint(ccp(0.5,0.5))
                        angerStar:setPosition(14+(j-1)*14,12)
                    end
                    card:addChild(angerStar,3,10+j)
                end
            end
        else
            if(sp~=nil)then
                sp:removeFromParentAndCleanup(true)
            end
        end
    end
    
    local effectPath = "images/battle/effect/lvdou"
    if openGodUnion then
        effectPath = "images/battle/effect/honggouyu"
    end

    if(angerNumber>=4)then
        local spellEffectSprite = card:getChildByTag(131)
        if(spellEffectSprite==nil)then
            
            for j=1,4 do
                local angerStar = CCLayerSprite:layerSpriteWithName(CCString:create(effectPath), -1,CCString:create(""))
                angerStar:setAnchorPoint(ccp(0.5,0.5))
                
                if(card:getContentSize().width>150)then
                    angerStar:setPosition(22+(j-1)*20,19)
                    angerStar:setScale(1.5)
                else
                    angerStar:setPosition(14+(j-1)*14,12)
                end
                card:addChild(angerStar,3,130+j)
                
                local redSprite = card:getChildByTag(10+j)
                if(redSprite~=nil)then
                    redSprite:setVisible(false)
                end
            end
        end
    else
        for j=1,4 do
            
            local tpSprite = card:getChildByTag(130+j)
            if(tpSprite~=nil)then
                card:removeChildByTag(130+j,true)
            end
            
            local redSprite = card:getChildByTag(10+j)
            if(redSprite~=nil)then
                redSprite:setVisible(true)
            end
        end
    end
end

-- 退出场景，释放不必要资源
function release (...) 

end

function getBattleOutLinePlayerCard(hid)
    
    hid = tonumber(hid)

    local cardPath = isBoss==true and IMG_PATH .. "bigcard/" or IMG_PATH .. "card/"
    
    local imageFile
    local grade
    if(htid~=nil)then
        local hero = DB_Heroes.getDataById(htid)
        grade = hero.star_lv
        imageFile = hero.boss_icon_id
    elseif(hid<10000000) then
        local monster = DB_Monsters.getDataById(hid)
        if(monster==nil) then
            monster = DB_Monsters.getDataById(1002011)
        end
        local monsterTmpl = DB_Monsters_tmpl.getDataById(monster.htid)
        grade = monsterTmpl.star_lv
        imageFile = monsterTmpl.boss_icon_id
    else
        local allHeros = HeroModel.getAllHeroes()
        if(allHeros==nil or allHeros[hid..""] == nil)then
            grade = hid%6+1
            imageFile = "zhan_jiang_guojia.png"
        else
            local htid = allHeros[hid..""].htid
            local hero = DB_Heroes.getDataById(htid)
            grade = hero.star_lv
            imageFile = hero.boss_icon_id
        end
    end
    
    local blankSprite = CCXMLSprite:create(IMG_PATH .. "card/blankcard.png")
    blankSprite:initXMLSprite(CCString:create(IMG_PATH .. "card/blankcard.png"));
    blankSprite:setAnchorPoint(ccp(0.5,0.5))
    blankSprite:setCascadeOpacityEnabled(true)
    blankSprite:setCascadeColorEnabled(true)
    
    local card = CCSprite:create("images/base/hero/body_img/" .. imageFile)
    card:setAnchorPoint(ccp(0.5,0))
    card:setPosition(ccp(blankSprite:getContentSize().width*0.5,0))
    card:setCascadeOpacityEnabled(true)
    card:setCascadeColorEnabled(true)
    
    blankSprite:addChild(card)
    return blankSprite
end

function getFormationPlayerCard(hid,isBoss,htid,dressId)
    require "script/battle/BattleLayer"
    BattleLayer.initPlayerCardHidMap()
    local hidMap = BattleLayer.m_playerCardHidMap
    if(dressId~=nil and tonumber(dressId) > 0 )then
        local dress = DB_Item_dress.getDataById(tonumber(dressId))
        if(dress.changeModel) then
            local modelArray = lua_string_split(dress.changeModel,",")
            for modelIndex=1,#modelArray do
                local baseHtid = lua_string_split(modelArray[modelIndex],"|")[1]
                local dressFile = lua_string_split(modelArray[modelIndex],"|")[2]
                local heroTmpl = DB_Heroes.getDataById(tonumber(htid))
                if(heroTmpl.model_id == tonumber(baseHtid))then
                    print("m_playerCardHidMap[cardInfo.hid]:",hid,baseHtid)
                    hidMap[hid .. ""] = {}
                    hidMap[hid .. ""].actionFile = dressFile
                end
            end
        end
    end
    
    if(hid == nil)then
        hid = 0
    end
    hid = tonumber(hid)
    local heroInfo = HeroModel.getHeroByHid(hid)
    if(isBoss==nil)then
        isBoss = false
    end
    htid = tonumber(htid)
    local imageFile
    local grade
    if(htid~=nil)then
        local hero = DB_Heroes.getDataById(htid)
        grade = hero.star_lv
        imageFile = hero.action_module_id
        if heroInfo then
            heroInfo.turned_id = tonumber(heroInfo.turned_id) or 0
            if heroInfo.turned_id ~= 0 then
                turnedId = heroInfo.turned_id
                imageFile = HeroTurnedData.getHeroCardImgById(heroInfo.turned_id)
                print("1", imageFile)
            end
        end
    else
        if(hid<10000000) then
            local monster = DB_Monsters.getDataById(hid)
            if(monster==nil) then
                monster = DB_Monsters.getDataById(1002011)
            end
            local monsterTmpl = DB_Monsters_tmpl.getDataById(monster.htid)
            grade = monsterTmpl.star_lv
            imageFile = monsterTmpl.action_module_id
        else
            local allHeros = HeroModel.getAllHeroes()
            if(allHeros[hid..""] == nil) then
                grade = hid%6+1
                imageFile = "zhu_nanxing.png"
            else
                local htid = allHeros[hid..""].htid
                local hero = DB_Heroes.getDataById(htid)
                grade = hero.star_lv
                imageFile = hero.action_module_id
                if heroInfo then
                    heroInfo.turned_id = tonumber(heroInfo.turned_id) or 0
                    if heroInfo.turned_id ~= 0 then
                        turnedId = heroInfo.turned_id
                        imageFile = HeroTurnedData.getHeroCardImgById(heroInfo.turned_id)
                        print("2", imageFile)  
                    end
                end
            end
        end
    end
    
    if(hidMap[hid .. ""]~=nil and hidMap[hid .. ""].actionFile~=nil)then
        imageFile = hidMap[hid .. ""].actionFile
    end
    if heroInfo then
        heroInfo.turned_id = heroInfo.turned_id or 0
        if heroInfo.turned_id ~= 0 then
            turnedId = heroInfo.turned_id
            imageFile = HeroTurnedData.getHeroCardImgById(heroInfo.turned_id)    
        end
        print("3", imageFile)
    end
    print("turnedId", turnedId)
    printTable("heroInfo", heroInfo)

    local card = CCXMLSprite:create(IMG_PATH .. "card/card_" .. (grade) .. ".png")
    card:initXMLSprite(CCString:create(IMG_PATH .. "card/card_" .. (grade) .. ".png"));
    card:setAnchorPoint(ccp(0.5,0.5))
    card:setCascadeOpacityEnabled(true)
    card:setCascadeColorEnabled(true)
    
    local heroSprite = CCSprite:create("images/base/hero/action_module/" .. imageFile);
    heroSprite:setAnchorPoint(ccp(0.5,0))
    local turnedId = nil
    if heroInfo then
        turnedId = heroInfo.turned_id
    end
    local changeY = getDifferenceYByImageName(htid,imageFile,false, turnedId)
    heroSprite:setPosition(card:getContentSize().width/2,card:getContentSize().height*0.17+changeY)
    card:addChild(heroSprite,2,1)
    print("turnedId 2", turnedId, changeY)
    
    local topSprint = CCSprite:create(IMG_PATH .. "card/card_" .. (grade) .. "_top.png")
    topSprint:setAnchorPoint(ccp(0,1))
    topSprint:setPosition(0,card:getContentSize().height)
    card:addChild(topSprint,1,2)
    
    local heroBgSprite = CCSprite:create(IMG_PATH .. "card/card_hero_bg.png");
    heroBgSprite:setAnchorPoint(ccp(0.5,0))
    heroBgSprite:setPosition(card:getContentSize().width/2,card:getContentSize().height*0.17)
    card:addChild(heroBgSprite,0,8)

    if(isBoss)then
        card:setScale(1.5)
    end
    return card
end

--[[
    @des:得到据点卡牌
--]]
function getCardByArmyId(armyId)
    armyId = tonumber(armyId)
    local army = DB_Army.getDataById(armyId)
    local team = DB_Team.getDataById(army.monster_group)
    local monsterHtid = team.copyTeamShowId
    return getBattlePlayerCardImage(0,nil,monsterHtid,nil)
end

--[[
    @des:设置战斗中卡牌是否显示武将名称
--]]
function setNameVisible( isVisible )
    _isNameVisble = isVisible
    for k,v in pairs(_nameLabelArray) do
        local nameLabel = tolua.cast(v,"CCRenderLabel")
        if(nameLabel) then
            nameLabel:setVisible(isVisible)
            print("nameLabel:setVisible(isVisible)", isVisible)
        else
            _nameLabelArray[k] = nil
            print("nameLabel:setVisible(isVisible)", k)
        end
    end
end

--[[
    @des:设置当前战斗数据
--]]
function setBattleData( battleData )
    _battleData = battleData
end

--[[
    @des:得到战斗中的武将信息
--]]
function getBattleHeroInfo( p_hid )
    if table.isEmpty(_battleData) then
        return
    end
    local heroInfo = nil
    for k,v in pairs(_battleData.team1.arrHero) do
        if (tonumber(v.hid) == tonumber(p_hid)) then
            heroInfo = v
        end
    end

    for k,v in pairs(_battleData.team2.arrHero) do
        if (tonumber(v.hid) == tonumber(p_hid)) then
            heroInfo = v
        end
    end
    -- if heroInfo == nil then
    --     error("not find hid " .. p_hid .. "in battle info")
    -- end
    return heroInfo
end

--[[
    @des:判断战斗中武将的神兵羁绊有木有开
    @parm:p_hid 武将hid
    @ret: true 开启 false 未开启
--]]
function isOpenGodUnion( p_hid )
    if not p_hid then
        return false
    end

    local heroInfo = getBattleHeroInfo(p_hid)
    printTable("heroInfo", heroInfo)
    local unionInfo = GodWeaponItemUtil.unionInfoForFight(heroInfo)
    printTable("unionInfo", unionInfo)
    if not table.isEmpty(unionInfo) then
        return true
    else
        return false
    end
end

--[[
    @des: 得到队伍主角名称
--]]
function getNecessaryName( hid )
    if(_battleData == nil) then
        return
    end

    for i,v in ipairs(_battleData.team1.arrHero) do
        print("team1: hid , v.hid",hid , v.hid)
        if(tonumber(hid) == tonumber(v.hid)) then
            return _battleData.team1.name
        end
    end

    for i,v in ipairs(_battleData.team2.arrHero) do
        print("team2:hid , v.hid",hid , v.hid)
        if(tonumber(hid) == tonumber(v.hid)) then
            return _battleData.team2.name
        end
    end  
end

-- added by bzx
function getFormationPlayerCardByHeroData(heroData,isBoss,htid,dressId)
    
    if(dressId~=nil and tonumber(dressId) > 0 )then
        require "db/DB_Item_dress"
        local dress = DB_Item_dress.getDataById(tonumber(dressId))
        if(dress.changeModel) then
            local modelArray = lua_string_split(dress.changeModel,",")
            for modelIndex=1,#modelArray do
                local baseHtid = lua_string_split(modelArray[modelIndex],"|")[1]
                local dressFile = lua_string_split(modelArray[modelIndex],"|")[2]
                local heroTmpl = DB_Heroes.getDataById(tonumber(htid))
                if(heroTmpl.model_id == tonumber(baseHtid))then
                    heroData = {}
                    heroData.actionFile = dressFile
                end
            end
        end
    end
    if(isBoss==nil)then
        isBoss = false
    end
    local imageFile
    local grade
    if(htid~=nil)then
        local hero = DB_Heroes.getDataById(htid)
        grade = hero.star_lv
        imageFile = hero.action_module_id
        hero.turned_id = tonumber(hero.turned_id) or 0
        if hero.turned_id ~= 0 then
            imageFile = HeroTurnedData.getHeroCardImgById(hero.turned_id)
        end
    else
        if(tonumber(heroData.hid)<10000000) then
            local monster = DB_Monsters.getDataById(hid)
            if(monster==nil) then
                monster = DB_Monsters.getDataById(1002011)
            end
            local monsterTmpl = DB_Monsters_tmpl.getDataById(monster.htid)
            grade = monsterTmpl.star_lv
            imageFile = monsterTmpl.action_module_id
        else
            local hero = DB_Heroes.getDataById(htid)
            grade = hero.star_lv
            imageFile = hero.action_module_id
            hero.turned_id = tonumber(hero.turned_id) or 0
            if hero.turned_id ~= 0 then
                imageFile = HeroTurnedData.getHeroCardImgById(hero.turned_id)
            end
        end
    end
    if heroData.actionFile ~= nil then
        imageFile = heroData.actionFile
    end
    heroData.turned_id = tonumber(heroData.turned_id) or 0
    if heroData.turned_id ~= 0 then
        imageFile = HeroTurnedData.getHeroCardImgById(heroData.turned_id)
    end
    
    local card = CCXMLSprite:create(IMG_PATH .. "card/card_" .. (grade) .. ".png")
    card:initXMLSprite(CCString:create(IMG_PATH .. "card/card_" .. (grade) .. ".png"));
    card:setAnchorPoint(ccp(0.5,0.5))
    card:setCascadeOpacityEnabled(true)
    card:setCascadeColorEnabled(true)

    local heroSprite = CCSprite:create("images/base/hero/action_module/" .. imageFile);
    heroSprite:setAnchorPoint(ccp(0.5,0))
    
    local changeY = getDifferenceYByImageName(htid,imageFile,false)
    heroSprite:setPosition(card:getContentSize().width/2,card:getContentSize().height*0.17+changeY)
    card:addChild(heroSprite,2,1)
    
    local topSprint = CCSprite:create(IMG_PATH .. "card/card_" .. (grade) .. "_top.png")
    topSprint:setAnchorPoint(ccp(0,1))
    topSprint:setPosition(0,card:getContentSize().height)
    card:addChild(topSprint,1,2)
    
    local heroBgSprite = CCSprite:create(IMG_PATH .. "card/card_hero_bg.png");
    heroBgSprite:setAnchorPoint(ccp(0.5,0))
    heroBgSprite:setPosition(card:getContentSize().width/2,card:getContentSize().height*0.17)
    card:addChild(heroBgSprite,0,8)

    if(isBoss)then
        card:setScale(1.5)
    end
    return card
end

function getDifferenceYByImageName(htid,imageFile,isBoss, pTurnedId)
    if(isBoss==nil)then
        isBoss = false;
    end
    
    local changeY = 0
    if("zhan_jiang_dingyuan.png"==imageFile) then
            changeY = -37
    elseif("zhan_jiang_guanyinping.png"==imageFile) then
        changeY = -25
    elseif("zhan_jiang_zhegeliang.png"==imageFile) then
        changeY = -44
    elseif("zhan_jiang_zhenji.png"==imageFile) then
        changeY = -8
    elseif("zhan_jiang_ganning.png"==imageFile and isBoss==false) then
        changeY = -17
    elseif("zhan_jiang_xiahoudun.png"==imageFile and isBoss==false) then
        changeY = -17
    elseif("zhan_jiang_zhangfei.png"==imageFile and isBoss==false) then
        changeY = -6
    elseif("zhan_jiang_nvzhu.png"==imageFile) then
        if(Platform.getPlatformFlag() == "ios_korea" or Platform.getPlatformFlag() == "Android_korea"
         or Platform.getPlatformFlag() == "Android_kakao" or Platform.getPlatformFlag() == "ios_kakao")then
            changeY = -37
        else
            changeY = -23
        end
    elseif("zhan_jiang_zhugeliang.png"==imageFile and isBoss==false) then
        changeY = -40
    elseif("zhan_jiang_sunjian.png"==imageFile and isBoss==false) then
        changeY = -10
    elseif("zhan_jiang_taishici.png"==imageFile and isBoss==false) then
        changeY = -30
    elseif("zhan_jiang_zhangbao.png"==imageFile) then
        changeY = -47
    elseif("zhan_jiang_dongzhuo.png"==imageFile) then
        changeY = -15
    elseif("zhan_jiang_simayi.png"==imageFile) then
        changeY = -12
    elseif("zhan_jiang_wujiang9.png"==imageFile) then
        changeY = -38
    elseif("zhan_jiang_yujin.png"==imageFile) then
        changeY = -44
    elseif("zhan_jiang_zhaoyun.png"==imageFile and isBoss==false) then
        changeY = -32
    elseif("zhan_jiang_zhaoyun.png"==imageFile) then
        changeY = -49
    elseif("zhan_jiang_xuchu.png"==imageFile and isBoss == false) then
        changeY = -10
    elseif("zhan_jiang_xuchu.png"==imageFile) then
        changeY = -12
    elseif("zhan_jiang_xuhuang.png"==imageFile and isBoss == false) then
        changeY = -32
    elseif("zhan_jiang_xuhuang.png"==imageFile) then
        changeY = -68
    elseif("zhan_jiang_xunyou.png"==imageFile) then
        changeY = -35
    elseif("zhan_jiang_guanping.png"==imageFile) then
        changeY = -22
    elseif("zhan_jiang_chengpu.png"==imageFile) then
        changeY = -21
    elseif("zhan_jiang_lvbu.png"==imageFile and isBoss==false) then
        changeY = -45
    elseif("zhan_jiang_molvbu.png"==imageFile and isBoss==false) then
        changeY = -102
    elseif("zhan_jiang_mozhangjiao.png"==imageFile and isBoss==false) then
        changeY = -78
    elseif("zhan_jiang_molvbu.png"==imageFile) then
        changeY = -138
    elseif("zhan_jiang_mozhangjiao.png"==imageFile) then
        changeY = -144
    elseif("zhan_jiang_mowang.png"==imageFile) then
        changeY = -41
    elseif("zhan_jiang_mowang_1.png"==imageFile) then
        changeY = -41
    elseif("zhan_jiang_sunjian.png"==imageFile) then
        changeY = -32
    elseif("zhan_jiang_lvbu.png"==imageFile) then
        changeY = -63
    elseif("zhan_jiang_fazheng.png"==imageFile) then
        changeY = -20
    elseif("zhan_jiang_caoren.png"==imageFile and isBoss==false) then
        changeY = -42
    elseif("zhan_jiang_handang.png"==imageFile and isBoss==false) then
        changeY = -27
    elseif("zhan_jiang_huatuo.png"==imageFile and isBoss==false) then
        changeY = -38
    elseif("zhan_jiang_sunquan.png"==imageFile and isBoss==false) then
        changeY = -46
    elseif("zhan_jiang_zhuhuan.png"==imageFile and isBoss==false) then
        changeY = -14
    elseif("zhan_jiang_nanzhu2.png"==imageFile and isBoss==false) then
        if(Platform.getPlatformFlag() == "ios_korea" or Platform.getPlatformFlag() == "Android_korea"
         or Platform.getPlatformFlag() == "Android_kakao" or Platform.getPlatformFlag() == "ios_kakao")then
            changeY = -37
        else
            changeY = -29
        end
    elseif("zhan_jiang_nanzhu.png"==imageFile and isBoss==false) then
        if(Platform.getPlatformFlag() == "ios_korea" or Platform.getPlatformFlag() == "Android_korea"
         or Platform.getPlatformFlag() == "Android_kakao" or Platform.getPlatformFlag() == "ios_kakao")then
            changeY = -37
        else
            changeY = 0
        end
    elseif("zhan_jiang_nvzhu2.png"==imageFile and isBoss==false) then
        if(Platform.getPlatformFlag() == "ios_korea" or Platform.getPlatformFlag() == "Android_korea"
         or Platform.getPlatformFlag() == "Android_kakao" or Platform.getPlatformFlag() == "ios_kakao")then
            changeY = -37
        else
            changeY = -16
        end
    elseif("zhan_jiang_wenguan6.png"==imageFile and isBoss==false) then
        changeY = -61
    elseif("zhan_jiang_yinma.png"==imageFile and isBoss==false) then
        changeY = -25
    elseif("zhan_jiang_jinma.png"==imageFile and isBoss==false) then
        changeY = -23
    elseif("zhan_jiang_zhuyi.png"==imageFile and isBoss==false) then
        changeY = -43
    elseif("zhan_jiang_masu.png"==imageFile and isBoss== false) then
        changeY = -59
    elseif("zhan_jiang_zhuyi.png"==imageFile ) then
        changeY = -52
    elseif("zhan_jiang_yinma.png"==imageFile ) then
        changeY = -18
    elseif("zhan_jiang_jinma.png"==imageFile ) then
        changeY = -16
    elseif("zhan_jiang_caoren.png"==imageFile ) then
        changeY = -66
    elseif("zhan_jiang_ganning.png"==imageFile) then
        changeY = -32
    elseif("zhan_jiang_handang.png"==imageFile ) then
        changeY = -26
    elseif("zhan_jiang_sunquan.png"==imageFile ) then
        changeY = -81
    elseif("zhan_jiang_zhugeliang.png"==imageFile ) then
        changeY = -56
    elseif("zhan_jiang_taishici.png"==imageFile ) then
        changeY = -77
    elseif("zhan_jiang_feiyi.png"==imageFile ) then
        changeY = -38
    elseif("zhan_jiang_guansuo.png"==imageFile ) then
        changeY = -41
    elseif("zhan_jiang_masu.png"==imageFile ) then
        changeY = -110
    elseif("zhan_jiang_simazhao.png"==imageFile ) then
        changeY = -36
    elseif("zhan_jiang_yangxiu.png"==imageFile ) then
        changeY = -45
    elseif("zhan_jiang_xiahouyuan.png"==imageFile and isBoss==false) then
        changeY = -29
    elseif("zhan_jiang_xiahouyuan.png"==imageFile ) then
        changeY = -37
    elseif("zhan_jiang_nanzhu_shizhuang1.png"==imageFile ) then
        changeY = -21
    elseif("zhan_jiang_nvzhu_shizhuang1.png"==imageFile ) then
        changeY = -32
    elseif("zhan_jiang_weiyan.png"==imageFile and isBoss==false) then
        changeY = -7
    elseif("zhan_jiang_jiangwei.png"==imageFile and isBoss==false) then
        changeY = -0
    elseif("zhan_jiang_jiangwei.png"==imageFile ) then
        changeY = -47
    elseif("zhan_jiang_weiyan.png"==imageFile ) then
        changeY = -66
    elseif("zhan_jiang_xushu.png"==imageFile and isBoss==false) then
        changeY = -6 
    elseif("zhan_jiang_xushu.png"==imageFile ) then
        changeY = -66
    elseif("zhan_jiang_yuji.png"==imageFile and isBoss==false) then
        changeY = -20

    elseif("zhan_jiang_yuanshu.png"==imageFile and isBoss==false) then
        changeY = -6
    elseif("zhan_jiang_zhurong.png"==imageFile and isBoss==false) then
        changeY = -17    
    elseif("zhan_jiang_caocao_1.png"==imageFile and isBoss==false) then
        changeY = -80    
    elseif("zhan_jiang_diaochan_1.png"==imageFile and isBoss==false) then
        changeY = -28    
    elseif("zhan_jiang_ganning_1.png"==imageFile and isBoss==false) then
        changeY = -29
    elseif("zhan_jiang_guanyu_1.png"==imageFile and isBoss==false) then
        changeY = -12                
    elseif("zhan_jiang_guojia_1.png"==imageFile and isBoss==false) then
        changeY = -20
    elseif("zhan_jiang_huatuo_1.png"==imageFile and isBoss==false) then
        changeY = -47    
    elseif("zhan_jiang_jiaxu_1.png"==imageFile and isBoss==false) then
        changeY = -26    
    elseif("zhan_jiang_luxun_1.png"==imageFile and isBoss==false) then
        changeY = -34
    elseif("zhan_jiang_lvmeng_1.png"==imageFile and isBoss==false) then
        changeY = -30                
    elseif("zhan_jiang_machao_1.png"==imageFile and isBoss==false) then
        changeY = -35
    elseif("zhan_jiang_sunce_1.png"==imageFile and isBoss==false) then
        changeY = -81    
    elseif("zhan_jiang_taishici_1.png"==imageFile and isBoss==false) then
        changeY = -64    
    elseif("zhan_jiang_weiyan_1.png"==imageFile and isBoss==false) then
        changeY = -17
    elseif("zhan_jiang_xiahoudun_1.png"==imageFile and isBoss==false) then
        changeY = -76                
    elseif("zhan_jiang_zhangfei_.png"==imageFile and isBoss==false) then
        changeY = -8
    elseif("zhan_jiang_zhanghe_1.png"==imageFile and isBoss==false) then
        changeY = -31    
    elseif("zhan_jiang_zhangjiao_1.png"==imageFile and isBoss==false) then
        changeY = -23    
    elseif("zhan_jiang_zhangliao_1.png"==imageFile and isBoss==false) then
        changeY = -28
    elseif("zhan_jiang_zhugeliang_1.png"==imageFile and isBoss==false) then
        changeY = -51                
    elseif("zhan_jiang_zuoci_1.png"==imageFile and isBoss==false) then
        changeY = -25
    elseif("zhan_jiang_zhangfei_1.png"==imageFile and isBoss==false) then
        changeY = -81

    --add by lichenyang
    elseif("zhan_jiang_weiyan.png"==imageFile and isBoss==false) then
        changeY = -7
    elseif("zhan_jiang_nanzhu3.png"==imageFile and isBoss==false) then
        changeY = -64
    elseif("zhan_jiang_nvzhu3.png"==imageFile and isBoss==false) then
        changeY = -50
    elseif("zhan_jiang_dengai.png"==imageFile and isBoss==false) then
        changeY = -71
    elseif("zhan_jiang_jianggan.png"==imageFile and isBoss==false) then
        changeY = -34
    elseif("zhan_jiang_pangtong.png"==imageFile and isBoss==false) then
        changeY = -75
    elseif("zhan_jiang_sunce.png"==imageFile and isBoss==false) then
        changeY = -57
    elseif("zhan_jiang_yanyan.png"==imageFile and isBoss==false) then
        changeY = -25
    elseif("zhan_jiang_chengyu.png"==imageFile and isBoss==false) then
        changeY = -25
    elseif("zhan_jiang_gongsunzan.png"==imageFile and isBoss==false) then
        changeY = -42
    elseif("zhan_jiang_maliang.png"==imageFile and isBoss==false) then
        changeY = -21
    elseif("zhan_jiang_wenyang.png"==imageFile and isBoss==false) then
        changeY = -22
    elseif("zhan_jiang_zhangzhongjing.png"==imageFile and isBoss==false) then
        changeY = -44
    elseif("zhan_jiang_zhugeke.png"==imageFile and isBoss==false) then
        changeY = -38
    elseif("zhan_jiang_zhangjiao.png"==imageFile and isBoss==false) then
        changeY = -0

    elseif("zhan_jiang_baosanniang.png"==imageFile and isBoss==false) then
        changeY = -28
    elseif("zhan_jiang_liaohua.png"==imageFile and isBoss==false) then
        changeY = -13
    elseif("zhan_jiang_liuxie.png"==imageFile and isBoss==false) then
        changeY = -10
    elseif("zhan_jiang_nanhualaoxian.png"==imageFile and isBoss==false) then
        changeY = -36
    elseif("zhan_jiang_xunyu.png"==imageFile and isBoss==false) then
        changeY = -34
    elseif("zhan_jiang_machao.png"==imageFile and isBoss==false) then
        changeY = 0
    elseif("zhan_jiang_caopei.png"==imageFile and isBoss==false) then
        changeY = 0
    elseif("zhan_jiang_liubei.png"==imageFile and isBoss==false) then
        changeY = 0
    elseif("zhan_jiang_menghuo.png"==imageFile and isBoss==false) then
        changeY = 0
    elseif("zhan_jiang_dianwei.png"==imageFile and isBoss==false) then
        changeY = -31
    elseif("zhan_jiang_diaochan.png"==imageFile and isBoss==false) then
        changeY = -15
    elseif("zhan_jiang_guanyu.png"==imageFile and isBoss == false) then
        changeY = -32
    elseif("zhan_jiang_zhangliao.png"==imageFile and isBoss == false) then
        changeY = -23
    elseif("zhan_jiang_pangde.png"==imageFile and isBoss == false) then
        changeY = -42
    elseif("zhan_jiang_nanzhu_shizhuang4.png"==imageFile and isBoss == false) then
        changeY = -33
    elseif("zhan_jiang_nvzhu_shizhuang4.png"==imageFile and isBoss == false) then
        changeY = -26
    elseif("zhan_jiang_dongzhuo_1.png"==imageFile and isBoss == false) then
        changeY = -25
    elseif("zhan_jiang_liubei_1.png"==imageFile and isBoss == false) then
        changeY = -46
    elseif("zhan_jiang_sunquan_1.png"==imageFile and isBoss == false) then
        changeY = -24
    elseif("zhan_jiang_xuhuang_1.png"==imageFile and isBoss == false) then
        changeY = -28
    elseif("zhan_jiang_nanzhu_shizhuang5.png"==imageFile and isBoss == false) then
        changeY = -7
    elseif("zhan_jiang_nvzhu_shizhuang5.png"==imageFile and isBoss == false) then
        changeY = -65       
    elseif("zhan_jiang_huangzhong_1.png"==imageFile and isBoss == false) then
        changeY = -6
    elseif("zhan_jiang_lejin_1.png"==imageFile and isBoss == false) then
        changeY = -9      
    elseif("zhan_jiang_nvzhu_shizhuang5.png"==imageFile and isBoss == false) then
        changeY = -5
    elseif("zhan_jiang_yuanshao_1.png"==imageFile and isBoss == false) then
        changeY = -0
    elseif("zhan_jiang_jiangwei_1.png"==imageFile and isBoss == false) then
        changeY = -5
    elseif("zhan_jiang_nanzhu_shizhuang6.png"==imageFile and isBoss == false) then
        changeY = -19
    elseif("zhan_jiang_nvzhu_shizhuang6.png"==imageFile and isBoss == false) then
        changeY = -29
    elseif("zhan_jiang_xiaoqiao_1.png"==imageFile and isBoss == false) then
        changeY = -26
    elseif("zhan_jiang_yujin_1.png"==imageFile and isBoss == false) then
        changeY = -30
    elseif("zhan_jiang_yuji_1.png"==imageFile and isBoss == false) then
        changeY = -27
    elseif("zhan_jiang_lvbu_1.png"==imageFile and isBoss == false) then
        changeY = -21
    elseif("zhan_jiang_simayi_1.png"==imageFile and isBoss == false) then
        changeY = -23
    elseif("zhan_jiang_zhaoyun_1.png"==imageFile and isBoss == false) then
        changeY = -24
    elseif("zhan_jiang_zhouyu_1.png"==imageFile and isBoss == false) then
        changeY = -47
    elseif("zhan_jiang_nanzhu_shizhuang7.png"==imageFile and isBoss == false) then
        changeY = -39
    elseif("zhan_jiang_nvzhu_shizhuang7.png"==imageFile and isBoss == false) then
        changeY = -36
    elseif("zhan_jiang_chengong_1.png"==imageFile and isBoss == false) then
        changeY = -45
    elseif("zhan_jiang_dianwei_1.png"==imageFile and isBoss == false) then
        changeY = -23
    elseif("zhan_jiang_huangyueying_1.png"==imageFile and isBoss == false) then
        changeY = -57
    elseif("zhan_jiang_sunshangxiang_1.png"==imageFile and isBoss == false) then
        changeY = -25
    elseif("zhan_jiang_luxun.png" == imageFile and isBoss == false) then
        changeY = -0
    elseif("zhan_jiang_caiwenji_1.png" == imageFile and isBoss == false) then
        changeY = -48
    elseif("zhan_jiang_huaxiong_1.png" == imageFile and isBoss == false) then
        changeY = -25
    elseif("zhan_jiang_sunjian_1.png" == imageFile and isBoss == false) then
        changeY = -19
    elseif("zhan_jiang_xushu_1.png" == imageFile and isBoss == false) then
        changeY = -24
    elseif("zhan_jiang_zhoutai_1.png" == imageFile and isBoss == false) then
        changeY = -18
    elseif("zhan_jiang_caiwenji_1.png" == imageFile) then
        changeY = -53
    elseif("zhan_jiang_huaxiong_1.png" == imageFile) then
        changeY = -66
    elseif("zhan_jiang_sunjian_1.png" == imageFile) then
        changeY = -49
    elseif("zhan_jiang_xushu_1.png" == imageFile) then
        changeY = -30
    elseif("zhan_jiang_zhoutai_1.png" == imageFile) then
        changeY = -58
    elseif("zhan_jiang_dingyuan.png" == imageFile) then
        changeY = -46
    elseif("zhan_jiang_xushu.png" == imageFile) then
        changeY = -66
    elseif("zhan_jiang_luxun.png" == imageFile) then
        changeY = -43
    elseif("zhan_jiang_chengong_1.png" == imageFile) then
        changeY = -30
    elseif("zhan_jiang_dianwei_1.png" == imageFile) then
        changeY = -61
    elseif("zhan_jiang_huangyueying_1.png" == imageFile) then
        changeY = -21
    elseif("zhan_jiang_sunshangxiang_1.png" == imageFile) then
        changeY = -26
    elseif("zhan_jiang_zhangfei_1.png" == imageFile) then
        changeY = -122
    elseif("zhan_jiang_lvbu_1.png" == imageFile) then
        changeY = -36
    elseif("zhan_jiang_zhouyu_1.png" == imageFile) then
        changeY = -16
    elseif("zhan_jiang_weiyan_1.png" == imageFile) then
        changeY = -30
    elseif("zhan_jiang_zuoci_1.png"==imageFile) then
        changeY = -54  
    elseif("zhan_jiang_zhugeliang_1.png"==imageFile) then
        changeY = -38  
    elseif("zhan_jiang_caocao_1.png"==imageFile) then
        changeY = -57  
    elseif("zhan_jiang_yujin_1.png"==imageFile) then
        changeY = -27
    elseif("zhan_jiang_yuji_1.png"==imageFile) then
        changeY = -37
    elseif("zhan_jiang_xiaoqiao_1.png"==imageFile) then
        changeY = -42
    elseif("zhan_jiang_jiangwei_1.png"==imageFile) then
        changeY = -40
    elseif("zhan_jiang_xiahoudun_1.png"==imageFile) then
        changeY = -25  
    elseif("zhan_jiang_taishici_1.png"==imageFile) then
        changeY = -21
    elseif("zhan_jiang_guojia_1.png"==imageFile) then
        changeY = -46
    elseif("zhan_jiang_huangzhong_1.png"==imageFile) then
        changeY = -41
    elseif("zhan_jiang_lejin_1.png"==imageFile) then
        changeY = -39
    elseif("zhan_jiang_yuanshao_1.png"==imageFile) then
        changeY = -28
    elseif("zhan_jiang_dongzhuo_1.png"==imageFile) then
        changeY = -32
    elseif("zhan_jiang_liubei_1.png"==imageFile) then
        changeY = -76
    elseif("zhan_jiang_sunquan_1.png"==imageFile) then
        changeY = -41
    elseif("zhan_jiang_xuhuang_1.png"==imageFile) then
        changeY = -30
    elseif("zhan_jiang_zhuhuan.png"==imageFile) then
        changeY = -35
    elseif("zhan_jiang_pangde.png"==imageFile) then
        changeY = -62
    elseif("zhan_jiang_dengai.png"==imageFile ) then
        changeY = -71
    elseif("zhan_jiang_guyong.png"==imageFile ) then
        changeY = -4
    elseif("zhan_jiang_jianggan.png"==imageFile ) then
        changeY = -35
    elseif("zhan_jiang_mateng.png"==imageFile ) then
        changeY = -25
    elseif("zhan_jiang_pangtong.png"==imageFile ) then
        changeY = -94
    elseif("zhan_jiang_sunce.png"==imageFile ) then
        changeY = -96
    elseif("zhan_jiang_sunce_1.png"==imageFile ) then
        changeY = -94
    elseif("zhan_jiang_yanyan.png"==imageFile ) then
        changeY = -53
    elseif("zhan_jiang_nanzhu_shizhuang3.png"==imageFile ) then
        changeY = -26
    elseif("zhan_jiang_chengyu_37px.png"==imageFile ) then
        changeY = -25
    elseif("zhan_jiang_nvzhu_shizhuang3.png"==imageFile ) then
        changeY = -25
    elseif("zhan_jiang_chengyu.png"==imageFile ) then
        changeY = -25
    elseif("zhan_jiang_gongsunzan.png"==imageFile ) then
        changeY = -89
    elseif("zhan_jiang_maliang.png"==imageFile ) then
        changeY = -21
    elseif("zhan_jiang_wenyang.png"==imageFile ) then
        changeY = -22
    elseif("zhan_jiang_zhangzhongjing.png"==imageFile ) then
        changeY = -44
    elseif("zhan_jiang_zhugeke.png"==imageFile ) then
        changeY = -38
    elseif("zhan_jiang_zhangjiao.png"==imageFile) then
        changeY = -17
    elseif("zhan_jiang_baosanniang.png"==imageFile) then
        changeY = -36
    elseif("zhan_jiang_liaohua.png"==imageFile) then
        changeY = -6
    elseif("zhan_jiang_xunyu.png"==imageFile) then
        changeY = -70
    elseif("zhan_jiang_caopei.png"==imageFile) then
        changeY = -28
    elseif("zhan_jiang_dianwei.png"==imageFile) then
        changeY = -43
    elseif("zhan_jiang_diaochan.png"==imageFile) then
        changeY = -60
    elseif("zhan_jiang_guanyu.png"==imageFile) then
        changeY = -54
    elseif("zhan_jiang_liubei.png"==imageFile) then
        changeY = -55
    elseif("zhan_jiang_machao.png"==imageFile) then
        changeY = -60
    elseif("zhan_jiang_menghuo.png"==imageFile) then
        changeY = -36
    elseif("zhan_jiang_zhangfei.png"==imageFile) then
        changeY = -32
    elseif("zhan_jiang_nanzhu_shizhuang8.png"==imageFile) then
        changeY = -26
    elseif("zhan_jiang_nvzhu_shizhuang8.png"==imageFile) then
        changeY = -24
    elseif("zhan_jiang_nanzhu_shizhuang9.png"==imageFile) then
        changeY = -43
    elseif("zhan_jiang_nvzhu_shizhuang9.png"==imageFile) then
        changeY = -48
    elseif("zhan_jiang_ganning_1.png" == imageFile) then
        changeY = -61
    elseif("zhan_jiang_nvzhu_shizhuang10.png" == imageFile) then
        changeY = -31
    elseif("zhan_jiang_nanzhu_shizhuang11.png" == imageFile) then
        changeY = -38
    elseif("zhan_jiang_nvzhu_shizhuang11.png" == imageFile) then
        changeY = -40
    elseif("zhan_jiang_nanzhu_shizhuang12.png" == imageFile) then
        changeY = -22
    elseif("zhan_jiang_nvzhu_shizhuang12.png" == imageFile) then
        changeY = -55
    elseif("zhan_jiang_nanzhu_shizhuang13.png" == imageFile) then
        changeY = -47
    elseif("zhan_jiang_nvzhu_shizhuang13.png" == imageFile) then
        changeY = -50
    elseif("zhan_jiang_nanzhu_shizhuang14.png" == imageFile) then
        changeY = -62
    elseif("zhan_jiang_nvzhu_shizhuang14.png" == imageFile) then
        changeY = -34
    elseif("zhan_jiang_nanzhu_shizhuang15.png" == imageFile) then
        changeY = -42
    elseif("zhan_jiang_nvzhu_shizhuang15.png" == imageFile) then
        changeY = -43
    elseif("zhan_jiang_nanzhu_shizhuang16.png" == imageFile) then
        changeY = -47
    elseif("zhan_jiang_nvzhu_shizhuang16.png" == imageFile) then
        changeY = -31
    elseif("zhan_jiang_nanzhu_shizhuang17.png" == imageFile) then
        changeY = -27
    elseif("zhan_jiang_nvzhu_shizhuang17.png" == imageFile) then
        changeY = -27
    elseif("zhan_jiang_nanzhu_shizhuang18.png" == imageFile) then
        changeY = -24
    elseif("zhan_jiang_nvzhu_shizhuang18.png" == imageFile) then
        changeY = -26
    elseif("zhan_jiang_nanzhu_shizhuang19.png" == imageFile) then
        changeY = -40
    elseif("zhan_jiang_nvzhu_shizhuang19.png" == imageFile) then
        changeY = -23
    elseif("zhan_jiang_nanzhu_shizhuang20.png" == imageFile) then
        changeY = -20
    elseif("zhan_jiang_nvzhu_shizhuang20.png" == imageFile) then
        changeY = -21
    elseif("zhan_jiang_nanzhu_shizhuang21.png" == imageFile) then
        changeY = -30
    elseif("zhan_jiang_nvzhu_shizhuang21.png" == imageFile) then
        changeY = -14
    elseif("zhan_jiang_nanzhu_shizhuang22.png" == imageFile) then
        changeY = -30
    elseif("zhan_jiang_nvzhu_shizhuang22.png" == imageFile) then
        changeY = -23
    elseif("zhan_jiang_nanzhu_shizhuang23.png" == imageFile) then
        changeY = -20
    elseif("zhan_jiang_nvzhu_shizhuang23.png" == imageFile) then
        changeY = -19 
    elseif("zhan_jiang_nanzhu_shizhuang24.png" == imageFile) then
        changeY = -25
    elseif("zhan_jiang_nvzhu_shizhuang24.png" == imageFile) then
        changeY = -50 
    end

    local isDress = false
    for k,v in pairs(DB_Item_dress.Item_dress) do
        local dbInfo = DB_Item_dress.getDataById(v[1])
        local changeModel = string.split(dbInfo.changeModel, ",")
        for k,v in pairs(changeModel) do
            local imageInfo = string.split(v, "|")
            if imageInfo[2] == imageFile then
                isDress = true
                break
            end
        end
        if isDress then
            break
        end
    end
    
    if pTurnedId and pTurnedId ~= 0 then
        print("pTurnedId offset 1", changeY)
        print("imageFile", imageFile)
        local turnedDbInfo = HeroTurnedData.getTurnDBInfoById(pTurnedId)
        if isBoss and turnedDbInfo.bigOffset then
            changeY = -tonumber(turnedDbInfo.bigOffset) 
        elseif turnedDbInfo.littleOffset then
            changeY = -tonumber(turnedDbInfo.littleOffset)
        end
        print("pTurnedId offset 2", changeY)
    else
        if not isDress then
            local heroInfo = DB_Heroes.getDataById(htid)
            if(heroInfo==nil) then
                local monsterInfo = DB_Monsters.getDataById(htid)
                heroInfo = DB_Heroes.getDataById(monsterInfo.htid)
            end
            if isBoss and heroInfo.bigOffset then
                changeY = -tonumber(heroInfo.bigOffset) 
            elseif heroInfo.littleOffset then
                changeY = -tonumber(heroInfo.littleOffset)
            end
        end
    end
    return changeY
end