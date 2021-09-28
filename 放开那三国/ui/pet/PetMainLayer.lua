-- Filename：	PetMainLayer.lua
-- Author：		zhz
-- Date：		2014-3-31
-- Purpose：		宠物的主界面


module("PetMainLayer", package.seeall)


require "script/model/user/UserModel"
require "script/utils/BaseUI"
require "script/ui/main/BulletinLayer"
require "script/ui/main/MainScene"
require "script/ui/main/MenuLayer"
require "script/ui/pet/PetData"
require "script/ui/pet/PetUtil"
require "script/ui/item/ItemUtil"
require "script/ui/pet/FeedCell"
require "script/ui/pet/PetBagLayer"
require "script/ui/pet/PetService"
require "script/ui/tip/AnimationTip"
require "script/ui/tip/AlertTip"
require "script/ui/pet/PetSelFormatLayer"
require "script/utils/LevelUpUtil"
require "db/DB_Pet_skill"
require "script/ui/tip/LackGoldTip"
require "script/ui/shop/RechargeLayer"
require "script/guide/NewGuide"
require "script/guide/PetGuide"
require "script/ui/pet/PetController"

local _bgLayer					-- 宠物的主layer
local _petBackgound				-- 宠物的背景
local _layerSize
local _topBg                    -- 
local _petLayerStatus           -- 宠物layer 的3中状态 1, 主界面状态， 2:吞噬 ,3：喂养状态， 4：领悟技能
local _curPetId                 -- 当前宠物的id
local _curPetIndex
local _curPetSize
local _formationPetInfo         -- 上阵武将的信息
local _petSrc                   -- 上阵宠物的CCScrollView
local _starsBgSp                -- 宠物星级的等级
local _titleSprite              -- 标题
local _updateTimer              -- 定时器
local _bottomBg                 -- 底部的背景
local _lvLabel                  -- 
local _fightforceSp
local _fightSpite
local _fightNode                -- 显示宠物战斗力的节点

local  _posIndex                -- 宠物上阵的栏位 从0开始
local _ksTagSelectedPet         = 1000      -- 选择吞噬宠物按钮的起始tag

local _petPropertyBg             --宠物属性的背景

-----------------------------------宠物喂养----------------------------------
local _feedViewBg               -- 喂养的tableView背景
local _feedTableView            -- 喂养的tableView
local _gid
local _feedPetLevel             -- 
local _feedSp                   -- 显示宠物喂养的图片
local _levelUpDescSp            -- 显示宠物升级说明的图片
local _itemFeedInfo             -- 宠物饲料的信息

----------------------------------宠物吞噬 -------------------
local _swallowBg                -- 吞噬的背景
local _swallowedPetInfo         -- 被吞噬宠物的信息
local _addPetButton             -- 
local _swallowedPetSp
local _swallowedPetId           -- 可以被吞噬宠物的id
 
---------------------------------- 宠物领悟 -------------------
local _graspBg                  -- 领悟的背景
local _graspView                --
local _graspBtn                 -- 领悟的背景
local _resetBtn                 -- 重置的按钮
local _produceItem              -- 特殊技能的按钮
local _produceLabel             -- 特殊技能倒计时
local _learnSp
local _cellIndex
local _btnOneKeyReceive         -- 一键领取所有宠物技能产出 zhangqiang
---------------------------------- 宠物进阶 -------------------
local _advancedBtn = nil
local _evolveLvLabel = nil
---------------------------------- 宠物培养 -------------------
local _trainBtn = nil
---------------------------------- 资质互换 -------------------
local _aptitudeSwapBtn = nil
-------------------------------从背包切换到宠物-----------
local _petIdByOutSide           -- 从背包进入到宠物阵容页面的的宠物Id
local _nameLabel = nil
local _lvLabel = nil
--4个属性文本数组

local _evolveAddSkillLv = 0 -- 宠物进阶增加技能等级

local function init(  )
	_bgLayer 		     = nil
	_petBackgound	     = nil
	_layerSize		     = nil
    _topBg               = nil
    _petLayerStatus      = 1
    _curPetId            = nil 
    _curPetIndex         = 1
    _petSrc              = nil
    _formationPetInfo    = nil
    _curPetSize          = CCSizeMake(640, 504)
    _bottomBg            = nil
    _feedViewBg          = nil
    _feedTableView       = nil
    _itemFeedInfo        = nil
    _feedSp              = nil
    _fightforceSp        = nil
    _fightNode           = nil
    _fightSpite          = nil
    _lvLabel             = nil
    _feedPetLevel        = nil
    _starsBgSp           = nil
    _produceItem         = nil
    _learnSp             = nil
    _petIdByOutSide      = nil
    _cellIndex           = nil
    _swallowedPetSp      = nil
    _addPetButton        = nil
    _swallowedPetId      = nil
    _petPropertyBg       = nil
    _titleSprite         = nil
    _aptitudeSwapBtn     = nil
    _evolveLvLabel       = nil
    _nameLabel           = nil
    _evolveLvLabel       = nil
    _evolveAddSkillLv    = 0
end

function getCurPetId()
    local curPetId = nil

    if(not table.isEmpty(_formationPetInfo) and not table.isEmpty(_formationPetInfo[_curPetIndex]) and _formationPetInfo[_curPetIndex].petid ~= nil)then
        curPetId = tonumber(_formationPetInfo[_curPetIndex].petid)
    end
    return curPetId
end

   -- 上标题栏 显示战斗力，银币，金币
function createTopUI( )

    _topBg = CCSprite:create("images/hero/avatar_attr_bg.png")
    _topBg:setAnchorPoint(ccp(0,1))
    _topBg:setPosition(0,_bgLayer:getContentSize().height)
    _topBg:setScale(g_fScaleX)
    _bgLayer:addChild(_topBg, 10)
    titleSize = _topBg:getContentSize()

    local powerDescLabel = CCSprite:create("images/common/fight_value.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(_topBg:getContentSize().width*0.13,_topBg:getContentSize().height*0.43)
    _topBg:addChild(powerDescLabel)
    print("getFightForceValue")
    print_t(UserModel.getFightForceValue())
    _powerLabel = CCRenderLabel:create( UserModel.getFightForceValue(), g_sFontName, 23, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _powerLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    _powerLabel:setPosition(_topBg:getContentSize().width*0.23,_topBg:getContentSize().height*0.66)
    _topBg:addChild(_powerLabel)
    
    -- modified by yangrui at 2015-12-03
    _silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(UserModel.getSilverNumber()),g_sFontName,18)
    _silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
    _silverLabel:setAnchorPoint(ccp(0,0.5))
    _silverLabel:setPosition(_topBg:getContentSize().width*0.61,_topBg:getContentSize().height*0.43)
    _topBg:addChild(_silverLabel)
    
    _goldLabel = CCLabelTTF:create(UserModel.getGoldNumber()  ,g_sFontName,18)
    _goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    _goldLabel:setAnchorPoint(ccp(0,0.5))
    _goldLabel:setPosition(_topBg:getContentSize().width*0.82,_topBg:getContentSize().height*0.43)
    _topBg:addChild(_goldLabel)
end

-- 刷新顶部的UI
function refreshTopUI( )
    -- modified by yangrui at 2015-12-03
    _silverLabel:setString(string.convertSilverUtilByInternational(UserModel.getSilverNumber()))
    _goldLabel:setString( UserModel.getGoldNumber())

end
-- 
function createBagMenuUI(  )
    
    local menuBar= CCMenu:create()
    menuBar:setPosition(0,0)
    _bgLayer:addChild(menuBar,111)

    local height= _layerSize.height - _topBg:getContentSize().height*g_fScaleX-9 
    local width = _layerSize.width- 5
    _bagItem = CCMenuItemImage:create("images/pet/pet/btn_bag_n.png", "images/pet/pet/btn_bag_h.png")
    _bagItem:setAnchorPoint(ccp(1,1))
    _bagItem:setPosition(width, height)
    _bagItem:registerScriptTapHandler(bagAction)
    _bagItem:setScale(MainScene.elementScale )
    menuBar:addChild(_bagItem,111)

    if PetData.isShowTip() then
        local alertSprite = CCSprite:create("images/common/tip_2.png")
        alertSprite:setAnchorPoint(ccp(0.5,0.5))
        alertSprite:setPosition(ccp(_bagItem:getContentSize().width*0.8,_bagItem:getContentSize().height*0.8))
        _bagItem:addChild(alertSprite,1,1998)
    end

    width = width- _bagItem:getContentSize().width*MainScene.elementScale- 8
    --_descItem= CCMenuItemImage:create("images/recycle/btn/btn_explanation_h.png", "images/recycle/btn/btn_explanation_n.png")
    _descItem= CCMenuItemImage:create("images/pet/handbook/handbook_btn_n.png", "images/pet/handbook/handbook_btn_h.png")
    _descItem:setPosition(width ,height+5)
    _descItem:setAnchorPoint(ccp(1,1))
    _descItem:setScale(MainScene.elementScale*0.99)
    _descItem:registerScriptTapHandler(descAction)
    menuBar:addChild(_descItem,112)
end


-- 创建底部部分的UI
function createBotom( )
    
    _formationNumBg= CCScale9Sprite:create("images/copy/ecopy/lefttimesbg.png")
    _formationNumBg:setContentSize(CCSizeMake( 200,34))
    _formationNumBg:setPosition(10*MainScene.elementScale , 208*g_fScaleX)
    _formationNumBg:setAnchorPoint(ccp(0,0))
    _formationNumBg:setScale(MainScene.elementScale )
    _bgLayer:addChild(_formationNumBg)

    -- 当前上阵
    local formationLabel= CCLabelTTF:create(GetLocalizeStringBy("key_1961"), g_sFontName, 24)-- 0, ccc3( 0x00, 0x00, 0x00), type_stroke)
    formationLabel:setColor(ccc3(0xff,0xff,0xff))
    _formationNumLabel= CCLabelTTF:create("" .. PetData.getFormationNum() .. "/" .. PetData.getMaxForamtionNum() , g_sFontName,24)
    _formationNumLabel:setColor(ccc3(0x00 ,0xff,0x18))

    local formationNode= BaseUI.createHorizontalNode({formationLabel, _formationNumLabel})
    formationNode:setPosition(_formationNumBg:getContentSize().width/2,  _formationNumBg:getContentSize().height/2)
    formationNode:setAnchorPoint(ccp(0.5,0.5))
    _formationNumBg:addChild(formationNode)

    createPropertyUI()
end

function createButtonButtons( ... )
    -- body
    -- 创建menu 
    local menuBar= CCMenu:create()
    menuBar:setPosition(0,0)
    _bgLayer:addChild(menuBar)
    local posY = 10 * g_fElementScaleRatio
    _swallowItem= LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150,73),GetLocalizeStringBy("key_2786"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _swallowItem:setAnchorPoint(ccp(0,0))
    _swallowItem:setPosition(_layerSize.width* 0.01, posY)--_layerSize.height*0.078)
    _swallowItem:setScale(MainScene.elementScale * 0.8)
    _swallowItem:registerScriptTapHandler(swallowAction)
    menuBar:addChild(_swallowItem,1)

    _feedItem= LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150,73),GetLocalizeStringBy("key_1488"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _feedItem:setAnchorPoint(ccp(0,0))
    _feedItem:setPosition(_layerSize.width*0.21,posY)-- _layerSize.height*0.078)
    _feedItem:setScale(MainScene.elementScale * 0.8)
    _feedItem:registerScriptTapHandler(feedAction)
    menuBar:addChild(_feedItem,1)

    _realizeItem= LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150,73),GetLocalizeStringBy("key_1084"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _realizeItem:setAnchorPoint(ccp(0,0))
    _realizeItem:setPosition(_layerSize.width*0.41,posY )-- _layerSize.height*0.078)
    _realizeItem:registerScriptTapHandler(realizeAction)
    _realizeItem:setScale(MainScene.elementScale * 0.8)
    menuBar:addChild(_realizeItem,1)

    _advancedBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150,73),GetLocalizeStringBy("key_1730"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _advancedBtn:setAnchorPoint(ccp(0,0))
    _advancedBtn:setPosition(_layerSize.width*0.61,posY )-- _layerSize.height*0.078)
    _advancedBtn:registerScriptTapHandler(advancedHandler)
    _advancedBtn:setScale(MainScene.elementScale * 0.8)
    menuBar:addChild(_advancedBtn)

    _trainBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150,73),GetLocalizeStringBy("syx_1076"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _trainBtn:setAnchorPoint(ccp(0,0))
    _trainBtn:setPosition(_layerSize.width*0.81,posY )-- _layerSize.height*0.078)
    _trainBtn:registerScriptTapHandler(trainHandler)
    _trainBtn:setScale(MainScene.elementScale * 0.8)
    menuBar:addChild(_trainBtn)
end


-- 设置让按钮位置可变
function setBottomUIVisible( visible)
    _formationNumBg:setVisible(visible)
    _swallowItem:setVisible(visible)
    _feedItem:setVisible(visible)
    _realizeItem:setVisible(visible)
    _trainBtn:setVisible(visible)
    _advancedBtn:setVisible(visible)
end

