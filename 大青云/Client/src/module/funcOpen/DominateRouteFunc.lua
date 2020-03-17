--[[
	2015年8月11日, PM 01:09:26
	主宰之路功能按钮闪烁
	wangyanwie
]]

_G.DominateRouteFunc = setmetatable({},{__index = BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.DominateRoute,DominateRouteFunc);

function DominateRouteFunc:OnBtnInit()

end