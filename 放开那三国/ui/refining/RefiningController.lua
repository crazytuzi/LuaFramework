-- Filename: RefiningController.lua
-- Author: zhang zihang
-- Date: 2015-4-24
-- Purpose: 炼化炉炼化重生过程控制层

module ("RefiningController", package.seeall)

require "script/ui/refining/RefiningData"
require "script/ui/refining/RefiningService"
require "script/ui/recycle/BreakDownGiftLayer"
require "script/ui/recycle/ResurrectGiftLayer"
require "script/model/hero/HeroModel"
require "script/model/user/UserModel"
require "script/ui/rechargeActive/ActiveCache"
require "script/ui/refining/SoulLayer"

local kResolveItemZOrder = 999

--[[
	@des 	:处理一些杂七杂八的问题
--]]
function dealOverLordThings()
	--当前tag
	local curTag = RefiningData.getCurMainTag()
	if curTag == RefiningData.kResolveMainTag then
		ResolveLayer.enableMenuItem()
		--清除按钮上的显示
		ResolveLayer.clearAndShowItem()
	elseif curTag == RefiningData.kResurrectMainTag then
		RebornLayer.enableMenuItem()
		--清除按钮上的显示
		RebornLayer.clearItemSprite()
	elseif curTag == RefiningData.kSoulMainTag then
		SoulLayer.enableMenuItem()
		SoulLayer.clearAndShowItem()
	end
	--清除选择数据
	RefiningData.resetChooseData()
	--主界面按钮可点
	RefiningMainLayer.setMenuItemEnable()
	--清除快速选择
	RefiningData.setFastBeginNum(0)
end

--[[
	@des 	:为开始炼化准备一些事情
--]]
function prepareOverLordThings()
	--当前tag
	local curTag = RefiningData.getCurMainTag()
	if curTag == RefiningData.kResolveMainTag then
		ResolveLayer.disableMenuItem()
		ResolveLayer.menuItemUnVisible()
	elseif curTag == RefiningData.kResurrectMainTag then
		RebornLayer.minusGoldNum()
		RebornLayer.disableMenuItem()
		RebornLayer.menuItemUnVisible()

		RefiningMainLayer.updateGoldNum()
	elseif curTag == RefiningData.kSoulMainTag then
		SoulLayer.disableMenuItem()
		SoulLayer.menuItemUnVisible()
	end
	--设置按钮不可点击
	RefiningMainLayer.setMenuItemDisable()
end

--[[
	@des 	:炼化显示奖励
	@param  : p_giftInfo 奖励信息 pSelectInfo 重生的武将或物品
--]]
function resolveShowGift(p_giftInfo,pSelectInfo)
	local curTag = RefiningData.getCurMainTag()
	local showLayer
	if curTag == RefiningData.kResolveMainTag then
		--炼化
		showLayer = BreakDownGiftLayer.createLayer(p_giftInfo)
	else
		--重生
		showLayer = ResurrectGiftLayer.createLayer(p_giftInfo,pSelectInfo)
	end
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(showLayer,kResolveItemZOrder)
end

--==================== Resolve ====================
--[[
	@des 	:网络回调
	@param  :选择的英雄
	@param  :网络返回的数据
--]]
function resetChooseData( p_tag )
	RefiningData.resetChooseData()
	RefiningData.setCurSelectTag(p_tag)
	RefiningData.setFastBeginNum(0)
end
--[[
	@des 	:网络回调
	@param  :选择的英雄
	@param  :网络返回的数据
--]]
function heroServiceCallBack(p_selectHero,p_dictData)
	--杀掉选择的武将，哼，小样儿
	for i = 1,#p_selectHero do
		HeroModel.deleteHeroByHid(p_selectHero[i].hid)
	end
	--更新银币，战魂，魂玉数量
	UserModel.addSilverNumber(tonumber(p_dictData.ret.silver))
	UserModel.addSoulNum(tonumber(p_dictData.ret.soul))
	UserModel.addJewelNum(tonumber(p_dictData.ret.jewel))
	--刷新银币数
	RefiningMainLayer.updateSilverNum()
	--动画回调，弹出奖励面板
	local animationCallBack = function()
		--奖励面板
		resolveShowGift(p_dictData.ret)
		--清除英雄选择信息
		RefiningData.clearHeroFit()
		--清理杂七杂八
		dealOverLordThings()
	end
	--准备杂七杂八
	prepareOverLordThings()
	RefiningMainLayer.createAnimation(animationCallBack)
