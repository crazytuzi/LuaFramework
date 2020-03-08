
local tbUi = Ui:CreateClass("ImperialTombPanel");

tbUi.tbOnClick = {};
tbUi.tbOnDrag =
{
	PartnerView = function (self, szWnd, nX, nY)
		self.pPanel:NpcView_ChangeDir("PartnerView", -nX, true)
	end,
}

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnOpen(bFemaleEmperor)
	self.bFemaleEmperor = bFemaleEmperor

	self.pPanel:NpcView_Open("PartnerView");
	self.pPanel:NpcView_ShowNpc("PartnerView", 0);
	self.pPanel:NpcView_SetScale("PartnerView", 0.7);

	if self.bFemaleEmperor then
		self.pPanel:Label_SetText("TitleType", "女帝疑冢");
	else
		self.pPanel:Label_SetText("TitleType", "始皇降世");
	end

	ImperialTomb:BossStatusRequest();

	self:UpdateListLeft();
end

function tbUi:OnClose()
	self.pPanel:NpcView_ShowNpc("PartnerView", 0);
	self.pPanel:NpcView_Close("PartnerView");
end

function tbUi:UpdateListItemMap(tbSubInfo)
	local szNameMsg = string.format("[faffa3]%s[-]", tbSubInfo.szNpcName);

	self.pPanel:Label_SetText("LeadName", szNameMsg);

	local _, nResId = KNpc.GetNpcShowInfo(tbSubInfo.nTemplateId);
	self.pPanel:NpcView_ShowNpc("PartnerView", nResId);

	self:UpdateSubAward(tbSubInfo);
	self:UpdateSubContent(tbSubInfo);
end

