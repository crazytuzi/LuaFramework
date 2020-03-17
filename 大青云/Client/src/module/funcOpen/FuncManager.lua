--[[
功能管理
lizhuangzhuang
2014年11月4日10:33:23
]]

_G.FuncManager = {};

FuncManager.funcClassMap = {};
FuncManager.funcs = {};

--打开功能
--@param openClose 自动执行打开关闭
--@param ... 传Show参数,可用作打开子功能
function FuncManager:OpenFunc(funcId, openClose, ...)
	local func = self:GetFunc(funcId);
	if not func then return; end
	if func:GetState() ~= FuncConsts.State_Open then
		local tips = self:GetFuncUnOpenTips(funcId);
		if tips ~= "" then
			FloatManager:AddSkill(tips);
		end
		return;
	end
	if funcId == FuncConsts.SmithingRing then
		if not SmithingModel:GetRingCid() then
			return
		end
	end

	--特殊处理
	if funcId == FuncConsts.Pick then --拾取
	DropItemController:DoPickUp();
	return;
	end
	if funcId == FuncConsts.Ride then --乘骑
	MountController:RideMount();
	return;
	end
	if funcId == FuncConsts.AutoBattle then --挂机
	if not _sys:isKeyDown(_System.KeyShift) then
		AutoBattleController:SetAutoHang();
		return;
	end
	end
	--跨服下的处理
	if MainPlayerController.isInterServer then
		return;
	end
	if funcId == FuncConsts.Sit then --打坐
	SitController:ReqSit();
	return;
	end
	if funcId == FuncConsts.TP then -- 回城
	if MapPath.MainCity == CPlayerMap:GetCurMapID() then
		FloatManager:AddCenter(StrConfig['backHome004']);
		return
	end
	MainPlayerController:OnBackHome()
	return;
	end
	if funcId == FuncConsts.WaBao then --挖宝
	WaBaoController:ShowUI();
	return;
	end
	--是子功能的,通过父功能打开
	--print("-----字节点",func:GetCfg().parentId)
	if func:GetCfg().parentId > 0 then
		FuncManager:OpenFunc(func:GetCfg().parentId, false, funcId, ...)
		return;
	end
	--打开UI
	local uiName = FuncConsts.UIMap[funcId];
	if not uiName then return; end
	local ui = UIManager:GetUI(uiName);
	if not ui then return; end
	if openClose then
		if ui:IsShow() then
			ui:Hide();
		else
			if ui:CheckOpen() then
				ui.tweenStartPos = func:GetBtnGlobalPos();
				ui:Show(unpack({ ... }));
			end
		end
	else
		if ui:CheckOpen() then
			ui.tweenStartPos = func:GetBtnGlobalPos();
			if ui:IsShow() then
				ui:Show(unpack({ ... }));
				ui:OnShow();
			else
				ui:Show(unpack({ ... }));
			end
		end
	end
end

--快捷键打开功能
function FuncManager:OnKeyDown(funcId)
	local func = self:GetFunc(funcId);
	if not func then return; end
	if func:GetState() ~= FuncConsts.State_Open then return; end
	if funcId == FuncConsts.Pick then --拾取
	DropItemController:DoPickUp();
	return;
	end
	--开启功能
	self:OpenFunc(funcId, true);
end


--注册功能
function FuncManager:RegisterFunc(id, func)
	if self.funcs[id] then
		Debug('Error:不能注册一个已存在功能');
		WriteLog(LogType.Normal, true, '-------------Error:不能注册一个已存在功能')
		return;
	end
	self.funcs[id] = func;
end

--获取一个功能
function FuncManager:GetFunc(id)
	return self.funcs[id];
end

--获取一个功能是否已开启
function FuncManager:GetFuncIsOpen(id)
	local func = self:GetFunc(id);
	if not func then return false; end
	if func:GetState() == FuncConsts.State_Open then
		return true;
	else
		return false;
	end
end

--注册功能的解析类
function FuncManager:RegisterFuncClass(id, class)
	if self.funcClassMap[id] then
		Debug("Error:已存在功能解析类");
		return;
	end
	self.funcClassMap[id] = class;
end

--获取未开启提示
function FuncManager:GetFuncUnOpenTips(funcId)
	local func = self:GetFunc(funcId);
	if not func then return ""; end
	return func:GetCfg().unOpenTips;
end

--所有功能按钮在UIMainFunc:OnBtnHideTop()后执行收缩方法
function FuncManager:OnAllFuncContraction()
	for _, func in pairs(FuncManager.funcs) do
		if func:GetState() == FuncConsts.State_Open then
			func:OnFuncContraction();
		end
	end
end