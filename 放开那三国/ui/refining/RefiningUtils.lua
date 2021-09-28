-- Filename: RefiningUtils.lua
-- Author: zhang zihang
-- Date: 2015-3-2
-- Purpose: 炼化炉工具方法

module ("RefiningUtils", package.seeall)

require "script/model/hero/HeroModel"
require "script/model/utils/HeroUtil"
require "script/ui/hero/HeroSort"
require "script/ui/hero/HeroLayerCell"
require "script/ui/refining/RefiningMenuItem"
require "script/ui/formation/LittleFriendData"
require "script/ui/formation/secondfriend/SecondFriendData"
require "script/ui/godweapon/godweaponcopy/GodWeaponCopyData"
require "script/ui/item/GodWeaponItemUtil"
require "db/DB_Heroes"
require "script/ui/bag/BagLayer"

local kSpriteTag = 100 		--背景图tag
local kMenuTag = 200		--菜单tag
local kBtnTag = 300			--按钮tag
local kTouchPriority = -395 --触摸优先级

--[[
	@des 	:得到选择物品的按钮的普通模式Sprite
	@param  :边界图路径
--]]
function getCommonMenuSprite(p_borderPath)
	local borderPath = p_borderPath or "images/common/border.png"

	local borderSprite = CCSprite:create("images/common/equipborder.png")
	borderSize = borderSprite:getContentSize()

	local innerSprite = CCSprite:create(borderPath)
	innerSprite:setPosition(ccp(borderSize.width/2,borderSize.height/2))
	innerSprite:setAnchorPoint(ccp(0.5,0.5))
	borderSprite:addChild(innerSprite)

	return borderSprite
end

--[[
	@des 	:得到选择物品的按钮的高亮模式Sprite
	@param  :边界图路径
--]]
function getHightLightMenuSprite(p_borderPath)
	local borderPath = p_borderPath or "images/common/border.png"
	
	local borderSprite = CCSprite:create("images/common/equipborder.png")
	borderSize = borderSprite:getContentSize()

	local innerSprite = CCSprite:create(borderPath)
	innerSprite:setPosition(ccp(borderSize.width/2,borderSize.height/2))
	innerSprite:setAnchorPoint(ccp(0.5,0.5))
	borderSprite:addChild(innerSprite)
	
	local highLightSprite = CCSprite:create("images/hero/quality/highlighted.png")
	highLightSprite:setPosition(borderSize.width/2,borderSize.height/2)
	highLightSprite:setAnchorPoint(ccp(0.5, 0.5))
	borderSprite:addChild(highLightSprite)

	return borderSprite
end

--[[
	@des 	:创建选择按钮
	@param  :物品信息
	@return :创建好的menuItem
--]]
function createSelectMenuItem(p_itemInfo)
	local borderImgPath
	local headImgPath
	local nameString
	local qualityNum
	local curTag = RefiningData.getCurSelectTag()
	if p_itemInfo ~= nil then
		if curTag == RefiningData.kHeroTag then
			borderImgPath = "images/hero/quality/" .. p_itemInfo.star_lv .. ".png"
			headImgPath = "images/base/hero/head_icon/" .. p_itemInfo.head_icon_id
			nameString = p_itemInfo.name
			qualityNum = p_itemInfo.star_lv
		elseif curTag == RefiningData.kEquipTag then
		    local quality = ItemUtil.getEquipQualityByItemInfo( p_itemInfo )
			local i_data = DB_Item_arm.getDataById(p_itemInfo.item_template_id)
			if( tonumber(quality) == 7)then
				borderImgPath = "images/base/potential/props_" .. quality .. ".png"
				headImgPath = "images/base/equip/small/" .. i_data.new_smallicon
			else
				borderImgPath = "images/base/potential/props_" .. quality .. ".png"
				headImgPath = "images/base/equip/small/" .. i_data.icon_small
			end

			nameString = ItemUtil.getEquipNameStrByItemInfo(p_itemInfo)
			qualityNum = quality			
		elseif curTag == RefiningData.kTreasureTag then
			--宝物涉及进阶问题
			local quality = ItemUtil.getTreasureQualityByItemInfo( p_itemInfo )
			borderImgPath = "images/base/potential/props_" .. quality .. ".png"
			headImgPath = "images/base/treas/small/" .. p_itemInfo.itemDesc.icon_small
			nameString = ItemUtil.getTreasureNameStrByItemInfo( p_itemInfo )
			qualityNum = quality	
		elseif curTag == RefiningData.kClothTag then
			borderImgPath = "images/base/potential/props_" .. p_itemInfo.itemDesc.quality .. ".png"
			local fashionName
			local oldhtid = UserModel.getAvatarHtid()
			local modelId = DB_Heroes.getDataById(tonumber(oldhtid)).model_id
			local nameArray = lua_string_split(p_itemInfo.itemDesc.name, ",")
			for k,v in pairs(nameArray) do
		    	local array = lua_string_split(v,"|")
		    	if tonumber(array[1]) == tonumber(modelId) then
					fashionName = array[2]
					break
		    	end
		    end
		    local fashionPic
		    local iconArray = lua_string_split(p_itemInfo.itemDesc.icon_small, ",")
			for k,v in pairs(iconArray) do
		    	local array = lua_string_split(v,"|")
		    	if(tonumber(array[1]) == tonumber(modelId)) then
					fashionPic = array[2]
					break
		    	end
		    end
		    headImgPath = "images/base/fashion/small/" .. fashionPic
			nameString = fashionName
			qualityNum = p_itemInfo.itemDesc.quality
		elseif curTag == RefiningData.kGodTag then
			local godQuality = GodWeaponItemUtil.getGodWeaponQualityAndEvolveNum(nil,nil,p_itemInfo)
			borderImgPath = "images/base/potential/props_" .. godQuality .. ".png"
			headImgPath = "images/base/godarm/small/" .. p_itemInfo.itemDesc.icon_small
			nameString = p_itemInfo.itemDesc.name
			qualityNum = godQuality
		elseif curTag == RefiningData.kTokenTag then
			borderImgPath = "images/base/potential/props_" .. p_itemInfo.itemDesc.quality .. ".png"
			headImgPath = "images/base/item_fuyin/" .. p_itemInfo.itemDesc.icon_small

			nameString = p_itemInfo.itemDesc.name
			qualityNum = p_itemInfo.itemDesc.quality
		elseif curTag == RefiningData.kPocketTag then
			borderImgPath = "images/base/potential/props_" .. p_itemInfo.itemDesc.quality .. ".png"
			headImgPath = "images/base/pocket/small/" .. p_itemInfo.itemDesc.icon_small

			nameString = p_itemInfo.itemDesc.name
			qualityNum = p_itemInfo.itemDesc.quality
		elseif curTag == RefiningData.kHeroJHTag then
			borderImgPath = "images/base/potential/props_" .. p_itemInfo.itemDesc.quality .. ".png"
			headImgPath = "images/base/props/" .. p_itemInfo.itemDesc.icon_small

			nameString = p_itemInfo.itemDesc.name
			qualityNum = p_itemInfo.itemDesc.quality
		elseif curTag == RefiningData.kTallyTag then
			borderImgPath = "images/base/potential/props_" .. p_itemInfo.itemDesc.quality .. ".png"
			headImgPath = "images/base/bingfu/small/" .. p_itemInfo.itemDesc.icon_small

			nameString = p_itemInfo.itemDesc.name
			qualityNum = p_itemInfo.itemDesc.quality
		elseif curTag == RefiningData.kChariotTag then
			-- 战车
			borderImgPath = "images/base/potential/props_" .. p_itemInfo.itemDesc.quality .. ".png"
			headImgPath = "images/base/warcar/small/" .. p_itemInfo.itemDesc.icon_small

			nameString = p_itemInfo.itemDesc.name
			qualityNum = p_itemInfo.itemDesc.quality
		end
	end
	--新的按钮
	local newMenuItem = RefiningMenuItem:new()
	newMenuItem:createMenuItem(borderImgPath)

	--设置头像
	newMenuItem:addHeadSprite(headImgPath)

	--如果是空，就闪
	if p_itemInfo == nil then
		newMenuItem:setSpriteAction()
	else
		newMenuItem:setName(nameString,qualityNum)
		if curTag == RefiningData.kHeroTag then
			--武将 考虑紫色进橙的情况
			if tonumber(p_itemInfo.evolve_level) > 0 then
				if p_itemInfo.star_lv <= 5 then 
		    		newMenuItem:setEvolveNum(p_itemInfo.evolve_level)
		    	else
		    		--武将升橙后 不是 +X 的形式 是X阶
		    		newMenuItem:setStageNum(p_itemInfo.evolve_level)
		    		--envolveNum:setString(heroModelInfo.evolve_level .. GetLocalizeStringBy("zzh_1159"))
		    	end
			end
		
		elseif curTag == RefiningData.kEquipTag then
			--装备 考虑套装有特效
			if(p_itemInfo.itemDesc.jobLimit and p_itemInfo.itemDesc.jobLimit>0 )then
				-- 套装
				newMenuItem:addEffectOnEuip(p_itemInfo.itemDesc.quality)
			end
		
		elseif curTag == RefiningData.kClothTag then
			--时装
			newMenuItem:addEffectOnCloth()
		elseif curTag == RefiningData.kHeroJHTag then
			-- 如果当前选择的是武将精华，添加数量文本
			local num = p_itemInfo.selectNum
			local numberLabel = CCRenderLabel:create(num,g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_stroke) 
			numberLabel:setColor(ccc3(0x00,0xff,0x18))
			numberLabel:setAnchorPoint(ccp(1,0))
			numberLabel:setPosition(ccpsprite(1,0,newMenuItem:getMenuItem()))
			newMenuItem:getMenuItem():addChild(numberLabel)
		end

	end

	return newMenuItem:getMenuItem()
end

