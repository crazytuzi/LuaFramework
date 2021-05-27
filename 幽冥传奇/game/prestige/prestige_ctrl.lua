require("scripts/game/prestige/prestige_data")
require("scripts/game/prestige/prestige_view")


PrestigeCtrl = PrestigeCtrl or BaseClass(BaseController)

function PrestigeCtrl:__init()
	if PrestigeCtrl.Instance then
		ErrorLog("[PrestigeCtrl] attempt to create singleton twice!")
		return
	end
	PrestigeCtrl.Instance = self
	
	self.data = PrestigeData.New()
	self.view = PrestigeView.New(ViewDef.Prestige)

	self:RegisterAllProtocols()
end

function PrestigeCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil
	
	self.data:DeleteMe()
	self.data = nil
	
	PrestigeCtrl.Instance = nil
end 

function PrestigeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCPrestigeTaskResult, "OnPrestigeTaskResult")
	self:RegisterProtocol(SCDuiHuanCishu, "OnDuiHuanCishu")

	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.Weiwang)
end


function PrestigeCtrl:OnPrestigeTaskResult(protocol)
	--print("所有数据下发")
	self.data:setPrestigeTaskResult(protocol)
	RemindManager.Instance:DoRemindDelayTime(RemindName.Weiwang, 0.2)
end


function PrestigeCtrl:OnDuiHuanCishu(protocol)
	self.data:setDuiHuanCishu(protocol)
end



function PrestigeCtrl:SendGetPrestigeTaskAward(index, dui_huan_time, item_list)
	local protocol = ProtocolPool.Instance:GetProtocol(CSPrestigeTaskExchangeReq)
	protocol.index = index
	protocol.dui_huan_time = dui_huan_time
	protocol.item_list = item_list
	protocol:EncodeAndSend()
end 


function PrestigeCtrl:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.ACTOR_PRESTIGE_VALUE then
		self.data:FlushCfgList()
		RemindManager.Instance:DoRemindDelayTime(RemindName.Weiwang, 0.2)
	end
end

function PrestigeCtrl:ItemDataListChangeCallback()
	self.data:FlushCfgList()
	RemindManager.Instance:DoRemindDelayTime(RemindName.Weiwang, 0.2)
end

function PrestigeCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.Weiwang then
		return self.data:GetCanDuiHuan()
	end
end