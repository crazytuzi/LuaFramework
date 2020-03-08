local tbUi = Ui:CreateClass("DreamlandGivePanel");

function tbUi:OnOpen()
	self.pPanel:Label_SetText("TxtHave", me.GetMoney(InDifferBattle.tbDefine.szMonoeyType))

	self.nCurMoney = 0;
	self:UpdateNumberInput(self.nCurMoney)
	local tbMembers = TeamMgr:GetTeamMember()

	local fnOnClick = function (itemClass)
		self.nSelRoleIndex = itemClass.index
	end

	local fnSetItem = function (itemObj, index)
		itemObj.index = index
		local tbRoleInfo = tbMembers[index]
		itemObj.pPanel.OnTouchEvent = fnOnClick;
		itemObj.pPanel:Toggle_SetChecked("Main", self.nSelRoleIndex == index)
		local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbRoleInfo.nPortrait)
		itemObj.pPanel:Sprite_SetSprite("SpRoleHead", szPortrait, szAltas);
		local SpFaction = Faction:GetIcon(tbRoleInfo.nFaction)
		itemObj.pPanel:Sprite_SetSprite("SpFaction",  SpFaction);
		itemObj.pPanel:Label_SetText("lbLevel", tbRoleInfo.nLevel)
		itemObj.pPanel:Label_SetText("Name", tbRoleInfo.szName)

	end
	self.GiveScrollView:Update(tbMembers, fnSetItem);
	self.pPanel:SetActive("Tip", #tbMembers == 0)
end

function tbUi:UpdateNumberInput(nCurMoney)
	if nCurMoney < 0 then
		return self.nCurMoney
	end
	if nCurMoney > me.GetMoney(InDifferBattle.tbDefine.szMonoeyType) then
		nCurMoney = me.GetMoney(InDifferBattle.tbDefine.szMonoeyType)
	end
    self.pPanel:Label_SetText("InputCountText", nCurMoney)
    self.nCurMoney = nCurMoney
    return nCurMoney
end


tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end;

	BtnMinus = function (self)
		if self.nCurMoney <= 0 then
			return
		end
		self:UpdateNumberInput(self.nCurMoney - 1)
	end;

	BtnPlus = function (self)
		if self.nCurMoney >= me.GetMoney(InDifferBattle.tbDefine.szMonoeyType) then
			return
		end
		self:UpdateNumberInput(self.nCurMoney + 1)
	end;

	InputNumber = function (self)
		local function fnUpdate(nInput)
	        local nResult = self:UpdateNumberInput(nInput);
	        return nResult;
	    end 
	    Ui:OpenWindow("NumberKeyboard", fnUpdate);
	end;
	
	BtnMax = function (self)
		self:UpdateNumberInput(me.GetMoney(InDifferBattle.tbDefine.szMonoeyType))
	end;

	BtnGive = function (self)
		local nSelRoleIndex = self.nSelRoleIndex
		if not nSelRoleIndex then
			me.CenterMsg("请先选择要赠予的队友")
			return
		end
		if self.nCurMoney <= 0 then
			me.CenterMsg("幻玉不足，无法赠送")
			return
		end

		local tbMembers = TeamMgr:GetTeamMember()
		local tbRoleInfo = tbMembers[nSelRoleIndex]
		if not tbRoleInfo then
			me.CenterMsg("无效的目标")
			return
		end

		if me.nFightMode == 2 then
			me.CenterMsg("您已阵亡，无法赠送")
			return
		end

		local pNpc = KNpc.GetById(tbRoleInfo.nNpcID)
		if pNpc and pNpc.nFightMode == 2 then
			me.CenterMsg("对方已阵亡，无法接受赠送")
			return
		end

		RemoteServer.InDifferBattleGiveMoneyTo(tbRoleInfo.nPlayerID,  self.nCurMoney)
	end;
};