-- 创建宠物的属性UI
function createPropertyUI( )
    if(_petPropertyBg~= nil) then
        _petPropertyBg:removeFromParentAndCleanup(true)
        _petPropertyBg= nil
    end

    if(_formationPetInfo[_curPetIndex].petid== nil or tonumber(_formationPetInfo[_curPetIndex].petid)==0 or _petLayerStatus~=1) then
        return
    end

    _petPropertyBg= CCScale9Sprite:create("images/common/bg/9s_1.png")
    _petPropertyBg:setContentSize(CCSizeMake(638,127))
    _petPropertyBg:setScale(g_fScaleX)
    _petPropertyBg:setPosition(_bgLayer:getContentSize().width/2, 78*MainScene.elementScale)
    _petPropertyBg:setAnchorPoint(ccp(0.5,0))
    _bgLayer:addChild(_petPropertyBg,11)

    --宠物属性框
    -- 创建sprite
    local destinyLabelBg= CCScale9Sprite:create("images/common/astro_labelbg.png")
    destinyLabelBg:setContentSize(CCSizeMake(183,40))
    destinyLabelBg:setAnchorPoint(ccp(0.5,0.5))
    destinyLabelBg:setPosition(_petPropertyBg:getContentSize().width/2, _petPropertyBg:getContentSize().height)
    _petPropertyBg:addChild(destinyLabelBg)

    local destinyLabel= CCRenderLabel:create(GetLocalizeStringBy("key_1420"), g_sFontPangWa, 24,1, ccc3(0x00,0x00,0x00),type_stroke )
    destinyLabel:setColor(ccc3(0xff,0xf6,0x00))
    destinyLabel:setPosition(destinyLabelBg:getContentSize().width/2, destinyLabelBg:getContentSize().height/2)
    destinyLabel:setAnchorPoint(ccp(0.5,0.5))
    destinyLabelBg:addChild(destinyLabel)

    local skillPropertyDesc= CCRenderLabel:create(GetLocalizeStringBy("key_2120"), g_sFontName,23,1, ccc3(0x00,0x00,0x00),type_stroke)
    skillPropertyDesc:setAnchorPoint(ccp(0.5,0))
    skillPropertyDesc:setColor(ccc3(0x00,0xff,0x18))
    skillPropertyDesc:setPosition(_petPropertyBg:getContentSize().width/2 - 60,5)
    _petPropertyBg:addChild(skillPropertyDesc)

  

    -- local skillNormal = _formationPetInfo[_curPetIndex].va_pet.skillNormal 
    local skillProperty= PetData.getPetValueById( tonumber(_formationPetInfo[_curPetIndex].petid))
    -- print("===========================skillProperty skillProperty skillProperty skillProperty ")
    -- print_t(skillProperty)
    -- 获取进阶和培养的属性
    -- local evolveAttrMap = PetData.getPetTrainAttrTotalValue(_formationPetInfo[_curPetIndex])
    local x_start= 96
    local x= x_start
    local y= 79
    local xOffset= 197
    -- print("skillProperty")
    -- print_t(skillProperty)
    -- print("evolveAttrMap")
    -- print_t(evolveAttrMap)
    local index = 0
    -- 技能属性和培养属性的对应关系
    local affixKeyMap = {[1] = "51",[4] = "54",[5] = "55",[9] = "100"}
    local descLabelMap = {}
    for i=1, table.count(skillProperty) do
        local descLabel= CCLabelTTF:create( skillProperty[i].affixDesc.displayName .. ":  " ,g_sFontName,23 )
        descLabel:setColor(ccc3(0xff,0xff,0xff))
        local descNumLabel= CCLabelTTF:create(skillProperty[i].displayNum,g_sFontName,23 )
        -- descNumLabel:setColor(ccc3(0x00,0xff,0x18))
        -- print(12345,tostring(skillProperty[i].affixDesc.id))
        -- print_t(evolveAttrMap)
        -- local evolveAttrLabel = CCLabelTTF:create("+"..100,g_sFontName,23 )
        -- evolveAttrLabel:setColor(ccc3(0x00,0xff,0x18))
        
        descLabelMap[affixKeyMap[skillProperty[i].affixDesc.id]] = descNumLabel
        local descNode= BaseUI.createHorizontalNode({ descLabel, descNumLabel})

        if(i==3) then
            x = x_start
            y = 40
        end
        descNode:setPosition(x,y)
        x = x + xOffset
        _petPropertyBg:addChild(descNode)
        index = i
    end  

    local petEvolveData = PetData.getPetTrainAttrTotalValue(_formationPetInfo[_curPetIndex])
    local petEvolveLabelAry = {}
    for k,evolveData in pairs(petEvolveData) do
        if evolveData.displayNum ~= 0 then
            local label = descLabelMap[k]
            if label then
                local evolveAttrLabel = CCLabelTTF:create("+"..evolveData.displayNum,g_sFontName,23 )
                evolveAttrLabel:setColor(ccc3(0x00,0xff,0x18))
                evolveAttrLabel:setAnchorPoint(ccp(0,0.5))
                evolveAttrLabel:setPosition(ccpsprite(1,0.5,label))
                label:addChild(evolveAttrLabel)
            else
                index = index + 1
                local descLabel= CCLabelTTF:create( evolveData.affixDesc.sigleName .. ":  " ,g_sFontName,23 )
                descLabel:setColor(ccc3(0xff,0xff,0xff))
                local evolveAttrLabel = CCLabelTTF:create(evolveData.displayNum,g_sFontName,23 )
                evolveAttrLabel:setColor(ccc3(0x00,0xff,0x18))
                evolveAttrLabel:setAnchorPoint(ccp(0,0.5))
                evolveAttrLabel:setPosition(ccpsprite(1,0.5,descLabel))
                descLabel:addChild(evolveAttrLabel)
                _petPropertyBg:addChild(descLabel)
                if index == 3 then
                    x = x_start
                    y = 40
                end
                descLabel:setPosition(ccp(x,y))
                x = x + xOffset
            end
        end
    end
    local attrCallBack = function()
        if table.isEmpty(skillProperty) and table.isEmpty(petEvolveData) then
            AnimationTip.showTip(GetLocalizeStringBy("zzh_1291"))
            return
        end
        require "script/ui/common/DetailAttrLayer"
        DetailAttrLayer.showLayer(DetailAttrLayer.kPetTag,nil,nil,nil,skillProperty,nil,petEvolveData)
    end

    local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    _petPropertyBg:addChild(bgMenu)

    local attrMenuItem = CCMenuItemImage:create("images/god_weapon/detail_n.png","images/god_weapon/detail_h.png")
    attrMenuItem:setAnchorPoint(ccp(0.5,0.5))
    attrMenuItem:setPosition(ccp(x_start + 2*xOffset + 60,_petPropertyBg:getContentSize().height*0.5))
    attrMenuItem:registerScriptTapHandler(attrCallBack)
    bgMenu:addChild(attrMenuItem)

end



-- 自动回复刷新
function autoAddPetExpRefresh()
    --刷新上阵宠物信息
    resetFormationPetInfo()
    --刷新特殊技能按钮，星值背景UI，场景UI
    refreshMiddleUI()
end


function createFightNode( )

    if(_fightSpite~= nil) then
        _fightSpite:removeFromParentAndCleanup(true)
        _fightSpite = nil
        _fightforceSp:removeFromParentAndCleanup(true)
        _fightforceSp= nil
    end

    _fightSpite= CCSprite:create("images/pet/pet/fight_sp.png")
    local  petid= tonumber( _formationPetInfo[_curPetIndex].petid)
    _fightforceSp=  LuaCC.createSpriteOfNumbers("images/pet/number", PetData.getPetFightForceById(petid),24 )

    _fightSpite:setPosition(_layerSize.width*0.367, _petSrc:getPositionY()+50*MainScene.elementScale)
    _bgLayer:addChild(_fightSpite,111)
    _fightSpite:setScale(MainScene.elementScale )

    _fightforceSp:setPosition(_layerSize.width*0.367+ _fightSpite:getContentSize().width*MainScene.elementScale, _petSrc:getPositionY()+52*MainScene.elementScale)
    _bgLayer:addChild(_fightforceSp,111)
    _fightforceSp:setAnchorPoint(ccp(0,0))
    _fightforceSp:setScale(MainScene.elementScale)

    -- _fightSpite= BaseUI.createHorizontalNode({ _fightSpite,_fightforceSp})
    -- _fightNode:setAnchorPoint(ccp(0.5,1))
    -- _fightNode:setPosition(_layerSize.width/2,_petSrc:getPositionY()+50*MainScene.elementScale )
    -- _fightNode:setScale(MainScene.elementScale)
    -- _bgLayer:addChild(_fightNode)

end

-- 创建宠物的特殊技能产生的icon
function createSpecialIcon( )
    if(_produceItem~= nil) then
        _produceItem:removeFromParentAndCleanup(true)
        _produceItem= nil

        _btnOneKeyReceive:removeFromParentAndCleanup(true)
        _btnOneKeyReceive = nil
    end

    local menu= CCMenu:create()
    menu:setPosition(ccp(0,0))
    _bgLayer:addChild(menu ,19)

    local height= _layerSize.height- _topBg:getContentSize().height*_topBg:getScale()

    -- print("_formationPetInfo ",_formationPetInfo[_curPetIndex].showStatus ,tonumber( _formationPetInfo[_curPetIndex].va_pet.skillProduct[1].id))
    if(_formationPetInfo[_curPetIndex].showStatus==1 and tonumber( _formationPetInfo[_curPetIndex].va_pet.skillProduct[1].id)>0 ) then

        local skillId= tonumber(_formationPetInfo[_curPetIndex].va_pet.skillProduct[1].id)
        local skillLevel= PetData.getPetSkillLevel( _formationPetInfo[_curPetIndex].petid )
        
        local skillData= DB_Pet_skill.getDataById(skillId)
        _produceItem=  CCMenuItemImage:create( "images/pet/pet/reward_border.png","images/pet/pet/reward_border.png")
        _produceItem:setAnchorPoint(ccp(0,1))
        -- _produceItem:setEnabled(false)
        _produceItem:setScale(MainScene.elementScale)
        _produceItem:setPosition(10*MainScene.elementScale, height)
        _produceItem:registerScriptTapHandler(produceAction)
        menu:addChild(_produceItem)

        local item = PetUtil.getProduceIcon( skillId,skillLevel )
        item:setPosition(_produceItem:getContentSize().width/2,_produceItem:getContentSize().height/2)
        item:setAnchorPoint(ccp(0.5,0.5))
        _produceItem:addChild(item)

        -- 
        local nameLabel= CCLabelTTF:create(skillData.name, g_sFontPangWa,18 )
        nameLabel:setColor(ccc3(0xff,0xf6,0x00))
        nameLabel:setAnchorPoint(ccp(0.5,1))
        nameLabel:setPosition( _produceItem:getContentSize().width/2 ,-1*MainScene.elementScale)
        _produceItem:addChild(nameLabel)

        

        _produceLabel= CCLabelTTF:create("00:00:00", g_sFontPangWa,18)
        _produceLabel:setColor(ccc3(0xff,0xff,0xff))
        _produceLabel:setAnchorPoint(ccp(0.5,1))
        _produceLabel:setPosition(_produceItem:getContentSize().width/2,-(1+nameLabel:getContentSize().height)  )
        _produceItem:addChild(_produceLabel)

        _receiveSp= CCSprite:create("images/pet/pet/received_sp.png")
        _receiveSp:setPosition(_produceItem:getContentSize().width/2,_produceItem:getContentSize().height/2)
        _receiveSp:setAnchorPoint(ccp(0.5,0.5))
        _receiveSp:setVisible(false)
        _produceItem:addChild(_receiveSp)

        --一键领取所有宠物产出按钮
        -- _btnOneKeyReceive = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png", "images/common/btn/btn_purple2_h.png", CCSizeMake(150, 73), GetLocalizeStringBy("zq_0015"), ccc3(254,219,28), 23, g_sFontPangWa, 2, ccc3(0,0,0))        
        local tSprite = {normal="images/common/btn/btn_purple2_n.png",selected="images/common/btn/btn_purple2_h.png",disabled="images/tower/graybg.png"}
        local tLabel = {text=GetLocalizeStringBy("zq_0015"),fontsize=23,color=ccc3(254,219,28),dColor=ccc3(253,253,253)}
        _btnOneKeyReceive = LuaCCMenuItem.createMenuItemOfRenderLabelOnSprite(tSprite,tLabel)
        _btnOneKeyReceive:setScale(0.8*MainScene.elementScale)
        _btnOneKeyReceive:setAnchorPoint(ccp(0.5,0.5))
        _btnOneKeyReceive:setPosition(_produceItem:getPositionX() + _produceItem:getContentSize().width*0.5*MainScene.elementScale, _produceItem:getPositionY()-180*MainScene.elementScale)
        menu:addChild(_btnOneKeyReceive)
        _btnOneKeyReceive:registerScriptTapHandler(tapOneKeyReceive)
        _btnOneKeyReceive:setEnabled(false)

    end
    
end

-- 领取完奖励之后的回调函数
function rfcAftProduce( )
    refreshTopUI()
    refreshOneKeyReceiveBtn()    --刷新一键领取所有宠物产出按钮状态

    resetFormationPetInfo()
end
-- 创建中部的UI
function createMiddleUI( )
    --宠物描述UI
    createPetSrc()
    --特殊技能UI
    createSpecialIcon( )
    --吞噬，喂养，领悟技能按钮
    createBotom()
    --资质互换按钮
    createSwapBtn()
    _titleSprite = CCSprite:create("images/pet/pet/swallow_sp.png")
    _titleSprite:setAnchorPoint(ccp(0.5, 1))
    _titleSprite:setScale(MainScene.elementScale)
    _titleSprite:setPosition(ccp(_layerSize.width/2, _topBg:getPositionY()-_topBg:getContentSize().height*g_fScaleX-4*MainScene.elementScale ))
    _titleSprite:setVisible(false)
    _bgLayer:addChild(_titleSprite, 15)

    --星值背景
    -- _starsBgSp = CCSprite:create("images/formation/stars_bg.png")
    -- _starsBgSp:setAnchorPoint(ccp(0.5, 1))
    -- _starsBgSp:setScale(MainScene.elementScale)
    -- _starsBgSp:setPosition(ccp(_layerSize.width/2, _topBg:getPositionY()-_topBg:getContentSize().height*g_fScaleX-4*MainScene.elementScale ))
    -- _bgLayer:addChild(_starsBgSp, 15)

    --宠物脚下法阵光特效
    createPetBotttom()

    -- starsXPositions = {0.5, 0.4, 0.6, 0.3, 0.7, 0.2, 0.8}
    -- starsYPositions = {0.75, 0.74, 0.74, 0.71, 0.71, 0.68, 0.68}

    --星星
    -- starArr_h={}
    -- for starIndex, xScale in pairs(starsXPositions) do
    --     local starSp = CCSprite:create("images/formation/star.png")
    --     starSp:setAnchorPoint(ccp(0.5, 0.5))
    --     starSp:setPosition(ccp(_starsBgSp:getContentSize().width * xScale, _starsBgSp:getContentSize().height * starsYPositions[starIndex]))
    --     _starsBgSp:addChild(starSp)
    --     table.insert(starArr_h, starSp)
    -- end

    local height= _layerSize.height- _topBg:getContentSize().height*_topBg:getScale()
    _feedSp = CCSprite:create("images/pet/pet/feedsp.png")
    _feedSp:setPosition(10,height)
    _feedSp:setScale(MainScene.elementScale)
    _feedSp:setAnchorPoint(ccp(0,1))
    _feedSp:setVisible(false)
    _bgLayer:addChild(_feedSp)

    _learnSp= CCSprite:create("images/pet/pet/learn_sp.png")
    _learnSp:setPosition(10,height)
    _learnSp:setScale(MainScene.elementScale)
    _learnSp:setAnchorPoint(ccp(0,1))
    _learnSp:setVisible(false)
    _bgLayer:addChild(_learnSp)

    _swallowSp= CCSprite:create("images/pet/pet/swallow_sp.png")
    _swallowSp:setPosition(10,height)
    _swallowSp:setScale(MainScene.elementScale)
    _swallowSp:setAnchorPoint(ccp(0,1))
    _swallowSp:setVisible(false)
    _bgLayer:addChild(_swallowSp)

    --出战按钮
    local upBtnPos = ccp(_layerSize.width/2, _titleSprite:getPositionY() -(15+ _titleSprite:getContentSize().height)*MainScene.elementScale)
    local menuBar= CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    _bgLayer:addChild(menuBar,20)
    _upBtn= CCMenuItemImage:create("images/pet/pet/up/btn_up_n.png", "images/pet/pet/up/btn_up_h.png")
    _upBtn:setPosition(upBtnPos)
    _upBtn:setAnchorPoint(ccp(0.5,1))
    -- _upBtn:setVisible(false)
    _upBtn:registerScriptTapHandler(fightUpPetAction )
    _upBtn:setScale(MainScene.elementScale)
    menuBar:addChild(_upBtn,20)

   -- 出战特效
    local img_path = CCString:create("images/pet/effect/chuzhan/chuzhan")
    local  petBottomEffect=  CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), -1,CCString:create(""))
    petBottomEffect:setFPS_interval(1/60.0)
    petBottomEffect:setPosition(_upBtn:getContentSize().width/2, _upBtn:getContentSize().height/2)
    petBottomEffect:setAnchorPoint(ccp(0.5,0.5))
    _upBtn:addChild(petBottomEffect,-1)

    --已出战
    _upAlreadySp= CCSprite:create("images/pet/pet/up_already.png")
    _upAlreadySp:setPosition(upBtnPos)
    _upAlreadySp:setAnchorPoint(ccp(0.5,1))
    _upAlreadySp:setScale(MainScene.elementScale)
    -- _upAlreadySp:setVisible(false)
    _bgLayer:addChild(_upAlreadySp,20)

    --左右箭头
    local leftArrSp= CCSprite:create("images/pet/petfeed/left_dr.png")
    leftArrSp:setPosition(ccp(8*MainScene.elementScale, 0.4*_layerSize.height))
    leftArrSp:setScale(MainScene.elementScale )
    _bgLayer:addChild(leftArrSp,15)
    arrowAction(leftArrSp)
    local rightArrSp = CCSprite:create("images/pet/petfeed/right_dr.png")
    rightArrSp:setScale(MainScene.elementScale )
    rightArrSp:setAnchorPoint(ccp(1,0))
    rightArrSp:setPosition(ccp(_layerSize.width-8*MainScene.elementScale, 0.4*_layerSize.height))
    _bgLayer:addChild(rightArrSp,15)
    arrowAction(rightArrSp)
    --战斗力UI
    createFightNode()
    -- 名字的背景
    local fullRect = CCRectMake(0,0,111,32)
    local insetRect = CCRectMake(39,15,2,2)
    _nameBg= CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
    _nameBg:setPreferredSize(CCSizeMake(245,35))
    _nameBg:setScale(MainScene.elementScale )
    _nameBg:setAnchorPoint(ccp(0.5,1))
    _nameBg:setPosition(_layerSize.width/2 , _fightSpite:getPositionY()+ 4*MainScene.elementScale )
    _bgLayer:addChild(_nameBg,17)

    --等级和名字
    local lvSp= CCSprite:create("images/common/lv.png")
    _lvLabel= CCLabelTTF:create( "100" ,g_sFontPangWa, 21)-- 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _lvLabel:setColor(ccc3(0xff,0xf6,0x00))

    _nameLabel= CCLabelTTF:create(GetLocalizeStringBy("key_1505"),g_sFontPangWa,25 )
    _nameLabel:setColor(ccc3(0xff,0x84,0x00))
    local evolveLevel = 0
    local petInfo = _formationPetInfo[_curPetIndex]
    _evolveLvLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1089",evolveLevel),g_sFontPangWa,21,1,ccc3(0,0,0),type_shadow)
    _evolveLvLabel:setColor(ccc3(0xff,0xf6,0x00))
    _evolveLvLabel:setAnchorPoint(ccp(0,0.5))
    _nameLabel:addChild(_evolveLvLabel)
    if petInfo and  petInfo.va_pet then
        local evolveLevel = petInfo.va_pet.evolveLevel or 0
        -- _evolveLvLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1089",evolveLevel),g_sFontPangWa,21,1,ccc3(0,0,0),type_shadow)
        -- _evolveLvLabel:setColor(ccc3(0xff,0xf6,0x00))
        -- _evolveLvLabel:setAnchorPoint(ccp(0,0.5))
        -- _nameLabel:addChild(_evolveLvLabel)
    end
    local nameNode= BaseUI.createHorizontalNode({lvSp, _lvLabel, _nameLabel})
    nameNode:setAnchorPoint(ccp(0.5,0.5))
    nameNode:setPosition(_nameBg:getContentSize().width/2 - 40, _nameBg:getContentSize().height/2)
    _nameBg:addChild(nameNode)
    --驯养
    _domestDescSp= CCSprite:create("images/pet/pet/domesti_desc_sp.png")
    _domestDescSp:setPosition(_layerSize.width/2,0.254*_layerSize.height )
    _domestDescSp:setAnchorPoint(ccp(0.5,0))
    _domestDescSp:setScale(MainScene.elementScale)
    _domestDescSp:setVisible(false)
    _bgLayer:addChild(_domestDescSp,115)

    --出战提示
    _upDescSp= CCSprite:create("images/pet/pet/up_desc_sp.png")
    _upDescSp:setPosition(_layerSize.width/2,0.2*_layerSize.height )
    _upDescSp:setAnchorPoint(ccp(0.5,0))
    _upDescSp:setScale(MainScene.elementScale )
    _upDescSp:setVisible(false)
    _bgLayer:addChild(_upDescSp,115)
    
    --根据主界面，喂养，吞噬，领悟技能创建界面UI
    createUIByLayerStatus()

    --刷新中部UI
    refreshMiddleUI()
    --刷新底部UI
    refreshBottomUI()

    -- 定时器
    _updateTimer = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateShieldTime, 1, false)
