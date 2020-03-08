local tbUi = Ui:CreateClass("Button");

function tbUi:SetText(szText)
	self.pPanel:Label_SetText("Text", szText);
end

function tbUi:SetState(nState)
	self.pPanel:Button_SetState("Main", nState);
end

function tbUi:SetVisible(bVisible)
	self.pPanel:SetActive("Main", bVisible);
end

function tbUi:SetGroup(nGroup)
	self.pPanel:Toggle_SetGroup("Main", nGroup);
end

function tbUi:SetChecked(bChecked)
	self.pPanel:Toggle_SetChecked("Main", bChecked);
end

function tbUi:SetCD(nCD)
	self.cd = nCD;
end

function tbUi:Countdown()
--	if self.cd and self.cd > 0 then
--		self.Text:SetText(self.cd);
--		self.Text:SetVisible(true);
--		self.Mask.pPanel:SetActive(true);
--		self.Mask.pPanel:Sprite_SetFillPercent(1);
--		local nDownCd = self.cd;
--		--TODO: Timer的帧数有待动态获取
--		local nID = Timer:Register(15 * 1, function ()
--			if nDownCd > 0 then
--				local nPercent = nDownCd / self.cd;
--				self.Mask.pPanel:Sprite_SetFillPercent(nPercent);
--				self.Text:SetText(tostring(nDownCd));
--				nDownCd = nDownCd - 1;
--				return true;
--			else
--				self.Mask.pPanel:Sprite_SetFillPercent(0);
--				--self.Mask:SetVisible(false);
--				self.Mask.pPanel:SetActive(false)
--				self.Text:SetVisible(false);
--				return false;
--			end
--		end)
--	end
end