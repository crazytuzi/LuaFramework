-- Filename: NFashionInfoCtrl.lua
-- Author: zhangqiang
-- Date: 2016-05-30
-- Purpose: 时装信息界面控制器

module("NFashionInfoCtrl", package.seeall)
require "script/ui/fashion/fashionInfo/NFashionInfoData"
require "script/ui/fashion/fashionInfo/NFashionInfoLayer"
require "script/ui/fashion/FashionLayer"

local _bPreMenuVisible = nil
local _bPreAvatarVisible = nil
local _bPreBulletinVisible = nil

local _fnStrengthenClose = nil

--[[
	desc:显示信息界面 
	param:
	return:
--]]
function showLayer( pFashionTid, pFashionId, pShowStrengthenBtn, pShowChangeBtn, pStrengthenCloseCb, pTouchPriority, pZOrder )
	print("NFashionInfoCtrl showLayer params ===============", pFashionTid, pFashionId, pShowStrengthenBtn, pShowChangeBtn, pStrengthenCloseCb, pTouchPriority, pZOrder)
	
	if pFashionId ~= nil and pFashionId > 0 then --已获取该时装时
		showLayerById(pFashionId, pTouchPriority, pZOrder )   --阵容－时装信息 默认显示（更换、卸下、强化按钮）

		--更新信息界面的按钮显示状态
		if pShowStrengthenBtn == true and pShowChangeBtn ~= true then   --背包－时装信息界面（显示 强化、关闭按钮）
			NFashionInfoData.setShowType(NFashionInfoData._kFashionInfoManual)   --开启人为控制按钮显示模式
			NFashionInfoData.setChangeShow(false)
			NFashionInfoData.setUnequipShow(false)
			NFashionInfoData.setStrengthenShow(true)
			NFashionInfoData.setCloseShow(true)

			NFashionInfoLayer.refreshBottomBarBtns()    --刷新底部按钮
		-- elseif pShowStrengthenBtn ~= true and pShowChangeBtn ~= true then  --时装屋－时装信息界面（只显示 关闭按钮）
		-- 	NFashionInfoData.setShowType(NFashionInfoData._kFashionInfoManual)   --开启人为控制按钮显示模式
		-- 	NFashionInfoData.setChangeShow(false)
		-- 	NFashionInfoData.setUnequipShow(false)
		-- 	NFashionInfoData.setStrengthenShow(false)
		-- 	NFashionInfoData.setCloseShow(true)

		-- 	NFashionInfoLayer.refreshBottomBarBtns()    --刷新底部按钮
		else
			
		end
	elseif (pFashionId == nil or pFashionId <= 0) and pFashionTid ~= nil and pFashionTid > 0 then  --没有获取到该时装时
		showLayerByTid(pFashionTid, pTouchPriority, pZOrder)    ----时装屋－时装信息界面 （只显示关闭 目前时装屋中的时装是否已拥有都是通过该接口显示的）
	else

	end

	--注册关闭强化界面后的回调
	registerStrengthenCloseHandler(pStrengthenCloseCb)
end


--[[
	desc:根据时装id显示信息界面 
	param:
	return:
--]]
function showLayerById( pFashionId, pTouchPriority, pZOrder )
	init(pTouchPriority, pZOrder)
	
	NFashionInfoData.setFashionInfoById(pFashionId)
	-- NFashionInfoData.setFashionInfoById(114550118)   --英雄身上
	-- NFashionInfoData.setFashionInfoById(114550119)
	-- NFashionInfoData.setFashionInfoById(114550117)
	NFashionInfoData.setShowType(NFashionInfoData._kFashionInfoOperation)

	NFashionInfoLayer.show()
end

--[[
	desc:根据时装tid显示信息界面 
	param:
	return:
--]]
function showLayerByTid( pFashionTid, pTouchPriority, pZOrder )
	init(pTouchPriority, pZOrder)
	

	NFashionInfoData.setFashionInfoByTid(pFashionTid)

	NFashionInfoData.setShowType(NFashionInfoData._kFashionInfoOnly)

	NFashionInfoLayer.show()

end

--[[
	desc: 关闭界面
	param:
	return:
--]]
function deinit( ... )
	_fnStrengthenClose = nil

	--关闭UI
	NFashionInfoLayer.deinit()
	NFashionInfoData.deinit()


	--还原打开界面前公共UI的显示状态
	popPreStatus()
end

--[[
	desc: 构造数据和UI
	param:
	return:
--]]
function init( pTouchPriority, pZOrder )
	--保存打开界面前公共UI的显示状态
	pushPreStatus()

	NFashionInfoData.init()
	NFashionInfoLayer.init(pTouchPriority, pZOrder)

	registerMainHandler()
