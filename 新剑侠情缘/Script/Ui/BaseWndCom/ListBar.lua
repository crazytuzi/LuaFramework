
local tbUi = Ui:CreateClass("ListBar");

function tbUi:OnCreate()
	print("on create listbar!")
end

function tbUi:InitBar(tbInfo)
	local name, level = tbInfo[1], tbInfo[2];
	tbUi.Name:SetText("abc");
	tbUi.Level:SetText("zzhero");
end
