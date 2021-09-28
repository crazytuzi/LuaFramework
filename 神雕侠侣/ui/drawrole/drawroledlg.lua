DrawRoleDlg = {}

setmetatable(DrawRoleDlg, Dialog);
DrawRoleDlg.__index = DrawRoleDlg;

local _instance;

function DrawRoleDlg.getInstance()
	if _instance == nil then
		_instance = DrawRoleDlg:new();
		_instance:OnCreate();
	end

	return _instance;
end

function DrawRoleDlg.getInstanceNotCreate()
	return _instance;
end

function DrawRoleDlg.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
		LogInfo("DrawRoleDlg DestroyDialog")
	end
end

function DrawRoleDlg.getInstanceAndShow()
    if not _instance then
        _instance = DrawRoleDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function DrawRoleDlg.ToggleOpenClose()
	if not _instance then 
		_instance = DrawRoleDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function DrawRoleDlg.GetLayoutFileName()
	return "huodonglaren.layout";
end

function DrawRoleDlg:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, DrawRoleDlg);

	return zf;
end

------------------------------------------------------------------------------

function DrawRoleDlg:OnCreate()
	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton();
	self.m_okBtn = winMgr:getWindow("huodonglaren/btn0");
	self.m_cancelBtn  = winMgr:getWindow("huodonglaren/btn1");
	self.m_waitBtn  = winMgr:getWindow("huodonglaren/btn11");
	self.m_txtLable = winMgr:getWindow("huodonglaren/txt");

	self.m_okBtn:subscribeEvent("MouseClick", DrawRoleDlg.HandleOkClicked, self);
	self.m_cancelBtn:subscribeEvent("MouseClick", DrawRoleDlg.HandleCancelClicked, self);
	self.m_waitBtn:subscribeEvent("MouseClick", DrawRoleDlg.HandleWaitClicked, self);
	
	self.m_okTextOrg = self.m_okBtn:getText()
end

function DrawRoleDlg:HandleOkClicked(arg)
	DrawRoleManager:getInstance():drawAccepted()
end

function DrawRoleDlg:HandleCancelClicked(arg)
	DrawRoleManager:getInstance():drawCancel()
end

function DrawRoleDlg:HandleWaitClicked(arg)
	DrawRoleManager:getInstance():hideDetail()
end

function DrawRoleDlg:setText( text )
	self.m_txtLable:setText(text)
end

function DrawRoleDlg:setTime( time )
	local timeStr = "("..tostring(math.floor(time))..")"
	self.m_okBtn:setText(self.m_okTextOrg..timeStr)
end




