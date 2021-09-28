-- FileName: FightPetAction.lua
-- Author: lichenyang
-- Date: 2015-07-21
-- Purpose: 战斗中宠物动作显示
--[[TODO List]]

module("FightPetAction", package.seeall)


--[[
	@des:播放宠物动作
	@parm：pCallback 播放完成回调
--]]
function showPetAtBattle( callbackFunc )
    --是否跳过
    if FightMainLoop.getIsSkip() == true then
        return
    end
    print("show pet battle")
    petNodeContainer = {}
    --判断是否有宠物参战，显示宠物
    local pet1Tid = FightStrModel.getTeam1PetTid()
    local pet2Tid = FightStrModel.getTeam2PetTid()

    if(pet1Tid == nil and pet2Tid == nil) then
        if(callbackFunc) then
            callbackFunc()
        end
        return
    end
    local playerTeam1Pet    =   nil
    local playerTeam2Pet    =   nil

    local isBufferEffectEnd1 = false
    local isBufferEffectEnd2 = false

	local pet1FirstAttackImagePath = nil
	local pet2FirstAttackImagePath = nil
    local bufferEffctEndCallfunc1 = function ( ... )
    	print("bufferEffctEndCallfunc1",pet2Tid ,isBufferEffectEnd2 )
        if(isBufferEffectEnd1 == true) then
            return
        end
        isBufferEffectEnd1 = true

        if(pet2Tid and isBufferEffectEnd2 == false) then
            playerTeam2Pet()
            return
        end

        if(callbackFunc and (isBufferEffectEnd2 == true or pet2Tid == nil)) then
            print("buffer 1 callback")
            callbackFunc()
        end
    end

    local bufferEffctEndCallfunc2 = function ( ... )
        print("isBufferEffectEnd2",pet1Tid ,isBufferEffectEnd1 )
        if(isBufferEffectEnd2 == true) then
            return
        end
        isBufferEffectEnd2 = true
        if(pet1Tid and isBufferEffectEnd1 == false) then
            playerTeam1Pet()
            return
        end

        if(callbackFunc and (isBufferEffectEnd1 == true or pet1Tid == nil)) then
            print("buffer 2 callback")
            callbackFunc()
        end
    end

    local removeNodeFromPetContainer = function ( pNode )
        for k,v in pairs(petNodeContainer) do
            if(v == pNode) then
                petNodeContainer[k] = nil
            end
        end
    end

    --先后手图片路径
    local pet1FirstAttackImagePath = nil
    local pet2FirstAttackImagePath = nil
    --播放卡牌buffer效果
    local isPlayedPetBuffer = false
    local playCardPetBuffer = function ( teamNum )  -- teamNum  1,team1 buffer 效果，2 team2 buffer 效果
        --是否跳过
        if FightMainLoop.getIsSkip() == true then
            return
        end
        isPlayedPetBuffer = true
        if(pet1Tid ~= nil and teamNum == 1) then
            --team1 宠物buffer 特效
            local cardArray  = FightScene.getPlayerCardLayer():getCards()
            for k,v in pairs(cardArray) do
                local cardSprite    = v
                if(cardSprite) then
                    local bufferEffct   = CCLayerSprite:layerSpriteWithNameAndCount("images/battle/pet/cwzhandouli", 1, CCString:create(""))
                    bufferEffct:setPosition(ccpsprite(0.5, 0.5, cardSprite))
                    cardSprite:addChild(bufferEffct, 2000)

                    local animationDelegate = BTAnimationEventDelegate:create()
                    animationDelegate:registerLayerEndedHandler(bufferEffctEndCallfunc1)
                    bufferEffct:setDelegate(animationDelegate)
                    bufferEffct:registerScriptHandler(function ( eventType )
                        if(eventType == "exit") then
                            removeNodeFromPetContainer(bufferEffct)
                        end
                    end)
                    table.insert(petNodeContainer, bufferEffct)
                end

            end
        end
        if(pet2Tid ~= nil and teamNum == 2) then
            --team2 宠物buffer 特效
            local cardArray  = FightScene:getEnemyCardLayer():getCards()
            for k,v in pairs(cardArray) do
                local cardSprite    = v
                if(cardSprite) then
                    local bufferEffct   = CCLayerSprite:layerSpriteWithNameAndCount("images/battle/pet/cwzhandouli", 1, CCString:create(""))
                    bufferEffct:setPosition(ccpsprite(0.5, 0.5, cardSprite))
                    cardSprite:addChild(bufferEffct,2000)

                    local animationDelegate = BTAnimationEventDelegate:create()
                    animationDelegate:registerLayerEndedHandler(bufferEffctEndCallfunc2)
                    bufferEffct:setDelegate(animationDelegate)
                    bufferEffct:registerScriptHandler(function ( eventType )
                        if(eventType == "exit") then
                            removeNodeFromPetContainer(bufferEffct)
                        end
                    end)
                    table.insert(petNodeContainer, bufferEffct)
                end
            end
        end
    end

    local isTeam1First = false
    local isTeam2First = false
    if FightStrModel.isFirstAttack() == 1 then
        --print("team1 first")
        isTeam1First = true
        if(pet1Tid == nil) then
            isTeam1First = false
            isTeam2First = true
        end
    else
        --print("team2 first")
        isTeam2First = true
        if(pet2Tid == nil) then
            isTeam1First = true
            isTeam2First = false
        end
    end

    --播放宠物出场
    playerTeam1Pet = function ( ... )
        if FightMainLoop.getIsSkip() == true then
            return
        end
        require "db/DB_Pet"
        print("playerTeam1Pet")
        if(pet1Tid ~= nil) then
            local pet1Info      = DB_Pet.getDataById(pet1Tid)
            local pet1Sprite    = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/pet/cwdchdown"), -1,CCString:create("")) --
            setAdaptNode(pet1Sprite)
            pet1Sprite:setPosition(ccps(0.5, 0.5))
            FightScene.getEffectLayer():addChild(pet1Sprite, 2000)
            pet1Sprite:registerScriptHandler(function ( eventType )
                if(eventType == "exit") then
                    removeNodeFromPetContainer(pet1Sprite)
                end
            end)
            table.insert(petNodeContainer, pet1Sprite)
            local replaceXmlSprite = tolua.cast( pet1Sprite:getChildByTag(1002) , "CCXMLSprite")
            local bodySprite = nil
            if(file_exists("images/pet/body_img/" .. pet1Info.roleModelID))then
                replaceXmlSprite:setReplaceFileName(CCString:create("images/pet/body_img/" .. pet1Info.roleModelID))
            end
            replaceXmlSprite:setVisible(false)

            local petInfoPanel = createPetInfoPanel(pet1Tid, FightStrModel.getPlayerInfo(), isTeam1First)
            petInfoPanel:setPosition(ccps(-0.5, 0.5))
            FightScene.getEffectLayer():addChild(petInfoPanel, 2005)
            petInfoPanel:runAction(CCMoveTo:create(0.4, ccps(0.55, 0.5)))
            petInfoPanel:registerScriptHandler(function ( eventType )
                if(eventType == "exit") then
                    removeNodeFromPetContainer(petInfoPanel)
                end
            end)
            table.insert(petNodeContainer, petInfoPanel)

            local animationEndFunc = function ( ... )
                pet1Sprite:removeFromParentAndCleanup(true)
                pet1Sprite = nil

                petInfoPanel:removeFromParentAndCleanup(true)
                petInfoPanel = nil

                print("playCardPetBuffer 1")
                playCardPetBuffer(1)
            end

            local animationDelegate = BTAnimationEventDelegate:create()
            animationDelegate:registerLayerEndedHandler(animationEndFunc)
            pet1Sprite:setDelegate(animationDelegate)
        else
            playerTeam2Pet()
        end
    end

    playerTeam2Pet = function ( ... )
        if FightMainLoop.getIsSkip() == true then
            return
        end
        if(pet2Tid ~= nil) then
            local pet2Info      = DB_Pet.getDataById(pet2Tid)
            local petSprite    = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/pet/cwdchup"), -1,CCString:create("")) --
            setAdaptNode(petSprite)
            petSprite:setPosition(ccps(0.5, 0.5))
            FightScene.getEffectLayer():addChild(petSprite, 2000)
            petSprite:registerScriptHandler(function ( eventType )
                if(eventType == "exit") then
                    removeNodeFromPetContainer(petSprite)
                end
            end)
            table.insert(petNodeContainer, petSprite)

            local replaceXmlSprite = tolua.cast( petSprite:getChildByTag(1002) , "CCXMLSprite")
            local bodySprite = nil
            if(file_exists("images/pet/body_img/" .. pet2Info.roleModelID))then
                replaceXmlSprite:setReplaceFileName(CCString:create("images/pet/body_img/" .. pet2Info.roleModelID))
            end
            replaceXmlSprite:setVisible(false)

            local petInfoPanel = createPetInfoPanel(pet2Tid, FightStrModel.getEnemyInfo(),  isTeam2First)
            petInfoPanel:setPosition(ccps(1.5, 0.5))
            FightScene.getEffectLayer():addChild(petInfoPanel, 2005)
            petInfoPanel:runAction(CCMoveTo:create(0.4, ccps(0.55, 0.5)))
            petInfoPanel:registerScriptHandler(function ( eventType )
                if(eventType == "exit") then
                    removeNodeFromPetContainer(petInfoPanel)
                end
            end)
            table.insert(petNodeContainer, petInfoPanel)

            local animationEndFunc = function ( ... )
                petSprite:removeFromParentAndCleanup(true)
                petSprite = nil

                petInfoPanel:removeFromParentAndCleanup(true)
                petInfoPanel = nil

                print("playCardPetBuffer 2")
                playCardPetBuffer(2)
            end

            local animationDelegate = BTAnimationEventDelegate:create()
            animationDelegate:registerLayerEndedHandler(animationEndFunc)
            petSprite:setDelegate(animationDelegate)
        else
            playerTeam1Pet()
        end
    end

    if FightStrModel.isFirstAttack() == 1 then
        pet1FirstAttackImagePath = "images/battle/strength/firstAttack.png"
        pet2FirstAttackImagePath = "images/battle/strength/lastAttack.png"
        playerTeam1Pet()
    elseif FightStrModel.isFirstAttack() == 2 then
        pet2FirstAttackImagePath = "images/battle/strength/firstAttack.png"
        pet1FirstAttackImagePath = "images/battle/strength/lastAttack.png"
        playerTeam2Pet()
    else
        callbackFunc()
    end
