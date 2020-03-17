--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/10/4
    Time: 14:53
   ]]

_G.RemindFuncTipsFrame = {};
RemindFuncTipsFrame.autoCloseTimerKey = nil;
function RemindFuncTipsFrame:new()
	local obj = setmetatable({}, { __index = self });
	obj.id = 0;
	obj.funcId = 0;
	obj.yunYingId = 0;
	obj.enabled = false;
	obj.bgURL = "";
	obj.contentURL = "";
	obj.pos = 0;
	obj.mc = nil;
	obj.closeCallBack = nil;
	obj.execFunc = nil;
	obj.promptLimitTime = 0; --毫秒值 弹框限制时间，如果为0则为没有限制。大于0则对应多少毫秒内不能弹出
	obj.lastPromptTime = 0;
	obj.originalBtnFunc = nil;
	obj.offsetX = 0;
	obj.offsetY = 0;
	obj.funcButton = nil;
	return obj;
end

function RemindFuncTipsFrame:GetId()
	return self.id;
end

function RemindFuncTipsFrame:GetFuncId()
	return self.funcId;
end

function RemindFuncTipsFrame:GetYunYingId()
	return self.yunYingId;
end

function RemindFuncTipsFrame:GetEnabled()
	return self.enabled;
end

function RemindFuncTipsFrame:SetExecFunc(func)
	self.execFunc = func;
end

function RemindFuncTipsFrame:Init()
	if not self.id then return; end
	local cfg = t_funcremindtips[self.id];
	if not cfg then return; end
	self.funcId = toint(cfg.fun_id);
	self.yunYingId = toint(cfg.yun_id);
	self.enabled = cfg.enabled;
	self.bgURL = ResUtil:GetRemindFuncTipsBG(cfg.bg_name);
	self.contentURL = ResUtil:GetRemindFuncTipsContent(cfg.content_name);
	self.pos = toint(cfg.pos);
	self.offsetX = toint(cfg.offset_x);
	self.offsetY = toint(cfg.offset_y);
	self.promptLimitTime = toint(cfg.open_interval) * 1000;
end

function RemindFuncTipsFrame:InitView(mcView, closeCallBack)
	self.mc = mcView;
	self.closeCallBack = closeCallBack;
	--更新界面显示
	if not self.mc then return; end
	local mc = self.mc;
	local callFunc = function()
		if self.closeCallBack then
			self.closeCallBack();
			self.closeCallBack = nil;
		end
	end
	mc.content.click = callFunc;
	mc.content.btnClose.click = callFunc;
	mc.content.bgLoader.source = self.bgURL;
	mc.content.contentLoader.source = self.contentURL;
	local button = self:GetTargetButton();
	--设置位置

	self.funcButton = button;
	self:Layout(mc, self.pos, button);

	--覆盖按钮方法,当点击这个功能按钮的时候关闭TIPS
	--重置按钮点击(看不懂的就不要改这段代码)
	self.originalBtnFunc = button.click;
	local metatable = {
		__call = function(s, func, index)
			s[index or #s + 1] = assert(func);
		end
	};
	local s = setmetatable({}, metatable);
	button.click = function(...)
		for i, f in ipairs(s) do
			if f(...) == false then break end
		end
		local i = 0
		while s[i] do
			if s[i](...) == false then break end
			i = i - 1
		end
	end
	button.click = s;
	if self.originalBtnFunc then
		button.click(self.originalBtnFunc);
	end
	button.click(function()
		if self.closeCallBack then
			self.closeCallBack();
		end
	end);

	TimerManager:UnRegisterTimer(self.autoCloseTimerKey)
	self.autoCloseTimerKey = nil;
	--自动关闭
	self.autoCloseTimerKey = TimerManager:RegisterTimer(function()
		TimerManager:UnRegisterTimer(self.autoCloseTimerKey)
		self.autoCloseTimerKey = nil;
		callFunc();
	end, RemindFuncTipsConsts.AUTO_CLOSE_DELAY, 1);
end

function RemindFuncTipsFrame:Layout(mc, posType, button)
	if not mc then return; end
	if not button then return; end
	local buttonPos = UIManager:PosLtoG(button);

	local btnW = button.width or button._width or 68;
	local btnH = button.height or button._height or 68;
	if posType == 7 then --左下
		mc._x = buttonPos.x - mc._width;
		mc._y = buttonPos.y + btnH;
	elseif posType == 8 then --右下
		mc._x = buttonPos.x + btnW;
		mc._y = buttonPos.y + btnH;
	end
	mc._x = mc._x + self.offsetX;
	mc._y = mc._y + self.offsetY;
end


function RemindFuncTipsFrame:Execute()
	if self.funcId > 0 and not FuncManager:GetFuncIsOpen(self.funcId) then return; end
	self:DoExec();
end


function RemindFuncTipsFrame:DoExec()
	if not self:GetEnabled() then return; end
	if not self.execFunc then return; end
	if self.funcId > 0 and not FuncManager:GetFuncIsOpen(self.funcId) then return; end
	--检查上一次提示时间间隔
	if (GetCurTime() - self.lastPromptTime) < self.promptLimitTime then
		return;
	end

	local result = self:execFunc(self);
	--这里写符合条件后的打开面板逻辑
	if result then
		RemindFuncTipsController:ShowTip(self:GetId())
	end
	return result;
end

function RemindFuncTipsFrame:DoPromptTimer()
	self.lastPromptTime = GetCurTime();
end

function RemindFuncTipsFrame:RemoveView()
	if not self.mc then return; end
	self.mc:removeMovieClip();
	self.mc = nil;
	self.closeCallBack = nil;
	TimerManager:UnRegisterTimer(self.autoCloseTimerKey)
	self.autoCloseTimerKey = nil;
	if self.originalBtnFunc then
		local button = self:GetTargetButton();
		button.click = nil;
		button.click = self.originalBtnFunc;
		self.originalBtnFunc = nil;
	end
	self.funcButton = nil;
end

function RemindFuncTipsFrame:Update()
	if not self.mc then return; end
	if not self.funcButton then return; end
	local button = self.funcButton
	self:Layout(self.mc, self.pos, button);
end

function RemindFuncTipsFrame:GetTargetButton()
	local button;
	if self.funcId > 0 then
		local parentFuncID = self.funcId;

		local funcCfg = t_funcOpen[self.funcId];
		if funcCfg then
			if funcCfg.parentId > 0 then
				parentFuncID = funcCfg.parentId;
			end
		end
		local func = FuncManager:GetFunc(parentFuncID);
		if not func then return; end
		button = func:GetButton();
		if not button then
			WriteLog(LogType.Normal, true, "RemindFuncTipsFrame.lua<RemindFuncTipsFrame:InitView>98 : ", self.funcId)
			return;
		end
	elseif self.yunYingId > 0 then
		button = YunYingUti:GetBtnPos(self.yunYingId);
		if not button then
			WriteLog(LogType.Normal, true, "RemindFuncTipsFrame.lua<RemindFuncTipsFrame:InitView>104 : ", self.yunYingId)
			return;
		end
	end
	return button;
end