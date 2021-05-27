local DigOreAccount = BaseClass(BaseView)

function DigOreAccount:__init()
	self.title_img_path = ResPath.GetWord("DigOreAccount")
	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/experiment.png'
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"experiment_ui_cfg", 3, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
	}

	-- 管理自定义对象
	self._objs = {}
	self.def_idx = 1
end

function DigOreAccount:ReleaseCallBack()
	-- 清理自定对象
	for k, v in pairs(self._objs) do
		if nil == v.DeleteMe then ErrorLog("不可清理的对象 ReleaseCallBack DigOreAccount") end
		v:DeleteMe()
	end
	self._objs = {}

	self.def_idx = 1

	self:DeleteResumeTimer()
end

function DigOreAccount:LoadCallBack(index, loaded_times)	
	EventProxy.New(ExperimentData.Instance, self):AddEventListener(ExperimentData.INFO_CHANGE, BindTool.Bind(self.ExperimentDataChangeCallback, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, function ()
		local consume_id = MiningActConfig.flushConsum.item.id
		local have_num = BagData.Instance:GetItemNumInBagById(consume_id)
		local need_num = MiningActConfig.flushConsum.item.count
		RichTextUtil.ParseRichText(self.node_t_list.rich_consum.node, string.format("{wordcolor;%s;%d}/ %d", have_num >= need_num and COLORSTR.GREEN or COLORSTR.RED, have_num, need_num) , 18, Str2C3b("a19481"))
	end)
	XUI.AddClickEventListener(self.node_t_list.btn_hire.node, function ()
		local info = ExperimentData.Instance:GetBaseInfo()
		if info.quality < #MiningActConfig.Miner then
			if self._objs.alert == nil then
				self._objs.alert = Alert.New()
			end
			-- self._objs.alert:SetShowCheckBox(true)
			self._objs.alert:SetLableString(Language.Dig.QualityTip)
			self._objs.alert:SetOkFunc(function ()	
				ExperimentCtrl.SendExperimentOptReq(2, self.data.slot)
				self:Close()
		  	end)
			self._objs.alert:Open()
		else
			ExperimentCtrl.SendExperimentOptReq(2, self.data.slot)
			self:Close()
		end
	end)

	XUI.AddClickEventListener(self.node_t_list.btn_up.node, function ()
		ExperimentCtrl.SendExperimentOptReq(3)
	end)

	XUI.AddClickEventListener(self.node_t_list.btn_help.node, function ()
		DescTip.Instance:SetContent(Language.DescTip.DigAccountContent, Language.DescTip.DigAccountTitle)
	end)

	-- 创建ui
	self:CreateShowList()

	--刷新所需消耗
	local consume_id = MiningActConfig.flushConsum.item.id
	self.node_t_list.img_consum_icon.node:loadTexture(ResPath.GetItem(ItemData.Instance:GetItemConfig(consume_id).icon))
	local have_num = BagData.Instance:GetItemNumInBagById(consume_id)
	local need_num = MiningActConfig.flushConsum.item.count
	RichTextUtil.ParseRichText(self.node_t_list.rich_consum.node, string.format("{wordcolor;%s;%d}/ %d", have_num >= need_num and COLORSTR.GREEN or COLORSTR.RED, have_num, need_num) , 18, Str2C3b("a19481"))

	self.node_t_list.lbl_gold.node:setString(MiningActConfig.flushConsum.needYb)
end

function DigOreAccount:CreateShowList()
	local ph = self.ph_list.ph_list
	local list_view = ListView.New()
	list_view:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, DigAccountShowRender, nil, false, self.ph_list.ph_item)
	list_view:SetItemsInterval(18)
	list_view:SetMargin(6)
	-- list_view:SetJumpDirection(ListView.Top)
	list_view:GetView():setTouchEnabled(false)
	list_view:SetSelectCallBack(function (render, idx)
		self:FlushAwardByIdx(idx)
	end)
	self.node_t_list.layout_dig_account.node:addChild(list_view:GetView(), 100)

	list_view:SetData(MiningActConfig.Miner)
	self._objs.show_list = list_view
end

function DigOreAccount:FlushAwardByIdx(idx)
	if nil == self._objs.award_list then
		local ph = self.ph_list.ph_award_list
		local list_view = ListView.New()
		list_view:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, BaseCell, nil, false)
		list_view:SetItemsInterval(3)
		self.node_t_list.layout_dig_account.node:addChild(list_view:GetView(), 100)
		self._objs.award_list = list_view
	end
	local data = {}
	for k,v in ipairs(MiningActConfig.Miner[idx].Awards) do
		data[k] = {item_id = v.id, num = v.count, is_bind = v.bind}
	end
	self._objs.award_list:SetData(data)
