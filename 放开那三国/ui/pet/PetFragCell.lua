-- Filename：	PetFragCell.lua
-- Author：		zhang zihang
-- Date：		2014-4-10
-- Purpose：		宠物碎片的scrollView

module( "PetFragCell", package.seeall)

require "script/utils/BaseUI"
require "script/ui/hero/HeroPublicLua"
require "db/DB_Pet"

local fragPetInfo = {}
local upper = {}

function showPetByFrag(tag,obj)
	require "script/ui/pet/PetInfoLayer"
	PetInfoLayer.showLayer(tag,nil,"fragLayer")
end
--合成宠物碎片后的回调
function togetherSuccess(cbName, dictData, bRet)
	print("togetherSuccess cbName, dictData, bRet",cbName, dictData, bRet)
	if not bRet then
		return
	end
	if cbName == "bag.useItem" then
		-- print("返回了哦")
		-- print_t(dictData)
		-- print("upper")
		-- print_t(upper)
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_1316") .. DB_Pet.getDataById(upper.itemDesc.aimPet).roleName)
		require "script/ui/item/ItemUtil"

		ItemUtil.reduceItemByGid(upper.gid,upper.itemDesc.need_part_num)
		DataCache.setBagStatus(true)
		require "script/ui/pet/PetBagLayer"
		PetBagLayer.refreshFragView()
		require "script/ui/pet/PetData"
		PetData.addPetInfo(dictData.ret.pet[1])
		PetBagLayer.minusRed()
	end
end

function togetherAction(tag,obj)
	--print(tag)
	require "script/ui/pet/PetUtil"
	if PetUtil.isPetBagFull() == true then
		-- require "script/ui/tip/AnimationTip"
		-- AnimationTip.showTip(GetLocalizeStringBy("key_1798"))
	else
		require "script/network/RequestCenter"
		require "script/network/Network"
		upper = fragPetInfo[tag]
		local args = Network.argsHandler(tonumber(upper.gid),tonumber(upper.item_id),tonumber(upper.itemDesc.need_part_num),1)
		local returnValue = RequestCenter.bag_useItem(togetherSuccess,args)
		--print(returnValue)
	end
end

function createCell(cellValues,aNum)
	local tCell = CCTableViewCell:create()

	local cellBg= CCScale9Sprite:create(CCRectMake(33, 35, 12, 45),"images/pet/pet/bag_bg.png")
	cellBg:setPreferredSize(CCSizeMake(640,185))
	tCell:addChild(cellBg)

	local cellSize = cellBg:getContentSize()

	local headIcon = PetUtil.getPetHeadIconByItid(tonumber(cellValues.itemDesc.aimPet),tonumber(cellValues.itemDesc.aimPet),showPetByFrag)
	headIcon:setAnchorPoint(ccp(0,0))
	headIcon:setPosition(ccp(20,30))
	cellBg:addChild(headIcon)

	local petFragSp = CCSprite:create("images/common/petfrag_tag.png")
	petFragSp:setAnchorPoint(ccp(0.5, 0.5))
	petFragSp:setPosition(ccp(headIcon:getContentSize().width*0.4, headIcon:getContentSize().height*0.9))
	headIcon:addChild(petFragSp)

	local headSize = headIcon:getContentSize()

	local nameBg = CCSprite:create("images/pet/pet/name_bg.png")
	nameBg:setPosition(20, cellSize.height-15)
	nameBg:setAnchorPoint(ccp(0,1))
	cellBg:addChild(nameBg)

	local nameBgSize = nameBg:getContentSize()

	local levelSprite = CCSprite:create("images/common/lv.png")
	local levelNum = CCLabelTTF:create("1", g_sFontName ,21)
	levelNum:setColor(ccc3(0xff,0xf6,0x00))

	local levelFinal = BaseUI.createHorizontalNode({levelSprite,levelNum})
	levelFinal:setAnchorPoint(ccp(0,0.5))
	levelFinal:setPosition(ccp(10,nameBgSize.height/2))
	nameBg:addChild(levelFinal)

	local petName = CCLabelTTF:create(tostring(cellValues.itemDesc.name), g_sFontName ,22)
	petName:setColor(HeroPublicLua.getCCColorByStarLevel(cellValues.itemDesc.quality))
	petName:setAnchorPoint(ccp(0,0.5))
	petName:setPosition(ccp(100,nameBgSize.height/2))
	nameBg:addChild(petName)

	local starOrignalWidth = 260

	-- for i = 1,tonumber(cellValues.itemDesc.quality) do
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

	local process = CCLabelTTF:create(GetLocalizeStringBy("key_3092"), g_sFontName ,25)
	process:setColor(ccc3(0x48,0x1b,0x00))
	local haveNum = CCLabelTTF:create(tostring(cellValues.item_num), g_sFontName ,25)
	haveNum:setColor(ccc3(0x12,0x9b,0x00))
	local stadardNum = CCLabelTTF:create("/" .. tostring(cellValues.itemDesc.need_part_num), g_sFontName ,25)
	stadardNum:setColor(ccc3(0xbd,0x01,0x01))

	local procession = BaseUI.createHorizontalNode({process,haveNum,stadardNum})
	procession:setAnchorPoint(ccp(0,0.5))
	procession:setPosition(ccp(5,33/2))
	whiteOne:addChild(procession)

	local menuBar= CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	cellBg:addChild(menuBar)

	if tonumber(cellValues.item_num) < tonumber(cellValues.itemDesc.need_part_num) then
		local ccSpriteInsufficient = CCSprite:create("images/hero/insufficient.png")
		ccSpriteInsufficient:setPosition(ccp(525, 45))
		ccSpriteInsufficient:setAnchorPoint(ccp(0.5,0))
		cellBg:addChild(ccSpriteInsufficient)
	else
		local mixItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_violet_n.png","images/common/btn/btn_violet_h.png",CCSizeMake(126,64),GetLocalizeStringBy("key_1363"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		mixItem:setPosition(ccp(525, 45))
		mixItem:setAnchorPoint(ccp(0.5,0))
		mixItem:registerScriptTapHandler(togetherAction)
		menuBar:addChild(mixItem,1,tonumber(aNum))
	end

	return tCell
