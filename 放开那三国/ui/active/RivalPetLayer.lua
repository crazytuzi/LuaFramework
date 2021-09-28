-- FileName: RivalPetLayer.lua 
-- Author: zhz
-- Date: 14-5-14
-- Purpose: 查看对手的上阵宠物界面

module("RivalPetLayer", package.seeall)

require "db/DB_Pet"
require "script/ui/pet/PetUtil"
require "script/ui/active/RivalInfoData"


local _bgLayer 							   -- 主layer
local _layerSize 						   -- 主layer宽高
local _petBgSprite						   -- 
local _petInfo							   -- 上阵宠物信息

local _bottomBg							   -- 属性的背景
local _curItem                             -- 当前选中的按钮
local _limitSize                           --

local _ksTagProperty 	=101
local _ksTagSkill 		=102




local function init( )
	_bgLayer		=nil
	_layerSize		=nil
	_petBgSprite 	=nil
	_bottomBg       =nil
	_curItem 		=nil
    _limitSize      =nil

end


-- 判断是如何滑动
local function scrollFriendAndPetLayer(xOffset)
    -- if(FormationLayer.isOnAnimatingFunc() == true)then
    --     return false
    -- end
    print(" scrollFriendAndPetLayer  xOffset is ", xOffset)

    if(RivalInfoData.hasFriend() ) then
        if(xOffset>_limitSize and xOffset>0 )then
            print("moveFriendOrPetAnimated moveFriendOrPetAnimated ")
            RivalInfoLayer.moveFriendOrPetAnimated( false, true )
        end
    else
        if(xOffset >_limitSize and xOffset>0  )then
            print("  moveToPetAnimatedByType 3")
            RivalInfoLayer.moveToPetAnimatedByType(3)
        end

    end    
end 


-- touch事件处理
local function cardLayerTouch(eventType, x, y)
   
    if(eventType == "began") then
    	_touchBeganPoint = ccp(x, y)
    	-- if( FormationLayer.isInLittleFriendFunc() == true )then
			local tPosition = _bgLayer:convertToNodeSpace(_touchBeganPoint)
			if( _bgLayer:isVisible() == true and tPosition.x>0 and tPosition.y>0 and tPosition.x<_bgLayer:getContentSize().width and tPosition.y<_bgLayer:getContentSize().height)then
				return true
			else
				return false
			end
    elseif(eventType == "moved") then
    	-- print("moved! ")
    else
        local k = (y-_touchBeganPoint.y)/(x-_touchBeganPoint.x)
        if(k<0.5 and k>-0.5)then
            scrollFriendAndPetLayer( x-_touchBeganPoint.x)
        end
    
	end
end




--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(cardLayerTouch, false, -999, true)
		_bgLayer:setTouchEnabled(false)

	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

