--[[
提醒队列基类
lizhuangzhuang
2014年10月22日16:44:23
]]

_G.RemindQueue = {};

RemindQueue.timerKey = nil;
RemindQueue.isTimer = false;
function RemindQueue:new()
	local obj = setmetatable({},{__index=self});
	obj.datalist = {};--数据列表
	obj.timerKey = nil;
	obj.isTimer = false;
	return obj;
end

--类型
function RemindQueue:GetType()
	return 0;
end

--按钮的库链接路径
function RemindQueue:GetLibraryLink()
	return nil;
end

--显示位置,1左侧,2右侧
function RemindQueue:GetPos()
	return 1;
end

--根据该字段排序
function RemindQueue:GetShowIndex()
	return 0;
end

--按钮宽
function RemindQueue:GetBtnWidth()
	return nil;
end

--按钮高
function RemindQueue:GetBtnHeight()
	return 0;
end

--获取代表自身的t_consts表的id
function RemindQueue:GetTConstsID()
	return 0;
end

--是否显示
function RemindQueue:GetIsShow()
	if self.datalist and #self.datalist>0 then
		return true;
	end
	return false;
end

--获取按钮上显示的数字
function RemindQueue:GetShowNum()
	if not self.datalist then return 0; end
	return #self.datalist;
end

--执行检测，如果有倒计时没完成，那么退出这个方法
function RemindQueue:Execute()
	local func = function()
		local constsID = self:GetTConstsID();
		if constsID == 0 then
			return self:CheckCondition();
		end
		if constsID > 0 then
			local consts = t_consts[constsID];
			if not consts then return; end
			local level = MainPlayerModel.humanDetailInfo.eaLevel;
			local minLv = consts.val1;
			local maxLv = consts.val2;
			if level >= minLv and level <= maxLv then
				return self:CheckCondition();
			end
		end
		return false;
	end
	local isExecute = false;
	--首先执行一次
	if self.isTimer == false then
		isExecute = func();
	end
	-- WriteLog(LogType.Normal, false, 'RemindQueue:Execute - ' .. self:GetType(), isExecute);
	--检测下是否需要计时器
	if isExecute then
		local cid = self:GetTConstsID();
		if cid > 0 and self.isTimer == false then
			local c = t_consts[cid];
			if c then
				local level = MainPlayerModel.humanDetailInfo.eaLevel;
				if level >= c.val1 and level <= c.val2 then
					self.timerKey = TimerManager:RegisterTimer(func, c.val3 * 1000, 0);
					self.isTimer = true;
				end
			end
		end
	end
end

function RemindQueue:CheckCondition()
	--子类按需重写
end

--添加数据
function RemindQueue:AddData(data)
	table.push(self.datalist,data);
end

--清空数据
function RemindQueue:ClearData()
	self.datalist = {};
end

--刷新数据到UI
function RemindQueue:RefreshData()
	Notifier:sendNotification(NotifyConsts.RemindRefresh,{type=self:GetType()});
end

function RemindQueue:GetButton()
	return self.button;
end

function RemindQueue:SetButton(mc)
	--[[
	if self.button then
		Debug("Error:Has find a button in queue");
		return;
	end
	]]
	self.button = mc;
	self.button.click = function() self:DoClick(); end
	self.button.rollOver = function() self:DoRollOver(); end
	self.button.rollOut = function() self:DoRollOut(); end
	self.button.close = function() self:DoClose(); end
	--
	if self.button.initialized then
		self:OnBtnInit();
	else
		print("Remind button not initialized");
		--延迟处理
		TimerManager:RegisterTimer(function()
			self:OnBtnInit();
		end,1000,1);
	end
end

--按钮初始化
function RemindQueue:OnBtnInit()

end

function RemindQueue:ShowButton()
	if self.btnIsShow then return; end
	self.btnIsShow = true;
	self.button.visible = true;
	if self.button.initialized then
		self:OnBtnShow();
	else
		self.button.init = function()
			self:OnBtnShow();
		end
	end
end

function RemindQueue:HideButton()
	if self.btnIsShow then
		self.btnIsShow = false;
		self.button.visible = false;
		self:OnBtnHide();
	end
end


--按钮显示
function RemindQueue:OnBtnShow()
	if self.button.eff then
		if self.button.eff.initialized then
			self.button.eff:playEffect(0);
		else
			self.button.eff.init = function()
				self.button.eff:playEffect(0);
			end
		end
	end
end

--按钮隐藏
function RemindQueue:OnBtnHide()
	if self.button.eff then
		self.button.eff.init = nil;
		self.button.eff:stopEffect();
	end
end

--点击处理
function RemindQueue:DoClick()

end

--鼠标移上
function RemindQueue:DoRollOver()
end

--鼠标移出处理
function RemindQueue:DoRollOut()

end

--关闭处理
function RemindQueue:DoClose()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end