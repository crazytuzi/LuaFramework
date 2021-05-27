require("scripts/game/equipment/data/authenticate_data")
require("scripts/game/equipment/view/authenticate_tip_view")
require("scripts/game/equipment/view/xilian_view")

--------------------------------------------------------
-- 锻造-鉴定
--------------------------------------------------------

AuthenticateCtrl = AuthenticateCtrl or BaseClass(BaseController)

function AuthenticateCtrl:__init()
	if	AuthenticateCtrl.Instance then
		ErrorLog("[AuthenticateCtrl]:Attempt to create singleton twice!")
	end
	AuthenticateCtrl.Instance = self

	self.data = AuthenticateData.New()
	self.tip_view = AuthenticateTipView.New()
	self.xilian_view = XilianView.New()

	self:RegisterAllProtocols()
end

function AuthenticateCtrl:__delete()
	AuthenticateCtrl.Instance = nil

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.tip_view then
		self.tip_view:DeleteMe()
		self.tip_view = nil
	end

	if self.xilian_view then
		self.xilian_view:DeleteMe()
		self.xilian_view = nil
	end

	if self.xl_suit then
		self.xl_suit:DeleteMe()
		self.xl_suit = nil
	end
end

--登记所有协议
function AuthenticateCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCAuthenticateResult, "OnAuthenticateResult")
	self:RegisterProtocol(SCAllEquipAutResult, "OnAllEquipAutResult")
end

----------接收----------

-- 接收鉴定结果(7, 47)
function AuthenticateCtrl:OnAuthenticateResult(protocol)
	self.data:SetAuthenticateData(protocol)
end

-- 接收全部装备鉴定结果(7, 51)
function AuthenticateCtrl:OnAllEquipAutResult(protocol)
	self.data:SetAllEquipData(protocol)
end

----------发送----------

--发送钻石打造请求(7, 49)
-- function AuthenticateCtrl.SendDiamondsCreateReq(equip_series)
-- 	local protocol = ProtocolPool.Instance:GetProtocol(CSAuthenticate)
-- 	protocol.equip_series = equip_series
-- 	protocol:EncodeAndSend()
-- end

-- 发送鉴定请求(jd_event-鉴定事件, equip_index-装备槽位, jd_type-鉴定类型, attr_index-属性槽位, jl_index-几率索引, lock_list)
function AuthenticateCtrl.SendAuthenticateReq(jd_event, equip_index, jd_type, attr_index, jl_index, lock_list)
	local protocol = ProtocolPool.Instance:GetProtocol(CSAuthenticate)
	protocol.jd_event = jd_event
	protocol.equip_index = equip_index
	protocol.jd_type = jd_type
	protocol.attr_index = attr_index or 1
	protocol.jl_index = jl_index or 1
	protocol.attr_idx = 5
	protocol.lock_list = lock_list
	protocol:EncodeAndSend()
end

--------------------

function AuthenticateCtrl:OpenTip(equip)
	self.tip_view:SetData(equip)
	self.tip_view:Open()
end

function AuthenticateCtrl:OpenXilian(idx, index, attr_index)
	self.xilian_view:SetData(idx, index, attr_index)
	self.xilian_view:Open()
end