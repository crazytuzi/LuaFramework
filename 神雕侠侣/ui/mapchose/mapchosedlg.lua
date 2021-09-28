require "ui.dialog"
require "ui.mapchose.mapchosespriterendereffect"
require "utils.mhsdutils"
require "utils.stringbuilder"

MapChoseDlg = {};
setmetatable(MapChoseDlg, Dialog);
MapChoseDlg.__index = MapChoseDlg;

--////////////二倍和三倍经验功能都已不存在，现在只有五倍

-----------------public:-----------------------
--------/////////singleton--------------------
local _instance;

function MapChoseDlg.GetSingleton()
	return _instance;
end

function MapChoseDlg.GetSingletonDialog()
	if not _instance then
		_instance = MapChoseDlg:new();
		_instance:OnCreate();
	end
	return _instance;
end

function MapChoseDlg.GetSingletonDialogAndShowIt()
	if not _instance then
		_instance = MapChoseDlg:new();
		_instance:OnCreate();
	else
		_instance:SetVisible(true);
	end
end

function MapChoseDlg.CloseDialog()
	if _instance then
		_instance:OnClose();
		_instance:ReleaseAllSprite();
		_instance = nil
	end
end

function MapChoseDlg.DestroyDialog()
	if _instance then
		_instance:CloseDialog()
	end
end

function MapChoseDlg.ToggleOpenHide()
	if not _instance then
		_instance = MapChoseDlg:new();
		_instance:OnCreate();
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false);
		else
			_instance:SetVisible(true);
		end
	end
end

function MapChoseDlg.ShowAndSetMapID(mapID, bForAutobattle)
	MapChoseDlg.GetSingletonDialogAndShowIt();
	MapChoseDlg.SetMapID(mapID, (bForAutobattle ~= 0));
end

function MapChoseDlg.SetMapID(mapID, bForAutobattle)
	if tonumber(mapID) > 0 then

		local mapRecord = knight.gsp.map.GetCWorldMapConfigTableInstance():getRecorder(mapID)
		if mapRecord.id ~= -1 then
			_instance:ReleaseAllSprite();

			_instance.m_bForAutoBattle = bForAutobattle;
			_instance.m_pTwoTimeBtn:setVisible(bForAutobattle);
			_instance.m_pThreeTimeBtn:setVisible(bForAutobattle);
			_instance.m_pDoubleTime:setVisible(bForAutobattle);

			_instance.m_pLocalMapAuttoBattle:setVisible(bForAutobattle);
			_instance.m_pMapchosedialog_match:setVisible(false);
			_instance.m_pMapchosedialog_title:setText(mapRecord.sonmapname);

			if _instance.m_bForAutoBattle then
				GetNetConnection():send(knight.gsp.item.CReqMultiExpTime());
			end

			local vecSubMaps =  MapChoseDlg.GetSubMapIDByString(mapRecord.sonmapid);
			local size = #vecSubMaps;
			if size > 0 then
				_instance:setMapSonMaps(size, vecSubMaps);
			end
		end

	end
end

function MapChoseDlg.ResetAllSubMap()
	
end

