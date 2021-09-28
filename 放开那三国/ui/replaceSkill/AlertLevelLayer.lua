-- Filename: AlertLevelLayer.lua
-- Author: DJN
-- Date: 2014-08-22
-- Purpose: 主角升级了某种技能后的弹窗

module("AlertLevelLayer", package.seeall)
require "script/audio/AudioUtil"
require "script/ui/replaceSkill/ReplaceSkillData"
require "script/ui/replaceSkill/ReplaceSkillLayer"
require "db/DB_Heroes"
require "db/skill"
require "script/utils/BaseUI"

local _touchPriority    --触摸优先级
local _ZOrder           --Z轴
local _bgLayer          --触摸屏蔽层
local _starId           --展示的技能所属武将

----------------------------------------初始化函数----------------------------------------
local function init()
    _touchPriority = nil
    _ZOrder = nil
    _bgLayer = nil
    _starId = nil
end

----------------------------------------触摸事件函数----------------------------------------
local function onTouchesHandler(eventType,x,y)
    if (eventType == "began") then
        return true
    elseif (eventType == "moved") then
        print("moved")
    else
        print("end")
    end
end

local function onNodeEvent(event)
    if event == "enter" then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
        _bgLayer:setTouchEnabled(true)
    elseif event == "exit" then
        _bgLayer:unregisterScriptTouchHandler()
    end
end

