-- FileName: PetAdvanceLayer.lua
-- Author: shengyixian
-- Date: 2016-02-02
-- Purpose: 宠物进阶
module("PetAdvanceLayer",package.seeall)

local _layer = nil
local _heroInfoPanel = nil
local _touchPriority = nil
local _scrollView = nil
local _scrollSize = nil
local _middleUIPosY = nil
-- 进阶按钮
local _advanceBtn = nil
-- 宠物属性背景
local _attrSp = nil
local _touchBeganPos = nil
local _tabBg = nil
local _curLv = nil
local _nameBg = nil
local _nameLabel = nil
local _advanceLvLabel = nil
local _lvLabel = nil
local _petInfoAry = nil
local _curPetInfo = nil
function init( ... )
	-- body
	_layer = nil
	_heroInfoPanel = nil
    _touchPriority = nil
	_scrollView = nil
	_scrollSize = CCSizeMake(640, 265)
    _touchBeganPos = nil
    _advanceBtn = nil
    _attrSp = nil
    _middleUIPosY = nil
    _tabBg = nil
    _itemTableView = nil
    _curLv = nil
    _nameBg = nil
    _nameLabel = nil
    _advanceLvLabel = nil
    _lvLabel = nil
    _petInfoAry = nil
    _curPetInfo = nil
end

function createLayer( ... )
	-- body
	_layer = CCLayer:create()
	_layer:setContentSize(_layerSize)
	_layer:registerScriptHandler(onNodeHandler)
	local bg = CCSprite:create("images/pet/pet_bg_2.jpg")
	bg:setScale(g_fBgScaleRatio)
    bg:setAnchorPoint(ccp(0.5,1))
    bg:setPosition(ccpsprite(0.5,1.1,_layer))
	_layer:addChild(bg)
    createTopUI()
    createMiddleUI()
    createButtomUI()
	return _layer
end

function showLayer( pPetId,pTouchPriority,pZOrder )
	-- body
	init()
	_curPetIndex = PetData.getEvolvePetIndex(pPetId) or 1
    _petInfoAry = PetData.getIsEvolvePetInfo()
    _curPetInfo = _petInfoAry[_curPetIndex]
	_touchPriority = pTouchPriority or -380
	pZOrder = pZOrder or 600
	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
    local menuLayerSize = MenuLayer.getLayerContentSize()
	_layerSize = CCSizeMake(0,0)
	_layerSize.width= g_winSize.width 
	_layerSize.height = g_winSize.height - (bulletinLayerSize.height + menuLayerSize.height) * g_fScaleX
	local layer = createLayer()
	layer:setPosition(ccp(0,menuLayerSize.height * g_fScaleX))
	MainScene.changeLayer(layer,"PetAdvanceLayer")
end

function createTopUI( ... )
	-- body
	local bulletinLayerSize = BulletinLayer.getLayerFactSize()
	createHeroInfoPanel()
	-- 上面的花边
    local border_filename = "images/recharge/mystery_merchant/border.png"
    local border_top = CCSprite:create(border_filename)
    border_top:setAnchorPoint(ccp(0, 0))
    border_top:setScale(g_fBgScaleRatio)
    border_top:setScaleY(-g_fBgScaleRatio)
    border_top:setVisible(false)
    local border_top_y = _layerSize.height - _heroInfoPanel:getContentSize().height * g_fBgScaleRatio
    border_top:setPosition(0, border_top_y)
    _layer:addChild(border_top)
    _middleUIPosY = border_top_y - border_top:getContentSize().height * g_fBgScaleRatio
    local titleSp = CCSprite:create("images/pet/evolve/evolve_title.png")
    titleSp:setAnchorPoint(ccp(0.5,1))
    titleSp:setPosition(ccp(_layerSize.width * 0.5,_layerSize.height - (_heroInfoPanel:getContentSize().height + 18) * g_fScaleX))
    titleSp:setScale(g_fScaleX)
    _layer:addChild(titleSp)
    local desSp = CCSprite:create("images/pet/evolve/evolve_say.png")
    desSp:setAnchorPoint(ccp(0.5,1))
    desSp:setPosition(ccpsprite(0.5,-0.2,titleSp))
    titleSp:addChild(desSp)
    -- 返回按钮
    local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(_touchPriority - 10)
	_layer:addChild(menu)
	local backItem = CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
	backItem:setScale(MainScene.elementScale * 0.9)
    backItem:registerScriptTapHandler(closeBtnHandler)
    backItem:setScale(MainScene.elementScale)
    backItem:setAnchorPoint(ccp(0,1))
    backItem:setPosition(ccp(_layerSize.width - 100 * MainScene.elementScale, _layerSize.height - (_heroInfoPanel:getContentSize().height + 10) * g_fScaleX))
	menu:addChild(backItem)