end

function DigOreAccount:ShowIndexCallBack()
	self:Flush()
end

function DigOreAccount:ExperimentDataChangeCallback()
	self:Flush()
end

function DigOreAccount:OnFlush()
	local data = ExperimentData.Instance:GetBaseInfo()
	local max_time1 = MiningActConfig.initTimes
	self.node_t_list.lbl_dig_num.node:setString(Language.Dig.FindDigTip4 .. (max_time1 - data.dig_num) .. "/" .. max_time1)

	self._objs.show_list:SelectIndex(data.quality)
	self:FlushResumeTimer()
end

function DigOreAccount:SetData(data)
	self.data = data
end

function DigOreAccount:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function DigOreAccount:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function DigOreAccount:OnDataChange(vo)
end

function DigOreAccount:ResumeTimerFunc()
	local time2 = ExperimentData.Instance:GetBaseInfo().resum_dig_num_time + COMMON_CONSTS.SERVER_TIME_OFFSET - TimeCtrl.Instance:GetServerTime()
	if time2 <= 0 then
		self.node_t_list.lbl_time_tip.node:setString("2小时恢复一次")
		self:DeleteResumeTimer()
	else
		self.node_t_list.lbl_time_tip.node:setString("恢复倒计时：" .. TimeUtil.FormatSecond(time2))
	end
end

function DigOreAccount:FlushResumeTimer()
	if nil == self.resume_timer and ExperimentData.Instance:IsResuming() then
		self.resume_timer = GlobalTimerQuest:AddRunQuest(function ()
			self:ResumeTimerFunc()
		end, 1)
		self:ResumeTimerFunc()
	end
end

function DigOreAccount:DeleteResumeTimer()
	if self.resume_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.resume_timer)
		self.resume_timer = nil
	end
end

DigAccountShowRender = DigAccountShowRender or BaseClass(BaseRender)
function DigAccountShowRender:__init()
	
end

function DigAccountShowRender:__delete()
	if nil ~= self.cell_charge_list then
		self.cell_charge_list:DeleteMe()
		self.cell_charge_list = nil
	end
end

function DigAccountShowRender:CreateChild()
	BaseRender.CreateChild(self)
	self:CreateRoleDisplay()
end

function DigAccountShowRender:CreateRoleDisplay( ... )
	if nil == self.role_display then
		self.role_display = RoleDisplay.New(self.view, 100, false, false, true, true)
		self.role_display:SetPosition(100, 200)
		self.role_display:SetScale(0.6)
	end
	self:UpdateApperance()
end

function DigAccountShowRender:UpdateApperance()
	if nil ~= self.role_display then
		local info = MiningActConfig.ClientResCfg[self:GetIndex()]
		local role_vo = {
			[OBJ_ATTR.ENTITY_MODEL_ID] = info.res_id,
			[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = info.wuqi_res_id,
			[OBJ_ATTR.ACTOR_WING_APPEARANCE] = info.chibang_res_id,
			[OBJ_ATTR.ACTOR_THANOSGLOVE_APPEARANCE] = 0,
			[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = 0,
			[OBJ_ATTR.ACTOR_SEX] = info.sex,
		}
		self.role_display:SetRoleVo(role_vo)
	end
end

-- 创建选中特效
function DigAccountShowRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2 - 8, size.width + 2, size.height - 10, ResPath.GetCommon("img9_285"), true)
	if nil == self.select_effect then
		ErrorLog("DigAccountShowRender:CreateSelectEffect fail")
		return
	end
	local sequence = cc.Sequence:create(cc.ScaleTo:create(0.3, 1.05), cc.ScaleTo:create(0.3, 1))
	self.select_effect:runAction(cc.RepeatForever:create(sequence))
	self.view:addChild(self.select_effect, -1)
end

function DigAccountShowRender:OnFlush()
	if nil == self.data then
		return
	end
	self.node_tree.img_lv_name.node:loadTexture(ResPath.GetExperiment("img_lbl_lv_" .. self:GetIndex()))
	self.node_tree.img_award_tip.node:loadTexture(ResPath.GetExperiment("img_lbl_get_" .. self:GetIndex()))
	self.node_tree.img_bg.node:loadTexture(ResPath.GetBigPainting("wk_bg_" .. self:GetIndex()))
end

return DigOreAccount