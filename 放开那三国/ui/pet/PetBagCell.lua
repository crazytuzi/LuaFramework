-- Filename：	PetBagCell.lua
-- Author：		zhang zihang
-- Date：		2014-4-8
-- Purpose：		宠物背包的scrollView

module( "PetBagCell", package.seeall)

require "script/ui/pet/PetUtil"
require "script/ui/pet/PetData"
require "script/utils/BaseUI"
require "script/ui/hero/HeroPublicLua"

local cellTable = {}

function showPetInfo(tag,obj)
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/pet/PetInfoLayer"
	PetInfoLayer.showLayer(nil,tag,"bagLayer")
end

function feedAction(tag,obj)
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	print(tag)

	local petid = tonumber(tag)
    require "script/ui/pet/PetFeedLayer"
    PetFeedLayer.showLayer(petid)
	-- local petInfo= PetData.getPetInfoById(petid)

	-- local posIndex= PetData.getPosIndexById(petid)

	-- local layer= PetMainLayer.createLayer( posIndex, 3)
	-- MainScene.changeLayer( layer,"PetMainLayer")

end




function learnSkillAction(tag,obj)
	print(tag)

	local petid = tonumber(tag)
    require "script/ui/pet/PetGraspLayer"
    PetGraspLayer.showLayer(petid)
	-- local petInfo= PetData.getPetInfoById(petid)

	-- local posIndex= PetData.getPosIndexById(petid)

	-- print("posIndex is ", posIndex)
	-- local layer= PetMainLayer.createLayer( posIndex,4)
	-- MainScene.changeLayer( layer,"PetMainLayer")
end


function eatItemAction( tag,item )
	print("tag is : " ,tag)

	local petid = tonumber(tag)
	local petInfo= PetData.getPetInfoById(petid)

	local posIndex= PetData.getPosIndexById(petid)

	print("posIndex is ", posIndex)
	local layer= PetMainLayer.createLayer( posIndex,2)
	MainScene.changeLayer( layer,"PetMainLayer")
end

