HuaShanZhiDianGuanJun = {}

setmetatable(HuaShanZhiDianGuanJun, Dialog);
HuaShanZhiDianGuanJun.__index = HuaShanZhiDianGuanJun;

local _instance;

function HuaShanZhiDianGuanJun.getInstance()
	if _instance == nil then
		_instance = HuaShanZhiDianGuanJun:new();
		_instance:OnCreate();
	end

	return _instance;
end

function HuaShanZhiDianGuanJun.getInstanceNotCreate()
	return _instance;
end

function HuaShanZhiDianGuanJun.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
		LogInfo("HuaShanZhiDianGuanJun DestroyDialog")
	end
end

function HuaShanZhiDianGuanJun.getInstanceAndShow()
    if not _instance then
        _instance = HuaShanZhiDianGuanJun:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function HuaShanZhiDianGuanJun.ToggleOpenClose()
	if not _instance then 
		_instance = HuaShanZhiDianGuanJun:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function HuaShanZhiDianGuanJun.GetLayoutFileName()
	return "huashanzhidianguanjun.layout";
end

function HuaShanZhiDianGuanJun:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, HuaShanZhiDianGuanJun);

	return zf;
end

------------------------------------------------------------------------------

function HuaShanZhiDianGuanJun:OnCreate()
	LogInfo("HuaShanZhiDianGuanJun OnCreate ")
	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_lingqu = winMgr:getWindow("huashanzhidianguanjun/bot/fasong")

	self.m_lingqu:subscribeEvent("MouseClick", self.HandleLingQu, self)
	
	LogInfo("HuaShanZhiDianGuanJun OnCreate finish")
end

function HuaShanZhiDianGuanJun:HandleLingQu()
	local p = require "protocoldef.knight.gsp.item.cusedhuizhang" : new()
    require "manager.luaprotocolmanager":send(p)
    
    self.DestroyDialog()
end


