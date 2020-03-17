--[[
任务脚本Step:点击按钮的基类处理
lizhuangzhuang
2014年9月14日18:48:11
]]

_G.QuestSSClickButton = setmetatable({},{__index=QuestScriptStep});

--要处理的按钮
QuestSSClickButton.button = nil;
--按钮原始点击函数
QuestSSClickButton.originalBtnFunc = nil;
--计时器ID
QuestSSClickButton.timerID = nil;
QuestSSClickButton.autoTimerID = nil;

--监听按钮
function QuestSSClickButton:ListenButton()
	if not (self.cfg.button and type(self.cfg.button)=="function") then
		print("Error:Quest Script Error.Cannot find button function");
		return false;
	end
	if not (self.cfg.Break and type(self.cfg.Break)=="function") then
		print("Error:Quest Script Error.Cannot find Break function");
		return false;
	end
	self.button = self.cfg.button();
	if not self.button then return false; end
	--重置按钮点击(看不懂的就不要改这段代码)
	self.originalBtnFunc = self.button.click;
	local metatable = {
		__call = function(s,func,index)
			s[index or #s+1] = assert(func);
		end
	};
	local s = setmetatable({},metatable);
	self.button.click = function(...)
		for i, f in ipairs(s) do
		  if f(...)==false then break end
		end
		local i = 0
		while s[i] do
		  if s[i](...)==false then break end
		  i = i-1
		end	
	end
	self.button.click = s;
	--
	if self.originalBtnFunc then
		self.button.click(self.originalBtnFunc);
	end
	self.button.click(function() self:OnButtonClick(); end);
	--画箭头
	if self.cfg.arrow then
		UIFuncGuide:Open({
			type = UIFuncGuide.Type_FuncGuide,
			showtype = UIFuncGuide.ST_Public,
			getButton = self.button,
			pos = self.cfg.arrowPos,
			offset = self.cfg.arrowOffset,
			btnMask = self.cfg.mask,
			text = self.cfg.text
		});
	end
	--监听UI关闭,做打断处理
	self.timerID = TimerManager:RegisterTimer(function()
		if self.cfg.Break() then
			TimerManager:UnRegisterTimer(self.timerID);
			self.timerID = nil;
			self.questScript:Break();
		end
	end,20,0);
	--自动进行下一步
	if self.cfg.autoTime and self.cfg.autoTime > 0 then
		if self.autoTimerID then
			TimerManager:UnRegisterTimer(self.autoTimerID);
			self.autoTimerID = nil;
		end
		self.autoTimerID = TimerManager:RegisterTimer(function()
			self.autoTimerID = nil;
			self.cfg.autoTimeFunc();
			self:Next();
		end,self.cfg.autoTime,1);
	end
	return true;
end

--还原按钮时间
function QuestSSClickButton:ResetButton()
	if self.originalBtnFunc then
		self.button.click = nil;
		self.button.click = self.originalBtnFunc;
		self.originalBtnFunc = nil;
	else
		if self.button then
			self.button.click = function() end;
		end
	end
end

--点击按钮处理
function QuestSSClickButton:OnButtonClick()
	self:Next();
end

function QuestSSClickButton:Enter()
	if self:ListenButton() then
		return true;
	else
		return false;
	end
end

function QuestSSClickButton:Exit()
	if self.timerID then
		TimerManager:UnRegisterTimer(self.timerID);
		self.timerID = nil;
	end
	if self.autoTimerID then
		TimerManager:UnRegisterTimer(self.autoTimerID);
		self.autoTimerID = nil;
	end
	if self.cfg.arrow then
		UIFuncGuide:Close(UIFuncGuide.Type_FuncGuide);
	end
	self:ResetButton();
	self.button = nil;
end
