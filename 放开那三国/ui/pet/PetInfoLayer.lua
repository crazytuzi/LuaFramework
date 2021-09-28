-- Filename：	PetInfoLayer.lua
-- Author：		zhang zihang
-- Date：		2014-4-9
-- Purpose：		宠物信息面板

module("PetInfoLayer", package.seeall)

require "script/ui/main/BulletinLayer"
require "script/audio/AudioUtil"
require "script/ui/main/MainScene"
require "script/utils/BaseUI"
require "script/ui/pet/PetData"
require "script/ui/pet/PetUtil"
require "db/DB_Pet_skill"
require "script/ui/hero/HeroPublicLua"

local _pet_tmpl				
local _petId
local _zorder
local _priority
local _bgLayer
local bgSprite
local topSize
local bgSize
local blueSize
local buttonSize
local bulletinLayerSize
local _petInfo
local scrollBg
local _position
local _posIndex

local function  init()
	_pet_tmpl 			= nil
	_petId 				= nil
	_zorder 			= nil
	_priority 			= nil
	_bgLayer 			= nil
	bgSprite 			= nil
	topSize 			= nil
	bgSize 				= nil
	blueSize 			= nil
	buttonSize 			= nil
	bulletinLayerSize 	= nil
	scrollBg 			= nil
	_petInfo 			= {}
	_posIndex			= nil
	_position			= nil
end

local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
	    return true
    elseif (eventType == "moved") then
    	print("moved")
    else
        print("end")
	end
end

local function onNodeEvent(event)
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _priority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

local function closeAction()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer=nil
end

local function createBackGround()
	bgSprite = CCScale9Sprite:create("images/item/equipinfo/bg_9s.png")
	bulletinLayerSize = BulletinLayer.getLayerContentSize()
	local bgHeight = g_winSize.height - bulletinLayerSize.height*g_fScaleX
	bgSprite:setContentSize(CCSizeMake(g_winSize.width, bgHeight))
	bgSprite:setAnchorPoint(ccp(0.5,1))
	bgSprite:setPosition(ccp(g_winSize.width/2,bgHeight))
	_bgLayer:addChild(bgSprite)

	bgSize = bgSprite:getContentSize()

	local topSprite = CCSprite:create("images/item/equipinfo/topbg.png")
	topSprite:setAnchorPoint(ccp(0.5, 1))
	topSprite:setPosition(ccp(bgSize.width/2, bgSize.height))
	topSprite:setScale(g_fScaleX)
	bgSprite:addChild(topSprite,_zorder)

	topSize = topSprite:getContentSize()

	local petCV = CCLabelTTF:create(GetLocalizeStringBy("key_2955"), g_sFontPangWa ,35)
	petCV:setColor(ccc3(0xff,0xe4,0x00))
	petCV:setAnchorPoint(ccp(0.5,0.5))
	petCV:setPosition(ccp(topSize.width/2,topSize.height/2))
	topSprite:addChild(petCV)

	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	topSprite:addChild(menu)

	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(1, 0.5))
    closeBtn:setPosition(ccp(topSprite:getContentSize().width*1.01, topSprite:getContentSize().height*0.54))
    closeBtn:registerScriptTapHandler(closeAction)
	menu:addChild(closeBtn)
	menu:setTouchPriority(_priority-1)
end

