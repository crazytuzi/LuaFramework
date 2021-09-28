local sfreshofflinehookstate = require "protocoldef.knight.gsp.buff.sfreshofflinehookstate"
function sfreshofflinehookstate:process()
	LogInfo("sfreshofflinehookstate process")
	require "ui.offlineexp.offlineexp"
	OfflineExp.getInstanceAndShow():Init(self.fivebeitimeused, self.danbeitimeused, self.perminexps, self.perminexpm, self.fivebeitimeremain, self.flag)	
end

local sfreshofflineresult = require "protocoldef.knight.gsp.buff.sfreshofflineresult"
function sfreshofflineresult:process()
	LogInfo("sfreshofflineresult process")
	require "ui.offlineexp.offlineexpconfirm"
	OfflineExpConfirm.getInstanceAndShow():Init(self.totalexp, self.itemnum, self.moneyneed)
end

local stakeexpsucc = require "protocoldef.knight.gsp.buff.stakeexpsucc"
function stakeexpsucc:process()
	LogInfo("stakeexpsucc process")
	require "ui.offlineexp.offlineexp"
	require "ui.offlineexp.offlineexpconfirm"
	OfflineExp.DestroyDialog()
	OfflineExpConfirm.DestroyDialog()
end

