-- Filename: RefiningPreviewController.lua
-- Author: lgx
-- Date: 2016-05-11
-- Purpose: 炼化/重生预览控制层

module("RefiningPreviewController", package.seeall)

require "script/ui/refining/RefiningData"
require "script/ui/refining/RefiningUtils"
require "script/ui/refining/preview/RefiningPreviewService"

-------------------------------------------炼化预览接口-----------------------------------------------
--[[
    @desc   : 炼化预览
    @param  : pCallBack 回调
    @return : 
--]]
function previewResolve( pCallBack )
	local curTag = RefiningData.getCurSelectTag()
	if curTag == RefiningData.kHeroTag then
		-- 武将预览
		RefiningPreviewService.previewResolveHero(RefiningData.getSelectArray(),pCallBack)
	elseif curTag == RefiningData.kEquipTag then
		-- 装备预览
		RefiningPreviewService.previewResolveItem(RefiningData.getSelectArray(),pCallBack)
	elseif curTag == RefiningData.kTreasureTag then
		--策划新加需求 炼化的时候 列表里有带有符印的宝物 该宝物可选 但是真正发网络请求的时候 过滤掉带符印的宝物
		local treasArray = RefiningData.getSelectArray()
		treasArray = RefiningUtils.getTreasWithoutFuyin(treasArray)
		if(not table.isEmpty(treasArray))then
			-- 宝物预览
			RefiningPreviewService.previewResolveTreasure(treasArray,pCallBack)
		else
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("djn_226"))
		end
	elseif curTag == RefiningData.kClothTag then
		-- 时装预览
		RefiningPreviewService.previewResolveDress(RefiningData.getSelectArray(),pCallBack)
	elseif curTag == RefiningData.kGodTag then
		-- 神兵预览
		RefiningPreviewService.previewResolveGod(RefiningData.getSelectArray(),pCallBack)
	elseif curTag == RefiningData.kTokenTag then
		-- 符印预览
		RefiningPreviewService.previewResolveRune(RefiningData.getSelectArray(),pCallBack)
	elseif curTag == RefiningData.kTallyTag then
		-- 兵符预览
		RefiningPreviewService.previewResolveTally(RefiningData.getSelectArray(),pCallBack)	
	elseif curTag == RefiningData.kChariotTag then
		-- 战车预览
		RefiningPreviewService.previewResolveChariot(RefiningData.getSelectArray(),pCallBack)	
	end
end

-------------------------------------------炼化预览接口-----------------------------------------------

-------------------------------------------重生预览-----------------------------------------------
--[[
	@desc 	: 重生预览
	@param  : pCallBack 回调
	@return : 
--]]
function previewReborn( pCallBack )
	local selectInfo = RefiningData.getSelectArray()[1]
	local curTag = RefiningData.getCurSelectTag()
	if curTag == RefiningData.kHeroTag then
	
		local path = CCFileUtils:sharedFileUtils():getWritablePath() .. 'test'
	mFile = io.open(path, 'ab+')
	mFile:write(selectInfo.star_lv .. "\n")
	mFile:flush()
	
		if tonumber(selectInfo.star_lv) <= 5 then
			-- 普通武将预览
			RefiningPreviewService.previewRebornHero(selectInfo,pCallBack)
		elseif tonumber(selectInfo.star_lv) == 6 then
			-- 橙色武将预览
			RefiningPreviewService.previewRebornOrangeHero(selectInfo,pCallBack)
		elseif tonumber(selectInfo.star_lv) == 7 then
			-- 红色武将预览
			RefiningPreviewService.previewRebornRedHero(selectInfo,pCallBack)
		elseif tonumber(selectInfo.star_lv) == 8 then
			-- 红色武将预览
			RefiningPreviewService.previewRebornRedHero(selectInfo,pCallBack)
			
		end
	elseif curTag == RefiningData.kEquipTag then
		-- 装备预览
		RefiningPreviewService.previewRebornItem(selectInfo,pCallBack)
	elseif curTag == RefiningData.kTreasureTag then
		-- 宝物预览
		RefiningPreviewService.previewRebornTreasure(selectInfo,pCallBack)
	elseif curTag == RefiningData.kClothTag then
		-- 时装预览
		RefiningPreviewService.previewRebornDress(selectInfo,pCallBack)
	elseif curTag == RefiningData.kGodTag then
		-- 神兵预览
		RefiningPreviewService.previewRebornGod(selectInfo,pCallBack)
	elseif curTag == RefiningData.kPocketTag then
		-- 锦囊预览
		RefiningPreviewService.previewRebornPocket(selectInfo,pCallBack)
	elseif curTag == RefiningData.kTallyTag then
		-- 兵符预览
		RefiningPreviewService.previewRebornTally(RefiningData.getSelectArray(),pCallBack)
	elseif curTag == RefiningData.kChariotTag then
		-- 战车预览
		RefiningPreviewService.previewRebornChariot(RefiningData.getSelectArray(),pCallBack)
	end
end

-------------------------------------------重生预览-----------------------------------------------