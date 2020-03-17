--[[
回城
wangshuai
]]


_G.BackHomeFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.TP,BackHomeFunc);

function BackHomeFunc:OnBtnRollOver()
	if self.state ~= FuncConsts.State_Open then return end;
	local c,t,s = CTimeFormat:sec2format(MainPlayerModel.redundantBackTime);
	if tonumber(t) <= 0 then
		TipsManager:ShowBtnTips(string.format(StrConfig["backHome005"]));
	else
		TipsManager:ShowBtnTips(string.format(StrConfig["backHome006"],t));
	end; 
end;

--鼠标移出按钮
function BackHomeFunc:OnBtnRollOut()
	TipsManager:Hide();
end


