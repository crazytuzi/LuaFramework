require "ui.dialog"
require "ui.mapchose.mapchosedlg"

WorldMapdlg = {};
setmetatable(WorldMapdlg, Dialog);
WorldMapdlg.__index = WorldMapdlg;

local eFenglingduFly = 1005;
local eJiaxingFly = 1006;
local eLinanFly  = 1007;
local eXiangyangFly = 1013;
local PLAYERICONSIZE = 25
local map_icon_index={1105,1108,1107,1100,1102,1008,1220,1014,1006
,1250,1210,1200,1007,1002,1013,1004,1230,1005,1240,1001,1011,1015,1010,1012,1009,1003,1104,1018};

-----------------------------public:------------------------------------
----------------////////////singleton------------------------------
local  _instance;
function WorldMapdlg.GetSingleton()
	return _instance;
end

function WorldMapdlg.GetSingletonDialog()
	if not _instance then
		_instance = WorldMapdlg:new();
		_instance:OnCreate();
	end
	
	return _instance;
end

function WorldMapdlg.GetSingletonDialogAndShowIt()
	if not _instance then
		_instance = WorldMapdlg:new();
		_instance:OnCreate();
	else 
		_instance:SetVisible(true);
	end
end

function WorldMapdlg.DestroyDialog()
	if _instance then 
		_instance:CloseDialog();
	end
end

function WorldMapdlg.SigleUpdateUseFlyFlagState()
	_instance:UpdateUseFlyFlagState();
end

function WorldMapdlg:CloseDialog()
	if _instance then
		_instance:OnClose()
		_instance = nil
	end
end

function WorldMapdlg.ToggleOpenClose()
	if not _instance then 
		_instance = WorldMapdlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end


----------//////////////////////////---------------------------
function WorldMapdlg:new()
	local self = {};
	self = Dialog:new();
	setmetatable(self, WorldMapdlg);
	self:init();
	return self;
end

function WorldMapdlg:init( )
	self.m_bFlyRuneMode = false;
	self.m_FlyRuneItemID = -1;
	self.m_Effect = nil;
	
	self.m_IconMap = {};

	--self.m_eDialogType = bit.bor(eDlgTypeBattleClose, self.m_eDialogType); --TODO: 验证dialogue type

	local ids = std.vector_int_();
	knight.gsp.map.GetCMapConfigTableInstance():getAllID(ids);
	local num = ids:size() - 1;
	for i= 0, num do
		local mapConfig =  knight.gsp.map.GetCMapConfigTableInstance():getRecorder(ids[i]);
		local rect = {};
		rect.d_left = tonumber(mapConfig.IconLeft);
		rect.d_top = tonumber(mapConfig.IconTop);
		rect.d_right = tonumber(mapConfig.IconLeft) + 70;
		rect.d_bottom = tonumber(mapConfig.IconTop) + 30;
		self.m_IconMap[ids[i]] = rect;
	end
end

function WorldMapdlg.GetLayoutFileName()
	return "worldmap.layout";
end

function WorldMapdlg:OnCreate()
	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton();
	self.m_CloseButton = winMgr:getWindow("WorldMap/CloseButton");
	self.m_CloseButton:subscribeEvent("Clicked", self.HandleCloseClick, self);
	self.m_MapImage = winMgr:getWindow("WorldMap/MapImage");
	self.m_MapImage:setAlwaysOnTop(true);
	self.m_MapImage:subscribeEvent("Clicked", self.HandleCloseClick, self);
	self.m_MapImage:setMousePassThroughEnabled(false);
	
	--////////////////////
	---/// 设置地图关卡按钮
	self.m_MapButtonMap = {};
	for k,v in pairs(self.m_IconMap) do
		if WorldMapdlg.isMapIdInMap(k) then
			self.m_MapButtonMap[k] = winMgr:getWindow("WorldMap/" .. tostring(k));
			self.m_MapButtonMap[k]:subscribeEvent("Clicked", WorldMapdlg.HandleMapButtonClick, self);
			self.m_MapButtonMap[k]:setID(k);

			local st = self.m_MapButtonMap[k]:getProperty("NormalImage"); -- TODO: 验证函数的有效性
			local pImage = CEGUI.PropertyHelper:stringToImage(st);

			if pImage then
				 self.m_IconMap[k].d_right = self.m_IconMap[k].d_left + pImage:getWidth();
				 self.m_IconMap[k].d_top = self.m_IconMap[k].d_top + pImage:getHeight();
			 end
		end 
	end

	self.m_PlayerPosImage = winMgr:getWindow("WorldMap/MapImage/PlayerPosImage");
	self.m_PlayerPosImage:setAlwaysOnTop(true);
	self.m_PlayerPosImage:setMousePassThroughEnabled(true);

	self.m_NoteBox = CEGUI.toRichEditbox(winMgr:getWindow("WorldMap/Note"));
	self.m_NoteBox:setReadOnly(true);
	self.m_NoteBox:SetForceHideVerscroll(true);
	self.m_NoteBox:SetHoriAutoCenter(true);
	self.m_NoteBox:SetVertAutoCenter(true);
	self.m_NoteBox:setAlwaysOnTop(true);
	self.m_NoteBox:setMousePassThroughEnabled(true);

	self.m_pSubFlyFlag = CEGUI.toCheckbox(winMgr:getWindow("WorldMap/MapImage/fly"));
	self.m_pSubFlyFlag:subscribeEvent("CheckStateChanged", self.HandleUseFlyFlagChange, self);

	self.m_pSubMapBox = winMgr:getWindow("WorldMap/MapImage/num");
	self.m_pSubMapBox:setVisible(false);

	self:UpdateButtonPos();
	self:SetPlayerMapPos();

	self.m_NoteBox:setReadOnly(true);
	self.m_NoteBox:setVisible(false);

	self:UpdateUseFlyFlagState();