function MapChoseDlg.UpdateMulExpInfo(doubleexpflag, doubleexpremaintime, tripleexpflag, tripleexpremaintime)
	
	if _instance.m_bForAutoBattle then
		_instance.m_iDoubleTimeMin = doubleexpremaintime;
		_instance.m_iTripleTimeMIn = tripleexpremaintime;

		if doubleexpflag == 0 then
			if doubleexpremaintime > 0 then
				_instance.m_pTwoTimeBtn:setText(MHSD_UTILS.get_resstring(2927));--继续双倍
				local min = math.floor(tonumber(doubleexpremaintime / 60))
				_instance.m_pDoubleTime:setVisible(true);
				local strbuilder = StringBuilder:new();
				strbuilder:Set("parameter", min)
				_instance.m_pThreeTime:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2928)));
				strbuilder:delete();
			else
				_instance.m_pTwoTimeBtn:setText(MHSD_UTILS.get_resstring(2929));
				_instance.m_pDoubleTime:setVisible(false);
			end
			_instance.m_bUseDouble = false;
		else
			_instance.m_pTwoTimeBtn:setText(MHSD_UTILS.get_resstring(2930));
			_instance.m_pDoubleTime:setVisible(true);
			local min = math.floor(tonumber(doubleexpremaintime / 60));

			local strbuilder = StringBuilder:new();
			strbuilder:Set("parameter", min)
			_instance.m_pDoubleTime:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2928)));
			strbuilder:delete();
			_instance.m_bUseDouble = true;
		end

		if tripleexpflag == 0 then
			if tripleexpremaintime > 0 then
				_instance.m_pThreeTimeBtn:setText(MHSD_UTILS.get_resstring(2931));
				_instance.m_pThreeTime:setVisible(true);
				local min = math.floor(tonumber(tripleexpremaintime / 60));
				local strbuilder = StringBuilder:new();
				strbuilder:Set("parameter", min)
				_instance.m_pThreeTime:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2928)));
				strbuilder:delete();
			else
				_instance.m_pThreeTimeBtn:setText(MHSD_UTILS.get_resstring(2932));
				_instance.m_pThreeTime:setVisible(false);
			end
			_instance.m_bUseTriple = false;
		else

			_instance.m_pThreeTimeBtn:setText(MHSD_UTILS.get_resstring(2933));
			_instance.m_pThreeTime:setVisible(true);
			local min = math.floor(tonumber(tripleexpremaintime / 60));
			local strbuilder = StringBuilder:new();
			strbuilder:Set("parameter", min)
			_instance.m_pThreeTime:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2928)));
			strbuilder:delete();
			_instance.m_bUseTriple = true;
		end
	end
end


-------------///////////////////--------------------------------

function MapChoseDlg:new()
	local self = {};
	self = Dialog:new();
	setmetatable(self, MapChoseDlg);
	self:init();
	return self;
end

function MapChoseDlg:init()
	self.m_bForAutoBattle = false
	self.m_bUseDouble = false
	self.m_bUseTriple = false
	self.m_ConfirmToGoMapID = 0
	self.m_iDoubleTimeMin = 0
	self.m_iTripleTimeMIn = 0
end

function MapChoseDlg.GetLayoutFileName()
	return "mapchosedialog.layout";
end


function MapChoseDlg:OnCreate()

	LogInfo("mapchose -------------onCreate");
	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton();

	self.m_pMapchosedialog_match = winMgr:getWindow("mapchosedialog/match");
	self.m_pMapchosedialog_closed = winMgr:getWindow("mapchosedialog/closed");
	self.m_pMapchosedialog_title = winMgr:getWindow("mapchosedialog/title");

	self.m_pTwoTimeBtn = winMgr:getWindow("mapchosedialog/double");
	self.m_pThreeTimeBtn = winMgr:getWindow("mapchosedialog/third");

	self.m_pDoubleTime = winMgr:getWindow("mapchosedialog/two");
	self.m_pThreeTime = winMgr:getWindow("mapchosedialog/three");
	self.m_pLocalMapAuttoBattle = winMgr:getWindow("mapchosedialog/now");
	self.m_pMapchosedialog_offlineexp = winMgr:getWindow("mapchosedialog/nowleave")

	self.m_pMapchosedialog_closed:subscribeEvent("Clicked", self.HandleMapchosedialog_closedBtnClicked, self);
	self.m_pTwoTimeBtn:subscribeEvent("Clicked", self.HandleUseTwoTimeBtnClick, self);
	self.m_pThreeTimeBtn:subscribeEvent("Clicked", self.HandleUseThreeTimeBtnClick, self);

	self.m_pTwoTimeBtn:setVisible(false);
	self.m_pThreeTimeBtn:setVisible(false);

	self.m_pLocalMapAuttoBattle:setVisible(false);
	self.m_pLocalMapAuttoBattle:subscribeEvent("Clicked", self.HandleLocalMapAutoBtnClick, self);

	self.m_pMapchosedialog_offlineexp:subscribeEvent("Clicked", self.HandleLocalMapOfflineExpBtnClick, self);

