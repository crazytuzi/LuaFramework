require("scripts/game/shending/shending_data")
-- require("scripts/game/shending/shending_view")

--------------------------------------------------------------
-- 神鼎（活跃度）
--------------------------------------------------------------

ShenDingCtrl = ShenDingCtrl or BaseClass(BaseController)

function ShenDingCtrl:__init()
	if	ShenDingCtrl.Instance then
		ErrorLog("[ShenDingCtrl]:Attempt to create singleton twice!")
	end
	ShenDingCtrl.Instance = self

	self.data = ShenDingData.New()
	-- self.view = ShenDingView.New(ViewDef.ShenDing)
	self:RegisterAllProtocols()
end

function ShenDingCtrl:__delete()
	ShenDingCtrl.Instance = nil

	-- if self.view then
	-- 	self.view:DeleteMe()
	-- 	self.view = nil
	-- end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

end

--登记所有协议
function ShenDingCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCActiveData, "OnActiveData")	-- 接收所有活跃度完成进度数据
	self:RegisterProtocol(SCActiveDataChange, "OnSCActiveDataChange") -- 接收活跃度数据变化
	self:RegisterProtocol(SCActivityRewardState, "OnActRewardState")
end

----------接收----------

function ShenDingCtrl:OnActiveData(protocol)
	self.data:SetTaskList(protocol)
end

function ShenDingCtrl:OnSCActiveDataChange(protocol)
	self.data:SetTaskListChange(protocol)
end

function ShenDingCtrl:OnActRewardState(protocol)
	self.data:SetActRewacdStatr(protocol)
end

----------发送----------

--发送钻石打造请求
function ShenDingCtrl.SendActRewReq(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReciverRewardReq)
	protocol.rew_index = index
	protocol:EncodeAndSend()
end

--------------------
