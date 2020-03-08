function WaiYiTry:OnClaim(nTemplateId)
	Ui:CloseWindow("WaiYiTryPanel")
    Guide:StartGuideById(self.Def.nGuideOpenBag, false, false, true)
end

function WaiYiTry:CanShowHomeScreenBtn()
	return GetTimeFrameState(self.Def.szMaxTimeframe) ~= 1 and me.nLevel >= self.Def.nMinLevel and me.nLevel <= self.Def.nMaxLevel
end

function WaiYiTry:OnUseWaiYi()
	if Guide:IsFinishGuide(WaiYiTry.Def.nGuideOpenBag) ~= 0 then
		Guide:StartGuideById(WaiYiTry.Def.nGuideOpenWaiYi, false, false, true)
	end
end