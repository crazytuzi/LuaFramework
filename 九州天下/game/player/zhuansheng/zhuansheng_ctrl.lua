require("game/player/zhuansheng/zhuansheng_data")

--------------------------------------------------------------
--转生相关
--------------------------------------------------------------
ZhuanShengCtrl = ZhuanShengCtrl or BaseClass(BaseController)
function ZhuanShengCtrl:__init()
	if ZhuanShengCtrl.Instance then
		print_error("[ZhuanShengCtrl] Attemp to create a singleton twice !")
	end
	ZhuanShengCtrl.Instance = self

	self.ZhuanSheng_data = ZhuanShengData.New()

	self:RegisterAllProtocols()
end

function ZhuanShengCtrl:__delete()
	ZhuanShengCtrl.Instance = nil

	self.ZhuanSheng_data:DeleteMe()
	self.ZhuanSheng_data = nil
end

function ZhuanShengCtrl:RegisterAllProtocols()
	-- 转生
	self:RegisterProtocol(CSZhuanShengOpearReq)

	self:RegisterProtocol(SCZhuanShengAllInfo, "OnSCZhuanShengAllInfo")
	self:RegisterProtocol(SCZhuanShengOtherInfo, "OnSCZhuanShengOtherInfo")
end

 -- 转生装备请求
function ZhuanShengCtrl:SendRoleZhuanSheng(opera_type, param1, param2, param3)
	local protocol = ProtocolPool.Instance:GetProtocol(CSZhuanShengOpearReq)
	protocol.opera_type = opera_type or 0
	protocol.reserve_sh = 0
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol.param3 = param3 or 0
	protocol:EncodeAndSend()
end

-- 转生装备信息
function ZhuanShengCtrl:OnSCZhuanShengAllInfo(protocol)
	self.ZhuanSheng_data:SetZhuanShengAllInfo(protocol)
	ViewManager.Instance:FlushView(ViewName.Player)
end

-- 转生装备其他信息
function ZhuanShengCtrl:OnSCZhuanShengOtherInfo(protocol)
	self.ZhuanSheng_data:SetZhuanShengOtherInfo(protocol)
	ViewManager.Instance:FlushView(ViewName.Player)
end