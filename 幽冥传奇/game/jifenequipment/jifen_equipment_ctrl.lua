require("scripts/game/jifenequipment/jifen_equipment_data")
JiFenEquipmentCtrl = JiFenEquipmentCtrl or BaseClass(BaseController)
function JiFenEquipmentCtrl:__init()
	if	JiFenEquipmentCtrl.Instance then
		ErrorLog("[JiFenEquipmentCtrl]:Attempt to create singleton twice!")
	end
	JiFenEquipmentCtrl.Instance = self

	self.data = JiFenEquipmentData.New()

	self:RegisterAllProtocols()
end

function JiFenEquipmentCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	JiFenEquipmentCtrl.Instance = nil
end

function JiFenEquipmentCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCFullScaleInfo,"OnQuanFuGongGao")
	self:RegisterProtocol(SCAddAllServerInfo,"OnAddQuanFuGongGao")
end

function JiFenEquipmentCtrl:OnQuanFuGongGao(protocol)
	self.data:SetExchangeInfo(protocol)
	ViewManager.Instance:FlushView(ViewName.Explore, TabIndex.explore_jf_exchange)
end

function JiFenEquipmentCtrl:OnAddQuanFuGongGao(protocol)
	self.data:SetAddExchangeInfo(protocol)
	ViewManager.Instance:FlushView(ViewName.Explore, TabIndex.explore_jf_exchange)
end

--请求兑换
function JiFenEquipmentCtrl:SendIntegralExchangeBagReq(type_index, index_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSIntegralExchangeBagReq)
	protocol.type_index = type_index
	protocol.index_id = index_id
	protocol:EncodeAndSend()
end

--获取全服公告信息
function JiFenEquipmentCtrl:SendGetFullScaleAnnouncementInfReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetFullScaleAnnouncementInfReq)
	protocol:EncodeAndSend()
end
