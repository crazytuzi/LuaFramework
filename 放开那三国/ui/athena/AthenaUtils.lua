-- Filename：    AthenaUtils.lua
-- Author：      zhang zihang
-- Date：        2015-3-31
-- Purpose：     主角星魂UI零件方法

module("AthenaUtils",package.seeall)

require "script/ui/athena/AthenaData"
require "script/utils/BaseUI"
require "db/DB_Awake_ability"
local kImgTag = 100             --图片tag
local kLvTag = 200              --等级tag
local kArrowTag = 300           --箭头tag
local kGrayTag = 400            --灰色图tag
local kGBgTag = 500             --灰色底tag
local kNBgTag = 600             --普通底tag
--[[
    @des    :得到普通技能图标
    @param  :技能id
    @param  :页面id
    @return :创建好的menuItem
--]]
function getNormalSkillMenuItem(p_skillId,p_pageNo)
    local skillInfo = AthenaData.getSkillDBInfo(p_skillId)

    --位置
    local posTable = string.split(skillInfo.place,"|")

    local bgPath = "images/base/potential/props_" .. skillInfo.skillQuality .. ".png"

    --背景图
    local bgSprite = CCSprite:create(bgPath)
    local bgSize = bgSprite:getContentSize()

    local skillMenuItem = CCMenuItemSprite:create(bgSprite,bgSprite)
    skillMenuItem:setPosition(ccp(tonumber(posTable[1]),tonumber(posTable[2])))

    local imgPathString = "images/athena/skill_icon/" .. skillInfo.icon
    --如果开启了
    local isSkillOpen = AthenaData.isSkillOpen(p_skillId,p_pageNo)

    --灰色底
    local grayBgSprite = BTGraySprite:create(bgPath)
    grayBgSprite:setAnchorPoint(ccp(0.5,0.5))
    grayBgSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.5))
    grayBgSprite:setVisible(not isSkillOpen)
    skillMenuItem:addChild(grayBgSprite,1,kGBgTag)

    --普通底
    local normalBgSprite = CCSprite:create(bgPath)
    normalBgSprite:setAnchorPoint(ccp(0.5,0.5))
    normalBgSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.5))
    normalBgSprite:setVisible(isSkillOpen)
    skillMenuItem:addChild(normalBgSprite,1,kNBgTag)

    --灰色图标
    local imgSprite = BTGraySprite:create(imgPathString)
    imgSprite:setAnchorPoint(ccp(0.5,0.5))
    imgSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.5))
    imgSprite:setVisible(not isSkillOpen)
    skillMenuItem:addChild(imgSprite,2,kGrayTag)
    --普通图标
    local normalSprite = CCSprite:create(imgPathString)
    normalSprite:setAnchorPoint(ccp(0.5,0.5))
    normalSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.5))
    normalSprite:setVisible(isSkillOpen)
    skillMenuItem:addChild(normalSprite,3,kImgTag)

    --等级
    local skillLv = AthenaData.getSkillLv(p_pageNo,p_skillId)
    local lvLabel = CCRenderLabel:create(skillLv .. "/" .. skillInfo.maxLevel,g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
    lvLabel:setColor(ccc3(0x00,0xff,0x18))
    lvLabel:setAnchorPoint(ccp(0.5,0))
    lvLabel:setPosition(ccp(bgSize.width*0.5,5))
    skillMenuItem:addChild(lvLabel,4,kLvTag)

    --升级
    local isEnough = AthenaData.isGoodEnough(p_skillId,p_pageNo)
    local isFullLv = AthenaData.isFullLv(p_skillId,p_pageNo)
    local upgradeSprite = CCSprite:create("images/common/xiangshang.png")
    upgradeSprite:setAnchorPoint(ccp(0.5,0.5))
    upgradeSprite:setPosition(ccp(bgSize.width,bgSize.height))
    upgradeSprite:setVisible(isSkillOpen and (not isFullLv) and isEnough)
    skillMenuItem:addChild(upgradeSprite,5,kArrowTag)

    return skillMenuItem
end

--[[
    @des    :得到普通技能的图标
    @param  :技能id
    @param  :页面id
    @return :创建好的sprite
--]]
function getNormalSkillSprite(p_skillId,p_pageNo)
    local skillInfo = AthenaData.getSkillDBInfo(p_skillId)
    --背景图
    local bgSprite = CCSprite:create("images/base/potential/props_" .. skillInfo.skillQuality .. ".png")
    local bgSize = bgSprite:getContentSize()
    local imgPathString = "images/athena/skill_icon/" .. skillInfo.icon
    local imgSprite = CCSprite:create(imgPathString)
    imgSprite:setAnchorPoint(ccp(0.5,0.5))
    imgSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.5))
    bgSprite:addChild(imgSprite)

    --等级
    local skillLv = AthenaData.getSkillLv(p_pageNo,p_skillId)
    local lvLabel = CCRenderLabel:create(skillLv .. "/" .. skillInfo.maxLevel,g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
    lvLabel:setColor(ccc3(0x00,0xff,0x18))
    lvLabel:setAnchorPoint(ccp(0.5,0))
    lvLabel:setPosition(ccp(bgSize.width*0.5,5))
    bgSprite:addChild(lvLabel,2,kLvTag)

    return bgSprite
end

--[[
    @des    :刷新等级label
    @param  :要刷新的按钮
    @param  :技能id
    @param  :当前页面
--]]
function refreshLvLabel(p_menuItem,p_skillId,p_pageNo)
    local skillInfo = AthenaData.getSkillDBInfo(p_skillId)
    local skillLv = AthenaData.getSkillLv(p_pageNo,p_skillId)
    local lvLabel = tolua.cast(p_menuItem:getChildByTag(kLvTag),"CCRenderLabel")
    lvLabel:setString(skillLv .. "/" .. skillInfo.maxLevel)
end

--[[
    @des    :刷新箭头图标
    @param  :要刷新的按钮
    @param  :技能id
    @param  :当前页面
--]]
function refreshUpgradeSprite(p_menuItem,p_skillId,p_pageNo)
    local isSkillOpen = AthenaData.isSkillOpen(p_skillId,p_pageNo)
    local isEnough = AthenaData.isGoodEnough(p_skillId,p_pageNo)
    local isFullLv = AthenaData.isFullLv(p_skillId,p_pageNo)

    local arrowSprite = tolua.cast(p_menuItem:getChildByTag(kArrowTag),"CCSprite")
    arrowSprite:setVisible(isSkillOpen and (not isFullLv) and isEnough)
end

--[[
    @des    :刷新图片
    @param  :要刷新的按钮
    @param  :技能id
    @param  :当前页面
--]]
function refreshImgSprite(p_menuItem,p_skillId,p_pageNo)
    --如果开启了
    local isSkillOpen = AthenaData.isSkillOpen(p_skillId,p_pageNo)
    local graySprite = tolua.cast(p_menuItem:getChildByTag(kGrayTag),"BTGraySprite")
    graySprite:setVisible(not isSkillOpen)
    local normalSprite = tolua.cast(p_menuItem:getChildByTag(kImgTag),"CCSprite")
    normalSprite:setVisible(isSkillOpen)
    local grayBgSprite = tolua.cast(p_menuItem:getChildByTag(kGBgTag),"BTGraySprite")
    grayBgSprite:setVisible(not isSkillOpen)
    local normalBgSprite = tolua.cast(p_menuItem:getChildByTag(kNBgTag),"CCSprite")
    normalBgSprite:setVisible(isSkillOpen)
end

--[[
    @des    :得到特殊技能按钮
    @param  :技能id
    @param  :创建好的按钮
--]]
function getSpecialSkillMenuItem(p_pageNo)
    local skillInfo = {}
    local imgPathString = nil
    local bgPath = "images/base/potential/props_5.png"
    local skillType = AthenaData.getSkillType(p_pageNo)
    if(skillType == AthenaData.kNormaoSkillType or skillType == AthenaData.kAngrySkillType)then
        --为技能
        local mapInfo = AthenaData.getTreeDBInfo(p_pageNo)
        local SSId = AthenaData.getSSkillId(mapInfo)[1]
        skillInfo = AthenaData.getSSDBInfo(SSId)
        local pngString = (skillInfo.roleSkillPic == nil) and "simayi.png" or skillInfo.roleSkillPic
        imgPathString = "images/replaceskill/skillicon/" .. pngString
    else
        --为觉醒
        skillInfo = AthenaData.getTreeDBInfo(p_pageNo)
        local id = skillInfo.awake_ability
        local awakeInfo = DB_Awake_ability.getDataById(id)
        local pnaString = awakeInfo.icon or "yazhi.png"
        imgPathString = "images/athena/awake_icon/"..pnaString

    end

    --背景图
    local bgSprite = CCSprite:create(bgPath)
    local bgSize = bgSprite:getContentSize()

    local skillMenuItem = CCMenuItemSprite:create(bgSprite,bgSprite)


    --如果开启了
    local isSkillOpen = AthenaData.isSSOpen(p_pageNo)
    --灰色底
    local grayBgSprite = BTGraySprite:create(bgPath)
    grayBgSprite:setAnchorPoint(ccp(0.5,0.5))
    grayBgSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.5))
    grayBgSprite:setVisible(not isSkillOpen)
    skillMenuItem:addChild(grayBgSprite,1,kGBgTag)

    --普通底
    local normalBgSprite = CCSprite:create(bgPath)
    normalBgSprite:setAnchorPoint(ccp(0.5,0.5))
    normalBgSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.5))
    normalBgSprite:setVisible(isSkillOpen)
    skillMenuItem:addChild(normalBgSprite,1,kNBgTag)

    --灰色图标
    local imgSprite = BTGraySprite:create(imgPathString)
    imgSprite:setAnchorPoint(ccp(0.5,0.5))
    imgSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.5))
    imgSprite:setVisible(not isSkillOpen)
    skillMenuItem:addChild(imgSprite,2,kGrayTag)
    --普通图标
    local normalSprite = CCSprite:create(imgPathString)
    normalSprite:setAnchorPoint(ccp(0.5,0.5))
    normalSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.5))
    normalSprite:setVisible(isSkillOpen)
    skillMenuItem:addChild(normalSprite,2,kImgTag)

    return skillMenuItem
