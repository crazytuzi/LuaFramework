local tbUi = Ui:CreateClass("KinPowerEditor");

function tbUi:Init()
	Kin:UpdateMemberList();
	self:UpdateListInfo(tbMembers);
end

function tbUi:UpdateListInfo()
	local tbMembers = Kin:GetMemberList() or {};
	local tbItems = {};
	for _, tbData in pairs(tbMembers) do
		if tbData.nCareer == Kin.Def.Career_ViceMaster then
			table.insert(tbItems, tbData);
		end
	end

	self.tbItems = tbItems;

	local nLeaderId = Kin:GetLeaderId()
	for nIdx = 1, 2 do
		if nIdx <= #tbItems then
			self.pPanel:SetActive("Item" .. nIdx, true);
			local listObj = self["Item" .. nIdx];
			local tbItem = tbItems[nIdx];
			listObj.pPanel:Label_SetText("Name", tbItem.szName);		
			local nVipLevel = tbItem.nVipLevel
			if not nVipLevel or  nVipLevel == 0 then
				listObj.pPanel:SetActive("VIP", false)
			else
				listObj.pPanel:SetActive("VIP", true)
				listObj.pPanel:Sprite_Animation("VIP",  Recharge.VIP_SHOW_LEVEL[nVipLevel]);			
			end

			local szCareerName = Kin.Def.Career_Name[tbItem.nCareer]
			if nLeaderId==tbItem.nMemberId then
				if Kin.Def.tbManagerCareers[tbItem.nCareer] then
					szCareerName = string.format("%s/%s", Kin.Def.Career_Name[Kin.Def.Career_Leader], szCareerName)
				else
					szCareerName = Kin.Def.Career_Name[Kin.Def.Career_Leader]
				end
			end

			listObj.pPanel:Label_SetText("Level", tbItem.nLevel);
			listObj.pPanel:Label_SetText("Post", szCareerName);
			local szFactionIcon = Faction:GetIcon(tbItem.nFaction);
			listObj.pPanel:Sprite_SetSprite("Faction", szFactionIcon);

			tbItem.tbAuthority = tbItem.tbAuthority or {};
			local tbAuthority = tbItem.tbAuthority;
			listObj.pPanel:Toggle_SetChecked("PowerKickOut", tbAuthority[Kin.Def.Authority_KickOut] and true or false);
			listObj.pPanel:Toggle_SetChecked("PowerGrant", tbAuthority[Kin.Def.Authority_GrantOlder] and true or false);
			listObj.pPanel:Toggle_SetChecked("PowerBuilding", tbAuthority[Kin.Def.Authority_Building] and true or false);
		else
			self.pPanel:SetActive("Item" .. nIdx, false);
		end
	end
end

tbUi.tbOnClick = {};

function tbUi.tbOnClick:BtnSaveChange()
	if not self.tbItems then
		return;
	end

	local myMemberData = Kin:GetMyMemberData();
	if myMemberData.nCareer ~= Kin.Def.Career_Master then
		me.CenterMsg("无权限进行修改");
		return;
	end

	local tbAuthorityData = {};
	for nIdx = 1, #self.tbItems do
		local tbItemData = self.tbItems[nIdx];
		local item = self["Item" .. nIdx];
		tbAuthorityData[tbItemData.nMemberId] = {
			[Kin.Def.Authority_KickOut]      = item.pPanel:Toggle_GetChecked("PowerKickOut");
			[Kin.Def.Authority_GrantOlder]   = item.pPanel:Toggle_GetChecked("PowerGrant");
			[Kin.Def.Authority_Building]      = item.pPanel:Toggle_GetChecked("PowerBuilding");
		}

		tbItemData.tbAuthority = tbAuthorityData[tbItemData.nMemberId];
	end

	if next(tbAuthorityData) then
		RemoteServer.OnKinRequest("SetAuthority", tbAuthorityData);
	end
end
