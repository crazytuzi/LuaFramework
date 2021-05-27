--------------------------------------------------------
-- 试炼挑战成功  配置 
--------------------------------------------------------

TrialWinView = TrialWinView or BaseClass(BaseView)

function TrialWinView:__init()
	self.texture_path_list[1] = 'res/xui/experiment.png'
	self:SetModal(true)
	self.config_tab = {
		{"trial_ui_cfg", 5, {0}},
	}

end

function TrialWinView:__delete()
end

--释放回调
function TrialWinView:ReleaseCallBack()
	self:CancelTimer()
end

--加载回调
function TrialWinView:LoadCallBack(index, loaded_times)
	self:CreateCellList()

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["layout_receive"].node, BindTool.Bind(self.OnReceive, self), true)
	XUI.AddClickEventListener(self.node_t_list["layout_continue"].node, BindTool.Bind(self.OnContinue, self), true)
end

function TrialWinView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function TrialWinView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self:CancelTimer()
end

--显示指数回调
function TrialWinView:ShowIndexCallBack(index)
	self:CreateTimer()

	self:Flush()
end
----------视图函数----------

function TrialWinView:OnFlush()
	local cur_trial_floor = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SOUL2)
	local cfg = TrialConfig and TrialConfig.chapters or {}
	self.cur_cfg = cfg[cur_trial_floor] or {}
	self.old_cfg = cfg[cur_trial_floor - 1] or {}

	self:FlushCellList()
	self:FlushGuajiAwards()
end


function TrialWinView:CreateTimer()
	self.time = 3
	local callback = function()
		self.time = self.time - 1
		if self:IsOpen() then
			self.node_t_list["lbl_time"].node:setString(string.format("(%d)", self.time))
		end

		if self.time <= 0 then
			self:CancelTimer()
			self:OnContinue()
		end
	end

	self:CancelTimer()
	self.node_t_list["lbl_time"].node:setString(string.format("(%d)", self.time))
	self.timer = GlobalTimerQuest:AddTimesTimer(callback, 1, self.time)
end

function TrialWinView:CancelTimer()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function TrialWinView:CreateCellList()
	local ph = self.ph_list["ph_award_list"]
	local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE}
	local parent = self.node_t_list["layout_trial_win"].node
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w + 10, ActBaseCell, ScrollDir.Horizontal, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	self.cell_list = grid_scroll
	self:AddObj("cell_list")
end

function TrialWinView:FlushCellList()
	local awards = self.cur_cfg.awards or {}
	local show_list = {}
	for i,v in ipairs(awards) do
		show_list[#show_list + 1] = ItemData.InitItemDataByCfg(v)
	end
	self.cell_list:SetDataList(show_list)

	-- 居中处理
	local view = self.cell_list:GetView()
	local inner = view:getInnerContainer()
	local size = view:getContentSize()
	local inner_width =(BaseCell.SIZE + 10) * (#show_list) - 10
	local view_width = math.min(self.ph_list["ph_award_list"].w, inner_width + 20)
	view:setContentSize(cc.size(view_width, size.height))
	view:setInnerContainerSize(cc.size(inner_width, size.height))
	view:jumpToTop()
end

function TrialWinView:FlushGuajiAwards()
	local gjawards = self.cur_cfg.gjawards or {}
	local old_gjawards = self.old_cfg.gjawards or {}
	local moneys = self.cur_cfg.moneys or {}
	local old_moneys = self.old_cfg.moneys or {}
	for i = 1, 4 do
		local award, old_award, count, old_count
		if i == 1 then
			award = moneys[i] or {id = 0, type = 0, count = 0}
			old_award = old_moneys[i] or {id = 0, type = 0, count = 0}
			count = award.count or 0
			old_count = old_award.count or 0
			count = count * 60 * 60
			old_count = old_count * 60 * 60
		else
			award = gjawards[i-1] or {id = 0, type = 0, count = 0}
			old_award = old_gjawards[i-1] or {id = 0, type = 0, count = 0}
			count = (award.count or 0) * 6
			old_count = old_award.count or 0
		end
		count = CommonDataManager.ConverMoney(count)
		old_count = CommonDataManager.ConverMoney(old_count)
		
		-- 图标
		local item = ItemData.InitItemDataByCfg(award)
		local item_cfg = ItemData.Instance:GetItemConfig(item.item_id)
		local path = ResPath.GetItem(tonumber(item_cfg.icon))
		self.node_t_list["img_award_" .. i].node:loadTexture(path)
		self.node_t_list["img_award_" .. i].node:setScale(0.35)


		local old_text = old_count
		self.node_t_list["lbl_old_award_" .. i].node:setString(old_text)

		local text =  string.format("{color;%s;%s}/小时", COLORSTR.GREEN, count)
		RichTextUtil.ParseRichText(self.node_t_list["rich_award_" .. i].node, text, 20, Str2C3b("e4ddba"))
		XUI.RichTextSetCenter(self.node_t_list["rich_award_" .. i].node)
		self.node_t_list["rich_award_" .. i].node:setHorizontalAlignment(RichHAlignment.HA_RIGHT)
		self.node_t_list["rich_award_" .. i].node:refreshView()
	end
end


----------end----------

function TrialWinView:OnReceive()
	local fuben_id = FubenData.Instance:GetFubenId()
	FubenCtrl.OutFubenReq(fuben_id)
	ViewManager.Instance:CloseViewByDef(ViewDef.TrialWin)
end

function TrialWinView:OnContinue()
	local cur_trial_floor = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SOUL2)
	local cfg = TrialConfig and TrialConfig.chapters or {}
	local cur_cfg = cfg[cur_trial_floor + 1] or {}
	local conditions = cur_cfg.conditions or {}
	local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local wing_lv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_LEVEL)
	local role_data = {["level"] = role_lv, ["circle"] = circle;["swinglv"] = wing_lv}
	local conditions_key = {
		{"level", "人物等级不足"},
		{"circle", "转生等级不足"},
		{"swinglv", "翅膀等级不足"},
	}
	local can_enter_trial = true
	local tip_text = nil
	for i,v in ipairs(conditions_key) do
		local key = v[1]
		local conditions_lv = conditions[key] or 0
		if conditions_lv > 0 then
			if role_data[key] < conditions_lv then
				tip_text = v[2]
				can_enter_trial = false
				break
			end
		end
	end

	if next(cur_cfg) and can_enter_trial then
		ExperimentCtrl.SendChallengeTrialReq()
	elseif nil == next(cur_cfg) then
		local str = Language.Trial.Trial_1 -- "已成功挑战最后一关"
		SysMsgCtrl.Instance:FloatingTopRightText(str)

		ViewManager.Instance:CloseViewByDef(ViewDef.TrialWin)
	else
		local fuben_id = FubenData.Instance:GetFubenId()
		FubenCtrl.OutFubenReq(fuben_id)
		SysMsgCtrl.Instance:FloatingTopRightText(tip_text or "未达到条件,进入下一关失败")
	end
	ViewManager.Instance:CloseViewByDef(ViewDef.TrialWin)
end

--------------------
