--[[
杀戮属性 功能
2015年3月26日14:49:30
haohu
]]

_G.KillValFunc = setmetatable( {}, {__index = BaseFunc} );

FuncManager:RegisterFuncClass( FuncConsts.KillVal, KillValFunc );


function KillValFunc:OnStateChange()
	if self.state == FuncConsts.State_Open then
		UIKillValue:Show();
	end
end