-- 创建有宠物的中间部分的UI
local function createOnPetUI( ... )
    local  petDb = DB_Pet.getDataById(_petInfo.pet_tmpl)
    local offsetY = 0
    if petDb ~= nil then
        offsetY = petDb.Offset or 0
    end

    local petSp= PetUtil.getPetIMGById( tonumber(_petInfo.pet_tmpl) ,1)
    petSp:setScale(0.95)
    petSp:setPosition(_petBgSprite:getContentSize().width/2,232-offsetY)
    petSp:setAnchorPoint(ccp(0.5,0))
    _petBgSprite:addChild(petSp)

     _fightSpite= CCSprite:create("images/pet/pet/fight_sp.png")
    local  petid= tonumber( _petInfo.pet_tmpl)
    _fightforceSp= LuaCC.createSpriteOfNumbers("images/pet/number", RivalInfoData.getPetFightForce(),24 )

    _fightSpite:setPosition(_petBgSprite:getContentSize().width*0.367, 272)
    _petBgSprite:addChild(_fightSpite,111)
    _fightforceSp:setPosition(_petBgSprite:getContentSize().width*0.367+ _fightSpite:getContentSize().width,272 )
    _petBgSprite:addChild(_fightforceSp,111)
    _fightforceSp:setAnchorPoint(ccp(0,0))

    local fullRect = CCRectMake(0,0,111,32)
    local insetRect = CCRectMake(39,15,2,2)
    local  nameBg= CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
    nameBg:setPreferredSize(CCSizeMake(245,35))
    nameBg:setAnchorPoint(ccp(0.5,1))
    nameBg:setPosition(_petBgSprite:getContentSize().width/2 , _fightSpite:getPositionY()+ 4 )
    _petBgSprite:addChild(nameBg,17)

    local lvSp= CCSprite:create("images/common/lv.png")
    local lvLabel= CCLabelTTF:create( _petInfo.level ,g_sFontPangWa, 18)-- 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lvLabel:setColor(ccc3(0xff,0xf6,0x00))

    local nameLabel= CCLabelTTF:create(_petInfo.petDesc.roleName ,g_sFontPangWa,25 )
    local nameColor = HeroPublicLua.getCCColorByStarLevel(_petInfo.petDesc.quality)
    --nameLabel:setColor(ccc3(0xff,0x84,0x00))
    nameLabel:setColor(nameColor)
    -- 品阶
    local evolveLv = 0
    if _petInfo then
        evolveLv = _petInfo.evolveLevel or 0
    end
    local evolveLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1089",evolveLv),g_sFontPangWa,21,1,ccc3(0,0,0),type_shadow)
    evolveLabel:setColor(ccc3(0xff,0xf6,0x00))
    evolveLabel:setAnchorPoint(ccp(0,0.5))
    evolveLabel:setPosition(ccpsprite(1.1,0.5,nameLabel))
    nameLabel:addChild(evolveLabel)

    local nameNode= BaseUI.createHorizontalNode({lvSp, lvLabel, nameLabel})
    nameNode:setAnchorPoint(ccp(0.5,0.5))
    nameNode:setPosition(nameBg:getContentSize().width/2 - evolveLabel:getContentSize().width / 2, nameBg:getContentSize().height/2)
    nameBg:addChild(nameNode)

    local upPetSprite= CCSprite:create("images/pet/pet/up_already.png")
    upPetSprite:setPosition(_petBgSprite:getContentSize().width/2, 554)
    upPetSprite:setAnchorPoint(ccp(0.5,0))
    _petBgSprite:addChild(upPetSprite)
end

-- 创建没有宠物的中间部分的UI
local function createDownPetUI( )
    local petSp= CCSprite:create("images/pet/pet/horse_dark.png") --PetUtil.getPetIMGById( tonumber(_petInfo.pet_tmpl) ,1)
    -- petSp:setScale(0.95)
    petSp:setPosition(_petBgSprite:getContentSize().width/2,232)
    petSp:setAnchorPoint(ccp(0.5,0))
    _petBgSprite:addChild(petSp)

    local noPetSp= CCSprite:create("images/active/no_pet_desc.png")
    noPetSp:setAnchorPoint(ccp(0.5,0))
    noPetSp:setPosition(petSp:getContentSize().width/2, 135)
    petSp:addChild(noPetSp)

end

