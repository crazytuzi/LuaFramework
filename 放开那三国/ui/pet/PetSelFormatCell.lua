-- Filename：	PetSelFormatCell.lua
-- Author：		zhz
-- Date：		2014-4-10
-- Purpose：		选择宠物上阵的cell

module("PetSelFormatCell", package.seeall)

require "db/DB_Pet"
require "script/utils/BaseUI"
require "script/ui/hero/HeroPublicLua"
require "script/ui/pet/PetData"

local _pos= nil

-- 上阵的回调函数
local function formationAction( tag, item)
	print("tag is : ", tag)
	require "script/ui/pet/PetService"
	
	local petid= tonumber(tag)

	local petInfo= PetData.getPetInfoById(petid)

	-- if()

	local function callbackFn(  )		
		require "script/ui/pet/PetMainLayer"
		print("_pos is :", _pos)
		if(NewGuide.guideClass ==  ksGuidePet) then
       		require "script/guide/PetGuide"
       		PetGuide.changLayer()
	   end
		local layer= PetMainLayer.createLayer( _pos)
		MainScene.changeLayer( layer,"PetMainLayer")
	end

	PetService.squandUpPet(petid, _pos , callbackFn)

end

function petInfoCallBack(tag,obj)
	require "script/ui/pet/PetInfoLayer"
	PetInfoLayer.showLayer(nil,tag,"fragLayer")
end

function createCell(cellValues , pos,aNum)
	local tCell = CCTableViewCell:create()

	local cellBg= CCScale9Sprite:create(CCRectMake(33, 35, 12, 45),"images/pet/pet/bag_bg.png")
	cellBg:setPreferredSize(CCSizeMake(640,210))
	tCell:addChild(cellBg,1, 101)

	local cellSize = cellBg:getContentSize()

	_pos= pos or 0

	local petTid= cellValues.pet_tmpl
	local headIcon = PetUtil.getPetHeadIconByItid(tonumber(petTid),tonumber(cellValues.petid),petInfoCallBack)
	headIcon:setAnchorPoint(ccp(0,0))
	headIcon:setPosition(ccp(20,40))
	cellBg:addChild(headIcon)

	local headSize = headIcon:getContentSize()

	-- 等级
	local nameBg = CCSprite:create("images/pet/pet/name_bg.png")
	nameBg:setPosition(20, cellSize.height-15)
	nameBg:setAnchorPoint(ccp(0,1))
	cellBg:addChild(nameBg)

	local nameBgSize = nameBg:getContentSize()

	local petDB = DB_Pet.getDataById(petTid)

	local levelSprite = CCSprite:create("images/common/lv.png")
	local levelNum = CCLabelTTF:create(tostring(cellValues.level), g_sFontName ,21)
	levelNum:setColor(ccc3(0xff,0xf6,0x00))

	local levelFinal = BaseUI.createHorizontalNode({levelSprite,levelNum})
	levelFinal:setAnchorPoint(ccp(0,0.5))
	levelFinal:setPosition(ccp(10,nameBgSize.height/2))
	nameBg:addChild(levelFinal)

	local petName = CCLabelTTF:create(tostring(petDB.roleName), g_sFontName ,22)
	petName:setColor(HeroPublicLua.getCCColorByStarLevel(petDB.quality))
	petName:setAnchorPoint(ccp(0,0.5))
	petName:setPosition(ccp(100,nameBgSize.height/2))
	nameBg:addChild(petName)

	local starOrignalWidth = 260

	-- for i = 1,petDB.quality do
	-- 	local QStar = CCSprite:create("images/common/star.png")
	-- 	QStar:setAnchorPoint(ccp(0,0.5))
	-- 	QStar:setPosition(ccp(260+(i-1)*35,nameBgSize.height/2))
	-- 	nameBg:addChild(QStar)
	-- end

	local whiteOne = CCScale9Sprite:create("images/pet/pet/bottom_white.png")

	whiteOne:setPreferredSize(CCSizeMake(207,33))
	whiteOne:setAnchorPoint(ccp(0,0.5))
	whiteOne:setPosition(ccp(headSize.width+3,headSize.height/2))
	headIcon:addChild(whiteOne)

	local petQuality = CCLabelTTF:create(GetLocalizeStringBy("key_3083") .. tostring(petDB.petQuality), g_sFontName ,25)
	petQuality:setColor(ccc3(0x48,0x1b,0x00))
	petQuality:setAnchorPoint(ccp(0,0.5))
	petQuality:setPosition(ccp(5,33/2))
	whiteOne:addChild(petQuality)

	local whiteTwo = CCScale9Sprite:create("images/pet/pet/bottom_white.png")
	whiteTwo:setPreferredSize(CCSizeMake(207,33))
	whiteTwo:setAnchorPoint(ccp(0,0))
	whiteTwo:setPosition(ccp(headSize.width+3,-10))
	headIcon:addChild(whiteTwo)

	local fightSprite = CCSprite:create("images/common/fight_value.png")
	local fightNum = CCLabelTTF:create("  " .. PetData.getPetFightForceById(cellValues.petid), g_sFontName ,25)
	fightNum:setColor(ccc3(0x12,0x9b,0x00))

	local fightValue = BaseUI.createHorizontalNode({fightSprite,fightNum})
	fightValue:setAnchorPoint(ccp(0,0.5))
	fightValue:setPosition(ccp(5,33/2))
	whiteTwo:addChild(fightValue)

	local whiteThree = CCScale9Sprite:create("images/pet/pet/bottom_white.png")
	whiteThree:setPreferredSize(CCSizeMake(207,33))
	whiteThree:setAnchorPoint(ccp(0,1))
	whiteThree:setPosition(ccp(headSize.width+3,headSize.height+10))
	headIcon:addChild(whiteThree)

	local skillPointC = CCLabelTTF:create(GetLocalizeStringBy("key_3257"), g_sFontName ,25)
	skillPointC:setColor(ccc3(0x48,0x1b,0x00))
	local skillPointN = CCLabelTTF:create(tostring(cellValues.skill_point),g_sFontName,25)
	skillPointN:setColor(ccc3(0xbd,0x01,0x01))

	local skillPointFinal = BaseUI.createHorizontalNode({skillPointC,skillPointN})
	skillPointFinal:setAnchorPoint(ccp(0,0.5))
	skillPointFinal:setPosition(ccp(5,33/2))
	whiteThree:addChild(skillPointFinal)

	-- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	cellBg:addChild(menuBar,1, 9898)

	local formationBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/green01_n.png","images/common/btn/green01_h.png",CCSizeMake(126,64),GetLocalizeStringBy("key_3011"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	formationBtn:setAnchorPoint(ccp(0,0))
	formationBtn:setPosition(ccp(435, 65))
	formationBtn:registerScriptTapHandler(formationAction)
	menuBar:addChild(formationBtn,1,tonumber(cellValues.petid))

	return tCell
end


