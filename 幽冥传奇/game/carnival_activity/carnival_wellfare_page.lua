-- 消费返利页面
CarnivalWellfarePage = CarnivalWellfarePage or BaseClass()

function CarnivalWellfarePage:__init()
	self.view = nil
end

function CarnivalWellfarePage:__delete()
	self:RemoveEvent()

	self.view = nil
end

function CarnivalWellfarePage:InitPage(view)
	self.view = view
	XUI.AddClickEventListener(self.view.node_t_list.btn_yuanbao_spend_addup.node, BindTool.Bind(self.OnClickSpendHandler, self), true)
	self:InitEvent()
	self:FlushCfgInfo()
end

function CarnivalWellfarePage:InitEvent()
	-- self.sign_in_data_event = GlobalEventSystem:Bind(WelfareEventType.SIGN_IN_DATA_CHANGE, BindTool.Bind(self.OnSignInDataChange, self))
end

function CarnivalWellfarePage:RemoveEvent()
	-- if self.sign_in_data_event then
	-- 	GlobalEventSystem:UnBind(self.sign_in_data_event)
	-- 	self.sign_in_data_event = nil
	-- end
end

function CarnivalWellfarePage:FlushCfgInfo()
	local cfg = CarnivalConfig.ConsumeReturn.Awards
	if cfg == nil then return end
	for k, v in ipairs(cfg) do
		if self.view.node_t_list["txt_s_stage_title_" .. k] then
			self.view.node_t_list["txt_s_stage_title_" .. k].node:setString(v.desc)
			local per = v.awardFactor * 100
			self.view.node_t_list["txt_s_stage_back_per_" .. k].node:setString(per .. "%")
		end
	end
end

--更新视图界面
function CarnivalWellfarePage:UpdateData(data)
	local my_money = CarnivalData.Instance:getCarnivaWelfareInfo()
	local content = string.format(Language.OperateActivity.SpendGiveMyMoney, my_money)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_my_addup_spend.node, content, 24)
	-- my_money = OperateActivityData.Instance:GetAddupSpendPaybackCnt()
	local index = 0
	local cfg = CarnivalConfig.ConsumeReturn
	if cfg == nil then return end
	for i,v in ipairs(cfg.Awards) do
		if my_money>=v.rechargeLimitNum then
			index = i
			break
		end
	end
	if index>0 then
		my_money = cfg.Awards[index].awardFactor*my_money
	else
		my_money = 0
	end
	content = string.format(Language.OperateActivity.AddChargePayback, my_money)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_my_s_addup_back_cnt.node, content, 24)

	local open_days =  OtherData.Instance:GetRoleCreatDay()
	if cfg and cfg.createRoleStartDay and cfg.createRoleEndDay then
		local time_util = TimeUtil.CONST_3600*TimeUtil.CONST_24
		local server_time = TimeCtrl.Instance:GetServerTime() or os.time()
		local ta_server = os.date("*t", server_time)
		server_time = server_time-(ta_server.hour*TimeUtil.CONST_3600+ta_server.min*TimeUtil.CONST_60+ta_server.sec)
		server_time = server_time-time_util*open_days
		server_time = server_time+time_util*cfg.createRoleStartDay
		local format_time_begin = os.date("*t", server_time)

		if cfg.createRoleEndDay > cfg.createRoleStartDay then
			local left = cfg.createRoleEndDay-cfg.createRoleStartDay
			server_time= server_time+time_util*left
		end
		local format_time_end = os.date("*t", server_time)
		self.view.node_t_list.addup_spend_pb_rest_time.node:setString(format_time_begin.year.."/"..format_time_begin.month.."/"..format_time_begin.day.."-"..format_time_end.year.."/"..format_time_end.month.."/"..format_time_end.day)
	end
end	

function CarnivalWellfarePage:OnClickSpendHandler()
	if self.view then
		self.view:Close()
		ViewManager.Instance:Open(ViewName.Shop, 1)
	end
end

function CarnivalWellfarePage:OnSignInDataChange()

end