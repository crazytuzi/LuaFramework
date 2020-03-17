--[[
功能开启管理
lizhuangzhuang
2014年11月6日11:09:09
]]

_G.FuncOpenManager = {};

--队列
FuncOpenManager.list = {};
--是否正在开启功能
FuncOpenManager.isShowOpen = false;

--添加新开启功能
function FuncOpenManager:AddNewOpenFunc(funcId)
	for i,id in ipairs(self.list) do
		if id == funcId then
			return;
		end
	end
	table.push(self.list,funcId);
	if StoryController:IsStorying() then
		StoryController:RegisterCurrCallBack(function()
			self:ShowFuncOpen();
		end);
	else
		self:ShowFuncOpen();
	end
end

--显示新功能开启
function FuncOpenManager:ShowFuncOpen()
	if self.isShowOpen then return; end
	if #self.list <= 0 then return; end
	local funcId = table.remove(self.list,1);
	local func = FuncManager:GetFunc(funcId);
	if not func then
		self:ShowFuncOpen();
		return;
	end
	local cfg = func:GetCfg();
	--不显示开启过程的直接添加按钮
	if not cfg.showOpen then
		if func:GetState() == FuncConsts.State_ReadyOpen then
			func:SetState(FuncConsts.State_Open);
			func:OnFuncOpen();
			UIMainSkill:CheckFuncBtnState();
		else
			func:SetState(FuncConsts.State_Open);
			UIMainFunc:AddFuncButton(funcId,true);
			func:OnFuncOpen();
			UIMainSkill:CheckFuncBtnState();
		end
		self:Guide(funcId);
		self:ShowFuncOpen();
		return;
	end
	--添加按钮
	local flyCompleteFunc = function()
		local parentId = func:GetCfg().parentId;
		if parentId > 0 then--子功能
			func:SetState(FuncConsts.State_Open);
			func:OnFuncOpen();
			UIMainSkill:CheckFuncBtnState();
		else
			if func:GetState() == FuncConsts.State_ReadyOpen then
				func:SetState(FuncConsts.State_Open);
				func:OnFuncOpen();
				UIMainSkill:CheckFuncBtnState();
			else
				func:SetState(FuncConsts.State_Open);
				UIMainFunc:AddFuncButton(funcId,true);
				func:OnFuncOpen();
				UIMainSkill:CheckFuncBtnState();
			end
		end
		self:Guide(funcId);
		self.isShowOpen = false;
		self:ShowFuncOpen();
	end
	--飞图标
	local showCompleteFunc = function(startPos)
		local flyVO = {};
		flyVO.objName = 'FlyVO'
		flyVO.url = ResUtil:GetFuncIconUrl(func:GetCfg().icon);
		flyVO.startPos = startPos;
		flyVO.time = 1.5;
		if func:GetState() == FuncConsts.State_ReadyOpen then
			flyVO.endPos = func:GetBtnGlobalPos();
		else
			local parentId = func:GetCfg().parentId;
			if  parentId > 0 then
				local parentFunc = FuncManager:GetFunc(parentId);
				if parentFunc then
					flyVO.endPos = parentFunc:GetBtnGlobalPos();
				end
			end
		end
		if not flyVO.endPos then
			local endPos = func:GetFlyPos();
			if endPos then
				flyVO.endPos = endPos;
			else
				flyVO.endPos = UIMainFunc:GetNewFuncBtnPos(funcId,nil,true);
			end
		end
		flyVO.tweenParam = {};
	    flyVO.tweenParam._width = 40;
	    flyVO.tweenParam._height = 40;
		flyVO.onComplete = flyCompleteFunc;
		FlyManager:FlyIcon(flyVO);
	end
	--显示面板
	if cfg.model ~= "" then
		UIFuncOpenModel:Open(funcId,showCompleteFunc);
	else
		UIFuncOpen:Open(funcId,showCompleteFunc);
	end
	self.isShowOpen = true;
end

--功能开启指引
function FuncOpenManager:Guide(funcId)
	local func = FuncManager:GetFunc(funcId);
	if not func then return; end
	local cfg = func:GetCfg();
	if cfg.guideScript ~= "" then
		QuestScriptManager:DoScript(cfg.guideScript);
	end
	--右下角功能提示
	RemindFuncController:ExecRemindOnFuncOpen(funcId);
	--功能提示tips
	RemindFuncTipsController:ForceExecOnFuncOpen(funcId);
end