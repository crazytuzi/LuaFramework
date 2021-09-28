HuashanzhidianBtn = {}

setmetatable(HuashanzhidianBtn, Dialog);
HuashanzhidianBtn.__index = HuashanzhidianBtn;

local _instance;

function HuashanzhidianBtn.getInstance()
	if _instance == nil then
		_instance = HuashanzhidianBtn:new();
		_instance:OnCreate();
	end

	return _instance;
end

function HuashanzhidianBtn.getInstanceNotCreate()
	return _instance;
end

function HuashanzhidianBtn.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
		print("HuashanzhidianBtn DestroyDialog")
	end
end

function HuashanzhidianBtn.getInstanceAndShow()
    if not _instance then
        _instance = HuashanzhidianBtn:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end

    return _instance
end

function HuashanzhidianBtn.ToggleOpenClose()
	if not _instance then 
		_instance = HuashanzhidianBtn:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function HuashanzhidianBtn.GetLayoutFileName()
	return "huashanzhidianbtn.layout"
end

function HuashanzhidianBtn:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, HuashanzhidianBtn);
	return zf;
end

------------------------------------------------------------------------------
function HuashanzhidianBtn:OnCreate()
	print("HuashanzhidianBtn OnCreate")
	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton();
	self.m_btn = CEGUI.Window.toScrollablePane(winMgr:getWindow("huashanzhidianbtn/button"))
	self.m_btn:subscribeEvent("MouseClick", self.HandleBtnClicked, self)

	print("HuashanzhidianBtn OnCreate finish")
end

function HuashanzhidianBtn:HandleBtnClicked()
	record = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.claren"):getRecorder(8)
	GetMessageManager():AddConfirmBox(eConfirmNormal, record.content 
		, self.HandleAccepted, self, CMessageManager.HandleDefaultCancelEvent, CMessageManager)
end

function HuashanzhidianBtn:HandleAccepted()
	GetMessageManager():CloseConfirmBox(eConfirmNormal, false)
	local p = require "protocoldef.knight.gsp.faction.cagreedrawrole" : new()
    p.agree = 1 
    p.flag = 8
    require "manager.luaprotocolmanager":send(p)
end

return HuashanzhidianBtn



