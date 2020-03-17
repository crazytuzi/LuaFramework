--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/10/5
    Time: 15:57
   ]]


_G.XiuWeiPoolFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.XiuweiPool, XiuWeiPoolFunc);

function XiuWeiPoolFunc:GetButton()
	return UIMainXiuweiPool:GetButton();
end