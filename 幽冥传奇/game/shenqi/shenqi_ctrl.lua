require("scripts/game/shenqi/shenqi_view")
require("scripts/game/shenqi/shenqi_data")
require("scripts/game/shenqi/shenqi_attr_view")

ShenqiCtrl = ShenqiCtrl or BaseClass(BaseController)

function ShenqiCtrl:__init()
	if ShenqiCtrl.Instance ~= nil then
		ErrorLog("[ShenqiCtrl] Attemp to create a singleton twice !")
	end
	ShenqiCtrl.Instance = self

	self.shenqi_view = ShenqiView.New(ViewDef.ShenqiView)
	self.shenqi_equip_view = ShenqiAttrView.New()
	self.data = ShenqiData.New()

	self:RegisterAllProtocols()
end

function ShenqiCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCShenQiInfo, "OnShenQiInfo")
	self:RegisterProtocol(SCShenQiUpgradeResult, "OnShenQiUpgradeResult") 
	self:RegisterProtocol(SCShenQiAttrUpResult, "OnShenQiAttrUpResult")
	
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.ShenQi)
end

function ShenqiCtrl:GetRemindNum()
	return self.data:GetRemindNum()
end

function ShenqiCtrl:OpenEquipView(index)
	self.shenqi_equip_view:SetData(index)
	self.shenqi_equip_view:Open()
end

function ShenqiCtrl:__delete()
	self.shenqi_view:DeleteMe()
	self.shenqi_view = nil

	self.data:DeleteMe()
	self.data = nil

	ShenqiCtrl.Instance = nil
end

function ShenqiCtrl:ChangeDisplay(floor)
	self.data:SetCurDisplayFloor(floor)
	self.shenqi_view:ChangeDisplay()
end
--下发神器数据
function ShenqiCtrl:OnShenQiInfo(protocol)
	self.data:SetShenQiInfo(protocol)
	RemindManager.Instance:DoRemind(RemindName.ShenQi)
end

--下发器魂结果
function ShenqiCtrl:OnShenQiUpgradeResult(protocol)
	self.data:SetUpgradeResult(protocol)
	RemindManager.Instance:DoRemind(RemindName.ShenQi)
end

--下发基础属性升级结果
function ShenqiCtrl:OnShenQiAttrUpResult(protocol)
	self.data:SetAttrUpResult(protocol)
	RemindManager.Instance:DoRemind(RemindName.ShenQi)

end
-------------------------------------------------
--------------------请求-------------------------
-- 器魂
function ShenqiCtrl.SendShenQiUpgrade()
	local protocol = ProtocolPool.Instance:GetProtocol(CSShenQiUpgrade)
	protocol:EncodeAndSend()
end

--属性升级
function ShenqiCtrl.SendShenQiAttrUpgrade(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSShenQiAttrUpgrade)
	protocol.type = index
	protocol:EncodeAndSend()
end