--==================== Condition ====================
--[[
	@des 	:得到满足炼化条件的英雄
	@return :满足炼化条件的英雄
--]]
function getFitResolveHeroes()
	--满足条件的英雄
	local fitTable = {}
	--所有的英雄
	local allHeroes = HeroModel.getAllHeroes()
	--因为牵扯到排序，所以只能增加一些key
	local sortTable = {}
	table.hcopy(allHeroes,sortTable)

	--对于所有的英雄
	for k,v in pairs(sortTable) do
		local heroDBInfo = DB_Heroes.getDataById(v.htid)
		--不是主角
		if not HeroModel.isNecessaryHero(v.htid) and
			--不在阵容里
			not HeroPublicLua.isBusyWithHid(v.hid) and
			--不是小伙伴
			not LittleFriendData.isInLittleFriend(v.hid) and
			--不是第二套小伙伴
			not SecondFriendData.isInSecondFriendByHid(v.hid) and
			--没有进阶过的
			tonumber(v.evolve_level) <= 0 and
			--没有加锁的
			(v.lock == nil or tonumber(v.lock) ~= 1) and
			--不是小兵
			heroDBInfo.advanced_id ~= nil and tonumber(heroDBInfo.advanced_id) ~= 0 and
			--只要4、5星武将
			heroDBInfo.star_lv >= 4 and heroDBInfo.star_lv <= 5 and
			--不在神兵副本里
			not GodWeaponCopyData.isOnCopyFormationBy(v.hid) then
				v.star_lv = heroDBInfo.star_lv
				v.heroQuality = heroDBInfo.heroQuality
				v.country_icon = HeroModel.getCiconByCidAndlevel(heroDBInfo.country,heroDBInfo.star_lv)
				v.head_icon_id = heroDBInfo.head_icon_id
				v.name = heroDBInfo.name

				--说明这个是满足条件的武将
				table.insert(fitTable,v)
		end
	end

	local srotedTable = HeroSort.sortForHeroList(fitTable)

	return srotedTable
end

--[[
	@des 	:得到满足重生条件的英雄
	@return :满足重生条件的英雄
--]]
function getFitResurrectHeroes()
	--满足条件的英雄
	local fitTable = {}
	--所有英雄
	local allHeroes = HeroModel.getAllHeroes()
	--因为牵扯到排序，所以只能增加一些key
	local sortTable = {}
	table.hcopy(allHeroes,sortTable)

	--对于所有的英雄
	for k,v in pairs(sortTable) do
		local heroDBInfo = DB_Heroes.getDataById(v.htid)
		--不是主角
		if not HeroModel.isNecessaryHero(v.htid) and
			--不在阵容里
			not HeroPublicLua.isBusyWithHid(v.hid) and
			--不是小伙伴
			not LittleFriendData.isInLittleFriend(v.hid) and
			--不是第二套小伙伴
			not SecondFriendData.isInSecondFriendByHid(v.hid) and
			--强化过的
			tonumber(v.level) >= 2 and
			--没有加锁的
			(v.lock == nil or tonumber(v.lock) ~= 1) and
			--不是小兵
			heroDBInfo.advanced_id ~= nil and tonumber(heroDBInfo.advanced_id) ~= 0 and
			--大于四星的
			heroDBInfo.star_lv >= 4 then
				v.star_lv = heroDBInfo.star_lv
				v.heroQuality = heroDBInfo.heroQuality
				v.country_icon = HeroModel.getCiconByCidAndlevel(heroDBInfo.country,heroDBInfo.star_lv)
				v.head_icon_id = heroDBInfo.head_icon_id
				v.rebirth_basegold = tonumber(heroDBInfo.rebirth_basegold)
				v.rebirth_addgold = tonumber(heroDBInfo.rebirth_addgold) or 0
				v.name = heroDBInfo.name
				--说明这个是满足条件的武将
				table.insert(fitTable,v)
		end
	end

	local srotedTable = HeroSort.sortForHeroList(fitTable)

	return srotedTable
end

--[[
	@des 	:得到满足炼化条件的装备
	@return :满足炼化条件的装备
--]]
function getFitResolveEquip()
	local fitTable = {}
	local bagInfo = DataCache.getBagInfo()
	local sortTable = {}
	table.hcopy(bagInfo.arm,sortTable)

	for k,v in pairs(sortTable) do
		--没加锁
		if (
				not(v.va_item_text.lock and tonumber(v.va_item_text.lock) == 1)  and
				--如果是5星以下的物品，且有炼化字段的，可以炼化
				(  
					(v.itemDesc.resolveId ~= nil and tonumber(v.itemDesc.resolveId) ~= 0 and tonumber(v.itemDesc.quality) <= 5) or
					   --或满足炼化条件的橙装
					(v.itemDesc.orangeResolveId ~= nil and tonumber(v.itemDesc.orangeResolveId) ~= 0 and tonumber(v.itemDesc.quality) == 6 
					 and v.va_item_text.armDevelop == nil )
				) 
			) then
			table.insert(fitTable,v)
		end
	end

	local function sort(w1,w2)
		if tonumber(w1.itemDesc.quality) > tonumber(w2.itemDesc.quality) then
			return true
		elseif tonumber(w1.itemDesc.quality) == tonumber(w2.itemDesc.quality) then
			if tonumber(w1.va_item_text.armReinforceLevel) > tonumber(w2.va_item_text.armReinforceLevel) then
				return true
			else 
				return false 
			end
		else 
			return false
		end
	end

	table.sort(fitTable,sort)

	return fitTable
end

--[[
	@des 	:得到满足重生条件的装备
	@return :满足重生条件的装备
--]]
function getFitResurrectEquip()
	local fitTable = {}
	local bagInfo = DataCache.getBagInfo()
	local sortTable = {}
	table.hcopy(bagInfo.arm,sortTable)

	for k,v in pairs(sortTable) do
		--品质大于5
		if tonumber(v.itemDesc.quality) >= 5 and 
			--强化过
		    v.va_item_text.armReinforceLevel ~= nil and
			tonumber(v.va_item_text.armReinforceLevel) > 0 and
			--没加锁
			(not(v.va_item_text.lock and tonumber(v.va_item_text.lock) == 1)) then
				table.insert(fitTable,v)
		end
	end
	
	local function sort(w1, w2)
		if tonumber(w1.va_item_text.armReinforceLevel) > tonumber(w2.va_item_text.armReinforceLevel) then
			return true
		else 
			return false
		end
	end

	table.sort(fitTable,sort)

	return fitTable
end

