--[[
    Created by IntelliJ IDEA.
     功能开启提醒，显示在游戏右下角的
    User: Hongbin Yang
    Date: 2016/8/26
    Time: 15:49
   ]]

_G.RemindFuncBase = {};

function RemindFuncBase:new()
	local obj = setmetatable({}, { __index = self });
	obj.id = 0;
	obj.funcId = 0;
	obj.isOpening = false;
	obj.isCheckOnFuncOpen = false;
	obj.isCheckOnEnterGame = false;
	obj.isCheckOnNewItemInBag = false;
	obj.checkNewItemList = {};
	obj.execFunc = nil;
	obj.timerKey = nil;
	obj.isTimer = false;
	obj.timerInterval = nil;
	obj.promptLimitTime = 0; --毫秒值 弹框限制时间，如果为0则为没有限制。大于0则对应多少毫秒内不能弹出
	obj.lastPromptTime = 0;
	obj.hasCondition = false;
	obj.args = nil;
	obj.onClickConfirm = nil;
	return obj;
end

function RemindFuncBase:Init()
	if not self.id then return; end
	local cfg = t_funcremind[self.id];
	self.funcId = toint(cfg.fun_id);
	if cfg.whether == "1" then
		self.isOpening = true;
	elseif cfg.whether == "0" then
		self.isOpening = false;
	end
	self.timerInterval = {};
	local intervalItems = GetPoundTable(cfg.open_interval);
	if intervalItems then
		for k, v in pairs(intervalItems) do
			local intervalOne = GetCommaTable(v);
			local vo = {};
			vo.minLv = toint(intervalOne[1]);
			vo.maxLv = toint(intervalOne[2]);
			vo.interval = toint(intervalOne[3]);
			table.push(self.timerInterval, vo);
		end
	end


	if toint(cfg.fun_open) == 1 then
		self.isCheckOnFuncOpen = true;
	else
		self.isCheckOnFuncOpen = false;
	end
	if toint(cfg.thread) == 1 then
		self.isCheckOnEnterGame = true;
	else
		self.isCheckOnEnterGame = false;
	end
	if toint(cfg.examine) == 1 then
		self.isCheckOnNewItemInBag = true;
	else
		self.isCheckOnNewItemInBag = false;
	end
	self.checkNewItemList = split(cfg.coincidentitem, "|");
	for k, v in pairs(self.checkNewItemList) do
		self.checkNewItemList[k] = toint(v);
	end
	if toint(cfg.isCondition) == 1 then
		self.hasCondition = true;
	else
		self.hasCondition = false;
	end
end

function RemindFuncBase:GetId()
	return self.id;
end

function RemindFuncBase:GetFuncId()
	return self.funcId;
end

function RemindFuncBase:GetIsOpening()
	return self.isOpening;
end

function RemindFuncBase:GetTimerInterval()
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	for k, v in pairs(self.timerInterval) do
		if level >= v.minLv and level <= v.maxLv then
			return v.interval * 1000;
		end
	end
	return 1;
end

function RemindFuncBase:IsCheckOnFuncOpen()
	return self.isCheckOnFuncOpen;
end

function RemindFuncBase:IsCheckOnEnterGame()
	return self.isCheckOnEnterGame;
end

function RemindFuncBase:IsCheckOnNewItemInBag()
	return self.isCheckOnNewItemInBag;
end

function RemindFuncBase:CheckNewItem(newItemID)
	if #self.checkNewItemList == 0 then
		return true;
	end
	local result = false;
	for k, v in pairs(self.checkNewItemList) do
		if v == newItemID then
			result = true;
		end
	end
	return result;
end

function RemindFuncBase:HasCondition()
	return self.hasCondition;
end

function RemindFuncBase:SetArgs(...)
	self.args = {...};
end

function RemindFuncBase:GetArgs()
	return self.args;
end

function RemindFuncBase:SetOnClickConfirm(func)
	self.onClickConfirm = func;
end

function RemindFuncBase:GetOnClickConfirm()
	return self.onClickConfirm;
end

function RemindFuncBase:ExecOnClickConfirm()
	if not self.onClickConfirm then return; end
	self:onClickConfirm(self)
end

function RemindFuncBase:SetExecFunc(func)
	self.execFunc = func;
end

function RemindFuncBase:GetExecFunc()
	return self.execFunc;
end

function RemindFuncBase:Execute()
	if not FuncManager:GetFuncIsOpen(self:GetFuncId()) then return; end
	if not self:GetIsOpening() then return; end
	--首先执行一次
	local isExecute = false;
	if self.isTimer == false then
		isExecute = self:DoExec();
	end
	--检测下是否需要计时器,计时器轮训不再使用，改为一种限制CD了
	--[[
	if isExecute then
		self:ExecuteAutoTimer();
	end
	]]
end

function RemindFuncBase:ExecuteAutoTimer()
	if self.timerInterval and #self.timerInterval > 0 then
		if self.isTimer == false then
			self.timerKey = TimerManager:RegisterTimer(function() self:DoExec(); end, self:GetTimerInterval(), 0);
			self.isTimer = true;
		end
	end
end

function RemindFuncBase:DoExec()
	if not self.execFunc then return; end
	if not FuncManager:GetFuncIsOpen(self:GetFuncId()) then return; end
	if not self:GetIsOpening() then return; end
	--检查等级是否符合条件
	local cfg = t_funcremind[self.id];
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	if myLevel >= cfg.maxlevel then return; end
	--检查道具是否符合
	if not self:CheckItemEnough() then return; end
	--检查上一次提示时间间隔
	if (GetCurTime() - self.lastPromptTime) < self.promptLimitTime then
		return ;
	end

	local result = self:ExecFunc();
	--这里写符合条件后的打开面板逻辑
	if result then
		RemindFuncManager:AddToShow(self:GetId());
	end
	return result;
end

function RemindFuncBase:ExecFunc()
	return self:execFunc(self);
end

function RemindFuncBase:DoPromptTimer()
	self.lastPromptTime = GetCurTime();
end

function RemindFuncBase:CheckItemEnough()
	local cfg = t_funcremind[self.id];
	if not cfg then return false; end
	if cfg.quantity == "" then return true; end
	local itemStr = split(cfg.quantity, "|");
	for k, v in pairs(itemStr) do
		local itemInfo = GetCommaTable(v);
		local itemID = toint(itemInfo[1]);
		local itemCount = toint(itemInfo[2]);
		if BagModel:GetItemNumInBag(itemID) >= itemCount then
			return true;
		end
		if MainPlayerModel.humanDetailInfo[itemID] and MainPlayerModel.humanDetailInfo[itemID] >= itemCount then
			return true;
		end
	end
	return false;
end
