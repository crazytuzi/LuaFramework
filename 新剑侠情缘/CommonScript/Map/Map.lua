Map.CELL_WIDTH = 0.01;
Map.MiniMapScale = 4;
Map.MiniMapSize = 512;
Map.nShowPosScale = 1/200;

Map.tbMapList = Map.tbMapList or LoadTabFile("Setting/Map/maplist.tab", "dsssdsdddddddddsdddddsdddddsddddd", "TemplateId",
	{"TemplateId", "ResName","InfoFilePath", "MapName", "CameraDirAngle", "Class", "DefaultPosX", "DefaultPosY",
	"TeamForbidden", "TransForbidden", "IsRunSpeed", "MapLevel", "MapType", "SoundID", "SoundID1", "UiState",
	"NearbyChat", "ForcePkMode", "ForbidRide", "IsPerformance", "EffectSoundVolume", "LoadingTexture",
	"CamDistance", "CamLookDownAngle", "CamFOV", "Excercise", "FightState", "MiniMap", "FocusAllPet", "ForbidTransEnter", "ForbidPeeking", "UiTopButtonType","DelayDelete"});

Map.tbLoadingTexture = Map.tbLoadingTexture or LoadTabFile("Setting/Map/LoadingTexture.tab", "s", nil, {"szTexture"});
Map.tbMapNpcInfo = Map.tbMapNpcInfo or {};
Map.tbMapTextPosInfo = Map.tbMapTextPosInfo or {}
Map.tbMapExtraSetting = LoadTabFile("Setting/Map/MapExtraInfo.tab", "dss", "MapId", {"MapId", "ChatDisplay", "MiniMapDesc"});


Map.emMap_None			= 0;
Map.emMap_Public 		= 1;
Map.emMap_Fuben 		= 2;
Map.emMap_Public_Fuben 	= 3;

Map.PRISON_MAP_TEAMPLATE_ID = 703; -- 天牢地图Id
Map.MAIN_CITY_XIANYAN_TEAMPLATE_ID = 10; -- 主城-襄阳

Map.tbMapTimeFrame = {
	[406] = {szEnterFrame = "OpenLevel49",  szShowFrame = "OpenLevel39"};	--40级地图
	[407] = {szEnterFrame = "OpenLevel49",  szShowFrame = "OpenLevel39"};	--40级地图
	[408] = {szEnterFrame = "OpenLevel49",  szShowFrame = "OpenLevel39"};	--40级地图
	[410] = {szEnterFrame = "OpenLevel69",  szShowFrame = "OpenLevel59"};	--60级地图
	[411] = {szEnterFrame = "OpenLevel69",  szShowFrame = "OpenLevel59"};	--60级地图
	[412] = {szEnterFrame = "OpenLevel69",  szShowFrame = "OpenLevel59"};	--60级地图
	[413] = {szEnterFrame = "OpenLevel89",  szShowFrame = "OpenLevel79"};	--80级地图
	[414] = {szEnterFrame = "OpenLevel89",  szShowFrame = "OpenLevel79"};	--80级地图
	[415] = {szEnterFrame = "OpenLevel89",  szShowFrame = "OpenLevel79"};	--80级地图
	[416] = {szEnterFrame = "OpenLevel109", szShowFrame = "OpenLevel99"};	--100级地图
	[417] = {szEnterFrame = "OpenLevel109", szShowFrame = "OpenLevel99"};	--100级地图
	[418] = {szEnterFrame = "OpenLevel109", szShowFrame = "OpenLevel99"};	--100级地图
	[423] = {szEnterFrame = "OpenLevel129", szShowFrame = "OpenLevel119"};	--120级地图
	[424] = {szEnterFrame = "OpenLevel129", szShowFrame = "OpenLevel119"};	--120级地图
	[426] = {szEnterFrame = "OpenLevel149", szShowFrame = "OpenLevel139"};	--140级地图
	[427] = {szEnterFrame = "OpenLevel149", szShowFrame = "OpenLevel139"};	--140级地图
	[429] = {szEnterFrame = "OpenLevel169", szShowFrame = "OpenLevel159"};	--160级地图
	[430] = {szEnterFrame = "OpenLevel169", szShowFrame = "OpenLevel159"};	--160级地图
	[431] = {szEnterFrame = "OpenLevel189", szShowFrame = "OpenLevel179"};	--180级地图
	[432] = {szEnterFrame = "OpenLevel189", szShowFrame = "OpenLevel179"};	--180级地图
	[433] = {szEnterFrame = "OpenDay720", szShowFrame = "OpenDay720"};	--荣耀0级地图
	[419] = {szEnterFrame = "OpenLevel59",  szShowFrame = "OpenLevel49"};	--50级PVP地图
	[420] = {szEnterFrame = "OpenLevel79",  szShowFrame = "OpenLevel69"};	--70级PVP地图
	[421] = {szEnterFrame = "OpenLevel99",  szShowFrame = "OpenLevel89"};	--90级PVP地图
	[422] = {szEnterFrame = "OpenLevel119", szShowFrame = "OpenLevel109"};	--110级PVP地图
	[425] = {szEnterFrame = "OpenLevel139", szShowFrame = "OpenLevel129"};	--130级PVP地图
	[428] = {szEnterFrame = "OpenLevel159", szShowFrame = "OpenLevel149"};	--150级PVP地图
	--[15] = "OpenDay720";	--暂不开启临安
};