function tbUi:UpdateSubAward(tbSubInfo)
	local tbShowAward = ImperialTomb:GetShowAward(tbSubInfo.nTemplateId)
	if not tbShowAward then
		self.pPanel:SetActive("ChallengeAward", false);
		self.pPanel:SetActive("ScrollViewAward", false);
		return
	end

	self.pPanel:SetActive("ChallengeAward", true);
	self.pPanel:SetActive("ScrollViewAward", true);

	local fnSetItem = function (tbItem, nIndex)
		local tbReward = tbShowAward[nIndex];
		if tbReward then
			if tbReward[1] == "item" then
				tbItem.itemframe1:SetItemByTemplate(tbReward[2], tbReward[3] or 1, me.nFaction);
			else
				tbItem.itemframe1:SetDigitalItem(tbReward[1], tbReward[2] or 1);
			end

			tbItem.itemframe1.fnClick = tbItem.itemframe1.DefaultClick;
		end
	end

	self.ScrollViewAward:Update(#tbShowAward, fnSetItem);
end

function tbUi:UpdateSubContent(tbSubInfo)
	for nI = 1, 4 do
		self.pPanel:SetActive("Container"..nI, false);
	end

	if self.bFemaleEmperor and
	 tbSubInfo.nTemplateId ~= ImperialTomb.EMPEROR_INFO.nTemplate and
	 tbSubInfo.nTemplateId ~= ImperialTomb.FEMALE_EMPEROR_INFO.nTemplate then
		self.pPanel:SetActive("ImperialTombTips", true);
		self.pPanel:Label_SetText("ImperialTombTips", string.format("共刷新两个%s，同一区只会刷新一个%s", tbSubInfo.szNpcName, tbSubInfo.szNpcName));
	else
		self.pPanel:SetActive("ImperialTombTips", false);
		self.pPanel:SetActive("BtnInfo", true)
		if self.bFemaleEmperor then
			self.pPanel:ResetGeneralHelp("BtnInfo", "ImperialTombFemaleHelp")
		else
			self.pPanel:ResetGeneralHelp("BtnInfo", "ImperialTombEmperorHelp")
		end
	end

	for nIndex,tbEnterInfo in ipairs(tbSubInfo.tbEnterList) do
		local nStatus, tbDeathInfo, tbEnterTrapInfo = ImperialTomb:GetBossStatus(tbEnterInfo.nMapType, tbEnterInfo.nIndex)
		local szTime = string.format("%.2d:%.2d", 22, 0);
		local szStatus = ""
		local szExrta = ""
		if nStatus == ImperialTomb.BOSS_STATUS.NONE then
			self.pPanel:SetActive("DeathLine"..nIndex, false);
			szStatus = tbEnterInfo.szMapName
			szExrta =  XT("未刷新")
			self.pPanel:SetActive("BtnGo"..nIndex, true);
		elseif nStatus == ImperialTomb.BOSS_STATUS.EXSIT then
			self.pPanel:SetActive("DeathLine"..nIndex, false);
			if tbEnterInfo.nMapType == ImperialTomb.MAP_TYPE.EMPEROR_ROOM then
				szStatus = string.format("%s入口%s", tbEnterInfo.szMapName, Lib:TransferDigit2CnNum(nIndex))
			else
				szStatus = tbEnterInfo.szMapName
			end
			self.pPanel:SetActive("BtnGo"..nIndex, true);
		elseif nStatus == ImperialTomb.BOSS_STATUS.DEAD then
			self.pPanel:SetActive("DeathLine"..nIndex, true);
			self.pPanel:SetActive("BtnGo"..nIndex, false);
			if tbDeathInfo then
				szStatus = string.format(XT("[92d2ff]击杀者：[-][faffa3]%s[-]"), tbDeathInfo[1] or "-")
				szExrta =  string.format(XT("[92d2ff]家族：[-][faffa3]%s[-]"), tbDeathInfo[2] or "-")
			else
				szStatus = string.format("\t%s", XT("[1eff00]已击杀[-]"));
			end
		end

		if tbEnterInfo.nMapType == ImperialTomb.MAP_TYPE.EMPEROR_ROOM then
			self.pPanel:Label_SetText("ContentTime"..nIndex, XT("已刷新"));
		elseif tbEnterInfo.nMapType == ImperialTomb.MAP_TYPE.FEMALE_EMPEROR_ROOM then
			self.pPanel:Label_SetText("ContentTime"..nIndex, self:GetEnterName(tbEnterInfo.nMapType, tbEnterTrapInfo[6]));
		else
			self.pPanel:Label_SetText("ContentTime"..nIndex, szTime);
		end

		self.pPanel:Label_SetText("ContentStatus"..nIndex, szStatus);
		self.pPanel:Label_SetText("ContentExtra"..nIndex, szExrta);
		self.pPanel:SetActive("Container"..nIndex, true);

		self["BtnGo"..nIndex].pPanel.OnTouchEvent = function ()
			if Calendar:IsActivityInOpenState("ImperialTombEmperor") or Calendar:IsActivityInOpenState("ImperialTombFemaleEmperor") then
				ImperialTomb:EnterEmperorRequest(tbEnterInfo.nMapTemplateId, tbEnterInfo.nX, tbEnterInfo.nY, tbEnterInfo.nParam)
			else
				me.CenterMsg(XT("活动尚未开始"))
			end
		end;
	end
end

function tbUi:UpdateListLeft()
	self.tbNpcList = {}

	--秦始皇
	local nEmperorMapType = ImperialTomb.MAP_TYPE.EMPEROR_ROOM

	local tbEmperorNpcInfo = 
	{
		nTemplateId = ImperialTomb.EMPEROR_INFO.nTemplate,
		tbEnterList = {},
	}

	if self.bFemaleEmperor then
		tbEmperorNpcInfo.nTemplateId = ImperialTomb.FEMALE_EMPEROR_INFO.nTemplate
		nEmperorMapType = ImperialTomb.MAP_TYPE.FEMALE_EMPEROR_ROOM
	end

	--tbEnterTrapInfo 格式 {nMapType, nMapTemplateId, nMapId, nX, nY, nTrapId}

	local bEmperorExist = false;

	for nIndex=1, ImperialTomb.EMPEROR_COUNT do
		local nStatus, tbDeathInfo, tbEnterTrapInfo = ImperialTomb:GetBossStatus(nEmperorMapType, nIndex)
		if tbEnterTrapInfo then
			tbEmperorNpcInfo.tbEnterList[nIndex] = 
			{
				szMapName = self:GetEnterName(nEmperorMapType),
				nIndex = nIndex,
				nMapType = nEmperorMapType,
				nMapTemplateId = tbEnterTrapInfo[2],
				nX = tbEnterTrapInfo[4],
				nY = tbEnterTrapInfo[5],
				nParam = tbEnterTrapInfo[6],
			}

			bEmperorExist = true
		end
	end

	if bEmperorExist then
		self:FillNpcInfo(tbEmperorNpcInfo);

		table.insert(self.tbNpcList, tbEmperorNpcInfo)
	end

	--首领
	local nBossMapType = ImperialTomb.MAP_TYPE.BOSS_ROOM
	local nBossCount = ImperialTomb.BOSS_COUNT
	local tbBossInfo = ImperialTomb.BOSS_INFO
	local tbTmpNpcList = {}

	if self.bFemaleEmperor then
		nBossMapType = ImperialTomb.MAP_TYPE.FEMALE_EMPEROR_BOSS_ROOM
		nBossCount =  ImperialTomb.FEMALE_EMPEROR_BOSS_COUNT
		tbBossInfo = ImperialTomb.FEMALE_EMPEROR_BOSS_INFO
	end

	for nIndex=1, nBossCount do
		local nStatus, tbDeathInfo, tbEnterTrapInfo = ImperialTomb:GetBossStatus(nBossMapType, nIndex)
		local tbBossInfo = tbBossInfo[nIndex]
		local nTemplateId = tbBossInfo and tbBossInfo.nTemplate

		if nTemplateId then
			local tbNpcInfo = tbTmpNpcList[nTemplateId]
			if not tbNpcInfo then
				tbNpcInfo = 
				{
					nTemplateId = nTemplateId,
					tbEnterList = {},
				}
				self:FillNpcInfo(tbNpcInfo);
				table.insert(self.tbNpcList, tbNpcInfo)
				tbTmpNpcList[nTemplateId] = tbNpcInfo
				if self.bFemaleEmperor and nStatus == ImperialTomb.BOSS_STATUS.NONE then
					--如果武则天的首领还没刷新显示4个进入点
					for nEnterIndex,tbEnterPos in ipairs(ImperialTomb.FEMALE_EMPEROR_FLOOR_ENTER_POS) do
						table.insert(tbNpcInfo.tbEnterList, 
							{
								szMapName = ImperialTomb.FEMALE_EMPEROR_SAFE_ZONE_NAME[nEnterIndex],
								nIndex = nIndex,
								nMapType = nBossMapType,
								nMapTemplateId = ImperialTomb.MAP_TEMPLATE_ID[ImperialTomb.MAP_TYPE.FEMALE_EMPEROR_FLOOR],
								nX = tbEnterPos[1],
								nY = tbEnterPos[2],
								nParam = nEnterIndex,
							})
					end
				end
			end

			if tbEnterTrapInfo and (not self.bFemaleEmperor or nStatus ~= ImperialTomb.BOSS_STATUS.NONE ) then
				table.insert(tbNpcInfo.tbEnterList, 
					{
						szMapName = self:GetEnterName(tbEnterTrapInfo[1], tbEnterTrapInfo[6]),
						nIndex = nIndex,
						nMapType = nBossMapType,
						nMapTemplateId = tbEnterTrapInfo[2],
						nX = tbEnterTrapInfo[4],
						nY = tbEnterTrapInfo[5],
						nParam = self:GetEnterIndexFromTrapId(nBossMapType, tbEnterTrapInfo[6]),
					})
			end
		end
	end

	local fnSelLeftKey = function (tbItem)
		self.nSelectIndex = tbItem.nIndex;
		self:UpdateListItemMap(tbItem.tbInfo);
	end

	local fnSetItem = function (tbItem, nIndex)
		local tbInfo = self.tbNpcList[nIndex];
		tbItem.tbInfo = tbInfo;
		tbItem.nIndex = nIndex;
		local szSubName = string.format("%s", tbInfo.szNpcName);

		if tbInfo.szFaceAtlas and tbInfo.szFaceSprite then
			tbItem.pPanel:SetActive("BossHead", true);
			tbItem.pPanel:Sprite_SetSprite("BossHead", tbInfo.szFaceSprite, tbInfo.szFaceAtlas);
		else
			tbItem.pPanel:SetActive("BossHead", false);
		end

		tbItem.pPanel:Label_SetText("LabelDark", szSubName);
		tbItem.pPanel:Label_SetText("LabelLight", szSubName);
		tbItem.pPanel.OnTouchEvent = fnSelLeftKey;
	end

	--Lib:LogTB(tbTmpNpcList)
	local nTotalCount = #self.tbNpcList;
	self.ScrollViewBtn:Update(nTotalCount, fnSetItem);

	self.nSelectIndex = self.nSelectIndex or 1;
	if self.nSelectIndex > nTotalCount then
		self.nSelectIndex = 1;
	end

	if nTotalCount >= self.nSelectIndex then
		self:UpdateListItemMap(self.tbNpcList[self.nSelectIndex]);
	end
end

function tbUi:FillNpcInfo(tbNpcInfo)
	tbNpcInfo.szNpcName  = KNpc.GetNameByTemplateId(tbNpcInfo.nTemplateId);

	local nFaceId = KNpc.GetNpcShowInfo(tbNpcInfo.nTemplateId);
	tbNpcInfo.szFaceAtlas, tbNpcInfo.szFaceSprite = Npc:GetFace(nFaceId);
end

function tbUi:GetEnterName(nMapType, nTrapId)
	if nMapType == ImperialTomb.MAP_TYPE.FIRST_FLOOR then
		return XT("一层密室")
	elseif nMapType == ImperialTomb.MAP_TYPE.SECOND_FLOOR then
		return XT("二层密室")
	elseif nMapType == ImperialTomb.MAP_TYPE.THIRD_FLOOR then
		return XT("三层密室")
	elseif nMapType == ImperialTomb.MAP_TYPE.EMPEROR_ROOM then
		return XT("永生台")
	elseif nMapType == ImperialTomb.MAP_TYPE.FEMALE_EMPEROR_ROOM then
		return ImperialTomb.FEMALE_EMPEROR_SAFE_ZONE_NAME[nTrapId] or ""
	elseif nMapType == ImperialTomb.MAP_TYPE.FEMALE_EMPEROR_FLOOR then
		return ImperialTomb.FEMALE_EMPEROR_BOSS_SAFE_ZONE_NAME[nTrapId] or ""
	end

	return ""
end

function tbUi:GetEnterIndexFromTrapId(nMapType, nTrapId)
	if nMapType ~= ImperialTomb.MAP_TYPE.FEMALE_EMPEROR_BOSS_ROOM then
		return nTrapId
	end

	return ImperialTomb.FEMALE_EMPEROR_BOSS_TRAP_2_ENTER_INDEX[nTrapId]
end

function tbUi:OnRefreshStatus()
	self:UpdateListLeft();
	local tbInfo = self.tbNpcList[self.nSelectIndex];
	if tbInfo then
		self:UpdateListItemMap(tbInfo);
	end
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{UiNotify.emNOTIFY_IMPERIAL_TOMB_BOSS_STATUS, self.OnRefreshStatus},
	};

	return tbRegEvent;
end