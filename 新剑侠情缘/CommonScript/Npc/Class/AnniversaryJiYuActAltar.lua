local tbNpc = Npc:GetClass("AnniversaryJiYuActAltar")

function tbNpc:OnDialog()
	local OptList = {
		{Text = "提交材料", Callback = self.SubmitMaterial, Param = {self}},
		{Text = "获取美酒", Callback = self.GetDrink, Param = {self}},
		{Text = "我再看看"},
	};
	local tbDialogInfo = {Text = "别忘了来参加今晚19:00-19:15期间举办的周年酒宴！", OptList = OptList}
	Dialog:Show(tbDialogInfo, me, him)
end

function tbNpc:SubmitMaterial()
	Activity:OnPlayerEvent(me, "Act_SubmitMaterial")
end

function tbNpc:GetDrink()
	Activity:OnPlayerEvent(me, "Act_GetDrink")
end