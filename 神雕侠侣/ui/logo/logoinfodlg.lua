require "ui.dialog"
require "ui.worldmap.worldmapdlg"

LogoInfoDialog = {};
setmetatable(LogoInfoDialog, Dialog);
LogoInfoDialog.__index = LogoInfoDialog;

------------------------public:----------------------------
----------------singleton //////////////////////////-------
local _instance ;
function LogoInfoDialog.getInstance()
	LogInfo("enter get logoinfodialog instance");

	if not _instance then
		_instance = LogoInfoDialog:new();
		_instance:OnCreate();
	end

	return _instance;
end

function LogoInfoDialog.DestroyDialog()
	if _instance then 
		LogInfo("destroy logoinfodialog")
		if GetScene() then
			GetScene().EventMapChange:RemoveScriptFunctor(_instance.m_hMapChange)
		end
		_instance:OnClose()
		_instance = nil
	end
end

function LogoInfoDialog.GetSingletonDialogAndShowIt()

	if not _instance then
        _instance = LogoInfoDialog:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function LogoInfoDialog.getInstanceNotCreate()
    return _instance
end

------------------------//////////////////////////----------------------

function LogoInfoDialog:new()
	local self = {};
	setmetatable(self, LogoInfoDialog);
	return self;
end

function LogoInfoDialog.GetLayoutFileName()
	return "logoinfo.layout";
end

function LogoInfoDialog:OnCreate()
	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton();

	if GetScene() then
        self.m_hMapChange = GetScene().EventMapChange:InsertScriptFunctor(self.UpdateMapName);
    end

	self.m_pMapName = winMgr:getWindow("LogoInfo/mapname");
	self.m_pPosition = winMgr:getWindow("LogoInfo/coordinate");

	self.m_pMiniMapBtn = winMgr:getWindow("LogoInfo/mimimapBtn");
	self.m_pShopEntrance = winMgr:getWindow("shopentrance/btn");
	self.m_pShopEntrance:subscribeEvent("Clicked", self.HandleShopEntranceBtnClicked, self);

	self:GetWindow():subscribeEvent("WindowUpdate", self.UpdatePos, self);

	self.m_pMiniMapBtn:subscribeEvent("Clicked", self.HandleMiniMapBtnClick, self);
	self.m_pPosition:subscribeEvent("MouseButtonDown", self.HandlePosWndClick, self);
	self:UpdateMapName();

	if GetScene() and GetScene():GetMapInfo() and GetScene():GetMapInfo().id == 1426 then
		self.m_pShopEntrance:setVisible(false)
	end
end

-- open shop
function LogoInfoDialog:HandleShopEntranceBtnClicked(args)
    require "protocoldef.knight.gsp.yuanbao.copencontinuechargedlg"
    local p = COpenContinueChargeDlg.Create()
    p.flag = 2 -- for shop show1
    p.page = 3
    require "manager.luaprotocolmanager":send(p)
end

function LogoInfoDialog:UpdatePos(eventArgs)
	if not GetMainCharacter() then
		return false;
	end

	local loc = GetMainCharacter():GetLogicLocation();
	if not self.m_loc or self.m_loc.x ~= loc.x or self.m_loc.y ~= loc.y then --��������煎��姣�杈�
		local strPos = "";
		strPos = strPos .. tostring(math.floor(loc.x / 16));
		strPos = strPos .. ",";
		strPos = strPos .. tostring(math.floor(loc.y / 16));

		self.m_pPosition:setText(strPos);
		self.m_loc = loc;
	end

end

function LogoInfoDialog:HandleMiniMapBtnClick(args)
	WorldMapdlg.GetSingletonDialogAndShowIt();
	return true
end

function LogoInfoDialog:HandlePosWndClick(args)
	
	if GetScene():isOnDreamScene() then
		GetGameUIManager():AddMessageTip(knight.gsp.message.GetCMessageTipTableInstance():getRecorder(141627).msg);
	else
		--[[
		local curMapID = GetScene():GetMapID();
		local curMapName = GetScene():GetMapName();
		local strText = "[" .. curMapName + " " .. (self.m_loc.x/16) + "," ..(self.m_loc.y/16) .. "]";
		--]]
	end
	return true
end

function LogoInfoDialog:UpdateMapName()
	if _instance then
		_instance.m_pMapName:setText(GetScene():GetMapName());
	end
end

function LogoInfoDialog:SetMapName(name)
	if _instance then
		_instance.m_pMapName:setText(name);
	end
end

return LogoInfoDialog
