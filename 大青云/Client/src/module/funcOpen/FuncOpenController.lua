--[[
功能开启
lizhuangzhuang
2014年11月3日16:48:00
]]

_G.FuncOpenController = setmetatable({},{__index=IController});

FuncOpenController.name = "FuncOpenController";

FuncOpenController.keyEnable = true;

function FuncOpenController:Create()
	self:RegisterAllFunc();
	MsgManager:RegisterCallBack(MsgType.SC_FunctionOpenInfo,self,self.OnFuncOpenList);
	MsgManager:RegisterCallBack(MsgType.SC_FunctionOpenTips,self,self.OnFuncOpenTips);
	MsgManager:RegisterCallBack(MsgType.SC_HumanTimerList,self,self.OnHumanTimerList);
	MsgManager:RegisterCallBack(MsgType.SC_ClickDelayOpenFuncResult,self,self.OnClickDelayOpenFuncResult);
	MsgManager:RegisterCallBack(MsgType.SC_FunctionShowOpen,self,self.OnFunctionShowOpen);
	MsgManager:RegisterCallBack(MsgType.SC_FunctionOpen,self,self.OnFunctionOpen);
	CControlBase:RegControl( self, true );
end

function FuncOpenController:OnKeyDown(dwKeyCode)
	if not self.keyEnable then
		FloatManager:AddSkill(StrConfig["float50"]);
		return;
	end
	------------------------------------
	for funcId,func in pairs(FuncManager.funcs) do
		local funcKeyCode = func:GetFuncKey();
		if funcKeyCode and funcKeyCode==dwKeyCode then
			FuncManager:OnKeyDown(funcId);
		end
	end
end

--取消功能快捷键
function FuncOpenController:DisableFuncKey()
	self.keyEnable = false;
end

--恢复功能快捷键
function FuncOpenController:EnableFuncKey()
	self.keyEnable = true;
end

--注册所有功能
function FuncOpenController:RegisterAllFunc()
	for i,cfg in pairs(t_funcOpen) do
		local class = FuncManager.funcClassMap[cfg.id];
		if not class then
			class = BaseFunc;
		end
		local func = class:new(cfg);
		FuncManager:RegisterFunc(cfg.id,func);
	end
end

--功能开启列表
function FuncOpenController:OnFuncOpenList(msg)

	local uiShow = UIMainFunc:IsShow();
	for i,vo in ipairs(msg.FuncList) do
		local func = FuncManager:GetFunc(vo.funcID);
		if func then
			func:SetState(FuncConsts.State_Open);
			if uiShow then
				UIMainFunc:AddFuncButton(vo.funcID,false);
			end
			if vo.click == 1 then
				func:SetDayState(FuncConsts.State_OpenClick);
			end
		end
	end
	self:CheckFuncReadyOpen();
	self:CheckFuncRightOpen();
end

--新功能开启提示
function FuncOpenController:OnFuncOpenTips(msg)
	local func = FuncManager:GetFunc(msg.funcID);
	if not func then return; end
	if func:GetCfg().isHide == 1 then return; end
	FuncOpenManager:AddNewOpenFunc(msg.funcID);
	if msg.click == 1 then
		func:SetDayState(FuncConsts.State_OpenClick);
	end
end
--新功能几天前的开启提示
function FuncOpenController:OnFunctionShowOpen(msg)
	local func = FuncManager:GetFunc(msg.funcID);
	if not func then return; end
	func:SetOpenDay(msg.days)
	func:SetDayState(FuncConsts.State_OpenPrompt);
end
--客户端请求新功能开启
function FuncOpenController:ReqFunctionOpen(funcID)
	local msg = ReqFunctionOpenMsg:new();
	msg.funcID = funcID
	MsgManager:Send(msg);
end
--新功能点击开启返回结果
function FuncOpenController:OnFunctionOpen(msg)
	local func = FuncManager:GetFunc(msg.funcID);
	if not func then return; end
	if msg.result==0 then
        if msg.funcID==FuncConsts.NewTianshen then
           FuncOpenController:OnFuncOpenTips(msg)
           BagController:QuickUseItem(BagConsts.BagType_Tianshen,0,1)
           UITianShenShowView:OpenPanel();
           return  
        end
		func:SetDayState(FuncConsts.State_FunOpened);
		if UIOpenFunInfo:IsShow() then
			UIOpenFunInfo:Hide();
		end
	end
end
--检查预开启
function FuncOpenController:CheckFuncReadyOpen()
	local playerLvl = MainPlayerModel.humanDetailInfo.eaLevel;
	for funcId,func in pairs(FuncManager.funcs) do
		if func:GetState() == FuncConsts.State_UnOpen then
			local readyOpenLvl = func:GetCfg().readyOpenLvl;
			if readyOpenLvl>0 and playerLvl>=readyOpenLvl then
				func:SetState(FuncConsts.State_ReadyOpen);
				if UIMainFunc:IsShow() then
					UIMainFunc:AddFuncButton(funcId,false);
				end
			end
		end
	end
end

-- 检查即将开启
function FuncOpenController:CheckFuncRightOpen()
	local playerLvl = MainPlayerModel.humanDetailInfo.eaLevel;
	for funcId,func in pairs(FuncManager.funcs) do
		if func:GetState() ~= FuncConsts.State_Open then
			local rightOpenLvl = func:GetCfg().rightOpenLvl;
			if func:GetCfg().isHide~=1 and rightOpenLvl>0 and playerLvl>=rightOpenLvl then
				UIFuncRightOpen:ShowRightOpen(funcId);
				return;
			end
		end
	end
	UIFuncRightOpen:ShowRightOpen(nil);
end

--切换场景
function FuncOpenController:OnChangeSceneMap()
	for funcId,func in pairs(FuncManager.funcs) do
		func:OnChangeSceneMap();
	end
end

--服务器通知的倒计时开启
function FuncOpenController:OnHumanTimerList(msg)
	-- for k, v in pairs(msg.TimerList) do
	-- 	if v.type == 1 and v.param == FuncConsts.NewTianshen then
	-- 		TianShenController.openRemainTime = v.remain_time;
	-- 		UIMainPageTianshen:SetTianShenOpenCountDown(v.remain_time);
	-- 		break;
	-- 	end
	-- end
end

function FuncOpenController:OnClickDelayOpenFuncResult(msg)
	-- if msg.result == 0 then
	-- 	if msg.funcid == FuncConsts.NewTianshen then
	-- 		--变更状态
	-- 		UIMainPageTianshen:SetTianShenButtonState(true);
	-- 		TianShenController.needClickOpen = false;
    --      TianShenController:ReqActiveBianShen(1)
	-- 	end
	-- end
end