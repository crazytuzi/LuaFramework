--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/8/27
    Time: 17:03
   ]]

_G.RemindFuncView = BaseUI:new("UIRemindFuncView");

RemindFuncView.id = 0;
RemindFuncView.funcId = 0;
RemindFuncView.originalUIClass = nil;
RemindFuncView.originalFunc = nil;
function RemindFuncView:Create()
	self:AddSWF("funcRemindPanel.swf", true, "bottomFloat");
end

function RemindFuncView:InitView(objSwf)
	-- 界面加载完成后的
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	local cfg = t_funcremind[self.id];
	if not cfg then return; end;
	self.funcId = cfg.fun_id;
	objSwf.tfTitle.htmlText = cfg.title;
	objSwf.tfContent.htmlText = cfg.content;
	objSwf.btnConfirm.label = cfg.btntxt;
	objSwf.btnConfirm.click = function() self:OnConfirmClickHandler() end;

	--更新禁用提示内容
	if cfg.hinttime == 0 then
		objSwf.noPromptCheck._visible = false;
	elseif cfg.hinttime == 1 then
		objSwf.noPromptCheck._visible = true;
		objSwf.noPromptCheck.label = StrConfig["remindfunc1"];
	elseif cfg.hinttime == 2 then
		objSwf.noPromptCheck._visible = true;
		objSwf.noPromptCheck.label = StrConfig["remindfunc2"];
	end
	objSwf.noPromptCheck.selected = false;
end

function RemindFuncView:OnShow()
	if #self.args <= 0 then return; end

	self.id = self.args[1];
	self:InitView(self.objSwf);
	self.objSwf.btnConfirm:showEffect(ResUtil:GetButtonEffect10());
end

function RemindFuncView:OnConfirmClickHandler()
	local rf = RemindFuncController.remindList[self.id];
	if not rf then return; end
	if rf:GetOnClickConfirm() then
		rf:ExecOnClickConfirm();
	else
		FuncManager:OpenFunc(self.funcId);
	end

	local parentFuncID = self.funcId;

	local funcCfg = t_funcOpen[self.funcId];
	if funcCfg then
		if funcCfg.parentId > 0 then
			parentFuncID = funcCfg.parentId;
		end
	end
	local uiName = FuncConsts.UIMap[parentFuncID];
	if uiName then
		local ui = UIManager:GetUI(uiName);
		if ui then
			--重置面板OnHide(采用lua元编程处理)
			self.originalUIClass = ui;
			self.originalFunc = ui.OnHide;

			local metatable = {
			__call = function(s,func,index,class)
					if index and index > 0 then
						s[index or #s+1] = {assert(func),class};
					end
					if not index or index <= 0 then
						for i, f in ipairs(s) do
							if f[1](f[2])==false then break end
						end
						local i = 0
						while s[i] do
							if s[i][1](s[i][2])==false then break end
							i = i-1
						end
					end
				end
			};
			local s = setmetatable({},metatable);
			ui.OnHide = s;
			if self.originalFunc then
				ui.OnHide(self.originalFunc, 1, ui);
			end
			ui.OnHide(function()
				self:DoCloseAndShowNext();
			end, 2, self);
		end
	end

	self:Hide();
end

--获取提示计时间隔时间
function RemindFuncView:GetPromptTime()
	if self.objSwf.noPromptCheck.selected == false then return 0; end
	local cfg = t_funcremind[self.id];
	if not cfg then return; end;
	local time = 0;
	if cfg.hinttime == 0 then
		time = 0;
	elseif cfg.hinttime == 1 then
		time = 999999999;--本次登录
	elseif cfg.hinttime == 2 then
		time = 60 * 60 * 1000;--1小时
	end
	return time;
end

function RemindFuncView:DoCloseAndShowNext()
	--记一次时间
	RemindFuncController.remindList[self.id]:DoPromptTimer();
	--关闭设置提示间隔
	RemindFuncController.remindList[self.id].promptLimitTime = math.max(self:GetPromptTime(), RemindFuncController.remindList[self.id]:GetTimerInterval());
	RemindFuncManager:RemoveFirstOne();
	RemindFuncManager.isShowing = false
	TimerManager:RegisterTimer(function()
		RemindFuncManager:ShowNext()
	end, 10, 1);
	local ui = self.originalUIClass;
	if ui then
		ui.OnHide = nil;
		ui.OnHide = self.originalFunc;
		self.originalFunc = nil;
		self.originalUIClass = nil;
	end
end

function RemindFuncView:OnHide()
	self.objSwf.btnConfirm:clearEffect();
end



--[[
function RemindFuncView:GetWidth()
	return 464;
end

function RemindFuncView:GetHeight()
	return 218;
end]]

function RemindFuncView:IsTween()
	return true;
end

function RemindFuncView:GetPanelType()
	return 0;
end

function RemindFuncView:ESCHide()
	return false;
end

function RemindFuncView:IsShowLoading()
	return false;
end

function RemindFuncView:IsShowSound()
	return true;
end

--点击关闭按钮
function RemindFuncView:OnBtnCloseClick()
	self:DoCloseAndShowNext();
	self:Hide();
end

function RemindFuncView:NeverDeleteWhenHide()
	return true;
end

RemindFuncView.TweenScale = 50;
--打开效果
function RemindFuncView:TweenShowEff(callback)
	local objSwf = self.objSwf;
	local endX,endY = self:GetCfgPos();
	local startX = endX + self:GetWidth()/2 - self:GetWidth()*self.TweenScale/100/2;
	local startY = endY + self:GetHeight()/2 - self:GetHeight()*self.TweenScale/100/2;
	--
	objSwf._x = startX;
	objSwf._y = startY;
	objSwf._alpha = 50;
	objSwf._xscale = self.TweenScale;
	objSwf._yscale = self.TweenScale;
	--
	Tween:To( self.objSwf, 0.3, {_alpha = 100,_xscale=100,_yscale=100,_x=endX,_y=endY,ease=Back.easeInOut},
		{onComplete=callback});
end

--关闭效果
function RemindFuncView:TweenHideEff(callback)
	local objSwf = self.objSwf;
	local startX,startY = self:GetCfgPos();
	local endX = startX + self:GetWidth()/2 - self:GetWidth()*self.TweenScale/100/2;
	local endY = startY + self:GetHeight()/2 - self:GetHeight()*self.TweenScale/100/2;
	--
	objSwf._x = startX;
	objSwf._y = startY;
	objSwf._alpha = 100;
	objSwf._xscale = 100;
	objSwf._yscale = 100;
	--
	self.isTweenHide = true;
	Tween:To( self.objSwf, 0.3, {_alpha = 0,_xscale=self.TweenScale,_yscale=self.TweenScale,_x=endX,_y=endY,ease=Back.easeInOut},
		{onComplete=function()
			self.isTweenHide = false;
			callback();
		end});
end

function RemindFuncView:DoTweenShow()
	self:TweenShowEff(function()
		self:DoShow();
	end);
end

function RemindFuncView:DoTweenHide()
	self:TweenHideEff(function()
		self:DoHide();
	end);
end