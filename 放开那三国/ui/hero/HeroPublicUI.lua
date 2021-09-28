-- Filename: HeroPublicUI.lua
-- Author: fang
-- Date: 2013-10-31
-- Purpose: 该文件用于: 武将系统公用UI

module("HeroPublicUI", package.seeall)

-- 武将初始值上限 100

-- 武将扩充
function showHeroExpandUI(tParam)
	require "script/ui/bag/BagUtil"
	require "script/ui/bag/BagEnlargeDialog"
	local callback = nil
	if(tParam and tParam.cb_expand)then
		callback = tParam.cb_expand
	end
	BagEnlargeDialog.showLayer(BagUtil.HERO_TYPE, callback)
end

-- 武将携带数量已达上限提示，如果武将数量未达上限则不弹出提示.
-- return: true表示已达上限, false表示未达上限，可继续操作.
function showHeroIsLimitedUI(tParam)
	require "script/model/hero/HeroModel"
	if not HeroModel.isLimitedCount() then
		return false
	end
	--关闭新手引导
	if NewGuide.guideClass ~= ksGuideClose then
		require "script/guide/NewGuide"
		require "script/guide/AstrologyGuide"
        AstrologyGuide.cleanLayer()
        NewGuide.guideClass = ksGuideClose
        BTUtil:setGuideState(false)
        NewGuide.saveGuideClass()
    end
	local tArgs = {}
	tArgs.text = GetLocalizeStringBy("key_1962")
	tArgs.items = {}
	tArgs.items[1] = {text=GetLocalizeStringBy("key_1158"), tag=1001, pos_x=20, pos_y=30}
	tArgs.items[2] = {text=GetLocalizeStringBy("key_1401"), tag=1002, pos_x=200, pos_y=30}
	tArgs.items[3] = {text=GetLocalizeStringBy("key_1269"), tag=1003, pos_x=370, pos_y=30}
	tArgs.callback = function (pTag)
		if pTag == 1002 then
			require "script/ui/hero/HeroSellLayer"
			require "script/ui/main/MainScene"
			MainScene.changeLayer(HeroSellLayer.createLayer(), "HeroSellLayer")
		elseif pTag == 1001 then
			showHeroExpandUI(tParam)
		elseif pTag == 1003 then
			require "script/ui/hero/HeroLayer"
			MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
		end
	end
	AlertTip.showNoramlDialog(tArgs)

	return true
end






