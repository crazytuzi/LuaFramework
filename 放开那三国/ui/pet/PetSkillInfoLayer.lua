-- Filename：	PetSkillInfoLayer.lua
-- Author：		zhang zihang
-- Date：		2014-4-12
-- Purpose：		宠物技能信息面板

module("PetSkillInfoLayer", package.seeall)

require "script/audio/AudioUtil"
require "script/utils/BaseUI"
require "script/network/Network"
require "script/model/user/UserModel"
require "script/ui/tip/LackGoldTip"
require "script/ui/tip/AnimationTip"

local _bgLayer
local _priority
local _zOrder
local _mySize
local _myScale
local _brownBg
local _skillId
local _lv
local _status
local _callBackFn
local _skillPLusTable
local _plusNum
local _petId
local _unlockBtn
local _lockBtn
local skillSprite
local _petInfo = nil

local function  init()
	_bgLayer = nil
	_priority = nil
	_zOrder = nil
	_mySize = nil
	_myScale = nil
	_brownBg = nil
	_skillId = nil
	_lv = nil
	_status = nil
	_callBackFn = nil
	_plusNum = nil
	_petId = nil
	_unlockBtn = nil
	_lockBtn = nil
	skillSprite = nil
	_skillPLusTable = {}
	_petInfo = nil
end

local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
		print("began")
	    return true
    elseif (eventType == "moved") then
  		print("moved")
    else
        print("end")
	end
end

local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false,_priority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

local function closeAction()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	if _callBackFn then
		_callBackFn()
	end
	_bgLayer = nil
end

local function refreshSprite()
	_brownBg:removeChildByTag(111,true)
	require "script/ui/pet/PetUtil"
	if tonumber(_status) == 1 then
		_status = 0
	elseif tonumber(_status) == 0 then
		_status = 1
	end

	-- 宠物进阶的技能等级加成
    local evolveLv = tonumber(_petInfo.va_pet.evolveLevel) or 0
    local evolveAddSkillLv = PetData.getPetEvolveSkillLevel(_petInfo,evolveLv)
    print("PetSkillInfoLayer refreshSprite evolveAddSkillLv => ",evolveAddSkillLv)

	skillSprite = PetUtil.getSkillIcon(_skillId,tonumber(_lv+PetData.getAddSkillByTalent(_petId).addNormalSkillLevel+evolveAddSkillLv),_status)
	skillSprite:setAnchorPoint(ccp(0,1))
	skillSprite:setPosition(ccp(15,_brownBg:getContentSize().height-50))
	_brownBg:addChild(skillSprite,1,111)
	PetGraspLayer.createHeroInfoPanel()
end

function lockCallBack(cbFlag, dictData, bRet)
	if not bRet then
		return
	end

	if cbFlag == "pet.lockSkillSlot" then
		_lockBtn:setVisible(false)
		_unlockBtn:setVisible(true)
		require "script/ui/pet/PetData"
		UserModel.addGoldNumber(tonumber(-PetData.getLockCost(_petId)))
		PetData.setNormalSkillStatus(_petId,_skillId,1)
		AnimationTip.showTip(GetLocalizeStringBy("key_3266"))
		refreshSprite()
	end
end

function unlockCallBack(cbFlag, dictData, bRet)
	if not bRet then
		return
	end

	if cbFlag == "pet.unlockSkillSlot" then
		_lockBtn:setVisible(true)
		_unlockBtn:setVisible(false)
		require "script/ui/pet/PetData"
		PetData.setNormalSkillStatus(_petId,_skillId,0)
		AnimationTip.showTip(GetLocalizeStringBy("key_1968"))
		refreshSprite()
	end
end

function yeahOpen()
    --if(isOpen == true) then
    if tonumber(UserModel.getGoldNumber()) >= tonumber(PetData.getLockCost(_petId)) then
        local subArg = CCArray:create()
		subArg:addObject(CCInteger:create(_petId))
		subArg:addObject(CCInteger:create(_skillId))
		Network.rpc(lockCallBack, "pet.lockSkillSlot","pet.lockSkillSlot", subArg, true)
	else
		LackGoldTip.showTip()
		_callBackFn()
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
   -- end
end  

local function lockAction()
	require "script/ui/pet/PetData"
	if tonumber(PetData.getLockCost(_petId)) ~= -1 then
		

			--AlertTip.showAlert(GetLocalizeStringBy("key_1406") .. PetData.getLockCost(_petId) .. GetLocalizeStringBy("key_2389") ,yeahOpen, true,nil,nil,nil)
		require "script/ui/pet/PetLockTip"
		PetLockTip.showAlert(GetLocalizeStringBy("key_2549"),tonumber(PetData.getLockCost(_petId)),yeahOpen)
		
	else
		AnimationTip.showTip(GetLocalizeStringBy("key_2691"))
	end
end

function sureUnlock(isOpen)
	if (isOpen == true) then
		local subArg = CCArray:create()

		subArg:addObject(CCInteger:create(_petId))
		subArg:addObject(CCInteger:create(_skillId))

		Network.rpc(unlockCallBack, "pet.unlockSkillSlot","pet.unlockSkillSlot", subArg, true)
	end