Map.tbPublicMapDesc = {
	[999] = "忘忧岛";
	[400] = "锁云渊-10级";
	[401] = "武夷山-10级";
	[402] = "雁荡山-10级";
	[403] = "洞庭湖畔-20级";
	[404] = "苗岭-20级";
	[405] = "点苍山-20级";
	[10] =  "襄阳";
	[15] =  "临安";
	[406] = "响水洞-40级";
	[407] = "见性峰-40级";
	[408] = "剑门关-40级";
	[409] = "夜郎废墟-30级";
	[410] = "荐菊洞-60级";
	[411] = "伏牛山-60级";
	[412] = "古战场-60级";
	[413] = "祁连山-80级";
	[414] = "沙漠遗迹-80级";
	[415] = "敦煌古城-80级";
	[416] = "药王谷-100级";
	[417] = "漠北草原-100级";
	[418] = "长白山-100级";
	[419] = "风陵渡-50级";
	[420] = "太行古径-70级";
	[421] = "昆虚脉藏-90级";
	[422] = "残桓铁城-110";
	[423] = "居延泽-120";	--120级地图
	[424] = "西夏皇陵-120";	--120级地图
	[425] = "龙门客栈-130";
	[426] = "蓬丘岱屿-140";
	[427] = "雾凇雪岭-140";
	[428] = "居庸关-150";
	[429] = "茶马商道-160";
	[430] = "震泽渡口-160";
	[431] = "朔北雪原-180";
	[432] = "楼兰古国-180";
	[433] = "蓬莱-200";
};

-- 某阶段地图可切换的背景音乐
Map.WEDDING_TOUR = 1 							-- 花轿游城阶段
Map.WEDDING_TOUR_AFTER = 2 						-- 花轿游城氛围阶段
Map.tbExtraSoundSetting = Map.tbExtraSoundSetting or {}
Map.tbExtraSound = Map.tbExtraSound or {}
Map.tbMapNpcByNpcId = Map.tbMapNpcByNpcId or {};

-- 障碍的类型
Map.emBrushType_None = 0
Map.emBrushType_Trap = 1
Map.emBrushType_Npc = 2
Map.emBrushType_DynamicObs = 200
Map.emBrushType_Barrier_Jump = 254
Map.emBrushType_Barrier = 255

function Map:InitSetting()
	-- 音乐配置
	Map.tbExtraSoundSetting =
	{
		[Wedding.nTourMapTemplateId] = { 									-- 襄阳(每个地图可能不同阶段需要播放不同的音乐，nPriority为播放优先级)
			[Map.WEDDING_TOUR] = {nSoundId = 1002, nPriority = 2}; 			-- 游城阶段
			[Map.WEDDING_TOUR_AFTER] = {nSoundId = 1001, nPriority = 1};    -- 游城之后阶段
		};
	}
end

local MAX_WAIYI_PATH_COUNT = 5;
function Map:LoadWaiYi()
	local tbTitle = {"MapId", "PosType", "WaiYiId"};
	local szType = "ddd";

	for i = 1, MAX_WAIYI_PATH_COUNT do
		table.insert(tbTitle, "Path" .. i);
		table.insert(tbTitle, "Idx" .. i);
		table.insert(tbTitle, "Material" .. i);
		szType = szType .. "sds";
	end

	self.tbMapWaiYiSetting = {};
	local tbFile = LoadTabFile("Setting/Map/MapWaiYi.tab", szType, nil, tbTitle);

	for _, tbRow in pairs(tbFile) do
		self.tbMapWaiYiSetting[tbRow.MapId] = self.tbMapWaiYiSetting[tbRow.MapId] or {};
		self.tbMapWaiYiSetting[tbRow.MapId][tbRow.PosType] = self.tbMapWaiYiSetting[tbRow.MapId][tbRow.PosType] or {};
		self.tbMapWaiYiSetting[tbRow.MapId][tbRow.PosType][tbRow.WaiYiId] = {};

		local tbWaiYiInfo = self.tbMapWaiYiSetting[tbRow.MapId][tbRow.PosType][tbRow.WaiYiId];
		for i = 1, MAX_WAIYI_PATH_COUNT do
			local szPath = tbRow["Path" .. i];
			local nIdx = tbRow["Idx" .. i];
			local szMaterial = tbRow["Material" .. i];
			if szPath and szPath ~= "" then
				tbWaiYiInfo[szPath] = tbWaiYiInfo[szPath] or {};
				tbWaiYiInfo[szPath][nIdx] = szMaterial;
			end
		end
	end

	for nMapId, tbInfo in pairs(self.tbMapWaiYiSetting) do
		for nPosType, tbWaiYiSetting in pairs(tbInfo) do
			assert(tbWaiYiSetting[0], string.format("has no map waiyi default setting %s, %s", nMapId, nPosType));
			for szPath, tbW in pairs(tbWaiYiSetting[0]) do
				for nWaiYiId, tbWaiYi in pairs(tbWaiYiSetting) do
					tbWaiYi[szPath] = tbWaiYi[szPath] or {};
					for nIdx, szMaterial in pairs(tbW) do
						tbWaiYi[szPath][nIdx] = tbWaiYi[szPath][nIdx] or szMaterial;
					end
				end
			end

			for nWaiYiId, tbWaiYi in pairs(tbWaiYiSetting) do
				for szPath, tbWW in pairs(tbWaiYi) do
					for nIdx in pairs(tbWW) do
						if not tbWaiYiSetting[0][szPath] or not tbWaiYiSetting[0][szPath][nIdx] then
							Log(string.format("waiyi default setting error ?? %s, %s, %s, %s", nMapId, nPosType, nWaiYiId, nIdx));
						end
					end
				end
			end
		end
	end
