require("scripts/game/unknown_dark_house/unknown_dark_house_data")
require("scripts/game/unknown_dark_house/unknown_dark_house_view")

--------------------------------------------------------
-- 未知暗殿
--------------------------------------------------------

UnknownDarkHouseCtrl = UnknownDarkHouseCtrl or BaseClass(BaseController)

function UnknownDarkHouseCtrl:__init()
	if	UnknownDarkHouseCtrl.Instance then
		ErrorLog("[UnknownDarkHouseCtrl]:Attempt to create singleton twice!")
	end
	UnknownDarkHouseCtrl.Instance = self

	self.data = UnknownDarkHouseData.New()
	self.view = UnknownDarkHouseView.New(ViewDef.UnknownDarkHouse)

	self:RegisterAllProtocols()
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))
end

function UnknownDarkHouseCtrl:__delete()
	UnknownDarkHouseCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

function UnknownDarkHouseCtrl:RecvMainInfoCallBack()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) -- 人物等级
	if level >= GameCond.CondId99.RoleLevel then
		UnknownDarkHouseCtrl.Instance:SendUnknownDarkHouseReq(1)
	end
end

--登记所有协议
function UnknownDarkHouseCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCUnknownDarkHouseResult, "OnUnknownDarkHouseResult")
	self:RegisterProtocol(SCUnknownDarkHouseExpResult, "OnUnknownDarkHouseExpResult")
	self:RegisterProtocol(SCSpecialEffInfo, "OnSpecialEffInfo")
end

----------接收----------

-- 接收结果(8, 34)
function UnknownDarkHouseCtrl:OnUnknownDarkHouseResult(protocol)
	self.data:SetData(protocol)
end

-- "未知暗殿"泡点经验(26 87)
function UnknownDarkHouseCtrl:OnUnknownDarkHouseExpResult(protocol)
	self.data:SetExp(protocol)
end

-- 特殊效果信息(26, 88)
function UnknownDarkHouseCtrl:OnSpecialEffInfo(protocol)
	self.data:SetSpecialEffInfo(protocol)
end

----------发送----------

--发送请求(139, 46)
function UnknownDarkHouseCtrl:SendUnknownDarkHouseReq(type, index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSUnknownDarkHouseReq)
	protocol.type = type -- 事件类型, 1获取信息, 2进入场景
	if type == 4 then
		protocol.index = index
	end
	protocol:EncodeAndSend()
end

--------------------
