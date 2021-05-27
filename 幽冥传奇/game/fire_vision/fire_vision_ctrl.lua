require("scripts/game/fire_vision/fire_vision_data")
require("scripts/game/fire_vision/fire_vision_view")

--------------------------------------------------------
-- 烈焰幻境
--------------------------------------------------------

FireVisionCtrl = FireVisionCtrl or BaseClass(BaseController)

function FireVisionCtrl:__init()
	if	FireVisionCtrl.Instance then
		ErrorLog("[FireVisionCtrl]:Attempt to create singleton twice!")
	end
	FireVisionCtrl.Instance = self

	self.data = FireVisionData.New()
	self.view = FireVisionView.New(ViewDef.FireVision)

	self:RegisterAllProtocols()
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))
end

function FireVisionCtrl:__delete()
	FireVisionCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	
end

function FireVisionCtrl:RecvMainInfoCallBack()
	if IS_ON_CROSSSERVER then
		FireVisionCtrl.Instance.CSFireVisionDataReq(1)
	end
end

--登记所有协议
function FireVisionCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCFireVisionData, "OnFireVisionDataResult")	--圣兽宫殿视图
end

----------接收----------

-- 接收"烈焰幻境"数据 请求(144, 11)
function FireVisionCtrl:OnFireVisionDataResult(protocol)
	self.data:SetData(protocol)
end

----------发送----------

-- 请求"烈焰幻境"数据 返回(144, 11)
function FireVisionCtrl.CSFireVisionDataReq(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFireVisionDataReq)
	protocol.index = index
	protocol:EncodeAndSend()
end

--------------------
