-- Filename：	PetSelectCell.lua
-- Author：		zhz
-- Date：		2014-3-31
-- Purpose：		宠物的吞噬的cell

module("PetSelectCell", package.seeall)

require "db/DB_Pet"
require "db/DB_Normal_config"
require "script/utils/BaseUI"
require "script/ui/common/CheckBoxItem"
require "script/utils/LuaUtil"
require "script/ui/pet/PetData"
require "script/utils/BaseUI"


-- check的action
function checkedAction( tag, item)
	require "script/ui/pet/SelSwallowPetLayer"
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- item:selected()

	local selecedList = SelSwallowPetLayer.getSwallowPetId() 
	selecedList= tonumber(tag)
	SelSwallowPetLayer.setSwalloePetId(selecedList)

	SelSwallowPetLayer.rfcTableView()
	SelSwallowPetLayer.refreshBottomSprite()

end


-- 处理检查checked 的宝物
function handleSelectedCheckedBtn( checkedBtn )
	require "script/ui/pet/SelSwallowPetLayer"
	require "script/ui/pet/SellPetLayer"

	local selecedList = SelSwallowPetLayer.getSwallowPetId() --TreasRefineSelLayer.getSelCheckedArr()
	if ( selecedList== nil ) then
		checkedBtn:unselected()
	else
		local isIn = false
		if ( tonumber(selecedList)== tonumber(checkedBtn:getTag()) ) then
			isIn = true
		end
		if (isIn) then
			checkedBtn:selected()
		else
			checkedBtn:unselected()
		end
	end
end

local function sellCheckedAction(tag, item )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")


	local sellList = SellPetLayer.getSellPetIds()
	if ( table.isEmpty(sellList) ) then
		sellList = {}
		table.insert(sellList, tag)
		item:selected()
	else
		local isIn = false
		local index = -1
		for k,petid in pairs(sellList) do
			if ( tonumber(petid) == tag ) then
				isIn = true
				index = k
				break
			end
		end
		if (isIn) then
			table.remove(sellList, index)
			item:unselected()
		else
			table.insert(sellList, tag)
			item:selected()
		end
	end
	SellPetLayer.setSellPetIds(sellList)

	SellPetLayer.refreshBottomSprite()
end

-- 处理要售买的宝物
function handleSellCheckBtn(checkedBtn )
	
	require "script/ui/pet/SellPetLayer"
	local sellList = SellPetLayer.getSellPetIds()
	if ( table.isEmpty(sellList) ) then
		checkedBtn:unselected()
	else
		local isIn = false
		for k,petid in pairs(sellList) do
			if ( tonumber(petid) == checkedBtn:getTag() ) then
				isIn = true
				break
			end
		end
		if (isIn) then
			checkedBtn:selected()
		else
			checkedBtn:unselected()
		end
	end
end


function createCell(cellValues, touchPriority , ctype)
	local tCell = CCTableViewCell:create()

	local ctype= ctype or 1
	
	local cellBg= CCScale9Sprite:create(CCRectMake(33, 35, 12, 45),"images/pet/pet/bag_bg.png")
	cellBg:setPreferredSize(CCSizeMake(640,210))
	tCell:addChild(cellBg)
	local cellSize = cellBg:getContentSize()

	local petTid= tonumber( cellValues.pet_tmpl)
	local headIcon = PetUtil.getPetHeadIconByItid(tonumber(petTid),tonumber(cellValues.petid),petInfoCallBack)
	headIcon:setAnchorPoint(ccp(0,0))
	headIcon:setPosition(ccp(20,40))
	cellBg:addChild(headIcon)
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


	local headSize = headIcon:getContentSize()

	local whiteOne = CCScale9Sprite:create("images/pet/pet/bottom_white.png")
	whiteOne:setPreferredSize(CCSizeMake(207,33))
	whiteOne:setAnchorPoint(ccp(0,1))
	whiteOne:setPosition(ccp(headSize.width+3,headSize.height+10))
	headIcon:addChild(whiteOne)

	local whiteTwo = CCScale9Sprite:create("images/pet/pet/bottom_white.png")
	whiteTwo:setPreferredSize(CCSizeMake(207,33))
	whiteTwo:setAnchorPoint(ccp(0,0))
	whiteTwo:setPosition(ccp(headSize.width+3,-10))
	headIcon:addChild(whiteTwo)

	local whiteThree = CCScale9Sprite:create("images/pet/pet/bottom_white.png")
	whiteThree:setPreferredSize(CCSizeMake(207,33))
	whiteThree:setAnchorPoint(ccp(0,0.5))
	whiteThree:setPosition(ccp(headSize.width+3,headSize.height/2))
	headIcon:addChild(whiteThree)

	local skillPointC = CCLabelTTF:create(GetLocalizeStringBy("key_3257"), g_sFontName ,25)
	skillPointC:setColor(ccc3(0x48,0x1b,0x00))
	local skillPointN = CCLabelTTF:create(tostring(cellValues.skill_point),g_sFontName,25)
	skillPointN:setColor(ccc3(0xbd,0x01,0x01))

	local skillPointFinal = BaseUI.createHorizontalNode({skillPointC,skillPointN})
	skillPointFinal:setAnchorPoint(ccp(0,0.5))
	skillPointFinal:setPosition(ccp(5,33/2))
	whiteOne:addChild(skillPointFinal)

	local fightSprite = CCSprite:create("images/common/fight_value.png")
	local fightNum = CCLabelTTF:create("  " .. PetData.getPetFightForceById(cellValues.petid), g_sFontName ,25)
	fightNum:setColor(ccc3(0x12,0x9b,0x00))

	local fightValue = BaseUI.createHorizontalNode({fightSprite,fightNum})
	fightValue:setAnchorPoint(ccp(0,0.5))
	fightValue:setPosition(ccp(5,33/2))
	whiteTwo:addChild(fightValue)

	local petQuality = CCLabelTTF:create(GetLocalizeStringBy("key_3083") .. tostring(cellValues.petDesc.petQuality), g_sFontName ,25)
	petQuality:setColor(ccc3(0x48,0x1b,0x00))
	petQuality:setAnchorPoint(ccp(0,0.5))
	petQuality:setPosition(ccp(5,33/2))
	whiteThree:addChild(petQuality)

	-- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority( touchPriority-1)
	cellBg:addChild(menuBar,1, 9898)

	if(ctype ==1) then
		local checkedBtn = CheckBoxItem.create()
		checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
	    checkedBtn:setPosition(ccp(cellBg:getContentSize().width*580/640, cellBg:getContentSize().height*0.5))
	    checkedBtn:registerScriptTapHandler(checkedAction)
	    menuBar:addChild(checkedBtn, 1, tonumber(cellValues.petid) )
		handleSelectedCheckedBtn(checkedBtn)
	elseif(ctype == 2) then
		local sellCheckedBTn= CheckBoxItem.create()
		sellCheckedBTn:setAnchorPoint(ccp(0.5, 0.5))
	    sellCheckedBTn:setPosition(ccp(cellBg:getContentSize().width*580/640, cellBg:getContentSize().height*0.5))
	    sellCheckedBTn:registerScriptTapHandler(sellCheckedAction)
	    menuBar:addChild(sellCheckedBTn, 1, tonumber(cellValues.petid))
	    handleSellCheckBtn(sellCheckedBTn)
	end

	return tCell
end