-- 宠物的UI
local function createPetUI( )

	local menuBar= CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-1001)
	_petBgSprite:addChild(menuBar)
	
	-- 查看技能按钮
    _skillItem= LuaCC.create9ScaleMenuItem("images/common/btn/btn_bg_n.png","images/common/btn/btn_bg_h.png",CCSizeMake(198,73),GetLocalizeStringBy("key_3422"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _skillItem:setAnchorPoint(ccp(0,0))
    _skillItem:setPosition(98,5)-- _layerSize.height*0.078)
    _skillItem:registerScriptTapHandler(menuAction)
    menuBar:addChild(_skillItem,1,_ksTagSkill )
    -- skillItem:selected()
    -- _curItem= skillItem

    -- 查看属性按钮
    _realizeItem= LuaCC.create9ScaleMenuItem("images/common/btn/btn_bg_n.png","images/common/btn/btn_bg_h.png",CCSizeMake(198,73),GetLocalizeStringBy("key_3423"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _realizeItem:setAnchorPoint(ccp(0,0))
    _realizeItem:setPosition( 339,5)-- _layerSize.height*0.078)
    _realizeItem:registerScriptTapHandler(menuAction)
    menuBar:addChild(_realizeItem,1,_ksTagProperty )

    _realizeItem:selected()
    _curItem= _realizeItem

    if( _petInfo~= nil ) then
        createOnPetUI()
    else
        _skillItem:setVisible(false)
        _realizeItem:setVisible(false)
        createDownPetUI()
    end    

end



function createPropertyUI( )
    if(_bottomBg~= nil) then
        _bottomBg:removeFromParentAndCleanup(true)
        _bottomBg= nil
    end

    _bottomBg= CCScale9Sprite:create("images/common/bg/9s_1.png")
    _bottomBg:setContentSize(CCSizeMake(581,144))
    _bottomBg:setPosition(_bgLayer:getContentSize().width/2, 77)
    _bottomBg:setAnchorPoint(ccp(0.5,0))
    _bgLayer:addChild(_bottomBg,11)

    -- 创建sprite
    local destinyLabelBg= CCScale9Sprite:create("images/common/astro_labelbg.png")
    destinyLabelBg:setContentSize(CCSizeMake(183,40))
    destinyLabelBg:setAnchorPoint(ccp(0.5,0.5))
    destinyLabelBg:setPosition(_bottomBg:getContentSize().width/2, _bottomBg:getContentSize().height)
    _bottomBg:addChild(destinyLabelBg)

    local destinyLabel= CCRenderLabel:create(GetLocalizeStringBy("key_1420"), g_sFontPangWa, 24,1, ccc3(0x00,0x00,0x00),type_stroke )
    destinyLabel:setColor(ccc3(0xff,0xf6,0x00))
    destinyLabel:setPosition(destinyLabelBg:getContentSize().width/2, destinyLabelBg:getContentSize().height/2)
    destinyLabel:setAnchorPoint(ccp(0.5,0.5))
    destinyLabelBg:addChild(destinyLabel)

    local skillDescStr = GetLocalizeStringBy("key_2120")
    if(_petInfo ~= nil ) then
        skillDescStr = GetLocalizeStringBy("key_2120")
    else
        skillDescStr= GetLocalizeStringBy("key_4003")
    end

    local skillPropertyDesc= CCRenderLabel:create(skillDescStr, g_sFontName,23,1, ccc3(0x00,0x00,0x00),type_stroke)
    skillPropertyDesc:setAnchorPoint(ccp(0.5,0))
    skillPropertyDesc:setColor(ccc3(0x00,0xff,0x18))
    skillPropertyDesc:setPosition(_bottomBg:getContentSize().width/2,5)
    _bottomBg:addChild(skillPropertyDesc)


    local skillProperty= RivalInfoData.getPetValue( )
    print("===========================skillProperty skillProperty skillProperty skillProperty ")
    print_t(skillProperty)
    -- 技能属性和培养属性的对应关系
    local affixKeyMap = {[1] = "51",[4] = "54",[5] = "55",[9] = "100"}
    local descLabelMap = {}
    local index = 0
    local x_start= 46
    local x= x_start
    local y= 79
    local xOffset= 197
    for i=1, #skillProperty do

        local descLabel= CCLabelTTF:create( skillProperty[i].affixDesc.displayName .. ":  " ,g_sFontName,23 )
        descLabel:setColor(ccc3(0xff,0xff,0xff))
        local descNumLabel= CCLabelTTF:create(skillProperty[i].displayNum,g_sFontName,23 )
        descNumLabel:setColor(ccc3(0xff,0xff,0xff))
        
        descLabelMap[affixKeyMap[skillProperty[i].affixDesc.id]] = descNumLabel
        if(i==3) then
            x = x_start
            y = 40
        end
        descLabel:setPosition(x,y)
        descNumLabel:setPosition(x+descLabel:getContentSize().width,y)
        -- descNode:setPosition(x,y)
        x = x + xOffset
        _bottomBg:addChild(descLabel)
        _bottomBg:addChild(descNumLabel)
        index = i
    end
    require "script/ui/pet/PetData"
    -- print(232332)
    local petEvolveData = PetData.getPetTrainAttrTotalValue(_petInfo)
    local petEvolveLabelAry = {}
    -- print("petEvolveData23242")
    -- print_t(_petInfo)
    -- print_t(petEvolveData)
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
                _bottomBg:addChild(descLabel)
                if index == 3 then
                    x = x_start
                    y = 40
                end
                descLabel:setPosition(ccp(x,y))
                x = x + xOffset
            end
        end
    end
end

-- 创建宠物技能的tableView
local function createSkillTableView( )
	
	local skillNormal = _petInfo.arrSkill.skillNormal

	local function keySort ( skillNormal_1, skillNormal_2 )
        return tonumber(skillNormal_1.id ) > tonumber(skillNormal_2.id)
    end

    table.sort( skillNormal, keySort)
   local addSkillBytalent=RivalInfoData.getAddSkillByTalent(petId)
    local addNormalSkillLevel = addSkillBytalent.addNormalSkillLevel

    -- 宠物进阶的技能等级加成
    local evolveLv = tonumber(_petInfo.evolveLevel) or 0
    local evolveAddSkillLv = PetData.getPetEvolveSkillLevel(_petInfo,evolveLv)
    print("RivalPetLayer createSkillTableView evolveAddSkillLv => ",evolveAddSkillLv)

    local columLimit = DB_Pet.getDataById( tonumber(_petInfo.pet_tmpl)).ColumLimit
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
                if(a1*4 +i<= #skillNormal) then 
                    local index= a1*4 +i
                    local headSprite = PetUtil.getSkillIcon(skillNormal[index].id, skillNormal[index].level+addNormalSkillLevel+evolveAddSkillLv,0 ) -- , shillNormal[index].status, _formationPetInfo[_curPetIndex].petid ,rfcAftLock )
                    headSprite:setPosition(ccp(28+138*(i-1),62))
                    a2:addChild(headSprite,1, index)

                    if( tonumber(skillNormal[index].id)>0 ) then

                        local skillData = DB_Pet_skill.getDataById( tonumber(skillNormal[index].id))
                        local skillNameLabel = CCRenderLabel:create( skillData.name ,g_sFontPangWa,18 ,1,ccc3(0x00,0x00,0x00),type_stroke )
                        local color= HeroPublicLua.getCCColorByStarLevel(skillData.skillQuality)
                        skillNameLabel:setColor(color )
                        skillNameLabel:setPosition( headSprite:getContentSize().width/2 ,-2)
                        skillNameLabel:setAnchorPoint(ccp(0.5,1))
                        headSprite:addChild(skillNameLabel)

                        local skillProperty = PetUtil.getNormalSkill( tonumber(skillNormal[index].id), tonumber(skillNormal[index].level)+addNormalSkillLevel+evolveAddSkillLv )
                        -- print("skillProperty is :")
                        -- print_t(skillProperty)
                        for i=1,#skillProperty do
                            local skillLabel_01 = CCLabelTTF:create( skillProperty[i].affixDesc.displayName .. " " , g_sFontName, 18)
                            skillLabel_01:setColor(ccc3(0xff,0xff,0xff))
                            local skillLabel_02= CCLabelTTF:create("+".. skillProperty[i].displayNum , g_sFontName, 18)
                            skillLabel_02:setColor(ccc3(0x00,0xff,0x18))

                            skillLabel_01:setPosition(headSprite:getContentSize().width*0.1, -24-(i-1)*21)
                            skillLabel_01:setAnchorPoint(ccp(0,1))
                            headSprite:addChild(skillLabel_01)

                            skillLabel_02:setPosition(headSprite:getContentSize().width*0.1 + skillLabel_01:getContentSize().width, -24-(i-1)*21)
                            skillLabel_02:setAnchorPoint(ccp(0,1))
                            headSprite:addChild(skillLabel_02)
                        end

                        local lineSp= CCSprite:create("images/common/line02.png")
                        lineSp:setPosition(headSprite:getContentSize().width/2,-64)
                        lineSp:setAnchorPoint(ccp(0.5,1))
                        headSprite:addChild(lineSp)
                    end
                elseif(a1*4 +i<= columLimit )then
                    local headSprite = PetUtil.getLockIcon()
                    headSprite:setPosition(ccp(28+138*(i-1),62))
                    a2:addChild(headSprite,1, index)
                end
           end
           r = a2
        elseif fn == "numberOfCells" then
            local num = math.ceil(#skillNormal/4 )
            r = math.ceil(columLimit/4 )
        elseif fn == "cellTouched" then
            
        elseif (fn == "scroll") then
            
        end
        return r
    end)

    local skillTableView = LuaTableView:createWithHandler(h, CCSizeMake(534, 124))
    skillTableView:setBounceable(true)
    -- _feedTableView:setDirection(kCCScrollViewDirectionHorizontal)
    skillTableView:setPosition(ccp(12, 2))
    skillTableView:setTouchPriority(-1001)
    skillTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _bottomBg:addChild(skillTableView)


end

--- 创建技能的UI
local function createSkillUI( )

	if(_bottomBg~= nil) then
        _bottomBg:removeFromParentAndCleanup(true)
        _bottomBg= nil
    end

    _bottomBg= CCScale9Sprite:create("images/common/bg/9s_1.png")
    _bottomBg:setContentSize(CCSizeMake(581,144))
    _bottomBg:setPosition(_bgLayer:getContentSize().width/2, 77)
    _bottomBg:setAnchorPoint(ccp(0.5,0))
    _bgLayer:addChild(_bottomBg,11)

    -- 创建sprite
    local destinyLabelBg= CCScale9Sprite:create("images/common/astro_labelbg.png")
    destinyLabelBg:setContentSize(CCSizeMake(183,40))
    destinyLabelBg:setAnchorPoint(ccp(0.5,0.5))
    destinyLabelBg:setPosition(_bottomBg:getContentSize().width/2, _bottomBg:getContentSize().height)
    _bottomBg:addChild(destinyLabelBg)

    local destinyLabel= CCRenderLabel:create(GetLocalizeStringBy("key_3424"), g_sFontPangWa, 24,1, ccc3(0x00,0x00,0x00),type_stroke )
    destinyLabel:setColor(ccc3(0xff,0xf6,0x00))
    destinyLabel:setPosition(destinyLabelBg:getContentSize().width/2, destinyLabelBg:getContentSize().height/2)
    destinyLabel:setAnchorPoint(ccp(0.5,0.5))
    destinyLabelBg:addChild(destinyLabel)

    if(_petInfo== nil ) then

        local skillPropertyDesc= CCRenderLabel:create( GetLocalizeStringBy("key_4003") , g_sFontName,23,1, ccc3(0x00,0x00,0x00),type_stroke)
        skillPropertyDesc:setAnchorPoint(ccp(0.5,0))
        skillPropertyDesc:setColor(ccc3(0x00,0xff,0x18))
        skillPropertyDesc:setPosition(_bottomBg:getContentSize().width/2,5)
        _bottomBg:addChild(skillPropertyDesc)
    else
        createSkillTableView()
    end    
end



-- 
function createPetLayer( )
	init()

	_bgLayer= CCLayer:create()

	width = 640
	height = 588
	_bgLayer:setContentSize(CCSizeMake(width,height))

	_layerSize = _bgLayer:getContentSize()

    _limitSize= 60

	_bgLayer:registerScriptHandler(onNodeEvent)
	_petInfo = RivalInfoData.getPetInfo()

	-- 宠物的北京sprite
	_petBgSprite= CCSprite:create("images/pet/pet_rival_bg.png")
	_petBgSprite:setPosition(_bgLayer:getContentSize().width*0.5,0)
	_petBgSprite:setAnchorPoint(ccp(0.5,0))
	_bgLayer:addChild(_petBgSprite)

	-- 
	createPetUI()

    if(_petInfo~=nil) then
	   createPropertyUI()
    end


	return _bgLayer
end


-----------------------------------  menuAction -----------------------
function menuAction( tag, item)
	_curItem:unselected()
	item:selected()
    _curItem= item
	if( tag == _ksTagProperty) then
		createPropertyUI()
	elseif( tag == _ksTagSkill ) then
		createSkillUI()
	end
end





