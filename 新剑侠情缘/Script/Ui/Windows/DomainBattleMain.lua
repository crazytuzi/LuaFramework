
local tbUi = Ui:CreateClass("DomainBattleMain");

local tbNilCount = 			-- nil数量对应的层级
{
	[0] = 3,
	[1] = 2,
	[2] = 1.
}

function tbUi:Init()
	Kin:UpdateBuildingData();
	Kin:UpdateMemberCareer();
	self:RefreshUi()
end

function tbUi:RefreshUi()
	self:UpdateCity()
	self:UpdateMachine()

	self.pPanel:SetActive("CrossBattleMark",DomainBattle.tbCross:CheckCrossDay())
end

function tbUi:UpdateCity()

	local tbBaseInfo = DomainBattle.tbBaseInfo or {}
	tbBaseInfo.tbMapOwner = tbBaseInfo.tbMapOwner or {}
	local nBattleVersion = tbBaseInfo.nBattleVersion or 0;

	local function fnClickDomain(itemObj)
		if not tbBaseInfo.tbMapOwner[itemObj.nMapTemplateId] then
			local bRet, szMsg = DomainBattle:CanKinSignUpMap(itemObj.nMapTemplateId, nBattleVersion)
			if not bRet then
				if szMsg then
					me.CenterMsg(szMsg)
				end
				return
			end
		end
		Ui:OpenWindow("DomainBattleTip",itemObj.nMapTemplateId)
	end

	local nMyMapTemplateId;
	for nMapTemplateId,tbInfo in pairs(DomainBattle.tbMapLevel) do
		local nDomainLevel = tbInfo[1]
		local nIndex1 = tbInfo[2]
		local nIndex2 = tbInfo[3]
		local NNilCount = 0

		if not nIndex1 then
			NNilCount = NNilCount + 1
			nIndex1 = 0
		end

		if not nIndex2 then
			NNilCount = NNilCount + 1
			nIndex2 = 0
		end

		local nUILevel = tbNilCount[NNilCount] 				-- 层级
		local szIndex = nUILevel ..nIndex1 .. nIndex2

		local tbCity = self["City" ..szIndex];

		tbCity.nMapTemplateId = nMapTemplateId
		tbCity.pPanel.OnTouchEvent = fnClickDomain

		-- 攻占家族
		local tbOwnKin = tbBaseInfo.tbMapOwner[nMapTemplateId]
		
		local szOwnKinName = (tbOwnKin and tbOwnKin[2]) and string.format("「%s」",tbOwnKin[2])  or ""
		tbCity.pPanel:Label_SetText("FamilyName",szOwnKinName)
		tbCity.pPanel:SetActive("FamilyName",(tbOwnKin and tbOwnKin[2]))
		local tbMapSetting = Map:GetMapSetting(nMapTemplateId) or {};
		tbCity.pPanel:Label_SetText("Name", tbMapSetting.MapName)
		
		tbCity.pPanel:SetActive("Mark",false)

		if tbOwnKin or DomainBattle:CanKinSignUpMap(nMapTemplateId, nBattleVersion) then
			tbCity.pPanel:SetActive("CityMark",false)			
		else
			tbCity.pPanel:SetActive("CityMark", true)			
		end

		
		if tbOwnKin and tbOwnKin[1] and me.dwKinId == tbOwnKin[1] then
			tbCity.pPanel:SetActive("Mark",true)
			nMyMapTemplateId = nMapTemplateId;
		end
	end

	--攻占领地
	self.pPanel:Label_SetText("CityName","家族领地：" .. (nMyMapTemplateId and Map:GetMapName(nMyMapTemplateId) or "-"))
	-- 宣战目标
	self.pPanel:Label_SetText("ToggleName","争夺目标：" .. (tbBaseInfo.nWarDeclareMap and Map:GetMapName(tbBaseInfo.nWarDeclareMap) or "-" ))
end