end
Map:LoadWaiYi();

function Map:SetMapWaiYiInfo(nPosType, nWaiYiId, nMapId)
	if not nPosType or not nMapId then
		return;
	end

	local nMapTemplateId = nMapId;
	if not MODULE_GAMECLIENT then
		nMapTemplateId = GetMapInfoById(nMapId);
	end

	if not self.tbMapWaiYiSetting or not self.tbMapWaiYiSetting[nMapTemplateId] then
		return;
	end

	if nWaiYiId and nWaiYiId == 0 then
		nWaiYiId = nil;
	end

	self.tbAllMapWaiYiInfo = self.tbAllMapWaiYiInfo or {};
	self.tbAllMapWaiYiInfo[nMapId] = self.tbAllMapWaiYiInfo[nMapId] or {};
	self.tbAllMapWaiYiInfo[nMapId][nPosType] = nWaiYiId;
	if Lib:CountTB(self.tbAllMapWaiYiInfo[nMapId]) == 0 then
		self.tbAllMapWaiYiInfo[nMapId] = nil;
	end

	if MODULE_GAMECLIENT then
		me.CallClientScript("Map:OnSyncSetWaiYiInfo", nMapId, nPosType, nWaiYiId);
	else
		KPlayer.MapBoardcastScriptByFuncName(nMapId, "Map:OnSyncSetWaiYiInfo", nMapId, nPosType, nWaiYiId);
	end
end

function Map:UpdateExtraSound(nMapTemplateId, tbSound, tbOverdueSound)
	local tbExtraSoundSetting = self:GetExtraSoundSetting(nMapTemplateId)
	if tbExtraSoundSetting and (next(tbSound or {}) or next(tbOverdueSound or {})) then
		local tbExtraSoundCache = self:GetExtraSoundCache(nMapTemplateId)
		for _, nSoundType in ipairs(tbSound) do
			local tbSoundSetting = tbExtraSoundSetting[nSoundType]
			if tbSoundSetting then
				tbSoundSetting.nSoundType = nSoundType
				tbExtraSoundCache[nSoundType] = tbSoundSetting
			end
		end
		for _, nSoundType in ipairs(tbOverdueSound) do
			tbExtraSoundCache[nSoundType] = nil
		end
	end
end

function Map:GetExtraSoundId(nMapTemplateId)
	local fnSort = function (a, b)
		return a.nPriority > b.nPriority
	end
	local tbExtraSoundCache = self:GetExtraSoundCache(nMapTemplateId)
	local tbTempSoundCache = {}
	for _, v in pairs(tbExtraSoundCache) do
		table.insert(tbTempSoundCache, v)
	end
	if #tbTempSoundCache > 1 then
		table.sort(tbTempSoundCache, fnSort)
	end
	return tbTempSoundCache[1] and {tbTempSoundCache[1].nSoundId}
end

function Map:GetExtraSoundSetting(nMapTemplateId)
	return Map.tbExtraSoundSetting[nMapTemplateId] and Lib:CopyTB(Map.tbExtraSoundSetting[nMapTemplateId])
end

function Map:GetExtraSoundCache(nMapTemplateId)
	Map.tbExtraSound[nMapTemplateId] = Map.tbExtraSound[nMapTemplateId] or {}
	return Map.tbExtraSound[nMapTemplateId]
end

function Map:GetMapDesc(nMapTemplateId)
	return self.tbPublicMapDesc[nMapTemplateId] or self:GetMapName(nMapTemplateId);
end

function Map:LoadTransmit()
	local tbResult = {};
	local tbSetting = Lib:LoadTabFile("Setting/Map/transmit.txt", {JumpKind = 1});
	for _, tbLineData in pairs(tbSetting or {}) do
		local nFromMapID = assert(tonumber(tbLineData.FromMapID));
		tbResult[nFromMapID] = tbResult[nFromMapID] or {};
		tbResult[nFromMapID][tbLineData.Name] = {
			FromPosX  = tonumber(tbLineData.FromPosX) or 0,
			FromPosY  = tonumber(tbLineData.FromPosY) or 0,
			ToMapID = assert(tonumber(tbLineData.ToMapID)),
			ToPosX  = assert(tonumber(tbLineData.ToPosX)),
			ToPosY  = assert(tonumber(tbLineData.ToPosY)),
			ToFightState = assert(tonumber(tbLineData.ToFightState)),
			JumpKind = tbLineData.JumpKind;
			JumpGroup = tbLineData.JumpGroup;
		};
	end

	self.tbTransferSetting = tbResult;