end

--[[
	@des 	:网络回调
	@param  :网络返回的数据
--]]
function itemServiceCallBack(p_dictData)
	--更新银币
	UserModel.addSilverNumber(tonumber(p_dictData.ret.silver))
	--刷新银币数
	RefiningMainLayer.updateSilverNum()
	--动画回调，弹出奖励面板
	local animationCallBack = function()
		--奖励面板
		resolveShowGift(p_dictData.ret)
		--清除装备选择信息
		RefiningData.clearEquipFit()
		--清理杂七杂八
		dealOverLordThings()
	end
	--准备杂七杂八
	prepareOverLordThings()
	RefiningMainLayer.createAnimation(animationCallBack)
end

--[[
	@des 	:网络回调
	@param  :网络返回的数据
--]]
function treasServiceCallBack(p_dictData)
	--更新银币
	UserModel.addSilverNumber(tonumber(p_dictData.ret.silver))
	--刷新银币数
	RefiningMainLayer.updateSilverNum()
	--动画回调，弹出奖励面板
	local animationCallBack = function()
		--奖励面板
		resolveShowGift(p_dictData.ret)
		--清除宝物选择信息
		RefiningData.clearTreasureFit()
		--清理杂七杂八
		dealOverLordThings()
	end
	--准备杂七杂八
	prepareOverLordThings()
	RefiningMainLayer.createAnimation(animationCallBack)
end

--[[
	@des 	:网络回调
	@param  :网络返回的数据
--]]
function clothServiceCallBack(p_dictData)
	--更新银币
	UserModel.addSilverNumber(tonumber(p_dictData.ret.silver))
	--刷新银币数
	RefiningMainLayer.updateSilverNum()
	--动画回调，弹出奖励面板
	local animationCallBack = function()
		--奖励面板
		resolveShowGift(p_dictData.ret)
		--清除时装选择信息
		RefiningData.clearClothFit()
		--清理杂七杂八
		dealOverLordThings()
	end
	--准备杂七杂八
	prepareOverLordThings()
	RefiningMainLayer.createAnimation(animationCallBack)
end

--[[
	@des 	:网络回调
	@param  :网络返回的数据
--]]
function godServiceCallBack(p_dictData)
	--更新银币
	UserModel.addSilverNumber(tonumber(p_dictData.ret.silver))
	--刷新银币数
	RefiningMainLayer.updateSilverNum()
	--动画回调，弹出奖励面板
	local animationCallBack = function()
		--奖励面板
		resolveShowGift(p_dictData.ret)
		--清除神兵选择信息
		RefiningData.clearGodFit()
		--清理杂七杂八
		dealOverLordThings()
	end
	--准备杂七杂八
	prepareOverLordThings()
	RefiningMainLayer.createAnimation(animationCallBack)
end
--[[
	@des 	:炼化兵符网络回调
	@param  :网络返回的数据
--]]
function tallyServiceCallBack( p_dictData )
	--更新兵符积分
	if(p_dictData.tally_point)then
		UserModel.addTallyPointNumber(tonumber(p_dictData.tally_point))
	end
	--动画回调，弹出奖励面板
	local animationCallBack = function()
		--奖励面板
		resolveShowGift(p_dictData)
		--清除英雄选择信息
		RefiningData.clearTallyFit()
		--清理杂七杂八
		dealOverLordThings()
	end
	--准备杂七杂八
	prepareOverLordThings()
	RefiningMainLayer.createAnimation(animationCallBack)
end

--[[
	@desc 	: 炼化战车回调
	@param  : pDictData 后端返回的数据
	@return :
--]]
function chariotServiceCallBack( pDictData )
	if (pDictData.silver) then
		-- 更新银币
		UserModel.addSilverNumber(tonumber(pDictData.silver))
		-- 刷新银币数
		RefiningMainLayer.updateSilverNum()
	end
	-- 动画回调 弹出奖励面板
	local animationCallBack = function()
		-- 奖励面板
		resolveShowGift(pDictData)
		-- 清除战车选择信息
		RefiningData.clearChariotFit()
		-- 清理杂七杂八
		dealOverLordThings()
	end
	-- 准备杂七杂八
	prepareOverLordThings()
	RefiningMainLayer.createAnimation(animationCallBack)
