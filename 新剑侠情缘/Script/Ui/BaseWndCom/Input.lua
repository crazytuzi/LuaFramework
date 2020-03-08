
local tbUi = Ui:CreateClass("Input");

function tbUi:GetText()
	return self.pPanel:Input_GetText("Main");
end

function tbUi:SetText(szText)
	self.pPanel:Input_SetText("Main", szText);
end

function tbUi:SetEnabled(bEnabled)
	-- body
end

function tbUi:SetCharLimit(nLimit)
	self.pPanel:Input_SetCharLimit("Main", nLimit);
end

