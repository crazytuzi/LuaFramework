-- Filename：	PetBasicInfoLayer.lua
-- Author：		zhz
-- Date：		2014-4-22
-- Purpose：		宠物信息

module("PetBasicInfoLayer",  package.seeall )

require "db/DB_Pet"
require "script/ui/pet/PetData"
require "script/ui/pet/PetUtil"

local _bgLayer
local _petBg
local _touchProperty
local _zOrder



local function init(  )
	_bgLayer			=nil
	_petBg				=nil
	_touchProperty		=nil
	_zOrder				=nil

end

local function layerTouch( ... )
	return true
end


function showLayer( petTmpl ,touchProperty, zOrder )
	
	init()

	_touchProperty= touchProperty or - 551
	_zOrder=zOrder or 1002

	_petSkillData= PetUtil.getNorSkillByTmpl(tonumber(petTmpl) )

	-- print("_petSkillData  _petSkillData  _petSkillData  _petSkillData  ")
	-- print_t(_petSkillData)
	

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
	_bgLayer:registerScriptTouchHandler(layerTouch,false,_touchProperty,true)
	_bgLayer:setTouchEnabled(true)

   local scene = CCDirector:sharedDirector():getRunningScene()
   scene:addChild(_bgLayer,_zOrder)


    local fullRect = CCRectMake(0, 0, 213, 171)
    local insetRect = CCRectMake(100, 80, 10, 20)
    _itemInfoBg= CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
    _itemInfoBg:setContentSize(CCSizeMake(589,437))
    _itemInfoBg:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(_itemInfoBg)
    _itemInfoBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _itemInfoBg:setAnchorPoint(ccp(0.5,0.5))

   local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(_itemInfoBg:getContentSize().width*0.5,_itemInfoBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	_itemInfoBg:addChild(titleBg)

	-- 可领悟技能预览
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_2360"), g_sFontPangWa,33,2,ccc3(0x0,0x00,0x0),type_shadow)
	labelTitle:setColor(ccc3( 0xff, 0xe4, 0x0))
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5+2 ))
	labelTitle:setAnchorPoint(ccp(0.5,0.5))
	titleBg:addChild(labelTitle)

    -- 关闭按钮
	local menu = CCMenu:create()
	menu:setTouchPriority(_touchProperty-1)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_itemInfoBg:addChild(menu,16)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(_itemInfoBg:getContentSize().width*0.95, _itemInfoBg:getContentSize().height*0.95 ))
	closeButton:registerScriptTapHandler(closeBtnCb)
	menu:addChild(closeButton)

	-- 背景
	_itemBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_itemBg:setContentSize(CCSizeMake(529, 307))
	_itemBg:setAnchorPoint(ccp(0.5, 0))
	_itemBg:setPosition(ccp(_itemInfoBg:getContentSize().width*0.5, 41))
	_itemInfoBg:addChild(_itemBg)

	local descLabel= CCLabelTTF:create(GetLocalizeStringBy("key_2401"), g_sFontPangWa,25)
	descLabel:setPosition(ccp(40, 358))
	descLabel:setColor(ccc3(0x78,0x25,0x00))
	_itemInfoBg:addChild(descLabel)


	createTableView()

end

function createTableView( ... )
	

	local cellSize = CCSizeMake(534, 160)
    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = cellSize
        elseif fn == "cellAtIndex" then
            a2 = CCTableViewCell:create()          
           for i =1, 4 do
                local index= a1*4 +i
                if(a1*4 +i<= #_petSkillData) then 
                    local index= a1*4 +i
                    local headSprite = PetUtil.getSkillIcon(_petSkillData[index].id,1 )
                    headSprite:setPosition(ccp(24+125*(i-1),60))
                    a2:addChild(headSprite,1, index)

                    local skillData = DB_Pet_skill.getDataById( tonumber(_petSkillData[index].id))
                    local skillNameLabel = CCRenderLabel:create( skillData.name ,g_sFontPangWa,18 ,1,ccc3(0x00,0x00,0x00),type_stroke )
                    local color= HeroPublicLua.getCCColorByStarLevel(skillData.skillQuality)
                    skillNameLabel:setColor(color )
                    skillNameLabel:setPosition( headSprite:getContentSize().width/2 ,0)
                    skillNameLabel:setAnchorPoint(ccp(0.5,1))
                    headSprite:addChild(skillNameLabel)

                    local skillProperty = PetUtil.getNormalSkill( tonumber(_petSkillData[index].id), 1)
                    for i=1,#skillProperty do
                        local skillLabel_01 = CCLabelTTF:create( skillProperty[i].affixDesc.displayName .. "   " , g_sFontName, 18)
                        skillLabel_01:setColor(ccc3(0xff,0xff,0xff))
                        skillLabel_02= CCLabelTTF:create("+"..skillProperty[i].displayNum ,g_sFontName, 18)
                        skillLabel_02:setColor(ccc3(0x00,0xff,0x18))

                        local skillNodeLabel= BaseUI.createHorizontalNode({skillLabel_01 ,skillLabel_02})
                        skillNodeLabel:setPosition( headSprite:getContentSize().width/2 , -22-(i-1)*21 )
                        skillNodeLabel:setAnchorPoint(ccp(0.5,1))
                        headSprite:addChild(skillNodeLabel)
                    end
                end

           end
           r = a2
        elseif fn == "numberOfCells" then
            local num = math.ceil(#_petSkillData/4 )
            r = num --math.ceil(columLimit/4 )
        elseif fn == "cellTouched" then
            
        elseif (fn == "scroll") then
            
        end
        return r
    end)

    _skillTableView = LuaTableView:createWithHandler(h, CCSizeMake(534, 300))
    _skillTableView:setBounceable(true)
    _skillTableView:setPosition(ccp(12, 2))
    _skillTableView:setTouchPriority(_touchProperty-1 )
    _skillTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _itemBg:addChild(_skillTableView)
end


---------------------------------------  回调事件 --------------------------------------
function closeBtnCb(  )
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer=nil
	
end



