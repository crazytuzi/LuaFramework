-- Filename：	PetEvolveSuccessLayer.lua
-- Author：		shengyixian
-- Date：		2016-02-17
-- Purpose：		宠物进化成功界面
module("PetEvolveSuccessLayer", package.seeall)
local _layer = nil
local _petId = nil

--==================== Init ====================

--[[
	@des 	:初始化函数
--]]
function init()
	_layer = nil
	_petId = nil
end

--[[
	@des 	:事件函数
	@param 	:事件
--]]
function fnHandlerOfTouch(event)
	if event == "ended" then
		_layer:removeFromParentAndCleanup(true)
		_layer = nil
		MainScene.setMainSceneViewsVisible(true,false,true)
	    require "script/ui/pet/advance/PetAdvanceLayer"
	    PetAdvanceLayer.showLayer(_petId)
	end
	return true
end

--[[
	@des 	:入口函数
--]]
function showLayer(pPetId,p_touchPriority,p_ZOrder)
	init()

	p_touchPriority = p_touchPriority or -1000
	p_ZOrder = p_ZOrder or 1000
	_petId = pPetId
	_layer = CCLayerColor:create(ccc4(0,0,0,255))
	_layer:setTouchEnabled(true)
	_layer:setTouchPriority(p_touchPriority)
	_layer:registerScriptTouchHandler(fnHandlerOfTouch,false,p_touchPriority,true)
	local layerSize = CCSizeMake(640,960)
	--转光特效
	local shineLayerSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/hero/transfer/zhuanguang"),-1,CCString:create(""))
	shineLayerSprite:setAnchorPoint(ccp(0.5,0.5))
	shineLayerSprite:setPosition(layerSize.width * 0.5 * g_fScaleX,layerSize.height * 0.70 * g_fBgScaleRatio)
	shineLayerSprite:setVisible(false)
	shineLayerSprite:setScale(g_fElementScaleRatio)
	_layer:addChild(shineLayerSprite,1)

	local animationEnd = function(actionName,xmlSprite)
    end

    local animationFrameChanged = function(frameIndex,xmlSprite)
    end

    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    
    shineLayerSprite:setDelegate(delegate)
    --进阶成功特效
    local successLayerSprite = CCLayerSprite:layerSpriteWithNameAndCount("images/base/effect/hero/transfer/jinjiechenggong",-1,CCString:create(""))
	successLayerSprite:setAnchorPoint(ccp(0.5,0.5))
	successLayerSprite:setPosition(g_winSize.width*0.5,g_winSize.height*0.43)
	successLayerSprite:setScale(g_fElementScaleRatio)
	_layer:addChild(successLayerSprite,1)
 	local ccDelegateSuccess = BTAnimationEventDelegate:create()
	ccDelegateSuccess:registerLayerEndedHandler(function (actionName,xmlSprite)
		successLayerSprite:cleanup()
	end)
	ccDelegateSuccess:registerLayerChangedHandler(function (index, xmlSprite)
	end)
	successLayerSprite:setDelegate(ccDelegateSuccess)

    AudioUtil.playEffect("audio/effect/zhuanshengchenggong.mp3")
	shineLayerSprite:setVisible(true)
	AudioUtil.playEffect("audio/effect/zhuanguang.mp3")

	local petInfo = PetData.getPetInfoById(pPetId)
	local curLv = petInfo.va_pet.evolveLevel - 1
	local petTid = nil 
    local petDb = nil
    if(petInfo.petDesc) then 
        petTid= petInfo.petDesc.id
        petDb = DB_Pet.getDataById(petTid)
    end
    local showStatus=  petInfo.showStatus
    local petSprite =  PetUtil.getPetIMGById(petTid ,showStatus)
    petSprite:setAnchorPoint(ccp(0.5,0.5))
    local offsetY = 0
    if petDb ~= nil then
        offsetY = petDb.Offset or 0
    end
    petSprite:setPosition(ccpsprite(0.5,0.5,shineLayerSprite))
    petSprite:setScale(0.8)
    shineLayerSprite:addChild(petSprite,11)
    -- 名字的背景
    local fullRect = CCRectMake(0,0,111,32)
    local insetRect = CCRectMake(39,15,2,2)
    local nameBg= CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
    nameBg:setPreferredSize(CCSizeMake(245,35))
    nameBg:setScale(1 / 0.8)
    nameBg:setAnchorPoint(ccp(0.5,1))
    nameBg:setPosition(ccpsprite(0.5,0.1,petSprite))
    petSprite:addChild(nameBg,17)
    local nameLabel= CCRenderLabel:create(petInfo.petDesc.roleName,g_sFontPangWa,25,1,ccc3(0,0,0),type_shadow)
    nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(petInfo.petDesc.quality))
    nameLabel:setAnchorPoint(ccp(0.5,0))
    nameLabel:setPosition(ccpsprite(0.5,0,nameBg))
    nameBg:addChild(nameLabel)
    local advanceLvLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1089",curLv + 1),g_sFontPangWa,21,1,ccc3(0,0,0),type_shadow)
    advanceLvLabel:setColor(ccc3(0xff,0xf6,0x00))
    advanceLvLabel:setAnchorPoint(ccp(0,0.5))
    advanceLvLabel:setPosition(ccpsprite(1.1,0.5,nameLabel))
    nameLabel:addChild(advanceLvLabel)
    local lvSp= CCSprite:create("images/common/lv.png")
    lvSp:setAnchorPoint(ccp(0,0))
    lvSp:setPosition(ccpsprite(-0.05,0.2,nameBg))
    nameBg:addChild(lvSp)
    local lvLabel= CCLabelTTF:create(petInfo.level,g_sFontPangWa, 21)-- 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lvLabel:setColor(ccc3(0xff,0xf6,0x00))
    lvLabel:setAnchorPoint(ccp(0,0.5))
    lvLabel:setPosition(ccpsprite(1,0.5,lvSp))
    lvSp:addChild(lvLabel)
    local width = 640
    local height = (successLayerSprite:getPositionY() - successLayerSprite:getContentSize().height / 2 * g_fElementScaleRatio) / g_fScaleX
    local attrSp = CCSprite:create()
    attrSp:setContentSize(CCSizeMake(width,height))
    attrSp:setScale(g_fScaleX)
    _layer:addChild(attrSp)
	local curSp = createAttrRowSp(GetLocalizeStringBy("syx_1087").."：",curLv,curLv + 1)
	curSp:setAnchorPoint(ccp(0,1))
	curSp:setPosition(ccp(width * 0.1,height * 6 / 7))
	attrSp:addChild(curSp)
	-- 属性进阶
	local curAttrData = PetData.getPetEvolveAttrByLv(petInfo,curLv)
	local nextAttrData = PetData.getPetEvolveAttrByLv(petInfo,curLv + 1)
	local attrNum = table.count(curAttrData)
	for i=1,attrNum do
		local attrName = curAttrData[i].affixDesc.sigleName
		local attrRowSp = createAttrRowSp(attrName.."：",curAttrData[i].displayNum,nextAttrData[i].displayNum)
		attrRowSp:setAnchorPoint(ccp(0,1))
		attrRowSp:setPosition(ccp(width * 0.1,height * (6 - i) / 7))
		attrSp:addChild(attrRowSp)
	end
	-- 技能进阶
	local curSkillNum = PetData.getPetEvolveSkillLevel(petInfo,curLv)
	local nextSkillNum = PetData.getPetEvolveSkillLevel(petInfo,curLv + 1)
	local skillSp = createAttrRowSp(GetLocalizeStringBy("syx_1090"),curSkillNum,nextSkillNum)
	skillSp:setAnchorPoint(ccp(0,1))
	skillSp:setPosition(ccp(width * 0.1,height * 1 / 7))
	attrSp:addChild(skillSp)

	MainScene.setMainSceneViewsVisible(false,false,false)
	MainScene.changeLayer(_layer,"EvolveSuccessLayer")