end

--[[
	@des 	:确认去炼化
--]]
function sureToBreakDown()
	local curTag = RefiningData.getCurSelectTag()
	if curTag == RefiningData.kHeroTag then
		RefiningService.resolveHero(RefiningData.getSelectArray(),heroServiceCallBack)
	elseif curTag == RefiningData.kEquipTag then
		RefiningService.resolveItem(RefiningData.getSelectArray(),itemServiceCallBack)
	elseif curTag == RefiningData.kTreasureTag then
		--策划新加需求 炼化的时候 列表里有带有符印的宝物 该宝物可选 但是真正发网络请求的时候 过滤掉带符印的宝物
		local treasArray = RefiningData.getSelectArray()
		treasArray = RefiningUtils.getTreasWithoutFuyin(treasArray)
		if(not table.isEmpty(treasArray))then
			RefiningService.resolveTreas(treasArray,treasServiceCallBack)
		else
			AnimationTip.showTip(GetLocalizeStringBy("djn_226"))
		end
	elseif curTag == RefiningData.kClothTag then
		RefiningService.resolveCloth(RefiningData.getSelectArray(),clothServiceCallBack)
	elseif curTag == RefiningData.kGodTag then
		RefiningService.resolveGod(RefiningData.getSelectArray(),godServiceCallBack)
	elseif curTag == RefiningData.kTokenTag then
		RefiningService.resolveToken(RefiningData.getSelectArray(),tokenRebornCallBack)
	elseif curTag == RefiningData.kTallyTag then
		RefiningService.resolveTally(RefiningData.getSelectArray(),tallyServiceCallBack)
	elseif curTag == RefiningData.kChariotTag then
		-- 炼化战车
		RefiningService.resolveChariot(RefiningData.getSelectArray(),chariotServiceCallBack)	
	end
end

--==================== Reborn ====================
--[[
	@des 	:网络回调
	@param  :网络返回的数据
--]]
function heroRebornCallBack(p_dictData)
	local selectInfo = RefiningData.getSelectArray()[1]
	--更新银币，战魂，魂玉数量
	UserModel.addSilverNumber(tonumber(p_dictData.ret.silver))
	UserModel.addSoulNum(tonumber(p_dictData.ret.soul))

	HeroModel.setHeroLevelByHid(selectInfo.hid,1)
	HeroModel.addEvolveLevelByHid(selectInfo.hid,-selectInfo.evolve_level)
	HeroModel.setHeroSoulByHid(selectInfo.hid,0)

	HeroModel.clearPillInfoByHid(selectInfo.hid)
	ActiveCache.setUserTransfer(selectInfo.hid)
	--刷新银币数
	RefiningMainLayer.updateSilverNum()
	--动画回调，弹出奖励面板
	local animationCallBack = function()
		--奖励面板
		resolveShowGift(p_dictData.ret,selectInfo)
		--清除英雄选择信息
		RefiningData.clearHeroFit()
		--清理杂七杂八
		dealOverLordThings()
	end
	--准备杂七杂八
	prepareOverLordThings()
	RefiningMainLayer.createAnimation(animationCallBack)
end

--[[
	@des 	:网络回调
	@param  :网络返回的数据
--]]
function orangeHeroCallBack(p_dictData)
	local selectInfo = RefiningData.getSelectArray()[1]
	--更新银币，战魂，魂玉数量
	UserModel.addSilverNumber(tonumber(p_dictData.ret.reborn_get.silver))
	HeroModel.setHeroByHid(selectInfo.hid,p_dictData.ret.hero_info)
	--清空武将天命战斗力
	require "script/ui/redcarddestiny/RedCardDestinyData"
	RedCardDestinyData.clearTotalAttForFightForce(selectInfo.hid)
	-- HeroModel.clearPillInfoByHid(selectInfo.hid)
	--刷新银币数
	RefiningMainLayer.updateSilverNum()
	--动画回调，弹出奖励面板
	local animationCallBack = function()
		--橙将 红将 记录一下后端返的新武将信息 add by lgx 20160513 重生奖励面板添加本身
		selectInfo.newHeroInfo = p_dictData.ret.hero_info
		--奖励面板
		resolveShowGift(p_dictData.ret.reborn_get,selectInfo)
		--清除英雄选择信息
		RefiningData.clearHeroFit()
		--清理杂七杂八
		dealOverLordThings()
	end
	--准备杂七杂八
	prepareOverLordThings()
	RefiningMainLayer.createAnimation(animationCallBack)
