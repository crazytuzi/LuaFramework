local tbUi = Ui:CreateClass("WorldMap");

local tbWorldMapSetting = {
	Birthplace = {1000};   -- MapTemplateId, Sprite
	yewai_10_1 = {400};    -- 锁云渊(zhulin01)
	yewai_10_2 = {401};    -- 武夷山(wuyishan01)
	yewai_10_3 = {402};    -- 雁荡山(yewai02)
	yewai_20_1 = {403};    -- 点苍山(xuedi01)
	yewai_20_2 = {404};    -- 苗岭(zhulin02)
	yewai_20_3 = {405};    -- 洞庭湖畔(yewai01)
	City	   = {10};     -- 主城-襄阳
	City2	   = {15};     -- 主城-临安
	yewai_40_1= {406};     -- 响水洞()
	yewai_40_2 = {407};    -- 见性峰(xuedi02)
	yewai_40_3 = {408};    -- 剑门关()
	yewai_40_pvp = {409};  -- 夜郎废墟PVP
	yewai_50_pvp = {419};  -- 风陵渡PVP
	yewai_70_pvp = {420};  -- 太行古径PVP
	yewai_60_1 = {410};	   -- 荐菊洞()
	yewai_60_2 = {411};    -- 伏牛山()
	yewai_60_3 = {412};    -- 古战场()
	yewai_80_1 = {413};    -- 祁连山()
	yewai_80_2 = {414};    -- 沙漠遗迹()
	yewai_80_3 = {415};    -- 敦煌古城()
	yewai_100_1 = {416};   -- 药王谷()
	yewai_100_2 = {417};   -- 漠北草原()
	yewai_100_3 = {418};   -- 长白山()
	yewai_90_pvp = {421};  -- 蜀南竹海PVP
	yewai_110_pvp = {422};  -- 残桓铁城PVP
	yewai_120_1 = {423};  -- 居延泽
	yewai_120_2 = {424};  -- 西夏皇陵
	yewai_130_pvp = {425};  -- 龙门客栈PVP
	yewai_140_1 = {427};  -- 雾凇雪岭
	yewai_140_2 = {426};  -- 蓬丘岱屿
	yewai_150_pvp = {428};  -- 居庸关
	yewai_160_1 = {429};  -- 茶马商道
	yewai_160_2 = {430};  -- 震泽渡口
	yewai_180_2 = {431};  -- 朔北雪原
	yewai_180_1 = {432};  -- 楼兰古国
	haidao_1 = {433};  -- 蓬莱
}

tbUi.SWITCHMAPTIME = 0.7;                                   --播完云动画0.7秒再切地图
tbUi.ISLANDOPENDAY = "OpenDay720";
tbUi.LAND = 1;
tbUi.HAIDAO = 2;

function tbUi:OnOpen()
	for key, tbInfo in pairs(tbWorldMapSetting) do
		local nMapTemplateId = tbInfo[1];
		local bTimeOpen, bTimeShow = Map:IsTimeFrameOpen(nMapTemplateId);
		local nMapLevel = Map:GetEnterLevel(nMapTemplateId);

		self.pPanel:SetActive(key, bTimeShow);
		if bTimeShow then
			self[key].pPanel:SetActive("CurrentLocation", (me.nMapTemplateId == nMapTemplateId));
			self[key].pPanel:SetActive("NotOpen", me.nLevel < nMapLevel or not bTimeOpen);
			self[key].pPanel:Button_SetText("Main", Map:GetMapDesc(nMapTemplateId));
		end
	end
end

tbUi.tbOnClick = {};

function tbUi.tbOnClick:BtnClose()
	Guide.tbNotifyGuide:ClearNotifyGuide("WorldMap");
	Ui:CloseWindow("WorldMap");
end

function tbUi.tbOnClick:WorldMapBg()
	Guide.tbNotifyGuide:ClearNotifyGuide("WorldMap");
end

function tbUi:CloseWithoutAni()
	Ui:CloseWindowAni("WorldMap", false);
end

local fnTouchItem = function (panel, szBtnName)
	local nMapTemplateId = tbWorldMapSetting[szBtnName][1];
	if me.nMapTemplateId == nMapTemplateId then
		Ui:OpenWindow("MiniMap", me.nMapTemplateId);
	else
		local nMapLevel = Map:GetEnterLevel(nMapTemplateId);
		if me.nLevel < nMapLevel then
			me.CenterMsg(string.format("达到%d级才可进入该地图", nMapLevel));
			return;
		end

		if not Map:IsTimeFrameOpen(nMapTemplateId) then
			me.CenterMsg("当前地图尚未开放");
			return;
		end

		if AutoFight:IsAuto() then
			AutoFight:StopAll();
			Timer:Register(Env.GAME_FPS * 1.3, function ()
				Map:SwitchMap(nMapTemplateId);
			end);
		else
			Map:SwitchMap(nMapTemplateId);
		end
	end
	Guide.tbNotifyGuide:ClearNotifyGuide("WorldMap");
	Ui:CloseWindow("WorldMap");
end

function tbUi:OnSynData( szDataType )
	if szDataType == "Common" then
		self:UpdateRightBtns()
	end
end

for key, _ in pairs(tbWorldMapSetting) do
	tbUi.tbOnClick[key] = fnTouchItem;
end

function tbUi.tbOnClick:BtnWarReport(  )
	Ui:CloseWindow(self.UI_NAME)
	Ui:OpenWindow("TerritorialWarMapPanel")
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{UiNotify.emNOTIFY_MAP_LEAVE, self.CloseWithoutAni},
		{UiNotify.emNOTIFY_LTZ_SYN_DATA, self.OnSynData, self },

	};
	return tbRegEvent;
end