end

function MapChoseDlg:HandleMapchosedialog_closedBtnClicked(e)
	MapChoseDlg.CloseDialog();
	return true;
end

function MapChoseDlg:HandleUseTwoTimeBtnClick(e)
	
	if self.m_bUseDouble then
		local service = knight.gsp.npc.CNpcService(0, knight.gsp.npc.NpcServices.BACK_MULTI_GIVENEXP);
		GetNetConnection():send(service);

		local  reqcmd = knight.gsp.item.CReqMultiExpTime();
		GetNetConnection():send(reqcmd);  
		return true;
	elseif self.m_iDoubleTimeMin > 0 then
		local continueCmd = knight.gsp.item.CContinueMultiExp();
		continueCmd.flag = 2
		GetNetConnection():send(continueCmd); 

		local reqcmd = knight.gsp.item.CReqMultiExpTime();
		GetNetConnection():send(reqcmd);
	else
		local bSucess = UseMultiTimeExpToAutoBattle(36112);
		if bSucess then
			self.m_pTwoTimeBtn:setText(MHSD_UTILS.get_resstring(2930));
			GetNetConnection():send(knight.gsp.item.CReqMultiExpTime());
		end
	end

	return true;
end

function MapChoseDlg.UseMultiTimeExpToAutoBattle(baseID)
	if baseID > 0 then
		local key  = GetRoleItemManager():GetItemKeyByBaseID(baseID);
		if key == 0 then
			GetGameUIManager():AddMessageTipById(144931);
			return false;
		end

		GetNetConnection():send(knight.gsp.item.CUseItem(key, knight.gsp.item.IDType.ROLE, GetDataManager():GetMainCharacterID()));
		return true;
	end
	return false;
end

function MapChoseDlg:HandleUseThreeTimeBtnClick(e)
	if self.m_bUseTriple then
		local service = knight.gsp.npc.CNpcService(0, knight.gsp.npc.NpcServices.BACK_MULTI_GIVENEXP);
		GetNetConnection():send(service);

		GetNetConnection():send(knight.gsp.item.CReqMultiExpTime());
		return true;
	elseif self.m_iTripleTimeMIn > 0 then
		local continueCmd = knight.gsp.item.CContinueMultiExp();
		continueCmd.flag = 3;
		GetNetConnection():send(continueCmd);

		GetNetConnection():send(knight.gsp.item.CReqMultiExpTime());
	else
		local bSuccess = MapChoseDlg.UseMultiTimeExpToAutoBattle(36034);
		if bSuccess then
			self.m_pThreeTimeBtn:setText(MHSD_UTILS.get_resstring(2934));
			GetNetConnection():send(knight.gsp.item.CReqMultiExpTime());
		end
	end
	return true;
end

function MapChoseDlg:HandleLocalMapAutoBtnClick(e)
	GetMainCharacter():SetRandomPacing();
	MapChoseDlg.CloseDialog();

	return true;
end

function MapChoseDlg:HandleLocalMapOfflineExpBtnClick(e)

	ActivityManager.reqOfflineExp();
	return true;
end

