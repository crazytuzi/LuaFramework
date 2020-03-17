--[[
杀戮属性 controller
haohu
2015年3月5日15:08:25
]]
_G.classlist['KillValueController'] = 'KillValueController'
_G.KillValueController = setmetatable( {}, {__index = IController} );
KillValueController.name = "KillValueController";
KillValueController.objName = 'KillValueController'
function KillValueController:Create()
	MsgManager:RegisterCallBack( MsgType.SC_KillingValue, self, self.OnKillingValue );
	MsgManager:RegisterCallBack( MsgType.SC_KillHistory, self, self.OnKillHistoryRsv );
end

--------------------------------response-----------------------------------------------
--返回杀戮值
function KillValueController:OnKillingValue(msg)
	local killValue = msg.killingValue;
	KillValueModel:SetKillValue(killValue);
	local attrAdded = msg.flag == 1; -- 是否增加了属性
	if attrAdded then
		-- 增加杀戮历史记录
		local level = KillValueUtils:GetLevel( killValue );
		KillValueModel:AddKillHistory( level, 1 );
		if FuncManager:GetFuncIsOpen( FuncConsts.KillVal ) then
			-- 打开属性获得提醒面板
			UIKillValueAttrAdd:Open(killValue);
			-- 播放属性增加艺术字提示
			UIKillValue:PlayWordArt();
		end
	end
end

--返回历史杀戮信息
function KillValueController:OnKillHistoryRsv( msg )
	for _, vo in pairs(msg.killHistory) do
		KillValueModel:AddKillHistory( vo.level, vo.num );
	end
end