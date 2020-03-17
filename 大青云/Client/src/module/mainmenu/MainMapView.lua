--[[
小地图
haohu
2014年8月18日11:18:46
]]

_G.UIMainMap = BaseMap:new("UIMainMap", MapConsts.Type_Curr, MapConsts.MapName_Small);

function UIMainMap:Create()
	self:AddSWF("mapSmallPanel.swf", true, "interserver");
end

function UIMainMap:NeverDeleteWhenHide()
	return true;
end

function UIMainMap:OnChildShow()
	self:Top();
	TimerManager:RegisterTimer( function()
		self:Top();
	end, 2000, 1 );
	self:CheckInterServer();
end

function UIMainMap:GetWidth()
	return 259;
end

--@vo: MapElementVO 地图元素数据
function UIMainMap:OnIconMove(vo)
	--如果是主玩家,调整地图,使玩家图标居中
	if vo:GetType() == MapConsts.Type_MainPlayer then
		self:UpdateMyPos(vo)
	end
end

function UIMainMap:OnIconAdd(vo)
	--如果是主玩家,调整地图,使玩家图标居中
	if vo:GetType() == MapConsts.Type_MainPlayer then
		self:UpdateMyPos(vo)
	end
end

--@vo: MapElementVO 主玩家地图元素
function UIMainMap:UpdateMyPos(vo)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local map = objSwf.map;
	local mapMask = objSwf.mapMask;
	local mapX = mapMask._x;
	local mapY = mapMask._y;
	local mapW = mapMask._width;
	local mapH = mapMask._height;
	local playerX, playerY = vo:Get2DPos();
	local mapModel = self:GetModel();
	local mapId = mapModel:GetMapId();
	local mapPointCfg = MapPoint[mapId];
	if not mapPointCfg then
		Error( string.format( "Cannot find map config in the table MapPoint. MAP ID:%s", mapId ) );
		return;
	end
	--map._x = math.max( math.min( mapX + mapW * 0.5 - playerX, mapX ), mapX + mapW - mapPointCfg.mapW );
	--map._y = math.max( math.min( mapY + mapH * 0.5 - playerY, mapY ), mapY + mapH - mapPointCfg.mapH );
end


---------------------------以下为与地图无关，或次要地图信息的处理-----------------------------
UIMainMap.BtnMap   = "BtnMap";
UIMainMap.BtnRank  = "BtnRank";

function UIMainMap:Init(objSwf)
	objSwf.btnMap.data         = UIMainMap.BtnMap;
--	objSwf.btnPingbi.data       = UIMainMap.BtnPingbi;
	objSwf.btnRankingList.data = UIMainMap.BtnRank;
	-- objSwf.btnTeam.data 	   = UIMainMap.BtnTeam;
end

function UIMainMap:RegisterOtherEvents(objSwf)
	objSwf.ddLine.change = function(e) self:OnDDLineChange(e); end
	self:RegisterBtn( objSwf.btnMap );
--	self:RegisterBtn( objSwf.btnPingbi );
	self:RegisterBtn( objSwf.btnRankingList );
	-- self:RegisterBtn( objSwf.btnTeam);
end

function UIMainMap:RegisterBtn(btn)
if btn then
	local param = btn.data;
	btn.click    = function() self:OnBtnClick( param ); end
	btn.rollOver = function() self:OnBtnRollOver( param ); end
	btn.rollOut  = function() self:OnBtnRollOut( param ); end
end
end

-- @param: btn.data.
function UIMainMap:OnBtnClick(param)
	if not param then
		Debug("need to init btn to fill it's 'data' property")
		return
	end
	if not FuncOpenController.keyEnable then
		return;
	end
	if param == UIMainMap.BtnMap then
		-- changer:houxudong date:2016/9/3 18:21:22
		if ActivityController:GetCurrId() == ActivityConsts.Lunch then
			FloatManager:AddSkill('当前活动中不能打开M地图')
			return;
		end
		NpcController:SendGetCurMapObjList(enEntType.eEntType_Portal)
		self:SwitchPanel( UIBigMap );
	elseif param == UIMainMap.BtnPingbi then
	--	self:SwitchPanel( UIAutoBattle );
	elseif param == UIMainMap.BtnRank then
		if not GMModule:IsGM() then
			local openLvl = RankListConsts.RanklistOpenLvl;
			local rolelvl = MainPlayerModel.humanDetailInfo.eaLevel;
			if rolelvl < openLvl then 
				return 
			end;
			self:SwitchPanel( UIRankList );
		else
			self:SwitchPanel( UIRankList );
		end
	end