--[[
	@des 	:得到满足炼化条件的宝物
	@return :满足炼化条件的宝物
--]]
function getFitResolveTreas()
	local fitTable = {}
	local bagInfo = DataCache.getBagInfo()
	local sortTable = {}
	table.hcopy(bagInfo.treas,sortTable)

	for k,v in pairs(sortTable) do
		--品质大于5
		v.itemDesc.quality = ItemUtil.getTreasureQualityByItemInfo(v)

		if tonumber(v.itemDesc.quality) >= 5 and 
			--不是经验宝物
			v.itemDesc.resolve_exp_item ~= nil then
				table.insert(fitTable,v)
		end
	end	
    if(#fitTable > 1)then
		table.sort(fitTable,tableSort)
	end
	return fitTable
end
function tableSort(w1,w_2)	
	    local value1 = 0
	    local value2 = 0
		if (w1.itemDesc.quality > w_2.itemDesc.quality) then
			value1 = value1 + 20
		else
			value2 = value2 + 20
		end
		if tonumber(w1.va_item_text.treasureLevel) > tonumber(w_2.va_item_text.treasureLevel)then
			value1 = value1 + 10
		else
			value2 = value2 + 10
		end
		return value1 > value2
end
--[[
	@des 	:得到满足重生条件的宝物
	@return :满足重生条件的宝物
--]]
function getFitResurrectTreas()
	local fitTable = {}
	local bagInfo = DataCache.getBagInfo()
	local sortTable = {}
	table.hcopy(bagInfo.treas,sortTable)

	for k,v in pairs(sortTable) do
		--品质大于5
		local quality = ItemUtil.getTreasureQualityByItemInfo(v)
		if quality >= 4 and 
			--不是经验宝物
			v.itemDesc.isExpTreasure == nil and

			not table.isEmpty(v.va_item_text) and 
			--进行过精练
			--v.va_item_text.treasureEvolve ~= nil and
			--洗练或升级过
			( (v.va_item_text.treasureEvolve ~= nil and tonumber(v.va_item_text.treasureEvolve) > 0 )
			or (v.va_item_text.treasureLevel ~= nil and  tonumber(v.va_item_text.treasureLevel) > 0 )
			or (v.va_item_text.treasureDevelop ~= nil and tonumber(v.va_item_text.treasureDevelop) > -1) )then
				table.insert(fitTable,v)
		end
	end
	
	local function sort(w1,w2)
		if tonumber(w1.va_item_text.treasureLevel) > tonumber(w2.va_item_text.treasureLevel) then
			return true
		else
			return false
		end
	end

	table.sort(fitTable,sort)

	return fitTable
end

--[[
	@des 	:得到满足炼化条件的时装
	@return :满足炼化条件的时装
--]]
function getFitResolveCloth()
	local fitTable = {}
	local bagInfo = DataCache.getBagInfo()
	local sortTable = {}
	table.hcopy(bagInfo.dress,sortTable)

	for k,v in pairs(sortTable) do
		table.insert(fitTable,v)
	end

	local function sort(w1,w2)
		if tonumber(w1.va_item_text.dressLevel) > tonumber(w2.va_item_text.dressLevel) then
			return true
		else
			return false
		end
	end

	table.sort(fitTable,sort)

	return fitTable
end

--[[
	@des 	:得到满足重生条件的时装
	@return :满足重生条件的时装
--]]
function getFitResurrectCloth()
	local fitTable = {}
	local bagInfo = DataCache.getBagInfo()
	local sortTable = {}
	table.hcopy(bagInfo.dress,sortTable)

	for k,v in pairs(sortTable) do
		--升级过
		if v.va_item_text.dressLevel ~= nil and 
			tonumber(v.va_item_text.dressLevel) > 0 then
			table.insert(fitTable,v)
		end
	end

	local function sort(w1,w2)
		if tonumber(w1.va_item_text.dressLevel) > tonumber(w2.va_item_text.dressLevel) then
			return true
		else
			return false
		end
	end

	table.sort(fitTable,sort)

	return fitTable
end

--[[
	@des 	:得到满足炼化条件的神兵
	@return :满足炼化条件的神兵
--]]
function getFitResolveGod()
	local fitTable = {}
	local bagInfo = DataCache.getBagInfo()
	local sortTable = {}
	table.hcopy(bagInfo.godWp,sortTable)

	for k,v in pairs(sortTable) do

		if v.va_item_text.evolveNum ~= nil and 
			tonumber(v.va_item_text.evolveNum) == tonumber(v.itemDesc.originalevolve) and
			--不是经验神兵
			tonumber(v.itemDesc.isgodexp) == 0 and
			--没加锁
			(v.va_item_text.lock == nil or tonumber(v.va_item_text.lock) ~= 1 )then
			--tonumber(v.va_item_text.lock) ~= 1 then
				table.insert(fitTable,v)
		end
	end

	local function sort(w1,w2)
		if tonumber(w1.itemDesc.quality) > tonumber(w2.itemDesc.quality) then
			return true
		else
			return false
		end
	end

	table.sort(fitTable,sort)


	return fitTable
end

--[[
	@des 	:得到满足重生条件的神兵
	@return :满足炼化条件的神兵
--]]
function getFitResurrectGod()
	local fitTable = {}
	local bagInfo = DataCache.getBagInfo()
	local sortTable = {}
	table.hcopy(bagInfo.godWp,sortTable)

	for k,v in pairs(sortTable) do
		--强化过
		if  v.va_item_text.reinForceLevel ~= nil and 
			tonumber(v.va_item_text.reinForceLevel) > 0 and
			--不是经验神兵
			tonumber(v.itemDesc.isgodexp) == 0 and
			--没加锁
			(v.va_item_text.lock == nil or tonumber(v.va_item_text.lock) ~= 1) then
				table.insert(fitTable,v)
		end
	end

	local function sort(w1,w2)
		if tonumber(w1.itemDesc.quality) > tonumber(w2.itemDesc.quality) then
			return true
		else
			return false
		end
	end

	table.sort(fitTable,sort)

	return fitTable
end
--[[
	@des 	:得到满足炼化条件的符印
	@return :满足炼化条件的符印
--]]
function getFitResolveToken()
	local fitTable = {}
	local bagInfo = DataCache.getBagInfo()
	local sortTable = {}
	table.hcopy(bagInfo.rune,sortTable)
	-- for k,v in pairs(sortTable) do
	-- 	--没进化过
	-- 	if tonumber(v.va_item_text.evolveNum) == tonumber(v.itemDesc.originalevolve) and
	-- 		--不是经验神兵
	-- 		tonumber(v.itemDesc.isgodexp) == 0 and
	-- 		--没加锁
	-- 		tonumber(v.va_item_text.lock) ~= 1 then
	-- 			table.insert(fitTable,v)
	-- 	end
	-- end

	local function sort(w1,w2)
		if tonumber(w1.itemDesc.quality) > tonumber(w2.itemDesc.quality) then
			return true
		else
			return false
		end
	end

	table.sort(sortTable,sort)
	
	return sortTable
end
--得到符合重生条件的锦囊
function getFitResurrectPocket( ... )
	local fitTable = {}
	local bagInfo = DataCache.getBagInfo()
	local sortTable = bagInfo.pocket
	if(table.isEmpty(sortTable))then
		return {}
	end
	--table.hcopy(bagInfo.pocket,sortTable)

	for k,v in pairs(sortTable) do	
		--强化过
		if  v.va_item_text and 
			tonumber(v.itemDesc.is_exp) == 0 and
			tonumber(v.va_item_text.pocketLevel) > 0 and
			not v.va_item_text.lock then
			local tmpTab = {}
			table.hcopy(v,tmpTab)
			table.insert(fitTable,tmpTab)
		end
	end

	local function sort(w1,w2)
		if tonumber(w1.itemDesc.quality) > tonumber(w2.itemDesc.quality) then
			return true
		else
			return false
		end
	end

	table.sort(fitTable,sort)

	return fitTable
end
--[[
	@des 	:获取符合化魂条件的武将精华
--]]
function getFitSoulHeroJH( ... )
	local fitTable = {}
	local bagInfo = DataCache.getBagInfo()
	local sortTable = {}
	table.hcopy(bagInfo.props,sortTable)

	for k,v in pairs(sortTable) do
		local itemInfo = ItemUtil.getItemById(v.itemDesc[1])
		if itemInfo.can_diss then
			v.can_diss = itemInfo.can_diss
			v.diss_num = itemInfo.diss_num
			v.desc = itemInfo.desc
			table.insert(fitTable,v)
		end
	end
	local function sort(w1,w2)
		if tonumber(w1.itemDesc[1]) < tonumber(w2.itemDesc[1]) then
			return true
		else
			return false
		end
	end
	table.sort(fitTable,sort)
	return fitTable
end
--[[
	@des 	:获取符合炼化条件的兵符
--]]
function getFitResolveTally( ... )
	local fitTable = {}
	local bagInfo = DataCache.getBagInfo()
	local sortTable = {}
	table.hcopy(bagInfo.tally,sortTable)

	for k,tallyInfo in pairs(sortTable) do
		if 	(not tallyInfo.va_item_text.tallyLevel or tonumber(tallyInfo.va_item_text.tallyLevel) == 0) and
			-- 未被强化过
			(not tallyInfo.va_item_text.tallyDevelop or tonumber(tallyInfo.va_item_text.tallyDevelop) == 0) and
			-- 未被进阶过
			(not tallyInfo.va_item_text.tallyEvolve or tonumber(tallyInfo.va_item_text.tallyEvolve) == 0) then
			-- 未被精炼过
				table.insert(fitTable,tallyInfo)
		end

	end
	-- 品质由低到高
	local function sort(w1,w2)
		return tonumber(w1.itemDesc.quality) < tonumber(w2.itemDesc.quality)
	end
	table.sort(fitTable,sort)
	return fitTable
end
--[[
	@des 	:获取符合重生条件的兵符
--]]
function getFitResurrectTally( ... )
	local fitTable = {}
	local bagInfo = DataCache.getBagInfo()
	local sortTable = {}
	table.hcopy(bagInfo.tally,sortTable)
	for k,tallyInfo in pairs(sortTable) do
		if 	(tallyInfo.va_item_text.tallyLevel and tonumber(tallyInfo.va_item_text.tallyLevel) > 0) or
			-- 被强化过
			(tallyInfo.va_item_text.tallyDevelop and tonumber(tallyInfo.va_item_text.tallyDevelop) > 0) or
			-- 被进阶过
			(tallyInfo.va_item_text.tallyEvolve and tonumber(tallyInfo.va_item_text.tallyEvolve) > 0) then
			-- 被精炼过
				table.insert(fitTable,tallyInfo)
		end
	end
	-- 品质由低到高
	local function sort(w1,w2)
		return tonumber(w1.itemDesc.quality) < tonumber(w2.itemDesc.quality)
	end
	table.sort(fitTable,sort)
	return fitTable
end

--[[
	@desc 	: 获取符合炼化条件的战车
	@param 	: 
	@return : 符合炼化条件的战车
--]]
function getFitResolveChariot()
	local fitTable = {}
	local bagInfo = DataCache.getBagInfo()
	local sortTable = {}
	table.hcopy(bagInfo.chariotBag,sortTable)

	for k,chariotInfo in pairs(sortTable) do
		if 	(not chariotInfo.va_item_text.chariotEnforce or tonumber(chariotInfo.va_item_text.chariotEnforce) <= 0) then
			-- 未被强化过
			table.insert(fitTable,chariotInfo)
		end
	end

	-- 品质由低到高
	local function sort(v1,v2)
		return tonumber(v1.itemDesc.quality) < tonumber(v2.itemDesc.quality)
	end

	table.sort(fitTable,sort)

	return fitTable
end

--[[
	@desc 	: 获取符合重生条件的战车
	@param 	: 
	@return : 符合重生条件的战车
--]]
function getFitResurrectChariot()
	local fitTable = {}
	local bagInfo = DataCache.getBagInfo()
	local sortTable = {}
	table.hcopy(bagInfo.chariotBag,sortTable)

	for k,chariotInfo in pairs(sortTable) do
		if (chariotInfo.va_item_text.chariotEnforce ~= nil and tonumber(chariotInfo.va_item_text.chariotEnforce) > 0) then
			-- 强化过
			table.insert(fitTable,chariotInfo)
		end
	end

	-- 品质由高到低
	local function sort(v1,v2)
		return tonumber(v1.itemDesc.quality) > tonumber(v2.itemDesc.quality)
	end

	table.sort(fitTable,sort)

	print("--------------getFitResurrectChariot---------------")
	print_t(fitTable)

	return fitTable
end

--==================== Cell ====================
--[[
	@des 	:得到英雄的cell
	@param  :cell信息
	@param  :是否是被选中的
	@return :创建好的cell
--]]
function createHeroCell(p_itemInfo,p_isSelected)
	local tCell = CCTableViewCell:create()

	local cellBgSprite = CCSprite:create("images/hero/attr_bg.png")
	cellBgSprite:setAnchorPoint(ccp(0,0))
	tCell:addChild(cellBgSprite,1,kSpriteTag)

	local cellBgSize = cellBgSprite:getContentSize()

	-- 武将所属国家
	if p_itemInfo.country_icon then
		local countrySprite = CCSprite:create(p_itemInfo.country_icon)
		countrySprite:setAnchorPoint(ccp(0,0))
		countrySprite:setPosition(ccp(16,105))
		cellBgSprite:addChild(countrySprite)
	end

	-- 武将等级
	local lvLabel = CCLabelTTF:create("Lv." .. p_itemInfo.level,g_sFontName,20,CCSizeMake(130,30),kCCTextAlignmentCenter)
	lvLabel:setPosition(30,105)
	lvLabel:setColor(ccc3(0xff,0xee,0x3a))
	cellBgSprite:addChild(lvLabel)

	--因为合服后会出现后面加服务器名字的情况，因此显示不下
	--在这里对于长度过长的名字进行名字处截断处理
	local cutName = HeroUtil.getOriginalName(p_itemInfo.name)
	require "script/ui/redcarddestiny/RedCardDestinyData"
    cutName =  RedCardDestinyData.getHeroRealName(p_itemInfo.hid)
    local name = DB_Heroes.getDataById(p_itemInfo.htid).name
    if(cutName==name)then
    	cutName = HeroUtil.getOriginalName(p_itemInfo.name)
    end
	-- 武将名称
	local nameLabel = CCLabelTTF:create(cutName,g_sFontName,22,CCSizeMake(136,30),kCCTextAlignmentCenter)
	nameLabel:setPosition(139,106)
	local heroStarLv = HeroPublicLua.getCCColorByStarLevel(p_itemInfo.star_lv)
	nameLabel:setColor(heroStarLv)
	cellBgSprite:addChild(nameLabel)
	-- 星级
	local starSprite = HeroLayerCell.createStars("images/hero/star.png",p_itemInfo.star_lv,ccp(290,112),4)
	cellBgSprite:addChild(starSprite)
	--头像
	local headSprite = HeroPublicCC.createHeroHeadIcon(p_itemInfo)
	--新武将表示
	if HeroModel.isNewHero(p_itemInfo.hid) == true then
		local newAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/mail/new/new"),-1,CCString:create(""))
        newAnimSprite:setPosition(ccp(headSprite:getContentSize().width*0.5 - 20,headSprite:getContentSize().height - 20))
       	headSprite:addChild(newAnimSprite,3,10)
	end
	--资质
	local qualityLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2871") .. p_itemInfo.heroQuality,g_sFontName,24,CCSizeMake(200,30),kCCTextAlignmentLeft)
	qualityLabel:setPosition(ccp(120,44))
	qualityLabel:setColor(ccc3(0x48,0x1b,0))
	cellBgSprite:addChild(qualityLabel)
	--menu层
	local bgMenu = CCMenu:create()
    bgMenu:setTouchPriority(-395)
    bgMenu:setPosition(ccp(0,0))
    bgMenu:addChild(headSprite)
    cellBgSprite:addChild(bgMenu,1,kMenuTag)

    local checkedBtn = CheckBoxItem.create()
	checkedBtn:setAnchorPoint(ccp(0.5,0.5))
    checkedBtn:setPosition(ccp(cellBgSize.width*580/640,cellBgSize.height*0.5))
    checkedBtn:setEnabled(false)
    
	bgMenu:addChild(checkedBtn,1,kBtnTag)

	if p_isSelected == true then
		checkedBtn:selected()
	else
		checkedBtn:unselected()
	end

	return tCell
end

--[[
	@des 	:得到装备的cell
	@param  :cell信息
	@param  :是否是被选中的
	@return :创建好的cell
--]]
function createEquipCell(p_itemInfo,p_isSelected)
	print("createEquipCell p_itemInfo")
	print_t(p_itemInfo)
	local tCell = CCTableViewCell:create()
	--背景
	local cellBg = CCSprite:create("images/bag/equip/equip_cellbg.png")
	cellBg:setAnchorPoint(ccp(0,0))
	tCell:addChild(cellBg,1,kSpriteTag)
	local cellBgSize = cellBg:getContentSize()

	local quality = ItemUtil.getEquipQualityByItemInfo( p_itemInfo )
	-- icon
	local iconSprite = ItemSprite.getItemSpriteByItemId(tonumber(p_itemInfo.item_template_id),nil,nil,nil,quality)
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(cellBgSize.width * 0.1, cellBgSize.height * 0.55))
	cellBg:addChild(iconSprite)

	if(p_itemInfo.itemDesc.jobLimit and p_itemInfo.itemDesc.jobLimit > 0)then
		local suitTagSprite = CCSprite:create("images/common/suit_tag.png")
		suitTagSprite:setAnchorPoint(ccp(0.5, 0.5))
		suitTagSprite:setPosition(ccp(iconSprite:getContentSize().width*0.25, iconSprite:getContentSize().height*0.9))
		iconSprite:addChild(suitTagSprite)
	end

	-- 等级
	local levelLabel = CCRenderLabel:create(p_itemInfo.va_item_text.armReinforceLevel, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    levelLabel:setPosition(ccp(cellBgSize.width*0.1, cellBgSize.height*0.26))
    cellBg:addChild(levelLabel)

	-- 印章
    local sealSprite = BagUtil.getSealSpriteByItemTempId(p_itemInfo.item_template_id)
    sealSprite:setAnchorPoint(ccp(0, 0.5))
    sealSprite:setPosition(ccp(cellBgSize.width*0.2, cellBgSize.height*0.8))
    cellBg:addChild(sealSprite)
    -----------------------
    -- 名称
	-- local quality = ItemUtil.getEquipQualityByItemInfo( equipData )

	-- local nameLabel = ItemUtil.getEquipNameByItemInfo(equipData,g_sFontName,28)
 --    nameLabel:setAnchorPoint(ccp(0,0.5))
 --    nameLabel:setPosition(ccp(cellBgSize.width*0.2 + sealSprite:getContentSize().width + 0.5, cellBgSize.height*0.8))
 --    cellBg:addChild(nameLabel)
	-- -- 品质
 --    local starSp = CCSprite:create("images/formation/changeequip/star.png")
 --    starSp:setAnchorPoint(ccp(0.5, 0.5))
 --    cellBg:addChild(starSp)
    -----------------------
	-- 名称
	
	--local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)

	--local nameLabel = CCRenderLabel:create(p_itemInfo.itemDesc.name, g_sFontName, 28, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    local nameLabel = ItemUtil.getEquipNameByItemInfo(p_itemInfo,g_sFontName,28)
    --nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0,0.5))
    nameLabel:setPosition(ccp(cellBgSize.width*0.2 + sealSprite:getContentSize().width + 0.5, cellBgSize.height*0.8))
    cellBg:addChild(nameLabel)

	-- 品质
    local starSp = CCSprite:create("images/formation/changeequip/star.png")
    starSp:setAnchorPoint(ccp(0.5, 0.5))
    starSp:setPosition(ccp( cellBgSize.width*410.0/640, cellBgSize.height*0.8))
    cellBg:addChild(starSp)

	-- 星级
    local potentialLabel = CCRenderLabel:create(quality, g_sFontName,25, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    potentialLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    potentialLabel:setPosition(cellBgSize.width*375.0/640, cellBgSize.height*0.87)
    cellBg:addChild(potentialLabel)

 --    -- 获得相关数值
	-- local t_numerial, t_numerial_pl, t_equip_score = ItemUtil.getTop2NumeralByIID( tonumber(p_itemInfo.item_id))
	-- local descString = ""
	-- for key,v_num in pairs(t_numerial) do
	-- 	if (key == "hp") then
	-- 		descString = descString .. GetLocalizeStringBy("key_1765")
	-- 	elseif (key == "gen_att") then
	-- 		descString = descString .. GetLocalizeStringBy("key_2980")
	-- 	elseif(key == "phy_att"  )then
	-- 		descString = descString .. GetLocalizeStringBy("key_2958") 
	-- 	elseif(key == "magic_att")then
	-- 		descString = descString .. GetLocalizeStringBy("key_1536")
	-- 	elseif(key == "phy_def"  )then
	-- 		descString = descString .. GetLocalizeStringBy("key_1588") 
	-- 	elseif(key == "magic_def")then
	-- 		descString = descString .. GetLocalizeStringBy("key_3133") 
	-- 	end
	-- 	descString = descString .."+".. v_num .. "\n"
	-- end

	-- 映射关系
	local showAttrId = {1,9,2,3,4,5}
	local baseData = EquipAffixModel.getEquipAffixById(p_itemInfo.item_id)
	local fixData = EquipAffixModel.getEquipFixedAffix(p_itemInfo)
	local developData = EquipAffixModel.getDevelopAffixByInfo(p_itemInfo)
	for k,v in pairs(baseData) do
		if(fixData[k])then 
			baseData[k] = baseData[k]+fixData[k] 
		end
		if(developData[k])then 
			baseData[k] = baseData[k] + developData[k] 
		end
	end
	local descString = ""
	local i = 0
	for k,v_id in pairs(showAttrId) do
		if( baseData[v_id] > 0 )then
			i = i + 1
		    local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(v_id,baseData[v_id])
		    descString = descString .. affixDesc.sigleName .. " +"
			descString = descString .. displayNum .. "\n"
			if( i >= 3)then
				break
			end
		end
	end

	-- 描述
	local descLabel = CCLabelTTF:create(descString, g_sFontName, 23, CCSizeMake(300, 80), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	descLabel:setColor(ccc3(0x78, 0x25, 0x00))
	descLabel:setAnchorPoint(ccp(0, 0.5))
	descLabel:setPosition(ccp(cellBgSize.width*0.21, cellBgSize.height*0.4))
	cellBg:addChild(descLabel)

	-- 评分
	local equipScoreLabel = CCRenderLabel:create(p_itemInfo.itemDesc.base_score, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
    equipScoreLabel:setColor(ccc3(0x8a, 0xff, 0x00))
    equipScoreLabel:setPosition(ccp((cellBgSize.width*1.05-equipScoreLabel:getContentSize().width)/2, cellBgSize.height*0.35))
    cellBg:addChild(equipScoreLabel)

    -- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-395)
	cellBg:addChild(menuBar,1,kMenuTag)

	-- 复选框
	local checkedBtn = CheckBoxItem.create()
	checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
    checkedBtn:setEnabled(false)
	menuBar:addChild(checkedBtn,1,kBtnTag)
	if p_isSelected == true then
		checkedBtn:selected()
	else
		checkedBtn:unselected()
	end

	return tCell
end

--[[
	@des 	:得到宝物的cell
	@param  :cell信息
	@param  :是否是被选中的
	@return :创建好的cell
--]]
function createTreasCell(p_treasInfo,p_isSelected)
	local tCell = CCTableViewCell:create()
	--背景
	local cellBg = CCSprite:create("images/bag/equip/treas_cellbg.png")
	cellBg:setAnchorPoint(ccp(0,0))
	tCell:addChild(cellBg,1,kSpriteTag)
	local cellBgSize = cellBg:getContentSize()

	-- icon
	local iconSprite = ItemSprite.getItemSpriteById(tonumber(p_treasInfo.item_template_id), nil,nil,nil,nil,nil, nil,nil, nil,nil,nil,nil,nil,p_treasInfo)
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(cellBgSize.width * 0.1, cellBgSize.height * 0.55))
	cellBg:addChild(iconSprite)

	-- 等级
	local t_level = 0
	if( (not table.isEmpty(p_treasInfo.va_item_text) and p_treasInfo.va_item_text.treasureLevel ))then
		t_level = p_treasInfo.va_item_text.treasureLevel
	end
	local levelLabel = CCRenderLabel:create("+" .. t_level, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelLabel:setColor(ccc3(0x2c, 0xdb, 0x23))
    levelLabel:setAnchorPoint(ccp(0.5,0.5))
    levelLabel:setPosition(ccp(cellBgSize.width*0.1, cellBgSize.height*0.2))
    cellBg:addChild(levelLabel)

    -- 印章
    local sealSprite = BagUtil.getSealSpriteByItemTempId(p_treasInfo.item_template_id)
    sealSprite:setAnchorPoint(ccp(0, 0.5))
    sealSprite:setPosition(ccp(cellBgSize.width*0.2, cellBgSize.height*0.8))
    cellBg:addChild(sealSprite)

	-- 名称
	local quality = ItemUtil.getTreasureQualityByItemInfo( p_treasInfo )
	local nameLabel = ItemUtil.getTreasureNameByItemInfo( p_treasInfo, g_sFontName, 28 )
	nameLabel:setAnchorPoint(ccp(0,0.5))
    nameLabel:setPosition(ccp(cellBgSize.width*0.2+ sealSprite:getContentSize().width+5, cellBgSize.height*0.8))
    cellBg:addChild(nameLabel)

	-- 品质
    local starSp = CCSprite:create("images/formation/changeequip/star.png")
    starSp:setAnchorPoint(ccp(0.5, 0.5))
    starSp:setPosition(ccp( cellBgSize.width*400.0/640, cellBgSize.height*0.8))
    cellBg:addChild(starSp)

	-- 星级
    local potentialLabel = CCRenderLabel:create(quality, g_sFontName,25, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    potentialLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    potentialLabel:setPosition(cellBgSize.width*360.0/640, cellBgSize.height*0.87)
    cellBg:addChild(potentialLabel)

    -- 获得相关数值
	local attr_arr, score_t, ext_active = ItemUtil.getTreasAttrByItemId( tonumber(p_treasInfo.item_id), p_treasInfo)
	local descString = ""
	local desCount = 0
	for key,attr_info in pairs(attr_arr) do
		desCount = desCount + 1
	    local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(attr_info.attId, attr_info.num)
	    descString = descString .. affixDesc.sigleName .. " +"
		descString = descString .. displayNum .. "\n"
		if(desCount >= 3)then
			break
		end
	end

	-- 描述
	local descLabel = CCLabelTTF:create(descString, g_sFontName, 23, CCSizeMake(300, 80), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	descLabel:setColor(ccc3(0x78, 0x25, 0x00))
	descLabel:setAnchorPoint(ccp(0, 0.5))
	descLabel:setPosition(ccp(cellBgSize.width*0.21, cellBgSize.height*0.4))
	cellBg:addChild(descLabel)

	-- 评分
	local equipScoreLabel = CCRenderLabel:create(score_t.num, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
    equipScoreLabel:setColor(ccc3(0x8a, 0xff, 0x00))
    equipScoreLabel:setPosition(ccp((cellBgSize.width*1.05-equipScoreLabel:getContentSize().width)/2, cellBgSize.height*0.35))
    cellBg:addChild(equipScoreLabel)

    -- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-395)
	cellBg:addChild(menuBar,1,kMenuTag)

	-- 复选框
	local checkedBtn = CheckBoxItem.create()
	checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
    checkedBtn:setEnabled(false)
    
	menuBar:addChild(checkedBtn,1,kBtnTag)

	if p_isSelected == true then
		checkedBtn:selected()
	else
		checkedBtn:unselected()
	end

	return tCell
end
--[[
	@des 	:得到兵符的cell
	@param  :cell信息
	@param  :是否是被选中的
	@return :创建好的cell
--]]
function createTallyCell( p_Info,p_isSelected )
	require "script/ui/bag/TallyBagCell"
	local tCell = TallyBagCell.createCell(p_Info,nil,nil,nil,nil,true)
	local cellBgSize = CCSizeMake(639,169)
	-- 用于根据kSpriteTag取sp
	local sp = CCSprite:create()
	sp:setContentSize(cellBgSize)
	tCell:addChild(sp,1,kSpriteTag)
    -- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-395)
	sp:addChild(menuBar,1,kMenuTag)
	-- 复选框
	local checkedBtn = CheckBoxItem.create()
	checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
    checkedBtn:setEnabled(false)
	menuBar:addChild(checkedBtn,1,kBtnTag)
	if p_isSelected == true then
		checkedBtn:selected()
	else
		checkedBtn:unselected()
	end
	return tCell
end

--[[
	@des 	:得到时装的cell
	@param  :cell信息
	@param  :是否是被选中的
	@return :创建好的cell
--]]
function createClothCell(p_clothInfo,p_isSelected)
	local tCell = CCTableViewCell:create()

	--背景
	local cellBg = CCSprite:create("images/bag/equip/treas_cellbg.png")
	cellBg:setAnchorPoint(ccp(0,0))
	tCell:addChild(cellBg,1,kSpriteTag)
	local cellBgSize = cellBg:getContentSize()
	local dressHtid = p_clothInfo.item_template_id
	-- icon
	local iconSprite = ItemSprite.getItemSpriteByItemId(dressHtid)
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(cellBgSize.width * 0.1, cellBgSize.height * 0.55))
	cellBg:addChild(iconSprite)

	-- 等级
    local lvSprite = CCSprite:create("images/common/lv.png")
    lvSprite:setPosition(ccp(30, cellBgSize.height*0.2))
    lvSprite:setAnchorPoint(ccp(0, 0.5))
    cellBg:addChild(lvSprite)

	local t_level = 0
	if( (not table.isEmpty(p_clothInfo.va_item_text) and p_clothInfo.va_item_text.dressLevel ))then
		t_level = p_clothInfo.va_item_text.dressLevel
	end
	local levelLabel = CCRenderLabel:create(t_level, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelLabel:setColor(ccc3(0x2c, 0xdb, 0x23))
    levelLabel:setAnchorPoint(ccp(0.5,0.5))
    levelLabel:setPosition(ccp(80, cellBgSize.height*0.2))
    cellBg:addChild(levelLabel)

    --时装标签
 	local iconName = CCSprite:create("images/fashion/fashion_icon2.png")
    iconName:setAnchorPoint(ccp(0.5, 0))
    iconName:setPosition(ccp(150, 120))
    cellBg:addChild(iconName)

	-- 名称
	local name = nil
	local nameColor = HeroPublicLua.getCCColorByStarLevel(p_clothInfo.itemDesc.quality)

	local oldhtid = UserModel.getAvatarHtid()
	local model_id = DB_Heroes.getDataById(tonumber(oldhtid)).model_id

    local nameArray = lua_string_split(p_clothInfo.itemDesc.name, ",")
    for k,v in pairs(nameArray) do
    	local array = lua_string_split(v, "|")
    	if(tonumber(array[1]) == tonumber(model_id)) then
			name = array[2]
			break
    	end
    end

	local nameLabel = CCRenderLabel:create(name, g_sFontName, 28, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0, 0.5))
    nameLabel:setPosition(ccp(cellBgSize.width*0.2+ iconName:getContentSize().width+5, cellBgSize.height*0.8))
    cellBg:addChild(nameLabel)    

	-- 品质
    local starSp = CCSprite:create("images/formation/changeequip/star.png")
    starSp:setAnchorPoint(ccp(0.5, 0.5))
    starSp:setPosition(ccp( cellBgSize.width*370.0/640 + 50, cellBgSize.height*0.8))
    cellBg:addChild(starSp)

	-- 星级
    local potentialLabel = CCRenderLabel:create(p_clothInfo.itemDesc.quality, g_sFontName,25, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    potentialLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    potentialLabel:setPosition(cellBgSize.width*330.0/640 + 50, cellBgSize.height*0.87)
    cellBg:addChild(potentialLabel)

    -- 获得相关数值
    require "db/DB_Item_dress"
    require "script/ui/fashion/FashionData"
	local localData = DB_Item_dress.getDataById(dressHtid)
	local monsterIds = FashionData.getAttrByItemData(p_clothInfo,t_level)
	local descString = ""
	local i = 0
	for k,v in pairs(monsterIds) do
		i = i+1
		descString = descString .. v.desc.displayName .."+".. v.displayNum .. "\n"
		if(i == 4)then
			break
		end
	end

	-- 描述
	local descLabel = CCLabelTTF:create(descString, g_sFontName, 21, CCSizeMake(300, 80), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	descLabel:setColor(ccc3(0x78, 0x25, 0x00))
	descLabel:setAnchorPoint(ccp(0, 0.5))
	descLabel:setPosition(ccp(cellBgSize.width*0.21, cellBgSize.height*0.4))
	cellBg:addChild(descLabel)

	-- 评分
	local equipScoreLabel = CCRenderLabel:create(localData.score or 0, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
    equipScoreLabel:setColor(ccc3(0x8a, 0xff, 0x00))
    -- equipScoreLabel:setAnchorPoint(ccp(0,0))
    equipScoreLabel:setPosition(ccp((cellBgSize.width*1.05-equipScoreLabel:getContentSize().width)/2, cellBgSize.height*0.35))
    cellBg:addChild(equipScoreLabel)

    -- 选择框
    local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-395)
	cellBg:addChild(menuBar,1,kMenuTag)

	local checkedBtn = CheckBoxItem.create()
	checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
    checkedBtn:setEnabled(false)
    
	menuBar:addChild(checkedBtn,1,kBtnTag)

	if p_isSelected == true then
		checkedBtn:selected()
	else
		checkedBtn:unselected()
	end

	return tCell
end

--[[
	@des 	:得到神兵的cell
	@param  :cell信息
	@param  :是否是被选中的
	@return :创建好的cell
--]]
function createGodWeaponCell(p_godInfo,p_isSelected)
	local tCell = CCTableViewCell:create()
	-- 背景
    local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(52,44,6,4)
    local cellBg = CCScale9Sprite:create("images/common/bg/bg_1.png",fullRect, insetRect)
    cellBg:setContentSize(CCSizeMake(635,170))
    cellBg:setAnchorPoint(ccp(0,0))
	tCell:addChild(cellBg,1,kSpriteTag)
	local cellBgSize = cellBg:getContentSize()

	-- icon 
	local iconSprite = ItemSprite.getItemSpriteById( tonumber(p_godInfo.item_template_id), tonumber(p_godInfo.item_id), nil,nil,nil,nil,nil,nil,nil,nil,true )
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(cellBgSize.width * 0.1, cellBgSize.height * 0.55))
	cellBg:addChild(iconSprite)

	-- 等级背景
	local fullRect = CCRectMake(0,0,46,23)
    local insetRect = CCRectMake(20,8,5,1)
	local lvBg = CCScale9Sprite:create("images/common/bg/name_1.png",fullRect, insetRect)
	lvBg:setContentSize(CCSizeMake(92,26))
	lvBg:setAnchorPoint(ccp(0,0))
	lvBg:setPosition(ccp(20,18))
	cellBg:addChild(lvBg)

	-- 等级
    local lvSp = CCSprite:create("images/common/lv.png")
    lvSp:setAnchorPoint(ccp(0,0.5))
    lvSp:setPosition(ccp(8,lvBg:getContentSize().height*0.5))
    lvBg:addChild(lvSp)

	-- 等级
	local levelLabel = CCRenderLabel:create(p_godInfo.va_item_text.reinForceLevel, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    levelLabel:setAnchorPoint(ccp(0,0.5))
    levelLabel:setPosition(ccp(lvSp:getPositionX()+lvSp:getContentSize().width+2, lvBg:getContentSize().height*0.5))
    lvBg:addChild(levelLabel)

	-- 印章
    local sealSprite = BagUtil.getSealSpriteByItemTempId(p_godInfo.item_template_id)
    sealSprite:setAnchorPoint(ccp(0, 0.5))
    sealSprite:setPosition(ccp(cellBgSize.width*0.2, cellBgSize.height*0.8))
    cellBg:addChild(sealSprite)

	-- 名称
	local quality,_,_ = GodWeaponItemUtil.getGodWeaponQualityAndEvolveNum(p_godInfo.item_template_id, p_godInfo.item_id)
	local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	local nameLabel = CCRenderLabel:create(p_godInfo.itemDesc.name, g_sFontName, 28, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0,0.5))
    nameLabel:setPosition(ccp(cellBgSize.width*0.2 + sealSprite:getContentSize().width + 0.5, cellBgSize.height*0.8))
    cellBg:addChild(nameLabel)

	-- 品质
    local starSp = CCSprite:create("images/formation/changeequip/star.png")
    starSp:setAnchorPoint(ccp(0.5, 0.5))
    starSp:setPosition(ccp( cellBgSize.width*370.0/640, cellBgSize.height*0.8))
    cellBg:addChild(starSp)

	-- 星级
    local potentialLabel = CCRenderLabel:create(quality, g_sFontName,25, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    potentialLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    potentialLabel:setPosition(cellBgSize.width*330.0/640, cellBgSize.height*0.87)
    cellBg:addChild(potentialLabel)

    -- 小背景
    local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
    local attrBg = CCScale9Sprite:create("images/common/bg/goods_bg.png",fullRect, insetRect)
    attrBg:setContentSize(CCSizeMake(300,92))
    attrBg:setAnchorPoint(ccp(0,0))
    attrBg:setPosition(ccp(120,20))
    cellBg:addChild(attrBg)

    -- 属性
    local attrTab = GodWeaponItemUtil.getWeaponAbility(p_godInfo.item_template_id, p_godInfo.item_id)
	local posX = {0.05,0.05,0.5,0.5}
	local posY = {0.7,0.3,0.7,0.3}
	if(not table.isEmpty(attrTab) )then
		for k,v in pairs(attrTab) do
			local attrLabel = CCLabelTTF:create(v.name .. "+" .. v.showNum ,g_sFontName,23)
			attrLabel:setColor(ccc3(0x78, 0x25, 0x00))
			attrLabel:setAnchorPoint(ccp(0, 0.5))
			attrLabel:setPosition(ccp(attrBg:getContentSize().width*posX[k],attrBg:getContentSize().height*posY[k]))
			attrBg:addChild(attrLabel)
		end
	end

    -- 选择框
    local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-395)
	cellBg:addChild(menuBar,1,kMenuTag)

	local checkedBtn = CheckBoxItem.create()
	checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
    checkedBtn:setEnabled(false)
    
	menuBar:addChild(checkedBtn,1,kBtnTag)

	if p_isSelected == true then
		checkedBtn:selected()
	else
		checkedBtn:unselected()
	end

	return tCell
end
--[[
	@des 	:得到符印的cell
	@param  :cell信息
	@param  :是否是被选中的
	@return :创建好的cell
--]]
function createTokenCell(p_tokenInfo,p_isSelected)
	local tCell = CCTableViewCell:create()
	local item_template_id = tonumber(p_tokenInfo.item_template_id)
    -- 一次tonumber 终生受用 哇哈哈
	
    -- 背景
    local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(52,44,6,4)
    local cellBg = CCScale9Sprite:create("images/common/bg/bg_1.png",fullRect, insetRect)
    cellBg:setContentSize(CCSizeMake(635,170))
    cellBg:setAnchorPoint(ccp(0,0))
	tCell:addChild(cellBg,1,kSpriteTag)
	local cellBgSize = cellBg:getContentSize()

	-- icon
	local iconSprite = ItemSprite.getItemSpriteByItemId(item_template_id)
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(cellBgSize.width * 0.1, cellBgSize.height * 0.55))
	cellBg:addChild(iconSprite)

	-- 印章
    local sealSprite = BagUtil.getSealSpriteByItemTempId(tem_template_id)
    sealSprite:setAnchorPoint(ccp(0, 0.5))
    sealSprite:setPosition(ccp(cellBgSize.width*0.2, cellBgSize.height*0.8))
    cellBg:addChild(sealSprite)

	-- 名称
	local quality = p_tokenInfo.itemDesc.quality
	local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	local nameLabel = CCRenderLabel:create(p_tokenInfo.itemDesc.name, g_sFontName, 28, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0,0.5))
    nameLabel:setPosition(ccp(cellBgSize.width*0.2 + sealSprite:getContentSize().width + 0.5, cellBgSize.height*0.8))
    cellBg:addChild(nameLabel)

    -- 小背景
    local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
    local attrBg = CCScale9Sprite:create("images/common/bg/goods_bg.png",fullRect, insetRect)
    attrBg:setContentSize(CCSizeMake(280,92))
    attrBg:setAnchorPoint(ccp(0,0))
    attrBg:setPosition(ccp(120,20))
    cellBg:addChild(attrBg)

    -- 分割线
    local line = CCScale9Sprite:create("images/common/line02.png")
    line:setContentSize(CCSizeMake(90,4))
    line:setAnchorPoint(ccp(0.5,0.5))
    line:setPosition(ccp(160,attrBg:getContentSize().height*0.5))
    attrBg:addChild(line)
    line:setRotation(90)

    -- 属性
    local attrTab = RuneData.getRuneAbilityByItemId(p_tokenInfo.item_id)
	local posX = {0.05,0.05,0.05,0.05}
	local posY = {0.75,0.5,0.25,0}
	if(not table.isEmpty(attrTab) )then
		for k,v in pairs(attrTab) do
			local attrLabel = CCLabelTTF:create(v.name .. "+" .. v.showNum ,g_sFontName,23)
			attrLabel:setColor(ccc3(0x78, 0x25, 0x00))
			attrLabel:setAnchorPoint(ccp(0, 0.5))
			attrLabel:setPosition(ccp(attrBg:getContentSize().width*posX[k],attrBg:getContentSize().height*posY[k]))
			attrBg:addChild(attrLabel)
		end
	end

	-- 品级
    local starSp = CCSprite:create("images/god_weapon/pin.png")
    starSp:setAnchorPoint(ccp(0.5, 1))
    starSp:setPosition(ccp(220, attrBg:getContentSize().height))
    attrBg:addChild(starSp)

	-- 品级值
    local potentialLabel = CCRenderLabel:create(p_tokenInfo.itemDesc.score, g_sFontName,25, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    potentialLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    potentialLabel:setAnchorPoint(ccp(0.5,0.5))
    potentialLabel:setPosition(starSp:getPositionX(), 25)
    attrBg:addChild(potentialLabel)

    -- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-395)
	cellBg:addChild(menuBar,1,kMenuTag)

	-- 复选框
	local checkedBtn = CheckBoxItem.create()
	checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
    checkedBtn:setEnabled(false)
    
	menuBar:addChild(checkedBtn,1,kBtnTag)

	if p_isSelected == true then
		checkedBtn:selected()
	else
		checkedBtn:unselected()
	end
    
	return tCell
end
--[[
	@des 	:得到锦囊的cell
	@param  :cell信息
	@param  :是否是被选中的
	@return :创建好的cell
--]]
function createPocketCell(p_pocketData,p_isSelected)
	local tCell = CCTableViewCell:create()
	local item_template_id = tonumber(p_pocketData.item_template_id)
  
    -- 背景
    local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(52,44,6,4)
    local cellBg = CCScale9Sprite:create("images/common/bg/bg_1.png",fullRect, insetRect)
    cellBg:setContentSize(CCSizeMake(635,170))
    cellBg:setAnchorPoint(ccp(0,0))
	tCell:addChild(cellBg,1,kSpriteTag)
	local cellBgSize = cellBg:getContentSize()

	-- icon
	local iconSprite = ItemSprite.getItemSpriteByItemId(item_template_id)
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(cellBgSize.width * 0.1, cellBgSize.height * 0.55))
	cellBg:addChild(iconSprite)


	-- 等级背景
	local fullRect = CCRectMake(0,0,46,23)
    local insetRect = CCRectMake(20,8,5,1)
	local lvBg = CCScale9Sprite:create("images/common/bg/name_1.png",fullRect, insetRect)
	lvBg:setContentSize(CCSizeMake(92,26))
	lvBg:setAnchorPoint(ccp(0,0))
	lvBg:setPosition(ccp(20,18))
	cellBg:addChild(lvBg)

	-- 等级
    local lvSp = CCSprite:create("images/common/lv.png")
    lvSp:setAnchorPoint(ccp(0,0.5))
    lvSp:setPosition(ccp(8,lvBg:getContentSize().height*0.5))
    lvBg:addChild(lvSp)
	-- 等级
	local levelLabel = CCRenderLabel:create(p_pocketData.va_item_text.pocketLevel, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    levelLabel:setAnchorPoint(ccp(0,0.5))
    levelLabel:setPosition(ccp(lvSp:getPositionX()+lvSp:getContentSize().width+2, lvBg:getContentSize().height*0.5))
    lvBg:addChild(levelLabel)

	-- 印章
    local sealSprite = BagUtil.getSealSpriteByItemTempId(p_pocketData.item_template_id)
    sealSprite:setAnchorPoint(ccp(0, 0.5))
    sealSprite:setPosition(ccp(cellBgSize.width*0.2, cellBgSize.height*0.8))
    cellBg:addChild(sealSprite)

	-- 名称
	local quality = p_pocketData.itemDesc.quality
	local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	local nameLabel = CCRenderLabel:create(p_pocketData.itemDesc.name, g_sFontName, 28, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0,0.5))
    nameLabel:setPosition(ccp(cellBgSize.width*0.2 + sealSprite:getContentSize().width + 0.5, cellBgSize.height*0.8))
    cellBg:addChild(nameLabel)

    -- 品质
    local potentialLabel = CCRenderLabel:create(quality, g_sFontName,25, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    potentialLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    potentialLabel:setAnchorPoint(ccp(0,0.5))
    potentialLabel:setPosition(cellBgSize.width*350.0/640, cellBgSize.height*0.79)
    cellBg:addChild(potentialLabel)

	-- 星
    local starSp = CCSprite:create("images/formation/changeequip/star.png")
    starSp:setAnchorPoint(ccp(0, 0.5))
    starSp:setPosition(ccp(potentialLabel:getPositionX()+potentialLabel:getContentSize().width + 5, potentialLabel:getPositionY()))
    cellBg:addChild(starSp)

    -- 小背景
    local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
    local attrBg = CCScale9Sprite:create("images/common/bg/goods_bg.png",fullRect, insetRect)
    attrBg:setContentSize(CCSizeMake(280,90))
    attrBg:setAnchorPoint(ccp(0,0))
    attrBg:setPosition(ccp(120,20))
    cellBg:addChild(attrBg)

    -- 属性
    local posX = {0.05,0.05,0.5,0.5}
	local posY = {0.7,0.3,0.7,0.3}
    if( tonumber(p_pocketData.itemDesc.is_exp) == 1 )then
    	-- 经验锦囊
    	-- 提供经验的数值
		local add_exp = tonumber(p_pocketData.itemDesc.baseExp)
		if( p_pocketData.va_item_text and p_pocketData.va_item_text.pocketExp )then
			add_exp = add_exp + tonumber(p_pocketData.va_item_text.pocketExp)
		end
		local add_exp_label = CCLabelTTF:create(GetLocalizeStringBy("key_2531") .. "+" .. add_exp, g_sFontName, 23)
		add_exp_label:setColor(ccc3(0x78, 0x25, 0x00))
		add_exp_label:setAnchorPoint(ccp(0, 0.5))
		add_exp_label:setPosition(ccp(attrBg:getContentSize().width*posX[1],attrBg:getContentSize().height*posY[1]))
		attrBg:addChild(add_exp_label)
    else
	    require "script/ui/pocket/PocketData"
	    local attrTab = PocketData.getPocketAttrByItemInfo( p_pocketData )
		if(not table.isEmpty(attrTab) )then
			local i = 0
			for k_id,v_num in pairs(attrTab) do
				i = i + 1
				local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(k_id, v_num)
				local attrLabel = CCLabelTTF:create(affixDesc.sigleName .. "+" .. displayNum ,g_sFontName,23)
				attrLabel:setColor(ccc3(0x78, 0x25, 0x00))
				attrLabel:setAnchorPoint(ccp(0, 0.5))
				attrLabel:setPosition(ccp(attrBg:getContentSize().width*posX[i],attrBg:getContentSize().height*posY[i]))
				attrBg:addChild(attrLabel)
			end
		end
	end


    -- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-395)
	cellBg:addChild(menuBar,1,kMenuTag)

	-- 复选框
	local checkedBtn = CheckBoxItem.create()
	checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
    checkedBtn:setEnabled(false)
    
	menuBar:addChild(checkedBtn,1,kBtnTag)

	if p_isSelected == true then
		checkedBtn:selected()
	else
		checkedBtn:unselected()
	end
    
	return tCell
