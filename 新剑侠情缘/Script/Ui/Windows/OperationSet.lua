
local tbUi = Ui:CreateClass("OperationSet");

tbUi.MAX_INPUT = 27

tbUi.tbOnClick = {}
for i = 1, tbUi.MAX_INPUT do
	tbUi.tbOnClick[string.format("Input%02d",i)] = function (self)
		self:OnClickInput(i)
	end
end

function tbUi.tbOnClick.BtnClose(self)
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi.tbOnClick.BtnComfirm(self)
	if self.tbKeyList then
		Ui.Hotkey:Save(self.tbKeyList)
	end
end

function tbUi:OnOpen()
	self:UpdateKeyList()
	self:Update()
	
	local tbShowSkillInfo = FightSkill:GetFactionSkill(me.nFaction);
	
	for _, tbInfo in pairs(tbShowSkillInfo) do
        if tbInfo.BtnIcon then
            self.pPanel:Sprite_SetSprite(tbInfo.BtnName.."Icon", tbInfo.BtnIcon, tbInfo.IconAltlas);
        else
            self.pPanel:SetActive(tbInfo.BtnName.."Icon", false);
        end
    end
	
	
end

function tbUi:OnClose()
	if self.nCurKeyId then
		self.pPanel:SetActive(string.format("light%02d", self.nCurKeyId), false)
		self.nCurKeyId = nil
	end
	Ui.UiManager.CheckAnyKeyDown(false);
end

function tbUi:Update()
	if not self.tbKeyList then
		self:UpdateKeyList()
	end
	for i = 1, tbUi.MAX_INPUT do
		self.pPanel:Label_SetText(string.format("TxtTitle%02d", i), self.tbKeyList[i] or "")
	end
end

function tbUi:UpdateKeyList()
	self.tbKeyList = Ui.Hotkey:GetCurSetting()
end

function tbUi:OnClickInput(nKeyId)
	if self.nCurKeyId then
		self.pPanel:SetActive(string.format("light%02d", self.nCurKeyId), false)
		self.nCurKeyId = nil
	end
	self.nCurKeyId = nKeyId
	self.pPanel:SetActive(string.format("light%02d", self.nCurKeyId), true)
	Ui.UiManager.CheckAnyKeyDown(true);
end

function tbUi:OnCheckAnyKeyDown(szKey)
	if self.nCurKeyId then
		self.tbKeyList[self.nCurKeyId] = szKey
		for nNowKeyId, szNowKey in pairs(self.tbKeyList) do
			if nNowKeyId ~= self.nCurKeyId and szNowKey == szKey then
				self.tbKeyList[nNowKeyId] = ""
			end
		end
		self.pPanel:SetActive(string.format("light%02d", self.nCurKeyId), false)
		self.nCurKeyId = nil;
		self:Update()
	end
end