end

function Map:GetCameraSettings(nTemplateId)
	local tbSetting = self:GetMapSetting(nTemplateId)
	if not tbSetting then return end

	if tbSetting.CamDistance>0 and tbSetting.CamLookDownAngle~=0 and tbSetting.CamFOV>0 then
		return {
			nDistance = tbSetting.CamDistance,
			nLookDownAngle = tbSetting.CamLookDownAngle,
			nFov = tbSetting.CamFOV,
		}
	end
	return nil
end

function Map:GetMapSetting(nTemplateId)
	return Map.tbMapList[nTemplateId];
end

function Map:GetForcePkMode(nTemplateId)
	local tbMapSetting = Map:GetMapSetting(nTemplateId)
	return tbMapSetting.ForcePkMode
end

function Map:GetEnterLevel(nTemplateId)
	local tbMapSetting = Map:GetMapSetting(nTemplateId);
	return tbMapSetting.MapLevel;
end

function Map:IsTimeFrameOpen(nTemplateId)
	local tbFrameInfo = Map.tbMapTimeFrame[nTemplateId];
	if not tbFrameInfo then
		return true, true;
	end

	return GetTimeFrameState(tbFrameInfo.szEnterFrame) == 1, GetTimeFrameState(tbFrameInfo.szShowFrame) == 1;
end

function Map:GetMapName(nTemplateId)
	local tbMapSetting = Map:GetMapSetting(nTemplateId);
	return tbMapSetting.MapName;
end

function Map:GetMapResName(nTemplateId)
	local tbMapSetting = Map:GetMapSetting(nTemplateId)
	return tbMapSetting.ResName
end

function Map:GetMapDescInChat(nTemplateId)
	local tbInfo = Map.tbMapExtraSetting[nTemplateId] or {};
	if Lib:IsEmptyStr(tbInfo.ChatDisplay) then
		return Map:GetMapName(nTemplateId);
	end

	return tbInfo.ChatDisplay;
end

function Map:GetMiniMapDesc(nTemplateId)
	local tbInfo = Map.tbMapExtraSetting[nTemplateId] or {};
	return tbInfo.MiniMapDesc;
end

function Map:GetMapType(nTemplateId)
	local tbMapSetting = Map:GetMapSetting(nTemplateId) or {};
	return tbMapSetting.MapType or Map.emMap_None;
end

function Map:GetMapUiState(nTemplateId)
	local tbMapSetting = Map:GetMapSetting(nTemplateId) or {};
	if not tbMapSetting.tbUiState then
		tbMapSetting.tbUiState = {0, true};
		local nState, szType = string.match(tbMapSetting.UiState, "^(%d+)|*([^|]*)$");
		tbMapSetting.tbUiState[1] = tonumber(nState or "nil") or 0;
		if szType and szType == "show" then
			tbMapSetting.tbUiState[2] = false;
		end
	end

	return unpack(tbMapSetting.tbUiState);
end

function Map:CanNearbyChat(nTemplateId)
	local tbMapSetting = Map:GetMapSetting(nTemplateId) or {};
	return tbMapSetting.NearbyChat == 1;
end

function Map:GetMapInfoPath(nTemplateId)
	local tbMapInfo = Map:GetMapSetting(nTemplateId);
	local szPath = tbMapInfo and "Setting/Map/" .. tbMapInfo.InfoFilePath .. "/npc_info.txt";
	return szPath;
end

function Map:GetMapTextPosInfoPath(nTemplateId)
	local tbMapInfo = Map:GetMapSetting(nTemplateId);
	local szPath = tbMapInfo and "Setting/Map/" .. tbMapInfo.InfoFilePath .. "/text_pos_info.tab";
	return szPath;
end

function Map:LoadMapNpcInfo(nMapTemplateId)
	local szPath = Map:GetMapInfoPath(nMapTemplateId);
	self.tbMapNpcInfo[nMapTemplateId] = LoadTabFile(szPath, "sdsdddddd", nil,
		{"Index", "NpcTemplateId", "NpcName", "CanAutoPath", "XPos", "YPos", "WalkNearLength", "TitleID", "HideTaskId"});

	self.tbMapNpcByNpcId[nMapTemplateId] = {};
	if self.tbMapNpcInfo[nMapTemplateId] then
		for _, tbRow in pairs(self.tbMapNpcInfo[nMapTemplateId]) do
			self.tbMapNpcByNpcId[nMapTemplateId][tbRow.NpcTemplateId] = self.tbMapNpcByNpcId[nMapTemplateId][tbRow.NpcTemplateId] or {};
			table.insert(self.tbMapNpcByNpcId[nMapTemplateId][tbRow.NpcTemplateId], tbRow)
		end
	end
end

