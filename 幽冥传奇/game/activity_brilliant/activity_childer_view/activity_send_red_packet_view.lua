SendRedPacketView = SendRedPacketView or BaseClass(ActBaseView)

function SendRedPacketView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function SendRedPacketView:__delete()
	if self.packet_record_list then 
		self.packet_record_list:DeleteMe()
		self.packet_record_list = nil
	end

	self:DeleteCutDownTimer()
end

function SendRedPacketView:InitView()
	self:CreatePacketRecord()
	--self.node_t_list.btn_go_charge.node:addClickEventListener(BindTool.Bind(self.OnClickGoChargeHandler, self))
	self.node_t_list.btn_send.node:addClickEventListener(BindTool.Bind(self.OnClickSendHandler, self))
	self.select_index = 1
	self.node_t_list.btn_go_charge.node:addClickEventListener(BindTool.Bind(self.OnClickGoChargeHandler, self))

	XUI.RichTextSetCenter(self.node_t_list.rich_next_send_time.node)	
end

function SendRedPacketView:OnClickGoChargeHandler()
	ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
	ActivityBrilliantCtrl.Instance:CloseView(self.act_id)
end

function SendRedPacketView:CreatePacketRecord()
	if nil == self.packet_record_list then
		local ph = self.ph_list.ph_rob_list
		self.packet_record_list = ListView.New()
		self.packet_record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, RedPacketRecordRender, nil, nil, nil)
		self.packet_record_list:GetView():setAnchorPoint(0, 0)
		self.packet_record_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_rob_red_packet.node:addChild(self.packet_record_list:GetView(), 100)
	end		
end

function SendRedPacketView:CreateSelecSingleBtn()
	if self.select_btn_view then return self.select_btn_view end
	local view = {}
	view.current_index = 1

	local width = 120
	local x = 230
	local y = 110
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.FHB)
	for index,v in ipairs(cfg.config.consumeType) do
		local vo = {
			btn_nohint_checkbox =  XUI.CreateImageView(index * width + x, y, ResPath.GetCommon("part_104")),
			img_hook =  XUI.CreateImageView(index * width + x, y, ResPath.GetCommon("bg_checkbox_hook")),
			lbl_text_tip = XUI.CreateText(index * width + x + 65, y - 12, 100, 50, cc.TEXT_ALIGNMENT_LEFT, v.name),
		}

		XUI.AddClickEventListener(vo.btn_nohint_checkbox, function ()	
			view.SetSelect(index)
		end, true)

		self.node_t_list.layout_rob_red_packet.node:addChild(vo.btn_nohint_checkbox, 300)
		self.node_t_list.layout_rob_red_packet.node:addChild(vo.img_hook, 300)
		self.node_t_list.layout_rob_red_packet.node:addChild(vo.lbl_text_tip, 300)
		vo.img_hook:setVisible(false)
		view[index] = vo
	end
	function view.SetSelect(index)
		view.current_index = index
		for k,v in ipairs(view) do
			view[k].img_hook:setVisible(index == k)
		end
		if view.SelectCallBack then
			view.SelectCallBack(index)
		end
	end

	function view.SetSelectCallBack(callfunc)
		view.SelectCallBack = callfunc
	end
	view.SetSelect(1)
	return view
end

function SendRedPacketView:RefreshView(param_list)
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.FHB)
	self.select_btn_view = self:CreateSelecSingleBtn()
	self.select_btn_view.SetSelectCallBack(function (index)	
		self.select_index = index
		local num = cfg.config.consumeType[index].consumeIntegral
		local str = string.format(Language.ActivityBrilliant.SendRedPacketComsume, num or 0)
		self.node_t_list.lbl_send_text.node:setString(str)
	end)
	local integral = ActivityBrilliantData.Instance:GetRedPacketIntegral()
	self.node_t_list.lbl_jifen.node:setString(string.format(Language.ActivityBrilliant.CurIntegral, integral))
	local packet_record = ActivityBrilliantData.Instance:GetRedPacketRrecord()
	self.packet_record_list:SetDataList(packet_record)

	self:FlushCutDownTimer()
end

function SendRedPacketView:GetCutDownTime()		
	return ActivityBrilliantData.Instance.cooling_endtime - TimeCtrl.Instance:GetServerTime()
end

function SendRedPacketView:CutDownTimerFunc()		
	local time = self:GetCutDownTime()
	self.node_t_list.rich_next_send_time.node:setVisible(time > 0)
	if time <= 0 then
		self:DeleteCutDownTimer()
	else
		RichTextUtil.ParseRichText(self.node_t_list.rich_next_send_time.node, "下次抢红包冷却时间:" .. TimeUtil.FormatSecond(time), 20)
	end
end

function SendRedPacketView:FlushCutDownTimer()
	if nil == self.cutdown_timer and self:GetCutDownTime() > 0 then
		self.cutdown_timer = GlobalTimerQuest:AddRunQuest(function ()
			self:CutDownTimerFunc()
		end, 1)
	end
	self:CutDownTimerFunc()
end

function SendRedPacketView:DeleteCutDownTimer()
	if self.cutdown_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.cutdown_timer)
		self.cutdown_timer = nil
	end
end

function SendRedPacketView:OnClickSendHandler()
	ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.FHB, 2, self.select_index)
end


RedPacketRecordRender = RedPacketRecordRender or BaseClass(BaseRender)
function RedPacketRecordRender:__init(w, h, list_view)	
	self.view_size = cc.size(280, 24)
	self.view:setContentSize(self.view_size)
	self.list_view = list_view
end

function RedPacketRecordRender:__delete()	
end

function RedPacketRecordRender:CreateChild()
	BaseRender.CreateChild(self)

	self.rich_text = RichTextUtil.ParseRichText(nil, "", 20, nil, 0, 0, self.view_size.width, self.view_size.height)
	self.rich_text:setAnchorPoint(0, 0)
	-- self.rich_text:setIgnoreSize(true)
	self.view:addChild(self.rich_text, 9)
end

function RedPacketRecordRender:OnFlush()
	if self.data == nil then return end
	local content = string.format(Language.ActivityBrilliant.RedPacketRecordStr, self.data.name, Language.ActivityBrilliant.FlagTypeGroup[self.data.flag], self.data.gold)
	-- self.rich_text:removeAllElements()
	RichTextUtil.ParseRichText(self.rich_text, content, 18)
	self.rich_text:refreshView()
	local inner_size = self.rich_text:getInnerContainerSize()
	local size = {
		width = math.max(inner_size.width, self.view_size.width),
		height = math.max(inner_size.height, self.view_size.height),
	}
	self.rich_text:setContentSize(size)
	self.view:setContentSize(size)
	self.list_view:requestRefreshView()
end

function RedPacketRecordRender:CreateSelectEffect()
end