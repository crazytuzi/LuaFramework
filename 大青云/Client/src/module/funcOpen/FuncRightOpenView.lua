--[[
主界面功能即将开启
lizhuangzhuang
2015年9月10日22:22:39
]]

_G.UIFuncRightOpen = BaseUI:new("UIFuncRightOpen");


UIFuncRightOpen.funcId = nil;
UIFuncRightOpen.modelDraw = nil;

function UIFuncRightOpen:Create()
	self:AddSWF("funcRightOpen.swf",nil,"bottom");
end

function UIFuncRightOpen:OnLoaded(objSwf)
	objSwf.panel.loader.hitTestDisable = true;
	objSwf.panel.btn.rollOver = function() self:OnRightOpenTipsOver(); end
	objSwf.panel.btn.rollOut = function() self:OnRightOpenTipsOut(); end
end


function UIFuncRightOpen:ShowRightOpen(funcId)
	if not funcId then
		self:Hide();
		self.funcId = nil;
		return;
	end
	self.funcId = funcId;
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end

function UIFuncRightOpen:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local func = FuncManager:GetFunc(self.funcId);
	if not func then
		return;
	end
	if self.modelDraw then
		self.modelDraw:Exit();
		self.modelDraw = nil;
	end
	if func:GetCfg().rightOpenModel == "" then
		objSwf.panel.loader._x = 0;
		objSwf.panel.loader._y = 0;
		objSwf.panel.loader.source = ResUtil:GetFuncIconUrl(func:GetCfg().icon,true);
	else
		if _G[func:GetCfg().rightOpenModel] then
			self.modelDraw = _G[func:GetCfg().rightOpenModel];
			self.modelDraw:Enter(objSwf.panel.loader);
		end
	end
	if func:GetCfg().open_type == 1 then
		objSwf.panel.tf.text = string.format("%s级开启%s",func:GetCfg().open_prama,func:GetName());
	else
		objSwf.panel.tf.text = func:GetCfg().rightOpenTxt;
	end
	self:ShowOpenPercent();
end

function UIFuncRightOpen:OnHide()
	self:OnRightOpenTipsOut();
	if self.modelDraw then
		self.modelDraw:Exit();
		self.modelDraw = nil;
	end
end

function UIFuncRightOpen:ShowOpenPercent()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local func = FuncManager:GetFunc(self.funcId);
	if not func then return; end
	if self.funcId == FuncConsts.ZhuanShen3 then
		objSwf.panel.siLvl._visible = false;
		objSwf.panel.tfPercent._visible = false;
		objSwf.panel.tf.text = func:GetCfg().rightOpenTxt;
		return;
	end
	objSwf.panel.siLvl._visible = true;
	objSwf.panel.tfPercent._visible = true;
	--
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	if func:GetCfg().open_type == 1 then
		objSwf.panel.siLvl.maximum = func:GetCfg().open_prama;
		objSwf.panel.siLvl.value = level;
		objSwf.panel.tfPercent.text = level .. "/".. func:GetCfg().open_prama;
	else
		local questCfg = t_quest[func:GetCfg().open_prama];
		if not questCfg then return; end
		objSwf.panel.siLvl.maximum = questCfg.minLevel;
		objSwf.panel.siLvl.value = level;
		objSwf.panel.tfPercent.text = level .."/".. questCfg.minLevel;
	end
end

--排即将开启按钮位置
function UIFuncRightOpen:Update()
	if not self.bShowState then return; end
	if not self.objSwf.panel._visible then return; end
	local teamY = UIMainTeammate:GetNextY();
	if teamY > 0 then
		self.objSwf.panel._y = teamY+10;
	else
		self.objSwf.panel._y = 180;
	end
end

function UIFuncRightOpen:OnRightOpenTipsOver()
	local func = FuncManager:GetFunc(self.funcId);
	if not func then return; end
	if func:GetCfg().rightOpenModel == "" then
		if func:GetCfg().rightOpenTips ~= "" then
			TipsManager:ShowBtnTips(func:GetCfg().rightOpenTips,TipsConsts.Dir_RightDown)
		end
	else
		UIFuncRightOpenCenter:Show(self.funcId);
	end
end

function UIFuncRightOpen:OnRightOpenTipsOut()
	local func = FuncManager:GetFunc(self.funcId);
	if not func then return; end
	if func:GetCfg().rightOpenModel == "" then
		if func:GetCfg().rightOpenTips ~= "" then
			TipsManager:Hide();
		end
	else
		UIFuncRightOpenCenter:Hide();
	end
end

function UIFuncRightOpen:HandleNotification(name,body)
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			self:ShowOpenPercent();
		end
	end
end

function UIFuncRightOpen:ListNotificationInterests()
	return {NotifyConsts.PlayerAttrChange};
end