end

local function unlockAction()
	require "script/ui/tip/AlertTip"
	AlertTip.showAlert(GetLocalizeStringBy("key_3203"), sureUnlock, true, nil, GetLocalizeStringBy("key_1985"),GetLocalizeStringBy("key_1202"))
end

local function createBg()
	local spriteBg = CCScale9Sprite:create("images/common/viewbg1.png")
	spriteBg:setContentSize(CCSizeMake(_mySize.width,_mySize.height))
	spriteBg:setPosition(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5)
	spriteBg:setScale(_myScale)
	spriteBg:setAnchorPoint(ccp(0.5,0.5))
	_bgLayer:addChild(spriteBg)

	local titileSprite = CCSprite:create("images/common/viewtitle1.png")
	titileSprite:setPosition(ccp(spriteBg:getContentSize().width/2,spriteBg:getContentSize().height))
	titileSprite:setAnchorPoint(ccp(0.5,0.5))
	spriteBg:addChild(titileSprite)

	local menuLabel =  CCLabelTTF:create(GetLocalizeStringBy("key_2276"), g_sFontPangWa, 33)
	menuLabel:setColor(ccc3(0xff,0xe4,0x00))
	menuLabel:setPosition(ccp(titileSprite:getContentSize().width*0.5,titileSprite:getContentSize().height*0.5+3))
	menuLabel:setAnchorPoint(ccp(0.5,0.5))
	titileSprite:addChild(menuLabel)

	_brownBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_brownBg:setContentSize(CCSizeMake(395,185 + 80*(_plusNum-1)))
	_brownBg:setAnchorPoint(ccp(0.5,1))
	_brownBg:setPosition(ccp(spriteBg:getContentSize().width/2,spriteBg:getContentSize().height-55))
	spriteBg:addChild(_brownBg)

	local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_priority-1)
    spriteBg:addChild(menu,99)
    
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(spriteBg:getContentSize().width*1.03,spriteBg:getContentSize().height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeAction)
    menu:addChild(closeBtn)

    _unlockBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_2677"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _unlockBtn:setPosition(ccp(spriteBg:getContentSize().width/2 - 10,40))
    _unlockBtn:setAnchorPoint(ccp(1,0))
    _unlockBtn:registerScriptTapHandler(unlockAction)
    menu:addChild(_unlockBtn)

    _lockBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_2895"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _lockBtn:setPosition(ccp(spriteBg:getContentSize().width/2 - 10,40))
    _lockBtn:setAnchorPoint(ccp(1,0))
    _lockBtn:registerScriptTapHandler(lockAction)
    menu:addChild(_lockBtn)

    if tonumber(_status) == 1 then
    	_unlockBtn:setVisible(true)
    	_lockBtn:setVisible(false)
    else
	    _unlockBtn:setVisible(false)
	    _lockBtn:setVisible(true) 
    end

    local quitBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_2474"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    quitBtn:setPosition(ccp(spriteBg:getContentSize().width/2 + 10,40))
    quitBtn:setAnchorPoint(ccp(0,0))
    quitBtn:registerScriptTapHandler(closeAction)
    menu:addChild(quitBtn)

    require "script/ui/pet/PetData"
    local DBLockNum,DBPetName,DBQuality = PetData.getPetName(_petId)
    require "script/ui/hero/HeroPublicLua"

    local tip_1 = CCRenderLabel:create(DBPetName,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
    tip_1:setColor(HeroPublicLua.getCCColorByStarLevel(DBQuality))
    local tip_2 = CCRenderLabel:create(GetLocalizeStringBy("zzh_1155"),g_sFontPangWa,25,1,ccc3(0xff,0xff,0xff),type_stroke)
    tip_2:setColor(ccc3(0x78,0x25,0x00))
    local tip_3 = CCRenderLabel:create(DBLockNum,g_sFontPangWa,25,1,ccc3(0xff,0xff,0xff),type_stroke)
    tip_3:setColor(ccc3(0x08,0x78,0x00))
    local tip_4 = CCRenderLabel:create(GetLocalizeStringBy("zzh_1156"),g_sFontPangWa,25,1,ccc3(0xff,0xff,0xff),type_stroke)
    tip_4:setColor(ccc3(0x78,0x25,0x00))

    local tipNode = BaseUI.createHorizontalNode({tip_1,tip_2,tip_3,tip_4})
    tipNode:setAnchorPoint(ccp(0.5,0))
    tipNode:setPosition(ccp(spriteBg:getContentSize().width/2,120))
    spriteBg:addChild(tipNode)
end

local function createContent()
	require "db/DB_Pet_skill"
	require "script/ui/pet/PetData"

	local petInfoTable = DB_Pet_skill.getDataById(tonumber(_skillId))

	local skillName = CCLabelTTF:create(petInfoTable.name,g_sFontPangWa,30)
	skillName:setColor(ccc3(0x00,0xff,0x18))
	skillName:setAnchorPoint(ccp(0.5,1))
	skillName:setPosition(ccp(_brownBg:getContentSize().width/2,_brownBg:getContentSize().height-10))
	_brownBg:addChild(skillName)

	local lvDes = CCLabelTTF:create(GetLocalizeStringBy("key_1986"),g_sFontPangWa,24)
	lvDes:setColor(ccc3(0xff,0xe4,0x00))

	-- 宠物进阶的技能等级加成
    local evolveLv = tonumber(_petInfo.va_pet.evolveLevel) or 0
    local evolveAddSkillLv = PetData.getPetEvolveSkillLevel(_petInfo,evolveLv)
    print("PetSkillInfoLayer createContent evolveAddSkillLv => ",evolveAddSkillLv)

	local lvNum
	if tonumber(PetData.getAddSkillByTalent(_petId).addNormalSkillLevel) >= 1  or evolveAddSkillLv >= 1 then
		lvNum = CCLabelTTF:create(_lv .. "（+" .. PetData.getAddSkillByTalent(_petId).addNormalSkillLevel + evolveAddSkillLv .. "）",g_sFontPangWa,24)
	else
		lvNum = CCLabelTTF:create(_lv , g_sFontPangWa,24)
	end
	lvNum:setColor(ccc3(0xff,0xff,0xff))
	-- local advanceLv = 0
	-- if _petInfo.va_pet then
	-- 	advanceLv = tonumber(_petInfo.va_pet.evolveLevel) or 0
	-- end
	-- local advanceSkillNum = PetData.getPetEvolveSkillLevel(_petInfo,advanceLv)
	-- if advanceSkillNum ~= 0 then
		-- local advanceLvLabel = CCRenderLabel:create("（+"..advanceSkillNum.."）",g_sFontPangWa,21,1,ccc3(0,0,0),type_shadow)
	 --    advanceLvLabel:setColor(ccc3(0x00,0xff,0x18))
	 --    advanceLvLabel:setAnchorPoint(ccp(0,0.5))
	 --    advanceLvLabel:setPosition(ccpsprite(1,0.5,lvNum))
	 --    lvNum:addChild(advanceLvLabel)
	-- end
	local lv = BaseUI.createHorizontalNode({lvDes, lvNum})
	lv:setAnchorPoint(ccp(0,0))
	lv:setPosition(ccp(138,_brownBg:getContentSize().height-86))
	_brownBg:addChild(lv)

	local brownLine1 = CCSprite:create("images/hunt/brownline.png")
	brownLine1:setAnchorPoint(ccp(0,0.5))
	brownLine1:setPosition(ccp(116,_brownBg:getContentSize().height-96))
	brownLine1:setScaleX(2)
	_brownBg:addChild(brownLine1)

	for i = 1,_plusNum do
		local skillDes = CCLabelTTF:create(_skillPLusTable[i].affixDesc.displayName .. "：",g_sFontPangWa,24)
		skillDes:setColor(ccc3(0xff,0xe4,0x00))
		local skillNum = CCLabelTTF:create("+" .. _skillPLusTable[i].displayNum,g_sFontPangWa,24)
		skillNum:setColor(ccc3(0xff,0xff,0xff))

		local skill = BaseUI.createHorizontalNode({skillDes,skillNum})
		skill:setAnchorPoint(ccp(0,0))
		skill:setPosition(ccp(138,_brownBg:getContentSize().height - 86 - 45*i))
		_brownBg:addChild(skill)

		local brownline2 = CCSprite:create("images/hunt/brownline.png")
		brownline2:setAnchorPoint(ccp(0,0.5))
		brownline2:setPosition(ccp(116,_brownBg:getContentSize().height - 96 - 45*i))
		brownline2:setScaleX(2)
		_brownBg:addChild(brownline2)
	end

	require "script/ui/pet/PetUtil"
	skillSprite = PetUtil.getSkillIcon(_skillId,tonumber(_lv+PetData.getAddSkillByTalent(_petId).addNormalSkillLevel+evolveAddSkillLv),_status)
	skillSprite:setAnchorPoint(ccp(0,1))
	skillSprite:setPosition(ccp(15,_brownBg:getContentSize().height-50))
	_brownBg:addChild(skillSprite,1,111)
end

local function createUI()
	createBg()
	createContent()
end

function showLayer(skillId, lv,status,petId,callBackFn,menu_priority,z_order)
	init()

	_skillId = skillId
	_petId = petId
	_lv = lv
	_status = status
	_callBackFn = callBackFn
	_priority = menu_priority or -555
	_zOrder = z_order or 999
	_petInfo = PetData.getFormationPetById(_petId)
	print("petinfo12345")
	print_t(_petInfo)
	require "script/ui/pet/PetUtil"
	_skillPLusTable = PetUtil.getNormalSkill(_skillId,_lv)
	print("加成数据")
	print_t(_skillPLusTable)
	
	_bgLayer = CCLayerColor:create(ccc4(11,11,11,166))
    _bgLayer:registerScriptHandler(onNodeEvent)

    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder)

    _myScale = MainScene.elementScale
    _plusNum = table.count(_skillPLusTable)
	_mySize = CCSizeMake(460,400 + 80*(_plusNum-1))

	createUI()
end
