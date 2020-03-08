if not MODULE_GAMESERVER then
    Activity.MonsterNianAct = Activity.MonsterNianAct or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("MonsterNianAct") or Activity.MonsterNianAct

function tbAct:LoadSetting()
	self.tbQuestions = Lib:LoadTabFile("Setting/Activity/LanternQuestions.tab", {nId=1, nUpper=1, nAnswerId=1})
end
tbAct:LoadSetting()

function tbAct:IsAnswerRight(nId, nAnswerId)
	local tbQuestion = self:GetQuestion(nId)
	if not tbQuestion then
		Log("[x] MonsterNianActC:IsAnswerRight", nId, nAnswerId)
		return false
	end
	return tbQuestion.nAnswerId==nAnswerId
end

function tbAct:GetQuestion(nId)
	return self.tbQuestions[nId]
end

if MODULE_GAMECLIENT then
	function tbAct:UpdateRankData()
		local tbData = self:GetRankData()
		RemoteServer.MonsterNianReq("UpdateRankData", tbData.nVersion)
	end

	function tbAct:GetRankData()
		return self.tbRankData or {nVersion=0}
	end

	function tbAct:OnUpdateRankData(tbData)
		self.tbRankData = tbData
		table.sort(self.tbRankData, function(tbA, tbB)
			return tbA[3]>tbB[3] or (tbA[3]==tbB[3] and tbA[1]<tbB[1])
		end)
		UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_MN_RANK)
	end
end