end
--[[
    @des    : 创建资质互换的按钮
    @param  : 
    @return : 
--]]
function createSwapBtn( ... )
    -- body
    -- 资质互换
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    _bgLayer:addChild(menu,19)
    _aptitudeSwapBtn = CCMenuItemImage:create("images/pet/pet/swap_btn_n.png","images/pet/pet/swap_btn_h.png")
    _aptitudeSwapBtn:setAnchorPoint(ccp(0.5,1))
    _aptitudeSwapBtn:setPosition(ccp(_bagItem:getPositionX() - _bagItem:getContentSize().width * g_fElementScaleRatio / 2,_bagItem:getPositionY() - _bagItem:getContentSize().height * g_fElementScaleRatio))
    _aptitudeSwapBtn:registerScriptTapHandler(swapCallBack)
    _aptitudeSwapBtn:setScale(MainScene.elementScale)
    menu:addChild(_aptitudeSwapBtn)
end

--[[
    @des    : 箭头的动画
    @param  : 
    @return : 
--]]
function arrowAction( arrow)
    local arrActions_2 = CCArray:create()
    arrActions_2:addObject(CCFadeOut:create(1))
    arrActions_2:addObject(CCFadeIn:create(1))
    local sequence_2 = CCSequence:create(arrActions_2)
    local action_2 = CCRepeatForever:create(sequence_2)
    arrow:runAction(action_2)
end
--[[
    @des    : 资质互换回调
    @param  : 
    @return : 
--]]
function swapCallBack( ... )
    -- body
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local petInfo = _formationPetInfo[_curPetIndex]
    if petInfo.petDesc.ifEvolve == 0 then
        AnimationTip.showTip(GetLocalizeStringBy("syx_1111"))
        return 
    end
    require "script/ui/pet/PetAptitudeSwapLayer.lua"
    PetAptitudeSwapLayer.showLayer(_formationPetInfo[_curPetIndex].petid)
end

function refreshMiddleUI(  )
    if tolua.isnull(_nameBg) then
        return
    end
    --宠物星值的星星
    -- refreshStarBg()
    --特殊技能领取按钮
    createSpecialIcon()
    -- print(12345)
    -- print_t(_formationPetInfo[_curPetIndex])
    --如果处于出战状态
    if( _formationPetInfo[_curPetIndex].showStatus==1 ) then
        _nameBg:setVisible(true)
        -- _aptitudeSwapBtn:setVisible(true)
        print(tolua.isnull(_lvLabel),_curPetIndex,_lvLabel)
        _lvLabel:setString(tostring( _formationPetInfo[_curPetIndex].level))
        _nameLabel:setString(_formationPetInfo[_curPetIndex].petDesc.roleName)
        _nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(_formationPetInfo[_curPetIndex].petDesc.quality))
        _domestDescSp:setVisible(false)
        _upDescSp:setVisible(false)
        local petInfo = _formationPetInfo[_curPetIndex]
        local evolveLevel = petInfo.va_pet.evolveLevel or 0
        _evolveLvLabel:setString(GetLocalizeStringBy("syx_1089",evolveLevel))
        _evolveLvLabel:setPosition(ccpsprite(1.1,0.5,_nameLabel))
        createFightNode()

        -- refreshFeedUI()
        -- 只有当宠物
        if( tonumber(_formationPetInfo[_curPetIndex].setpet.status)==1) then
            _upBtn:setVisible(false)
            _upAlreadySp:setVisible(true)
        else
            _upBtn:setVisible(true)
            _upAlreadySp:setVisible(false)
        end
        _aptitudeSwapBtn:setVisible(true)
        _aptitudeSwapBtn:setEnabled(true)
    --处于驯养状态
    elseif(_formationPetInfo[_curPetIndex].showStatus==2) then 
        _fightSpite:setVisible(false)
        _fightforceSp:setVisible(false)
        _nameBg:setVisible(false)
        _domestDescSp:setVisible(true)
        _upDescSp:setVisible(true)
        _aptitudeSwapBtn:setVisible(false)
        _aptitudeSwapBtn:setEnabled(false)
        _upAlreadySp:setVisible(false)
        _upBtn:setVisible(false)
    --处于平常状态
    elseif(_formationPetInfo[_curPetIndex].showStatus==3)then 
        _fightSpite:setVisible(false)
        _fightforceSp:setVisible(false)
        _domestDescSp:setVisible(false)
        _upDescSp:setVisible(false)
        _nameBg:setVisible(false)
        _aptitudeSwapBtn:setVisible(false)
        _aptitudeSwapBtn:setEnabled(false)
        _upAlreadySp:setVisible(false)
        _upBtn:setVisible(false)
    end
    --_petLayerStatus 1, 主界面状态， 2:吞噬 ,3：喂养状态， 4：领悟技能
    if(_petLayerStatus ==1) then
        _feedSp:setVisible(false)
        _learnSp:setVisible(false)
        _swallowSp:setVisible(false)
    elseif(_petLayerStatus == 2) then
        _swallowSp:setVisible(true)
         _feedSp:setVisible(false)
        _learnSp:setVisible(false)
    elseif(_petLayerStatus == 3) then
        _feedSp:setVisible(true)
        _swallowSp:setVisible(false)
        _learnSp:setVisible(false)
    elseif(_petLayerStatus == 4) then
        _feedSp:setVisible(false)
        _swallowSp:setVisible(false)
        _learnSp:setVisible(true)
    end   
    
end

-- 刷新提示的sprite
function refreshDescSp( ... )
    if(_petLayerStatus ==1) then
        _feedSp:setVisible(false)
        _learnSp:setVisible(false)
        _swallowSp:setVisible(false)
    elseif(_petLayerStatus == 2) then
         _feedSp:setVisible(false)
        _learnSp:setVisible(false)
        _swallowSp:setVisible(true)
    elseif(_petLayerStatus == 3) then
        _feedSp:setVisible(true)
        _learnSp:setVisible(false)
        _swallowSp:setVisible(false)
    elseif(_petLayerStatus == 4) then
        _swallowSp:setVisible(false)
        _feedSp:setVisible(false)
        _learnSp:setVisible(true)
    end   
    
end

function rfcAftFightUp( )

    PetData.setFightStatusById(_formationPetInfo[_curPetIndex].petid )
    _upAlreadySp:setVisible(true)
    _upBtn:setVisible(false)
    resetFormationPetInfo()

    -- if(_petLayerStatus == 4 and _skillTableView~= nil ) then
    --     print("===========================     ==================== =========== ==")
    --     _skillNormal = _formationPetInfo[_curPetIndex].va_pet.skillNormal
    --     PetUtil.sortSkillNormal(_skillNormal)
    --     local offset= _skillTableView:getContentOffset()
    --     _skillTableView:reloadData()
    --     _skillTableView:setContentOffset(offset)
    --     createGraspUI()
    -- end

    if(_petLayerStatus == 4 and _bottomBg ~= nil) then

        local petId= tonumber(_formationPetInfo[_curPetIndex].petid )
        local addSkillBytalent=PetData.getAddSkillByTalent(petId)
        _addNormalSkillLevel = addSkillBytalent.addNormalSkillLevel
        print("===========")

        -- 宠物进阶的技能等级加成
        local curPetInfo = _formationPetInfo[_curPetIndex]
        local evolveLv = tonumber(curPetInfo.va_pet.evolveLevel) or 0
        _evolveAddSkillLv = PetData.getPetEvolveSkillLevel(curPetInfo,evolveLv)
        print("PetMainLayer rfcAftFightUp evolveAddSkillLv => ",_evolveAddSkillLv)

        _skillNormal = _formationPetInfo[_curPetIndex].va_pet.skillNormal
        PetUtil.sortSkillNormal(_skillNormal)

        local offset= _skillTableView:getContentOffset()
        _skillTableView:reloadData()
        _skillTableView:setContentOffset(offset)
    end
end

function resetFormationPetInfo( )
    _formationPetInfo= PetData.getFormationPetInfo()
    print("resetFormationPetInfo resetFormationPetInfo")
   -- print_t(_formationPetInfo)
end

-- 创建宠物的底UI
function createPetBotttom( )
    -- _petSrcBottom= CCSprite:create("images/pet/pet/pet_bottom.png")
    -- _petSrcBottom:setPosition(ccp(_layerSize.width/2,_layerSize.height*0.33))
    -- _petSrcBottom:setAnchorPoint(ccp(0.5,0))
    -- _bgLayer:addChild(_petSrcBottom)

    -- fazhenfaguang
    local img_path = CCString:create("images/pet/effect/fazhenfaguang/fazhenfaguang")
    _petBottomEffect=  CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), -1,CCString:create(""))
    _petBottomEffect:retain()
    _petBottomEffect:setPosition( _layerSize.width*0.5 ,_layerSize.height*0.39)
    _petBottomEffect:setAnchorPoint(ccp(0.5,0))
    _petBottomEffect:setScale(MainScene.elementScale)
    _bgLayer:addChild(_petBottomEffect,10)

end