end

--[[
    @des    :得到特殊技能按钮(不变灰)
    @param  :技能id
    @param  :创建好的按钮
--]]
function getSkillMenuItem(p_skillId, p_pageNo)
    local skillInfo = AthenaData.getSSDBInfo(p_skillId)

    local bgPath = "images/base/potential/props_5.png"

    --背景图
    local bgSprite = CCSprite:create(bgPath)
    local bgSize = bgSprite:getContentSize()

    local skillMenuItem = CCMenuItemSprite:create(bgSprite,bgSprite)

    local pngString = (skillInfo.roleSkillPic == nil) and "simayi.png" or skillInfo.roleSkillPic

    local imgPathString = "images/replaceskill/skillicon/" .. pngString

    --普通底
    local normalBgSprite = CCSprite:create(bgPath)
    normalBgSprite:setAnchorPoint(ccp(0.5,0.5))
    normalBgSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.5))
    skillMenuItem:addChild(normalBgSprite)

    --普通图标
    local normalSprite = CCSprite:create(imgPathString)
    normalSprite:setAnchorPoint(ccp(0.5,0.5))
    normalSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.5))
    skillMenuItem:addChild(normalSprite)

    return skillMenuItem
end

--[[
    @des    :刷新特殊技能图标
    @param  :所在页数
--]]
function refreshSSMenuItem(p_menuItem,p_pageNo)
    local isSkillOpen = AthenaData.isSSOpen(p_pageNo)
    local graySprite = tolua.cast(p_menuItem:getChildByTag(kGrayTag),"BTGraySprite")
    graySprite:setVisible(not isSkillOpen)
    local normalSprite = tolua.cast(p_menuItem:getChildByTag(kImgTag),"CCSprite")
    normalSprite:setVisible(isSkillOpen)
    local grayBgSprite = tolua.cast(p_menuItem:getChildByTag(kGBgTag),"BTGraySprite")
    grayBgSprite:setVisible(not isSkillOpen)
    local normalBgSprite = tolua.cast(p_menuItem:getChildByTag(kNBgTag),"CCSprite")
    normalBgSprite:setVisible(isSkillOpen)
