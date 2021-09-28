local QiandaosongliBtn = {}

setmetatable(QiandaosongliBtn, Dialog);
QiandaosongliBtn.__index = QiandaosongliBtn;

local _instance;

function QiandaosongliBtn.getInstance()
	if _instance == nil then
		_instance = QiandaosongliBtn:new();
		_instance:OnCreate();
	end

	return _instance;
end

function QiandaosongliBtn.getInstanceNotCreate()
	return _instance;
end

function QiandaosongliBtn.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
		print("QiandaosongliBtn DestroyDialog")
	end
end

function QiandaosongliBtn.getInstanceAndShow()
    if not _instance then
        _instance = QiandaosongliBtn:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end

    return _instance
end

function QiandaosongliBtn.ToggleOpenClose()
	if not _instance then 
		_instance = QiandaosongliBtn:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function QiandaosongliBtn.GetLayoutFileName()
	return "qiandaosonglibtn.layout"
end

function QiandaosongliBtn:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, QiandaosongliBtn);
	return zf;
end

------------------------------------------------------------------------------
function QiandaosongliBtn:OnCreate()
	print("QiandaosongliBtn OnCreate")
	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton();
	self.m_btn = CEGUI.Window.toScrollablePane(winMgr:getWindow("qiandaosonglibtn/button"))
	self.m_btn:subscribeEvent("MouseClick", self.HandleBtnClicked, self)

	print("QiandaosongliBtn OnCreate finish")
end

function QiandaosongliBtn:HandleBtnClicked()
	require "ui.qiandaosongli.qiandaosonglidlg".getInstanceAndShow()
	local p = require "protocoldef.knight.gsp.activity.signin.cquerysignin":new()
    require "manager.luaprotocolmanager":send(p)
end

return QiandaosongliBtn