function tbUi:UpdateMachine()
	local nApplys = Lib:CountTB(DomainBattle.define.tbBattleApplyIdOrder)

	local tbApply = DomainBattle.tbBattleSupply or {}
	for nIdx,nTemplateId in ipairs(DomainBattle.define.tbBattleApplyIdOrder) do
		local  tbItem = KItem.GetItemBaseProp(nTemplateId)
        if tbItem then
        	local szName, nIcon, nView, nQuality = Item:GetItemTemplateShowInfo(nTemplateId, me.nFaction, me.nSex);
        	local szIconAtlas, szIconSprite = Item:GetIcon(nIcon);
        	 self["itemframe" ..nIdx]:SetItemByTemplate(nTemplateId)
        	 self["itemframe" ..nIdx].fnClick = self["itemframe" ..nIdx].DefaultClick
 		 	self.pPanel:Sprite_SetSprite("itemframe" ..nIdx,szIconSprite, szIconAtlas)
 		 	local nCount = tbApply[nTemplateId] or 0
 		 	local szCount = string.format("数量：%s个",nCount)
            self.pPanel:Label_SetText("ItemName" ..nIdx,szName)
            self.pPanel:Label_SetText("ItemNumber" ..nIdx,szCount)
        end
	end
end

tbUi.tbOnClick = {};

function tbUi.tbOnClick:BtnJoinBattle()
	if DomainBattle.tbCross:CheckCrossDay() then
		RemoteServer.CrossDomainEnterReq()
	else
		DomainBattle:PlayerSign()
	end
end

function tbUi.tbOnClick:BtnBuy()
	local nBuildingId = Kin.Def.Building_War;
	local nOpenLevel = Kin:GetBuildingLimitLevel(nBuildingId);
	if Kin:GetLevel() < nOpenLevel then
		me.CenterMsg(string.format("%s在主殿%s级后开放", Kin:GetBuildingName(nBuildingId), nOpenLevel));
		return;
	end

	local tbBuildingData = Kin:GetBuildingData(nBuildingId) or {nLevel = 0};
	if Kin:GetBuildingLevel(nBuildingId) <= 0 then
		Ui:OpenWindow("KinBuildingLevelUp", nBuildingId);
		return;
	end

	Ui:OpenWindow("KinStore", nBuildingId)
end

---------------------------------提示
local tbTipUi = Ui:CreateClass("DomainBattleTip");

function tbTipUi:OnOpen(nMapID)
	if not nMapID then
		return
	end
	self.nMapID = nMapID
	self:UpdateTip()
end

function tbTipUi:UpdateTip()
	
	local tbMapSetting = Map:GetMapSetting(self.nMapID) or {};

	local szFieldName = tbMapSetting.MapName or "-"
	local szDomainLevel = DomainBattle.tbMapLevelDesc[DomainBattle:GetMapLevel(self.nMapID)] 
	
	local tbBaseInfo = DomainBattle.tbBaseInfo or {}
	local tbMapOwner = tbBaseInfo.tbMapOwner or {}
	local tbKinInfo = tbMapOwner[self.nMapID] or {}
	local tbMapDeclareNum = tbBaseInfo.tbMapDeclareNum or {}
	local nDeclareNum = tbMapDeclareNum[self.nMapID] or 0

	local szBelongKin = tbKinInfo[2] and tbKinInfo[2] or "-" 					-- 待接入

	self.pPanel:Label_SetText("TerritoryName","领地名字：" ..szFieldName)
	self.pPanel:Label_SetText("TerritoryLevel","领地等级：" ..szDomainLevel)
	self.pPanel:Label_SetText("FamilyName","占据家族：" ..szBelongKin)
	self.pPanel:Label_SetText("TerritoryNumber","宣战家族数量：" ..nDeclareNum)
end

function tbTipUi:OnScreenClick()
    Ui:CloseWindow(self.UI_NAME);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
end

tbTipUi.tbOnClick = {};

function tbTipUi.tbOnClick:BtnDeclareWar()
	DomainBattle:DeclareWar(self.nMapID)
	Ui:CloseWindow(self.UI_NAME);
end
