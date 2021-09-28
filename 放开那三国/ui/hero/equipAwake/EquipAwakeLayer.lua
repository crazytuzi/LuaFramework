-- Filename: EquipAwakeLayer.lua
-- Author: FQQ
-- Date: 2016-01-04
-- Purpose:装备觉醒界面

module ("EquipAwakeLayer",package.seeall)
require "script/ui/hero/equipAwake/EquipAwakeController"
require "script/ui/hero/equipAwake/EquipAwakeData"
require "script/ui/hero/equipAwake/EquipAwakeCell"
require "script/model/hero/HeroModel"
require "db/DB_Awake_ability"
require "script/audio/AudioUtil"
require "script/ui/tip/AnimationTip"
local _layer
local _silver_count_labelvalue  -- 银币数量
local _gold_count_labelvalue    -- 金币数量
local _info_node                -- 玩家信息
local _title                    -- 标题
local _BG                       -- 背景
local _comprehend               -- 中间界面
local _tableView
local _btnAry = nil
local _fScaleCard = 0.835       -- 卡牌的缩放尺寸
local _priority = nil
local _index = nil
local _imagePath
local _tableView
local _infoEquip
local info_label
local _blueBg = nil
local _attrBg = nil

local kAwakePositionFirst = 1
local kAwakePositionSecond  = 2

function init()
    _BG = nil
    _info_node = nil
    _comprehend = nil
    _imagePath = {
        tap_btn_n = "images/common/btn/tab_button/btn1_n.png",
        tap_btn_h = "images/common/btn/tab_button/btn1_h.png"
    }
    _btnAry = {}
    _tableView = nil
    _priority = -504
    nameLabel = nil
    descLabel = nil
    _index = nil
    _tableView = nil
    _infoEquip = nil
    info_label = nil
    _blueBg = nil
    _attrBg = nil
end
--注册事件
function onNodeEvent(event)
    if event == "exit" then
        if _layer ~= nil then
            _layer:autorelease()
        end
    end
end
--[[
    @des    :入口函数
    @param  :
    @return :
--]]
function show(hero_hid, callback, isCheck)
    if callback ~= nil then
        callback()
    end
    create()
    MainScene.changeLayer(_layer, "ComprehendLayer")
    MainScene.setMainSceneViewsVisible(true, false, true)
end

function create()
    init()
    _layer = CCLayer:create()
    _layer:registerScriptHandler(onNodeEvent)
    loadBG()
    loadTitle()
    loadComprehend()
    setContentType(kAwakePositionFirst)
    local callback =function ( ... )
        _infoEquip = EquipAwakeData.getEquipAwakeArry()
        loadTableView()
    end
    EquipAwakeController.getArrMasterTalent(callback)
    adaptive()
    return _layer
end

--[[
    @des    : 深蓝色背景
    @param  : 
    @return : 
--]]
function loadBG()
    _BG = CCSprite:create("images/main/module_bg.png")
end



--[[
    @des    : 创建标题栏
    @param  : 
    @return : 
--]]
function loadTitle()
    require "script/libs/LuaCC"
    local tLabel = {text=GetLocalizeStringBy("fqq_041"),color=ccc3(0xff, 0xe4, 0x00), fontsize=35, vOffset=4, tag=101, fontname=g_sFontPangWa}
    _title = LuaCC.createSpriteWithLabel("images/common/title_bg.png", tLabel)

    local menu = CCMenu:create()
    _title:addChild(menu)
    menu:setPosition(ccp(0, 0))
    local close_btn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    menu:addChild(close_btn)
    close_btn:setAnchorPoint(ccp(1, 0.5))
    close_btn:setPosition(ccp(_title:getContentSize().width + 5, _title:getContentSize().height * 0.5 + 3))
    close_btn:registerScriptTapHandler(callbackBack)
