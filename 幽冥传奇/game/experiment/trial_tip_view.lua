--------------------------------------------------------
-- 试炼-练功收益(上线提示)  配置 
--------------------------------------------------------

TrialTipView = TrialTipView or BaseClass(BaseView)

function TrialTipView:__init()
	self.texture_path_list = {
		'res/xui/experiment.png',
	}
	self.config_tab = {
		{"trial_ui_cfg", 8, {0}},
	}

	self.is_any_click_close = true
	self:SetModal(true)
end

function TrialTipView:__delete()

end

--释放回调
function TrialTipView:ReleaseCallBack()
end

--加载回调
function TrialTipView:LoadCallBack(index, loaded_times)

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_1"].node, BindTool.Bind(self.OnBtn, self, 2), true)


	-- 数据监听
	EventProxy.New(ExperimentData.Instance, self):AddEventListener(ExperimentData.TRIAL_DATA_CHANGE, BindTool.Bind(self.FlushEarnings, self))
end

function TrialTipView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function TrialTipView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()

	ExperimentCtrl.SendReceiveTrialAwardsReq()
end

--显示指数回调
function TrialTipView:ShowIndexCallBack(index)
	self:Flush()
end

----------视图函数----------

function TrialTipView:OnFlush(param_list, index)
	self:FlushAward()
	self:FlushEarnings()
	self:FlushVipLv()
	self:FlushRichText()
end


function TrialTipView:FlushAward()
	local cur_trial_floor = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SOUL2)
	local cfg = TrialConfig and TrialConfig.chapters or {}
	local cur_cfg = cfg[cur_trial_floor] or cfg[1] or {}
	local gjawards = cur_cfg.gjawards or {}
	local moneys = cur_cfg.moneys or {}

	for i = 1, 4 do
		if next(gjawards) and next(moneys) then
			local award, count, item
			if i == 1 then
				award = moneys[i] or {id = 0, type = 0, count = 0}
				count = award.count or 0
				count = count * 60 * 60
				item = ItemData.InitItemDataByCfg(award)
			else
				award = gjawards[i - 1] or {id = 0, type = 0, count = 0}
				count = (award.count or 0) * 6
				item = ItemData.InitItemDataByCfg(award)
			end
			count = CommonDataManager.ConverMoney(count)

			-- 图标
			item = ItemData.InitItemDataByCfg(award)
			local item_cfg = ItemData.Instance:GetItemConfig(item.item_id)
			local path = ResPath.GetItem(tonumber(item_cfg.icon))
			self.node_t_list["img_total_award_" .. i].node:loadTexture(path)
			self.node_t_list["img_total_award_" .. i].node:setScale(0.35)
			self.node_t_list["img_total_award_" .. i].node:setVisible(true)
		else
			self.node_t_list["img_total_award_" .. i].node:setVisible(false)
		end
	end

end

function TrialTipView:FlushEarnings(data)
	local title_text = Language.Trial and Language.Trial.GjAwardsTitle or {}
	local data = data or ExperimentData.Instance:GetTrialData()
	local awards = data.awards or {}
	local cur_trial_floor = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SOUL2)
	for i = 1, 4 do
		local num = awards[i] and awards[i].num or 0
		self.node_t_list["lbl_total_award_" .. i].node:setString((title_text[i] or "") .. "：" .. num)
	end

	local time = TimeUtil.FormatSecond2Str(data.all_hang_up_times)
	self.node_t_list["lbl_cur_time"].node:setString("练功时间：" .. time)
end

function TrialTipView:FlushVipLv()
	if nil == self.vip_lv then
		local ph = self.ph_list["ph_vip_lv"]
		local path = ResPath.GetExperiment("num_vip2_")
		local parent = self.node_t_list["layout_trial_tip"].node
		local number_bar = NumberBar.New()
		number_bar:Create(ph.x, ph.y, ph.w, ph.h, path)
		number_bar:SetSpace(-10)
		number_bar:SetGravity(NumberBarGravity.Left)
		parent:addChild(number_bar:GetView(), 99)
		self.vip_lv = number_bar
		self:AddObj("vip_lv")
	end

	local vip_lv = VipData.Instance:GetVipLevel()
	self.vip_lv:SetNumber(vip_lv)
end

function TrialTipView:FlushRichText()
	local vip_lv = VipData.Instance:GetVipLevel()
	local cfg = TrialConfig and TrialConfig.diamondsPlus or {}
	local cur_cfg = cfg[vip_lv] or {}
	local gjtime = cur_cfg.gjtime or 0
	gjtime = math.floor(gjtime / 60 / 60)
	local rich = self.node_t_list["rich_text_1"].node
	local text = string.format(Language.Trial.TrialTipRich, COLORSTR.ORANGE, gjtime)
	rich = RichTextUtil.ParseRichText(rich, text, 16, COLOR3B.OLIVE)
	XUI.RichTextSetCenter(rich)
	rich:refreshView()
end

----------end----------

function TrialTipView:OnBtn()
	self:Close()
end

--------------------