end
--[[
	@des 	:得到武将精华的cell
	@param  :cell信息
	@param  :是否是被选中的
	@return :创建好的cell
--]]
function createHeroJHCell(p_data,p_isSelected,p_index)
	local tCell = CCTableViewCell:create()
	local item_template_id = tonumber(p_data.item_template_id)
	-- 背景
    local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(52,44,6,4)
    local cellBg = CCScale9Sprite:create("images/common/bg/bg_1.png",fullRect, insetRect)
    cellBg:setContentSize(CCSizeMake(640,170))
    cellBg:setAnchorPoint(ccp(0,0))
	tCell:addChild(cellBg,1,kSpriteTag)
	local cellBgSize = cellBg:getContentSize()
    -- 小背景
    local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
    local attrBg = CCScale9Sprite:create("images/common/bg/goods_bg.png",fullRect, insetRect)
    attrBg:setContentSize(CCSizeMake(350,100))
    attrBg:setAnchorPoint(ccp(0,0))
    attrBg:setPosition(ccp(120,20))
    cellBg:addChild(attrBg)
	-- 数量背景
	local fullRect = CCRectMake(0,0,46,23)
    local insetRect = CCRectMake(20,8,5,1)
	local numBg = CCScale9Sprite:create("images/common/bg/name_1.png",fullRect, insetRect)
	numBg:setContentSize(CCSizeMake(92,26))
	numBg:setAnchorPoint(ccp(0,0))
	numBg:setPosition(ccp(20,20))
	cellBg:addChild(numBg)
	local numLabel = CCLabelTTF:create(GetLocalizeStringBy("syx_1060",p_data.item_num),g_sFontName,20,CCSizeMake(92,26),kCCTextAlignmentCenter)
	numLabel:setAnchorPoint(ccp(0.5,0.5))
	numLabel:setPosition(ccpsprite(0.5,0.4,numBg))
	numBg:addChild(numLabel)
	-- icon
	local iconSprite = ItemSprite.getItemSpriteByItemId(item_template_id,nil,nil,tonumber(p_data.item_id))
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(cellBgSize.width * 0.1, cellBgSize.height * 0.55))
	cellBg:addChild(iconSprite)
	-- 按钮层
	local menu = CCMenu:create()
	menu:setTouchPriority(kTouchPriority)
	menu:setAnchorPoint(ccp(0,0))
	menu:setPosition(ccp(0,0))
	cellBg:addChild(menu,1,kMenuTag)
    local selectBtn = CCMenuItemImage:create("images/common/btn/green01_n.png","images/common/btn/green01_h.png")
	selectBtn:setAnchorPoint(ccp(0.5,0.5))
    selectBtn:setPosition(ccp(550,cellBgSize.height*0.5))
    menu:addChild(selectBtn,1,p_index)
    local selectLabel = CCRenderLabel:create(GetLocalizeStringBy("lic_1585",100),g_sFontName, 30, 1, ccc3( 0x00, 0x00, 0x00))
    selectLabel:setColor(ccc3( 0xfe, 0xdb, 0x1c))
    selectLabel:setAnchorPoint(ccp(0.5,0.5))
    selectLabel:setPosition(ccpsprite(0.5,0.5,selectBtn))
    selectBtn:addChild(selectLabel)
    local selectNum = tonumber(RefiningData.getTempChooseNumById(p_index))
    local selectNumLabel = CCRenderLabel:create(GetLocalizeStringBy("lic_1586",selectNum),g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00))
    selectNumLabel:setColor(ccc3( 0x00, 0xff, 0x00))
    selectNumLabel:setAnchorPoint(ccp(0.5,1))
    selectNumLabel:setPosition(ccpsprite(0.5,0,selectBtn))
    selectBtn:addChild(selectNumLabel)
    selectBtn:registerScriptTapHandler(function ( ... )
    	-- 弹框
		local dialogShow = function ( ... )
			require "script/utils/SelectNumDialog"
			local dialog = SelectNumDialog:create()
			dialog:setTitle(GetLocalizeStringBy("lic_1585"))
			dialog:show(-810, 800)
			dialog:setMinNum(0)
			dialog:setLimitNum(tonumber(p_data.item_num))
			dialog:setNum(selectNum)
			dialog:registerOkCallback(function ()
				selectNum = dialog:getNum()
				-- item.num = num
				selectNumLabel:setString(GetLocalizeStringBy("lic_1586",selectNum))
				if selectNum > 0 then
					--增加已选中的数量
					if not RefiningData.isTempChoose(p_index) then
						RefiningData.addTempChooseNum(1)
					end
					RefiningData.addTempChooseIdAndNum(p_index,selectNum)
				else
					--减去已选中的数目
					if RefiningData.isTempChoose(p_index) then
						RefiningData.addTempChooseNum(-1)
					end
					--将其移除
					RefiningData.delTempChooseId(p_index)
				end
				-- 更新选择数量
				RefiningSelectLayer.refreshNumLabel()
			end)
		end
		-- 如果没有被选中
		if not RefiningData.isTempChoose(p_index) then
			-- 如果数量够了
			if RefiningData.getTempChooseNum() == RefiningData.getMaxChooseNum() then
				AnimationTip.showTip(GetLocalizeStringBy("key_3027"))
			else
				dialogShow()
			end
		else
			dialogShow()
		end
    end)
   	-- 印章
    local sealSprite = BagUtil.getSealSpriteByItemTempId(p_data.item_template_id)
    sealSprite:setAnchorPoint(ccp(0, 1))
    sealSprite:setPosition(ccp(cellBgSize.width*0.2, cellBgSize.height-15))
    cellBg:addChild(sealSprite)
    -- 名称
	local quality = p_data.itemDesc.quality
	local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	local nameLabel = CCRenderLabel:create(p_data.itemDesc.name, g_sFontName, 28, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0,1))
    nameLabel:setPosition(ccp(cellBgSize.width*0.2 + sealSprite:getContentSize().width + 0.5, cellBgSize.height-15))
    cellBg:addChild(nameLabel)
	-- require "script/ui/pocket/PocketData"
	-- 显示效果
	local desLabel = CCLabelTTF:create( p_data.desc, g_sFontName, 23, CCSizeMake(attrBg:getContentSize().width-15,attrBg:getContentSize().height-15), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	desLabel:setColor(ccc3(0x78, 0x25, 0x00))
	desLabel:setAnchorPoint(ccp(0.5, 0.5))
	desLabel:setPosition(ccp(attrBg:getContentSize().width*0.5,attrBg:getContentSize().height*0.5))
	attrBg:addChild(desLabel)
	return tCell
end

--[[
	@desc 	: 创建战车的选择Cell
	@param  : pCellData 战车信息
	@param  : pIsSelected 是否是被选中的
	@return : ChariotCell 带复选框的Cell
--]]
function createChariotCell( pCellData, pIsSelected )
	require "script/ui/bag/ChariotCell"
	local cell = ChariotCell.createCell(pCellData,-1,false,nil)
	-- 隐藏下拉按钮
	ChariotCell.setOpenMenuBtnVisible(false)
	local cellBgSize = CCSizeMake(639,190)

	-- 用于根据 kSpriteTag 取 checkedBtnBg
	local checkedBtnBg = CCSprite:create()
	checkedBtnBg:setContentSize(cellBgSize)
	cell:addChild(checkedBtnBg,1,kSpriteTag)

    -- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-395)
	checkedBtnBg:addChild(menuBar,1,kMenuTag)

	-- 复选框
	local checkedBtn = CheckBoxItem.create()
	checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
    checkedBtn:setEnabled(false)
	menuBar:addChild(checkedBtn,1,kBtnTag)
	if pIsSelected == true then
		checkedBtn:selected()
	else
		checkedBtn:unselected()
	end

	return cell
