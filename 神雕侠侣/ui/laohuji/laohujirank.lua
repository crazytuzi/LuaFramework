require "ui.dialog"
local LaohujiRank = {}

setmetatable(LaohujiRank, Dialog);
LaohujiRank.__index = LaohujiRank;

local _instance;

function LaohujiRank.getInstance()
	if _instance == nil then
		_instance = LaohujiRank:new();
		_instance:OnCreate();
	end

	return _instance;
end

function LaohujiRank.getInstanceNotCreate()
	return _instance;
end

function LaohujiRank.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
		LogInfo("LaohujiRank DestroyDialog")
	end
end

function LaohujiRank.getInstanceAndShow()
    if not _instance then
        _instance = LaohujiRank:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function LaohujiRank.ToggleOpenClose()
	if not _instance then 
		_instance = LaohujiRank:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function LaohujiRank.GetLayoutFileName()
	return "laohujirank.layout";
end

function LaohujiRank:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, LaohujiRank);
	return zf;
end

------------------------------------------------------------------------------

local stigerranklist = require "protocoldef.knight.gsp.activity.gamble.stigerranklist"
function stigerranklist:process()
	LogInfo("stigerranklist process ")
	if not _instance then return end
	_instance:SetData(self.ranklist)
end

function LaohujiRank:OnCreate()
	LogInfo("LaohujiRank OnCreate begin")
	Dialog.OnCreate(self)

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_listWnd = CEGUI.Window.toMultiColumnList(winMgr:getWindow("marrylist/PersonalInfo/list"))

	local p = require "protocoldef.knight.gsp.activity.gamble.creqtigerranklist":new()
	require "manager.luaprotocolmanager":send(p)	
end

function LaohujiRank:SetData( data )
	self.m_listWnd:resetList()
	for i= 1, #data do
        self.m_listWnd:addRow(i-1)

        local pItem = CEGUI.createListboxTextItem(tostring(data[i].rank))
        pItem:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
        pItem:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
        self.m_listWnd:setItem(pItem, 0, i-1)

        pItem = CEGUI.createListboxTextItem(data[i].rolename)
        pItem:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
        pItem:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
        self.m_listWnd:setItem(pItem, 1, i-1)
    end
end

return LaohujiRank