require("scripts/game/card_handle/card_handle_data")
require("scripts/game/card_handle/card_view")
require("scripts/game/card_handle/card_check_suit")
require("scripts/game/card_handle/card_check_view")

CardHandlebookCtrl = CardHandlebookCtrl or BaseClass(BaseController)

function CardHandlebookCtrl:__init()
	if CardHandlebookCtrl.Instance then
		ErrorLog("[ CardHandlebookCtrl]:Attempt to create singleton twice!")
	end
	
	CardHandlebookCtrl.Instance = self

	self.view = CardView.New(ViewDef.CardHandlebook)
	self.data = CardHandlebookData.New()
	self.card_suit_view = CardCheckSuit.New()
	self.card_check_view = CardHandlebookCheckView.New(ViewDef.CardHandlebookCheck)

	self:RegisterAllProtocols()
end

function CardHandlebookCtrl:__delete()
	CardHandlebookCtrl.Instance = nil

	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil
end

function CardHandlebookCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCDecomposeCardResult, "OnCardDecomposeResult")	--分解结果
	self:RegisterProtocol(SCCardHandleInfo, "OnCardHandleInfo")				--图鉴数据
	self:RegisterProtocol(SCCardFireResult, "OnCardFireResult")				--激活结果
	self:RegisterProtocol(SCCardUpLevelResult, "OnCardUpLevelResult")		--升级结果
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainRoleInfo, self))
end

function CardHandlebookCtrl:RecvMainRoleInfo()
	self.data:SetListenerEvent()
end

function CardHandlebookCtrl:OpenCardCheckView(data)
	self.card_check_view:Open()
	self.data:SetOpenCardData(data)
end

function CardHandlebookCtrl:OpenCardCheckSuit(type)
	self.card_suit_view:Open()
	self.card_suit_view:SetType(type)
end

-------------------------
--图鉴分解面板
-------------------------
-- 图鉴分解
function CardHandlebookCtrl.CardDecomposeReq(equip_t)
	local protocol = ProtocolPool.Instance:GetProtocol(CSDecomposeCardReq)
	protocol.equip_t = equip_t
	protocol:EncodeAndSend()
end

function CardHandlebookCtrl:OnCardDecomposeResult(protocol)
	-- RemindManager.Instance:DoRemindDelayTime(RemindName.CardHandlebook)
	self.data:SetCardDecomposeResult(protocol)
end


--==============================--

-- 把一个物品从分解背包加入分解列表
function CardHandlebookCtrl:MoveItemToDecomposeFromBag(item)
	self.data:DelDecomposeCardHandlebookData(item)
	self.data:AddDecomposeData(item)
	-- self.descompose_card_view:Flush(0, "recycle_bag_list")
	-- self.descompose_card_view:Flush(0, "recycle_list")
end

-- 把一个物品从分解列表取回分解背包
function CardHandlebookCtrl:MoveItemToBagFromDecompose(series)
	local item = self.data:DelDecomposeData(series)
	self.data.Instance:AddDecomposeCardHandlebookData(item)
	-- self.descompose_card_view:Flush(0, "recycle_bag_list")
	-- self.descompose_card_view:Flush(0, "recycle_list")
end
--==============================--


-------------------------
--图鉴展示面板
-------------------------
-- 请求图鉴数据
function CardHandlebookCtrl.CardHandleInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCardHandleInfoReq)
	protocol:EncodeAndSend()
end

-- 请求图鉴激活
function CardHandlebookCtrl.CardFireReq(series)
	if nil == series then return end
	local protocol = ProtocolPool.Instance:GetProtocol(CSCardFireReq)
	protocol.series = series
	protocol:EncodeAndSend()
end

-- 请求图鉴升级
function CardHandlebookCtrl.CardUpLevelReq(type_index, caowei_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCardUpLevelReq)
	protocol.type_index = type_index
	protocol.caowei_index = caowei_index
	protocol:EncodeAndSend()
end

-- 图鉴数据结果
function CardHandlebookCtrl:OnCardHandleInfo(protocol)
	self.data:SetShowCardData(protocol)
end

-- 图鉴激活结果
function CardHandlebookCtrl:OnCardFireResult(protocol)
	self.data:UpdateJihuoCardData(protocol)
end

-- 图鉴升级结果
function CardHandlebookCtrl:OnCardUpLevelResult(protocol)
	self.data:UpdateUpCardData(protocol)
end
