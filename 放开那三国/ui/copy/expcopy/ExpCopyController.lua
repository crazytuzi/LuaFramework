-- Filename: ExpCopyController.lua
-- Author: lichenyang
-- Date: 2015-03-31
-- Purpose: 主角经验副本控制层

module("ExpCopyController", package.seeall)
require "script/model/DataCache"
require "script/ui/copy/expcopy/ExpCopyService"
require "script/ui/copy/expcopy/ExpCopyData"
require "script/ui/copy/expcopy/ExpCopyAfterBattleLayer"
function doBattleCallback(p_copyInfo)
	
	--判断是否可以攻打
	if p_copyInfo.isOpen == false then
		return
	end
	--判断剩余攻打次数
	if ExpCopyData.getCanDefeatNum() <= 0 then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_1817"))
		return
	end
	
	ExpCopyService.doBattle("300005",p_copyInfo.id,p_copyInfo.amyid,function ( p_fightInfo )
		--攻打完成刷新攻打次数
		if p_fightInfo.appraisal ~= "E" and p_fightInfo.appraisal ~= "F" then
	        ExpCopyData.setCanDefeatNum(ExpCopyData.getCanDefeatNum() - 1)
	    end
	    --修改baseId
	    ExpCopyData.setOpenFrontId(p_fightInfo.base_id)

		--刷新副本列表
		CopyLayer.refreshMyTableView()
		local fightStr = p_fightInfo.fightRet
		printTable("p_fightInfo",p_fightInfo)

		--刷新活动副本气泡副本次数
		CopyLayer.refreshCopyTip()
		

		-- 调用结算面板
        local reportLayer = ExpCopyAfterBattleLayer.createLayer(p_fightInfo.reward.item, p_fightInfo.appraisal)
		require "script/battle/BattleLayer"
		BattleLayer.showBattleWithString(fightStr, nil,reportLayer, "ducheng.jpg",nil,nil,nil,nil,nil)
	end)
end

function buyExpUserAtkNum( p_num )
	
	--检查是否有足够的金币
	ExpCopyService.buyExpUserAtkNum(p_num, function ( ... )
		--购买完成增加次数
		ExpCopyData.setCanDefeatNum(ExpCopyData.getCanDefeatNum() + 1)
	end)
end