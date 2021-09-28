-- Filename: HeroDestineyCopyCtrl.lua
-- Author: zhangqiang
-- Date: 2016-05-16
-- Purpose: 批量使用(激活)称号界面

module("HeroDestineyCopyCtrl", package.seeall)
require "script/ui/copy/heroDestineyCopy/HeroDestineyBuyLayer"
require "script/ui/copy/heroDestineyCopy/HeroDestineyCopyData"

--显示购买攻打次数界面
function showAttckBuyLayer( ... )

	--剩余的最大购买次数
	local nMaxLeftBuyNum = HeroDestineyCopyData.getMaxLeftBuyNumPerDay()

	HeroDestineyBuyLayer.showDialog(tapBuyComfirm, nil, nMaxLeftBuyNum, HeroDestineyCopyData.getTotalCostByNum)
end



--处理事件
function dispatchEvent( pEventName, pData )
	-- --若界面已不存在，则不处理
	-- if tolua.isnull(_bgLayer) then
	-- 	return
	-- end
	
	if pEventName == HeroDestineyCopyData.kBuyDestinyAtkNumSuccess then
		CopyLayer.refreshACopyView()   --刷新副本列表中 英雄天命副本cell上的剩余攻打次数
	else

	end
end

---------------------------------------------------------------------
--批量购买界面，点击确定(将要购买的次数， 剩余的最大购买次数)
function tapBuyComfirm( pWillBuyNum, pMaxBuyNum )
	local nWillBuyNum = tonumber(pWillBuyNum or 0)
	if nWillBuyNum <= 0 then
		return
	end
	
	HeroDestineyCopyData.sendBuyDestinyAtkNum(nWillBuyNum)
end