local function  createPetPart()
	--宠物
	local bluePosY = bgSize.height - topSize.height*g_fScaleX - 305*MainScene.elementScale

	local blueButtom = CCSprite:create("images/pet/pet_buttom.png")
	blueButtom:setAnchorPoint(ccp(0.5,0.5))
	blueButtom:setPosition(ccp(bgSize.width/2,bluePosY))
	blueButtom:setScale(g_fScaleX)
	bgSprite:addChild(blueButtom)

	blueSize = blueButtom:getContentSize()

	require "script/ui/pet/PetUtil"
	local petBodyImage = PetUtil.getPetIMGById(_petInfo.petDesc.id,1)
	petBodyImage:setAnchorPoint(ccp(0.5,0))
	petBodyImage:setPosition(ccp(blueSize.width/2,blueSize.height/2-20))
	petBodyImage:setScale(0.7)
	blueButtom:addChild(petBodyImage)

	--四个花纹
	local huaOne = CCSprite:create("images/hunt/hua.png")
	local huaOnePosX = bgSize.width - 55*MainScene.elementScale
	local huaOnePosY = bgSize.height - topSize.height*g_fScaleX - 10*MainScene.elementScale
	huaOne:setAnchorPoint(ccp(1,1))
	huaOne:setPosition(ccp(huaOnePosX,huaOnePosY))
	huaOne:setScale(g_fScaleX)
	bgSprite:addChild(huaOne)

	local huaSize = huaOne:getContentSize()

	local huaTwo = CCSprite:create("images/hunt/hua.png")
	local huaTwoPosX = huaOnePosX - huaSize.height*g_fScaleX
	local huaTwoPosY = bgSize.height - topSize.height*g_fScaleX - 325*MainScene.elementScale
	huaTwo:setRotation(90)
	huaTwo:setAnchorPoint(ccp(1,0))
	huaTwo:setPosition(ccp(huaTwoPosX,huaTwoPosY))
	huaTwo:setScale(g_fScaleX)
	bgSprite:addChild(huaTwo)

	local huaThree = CCSprite:create("images/hunt/hua.png")
	local huaThreePosX = 55*MainScene.elementScale + huaSize.width*g_fScaleX
	local huaThreePosY = huaTwoPosY + huaSize.height*g_fScaleX
	huaThree:setRotation(180)
	huaThree:setAnchorPoint(ccp(0,0))
	huaThree:setPosition(ccp(huaThreePosX,huaThreePosY))
	huaThree:setScale(g_fScaleX)
	bgSprite:addChild(huaThree)

	local huaFour = CCSprite:create("images/hunt/hua.png")
	local huaFourPosX = 55*MainScene.elementScale
	local huaFourPosY = huaOnePosY - huaSize.width*g_fScaleX
	huaFour:setRotation(270)
	huaFour:setAnchorPoint(ccp(0,1))
	huaFour:setPosition(ccp(huaFourPosX,huaFourPosY))
	huaFour:setScale(g_fScaleX)
	bgSprite:addChild(huaFour)

	--宠物图片等等
	local namePosY = bgSize.height - topSize.height*g_fScaleX - 3*MainScene.elementScale
	local nameBg = CCScale9Sprite:create("images/pet/pet/bottom.png")
	nameBg:setContentSize(CCSizeMake(268, 38))
	nameBg:setAnchorPoint(ccp(0.5,1))
	nameBg:setPosition(ccp(bgSize.width/2,namePosY))
	nameBg:setScale(g_fScaleX)
	bgSprite:addChild(nameBg)

	local nameSize = nameBg:getContentSize()

	local lvSprite = CCSprite:create("images/common/lv.png")
	local lvNum
	if _petId ~= nil then
		lvNum = CCLabelTTF:create(tostring(_petInfo.level), g_sFontPangWa ,18)
	else
		lvNum = CCLabelTTF:create("1", g_sFontPangWa ,18)
	end
	lvNum:setColor(ccc3(0xff,0xf6,0x00))
	local petName = CCLabelTTF:create("  " .. tostring(_petInfo.petDesc.roleName), g_sFontPangWa ,25)
	require "script/ui/hero/HeroPublicLua"
	petName:setColor(HeroPublicLua.getCCColorByStarLevel(_petInfo.petDesc.quality))
	-- 品阶
	local evolveLv = 0
	if _petInfo.va_pet then
		evolveLv = _petInfo.va_pet.evolveLevel or 0
	end
	local evolveLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1089",evolveLv),g_sFontPangWa,21,1,ccc3(0,0,0),type_shadow)
	evolveLabel:setColor(ccc3(0xff,0xf6,0x00))
	evolveLabel:setAnchorPoint(ccp(0,0.5))
    evolveLabel:setPosition(ccpsprite(1.1,0.5,petName))
    petName:addChild(evolveLabel)
	local nameUpper = BaseUI.createHorizontalNode({lvSprite,lvNum,petName})
	nameUpper:setAnchorPoint(ccp(0.5,0.5))
	nameUpper:setPosition(ccp(nameSize.width/2 - evolveLabel:getContentSize().width / 2,nameSize.height/2))
	nameBg:addChild(nameUpper)

	local arrowPosY = namePosY - nameSize.height*g_fScaleX - MainScene.elementScale

	-- local arrow = CCSprite:create("images/common/star_bg.png")
	-- arrow:setAnchorPoint(ccp(0.5,1))
	-- arrow:setPosition(ccp(bgSize.width/2,arrowPosY))
	-- arrow:setScale(g_fScaleX)
	-- bgSprite:addChild(arrow)

	-- local arrowSize = arrow:getContentSize()
	-- local halfSize = arrowSize.width/2
	-- local starPosOddY = {halfSize,halfSize-30,halfSize+30,halfSize-60,halfSize+60,halfSize-90,halfSize+90}
	-- local starPosEvenY = {halfSize-15,halfSize+15,halfSize-45,halfSize+45,halfSize-75,halfSize+75}

	-- local usePos = {}

	-- if tonumber(_petInfo.petDesc.quality)%2 == 0 then
	-- 	usePos = starPosEvenY
	-- else
	-- 	usePos = starPosOddY
	-- end

	-- for i = 1,tonumber(_petInfo.petDesc.quality) do
	-- 	local starSprite = CCSprite:create("images/common/star.png")
	-- 	starSprite:setAnchorPoint(ccp(0.5,0.5))
	-- 	starSprite:setPosition(ccp(usePos[i],arrowSize.height/2))
	-- 	arrow:addChild(starSprite)
	-- end
end


local function createMenuPart()
	local underMenu = CCMenu:create()
	underMenu:setPosition(ccp(0,0))
	underMenu:setTouchPriority(_priority-1)
	bgSprite:addChild(underMenu)

	if _position == "bagLayer" then
		-- local nurseButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1121"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		-- nurseButton:setAnchorPoint(ccp(0, 0))
	 --    nurseButton:setPosition(ccp(85*MainScene.elementScale, 25*MainScene.elementScale))
	 --    nurseButton:registerScriptTapHandler(gotoNurse)
		-- underMenu:addChild(nurseButton)
		-- nurseButton:setScale(g_fScaleX)

		-- local understandButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_2875"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		-- understandButton:setAnchorPoint(ccp(1, 0))
	 --    understandButton:setPosition(ccp(bgSize.width-85*MainScene.elementScale, 25*MainScene.elementScale))
	 --    understandButton:registerScriptTapHandler(gotoUnderstand)
		-- underMenu:addChild(understandButton)
		-- understandButton:setScale(g_fScaleX)
		local closeButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_2474"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		closeButton:setAnchorPoint(ccp(0.5, 0))
	    closeButton:setPosition(ccp(bgSize.width/2, 25*MainScene.elementScale))
	    closeButton:registerScriptTapHandler(closeAction)
		underMenu:addChild(closeButton)
		closeButton:setScale(g_fScaleX)
	elseif _position == "mainLayer" then
		local changeButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_3348"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		changeButton:setAnchorPoint(ccp(0, 0))
	    changeButton:setPosition(ccp(85*MainScene.elementScale, 25*MainScene.elementScale))
	    changeButton:registerScriptTapHandler(gotoChange)
		underMenu:addChild(changeButton)
		changeButton:setScale(g_fScaleX)

		local takeOffButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_2933"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		takeOffButton:setAnchorPoint(ccp(1, 0))
	    takeOffButton:setPosition(ccp(bgSize.width-85*MainScene.elementScale, 25*MainScene.elementScale))
	    takeOffButton:registerScriptTapHandler(gotoTakeOff)
		underMenu:addChild(takeOffButton)
		takeOffButton:setScale(g_fScaleX)
		-- local closeButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_2474"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		-- closeButton:setAnchorPoint(ccp(0.5, 0))
	 --    closeButton:setPosition(ccp(bgSize.width/2, 25*MainScene.elementScale))
	 --    closeButton:registerScriptTapHandler(closeAction)
		-- underMenu:addChild(closeButton)
		-- closeButton:setScale(g_fScaleX)
	elseif _position == "fragLayer" then
		local closeButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_2474"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		closeButton:setAnchorPoint(ccp(0.5, 0))
	    closeButton:setPosition(ccp(bgSize.width/2, 25*MainScene.elementScale))
	    closeButton:registerScriptTapHandler(closeAction)
		underMenu:addChild(closeButton)
		closeButton:setScale(g_fScaleX)
	end

	buttonSize = CCSizeMake(200,73)