function Map:GetMapNpcInfoByNpcTemplate(nMapTemplateId, nNpcTemplateId)
	if not Map:GetMapSetting(nMapTemplateId) then
		return;
	end

	if not self.tbMapNpcByNpcId[nMapTemplateId] then
		self:LoadMapNpcInfo(nMapTemplateId);
	end

	return self.tbMapNpcByNpcId[nMapTemplateId][nNpcTemplateId];
end

function Map:GetMapNpcInfo(nMapTemplateId)
	if not Map:GetMapSetting(nMapTemplateId) then
		return;
	end

	if not self.tbMapNpcInfo[nMapTemplateId] then
		self:LoadMapNpcInfo(nMapTemplateId);
	end

	return self.tbMapNpcInfo[nMapTemplateId];
end

function Map:LoadMapTextPosInfo(nMapTemplateId)
	local szPath = Map:GetMapTextPosInfoPath(nMapTemplateId);
	self.tbMapTextPosInfo[nMapTemplateId] = LoadTabFile(szPath, "sddssdd", nil,
		{"Index", "XPos", "YPos", "Text", "Color", "FontSize", "NotShow"}) or {};
end

function Map:GetMapTextPosInfo(nMapTemplateId)
	if not Map:GetMapSetting(nMapTemplateId) then
		return;
	end

	if not self.tbMapTextPosInfo[nMapTemplateId] then
		self:LoadMapTextPosInfo(nMapTemplateId);
	end

	return self.tbMapTextPosInfo[nMapTemplateId];
end

function Map:GetClassDesc(nTemplateId)
	local tbMapSetting = Map:GetMapSetting(nTemplateId);
	return tbMapSetting and tbMapSetting.Class or "";
end

function Map:GetSoundID(nTemplateId)
	local tbMapSetting = Map:GetMapSetting(nTemplateId);
	return {tbMapSetting.SoundID, tbMapSetting.SoundID1};
end

function Map:GetDefaultPos(nTemplateId)
	if MODULE_GAMESERVER then
		local _, nX, nY = PlayerEvent:GetRevivePos(nTemplateId);
		if nX and nY then
			return nX, nY;
		end
	end

	local tbMapSetting = Map:GetMapSetting(nTemplateId);
	return tbMapSetting.DefaultPosX, tbMapSetting.DefaultPosY, tbMapSetting.FightState;
end

function Map:IsRunSpeedMap(nTemplateId)
	local tbMapSetting = Map:GetMapSetting(nTemplateId);
	if tbMapSetting.IsRunSpeed ~= 1 then
		return false;
	end

	return true;
end

function Map:IsForbidRide(nTemplateId)
    local tbMapSetting = Map:GetMapSetting(nTemplateId);
	if tbMapSetting.ForbidRide ~= 1 then
		return false;
	end

	return true;
end

function Map:GetEffectSoundVolume(nTemplateId)
    local tbMapSetting = Map:GetMapSetting(nTemplateId);
    if not tbMapSetting then
    	return 0;
    end

	return tbMapSetting.EffectSoundVolume or 0;
end

function Map:IsPerformance(nTemplateId)
    local tbMapSetting = Map:GetMapSetting(nTemplateId);
	if tbMapSetting.IsPerformance ~= 1 then
		return false;
	end

	return true;
end

function Map:IsFocusAllPet(nTemplateId)
	if WuLinDaHui:IsInMap(nTemplateId) then
		return WuLinDaHui:CanOperateParnter()
	end
    local tbMapSetting = Map:GetMapSetting(nTemplateId);
	if tbMapSetting.FocusAllPet ~= 1 then
		return false;
	end
	return true;
end

function Map:IsForbidTransEnter(nTemplateId)
    local tbMapSetting = Map:GetMapSetting(nTemplateId);
	if tbMapSetting.ForbidTransEnter ~= 1 then
		return false;
	end

	return true;
end

function Map:IsForbidPeeking(nTemplateId)
	local tbMapSetting = Map:GetMapSetting(nTemplateId);
	if tbMapSetting.ForbidPeeking ~= 1 then
		return false;
	end

	return true;
end

function Map:IsFieldFightMap(nTemplateId)
	local szClass = Map:GetClassDesc(nTemplateId);
	if szClass ~= "fight" then
		return false;
	end

	return true;
end

function Map:IsBossMap(nTemplateId)
	local szClass = Map:GetClassDesc(nTemplateId);
	if szClass ~= "boss" then
		return false;
	end

	return true;
end

function Map:IsBattleMap(nTemplateId)
	local szClass = Map:GetClassDesc(nTemplateId);
	return szClass == "battle";
end

function Map:IsKinMap(nTemplateId)
	local szClass = Map:GetClassDesc(nTemplateId);
	return szClass == "kin";
end

function Map:IsCityMap(nTemplateId)
	local szClass = Map:GetClassDesc(nTemplateId);
	return szClass == "city";
end

function Map:IsHouseMap(nTemplateId)
	local szClass = Map:GetClassDesc(nTemplateId);
	return szClass == "house";
end

function Map:IsTransForbid(nTemplateId)
	local tbMapSetting = Map:GetMapSetting(nTemplateId);
	return tbMapSetting.TransForbidden > 0