end

--==================== Select ====================
--[[
	@des 	:点击cell显示，针对炼化
	@param  :下标
--]]
function tapResolveSelect(p_index)
	require "script/ui/refining/RefiningData"
	local tipTable = 	{
							[RefiningData.kHeroTag] = GetLocalizeStringBy("key_3027"),
							[RefiningData.kEquipTag] = GetLocalizeStringBy("key_3124"),
							[RefiningData.kTreasureTag] = GetLocalizeStringBy("zzh_1334"),
							[RefiningData.kClothTag] = GetLocalizeStringBy("key_3164"),
							[RefiningData.kGodTag] = GetLocalizeStringBy("zzh_1230"),
                            [RefiningData.kTokenTag] = GetLocalizeStringBy("djn_175"),
                            [RefiningData.kTallyTag] = GetLocalizeStringBy("syx_1069"),
                            [RefiningData.kChariotTag] = GetLocalizeStringBy("lgx_1083"),
				  		}	

	local curTag = RefiningData.getTempChooseTag()
	--获得当前的a2
	local curA2
	if curTag == RefiningData.kHeroTag then
		curA2 = RefiningData.getHeroA2(p_index)
	elseif curTag == RefiningData.kEquipTag then
		curA2 = RefiningData.getEquipA2(p_index)
	elseif curTag == RefiningData.kTreasureTag then
		curA2 = RefiningData.getTreasA2(p_index)
	elseif curTag == RefiningData.kClothTag then
		curA2 = RefiningData.getClothA2(p_index)
	elseif curTag == RefiningData.kGodTag then
		curA2 = RefiningData.getGodA2(p_index)
	elseif curTag == RefiningData.kTokenTag then
		curA2 = RefiningData.getTokenA2(p_index)
	elseif curTag == RefiningData.kTallyTag then
		curA2 = RefiningData.getTallyA2(p_index)
	elseif curTag == RefiningData.kChariotTag then
		-- 战车
		curA2 = RefiningData.getChariotA2(p_index)
	end

	local bgSprite = tolua.cast(curA2:getChildByTag(kSpriteTag),"CCSprite")
	local bgMenu = tolua.cast(bgSprite:getChildByTag(kMenuTag),"CCMenu")
	local selectBtn = tolua.cast(bgMenu:getChildByTag(kBtnTag),"CCMenuItemSprite")

	local tipString = tipTable[curTag]

	--如果没有被选中
	if not RefiningData.isTempChoose(p_index) then
		--如果数量够了
		if RefiningData.getTempChooseNum() == RefiningData.getMaxChooseNum() then
			AnimationTip.showTip(tipString)
		else
			--对勾显示
			selectBtn:selected()
			--增加已选中的数量
			RefiningData.addTempChooseNum(1)
			--加入新的已选中的
			RefiningData.addTempChooseId(p_index)
		end
	else
		--对勾不显示
		selectBtn:unselected()
		--减去已选中的数目
		RefiningData.addTempChooseNum(-1)
		--将其移除
		RefiningData.delTempChooseId(p_index)
	end
	
	--更新选择数量
	RefiningSelectLayer.refreshNumLabel()
