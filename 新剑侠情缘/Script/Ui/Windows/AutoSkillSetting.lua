local tbUi = Ui:CreateClass("AutoSkillSetting");

local nAutoSkillCount = 10
local nCellCount = 5

function tbUi:RegisterEvent()
	local tbRegEvent = {
		{UiNotify.emNOTIFY_MAP_LEAVE, self.AutoClose},
		{UiNotify.emNOTIFY_FINISH_PERSONALFUBEN, self.AutoClose},
		{UiNotify.emNOTIFY_SHOW_DIALOG, self.AutoClose},
	}
	return tbRegEvent
end

function tbUi:OnOpenEnd()
	local tbSetting = AutoFight:GetSetting();
	local tbBegin = {1, nCellCount + 1};
	local tbEnd = {nCellCount, nAutoSkillCount};
	for i = 1, nAutoSkillCount do
		self["SkillIcon" .. i].tbSkill = nil
	end
	for i = 1, nAutoSkillCount do
		local tbSkill = tbSetting[i];
		if tbSkill then
			local nWeapon = tbSkill.nWeapon + 1
			local nLevel = me.GetSkillLevel(tbSkill.nSkillId);
			if nLevel > 0 then
				self["SkillIcon" .. tbBegin[nWeapon]].tbSkill = tbSkill;
				tbSkill.bShow = true;
				tbBegin[nWeapon] = tbBegin[nWeapon] + 1;
			else
				self["SkillIcon" .. tbEnd[nWeapon]].tbSkill = tbSkill;
				tbSkill.bActive = false;
				tbSkill.bShow = false;
				tbEnd[nWeapon] = tbEnd[nWeapon] - 1;
			end
		end
	end

	local b2List = tbBegin[2] > (nCellCount + 1)
	if b2List then
		self.pPanel:ChangeScale("SkillList1", 0.8, 0.8, 0.8)
		self.pPanel:ChangePosition("SkillList1", 0, 80)
	else
		self.pPanel:ChangeScale("SkillList1", 1, 1, 1)
		self.pPanel:ChangePosition("SkillList1", 0, 46)
	end

	local nJiuId = Item:GetClass("jiu").nTemplateId
	local nCount = me.GetItemCountInAllPos(nJiuId) or 0
	self.itemframe:SetItemByTemplate(nJiuId, nCount) --酒的道具id
	self.itemframe.fnClick = self.itemframe.DefaultClick

	self:Update();


	local nSelectMode = Operation:GetSelectTargetMode();
	if nSelectMode == Operation.eTargetModeUnlimited then
		self.pPanel:Toggle_SetChecked("Unlimited", true);
	elseif nSelectMode == Operation.eTargetModeNpcFirst then
		self.pPanel:Toggle_SetChecked("NPC", true);
	elseif nSelectMode == Operation.eTargetModePlayerFirst then
		self.pPanel:Toggle_SetChecked("Player", true);
	end

	Guide.tbNotifyGuide:ClearNotifyGuide("AutoFightSettingGuide");
end

function tbUi:OnClose()
	local bNpcFirst    = self.pPanel:Toggle_GetChecked("NPC");
	local bPlayerFirst = self.pPanel:Toggle_GetChecked("Player");
	local nSelectMode  = Operation.eTargetModeUnlimited;
	if bNpcFirst then
		nSelectMode = Operation.eTargetModeNpcFirst;
	elseif bPlayerFirst then
		nSelectMode = Operation.eTargetModePlayerFirst;
	end
	Operation:SetSelectTargetMode(nSelectMode);

	Ui.UiManager.DisableDragSprite();
end