end

function createHeroInfoPanel( ... )
    if _heroInfoPanel then
        _heroInfoPanel:removeFromParentAndCleanup(true)
        _heroInfoPanel = nil
    end
    _heroInfoPanel = PetUtil.createHeroInfoPanel()
    _heroInfoPanel:setAnchorPoint(ccp(0,1))
    _heroInfoPanel:setPosition(ccp(0,_layerSize.height))
    _heroInfoPanel:setScale(g_fScaleX)
    _layer:addChild(_heroInfoPanel)
end

function onNodeHandler( eventType )
    -- body
    if eventType == "enter" then
        _layer:registerScriptTouchHandler(function ( eventType )
            -- body
            if eventType == "began" then
                return true
            end
        end,false,_touchPriority,true)
        _layer:setTouchEnabled(true)
    elseif eventType == "exit" then
        _layer:unregisterScriptTouchHandler()
    end
end

function onTouchHandler( eventType,x,y )
    if eventType == "began" then
        _touchBeganPos = ccp(x,y)
        local beganInNodePos = _scrollView:convertToNodeSpace(ccp(x,y))
        if x > 0 and x < _scrollSize.width * g_fScaleX and beganInNodePos.y > 0 and beganInNodePos.y < _scrollSize.height then
            return true
        end
    elseif eventType == "moved" then
        _scrollView:setContentOffset(ccp(x - _touchBeganPos.x - (_curPetIndex-1) * _scrollSize.width, 0))
    else
        -- local feededPetInfo = PetData.getIsEvolvePetInfo()
        local xOffset = x - _touchBeganPos.x
        if xOffset < -20 * g_fScaleX then
            setCurPetIndex(_curPetIndex + 1)
        elseif xOffset > 20 * g_fScaleX then
            setCurPetIndex(_curPetIndex - 1)
        end
        _scrollView:setContentOffsetInDuration(ccp(-(_curPetIndex -1)*_scrollSize.width, 0),0.2)
    end
end

function createMiddleUI( ... )
    -- body
    createScrollView()
    -- local petInfo = PetData.getIsEvolvePetInfo()[_curPetIndex]
    -- 名字的背景
    local fullRect = CCRectMake(0,0,111,32)
    local insetRect = CCRectMake(39,15,2,2)
    _nameBg= CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
    _nameBg:setPreferredSize(CCSizeMake(245,35))
    _nameBg:setScale(g_fBgScaleRatio)
    _nameBg:setAnchorPoint(ccp(0.5,0))
    _nameBg:setPosition(_layerSize.width * 0.5 , _scrollView:getPositionY() - _scrollView:getContentSize().height * g_fBgScaleRatio)
    _layer:addChild(_nameBg,17)
    _nameLabel = CCRenderLabel:create(_curPetInfo.petDesc.roleName,g_sFontPangWa,25,1,ccc3(0,0,0),type_shadow)
    -- _nameLabel= CCLabelTTF:create(petInfo.petDesc.roleName,g_sFontPangWa,25 )
    _nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(_curPetInfo.petDesc.quality))
    _nameLabel:setAnchorPoint(ccp(0.5,0))
    _nameLabel:setPosition(ccpsprite(0.5,0,_nameBg))
    _nameBg:addChild(_nameLabel)
    _advanceLvLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1089",_curLv),g_sFontPangWa,21,1,ccc3(0,0,0),type_shadow)
    -- _advanceLvLabel = CCLabelTTF:create(GetLocalizeStringBy("syx_1089",_curLv),g_sFontPangWa,25 )
    _advanceLvLabel:setColor(ccc3(0xff,0xf6,0x00))
    _advanceLvLabel:setAnchorPoint(ccp(0,0.5))
    _advanceLvLabel:setPosition(ccpsprite(1.1,0.5,_nameLabel))
    _nameLabel:addChild(_advanceLvLabel)
    local lvSp= CCSprite:create("images/common/lv.png")
    lvSp:setAnchorPoint(ccp(0,0))
    lvSp:setPosition(ccpsprite(-0.05,0.2,_nameBg))
    _nameBg:addChild(lvSp)
    _lvLabel= CCLabelTTF:create(_curPetInfo.level,g_sFontPangWa, 21)-- 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _lvLabel:setColor(ccc3(0xff,0xf6,0x00))
    _lvLabel:setAnchorPoint(ccp(0,0.5))
    _lvLabel:setPosition(ccpsprite(1,0.5,lvSp))
    lvSp:addChild(_lvLabel)
