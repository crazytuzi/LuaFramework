-- Filename：    DevelopCostLayer.lua
-- Author：      DJN
-- Date：        2015-7-26
-- Purpose：     武将进化消耗预览弹板 展示单个武将的

module ("DevelopCostLayer", package.seeall)
require "script/libs/LuaCCLabel"
-- require "script/ui/main/MainScene"
-- require "script/utils/BaseUI"
-- require "script/ui/develop/DevelopData"

local _touchPriority    
local _zOrder
local _bgLayer              --背景层
local _newhtid                  --橙将htid
local _oldHtid              --紫将htid
local kBgNodeHeight = 700--g_winSize.height/g_fScaleX - 40/g_fScaleX
local kAdaptiveSize = CCSizeMake(640, g_winSize.height/g_fScaleX)
local kScrollBgSize = CCSizeMake(249, kBgNodeHeight-650)
local kScrollSize = CCSizeMake(249, kScrollBgSize.height-20)
local LEFTCARD = 1001
local RIGHTCARD = 1002

----------------------------------------初始化函数----------------------------------------
local function init()
    _touchPriority = nil
    _zOrder = nil
    _bgLayer = nil
    _newhtid = nil
    _oldHtid = nil
end

----------------------------------------触摸事件函数----------------------------------------
local function onTouchesHandler(eventType,x,y)
    if (eventType == "began") then
        return true
    elseif (eventType == "moved") then
        --print("moved")
    else
        --print("end")
    end
end

local function onNodeEvent(event)
    if event == "enter" then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
        _bgLayer:setTouchEnabled(true)
    elseif eventType == "exit" then
        _bgLayer:unregisterScriptTouchHandler()
    end
end

----------------------------------------回调函数----------------------------------------


--[[
    @des    :关闭按钮回调
    @param  :
    @return :
--]]
function closeCallBack()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
end

