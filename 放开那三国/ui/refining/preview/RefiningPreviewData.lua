-- Filename: RefiningPreviewData.lua
-- Author: lgx
-- Date: 2016-05-11
-- Purpose: 炼化/重生预览数据层

module("RefiningPreviewData", package.seeall)

require "script/utils/LuaUtil"
require "script/ui/refining/RefiningData"

--[[
	@desc	: 处理炼化预览数据为指定格式
	@param 	: pSelectedArr 选择的武将或宝物等信息
	@param 	: pData 炼化预览数据
	@return : table {
			[1] => {
				type = "silver",
				num = 2000
			},
			[2] => {
				type = "soul",
				num = 2000
			},
			[3] => {
				type = "item",
				tid = "60002",
				realNnm = 100,
				minNum = 0,
				maxNum = 0
			} ...
		}
--]]
function solveResolvePreviewData( pSelectedArr, pData )
	local retData = {}

	-- 固定产物
	-- 将魂 soul
	if pData.soul and tonumber(pData.soul) ~= 0  then
		local soulTab = {}
		soulTab.type = "soul"
		soulTab.num = tonumber(pData.soul)
		table.insert(retData,soulTab)
	end

	-- 银币 silver
	if pData.silver and tonumber(pData.silver) ~= 0 then
		local silverTab = {}
		silverTab.type = "silver"
		silverTab.num = tonumber(pData.silver)
		table.insert(retData,silverTab)
	end

	-- 魂玉 jewel
	if pData.jewel and tonumber(pData.jewel) ~= 0 then
		local jewelTab = {}
		jewelTab.type = "jewel"
		jewelTab.num = tonumber(pData.jewel)
		table.insert(retData,jewelTab)
	end

	-- 兵符积分 tally_point
	if pData.tally_point and tonumber(pData.tally_point) ~= 0 then
		local tallyTab = {}
		tallyTab.type = "tally_point"
		tallyTab.num = tonumber(pData.tally_point)
		table.insert(retData,tallyTab)
	end

	-- 天宫令 tg => tg_num
	if pData.tg and tonumber(pData.tg) ~= 0 then
		local tgTab = {}
		tgTab.type = "tg_num"
		tgTab.num = tonumber(pData.tg)
		table.insert(retData,tgTab)
	end

	--[[ 处理成id => {
				"realNnm" = 12,
				"minNnm" = 0,
				"maxNnm" = 0
			}
	--]]
	local hasItem = {}
	if pData and pData.item then
		for k,v in pairs(pData.item) do
			local tab = {}
			tab.realNnm = tonumber(v)
			tab.minNnm = 0
			tab.maxNnm = 0
			hasItem[k] = tab
		end
	end

	-- 随机产物 紫装和神兵
	local curTag = RefiningData.getCurSelectTag()
	if (curTag == RefiningData.kEquipTag or curTag == RefiningData.kGodTag) then
		for i,itemInfo in ipairs(pSelectedArr) do
			if (itemInfo.itemDesc ~= nil) then
				local itemDbInfo = itemInfo.itemDesc
				if (itemDbInfo.resolvePreview ~= nil) then
					local resolvePreviewInfo = parseField(itemDbInfo.resolvePreview)
					for i,itemVal in ipairs(resolvePreviewInfo) do
						local itemId = tostring(itemVal[1])
						if (hasItem[itemId] ~= nil) then
							hasItem[itemId].realNnm = 0
							hasItem[itemId].minNnm = hasItem[itemId].minNnm + itemVal[2]
							hasItem[itemId].maxNnm = hasItem[itemId].maxNnm + itemVal[3]
						else
							local tab = {}
							tab.realNnm = 0
							tab.minNnm = itemVal[2]
							tab.maxNnm = itemVal[3]
							hasItem[itemId] = tab
						end
					end
				end
			end
		end
	end

	-- print("------------------solveResolvePreviewData hasItem--------------------")
	-- print_t(hasItem)
	-- print("------------------solveResolvePreviewData hasItem--------------------")

	-- 物品 item
	if hasItem then
		for k,v in pairs(hasItem) do
			local itemTab = {}
			itemTab.type = "item"
			itemTab.tid = tonumber(k)
			itemTab.num = tonumber(v.realNnm)
			itemTab.numStr = v.minNnm .. "~" .. v.maxNnm
			table.insert(retData,itemTab)
		end
	end

	-- 按num排序
    table.sort(retData,function (v1,v2)
    	return v1.num > v2.num
	end)

	-- print("------------------solveResolvePreviewData retData--------------------")
	-- print_t(retData)
	-- print("------------------solveResolvePreviewData retData--------------------")

	return retData