end

function createScrollView( ... )
	-- body
    local evolvePetInfo = PetData.getIsEvolvePetInfo()
    -- print(12345,_curPetIndex)
    -- print_t(evolvePetInfo)
    _curLv = tonumber(evolvePetInfo[_curPetIndex].va_pet.evolveLevel) or 0
    _scrollView= CCScrollView:create()
    _scrollView:setViewSize(CCSizeMake(_scrollSize.width,_scrollSize.height))
    _scrollView:setContentSize(CCSizeMake(_scrollSize.width * table.count(evolvePetInfo), _scrollSize.height ))
    _scrollView:setContentOffset(ccp(0,0))
    _scrollView:setScale(g_fBgScaleRatio)
    _scrollView:setAnchorPoint(ccp(0,1))
    _scrollView:ignoreAnchorPointForPosition(false)
    _scrollView:setDirection(kCCScrollViewDirectionHorizontal)
    _scrollView:setPosition((_layerSize.width - _scrollSize.width*g_fBgScaleRatio)/2,_middleUIPosY)
    _layer:addChild(_scrollView,11)
    local scrollLayer = CCLayer:create()
    scrollLayer:setContentSize( CCSizeMake( _scrollSize.width*table.count(evolvePetInfo), _scrollSize.height ))
    _scrollView:setContainer(scrollLayer)
    for i,petInfo in ipairs(evolvePetInfo) do
        local petTid = nil 
        local petDb = nil
        if(petInfo.petDesc) then 
            petTid= petInfo.petDesc.id
            petDb = DB_Pet.getDataById(petTid)
        end
        local showStatus=  petInfo.showStatus
        local slotIndex= i
        local petSprite =  PetUtil.getPetIMGById(petTid ,showStatus, slotIndex)
        petSprite:setAnchorPoint(ccp(0.5,0))
        local offsetY = 0
        if petDb ~= nil then
            offsetY = petDb.Offset or 0
            if tonumber(offsetY) == 98 or tonumber(offsetY) == 95 then
                offsetY = 40
            end
        end
        petSprite:setPosition(ccp(_scrollSize.width*(i-0.5) , 25 - offsetY))
        petSprite:setScale(0.55)
        scrollLayer:addChild(petSprite,1)
    end
    _scrollView:setContentOffset(ccp(-(_curPetIndex -1)*_scrollSize.width , 0))
end

