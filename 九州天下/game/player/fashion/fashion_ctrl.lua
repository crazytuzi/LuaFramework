require("game/player/fashion/fashion_data")
require("game/player/player_fashion_huanhua_view")
--------------------------------------------------------------
--角色服装
--------------------------------------------------------------
FashionCtrl = FashionCtrl or BaseClass(BaseController)
function FashionCtrl:__init()
	if FashionCtrl.Instance then
		print_error("[FashionCtrl] 尝试生成第二个单例模式")
	end
	FashionCtrl.Instance = self
	self.fashion_data = FashionData.New()
	self:RegisterAllProtocols()
	self.fashion_change_callback = nil
	self.huanhua_view = PlayerFashionHuanhuaView.New(ViewName.PlayerFashionHuanhua)
end

function FashionCtrl:__delete()
	self.fashion_data:DeleteMe()
	self.fashion_data = nil
	FashionCtrl.Instance = nil
	self.view = nil

	if self.huanhua_view then
		self.huanhua_view:DeleteMe()
		self.huanhua_view = nil
	end
end

function FashionCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCShizhuangInfo, "OnShizhuangInfo")
	self:RegisterProtocol(SCOtherCapabilityInfo, "OnOtherCapabilityInfo")
	self:RegisterProtocol(CSShizhuangUseReq)
	self:RegisterProtocol(CSShizhuangUpgradeReq)
	self:RegisterProtocol(CSUseImages)

	self:RegisterProtocol(SCMasterCollectInfo, "OnSCMasterCollectInfo")
	self:RegisterProtocol(SCMasterCollectItemInfo, "OnSCMasterCollectItemInfo")
	self:RegisterProtocol(SCUseImagesAck, "OnSCUseImagesAck")
end

function FashionCtrl:NotifyWhenFashionChange(callback)
	self.fashion_change_callback = callback
end

function FashionCtrl:UnNotifyWhenFashionChange()
	self.fashion_change_callback = nil
end

--三件套信息
function FashionCtrl:OnOtherCapabilityInfo(protocol)
	print("协议：三件套信息")

end

--时装信息
--穿戴成功或时装被激活时调用
function FashionCtrl:OnShizhuangInfo(protocol)
	for k,v in pairs(protocol.item_list) do
		if k == SHIZHUANG_TYPE.WUQI then
			self.fashion_data:SetUseWuqiIndex(v.use_idx)
			self.fashion_data:SetWuqiActFlag(v.active_flag)
		elseif k == SHIZHUANG_TYPE.BODY then
			self.fashion_data:SetUseClothingIndex(v.use_idx)
			self.fashion_data:SetClothingActFlag(v.active_flag)
		end
	end

	self.fashion_data:SetFashionUpgradeInfo(protocol.item_list_upgrade)

	-- if self.fashion_change_callback ~= nil then
	-- 	self.fashion_change_callback()
	-- end
	if self.huanhua_view:IsOpen() then
		self.huanhua_view:Flush()
	end

	--PlayerCtrl.Instance:FlushPlayerView()
	--PlayerCtrl.Instance:FlushPlayerView("cur_fashion")
	RemindManager.Instance:Fire(RemindName.PlayerFashion)
end

--发送使用时装协议
function FashionCtrl:SendShizhuangUseReq(part, index)
	print("发送使用时装协议")
	print(part,index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSShizhuangUseReq)
	protocol.part = part
	protocol.index = index
	protocol:EncodeAndSend()
end

--发送升级时装协议
function FashionCtrl:SendFashionUpgradeReq(part, index)
	print("发送升级时装协议")
	local protocol = ProtocolPool.Instance:GetProtocol(CSShizhuangUpgradeReq)
	protocol.part = part
	protocol.index = index
	protocol:EncodeAndSend()
end

function FashionCtrl:OnSCMasterCollectInfo(protocol)
	self.fashion_data:SetMasterActiveFla(protocol.master_collect_flags)
	PlayerCtrl.Instance:FlushPlayerView("fashion_icon")
end

function FashionCtrl:OnSCMasterCollectItemInfo(protocol)
	self.fashion_data:SetCurItemListData(protocol.item_info_list, protocol.seq)
	PlayerCtrl.Instance:FlushPlayerView()
end

function FashionCtrl:SendUseFashionReq(index_list, mount_img_id, wing_img_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSUseImages)
	protocol.index_list = index_list
	protocol.mount_img_id = mount_img_id
	protocol.wing_img_id = wing_img_id
	protocol:EncodeAndSend()
end

function FashionCtrl:OnSCUseImagesAck(protocol)
	PlayerCtrl.Instance:FlushPlayerView("cur_fashion")
end