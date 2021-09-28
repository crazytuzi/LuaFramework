-- Filename：    OneKeyRobCell.lua
-- Author：      DJN
-- Date：        2014-7-8
-- Purpose：     一键夺宝

module("OneKeyRobCell", package.seeall)

require "db/DB_Loot"

function createCell( pCellInfo, pCellIndex)
    -- 创建cell
    local pOrder = 0
    local str_height = 40
   
    local cell = CCTableViewCell:create()
    cell:setContentSize(CCSizeMake(515, 110))

    if pCellInfo == nil then
        return cell
    end
    --左上角图标
    local cell_icon = CCSprite:create("images/digCowry/star_bg.png")
    cell_icon:setAnchorPoint(ccp(0,1))
    cell_icon:setPosition(ccpsprite(0,1, cell))
    cell:addChild(cell_icon,pOrder)
    -- 第x行 
    local str_times = pCellIndex or " "
    local times_label = CCLabelTTF:create(GetLocalizeStringBy("lcyx_1987", pCellIndex),g_sFontPangWa, 21)
 
    times_label:setAnchorPoint(ccp(0.5,0.5))
    times_label:setColor(ccc3(0xff, 0xe4, 0x00))
    times_label:setPosition(ccp(cell_icon:getContentSize().width*0.5-10, cell_icon:getContentSize().height*0.5+3))
    cell_icon:addChild(times_label)
    -- 横线
    local line = CCSprite:create("images/common/line02.png")
    line:setAnchorPoint(ccp(0,0.5))
    line:setPosition(ccpsprite(1, 0.5, cell_icon))
    line:setScaleX(2)
    cell_icon:addChild(line,pOrder+1)
    
    --银币图标
    local silver_icon = CCSprite:create("images/common/coin_silver.png")
    silver_icon:setAnchorPoint(ccp(0,0))
    silver_icon:setPosition(ccp(25,str_height))
    cell:addChild(silver_icon)

    -- 银币
    local lootInfo = DB_Loot.getDataById(1)
    local str_silver = math.min(tonumber(lootInfo.win_silver)*UserModel.getHeroLevel(), tonumber(lootInfo.max_win_silver))
    local silver_label = CCLabelTTF:create("+"..str_silver,g_sFontPangWa, 18)
    silver_label:setAnchorPoint(ccp(0,0))
    silver_label:setColor(ccc3(0x00,0xe4,0xff))
    silver_label:setPosition(ccp(58,str_height))
    cell:addChild(silver_label)

    --EXP图标
    local EXP_icon = CCSprite:create("images/arena/exp.png")
    EXP_icon:setAnchorPoint(ccp(0,0))
    EXP_icon:setPosition(ccp(175,str_height))
    cell:addChild(EXP_icon)

    -- EXP
    -- 一键抢夺默认为直接胜利
    local str_EXP = tonumber(lootInfo.win_exp)*UserModel.getHeroLevel()
    local EXP_label = CCLabelTTF:create("+"..str_EXP, g_sFontPangWa, 18)
    EXP_label:setAnchorPoint(ccp(0,0))
    EXP_label:setColor(ccc3(0x00,0xe4,0xff))
    EXP_label:setPosition(ccp(233,str_height))
    cell:addChild(EXP_label)

    --耐力图标
    local naili_icon = CCSprite:create("images/match/stamina.png")
    naili_icon:setAnchorPoint(ccp(0,0))
    naili_icon:setScale(0.75)
    naili_icon:setPosition(ccp(335,str_height))
    cell:addChild(naili_icon)

    -- 耐力
    local str_naili = "2" or " "
    local naili_label = CCLabelTTF:create("-"..str_naili,g_sFontPangWa, 18)
    naili_label:setAnchorPoint(ccp(0,0))
    naili_label:setColor(ccc3(0xff,0x17,0x0c))
    naili_label:setPosition(ccp(385,str_height))
    cell:addChild(naili_label)

    local desArray = {}
    --得到碎片
    if pCellInfo.fragId then
        local itemInfo = ItemUtil.getItemById(pCellInfo.fragId)
        local contentInfo = {}
        contentInfo.labelDefaultColor = ccc3(0xff, 0xe4, 0x00)
        contentInfo.labelDefaultSize = 21
        contentInfo.defaultType = "CCRenderLabel"
        contentInfo.lineAlignment = 1
        contentInfo.labelDefaultFont = g_sFontPangWa
        contentInfo.elements = {
            {
                text = itemInfo.name,
                color = HeroPublicLua.getCCColorByStarLevel(itemInfo.quality)
                
            },
        }
        local fragmDes = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("lcyx_1989"), contentInfo)
        table.insert(desArray, fragmDes)
    end
    if pCellInfo.fragId then
        local spaceNode = CCSprite:create()
        spaceNode:setContentSize(CCSizeMake(90, 5))
        table.insert(desArray, spaceNode)
    end
    --消耗耐力丹
    if pCellInfo.medicine then
        local contentInfo = {}
        contentInfo.labelDefaultColor = ccc3(0xff, 0xe4, 0x00)
        contentInfo.labelDefaultSize = 21
        contentInfo.defaultType = "CCRenderLabel"
        contentInfo.lineAlignment = 1
        contentInfo.labelDefaultFont = g_sFontPangWa
        contentInfo.elements = {
            {
                type = "CCNode",
                create = function ( ... )
                    local node = CCSprite:create("images/common/stamina_small.png")
                    return node
                end
            },
        }
        local staminaDes = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("lcyx_1988"), contentInfo)
        table.insert(desArray, staminaDes)
    end

    local desNode = BaseUI.createHorizontalNode(desArray)
    desNode:setAnchorPoint(ccp(0, 0))
    desNode:setPosition(47, 5)
    cell:addChild(desNode)

    if pCellIndex == table.count(OneKeyRobData.getCardInfo().detail)then
        local desLabel = getStopTipLabel()
        if desLabel then
            desLabel:setAnchorPoint(ccp(0.5, 1))
            desLabel:setPosition(ccpsprite(0.5, 0, cell))
            cell:addChild(desLabel)
        end
    end
    return cell