end

--[[
	@desc	: 处理重生预览数据为指定格式
	@param 	: pSelectedInfo 选择的武将或宝物等信息
	@param 	: pData 重生预览数据
	@return : table {
			[1] => {
				type = "silver",
				num = 2000
			},
			[2] => {
				type = "soul",
				num = 2000
			},
			[3] => {
				type = "item",
				tid = "60002",
				num = 100
			} ...
		}
--]]
function solveRebornPreviewData( pSelectedInfo, pData )
	local retData = {}
	-- 本身
	if pSelectedInfo and pSelectedInfo.hid ~= nil and tonumber(pSelectedInfo.hid) ~= 0 then
		-- 重生武将
		local heroTab = {}
		heroTab.type = "hero"
		if pSelectedInfo.star_lv ~= nil and tonumber(pSelectedInfo.star_lv) > 5 then
			-- 橙将 红将 特殊处理 有进阶等级显示
			heroTab.tid = tonumber(pData.hero_info.htid)
			heroTab.evolveLevel = tonumber(pData.hero_info.evolve_level)
			heroTab.num = 1
			-- 获取奖励
			pData = pData.reborn_get
		else
			-- 普通武将
			heroTab.tid = tonumber(pSelectedInfo.htid)
			heroTab.num = 1
		end
		table.insert(retData,heroTab)
	else
		-- 重生物品 装备 宝物 时装 神兵 锦囊 兵符
		local itemTab = {}
		itemTab.type = "item"
		itemTab.tid = tonumber(pSelectedInfo.item_template_id)
		itemTab.num = tonumber(pSelectedInfo.item_num)
		table.insert(retData,itemTab)
	end

	-- 如果宝物上有镶嵌符印
	local curTag = RefiningData.getCurSelectTag()
	if (curTag == RefiningData.kTreasureTag) then
		if(not table.isEmpty(pSelectedInfo.va_item_text) and not table.isEmpty(pSelectedInfo.va_item_text.treasureInlay))then
			if( table.isEmpty(pData.item) )then
				pData.item = {}
			end
			for kIndex,vInfo in pairs (pSelectedInfo.va_item_text.treasureInlay) do 
				--把返还的符印加到弹板信息上 后端返回数据里没有符印 只是推进背包
				pData.item[vInfo.item_template_id] = vInfo.item_num
			end
		end
	end
	
	-- 将魂 soul
	if pData.soul and tonumber(pData.soul) ~= 0  then
		local soulTab = {}
		soulTab.type = "soul"
		soulTab.num = tonumber(pData.soul)
		table.insert(retData,soulTab)
	end

	-- 魂玉 jewel
	if pData.jewel and tonumber(pData.jewel) ~= 0 then
		local jewelTab = {}
		jewelTab.type = "jewel"
		jewelTab.num = tonumber(pData.jewel)
		table.insert(retData,jewelTab)
	end

	-- 银币 silver
	if pData.silver and tonumber(pData.silver) ~= 0 then
		local silverTab = {}
		silverTab.type = "silver"
		silverTab.num = tonumber(pData.silver)
		table.insert(retData,silverTab)
	end

	-- 物品 item
	if pData and pData.item then
		for k,v in pairs(pData.item) do
			local itemTab = {}
			itemTab.type = "item"
			itemTab.tid = tonumber(k)
			itemTab.num = tonumber(v)
			table.insert(retData,itemTab)
		end
	end

	-- 武将 hero
	if pData and pData.hero then
		-- 合并相同武将
		local hashTable = {} -- 记录已有武将tab
    	local newHeroTable = {} -- 合并后的tab
        local i = 1
        for k,v in pairs(pData.hero) do
            if hashTable[tonumber(v.htid)] == nil then
                hashTable[tonumber(v.htid)] = i
                local innerTable = {}
                innerTable.htid = v.htid
                innerTable.num = tonumber(v.num)
                newHeroTable[i] = innerTable
                i = i + 1
            else
                newHeroTable[hashTable[tonumber(v.htid)]].num = newHeroTable[hashTable[tonumber(v.htid)]].num + tonumber(v.num)
            end
        end
        pData.hero = newHeroTable

		for k,v in pairs(pData.hero) do
			local heroTab = {}
			heroTab.type = "hero"
			heroTab.tid = tonumber(v.htid)
			heroTab.num = tonumber(v.num)
			table.insert(retData,heroTab)
		end
	end

	return retData
end