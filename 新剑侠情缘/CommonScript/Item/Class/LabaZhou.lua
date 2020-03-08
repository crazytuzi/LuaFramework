local tbItem = Item:GetClass("LabaZhou");
tbItem.nAssistId = 1
-- 266
function tbItem:GetUseSetting(nItemTemplateId, nItemId)
	local function fnGo()
		Ui.HyperTextHandle:Handle("[url=npc:刘云, 91, 15]", 0, 0)
		Ui:CloseWindow("ItemTips")
		Ui:CloseWindow("ItemBox")
	end
	return {szFirstName = "使用", fnFirst = fnGo};
end
function tbItem:GetTip(it)
	return "热气腾腾刚出炉的一大锅[FFFE0D]腊八粥[-]，前线的将士终于能感受到冬日的温暖了";
end

function tbItem:GetIntrol(nTemplateId, nItemId)
	 local it 
	 if nItemId then
	 	it = KItem.GetItemObj(nItemId)
	 end
	 local szTips  ="";

	if not it then
		szTips = "用[FFFE0D]薏米仁[-]、[FFFE0D]桂圆[-]、[FFFE0D]莲子[-]、[FFFE0D]葡萄干[-]、[FFFE0D]栗子[-]、[FFFE0D]红枣[-]、[FFFE0D]粳米[-]、[FFFE0D]核桃仁[-]做成，香气扑鼻，沁人心脾";
	else
		local szAssistPlayerName = it.GetStrValue(self.nAssistId);
		if not Lib:IsEmptyStr(szAssistPlayerName) then
			szTips = string.format("这份腊八粥由你的好友%s协助完成。\n", szAssistPlayerName)
		end
		szTips = szTips .. "送往战场前线可获得奖励"
		
	end

	return szTips;
end