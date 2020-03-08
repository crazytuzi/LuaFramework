local tbUi = Ui:CreateClass("NewInfo_TerritorialWarPresentation")

function tbUi:OnOpen(tbData)
	local _tbOldAllKinOwnMap, _tbNewAllKinOwnMap, tbAllKinName,nOpenRound = unpack(tbData)
	self.pPanel:Label_SetText("Details2", string.format("第[FFFE0D]%d[-]轮领土战战报",nOpenRound) )
	local tbOldAllKinOwnMap, tbNewAllKinOwnMap = {},{};
	local tbCityMapId = {};
	for k,v in pairs(LingTuZhan.define.tbMapSeting) do
		if v.nType == LingTuZhan.tbConst.MAP_TYPE_CITY then
			tbCityMapId[k] = 1;
		end
	end
	for k,v in pairs(_tbOldAllKinOwnMap) do
		tbOldAllKinOwnMap[k] = {};
		for k2,v2 in pairs(v) do
			table.insert(tbOldAllKinOwnMap[k], k2)
		end
	end
	local fnGetKinName = function ( szKinKey )
		local szKinName = tbAllKinName[szKinKey] or ""
		local nServerId = LingTuZhan:GetSplitKinKey(szKinKey)
		return  string.format("%s［%s］", szKinName, Sdk:GetServerDesc(nServerId))
	end
	local tbKinAllStar = {};
	for k,v in pairs(_tbNewAllKinOwnMap) do
		tbNewAllKinOwnMap[k] = {};
		local nToTalStar = 0;
		for k2,v2 in pairs(v) do
			table.insert(tbNewAllKinOwnMap[k], k2)
			if tbCityMapId[k2] then
				tbCityMapId[k2] = k;
			end
			local nStar = LingTuZhan.define.tbMapSeting[k2].nStar
			nToTalStar = nToTalStar + nStar
		end
		tbKinAllStar[k] = nToTalStar
	end

	local tbSortKin = {};
	for k,v in pairs(tbNewAllKinOwnMap) do
		table.insert(tbSortKin, k)
	end
	table.sort( tbSortKin, function (a, b)
		return tbKinAllStar[a] > tbKinAllStar[b]
	end )

	local nCurRank = 1
	local nLastStar = -1;
	local tbKinRealRank = {}
	for i,szKinKey in ipairs(tbSortKin) do
		local nCurStar = tbKinAllStar[szKinKey]
		if nCurStar ~= nLastStar then
			nLastStar = nCurStar
			nCurRank = i;
		end
		tbKinRealRank[szKinKey] = nCurRank
	end

	local fnSetItem1 = function ( itemObj, index )
		local szKinKey = tbSortKin[index]
		itemObj.pPanel:Label_SetText("Number", string.format("第%s名：", Lib:Transfer4LenDigit2CnNum(tbKinRealRank[szKinKey])) )
		itemObj.pPanel:Label_SetText("FamilyName",  fnGetKinName(szKinKey))
		itemObj.pPanel:Label_SetText("LeaderName",  string.format("占有%d块土地（%d星）",#tbNewAllKinOwnMap[szKinKey], tbKinAllStar[szKinKey]))
	end
	self.ScrollView1:Update(tbSortKin , fnSetItem1)	

	local tbKinAddMaps = {};
	for k,v in pairs(tbNewAllKinOwnMap) do
		local vOld = tbOldAllKinOwnMap[k] or {};
		tbKinAddMaps[k] = #v - #vOld
	end
	local tbSortKin2 = Lib:CopyTB(tbSortKin)
	table.sort( tbSortKin2, function ( a, b )
		return tbKinAddMaps[a] > tbKinAddMaps[b]
	end )
	local fnSetItem2 = function ( itemObj, index )
		local szKinKey = tbSortKin2[index]
		local nNum = tbKinAddMaps[szKinKey]
		itemObj.pPanel:Label_SetText("FamilyTxt", string.format("%s——扩展了%d块土地", fnGetKinName(szKinKey), nNum))
	end
	self.ScrollView2:Update(tbSortKin2, fnSetItem2)
	
	local tbCityMapIdList = {}
	for k,v in pairs(tbCityMapId) do
		table.insert(tbCityMapIdList, k)
	end
	for i=1,2 do
		local nMapId = tbCityMapIdList[i]
		local szKinKey = tbCityMapId[nMapId]
		if szKinKey == 1 then
			self.pPanel:Label_SetText("CityGroupTxt" .. i,string.format("%s——无人占领", Map:GetMapName(nMapId)))	
		else
			self.pPanel:Label_SetText("CityGroupTxt" .. i,string.format("%s——被%s占领", Map:GetMapName(nMapId), fnGetKinName(szKinKey) ))	
		end
	end

end