end

--[[
	@des 	:网络回调
	@param  :网络返回的数据
--]]
function itemRebornCallBack(p_dictData)
	local selectInfo = RefiningData.getSelectArray()[1]
	--更新银币，战魂，魂玉数量
	UserModel.addSilverNumber(tonumber(p_dictData.ret.silver))
	DataCache.resetArmInfoByItemID(selectInfo.item_id)
	--刷新银币数
	RefiningMainLayer.updateSilverNum()
	--动画回调，弹出奖励面板
	local animationCallBack = function()
		--奖励面板
		resolveShowGift(p_dictData.ret,selectInfo)
		--清除英雄选择信息
		RefiningData.clearEquipFit()
		--清理杂七杂八
		dealOverLordThings()
	end
	--准备杂七杂八
	prepareOverLordThings()
	RefiningMainLayer.createAnimation(animationCallBack)
end

--[[
	@des 	:网络回调
	@param  :网络返回的数据
--]]
function treasRebornCallBack(p_dictData)
	local selectInfo = RefiningData.getSelectArray()[1]
	--如果宝物上有镶嵌符印
	if(not table.isEmpty(selectInfo.va_item_text) and not table.isEmpty(selectInfo.va_item_text.treasureInlay))then
		if( table.isEmpty(p_dictData.ret.item ))then
			p_dictData.ret.item = {}
		end
		for k_index,v_info in pairs (selectInfo.va_item_text.treasureInlay) do 
			--DataCache.changeTreasureRuneInBag( selectInfo.item_id,nil, k_index) 
			--把返还的符印加到弹板信息上 后端返回数据里没有符印 只是推进背包
			p_dictData.ret.item[v_info.item_template_id] = v_info.item_num
		end
	end
	--更新银币，战魂，魂玉数量
	UserModel.addSilverNumber(tonumber(p_dictData.ret.silver))
	DataCache.resetTreasureInfoByItemID(selectInfo.item_id)
	--刷新银币数
	RefiningMainLayer.updateSilverNum()
	--动画回调，弹出奖励面板
	local animationCallBack = function()
		--奖励面板
		resolveShowGift(p_dictData.ret,selectInfo)
		--清除英雄选择信息
		RefiningData.clearTreasureFit()
		--清理杂七杂八
		dealOverLordThings()
	end
	--准备杂七杂八
	prepareOverLordThings()
	RefiningMainLayer.createAnimation(animationCallBack)
end

--[[
	@des 	:网络回调
	@param  :网络返回的数据
--]]
function clothRebornCallBack(p_dictData)
	local selectInfo = RefiningData.getSelectArray()[1]
	--更新银币，战魂，魂玉数量
	UserModel.addSilverNumber(tonumber(p_dictData.ret.silver))
	DataCache.resetClothInfoByItemId(selectInfo.item_id)
	--刷新银币数
	RefiningMainLayer.updateSilverNum()
	--动画回调，弹出奖励面板
	local animationCallBack = function()
		--奖励面板
		resolveShowGift(p_dictData.ret,selectInfo)
		--清除英雄选择信息
		RefiningData.clearClothFit()
		--清理杂七杂八
		dealOverLordThings()
	end
	--准备杂七杂八
	prepareOverLordThings()
	RefiningMainLayer.createAnimation(animationCallBack)
end

--[[
	@des 	:网络回调
	@param  :网络返回的数据
--]]
function godRebornCallBack(p_dictData)
	local selectInfo = RefiningData.getSelectArray()[1]
	--更新银币，战魂，魂玉数量
	UserModel.addSilverNumber(tonumber(p_dictData.ret.silver))
	DataCache.resetGodWeaponById(selectInfo.item_id,selectInfo.itemDesc)
	--刷新银币数
	RefiningMainLayer.updateSilverNum()
	--动画回调，弹出奖励面板
	local animationCallBack = function()
		--奖励面板
		resolveShowGift(p_dictData.ret,selectInfo)
		--清除英雄选择信息
		RefiningData.clearGodFit()
		--清理杂七杂八
		dealOverLordThings()
	end
	--准备杂七杂八
	prepareOverLordThings()
	RefiningMainLayer.createAnimation(animationCallBack)