end

function getStopTipLabel( ... )
    local tipTxt = OneKeyRobData.getStopErr()
    print("tipTxt:",tipTxt)
    if tipTxt == "enough" then
        local treasureId = OneKeyRobDialog.getRobTreasureId()
        local itemInfo = ItemUtil.getItemById(treasureId)
        local contentInfo = {}
        contentInfo.labelDefaultColor = ccc3(0xff, 0xe4, 0x00)
        contentInfo.labelDefaultSize = 25
        contentInfo.defaultType = "CCRenderLabel"
        contentInfo.lineAlignment = 1
        contentInfo.labelDefaultFont = g_sFontPangWa
        contentInfo.elements = {
            {
                text = itemInfo.name,
                color = HeroPublicLua.getCCColorByStarLevel(itemInfo.quality)
                
            },
        }
        local fragmDes = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("lcyx_1994"), contentInfo)
        return fragmDes
    elseif tipTxt == "bagFull" then
        local  tipLabel = CCRenderLabel:create(GetLocalizeStringBy("lcyx_1992"),g_sFontPangWa,25,1, ccc3(0x00, 0x00, 0x00), type_stroke)
        tipLabel:setColor(ccc3(0x97, 0x97, 0x97))
        print("tipTxt:",tipTxt)
        return tipLabel
    elseif tipTxt == "noStamina" then
        local  tipLabel = CCRenderLabel:create(GetLocalizeStringBy("lcyx_1991"),g_sFontPangWa,25,1, ccc3(0x00, 0x00, 0x00), type_stroke)
        tipLabel:setColor(ccc3(0x97, 0x97, 0x97))
        print("tipTxt:",tipTxt)
        return tipLabel
    elseif tipTxt == "noMedicine" then
        local  tipLabel = CCRenderLabel:create(GetLocalizeStringBy("lcyx_1993"),g_sFontPangWa,25,1, ccc3(0x00, 0x00, 0x00), type_stroke)
        tipLabel:setColor(ccc3(0x97, 0x97, 0x97))
        print("tipTxt:",tipTxt)
        return tipLabel
    else
        return nil
    end
end