end

function createAttrRowSp( pTitle,pCurValue,pNextValue)
	-- body
	local width = 640
	local attrSp = CCSprite:create()
	attrSp:setContentSize(CCSizeMake(width,30))
	-- 等级
	local titleLabel = CCRenderLabel:create(pTitle,g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_shadow)
	titleLabel:setColor(ccc3(25,145,215))
	titleLabel:setAnchorPoint(ccp(0,0))
	titleLabel:setPosition(ccp(0,0))
	attrSp:addChild(titleLabel)
	local curValueLabel = CCRenderLabel:create(pCurValue,g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_shadow)
	curValueLabel:setColor(ccc3(255, 0x6c,0))
	curValueLabel:setAnchorPoint(ccp(0,0.5))
	curValueLabel:setPosition(ccpsprite(1,0.5,titleLabel))
	titleLabel:addChild(curValueLabel)
	-- 箭头特效
	local arrowLayerSprite = CCLayerSprite:layerSpriteWithNameAndCount("images/base/effect/hero/transfer/jiantou",-1,CCString:create(""))
	arrowLayerSprite:setAnchorPoint(ccp(0,0))
	arrowLayerSprite:setPosition(ccp(width * 0.4,15))
	attrSp:addChild(arrowLayerSprite)
	local nextValueLabel = CCRenderLabel:create(pNextValue,g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_shadow)
	nextValueLabel:setColor(ccc3(0x67,0xf9,0))
	nextValueLabel:setAnchorPoint(ccp(0,0))
	nextValueLabel:setPosition(ccp(width * 0.6,0))
	attrSp:addChild(nextValueLabel)
	if pNextValue - pCurValue > 0 then
		local greenSprite = CCSprite:create("images/hero/transfer/arrow_green.png")
		greenSprite:setPosition(width * 0.8,0)
		attrSp:addChild(greenSprite)
	end
	return attrSp
end