end

local tbHomeMiniMapScale = {
	battle = 0.5;
}

-- 各主界面地图的缩放特殊需求
function Map:GetMapScale(nTemplateId, bHomeMiniMap)
	local nScale = 1;
	local szClass = Map:GetClassDesc(nTemplateId);
	if tbHomeMiniMapScale[szClass] then
		nScale = nScale * tbHomeMiniMapScale[szClass];
	end

	return nScale;
end

local tbMapOrgScale = {
	["cj_xinshoucun02"] = 1.255;
	["fb_rongyan04"]  = 0.8;
	["fb_rongyan05"]  = 0.8;
	["fb_rongyan07"]  = 0.8;
	["yw_luoyegu"]    = 0.8;
	--["fb_tianjifang"] = 0.8;
	["yw_xuedi01"] = 0.64;
	["yw_xuedi02"] = 0.64;
	["yewai_01"] = 0.64;
	["yewai_02"] = 0.8;
	["yw_zhulin01"] = 0.64;
	["yw_zhulin02"] = 0.64;
	--["fb_xuedi06"] = 0.8;
	["yw_xiangshuidong"] = 0.64;
	["yw_wuyishan01"] = 0.64;
	["yw_yelangfeixu01"] = 0.64;
	["yw_jianmenguan"] = 0.64;
	["baihutang01"] = 0.64;
	["jj_menpaijingji01"] = 0.8;
	["jiazhushilian01"] = 0.7;
	["zc_zhanchang"] = 0.6;
	--["cj_luoyang01"] = 0.57;
	["yw_jianmenguan2"] = 0.6;
	["yw_jianjudong"] = 0.64;
	["zc_lingtuzhan01"] = 0.6;
	["zc_lingtuzhan02"] = 0.64;
	["yw_fenglingdu"] = 0.64;
	["zc_zhanchang03"] = 0.6;
	["yw_dunhuanggucheng01"] = 0.6;
	["yw_qilianshan"] = 0.6;
	["yw_shamomigong"] = 0.6;
	["yw_taihanggujing01"] = 0.6;
	["jj_zhuduileitai01"] = 0.8;
	["q_qinshi01"] = 0.64;
	["q_qinshi02"] = 0.8;
	--["hs_shashanlunjian01"] = 0.8;
	--["q_shinei01"] = 0.64;
	--["q_shinei02"] = 0.8;
	--["q_shinei03"] = 0.8;
	--["q_shinei04"] = 0.8;
	["fb_huxiaozhandao01"] = 0.71;
	["yw_mobeicaoyuan"] = 0.5;
	["yw_changbaishan"] = 0.53;
	["yw_yaowanggu"] = 0.64;
	["yw_shunanzhuhai"] = 0.64;
	["cj_linan01"] = 0.64;
	["lt_yewai_01"] = 0.64,
	["lt_yw_zhulin02"] = 0.64,
	["lt_yw_xuedi02"] = 0.64,
	["lt_yw_xiangshuidong"]	= 0.64,
	["lt_yw_xuedi01"] = 0.64,
	["lt_yw_jianmenguan2"] =  0.6,
	["lt_yw_jianjudong"] = 0.64,
	["lt_yw_jianmenguan"] = 0.64,
	["jj_wulindahui02"] = 0.64,
	["yw_canhuantiecheng"] = 0.6,
	["zc_zhanchang04"] = 0.56,
	--["nd_nvdiyizhong01"] = 0.56,
	--["nd_nvdiyizhong02"] = 0.9,
	["yw_juyanze"] = 0.64,
	["yw_xixiahuangling"] = 0.64,
	["fb_baishuisi01"] = 0.674;
	--["fb_canghai02"] = 1.39;
	["yw_mobeicaoyuan_01"] = 0.5;
	["zc_kuafuzhan01"] = 0.32;
	["yw_shamokezhan01"] = 0.64;
	["jiazhumijing01"] = 0.71;
	["jj_wuchabie02"] = 0.32,

	--以下为新地图调整，重点测试---
	["mijing_e_05"] = 1.78,
	["fb_zhulin02"] = 2.28,
	["fb_canghai02"] = 1.68,
	["nd_nvdiyizhong02"] = 1.88,
	["fb_erengu03"] = 2,
	["fb_zhulin05"] = 1.68,
	["fb_luoyegu02"] = 1.83,
	["baihutang02"] = 1.68,
	["q_shinei04"] = 1.78,
	["q_shinei02"] = 1.78,
	["fb_erengu02"] = 1.78,
	["fb_erengu05"] = 1.73,
	["fb_xuedi01"] = 1.73,
	["fb_erengu07"] = 1.68,
	["fb_luoyegu01"] = 1.68,
	["fb_luoyegu04"] = 1.64,
	["fb_luoyegu06"] = 1.6,
	["fb_luoyegu05"] = 1.6,
	["mijing_c_02"] = 1.6,
	["q_shinei03"] = 1.56,
	["q_shinei01"] = 1.56,
	["fb_canghai04"] = 1.49,
	["fb_erengu"] = 1.49,
	["yw_canghai2"] = 1.16,
	["fb_xuedi03"] = 1.45,
	["fb_canghai06"] = 1.45,
	["fb_canghai05"] = 1.45,
	["fb_erengu06"] = 1.45,
	["tongtianta_zhunbei01"] = 1.28,
	["fb_cangjian"] = 1.28,
	["fb_tianjifang"] = 1.33,
	--["fb_digong03"] = 1,
	--["fb_zhandao01"] = 1.16,
	["fb_xuedi06"] = 1,
	["fb_digong05"] = 1,
	["cj_luoyang01"] = 0.73,
	["nd_nvdiyizhong01"] = 0.56,
	["sn_jiayuan01_childmap1"] = 2.32,
	["sn_jiayuan02_childmap1"] = 2.32,
	["sn_jiayuan03_childmap1"] = 2.32,
	["sn_jiayuan04_childmap1"] = 2.32,
	["sn_jiayuan05_childmap1"] = 2.32,
	["sn_jiayuan06_childmap1"] = 2.32,
	["sn_jiayuan07_childmap1"] = 1.6,
	--["sn_jiayuan04_childmap2"] = 0.9,
	["sn_jiayuan07_childmap2"] = 0.97,
	---以上为新地图资源调整-------

	["zc_lingtuzhan03"] = 64/95,
	["taohuamizhen01"] = 64/90,
	["taohuamizhen02"] = 64/80,
	["taohuamizhen03"] = 64/43,
	["jiazuPK_01"] = 0.49,
	["yw_pengqiudaiyu01"] = 64/80,
	["yw_wusongxueling"] = 64/93,
	["jiazhumijing02"] = 64/67,
	["yw_juyongguan"] = 64/90,
	["zc_lingtuzhan04"] = 64/61,
	["zc_lingtuzhan05"] = 64/75,
	["zc_lingtuzhan06"] = 64/125,
	["hd_changbaizhidian01"] = 64/70,
	["jz_fokuzhizhan01"] = 64/80,
	["jz_fokuzhizhan02"] = 64/100,
	["yw_zangqu"] = 64/85,
	["yw_jiangnan"] = 64/90,
	["yw_shuobeixueyuan"] = 64/85,
	["yw_loulanguguo"] = 64/85,
	["hd_damodong"] = 64/95,
	["hd_damodong01"] = 64/60,
	["yw_penglai"] = 64/85,
};