end

local function getSkillHeight()
	local allHeight = 0
	local TNum = 0
	local PNum = 0
	local NNum = 0
	local maxSkill = 0
	for k,v in pairs(_petInfo.va_pet) do
		if tostring(k) == "skillTalent" then
			if (not table.isEmpty(v)) then
				-- local petDBTable = DB_Pet_skill.getDataById(v[1].id)
				-- local needSkillReturn = lua_string_split(petDBTable.specialCondition,",")
				for g = 1,#v do
					if tonumber(v[g].id) ~= 0 then
						TNum = TNum+1
					end
				end
				allHeight = allHeight + 195 + (TNum-1)*140
			end
		elseif tostring(k) == "skillProduct" then
			if not table.isEmpty(v) and (tonumber(v[1].id) ~= 0) then
				allHeight = allHeight + 230 
				PNum = 1
			end
		elseif tostring(k) == "skillNormal" then
			maxSkill = 1
			local j = _petInfo.petDesc.ColumLimit
			if not table.isEmpty(v) then
				for i = 1,#v do
					if tonumber(v[i].id) ~= 0 then
						local tempTable = PetUtil.getNormalSkill(v[i].id,v[i].level)
						if #tempTable > maxSkill then
							maxSkill = #tempTable
						end
					end
				end
			end
			allHeight = math.ceil((j)/4)*(245+(maxSkill-1)*30) + allHeight
			NNum = j
		end 
	end

	return allHeight,TNum,PNum,NNum,maxSkill
end

local function getChinese(recoverTime)
	local hour = math.floor(recoverTime/3600)
	local min = math.floor((recoverTime - hour*3600)/60)
	local sec = tonumber(recoverTime - hour*3600 - min*60)

	if hour > 0 then
		if (min == 0) and (sec == 0) then
			return GetLocalizeStringBy("key_3063") .. hour .. GetLocalizeStringBy("key_1769")
		end
		if (sec == 0) and (min > 0) then
			return GetLocalizeStringBy("key_3063") .. hour .. GetLocalizeStringBy("key_1769") .. min .. GetLocalizeStringBy("key_2164")
		end
		if (min == 0) and (sec > 0) then
			return GetLocalizeStringBy("key_3063") .. hour .. GetLocalizeStringBy("key_1769") .. sec .. GetLocalizeStringBy("key_3240")
		end
		if (min > 0) and (sec > 0) then
			return GetLocalizeStringBy("key_3063") .. hour .. GetLocalizeStringBy("key_1769") .. min .. GetLocalizeStringBy("key_2164") .. sec .. GetLocalizeStringBy("key_3240")
		end
	elseif (hour == 0) and (min > 0) then
		if sec == 0 then
			return GetLocalizeStringBy("key_3063") .. min .. GetLocalizeStringBy("key_3249")
		end
		if sec > 0 then
			return GetLocalizeStringBy("key_3063") .. min .. GetLocalizeStringBy("key_2164") .. sec .. GetLocalizeStringBy("key_3240")
		end
	elseif (hour == 0) and (min == 0) then
		if sec > 0 then
			return GetLocalizeStringBy("key_3063") .. sec .. GetLocalizeStringBy("key_3240")
		end
		if sec == 0 then
			return ""
		end
	end
end

