local tbUi = Ui:CreateClass("TeacherRewardPanel")
tbUi.tbOnClick = 
{
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	BtnShop = function(self)
		Ui:OpenWindow("CommonShop", "Renown")
	end,
}

function tbUi:OnOpen()
	local tbItems = {}
	tbItems[1] = TeacherStudent.Def.tbGraduateStudentRewards[1].tbAttach[1]
	tbItems[2] = TeacherStudent.Def.tbGraduateTeacherRewards[1].tbAttach[1]
	tbItems[3] = TeacherStudent.Def.tbGraduateStudentRewards[2].tbAttach[1]
	tbItems[4] = TeacherStudent.Def.tbGraduateTeacherRewards[2].tbAttach[1]

	for i, tb in ipairs(tbItems) do
		local pItemFrame = self[string.format("Itemframe%d", i)]
		pItemFrame:SetGenericItem(tb)
		pItemFrame.fnClick = pItemFrame.DefaultClick
	end
end