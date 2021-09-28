-- Filename: BattleLayerLee.lua
-- Author: k
-- Date: 2013-05-27
-- Purpose: 战斗场景



require "script/utils/extern"
require "script/utils/LuaUtil"
--require "amf3"
-- 主城场景模块声明
module("BattleCardUtilLee", package.seeall)


local IMG_PATH = "images/battle/"				-- 图片主路径


function getBattlePlayerCard(hid,isBoss,htid,isdemonLoad)
     --hid = (hid == nil) and 0 or hid
    --print("=============  getBattlePlayerCard hid:",hid)
   --hid = (hid == nil) and 0 or hid
    --print("=============  getBattlePlayerCard hid:",hid)
    hid = tonumber(hid)
    isBoss = isBoss==nil and false or isBoss
    isdemonLoad = isdemonLoad==nil and false or isdemonLoad
    
    local cardPath = isBoss==true and IMG_PATH .. "bigcard/" or IMG_PATH .. "card/"
    
    local imageFile
    local grade
    if(htid~=nil)then
        
        require "db/DB_Heroes"
        local hero = DB_Heroes.getDataById(htid)
        
        grade = hero.star_lv
        imageFile = hero.action_module_id
    elseif(hid<10000000) then
        require "db/DB_Monsters"
        local monster = DB_Monsters.getDataById(hid)
        
        if(monster==nil) then
           monster = DB_Monsters.getDataById(3014201)
        end
        
        require "db/DB_Monsters_tmpl"
        local monsterTmpl = DB_Monsters_tmpl.getDataById(monster.htid)
        
        grade = monsterTmpl.star_lv
        imageFile = monsterTmpl.action_module_id
    else
        require "script/model/hero/HeroModel"
        require "script/utils/LuaUtil"
        local allHeros = HeroModel.getAllHeroes()
        if(allHeros==nil or allHeros[hid..""] == nil)then
            
            grade = hid%6+1
            imageFile = "zhan_jiang_guojia.png"
            --[[
        end
        --print_table("tb",allHeros)
        --print("----------- allHeros[hid].htid",allHeros[hid..""])
        --print("----------- allHeros[hid].htid",allHeros[hid])
        if(allHeros[hid..""] == nil) then
            
            grade = hid%6+1
            imageFile = "zhan_jiang_guojia.png"
             --]]
        else
            local htid = allHeros[hid..""].htid
               
            require "db/DB_Heroes"
            local hero = DB_Heroes.getDataById(htid)
            
            grade = hero.star_lv
            imageFile = hero.action_module_id
        end
    end
    
    if(isdemonLoad==true)then
        grade = 99
        cardPath = IMG_PATH .. "bigcard/"
        isBoss = true
    end
    
    local card = CCXMLSprite:create(cardPath .. "card_" .. (grade) .. ".png")
    card:initXMLSprite(CCString:create(cardPath .. "card_" .. (grade) .. ".png"));
    card:setAnchorPoint(ccp(0.5,0.5))
    card:setCascadeOpacityEnabled(true)
    card:setCascadeColorEnabled(true)
    
    -- print("============= imageFile",imageFile)
    local heroSprite = nil
    if((isBoss==true or isdemonLoad==true) and file_exists("images/base/hero/action_module_b/" .. imageFile)==true)then
        heroSprite = CCSprite:create("images/base/hero/action_module_b/" .. imageFile);
    else
        heroSprite = CCSprite:create("images/base/hero/action_module/" .. imageFile);
    end
    heroSprite:setAnchorPoint(ccp(0.5,0))
    local changeY = 0
    if("zhan_jiang_dingyuan.png"==imageFile) then
        changeY = -37
    elseif("zhan_jiang_guanyinping.png"==imageFile) then
        changeY = -25
    elseif("zhan_jiang_zhegeliang.png"==imageFile) then
        changeY = -44
    elseif("zhan_jiang_zhenji.png"==imageFile) then
        changeY = -8
    elseif("zhan_jiang_diaochan.png"==imageFile) then
        changeY = -15
    elseif("zhan_jiang_ganning.png"==imageFile) then
        changeY = -17
    elseif("zhan_jiang_xiahoudun.png"==imageFile) then
        changeY = -17
        elseif("zhan_jiang_zhangfei.png"==imageFile) then
        changeY = -6
        elseif("zhan_jiang_nvzhu.png"==imageFile) then
        changeY = -23
        elseif("zhan_jiang_wenguan6.png"==imageFile) then
        changeY = -61
        elseif("zhan_jiang_zhugeliang.png"==imageFile) then
        changeY = -44
        elseif("zhan_jiang_sunjian.png"==imageFile and isdemonLoad==false) then
        changeY = -10
        elseif("zhan_jiang_taishici.png"==imageFile) then
        changeY = -30
        elseif("zhan_jiang_zhangbao.png"==imageFile) then
        changeY = -47
        elseif("zhan_jiang_guanyu.png"==imageFile) then
        changeY = -31
        elseif("zhan_jiang_dongzhuo.png"==imageFile) then
        changeY = -15
        elseif("zhan_jiang_simayi.png"==imageFile) then
        changeY = -12
        elseif("zhan_jiang_wujiang9.png"==imageFile) then
        changeY = -38
        elseif("zhan_jiang_yujin.png"==imageFile) then
        changeY = -44
        elseif("zhan_jiang_zhaoyun.png"==imageFile) then
        changeY = -32
        elseif("zhan_jiang_zhurong.png"==imageFile) then
        changeY = -17
        elseif("zhan_jiang_sunce.png"==imageFile) then
        changeY = -31
        elseif("zhan_jiang_xuchu.png"==imageFile) then
        changeY = -10
        elseif("zhan_jiang_xuhuang.png"==imageFile) then
        changeY = -32
        elseif("zhan_jiang_xushu.png"==imageFile) then
        changeY = -6
        elseif("zhan_jiang_dianwei.png"==imageFile) then
        changeY = -31
        elseif("zhan_jiang_weiyan.png"==imageFile) then
        changeY = -7
        elseif("zhan_jiang_xunyou.png"==imageFile) then
        changeY = -35
        elseif("zhan_jiang_guanping.png"==imageFile) then
        changeY = -22
        elseif("zhan_jiang_chengpu.png"==imageFile) then
        changeY = -21
        elseif("zhan_jiang_xunyu.png"==imageFile) then
        changeY = -21
        elseif("zhan_jiang_lvbu.png"==imageFile) then
        changeY = -45
        elseif("zhan_jiang_molvbu.png"==imageFile and isdemonLoad==false) then
        changeY = -102
        elseif("zhan_jiang_mozhangjiao.png"==imageFile and isdemonLoad==false) then
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
    end
    
    if(isdemonLoad==true)then
        changeY = changeY - card:getContentSize().height*0.027
    end
    
    --local changeY = ("jiang_xinxianying.png"==imageFile) and -16 or 0
    heroSprite:setPosition(card:getContentSize().width/2,card:getContentSize().height*0.17+changeY)
    card:addChild(heroSprite,2,1)
    
    local topSprint = CCSprite:create(cardPath .. "card_" .. (grade) .. "_top.png")
    topSprint:setAnchorPoint(ccp(0,1))
    topSprint:setPosition(0,card:getContentSize().height)
    card:addChild(topSprint,1,2)
    
    --取消职业现实
    --[[
    local bottomSprint = CCSprite:create(cardPath .. "card_" .. (grade) .. "_bottom.png")
    bottomSprint:setAnchorPoint(ccp(1,0))
    bottomSprint:setPosition(card:getContentSize().width,card:getContentSize().height*0.17)
    card:addChild(bottomSprint,3,3)
    bottomSprint:setCascadeOpacityEnabled(true)
    bottomSprint:setCascadeColorEnabled(true)
    
    local occupationSprite = CCSprite:create(IMG_PATH .. "occupation/occupation_" .. (grade) .. ".png")
    occupationSprite:setAnchorPoint(ccp(0,1))
    occupationSprite:setPosition(bottomSprint:getContentSize().width*0,bottomSprint:getContentSize().height*1)
    bottomSprint:addChild(occupationSprite,4,4)
    --]]
    local shadowSprint = CCSprite:create(cardPath .. "card_shadow.png")
    shadowSprint:setAnchorPoint(ccp(0,1))
    shadowSprint:setPosition(-6,card:getContentSize().height+5)
    card:addChild(shadowSprint,-1,5)
    
    local hpLineBg = CCSprite:create(cardPath .. "hpline_bg.png")
    hpLineBg:setAnchorPoint(ccp(0.5,0.5))
    hpLineBg:setPosition(card:getContentSize().width*0.5,card:getContentSize().height*-0.05)
    card:addChild(hpLineBg,1,6)
    hpLineBg:setCascadeOpacityEnabled(true)
    hpLineBg:setCascadeColorEnabled(true)
    
    local hpLine = CCSprite:create(cardPath .. "hpline.png")
    hpLine:setAnchorPoint(ccp(0,0.5))
    hpLine:setPosition(0,hpLineBg:getContentSize().height*0.5)
    hpLineBg:addChild(hpLine,1,7)
    ---[[
    local heroBgSprite = CCSprite:create(cardPath .. "card_hero_bg.png");
    heroBgSprite:setAnchorPoint(ccp(0.5,0))
    heroBgSprite:setPosition(card:getContentSize().width/2,card:getContentSize().height*0.17)
    card:addChild(heroBgSprite,0,8)
     --]]
    
    
    return card