-- 创建宠物的
function createPetSrc(  )

    if(_petSrc~= nil) then
        _petSrc:removeFromParentAndCleanup(true)
        _petSrc= nil
    end

    resetFormationPetInfo()

    -- print("_bgLayer ======== 000  ",_bgLayer:getContentSize().width )

    _petSrc= CCScrollView:create()
    _petSrc:setViewSize(CCSizeMake(_curPetSize.width,_curPetSize.height))
    _petSrc:setContentSize(CCSizeMake(_curPetSize.width*(#_formationPetInfo)*1, _curPetSize.height ))
    _petSrc:setContentOffset(ccp(0,0))
    _petSrc:setScale(g_fScaleX)
    _petSrc:setDirection(kCCScrollViewDirectionHorizontal)
    _petSrc:setPosition((_layerSize.width - _curPetSize.width*g_fScaleX)/2,_layerSize.height*0.333)
    _bgLayer:addChild(_petSrc,11)

    _petSrcLayer= CCLayer:create()
    _petSrcLayer:setPosition(ccp(0,0))
    _petSrcLayer:setContentSize( CCSizeMake( _curPetSize.width*table.count(_formationPetInfo), _curPetSize.height ))
    _petSrc:setContainer(_petSrcLayer)

    for i=1, #_formationPetInfo do  
        local petTid = nil 
        local petDb = nil
        if(_formationPetInfo[i].petDesc) then 
            petTid= _formationPetInfo[i].petDesc.id
            petDb = DB_Pet.getDataById(petTid)
        end
        local showStatus=  _formationPetInfo[i].showStatus
        local slotIndex= i
        local petSprite =  PetUtil.getPetIMGById(petTid ,showStatus, slotIndex)
        petSprite:setAnchorPoint(ccp(0.5,0))
        local offsetY = 0
        if petDb ~= nil then
            offsetY = petDb.Offset or 0
        end
        petSprite:setPosition(ccp(_curPetSize.width*(i-0.5) , (25 - offsetY)*MainScene.elementScale/g_fScaleX))
        petSprite:setScale(MainScene.elementScale/g_fScaleX )
        _petSrcLayer:addChild(petSprite,1)
    end

    if(_posIndex) then
        local offset= _petSrc:getContentOffset()
        print("_posIndex  is : ", _posIndex)
        _curPetIndex = _posIndex+1
        _petSrc:setContentOffset(ccp(offset.x-_curPetSize.width*(_posIndex),offset.y))
    end

    print(" _curPetIndex is :", _curPetIndex)
end


-- function updateShieldTime( )

--     if( _formationPetInfo[_curPetIndex].showStatus==1  and  tonumber(_formationPetInfo[_curPetIndex].va_pet.skillProduct[1].id)>0 ) then
--         local skillId= tonumber(_formationPetInfo[_curPetIndex].va_pet.skillProduct[1].id)
--         local skillLevel= PetData.getPetSkillLevel( _formationPetInfo[_curPetIndex].petid)
--         local cdTime= PetUtil.getProduceTime(skillId, skillLevel)
--         local leftTime = cdTime+ tonumber(_formationPetInfo[_curPetIndex].setpet.producttime )- BTUtil:getSvrTimeInterval()

--         -- print("skillId is : ", skillId, "skillLevel is ,",skillLevel)
--         -- print(" cdTime is :", cdTime , " leftTime ", leftTime)

--         require "script/utils/TimeUtil"
        
--         --刷新剩余时间
--         local shieldTime = "" .. TimeUtil.getTimeString( leftTime )

--         if(_bgLayer~= nil and _produceLabel ~= nil ) then
--             _produceLabel:setString(shieldTime)
--              _produceLabel:setVisible(true)
--              _receiveSp:setVisible(true)
--             if( tonumber(leftTime) <=0 ) then
--                 _produceLabel:setVisible(false)
--                 _receiveSp:setVisible(true)
--                 -- _produceItem:setEnabled(true)
--             else
--                 _receiveSp:setVisible(false)
--                  -- _produceItem:setEnabled(false)
--             end
--         end
--     end
-- end
function updateShieldTime( )

    if( _formationPetInfo[_curPetIndex].showStatus==1  and  tonumber(_formationPetInfo[_curPetIndex].va_pet.skillProduct[1].id)>0 ) then
        -- local skillId= tonumber(_formationPetInfo[_curPetIndex].va_pet.skillProduct[1].id)
        -- local skillLevel= PetData.getPetSkillLevel( _formationPetInfo[_curPetIndex].petid)
        -- local cdTime= PetUtil.getProduceTime(skillId, skillLevel)
        local nPetId = tonumber(_formationPetInfo[_curPetIndex].petid)
        local leftTime = PetData.getLeftProducttimeById( nPetId )

        -- print("skillId is : ", skillId, "skillLevel is ,",skillLevel)
        -- print(" cdTime is :", cdTime , " leftTime ", leftTime)

        require "script/utils/TimeUtil"
        
        --刷新剩余时间
        local shieldTime = "" .. TimeUtil.getTimeString( leftTime )

        if(_bgLayer~= nil and _produceLabel ~= nil ) then
            _produceLabel:setString(shieldTime)
             _produceLabel:setVisible(true)
             _receiveSp:setVisible(true)
            if( tonumber(leftTime) <=0 ) then
                _produceLabel:setVisible(false)
                _receiveSp:setVisible(true)
                -- _produceItem:setEnabled(true)
            else
                _receiveSp:setVisible(false)
                 -- _produceItem:setEnabled(false)
            end
        end

        --刷新一键领取所有宠物产出按钮
        refreshOneKeyReceiveBtn()
    end
end

function refreshOneKeyReceiveBtn( ... )
    if _btnOneKeyReceive == nil then
        print("refreshOneKeyReceiveBtn _btnOneKeyReceive is nil")
        return
    end

    --检测是否有宠物的技能产出可以领取
    local bHas = PetData.hasProductToReceive()
    if bHas then
        _btnOneKeyReceive:setEnabled(true)
    else
        _btnOneKeyReceive:setEnabled(false)
    end
end

local function levelUpEffect()
    local img_path = CCString:create("images/pet/effect/fazhenbao/fazhenbao")
    local addPetEffect = CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), 1,CCString:create(""))
    addPetEffect:setFPS_interval(1/60.0)
    addPetEffect:setPosition((_layerSize.width)/2,_layerSize.height*0.43)
    addPetEffect:setAnchorPoint(ccp(0.5,0))
    _bgLayer:addChild(addPetEffect,4)

    local img_path = CCString:create("images/pet/effect/guangxian/guangxian")
    local addPetEffect_02 = CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), 1,CCString:create(""))
    addPetEffect_02:setFPS_interval(1/60.0)
    addPetEffect_02:setPosition((_layerSize.width)/2,_layerSize.height*0.53)
     addPetEffect_02:setAnchorPoint(ccp(0.5,0))
    _bgLayer:addChild(addPetEffect_02,12)

    if( _formationPetInfo[_curPetIndex].level ~= nil ) then 
        LevelUpUtil.showFloatText(GetLocalizeStringBy("key_2693") .. _formationPetInfo[_curPetIndex].level .. GetLocalizeStringBy("key_2469"),g_sFontPangWa, rewardTxtColor)
    end
end


-- animate end
local animationEnd = function(actionName,xmlSprite)
    levelUpEffect()

 end
        

-- 宠物喂养的特效 ,通过boolUp来判断宠物是否升级
function feedEffect(boolUp)
    if tolua.isnull(_layer) then
        return
    end
    if(boolUp == nil) then
        boolUp = false
    end
    local img_path = CCString:create("images/pet/effect/chongwuweiyang/chongwuweiyang") 
    local addPetEffect = CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), 1,CCString:create(""))
    -- music
    if(file_exists("images/pet/effect/chongwuweiyang.mp3")) then
        require "script/audio/AudioUtil"
        AudioUtil.playEffect("images/pet/effect/chongwuweiyang.mp3")
    end
    addPetEffect:setPosition(ccp(g_winSize.width*0.5,_layerSize.height*0.6))
    addPetEffect:setAnchorPoint(ccp(0.5,0))
    addPetEffect:setFPS_interval(1/60.0)
    --CCDirector:sharedDirector():getRunningScene():addChild(addPetEffect,1000,9999)
    _bgLayer:addChild(addPetEffect,13)


    local delegate = BTAnimationEventDelegate:create()
    --如果宠物升级
    if(boolUp) then
        delegate:registerLayerEndedHandler(animationEnd)
    end
    addPetEffect:setDelegate(delegate)
end


-- 开启上阵栏位之后的回调函数
local function rfcAtfOpenSquandSlot(  )

    -- local img_path = CCString:create("images/pet/effect/cwjinengkaiqi/cwjinengkaiqi") 
    -- local addPetEffect = CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), 1,CCString:create(""))
    -- -- music
    -- addPetEffect:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*450/960))
    -- addPetEffect:setAnchorPoint(ccp(0.5,0))
    -- addPetEffect:setFPS_interval(1/60.0)
    -- _bgLayer:addChild(addPetEffect,100)

    resetFormationPetInfo()
    _posIndex= _curPetIndex-1

    createPetSrc()
    refreshMiddleUI()
    refreshTopUI()
    _formationNumLabel:setString("" .. PetData.getFormationNum() .. "/" .. PetData.getMaxForamtionNum())
end

--[[
 @desc   宠物
 @para      
 @return 
--]]
local function switchPetSrc( xOffset )
    if (math.abs(xOffset) < 20) then

        if( _formationPetInfo[_curPetIndex].showStatus ==1) then
            require "script/ui/pet/PetInfoLayer"

            local petId= tonumber(_formationPetInfo[_curPetIndex].petid)
            local pet_tmpl = tonumber(_formationPetInfo[_curPetIndex].pet_tmpl )

            PetInfoLayer.showLayer(pet_tmpl,petId,"mainLayer", _curPetIndex-1)

        elseif( _formationPetInfo[_curPetIndex].showStatus ==2) then
            if(NewGuide.guideClass ==  ksGuidePet) then
                require "script/guide/PetGuide"
                PetGuide.changLayer()
            end

           local layer = PetSelFormatLayer.createLayer(_curPetIndex-1 )
           MainScene.changeLayer(layer ,"PetSelFormatLayer")
        elseif(_formationPetInfo[_curPetIndex].showStatus ==3) then
            local  costGold, needLv = PetUtil.getCostFenceGoldBySlot(_curPetIndex)
            -- local _dbInfo = DB_Pet_cost.getDataById(1)
            -- local dbData = string.split(_dbInfo.openPetItemNum,"|")
            -- local _curHaveItemNum = ItemUtil.getCacheItemNumBy(dbData[1])
            -- if(_curHaveItemNum>=tonumber(dbData[2]))then

            -- else
            --     if(costGold> UserModel.getGoldNumber() ) then
            --         -- AnimationTip.showTip(GetLocalizeStringBy("key_2376"))
            --         LackGoldTip.showTip()
            --         return 
            --     end
            --     AnimationTip.showTip(GetLocalizeStringBy("lic_1634"))
            --     return
            -- end

            local function openSquan( pType)
               -- if(isOpen == true) then
                    local petid= _formationPetInfo[_curPetIndex].petid
                    local pos = _curPetIndex-1
                    PetService.openSquandSlot( pos, pType, rfcAtfOpenSquandSlot)
                --end
            end  

            require "script/ui/pet/OpenPetSquandTip"
            if(tonumber(needLv)<999 ) then
                OpenPetSquandTip.showAlert( costGold, needLv, openSquan)
                  --AlertTip.showAlert(GetLocalizeStringBy("key_2781") ..costGold .. GetLocalizeStringBy("key_1491") .. GetLocalizeStringBy("key_1435") .. needLv..GetLocalizeStringBy("key_1226") ,openSquan, true,nil,nil,nil)
            else
                 OpenPetSquandTip.showAlert( costGold, nil, openSquan) --AlertTip.showAlert(GetLocalizeStringBy("key_2781") ..costGold .. GetLocalizeStringBy("key_1491") ,openSquan, true,nil,nil,nil)
            end
        end

        print("xOffset is : ", -(_curPetIndex -1 )*_curPetSize.width)
        _petSrc:setContentOffset(ccp(-(_curPetIndex -1 )*_curPetSize.width , 0))
    else
        if(xOffset<0) then
            if(_curPetIndex == table.count( _formationPetInfo))then
                _curPetIndex= _curPetIndex
            else
                _curPetIndex = _curPetIndex+1
            end
        else
            if(_curPetIndex== 1) then
                _curPetIndex=_curPetIndex
            else
                _curPetIndex = _curPetIndex-1
            end
        end
        refreshMiddleUI()

        refreshBottomUI()
        _petSrc:setContentOffsetInDuration(ccp(-(_curPetIndex -1 )*_curPetSize.width , 0),0.2)
        
    end
end

local function onTouchesHandler( eventType, x, y )
    if(eventType == "began") then
        print("began")
        touchBeganPoint = ccp(x, y)

        local vPosition = _petSrc:convertToNodeSpace(touchBeganPoint)
        if ( vPosition.x >0 and vPosition.x <  _curPetSize.width and vPosition.y > 0 and vPosition.y < _curPetSize.height ) then
            return true
        end
    elseif(eventType == "moved") then
        
        _petSrc:setContentOffset(ccp(x - touchBeganPoint.x- (_curPetIndex-1)*_curPetSize.width , 0))
    else
        print("ended")
        local xOffset = x - touchBeganPoint.x
        switchPetSrc(xOffset)
    end 
end

local function onNodeEvent( eventType )
    if (eventType == "enter") then
        print("_bgLayer  enter")
        _bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -124, true)
        _bgLayer:setTouchEnabled(true)
        --开始计时器
        PetService.startScheduler()
    elseif(eventType == "exit") then
        if(_updateTimer ~= nil)then
           CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimer)
           _updateTimer = nil
        end
        PetService.stopScheduler()
        PreRequest.setBagDataChangedDelete(nil)
        _bgLayer:unregisterScriptTouchHandler()
        RechargeLayer.registerChargeGoldCb(nil)
        -- _bgLayer= nil
    end
end
--[[
	@des   	:得到宠物的主界面
	@param  : posIndex ：上阵的栏位，从0 开始, petLayerStatus:一开始就进到宠物的的状态, petId:一开始就进宠物的Id
	@return	: layer
]]
function createLayer(posIndex, petLayerStatus, petId)

	init()

	_bgLayer= CCLayer:create()
    _bgLayer:registerScriptHandler(onNodeEvent)

    _posIndex= posIndex or 0

    if(_posIndex) then
        _curPetIndex = _posIndex+1
    end

    if( petLayerStatus== nil) then
        _petLayerStatus =1
    else
        _petLayerStatus= petLayerStatus
    end

    _petIdByOutSide= petId

	MainScene.getAvatarLayerObj():setVisible(false)
	MenuLayer.getObject():setVisible(true)
	BulletinLayer.getLayer():setVisible(true)
    local bulletinLayerSize = BulletinLayer.getLayerContentSize()
    local menuLayerSize = MenuLayer.getLayerContentSize()

	_layerSize = {width= 0, height=0}
	_layerSize.width= g_winSize.width 
	_layerSize.height =g_winSize.height - (bulletinLayerSize.height+menuLayerSize.height)*g_fScaleX

	_bgLayer:setContentSize(CCSizeMake(_layerSize.width, _layerSize.height))
	_bgLayer:setPosition(ccp(0, menuLayerSize.height*g_fScaleX))

	-- 背景
	_petBackgound = CCSprite:create("images/pet/pet_bg.png")
	_petBackgound:setScale(g_fBgScaleRatio)
	_petBackgound:setAnchorPoint(ccp(0.5, 0.5))
	_petBackgound:setPosition(ccp(_layerSize.width/2,_layerSize.height/2))
	_bgLayer:addChild(_petBackgound)

    --创建战斗力，金银币UI
    createTopUI()
    -- createBotom()
    --背包按钮
    createBagMenuUI()
   
    -- if(_petIdByOutSide == nil ) then
    --拉取所有宠物信息后创建中部的UI（场景UI，特殊技能UI，星值UI）
    PetService.getAllPet(createMiddleUI)

    RechargeLayer.registerChargeGoldCb( refreshTopUI)
    -- else

    createButtonButtons()
    -- end

    -- 宠物新手第2步
	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
            addGuidePetGuide2()
    end))
    _bgLayer:runAction(seq)

	return _bgLayer
end


------------------------------------------------[[ 按钮回调事件 ]]-------------------------------------------------
-- 喂养的回调函数
  --_petLayerStatus 的3中状态 1, 主界面状态， 2:吞噬 ,3：喂养状态， 4：领悟技能
function feedAction( )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui/pet/PetFeedLayer"
    -- _petLayerStatus= 3
    -- setBottomUIVisible(false)
    -- createFeedUI()
    -- refreshDescSp()
    -- createPropertyUI( )
    require "script/guide/NewGuide"
    require "script/guide/PetGuide"
    if(NewGuide.guideClass ==  ksGuidePet and PetGuide.stepNum == 5) then
        PetGuide.changLayer()
        PetFeedLayer.showLayer(_formationPetInfo[_curPetIndex].petid)
        local button = PetFeedLayer.getFirstFoodCell()
        local rect   = getSpriteScreenRect(button)
        PetGuide.show(6, rect)
    else
    PetFeedLayer.showLayer(_formationPetInfo[_curPetIndex].petid)
    end
end

-- 吞噬按钮的回调函数
function swallowAction(tag, item)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    -- _petLayerStatus= 2
    -- setBottomUIVisible(false)
    -- createSwallowUI()
    -- -- 描述图片和文字
    -- refreshDescSp()
    -- createPropertyUI( )
    require "script/ui/pet/SelSwallowPetLayer"
    print(" _swallowedPetId  is : ", _swallowedPetId)
    SelSwallowPetLayer.showLayer( _formationPetInfo[_curPetIndex].petid , _swallowedPetId)

end

-- 创建领悟技能的UI的回调函数
function realizeAction(tag, item)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    -- print(GetLocalizeStringBy("key_2798"))
    -- _petLayerStatus= 4
    -- setBottomUIVisible(false)
    -- createGraspUI()
    -- refreshDescSp()
    -- createPropertyUI()
    
    require "script/guide/NewGuide"
    require "script/guide/PetGuide"
    if(NewGuide.guideClass ==  ksGuidePet and PetGuide.stepNum == 9) then
        PetGuide.changLayer()
        PetGuide.show(10, nil)
    end
    require "script/ui/pet/PetGraspLayer"
    PetGraspLayer.showLayer(_formationPetInfo[_curPetIndex].petid)
