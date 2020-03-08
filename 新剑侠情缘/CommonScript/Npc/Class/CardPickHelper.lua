local tbNpc = Npc:GetClass("CardPickHelper");

function tbNpc:OnDialog()
	local szText = "桃花桃花桃花，总是好运相伴~";
	local tbOptList = {};

	if version_tx then
		table.insert(tbOptList, { Text = "随机概率公示", Callback = function () self:OpenCardPickProbInfo(); end});
		table.insert(tbOptList, { Text = "查看招募记录", Callback = function () self:ShowCardPickHistory(); end});
	end

	Dialog:Show(
	{
		Text	= szText,
		OptList = tbOptList,
	}, me, him);
end

function tbNpc:OpenCardPickProbInfo()
	me.CallClientScript("Ui:OpenWindow", "CardPickRecordPanel", "Prob");
end

function tbNpc:ShowCardPickHistory()
	me.CallClientScript("Ui:OpenWindow", "CardPickRecordPanel", "History");
end