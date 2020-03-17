--[[
打包活力值功能
2015年3月26日14:53:34
haohu
]]

_G.DropValFunc = setmetatable( {}, {__index = BaseFunc} );

FuncManager:RegisterFuncClass( FuncConsts.DropVal, DropValFunc );

function DropValFunc:OnStateChange()
	if self.state == FuncConsts.State_Open then
		UIDropValue:Show();
	end
end