end
--[[
    @des    : 进阶按钮回调
    @param  : 
    @return : 
--]]
function advancedHandler( ... )
    -- body
    if not DataCache.getSwitchNodeState(ksSwitchPetDevelop) then
        return
    end
    local petInfo = _formationPetInfo[_curPetIndex]
    -- 当前宠物是否可以进阶
    if petInfo.petDesc.ifEvolve == 0 then
        AnimationTip.showTip(GetLocalizeStringBy("syx_1097"))
        return 
    end
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui/pet/advance/PetAdvanceLayer"
    PetAdvanceLayer.showLayer(_formationPetInfo[_curPetIndex].petid)
end
--[[
    @des    : 培养按钮回调
    @param  : 
    @return : 
--]]
function trainHandler( ... )
    -- body
    if not DataCache.getSwitchNodeState(ksSwitchPetDevelop) then
        return
    end
    local petInfo = _formationPetInfo[_curPetIndex]
    if petInfo.petDesc.ifEvolve == 0 then
        AnimationTip.showTip(GetLocalizeStringBy("syx_1096"))
        return 
    end
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui/pet/PetTrainLayer"
    PetTrainLayer.showLayer(_formationPetInfo[_curPetIndex].petid)
end


-- 点击背包按钮的回调函数
function bagAction(tag, item  )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    require "script/ui/pet/PetBagLayer"
    local layer= PetBagLayer.createLayer()
    --_bgLayer:addChild(layer)
    MainScene.changeLayer( layer,"petBagLayer")
    
end

-- 点击说明按钮的回调函数
function descAction( tag, item)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    -- require "script/ui/pet/PetDescription"
    -- PetDescription.showLayer()

    -- require "script/ui/pet/description/PetDescriptionPanel"
    -- PetDescriptionPanel.showLayer()
    require "script/ui/pet/PetHandbookLayer"
    PetHandbookLayer.show()
end

-- 一键喂养的回调函数
function feedByOneAction(tag, item)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    local curPetId = _formationPetInfo[_curPetIndex].petid 
    if(table.isEmpty(_itemFeedInfo)) then
        AnimationTip.showTip(GetLocalizeStringBy("key_1707"))
        return 
    end
    if(curPetId ~= nil) then

        local allExp = 0
        for i=1, table.count(_itemFeedInfo) do
            allExp = allExp + _itemFeedInfo[i].itemDesc.add_exp*_itemFeedInfo[i].item_num
        end

        local expUpgradeID = tonumber(_formationPetInfo[_curPetIndex].petDesc.expUpgradeID)
        local expFeed = tonumber(_formationPetInfo[_curPetIndex].exp) 
        local curLv,curExp,needExp = LevelUpUtil.getObjectCurExp(expUpgradeID,expFeed)


        if( tonumber(_formationPetInfo[_curPetIndex].level)>= UserModel.getHeroLevel() ) then
            AnimationTip.showTip(GetLocalizeStringBy("key_1251"))
            return
        end

         print("allExp is : ", allExp , " and needExp is : ", needExp ," table.count(_itemFeedInfo)  is : ", table.count(_itemFeedInfo))

        local function feedToLimit( isFeed)
            if(isFeed== false) then
                return
            end
            PetService.feedPetByOne( curPetId, frcAftFeedToLimit)
        end

        if(allExp > needExp) then
            AlertTip.showAlert(GetLocalizeStringBy("key_2440"),feedToLimit, true,nil,nil,nil)
        else
            feedToLimit(true)
        end        
    else
        AnimationTip.showTip(GetLocalizeStringBy("key_1858"))
    end
end

-- 喂养界面返回的回调函数
function feedBackAction(tag, item)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

    print(GetLocalizeStringBy("key_1868"))
    _petLayerStatus= 1
    setBottomUIVisible(true)
    -- refreshBottomUI()
    if(_bottomBg~= nil) then
        _bottomBg:removeFromParentAndCleanup(true)
        _bottomBg= nil
    end
    refreshDescSp()
    createPropertyUI( )

    require "script/guide/NewGuide"
    require "script/guide/PetGuide"
    if(NewGuide.guideClass ==  ksGuidePet and PetGuide.stepNum == 8) then
        PetGuide.changLayer()
        require "script/ui/pet/PetMainLayer"
        local button = PetMainLayer.getRealizeItem()
        local rect   = getSpriteScreenRect(button)
        PetGuide.show(9, rect)
    end
end


-- 吞噬返回的回调函数
function swallowBackAction( tag, item)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    print(" tag is : ", tag)

    print(GetLocalizeStringBy("key_1868"))
    _petLayerStatus= 1
    setBottomUIVisible(true)
    -- refreshBottomUI()
    if(_bottomBg~= nil) then
        _bottomBg:removeFromParentAndCleanup(true)
        _bottomBg= nil
    end
    refreshDescSp()
    createPropertyUI( )

end

-- 领悟界面返回的回调函数
function graspBackAction()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    print(GetLocalizeStringBy("key_1868"))
    _petLayerStatus= 1
    setBottomUIVisible(true)
    -- refreshBottomUI()
    if(_bottomBg~= nil) then
        _bottomBg:removeFromParentAndCleanup(true)
        _bottomBg= nil
    end

    createPropertyUI()
    refreshDescSp()

    if(NewGuide.guideClass ==  ksGuidePet and PetGuide.stepNum == 13) then
        PetGuide.changLayer()
        require "script/ui/pet/PetMainLayer"
        PetGuide.show(14, nil)
    end
end

-- 选择吞噬宠物的回调函数
function addSwalPetAction( tag, item)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui/pet/SelSwallowPetLayer"
    print(" _swallowedPetId  is : ", _swallowedPetId)
    SelSwallowPetLayer.showLayer( _formationPetInfo[_curPetIndex].petid , _swallowedPetId)
end

function swallowPetAction( )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    if( _swallowedPetId == nil) then
        AnimationTip.showTip(GetLocalizeStringBy("key_2180"))
        return
    end

    print( " _swallowedPetId is :", _swallowedPetId)
    -- local bePetIds= CCArray:create()
    -- bePetIds:addObject(CCInteger:create(tonumber( _swallowedPetId) ))
    PetService.swallowPet(_formationPetInfo[_curPetIndex].petid, _swallowedPetId, rfcAftSwallow )
    
end

-- 重技能的回调函数
function resetAction( tag, item)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    local function reserSkill( isRest )
        if(isRest== false) then
            return
        end

        local petId= _formationPetInfo[_curPetIndex].petid
        PetService.resetSkill(petId ,rfcAftResetSkill)

    end

    AlertTip.showAlert(GetLocalizeStringBy("key_2131") ..  _formationPetInfo[_curPetIndex].petDesc.resetSkillGold .. GetLocalizeStringBy("key_1866") ,reserSkill, true,nil,nil,nil)
end

-- 领悟技能的回调函数
function graspSkillAction( tag,item)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    print(GetLocalizeStringBy("key_2842"))

    local ColumLimit = _formationPetInfo[_curPetIndex].petDesc.ColumLimit or 0
    local levelLimit = _formationPetInfo[_curPetIndex].petDesc.levelLimit or 0
    local maxSkillNumber= tonumber(ColumLimit)*tonumber(levelLimit)
    -- local addlevel = 0
    -- local evolveLevel = tonumber(_formationPetInfo[_curPetIndex].va_pet.evolveLevel) or 0
    -- local evolveSkill = PetController.analysisDbStr(_formationPetInfo[_curPetIndex].petDesc.evolveSkill)
    -- if(not table.isEmpty(evolveSkill) and evolveLevel > 0)then
    --     for i =1,#evolveSkill do
    --         if(evolveLevel >= tonumber(evolveSkill[i][1]))then
    --             addlevel = addlevel + tonumber(evolveSkill[i][2])
    --         else
    --             break;
    --         end
    --     end
    -- end
    -- local maxSkillNumber= tonumber(ColumLimit)*(tonumber(levelLimit) + addlevel)

    local curSkillNumber= 0
    local skillNormal =  _formationPetInfo[_curPetIndex].va_pet.skillNormal 
    for i=1, table.count(skillNormal) do
        if(tonumber(skillNormal[i].id) ~= 0 ) then
            curSkillNumber = curSkillNumber+ skillNormal[i].level
        end
    end

    if(tonumber(curSkillNumber)>= maxSkillNumber ) then
        AnimationTip.showTip(GetLocalizeStringBy("key_1193"))
        return 
    end


    local petId= _formationPetInfo[_curPetIndex].petid
    --学习了技能
    PetService.learnSkill(petId , rfcAftLearnSkill )

    --新手引导
    if(NewGuide.guideClass ==  ksGuidePet and PetGuide.stepNum == 12) then
        PetGuide.changLayer()
        require "script/ui/pet/PetMainLayer"
        local button = PetMainLayer.getGraspBackItem()
        local rect   = getSpriteScreenRect(button)
        PetGuide.show(13, rect)
    end
    if(NewGuide.guideClass ==  ksGuidePet and PetGuide.stepNum == 11) then
        PetGuide.changLayer()
        require "script/ui/pet/PetMainLayer"
        local button = PetMainLayer.getGraspItem()
        local rect   = getSpriteScreenRect(button)
        PetGuide.show(12, rect)
    end

end


-- 宠物出战的回调函数
function fightUpPetAction(tag,item )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    local curPetId = tonumber(_formationPetInfo[_curPetIndex].petid )

    PetService.fightUpPet( curPetId , rfcAftFightUp)

    if(NewGuide.guideClass ==  ksGuidePet and PetGuide.stepNum == 16) then
        PetGuide.changLayer()
        require "script/ui/pet/PetMainLayer"
        PetGuide.show(17, nil)
    end
    
end

-- 生产按钮的回调函数
function produceAction( tag, item)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local skillId= tonumber(_formationPetInfo[_curPetIndex].va_pet.skillProduct[1].id)
    local skillLevel= PetData.getPetSkillLevel( _formationPetInfo[_curPetIndex].petid)
    local cdTime= PetUtil.getProduceTime(skillId, skillLevel)
    local leftTime = cdTime+ tonumber(_formationPetInfo[_curPetIndex].setpet.producttime )- BTUtil:getSvrTimeInterval()
    local curPetId = tonumber(_formationPetInfo[_curPetIndex].petid )
    
    if( leftTime <0) then
        PetService.collectProduction(curPetId, rfcAftProduce)
    else
        AnimationTip.showTip(GetLocalizeStringBy("key_2416"))
    end

    
end

-- 一键领取所有宠物产出
function tapOneKeyReceive( pTag, pItem )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    --检测是否有宠物的技能产出可以领取
    local nCanReceive, sDesc = PetData.canOneKeyReceive()
    -- print("nCanReceive: ", nCanReceive, "sDesc: ", sDesc)
    if nCanReceive == 0 then
        --满足一键领取所有条件
        PetService.collectAllProduction(rfcAftProduce)
    elseif nCanReceive == 1 then
        --背包已满
    elseif nCanReceive == 2 then
        --英雄数量已达上限
        HeroPublicUI.showHeroIsLimitedUI()
    else
        AnimationTip.showTip(sDesc)
    end
end


----------------------------------宠物的新手引导----------------------------------

---[==[宠物 第2步
function addGuidePetGuide2( ... )
    require "script/guide/NewGuide"
    require "script/guide/PetGuide"
    if(NewGuide.guideClass ==  ksGuidePet and PetGuide.stepNum == 1) then
        local rect = CCRectMake(g_winSize.width*0.2, g_winSize.height*0.25, g_winSize.width*0.6, g_winSize.height*0.5)
        PetGuide.show(2, rect)
    end

    --喂养按钮引导
    if(NewGuide.guideClass ==  ksGuidePet and PetGuide.stepNum == 4) then
        local sprite = getFeedItem()
        local rect   = getSpriteScreenRect(sprite)
        PetGuide.show(5, rect)
    end
end
--]==]

-- 获得喂养按钮
function getFeedItem( )
    return _feedItem
end

-- 得到第一个宠物饲料的cell
function getFirstFoodCell( ... )
    local curCell= tolua.cast(_feedTableView:cellAtIndex(0),"CCTableViewCell")
    local sprite = tolua.cast(curCell:getChildByTag(1),"CCSprite")
    return sprite
end

-- 宠物喂养界面的返回按钮
function getFeedBackItem( ... )
    
    return _feedBackItem
end

-- 得到领悟技能的按钮
function getRealizeItem( )
    return _realizeItem
end

-- 得到开始领悟的按钮
function getGraspItem( ... )
    return _graspBtn
end

-- 得到领悟技能返回的按钮
function getGraspBackItem( ... )
    return _graspBackBtn
end

-- 得到出战的按钮
function getUpBtn( ... )
    return _upBtn
end

function getCurPetIndex( ... )
    return _curPetIndex - 1
end

