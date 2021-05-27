require("scripts/game/fashion/fashion_data")
require("scripts/game/fashion/fashion_view")
require("scripts/game/fashion/fashion_title_tip_view")

--------------------------------------------------------
-- 装扮 ctrl
--------------------------------------------------------

FashionCtrl = FashionCtrl or BaseClass(BaseController)

function FashionCtrl:__init()
	if	FashionCtrl.Instance then
		ErrorLog("[FashionCtrl]:Attempt to create singleton twice!")
	end
	FashionCtrl.Instance = self

	self.data = FashionData.New()
	self.view = FashionView.New(ViewDef.Fashion)
	self.fashion_title_view = FashionTitleTipView.New(ViewDef.FashionTitleTipView)

	self:RegisterAllProtocols()
end

function FashionCtrl:__delete()
	FashionCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.fashion_title_view then
		self.fashion_title_view:DeleteMe()
		self.fashion_title_view = nil
	end
end

--登记所有协议
function FashionCtrl:RegisterAllProtocols()
	--所有装备
	self:RegisterProtocol(SCAllFashionData, "OnAllFashionData")
	--添加装备
	self:RegisterProtocol(SCAddFashionEquip, "OnAddFashionEquip")
	--收回装备
	self:RegisterProtocol(SCAddRecycleEquip, "OnAddRecycleEquip")
	--物品数据变化
	self:RegisterProtocol(SCUpdateEquip, "OnUpdateEquip")
end

----------接收----------

function FashionCtrl:OnAllFashionData(protocol)
	self.data:SetAllFashionData(protocol.fashion_list)
end

function FashionCtrl:OnAddFashionEquip(protocol)
	self.data:SetAddData(protocol.item_data)
end

function FashionCtrl:OnAddRecycleEquip(protocol)
	self.data:SetRecycleData(protocol.series)
end

function FashionCtrl:OnUpdateEquip(protocol)
	self.data:SetUpdataData(protocol.item_data)
end

--放入形象柜
function FashionCtrl:SendXingXiangGuan(series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSendXingXiangGuan)
	protocol.series = series
	protocol:EncodeAndSend()
end

--收回装备
function FashionCtrl:SendSHouhuiEquipReq(series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSHouhuiEquip)
	protocol.series = series
	protocol:EncodeAndSend()
end

--幻化装备
function FashionCtrl:SendHuanhuaEquipReq(series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSHuanhuaEquip)
	protocol.series = series
	protocol:EncodeAndSend()
end

--取消幻化装备
function FashionCtrl:SendCancelHuanHuaEquipReq(series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCancelHuanHuaEquip)
	protocol.series = series
	protocol:EncodeAndSend()
end

----------发送----------

-- 请求真气升级形象
function FashionCtrl.SendZhenQiUpgrade(series)
	local protocol = ProtocolPool.Instance:GetProtocol(CS_72_5)
	protocol.series = series
	protocol:EncodeAndSend()
end

--------------------

function FashionCtrl:OpenTipTitle(titleID)
	self.fashion_title_view:Open()
	self.fashion_title_view:SetDataId(titleID)
end
