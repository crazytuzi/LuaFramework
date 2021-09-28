DrawRoleReminder = {}

setmetatable(DrawRoleReminder, Dialog);
DrawRoleReminder.__index = DrawRoleReminder;

local _instance;

function DrawRoleReminder.getInstance()
	if _instance == nil then
		_instance = DrawRoleReminder:new();
		_instance:OnCreate();
	end

	return _instance;
end

function DrawRoleReminder.getInstanceNotCreate()
	return _instance;
end

function DrawRoleReminder.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
	end
end

function DrawRoleReminder.getInstanceAndShow()
	LogInfo("DrawRoleReminder.getInstanceAndShow")
    if not _instance then
        _instance = DrawRoleReminder:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end

    return _instance
end

function DrawRoleReminder.ToggleOpenClose()
	if not _instance then 
		_instance = DrawRoleReminder:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function DrawRoleReminder.GetLayoutFileName()
	return "huodonglarenbtn.layout";
end

function DrawRoleReminder:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, DrawRoleReminder);

	return zf;
end

------------------------------------------------------------------------------

function DrawRoleReminder:OnCreate()
	Dialog.OnCreate(self);

	self.m_btns = {};
	local winMgr = CEGUI.WindowManager:getSingleton();
	self.m_btns[1] = winMgr:getWindow("huolonglarenbtn/imgbtn0");
	self.m_btns[2] = winMgr:getWindow("huolonglarenbtn/imgbtn1");
	self.m_btns[3] = winMgr:getWindow("huolonglarenbtn/imgbtn2");
	self.m_animBtn = winMgr:getWindow("huolonglarenbtn/imgbtn3");	

	local start = self.m_animBtn:getPosition()
	local stop = self.m_btns[1]:getPosition()
	self.m_animStart = CEGUI.UVector2(CEGUI.UDim(start.x.scale, start.x.offset),CEGUI.UDim(start.y.scale, start.y.offset))
	self.m_animEnd = CEGUI.UVector2(CEGUI.UDim(stop.x.scale, stop.x.offset),CEGUI.UDim(stop.y.scale, stop.y.offset))
	self.m_animTime = 1000
	self.m_animating = false
	self.m_time = 0

	self.m_btns[1]:setVisible(false)
	self.m_btns[2]:setVisible(false)
	self.m_btns[3]:setVisible(false)
	self.m_animBtn:setVisible(false)
	_instance:SetVisible(true)
	if GetBattleManager():IsInBattle() then
		_instance:SetVisible(false)
	end

	self.m_btns[1]:subscribeEvent("MouseClick", DrawRoleReminder.HandleBtnClicked1, self);
	self.m_btns[2]:subscribeEvent("MouseClick", DrawRoleReminder.HandleBtnClicked2, self);
	self.m_btns[3]:subscribeEvent("MouseClick", DrawRoleReminder.HandleBtnClicked3, self);
end

function DrawRoleReminder:startAnimation()
	self.m_animating = true
	self.m_time = 0
	self.m_animBtn:setPosition(self.m_animStart)
	self.m_animBtn:setVisible(true)
end

function DrawRoleReminder:run( delta )
	if not self.m_animating then return end
	self.m_time  = self.m_time + delta
	if self.m_time > self.m_animTime then
		self.m_animating = false
		DrawRoleManager:getInstance():updateReminder()
		self.m_animBtn:setVisible(false)
		return
	end
	local x = self.m_time / self.m_animTime
	local xscale  = self:interpolation(self.m_animStart.x.scale, self.m_animEnd.x.scale, x)
	local xoffset = self:interpolation(self.m_animStart.x.offset, self.m_animEnd.x.offset, x)
	local yscale  = self:interpolation(self.m_animStart.y.scale, self.m_animEnd.y.scale, x)
	local yoffset = self:interpolation(self.m_animStart.y.offset, self.m_animEnd.y.offset, x)
	self.m_animBtn:setPosition(CEGUI.UVector2(CEGUI.UDim(xscale, xoffset),CEGUI.UDim(yscale,yoffset)))
end

function DrawRoleReminder:interpolation( a, b, x )
	return a + (b - a) * x
end

function DrawRoleReminder:HandleBtnClicked1(arg)
	DrawRoleManager:getInstance():showDetailAtBtn(1)
end

function DrawRoleReminder:HandleBtnClicked2(arg)
	DrawRoleManager:getInstance():showDetailAtBtn(2)
end

function DrawRoleReminder:HandleBtnClicked3(arg)
	DrawRoleManager:getInstance():showDetailAtBtn(3)
end

function DrawRoleReminder:setBtnNum( num )
	for i = 1, 3 do
		if i <= num then
			self.m_btns[i]:setVisible(true)
		else
			self.m_btns[i]:setVisible(false)
		end
	end
end




