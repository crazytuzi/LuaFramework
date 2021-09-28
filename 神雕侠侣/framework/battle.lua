Battle = {}
function Battle.EnterBattle()
	print("enter battle");
	BattleZhenFa.getInstance();
end

function Battle.EndBattle()
	print("end battle");
	BattleZhenFa.DestroyDialog();
	ZhenFaTip.DestroyDialog();
end

