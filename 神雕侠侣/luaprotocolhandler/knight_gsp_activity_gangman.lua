local SGandManInfo = require "protocoldef.knight.gsp.activity.gangman.sgandmaninfo"
function SGandManInfo:process()
	local LotteryFightDlg = require 'ui.lotteryfight.lotteryfightdlg'
	LotteryFightDlg.getInstanceAndShow():info(self.records, self.canrandom)
end

local SRandomGangMan = require "protocoldef.knight.gsp.activity.gangman.srandomgangman"
function SRandomGangMan:process()
	local LotteryFightDlg = require 'ui.lotteryfight.lotteryfightdlg'
	LotteryFightDlg.getInstanceAndShow():rand(self.id)
end