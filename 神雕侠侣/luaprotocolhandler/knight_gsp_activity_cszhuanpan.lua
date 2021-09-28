-- 界面通知有该按钮
local SCsNotifyDisplay = require "protocoldef.knight.gsp.activity.cszhuanpan.scsnotifydisplay"
function SCsNotifyDisplay:process()
	local LotteryConsumeBtn = require 'ui.lotteryconsume.lotteryconsumebtn'
	if GetScene():IsInFuben() or GetBattleManager():IsInBattle() then
		LotteryConsumeBtn.getInstance():SetVisible(false)
	else
		LotteryConsumeBtn.getInstanceAndShow()
	end
end

-- 通知流光
local SCsNotiyLiuGuang = require "protocoldef.knight.gsp.activity.cszhuanpan.scsnotiyliuguang"
function SCsNotiyLiuGuang:process()
	local LotteryConsumeBtn = require 'ui.lotteryconsume.lotteryconsumebtn'
	local inst = LotteryConsumeBtn.getInstanceNotCreate()
	if inst then
		inst:addEffect()
	end
end

-- 大转盘信息
local SCsZhuanpanInfo = require "protocoldef.knight.gsp.activity.cszhuanpan.scszhuanpaninfo"
function SCsZhuanpanInfo:process()
	local LotteryConsumeDlg = require 'ui.lotteryconsume.lotteryconsumedlg'
	LotteryConsumeDlg.getInstanceAndShow():info(self.ztype, self.awardid, self.zhuanpinfo)
end

-- 通知奖品
local SCsNotifyAward = require "protocoldef.knight.gsp.activity.cszhuanpan.scsnotifyaward"
function SCsNotifyAward:process()
	local LotteryConsumeDlg = require 'ui.lotteryconsume.lotteryconsumedlg'
	local inst = LotteryConsumeDlg.getInstanceNotCreate()
	if inst then
		inst:stop(self.ztype, self.awardid, self.zhuanpinfo)
	end
end

-- 领取奖品
local SCsFetchAward = require "protocoldef.knight.gsp.activity.cszhuanpan.scsfetchaward"
function SCsFetchAward:process()
	local LotteryConsumeDlg = require 'ui.lotteryconsume.lotteryconsumedlg'
	local inst = LotteryConsumeDlg.getInstanceNotCreate()
	if inst then
		inst:award(self.flag, self.status, self.zhuanpinfo)
	end
end