-- Filename：	PetSelFormatLayer.lua
-- Author：		zhz
-- Date：		2014-4-10
-- Purpose：		选择宠物上阵的layer

module("PetSelFormatLayer", package.seeall)


require "script/model/user/UserModel"
require "script/utils/BaseUI"
require "script/ui/main/BulletinLayer"
require "script/ui/main/MainScene"
require "script/ui/main/MenuLayer"
require "script/ui/pet/PetData"
require "script/ui/pet/PetSelFormatCell"

local _bgLayer
local _layerSize     
local _pos              --$pos 开启的位置

local function init()
	_bgLayer 	        = nil
    _layerSize          = nil   
    _menuBag            = nil
    _menuFrag           = nil
end


local function closeAction( ... )
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

    require "script/ui/pet/PetMainLayer"
    local layer = PetMainLayer.createLayer(_pos)
    MainScene.changeLayer(layer,"PetMainLayer")
    -- _bgLayer:removeFromParentAndCleanup(true)
    -- _bgLayer = nil 
end

-- 创建标题面板
local function createTitleLayer( )

    -- 标题背景底图
    _topTitleSprite = CCSprite:create("images/hero/select/title_bg.png")
    _topTitleSprite:setScale(g_fScaleX)
    -- 加入背景标题底图进层
    -- 标题
    local ccSpriteTitle = CCSprite:create("images/pet/pet/choose_pet.png")
    ccSpriteTitle:setPosition(ccp(45, 50))
    _topTitleSprite:addChild(ccSpriteTitle)

    local tItems = {
        {normal="images/common/close_btn_n.png", highlighted="images/common/close_btn_h.png", pos_x=493, pos_y=40, cb=closeAction},
    }
    local menu = LuaCC.createMenuWithItems(tItems)
    menu:setPosition(ccp(0, 0))
    menu:setTouchPriority(-432)
    _topTitleSprite:addChild(menu)

    _topTitleSprite:setPosition(0, _layerSize.height)
    _topTitleSprite:setAnchorPoint(ccp(0, 1))
    _bgLayer:addChild(_topTitleSprite)
end

function getFormationAndSort()
    require "script/ui/pet/PetData"
    local petData = PetData.getPetCanFormation()
    require "db/DB_Pet"

    local function sort(w1, w2)
        local petData1 = DB_Pet.getDataById(w1.pet_tmpl)
        local petData2 = DB_Pet.getDataById(w2.pet_tmpl)
        if tonumber(petData1.quality) < tonumber(petData2.quality) then
            return true
        elseif tonumber(petData1.quality) == tonumber(petData2.quality) then
            if tonumber(w1.level) < tonumber(w2.level) then
                return true
            elseif tonumber(w1.level) == tonumber(w2.level) then
                if tonumber(w1.petid) < tonumber(w2.petid) then
                    return true
                else
                    return false
                end
            end
        else 
            return false
        end
    end

    table.sort(petData, sort)

    return petData
end

-- 创建TableView  
function createTableView()
    _formatPetData = getFormationAndSort()

    print(" _formatPetData  is : ")
    print_t(_formatPetData)

    local cellSize = CCSizeMake(640*g_fScaleX,210*g_fScaleX)
    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = CCSizeMake(cellSize.width, cellSize.height)
        elseif fn == "cellAtIndex" then
            a2 = PetSelFormatCell.createCell(_formatPetData[a1 + 1], _pos,a1+1)
            a2:setScale(g_fScaleX)
            r = a2
        elseif fn == "numberOfCells" then
            r = #_formatPetData
        elseif fn == "cellTouched" then
            
        elseif (fn == "scroll") then
            
        end
        return r
    end)
    local height = _layerSize.height- (_topTitleSprite:getContentSize().height - 12)*(_topTitleSprite:getScale())
    _myTableView = LuaTableView:createWithHandler(h, CCSizeMake(_layerSize.width,height))
    _myTableView:setAnchorPoint(ccp(0,0))
    _myTableView:setBounceable(true)
    -- _myTableView:setScale(g_fScaleX)
    _myTableView:setTouchPriority(-300)
    _myTableView:setPosition(ccp(0, 5))
    _myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _bgLayer:addChild(_myTableView, 9)

    -- local maxAnimateIndex = visiableCellNum
    -- if (visiableCellNum > #curData) then
    --  maxAnimateIndex = #curData
    -- end
    -- for i=1, maxAnimateIndex do
    --  local itemCell = myTableView:cellAtIndex( #curData -i )
    --  if (itemCell) then
    --      ItemCell.startItemCellAnimate(itemCell, i)
    --  end
    -- end
end



function createLayer( pos)
	
    init()

    _bgLayer = CCLayer:create()
    _pos= pos or 0

    local bg = CCSprite:create("images/main/module_bg.png")
    bg:setScale(g_fBgScaleRatio)
    _bgLayer:addChild(bg)

    require "script/ui/main/BulletinLayer"
    require "script/ui/main/MainScene"
    require "script/ui/main/MenuLayer"
    local bulletinLayerSize = BulletinLayer.getLayerContentSize()
    local menuLayerSize = MenuLayer.getLayerContentSize()
    
    MainScene.getAvatarLayerObj():setVisible(false)
    MenuLayer.getObject():setVisible(true)
    BulletinLayer.getLayer():setVisible(true)

    _layerSize = {width= 0, height=0}
    _layerSize.width= g_winSize.width 
    _layerSize.height =g_winSize.height - (bulletinLayerSize.height+menuLayerSize.height)*g_fScaleX

    _bgLayer:setContentSize(CCSizeMake(_layerSize.width, _layerSize.height))
    _bgLayer:setPosition(ccp(0, menuLayerSize.height*g_fScaleX))

    createTitleLayer()
    createTableView()

    local label = CCRenderLabel:create(GetLocalizeStringBy("key_2913"), g_sFontPangWa , 26, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    label:setPosition(_layerSize.width*0.5, _layerSize.height*0.5 )
    label:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(label)

    -- local item = getFirstFormatPet()
    -- print("item:getPositionY()  ", item:getPositionY() )

    local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
            addGuidePetGuide3()
    end))
    _bgLayer:runAction(seq)



    
    return _bgLayer
end




----------------------------------- 新手引导 获得第一个宠物的cell----------------------------------
--得到第一个上阵宠物的按钮
function getFirstFormatPet( )
    local petid = tonumber( _formatPetData[1].petid)
    print("_formatPetData[1].petid is ", _formatPetData[1].petid)

    local curCell = tolua.cast(_myTableView:cellAtIndex(0),"CCTableViewCell")
    local menu= tolua.cast( curCell:getChildByTag(101):getChildByTag(9898) ,"CCMenu" )
    local item = tolua.cast(menu:getChildByTag(petid), "CCMenuItemImage")
    return item

end


function addGuidePetGuide3( ... )
    require "script/guide/NewGuide"
    require "script/guide/PetGuide"
    
    if(NewGuide.guideClass ==  ksGuidePet and PetGuide.stepNum == 3) then
        local sprite = getFirstFormatPet()
        local rect   = getSpriteScreenRect(sprite)
        PetGuide.show(4, rect)
    end
end

