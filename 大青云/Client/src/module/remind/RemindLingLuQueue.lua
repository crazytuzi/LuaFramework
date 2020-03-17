--[[
	定时副本提示
	2015年5月6日, PM 09:27:23
	wangyanwei
]]
_G.RemindLingLuQueue = setmetatable({},{__index=RemindQueue});

function RemindLingLuQueue:GetType()
	return RemindConsts.Type_LingLu;
end;

function RemindLingLuQueue:GetLibraryLink()
	return "RemindLingLu";
end;

--是否显示
function RemindLingLuQueue:GetIsShow()
	return self.isshow;
end

function RemindLingLuQueue:GetPos()
	return 2;
end;

function RemindLingLuQueue:GetShowIndex()
	return 33;
end;

function RemindLingLuQueue:GetBtnWidth()
	return 282;
end

function RemindLingLuQueue:GetBtnHeight()
	return 130;
end

--
RemindLingLuQueue.state = nil;
RemindLingLuQueue.objData = nil;
function RemindLingLuQueue:AddData(data)
	local boo = data.state == 1;
	self.objData = data;
	if self.oldHour ~= self.objData.hourNum or self.oldState ~= self.objData.state then
		self.isshow = true;
	else
		self.isshow = false;
	end
	if self.button then
		local func =function()
			if boo then
				self.button.tf1.text = '后关闭'
				local min1,sec1 = self:OnBackNowLeaveTime((1800 - data.minNum * 60) - data.secNum);
				self.button.tf2.text =  min1 .. ':' .. sec1;
			else
				self.button.tf1.text = '后开启'
				local min1,sec1 = self:OnBackNowLeaveTime((60 - data.minNum) * 60 - data.secNum);
				self.button.tf2.text =  min1 .. ':' .. sec1;
			end
			-- if sec1 == '01' then
				-- self:DoClick();
			-- end
			if (1800 - data.minNum * 60) - data.secNum == 1 then
				self.timeKey = TimerManager:RegisterTimer(function () 
				self.isshow = false;
				self:RefreshData();
				end,2000,1);
			end
		end
		if self.button.initialized then
			func();
		elseif self.button.init then 
			func();
		end
	end
	--self:RefreshData();
end

--新版要重写的两个方法
-- OnBtnInit 注册鼠标事件
-- OnBtnShow 绘制UI上的数据
-- ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
--按钮初始化 
function RemindLingLuQueue:OnBtnInit()
	if self.button then
		self.button.tf3.text = t_monkeytime[1].opentime;
		self.button.tf4.text = UIStrConfig['timeDungeon251'];
		self.button.tf5.text = UIStrConfig['timeDungeon204'];
		self.button.tf6.htmlText = UIStrConfig['timeDungeon205'];
		self.button.tf8.text = UIStrConfig['timeDungeon201'];
		self.button.btn_close.click = function () self:DoCloseClick() end
		self.button.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
		self.button.rewardList.itemRollOut = function () TipsManager:Hide(); end
	end
end

function RemindLingLuQueue:OnBtnShow()
	if not self.button then
		return 
	end
	local cfg = t_monkeytime[1];
	local rewardList = RewardManager:Parse(cfg.firstReward);
	self.button.rewardList.dataProvider:cleanUp();
	self.button.rewardList.dataProvider:push(unpack(rewardList));
	self.button.rewardList:invalidateData();
end

function RemindLingLuQueue:OnTimeHide()
	
	
end

function RemindLingLuQueue:OnBackNowLeaveTime(num)
	local hour,min,sec = CTimeFormat:sec2format(num);
	if min < 10 then min = '0' .. min; end
	if sec < 10 then sec = '0' .. sec; end
	return min,sec
end

RemindLingLuQueue.isshow = true;
RemindLingLuQueue.oldHour = nil;
RemindLingLuQueue.oldState = nil;
function RemindLingLuQueue:DoClick()
	-- UITimerDungeon:Show();
	FuncManager:OpenFunc(FuncConsts.TimeDugeon);
	self.isshow = self.oldHour == self.objData.hourNum and self.oldState == self.objData.state;
	self.oldHour,self.oldState = self.objData.hourNum , self.objData.state;
	self.isshow = false;
	self:RefreshData();
end

function RemindLingLuQueue:DoCloseClick()
	self.isshow = self.oldHour == self.objData.hourNum and self.oldState == self.objData.state;
	self.oldHour,self.oldState = self.objData.hourNum , self.objData.state;
	self.isshow = false;
	self:RefreshData();
end

function RemindLingLuQueue:DoRollOver()
	-- if not UITimeDungeinTips:IsShow() then
		-- UITimeDungeinTips:Show();
	-- end
end
--鼠标移出处理
function RemindLingLuQueue:DoRollOut()
	-- UITimeDungeinTips:Hide();
end