-- 获取地图的原始缩放比例
function Map:GetMapOrgScale(szMiniMap)
	local nScale = Map.MiniMapScale;
	if tbMapOrgScale[szMiniMap] then
		nScale = nScale * tbMapOrgScale[szMiniMap];
	end
	return nScale;
end


-- 小地图替换 对应关系表
local tbMiniMapReplaceTabel = {
	[202] = 201;
	[204] = 201;
	[206] = 201;
	[207] = 201;
	[208] = 201;
	[210] = 201;
	[213] = 201;
	[214] = 201;
	[218] = 201;
	[220] = 201;
	[221] = 201;
	[223] = 201;
	[224] = 201;
	[225] = 201;
	[227] = 201;
	[228] = 201;
	[231] = 201;
	[233] = 201;
	[234] = 201;
	[235] = 201;
	[238] = 201;
	[239] = 201;
	[241] = 201;
	[242] = 201;
	[243] = 201;
	[244] = 201;
	[245] = 201;
	[246] = 201;
	[249] = 201;
};

function Map:GetMiniMapInfo(nTemplateId)
	nTemplateId = tbMiniMapReplaceTabel[nTemplateId] or nTemplateId;

	local tbMapSetting = Map:GetMapSetting(nTemplateId);
	local szMiniMap = tbMapSetting.MiniMap == "" and tbMapSetting.ResName or tbMapSetting.MiniMap;
	local szSettingPath = "Setting/Map/" .. tbMapSetting.InfoFilePath .. "/info.ini";
	local tbIniSetting = Lib:LoadIniFile(szSettingPath);
	local tbMiniMapSetting = tbIniSetting.Setting;
	for szKey, szValue in pairs(tbMiniMapSetting) do
		tbMiniMapSetting[szKey] = tonumber(szValue);
	end

	local tbChildMapSetting = nil;
	if tbMiniMapSetting.ChildMapCount and tbMiniMapSetting.ChildMapCount > 0 then
		tbChildMapSetting = {};
		for i = 1, tbMiniMapSetting.ChildMapCount do
			local tbChildSetting = tbIniSetting["ChildMap_" .. i];
			assert(tbChildSetting, "unknown child map: " .. nTemplateId .. "*" .. i);
			for szKey, szValue in pairs(tbChildSetting) do
				tbChildSetting[szKey] = tonumber(szValue);
			end

			table.insert(tbChildMapSetting, { szMiniMap = string.format("%s_childmap%d", szMiniMap, i), tbSetting = tbChildSetting });
		end
	end

	return tbMiniMapSetting, szMiniMap, tbChildMapSetting;
end

