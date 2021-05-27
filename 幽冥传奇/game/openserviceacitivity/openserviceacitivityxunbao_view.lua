local OpenServiceAcitivityXunBaoView = OpenServiceAcitivityXunBaoView or BaseClass(SubView)

function OpenServiceAcitivityXunBaoView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/openserviceacitivity.png'
	self.config_tab = {
		{"openserviceacitivity_ui_cfg", 3, {0}},
		{"openserviceacitivity_ui_cfg", 10, {0}},
	}
end

function OpenServiceAcitivityXunBaoView:LoadCallBack()
	self:CreateTreasureBox()
	self:CreateProgressBar()
	EventProxy.New(OpenServiceAcitivityData.Instance, self):AddEventListener(OpenServiceAcitivityData.XunBaoChange, BindTool.Bind(self.OnFlushXunBaoView, self))
end

function OpenServiceAcitivityXunBaoView:ReleaseCallBack()
	if self.award_list then
		for k, v in pairs(self.award_list) do
			v:DeleteMe()
			v = {}
		end
		self.award_list = {}
	end

	if nil ~= self.progress_bar then
		self.progress_bar:DeleteMe()
		self.progress_bar = nil
	end

	if self.treasure_box_list then
		for k, v in pairs(self.treasure_box_list) do
			v:DeleteMe()
			v = nil
		end
		self.treasure_box_list = nil
	end
	if self.consume_timer_quest then
		GlobalTimerQuest:CancelQuest(self.consume_timer_quest)
	end

	self.panel_info = {}
end

function OpenServiceAcitivityXunBaoView:ShowIndexCallBack()
	self.node_t_list.img_top_bg.node:loadTexture(ResPath.GetBigPainting("open_service_acitivity_bg3"))
	self:OnFlushXunBaoView()
end

function OpenServiceAcitivityXunBaoView:OnFlushXunBaoView()
	self.panel_info = OpenServiceAcitivityData.Instance:GetXunBaoInfo()
	self.node_t_list.lbl_xunbao_times.node:setString(self.panel_info.xun_bao_times)
	self:SetBoxData()
	self:SetProgressBar()
	local activity_time_text = self.panel_info.time.day .. "天" .. self.panel_info.time.hour .. "小时" .. self.panel_info.time.min .. "分钟"
	self.node_t_list.lbl_activity_time.node:setString(activity_time_text)

	if self.consume_timer_quest then
		GlobalTimerQuest:CancelQuest(self.consume_timer_quest)
	end
	self.consume_timer_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SetCountdown, self), 60)
end

function OpenServiceAcitivityXunBaoView:CreateTreasureBox()
	if nil ~= self.treasure_box_list then return end
	self.treasure_box_list = {}
	self.panel_info = OpenServiceAcitivityData.Instance:GetXunBaoInfo()
	for k, v in pairs(self.panel_info.item_list) do
		local box_item = TreasureBoxRender.New()
		local x, y = self.ph_list["ph_box_" .. k].x, self.ph_list["ph_box_" .. k].y
		box_item:SetUiConfig(self.ph_list.ph_box_render, true)
		box_item:GetView():setPosition(x, y)
		self.node_t_list.layout_xunbao.node:addChild(box_item:GetView(), 99)
		self.treasure_box_list[k] = box_item
	end
end

function OpenServiceAcitivityXunBaoView:CreateProgressBar()
	if self.progress_bar == nil then
		self.progress_bar = ProgressBar.New()
		self.progress_bar:SetView(self.node_t_list.prog9_xun_bao.node)
		self.progress_bar:SetTotalTime(0)
		self.progress_bar:SetTailEffect(991, nil, true)
		self.progress_bar:SetEffectOffsetX(-20)
		self.progress_bar:SetPercent(0)
	end
end