end
--[[
	@des 	:网络回调
	@param  :网络返回的数据
--]]
function pocketRebornCallBack(p_dictData)
	local selectInfo = RefiningData.getSelectArray()[1]
	--更新银币，战魂，魂玉数量
	UserModel.addSilverNumber(tonumber(p_dictData.ret.silver))
	DataCache.resetPocketById(selectInfo.item_id,selectInfo.itemDesc)
	--刷新银币数

	if( table.isEmpty(p_dictData.ret.item ))then
		p_dictData.ret.item = {}
	end
	--策划说要把重生的锦囊也加在弹板上 。。。。。 。。。。。。 。。。。。
	-- p_dictData.ret.item[selectInfo.item_template_id] = 1
	RefiningMainLayer.updateSilverNum()
	--动画回调，弹出奖励面板
	local animationCallBack = function()
		--奖励面板
		resolveShowGift(p_dictData.ret,selectInfo)
		--清除英雄选择信息
		RefiningData.clearPocketFit()
		--清理杂七杂八
		dealOverLordThings()
	end
	--准备杂七杂八
	prepareOverLordThings()
	RefiningMainLayer.createAnimation(animationCallBack)
end
--[[
	@des 	:网络回调
	@param  :网络返回的数据
--]]
function tokenRebornCallBack(p_dictData)

	local selectInfo = RefiningData.getSelectArray()[1]
	--更新银币
	if(p_dictData.ret.silver)then
		UserModel.addSilverNumber(tonumber(p_dictData.ret.silver))
	end
	--更新天工令
	if(p_dictData.ret.tg)then
		UserModel.addGodCardNum(tonumber(p_dictData.ret.tg))
	end
	--刷新银币数
	RefiningMainLayer.updateSilverNum()

	--动画回调，弹出奖励面板
	local animationCallBack = function()
		--奖励面板
		resolveShowGift(p_dictData.ret,selectInfo)
		--清除英雄选择信息
		RefiningData.clearTokenFit()
		--清理杂七杂八
		dealOverLordThings()
	end
	--准备杂七杂八
	prepareOverLordThings()
	RefiningMainLayer.createAnimation(animationCallBack)
end
--[[
	@des 	:兵符重生网络回调
	@param  :网络返回的数据
--]]
function tallyRebornCallBack(p_dictData)

	local selectInfo = RefiningData.getSelectArray()[1]
	-- 重置兵符数据
	DataCache.changeTallyLvAndExpInBag(selectInfo.item_id,0,0)
	DataCache.changeTallyDevLvInBag(selectInfo.item_id,0)
	DataCache.changeTallyEvolveLvInBag(selectInfo.item_id,0)
	--更新银币
	if(p_dictData.silver)then
		UserModel.addSilverNumber(tonumber(p_dictData.silver))
	end
	-- 更新魂玉
	if(p_dictData.jewel) then
		UserModel.addJewelNum(tonumber(p_dictData.jewel))
	end
	--刷新银币数
	RefiningMainLayer.updateSilverNum()
	--动画回调，弹出奖励面板
	local animationCallBack = function()
		--奖励面板
		resolveShowGift(p_dictData,selectInfo)
		--清除英雄选择信息
		RefiningData.clearTallyFit()
		--清理杂七杂八
		dealOverLordThings()
	end
	--准备杂七杂八
	prepareOverLordThings()
	RefiningMainLayer.createAnimation(animationCallBack)
end

--[[
	@desc 	: 重生战车回调
	@param  : pDictData 后端返回的数据
	@return :
--]]
function chariotRebornCallBack( pDictData )
	local selectInfo = RefiningData.getSelectArray()[1]
	-- 重置战车数据
	DataCache.updateChariotEnforceLvInBag(selectInfo.item_id,0)
	-- 更新银币
	if(pDictData.silver)then
		UserModel.addSilverNumber(tonumber(pDictData.silver))
	end
	-- 更新魂玉
	if(pDictData.jewel) then
		UserModel.addJewelNum(tonumber(pDictData.jewel))
	end
	-- 刷新银币数
	RefiningMainLayer.updateSilverNum()
	-- 动画回调 弹出奖励面板
	local animationCallBack = function()
		-- 奖励面板
		resolveShowGift(pDictData,selectInfo)
		-- 清除战车选择信息
		RefiningData.clearChariotFit()
		-- 清理杂七杂八
		dealOverLordThings()
	end
	-- 准备杂七杂八
	prepareOverLordThings()
	RefiningMainLayer.createAnimation(animationCallBack)