function Map:CheckCanLeave(nTemplateId)
	if not self.tbSafeMap then
		self.tbSafeMap = {
			[QunYingHui.tbDefInfo.nPrepareTempMapID] = 1,
			[Battle.READY_MAP_ID] = 1,
			[Battle.ZONE_READY_MAP_ID] = 1,
			[InDifferBattle.tbDefine.nReadyMapTemplateId] = 1,
			[KinBattle.PRE_MAP_ID] = 1,
			[TeamBattle.PRE_MAP_ID] = 1,
			[TeamBattle.TOP_MAP_ID] = 1,
			[FactionBattle.PREPARE_MAP_TAMPLATE_ID] = 1,
			[FactionBattle.FREEPK_MAP_TAMPLATE_ID] = 1,
			[Fuben.WhiteTigerFuben.PREPARE_MAPID] = 1,
			[BiWuZhaoQin.nPreMapTID] = 1,
			[ChangBaiZhiDian.Def.nReadyMapTID] = 1,
		}
	end
	return nTemplateId and self.tbSafeMap[nTemplateId]
end

function Map:GetLoadingTexture(bRandom)
	if bRandom then
		self.nLoadingTextureIdx = MathRandom(#self.tbLoadingTexture);
	end

	return (self.tbLoadingTexture[self.nLoadingTextureIdx or 0] or {}).szTexture or "UI/Textures/Loading.jpg";
end

function Map:CheckEnterOtherMap(pPlayer)
    if not Fuben.tbSafeMap[pPlayer.nMapTemplateId] and Map:GetClassDesc(pPlayer.nMapTemplateId) ~= "fight" then
		return false, "所在地图不允许进入！";
	end

	if pPlayer.nFightMode ~= 0 then
		return false, "不在安全区，不允许进入！";
	end

	local bRet = Map:IsForbidTransEnter(pPlayer.nMapTemplateId);
	if bRet then
		return false, "目标地图无法传送!";
	end

	if not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
        return false, "当前状态不允许切换地图"
    end

	return true, "";
end

function Map:GetDesTransTrap(nFromId, nToId)
	local tbList = {}
	for nFromMapId, tbTrapList in pairs(self.tbTransferSetting) do
		if nFromId == nFromMapId then
			for szTrapName,tbTrapInfo in pairs(tbTrapList) do
				if nToId == tbTrapInfo.ToMapID then
					table.insert(tbList,
						{
							nFromMapId = nFromMapId,
							szTrapName = szTrapName,
							nFromX = tbTrapInfo.FromPosX,
							nFromY = tbTrapInfo.FromPosY,
							nToMapId = nToId,
							nToX = tbTrapInfo.ToPosX,
							nToY = tbTrapInfo.ToPosY,
						})
				end
			end
		end
	end
	return tbList;
end

function Map:GetNearestTransTrap(nFromId, nFromX, nFromY, nToId, nX, nY)
	local tbList = self:GetDesTransTrap(nFromId, nToId)
	if #tbList <= 0 then
		return nil
	end

	local nLen = nil
	local tbTrapInfo = nil

	for _,tbInfo in pairs(tbList) do
		local nDistance = 0;
		if nX and nY then
			nDistance = nDistance + Lib:GetDistance(nX, nY, tbInfo.nToX, tbInfo.nToY)
		end

		if nFromX and nFromY then
			nDistance = nDistance + Lib:GetDistance(nFromX, nFromY, tbInfo.nFromX, tbInfo.nFromY)
		end

		if not nLen or  nDistance < nLen then
			nLen = nDistance
			tbTrapInfo = tbInfo
		end
	end

	return tbTrapInfo, nLen
end

function Map:SetMapNpcInfoCanAutoPath(nMapTemplateId, szInfoIndex, nCanAutoPath)
	if not self.tbMapNpcInfo[nMapTemplateId] then
		self:LoadMapNpcInfo(nMapTemplateId);
	end

	if not self.tbMapNpcInfo[nMapTemplateId] then
		return
	end

	for _, tbRow in pairs(self.tbMapNpcInfo[nMapTemplateId]) do
		if tbRow.Index == szInfoIndex then
			tbRow.CanAutoPath = nCanAutoPath
		end
	end
end

function Map:SetMapTextPosInfoNotShow(nMapTemplateId, szInfoIndex, nNotShow)
	if not self.tbMapTextPosInfo[nMapTemplateId] then
		self:LoadMapTextPosInfo(nMapTemplateId);
	end

	if not self.tbMapTextPosInfo[nMapTemplateId] then
		return
	end

	for _, tbRow in pairs(self.tbMapTextPosInfo[nMapTemplateId]) do
		if tbRow.Index == szInfoIndex then
			tbRow.NotShow = nNotShow
		end
	end
end

function Map:SetMapTextPosInfoColor(nMapTemplateId, szInfoIndex, szColor)
	if not self.tbMapTextPosInfo[nMapTemplateId] then
		self:LoadMapTextPosInfo(nMapTemplateId);
	end

	if not self.tbMapTextPosInfo[nMapTemplateId] then
		return
	end

	for _, tbRow in pairs(self.tbMapTextPosInfo[nMapTemplateId]) do
		if tbRow.Index == szInfoIndex then
			tbRow.Color = szColor
		end
	end
end

Map:LoadTransmit();
