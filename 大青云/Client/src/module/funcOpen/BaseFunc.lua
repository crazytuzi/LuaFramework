--[[
功能开启基类
lizhuangzhuang
2014年11月3日16:43:05
]]

_G.BaseFunc = {};

function BaseFunc:new(cfg)
	local obj = setmetatable({},{__index=self});
	obj.cfg = cfg;
	obj.funcKeyCode = nil;
	obj:InitCfg();
	return obj;
end

function BaseFunc:InitCfg()
	if self.cfg.defaultOpen then
		self.state = FuncConsts.State_Open;
	else
		self.state = FuncConsts.State_UnOpen;
	end
	if self.cfg.parentId > 0 or self.cfg.iconPos == "" then
		self.pos = 0;
		self.line = 0;
		self.index = 0;
	else
		local t = split(self.cfg.iconPos,",");
		self.pos = tonumber(t[1]);
		self.line = tonumber(t[2]);
		self.index = tonumber(t[3]);
	end
end

--获取配置
function BaseFunc:GetCfg()
	return self.cfg;
end

--功能id
function BaseFunc:GetId()
	return self.cfg.id;
end

--功能名
function BaseFunc:GetName()
	return self.cfg.name;
end

--位置
function BaseFunc:GetPos()
	return self.pos;
end

--行
function BaseFunc:GetLine()
	return self.line;
end

--行内索引
function BaseFunc:GetIndex()
	return self.index;
end

--库链接名
function BaseFunc:GetLibUrl()
	return self.cfg.libUrl;
end

--开启类型
function BaseFunc:GetOpenType()
	return self.cfg.open_type;
end
--是否需要点击开启
function BaseFunc:GetIsClickOpen()
	return self.cfg.click_open;
end

--设置功能快捷键
--@param keyCode nil,使用配表快捷键;-1,无快捷键
function BaseFunc:SetFuncKey(keyCode)
	self.funcKeyCode = keyCode;
end

--功能快捷键
function BaseFunc:GetFuncKey()
	if self.funcKeyCode then
		return self.funcKeyCode;
	end
	if self.funcKeyCode == -1 then
		return nil;
	end
	if self.cfg.quickKey == "" then
		return nil;
	end
	local keyCode = tonumber(self.cfg.quickKey);
	if keyCode then
		return keyCode;
	end
	if _System[self.cfg.quickKey] then
		return _System[self.cfg.quickKey];
	end
	return nil;
end

--当前状态
function BaseFunc:GetState()
	if self:GetCfg().isHide == 1 then
		return FuncConsts.State_UnOpen;
	end
	return self.state;
end

function BaseFunc:SetState(state)
	self.state = state;
	if self:GetCfg().isHide == 1 then
		self.state = FuncConsts.State_UnOpen;
	end
	self:OnStateChange();
	FuncOpenController:CheckFuncRightOpen()
end
--按天数开启的功能提示天数
function BaseFunc:GetOpenDay()
	return self.day;
end

function BaseFunc:SetOpenDay(day)
	self.day = day;
end
--按天数开启的功能提示状态
function BaseFunc:GetDayState()
	return self.dayState;
end

function BaseFunc:SetDayState(dayState)
	self.dayState = dayState;
	self:OnDayStateChange();
end
function BaseFunc:OnStateChange()
	if not self.button then return; end
	if self.state == FuncConsts.State_Open then
		self.button.disabled = false;
	elseif self.state == FuncConsts.State_ReadyOpen then
		self.button.disabled = true;
	end
end

function BaseFunc:OnDayStateChange()

end

--功能开启时
function BaseFunc:OnFuncOpen()

end

--按钮收缩时
function BaseFunc:OnFuncContraction()
	
end

--切换场景
function BaseFunc:OnChangeSceneMap()

end

--设置按钮
function BaseFunc:SetButton(mc)
	if self.button then
		self:RemoveButton();
	end
	self.button = mc;
	self.button.alwaysRollEvent = true;
	self.button.click = function() self:OnBtnClick(); end
	self.button.rollOver = function() self:OnBtnRollOver(); end
	self.button.rollOut = function() self:OnBtnRollOut(); end
	self:OnStateChange();
	if self.button.initialized then
		self:OnBtnInit();
	else
		self.button.buttonInit = function()
			self:OnBtnInit();
		end
	end
end

function BaseFunc:GetButton()
	return self.button;
end

--按钮初始化
function BaseFunc:OnBtnInit()

end
--按钮是否显示 
function BaseFunc:IsShow()
   return true
end

--移除按钮
function BaseFunc:RemoveButton()
	if not self.button then
		return;
	end
	self.button.click = nil;
	self.button.rollOver = nil;
	self.button.rollOut = nil;
	self.button = nil;
end

--获取按钮的全局坐标
function BaseFunc:GetBtnGlobalPos()
	if not self.button then
		return _sys:getRelativeMouse();
	end
	return UIManager:PosLtoG(self.button,0,0);
end

--点击按钮
function BaseFunc:OnBtnClick()
	if self.state == FuncConsts.State_Open then
		FuncManager:OpenFunc(self:GetId(),true);
	end
end

--鼠标移上按钮
function BaseFunc:OnBtnRollOver()
	if self.state == FuncConsts.State_Open then                          -- 功能已开启
		if self.cfg.tips ~= "" then
			local funcKeyCode = self:GetFuncKey();
			if funcKeyCode then
				if SetSystemConsts.KeyConsts[funcKeyCode] then
					local str = string.format(self.cfg.tips,SetSystemConsts.KeyConsts[funcKeyCode]);
					TipsManager:ShowBtnTips(str);
				else
					TipsManager:ShowBtnTips(string.format(self.cfg.tips,""));
				end
			else
				TipsManager:ShowBtnTips(self.cfg.tips);
			end
		end
	elseif self.state == FuncConsts.State_ReadyOpen then                 --功能即将开启
		if self.cfg.readyOpenTips ~= "" then
			TipsManager:ShowBtnTips(self.cfg.readyOpenTips);
		end
	elseif self.state == FuncConsts.State_UnOpen then
		if self.cfg.readyOpenTips ~= "" then
			TipsManager:ShowBtnTips(self.cfg.rightOpenTips);
		end
	end
end

--鼠标移出按钮
function BaseFunc:OnBtnRollOut()
	TipsManager:Hide();
end

--获取功能开启时飞的位置
--返回nil时根据UI位置去计算
function BaseFunc:GetFlyPos()
	return nil;
end

-- 判断一个功能是不是已经完全开启 date: 2016/11/26 16:22:36 adder:houxudong
function BaseFunc:GetFuncOpenState( )
	local openState = false
	if self.state == FuncConsts.State_Open and self:GetDayState() == FuncConsts.State_FunOpened or self.state == FuncConsts.State_Open and self:GetDayState() == nil then
		openState = true
	end
	return openState
end
