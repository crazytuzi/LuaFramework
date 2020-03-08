--[[
--同一时间只能有一种重逢关系，要么是回流玩家，要么向导，要么当前没有重逢好友。不能同时是向导有时回流玩家
nMyType          = 0,
tbRelation       = {
	[nPlayerId]  = {
		nRelationTime   = 0,
		nChuanGongTimes = 0,
		nChuanGongDay   = 0,
		tbComplete      = {
			[ActId] = {[Reunion.COMPLETE_IDX_COUNT] = nCompleteTimes, [Reunion.COMPLETE_IDX_FLAG] = bReported},
			[ActId] = {[Reunion.COMPLETE_IDX_COUNT] = nCompleteTimes, [Reunion.COMPLETE_IDX_FLAG] = bReported},
			[ActId] = {[Reunion.COMPLETE_IDX_COUNT] = nCompleteTimes, [Reunion.COMPLETE_IDX_FLAG] = bReported},
		},
	},
}
]]

Reunion.RELATION_COUNT     = 2
Reunion.CHUANGONG_EXP_BASE = 30
Reunion.RELATION_TIME      = 30*24*3600
Reunion.DAY_ZERO           = 4*3600
Reunion.CHUANGONG_TIMES    = 1
Reunion.ALLCOMPLETE_AWARD  = {{"item", 10614,1}}
Reunion.IMITY_LEVEL        = 15
Reunion.VIP_LEVEL          = 5
Reunion.GUIDER_VIP_LEVEL   = 6
Reunion.PLAYERLEVEL        = 1 --向导与召回最小等级差

Reunion.TYPE_GUIDE         = 1
Reunion.TYPE_BACK          = 2
Reunion.COMPLETE_IDX_COUNT = 1
Reunion.COMPLETE_IDX_FLAG  = 2

function Reunion:LoadSetting()
	self.TARGET_ACT = {}
	local tbFile = Lib:LoadTabFile("Setting/Reunion/Targets.tab", {nActId = 1, nCompleteCount = 1, nBackerExp = 1, nGuiderRenown = 1})
	for _, tbInfo in ipairs(tbFile) do
		if not Lib:IsEmptyStr(tbInfo.szGuiderExtAward) then
			local tbAward = Lib:GetAwardFromString(tbInfo.szGuiderExtAward)
			if MODULE_GAMESERVER then
				tbInfo.tbGuiderExtAward = tbAward
			end
		end
		self.TARGET_ACT[tbInfo.szAct] = tbInfo
	end
	Reunion.TARGET_COUNT = #tbFile
end
Reunion:LoadSetting()

function Reunion:GetTargetInfo(nActId)
	if not self.tbActId2Key then
		self.tbActId2Key = {}
		for szKey, tbInfo in pairs(self.TARGET_ACT) do
			self.tbActId2Key[tbInfo.nActId] = szKey
		end
	end
	local szKey = self.tbActId2Key[nActId]
	return self.TARGET_ACT[szKey]
end

Reunion.tbCheckTF = {
	["ImperialTomb"] = function (nRelationTime)
		return nRelationTime >= TimeFrame:CalcTimeFrameOpenTime(ImperialTomb.OPEN_TIME_FRAME)
	end;
}
function Reunion:CheckTimeFrame(szAct, nRelationTime)
	if not self.tbCheckTF[szAct] then
		return true
	end
	return self.tbCheckTF[szAct](nRelationTime)
end