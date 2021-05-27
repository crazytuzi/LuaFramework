-- 运营活动-许愿井
OperateWishWellPage = OperateWishWellPage or BaseClass()

function OperateWishWellPage:__init()
	self.view = nil

end

function OperateWishWellPage:__delete()
	self:RemoveEvent()
	if self.record_list then
		self.record_list:DeleteMe()
		self.record_list = nil
	end
	self.view = nil
end


function OperateWishWellPage:InitPage(view)
	self.view = view
	self:CreateRecordList()
	-- self.view.node_t_list.rich_wish_well_des.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	-- 安卓平台调整位置
	if PLATFORM == cc.PLATFORM_OS_ANDROID then
		local pos_y = self.view.node_t_list.rich_wish_rest_get_info.node:getPositionY()
		self.view.node_t_list.rich_wish_rest_get_info.node:setPositionY(pos_y + 6)
	end
	self:InitEvent()
end

--初始化事件
function OperateWishWellPage:InitEvent()
	XUI.AddClickEventListener(self.view.node_t_list.layout_start_wish.node, BindTool.Bind(self.OnStartWishClick, self), true)
	self.wish_well_evt = GlobalEventSystem:Bind(OperateActivityEventType.WISH_WELL_DATA_CHANGE, BindTool.Bind(self.OnWishWellDataChange, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
end

--移除事件
function OperateWishWellPage:RemoveEvent()
	if self.wish_well_evt then
		GlobalEventSystem:UnBind(self.wish_well_evt)
		self.wish_well_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

end

-- 刷新
function OperateWishWellPage:UpdateData(param_t)
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.WISH_WELL)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, OPERATE_ACTIVITY_ID.WISH_WELL)
	end

	local cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.WISH_WELL)
	local content = cfg and cfg.act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_wish_well_des.node, content, 24, COLOR3B.YELLOW)
end

function OperateWishWellPage:CreateRecordList()
	if not self.record_list then
		local ph = self.view.ph_list.ph_wish_record_list
		self.record_list = ListView.New()
		self.record_list:SetIsUseStepCalc(false)
		self.record_list:Create(ph.x, ph.y, ph.w, ph.h, direction, RecordRender, gravity, is_bounce, self.view.ph_list.ph_record_content)
		self.record_list:SetJumpDirection(ListView.Top)
		self.record_list:SetMargin(2)
		self.view.node_t_list.layout_wish_well.node:addChild(self.record_list:GetView(), 100)
	end
end

function OperateWishWellPage:FlushInfo()
	local rest_wish_cnt = OperateActivityData.Instance:GetWishWellRestWishCnt()
	local already_get_cnt = OperateActivityData.Instance:GetWishWellAlreadyGetCnt()
	local content = string.format(Language.OperateActivity.WishWellTexts[2], rest_wish_cnt, already_get_cnt)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_wish_rest_get_info.node, content, 20, COLOR3B.BRIGHT_GREEN)
	local record_data = OperateActivityData.Instance:GetWishWellRecordData()
	if record_data and self.record_list then
		self.record_list:SetDataList(record_data)
	end
end

function OperateWishWellPage:OnWishWellDataChange()
	self:FlushRemainTime()
	self:FlushInfo()
end

function OperateWishWellPage:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.WISH_WELL)

	if self.view.node_t_list.txt_wish_well_time then
		self.view.node_t_list.txt_wish_well_time.node:setString(time)
	end

	if OperateActivityData.Instance:IsGetAllWishCnt() then
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_next_add_one_time.node, "")
	else
		local add_gap_time = OperateActivityData.Instance:GetWishWellAddCntRestTime()
		if add_gap_time > 0 then
			local gap_time_str = TimeUtil.FormatSecond2Str(add_gap_time, 1)
			local content = string.format(Language.OperateActivity.WishWellTexts[1], gap_time_str)
			RichTextUtil.ParseRichText(self.view.node_t_list.rich_next_add_one_time.node, content, 20)
		elseif add_gap_time == 0 then
			local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.WISH_WELL)
			if cmd_id then
				OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, OPERATE_ACTIVITY_ID.WISH_WELL)
			end
		end 
	end
end

function OperateWishWellPage:OnStartWishClick()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.WISH_WELL)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.WISH_WELL)
	end
end