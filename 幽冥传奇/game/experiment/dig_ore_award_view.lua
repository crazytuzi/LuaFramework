local DigOreAward = BaseClass(BaseView)

function DigOreAward:__init()
	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/experiment.png'
	}
	self.config_tab = {
		{"experiment_ui_cfg", 4, {0}},
	}

	-- 管理自定义对象
	self._objs = {}
end

function DigOreAward:ReleaseCallBack()
	-- 清理自定对象
	for k, v in pairs(self._objs) do
		if nil == v.DeleteMe then ErrorLog("不可清理的对象 ReleaseCallBack DigOreAward") end
		v:DeleteMe()
	end
	self._objs = {}
end

function DigOreAward:LoadCallBack(index, loaded_times)
	XUI.AddClickEventListener(self.node_t_list.btn_lingqu.node, function ()
		ExperimentCtrl.SendExperimentOptReq(5, 1)
		self:Close()
		ExperimentCtrl.Instance:CheckNeedOpenDigAcountView()
	end)

	XUI.AddClickEventListener(self.node_t_list.btn_double_lingqu.node, function ()
		ExperimentCtrl.SendExperimentOptReq(5, 2)
		self:Close()
		ExperimentCtrl.Instance:CheckNeedOpenDigAcountView()
	end)

	self:CreateRoleDisplay()
	self:CreateAwardList()
end

function DigOreAward:ShowIndexCallBack()
	self:FlushView()
end

function DigOreAward:CreateAwardList()
	local ph = self.ph_list.ph_award_list
	local list_view = ListView.New()
	list_view:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, DigAwardRender, nil, false, self.ph_list.ph_item)
	list_view:SetItemsInterval(18)
	-- list_view:SetJumpDirection(ListView.Top)
	-- list_view:SetSelectCallBack(function (render, idx)
	-- 	self:FlushAwardByIdx(idx)
	-- end)
	self.node_t_list.layout_dig_award.node:addChild(list_view:GetView(), 100)

	list_view:SetData(MiningActConfig.Miner)
	self._objs.award_list = list_view
end

function DigOreAward:CreateRoleDisplay( ... )
	if nil == self._objs.role_display then
		self._objs.role_display = RoleDisplay.New(self.node_t_list.layout_dig_award.node, 100, false, false, true, true)
		self._objs.role_display:SetPosition(130, 314)
		self._objs.role_display:SetScale(0.6)
	end
end

function DigOreAward:UpdateApperance()
	if nil ~= self._objs.role_display then
		local info = MiningActConfig.ClientResCfg[self.data.idx]
		local role_vo = {
			[OBJ_ATTR.ENTITY_MODEL_ID] = info.res_id,
			[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = info.wuqi_res_id,
			[OBJ_ATTR.ACTOR_WING_APPEARANCE] = info.chibang_res_id,
			[OBJ_ATTR.ACTOR_THANOSGLOVE_APPEARANCE] = 0,
			[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = 0,
			[OBJ_ATTR.ACTOR_SEX] = info.sex,
		}
		self._objs.role_display:SetRoleVo(role_vo)
	end
end

function DigOreAward:FlushView()
	if nil == self.data then
		return 
	end
	self:UpdateApperance()
	self.node_t_list.img_lv_name.node:loadTexture(ResPath.GetExperiment("img_lbl_lv_" .. self.data.idx))
	self.node_t_list.img_award_tip.node:loadTexture(ResPath.GetExperiment("img_lbl_get_" .. self.data.idx))
	self.node_t_list.img_bg.node:loadTexture(ResPath.GetBigPainting("wk_bg_" .. self.data.idx))

	self.node_t_list.lbl_gold.node:setString(MiningActConfig.getAwardsType[2].consume[1].count)
	self._objs.award_list:SetData(MiningActConfig.Miner[self.data.idx].Awards)
end

function DigOreAward:SetData(data)
	self.data = data
end

function DigOreAward:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function DigOreAward:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.data = nil
end

function DigOreAward:OnDataChange(vo)
end




DigAwardRender = DigAwardRender or BaseClass(BaseRender)
function DigAwardRender:__init()
end

function DigAwardRender:__delete()
end

function DigAwardRender:CreateChild()
	BaseRender.CreateChild(self)
end

function DigAwardRender:CreateSelectEffect()
end

function DigAwardRender:OnFlush()
	if nil == self.data then
		return
	end
	local cfg = ItemData.Instance:GetItemConfig(self.data.id)
	RichTextUtil.ParseRichText(self.node_tree.rich_record.node, cfg.name .. "{wordcolor;1eff00;x" .. self.data.count .. "}", 20, COLOR3B.PURPLE)
end

return DigOreAward