end

--[[
	@des 	:点击cell显示，针对重生
	@param  :下标
--]]
function tapResurrectSelect(p_index)
	require "script/ui/refining/RefiningData"
	local curTag = RefiningData.getTempChooseTag()
	--获得当前的a2
	local curA2
	if curTag == RefiningData.kHeroTag then
		curA2 = RefiningData.getHeroA2(p_index)
	elseif curTag == RefiningData.kEquipTag then
		curA2 = RefiningData.getEquipA2(p_index)
	elseif curTag == RefiningData.kTreasureTag then
		curA2 = RefiningData.getTreasA2(p_index)
	elseif curTag == RefiningData.kClothTag then
		curA2 = RefiningData.getClothA2(p_index)
	elseif curTag == RefiningData.kGodTag then
		curA2 = RefiningData.getGodA2(p_index)
	elseif curTag == RefiningData.kTokenTag then
		curA2 = RefiningData.getTokenA2(p_index)
	elseif curTag == RefiningData.kPocketTag then
		curA2 = RefiningData.getPocketA2(p_index)
	elseif curTag == RefiningData.kTallyTag then
		curA2 = RefiningData.getTallyA2(p_index)
	elseif curTag == RefiningData.kChariotTag then
		-- 战车
		curA2 = RefiningData.getChariotA2(p_index)
	end

	local bgSprite = tolua.cast(curA2:getChildByTag(kSpriteTag),"CCSprite")
	local bgMenu = tolua.cast(bgSprite:getChildByTag(kMenuTag),"CCMenu")
	local selectBtn = tolua.cast(bgMenu:getChildByTag(kBtnTag),"CCMenuItemSprite")

	--如果当前是选中的
	if RefiningData.isTempChoose(p_index) then
		selectBtn:unselected()
		RefiningData.addTempChooseNum(-1)
		RefiningData.delTempChooseId(p_index)
	else
		local haveChooseId = nil
		for k,v in pairs(RefiningData.getChooseTable()) do
			haveChooseId = k
		end
		--如果当前已经有选中的了
		if haveChooseId ~= nil then
			--获得已经选中的a2
			local otherA2
			if curTag == RefiningData.kHeroTag then
				otherA2 = tolua.cast(RefiningData.getHeroA2(haveChooseId),"CCTableViewCell")
			elseif curTag == RefiningData.kEquipTag then
				otherA2 = tolua.cast(RefiningData.getEquipA2(haveChooseId),"CCTableViewCell")
			elseif curTag == RefiningData.kTreasureTag then
				otherA2 = tolua.cast(RefiningData.getTreasA2(haveChooseId),"CCTableViewCell")
			elseif curTag == RefiningData.kClothTag then
				otherA2 = tolua.cast(RefiningData.getClothA2(haveChooseId),"CCTableViewCell")
			elseif curTag == RefiningData.kGodTag then
				otherA2 = tolua.cast(RefiningData.getGodA2(haveChooseId),"CCTableViewCell")
			elseif curTag == RefiningData.kTokenTag then
				otherA2 = tolua.cast(RefiningData.getTokenA2(haveChooseId),"CCTableViewCell")
			elseif curTag == RefiningData.kPocketTag then
				otherA2 = tolua.cast(RefiningData.getPocketA2(haveChooseId),"CCTableViewCell")
			elseif curTag == RefiningData.kTallyTag then
				otherA2 = tolua.cast(RefiningData.getTallyA2(haveChooseId),"CCTableViewCell")
			elseif curTag == RefiningData.kChariotTag then
				-- 战车
				otherA2 = tolua.cast(RefiningData.getChariotA2(haveChooseId),"CCTableViewCell")
			end
			--如果当前a2在屏幕可见范围内
			if otherA2 ~= nil then
				local otherSprite = tolua.cast(otherA2:getChildByTag(kSpriteTag),"CCSprite")
				local otherMenu = tolua.cast(otherSprite:getChildByTag(kMenuTag),"CCMenu")
				local otherBtn = tolua.cast(otherMenu:getChildByTag(kBtnTag),"CCMenuItemSprite")
				otherBtn:unselected()
			end
			RefiningData.addTempChooseNum(-1)
			RefiningData.delTempChooseId(haveChooseId)
		end

		selectBtn:selected()
		RefiningData.addTempChooseNum(1)
		RefiningData.addTempChooseId(p_index)
	end
	--更新选择数量
	RefiningSelectLayer.refreshNumLabel()
