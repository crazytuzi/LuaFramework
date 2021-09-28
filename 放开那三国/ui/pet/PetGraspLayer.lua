-- FileName: PetGraspLayer.lua
-- Author: shengyixian
-- Date: 2016-01-29
-- Purpose: 宠物技能
module("PetGraspLayer",package.seeall)

local _layer = nil
local _layerSize = nil
local _scrollView = nil
local _scrollSize = nil
local _curPetIndex = nil
local _touchBeganPos = nil
-- 技能底框背景
local _bottomBg = nil
-- 最大技能个数
local _maxSkillNumLabel = nil
-- 单个技能等级上限
local _levelLimitNumLabel = nil
-- 技能点数
local _skillPointNumLabel = nil
-- 重置技能按钮
local _resetBtn = nil
-- 玩家信息面板
local _heroInfoPanel = nil
local _skillNormal = nil
local _nameBg = nil
local _nameLabel = nil
local _advanceLvLabel = nil
local _middleUIPosY = nil
local _lvLabel = nil
local _graspBtn = nil
local _backItem = nil
local _skillTableViewSize = nil


function init( ... )
	-- body
	_layer = nil
	_scrollView = nil
	_scrollSize = CCSizeMake(640, 265)
	_layerSize = nil
	_touchBeganPos = nil
	_curPetIndex = nil
    _bottomBg = nil
    _maxSkillNumLabel = nil
    _levelLimitNumLabel = nil
    _skillPointNumLabel = nil
    _heroInfoPanel = nil
    _skillNormal = nil
    _nameBg = nil
    _nameLabel = nil
    _advanceLvLabel = nil
    _middleUIPosY = nil
    _lvLabel = nil
    _graspBtn = nil
    _backItem = nil
    _skillTableViewSize = nil
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
    local titleSp = CCSprite:create("images/pet/pet/learn_sp.png")
    titleSp:setAnchorPoint(ccp(0.5,1))
    titleSp:setPosition(ccp(_layerSize.width * 0.5,_layerSize.height - (_heroInfoPanel:getContentSize().height + 18) * g_fScaleX))
    titleSp:setScale(g_fScaleX)
    _layer:addChild(titleSp)
    local desSp = CCSprite:create("images/pet/pet/level_up_desc.png")
    desSp:setAnchorPoint(ccp(0.5,1))
    desSp:setPosition(ccpsprite(0.5,-0.2,titleSp))
    titleSp:addChild(desSp)
    -- 返回按钮
    local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(_touchPriority - 10)
	_layer:addChild(menu)
	_backItem= CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
	_backItem:setScale(MainScene.elementScale * 0.9)
    _backItem:registerScriptTapHandler(closeBtnHandler)
    _backItem:setScale(MainScene.elementScale)
    _backItem:setAnchorPoint(ccp(0,1))
    _backItem:setPosition(ccp(_layerSize.width - 100 * MainScene.elementScale, _layerSize.height - (_heroInfoPanel:getContentSize().height + 10) * g_fScaleX))
	menu:addChild(_backItem)
    local skillViewBtn= CCMenuItemImage:create( "images/pet/btn_skill/btn_skill_n.png","images/pet/btn_skill/btn_skill_h.png")
    skillViewBtn:setScale(MainScene.elementScale * 0.9)
    skillViewBtn:setPosition(ccp(20 * MainScene.elementScale, _layerSize.height - (_heroInfoPanel:getContentSize().height + 10) * g_fScaleX))
    skillViewBtn:setAnchorPoint(ccp(0,1))
    skillViewBtn:registerScriptTapHandler(skillViewHandler)
    menu:addChild(skillViewBtn)
end
--[[
    @des    : 宠物技能预览
    @param  : 
    @return :
--]]
function skillViewHandler( ... )
    -- body
    require "script/ui/pet/PetBasicInfoLayer"
    local feededPetInfo = PetData.getFeededPetInfo()
    local petTmpl = tonumber(feededPetInfo[_curPetIndex].pet_tmpl )
    PetBasicInfoLayer.showLayer(petTmpl,_touchPriority-5,999)
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