-----------过去的代码遗留，现在没有在使用---------------
-- 喂养部分的UI
function createFeedUI( )

    if(_bottomBg~= nil) then
        _bottomBg:removeFromParentAndCleanup(true)
        _bottomBg= nil
    end

    _bottomBg= CCScale9Sprite:create("images/pet/pet/bottom_bg.png")
    _bottomBg:setContentSize(CCSizeMake(640*g_fScaleX, 248*MainScene.elementScale ) )
    _bottomBg:setAnchorPoint(ccp(0.5,0))
    _bottomBg:setPosition(_layerSize.width/2, 4)
    _bgLayer:addChild(_bottomBg,15)
    
    local fullRect = CCRectMake(0,0,95,247)
    local insetRect = CCRectMake(41,57,3,157)
    _feedViewBg= CCScale9Sprite:create("images/pet/pet/feed_bg.png", fullRect, insetRect)
    _feedViewBg:setPreferredSize(CCSizeMake(630,248))
    _feedViewBg:setScale(MainScene.elementScale)
    _feedViewBg:setPosition(_layerSize.width/2, 0)
    _feedViewBg:setAnchorPoint(ccp(0.5,0))
    _bottomBg:addChild(_feedViewBg)

    _levelUpDescSp= CCSprite:create("images/pet/pet/level_up_desc.png")
    _levelUpDescSp:setPosition(ccp(_feedViewBg:getContentSize().width/2 , _feedViewBg:getContentSize().height+3 ))
    _levelUpDescSp:setAnchorPoint(ccp(0.5,0))
    -- _levelUpDescSp:setScale(MainScene.elementScale)
    _feedViewBg:addChild(_levelUpDescSp,50)

    local lvSp= CCSprite:create("images/common/lv.png")
    lvSp:setPosition(55,213)
    _feedViewBg:addChild(lvSp)

    _feedPetLevel= CCLabelTTF:create(tostring(_formationPetInfo[_curPetIndex].level ),g_sFontPangWa, 18)
    _feedPetLevel:setColor(ccc3(0xff,0xf6,0x00))
    _feedPetLevel:setAnchorPoint(ccp(0,0))
    _feedPetLevel:setPosition(96, 213)
    _feedViewBg:addChild(_feedPetLevel)

    local progressBg= CCScale9Sprite:create(CCRectMake(11, 7, 1, 1) , "images/pet/pet/progress_bg.png")
    progressBg:setPosition(133, 210)
    progressBg:setPreferredSize(CCSizeMake(440,23))
    _feedViewBg:addChild(progressBg)

    _lvProgress= CCScale9Sprite:create( "images/pet/petfeed/exp_progress.png")
    _lvProgress:setAnchorPoint(ccp(0, 0))
    _lvProgress:setPosition(ccp(2,0))

    local expUpgradeID = tonumber(_formationPetInfo[_curPetIndex].petDesc.expUpgradeID)
    local expFeed = _formationPetInfo[_curPetIndex].exp
    print("expUpgradeID is :", expUpgradeID , expFeed)
    local curLv,curExp,needExp = LevelUpUtil.getObjectCurExp(expUpgradeID,expFeed)
    print(" curLv,curExp,needExp  is : ", curLv,curExp,needExp )
    progressBg:addChild(_lvProgress)

    _lvProgress:setPreferredSize(CCSizeMake( 436*math.floor(curExp)/needExp, _lvProgress:getContentSize().height))

    _progressLebel= CCLabelTTF:create("" .. curExp .. "/" .. needExp, g_sFontName,21)
    _progressLebel:setPosition(progressBg:getContentSize().width/2,progressBg:getContentSize().height/2 )
    _progressLebel:setAnchorPoint(ccp(0.5,0.5))
    progressBg:addChild(_progressLebel)

     if(tonumber(_formationPetInfo[_curPetIndex].level)>= UserModel.getHeroLevel()) then
        _progressLebel:setString(GetLocalizeStringBy("key_1976"))
    else
        _progressLebel:setString("" ..  curExp .. "/" .. needExp)
    end


    local menuBar= CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    _feedViewBg:addChild(menuBar)

    -- 一键喂养按钮
    feedByOneItem= LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(213,73),GetLocalizeStringBy("key_1126"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    feedByOneItem:setAnchorPoint(ccp(0.5,0))
    feedByOneItem:setPosition(_feedViewBg:getContentSize().width*0.75, 8 )
    -- feedByOneItem:setScale(MainScene.elementScale )
    feedByOneItem:registerScriptTapHandler(feedByOneAction)
    menuBar:addChild(feedByOneItem,1)

    --  返回
    _feedBackItem= LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(213,73),GetLocalizeStringBy("key_3290"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _feedBackItem:setAnchorPoint(ccp(0.5,0))
    _feedBackItem:setPosition(_feedViewBg:getContentSize().width*0.25, 8)
    -- feedBackItem:setScale(MainScene.elementScale )
    _feedBackItem:registerScriptTapHandler(feedBackAction)
    menuBar:addChild(_feedBackItem,1)

    -- 左边的箭头
    local leftArrow= CCSprite:create("images/formation/btn_left.png")
    leftArrow:setPosition(14,94)
    _feedViewBg:addChild(leftArrow)

     -- 右边的箭头
    local rightArrow= CCSprite:create("images/formation/btn_right.png")
    rightArrow:setPosition(567,94)
    _feedViewBg:addChild(rightArrow)

    --获得食品的信息，如果食品是空则显示前往商店和竞技功能，否则创建tableView
    --added by Zhang Zihang
    _itemFeedInfo = ItemUtil.getFeedInfos()

    if #_itemFeedInfo == 0 then
        --隐藏一键喂养和返回按钮
        feedByOneItem:setVisible(false)
        _feedBackItem:setPosition(_feedViewBg:getContentSize().width*0.5, 8)
        --创建寻找食物按钮
        createFindFoodFunction()
    else
        createFeedTableView()
    end
end

--[[
    @des    :创建前往商店和前往竞技按钮
    @param  :
    @return :
--]]
--added by Zhang Zihang
function createFindFoodFunction()
    local feedViewMenu = CCMenu:create()
    feedViewMenu:setPosition(ccp(0,0))
    _feedViewBg:addChild(feedViewMenu)

    --前往商店按钮
    local gotoShopMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1408"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1,ccc3(0x00, 0x00, 0x00))
    gotoShopMenuItem:setAnchorPoint(ccp(0.5, 0.5))
    gotoShopMenuItem:setPosition(ccp(_feedViewBg:getContentSize().width*0.3,_feedViewBg:getContentSize().height*0.65))
    gotoShopMenuItem:registerScriptTapHandler(gotoShopCallBack)
    feedViewMenu:addChild(gotoShopMenuItem)

    --前往竞技按钮
    local gotoPKMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1279"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1,ccc3(0x00, 0x00, 0x00))
    gotoPKMenuItem:setAnchorPoint(ccp(0.5, 0.5))
    gotoPKMenuItem:setPosition(ccp(_feedViewBg:getContentSize().width*0.7,_feedViewBg:getContentSize().height*0.65))
    gotoPKMenuItem:registerScriptTapHandler(gotoPKCallBack)
    feedViewMenu:addChild(gotoPKMenuItem)

    --可前往商店购买，或前往竞技场兑换
    local foodLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1015"),g_sFontPangWa,24,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    foodLabel:setColor(ccc3(0xff,0xff,0xff))
    foodLabel:setAnchorPoint(ccp(0.5,0))
    foodLabel:setPosition(ccp(_feedViewBg:getContentSize().width*0.5,_feedViewBg:getContentSize().height*0.4))
    _feedViewBg:addChild(foodLabel)
end

--[[
    @des    :前往商店回调
    @param  :
    @return :
--]]
--added by Zhang Zihang
function gotoShopCallBack()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    --以下逻辑照抄StarLayer.gotoShopAction

    require "script/model/DataCache"
    if DataCache.getSwitchNodeState(ksSwitchShop) then
        require "script/ui/shop/ShopLayer"
        local  shopLayer = ShopLayer.createLayer(ShopLayer.Tag_Shop_Prop)
        MainScene.changeLayer(shopLayer,"shopLayer",ShopLayer.layerWillDisappearDelegate)
    end
end

--[[
    @des    :前往竞技回调
    @param  :
    @return :
--]]
--added by Zhang Zihang
function gotoPKCallBack()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    --以下逻辑照抄StarLayer.gotoMatchAction
    --为什么要判断物品和武将满，去问程亮

    --判断物品背包是否满
    if ItemUtil.isBagFull() == true then
        return
    end
    -- 判断武将背包是否满
    require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then
        return
    end
    require "script/model/DataCache"
    local canEnter = DataCache.getSwitchNodeState(ksSwitchArena)
    if(canEnter) then
        require "script/ui/arena/ArenaLayer"
        local arenaLayer = ArenaLayer.createArenaLayer()
        MainScene.changeLayer(arenaLayer,"arenaLayer")
    end
end

-- 宠物饲料的tableView
function createFeedTableView( )
    --下面这一行代码被注释掉是因为挪到createFeedUI()函数createFeedTableView()前面了
    --因为要在没有食品的情况下展示前往商店和前往竞技功能
    --added by Zhang Zihang    
    --_itemFeedInfo = ItemUtil.getFeedInfos()

    -- 
    -- local function cmp( k1,k2)
    --     return tonumber(k1.itemDesc.add_exp) < tonumber(k2.itemDesc.add_exp)
    -- end
    -- -- 按照品质排序，然后经验排序
    local function cmp( k1,k2)
        if( tonumber(k1.itemDesc.quality) > tonumber(k2.itemDesc.quality) ) then
            return true
        else
            if( tonumber(k1.itemDesc.quality) == tonumber(k2.itemDesc.quality) and  tonumber(k1.itemDesc.add_exp) > tonumber(k2.itemDesc.add_exp)) then
                return true
            else
                return false
            end
        end 
    end

    table.sort(_itemFeedInfo,cmp)
    -- print(" ++++=====  _itemFeedInfo  is ; +++++++++++++ ")
    -- print_t(_itemFeedInfo)

    local cellSize = CCSizeMake(128, 119)
    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            --r = CCSizeMake(cellSize.width * myScale, cellSize.height * myScale)
            r = cellSize

        elseif fn == "cellAtIndex" then
            a2 = FeedCell.createCell(_itemFeedInfo[a1+1])
            r = a2
            print("refreshFeedView refreshFeedView refreshFeedView ")
        elseif fn == "numberOfCells" then
            local num = #_itemFeedInfo
            r = num
        elseif fn == "cellTouched" then

            print("a1:getIdx() is ", a1:getIdx())
    
            local curPetId = _formationPetInfo[_curPetIndex].petid
            local item_id = _itemFeedInfo[a1:getIdx()+1].item_id
            local item_tmple_id= tonumber(_itemFeedInfo[a1:getIdx()+1].itemDesc.id)
            _gid = _itemFeedInfo[a1:getIdx()+1].gid

            if(_itemFeedInfo[a1:getIdx()+1].item_num == 0) then
                return
            end
            local expUpgradeID = tonumber(_formationPetInfo[_curPetIndex].petDesc.expUpgradeID)
            local expFeed = _formationPetInfo[_curPetIndex].exp
            local curLv,curExp,needExp = LevelUpUtil.getObjectCurExp(expUpgradeID,expFeed)
            local exp = tonumber (_formationPetInfo[_curPetIndex].exp)
            if( tonumber(_formationPetInfo[_curPetIndex].level)>=  UserModel.getHeroLevel() ) then
                AnimationTip.showTip(GetLocalizeStringBy("key_1251"))
                return
            end
            --喂养物品引导
            if(NewGuide.guideClass ==  ksGuidePet and PetGuide.stepNum == 6) then
                PetGuide.changLayer()
                PetGuide.show(7, nil)
            end
           PetService.feedPetByItem(curPetId, item_id , item_tmple_id,rfcAftFeed)
            
        elseif (fn == "scroll") then
            
        end
        return r
    end)

    _feedTableView = LuaTableView:createWithHandler(h, CCSizeMake(512, 119))
    _feedTableView:setBounceable(true)
    _feedTableView:setTouchPriority(-151)
    _feedTableView:setDirection(kCCScrollViewDirectionHorizontal)
    _feedTableView:setPosition(ccp(_feedViewBg:getContentSize().width*0.1, 82))
    _feedTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _feedViewBg:addChild(_feedTableView)
end

-- 刷新喂养时的等级和进度条
function refreshFeedUI()
    if(_petLayerStatus==3 and _bottomBg~= nil and _formationPetInfo[_curPetIndex].showStatus ==1) then
        _bottomBg:setVisible(true)

        _feedPetLevel:setString(tostring(_formationPetInfo[_curPetIndex].level))  --CCLabelTTF:create(tostring(_formationPetInfo[_curPetIndex].level ),g_sFontPangWa, 18)
        local expUpgradeID = tonumber(_formationPetInfo[_curPetIndex].petDesc.expUpgradeID)
        local expFeed = _formationPetInfo[_curPetIndex].exp
        local curLv,curExp,needExp = LevelUpUtil.getObjectCurExp(expUpgradeID,expFeed)
        local exp = tonumber (_formationPetInfo[_curPetIndex].exp)
        _lvProgress:setPreferredSize(CCSizeMake( 436*math.floor(curExp)/needExp, _lvProgress:getContentSize().height))
        if(tonumber(_formationPetInfo[_curPetIndex].level)>= UserModel.getHeroLevel()) then
            _progressLebel:setString(GetLocalizeStringBy("key_1976"))
        else
            _progressLebel:setString("" ..  curExp .. "/" .. needExp)
        end
    elseif( _bottomBg~= nil and  _petLayerStatus==3 and _formationPetInfo[_curPetIndex].showStatus ~=1 ) then
        _bottomBg:setVisible(false)
    end
end


-- 点击物品时喂养刷新
function rfcAftFeed()

    ItemUtil.reduceItemByGid(_gid,1)
    resetFormationPetInfo()
    refreshFeedView()
    refreshFeedUI()
    createFightNode()
    _lvLabel:setString(tostring( _formationPetInfo[_curPetIndex].level))

    if #ItemUtil.getFeedInfos() == 0 then
        feedByOneItem:setVisible(false)
        _feedBackItem:setPosition(_feedViewBg:getContentSize().width*0.5, 8)
        createFindFoodFunction()
    end


    -- _feedPetLevel:setString(tostring(_formationPetInfo[_curPetIndex].level))  --CCLabelTTF:create(tostring(_formationPetInfo[_curPetIndex].level ),g_sFontPangWa, 18)
    -- local expUpgradeID = tonumber(_formationPetInfo[_curPetIndex].petDesc.expUpgradeID)
    -- local expFeed = _formationPetInfo[_curPetIndex].exp
    -- local curLv,curExp,needExp = LevelUpUtil.getObjectCurExp(expUpgradeID,expFeed)
    -- local exp = tonumber (_formationPetInfo[_curPetIndex].exp)
    -- _lvProgress:setPreferredSize(CCSizeMake( 436*math.floor(curExp)/needExp, _lvProgress:getContentSize().height))
end
-- 刷新_feedTableView 
function refreshFeedView()

    _itemFeedInfo = ItemUtil.getFeedInfos()
    local function cmp( k1,k2)
        if( tonumber(k1.itemDesc.quality) > tonumber(k2.itemDesc.quality) ) then
            return true
        else
            if( tonumber(k1.itemDesc.quality) == tonumber(k2.itemDesc.quality) and  tonumber(k1.itemDesc.add_exp) > tonumber(k2.itemDesc.add_exp)) then
                return true
            else
                return false
            end
        end 
    end
    table.sort(_itemFeedInfo,cmp)
    local contentOffset = _feedTableView:getContentOffset()
    _feedTableView:reloadData()
    _feedTableView:setContentOffset(contentOffset)
end


function bagChangedDelegateFunc( )

    if(_petLayerStatus == 3) then
        resetFormationPetInfo()
        refreshFeedUI()
        refreshFeedView()
        refreshMiddleUI()
    end 
end

function frcAftFeedToLimit()
    PreRequest.setBagDataChangedDelete(bagChangedDelegateFunc)  
    _itemFeedInfo = ItemUtil.getFeedInfos()
    if #_itemFeedInfo == 0 then
        feedByOneItem:setVisible(false)
        _feedBackItem:setPosition(_feedViewBg:getContentSize().width*0.5, 8)
        createFindFoodFunction()
    end
end

function refreshBottomUI( )

    --刷新喂养宠物进度条
    -- refreshFeedUI()
    --刷新领悟技能
    -- refreshGraspUI()
    --刷新吞噬
    -- refreshSwallowUI()

    --宠物属性框
    createPropertyUI()

    --四种主界面UI状态
    if( _petLayerStatus ==1) then 
        _feedItem:setVisible(true)
        _realizeItem:setVisible(true)
        _swallowItem:setVisible(true)
        _formationNumBg:setVisible(true)
        _advancedBtn:setVisible(true)
        _trainBtn:setVisible(true)
         if(_formationPetInfo[_curPetIndex].showStatus ~=1) then
            _swallowItem:setVisible(false)
            _realizeItem:setVisible(false)
            _feedItem:setVisible(false)
            _formationNumBg:setVisible(false)
            _advancedBtn:setVisible(false)
            _trainBtn:setVisible(false)
        end 
    elseif(_petLayerStatus ==2)then
        _swallowItem:setVisible(false)
        _feedItem:setVisible(false)
        _realizeItem:setVisible(false)
        _formationNumBg:setVisible(false)
        _advancedBtn:setVisible(false)
        _trainBtn:setVisible(false)
    elseif(_petLayerStatus==3)then
         _swallowItem:setVisible(false)
        _feedItem:setVisible(false)
        _realizeItem:setVisible(false)
        _formationNumBg:setVisible(false)
        _advancedBtn:setVisible(false)
        _trainBtn:setVisible(false)
    elseif(_petLayerStatus==4) then
         _swallowItem:setVisible(false)
        _feedItem:setVisible(false)
        _realizeItem:setVisible(false)
        _formationNumBg:setVisible(false)
        _advancedBtn:setVisible(false)
        _trainBtn:setVisible(false)
    end  
end


--  创建宠物吞噬的UI
function createSwallowUI( )

    if(_bottomBg~= nil) then
        _bottomBg:removeFromParentAndCleanup(true)
        _bottomBg= nil
    end

    _addPetButton= nil
    _swallowedPetSp = nil
    _swallowedPetId = nil

    _bottomBg= CCScale9Sprite:create("images/pet/pet/bottom_bg.png")
    _bottomBg:setContentSize(CCSizeMake(_layerSize.width, 265*MainScene.elementScale ) )
    _bottomBg:setAnchorPoint(ccp(0.5,0))
    _bottomBg:setPosition(_layerSize.width/2, 4)
    _bgLayer:addChild(_bottomBg)

    -- 边框
    local frameSp= CCSprite:create("images/main/base_bottom_border.png")
    frameSp:setPosition(ccp(_bottomBg:getContentSize().width/2,  _bottomBg:getContentSize().height))
    frameSp:setAnchorPoint(ccp(0.5,0.7))
    frameSp:setScale(g_fScaleX)
    _bottomBg:addChild(frameSp,17)

    local swallDescSp= CCSprite:create("images/pet/pet/swallow_desc.png")
    swallDescSp:setPosition( _bottomBg:getContentSize().width/2,frameSp:getPositionY()- frameSp:getContentSize().height*g_fScaleX- 14*g_fScaleX )
    swallDescSp:setAnchorPoint(ccp(0.5,0.7))
    swallDescSp:setScale(MainScene.elementScale )
    _bottomBg:addChild(swallDescSp)

    local menuBar= CCMenu:create()
    menuBar:setPosition(0,0)
    _bottomBg:addChild(menuBar,11)

    --  返回
    local swallowBackItem= LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(213,73),GetLocalizeStringBy("key_3290"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    swallowBackItem:setAnchorPoint(ccp(0.5,0))
    swallowBackItem:setPosition(_bottomBg:getContentSize().width*0.25, 5*MainScene.elementScale)
    swallowBackItem:setScale(MainScene.elementScale )
    swallowBackItem:registerScriptTapHandler(swallowBackAction)
    menuBar:addChild(swallowBackItem,1)

    -- 吞噬按钮
    local swallowItem= LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(213,73),GetLocalizeStringBy("key_2786"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    swallowItem:setAnchorPoint(ccp(0.5,0))
    swallowItem:setPosition(_bottomBg:getContentSize().width*0.75, 5*MainScene.elementScale)
    swallowItem:setScale(MainScene.elementScale )
    swallowItem:registerScriptTapHandler(swallowPetAction)
    menuBar:addChild(swallowItem,1)

    -- 选择吞噬
    local fullRect = CCRectMake(0,0,95,247)
    local insetRect = CCRectMake(43,57,2,157)
    local  swallowBg= CCScale9Sprite:create("images/common/bg/9s_1.png")--, fullRect, insetRect)
    swallowBg:setPreferredSize(CCSizeMake(585,119))
    swallowBg:setScale(MainScene.elementScale)
    swallowBg:setPosition(_bottomBg:getContentSize().width/2, 73*MainScene.elementScale )
    swallowBg:setAnchorPoint(ccp(0.5,0))
    _bottomBg:addChild(swallowBg)

    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    swallowBg:addChild(menu)

    --添加被吞噬宠物按钮
    _addPetButton = CCMenuItemImage:create("images/formation/potential/equip_1.png", "images/formation/potential/equip_1.png")
    _addPetButton:setPosition(124, swallowBg:getContentSize().height/2)
    _addPetButton:setAnchorPoint(ccp(0,0.5))
    _addPetButton:registerScriptTapHandler(addSwalPetAction)
    menu:addChild(_addPetButton)

    local head_icon=CCSprite:create("images/common/add_new.png")
    local arrActions_2 = CCArray:create()
    arrActions_2:addObject(CCFadeOut:create(1))
    arrActions_2:addObject(CCFadeIn:create(1))
    local sequence_2 = CCSequence:create(arrActions_2)
    local action_2 = CCRepeatForever:create(sequence_2)
    head_icon:runAction(action_2)
    head_icon:setPosition(_addPetButton:getContentSize().width/2, _addPetButton:getContentSize().height/2)
    head_icon:setAnchorPoint(ccp(0.5,0.5))
    _addPetButton:addChild(head_icon)

    
    -- local curPetTmpl, swallowNum= _formationPetInfo[_curPetIndex].pet_tmpl ,_formationPetInfo[_curPetIndex].swallow 
    -- local canSwallowNum= PetUtil.getCanSwallowNum( curPetTmpl, swallowNum)
    local swallowLabel= CCLabelTTF:create(GetLocalizeStringBy("key_2117"), g_sFontName, 21)
    swallowLabel:setColor(ccc3(0xff,0xff,0xff))
    _swallowNumLabel= CCLabelTTF:create(""  ,g_sFontName, 21) 
    _swallowNumLabel:setColor(ccc3(0x00,0xff,0x18))
    local swallowNode= BaseUI.createHorizontalNode({swallowLabel , _swallowNumLabel})
    swallowNode:setPosition(273, swallowBg:getContentSize().height/2 )
    swallowNode:setAnchorPoint(ccp(0,0.5))
    swallowNode:setAnchorPoint(ccp(0,0))
    swallowBg:addChild(swallowNode)
    
end


function refreshSwallowUI( )

    if(_petLayerStatus== 2 and _bottomBg~= nil and _formationPetInfo[_curPetIndex].showStatus ==1) then
        --创建吞噬UI
        createSwallowUI()
    elseif( _bottomBg~= nil and  _petLayerStatus==2 and _formationPetInfo[_curPetIndex].showStatus ~=1 ) then
        _bottomBg:setVisible(false)
    end
    
end

-- 选择吞噬完宠物之后的回调函数
function rfcAftSelect(  petId)
    print("=============  rfcAftSelect  petId is ", petId)
    MainScene.setMainSceneViewsVisible(true, false,  true )
    if(petId== nil ) then
        _swallowedPetId = nil
        return
    end
    -- 
    if(_swallowedPetSp~= nil) then
        _swallowedPetSp:removeFromParentAndCleanup(true)
        _swallowedPetSp= nil
    end

    _swallowedPetId= tonumber(petId)
    local swallowedPetInfo = PetData.getPetInfoById(tonumber(petId) )
    _swallowedPetSp = PetUtil.getPetHeadIconByItid( tonumber(swallowedPetInfo.pet_tmpl),nil,nil,-1 )
    _swallowedPetSp:setPosition(_addPetButton:getContentSize().width/2, _addPetButton:getContentSize().height/2 )
    _swallowedPetSp:setAnchorPoint(ccp(0.5,0.5))
    _addPetButton:addChild(_swallowedPetSp,11)

    local addPoint= PetData.getAddPoint( _formationPetInfo[_curPetIndex].petid,_swallowedPetId )
    _swallowNumLabel:setString("" .. addPoint )

end

-- 吞噬完后，的刷新函数
function rfcAftSwallow( )

    if(_swallowedPetSp~= nil) then
        _swallowedPetSp:removeFromParentAndCleanup(true)
        _swallowedPetSp= nil
    end

    resetFormationPetInfo()
    -- _swallowedPetId= nil
    -- _swallowNumLabel:setString("")
   _lvLabel:setString(tostring( _formationPetInfo[_curPetIndex].level))
   createFightNode()
end

-- 创建领悟的UI
function createGraspUI( )

    if(_bottomBg~= nil) then
        _bottomBg:removeFromParentAndCleanup(true)
        _bottomBg= nil
    end

    --底框UI
    _bottomBg= CCScale9Sprite:create("images/pet/pet/bottom_bg.png")
    _bottomBg:setContentSize(CCSizeMake(_layerSize.width, 255*MainScene.elementScale ) )
    _bottomBg:setAnchorPoint(ccp(0.5,0))
    _bottomBg:setPosition(_layerSize.width/2, 4)
    _bgLayer:addChild(_bottomBg)

    -- 边框
    local frameSp= CCSprite:create("images/main/base_bottom_border.png")
    frameSp:setPosition(ccp(_bottomBg:getContentSize().width/2,  _bottomBg:getContentSize().height))
    frameSp:setAnchorPoint(ccp(0.5,0.7))
    frameSp:setScale(g_fScaleX)
    _bottomBg:addChild(frameSp,17)

    -- 
    _graspBg= CCScale9Sprite:create("images/common/bg/9s_1.png")
    _graspBg:setContentSize(CCSizeMake(588,163))
    _graspBg:setScale(MainScene.elementScale)
    _graspBg:setPosition(_bgLayer:getContentSize().width/2, 75*MainScene.elementScale)
    _graspBg:setAnchorPoint(ccp(0.5,0))
    _bottomBg:addChild(_graspBg,11)

    local skillBg= CCScale9Sprite:create("images/common/bg/9s_2.png")
    skillBg:setContentSize(CCSizeMake(170,31))
    skillBg:setAnchorPoint(ccp(1,0))
    skillBg:setPosition( frameSp:getContentSize().width -10*MainScene.elementScale,frameSp:getContentSize().height/2 )
    -- skillBg:setScale(MainScene.elementScale)
    frameSp:addChild(skillBg)

    local skillLabel= CCLabelTTF:create(GetLocalizeStringBy("key_1534"), g_sFontPangWa ,18)
    skillLabel:setColor(ccc3(0xff,0xff,0xff))
    _skillNumLabel= CCLabelTTF:create("" .. _formationPetInfo[_curPetIndex].skill_point , g_sFontPangWa,18)
    _skillNumLabel:setColor(ccc3(0x00,0xff,0x18))

    skillLabel:setPosition(skillBg:getContentSize().width*0.08,  skillBg:getContentSize().height/2)
    skillLabel:setAnchorPoint(ccp(0,0.5))
    skillBg:addChild(skillLabel)

    _skillNumLabel:setPosition(skillBg:getContentSize().width*0.08+ skillLabel:getContentSize().width ,  skillBg:getContentSize().height/2)
    _skillNumLabel:setAnchorPoint(ccp(0,0.5))
    skillBg:addChild(_skillNumLabel)

    -- local skillNumNode= BaseUI.createHorizontalNode({ skillLabel,_skillNumLabel })
    -- skillNumNode:setPosition(ccp(skillBg:getContentSize().width/2,  skillBg:getContentSize().height/2))
    -- skillNumNode:setAnchorPoint(ccp(0.5,0.5))
    -- skillBg:addChild(skillNumNode)

    ---
    local skillBg_1 = CCScale9Sprite:create("images/common/bg/9s_2.png")
    skillBg_1:setContentSize(CCSizeMake(170,31))
    skillBg_1:setAnchorPoint(ccp(0,0))
    skillBg_1:setPosition(10*MainScene.elementScale, frameSp:getContentSize().height/2 )
    frameSp:addChild(skillBg_1)

    local maxSkillLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2226"), g_sFontPangWa,18)
    _maxSkillNumLabel= CCLabelTTF:create( _formationPetInfo[_curPetIndex].petDesc.ColumLimit ,g_sFontPangWa,18)
    _maxSkillNumLabel:setColor(ccc3(0x00,0xff,0x18))

    
    maxSkillLabel:setPosition(skillBg_1:getContentSize().width*0.08,  skillBg_1:getContentSize().height/2)
    maxSkillLabel:setAnchorPoint(ccp(0,0.5))
    skillBg_1:addChild(maxSkillLabel)

    _maxSkillNumLabel:setPosition(skillBg_1:getContentSize().width*0.08+ skillLabel:getContentSize().width ,  skillBg_1:getContentSize().height/2)
    _maxSkillNumLabel:setAnchorPoint(ccp(0,0.5))
    skillBg_1:addChild(_maxSkillNumLabel)
    
    -- local skillNumNode= BaseUI.createHorizontalNode({ maxSkillLabel,_maxSkillNumLabel })
    -- skillNumNode:setPosition(skillBg_1:getContentSize().width/2,  skillBg_1:getContentSize().height/2)
    -- skillNumNode:setAnchorPoint(ccp(0.5,0.5))
    -- skillBg_1:addChild(skillNumNode)


    ---
    local skillBg_2 = CCScale9Sprite:create("images/common/bg/9s_2.png")
    skillBg_2:setContentSize(CCSizeMake(190 ,31))
    skillBg_2:setAnchorPoint(ccp(0.5,0))
    skillBg_2:setPosition( frameSp:getContentSize().width/2 , frameSp:getContentSize().height/2)--- 10*g_fScaleX)
    frameSp:addChild(skillBg_2)

    local levelLimit = CCLabelTTF:create(GetLocalizeStringBy("key_2042"), g_sFontPangWa,18)
    _levelLimitNumLabel= CCLabelTTF:create( _formationPetInfo[_curPetIndex].petDesc.levelLimit ,g_sFontPangWa, 18)
    _levelLimitNumLabel:setColor(ccc3(0x00,0xff,0x18))

    levelLimit:setPosition(skillBg_2:getContentSize().width*0.08,  skillBg_2:getContentSize().height/2)
    levelLimit:setAnchorPoint(ccp(0,0.5))
    skillBg_2:addChild(levelLimit)

    _levelLimitNumLabel:setPosition(skillBg_2:getContentSize().width*0.08+ levelLimit:getContentSize().width ,  skillBg_2:getContentSize().height/2)
    _levelLimitNumLabel:setAnchorPoint(ccp(0,0.5))
    skillBg_2:addChild(_levelLimitNumLabel)


    -- local skillNumNode= BaseUI.createHorizontalNode({ levelLimit,_levelLimitNumLabel })
    -- skillNumNode:setPosition(skillBg_2:getContentSize().width/2,  skillBg_2:getContentSize().height/2)
    -- skillNumNode:setAnchorPoint(ccp(0.5,0.5))
    -- skillBg_2:addChild(skillNumNode)


    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-350)
    _bottomBg:addChild(menu)

    -- 重置按钮 438
    local scale= MainScene.elementScale
    _resetBtn= LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(180,73),GetLocalizeStringBy("key_1040"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _resetBtn:setPosition(235*scale ,8*scale)
    _resetBtn:setVisible(true)
    _resetBtn:registerScriptTapHandler(resetAction)
    _resetBtn:setScale(MainScene.elementScale)
    menu:addChild(_resetBtn)

    -- 领悟按钮 26
    _graspBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(180,73),GetLocalizeStringBy("key_1304"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _graspBtn:setPosition(438*scale,8*scale)
    _graspBtn:setVisible(true)
    _graspBtn:registerScriptTapHandler(graspSkillAction)
    _graspBtn:setScale(MainScene.elementScale)
    menu:addChild(_graspBtn)

    -- 返回按钮 235
    _graspBackBtn= LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(180,73),GetLocalizeStringBy("key_3290"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _graspBackBtn:setPosition(26*scale,8*scale)
    _graspBackBtn:setVisible(true)
    _graspBackBtn:registerScriptTapHandler(graspBackAction)
    _graspBackBtn:setScale(MainScene.elementScale)
    menu:addChild(_graspBackBtn)

    local normalSkillNum = PetData.getSkillNum( _formationPetInfo[_curPetIndex].petid )
    if( normalSkillNum <=0 ) then
        _resetBtn:setEnabled(false)
    else
        _resetBtn:setEnabled(true)
    end

    --创建tableView
    createSkillTableView()
end


function createSkillTableView( )

    _skillNormal = _formationPetInfo[_curPetIndex].va_pet.skillNormal
    PetUtil.sortSkillNormal(_skillNormal )
    -- print_t(_skillNormal)

    local columLimit = _formationPetInfo[_curPetIndex].petDesc.ColumLimit

    local petId= tonumber(_formationPetInfo[_curPetIndex].petid )

    -- print("_skillNormal _skillNormal  _skillNormal petId is :", petId)
    require "script/ui/hero/HeroPublicLua"

    local addSkillBytalent=PetData.getAddSkillByTalent(petId)
    _addNormalSkillLevel = addSkillBytalent.addNormalSkillLevel


    -- 宠物进阶的技能等级加成
    local curPetInfo = _formationPetInfo[_curPetIndex]
    local evolveLv = tonumber(curPetInfo.va_pet.evolveLevel) or 0
    _evolveAddSkillLv = PetData.getPetEvolveSkillLevel(curPetInfo,evolveLv)
    print("PetMainLayer createSkillTableView evolveAddSkillLv => ",_evolveAddSkillLv)

    local cellSize = CCSizeMake(140, 165)
    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            --r = CCSizeMake(cellSize.width * myScale, cellSize.height * myScale)
            r = cellSize

        elseif fn == "cellAtIndex" then
            a2 = CCTableViewCell:create()          
           for i =1, 4 do
                local index= a1*4 +i
                if(a1*4 +i<= #_skillNormal) then 
                    local index= a1*4 +i
                    --得到技能
                    local headSprite = PetUtil.getNormalSkillIcon(_skillNormal[index].id, _skillNormal[index].level , _addNormalSkillLevel + _evolveAddSkillLv , _skillNormal[index].status, _formationPetInfo[_curPetIndex].petid ,rfcAftLock )
                    headSprite:setPosition(ccp(28+138*(i-1),67))
                    a2:addChild(headSprite,1, index)

                    if( tonumber(_skillNormal[index].id)>0 ) then

                        local skillData = DB_Pet_skill.getDataById( tonumber(_skillNormal[index].id))
                        local skillNameLabel = CCRenderLabel:create( skillData.name ,g_sFontPangWa,18 ,1,ccc3(0x00,0x00,0x00),type_stroke )
                        local color= HeroPublicLua.getCCColorByStarLevel(skillData.skillQuality)
                        skillNameLabel:setColor(color )
                        skillNameLabel:setPosition( headSprite:getContentSize().width/2 ,-2)
                        skillNameLabel:setAnchorPoint(ccp(0.5,1))
                        headSprite:addChild(skillNameLabel)

                        local skillProperty = PetUtil.getNormalSkill( tonumber(_skillNormal[index].id), tonumber(_skillNormal[index].level)+_addNormalSkillLevel + _evolveAddSkillLv )
                        -- print("skillProperty is :")
                        -- print_t(skillProperty)
                        for i=1,#skillProperty do
                            local skillLabel_01 = CCLabelTTF:create( skillProperty[i].affixDesc.displayName .. " " , g_sFontName, 18)
                            skillLabel_01:setColor(ccc3(0xff,0xff,0xff))
                            local skillLabel_02= CCLabelTTF:create("+".. skillProperty[i].displayNum , g_sFontName, 18)
                            skillLabel_02:setColor(ccc3(0x00,0xff,0x18))

                            skillLabel_01:setPosition(0, -24-(i-1)*21)
                            skillLabel_01:setAnchorPoint(ccp(0,1))
                            headSprite:addChild(skillLabel_01)

                            skillLabel_02:setPosition(skillLabel_01:getContentSize().width, -24-(i-1)*21)
                            skillLabel_02:setAnchorPoint(ccp(0,1))
                            headSprite:addChild(skillLabel_02)

                            -- local skillNodeLabel= BaseUI.createHorizontalNode({skillLabel_01 ,skillLabel_02})
                            -- skillNodeLabel:setPosition( headSprite:getContentSize().width/2 , -24-(i-1)*21 )---45+(i-1)*21 )
                            -- skillNodeLabel:setAnchorPoint(ccp(0.5,1))
                            -- headSprite:addChild(skillNodeLabel)
                        end

                        local lineSp= CCSprite:create("images/common/line02.png")
                        lineSp:setPosition(headSprite:getContentSize().width/2,-64)
                        lineSp:setAnchorPoint(ccp(0.5,1))
                        headSprite:addChild(lineSp)
                    end

                elseif(a1*4 +i<= columLimit )then
                    local headSprite = PetUtil.getLockIcon()
                    headSprite:setPosition(ccp(28+138*(i-1),67))
                    a2:addChild(headSprite,1, index)
                end
           end
           r = a2
        elseif fn == "numberOfCells" then
            local num = math.ceil(#_skillNormal/4 )
            r =  math.ceil(columLimit/4 )
        elseif fn == "cellTouched" then
            
        elseif (fn == "scroll") then
            
        end
        return r
    end)

    _skillTableView = LuaTableView:createWithHandler(h, CCSizeMake(534, 160))
    _skillTableView:setBounceable(true)
    -- _feedTableView:setDirection(kCCScrollViewDirectionHorizontal)
    _skillTableView:setPosition(ccp(12, 2))
    _skillTableView:setTouchPriority(-551)
    _skillTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _graspBg:addChild(_skillTableView)
   
end
-- 宠物技能来回切换时的刷新
function refreshGraspUI( )
    if(_petLayerStatus== 4 and _bottomBg~= nil and _formationPetInfo[_curPetIndex].showStatus ==1) then
        -- _bottomBg:setVisible(true)
        -- _skillNormal = _formationPetInfo[_curPetIndex].va_pet.skillNormal
        -- PetUtil.sortSkillNormal(_skillNormal )
        -- _skillTableView:reloadData()

        -- _skillNumLabel:setString("" .. _formationPetInfo[_curPetIndex].skill_point )

        -- _maxSkillNumLabel:setString("" .. _formationPetInfo[_curPetIndex].petDesc.ColumLimit)
        -- _levelLimitNumLabel:setString("" .. _formationPetInfo[_curPetIndex].petDesc.levelLimit)

        -- local normalSkillNum = PetData.getSkillNum( _formationPetInfo[_curPetIndex].petid )
        -- if( normalSkillNum <=0 ) then
        --     _resetBtn:setEnabled(false)
        -- else
        --     _resetBtn:setEnabled(true)
        -- end

        --创建领悟技能框
        createGraspUI()

    elseif( _bottomBg~= nil and  _petLayerStatus==4 and _formationPetInfo[_curPetIndex].showStatus ~=1 ) then
        _bottomBg:setVisible(false)
    end

end

-- 
function rfcAftLearnSkill( isSuccss )

    refreshTopUI()

    local normalSkillNum = PetData.getSkillNum( _formationPetInfo[_curPetIndex].petid )
    if( normalSkillNum <=0 ) then
        _resetBtn:setEnabled(false)
    else
        _resetBtn:setEnabled(true)
    end

    if(isSuccss == false) then
         _skillNumLabel:setString("" .. _formationPetInfo[_curPetIndex].skill_point) --CCLabelTTF:create("" .. _formationPetInfo[_curPetIndex].skill_point , g_sFontPangWa,18)
         return 
    end



    local originSkill = {} 
    table.hcopy( _skillNormal,originSkill)

    createFightNode()

    local orginGidNum= table.count(_skillNormal)

    resetFormationPetInfo()
    _skillNormal = _formationPetInfo[_curPetIndex].va_pet.skillNormal

    PetUtil.sortSkillNormal_2(_skillNormal)
    PetUtil.sortSkillNormal(_skillNormal)


     _skillNumLabel:setString("" .. _formationPetInfo[_curPetIndex].skill_point)

    local index =0

    -- 原来的有的技能数
    local originSkillNum=0
    for i=1,table.count(originSkill) do
        if(tonumber(originSkill[i].id )~=0 ) then
            originSkillNum =originSkillNum+1
        end
    end

    -- 现有的技能数
    local normalSkillNum=0
    for i=1,table.count(_skillNormal) do
        if(tonumber(_skillNormal[i].id )~=0 ) then
            normalSkillNum =normalSkillNum+1
        end
    end

    local learnType= 0-- 学习技能的三种情况，1， 开启新的技能栏位， 2, 学到新的技能，3，技能升级 

    -- 
    if( table.count(originSkill) < table.count(_skillNormal)) then
        index= table.count(_skillNormal)

        learnType =1
    elseif( originSkillNum<normalSkillNum )then
        index= normalSkillNum
        learnType =2
    else  
        for i=1, table.count(originSkill ) do
            if( tonumber(_skillNormal[i].id ) ~= tonumber(originSkill[i].id) or tonumber(_skillNormal[i].level ) ~= tonumber(originSkill[i].level) ) then
                index= i
                learnType =3
                break
            end
        end
    end 

    local upSkillInfo ={}

    if(learnType==3 ) then
        upSkillInfo.skill_desc= DB_Pet_skill.getDataById( tonumber(_skillNormal[index].id ))
        upSkillInfo.level = _skillNormal[index].level
    elseif(learnType==2 ) then
        
        for i=1, table.count(_skillNormal) do
            local bool = false
            for j=1, table.count( originSkill) do
                if(tonumber( _skillNormal[i].id) == tonumber(originSkill[j].id )) then
                      bool= true
                end
            end

            if(bool == false) then
                upSkillInfo.skill_desc= DB_Pet_skill.getDataById( tonumber(_skillNormal[i].id) )
                upSkillInfo.level = _skillNormal[i].level

            end
        end    
    end

    _cellIndex= math.floor((index-1)/4)

    local columLimit =  tonumber( _formationPetInfo[_curPetIndex].petDesc.ColumLimit)
    local allCellNum=  math.ceil(columLimit/4 )
    _skillTableView:setContentOffset(ccp(0, -170*(allCellNum- _cellIndex-1 ) ))

    -- print("_skillTableView:getContentOffset() ", _skillTableView:getContentOffset().y)
    print("_cellIndex is :", _cellIndex)
    print("index is :", index)

    local curCell= tolua.cast(_skillTableView:cellAtIndex(_cellIndex),"CCTableViewCell")
    if(curCell~= nil ) then

        local iconSp = tolua.cast( curCell:getChildByTag(index)  ,"CCSprite")

        print("index is : ", index)
        print("_cellIndex is ", _cellIndex)
        if( iconSp~= nil ) then
            if(learnType==1 ) then
                local img_path=  CCString:create("images/pet/effect/cwjinengkaiqi/cwjinengkaiqi")
                local openEffect=  CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), 1,CCString:create(""))
                openEffect:setPosition(iconSp:getContentSize().width/2,iconSp:getContentSize().width*0.5)
                openEffect:setAnchorPoint(ccp(0.5,0.5))
                openEffect:retain()
                iconSp:addChild(openEffect,1)
                local delegate = BTAnimationEventDelegate:create()
                delegate:registerLayerEndedHandler(openEffectEnd)
                openEffect:setDelegate(delegate)
                AnimationTip.showTip(GetLocalizeStringBy("key_2721"))

            elseif(learnType==2) then
                 local img_path=  CCString:create("images/pet/effect/cwjineng/cwjineng")
                local openEffect=  CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), 1,CCString:create(""))
                openEffect:setPosition(iconSp:getContentSize().width/2,iconSp:getContentSize().width*0.4)
                openEffect:setAnchorPoint(ccp(0.5,0.5))
                openEffect:retain()
                iconSp:addChild(openEffect,1)
                local delegate = BTAnimationEventDelegate:create()
                delegate:registerLayerEndedHandler(openEffectEnd)
                openEffect:setDelegate(delegate)

                local textInfo= {
                        {tipText=GetLocalizeStringBy("key_1231"), color=ccc3(255, 255, 255)},
                        {tipText= upSkillInfo.skill_desc.name, color= HeroPublicLua.getCCColorByStarLevel( upSkillInfo.skill_desc.skillQuality) },
                    }

               -- AnimationTip.showTip(GetLocalizeStringBy("key_1759") .. upSkillInfo.skill_desc.name )
               AnimationTip.showRichTextTip(textInfo)

            elseif(learnType==3) then
                local img_path=  CCString:create("images/pet/effect/cwjineng/cwjineng")
                local openEffect=  CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), 1,CCString:create(""))
                openEffect:setPosition(iconSp:getContentSize().width/2,iconSp:getContentSize().width*0.4)
                openEffect:setAnchorPoint(ccp(0.5,0.5))
                openEffect:retain()
                iconSp:addChild(openEffect,1)
                local delegate = BTAnimationEventDelegate:create()
                delegate:registerLayerEndedHandler(openEffectEnd)
                openEffect:setDelegate(delegate)

                AnimationTip.showTip( upSkillInfo.skill_desc.name .. GetLocalizeStringBy("key_2994") .. upSkillInfo.level .. GetLocalizeStringBy("key_2469") )
            end

            -- 显示fly的文字 
            if(learnType~=1) then
                local upSkillProperty= PetUtil.getNormalSkill( upSkillInfo.skill_desc.id, 1)
                local textInfo = {}
                for i=1, #upSkillProperty do
                    local tempTxt ={}
                    tempTxt.txt= upSkillProperty[i].affixDesc.displayName
                    tempTxt.num= upSkillProperty[i].displayNum
                    table.insert(textInfo, tempTxt)
                end
                LevelUpUtil.showFlyText(textInfo)
            end

        else
            openEffectEnd()
        end
    else
        openEffectEnd()
    end  
