local CrossBossRewardView = BaseClass(BaseView)

function CrossBossRewardView:__init()
	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/cross_boss.png'
	}
	self.config_tab = {
		{"cross_boss_ui_cfg", 3, {0}},
	}

	-- 管理自定义对象
	self._objs = {}
end

function CrossBossRewardView:ReleaseCallBack()
	-- 清理自定对象
	for k, v in pairs(self._objs) do
		if nil == v.DeleteMe then ErrorLog("不可清理的对象 ReleaseCallBack CrossBossRewardView") end
		v:DeleteMe()
	end
	self._objs = {}
end

function CrossBossRewardView:LoadCallBack(index, loaded_times)
	XUI.EnableOutline(self.node_t_list.lbl_title.node, COLOR3B.G_Y)

	local ph = self.ph_list.ph_award_1_list
	self._objs.award1_list = ListView.New()
	self._objs.award1_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, CrossBossRewardView.AwardCell)
	self._objs.award1_list:SetItemsInterval(10)
	self._objs.award1_list:SetMargin(10)
	self.node_t_list.layout_boss_award_show_tip.node:addChild(self._objs.award1_list:GetView(), 100)

	local ph = self.ph_list.ph_award_2_list
	self._objs.award2_list = ListView.New()
	self._objs.award2_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, CrossBossRewardView.AwardCell)
	self._objs.award2_list:SetItemsInterval(10)
	self.node_t_list.layout_boss_award_show_tip.node:addChild(self._objs.award2_list:GetView(), 200)

	XUI.AddClickEventListener(self.node_t_list.btn_rob.node, function ()
		local obj = Scene.Instance:GetObjectByObjId(self.data.asc_role_id)
		if nil ~= obj and obj:IsRole() then
			Scene.Instance:GetMainRole():StopMove()
			GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
			GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, obj, "near")
		end
		self:Close()
	end)
end

function CrossBossRewardView:ShowIndexCallBack()
	self:FlushView()
end

function CrossBossRewardView:FlushView()
	if nil == self.data then return end
	if nil == CrossBossAwards[self.data.boss_id] then return end

	local data = {}
	for k,v in ipairs(CrossBossAwards[self.data.boss_id].vest) do
		local vo = ItemData.FormatItemData(v)
		vo.is_fixed = true --归属专有
		data[#data + 1] = vo
	end	
	for k,v in ipairs(CrossBossAwards[self.data.boss_id].join[1].awards) do
		local vo = ItemData.FormatItemData(v)
		vo.num = 1
		data[#data + 1] = vo
	end

	local data1 = {}
	for k,v in ipairs(CrossBossAwards[self.data.boss_id].join[1].awards) do
		local vo = ItemData.FormatItemData(v)
		vo.num = 1
		data1[k] = vo
	end

	self._objs.award1_list:SetData(data)
	self._objs.award2_list:SetData(data1)

	self.node_t_list.lbl_role_name.node:setString(self.data.role_name or "无")
	XUI.SetButtonEnabled(self.node_t_list.btn_rob.node, nil ~= self.data.asc_role_id)
	-- self.node_t_list.btn_rob.node:setTouchEnabled(nil ~= self.data.obj_id)
end

function CrossBossRewardView:SetData(data)
	self.data = data
end

function CrossBossRewardView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CrossBossRewardView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.data = nil
end


local AwardCell = BaseClass(BaseCell)
CrossBossRewardView.AwardCell = AwardCell
-- function AwardCell:__init()
	
-- end

-- function AwardCell:__delete()
-- end

-- function AwardCell:OnFlush(...)
-- 	BaseCell.OnFlush(self)
-- end

function AwardCell:CreateSelectEffect()
end

function AwardCell:OnFlush()
	BaseCell.OnFlush(self)
	if self.data.is_fixed then
		self.node_tree.self_stamp_img = XUI.CreateImageView(20, 60, ResPath.GetCommon("stamp_22"), true)
		self.node_tree.self_stamp_img:setScale(0.8)
		self.view:addChild(self.node_tree.self_stamp_img, 300)
	end
	if self.node_tree.self_stamp_img then
		self.node_tree.self_stamp_img:setVisible(self.data.is_fixed)
	end
end

return CrossBossRewardView