end
--[[
    @des    : 觉醒能力1，2的lable
    @param  : 
    @return : 
--]]
function loadComprehend()
    _comprehend = CCNode:create()
    _comprehend:setContentSize(CCSizeMake(640, 960))

    local comprehend_size = _comprehend:getContentSize()


    local BG_full_rect = CCRectMake(0, 0, 196, 198)
    local BG_inset_rect = CCRectMake(61, 80, 46, 36)
    local BG = CCScale9Sprite:create("images/hero/bg_ng.png", BG_full_rect, BG_inset_rect)
    _comprehend:addChild(BG)
    local preferred_size = CCSizeMake(640,g_winSize.height * 0.32/g_fScaleX)
    BG:setPreferredSize(preferred_size)
    BG:setPosition(ccp(comprehend_size.width * 0.5, 960 - _title:getPositionY()))
    BG:setAnchorPoint(ccp(0.5, 1))

    --金色的线
    local orangeLine = CCSprite:create("images/common/separator_top.png")
    orangeLine:setAnchorPoint(ccp(0.5,1))
    orangeLine:setPosition(ccp(comprehend_size.width * 0.5,13))
    BG:addChild(orangeLine)
    -- 标签文本
    local btnLabel = {
        GetLocalizeStringBy("key_8080"),
        GetLocalizeStringBy("key_8081"),
        GetLocalizeStringBy("fqq_125")
    }
    local menu = CCMenu:create()
    menu:setPosition(ccp(0, 0))
    _comprehend:addChild(menu)
    for i=1,3 do
        local btn = createBtn(btnLabel[i])
        -- btn:setPosition(ccp(255 * (i - 1),_comprehend:getContentSize().height - 60))
        btn:setPosition(ccp(10+btn:getContentSize().width*(i-1),_comprehend:getContentSize().height - 60))
        btn:setAnchorPoint(ccp(0,1))
        if i == 1 then
            btn:setEnabled(false)
        else
            btn:setEnabled(true)
        end
        menu:addChild(btn,1,i)
        table.insert(_btnAry,btn)
    end
end

function createBtn(text)
    local insertRect = CCRectMake(35,20,1,1)
    local tapBtnN = CCScale9Sprite:create(insertRect,_imagePath.tap_btn_n)
    tapBtnN:setPreferredSize(CCSizeMake(211,43))
    local tapBtnH = CCScale9Sprite:create(insertRect,_imagePath.tap_btn_h)
    tapBtnH:setPreferredSize(CCSizeMake(211,53))
    
    local label1 = CCRenderLabel:create(text, g_sFontName, 30, 2, ccc3(0xff, 0xf9, 0xd0 ), type_stroke)
    label1:setColor(ccc3(0x7c, 0x48, 0x01))
    label1:setAnchorPoint(ccp(0.5,0.5))
    label1:setPosition(ccp(tapBtnN:getContentSize().width*0.5,tapBtnN:getContentSize().height*0.45))
    tapBtnH:addChild(label1) 

    local label2 = CCRenderLabel:create(text, g_sFontName, 30, 1, ccc3(0xd7, 0xa5, 0x56 ), type_stroke)
    label2:setColor(ccc3(0x76, 0x3b, 0x0b))
    label2:setAnchorPoint(ccp(0.5,0.5))
    label2:setPosition(ccp(tapBtnH:getContentSize().width*0.5,tapBtnH:getContentSize().height*0.4))
    tapBtnN:addChild(label2) 
    local btn = CCMenuItemSprite:create(tapBtnN, nil,tapBtnH)
    btn:setAnchorPoint(ccp(0.5,0.5))
    btn:registerScriptTapHandler(setContentType)
    return btn
end

function setContentType( value )
    --音效
     AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
   
    local htid = UserModel.getUserHid()
    
    -- if(kAwakePositionFirst == _index)then
    --     _btnAry[kAwakePositionFirst]:setEnabled(false)
    --     _btnAry[kAwakePositionSecond]:setEnabled(true)
    -- else
    --     _btnAry[kAwakePositionFirst]:setEnabled(true)
    --     _btnAry[kAwakePositionSecond]:setEnabled(false)
    -- end

    local hid = UserModel.getUserHid()
    local curHeroInfo = HeroUtil.getHeroInfoByHid(hid)

    if(value == 3)then
         if tonumber(curHeroInfo.localInfo.star_lv) > 6 and tonumber(curHeroInfo.evolve_level) >=2 then
             _index = value
         else 
             _index = _index
             AnimationTip.showTip(GetLocalizeStringBy("fqq_134"))
                 
        end 
    else
         _index = value
    end
    local awakeId = HeroModel.getMasterTalentId(htid,_index)

    for i=1,#_btnAry do
        if(i == _index )then
                _btnAry[_index]:setEnabled(false)     
        else
            _btnAry[i]:setEnabled(true)
        end
    end

    abilityAwakeUI(awakeId)

end


