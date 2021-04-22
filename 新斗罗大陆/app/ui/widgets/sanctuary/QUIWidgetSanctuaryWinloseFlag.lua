--
-- zxs
-- 精英赛胜负标记
--

local QUIWidget = import("..QUIWidget")
local QUIWidgetSanctuaryWinloseFlag = class("QUIWidgetSanctuaryWinloseFlag", QUIWidget)

function QUIWidgetSanctuaryWinloseFlag:ctor(options)
	local ccbFile = "ccb/Widget_Sanctuary_winlose.ccbi"
	local callBacks = {
	}
	QUIWidgetSanctuaryWinloseFlag.super.ctor(self,ccbFile,callBacks,options)
end

--刷新数据
function QUIWidgetSanctuaryWinloseFlag:setIndex(index)
	self._index = index
	self._ccbOwner.tf_num:setString("第"..index.."局")
end

function QUIWidgetSanctuaryWinloseFlag:setIsWin(isWin)
	self._ccbOwner.sp_win_flag:setVisible(isWin)
	self._ccbOwner.sp_lose_flag:setVisible(not isWin)
end

return QUIWidgetSanctuaryWinloseFlag