-- para: cellValues:对应得数据
-- status: 对应的状态
local function createCell(cellValues)

	local tCell = CCTableViewCell:create()

	local cellBg= CCScale9Sprite:create(CCRectMake(33, 35, 12, 45),"images/pet/pet/bag_bg.png")
	cellBg:setPreferredSize(CCSizeMake(640,210))
	tCell:addChild(cellBg)

	local cellSize = cellBg:getContentSize()

	local headIcon = PetUtil.getPetHeadIconByItid(tonumber(cellValues.ptid),tonumber(cellValues.pid),showPetInfo)
	headIcon:setAnchorPoint(ccp(0,0))
	headIcon:setPosition(ccp(20,40))
	cellBg:addChild(headIcon)

	local headSize = headIcon:getContentSize()

	local nameBg = CCSprite:create("images/pet/pet/name_bg.png")
	nameBg:setPosition(20, cellSize.height-15)
	nameBg:setAnchorPoint(ccp(0,1))
	cellBg:addChild(nameBg)

	local nameBgSize = nameBg:getContentSize()

	local levelSprite = CCSprite:create("images/common/lv.png")
	local levelNum = CCLabelTTF:create(tostring(cellValues.lv), g_sFontName ,21)
	levelNum:setColor(ccc3(0xff,0xf6,0x00))

	local levelFinal = BaseUI.createHorizontalNode({levelSprite,levelNum})
	levelFinal:setAnchorPoint(ccp(0,0.5))
	levelFinal:setPosition(ccp(10,nameBgSize.height/2))
	nameBg:addChild(levelFinal)

	local petName = CCLabelTTF:create(tostring(cellValues.name), g_sFontName ,22)
	petName:setColor(HeroPublicLua.getCCColorByStarLevel(cellValues.quality))
	petName:setAnchorPoint(ccp(0,0.5))
	petName:setPosition(ccp(100,nameBgSize.height/2))
	nameBg:addChild(petName)

	local starOrignalWidth = 260

	-- for i = 1,cellValues.quality do
	-- 	local QStar = CCSprite:create("images/common/star.png")
	-- 	QStar:setAnchorPoint(ccp(0,0.5))
	-- 	QStar:setPosition(ccp(260+(i-1)*35,nameBgSize.height/2))
	-- 	nameBg:addChild(QStar)
	-- end

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
	local skillPointN = CCLabelTTF:create(tostring(cellValues.skillPoint),g_sFontName,25)
	skillPointN:setColor(ccc3(0xbd,0x01,0x01))

	local skillPointFinal = BaseUI.createHorizontalNode({skillPointC,skillPointN})
	skillPointFinal:setAnchorPoint(ccp(0,0.5))
	skillPointFinal:setPosition(ccp(5,33/2))
	whiteOne:addChild(skillPointFinal)

	local fightSprite = CCSprite:create("images/common/fight_value.png")
	local fightNum = CCLabelTTF:create("  " .. PetData.getPetFightForceById(cellValues.pid), g_sFontName ,25)
	fightNum:setColor(ccc3(0x12,0x9b,0x00))

	local fightValue = BaseUI.createHorizontalNode({fightSprite,fightNum})
	fightValue:setAnchorPoint(ccp(0,0.5))
	fightValue:setPosition(ccp(5,33/2))
	whiteTwo:addChild(fightValue)

	local petQuality = CCLabelTTF:create(GetLocalizeStringBy("key_3083") .. tostring(cellValues.petQuality), g_sFontName ,25)
	petQuality:setColor(ccc3(0x48,0x1b,0x00))
	petQuality:setAnchorPoint(ccp(0,0.5))
	petQuality:setPosition(ccp(5,33/2))
	whiteThree:addChild(petQuality)

	if cellValues.isOnFormation then
		local haveFormation = CCSprite:create("images/pet/petting.png")
		haveFormation:setAnchorPoint(ccp(1,1))
		haveFormation:setPosition(ccp(cellSize.width,cellSize.height))
		cellBg:addChild(haveFormation)
	

		local menuBar= CCMenu:create()
		menuBar:setPosition(ccp(0,0))
		cellBg:addChild(menuBar)

		local feedItem = LuaCC.create9ScaleMenuItem("images/common/btn/green01_n.png","images/common/btn/green01_h.png",CCSizeMake(126,64),GetLocalizeStringBy("key_1488"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		feedItem:setAnchorPoint(ccp(0,0))
		feedItem:setPosition(ccp(415, 85))
		feedItem:registerScriptTapHandler(feedAction)
		menuBar:addChild(feedItem,1,tonumber(cellValues.pid))

		local skillItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_violet_n.png","images/common/btn/btn_violet_h.png",CCSizeMake(126,64),GetLocalizeStringBy("key_1095"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		skillItem:setPosition(ccp(415, 20))
		skillItem:setAnchorPoint(ccp(0,0))
		skillItem:registerScriptTapHandler(learnSkillAction)
		menuBar:addChild(skillItem,1,tonumber(cellValues.pid))


		-- local eatItem = LuaCC.create9ScaleMenuItem("images/common/btn/green01_n.png","images/common/btn/green01_h.png",CCSizeMake(126,64),GetLocalizeStringBy("key_2786"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		-- eatItem:setAnchorPoint(ccp(0,0))
		-- eatItem:setPosition(ccp(493,85))
		-- eatItem:registerScriptTapHandler(eatItemAction)
		-- menuBar:addChild(eatItem,1, tonumber(cellValues.pid))
	end

	return tCell
end

--处理下宠物背包中的数据，好用来创建cell方便
local function dealPetBagData(originalData)
	cellTable = {}
	for k,v in pairs(originalData) do
		local singleTable = {}
		singleTable.pid = tonumber(k)
		singleTable.ptid = tonumber(v.pet_tmpl)
		singleTable.lv = tonumber(v.level)
		singleTable.name = tostring(PetData.getPetNameByTid(v.pet_tmpl))
		singleTable.quality = tonumber(PetData.getPetQualityByTid(v.pet_tmpl))
		singleTable.skillPoint = tonumber(v.skill_point)
		singleTable.fightPower = tonumber(PetData.getPetFightForceById(tonumber(k)))
		singleTable.isOnFormation = PetData.isPetUpByid(tonumber(k))
		singleTable.petQuality = tonumber(PetData.getPetQuality(v.pet_tmpl))
		table.insert(cellTable,singleTable)
	end

	local function sort(w1, w2)
		if (w1.isOnFormation == false) and (w2.isOnFormation == true) then
			return true
		elseif ((w1.isOnFormation == false) and (w2.isOnFormation == false)) or ((w1.isOnFormation == true) and (w2.isOnFormation == true)) then 
			if tonumber(w1.quality) < tonumber(w2.quality) then
				return true
			elseif tonumber(w1.quality) == tonumber(w2.quality) then
				if tonumber(w1.lv) < tonumber(w2.lv) then
					return true
				elseif tonumber(w1.lv) == tonumber(w2.lv) then
					if tonumber(w1.fightPower) < tonumber(w2.fightPower) then
						return true
					elseif tonumber(w1.fightPower) == tonumber(w2.fightPower) then
						if tonumber(w1.pid) < tonumber(w2.pid) then
							return true
						else
							return false
						end
					end
				end
			end
		else 
			return false
		end
	end

	table.sort(cellTable, sort)

	return cellTable
end

function creteBagTableView(layerWidth,_scrollview_height)
	local cellWidth = 640*g_fScaleX
	local cellHeight = 210*g_fScaleX

	local bagPetInfo = PetData.getAllBagPetInfo()
	print("西路露露露露")
	print_t(bagPetInfo)
	local petCellInfo = dealPetBagData(bagPetInfo)

	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			r = CCSizeMake(cellWidth, cellHeight)
		elseif (fn == "cellAtIndex") then
			print("a1是多少呢~~",a1)
			a2 = createCell(petCellInfo[a1+1])
			a2:setScale(g_fScaleX)
			r = a2
		elseif (fn == "numberOfCells") then
			r = tonumber(PetData.getPetNum())
		elseif (fn == "cellTouched") then
		end
		
		return r
	end)
	local tableView = LuaTableView:createWithHandler(handler, CCSizeMake(layerWidth, _scrollview_height))
	tableView:setAnchorPoint(ccp(0, 0))
	tableView:setBounceable(true)

	return tableView
end

function getPetInfoByPid(pid)
	for k,v in pairs(cellTable) do
		if tonumber(v.pid) == tonumber(pid) then
			return v
		end
	end
end