--[[
    @des    : 上半部分的觉醒属性UI
    @param  : 
    @return : 
--]]
function abilityAwakeUI( pAwakeId )
    if(_attrBg ~= nil)then
        _attrBg:removeFromParentAndCleanup(true)
        _attrBg = nil
    end

    -- 背景图
    local comprehend_size = _comprehend:getContentSize()
    local attr_full_rect = CCRectMake(0, 0, 75, 75)
    local attr_inset_rect = CCRectMake(30, 30, 15, 10)
    _attrBg  = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", attr_full_rect, attr_inset_rect)
    _comprehend:addChild(_attrBg)
    _attrBg:setPreferredSize(CCSizeMake(600, g_winSize.height * 0.18/g_fScaleX))
    _attrBg:setAnchorPoint(ccp(0.5, 1))
    _attrBg:setPosition(ccp(comprehend_size.width * 0.5, comprehend_size.height - 103))
    local attr_full_rect1 = CCRectMake(0, 0, 75, 75)
    local attr_inset_rect1 = CCRectMake(35, 35, 5, 5)
    local di = CCScale9Sprite:create("images/biography/di1.png",attr_full_rect1,attr_inset_rect1)
    di:setPreferredSize(CCSizeMake(600,g_winSize.height*0.17/g_fScaleX))
    _attrBg:addChild(di)
    di:setAnchorPoint(ccp(0.5, 1))
    di:setPosition(ccp(_attrBg:getContentSize().width * 0.5, _attrBg:getContentSize().height - 8))
    --觉醒能力icon的背景
    local iconButton = CCSprite:create("images/common/border.png")
    di:addChild(iconButton)
    iconButton:setAnchorPoint(ccp(0,0.5))
    iconButton:setPosition(ccp(25,di:getContentSize().height*0.5))

    info_label = CCScale9Sprite:create("images/common/bg/9s_word.png",CCRectMake(0,0,44,38))
    di:addChild(info_label)
    info_label:setPreferredSize(CCSizeMake(450,g_winSize.height * 0.1/g_fScaleX))
    info_label:setAnchorPoint(ccp(0,0.5))
    info_label:setPosition(ccp(130,di:getPositionY() - di:getContentSize().height*0.52))

    --label 当前觉醒能力
    local curAwake_label = CCRenderLabel:create(GetLocalizeStringBy("fqq_042"),g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
    curAwake_label:setColor(ccc3(0x00,0xff,0x18))
    info_label:addChild(curAwake_label)
    curAwake_label:setAnchorPoint(ccp(0.5,0))
    curAwake_label:setPosition(ccp(info_label:getContentSize().width*0.5,info_label:getContentSize().height))


    local line = CCSprite:create("images/common/line_4.png")
    line:setScale(0.8)
    info_label:addChild(line)
    line:setAnchorPoint(ccp(0,0))
    line:setPosition(ccp(0,info_label:getContentSize().height*0.56))
    --如果主角有觉醒装备能力，就显示出来icon，名字，描述，字体“觉”
    if(pAwakeId)then
        local awakeInfo = DB_Awake_ability.getDataById(pAwakeId)
        createNameLabel(awakeInfo)
        createDesLabel(awakeInfo)

        local icon = awakeInfo.icon
        local iconString = "images/athena/awake_icon/"..icon
        --物品的icon
        local iconSprite = CCSprite:create(iconString)
        iconSprite:setAnchorPoint(ccp(0.5,0.5))
        iconSprite:setPosition(ccp(iconButton:getContentSize().width*0.5,iconButton:getContentSize().height*0.5))
        iconButton:addChild(iconSprite)

        --添加"觉"背景
        local  awake = CCSprite:create("images/hero/info/awake.png")
        info_label:addChild(awake)
        awake:setAnchorPoint(ccp(0,0.5))
        awake:setPosition(ccp(15,info_label:getContentSize().height*0.3))
        --字体“觉”
        local awakeLabel = CCLabelTTF:create(GetLocalizeStringBy("fqq_053"),g_sFontName,25)
        awakeLabel:setColor(ccc3(0xff,0xff,0xff))
        awakeLabel:setAnchorPoint(ccp(0.5,0.5))
        awakeLabel:setPosition(ccp(awake:getContentSize().width*0.5,awake:getContentSize().height*0.5))
        awake:addChild(awakeLabel)
    end

end
--[[
    @des    : 创建物品名称
    @param  : 
    @return : 
--]]
function createNameLabel(p_info )
    local text = nil
    if(not table.isEmpty(p_info))then
        text = p_info.name
    else
        text = " "
    end
    --物品名称
    local  nameLabel = CCRenderLabel:create(text,g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
    nameLabel:setColor(ccc3(0xe4,0x00,0xff))
    info_label:addChild(nameLabel)
    nameLabel:setAnchorPoint(ccp(0,1))
    nameLabel:setPosition(ccp(30,info_label:getContentSize().height*0.9))
end
--[[
    @des    : 创建物品描述
    @param  : 
    @return : 
--]]
function createDesLabel( p_info )
    local text = nil
    if(not table.isEmpty(p_info))then
        text = p_info.des
    else
        text = " "
    end
    --物品描述
    local descLabel = CCRenderLabel:createWithAlign(text,g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke,CCSizeMake(306,50),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    descLabel:setColor(ccc3(0xff,0xff,0xff))
    info_label:addChild(descLabel)
    descLabel:setAnchorPoint(ccp(0,1))
    descLabel:setPosition(ccp(70,info_label:getContentSize().height*0.48))
end


--[[
    @des    : 下半部分深蓝色背景
    @param  : 
    @return : 
--]]
function loadTableView( ... )
    if(_tableView ~= nil)then
        _tableView:removeFromParentAndCleanup(true)
    end
    local comprehend_size = _comprehend:getContentSize()
    if not table.isEmpty(_infoEquip) then
        local h = LuaEventHandler:create(function ( fn,p_table,a1,a2)
            local r
            if fn == "cellSize" then
                r = CCSizeMake(590,170)
            elseif fn == "cellAtIndex" then
                a2 = EquipAwakeCell.createCell(_infoEquip[a1 + 1], a1 + 1,_priority - 30)
                r = a2
            elseif fn == "numberOfCells" then
                r = table.count(_infoEquip)

            end
            return r
        end)
        _tableView = LuaTableView:createWithHandler(h,CCSizeMake(640,g_winSize.height * 0.48/g_fScaleX))
        _comprehend:addChild(_tableView)
        _tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
        _tableView:setAnchorPoint(ccp(0.5,1))
        _tableView:setPosition(ccp(comprehend_size.width * 0.5, comprehend_size.height - 100 - 23 -g_winSize.height * 0.2/g_fScaleX))
        _tableView:ignoreAnchorPointForPosition(false)
        _tableView:setTouchPriority(-600)
    else
        --显示 label 当前没有觉醒属性的装备
        --当前没有觉醒属性可装备
        local label1 = CCRenderLabel:create(GetLocalizeStringBy("fqq_043"),g_sFontPangWa,23,1,ccc3(0x00,0x00,0x00),type_stroke)
        label1:setColor(ccc3(0xff,0xff,0xff))
        label1:setPosition(ccp(640*0.5,comprehend_size.height - 186 - 23 -g_winSize.height * 0.2/g_fScaleX))
        label1:setAnchorPoint(ccp(0.5,1))
        _comprehend:addChild(label1)
        --觉醒属性可在星魂系统中获取
        local label2 = CCRenderLabel:create(GetLocalizeStringBy("fqq_044"),g_sFontPangWa,23,1,ccc3(0x00,0x00,0x00),type_stroke)
        label2:setColor(ccc3(0xff,0xff,0xff))
        label2:setPosition(ccp(640*0.5,comprehend_size.height - 186 - 23 -g_winSize.height * 0.2/g_fScaleX - label1:getContentSize().height*1.3))
        label2:setAnchorPoint(ccp(0.5,1))
        _comprehend:addChild(label2)

    end

end
--[[
    @des    : 屏幕适配
    @param  : 
    @return : 
--]] 
function adaptive()
    local bulletin_layer_size = BulletinLayer.getLayerContentSize()
    local menu_layer_size = MenuLayer.getLayerContentSize()

    _layer:addChild(_BG)
    _BG:setAnchorPoint(ccp(0, 0))
    _BG:setScale(g_fBgScaleRatio)

    _layer:addChild(_title, 10)
    _title:setScale(g_fScaleX)
    _title:setAnchorPoint(ccp(0.5, 1))
    local _info_node_y = g_winSize.height - bulletin_layer_size.height * g_fScaleX
    local title_y = _info_node_y 
    _title:setPosition(g_winSize.width * 0.5, title_y)

    _layer:addChild(_comprehend)
    _comprehend:setScale(g_fScaleX)
    _comprehend:setAnchorPoint(ccp(0.5, 1))
    _comprehend:setPosition(ccp(g_winSize.width * 0.5, _title:getPositionY() - 20 * g_fScaleX))

end
--[[
    @des    : 返回按钮的回调
    @param  : 
    @return : 
--]]
function callbackBack()
    --音效
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    require "script/ui/hero/HeroLayer"
    _layer:removeFromParentAndCleanup(true)
    MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
end
--[[
    @des    : 刷新UI
    @param  : 
    @return : 
--]]
function updateUI( ... )
    _infoEquip = EquipAwakeData.getEquipAwakeArry()
    local hid = UserModel.getUserHid()
    local awakeId = HeroModel.getMasterTalentId(hid,_index)
    loadTableView()
    abilityAwakeUI(awakeId)
end
--[[
    @des    :获取下标
    @param  :
    @return :
--]]
function getIndex( ... )
    local index = 1
    if(_index == kAwakePositionFirst)then
        index = 1
    elseif _index == kAwakePositionSecond then
        index = 2
    else
        index = 3
    end
    return index
end














