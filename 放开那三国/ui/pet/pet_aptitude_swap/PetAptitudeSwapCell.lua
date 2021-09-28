-- FileName: PetAptitudeSwapCell.lua
-- Author: shengyixian
-- Date: 2016-03-02
-- Purpose: 宠物资质互换选择cell
module("PetAptitudeSwapCell",package.seeall)

require "db/DB_Pet"
require "db/DB_Normal_config"
require "script/utils/BaseUI"
require "script/ui/common/CheckBoxItem"
require "script/utils/LuaUtil"
require "script/ui/pet/PetData"
require "script/utils/BaseUI"
function checkedAction( tag, item)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	PetSwapSelectLayer.setSwapedPetID(tonumber(tag))
	PetSwapSelectLayer.rfcTableView()
end

-- 处理检查checked
function handleSelectedCheckedBtn( checkedBtn )
	local selectedPetID = PetSwapSelectLayer.getSwapedPetID()
	if ( selectedPetID == nil ) then
		checkedBtn:unselected()
	else
		local isSeleced = false
		if ( tonumber(selectedPetID) == tonumber(checkedBtn:getTag()) ) then
			isSeleced = true
		end
		if (isSeleced) then
			checkedBtn:selected()
		else
			checkedBtn:unselected()
		end
	end
end

function createCell(cellValues, touchPriority, pSwapPetID)
	local tCell = CCTableViewCell:create()
	
	local cellBg= CCScale9Sprite:create(CCRectMake(33, 35, 12, 45),"images/pet/pet/bag_bg.png")
	cellBg:setPreferredSize(CCSizeMake(640,160))
	tCell:addChild(cellBg)
	local cellSize = cellBg:getContentSize()

	local petTid= tonumber(cellValues.pet_tmpl)
	-- 头像
	local headIcon = PetUtil.getPetHeadIconByItid(tonumber(petTid),tonumber(cellValues.petid),petInfoCallBack)
	headIcon:setAnchorPoint(ccp(0,0))
	headIcon:setPosition(ccp(20,18))
	cellBg:addChild(headIcon)
	local nameBg = CCSprite:create("images/pet/pet/name_bg.png")
	nameBg:setPosition(20, cellSize.height-15)
	nameBg:setAnchorPoint(ccp(0,1))
	cellBg:addChild(nameBg)
	local nameBgSize = nameBg:getContentSize()
	local petDB = DB_Pet.getDataById(petTid)
	-- 等级
	local levelSprite = CCSprite:create("images/common/lv.png")
	local levelNum = CCLabelTTF:create(tostring(cellValues.level), g_sFontName ,21)
	levelNum:setColor(ccc3(0xff,0xf6,0x00))
	local levelFinal = BaseUI.createHorizontalNode({levelSprite,levelNum})
	levelFinal:setAnchorPoint(ccp(0,0.5))
	levelFinal:setPosition(ccp(10,nameBgSize.height/2))
	nameBg:addChild(levelFinal)
	-- 名字
	local petName = CCLabelTTF:create(tostring(petDB.roleName), g_sFontName ,22)
	petName:setColor(HeroPublicLua.getCCColorByStarLevel(petDB.quality))
	petName:setAnchorPoint(ccp(0,0.5))
	petName:setPosition(ccp(100,nameBgSize.height/2))
	nameBg:addChild(petName)

	local headSize = headIcon:getContentSize()
	local whiteOne = CCScale9Sprite:create("images/pet/pet/bottom_white.png")
	whiteOne:setPreferredSize(CCSizeMake(207,33))
	whiteOne:setAnchorPoint(ccp(0,0))
	whiteOne:setPosition(ccp(headSize.width+3,headSize.height / 2 + 5))
	headIcon:addChild(whiteOne)
	local whiteThree = CCScale9Sprite:create("images/pet/pet/bottom_white.png")
	whiteThree:setPreferredSize(CCSizeMake(207,33))
	whiteThree:setAnchorPoint(ccp(0,1))
	whiteThree:setPosition(ccp(headSize.width+3,headSize.height / 2 - 5))
	headIcon:addChild(whiteThree)
	-- 品阶
	local skillPointC = CCLabelTTF:create(GetLocalizeStringBy("syx_1087").."：", g_sFontName ,25)
	skillPointC:setColor(ccc3(0x48,0x1b,0x00))
	-- 进阶等级
	local evolveLevel = 0
	-- 是否已培养
	local trainStr = nil
	if cellValues.va_pet then
		evolveLevel = cellValues.va_pet.evolveLevel or 0
		if not table.isEmpty(cellValues.va_pet.confirmed) then
			trainStr = GetLocalizeStringBy("syx_1098")
		else
			trainStr = GetLocalizeStringBy("syx_1099")
		end
	end
	local skillPointN = CCLabelTTF:create(evolveLevel,g_sFontName,25)
	skillPointN:setColor(ccc3(0xbd,0x01,0x01))
	local skillPointFinal = BaseUI.createHorizontalNode({skillPointC,skillPointN})
	skillPointFinal:setAnchorPoint(ccp(0,0.5))
	skillPointFinal:setPosition(ccp(5,33/2))
	whiteOne:addChild(skillPointFinal)
	-- 培养
	local petQuality = CCLabelTTF:create(GetLocalizeStringBy("syx_1076").."：", g_sFontName ,25)
	petQuality:setColor(ccc3(0x48,0x1b,0x00))
	-- petQuality:setAnchorPoint(ccp(0,0.5))
	-- petQuality:setPosition(ccp(5,33/2))
	-- whiteThree:addChild(petQuality)
	local isTrainLabel = CCRenderLabel:create(trainStr,g_sFontName,25,1,ccc3(0,0,0),type_shadow)
	isTrainLabel:setColor(ccc3(0x00,0xff,0x18))
	-- isTrainLabel:setAnchorPoint(ccp(0,0.5))
	-- isTrainLabel:setPosition(ccp(5,33/2))
	local trainLabelNode = BaseUI.createHorizontalNode({petQuality,isTrainLabel})
	trainLabelNode:setAnchorPoint(ccp(0,0.5))
	trainLabelNode:setPosition(ccp(5,33/2))
	whiteThree:addChild(trainLabelNode)
	-- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority( touchPriority-1)
	cellBg:addChild(menuBar,1, 9898)
	local checkedBtn = CheckBoxItem.create()
	checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
    checkedBtn:setPosition(ccp(cellBg:getContentSize().width*580/640, cellBg:getContentSize().height*0.5))
    checkedBtn:registerScriptTapHandler(checkedAction)
    menuBar:addChild(checkedBtn, 1, tonumber(cellValues.petid))
    handleSelectedCheckedBtn(checkedBtn)
    -- print("cellValues.petid",cellValues.petid,pSwapPetID)
    if cellValues.petid == pSwapPetID then
    	checkedBtn:selected()
    end
	return tCell
end