end

function setCardHp(card,scale)
    --判断是否为标准卡牌
    if(card~=nil and card:getChildByTag(6)~=nil and card:getChildByTag(6):getChildByTag(7)~=nil)then
        local hpLine = tolua.cast(card:getChildByTag(6):getChildByTag(7), "CCSprite")
        local textureSize = hpLine:getTexture():getContentSize()
        hpLine:setTextureRect(CCRectMake(0,0,textureSize.width*scale,textureSize.height))
    end
end

function setCardAnger(card,angerPoint)
    --判断是否为标准卡牌
    if(card~=nil and card:getChildByTag(6)~=nil and card:getChildByTag(6):getChildByTag(7)~=nil)then
        local angerPerPoint = 1
        
        if(card==nil)then
            return
        end
        
        local angerNumber = math.floor( angerPoint/angerPerPoint)
        --angerNumber = angerNumber>4 and 4 or angerNumber
        
        for j=1,4 do
            local sp = tolua.cast(card:getChildByTag(10+j),"CCSprite")
            if(angerNumber>=j)then
                if(sp==nil)then
                    if(card:getContentSize().width>150)then
                        
                        local angerStar = CCSprite:create(IMG_PATH .. "bigcard/anger.png")
                        --替换为动画
                        --local angerStar = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/nuqi"), -1,CCString:create(""))
                        angerStar:setAnchorPoint(ccp(0.5,0.5))
                        angerStar:setPosition(22+(j-1)*20,21)
                        card:addChild(angerStar,3,10+j)
                    else
                        local angerStar = CCSprite:create(IMG_PATH .. "card/anger.png")
                        --替换为动画
                        --local angerStar = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/nuqi"), -1,CCString:create(""))
                        angerStar:setAnchorPoint(ccp(0.5,0.5))
                        --angerStar:setPosition(17+(j-1)*14,13.5)
                        
                        angerStar:setPosition(14+(j-1)*14,12)
                        card:addChild(angerStar,3,10+j)
                    end
                end
            else
                if(sp~=nil)then
                    sp:removeFromParentAndCleanup(true)
                end
            end
        end
        
        if(angerNumber>4)then
            local spellEffectSprite = card:getChildByTag(131)
            if(spellEffectSprite==nil)then
                local originalFormat = CCTexture2D:defaultAlphaPixelFormat()
                CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
                local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. "nuqibaoman"), -1,CCString:create(""))
                
                spellEffectSprite:setPosition(ccp(card:getContentSize().width/2,card:getContentSize().height*0.1))
                spellEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
                card:addChild(spellEffectSprite,-2,131);
                CCTexture2D:setDefaultAlphaPixelFormat(originalFormat)
            end
            --[[
            --delegate
            local animationEnd = function(actionName,xmlSprite)
                spellEffectSprite:removeFromParentAndCleanup(true)
            end
            
            local animationFrameChanged = function(frameIndex,xmlSprite)
            end

            --增加动画监听
            local delegate = BTAnimationEventDelegate:create()
            delegate:registerLayerEndedHandler(animationEnd)
            delegate:registerLayerChangedHandler(animationFrameChanged)
            spellEffectSprite:setDelegate(delegate)
             --]]
        else
            --card:removeChildByTag(131,true)
            
            local bSprite = card:getChildByTag(131)
            if(bSprite~=nil)then
                bSprite:removeFromParentAndCleanup(true)
            end
        end
    end
    --[[
    for i=1,angerNumber do
        local angerStar = CCSprite:create(IMG_PATH .. "card/anger.png")
        angerStar:setAnchorPoint(ccp(0.5,0.5))
        angerStar:setPosition(14+(i-1)*14,12)
        card:addChild(angerStar,3,10+i)
    end
     --]]
