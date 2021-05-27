require("scripts/game/consign/consign_data")
require("scripts/game/consign/consign_view")
require("scripts/game/consign/consign_my_item")
require("scripts/game/consign/consign_buy_item")
require("scripts/game/consign/consign_exchange_tip")
require("scripts/game/consign/reddrille_tip_view")

-- 寄售
ConsignCtrl = ConsignCtrl or BaseClass(BaseController)

function ConsignCtrl:__init()
	if	ConsignCtrl.Instance then
		ErrorLog("[ConsignCtrl]:Attempt to create singleton twice!")
	end
	ConsignCtrl.Instance = self
	
	self.data = ConsignData.New()
	self.view = ConsignView.New(ViewDef.Consign)
	self.reddrille_tip_view = RedDrilleTipView.New(ViewDef.RedDrilleTip)
	self.exchange_tip = RedDrillExchangePage.New(ViewDef.RedDrillExchange)
	require("scripts/game/consign/consign_my_item").New(ViewDef.Consign.Sell)
	require("scripts/game/consign/consign_buy_item").New(ViewDef.Consign.Buy)
	require("scripts/game/consign/consign_jishou").New(ViewDef.Consign.Consign)
	require("scripts/game/consign/consign_red_drill").New(ViewDef.Consign.RedDrill)
	
	self:RegisterAllProtocols()
end

function ConsignCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil
	
	self.data:DeleteMe()
	self.data = nil

	self.exchange_tip:DeleteMe()
	self.exchange_tip = nil

	if self.reddrille_tip_view then
		self.reddrille_tip_view:DeleteMe()
		self.reddrille_tip_view = nil
	end
	
	ConsignCtrl.Instance = nil
end

function ConsignCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGetMyConsignItems, "OnGetMyConsignItems")
	self:RegisterProtocol(SCSearchConsignItems, "OnSearchConsignItems")
	self:RegisterProtocol(SCConsignItem, "OnConsignItem")
	self:RegisterProtocol(SCCancelConsignItem, "OnCancelConsignItem")
	self:RegisterProtocol(SCBuyConsignItem, "OnBuyConsignItem")
	self:RegisterProtocol(SCAddConsignItem, "OnAddConsignItem")
	self:RegisterProtocol(SCDelConsignItem, "OnDelConsignItem")
	
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.PreDownloadConsignItemCfg))
end

function ConsignCtrl.PreDownloadConsignItemCfg()
	ConsignCtrl.Instance:SendSearchConsignItemsReq()
	ConsignCtrl.Instance:ReqRechargeConfig()
end

-- 获取本人的寄卖物品
function ConsignCtrl:SendGetMyConsignItemsReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetMyConsignItemsReq)
	protocol:EncodeAndSend()
end

function ConsignCtrl:OnGetMyConsignItems(protocol)
	self.data:SetMyConsignItemsData(protocol)
	self.view:Flush()
end

-- 获取出售的物品记录
function ConsignCtrl:SendSearchConsignItemsReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSSearchConsignItemsReq)
	protocol:EncodeAndSend()
end

-- 兑换红钻
function ConsignCtrl:SendExchangeDrillReq(zuan_num)
	local protocol = ProtocolPool.Instance:GetProtocol(CSExchangeDrillReq)
	protocol.red_drill_num = zuan_num
	protocol:EncodeAndSend()
end

function ConsignCtrl:OnSearchConsignItems(protocol)
	self.data:SetSearchConsignItemsData(protocol)
	self.view:Flush()
end

function ConsignCtrl:OnAddConsignItem(protocol)
	self.data:AddConsignItem(protocol.item_info)
	self.view:Flush()
end


function ConsignCtrl:OnDelConsignItem(protocol)
	self.data:DelConsignItem(protocol.item_handle)
end

-- 寄卖物品
function ConsignCtrl:SendConsignItemReq(item_guid, item_price)
	local protocol = ProtocolPool.Instance:GetProtocol(CSConsignItemReq)
	protocol.item_guid = item_guid
	protocol.item_price = item_price
	protocol:EncodeAndSend()
end

function ConsignCtrl:OnConsignItem(protocol)
	self.data:SetResult(protocol)
	self:SendGetMyConsignItemsReq()
end

-- 下架物品
function ConsignCtrl:SendCancelConsignItemReq(item_guid, item_handle, operation)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCancelConsignItemReq)
	protocol.item_guid = item_guid
	protocol.item_handle = item_handle
	protocol.operation = operation
	protocol:EncodeAndSend()
end

function ConsignCtrl:OnCancelConsignItem(protocol)
	self:SendGetMyConsignItemsReq()
end

function ConsignCtrl:SendBuyConsignItem(data)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBuyConsignItemReq)
	protocol.item_guid = data.series
	protocol.item_handle = data.item_handle
	protocol:EncodeAndSend()
end

function ConsignCtrl:OnBuyConsignItem(protocol)
	self:SendSearchConsignItemsReq()
end



-------------------------------------------
-- 出售
-------------------------------------------
function ConsignCtrl:InputSellItem(data)
	ViewManager.Instance:GetViewObj(ViewDef.Consign.Sell):SetMyItemCellData(data)
end

-- 向后台请求充值配置
function ConsignCtrl:ReqRechargeConfig()
	local key = "hdISla9sjXphPqEoE8lZcg=="
	local params = {}
	params.spid = AgentAdapter:GetSpid()												--平台ID     spid
	params.sid = GameVoManager.Instance:GetUserVo().plat_server_id						--服ID       sid
	params.plat_user_name = AgentAdapter:GetPlatName()      							--平台帐号	 plat_user_name
	params.role_id = GameVoManager.Instance:GetMainRoleVo().role_id		  			    --角色ID     role_id  
	params.role_name = GameVoManager.Instance:GetMainRoleVo().name	  			    	--角色名字   role_name
	params.time = os.time()												    			--时间戳	 time
	params.sign = UtilEx:md5Data(params.spid .. params.sid .. params.role_id .. params.time .. key)   --签名
	-- params.platfrom = cc.Application:getInstance():getTargetPlatform() 					--本机类型   PLATFORM

	local url_format = "http://l.cqtest.jianguogame.com:88/api/red_pay_phase.php?spid=%s&time=%s&sign=%s&sid=%s&role_id=%s"
	local url_str = string.format(url_format, params.spid, tostring(params.time), params.sign, tostring(params.sid), tostring(params.role_id))

	HttpClient:Request(url_str, "", 
		function(url, arg, data, size)
			self:RechargeCfgCallback(url, arg, data, size)
		end)
end

function ConsignCtrl:RechargeCfgCallback(url, arg, data, size)
	if nil == data then
		Log("--->>>ReqRechargeConfig data is nil")
		return
	end

	if size <= 0 then
		Log("--->>>ReqRechargeConfig size <= 0")
		return
	end
	
	local ret_t = cjson.decode(data)
	if nil ~= ret_t and nil ~= ret_t.data then
		self.data:SetRechargeCfgByBackstage(ret_t.data)
		ViewManager:FlushViewByDef(ViewDef.Consign.RedDrill)
	end
end

function ConsignCtrl:OpenRedDrilleTip(num)
	self.reddrille_tip_view:SetNumber(num)
	ViewManager.Instance:OpenViewByDef(ViewDef.RedDrilleTip)
end