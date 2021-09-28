local p = require "protocoldef.knight.gsp.activity.chongzhifanli.srechargehisinfo"
function p:process()
	LogInfo("srechargehisinfo process")
	
	local ChargeFeedback = require "ui.chargefeedback.chargefeedbackdlg"	
	ChargeFeedback.getInstance():Initial(self.totallogin,self.backrate,self.nextrate,self.hasnext, self.flag)
	
	if GetScene():IsInFuben() or GetBattleManager():IsInBattle() then
		ChargeFeedback.getInstance():SetVisible(false)
	else
    	ChargeFeedback.getInstanceAndShow()
	end
	LogInfo("snotifydispaly end")
end

local p = require "protocoldef.knight.gsp.activity.chongzhifanli.sgetrechargeresult"
function p:process()
	LogInfo("sgetrechargeresult process")	
	local ChargeFeedback = require "ui.chargefeedback.chargefeedbackdlg"
	ChargeFeedback.DestroyDialog()		
	LogInfo("sgetrechargeresult end")
end

