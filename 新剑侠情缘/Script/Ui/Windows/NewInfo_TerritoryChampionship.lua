local tbUi = Ui:CreateClass("NewInfo_TerritoryChampionship")

function tbUi:OnOpen(tbNewInfoData)
	self.pPanel:Label_SetText("WLDHInformation", string.format("恭喜[FFFE0D]%s[-] 家族荣登临安城王座！", tbNewInfoData.szKinFullName));
	self.pPanel:Label_SetText("PlayerName", tbNewInfoData.szLeaderName);

	if tbNewInfoData.nLeaderHonorLevel > 0 then
		self.pPanel:SetActive("PlayerTitle", true)
		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbNewInfoData.nLeaderHonorLevel)
		self.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
	else
		self.pPanel:SetActive("PlayerTitle", false)
	end

	if tbNewInfoData.nLeaderFaction > 0 then
		self.pPanel:NpcView_Open("PlayerView", tbNewInfoData.nLeaderFaction);

		if tbNewInfoData.nLeaderResId > 0 then
			self.pPanel:NpcView_ShowNpc("ShowRole", tbNewInfoData.nLeaderResId);
		end

		for nPartId, nResId in pairs( tbNewInfoData.tbLeaderPartRes ) do
			--暂时不骑马
			if nPartId == Npc.NpcResPartsDef.npc_part_horse then
				nResId = 0;
			end

			if nResId > 0 then
				self.pPanel:NpcView_ChangePartRes("PlayerView", nPartId, nResId);
			end
		end

		--self.pPanel:NpcView_SetScale("PlayerView", 0.8);
		--self.pPanel:NpcView_ChangeDir("PlayerView", 220, false);
	end
end