local function  createMainScrollView()
	local contentScrollView = CCScrollView:create()
	contentScrollView:setViewSize(CCSizeMake(scrollBg:getContentSize().width, scrollBg:getContentSize().height))
	contentScrollView:setDirection(kCCScrollViewDirectionVertical)
	contentScrollView:setTouchPriority(_priority-5)
	local layer = CCLayer:create()
	contentScrollView:setContainer(layer)

	--得到layer的高度，天赋技能数量，特殊技能数量，普通技能数量

	local layerScrollHeight,talentNum,produceNum,normalNum,maxNormal= getSkillHeight()

	layer:setContentSize(CCSizeMake(scrollBg:getContentSize().width,layerScrollHeight))
	layer:setPosition(ccp(0,scrollBg:getContentSize().height-layerScrollHeight))

	contentScrollView:setPosition(ccp(0,0))

	scrollBg:addChild(contentScrollView)

	local beginHeight = layer:getContentSize().height
	local layerWidth = layer:getContentSize().width
	if produceNum > 0 then
		local specialButtom = CCScale9Sprite:create(CCRectMake(35, 30, 8, 10),"images/pet/pet/pet_under.png")
		specialButtom:setContentSize(CCSizeMake(575,155))
		specialButtom:setAnchorPoint(ccp(0.5,1))
		specialButtom:setAnchorPoint(ccp(0.5,1))
		specialButtom:setPosition(ccp(layerWidth/2,beginHeight - 35))
		layer:addChild(specialButtom)

		local sSkill = CCSprite:create("images/pet/pet/special_skill.png")
		sSkill:setAnchorPoint(ccp(0.5,0.5))
		sSkill:setPosition(ccp(specialButtom:getContentSize().width/2,specialButtom:getContentSize().height-5))
		specialButtom:addChild(sSkill)
		
		beginHeight = beginHeight - 195

		local sDes = CCLabelTTF:create(GetLocalizeStringBy("key_1123"), g_sFontPangWa ,25)
		sDes:setColor(ccc3(0xff,0xff,0xff))
		sDes:setAnchorPoint(ccp(0.5,1))
		sDes:setPosition(ccp(sSkill:getContentSize().width/2,sSkill:getContentSize().height-18))
		sSkill:addChild(sDes)

		--技能头像
		local produceLevel = PetData.getPetSkillLevel(_petInfo.petid)
		local sHead = PetUtil.getProduceIcon(_petInfo.va_pet.skillProduct[1].id,produceLevel )
		sHead:setAnchorPoint(ccp(0,1))
		sHead:setPosition(ccp(35,specialButtom:getContentSize().height-15))
		specialButtom:addChild(sHead)

		local petDBTable = DB_Pet_skill.getDataById(_petInfo.va_pet.skillProduct[1].id)

		--名字
		local sName = CCLabelTTF:create(petDBTable.name, g_sFontPangWa ,18)
		sName:setColor(HeroPublicLua.getCCColorByStarLevel(petDBTable.skillQuality))
		sName:setAnchorPoint(ccp(0.5,1))
		sName:setPosition(ccp(sHead:getContentSize().width/2,0))
		sHead:addChild(sName)

		--级别
		local lvSprite = CCSprite:create("images/common/lv.png")
		local sLvNum = CCLabelTTF:create("" .. produceLevel , g_sFontName ,21)
		sLvNum:setColor(ccc3(0xff,0xf6,0x00))

		local lvFinal = BaseUI.createHorizontalNode({lvSprite,sLvNum})
		lvFinal:setAnchorPoint(ccp(0.5,1))
		lvFinal:setPosition(ccp(sHead:getContentSize().width/2,-20))
		sHead:addChild(lvFinal)

		--描述
		local produceTime = PetUtil.getProduceTime(_petInfo.va_pet.skillProduct[1].id, produceLevel) 
		local chineseTime = getChinese(produceTime)

		local rName,rNum = PetUtil.getProduceName(_petInfo.va_pet.skillProduct[1].id,produceLevel )

		local plusChinese = CCLabelTTF:create(chineseTime .. GetLocalizeStringBy("key_2414"), g_sFontName ,23)
		plusChinese:setColor(ccc3(0xff,0xff,0xff))
		local numChinese = CCLabelTTF:create(rNum .. " ", g_sFontName ,28)
		numChinese:setColor(ccc3(0xff,0xf6,0x00))
		local typeChinese = CCLabelTTF:create(rName, g_sFontName ,23)
		typeChinese:setColor(ccc3(0xff,0xff,0xff))

		if not PetData.isPetUpByid(_petId) then
			plusChinese:setColor(ccc3(0x2e,0x2e,0x2e))
			numChinese:setColor(ccc3(0x2e,0x2e,0x2e))
			typeChinese:setColor(ccc3(0x2e,0x2e,0x2e))
		end 

		local produceSay = BaseUI.createHorizontalNode({plusChinese,numChinese,typeChinese})
		produceSay:setAnchorPoint(ccp(0,0.5))
		produceSay:setPosition(ccp(150,specialButtom:getContentSize().height/2))
		specialButtom:addChild(produceSay)
	end
	if talentNum > 0 then
		--local needSkillReturn = lua_string_split(petDBTable.specialCondition,",")

		--local custNum = 40*(math.ceil(#needSkillReturn/2)-1)

		local talentButtom = CCScale9Sprite:create(CCRectMake(35, 30, 8, 10),"images/pet/pet/pet_under.png")
		talentButtom:setContentSize(CCSizeMake(575,140 + (talentNum-1)*140))
		talentButtom:setAnchorPoint(ccp(0.5,1))
		talentButtom:setPosition(ccp(layerWidth/2,beginHeight-20))
		layer:addChild(talentButtom)

		local tSkill = CCSprite:create("images/pet/pet/talent_skill.png")
		tSkill:setAnchorPoint(ccp(0.5,0.5))
		tSkill:setPosition(ccp(talentButtom:getContentSize().width/2,talentButtom:getContentSize().height-10))
		talentButtom:addChild(tSkill)
		
		local tDes = CCLabelTTF:create(GetLocalizeStringBy("key_1506"), g_sFontPangWa ,25)
		tDes:setColor(ccc3(0xff,0xff,0xff))
		tDes:setAnchorPoint(ccp(0.5,1))
		tDes:setPosition(ccp(tSkill:getContentSize().width/2,tSkill:getContentSize().height-5 ))
		tSkill:addChild(tDes)

		beginHeight = beginHeight - 160 - (talentNum-1)*140

		local colorTableName = {}
		local colorTableDes = {}

		for i = 1,talentNum do
			local petDBTable = DB_Pet_skill.getDataById(_petInfo.va_pet.skillTalent[i].id)

			local tHead = PetUtil.getSkillIcon(_petInfo.va_pet.skillTalent[i].id,_petInfo.va_pet.skillTalent[i].level)
			tHead:setAnchorPoint(ccp(0,1))
			tHead:setPosition(ccp(35,talentButtom:getContentSize().height-15- 140*(i-1)))
			talentButtom:addChild(tHead)

			local tName = CCLabelTTF:create(petDBTable.name, g_sFontPangWa ,18)
			tName:setColor(HeroPublicLua.getCCColorByStarLevel(petDBTable.skillQuality))
			tName:setAnchorPoint(ccp(0.5,1))
			tName:setPosition(ccp(tHead:getContentSize().width/2,0))
			tHead:addChild(tName)

			local tDes = CCLabelTTF:create(tostring(petDBTable.des),g_sFontName,23,CCSizeMake(415, 95), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
			tDes:setColor(ccc3(0x00,0xff,0x18))
			tDes:setAnchorPoint(ccp(0,1))
			tDes:setPosition(ccp(150,talentButtom:getContentSize().height-35-130*(i-1)))
			talentButtom:addChild(tDes)

			table.insert(colorTableName,tName)
			table.insert(colorTableDes,tDes)
		end

		-- require "db/DB_Pet"

		-- local before = ""

		-- local lockTable = {}
		-- local comma = {}

		-- local insetTable = {}
		-- -- local insetTable2 = {}
		-- -- local insetTable3 = {}
		-- local plusTable = {}

		-- local needNum = 0

		-- print(GetLocalizeStringBy("key_1214"),_petInfo.va_pet.skillTalent[1].id)

		-- if tonumber(petDBTable.isSpecial) == 1 then
		-- 	before = GetLocalizeStringBy("key_1304")
		-- 	local skillReturn = lua_string_split(petDBTable.specialCondition,",")
		-- 	for i = 1,#skillReturn do
		-- 		needNum = needNum+1
		-- 		print(GetLocalizeStringBy("key_3298"),skillReturn[i])
		-- 		print(DB_Pet_skill.getDataById(skillReturn[i]).name)
		-- 		local someSkill = CCLabelTTF:create(DB_Pet_skill.getDataById(skillReturn[i]).name .. GetLocalizeStringBy("key_1084"), g_sFontName ,23)
		-- 		someSkill:setColor(ccc3(0x00,0xe4,0xff))
		-- 		local someComma = CCLabelTTF:create("，", g_sFontName ,23)
		-- 		someComma:setColor(ccc3(0xff,0xff,0xff))
		-- 		comma[i] = someComma
		-- 		lockTable[i] = someSkill
		-- 	end
		-- elseif tonumber(petDBTable.isSpecial) == 2 then
		-- 	before = GetLocalizeStringBy("key_1984")
		-- 	local skillReturn = lua_string_split(petDBTable.specialCondition,",")
		-- 	for i = 1,#skillReturn do
		-- 		needNum = needNum +1
		-- 		local somePet = CCLabelTTF:create(DB_Pet.getDataById(skillReturn[i]).roleName .. GetLocalizeStringBy("key_1893"), g_sFontName ,23)
		-- 		somePet:setColor(ccc3(0x00,0xe4,0xff))
		-- 		local someComma = CCLabelTTF:create("，", g_sFontName ,23)
		-- 		someComma:setColor(ccc3(0xff,0xff,0xff))
		-- 		comma[i] = someComma
		-- 		lockTable[i] = somePet
		-- 	end
		-- end

		-- local unstand = CCLabelTTF:create(before,g_sFontName,23)
		-- unstand:setColor(ccc3(0xff,0xff,0xff))

		-- table.insert(insetTable,unstand)

		-- local addNSomething
		-- local addNLevel
		-- local addSSomething
		-- local addSLevel
		-- local addComma = CCLabelTTF:create("，", g_sFontName ,23)
		-- addComma:setColor(ccc3(0xff,0xff,0xff))

		-- if (petDBTable.addNormalSkillLevel ~= nil) and (petDBTable.addSpecialSkillLevel == nil) then
		-- 	addNSomething = CCLabelTTF:create(GetLocalizeStringBy("key_1042"),g_sFontName,23)
		-- 	addNSomething:setColor(ccc3(0xff,0xff,0xff))
		-- 	addNLevel = CCLabelTTF:create("+" .. petDBTable.addNormalSkillLevel,g_sFontName,23)
		-- 	addNLevel:setColor(ccc3(0x00,0xff,0x18))
		-- 	table.insert(plusTable,addNSomething)
		-- 	table.insert(plusTable,addNLevel)
		-- end
		-- if (petDBTable.addSpecialSkillLevel ~= nil) and (petDBTable.addNormalSkillLevel == nil) then
		-- 	addSSomething = CCLabelTTF:create(GetLocalizeStringBy("key_2925"),g_sFontName,23)
		-- 	addSSomething:setColor(ccc3(0xff,0xff,0xff))
		-- 	addSLevel = CCLabelTTF:create("+" .. petDBTable.addSpecialSkillLevel,g_sFontName,23)
		-- 	addSLevel:setColor(ccc3(0x00,0xff,0x18))
		-- 	table.insert(plusTable,addNSomething)
		-- 	table.insert(plusTable,addNLevel)
		-- end
		-- if (petDBTable.addSpecialSkillLevel ~= nil) and (petDBTable.addNormalSkillLevel ~= nil) then
		-- 	addNSomething = CCLabelTTF:create(GetLocalizeStringBy("key_1042"),g_sFontName,23)
		-- 	addNSomething:setColor(ccc3(0xff,0xff,0xff))
		-- 	addNLevel = CCLabelTTF:create("+" .. petDBTable.addNormalSkillLevel,g_sFontName,23)
		-- 	addNLevel:setColor(ccc3(0x00,0xff,0x18))
		-- 	table.insert(plusTable,addNSomething)
		-- 	table.insert(plusTable,addNLevel)
		-- 	table.insert(plusTable,addComma)
		-- 	addSSomething = CCLabelTTF:create(GetLocalizeStringBy("key_2925"),g_sFontName,23)
		-- 	addSSomething:setColor(ccc3(0xff,0xff,0xff))
		-- 	addSLevel = CCLabelTTF:create("+" .. petDBTable.addSpecialSkillLevel,g_sFontName,23)
		-- 	addSLevel:setColor(ccc3(0x00,0xff,0x18))
		-- 	table.insert(plusTable,addSSomething)
		-- 	table.insert(plusTable,addSLevel)
		-- end

		-- local lineSkillNum = 1

		-- for i = 1,needNum,2 do
		-- 	table.insert(insetTable,lockTable[i])
		-- 	table.insert(insetTable,comma[i])
		-- 	if lockTable[i+1] ~= nil then
		-- 		table.insert(insetTable,lockTable[i+1])
		-- 		table.insert(insetTable,comma[i+1])
		-- 	end
		-- 	local condiction = BaseUI.createHorizontalNode(insetTable)
		-- 	condiction:setAnchorPoint(ccp(0,1))
		-- 	condiction:setPosition(ccp(150,talentButtom:getContentSize().height-40*lineSkillNum))
		-- 	lineSkillNum = lineSkillNum+1
		-- 	talentButtom:addChild(condiction)

		-- 	insetTable = nil
		-- 	insetTable = {}
		-- end

		-- local plusBenefit = BaseUI.createHorizontalNode(plusTable)
		-- plusBenefit:setAnchorPoint(ccp(0,1))
		-- plusBenefit:setPosition(ccp(150,talentButtom:getContentSize().height-40*lineSkillNum))
		-- talentButtom:addChild(plusBenefit)


		for i = 1,talentNum do
			if not PetData.isSkillEffect(_petInfo.va_pet.skillTalent[i].id,_petId) then
				colorTableName[i]:setColor(ccc3(0x2e,0x2e,0x2e))
				-- unstand:setColor(ccc3(0x2e,0x2e,0x2e))
				-- for i = 1,needNum do
				-- 	lockTable[i]:setColor(ccc3(0x2e,0x2e,0x2e))
				-- 	comma[i]:setColor(ccc3(0x2e,0x2e,0x2e))
				-- end
				-- for k,v in pairs(plusTable) do
				-- 	v:setColor(ccc3(0x2e,0x2e,0x2e))
				-- end
				colorTableDes[i]:setColor(ccc3(0x2e,0x2e,0x2e))
			end
		end
	end
	if normalNum > 0 then
		local lineNum = math.ceil(normalNum/4)-1

		local normalButtom = CCScale9Sprite:create(CCRectMake(35, 30, 8, 10),"images/pet/pet/pet_under.png")
		normalButtom:setContentSize(CCSizeMake(575,195+30*(maxNormal-1)+(150+30*(maxNormal-1))*lineNum))
		normalButtom:setAnchorPoint(ccp(0.5,1))
		normalButtom:setPosition(ccp(layerWidth/2,beginHeight-20))
		layer:addChild(normalButtom)

		local nSkill = CCSprite:create("images/pet/pet/normal_skill.png")
		nSkill:setAnchorPoint(ccp(0.5,0.5))
		nSkill:setPosition(ccp(normalButtom:getContentSize().width/2,normalButtom:getContentSize().height-10))
		normalButtom:addChild(nSkill)

		local nDes = CCLabelTTF:create(GetLocalizeStringBy("key_1808"), g_sFontPangWa ,25)
		nDes:setColor(ccc3(0xff,0xff,0xff))
		nDes:setAnchorPoint(ccp(0.5,1))
		nDes:setPosition(ccp(nSkill:getContentSize().width/2,nSkill:getContentSize().height-5))
		nSkill:addChild(nDes)

		local bPos = 35
		local bHei = normalButtom:getContentSize().height - 35

		local weightPlus = (normalButtom:getContentSize().width - 70 - 90*4)/3+90
		local heightPlus = 150 + 30*(maxNormal-1)

		local normalInfo = _petInfo.va_pet.skillNormal

		local j = 0
		local noOver = true

		for i = 1 , tonumber(normalNum) do
			j = j+1
			local xPos = j%4
			if xPos == 0 then
				xPos = 4
			end
			
			local beginPos = bPos + (xPos-1)*weightPlus
			local beginHei = bHei - heightPlus*(math.ceil(j/4)-1)

			if i == #normalInfo +1 then
				noOver = false
			end

			if noOver and tonumber(normalInfo[i].id) ~= 0 then
				local gray = CCScale9Sprite:create("images/pet/black_white.png")
				gray:setPreferredSize(CCSizeMake(90,71+25*(maxNormal-1)))
				gray:setAnchorPoint(ccp(0,1))
				gray:setPosition(ccp(beginPos,beginHei-70))
				normalButtom:addChild(gray)

				local addLevel = PetData.getAddSkillByTalent( _petId).addNormalSkillLevel

				-- 宠物进阶的技能等级加成
			    local evolveLv = tonumber(_petInfo.va_pet.evolveLevel) or 0
			    local evolveAddSkillLv = PetData.getPetEvolveSkillLevel(_petInfo,evolveLv)
			    print("PetInfoLayer createMainScrollView evolveAddSkillLv => ",evolveAddSkillLv)

				local nhead = PetUtil.getSkillIcon(normalInfo[i].id,normalInfo[i].level + addLevel + evolveAddSkillLv,normalInfo[i].status)
				nhead:setAnchorPoint(ccp(0,1))
				nhead:setPosition(ccp(beginPos,beginHei))
				normalButtom:addChild(nhead)

				local petDBTable = DB_Pet_skill.getDataById(_petInfo.va_pet.skillNormal[i].id)

				local nName = CCLabelTTF:create(petDBTable.name, g_sFontPangWa ,18)
				nName:setColor(HeroPublicLua.getCCColorByStarLevel(petDBTable.skillQuality))
				nName:setAnchorPoint(ccp(0.5,1))
				nName:setPosition(ccp(nhead:getContentSize().width/2,0))
				nhead:addChild(nName)

				local plusTable = PetUtil.getNormalSkill(normalInfo[i].id,normalInfo[i].level + addLevel)
				for i = 1,#plusTable do
					local plusName = CCLabelTTF:create(plusTable[i].affixDesc.displayName .. " ", g_sFontName ,18)
					plusName:setColor(ccc3(0xff,0xff,0xff))
					local plusNum = CCLabelTTF:create("+" .. plusTable[i].displayNum, g_sFontName ,18)
					plusNum:setColor(ccc3(0x00,0xff,0x18))

					local plusSay = BaseUI.createHorizontalNode({plusName,plusNum})
					plusSay:setAnchorPoint(ccp(0.5,1))
					plusSay:setPosition(ccp(nhead:getContentSize().width/2,-22*i))
					nhead:addChild(plusSay)
				end
			elseif noOver and tonumber(normalInfo[i].id) == 0 then
				local nhead = CCSprite:create("images/formation/potential/officer_11.png")
				nhead:setAnchorPoint(ccp(0,1))
				nhead:setPosition(ccp(beginPos,beginHei))
				normalButtom:addChild(nhead)
			else
				local nhead = PetUtil.getLockIcon()
				nhead:setAnchorPoint(ccp(0,1))
				nhead:setPosition(ccp(beginPos,beginHei))
				normalButtom:addChild(nhead)
			end
		end
	end
end

local function countLayerHeight(str)
	local strLen = 0
	local i =1
	local enter = 0
	while i<= #str do
		if(string.byte(str,i) > 127) then
			-- 汉字
			strLen = strLen + 1
			i= i+ 3
		elseif(string.byte(str,i) == 10) then
			--换行符
			i =i+1
			enter = enter+1
		elseif(string.byte(str,i) == 32) then
			strLen = strLen + 1/3
			i = i+1
		else
			--英文
			i =i+1
			strLen = strLen + 1
		end
	end

	--21号字
	local linNum = math.ceil(strLen/(560/23))+enter
	local linHeight = linNum*23

	return linHeight
end

local function createViceScrollView()
	local contentScrollView = CCScrollView:create()
	contentScrollView:setViewSize(CCSizeMake(scrollBg:getContentSize().width, scrollBg:getContentSize().height))
	contentScrollView:setDirection(kCCScrollViewDirectionVertical)
	contentScrollView:setTouchPriority(_priority-5)
	local layer = CCLayer:create()
	contentScrollView:setContainer(layer)

	--字符读取

	local PString = _petInfo.petDesc.produceDes
	local NString = _petInfo.petDesc.normalDes

	--处理天赋技能高度用

	local allTalentTable = PetUtil.getTalentSkillByTmpId(_pet_tmpl)

	local talentAmount = 0

	for i = 1,#allTalentTable do
		if tonumber(allTalentTable[i]) ~= 0 then
			talentAmount = talentAmount+1
		end
	end

	--字符高度处理

	local produceHeight = countLayerHeight(tostring(PString))
	local normalHeight = countLayerHeight(tostring(NString))

	local layerScrollHeight = produceHeight + normalHeight + 140 + (talentAmount-1)*140 + 250

	layer:setContentSize(CCSizeMake(scrollBg:getContentSize().width,layerScrollHeight))
	layer:setPosition(ccp(0,scrollBg:getContentSize().height-layerScrollHeight))

	contentScrollView:setPosition(ccp(0,0))

	scrollBg:addChild(contentScrollView)

	local beginHeight = layer:getContentSize().height
	local beginWidth = layer:getContentSize().width/2

	--特殊技能

	local specialButtom = CCScale9Sprite:create(CCRectMake(35, 30, 8, 10),"images/pet/pet/pet_under.png")
	specialButtom:setContentSize(CCSizeMake(575,70+produceHeight))
	specialButtom:setAnchorPoint(ccp(0.5,1))
	specialButtom:setAnchorPoint(ccp(0.5,1))
	specialButtom:setPosition(ccp(beginWidth,beginHeight - 35))
	layer:addChild(specialButtom)

	local sSkill = CCSprite:create("images/pet/pet/special_skill.png")
	sSkill:setAnchorPoint(ccp(0.5,0.5))
	sSkill:setPosition(ccp(specialButtom:getContentSize().width/2,specialButtom:getContentSize().height-5))
	specialButtom:addChild(sSkill)

	local sDes = CCLabelTTF:create(GetLocalizeStringBy("key_1123"), g_sFontPangWa ,25)
	sDes:setColor(ccc3(0xff,0xff,0xff))
	sDes:setAnchorPoint(ccp(0.5,1))
	sDes:setPosition(ccp(sSkill:getContentSize().width/2,sSkill:getContentSize().height-18))
	sSkill:addChild(sDes)

	beginHeight = beginHeight - 45-specialButtom:getContentSize().height

	local specicalDes = CCLabelTTF:create(tostring(PString), g_sFontName, 23, CCSizeMake(500, produceHeight), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	specicalDes:setAnchorPoint(ccp(0.5,1))
	specicalDes:setPosition(ccp(specialButtom:getContentSize().width/2,specialButtom:getContentSize().height-40))
	specialButtom:addChild(specicalDes)

	--天赋技能

	if talentAmount > 0 then
		local talentButtom = CCScale9Sprite:create(CCRectMake(35, 30, 8, 10),"images/pet/pet/pet_under.png")
		talentButtom:setContentSize(CCSizeMake(575,140 + (talentAmount-1)*140))
		talentButtom:setAnchorPoint(ccp(0.5,1))
		talentButtom:setPosition(ccp(beginWidth,beginHeight-20))
		layer:addChild(talentButtom)

		local tSkill = CCSprite:create("images/pet/pet/talent_skill.png")
		tSkill:setAnchorPoint(ccp(0.5,0.5))
		tSkill:setPosition(ccp(talentButtom:getContentSize().width/2,talentButtom:getContentSize().height-10))
		talentButtom:addChild(tSkill)
		
		local tDes = CCLabelTTF:create(GetLocalizeStringBy("key_1506"), g_sFontPangWa ,25)
		tDes:setColor(ccc3(0xff,0xff,0xff))
		tDes:setAnchorPoint(ccp(0.5,1))
		tDes:setPosition(ccp(tSkill:getContentSize().width/2,tSkill:getContentSize().height-5 ))
		tSkill:addChild(tDes)

		for i = 1,#allTalentTable do
			if tonumber(allTalentTable[i]) ~= 0 then
				local petDBTable = DB_Pet_skill.getDataById(allTalentTable[i])

				local tHead = PetUtil.getSkillIcon(petDBTable.id,1)
				tHead:setAnchorPoint(ccp(0,1))
				tHead:setPosition(ccp(35,talentButtom:getContentSize().height-15- 140*(i-1)))
				talentButtom:addChild(tHead)

				local tName = CCLabelTTF:create(petDBTable.name, g_sFontPangWa ,18)
				tName:setColor(ccc3(0x2e,0x2e,0x2e))
				tName:setAnchorPoint(ccp(0.5,1))
				tName:setPosition(ccp(tHead:getContentSize().width/2,0))
				tHead:addChild(tName)

				local tDes = CCLabelTTF:create(petDBTable.des,g_sFontName,23,CCSizeMake(415, 95), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
				tDes:setColor(ccc3(0x2e,0x2e,0x2e))
				tDes:setAnchorPoint(ccp(0,1))
				tDes:setPosition(ccp(150,talentButtom:getContentSize().height-35-130*(i-1)))
				talentButtom:addChild(tDes)
			end
		end

		beginHeight = beginHeight - 160 - (talentAmount-1)*140
	end

	--普通技能

	local normalButtom = CCScale9Sprite:create(CCRectMake(35, 30, 8, 10),"images/pet/pet/pet_under.png")
	normalButtom:setContentSize(CCSizeMake(575,70 + normalHeight))
	normalButtom:setAnchorPoint(ccp(0.5,1))
	normalButtom:setAnchorPoint(ccp(0.5,1))
	normalButtom:setPosition(ccp(beginWidth,beginHeight - 20))
	layer:addChild(normalButtom)

	local nSkill = CCSprite:create("images/pet/pet/normal_skill.png")
	nSkill:setAnchorPoint(ccp(0.5,0.5))
	nSkill:setPosition(ccp(normalButtom:getContentSize().width/2,normalButtom:getContentSize().height-10))
	normalButtom:addChild(nSkill)

	local nDes = CCLabelTTF:create(GetLocalizeStringBy("key_1808"), g_sFontPangWa ,25)
	nDes:setColor(ccc3(0xff,0xff,0xff))
	nDes:setAnchorPoint(ccp(0.5,1))
	nDes:setPosition(ccp(nSkill:getContentSize().width/2,nSkill:getContentSize().height-5))
	nSkill:addChild(nDes)

	local normalDes = CCLabelTTF:create(tostring(NString), g_sFontName, 23, CCSizeMake(500, normalHeight), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	normalDes:setAnchorPoint(ccp(0.5,1))
	normalDes:setPosition(ccp(normalButtom:getContentSize().width/2,normalButtom:getContentSize().height-35))
	normalButtom:addChild(normalDes)
end

local function createScrollViewPart()
	scrollBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	--local scrollBgHeight = g_winSize.height/g_fScaleY - bulletinLayerSize.height - 420 - blueSize.height - buttonSize.height
	local scrollBgHeight = (g_winSize.height - 570*MainScene.elementScale)/g_fScaleX
	scrollBg:setContentSize(CCSizeMake(580,scrollBgHeight))
	scrollBg:setScale(g_fScaleX)
	scrollBg:setAnchorPoint(ccp(0.5,1))
	scrollBg:setPosition(ccp(bgSize.width/2,bgSize.height - topSize.height*g_fScaleX - 305*MainScene.elementScale - blueSize.height/2*g_fScaleX))
	bgSprite:addChild(scrollBg)

	if _petId ~= nil then
		createMainScrollView()
	else 
		createViceScrollView()
	end

	-- 添加一个技能预览按钮， added by zhz

	local menu= CCMenu:create()
	menu:setPosition(ccp(0,0))
	scrollBg:addChild(menu)
	menu:setTouchPriority( _priority-5 )

	local skillViewBtn= CCMenuItemImage:create( "images/pet/btn_skill/btn_skill_n.png","images/pet/btn_skill/btn_skill_h.png")
	skillViewBtn:setPosition(scrollBg:getContentSize().width-19*MainScene.elementScale,scrollBg:getContentSize().height)
	skillViewBtn:setAnchorPoint(ccp(1,0))
	skillViewBtn:registerScriptTapHandler(skillViewAction)
	menu:addChild(skillViewBtn)


end

local function createUI()
	createBackGround()

	createPetPart()

	createMenuPart()

	createScrollViewPart()
end

function showLayer(pet_tmpl ,petId,position,posIndex,z_order,menu_priority, callBackFn)
	init()

	_position = position
	_pet_tmpl = tonumber(pet_tmpl)  
	_petId = tonumber(petId)
	_posIndex = posIndex  -- 从宠物主界面进宠物时，更换和卸载要用
	_zorder = z_order or 999
	_priority = menu_priority or (-550)

	_petInfo = {}
	

	print(GetLocalizeStringBy("key_1697"),_pet_tmpl)

	if _petId ~= nil then
		_petInfo= PetData.getPetInfoById(_petId)
		local petTempId = _petInfo.pet_tmpl
		_petInfo.petDesc = DB_Pet.getDataById(tonumber(petTempId))
		_pet_tmpl= petTempId

	else
		_petInfo.petDesc= DB_Pet.getDataById(tonumber(_pet_tmpl))
	end
	print("petInfo")
	print_t(_petInfo)

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)

	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zorder)

    createUI()
end

------------------------------------------------------[[按钮的回调事件]]---------------------------------------

-- 点击喂养的回调函数，切换到喂养界面
function  gotoNurse()
	
end

-- 领悟技能的回调函数，切换到领悟技能
function gotoUnderstand()
end

-- 更换宠物的回调函数
function  gotoChange()

		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer=nil

	    local layer = PetSelFormatLayer.createLayer( _posIndex )
        MainScene.changeLayer(layer ,"PetSelFormatLayer")

	-- local function callbackFn(  )		
	-- 	require "script/ui/pet/PetMainLayer"
	-- 	print("_posIndex is :", _posIndex)
	-- 	local layer= PetMainLayer.createLayer( _posIndex)
	-- 	MainScene.changeLayer( layer,"PetMainLayer")
	-- end

	-- PetService.squandUpPet( _petId, _posIndex, callbackFn)
end

-- 卸下宠物的回调函数
function gotoTakeOff()

	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer=nil

	local function callbackFn(  )

		require "script/ui/pet/PetMainLayer"
		print("_posIndex is :", _posIndex)
		local layer= PetMainLayer.createLayer( _posIndex)
		MainScene.changeLayer( layer,"PetMainLayer")
	end

	PetService.squandDownPet( _petId, _posIndex, callbackFn)

end

-- 技能预览
function skillViewAction( )

	require "script/ui/pet/PetBasicInfoLayer"
	PetBasicInfoLayer.showLayer(_pet_tmpl , _priority-5,_zorder+1  )
end
