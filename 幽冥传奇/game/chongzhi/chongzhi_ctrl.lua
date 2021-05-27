require("scripts/game/chongzhi/chongzhi_data")
-- require("scripts/game/chongzhi/chongzhi_view")
ChongzhiCtrl = ChongzhiCtrl or BaseClass(BaseController)
function ChongzhiCtrl:__init()
	if	ChongzhiCtrl.Instance then
		ErrorLog("[ChongzhiCtrl]:Attempt to create singleton twice!")
	end
	ChongzhiCtrl.Instance = self

	-- self.view = ChongzhiView.New(ViewDef.Recharge)
	self.data = ChongzhiData.New()
	self:RegisterAllProtocols()
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.RecvMainRoleInfoCallBack, self))
end

function ChongzhiCtrl:__delete()
	ChongzhiCtrl.Instance = nil

	self.data:DeleteMe()
	self.data = nil
end

function ChongzhiCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCDoubleRebageMsg, "OnDoubleRebageMsg")
	self:RegisterProtocol(SCChongZhiInfo, "OnChongZhiInfo")
end

function ChongzhiCtrl:RecvMainRoleInfoCallBack()
	self:ReqRechargeConfig()
end

-- 向后台请求充值配置
function ChongzhiCtrl:ReqRechargeConfig()
	local key = "hdISla9sjXphPqEoE8lZcg=="
	local params = {}
	params.spid = AgentAdapter:GetSpid()												--平台ID     spid
	params.sid = GameVoManager.Instance:GetUserVo().plat_server_id						--服ID       sid
	params.plat_user_name = AgentAdapter:GetPlatName()      							--平台帐号	 plat_user_name
	params.role_id = GameVoManager.Instance:GetMainRoleVo().role_id		  			    --角色ID     role_id  
	params.role_name = GameVoManager.Instance:GetMainRoleVo().name	  			    	--角色名字   role_name
	params.time = os.time()												    			--时间戳	 time
	params.sign = UtilEx:md5Data(params.spid .. params.sid .. params.role_id .. params.time .. key)   --签名
	local url_format = "http://l.cqtest.jianguogame.com:88/api/pay_phase.php?spid=%s&time=%s&sign=%s&sid=%s&role_id=%s"
	local url_str = string.format(url_format, params.spid, tostring(params.time), params.sign, tostring(params.sid), tostring(params.role_id))

	HttpClient:Request(url_str, "", 
		function(url, arg, data, size)
			self:RechargeCfgCallback(url, arg, data, size)
		end)
end

function ChongzhiCtrl:RechargeCfgCallback(url, arg, data, size)
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
		ViewManager:FlushViewByDef(ViewDef.ZsVip.Recharge)
	end
end

function ChongzhiCtrl:OnDoubleRebageMsg(protocol)
	self.data:SetIsOpenDouble(protocol.is_open_double,protocol.max_times)
end

function ChongzhiCtrl:OnChongZhiInfo(protocol)
	self.data:SetChongZhiDoubleInfo(protocol.files,protocol.chongzhi_info_list)
	ViewManager:FlushViewByDef(ViewDef.ZsVip.Recharge)
end

function ChongzhiCtrl:SendDoubleInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSChongZhiInfoReq)
	protocol:EncodeAndSend()
end


---------------------------------------------
-- view api

-- 充值相关操作
-- 相关接口 AgentAdapter.Pay  [path]scripts/agent/#渠道号
--[[ 
	charge_type 普通充值：0 ；特权卡：1 ；麻痹特戒：2 ；灭霸手套：3；红钻充值：4；
	money 实际充值金额 与后台写死金额对比
]]

function ChongzhiCtrl.Recharge(money, charge_type)
	Log("Recharge try", money, charge_type)
	if (not GLOBAL_CONFIG.param_list.switch_list) or (not GLOBAL_CONFIG.param_list.switch_list.open_chongzhi) then
		SysMsgCtrl.Instance:ErrorRemind("暂未开通充值功能")
		return
	end

	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local role_name = GameVoManager.Instance:GetMainRoleVo().name
	local server_id = GameVoManager.Instance:GetMainRoleVo().server_id
	local is_first = 0 -- 1首充 0不是首充
	if money and money ~= 0 and role_id and role_name and server_id then
		AgentAdapter:Pay(role_id, role_name, money, server_id, nil, is_first, charge_type or 0)
		--Log("Recharge", role_id, role_name, money, server_id, nil, is_first, charge_type or 0)
	else
		SysMsgCtrl.Instance:ErrorRemind("充值操作失败！")
	end
end

-- 特权卡购买
function ChongzhiCtrl.BuyPrivilege(money)
	ChongzhiCtrl.Recharge(money, 1)
end

-- 道具礼包购买
-- EveryDayGiftBagConfig.GradeGift
-- 戒指礼包
function ChongzhiCtrl.BuyRingGift(money)
	ChongzhiCtrl.Recharge(money, 2)
end
-- 手套礼包
function ChongzhiCtrl.BuyHandGift(money)
	ChongzhiCtrl.Recharge(money, 3)
end
-- 红钻充值
function ChongzhiCtrl.BuyRedDiamond(money)
	ChongzhiCtrl.Recharge(money, 4)
end
--运营活动充值
function ChongzhiCtrl.ActivityCharge(money, re_type)
	ChongzhiCtrl.Recharge(money, re_type)
end