end

--[[
    @des    :得到特殊技能图
    @param  :技能id
    @param  :创建好的sprite
--]]
function getSpecialSkillSprite(p_pageNo)
    local skillInfo = {}
    local imgPathString = nil
    --背景图
    local bgSprite = CCSprite:create("images/base/potential/props_5.png")
    local bgSize = bgSprite:getContentSize()
    print(p_pageNo)
    local skillType = AthenaData.getSkillType(p_pageNo)
    if(skillType == AthenaData.kNormaoSkillType or skillType == AthenaData.kAngrySkillType)then
        --为技能
        local mapInfo = AthenaData.getTreeDBInfo(p_pageNo)
        local SSId = AthenaData.getSSkillId(mapInfo)[1]
        skillInfo = AthenaData.getSSDBInfo(SSId)
        local pngString = (skillInfo.roleSkillPic == nil) and "simayi.png" or skillInfo.roleSkillPic
        imgPathString = "images/replaceskill/skillicon/" .. pngString
    else
        --为觉醒
        skillInfo = AthenaData.getTreeDBInfo(p_pageNo)
        local id = skillInfo.awake_ability
        local awakeInfo = DB_Awake_ability.getDataById(id)
        local pnaString = awakeInfo.icon or "yazhi.png"
        imgPathString = "images/athena/awake_icon/"..pnaString

    end
    --普通图标
    local normalSprite = CCSprite:create(imgPathString)
    normalSprite:setAnchorPoint(ccp(0.5,0.5))
    normalSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.5))
    bgSprite:addChild(normalSprite)

    return bgSprite