end

--[[
	desc: 保存打开界面前的状态
	param:
	return:
--]]
function pushPreStatus( ... )
	_bPreMenuVisible = MainScene.isMenuVisible()
	_bPreAvatarVisible = MainScene.isAvatarVisible()
	_bPreBulletinVisible = MainScene.isBulletinVisible()

	print("pushPreStatus _bPreMenuVisible: ", _bPreMenuVisible, " _bPreAvatarVisible: ", _bPreAvatarVisible, " _bPreBulletinVisible: ", _bPreBulletinVisible)
end

--[[
	desc: 还原打开界面前的状态
	param:
	return:
--]]
function popPreStatus( ... )
	MainScene.setMainSceneViewsVisible(_bPreMenuVisible, _bPreAvatarVisible, _bPreBulletinVisible)
end

--[[
	desc: 创建UI，并注册相关回调
	param:
	return:
--]]
function registerMainHandler( ... )

	NFashionInfoLayer._fnOnEnter = function ( ... )
		onMainEnter()
	end

	NFashionInfoLayer._fnOnExit = function ( ... )
		onMainExit()
	end

	NFashionInfoLayer._fnTapClose = function ( pTag, pSender )
		tapClose(pTag, pSender)
	end

	--更换
	NFashionInfoLayer._fnTapChange = function ( pTag, pSender )
		tapChange(pTag, pSender)
	end

	--卸下
	NFashionInfoLayer._fnTapUnequip = function ( pTag, pSender )
		tapUnequip(pTag, pSender)
	end

	--强化
	NFashionInfoLayer._fnTapStrengthen = function ( pTag, pSender )
		tapStrengthen(pTag, pSender)
	end

end

--[[
	desc:注册从信息界面进入强化界面后，关闭强化界面时的回调函数
	param:
	return:
--]]
function registerStrengthenCloseHandler( pFnStrengthenClose )
	_fnStrengthenClose = pFnStrengthenClose
end

-------------------------回调-----------------------------
--[[
	desc:打开界面调用 
	param:
	return:
--]]
function onMainEnter( ... )
	NFashionInfoLayer.refreshAll()
end

--[[
	desc:关闭界面时调用 
	param:
	return:
--]]
function onMainExit( ... )
	deinit()

end

--[[
	desc: 点击关闭按钮
	param:
	return:
--]]
function tapClose( pTag, pSender )
	NFashionInfoLayer.close()
end

--[[
	desc: 点击换装
	param:
	return:
--]]
function tapChange( pTag, pSender )
	require "script/ui/fashion/ChangeFashion"
	NFashionInfoLayer.close()  --关闭界面
	local changeLayer = ChangeFashion.create()
	MainScene.changeLayer(changeLayer, "changeLayer")
end

--[[
	desc: 点击卸下
	param:
	return:
--]]
function tapUnequip( pTag, pSender )
	FashionNet.offFashion(function ( ... )
		local heroHtid = HeroModel.getNecessaryHero().equip.dress["1"].item_template_id 
		local item_id = HeroModel.getNecessaryHero().equip.dress["1"].item_id 
		local itemData = HeroModel.getNecessaryHero().equip.dress["1"]

		HeroModel.getNecessaryHero().equip.dress["1"] = "0"

		-- 刷新时装属性缓存
		require "script/model/affix/DressAffixModel"
		DressAffixModel.getAffixByHid(HeroModel.getNecessaryHero().hid, true)
		DressAffixModel.getUnLockAffix(true)
	    NFashionInfoLayer.close()  --关闭界面
		require "script/ui/fashion/FashionLayer"
		local mark = FashionLayer.getMark()
		local fashionLayer = FashionLayer:createFashion()
		MainScene.changeLayer(fashionLayer, "FashionLayer")		
			FashionLayer.setMark(mark)

		FashionLayer.addPro(heroHtid, true, item_id, itemData )
	end, tag)
end

--[[
	desc: 点击强化
	param:
	return:
--]]
function tapStrengthen( pTag, pSender )
	local tbFashion = NFashionInfoData.getFashionInfo()
	if table.isEmpty(tbFashion) then
		return
	end

	-- 强化
	local isNeed = false
	if(_bPreAvatarVisible)then
		isNeed = true
	else
		isNeed = false
	end
	require "script/ui/fashion/FashionEnhanceLayer"
	-- local enforceLayer = FashionEnhanceLayer.createLayer(_item_id, _enhanceDelegate, isNeed)
	local enforceLayer = FashionEnhanceLayer.createLayer(tbFashion.item_id, _fnStrengthenClose, isNeed)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(enforceLayer, 10)
	-- 关闭
	NFashionInfoLayer.close()
end