function OpenServiceAcitivityXunBaoView:SetCountdown()
	self.panel_info.time.min = self.panel_info.time.min - 1
	if self.panel_info.time.min < 0 then
		self.panel_info.time.min = 59
		self.panel_info.time.hour = self.panel_info.time.hour - 1
		if self.panel_info.time.hour < 0 then
			self.panel_info.time.hour = 23
			self.panel_info.time.day = self.panel_info.time.day - 1
			if self.panel_info.time.day < 0 then
				----------------------------------------------------------
				OpenServiceAcitivityData.Instance:UpdateTabbarMarkList()
				----------------------------------------------------------
			end
		end
	end
	
	local activity_time_text = self.panel_info.time.day .. "天" .. self.panel_info.time.hour .. "小时" .. self.panel_info.time.min .. "分钟"
	self.node_t_list.lbl_activity_time.node:setString(activity_time_text)
end

function OpenServiceAcitivityXunBaoView:SetBoxData()
	for k, v in pairs(self.treasure_box_list) do
		if self.panel_info.item_list[k] then
			v:SetData(self.panel_info.item_list[k])
		end
	end
end

-- 设置进度条
function OpenServiceAcitivityXunBaoView:SetProgressBar()
	local times = self.panel_info.xun_bao_times
	local percent = 0
	local last_limit = 0
	for k, v in pairs(self.panel_info.item_list) do
		if times >= v.limit_times then
			if k == 1 then
				percent = percent + 0.5 * (100 / #self.panel_info.item_list)
			else
				percent = percent + (100 / #self.panel_info.item_list)
			end
		else
			percent = percent + ((times - last_limit) / (v.limit_times - last_limit)) * (100 / #self.panel_info.item_list)
			if k == 1 then 
				percent = percent * 0.5
			end
			break
		end
		last_limit = v.limit_times
	end
	self.progress_bar:SetPercent(percent)
end

-- 宝箱Render
TreasureBoxRender = TreasureBoxRender or BaseClass(BaseRender)

function TreasureBoxRender:__init()
	self:AddClickEventListener()
end

function TreasureBoxRender:__delete()
end

function TreasureBoxRender:CreateChildCallBack()
	self.node_tree.img_stamp.node:setVisible(false)
	self.node_tree.remind_eff = RenderUnit.CreateEffect(335, self.view, 99)
	self:SetClickCallBack(BindTool.Bind(self.OnClickBox, self))
	self:CreateXunBaoNum()
end

function TreasureBoxRender:OnFlush()
	if nil == self.data then return end
	self.need_xun_bao_num:SetNumber(self.data.limit_times)
	self.node_tree.img_box.node:loadTexture(ResPath.GetOpenServerActivities("treasure_box" .. self.data.index))
	self.node_tree.img_box.node:setGrey(self.data.btn_state == 2)
	self.need_xun_bao_num:SetGrey(self.data.btn_state == 2)
	self.node_tree.img_word_bg.node:setGrey(self.data.btn_state == 2)
	self.node_tree.img_bg.node:setGrey(self.data.btn_state == 2)
	self.node_tree.img_stamp.node:setVisible(self.data.btn_state == 2)
	self.node_tree.remind_eff:setVisible(self.data.btn_state == 1)
end

-- 创建需要寻宝次数NumberBar
function TreasureBoxRender:CreateXunBaoNum()
	if self.need_xun_bao_num ~= nil then return end
	local ph = self.ph_list.ph_xunbao_num
	local x, y = ph.x, ph.y
	local charge_num = NumberBar.New()
	charge_num:SetRootPath(ResPath.GetCommon("num_151_"))
	charge_num:SetPosition(x, y - 10)
	charge_num:SetSpace(-7)
	self.need_xun_bao_num = charge_num
	self.need_xun_bao_num:SetGravity(NumberBarGravity.Center)
	self:GetView():addChild(charge_num:GetView(), 100, 100)
end

-- 选中回调
function TreasureBoxRender:OnClickBox()
	if 1 == self.data.btn_state then
		OpenServiceAcitivityCtrl.SendGetXunBaoGift(self.data.index)
	else
		TipCtrl.Instance:OpenItem(OpenServiceAcitivityData.Instance:GetXunBaoAwardShowData(self.data.index), EquipTip.FROM_NORMAL)
	end
end

-- 创建选中特效
function TreasureBoxRender:CreateSelectEffect()
end

return OpenServiceAcitivityXunBaoView