function createButtomUI( ... )
	-- body
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_touchPriority - 10)
    _layer:addChild(menu)
    _advanceBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(190,75),GetLocalizeStringBy("key_2082"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _advanceBtn:setAnchorPoint(ccp(0.5,0))
    _advanceBtn:setPosition(_layerSize.width*0.5,7 * g_fElementScaleRatio )
    _advanceBtn:registerScriptTapHandler(advanceCallBack)
    _advanceBtn:setScale(MainScene.elementScale)
    menu:addChild(_advanceBtn)
    _tabBg = CCScale9Sprite:create("images/common/bg/astro_btnbg.png")
    _tabBg:setContentSize(CCSizeMake(610 * g_fScaleX / g_fScaleY,108))
    _tabBg:setAnchorPoint(ccp(0.5,0))
    _tabBg:setPosition(ccp(_layer:getContentSize().width/2,_advanceBtn:getPositionY()+(_advanceBtn:getContentSize().height)*g_fElementScaleRatio - 5 * g_fElementScaleRatio))
    _tabBg:setScale(g_fScaleY)
    _layer:addChild(_tabBg)
    -- 向左的箭头
    _upArrowSp = CCSprite:create("images/common/arrow_left.png")
    _upArrowSp:setPosition(0, _tabBg:getContentSize().height / 2)
    _upArrowSp:setAnchorPoint(ccp(0,0.5))
    _tabBg:addChild(_upArrowSp,1, 101)
    -- _upArrowSp:setVisible(false)
    _upArrowSp:setVisible(true)
    -- 向右的箭头
    _downArrowSp = CCSprite:create( "images/common/arrow_right.png")
    _downArrowSp:setPosition(_tabBg:getContentSize().width, _tabBg:getContentSize().height / 2)
    _downArrowSp:setAnchorPoint(ccp(1,0.5))
    _tabBg:addChild(_downArrowSp,1, 102)
    _downArrowSp:setVisible(true)

    arrowAction(_downArrowSp)
    arrowAction(_upArrowSp)

    createItemTableview()
    createPetAttrInfoArea()
end
function advanceCallBack( ... )
    -- body
    local evolvePetInfo = PetData.getIsEvolvePetInfo()[_curPetIndex]
    local callBack = function ( ... )
        -- body
        -- 创建屏蔽层
        local runningScene = CCDirector:sharedDirector():getRunningScene()
        local maskLayer = BaseUI.createMaskLayer(-5000,nil,nil,0)
        runningScene:addChild(maskLayer,10000)
        -- 特效
        local successLayerSp = XMLSprite:create("images/base/effect/hero/transfer/zhuangchang")
        successLayerSp:setPosition(ccp((g_winSize.width-320*2*g_fElementScaleRatio)/2,g_winSize.height))
        successLayerSp:setScale(g_fElementScaleRatio)
        local runningScene = CCDirector:sharedDirector():getRunningScene()
        runningScene:addChild(successLayerSp,9999)
        -- 特效播放结束后
        local animationEnd = function()
            successLayerSp:removeFromParentAndCleanup(true)
            successLayerSp = nil
            -- 干掉屏蔽层
            if( maskLayer ~= nil )then
                maskLayer:removeFromParentAndCleanup(true)
                maskLayer = nil
            end
            -- 弹出成功界面
            require "script/ui/pet/advance/PetEvolveSuccessLayer"
            PetEvolveSuccessLayer.showLayer(tonumber(evolvePetInfo.petid))
        end
        successLayerSp:registerEndCallback( animationEnd )
    end
    PetController.evolve(evolvePetInfo.petid,callBack)
end

--[[
    @des    : 创建升级所需物品tableview
    @param  : 
    @return : 
--]]
function createItemTableview( ... )
    -- tableview BG
    if (_itemTableView) then
        _itemTableView:removeFromParentAndCleanup(true)
        _itemTableView = nil
    end
    local tableViewSize = CCSizeMake(600,108)
    local cellSize = CCSizeMake(150,108)
    local evolvePetInfo = PetData.getIsEvolvePetInfo()
    local petInfo = evolvePetInfo[_curPetIndex]
    local dataStrAry = PetData.getAdvanceCostByLevel(tonumber(petInfo.petDesc.id),_curLv + 1)
    -- local itemsStr = TallyMainData.getDevCostTabByLv(_curTallyTid,_curLv+1)
    local data = ItemUtil.getItemsDataByStr(dataStrAry)
    local dataLen = table.count(data)
    local luaHandler = LuaEventHandler:create(function(fn,t,a1,a2)
        local ret
        if fn == "cellSize" then
            ret = cellSize
        elseif fn == "cellAtIndex" then
            ret = createItemTableviewCell(data[a1+1])
        elseif fn == "numberOfCells" then
            ret = dataLen
        elseif fn == "cellTouched" then
        end
        return ret
    end)
    _itemTableView = LuaTableView:createWithHandler(luaHandler,tableViewSize)
    _itemTableView:setTouchPriority(_touchPriority-10)
    _itemTableView:setBounceable(true)
    _itemTableView:setDirection(kCCScrollViewDirectionHorizontal)
    _itemTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _itemTableView:setAnchorPoint(ccp(0,0))
    _itemTableView:setPosition(ccp(5,4))
    _tabBg:addChild(_itemTableView)
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
    @des    :设置当前宠物的索引变量
    @param  :
    @return :
--]]
function setCurPetIndex( pValue )
    if pValue > table.count(_petInfoAry) then
        pValue = table.count(_petInfoAry)
    elseif pValue < 1 then
        pValue = 1
    end
    if _curPetIndex ~= pValue then
        _curPetIndex = pValue
        _curPetInfo = _petInfoAry[_curPetIndex]
        _nameLabel:setString(_curPetInfo.petDesc.roleName)
        _nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(_curPetInfo.petDesc.quality))
        _curLv = _curPetInfo.va_pet.evolveLevel or 0
        _advanceLvLabel:setString(GetLocalizeStringBy("syx_1089",_curLv))
        _advanceLvLabel:setPosition(ccpsprite(1.1,0.5,_nameLabel))
        createPetAttrInfoArea(_curPetInfo)
        createItemTableview()
        _lvLabel:setString(_curPetInfo.level)
    end
end

