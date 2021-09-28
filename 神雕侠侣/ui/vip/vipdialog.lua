require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"
require "protocoldef.knight.gsp.battle.cbuyvipproduct"
require "ui.vip.vipdialog_default"
require "ui.vip.vipdialog_ydjd"

VipDialog = {}
setmetatable(VipDialog, Dialog)
VipDialog.__index = VipDialog

function VipDialog.getInstanceAndShow()
	LogInfo("enter vipdialog.getInstanceAndShow")

	--for ydjd vipdialog
	if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "ydjd" then
		return VipDialogYdjd.getInstanceAndShow()
	end
	
	--for default vipdialog
	return VipDialogDefault.getInstanceAndShow()
end