--[[
    @desc : 创建属性面板
    @param: p_dataTable 由方法DevelopData.getCurHeroInfo()和DevelopData.getCurDevelopInfo()获得
            p_state int 1是创建紫卡的 2是创建橙卡的 
    @ret  : 
--]]
function createAttrPanel(p_dataTable, p_state)
    p_state =tonumber(p_state)
    local labelColor = p_state == 2 and ccc3(0x00,0xff,0x18) or ccc3(0xff,0xff,0xff)
    local scrollBg = CCScale9Sprite:create("images/develop/scroll_bg.png")
    scrollBg:setPreferredSize(kScrollBgSize)

    local scroll = CCScrollView:create()
    scroll:setViewSize(kScrollSize)
    scroll:setDirection(kCCScrollViewDirectionVertical)
    scroll:setTouchPriority(_touchPriority-10)
    scroll:setBounceable(true)
    scroll:ignoreAnchorPointForPosition(false)
    scroll:setAnchorPoint(ccp(0.5,0.5))
    scroll:setPosition(kScrollBgSize.width*0.5, kScrollBgSize.height*0.5)
    scrollBg:addChild(scroll)

    --上下滚动箭头
    local arrowData = {
        [1] = {"images/common/arrow_up_h.png", ccp(0.5,1), ccp(kScrollSize.width-30,kScrollSize.height+12)},
        [2] = {"images/common/arrow_down_h.png", ccp(0.5,0), ccp(kScrollSize.width-30,12)},
    }
    local arrows = {}
    for i = 1, 2 do
        arrows[i] = CCSprite:create(arrowData[i][1])
        arrows[i]:setAnchorPoint(arrowData[i][2])
        arrows[i]:setPosition(arrowData[i][3])
        arrows[i]:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeOut:create(1),CCFadeIn:create(1))))
        arrows[i]:setVisible(false)
        scrollBg:addChild(arrows[i])
    end

    local updateArrow = function ()
        local offset =  scroll:getContentSize().height+ scroll:getContentOffset().y- scroll:getViewSize().height
        if(arrows[1]~= nil )  then
            if(offset>1) then
                arrows[1]:setVisible(true)
            else
                arrows[1]:setVisible(false)
            end
        end
        if(arrows[2] ~= nil) then
            if( scroll:getContentOffset().y <-1) then
                arrows[2]:setVisible(true)
            else
                arrows[2]:setVisible(false)
            end
        end
    end
    schedule(scrollBg, updateArrow, 1)

    local containerSize = CCSizeMake(kScrollSize.width,20)
    local container = CCLayer:create()
    container:setContentSize(containerSize)

    -- local bottomDesc = {GetLocalizeStringBy("zz_90"), GetLocalizeStringBy("zz_87")}
    -- if p_dataTable ~= nil and p_state == 2 then
    --  for k,v in ipairs(bottomDesc) do
    --      local label = CCLabelTTF:create(v, g_sFontName, 18)
    --      label:setColor(labelColor)
    --      label:setAnchorPoint(ccp(0.5,0))
    --      label:setPosition(kScrollSize.width*0.5,containerSize.height)
    --      container:addChild(label)
    --      containerSize.height = containerSize.height + label:getContentSize().height + 5
    --  end
    -- end
    -- containerSize.height = containerSize.height + 10

    --怒气技能和普通技能
    local angerSkillDesc = p_dataTable == nil and "?" or p_dataTable.angerSkill.skillName
    local normalSkillDesc = p_dataTable == nil and "?" or p_dataTable.normalSkill.skillName
    local fontName = p_dataTable == nil and g_sFontPangWa or g_sFontName
    local skillData = {
        [1] = {angerSkillDesc, "images/hero/info/anger.png", GetLocalizeStringBy("zz_54")},
        [2] = {normalSkillDesc, "images/hero/info/normal.png", GetLocalizeStringBy("zz_78")},
    }
    require "script/ui/replaceSkill/CreateUI"
    for i = 1,2 do
        local dimensions = CreateUI.getStringDimensions(skillData[i][1], 10, 18)
        local descLabel = CCLabelTTF:create(skillData[i][1], fontName, 18)
        descLabel:setColor(labelColor)
        descLabel:setDimensions(dimensions)
        descLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
        descLabel:setVerticalAlignment(kCCVerticalTextAlignmentTop)
        descLabel:setAnchorPoint(ccp(0,0))
        descLabel:setPosition(70, containerSize.height)
        container:addChild(descLabel)

        local iconBg = CCSprite:create(skillData[i][2])
        local size = iconBg:getContentSize()
        iconBg:setAnchorPoint(ccp(0,0.5))
        iconBg:setPosition(12, containerSize.height+dimensions.height-9)
        container:addChild(iconBg)

        local iconLabel = CCLabelTTF:create(skillData[i][3], g_sFontName, 25)
        iconLabel:setColor(ccc3(0xff,0xff,0xff))
        iconLabel:setAnchorPoint(ccp(0.5,0.5))
        iconLabel:setPosition(size.width*0.5, size.height*0.5)
        iconBg:addChild(iconLabel)

        containerSize.height = containerSize.height + dimensions.height + 18
    end

    --技能标题
    local skillTitleBg = CCSprite:create("images/hero/info/title_bg.png")
    local size = skillTitleBg:getContentSize()
    skillTitleBg:setAnchorPoint(ccp(0,0))
    skillTitleBg:setPosition(0,containerSize.height)
    container:addChild(skillTitleBg)
    containerSize.height = containerSize.height + size.height + 10

    local skillTitleLabel = CCLabelTTF:create(GetLocalizeStringBy("zz_79"), g_sFontName,25)
    skillTitleLabel:setColor(ccc3(0x00,0x00,0x00))
    skillTitleLabel:setAnchorPoint(ccp(0.5,0.5))
    skillTitleLabel:setPosition(size.width*0.5, size.height*0.5)
    skillTitleBg:addChild(skillTitleLabel)

    --"智慧","武力","统帅","资质"
    local intelligence = p_dataTable == nil and "?" or p_dataTable.intelligence
    local strength = p_dataTable == nil and "?" or p_dataTable.strength
    local command = p_dataTable == nil and "?" or p_dataTable.command
    local aptitude = p_dataTable == nil and "?" or p_dataTable.aptitude
    local attrData = {
        [1] = {intelligence, GetLocalizeStringBy("zz_80"),},
        [2] = {strength, GetLocalizeStringBy("zz_81"),},
        [3] = {command, GetLocalizeStringBy("zz_82"),},
        [4] = {aptitude, 0,},
    }
    for i = 1,4 do
        local descLabel = CCRenderLabel:create(attrData[i][1], g_sFontPangWa, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
        descLabel:setColor(labelColor)
        descLabel:setAnchorPoint(ccp(0,0))
        descLabel:setPosition(88, containerSize.height)
        container:addChild(descLabel)

        local attrNameLabel = nil
        if attrData[i][2] == 0 then
            attrNameLabel = CCSprite:create("images/hero/potential.png")
            attrNameLabel:setScale(0.85)
        else
            attrNameLabel = CCRenderLabel:create(attrData[i][2], g_sFontPangWa, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
            attrNameLabel:setColor(ccc3(0xff,0xff,0xff))
        end
        attrNameLabel:setAnchorPoint(ccp(0,0))
        attrNameLabel:setPosition(15, containerSize.height)
        container:addChild(attrNameLabel)

        containerSize.height = containerSize.height + descLabel:getContentSize().height + 8
    end

    --武将名字背景
    local heroNameBg = CCSprite:create("images/common/red_line.png")
    local heroNameBgSize = heroNameBg:getContentSize()
    heroNameBg:setScale(0.8)
    heroNameBg:setAnchorPoint(ccp(0.5,0))
    heroNameBg:setPosition(containerSize.width*0.5,containerSize.height)
    container:addChild(heroNameBg)
    containerSize.height = containerSize.height + heroNameBgSize.height

    --武将名字和进阶等级
    local heroName = ""
    local evolveLevel = ""
    local nameColor = ccc3(0x00,0xe4,0xff)
    if p_dataTable ~= nil then
        heroName = p_dataTable.heroName .. "   "
        evolveLevel = p_state == 2 and GetLocalizeStringBy("zz_99",p_dataTable.evolveLevel) or "+" .. p_dataTable.evolveLevel
        nameColor = HeroPublicLua.getCCColorByStarLevel(p_dataTable.star_lv)
    end
    local nameData = {
        [1] = {desc=heroName, color=nameColor},
        [2] = {desc=evolveLevel, color=ccc3(0x00,0xff,0x18)},
    }
    local nameTable = createLabel(nameData)
    nameTable.parent:setAnchorPoint(ccp(0.5,0.5))
    nameTable.parent:setPosition(heroNameBgSize.width*0.5, heroNameBgSize.height*0.5)
    nameTable.parent:setScale(1/0.8)
    heroNameBg:addChild(nameTable.parent)

    container:setContentSize(containerSize)
    scroll:setContainer(container)
    scroll:setContentOffset(ccp(0, kScrollSize.height-containerSize.height))
    --scroll:setContentSize(containerSize)
    return scrollBg
end

--[[
    @desc : 创建资源消耗列表
    @param: 
    @ret  : 
--]]
function createTable()
    --表格背景
    local tableBg = CCScale9Sprite:create("images/star/intimate/bottom9s.png")
    local tableBgSize = CCSizeMake(620,136)
    tableBg:setPreferredSize(tableBgSize)

    --左右箭头
    local arrowData = {
        [1] = {"images/pet/petfeed/btn_left.png", ccp(1,0.5), ccp(55, tableBgSize.height*0.5)},
        [2] = {"images/pet/petfeed/btn_right.png", ccp(0,0.5), ccp(tableBgSize.width-55, tableBgSize.height*0.5)},
    }
    for i = 1,2 do
        local arrow = CCSprite:create(arrowData[i][1])
        arrow:setAnchorPoint(arrowData[i][2])
        arrow:setPosition(arrowData[i][3])
        tableBg:addChild(arrow)
    end

    --表格
    
    if _costResource ~= nil then
        local tableView = CreateUI.createTableView(1, CCSizeMake(tableBgSize.width-130,115), CCSizeMake(100,115), #_costResource.cost, createCell)
        tableView:ignoreAnchorPointForPosition(false)
        tableView:setTouchPriority(_touchPriority - 10 )
        tableView:setAnchorPoint(ccp(0.5,0.5))
        tableView:setPosition(tableBgSize.width*0.5, tableBgSize.height*0.5)
        tableBg:addChild(tableView)
    end

    return tableBg
end

--[[
    @desc : 创建各个消耗资源的图标
    @param: 
    @ret  : 
--]]
function createIcon( p_index )
    local data = _costResource.cost[p_index]

    local icon = nil
    if data.type == DevelopData.kItemTag then
        icon = ItemSprite.getItemSpriteById(data.id,nil,nil,nil,_touchPriority+1)
    elseif data.type == DevelopData.kHeroTag then
        --icon = HeroUtil.getHeroIconByHTID(data.id)
        icon = ItemSprite.getHeroIconItemByhtid(data.id, _touchPriority+1)
    else

    end
    local size = icon:getContentSize()

    local numLabel = CCRenderLabel:create(data.hasNum .. "/" .. data.needNum, g_sFontName, 18, 1 , ccc3(0x00,0x00,0x00), type_shadow)
    local labelColor = data.hasNum >= data.needNum and ccc3(0x00,0xff,0x18) or ccc3(0xff,0x00,0x00)
    numLabel:setColor(labelColor)
    numLabel:setAnchorPoint(ccp(1,0))
    numLabel:setPosition(size.width, 0)
    icon:addChild(numLabel)

    local nameLabel = CCRenderLabel:create(data.name, g_sFontName, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
    nameLabel:setColor(data.nameColor)
    nameLabel:setAnchorPoint(ccp(0.5,1))
    nameLabel:setPosition(size.width*0.5,0)
    icon:addChild(nameLabel)

    return icon
end

--[[
    @desc : 创建表格单元
    @param: 
    @ret  : 
--]]
function createCell( p_index )
    local cell = CCTableViewCell:create()

    local icon = createIcon(p_index)
    icon:setAnchorPoint(ccp(0,0))
    icon:setPosition(0,20)
    cell:addChild(icon)

    return cell
end

--[[
    @desc : 创建标签:消耗银币
    @param: 
    @ret  : 
--]]
function createCostSliverLabel( ... )

    local richInfo = {elements = {},alignment = 2,defaultType = "CCRenderLabel"}
            richInfo.elements[1] = {
                    text = GetLocalizeStringBy("zz_89"),
                    color=ccc3(0xff,0xff,0xff),
                    font=g_sFontName,
                    size = 21
                    }
            richInfo.elements[2] = {
                    ["type"] = CCSprite,
                    image = "images/common/coin_silver.png"}
            richInfo.elements[3] = {
                    text = _costResource.template.costSilver or "000",
                    color=ccc3(0xff,0xff,0xff),
                    font=g_sFontName,
                    size = 21}       
    return LuaCCLabel.createRichLabel(richInfo)
end

--创建一个武将卡牌 带名字和进阶次数
function createCardNode(p_htid,p_cardType)
    --武将形象
    local heroNode = HeroPublicCC.createSpriteCardShow(p_htid)
    heroNode:setScale(0.58)

    --武将名字背景
    local heroNameBg = CCSprite:create("images/common/red_line.png")
    local heroNameBgSize = heroNameBg:getContentSize()
    heroNameBg:setScale(0.8/0.58)
    heroNameBg:setAnchorPoint(ccp(0.5,0))
    heroNameBg:setPosition(ccpsprite(0.5,-0.15,heroNode))
    heroNode:addChild(heroNameBg)
    local evolveLevel = ""
    local p_dataTable = HeroUtil.getHeroLocalInfoByHtid(p_htid)
    local p_level = 0
    if(p_cardType == RIGHTCARD)then
        p_level = 0
    elseif(p_cardType == LEFTCARD)then
        if(p_dataTable.star_lv == 5)then
            p_level = 7
        elseif(p_dataTable.star_lv == 6)then
            p_level = 5
        end

    end
    --武将名字和进阶等级
    local heroName = ""
    local nameColor = ccc3(0x00,0xe4,0xff)
    if p_dataTable ~= nil then
        heroName = p_dataTable.name .. "   "
        if (p_level == 0 or p_level == 5 ) then
            evolveLevel =  GetLocalizeStringBy("zz_99",p_level) 
        else
            evolveLevel = "+" .. p_level
        end
        nameColor = HeroPublicLua.getCCColorByStarLevel(p_dataTable.star_lv)
    end
    local nameData = {
        [1] = {desc=heroName, color=nameColor},
        [2] = {desc=evolveLevel, color=ccc3(0x00,0xff,0x18)},
    }
    local nameTable = createLabel(nameData)
    nameTable.parent:setAnchorPoint(ccp(0.5,0.5))
    nameTable.parent:setPosition(heroNameBgSize.width*0.5, heroNameBgSize.height*0.5)
    --nameTable.parent:setScale(1/0.8)
    heroNameBg:addChild(nameTable.parent)

    return heroNode
end
function createLabel( p_table )
    local labelTable = {parent = CCNode:create(), children = {}}
    print("createLabel")
    print_t(p_table)

    local node = labelTable.parent
    local contentSize = CCSizeMake(0,21)
    for _,v in ipairs(p_table) do
        local font = v.font or g_sFontPangWa
        local label = CCRenderLabel:create(v.desc, font, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
        label:setColor(v.color)
        label:setAnchorPoint(ccp(0,0))
        label:setPosition(contentSize.width,0)
        node:addChild(label)
        contentSize.width = contentSize.width + label:getContentSize().width
        table.insert(labelTable.children, label)
    end
    node:setContentSize(contentSize)

    return labelTable
end
----------------------------------------UI函数----------------------------------------
--[[
    @des    :创建UI
    @param  :
    @return :
--]]
function createUI()
    local fullRect = CCRectMake(0,0,640,51)
    local insetRect = CCRectMake(314,27,13,6)
    local bgNode = CCScale9Sprite:create("images/god_weapon/view_bg.png",fullRect, insetRect)
    bgNode:setContentSize(CCSizeMake(640,kBgNodeHeight))

    bgNode:setAnchorPoint(ccp(0.5,0.5))
    bgNode:setScale(g_fScaleX)
    bgNode:setPosition(ccpsprite(0.5,0.5,_bgLayer))
    _bgLayer:addChild(bgNode)
    local titleSp = CCSprite:create("images/hero/develop_title.png")
    titleSp:setAnchorPoint(ccp(0.5,0.7))
    titleSp:setPosition(ccpsprite(0.5,1,bgNode))
    bgNode:addChild(titleSp)

    local rightCard = createCardNode(_newhtid,RIGHTCARD )    
    rightCard:setAnchorPoint(ccp(0,1))
    rightCard:setPosition(ccpsprite(0.6,0.9,bgNode))
    bgNode:addChild(rightCard)


    local leftCard = createCardNode(_oldHtid,LEFTCARD)
    leftCard:setAnchorPoint(ccp(0,1))
    leftCard:setPosition(ccpsprite(0.1, 0.9,bgNode))
    bgNode:addChild(leftCard)

    -- local leftAttrData = DevelopData.getPreviewHeroInfo(_oldHtid,7)
    -- local leftAttrLabel = createAttrPanel(leftAttrData,1)
    -- leftAttrLabel:setAnchorPoint(ccp(0,0))
    -- bgNode:addChild(leftAttrLabel)
    -- leftAttrLabel:setPosition(ccp(20,285))

    -- local rightAttrData = DevelopData.getPreviewHeroInfo(_newhtid,0)
    -- local rightAttrLabel = createAttrPanel(rightAttrData,2)
    -- rightAttrLabel:setAnchorPoint(ccp(1,0))
    -- bgNode:addChild(rightAttrLabel)
    -- rightAttrLabel:setPosition(ccp(620,285))
    
    --右箭头
    local batchNode = CCSprite:create("images/hero/transfer/arrow.png")
    batchNode:setAnchorPoint(ccp(0.5,0.5))
    batchNode:setScale(0.6)
    batchNode:setPosition(ccpsprite(0.5, 0.7,bgNode))
    bgNode:addChild(batchNode)
    
    --"进化所需材料"
    local needMaterialLabel = CCRenderLabel:create(GetLocalizeStringBy("zz_83"), g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
    needMaterialLabel:setColor(ccc3(0xff,0xe4,0x00))
    needMaterialLabel:setAnchorPoint(ccp(0,0))
    needMaterialLabel:setPosition(ccp(34,265))
    bgNode:addChild(needMaterialLabel)

    --所需材料的展示列表
  
    local materialTableBg = createTable()
    materialTableBg:setAnchorPoint(ccp(0.5,1))
    materialTableBg:setPosition(ccp(320,260))
    bgNode:addChild(materialTableBg)
   

    --消耗银币
    local silverTable = createCostSliverLabel()
    silverTable:setAnchorPoint(ccp(0.5,0))
    silverTable:setPosition(ccp(320,95))
    bgNode:addChild(silverTable)

    --关闭按钮
    local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority-1)
    bgNode:addChild(bgMenu)
   
    --关闭按钮
    local colseMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1284"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    colseMenuItem:setAnchorPoint(ccp(0.5,0))
    colseMenuItem:setPosition(ccp(320,20))
    colseMenuItem:registerScriptTapHandler(closeCallBack)
    bgMenu:addChild(colseMenuItem)
end

----------------------------------------入口函数----------------------------------------
function showLayer(p_htid,p_touchPriority,p_zOrder)
    init()
    _newhtid = p_htid
    _touchPriority = p_touchPriority or -600
    _zOrder = p_zOrder or 1000
    local heroInfo =  HeroUtil.getHeroLocalInfoByHtid(_newhtid)
    if heroInfo then
        if(heroInfo.star_lv == 6)then
            _oldHtid = heroInfo.model_id
        elseif(heroInfo.star_lv == 7)then
             _oldHtid = heroInfo.red_ID
        end
    else
        return
    end
    _costResource = DevelopData.getPreviewCostResource(_oldHtid)
    _bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
    _bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder)

    --创建UI层
    createUI()
end