end

function openEffectEnd( )
    -- createGraspUI()

    -- if(_cellIndex~= nil) then
    --     local columLimit =  tonumber( _formationPetInfo[_curPetIndex].petDesc.ColumLimit)
    --     local allCellNum=  math.ceil(columLimit/4 )
    --     _skillTableView:setContentOffset(ccp(0, -170*(allCellNum- _cellIndex-1 ) ))
    -- end


    local offset= _skillTableView:getContentOffset()
    _skillNormal = _formationPetInfo[_curPetIndex].va_pet.skillNormal
    PetUtil.sortSkillNormal(_skillNormal )
    _skillTableView:reloadData()
    _skillTableView:setContentOffset(offset)

    -- CCLabelTTF:create("" .. _formationPetInfo[_curPetIndex].skill_point
end

-- 重置技能时的刷新函数
function rfcAftResetSkill( ... )
    resetFormationPetInfo()
    createGraspUI()
    _lvLabel:setString(tostring( _formationPetInfo[_curPetIndex].level))
    refreshTopUI()
    createFightNode()

    local normalSkillNum = PetData.getSkillNum( _formationPetInfo[_curPetIndex].petid )
    if( normalSkillNum <=0 ) then
        _resetBtn:setEnabled(false)
    else
        _resetBtn:setEnabled(true)
    end
end

function rfcAftLock( )
    resetFormationPetInfo()

    _skillNormal = _formationPetInfo[_curPetIndex].va_pet.skillNormal
    PetUtil.sortSkillNormal(_skillNormal)

    local offset= _skillTableView:getContentOffset()
    _skillTableView:reloadData()
    _skillTableView:setContentOffset(offset)

    refreshTopUI()

end
function createUIByLayerStatus(  )
    if(_petLayerStatus ==1 ) then

    elseif(_petLayerStatus ==2) then
        swallowAction()
    elseif(_petLayerStatus==3 ) then
        feedAction()
    elseif(_petLayerStatus== 4) then
        realizeAction()
    end
end
function refreshStarBg( ... )

    local starsXPositionsDouble = {0.45,0.55,0.35,0.65,0.25,0.75,0.8}
    local starsYPositionsDouble = {0.745,0.745,0.72,0.72,0.7,0.7,0.68}
   
    if(_formationPetInfo[_curPetIndex].showStatus == 1) then
        local potential=  tonumber( _formationPetInfo[_curPetIndex].petDesc.quality )
        for k, h_starsp in pairs(starArr_h) do
            if ((potential%2) ~= 0) then
                h_starsp:setPosition(ccp(_titleSprite:getContentSize().width * starsXPositions[k], _titleSprite:getContentSize().height * starsYPositions[k]))
                if(k<= potential) then
                    h_starsp:setVisible(true)
                else
                    h_starsp:setVisible(false)
                end
            else
                h_starsp:setPosition(ccp(_titleSprite:getContentSize().width * starsXPositionsDouble[k], _titleSprite:getContentSize().height * starsYPositionsDouble[k]))
                if(k<= potential) then
                    h_starsp:setVisible(true)
                else
                    h_starsp:setVisible(false)
                end
            end
        end
    else
        for k, h_starsp in pairs(starArr_h) do
            h_starsp:setVisible(false)
        end 

    end   
end