end


function createPetInfoPanel( petTid, teamInfo, isFirstAttack)

    local petInfo      = DB_Pet.getDataById(petTid)
    --宠物信息面板
    local petInfoPanel = CCSprite:create("images/battle/pet/pet_info_panel.png")
    petInfoPanel:setAnchorPoint(ccp(0.5, 0.5))
    petInfoPanel:setScale(g_fScaleX)

    local battlePetWord = CCSprite:create("images/battle/pet/battle_pet.png")
    battlePetWord:setPosition(ccpsprite(0.53, 0.95, petInfoPanel))
    battlePetWord:setAnchorPoint(ccp(0.5, 0.5))
    petInfoPanel:addChild(battlePetWord, 2006)

    local petSprite = CCSprite:create("images/pet/body_img/" .. petInfo.roleModelID)
    petSprite:setPosition(ccpsprite(-0.15, 0.5, petInfoPanel))
    petSprite:setAnchorPoint(ccp(0, 0.5))
    petInfoPanel:addChild(petSprite)
    petSprite:setScale(0.5)

    --宠物名称
    local petName = CCRenderLabel:create( petInfo.roleName , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    petName:setPosition(ccpsprite(0, 0, petInfoPanel))
    petInfoPanel:addChild(petName, 2)
    petName:setColor(HeroPublicLua.getCCColorByStarLevel(petInfo.quality))
    --先后手图标
    local firstAttackImagePath = "images/battle/strength/firstAttack.png"
    local lastAttackImagePath = "images/battle/strength/lastAttack.png"
    local attackSprite = nil
    if(isFirstAttack) then
        attackSprite = CCSprite:create(firstAttackImagePath)
    else
        attackSprite = CCSprite:create(lastAttackImagePath)
    end
    -- 玩家名称
    local playName = CCRenderLabel:create( teamInfo.name , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    playName:setColor(ccc3(0xff,0xf6,0x00))
    local nameNode = BaseUI.createHorizontalNode({attackSprite, playName})
    nameNode:setAnchorPoint(ccp(0.5, 0.5))
    nameNode:setPosition(ccpsprite(0.5, 1.15, petInfoPanel))
    petInfoPanel:addChild(nameNode)

    --计算宠物属性数值
    require "script/ui/pet/PetUtil"
    local affixValues = PetUtil.getPetValueByInfo(teamInfo.arrPet[1].arrSkill)
    --print("teamInfo.arrHero.arrSkill")
    --print_table("teamInfo.arrHero.arrSkill", teamInfo.arrHero.arrSkill)
    --print("affixValues pet:")
    --print_table("affixValues", affixValues)
    --宠物属性
    --生命
    affixValues["1"] = affixValues["1"] or {}
    local lifeName = CCRenderLabel:create( GetLocalizeStringBy("lcy_10012") , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lifeName:setColor(ccc3(0xff, 0xf6, 0x00))
    local lifeValue = CCRenderLabel:create( "+" .. (affixValues["1"].displayNum or 0), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lifeValue:setColor(ccc3(0x00, 0xff, 0x18))

    local lifeNode = BaseUI.createHorizontalNode({lifeName, lifeValue})
    lifeNode:setAnchorPoint(ccp(0.5,0.5))
    lifeNode:setPosition(ccpsprite(0.4, 0.7, petInfoPanel))
    petInfoPanel:addChild(lifeNode)

    --攻击
    affixValues["9"] = affixValues["9"] or {}
    local attackName = CCRenderLabel:create( GetLocalizeStringBy("lcy_10013") , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    attackName:setColor(ccc3(0xff, 0xf6, 0x00))
    local attackValue = CCRenderLabel:create( "+" .. (affixValues["9"].displayNum or 0) , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    attackValue:setColor(ccc3(0x00, 0xff, 0x18))

    local attackNode = BaseUI.createHorizontalNode({attackName, attackValue})
    attackNode:setAnchorPoint(ccp(0.5,0.5))
    attackNode:setPosition(ccpsprite(0.7, 0.7, petInfoPanel))
    petInfoPanel:addChild(attackNode)

    --物防
    affixValues["4"] = affixValues["4"] or {}
    local physicsDefenseName = CCRenderLabel:create( GetLocalizeStringBy("lcy_10014") , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    physicsDefenseName:setColor(ccc3(0xff, 0xf6, 0x00))
    local physicsDefenseValue = CCRenderLabel:create( "+" .. (affixValues["4"].displayNum or 0), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    physicsDefenseValue:setColor(ccc3(0x00, 0xff, 0x18))

    local physicsDefenseNode = BaseUI.createHorizontalNode({physicsDefenseName, physicsDefenseValue})
    physicsDefenseNode:setAnchorPoint(ccp(0.5,0.5))
    physicsDefenseNode:setPosition(ccpsprite(0.4, 0.3, petInfoPanel))
    petInfoPanel:addChild(physicsDefenseNode)

    --法防
    affixValues["5"] = affixValues["5"] or {}
    local magicDefenseName = CCRenderLabel:create( GetLocalizeStringBy("lcy_10015") , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    magicDefenseName:setColor(ccc3(0xff, 0xf6, 0x00))
    local magicDefenseValue = CCRenderLabel:create( "+" .. (affixValues["5"].displayNum or 0), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    magicDefenseValue:setColor(ccc3(0x00, 0xff, 0x18))

    local magicDefenseNode = BaseUI.createHorizontalNode({magicDefenseName, magicDefenseValue})
    magicDefenseNode:setAnchorPoint(ccp(0.5,0.5))
    magicDefenseNode:setPosition(ccpsprite(0.7, 0.3, petInfoPanel))
    petInfoPanel:addChild(magicDefenseNode)

    return petInfoPanel
end