----------------------------------------UI函数----------------------------------------
--[[
    @des    :创建背景UI
    @param  :
    @return :
--]]
function createBgUI()
    require "script/ui/main/MainScene"
    local bgSize = CCSizeMake(460,430)
    local bgScale = MainScene.elementScale

    --主背景图
    local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
    bgSprite:setContentSize(CCSizeMake(bgSize.width,bgSize.height))
    bgSprite:setAnchorPoint(ccp(0.5,0.5))
    bgSprite:setPosition(ccp(_bgLayer:getContentSize().width/2,_bgLayer:getContentSize().height/2))
    bgSprite:setScale(bgScale)
    _bgLayer:addChild(bgSprite)

    --标题背景
    local titleSprite = CCSprite:create("images/common/viewtitle1.png")
    titleSprite:setAnchorPoint(ccp(0.5,0.5))
    titleSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 6))
    bgSprite:addChild(titleSprite)
    
    local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3158"), g_sFontPangWa, 30)
    titleLabel:setColor(ccc3(0xff,0xe4,0x00))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(ccp(titleSprite:getContentSize().width/2,titleSprite:getContentSize().height/2))
    titleSprite:addChild(titleLabel)

    --二级背景
    local brownSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    brownSprite:setContentSize(CCSizeMake(394,258))
    brownSprite:setAnchorPoint(ccp(0.5,0.5))
    brownSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height/2+20))
    bgSprite:addChild(brownSprite)

    --背景按钮层
    local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority-1)
    bgSprite:addChild(bgMenu)

    --关闭按钮
    local closeMenuItem = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png","images/common/btn_close_h.png")
    closeMenuItem:setPosition(ccp(bgSprite:getContentSize().width*1.03,bgSprite:getContentSize().height*1.03))
    closeMenuItem:setAnchorPoint(ccp(1,1))
    closeMenuItem:registerScriptTapHandler(closeCallBack)
    bgMenu:addChild(closeMenuItem)
    
    --前往装备的按钮
    local skillBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(222, 73),GetLocalizeStringBy("djn_32"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    skillBtn:setPosition(bgSprite:getContentSize().width*0.5, 29)
    skillBtn:setAnchorPoint(ccp(0.5, 0))
    skillBtn:registerScriptTapHandler(skillBtnCallback)
    bgMenu:addChild(skillBtn)

    --获取后端传来的数据
    local allInfo = ReplaceSkillData.getAllInfo().star_list
    print("输出后端获取的数据")
    print_t(allInfo)
    print("输出当前武将")
    print(_starId)
    print("定位的信息")
    _starId = tostring(_starId)
    print_t(allInfo[tostring(_starId)])
    --恭喜主公将*******那句话
    local strA = CCLabelTTF:create(GetLocalizeStringBy("djn_37"),g_sFontPangWa,21)
    strA:setColor(ccc3(0xff,0xff,0xff))

 
    local strB = CCRenderLabel:create(DB_Star.getDataById(allInfo[_starId].star_tid).name,g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
    strB:setColor(ccc3(0xe4,0x00,0xff))

    local strC = CCLabelTTF:create(GetLocalizeStringBy("djn_33"),g_sFontPangWa,21)
    strC:setColor(ccc3(0xff,0xff,0xff))
     print("allInfo[_starId].feel_skill")
     print(allInfo[_starId].feel_skill)
    local strD =  CCRenderLabel:create(skill.getDataById(allInfo[_starId].feel_skill).name ,g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
    strD:setColor(ccc3(0xe4,0x00,0xff))

    local lineNode = BaseUI.createHorizontalNode{strA,strB,strC,strD}
    lineNode:setAnchorPoint(ccp(0.5,0))
    lineNode:setPosition(ccp(brownSprite:getContentSize().width*0.5,211))
    brownSprite:addChild(lineNode)
    --提升至LV*  那句话
    local strE = CCLabelTTF:create(GetLocalizeStringBy("djn_35") ,g_sFontPangWa,21)
    strE:setColor(ccc3(0xff,0xff,0xff))
    local strF = CCLabelTTF:create(GetLocalizeStringBy("djn_31").. ReplaceSkillData.getSelectSkillInfo().skillLevel,g_sFontPangWa,21)
    strF:setColor(ccc3(0xfe, 0xdb, 0x1c))
    local lineNodeB = BaseUI.createHorizontalNode{strE,strF}
    lineNodeB:setAnchorPoint(ccp(0.5,1))
    lineNodeB:setPosition(ccp(brownSprite:getContentSize().width*0.5,187))
    brownSprite:addChild(lineNodeB)


    --当前技能的图标
    local iconSprite = ReplaceSkillLayer.createSkillIcon(allInfo[_starId].feel_skill)
    iconSprite:setAnchorPoint(ccp(0.5, 0))
    iconSprite:setPosition(ccp(brownSprite:getContentSize().width*0.5, 53))
    brownSprite:addChild(iconSprite)

    --技能名称
   
    local nameLabel = CCLabelTTF:create(skill.getDataById(allInfo[_starId].feel_skill).name ,g_sFontName,21)
    nameLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    nameLabel:setAnchorPoint(ccp(0.5,1))
    nameLabel:setPosition(ccp(iconSprite:getContentSize().width*0.5,-3))
    iconSprite:addChild(nameLabel)
    --等级
    local lvImage = CCSprite:create("images/common/lv.png")
    lvImage:setAnchorPoint(ccp(1,1))
    lvImage:setPosition(ccp(iconSprite:getContentSize().width*0.5+1,-25))
    iconSprite:addChild(lvImage)

    -- local skillList = ReplaceSkillData.getSkillInfoBySid(_starId)
    -- local skillInfo = ReplaceSkillData.getSkillById(skillList,allInfo[_starId].feel_skill)
    local skillInfo = ReplaceSkillData.getSelectSkillInfo()
    local levelLabel = CCLabelTTF:create(skillInfo.skillLevel,g_sFontName,21)
    levelLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    levelLabel:setAnchorPoint(ccp(0,1))
    levelLabel:setPosition(ccp(iconSprite:getContentSize().width*0.5+3,-25))
    iconSprite:addChild(levelLabel)


   
    
end



----------------------------------------回调函数----------------------------------------
--[[
    @des    :关闭回调
    @param  :
    @return :
--]]
function closeCallBack()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
end
--[[
    @des    :前往装备回调
    @param  :
    @return :
--]]
function skillBtnCallback()
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
    require "script/ui/fashion/FashionLayer"
    local mark = FashionLayer.getMark()
    local fashionLayer = FashionLayer:createFashion()
    MainScene.changeLayer(fashionLayer, "FashionLayer")     
    FashionLayer.setMark(mark)
end
----------------------------------------入口函数----------------------------------------
--第一个参数代表所学的技能属于的武将，不可缺省
function showLayer(starId,p_touchPriority,p_ZOrder)
    init()
    _touchPriority = p_touchPriority or -550
    _ZOrder = p_ZOrder or 999
    _starId = starId
    --绿色触摸屏蔽层
    _bgLayer = CCLayerColor:create(ccc4(0x00,0x00,0x00,155))
    _bgLayer:registerScriptHandler(onNodeEvent)
    local curScene = CCDirector:sharedDirector():getRunningScene()
    curScene:addChild(_bgLayer,_ZOrder) 
    --创建背景UI
    createBgUI()

   
end

