
local tbTestItem = Item:GetClass("test");

function tbTestItem:OnUse()
	print("UseItem xxxxxxxxxxxxxxxxxxxxxxxxxx")
	return 1;
end

function tbTestItem:OnUseAll()
	print("UseItemAll xxxxxxxxxxxxxxxxxxxxxxxxxx")
	return 3;
end

