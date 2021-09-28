local p = require "protocoldef.knight.gsp.lock.slockinfo"
function p:process()
	print("slockinfo process".."    " .. self.status)
	require "ui.settingmainframe"
	SettingMainFrame.getInstance():CheckLockHandler(self.status)
	SecurityLockSettingDlg.SetLockStatus(self.status)
end

local p = require "protocoldef.knight.gsp.lock.sneedunlock"
function p:process()
	print("sneedunlock process")
	require "ui.safeunlockdlg"
	SafeUnlockDlg.getInstanceAndShow()
end
local p = require "protocoldef.knight.gsp.lock.saddlocksuc"
function p:process()
	print("saddlocksuc process")
	require "ui.safelocksetdlg"
	SafeLockSetDlg.setSuccess()
end
local p = require "protocoldef.knight.gsp.lock.sunlocksuc"
function p:process()
	print("SUnlockSuc process")
	require "ui.safeunlockdlg"
	SafeUnlockDlg.setSuccess()
end
local p = require "protocoldef.knight.gsp.lock.scancellocksuc"
function p:process()
	print("SCancelLockSuc process")
	require "ui.safelockcancelalldlg"
	SafeLockCancelAllDlg.setSuccess()
end
local p = require "protocoldef.knight.gsp.lock.sunlocksuc"
function p:process()
	print("SUnlockSuc process")
	require "ui.safeunlockdlg"
	SafeUnlockDlg.setSuccess()
end
local p = require "protocoldef.knight.gsp.lock.sforceunlocksuc"
function p:process()
	print("SForceUnlockSuc process")
--	SafeUnlockDlg.setSuccess()
end
local p = require "protocoldef.knight.gsp.lock.schangepasswordsuc"
function p:process()
	print("SChangePasswordSuc process")
	require "ui.safelockchangedlg"
	SafeLockChangeDlg.setSuccess()
end
local p = require "protocoldef.knight.gsp.lock.supdatelockinfo"
function p:process()
	require "ui.securitylocksettingdlg"
	SecurityLockSettingDlg.SetLockStatus(self.status)
end


