require("game/player/touxian/touxian_data")
require("game/player/touxian/touxian_view")
--------------------------------------------------------------
--头衔
--------------------------------------------------------------
TouxianCtrl = TouxianCtrl or BaseClass(BaseController)
function TouxianCtrl:__init()
	if TouxianCtrl.Instance then
		print_error("[TouxianCtrl] 尝试生成第二个单例模式")
	end
	TouxianCtrl.Instance = self
	self.data = TouxianData.New()
	self.view = TouxianView.New(ViewName.Touxian)
	self:RegisterAllProtocols()
end

function TouxianCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	self.view:DeleteMe()
	self.view = nil

	TouxianCtrl.Instance = nil
end

function TouxianCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRoleJingJie, "OnRoleJingJie")
end

function TouxianCtrl:OnRoleJingJie(protocol)
	self.data:SetTouxianInfo(protocol)
	Scene.Instance:GetMainRole():SetAttr("touxian", protocol.jingjie_level)

	RemindManager.Instance:Fire(RemindName.Touxian)
	self.view:Flush()
end

--请求头衔信息
function TouxianCtrl.SendTouxianGetInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSTouxianGetInfo)
	protocol:EncodeAndSend()
end

--头衔升级请求
function TouxianCtrl.SendUpTouxian(is_auto_buy)
	TouxianCtrl.SendRoleJingJieReq(TouxianData.OPERA.PROMOTE_LEVEL, is_auto_buy)
end

--头衔升级请求
function TouxianCtrl.SendRoleJingJieReq(opera_type, is_auto_buy)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRoleJingJieReq)
	protocol.opera_type = opera_type
	protocol.is_auto_buy = is_auto_buy or 0
	protocol:EncodeAndSend()
end