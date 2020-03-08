local tbItem = Item:GetClass("ImperialTombTicket");

function tbItem:GetUseSetting()
	return {};
end

function tbItem:GetIntrol()
	Log(GetTimeFrameState(ImperialTomb.FEMALE_EMPEROR_TIME_FRAME))
	if GetTimeFrameState(ImperialTomb.FEMALE_EMPEROR_TIME_FRAME) ~= 1 then
		return "通体剔透的明珠，溢彩流光，不仅可在黑暗中散发出光华，更有避毒之功用。\n\n[FFFE0D]周四、周日21：55-22：30[-]始皇降世之时，须凭此物方可参与"
	else
		return "通体剔透的明珠，溢彩流光，不仅可在黑暗中散发出光华，更有避毒之功用。\n\n[FFFE0D]周四21：55-22：30[-]始皇降世，[FFFE0D]周日21：55-22：30[-]女帝复苏，须凭此物方可参与"
	end
end