end
--[[
	@des 	:点击cell显示，针对化魂
	@param  :下标
--]]
function tapSoulSelect(p_index)
	require "script/ui/refining/RefiningData"
	local curTag = RefiningData.getTempChooseTag()
	if curTag == RefiningData.kHeroTag then
		curA2 = RefiningData.getHeroA2(p_index)
	elseif curTag == RefiningData.kHeroJHTag then
		curA2 = RefiningData.getHeroA2(p_index)
	end
	local bgSprite = tolua.cast(curA2:getChildByTag(kSpriteTag),"CCSprite")
	local bgMenu = tolua.cast(bgSprite:getChildByTag(kMenuTag),"CCMenu")
	local selectBtn = tolua.cast(bgMenu:getChildByTag(kBtnTag),"CCMenuItemSprite")

	local tipString = GetLocalizeStringBy("key_3027")

	--如果没有被选中
	if not RefiningData.isTempChoose(p_index) then
		--如果数量够了
		if RefiningData.getTempChooseNum() == RefiningData.getMaxChooseNum() then
			AnimationTip.showTip(tipString)
		else
			--对勾显示
			selectBtn:selected()
			--增加已选中的数量
			RefiningData.addTempChooseNum(1)
			--加入新的已选中的
			RefiningData.addTempChooseId(p_index)
		end
	else
		--对勾不显示
		selectBtn:unselected()
		--减去已选中的数目
		RefiningData.addTempChooseNum(-1)
		--将其移除
		RefiningData.delTempChooseId(p_index)
	end
	
	--更新选择数量
	RefiningSelectLayer.refreshNumLabel()