end

function UIMainMap:OnBtnRollOver(param)
	if not param then
		Debug("need to init btn to fill it's 'data' property")
		return
	end
	if param == UIMainMap.BtnMap then
		TipsManager:ShowBtnTips( StrConfig["mainmenuMap01"] );
	elseif param == UIMainMap.BtnRank then
		if GMModule:IsGM() then
			return;
		end
		local openLvl = RankListConsts.RanklistOpenLvl;
		local rolelvl = MainPlayerModel.humanDetailInfo.eaLevel;
		if rolelvl >= openLvl then 
			return 
		end;
		local str = RankListConsts.RanklistOpenLvl
		TipsManager:ShowBtnTips(string.format(StrConfig["mainmenuMap10"] ,str));
	end
end

function UIMainMap:OnBtnRollOut(param)
	TipsManager:Hide();
end

function UIMainMap:SwitchPanel(panel)
	if panel:IsShow() then
		panel:Hide();
		return;
	end
	panel:Show();
end

function UIMainMap:UpdateOther()
	self:ShowMapName();
    self:ShowLines()
	self:UptateRankListOpenState();
end

function UIMainMap:ShowMapName()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local model = self:GetModel();
	local mapId = model:GetMapId();
	local cfg = t_map[mapId];
	if not cfg then return end
	objSwf.txtName.text = cfg.name;
end

--显示当前是几线
function UIMainMap:ShowLines()
    local objSwf = self.objSwf;
    if not objSwf then return end
    local panel = objSwf
    local ddLine = panel and panel.ddLine;
    if not ddLine then return end
    panel.ddLine.dataProvider:cleanUp();
    local lines = MainPlayerModel.lines;
    for i, line in ipairs( lines ) do
    	local vo = MainMenuConsts.LineMap[line];
    	if vo then
		panel.ddLine:decodeItem( UIData.encode(vo) );
        end
    end
    for i, line in ipairs( lines ) do
        if line == CPlayerMap:GetCurLineID() then
			panel.ddLine.selectedIndex = i - 1;
			break;
        end
    end
end

-- 排行榜开启状态
function UIMainMap:UptateRankListOpenState()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if objSwf.btnRankingList.btnRnakHui then
		if GMModule:IsGM() then
			objSwf.btnRankingList.btnRnakHui._visible = false;
			return;
		end
	--
		local openLvl = RankListConsts.RanklistOpenLvl;
		local rolelvl = MainPlayerModel.humanDetailInfo.eaLevel;
		if rolelvl >= openLvl then 
			objSwf.btnRankingList.btnRnakHui._visible = false;
		else
			objSwf.btnRankingList.btnRnakHui._visible = true;
		end
	end
	
	
end


--点击切换线
function UIMainMap:OnDDLineChange(e)
	local toLine = e.data and e.data.line;
	if toLine and toLine ~= CPlayerMap:GetCurLineID() then
		if not MainPlayerController:ReqChangeLine(toLine) then
			self:ShowLines();
		end
	end
end

--监听消息列表(不包含地图消息，地图的在父类处理)
function UIMainMap:ListOtherNotiInterests()
	return {
        NotifyConsts.SceneLineChanged,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.SmallMapChangeLineVisible,
		NotifyConsts.InterServerState
	};
end

--处理消息(不包含地图消息，地图的在父类处理)
function UIMainMap:HandleOtherNotification(name, body)
	if name == NotifyConsts.SceneLineChanged then
        self:ShowLines();
    elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then 
			self:UptateRankListOpenState();
		end
	elseif name == NotifyConsts.InterServerState then
		self:CheckInterServer();
	
	elseif name == NotifyConsts.SmallMapChangeLineVisible then
		local objSwf = self.objSwf 
		if not objSwf then return end
		if body.lineVisible then
			objSwf.ddLine.visible = true
		else
			objSwf.ddLine.visible = false
		end
	end
end

function UIMainMap:GetMapBtnPos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local btn = objSwf.centerPos;
	return UIManager:PosLtoG( btn, 0, 0 );
end

--------------------------跨服时要做的处理--------------------------
function UIMainMap:CheckInterServer()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnMap.visible = not MainPlayerController.isInterServer;
	objSwf.btnRankingList.visible = not MainPlayerController.isInterServer;
	-- objSwf.btnTeam.visible = not MainPlayerController.isInterServer;
	--objSwf.effcontainer._visible = not MainPlayerController.isInterServer;
end
--------------------------------------------------------------------