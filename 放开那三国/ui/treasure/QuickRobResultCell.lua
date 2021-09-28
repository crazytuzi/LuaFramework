-- Filename：    QuickRobResultCell.lua
-- Author：      DJN
-- Date：        2014-7-8
-- Purpose：     快速夺宝结果cell

module("QuickRobResultCell", package.seeall)
function createCell( tCellValue,line_count)
    -- 创建cell
    local pOrder = 0
    local str_height = 20
   
    local cell = CCTableViewCell:create()
    
    --如果抽到碎片的话，需要在最下面展示碎片名字，为了UI美观，增加一个空cell占位（引擎目前不支持单独设置某一个cell的高度）
    if(line_count == tonumber(tCellValue.ret.donum) + 1 )then
        return cell
    end
    
    --左上角图标
    local cell_icon = CCSprite:create("images/digCowry/star_bg.png")
    --cell_icon:setContentSize(CCSizeMake(686,30))
    cell_icon:setAnchorPoint(ccp(0,1))
    cell_icon:setPosition(ccp(0,100))
    cell:addChild(cell_icon,pOrder)

    -- 第x行 
    local str_times = line_count or " "
    local times_label = CCLabelTTF:create(GetLocalizeStringBy("key_2886")..line_count..GetLocalizeStringBy("key_3010"),g_sFontPangWa, 21)
 
    times_label:setAnchorPoint(ccp(0.5,0.5))
    times_label:setColor(ccc3(0xff, 0xe4, 0x00))
    times_label:setPosition(ccp(cell_icon:getContentSize().width*0.5-10, cell_icon:getContentSize().height*0.5+3))
    cell_icon:addChild(times_label)
    -- 横线
    local line = CCSprite:create("images/common/line02.png")
    line:setAnchorPoint(ccp(0,0.5))
    line:setPosition(ccp(200,80))
    line:setScaleX(2)
    cell:addChild(line,pOrder+1)
    
    --银币图标
    local silver_icon = CCSprite:create("images/common/coin_silver.png")
    silver_icon:setAnchorPoint(ccp(0,0))
    silver_icon:setPosition(ccp(25,str_height))
    cell:addChild(silver_icon)

    -- 银币
    local str_silver = math.floor(tonumber(tCellValue.ret.reward.silver)/tonumber(tCellValue.ret.donum))or " "
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
    local str_EXP = math.floor(tonumber(tCellValue.ret.reward.exp)/tonumber(tCellValue.ret.donum))or " "
    local EXP_label = CCLabelTTF:create("+"..str_EXP,g_sFontPangWa, 18)
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

    
    if((tostring(line_count) == tCellValue.ret.donum) and tCellValue.ret.reward.fragNum)then
        --展示碎片名
        --require "db/DB_Item_treasure_fragment"
        require "script/ui/treasure/QuickRobData"

        local tableInfo = DB_Item_treasure_fragment.getDataById(QuickRobData.getItemid())
        local fragmentName = tableInfo.name
        --得到品质颜色
        require "script/ui/hero/HeroPublicLua"
        local nameColor = HeroPublicLua.getCCColorByStarLevel(tableInfo.quality)

        local Name_label_1 = CCLabelTTF:create(GetLocalizeStringBy("djn_8"),g_sFontPangWa, 23)
        Name_label_1:setAnchorPoint(ccp(0.5,1))
        Name_label_1:setColor(ccc3(0xff, 0xe4, 0x00))
        Name_label_1:setPosition(ccp(140, str_height-13))
        cell:addChild(Name_label_1)

        local Name_label_2 = CCLabelTTF:create(fragmentName,g_sFontPangWa,23)
        Name_label_2:setAnchorPoint(ccp(0,1))
        Name_label_2:setColor(nameColor)
        Name_label_2:setPosition(ccp((Name_label_1:getPositionX() + (Name_label_1:getContentSize().width*0.5)), str_height-13))
        cell:addChild(Name_label_2)

    end


    return cell
end
