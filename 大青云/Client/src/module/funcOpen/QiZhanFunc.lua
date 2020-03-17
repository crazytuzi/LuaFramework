--[[
骑战功能
zhangshuhui
2015年11月13日16:58:09
]]

_G.QiZhanFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.QiZhan,QiZhanFunc);

function QiZhanFunc:OnFuncOpen()
	--UIQiZhanShowView:OpenPanel()
end