end

function sortPet(pTable)
	local function sort(w1, w2)
		if (tonumber(w1.item_num) < tonumber(w1.itemDesc.need_part_num)) and (tonumber(w2.item_num) >= tonumber(w2.itemDesc.need_part_num)) then
			return true
		elseif ((tonumber(w1.item_num) < tonumber(w1.itemDesc.need_part_num)) and (tonumber(w2.item_num) < tonumber(w2.itemDesc.need_part_num))) or ((tonumber(w1.item_num) >= tonumber(w1.itemDesc.need_part_num)) and (tonumber(w2.item_num) >= tonumber(w2.itemDesc.need_part_num))) then
			if tonumber(w1.itemDesc.quality) < tonumber(w2.itemDesc.quality) then
				return true
			elseif tonumber(w1.itemDesc.quality) == tonumber(w2.itemDesc.quality) then
				if tonumber(w1.itemDesc.aimPet) < tonumber(w2.itemDesc.aimPet) then
					return true
				else
					return false
				end
			end
		else 
			return false
		end
	end

	table.sort(pTable, sort)

	return pTable
end

function getFragAndSort()
	require "script/ui/item/ItemUtil"
	local fragTemp = ItemUtil.getPetFragInfos()
	print("getFragAndSort fragTemp")
	print_t(fragTemp)
	local fragInfo = sortPet(fragTemp)

	return fragInfo
end

function crateFragTableView(layerWidth,_scrollview_height)
	local cellWidth = 640*g_fScaleX
	local cellHeight = 185*g_fScaleX
	
	fragPetInfo = getFragAndSort()
	-- print("xxxx")
	-- print_t(fragPetInfo)
	--local petCellInfo = dealPetBagData(bagPetInfo)

	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			r = CCSizeMake(cellWidth, cellHeight)
		elseif (fn == "cellAtIndex") then
			--print("a1是多少呢~~",a1)
			a2 = createCell(fragPetInfo[a1+1],a1+1)
			a2:setScale(g_fScaleX)
			r = a2
		elseif (fn == "numberOfCells") then
			r = #fragPetInfo
		elseif (fn == "cellTouched") then
		end
		
		return r
	end)
	local tableView = LuaTableView:createWithHandler(handler, CCSizeMake(layerWidth, _scrollview_height))
	tableView:setAnchorPoint(ccp(0, 0))
	tableView:setBounceable(true)

	return tableView
end
