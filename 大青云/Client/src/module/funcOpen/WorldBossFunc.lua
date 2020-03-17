--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/10/26
    Time: 19:11
   ]]


_G.WorldBossFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.WorldBoss, WorldBossFunc);

function WorldBossFunc:GetButton()

end