end

-- 检测地图上是否由此索引的地图图标
function WorldMapdlg.isMapIdInMap(id)
	for k,v in pairs(map_icon_index) do 
		if v == id then
			return true;
		end
	end
	return false;
end

function WorldMapdlg:HandleCloseClick(e)
	local mouseArgs = CEGUI.toMouseEventArgs(e);
	if mouseArgs.window == self.m_MapImage then
		if mouseArgs.button ~= CEGUI.RightButton then
			return true;
		end
	end
	if self.m_Effect then
		GetGameUIManager():RemoveUIEffect(self.m_Effect);
		self.m_Effect = nil;
	end

	WorldMapdlg.DestroyDialog();
	return true;
end

function WorldMapdlg:HandleMapButtonClick(e)
	print("WorldMapdlg:HandleMapButtonClick")
	local mouseArgs = CEGUI.toMouseEventArgs(e);
	local mapId = mouseArgs.window:getID();
	print("MapID: " .. mapId)

	if mapId < 0 then
		return true;
	end

	if mapId == 1240 or mapId == 1250 then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(144858);
        end
		return true;
	end

	local  mapRecord = knight.gsp.map.GetCWorldMapConfigTableInstance():getRecorder(mapId);

	if mapRecord.id == -1 then
		return true
	end

	if mapRecord.maptype == 1 or mapRecord.maptype == 2 then
		local randX = mapRecord.bottomx - mapRecord.topx;
		randX = mapRecord.topx + math.random(0, randX);

		local randY = mapRecord.bottomy - mapRecord.topy;
		randY = mapRecord.topy + math.random(0, randY);

		GetNetConnection():send(knight.gsp.task.CReqGoto(mapId, randX, randY));
		WorldMapdlg.DestroyDialog();

	elseif mapRecord.maptype == 3 and mapRecord.sonmapid ~= "0" then

		MapChoseDlg.GetSingletonDialogAndShowIt();
        if MapChoseDlg.GetSingleton() then
            MapChoseDlg.GetSingleton().SetMapID(mapId, false);
            
            WorldMapdlg.DestroyDialog();
        end
	else

	end
	return true;
end

function WorldMapdlg:HandleUseFlyFlagChange(e)
	local bUse = self.m_pSubFlyFlag:isSelected();
	if GetRoleItemManager() then
		GetRoleItemManager():EnableUseFlyFlagToFly(bUse);
	end
end

function WorldMapdlg:UpdateButtonPos()
	for i, v in ipairs(self.m_MapButtonMap) do
		v:setProperty("UnifiedAreaRect", self.RectToStringAbsolute(self.m_IconMap[i]));
	end
end

function WorldMapdlg.RectToStringAbsolute( rect )
	local iss = "{{" .. "0" .. "," .. rect.d_left .. "},{" ..
						"0" .. "," .. rect.d_top .. "},{" ..
						"0" .. "," .. rect.d_right .. "},{" ..
						"0" .. "," .. rect.d_bottom .. "}}";
	return iss;
end

function WorldMapdlg:SetPlayerMapPos()
	local mapid = GetScene():GetMapID();
	if not self.m_MapButtonMap[mapid] then
		self.m_PlayerPosImage:setVisible(false);
		return;
	end
	local  mapconfig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(mapid);

	if mapconfig.playerPosX >= 0 and mapconfig.playerPosY >= 0 then
		local shape = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(GetDataManager():GetMainCharacterShape());
		local iconpath = GetIconManager():GetImagePathByID(shape.littleheadID):c_str();
		self.m_PlayerPosImage:setVisible(true);
		self.m_PlayerPosImage:setProperty("Image", iconpath);

		local rect = {};
		local btnXpos = self.m_MapButtonMap[mapid]:GetScreenPosOfCenter().x;
		local btnYpos = self.m_MapButtonMap[mapid]:GetScreenPosOfCenter().y;

		
		
		if Config.isKoreanAndroid() or  ( Config.TRD_PLATFORM == 1 and Config.MOBILE_ANDROID == 0 and Config.CUR_3RD_PLATFORM == "kris" ) then
			rect.d_left = btnXpos - PLAYERICONSIZE / 2 - self:GetWindow():GetScreenPos().x;
			rect.d_top = btnYpos - PLAYERICONSIZE / 2 - self:GetWindow():GetScreenPos().y;
			rect.d_right = rect.d_left + PLAYERICONSIZE;
			rect.d_bottom = rect.d_top + PLAYERICONSIZE;
		else
			rect.d_left = btnXpos - PLAYERICONSIZE / 2;
			rect.d_top = btnYpos - PLAYERICONSIZE / 2;
			rect.d_right = rect.d_left + PLAYERICONSIZE;
			rect.d_bottom = rect.d_top + PLAYERICONSIZE;
		end

		self.m_PlayerPosImage:setProperty("UnifiedAreaRect", self.RectToStringAbsolute(rect));
		if self.m_Effect == nil then
			self.m_Effect = GetGameUIManager():AddUIEffect(self.m_PlayerPosImage, MHSD_UTILS.get_effectpath(10201), true);
		end
	else
		self.m_PlayerPosImage:setVisible(false);
		GetGameUIManager():RemoveUIEffect(self.m_Effect);
		self.m_Effect = nil;
	end

end

function WorldMapdlg:UpdateUseFlyFlagState()
	if GetRoleItemManager() then
		local bUse = GetRoleItemManager():isUseFlyFlagToFly();
		self.m_pSubFlyFlag:setSelected(bUse);
	end
end

return WorldMapdlg;