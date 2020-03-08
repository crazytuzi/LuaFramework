local tbUi = Ui:CreateClass("EquipStarAttribTips");

function tbUi:OnOpen(szType)
	if szType == "Enhance" then
		local nCurEnhExIdx = me.nEnhExIdx;
		local tbCurAttrib, tbNextAttrib;
		local nNextEnhExIdx = (nCurEnhExIdx or 0) + 1;
		if nCurEnhExIdx then
			tbCurAttrib = Strengthen:GetEnhExAttrib(nCurEnhExIdx)
			self.pPanel:Label_SetText("CurLevel",  string.format("%d件%d级装备", tbCurAttrib.NeedNum, tbCurAttrib.EnhLevel))
		else
			self.pPanel:Label_SetText("CurLevel", "0级")
		end
		local szBottomDesc = "全身装备强化至一定等级，可激活额外属性"

		if nNextEnhExIdx then
			tbNextAttrib = Strengthen:GetEnhExAttrib(nNextEnhExIdx)
			if tbNextAttrib then
				if Strengthen.tbEnhanceLv then
					local nCurNum = Strengthen.tbEnhanceLv[tbNextAttrib.EnhLevel] or 0
					szBottomDesc = string.format("已强化%d级的装备：[c8ff00]%d/%d[-]", tbNextAttrib.EnhLevel, nCurNum, tbNextAttrib.NeedNum)
				end

				self.pPanel:Label_SetText("NextLevel",  string.format("%d件%d级装备", tbNextAttrib.NeedNum, tbNextAttrib.EnhLevel))
			else
				self.pPanel:Label_SetText("NextLevel", "已满级")
			end
		end
		
		self:Update(
			"装备强化激活",
			tbCurAttrib,
			tbNextAttrib,
			szBottomDesc)
		
	elseif szType == "Inset" then
		
		local nCurInsetExIdx = me.nInsetExIdx;
		local tbCurAttrib, tbNextAttrib;
		local nNextInsetExIdx = (nCurInsetExIdx or 0) + 1;
		if nCurInsetExIdx then
			tbCurAttrib = StoneMgr:GetInsetExAttrib(nCurInsetExIdx)
			self.pPanel:Label_SetText("CurLevel", string.format("%d个%d级魂石", tbCurAttrib.NeedNum, tbCurAttrib.StoneLevel))
		else
			self.pPanel:Label_SetText("CurLevel", "0级")
		end

		local szBottomDesc = "全身装备镶嵌一定等级的魂石，可激活额外属性"
		
		if nNextInsetExIdx then
			tbNextAttrib = StoneMgr:GetInsetExAttrib(nNextInsetExIdx)
			if tbNextAttrib then
				if StoneMgr.tbInsetLv then
					local nCurNum = StoneMgr.tbInsetLv[tbNextAttrib.StoneLevel] or 0
					szBottomDesc = string.format("已镶嵌%d级魂石：[c8ff00]%d/%d[-]", tbNextAttrib.StoneLevel, nCurNum, tbNextAttrib.NeedNum)
				end
				self.pPanel:Label_SetText("NextLevel",  string.format("%d个%d级魂石", tbNextAttrib.NeedNum, tbNextAttrib.StoneLevel))
			else
				self.pPanel:Label_SetText("NextLevel", "已满级")
			end
		end
		self:Update(
			"装备镶嵌激活",
			tbCurAttrib,
			tbNextAttrib,
			szBottomDesc)
	end
end
	
function tbUi:Update(szTitle, tbCurAttrib, tbNextAttrib, szDesc)
	self.pPanel:Label_SetText("Title", szTitle);
	self.pPanel:Label_SetText("Lab_Desc", szDesc);
	
	
	if tbCurAttrib then
		self.pPanel:SetActive("CurGroup", true);
		
		self:SetAttribDesc(tbCurAttrib.tbAttrib, "Cur");
		
	else
		self.pPanel:SetActive("CurGroup", false);
	end

	if tbNextAttrib then
		self.pPanel:SetActive("NextGroup", true);
		
		self:SetAttribDesc(tbNextAttrib.tbAttrib, "Next");
	else
		self.pPanel:SetActive("NextGroup", false);
	end
end

function tbUi:SetAttribDesc(tbAttribs, szFlag)
	for i = 1, 3 do
		if tbAttribs[i] then
			local szName, szValue = FightSkill:GetMagicDescSplit(tbAttribs[i].szAttribName, tbAttribs[i].tbValue);
			self.pPanel:SetActive(szFlag .. "AttribType" .. i, true);
			self.pPanel:SetActive(szFlag .. "AttribValue" .. i, true);
			self.pPanel:Label_SetText(szFlag .. "AttribType" .. i, szName);
			self.pPanel:Label_SetText(szFlag .. "AttribValue" .. i, szValue);
		else
			self.pPanel:SetActive(szFlag .. "AttribType" .. i, false);
			self.pPanel:SetActive(szFlag .. "AttribValue" .. i, false);
		end
	end
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end
