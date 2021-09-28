local p = require "protocoldef.knight.gsp.activity.dazhuanpan.snotifydisplay"
function p:process()
	LogInfo("snotifydispaly end")

	local LuckyWheelEntrance = require "ui.luckywheel.luckywheelentrance"

	if GetScene():IsInFuben() or GetBattleManager():IsInBattle() then
		LuckyWheelEntrance.getInstance():SetVisible(false)
	else
    	LuckyWheelEntrance.getInstanceAndShow()
	end

	LogInfo("snotifydispaly end")
end

local p = require "protocoldef.knight.gsp.activity.dazhuanpan.snotiyliuguang"
function p:process()
	LogInfo("set effect")
	local LuckyWheelEntrance = require "ui.luckywheel.luckywheelentrance"

	if LuckyWheelEntrance.getInstanceNotCreate() then
		LuckyWheelEntrance.getInstance():setEffect()
	end
end

local p = require "protocoldef.knight.gsp.activity.dazhuanpan.szhuanpaninfo"
function p:process()
	LogInfo("szhuanpaninfo process")
	local index = self.index
	local ztype = self.ztype
	local info = self.zhuanpinfo
	LogInfo("szhuanpaninfo: ",ztype, " ",index)
	LogInfo(info.bltyileftnums," ",info.bltyless," ",info.qznfleftnums," ",info.qznfless)

	local LuckyWheelDlg = require "ui.luckywheel.luckywheeldlg"

	if index >= 0 then
		LogInfo("has untaken award: ", self.ztype, " ", self.index, " ",info.delaytime) -- need to konw which pannel: ztype
		LuckyWheelDlg.getInstanceAndShow():HandleUntakenPrize(ztype,index,info)
	else
		LogInfo(" show dlg")
		LuckyWheelDlg.getInstanceAndShow():SetPannelData(1,0,info)
	end

	LogInfo("szhuanpaninfo end")
end

local p = require "protocoldef.knight.gsp.activity.dazhuanpan.snotifyaward"
function p:process()

	LogInfo("snotifyaward process begin: ",self.ztype," ",self.index)

	local LuckyWheelDlg = require "ui.luckywheel.luckywheeldlg"

	local dlg = LuckyWheelDlg.getInstanceNotCreate()

	if dlg and dlg:IsVisible() then	
		local zpinfo = self.zhuanpinfo
		dlg:SetPrizeIndex(self.ztype, self.index, zpinfo)
	end

	LogInfo("snotifyaward process end")

end

local p = require "protocoldef.knight.gsp.activity.dazhuanpan.sfetchaward"
function p:process()

	local LuckyWheelDlg = require "ui.luckywheel.luckywheeldlg"

	local dlg = LuckyWheelDlg.getInstanceNotCreate()

	if dlg and dlg:IsVisible() then	
		local zpinfo = self.zhuanpinfo
		dlg:setFetchResult(self.flag,self.status)
	end
end
