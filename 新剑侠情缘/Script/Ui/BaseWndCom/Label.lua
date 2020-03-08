
local tbUi = Ui:CreateClass("Label");

function tbUi:SetText(szText)
	szText = Ui.HyperTextHandle:AttachText(szText);
	self.pPanel:Label_SetText("Main", szText);
end

function tbUi:SetColor(nR, nG, nB)
	self.pPanel:Label_SetColor("Main", nR, nG, nB);
end

function tbUi:SetAlpha(nAlpha)
	self.pPanel:Label_SetAlpha("Main", nAlpha);
end

function tbUi:SetFontSize(nSize)
	self.pPanel:Label_SetFontSize("Main", nSize);
end

function tbUi:SetVisible(bVisible)
	self.pPanel:SetActive("Main", bVisible);
end

function tbUi:SetLinkText(szText)
	local tbLinks = {};
	for szLink in string.gmatch(szText, "(%[url=.-%])") do
		table.insert(tbLinks, szLink);
	end

	if next(tbLinks) then
		self.pPanel.OnTouchEvent = function (msgObj, nClickId)
			if tbLinks[nClickId] then
				Ui.HyperTextHandle:Handle(tbLinks[nClickId]);
			end
		end
	else
		self.pPanel.OnTouchEvent = nil;
	end

	self:SetText(szText);
end

