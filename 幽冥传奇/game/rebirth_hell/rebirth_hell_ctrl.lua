require("scripts/game/rebirth_hell/rebirth_hell_data")
require("scripts/game/rebirth_hell/rebirth_hell_view")

--------------------------------------------------------
-- 跨服BOSS-轮回地狱
--------------------------------------------------------

RebirthHellCtrl = RebirthHellCtrl or BaseClass(BaseController)

function RebirthHellCtrl:__init()
	if	RebirthHellCtrl.Instance then
		ErrorLog("[RebirthHellCtrl]:Attempt to create singleton twice!")
	end
	RebirthHellCtrl.Instance = self

	self.data = RebirthHellData.New()
	self.view = RebirthHellView.New(ViewDef.RebirthHell)

	self:RegisterAllProtocols()
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))
end

function RebirthHellCtrl:__delete()
	RebirthHellCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

end

function RebirthHellCtrl:RecvMainInfoCallBack()
	if IS_ON_CROSSSERVER then
		RebirthHellCtrl.Instance.SendRotaryTableReq(1)
		RebirthHellCtrl.Instance.SendRebirthHellDataReq(2)
	end
end

--登记所有协议
function RebirthHellCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRebirthHellData, "OnRebirthHellData")	--轮回地狱
	self:RegisterProtocol(SCRotaryTableResults, "OnRotaryTableData")	--跨服转盘
end

----------接收----------

-- 接收"跨服转盘"数据 请求(144, 7)
function RebirthHellCtrl:OnRotaryTableData(protocol)
	self.data:SetRotaryTableData(protocol)
end

-- 接收"轮回地狱"数据 请求(144, 8)
function RebirthHellCtrl:OnRebirthHellData(protocol)
	self.data:SetData(protocol)
end

----------发送----------

-- 请求"跨服转盘"操作 返回(144, 7)
function RebirthHellCtrl.SendRotaryTableReq(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRotaryTableReq)
	protocol.index = index
	protocol:EncodeAndSend()
end

-- 请求"轮回地狱"操作 返回(144, 8)
function RebirthHellCtrl.SendRebirthHellDataReq(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRebirthHellrDataReq)
	protocol.index = index -- 1 购买次数 2 获取信息
	protocol:EncodeAndSend()
end

--------------------