end

--[[
	@des 	:确认去重生
--]]
function sureToResurrect()
	local selectInfo = RefiningData.getSelectArray()[1]
	local curTag = RefiningData.getCurSelectTag()
	if curTag == RefiningData.kHeroTag then
		if tonumber(selectInfo.star_lv) <= 5 then
			RefiningService.rebornHero(selectInfo,heroRebornCallBack)
		elseif tonumber(selectInfo.star_lv) == 6 then
			RefiningService.rebornOrangeHero(selectInfo,orangeHeroCallBack)
		elseif tonumber(selectInfo.star_lv) == 7 then
			RefiningService.rebornRedHero(selectInfo,orangeHeroCallBack)
		elseif tonumber(selectInfo.star_lv) == 8 then
			--金卡
			RefiningService.rebornRedHero(selectInfo,orangeHeroCallBack)
		end
	elseif curTag == RefiningData.kEquipTag then
		RefiningService.rebornItem(selectInfo,itemRebornCallBack)
	elseif curTag == RefiningData.kTreasureTag then
		RefiningService.rebornTreas(selectInfo,treasRebornCallBack)
	elseif curTag == RefiningData.kClothTag then
		RefiningService.rebornCloth(selectInfo,clothRebornCallBack)
	elseif curTag == RefiningData.kGodTag then
		RefiningService.rebornGod(selectInfo,godRebornCallBack)
	elseif curTag == RefiningData.kPocketTag then
		RefiningService.rebornPocket(selectInfo,pocketRebornCallBack)
	elseif curTag == RefiningData.kTallyTag then
		RefiningService.rebornTally(RefiningData.getSelectArray(),tallyRebornCallBack)
	elseif curTag == RefiningData.kChariotTag then
		-- 重生战车
		RefiningService.rebornChariot(RefiningData.getSelectArray(),chariotRebornCallBack)
	end
end
--==================== 化魂 ====================
--[[
	@des 	:一键添加
--]]
function oneKeyAdd( ... )
	-- body
	RefiningData.resetChooseData()
	RefiningData.resetTempData()
	RefiningData.setSoulFit()
	SoulLayer.updateMenuItemContainer()
end
--[[
	@des 	:确定化魂
--]]
function sureToSoul( curTag )
	--判断银币是否充足
	local needSilver = RefiningData.getSoulSilver()
	if(UserModel.getSilverNumber() < needSilver) then
        AnimationTip.showTip(GetLocalizeStringBy("key_1114"))
        SoulLayer.updateAfterSoul()
        return
    end
    -- 化魂网络回调
    local callBack = function ( pData )
    	if curTag == RefiningData.kHeroTag then
		    RefiningData.removeSelectedHeros()
	    elseif curTag == RefiningData.kHeroJHTag then
	    	RefiningData.clearTempHeroJHInfo()
    	end
		--刷新银币数
		UserModel.addSilverNumber(-needSilver)
		RefiningMainLayer.updateSilverNum()
		local rewardData = RefiningData.getParseData(pData)
		--动画回调，弹出奖励面板
		local animationCallBack = function()
			--奖励面板
			require "script/ui/recycle/ShowRewardDialog"
			ShowRewardDialog.showLayer(rewardData)
			if RefiningData.getCurMainTag() == RefiningData.kSoulMainTag then
		        SoulLayer.updateAfterSoul()
		    end
			--清理杂七杂八
			dealOverLordThings()
		end
		--准备杂七杂八
		prepareOverLordThings()
		RefiningMainLayer.createAnimation(animationCallBack)
    end
    if curTag == RefiningData.kHeroTag then
		RefiningService.soulHero(RefiningData.getSelectHidAry(),function ( cbFlag, dictData, bRet )
			callBack(dictData)
		end)
	elseif curTag == RefiningData.kHeroJHTag then
		RefiningService.resolveHeroJH(RefiningData.getSelectArray(),function ( cbFlag, dictData, bRet )
			callBack(dictData)
		end)
	end
end