local ButtonDlg = {}

setmetatable(ButtonDlg, Dialog);
ButtonDlg.__index = ButtonDlg;

local _instance;

function ButtonDlg.getInstance()
	if _instance == nil then
		_instance = ButtonDlg:new();
		_instance:OnCreate();
	end

	return _instance;
end

function ButtonDlg.getInstanceNotCreate()
	return _instance;
end

function ButtonDlg.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
		LogInfo("ButtonDlg DestroyDialog")
	end
end

function ButtonDlg.getInstanceAndShow()
    if not _instance then
        _instance = ButtonDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function ButtonDlg.ToggleOpenClose()
	if not _instance then 
		_instance = ButtonDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ButtonDlg.GetLayoutFileName()
	return "btn.layout";
end

function ButtonDlg:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, ButtonDlg);

	return zf;
end

------------------------------------------------------------------------------

function ButtonDlg:OnCreate()
	LogInfo("ButtonDlg OnCreate ")
	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton();

	self.m_btns = {}
	self.m_btns[1] = winMgr:getWindow("btn/button")
	self.m_btns[2] = winMgr:getWindow("btn/button1")
	self.m_btns[3] = winMgr:getWindow("btn/button2")

	self.m_parentPos = self:GetWindow():GetScreenPos()
	for i,v in ipairs(self.m_btns) do
		v.position = v:GetScreenPos()
		v.position.x = v.position.x - self.m_parentPos.x
		v.position.y = v.position.y - self.m_parentPos.y
		v:setVisible(false)
	end

	LuaUIManager.getInstance():RemoveUIDialog(self:GetWindow())

	LogInfo("ButtonDlg OnCreate finish")
end

function ButtonDlg:GetX( row )
	return self.m_btns[row].position.x
end

function ButtonDlg:GetY( row )
	return self.m_btns[row].position.y
end

return ButtonDlg

