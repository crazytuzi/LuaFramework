--[[
家园功能
lizhuangzhuang
2015年9月12日20:27:49
]]

_G.HomeFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.Homestead,HomeFunc);

function HomeFunc:OnFuncOpen()
	
end