end
--[[
	@des 	: 获取符合化魂条件英雄
	@param  :
--]]
function getFitSoulHeroes( ... )
	--满足条件的英雄
	local fitTable = {}
	--所有的英雄
	local allHeroes = HeroModel.getAllHeroes()
	--因为牵扯到排序，所以只能增加一些key
	local sortTable = {}
	table.hcopy(allHeroes,sortTable)
	for k,v in pairs(sortTable) do
		local heroDBInfo = DB_Heroes.getDataById(v.htid)
		--不是主角
		if not HeroModel.isNecessaryHero(v.htid) and
			--不在阵容里
			not HeroPublicLua.isBusyWithHid(v.hid) and
			-- --不是小伙伴
			not LittleFriendData.isInLittleFriend(v.hid) and
			-- --不是第二套小伙伴
			not SecondFriendData.isInSecondFriendByHid(v.hid) and
			-- --没有进阶过的
			tonumber(v.evolve_level) <= 0 and
			-- --没有加锁的
			(v.lock == nil or tonumber(v.lock) ~= 1) and
			-- --不是小兵
			heroDBInfo.advanced_id ~= nil and tonumber(heroDBInfo.advanced_id) ~= 0 and
			--只要4、5星武将
			heroDBInfo.star_lv >= 4 and heroDBInfo.star_lv <= 5 and
			--没强化过的
			v.level ~= nil and tonumber(v.level) == 1 and 
			--不在神兵副本里
			not GodWeaponCopyData.isOnCopyFormationBy(v.hid) and
			--不在变身中
			not ActiveCache.isUnhandleTransfer(v.hid) and 
			--不在觉醒中
			not HeroModel.haveTalent(v.hid) then
				v.star_lv = heroDBInfo.star_lv
				v.heroQuality = heroDBInfo.heroQuality
				v.country_icon = HeroModel.getCiconByCidAndlevel(heroDBInfo.country,heroDBInfo.star_lv)
				v.head_icon_id = heroDBInfo.head_icon_id
				v.name = heroDBInfo.name
				--说明这个是满足条件的武将
				table.insert(fitTable,v)
		end
	end
	--排序
	local srotedTable = HeroSort.sortForHeroList(fitTable)

	return srotedTable
end
--将参数传来的宝物列表过滤掉带有符印的宝物 并返回
function getTreasWithoutFuyin( p_array)
	if(table.isEmpty(p_array))then
		return
	end
	print("判断符印传进来的宝物")
	print_t(p_array)
	local resultTab = {}
	for k,v in pairs(p_array) do
		if  v.va_item_text and not table.isEmpty(v.va_item_text.treasureInlay)then
			--有符印
		else
			table.insert(resultTab,v)
		end
	end
	print("判断后符印返回的宝物")
	print_t(resultTab)
	return resultTab
end