-- Filename: WorldCarnivalController.lua
-- Author: bzx
-- Date: 2014-08-27
-- Purpose: 跨服嘉年华控制层

module("WorldCarnivalController", package.seeall)

btimport "script/ui/world_carnival/WorldCarnivalService"
btimport "script/ui/world_carnival/WorldCarnivalBattleReportLayer"

-- 返回
function backCallback( ... )
	WorldCarnivalLayer.close()
	local main_base_layer = MainBaseLayer.create()
	MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
    MainScene.setMainSceneViewsVisible(true,true,true)
end

-- 更新战斗信息
function updateFormationInfoCallback( ... )
	if not WorldCarnivalData.isFighter() then
		AnimationTip.showTip(GetLocalizeStringBy("key_10327"))
		return
	end
	local rpcCallback = function ( ... )
		WorldCarnivalLayer.showUpdateTip()
	end
	WorldCarnivalService.updateFmt(rpcCallback)
end

-- 布阵的回调函数
function formationCallback( ... )
	if(DataCache.getSwitchNodeState(ksSwitchWarcraft, false) == true)then
		require "script/ui/warcraft/WarcraftLayer"
		WarcraftLayer.show(-600)
	else
		require "script/ui/formation/MakeUpFormationLayer"
		MakeUpFormationLayer.showLayer()
	end
end

-- 查看战报
function checkBattleReportCallback( p_tag, p_menuItem )
	local rpcCallback = function ()
		local reportInfo = WorldCarnivalData.getReportInfo()
		WorldCarnivalBattleReportLayer.show(reportInfo)
	end
	local round = p_tag
	WorldCarnivalService.getRecord(rpcCallback, round)
end