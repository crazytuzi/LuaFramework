local tbUi = Ui:CreateClass("TerritorialWarPanel")

function tbUi:OnOpen()
	self:UpdateComon();
	self:UpdateMapKinPower()
	self:UpdateMyRank()
end

function tbUi:UpdateComon( )
	local tbSynComon = LingTuZhan:GetSynCommonData()
	local tbTime = os.date("*t", GetTime())
	self.pPanel:Label_SetText("TitleTxt", string.format("第%d轮领土战即时战报（%d年第%d季度）",tbSynComon.nOpenRound or 1,  tbTime.year, math.ceil(tbTime.month / 3) ))
end

function tbUi:UpdateMapKinPower( )
	local tbSynMapKinPower, tbAllKinName = LingTuZhan:GetMapKinPower()
	local nMapTemplateId = me.nMapTemplateId
	self.pPanel:Label_SetText("MapName", string.format("当前地图（%s）：",Map:GetMapName(nMapTemplateId)))

	local tbKinPower = tbSynMapKinPower[nMapTemplateId] or {};
	local tbSortKin = {};
	for k,v in pairs(tbKinPower) do
		table.insert(tbSortKin, k)
	end
	table.sort(tbSortKin, function ( a, b )
		return tbKinPower[a] > tbKinPower[b]
	end )
	local fnGetKinName = function ( szKinKey )
		local szKinName = tbAllKinName[szKinKey] or ""
		local nServerId = LingTuZhan:GetSplitKinKey(szKinKey)
		if nServerId then
			return  string.format("%s［%s］", szKinName, Sdk:GetServerDesc(nServerId))
		else
			return szKinName
		end
	end
	local fnSetItem1 = function ( itemObj, i )
		local szKinKey = tbSortKin[i]
		itemObj.pPanel:Label_SetText("NameTxt1" ,  fnGetKinName(szKinKey))
		itemObj.pPanel:Label_SetText("DominanceTxt1" , tbKinPower[szKinKey])
		itemObj.pPanel:Label_SetText("RankingTxt1" , i)
	end
	self.ScrollView1:Update(tbSortKin, fnSetItem1)

	local szMyKinKey = LingTuZhan:GetMyKinKey(  )
	local tbMyMapInfo = {}; -- nMapId, PowerRank, nPower

	for k1, v1 in pairs(tbSynMapKinPower) do
		if v1[szMyKinKey] then
			local fnSort = function ( a, b )
				return v1[a] > v1[b]
			end
			local tbSortKin = {}
			for k2,v2 in pairs(v1) do
				table.insert(tbSortKin, k2)
			end
			table.sort( tbSortKin, fnSort )
			local nRank = 0
			for i2,v2 in ipairs(tbSortKin) do
				if v2 == szMyKinKey then
					nRank = i2;
					break;
				end
			end
			table.insert(tbMyMapInfo, {k1, nRank, v1[szMyKinKey]})
		end
	end
	table.sort( tbMyMapInfo, function ( a, b )
		return a[2] < b[2]
	end )

	local fnSetItem2 = function ( itemObj, i )
		local nMapId,nRank,nPower = unpack(tbMyMapInfo[i])
		itemObj.pPanel:Label_SetText("OccupyTxt", nRank == 1 and "临时占领" or "")
		itemObj.pPanel:Label_SetText("NameTxt", Map:GetMapName(nMapId))
		itemObj.pPanel:Label_SetText("FamilyDominance", nPower)
		itemObj.pPanel:Label_SetText("RankBoardTxt", nRank)
		local tbMapSetting = LingTuZhan:GetMapSetting( nMapId )
		itemObj.pPanel:Label_SetText("StarClassTxt", tbMapSetting.nStar)
	end
	self.ScrollView2:Update(tbMyMapInfo, fnSetItem2)
end

function tbUi:UpdateMyRank(  )
	local tbMyInfo = LingTuZhan:GetMyFightRoleInfo()
	self.pPanel:Label_SetText("MeritoriousServiceTxt", string.format("积分：%d", tbMyInfo.nScore or 0 ))
	self.pPanel:Label_SetText("KillingTheEnemyTxt", string.format("杀敌数：%d", tbMyInfo.nKillCount or 0 ))
	self.pPanel:Label_SetText("MaximumDoubleHitTxt", string.format("最大连斩：%d", tbMyInfo.nMaxCombo or 0 ))
	self.pPanel:Label_SetText("CurrentDoubleHitTxt", string.format("当前连斩：%d", tbMyInfo.nCombo or 0 ))
	self.pPanel:SetActive("DestroyTxt", false)
end

function tbUi:OnSynData( szDataType )
    if szDataType == "Common" then
        self:UpdateComon()
    elseif szDataType == "MapKinPower" then
    	self:UpdateMapKinPower()
   	elseif szDataType == "MyRoleInfo" then
   		self:UpdateMyRank()
    end
end

function tbUi:RegisterEvent()
    return 
    {
        { UiNotify.emNOTIFY_LTZ_SYN_DATA, self.OnSynData, self },
    };
end

tbUi.tbOnClick = {};

function tbUi.tbOnClick:BtnClose(  )
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnRanking(  )
	Ui:OpenWindow("TerritorialWarAchievementPanel")
end