end

-- 退出场景，释放不必要资源
function release (...) 

end

function getBattleOutLinePlayerCard(hid)
    
    --hid = (hid == nil) and 0 or hid
    --print("=============  getBattlePlayerCard hid:",hid)
    hid = tonumber(hid)

    local cardPath = isBoss==true and IMG_PATH .. "bigcard/" or IMG_PATH .. "card/"
    
    local imageFile
    local grade
    if(htid~=nil)then
        
        require "db/DB_Heroes"
        local hero = DB_Heroes.getDataById(htid)
        
        grade = hero.star_lv
        imageFile = hero.boss_icon_id
    elseif(hid<10000000) then
        require "db/DB_Monsters"
        local monster = DB_Monsters.getDataById(hid)
        
        if(monster==nil) then
            monster = DB_Monsters.getDataById(1002011)
        end
        
        require "db/DB_Monsters_tmpl"
        local monsterTmpl = DB_Monsters_tmpl.getDataById(monster.htid)
        
        grade = monsterTmpl.star_lv
        imageFile = monsterTmpl.boss_icon_id
    else
        require "script/model/hero/HeroModel"
        require "script/utils/LuaUtil"
        local allHeros = HeroModel.getAllHeroes()
        if(allHeros==nil or allHeros[hid..""] == nil)then
            
            grade = hid%6+1
            imageFile = "zhan_jiang_guojia.png"
            --[[
             end
             --print_table("tb",allHeros)
             --print("----------- allHeros[hid].htid",allHeros[hid..""])
             --print("----------- allHeros[hid].htid",allHeros[hid])
             if(allHeros[hid..""] == nil) then
             
             grade = hid%6+1
             imageFile = "zhan_jiang_guojia.png"
             --]]
            else
            local htid = allHeros[hid..""].htid
            
            require "db/DB_Heroes"
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
    --local card = CCXMLSprite:create("images/base/hero/body_img/" .. imageFile)
    --card:initXMLSprite(CCString:create("images/base/hero/body_img/" .. imageFile));
    card:setAnchorPoint(ccp(0.5,0))
    card:setPosition(ccp(blankSprite:getContentSize().width*0.5,0))
    card:setCascadeOpacityEnabled(true)
    card:setCascadeColorEnabled(true)
    
    blankSprite:addChild(card)
    
    --return card
    return blankSprite
