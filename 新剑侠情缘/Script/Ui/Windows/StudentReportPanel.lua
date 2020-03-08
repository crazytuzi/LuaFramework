local tbUI = Ui:CreateClass("StudentReportPanel")

tbUI.tbOnClick = 
{
    BtnBack = function(self)
        Ui:CloseWindow(self.UI_NAME)
    end,

    Btn = function(self)
		TeacherStudent:ConfirmTargetReportReq(self.nStudentId)
		Ui:CloseWindow(self.UI_NAME)
    end,
}

function tbUI:OnOpen(nStudentId, szName, tbTargets)
	self.nStudentId = nStudentId

	self.pPanel:Label_SetText("PlayerName2", string.format("徒弟%s的师徒目标汇报", szName))

	self.TxtScrollView:Update(#tbTargets, function(pGrid, nIdx)
		local nTargetId = tbTargets[nIdx]
		local szTargetDesc = self:GetTargetDesc(nTargetId)
		pGrid.pPanel:Label_SetText("Main", szTargetDesc)
	end)
end

function tbUI:GetTargetDesc(nTargetId)
	local tbSetting = TeacherStudent:GetTargetSetting(nTargetId)
	return string.format("已达成[FFFE0D]%s[-]，你将获得[FFFE0D]%d名望[-]", tbSetting.szDesc, tbSetting.nTeacherRenown)
end
