require("scripts/game/dragon_soul/dragon_soul_data")
require("scripts/game/dragon_soul/dragon_soul_view")

--------------------------------------------------------
-- 龙魂圣域
--------------------------------------------------------

DragonSoulCtrl = DragonSoulCtrl or BaseClass(BaseController)

function DragonSoulCtrl:__init()
	if	DragonSoulCtrl.Instance then
		ErrorLog("[DragonSoulCtrl]:Attempt to create singleton twice!")
	end
	DragonSoulCtrl.Instance = self

	self.data = DragonSoulData.New()
	self.view = DragonSoulView.New(ViewDef.DragonSoul)

	self:RegisterAllProtocols()
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))
end

function DragonSoulCtrl:__delete()
	DragonSoulCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	
end

function DragonSoulCtrl:RecvMainInfoCallBack()
	if IS_ON_CROSSSERVER then
		DragonSoulCtrl.Instance.CSDragonSoulDataReq(1)
	end
end


--登记所有协议
function DragonSoulCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCDragonSoulData, "OnDragonSoulDataResult")
end

----------接收----------

-- 接收"龙魂圣域"数据 请求(144, 9)
function DragonSoulCtrl:OnDragonSoulDataResult(protocol)
	self.data:SetData(protocol)
end

----------发送----------

-- 请求"龙魂圣域"数据 返回(144, 9)
function DragonSoulCtrl.CSDragonSoulDataReq(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSDragonSoulDataReq)
	protocol.index = index
	protocol:EncodeAndSend()
end

--------------------