end

--[[
    @des    :向背景添加属性信息
    @param  :背景图
    @param  :标题
    @param  :起始位置
    @param  :当前级别
    @param  :物品id
--]]
function addAtrrInfoToBg(p_bgSprite,p_titleString,p_posY,p_curLv,p_itemId)
    local atrrTitleLabel = CCLabelTTF:create(p_titleString,g_sFontName,21)
    atrrTitleLabel:setColor(ccc3(0xff,0xff,0xff))
    atrrTitleLabel:setAnchorPoint(ccp(0,1))
    atrrTitleLabel:setPosition(ccp(190,p_posY))
    p_bgSprite:addChild(atrrTitleLabel)
    local gapLineSprite = CCScale9Sprite:create("images/common/line02.png")
    gapLineSprite:setContentSize(CCSizeMake(225,5))
    gapLineSprite:setAnchorPoint(ccp(0,0.5))
    gapLineSprite:setPosition(180,p_posY - 25)
    p_bgSprite:addChild(gapLineSprite)
    local curAtrrInfo = AthenaData.getAtrrInfo(p_itemId,p_curLv)
    for j = 1,#curAtrrInfo do
        local curData = curAtrrInfo[j]
        local atrrNameLabel = CCLabelTTF:create(curData.name .. "：",g_sFontName,21)
        atrrNameLabel:setColor(ccc3(0xff,0xf6,0x00))
        local plusLabel = CCLabelTTF:create("+" .. curData.showNum,g_sFontName,21)
        plusLabel:setColor(ccc3(0xff,0xff,0xff))
        local connectNode = BaseUI.createHorizontalNode({atrrNameLabel,plusLabel})
        connectNode:setAnchorPoint(ccp(0,1))
        connectNode:setPosition(ccp(230,p_posY - 40 - 30*(j - 1)))
        p_bgSprite:addChild(connectNode)
    end
end

--[[
    @des    :给sprite加效果
    @param  :sprite
--]]
function addActionToSprite(p_sprite)
    --动画
    local arrActions = CCArray:create()
    arrActions:addObject(CCFadeOut:create(1))
    arrActions:addObject(CCFadeIn:create(1))
    local sequence = CCSequence:create(arrActions)
    local action = CCRepeatForever:create(sequence)
    p_sprite:runAction(action)
end