function MapChoseDlg.GetSubMapIDByString(strSubMaps)
	local sub_str_tab = {};
	local str = strSubMaps;
	while (true) do 
		local pos = string.find(str, ",");
		if not pos then
			sub_str_tab[#sub_str_tab + 1] = str;
			break;
		end
		local sub_str = string.sub(str, 1, pos - 1);
		sub_str_tab[#sub_str_tab + 1] = sub_str;
		str = string.sub(str, pos + 1, #str);
	end
	return sub_str_tab;
end

function MapChoseDlg:HandleMapchosedialog_mapBtnClicked(e)
	local  wndE = CEGUI.toMouseEventArgs(e);

	if wndE.window ~= nil then
		local mapID = wndE.window:getID();
		if mapID > 0 then
			local mapRecord = knight.gsp.map.GetCWorldMapConfigTableInstance():getRecorder(mapID);
			
			if mapRecord.id ~= -1 then -- 存在地图

				local roleLevel = GetDataManager():GetMainCharacterLevel();
				if roleLevel < mapRecord.LevelLimitMin then -- 等级限制的判断

					local strMessage = MHSD_UTILS.get_msgtipstring(144857);
					GetMessageManager():AddConfirmBox(eConfirmGotoHighLevelMap, strMessage,
						MapChoseDlg.OnConfirmGoHighLevelMap, self,
						CMessageManager.HandleDefaultCancelEvent,CMessageManager);
					self.m_ConfirmToGoMapID = mapID;
					return true;
				else
					if GetTeamManager() and -- 组队中
						GetTeamManager():IsOnTeam() and 
						GetTeamManager():GetTeamMinLevel() < mapRecord.LevelLimitMin then

						local strMessage = MHSD_UTILS.get_msgtipstring(144848)
						GetMessageManager():AddConfirmBox(eConfirmGotoHighLevelMap, strMessage,
						 	MapChoseDlg.OnConfirmGoHighLevelMap, self,
							CMessageManager.HandleDefaultCancelEvent,CMessageManager);
						self.m_ConfirmToGoMapID = mapID;
						return true;
					end
				end

				-- 没有进入选定的地图，在当前地图中漫步
				if GetScene() and mapID == GetScene():GetMapID() and GetMainCharacter() then

					GetMainCharacter():SetRandomPacing();
					MapChoseDlg.CloseDialog();
					return true;
				end

				local randX=mapRecord.bottomx - mapRecord.topx;
				randX = mapRecord.topx + math.random(0, randX);

				local randY = mapRecord.bottomy - mapRecord.topy;
				randY = mapRecord.topy + math.random(0, randY);

				local cmd = knight.gsp.task.CReqGoto(mapID, randX, randX);
				GetNetConnection():send(cmd);

				if GetScene() and self.m_bForAutoBattle then
					GetScene():EnableJumpMapForAutoBattle(true);
				end
				MapChoseDlg.CloseDialog();
			end
		end
	end
	return true;
end

function MapChoseDlg:OnConfirmGoHighLevelMap(e)
	if _instance.m_ConfirmToGoMapID == 0 then 
		return true;
	end

	if GetScene() and _instance.m_ConfirmToGoMapID == GetScene():GetMapID() and GetMainCharacter() then
		GetMainCharacter():SetRandomPacing();
	else
		local mapRecord = knight.gsp.map.GetCWorldMapConfigTableInstance():getRecorder(_instance.m_ConfirmToGoMapID);
		if mapRecord.id ~= -1 then
			local randX = mapRecord.bottomx - mapRecord.topx;
			randX = mapRecord.topx + math.random(0, randX);

			local randY = mapRecord.bottomy - mapRecord.topy;
			randY = mapRecord.topy + math.random(0, randY);

			GetNetConnection():send(knight.gsp.task.CReqGoto(_instance.m_ConfirmToGoMapID, randX, randY));

			if GetScene() and _instance.m_bForAutoBattle then
				GetScene():EnableJumpMapForAutoBattle(true);
			end
		end
	end

	_instance.m_ConfirmToGoMapID = 0;
	CMessageManager:HandleDefaultCancelEvent(e);
	MapChoseDlg.CloseDialog();

	return true;
end

function MapChoseDlg:setMapSonMaps(size, subMaps)

	local winMgr = CEGUI.WindowManager:getSingleton();
	self.m_vecSpriteHandles = {};
	local subMapNum = size;
	for i = 1, 8 do
		local strButtonname = "mapchosedialog/map" .. tostring(i);
		local pButton = winMgr:getWindow(strButtonname);
		pButton:subscribeEvent("Clicked", self.HandleMapchosedialog_mapBtnClicked, self);

		local pName = winMgr:getWindow("mapchosedialog/name" .. i);
		local pLevel = winMgr:getWindow("mapchosedialog/level" .. i);

		if i > subMapNum then
			pButton:setVisible(false);
			pName:setVisible(false);
			pLevel:setVisible(false);
			pButton:setID(0);
			pButton:setEnabled(false);
		else
			local subMapID = subMaps[i];
			local subMapRecord = knight.gsp.map.GetCWorldMapConfigTableInstance():getRecorder(subMapID);
			if subMapRecord.id == -1 then
				pName:setVisible(false);
				pLevel:setVisible(false);
				pButton:setID(0);
				pButton:setEnabled(false);
			else
				local roleLevel = GetDataManager():GetMainCharacterLevel();
				pButton:setEnabled(true);
				if roleLevel < subMapRecord.LevelLimitMin then
 					pButton:setProperty("NormalImage", subMapRecord.sonmapdisable);
                    pButton:setProperty("PushedImage", subMapRecord.sonmapdisable);
                    pButton:setProperty("HoverImage", subMapRecord.sonmapdisable);
                    pButton:setProperty("DisabledImage", subMapRecord.sonmapdisable);
				else
					pButton:setProperty("NormalImage", subMapRecord.sonmapnormal);
                    pButton:setProperty("PushedImage", subMapRecord.sonmappushed);
                    pButton:setProperty("HoverImage", subMapRecord.sonmappushed);
                    pButton:setProperty("DisabledImage", subMapRecord.sonmapdisable);
				end

				pName:setText(subMapRecord.mapName);
				local strbuilder = StringBuilder:new();
				strbuilder:Set("parameter1", subMapRecord.LevelLimitMin)
				strbuilder:Set("parameter2", subMapRecord.LevelLimitMax)
				pLevel:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2935)));
				strbuilder:delete();
				pButton:setID(subMapID);
				self:AddSprite(pButton, subMapRecord.sculptid);

				if roleLevel >= subMapRecord.LevelLimitMin and roleLevel <= subMapRecord.LevelLimitMax then

					self.m_pMapchosedialog_match:setVisible(true);
					local pt = pButton:GetScreenPosOfCenter();
					local Size = self.m_pMapchosedialog_match:getPixelSize();

					local xPos = pt.x - Size.width / 2;
					local yPos = pt.y - Size.height / 2;
					local parentPos = self.m_pMapchosedialog_match:getParent():GetScreenPos();
					xPos = xPos - parentPos.x;
					yPos = yPos - parentPos.y;
					self.m_pMapchosedialog_match:setXPosition( CEGUI.UDim(0,xPos));
					self.m_pMapchosedialog_match:setYPosition( CEGUI.UDim(0,yPos));

					pButton:setProperty("NormalImage", "set:MainControl13 image:mapchooselight");
				end
			end
		end
	end