end

function getFormationPlayerCard(hid,isBoss)
    
    --hid = (hid == nil) and 0 or hid
    --print("=============  getBattlePlayerCard hid:",hid)
    hid = tonumber(hid)
    isBoss = isBoss==nil and false or isBoss
    
    
    local imageFile
    local grade
    if(hid<10000000) then
        require "db/DB_Monsters"
        local monster = DB_Monsters.getDataById(hid)
        
        if(monster==nil) then
            monster = DB_Monsters.getDataById(1002011)
        end
        
        require "db/DB_Monsters_tmpl"
        local monsterTmpl = DB_Monsters_tmpl.getDataById(monster.htid)
        
        grade = monsterTmpl.star_lv
        imageFile = monsterTmpl.action_module_id
        else
        require "script/model/hero/HeroModel"
        local allHeros = HeroModel.getAllHeroes()
        require "script/utils/LuaUtil"
        --print_table("tb",allHeros)
        --print("----------- allHeros[hid].htid",allHeros[hid..""])
        --print("----------- allHeros[hid].htid",allHeros[hid])
        if(allHeros[hid..""] == nil) then
            
            grade = hid%6+1
            imageFile = "zhu_nanxing.png"
            else
            local htid = allHeros[hid..""].htid
            
            require "db/DB_Heroes"
            local hero = DB_Heroes.getDataById(htid)
            
            grade = hero.star_lv
            imageFile = hero.action_module_id
        end
    end
    
    local card = CCXMLSprite:create(IMG_PATH .. "card/card_" .. (grade) .. ".png")
    card:initXMLSprite(CCString:create(IMG_PATH .. "card/card_" .. (grade) .. ".png"));
    card:setAnchorPoint(ccp(0.5,0.5))
    card:setCascadeOpacityEnabled(true)
    card:setCascadeColorEnabled(true)
    
    --print("============= imageFile",imageFile)
    local heroSprite = CCSprite:create("images/base/hero/action_module/" .. imageFile);
    heroSprite:setAnchorPoint(ccp(0.5,0))
    local changeY = 0
    if("zhan_jiang_dingyuan.png"==imageFile) then
        changeY = -37
        elseif("zhan_jiang_guanyinping.png"==imageFile) then
        changeY = -25
        elseif("zhan_jiang_zhegeliang.png"==imageFile) then
        changeY = -44
        elseif("zhan_jiang_zhenji.png"==imageFile) then
        changeY = -8
        elseif("zhan_jiang_diaochan.png"==imageFile) then
        changeY = -15
        elseif("zhan_jiang_ganning.png"==imageFile) then
        changeY = -17
        elseif("zhan_jiang_xiahoudun.png"==imageFile) then
        changeY = -17
        elseif("zhan_jiang_zhangfei.png"==imageFile) then
        changeY = -6
        elseif("zhan_jiang_nvzhu.png"==imageFile) then
        changeY = -23
        elseif("zhan_jiang_wenguan6.png"==imageFile) then
        changeY = -61
        elseif("zhan_jiang_zhugeliang.png"==imageFile) then
        changeY = -44
        elseif("zhan_jiang_sunjian.png"==imageFile) then
        changeY = -10
        elseif("zhan_jiang_taishici.png"==imageFile) then
        changeY = -30
        elseif("zhan_jiang_zhangbao.png"==imageFile) then
        changeY = -47
        elseif("zhan_jiang_guanyu.png"==imageFile) then
        changeY = -12
        elseif("zhan_jiang_dongzhuo.png"==imageFile) then
        changeY = -15
        elseif("zhan_jiang_simayi.png"==imageFile) then
        changeY = -12
        elseif("zhan_jiang_wujiang9.png"==imageFile) then
        changeY = -38
        elseif("zhan_jiang_yujin.png"==imageFile) then
        changeY = -44
        elseif("zhan_jiang_zhaoyun.png"==imageFile) then
        changeY = -32
        elseif("zhan_jiang_zhurong.png"==imageFile) then
        changeY = -17
        elseif("zhan_jiang_molvbu.png"==imageFile) then
        changeY = -102
        elseif("zhan_jiang_mozhangjiao.png"==imageFile) then
        changeY = -78
    end
    --local changeY = ("jiang_xinxianying.png"==imageFile) and -16 or 0
    heroSprite:setPosition(card:getContentSize().width/2,card:getContentSize().height*0.17+changeY)
    card:addChild(heroSprite,2,1)
    
    local topSprint = CCSprite:create(IMG_PATH .. "card/card_" .. (grade) .. "_top.png")
    topSprint:setAnchorPoint(ccp(0,1))
    topSprint:setPosition(0,card:getContentSize().height)
    card:addChild(topSprint,1,2)
    
    --取消职业现实
    --[[
     local bottomSprint = CCSprite:create(IMG_PATH .. "card/card_" .. (grade) .. "_bottom.png")
     bottomSprint:setAnchorPoint(ccp(1,0))
     bottomSprint:setPosition(card:getContentSize().width,card:getContentSize().height*0.17)
     card:addChild(bottomSprint,3,3)
     bottomSprint:setCascadeOpacityEnabled(true)
     bottomSprint:setCascadeColorEnabled(true)
     
     local occupationSprite = CCSprite:create(IMG_PATH .. "occupation/occupation_" .. (grade) .. ".png")
     occupationSprite:setAnchorPoint(ccp(0,1))
     occupationSprite:setPosition(bottomSprint:getContentSize().width*0,bottomSprint:getContentSize().height*1)
     bottomSprint:addChild(occupationSprite,4,4)
     
    local shadowSprint = CCSprite:create(IMG_PATH .. "card/card_shadow.png")
    shadowSprint:setAnchorPoint(ccp(0,1))
    shadowSprint:setPosition(-6,card:getContentSize().height+5)
    card:addChild(shadowSprint,-1,5)
     
     --]]
    --[[
    local hpLineBg = CCSprite:create(IMG_PATH .. "card/hpline_bg.png")
    hpLineBg:setAnchorPoint(ccp(0.5,0.5))
    hpLineBg:setPosition(card:getContentSize().width*0.5,card:getContentSize().height*-0.05)
    card:addChild(hpLineBg,1,6)
    hpLineBg:setCascadeOpacityEnabled(true)
    hpLineBg:setCascadeColorEnabled(true)
    
    local hpLine = CCSprite:create(IMG_PATH .. "card/hpline.png")
    hpLine:setAnchorPoint(ccp(0,0.5))
    hpLine:setPosition(0,hpLineBg:getContentSize().height*0.5)
    hpLineBg:addChild(hpLine,1,7)
     --]]
    ---[[
    local heroBgSprite = CCSprite:create(IMG_PATH .. "card/card_hero_bg.png");
    heroBgSprite:setAnchorPoint(ccp(0.5,0))
    heroBgSprite:setPosition(card:getContentSize().width/2,card:getContentSize().height*0.17)
    card:addChild(heroBgSprite,0,8)
    --]]
    
    if(isBoss)then
        card:setScale(1.5)
    end
    
    return card
end