function createScrollView( ... )
	-- body
    local feededPetInfo = PetData.getFeededPetInfo()
    _scrollView= CCScrollView:create()
    _scrollView:setViewSize(CCSizeMake(_scrollSize.width,_scrollSize.height))
    _scrollView:setContentSize(CCSizeMake(_scrollSize.width * table.count(feededPetInfo), _scrollSize.height ))
    _scrollView:setContentOffset(ccp(0,0))
    _scrollView:setScale(g_fBgScaleRatio)
    _scrollView:ignoreAnchorPointForPosition(false)
    _scrollView:setAnchorPoint(ccp(0,1))
    _scrollView:setDirection(kCCScrollViewDirectionHorizontal)
    _scrollView:setPosition((_layerSize.width - _scrollSize.width*g_fBgScaleRatio)/2,_middleUIPosY)
    _layer:addChild(_scrollView,11)
    local scrollLayer = CCLayer:create()
    scrollLayer:setContentSize( CCSizeMake( _scrollSize.width*table.count(feededPetInfo), _scrollSize.height ))
    _scrollView:setContainer(scrollLayer)
    for i,petInfo in ipairs(feededPetInfo) do
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

-- 创建领悟的UI
function createGraspUI( )

    if(_bottomBg ~= nil) then
        _bottomBg:removeFromParentAndCleanup(true)
        _bottomBg = nil
    end
    local feededPetInfo = PetData.getFeededPetInfo()
    local spaceSize = _scrollView:getPositionY() - _scrollView:getContentSize().height * g_fBgScaleRatio - 255*MainScene.elementScale
    print("spaceSize",spaceSize)
    local bottomBgSize = 255*MainScene.elementScale
    local graspSize = 163
    _skillTableViewSize = 160
    if (spaceSize > bottomBgSize) then
        bottomBgSize = 420 * MainScene.elementScale
        graspSize = 328
        _skillTableViewSize = 325
    end
    --底框UI
    _bottomBg= CCScale9Sprite:create("images/pet/pet/bottom_bg.png")
    _bottomBg:setContentSize(CCSizeMake(_layerSize.width, bottomBgSize ) )
    _bottomBg:setAnchorPoint(ccp(0.5,0))
    _bottomBg:setPosition(_layerSize.width/2, 4)
    _layer:addChild(_bottomBg)

    -- 边框
    local frameSp= CCSprite:create("images/main/base_bottom_border.png")
    frameSp:setPosition(ccp(_bottomBg:getContentSize().width/2,  _bottomBg:getContentSize().height))
    frameSp:setAnchorPoint(ccp(0.5,0.7))
    frameSp:setScale(g_fScaleX)
    _bottomBg:addChild(frameSp,17)

    _graspBg= CCScale9Sprite:create("images/common/bg/9s_1.png")
    _graspBg:setContentSize(CCSizeMake(588,graspSize))
    _graspBg:setScale(MainScene.elementScale)
    _graspBg:setPosition(_layer:getContentSize().width/2, 75*MainScene.elementScale)
    _graspBg:setAnchorPoint(ccp(0.5,0))
    _bottomBg:addChild(_graspBg,11)

    local skillBg= CCScale9Sprite:create("images/common/bg/9s_2.png")
    skillBg:setContentSize(CCSizeMake(170,31))
    skillBg:setAnchorPoint(ccp(1,0))
    skillBg:setPosition( frameSp:getContentSize().width -10*MainScene.elementScale,frameSp:getContentSize().height/2 )
    frameSp:addChild(skillBg)

    local skillLabel= CCLabelTTF:create(GetLocalizeStringBy("key_1534"), g_sFontPangWa ,18)
    skillLabel:setColor(ccc3(0xff,0xff,0xff))
    _skillPointNumLabel= CCLabelTTF:create("" .. feededPetInfo[_curPetIndex].skill_point , g_sFontPangWa,18)
    _skillPointNumLabel:setColor(ccc3(0x00,0xff,0x18))

    skillLabel:setPosition(skillBg:getContentSize().width*0.08,  skillBg:getContentSize().height/2)
    skillLabel:setAnchorPoint(ccp(0,0.5))
    skillBg:addChild(skillLabel)

    _skillPointNumLabel:setPosition(skillBg:getContentSize().width*0.08+ skillLabel:getContentSize().width ,  skillBg:getContentSize().height/2)
    _skillPointNumLabel:setAnchorPoint(ccp(0,0.5))
    skillBg:addChild(_skillPointNumLabel)

    ---
    local skillBg_1 = CCScale9Sprite:create("images/common/bg/9s_2.png")
    skillBg_1:setContentSize(CCSizeMake(170,31))
    skillBg_1:setAnchorPoint(ccp(0,0))
    skillBg_1:setPosition(10*MainScene.elementScale, frameSp:getContentSize().height/2 )
    frameSp:addChild(skillBg_1)

    local maxSkillLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2226"), g_sFontPangWa,18)
    _maxSkillNumLabel= CCLabelTTF:create( feededPetInfo[_curPetIndex].petDesc.ColumLimit ,g_sFontPangWa,18)
    _maxSkillNumLabel:setColor(ccc3(0x00,0xff,0x18))

    
    maxSkillLabel:setPosition(skillBg_1:getContentSize().width*0.08,  skillBg_1:getContentSize().height/2)
    maxSkillLabel:setAnchorPoint(ccp(0,0.5))
    skillBg_1:addChild(maxSkillLabel)

    _maxSkillNumLabel:setPosition(skillBg_1:getContentSize().width*0.08+ skillLabel:getContentSize().width ,  skillBg_1:getContentSize().height/2)
    _maxSkillNumLabel:setAnchorPoint(ccp(0,0.5))
    skillBg_1:addChild(_maxSkillNumLabel)

    local skillBg_2 = CCScale9Sprite:create("images/common/bg/9s_2.png")
    skillBg_2:setContentSize(CCSizeMake(190 ,31))
    skillBg_2:setAnchorPoint(ccp(0.5,0))
    skillBg_2:setPosition( frameSp:getContentSize().width/2 , frameSp:getContentSize().height/2)--- 10*g_fScaleX)
    frameSp:addChild(skillBg_2)

    local levelLimit = CCLabelTTF:create(GetLocalizeStringBy("key_2042"), g_sFontPangWa,18)
    _levelLimitNumLabel= CCLabelTTF:create( feededPetInfo[_curPetIndex].petDesc.levelLimit ,g_sFontPangWa, 18)
    _levelLimitNumLabel:setColor(ccc3(0x00,0xff,0x18))
    levelLimit:setPosition(skillBg_2:getContentSize().width*0.08,  skillBg_2:getContentSize().height/2)
    levelLimit:setAnchorPoint(ccp(0,0.5))
    skillBg_2:addChild(levelLimit)
    _levelLimitNumLabel:setPosition(skillBg_2:getContentSize().width*0.08+ levelLimit:getContentSize().width ,  skillBg_2:getContentSize().height/2)
    _levelLimitNumLabel:setAnchorPoint(ccp(0,0.5))
    skillBg_2:addChild(_levelLimitNumLabel)
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-350)
    _bottomBg:addChild(menu)
    -- 重置按钮
    local scale= MainScene.elementScale
    _resetBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(180,73),GetLocalizeStringBy("key_1040"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _resetBtn:setPosition(50*scale,3*scale)
    _resetBtn:setVisible(true)
    _resetBtn:registerScriptTapHandler(resetHandler)
    _resetBtn:setScale(MainScene.elementScale)
    menu:addChild(_resetBtn)
    -- 领悟按钮
    _graspBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(180,73),GetLocalizeStringBy("key_1304"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _graspBtn:setPosition(414*scale,3*scale)
    _graspBtn:setVisible(true)
    _graspBtn:registerScriptTapHandler(graspHandler)
    _graspBtn:setScale(MainScene.elementScale)
    menu:addChild(_graspBtn)
    updateResetBtn()
    --创建tableView
    createSkillTableView()
end

function graspHandler( ... )
    -- body
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    PetController.learnSkill(_curPetIndex)
    --新手引导
    if(NewGuide.guideClass ==  ksGuidePet and PetGuide.stepNum == 12) then
        PetGuide.changLayer()
        require "script/ui/pet/PetMainLayer"
        local button = getGraspBackItem()
        local rect   = getSpriteScreenRect(button)
        PetGuide.show(13, rect)
    end
    if(NewGuide.guideClass ==  ksGuidePet and PetGuide.stepNum == 11) then
        PetGuide.changLayer()
        require "script/ui/pet/PetMainLayer"
        local button = getGraspItem()
        local rect   = getSpriteScreenRect(button)
        PetGuide.show(12, rect)
    end
end

-- 重技能的回调函数
function resetHandler( tag, item)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local feededPetInfo = PetData.getFeededPetInfo()
    local function reserSkill( isRest )
        if(isRest == false) then
            return
        end
        PetController.resetSkill(_curPetIndex,updateAfterReset)
    end
    AlertTip.showAlert(GetLocalizeStringBy("key_2131") ..  feededPetInfo[_curPetIndex].petDesc.resetSkillGold .. GetLocalizeStringBy("key_1866") ,reserSkill, true,nil,nil,nil)
end


function createSkillTableView( )
    local feededPetInfo = PetData.getFeededPetInfo()
    _skillNormal = feededPetInfo[_curPetIndex].va_pet.skillNormal
    PetUtil.sortSkillNormal(_skillNormal )
    -- print_t(_skillNormal)
    local columLimit = feededPetInfo[_curPetIndex].petDesc.ColumLimit
    local petId= tonumber(feededPetInfo[_curPetIndex].petid )
    -- print("_skillNormal _skillNormal  _skillNormal petId is :", petId)
    require "script/ui/hero/HeroPublicLua"

    local addSkillBytalent=PetData.getAddSkillByTalent(petId)
    _addNormalSkillLevel = addSkillBytalent.addNormalSkillLevel

    -- 宠物进阶的技能等级加成
    local curPetInfo = feededPetInfo[_curPetIndex]
    local evolveLv = tonumber(curPetInfo.va_pet.evolveLevel) or 0
    local evolveAddSkillLv = PetData.getPetEvolveSkillLevel(curPetInfo,evolveLv)
    print("PetGraspLayer createSkillTableView evolveAddSkillLv => ",evolveAddSkillLv)

    local cellSize = CCSizeMake(140, 165)
    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = cellSize

        elseif fn == "cellAtIndex" then
            a2 = CCTableViewCell:create()          
           for i =1, 4 do
                local index= a1*4 +i
                if(a1*4 +i<= #_skillNormal) then 
                    local index= a1*4 +i
                    --得到技能
                    local headSprite = PetUtil.getNormalSkillIcon(_skillNormal[index].id, _skillNormal[index].level , _addNormalSkillLevel+evolveAddSkillLv , _skillNormal[index].status, feededPetInfo[_curPetIndex].petid ,rfcAftLock )
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

                        local skillProperty = PetUtil.getNormalSkill( tonumber(_skillNormal[index].id), tonumber(_skillNormal[index].level)+_addNormalSkillLevel+evolveAddSkillLv )
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

    _skillTableView = LuaTableView:createWithHandler(h, CCSizeMake(534, _skillTableViewSize))
    _skillTableView:setBounceable(true)
    _skillTableView:setPosition(ccp(12, 2))
    _skillTableView:setTouchPriority(_touchPriority - 5)
    _skillTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _graspBg:addChild(_skillTableView)
   
end
function rfcAftLock( )
    local petInfo =  PetData.getFeededPetInfo()
    -- resetFormationPetInfo()
    -- if petInfo[_curPetIndex].va_pet then
    -- print(_curPetIndex,123545)
        _skillNormal = petInfo[_curPetIndex].va_pet.skillNormal
        PetUtil.sortSkillNormal(_skillNormal)
    -- else
    --     _skillNormal = {}
    -- end

    local offset= _skillTableView:getContentOffset()
    _skillTableView:reloadData()
    _skillTableView:setContentOffset(offset)
    -- refreshTopUI()

end
-- 刷新顶部的UI
-- function refreshTopUI( )
--     -- modified by yangrui at 2015-12-03
--     _silverLabel:setString(string.convertSilverUtilByInternational(UserModel.getSilverNumber()))
--     _goldLabel:setString( UserModel.getGoldNumber())

-- end

--[[
    @des    :学习技能后刷新
    @param  :pIsSuccess:是否学习成功
    @return :
--]]
function update( pIsSuccess )
    -- body
    local feededPetInfo = PetData.getFeededPetInfo()
    _skillPointNumLabel:setString(feededPetInfo[_curPetIndex].skill_point)
    if pIsSuccess then
    --     if _skillTableView then
    --         _skillTableView:removeFromParentAndCleanup(true)
    --         _skillTableView = nil
    --     end
    --     createSkillTableView()
    -- end

        local originSkill = {} 
        table.hcopy( _skillNormal,originSkill)

        local orginGidNum= table.count(_skillNormal)

        local feededPetInfo = PetData.getFeededPetInfo()
        _skillNormal = feededPetInfo[_curPetIndex].va_pet.skillNormal

        PetUtil.sortSkillNormal_2(_skillNormal)
        PetUtil.sortSkillNormal(_skillNormal)

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

        local columLimit =  tonumber( feededPetInfo[_curPetIndex].petDesc.ColumLimit)
        local allCellNum=  math.ceil(columLimit/4 )
        local offsetY = _skillTableView:getContentOffset().y
        _skillTableView:setContentOffset(ccp(0, offsetY*(allCellNum- _cellIndex-1 ) ))

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
end

function openEffectEnd( )
    local feededPetInfo = PetData.getFeededPetInfo()
    local offset= _skillTableView:getContentOffset()
    _skillNormal = feededPetInfo[_curPetIndex].va_pet.skillNormal
    PetUtil.sortSkillNormal(_skillNormal )
    _skillTableView:reloadData()
    _skillTableView:setContentOffset(offset)
end

function updateResetBtn( ... )
    local feededPetInfo = PetData.getFeededPetInfo()
    local normalSkillNum = PetData.getSkillNum( feededPetInfo[_curPetIndex].petid )
    if( normalSkillNum <= 0 ) then
        _resetBtn:setEnabled(false)
    else
        _resetBtn:setEnabled(true)
    end
end
--[[
    @des    :重置技能后刷新
    @param  :pIsSuccess:是否学习成功
    @return :
--]]
function updateAfterReset( ... )
    -- body
    _resetBtn:setEnabled(false)
    createHeroInfoPanel()
    if _skillTableView then
        _skillTableView:removeFromParentAndCleanup(true)
        _skillTableView = nil
    end
    createSkillTableView()
    local feededPetInfo = PetData.getFeededPetInfo()
    _skillPointNumLabel:setString(feededPetInfo[_curPetIndex].skill_point)
end

function onNodeHandler( eventType )
	-- body
	if eventType == "enter" then
		_layer:registerScriptTouchHandler(onTouchHandler,false,_touchPriority,true)
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
		local feededPetInfo = PetData.getFeededPetInfo()
        local xOffset = x - _touchBeganPos.x
        if xOffset < -20 * g_fScaleX then
        	setCurPetIndex(_curPetIndex + 1)
        elseif xOffset > 20 * g_fScaleX then
            setCurPetIndex(_curPetIndex - 1)
       	end
    	_scrollView:setContentOffsetInDuration(ccp(-(_curPetIndex -1)*_scrollSize.width, 0),0.2)
	end
end
--[[
    @des    :设置当前宠物的索引变量
    @param  :
    @return :
--]]
function setCurPetIndex( pValue )
    local feededPetInfo = PetData.getFeededPetInfo()
    if pValue > table.count(feededPetInfo) then
        pValue = table.count(feededPetInfo)
    elseif pValue < 1 then
        pValue = 1
    end
    if _curPetIndex ~= pValue then
        _curPetIndex = pValue
        local petInfo = feededPetInfo[_curPetIndex]
        _maxSkillNumLabel:setString(petInfo.petDesc.ColumLimit)
        _levelLimitNumLabel:setString(petInfo.petDesc.levelLimit)
        local feededPetInfo = PetData.getFeededPetInfo()
        _skillPointNumLabel:setString(feededPetInfo[_curPetIndex].skill_point)
        if _skillTableView then
            _skillTableView:removeFromParentAndCleanup()
            _skillTableView = nil
        end
        createSkillTableView()
        updateResetBtn()
        createNameUI()
    end
end

function createLayer( ... )
	-- body
	_layer = CCLayer:create()
	_layer:setContentSize(_layerSize)
	_layer:registerScriptHandler(onNodeHandler)
	local bg = CCSprite:create("images/pet/pet_bg_2.jpg")
    bg:setAnchorPoint(ccp(0.5,1))
    bg:setPosition(ccpsprite(0.5,1.1,_layer))
	bg:setScale(g_fBgScaleRatio)
	_layer:addChild(bg)
    createTopUI()
    createMiddleUI()
    createGraspUI()
	return _layer
end

function showLayer( pPetId,pTouchPriority,pZOrder )
	-- body
	init()
    _curPetIndex = PetData.getFeededPetIndex(pPetId) or 1
	_touchPriority = pTouchPriority or -380
	pZOrder = pZOrder or 600
	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
    local menuLayerSize = MenuLayer.getLayerContentSize()
	_layerSize = CCSizeMake(0,0)
	_layerSize.width= g_winSize.width 
	_layerSize.height = g_winSize.height - (bulletinLayerSize.height + menuLayerSize.height) * g_fScaleX
	local layer = createLayer()
	layer:setPosition(ccp(0,menuLayerSize.height * g_fScaleX))
	MainScene.changeLayer(layer,"PetGraspLayer")
end

function closeBtnHandler( ... )
	if not tolua.isnull(_layer) then
		_layer:removeFromParentAndCleanup(true)
		_layer = nil
        if(NewGuide.guideClass ==  ksGuidePet and PetGuide.stepNum == 13) then
            PetGuide.changLayer()
            PetGuide.show(14, nil)
        end
		require "script/ui/pet/PetMainLayer"
    	local layer = PetMainLayer.createLayer(PetMainLayer.getCurPetIndex())
    	MainScene.changeLayer(layer,"PetMainLayer")
	end
end

function createMiddleUI( ... )
    -- body
    createScrollView()
    createNameUI()
end
function createNameUI( ... )
    -- body
    if _nameBg then
        _nameBg:removeFromParentAndCleanup(true)
        _nameBg = nil
    end
    local petInfo = PetData.getFeededPetInfo()[_curPetIndex]
    -- 名字的背景
    local fullRect = CCRectMake(0,0,111,32)
    local insetRect = CCRectMake(39,15,2,2)
    _nameBg= CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
    _nameBg:setPreferredSize(CCSizeMake(245,35))
    _nameBg:setScale(g_fBgScaleRatio)
    _nameBg:setAnchorPoint(ccp(0.5,0))
    _nameBg:setPosition(_layerSize.width * 0.5 , _scrollView:getPositionY() - _scrollView:getContentSize().height * g_fBgScaleRatio)
    _layer:addChild(_nameBg,17)
    _nameLabel = CCRenderLabel:create(petInfo.petDesc.roleName,g_sFontPangWa,25,1,ccc3(0,0,0),type_shadow)
    -- _nameLabel= CCLabelTTF:create(petInfo.petDesc.roleName,g_sFontPangWa,25 )
    _nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(petInfo.petDesc.quality))
    _nameLabel:setAnchorPoint(ccp(0.5,0))
    _nameLabel:setPosition(ccpsprite(0.5,0,_nameBg))
    _nameBg:addChild(_nameLabel)
    local evolveLevel = petInfo.va_pet.evolveLevel or 0
    _advanceLvLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1089",evolveLevel),g_sFontPangWa,21,1,ccc3(0,0,0),type_shadow)
    -- _advanceLvLabel = CCLabelTTF:create(GetLocalizeStringBy("syx_1089",_curLv),g_sFontPangWa,25 )
    _advanceLvLabel:setColor(ccc3(0xff,0xf6,0x00))
    _advanceLvLabel:setAnchorPoint(ccp(0,0.5))
    _advanceLvLabel:setPosition(ccpsprite(1,0.5,_nameLabel))
    _nameLabel:addChild(_advanceLvLabel)
    local lvSp= CCSprite:create("images/common/lv.png")
    lvSp:setAnchorPoint(ccp(0,0.5))
    lvSp:setPosition(ccpsprite(0,0.5,_nameBg))
    _nameBg:addChild(lvSp)
    _lvLabel= CCLabelTTF:create(tostring(petInfo.level ),g_sFontPangWa, 18)
    _lvLabel:setColor(ccc3(0xff,0xf6,0x00))
    _lvLabel:setAnchorPoint(ccp(0,0.5))
    _lvLabel:setPosition(ccpsprite(1,0.5,lvSp))
    lvSp:addChild(_lvLabel)
end
function getGraspItem( ... )
    -- body
    return _graspBtn
end
function getGraspBackItem( ... )
    -- body
    return _backItem
end