end

function MapChoseDlg:AddSprite(pButton, shapeID)
	if pButton == nil then
		return
	end
	
	local shapeRecord = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(shapeID);
	
	pButton:getGeometryBuffer():setRenderEffect(CGameUImanager:createXPRenderEffect((#self.m_vecSpriteHandles + 1), 
													MapChoseSpriteRenderEffect.performPostRenderFunctions)); 
	if shapeRecord.id ~= -1 then 
		
		local sprite = CUISprite:new(shapeID)
		if sprite  then
			local pt = pButton:GetScreenPosOfCenter();
			local loc = XiaoPang.CPOINT(tonumber(pt.x), tonumber(pt.y + 30));
			sprite:SetUILocation(loc)
			sprite:SetUIDirection(XiaoPang.XPDIR_BOTTOMRIGHT)
			sprite:SetUIScale(0.8);

			self.m_vecSpriteHandles[#self.m_vecSpriteHandles + 1] = sprite;
		end
	end
end

function MapChoseDlg:DrawSprite(id)
	if self.m_vecSpriteHandles ~= nil then 
		local sprite = self.m_vecSpriteHandles[id];
		sprite:RenderUISprite()
	end
end

function MapChoseDlg:ReleaseAllSprite()
	if self.m_vecSpriteHandles ~= nil then 
		for k, v in pairs(self.m_vecSpriteHandles) do
			if v then 
				v:delete();
				v = nil;
			end
		end
	end
end

---------------------/////////////////
return MapChoseDlg;