require('game.vipSmall.RequireVipSmall')
VipSmallController = VipSmallController or class("VipSmallController",BaseController)

function VipSmallController:ctor()
	VipSmallController.Instance = self

	self.vip_small_model = VipSmallModel:GetInstance()
	self.vip_small_model_events = {}

	self.global_events = {}

    self:AddEvents()
    
	self:RegisterAllProtocal()
end

function VipSmallController:dctor()
	GlobalEvent:RemoveTabListener(self.global_events)
	self.global_events = {}

	self.vip_small_model:RemoveTabListener(self.vip_small_model_events)
	self.vip_small_model_events = {}
end

function VipSmallController:GameStart(  )

	local function callback(  )
		--游戏开始时获取一下相关信息
		self:RequestVip2Info()
		WelfareController.GetInstance():RequestWelfareOnline2()
	end
	GlobalSchedule:StartOnce(callback, Constant.GameStartReqLevel.High)

	local function callback(  )
		local function callback2(  )
			--每分钟获取一次小贵族在线奖励信息
			WelfareController.GetInstance():RequestWelfareOnline2()
		end
		GlobalSchedule:Start(callback2, 60)
	end
	GlobalSchedule:StartOnce(callback, Constant.GameStartReqLevel.Low)
end

function VipSmallController:GetInstance()
	if not VipSmallController.Instance then
		VipSmallController.new()
	end
	return VipSmallController.Instance
end

function VipSmallController:RegisterAllProtocal(  )
	-- protobuff的模块名字，用到pb一定要写
	self.pb_module_name = "pb_1148_vip2_pb"
	self:RegisterProtocal(proto.VIP2_INFO, self.HandleVip2Info)
	self:RegisterProtocal(proto.VIP2_FETCH, self.HandleVip2Fetch)
	self:RegisterProtocal(proto.VIP2_ACTIVE, self.HandleVip2Active)
end

function VipSmallController:AddEvents()

	--打开小贵族界面
	local function call_back()
		local panel = lua_panelMgr:GetPanelOrCreate(VipSmallPanel)
		panel:Open()
	end
	GlobalEvent:AddListener(VipSmallEvent.OpenVipSmallPanel, call_back)

	--使用小贵族激活卡物品的返回处理
	-- local function call_back(id)
	-- 	if self.vip_small_model.vip2_card_cfg[id] then
	-- 		local card_id = self.vip_small_model.vip2_card_cfg[id].id
	-- 		--logError("使用了小贵族激活卡,id为.."..card_id)
	-- 		self:RequestVip2Active(card_id)
	-- 	end
	-- end
	-- GlobalEvent:AddListener(GoodsEvent.UseItemSuccess, call_back)
end

--请求小贵族信息
function VipSmallController:RequestVip2Info(  )
	local pb = self:GetPbObject("m_vip2_info_tos")
	self:WriteMsg(proto.VIP2_INFO, pb)
	--logError("请求小贵族信息")
end

--处理小贵族信息返回
function VipSmallController:HandleVip2Info(  )
	local data = self:ReadMsg("m_vip2_info_toc")
	--logError("处理小贵族信息返回-"..Table2String(data))
	local level = data.level  --小贵族等级
	local exp = data.exp  --小贵族经验
	local lv_reward = data.lv_reward  --已领取的等级奖励

	self.vip_small_model.vip_small_lv = level
	self.vip_small_model.vip_small_exp = exp
	self.vip_small_model.lv_reward = lv_reward

	self.vip_small_model:Brocast(VipSmallEvent.HandleVip2Info)

	local show_icon_reddot = self.vip_small_model:IsCanReceiveReward()
	GlobalEvent:Brocast(VipSmallEvent.VipSmallIconReddotChange,show_icon_reddot)
end

--请求小贵族奖励领取
function VipSmallController:RequestVip2Fetch(level)
	local pb = self:GetPbObject("m_vip2_fetch_tos")
	pb.level = level  --等级
	self:WriteMsg(proto.VIP2_FETCH, pb)
	--logError("请求小贵族奖励领取,lv-"..level)
end

--处理小贵族奖励领取返回
function VipSmallController:HandleVip2Fetch(  )
	local data = self:ReadMsg("m_vip2_fetch_toc")
	--logError("处理小贵族奖励领取返回-"..Table2String(data))
	local level = data.level
	table.insert(self.vip_small_model.lv_reward,level)
	self.vip_small_model:Brocast(VipSmallEvent.HandleVip2Fetch)

	local show_icon_reddot = self.vip_small_model:IsCanReceiveReward()
	GlobalEvent:Brocast(VipSmallEvent.VipSmallIconReddotChange,show_icon_reddot)
end

--请求小贵族激活
function VipSmallController:RequestVip2Active(id)
	local pb = self:GetPbObject("m_vip2_active_tos")
	pb.id = id
	self:WriteMsg(proto.VIP2_ACTIVE, pb)
	--logError("请求小贵族激活,id-"..id)
end

--处理小贵族激活返回
function VipSmallController:HandleVip2Active( )
	local data = self:ReadMsg("m_vip2_active_toc")
	--logError("处理小贵族激活返回-"..Table2String(data))
	local id = data.id
	self.vip_small_model:Brocast(VipSmallEvent.HandleVip2Active)

	--激活完成后重新请求下信息
	self:RequestVip2Info()
end