function tbUi:Update()
	for i = 1, nAutoSkillCount do
		local skillObj = self["SkillIcon" .. i];
		local bShow = skillObj.tbSkill and skillObj.tbSkill.bShow
		skillObj.pPanel:SetActive("Main", bShow);
		if bShow then
			local tbIcon, _ = FightSkill:GetSkillShowInfo(skillObj.tbSkill.nSkillId);
			skillObj.pPanel:Toggle_SetChecked("Main", skillObj.tbSkill.bActive);
			skillObj.pPanel:SetActive("Mark", not skillObj.tbSkill.bActive);
			skillObj.pPanel:Sprite_SetSprite("Main", tbIcon.szIconSprite, tbIcon.szIconAtlas);

			local tbSkillFactionInfo = FightSkill:GetSkillFactionInfo(skillObj.tbSkill.nSkillId) or {};
			local bAngerSkill = tbSkillFactionInfo.IsAnger == 1;
			skillObj.pPanel:SetActive("AngerSkill", bAngerSkill);
		end
	end

	self.pPanel:Toggle_SetChecked("CheckBoxItem", (not Client:GetFlag("NotAutoUseJiu")) or false)
	self.pPanel:Toggle_SetChecked("CheckBoxItem2", (not Ui:CheckNotShowTips("ShowAutoBuyJiu|NEVER")))


	local tbSetting = AutoFight:GetSetting();
	for i = 1, nAutoSkillCount do
		tbSetting[i] = self["SkillIcon" .. i].tbSkill;
	end
end

tbUi.tbOnClick = {};

function tbUi.tbOnClick:BtnClose()
	AutoFight:SaveSetting();

	UiNotify.OnNotify(UiNotify.emNOTIFY_AUTO_SKILL_CHANGED);
	Ui:CloseWindow("AutoSkillSetting");
end


function tbUi.tbOnClick:CheckBoxItem()
	if self.pPanel:Toggle_GetChecked("CheckBoxItem") then
		Client:ClearFlag("NotAutoUseJiu")
	else
		Client:SetFlag("NotAutoUseJiu")
	end
end

function tbUi.tbOnClick:CheckBoxItem2()
	if self.pPanel:Toggle_GetChecked("CheckBoxItem2") then
		Ui:SetNotShowTips("ShowAutoBuyJiu|NEVER", false)
	else
		Ui:SetNotShowTips("ShowAutoBuyJiu|NEVER", true)
	end
end


tbUi.tbOnDrag    = {};
tbUi.tbOnDrop    = {};
tbUi.tbOnDragEnd = {};

for i = 1, nAutoSkillCount do
	tbUi.tbOnDrag["SkillIcon" .. i] = function (self, szWnd, ...)
		self:StartDrag(i, szWnd);
	end

	tbUi.tbOnDrop["SkillIcon" .. i] = function (self, szWnd, szDropWnd)
		self:OnDropSwitch(szWnd, szDropWnd);
	end

	tbUi.tbOnClick["SkillIcon" .. i] = function (self)
		local skillObj = self["SkillIcon" .. i];
		if skillObj.tbSkill then
			skillObj.tbSkill.bActive = skillObj.pPanel:Toggle_GetChecked("Main");
			self:Update();
		end
	end
end

function tbUi:StartDrag(nPosId, szWnd)
	local orgObj = self[szWnd];
	if orgObj.tbSkill and orgObj.tbSkill.bShow then
		local tbIcon, _ = FightSkill:GetSkillShowInfo(orgObj.tbSkill.nSkillId);
		self.pPanel:StartDrag(tbIcon.szIconAtlas, tbIcon.szIconSprite);
	end
end

function tbUi:OnDropSwitch(szWnd, szDropWnd)
	local szPosIdx = string.match(szWnd, "^SkillIcon(%d+)");
	local szDropPosIdx = string.match(szDropWnd, "^SkillIcon(%d+)");

	if not szPosIdx or not szDropPosIdx then
		return;
	end

	local orgObj = self[szWnd];
	local targetObj = self[szDropWnd];
	if not orgObj.tbSkill.bShow or not targetObj.tbSkill.bShow then
		return;
	end

	local nBeginPos = tonumber(szPosIdx)
	local nEndPos = tonumber(szDropPosIdx)
	if nBeginPos == nEndPos then
		return
	end

	if (nBeginPos <= nCellCount and nEndPos > nCellCount) or
		(nBeginPos > nCellCount and nEndPos <= nCellCount) then
		for i = 1, nCellCount do
			local orgObjT = self["SkillIcon" .. i]
			local targetObjT = self["SkillIcon" .. (i + nCellCount)]
			orgObjT.tbSkill, targetObjT.tbSkill = targetObjT.tbSkill, orgObjT.tbSkill
		end
	else
		orgObj.tbSkill, targetObj.tbSkill = targetObj.tbSkill, orgObj.tbSkill;
	end
	
	self:Update();
end

function tbUi:AutoClose()
	Ui:CloseWindow("AutoSkillSetting")
end