--[[
    @des    : 创建升级所需物品tableviewcell
    @param  : 
    @return : 
--]]
function createItemTableviewCell( pData )
    local cell = CCTableViewCell:create()
    cell:setContentSize(CCSizeMake(120,120))
    local itemSp = ItemUtil.createGoodsIcon(pData,_touchPriority - 1,1234,-555,nil,nil,false,true,false)
    itemSp:setAnchorPoint(ccp(0.5,0.5))
    itemSp:setPosition(ccp(cell:getContentSize().width/2,cell:getContentSize().height/2 + 8))
    cell:addChild(itemSp)
    local numLabel = CCRenderLabel:create((pData.num/ 10000)..GetLocalizeStringBy("key_2593"),g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
    numLabel:setAnchorPoint(ccp(1,0))
    local numLabelColor = ccc3(0x00,0xff,0x18)
    if  pData.type == "silver" then
        if pData.num > UserModel.getSilverNumber() then
            numLabelColor = ccc3(0xff,0x00,0x00)
        end
    elseif pData.type == "item" then
        local itemNum = ItemUtil.getCacheItemNumBy(pData.tid)
        if pData.num > itemNum then
            numLabelColor = ccc3(0xff,0x00,0x00)
        end
        numLabel:setString(itemNum.."/"..pData.num)
    end
    local itemSpSize = itemSp:getContentSize().width
    numLabel:setColor(numLabelColor)
    numLabel:setPosition(ccp(itemSpSize - 3,3))
    itemSp:addChild(numLabel)
    cell:setScale(0.9)
    return cell
end

function createPetAttrInfoArea(  )
    -- body
    if _attrSp then
        _attrSp:removeFromParentAndCleanup(true)
        _attrSp = nil
    end
    _attrSp = CCSprite:create()
    -- _attrSp:setAnchorPoint(ccp(0,0))
    local evolvePetInfo = PetData.getIsEvolvePetInfo()
    -- local curSkillProperty = PetData.getPetEvolveAttrByLv(tonumber(evolvePetInfo[_curPetIndex].petid),_curLv)
    local curAttrColor = ccc3(0xff,0xff,0xff)
    -- 品阶颜色
    local curLvColor = ccc3(0xff,0xf6,0x00)
    local curPetAttrSp = PetUtil.createPetAttrInfoPanel(evolvePetInfo[_curPetIndex],curAttrColor,_curLv,curLvColor)
    -- curPetAttrSp:setAnchorPoint(ccp(0,1))
    _attrSp:setContentSize(CCSizeMake(640 * g_fScaleX / g_fScaleY,164))
    -- _attrSp:setPosition(ccp(0,_scrollView:getPositionY() - _scrollView:getContentSize().height * g_fScaleX - 75 * g_fScaleX))
    local spaceSize = _scrollView:getPositionY() - _scrollView:getContentSize().height * g_fBgScaleRatio - (_tabBg:getPositionY() + _tabBg:getContentSize().height * g_fScaleY)
    local offsetY = spaceSize - 140 * g_fScaleY
    _attrSp:setPosition(ccp(0,_tabBg:getPositionY() + _tabBg:getContentSize().height * g_fScaleY + offsetY / 3))
    _attrSp:setScale(g_fScaleY)
    _layer:addChild(_attrSp)
    curPetAttrSp:setPosition(ccp(50 * g_fScaleX / g_fScaleY,0))
    _attrSp:addChild(curPetAttrSp)
    -- 箭头
    local arrow = CCSprite:create("images/hero/transfer/arrow.png")
    arrow:setAnchorPoint(ccp(0.5,0.5))
    arrow:setPosition(ccp(_attrSp:getContentSize().width / 2,_attrSp:getContentSize().height/2))
    arrow:setScale(0.4)
    _attrSp:addChild(arrow)
    -- local nextAttr = PetData.getPetEvolveAttrByLv(tonumber(evolvePetInfo[_curPetIndex].petid),_curLv + 1)
    if tonumber(_curLv) >= PetData.getMaxEvolveLevel(evolvePetInfo[_curPetIndex]) then
        return 
    end
    local nextAttrColor = ccc3(0x00,0xff,0x18)
    local nextLvColor = ccc3(0xff,0xf6,0x00)
    local nextPetAttrSp = PetUtil.createPetAttrInfoPanel(evolvePetInfo[_curPetIndex],nextAttrColor,_curLv + 1,nextLvColor)
    nextPetAttrSp:setAnchorPoint(ccp(1,0))
    nextPetAttrSp:setPosition(ccp(590 * g_fScaleX / g_fScaleY,0))
    _attrSp:addChild(nextPetAttrSp)
end

function closeBtnHandler( ... )
	if not tolua.isnull(_layer) then
		_layer:removeFromParentAndCleanup(true)
		_layer = nil
		require "script/ui/pet/PetMainLayer"
    	local layer = PetMainLayer.createLayer(PetMainLayer.getCurPetIndex())
    	MainScene.changeLayer(layer,"PetMainLayer")
	end
end