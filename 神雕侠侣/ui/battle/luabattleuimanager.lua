
LuaBattleUIManager = {}

function LuaBattleUIManager.CreateBattleUI()
	local TotalDamageDlg = require "ui.battle.totaldamagedlg"
	local RoundCountDlg = require "ui.battle.roundcountdlg"
	local BattlePerCountDownDlg = require "ui.battle.battlepercountdowndlg"
	local UserMiniIconDlg = require "ui.battle.userminiicondlg"
	TotalDamageDlg.getInstance()
	RoundCountDlg.getInstance()
	BattlePerCountDownDlg.getInstance()
	UserMiniIconDlg:getInstance()
end

function LuaBattleUIManager.DestoryBattleUI()
	local TotalDamageDlg = require "ui.battle.totaldamagedlg"
	local RoundCountDlg = require "ui.battle.roundcountdlg"
	local BattlePerCountDownDlg = require "ui.battle.battlepercountdowndlg"
	local UserMiniIconDlg = require "ui.battle.userminiicondlg"
	TotalDamageDlg.DestroyDialog()
	RoundCountDlg.DestroyDialog()
	BattlePerCountDownDlg.DestroyDialog()
	if UserMiniIconDlg:getInstanceOrNot() then
		UserMiniIconDlg:getInstanceOrNot():DestroyDialog()
	end
end

function LuaBattleUIManager.Tick(delta)
	local TotalDamageDlg = require "ui.battle.totaldamagedlg"
	local RoundCountDlg = require "ui.battle.roundcountdlg"
	local BattlePerCountDownDlg = require "ui.battle.battlepercountdowndlg"
	local UserMiniIconDlg = require "ui.battle.userminiicondlg"
	if TotalDamageDlg.getInstanceNotCreate() then
		TotalDamageDlg.getInstanceNotCreate():run(delta)
	end
	if RoundCountDlg.getInstanceNotCreate() then
		RoundCountDlg.getInstanceNotCreate():run(delta)
	end
	if BattlePerCountDownDlg.getInstanceNotCreate() then
		BattlePerCountDownDlg.getInstanceNotCreate():run(delta)
	end
	if UserMiniIconDlg:getInstanceOrNot() then
		UserMiniIconDlg:getInstanceOrNot():run(delta)
	end
end

function LuaBattleUIManager.SetTotalDamage(damage)
	local TotalDamageDlg = require "ui.battle.totaldamagedlg"
	if TotalDamageDlg.getInstanceNotCreate() then
		TotalDamageDlg.getInstanceNotCreate():setDamage(damage)
	end
end

function LuaBattleUIManager.ChangeBattleRound(roundcount)
	local RoundCountDlg = require "ui.battle.roundcountdlg"
	if RoundCountDlg.getInstanceNotCreate() then
		RoundCountDlg.getInstanceNotCreate():changeRoundCount(roundcount)
	end
end

function LuaBattleUIManager.SetOperateTime(time)
	local BattlePerCountDownDlg = require "ui.battle.battlepercountdowndlg"
	if BattlePerCountDownDlg.getInstanceNotCreate() then
		BattlePerCountDownDlg.getInstanceNotCreate():setCount(time)
	end
end

return LuaBattleUIManager
