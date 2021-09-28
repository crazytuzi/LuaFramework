require("game/baoju/zhibao/zhibao_data")
require("game/baoju/zhibao/zhibao_huanhua_view")

ZhiBaoCtrl = ZhiBaoCtrl or BaseClass(BaseController)

function ZhiBaoCtrl:__init()
	if ZhiBaoCtrl.Instance then
		print_error("[ZhiBaoCtrl] 尝试创建第二个单例模式")
		return
	end
	ZhiBaoCtrl.Instance = self

	self.zhibao_data = ZhiBaoData.New()
	self.huanhua_view = ZhiBaoHuanHuaView.New(ViewName.ZhiBaoHuanhua)
	self.view = BaoJuView.New(ViewName.BaoJu)
	self:RegisterAllProtocols()
end

function ZhiBaoCtrl:OpenHuanHuaView()
	ViewManager.Instance:Open(ViewName.ZhiBaoHuanhua)
end

function ZhiBaoCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end
	self.zhibao_data:DeleteMe()
	self.huanhua_view:DeleteMe()
	self.zhibao_data = nil
	ZhiBaoCtrl.Instance = nil
end

function ZhiBaoCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCActiveDegreeInfo, "SyncActiveDegreeInfo")
	self:RegisterProtocol(SCAllZhiBaoInfo, "SyncZhiBaoInfo")
end

function ZhiBaoCtrl:SyncActiveDegreeInfo(protocol)
	self.zhibao_data:SetActiveDegreeInfo(protocol)
	if self.view.active_view ~= nil then
		self.view.active_view:OnProtocolChange()
	end

	GlobalEventSystem:Fire(OtherEventType.VIRTUAL_TASK_CHANGE)

	RemindManager.Instance:Fire(RemindName.ZhiBao_Active)
	RemindManager.Instance:Fire(RemindName.DailyLeiJi)

	LeiJiRDailyCtrl.Instance:SetLeijiViewNextCurrentIndex()
end

function ZhiBaoCtrl:SyncZhiBaoInfo(protocol)
	self.zhibao_data:SyncZhiBaoInfo(protocol)
	if self.view.zhibao_view ~= nil then
		self.view.zhibao_view:Flush()
	end
	if self.huanhua_view ~= nil then
		self.huanhua_view:Flush()
	end
	if self.zhibao_data:GetZhiBaoIsJj() then
		local id = self.zhibao_data:GetZhiBaoIsJj(true)
		local asset = "1300"..id
		local image_cfg = {res_id = asset, image_id = id, image_name = self.zhibao_data:GetNameByLevel()}
		local cur_attrs,value = self.zhibao_data:GetAttrOldOrNew(false)
		local before_attrs,old_value = self.zhibao_data:GetAttrOldOrNew(true)
		local from_view = "zhibao_view"
		self:SendUseImage(image_cfg.image_id)
		TipsCtrl.Instance:ShowAdvanceSucceView(image_cfg, cur_attrs, before_attrs, from_view, value, old_value)
	end

	self.view:Flush()

	if self.zhibao_data:GetIsUpGrade() and self.view.zhibao_view then
		self.view.zhibao_view:Flush()
	end

	-- 新旧等级比较完成后再赋值
	self.zhibao_data:SetOldLevel(protocol.level)
	RemindManager.Instance:Fire(RemindName.ZhiBao_Upgrade)
end

--0、激活 1、升级 2、使用
function ZhiBaoCtrl:SendActiveHuanhua(big_type, type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSZhiBaoHuanHua)
	send_protocol.big_type = big_type
	send_protocol.type = type
	send_protocol:EncodeAndSend()
end

function ZhiBaoCtrl:SendZhiBaoUpgrade()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSZhiBaoUplevel)
	send_protocol:EncodeAndSend()
end

function ZhiBaoCtrl:SendUseImage(image_index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSZhiBaoUseImage)
	send_protocol.use_image = image_index
	send_protocol:EncodeAndSend()
end

function ZhiBaoCtrl:SendGetActiveReward(operate_type, param)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSActiveFetchReward)
	send_protocol.operate_type = operate_type
	send_protocol.param = param
	send_protocol:EncodeAndSend()
end

