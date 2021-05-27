
-- 领取必杀技
BiShaRecView = BiShaRecView or BaseClass(BaseView)

function BiShaRecView:__init()
	-- self:SetModal(true)
	self.zorder = COMMON_CONSTS.ZORDER_RECEIVE_BISHA
	self.is_async_load = false
	self:SetIsAnyClickClose(false)
	self.texture_path_list = {}
	self.config_tab = {
		{"bishaji_ui_cfg", 2, {0}},
	}
	self.icon = nil
end

function BiShaRecView:__delete()
end

function BiShaRecView:ReleaseCallBack()
	CountDown.Instance:RemoveCountDown(self.delay_cd)
end

function BiShaRecView:LoadCallBack(index, loaded_times)
	self.node_t_list.btn_rec.node:setTitleText("领取")
	self.node_t_list.btn_rec.node:setTitleFontName(COMMON_CONSTS.FONT)
	self.node_t_list.btn_rec.node:setTitleFontSize(22)
	self.node_t_list.btn_rec.node:setTitleColor(COLOR3B.G_W2)
	XUI.AddClickEventListener(self.node_t_list.btn_rec.node, BindTool.Bind(self.OnClickBtn, self))

	local size =  self.node_t_list.layout_rec_bisha.node:getContentSize()
	RenderUnit.CreateEffect(355, self.node_t_list.layout_rec_bisha.node, 999, nil, nil, size.width / 2 - 2, size.height - 5)

	self.auto_equip_txt = XUI.CreateText(339, 20, 200, 20, cc.TEXT_ALIGNMENT_center, "", nil, 19, COLOR3B.RED)
	self.node_t_list.layout_rec_bisha.node:addChild(self.auto_equip_txt, 10)
end

function BiShaRecView:OpenCallBack()
end

function BiShaRecView:CloseCallBack(is_all)
	if self.icon then
		local node = ViewManager.Instance:GetUiNode("MainUi", NodeName.SpecialSkillIcon)
		local size = node:getContentSize()
		local skill_pos = node:convertToWorldSpace(cc.p(size.width / 2, size.height / 2))
		local icon = self.icon
		icon:runAction(cc.Sequence:create(cc.MoveTo:create(3, skill_pos), cc.CallFunc:create(function()
			local skill = SkillData.Instance:GetSkill(SkillData.Instance:GetMainRoleSpecSkillId())
			if nil ~= skill then
				skill.is_guideing_bisha = false
			end
			icon:removeFromParent()
			icon = nil
		end)))
	end
	self.icon = nil
end

function BiShaRecView:ShowIndexCallBack(index)
	local node = self.node_t_list.layout_rec_bisha.node
	node:stopAllActions()
	node:setOpacity(0)
	local act = cc.FadeIn:create(0.3)
	node:runAction(act)

	CountDown.Instance:RemoveCountDown(self.delay_cd)
	self.delay_cd = CountDown.Instance:AddCountDown(6, 1, BindTool.Bind(self.OnDelayCountDownUpdate, self))
	self:OnDelayCountDownUpdate(0, 5.1)
end

function BiShaRecView:OnFlush(param_t, index)
	if param_t.icon_data then
		self.icon = param_t.icon_data.icon
	end
end

function BiShaRecView:OnClickBtn()
	if nil == self.icon then
		return
	end
	
	self:CloseHelper()
end

function BiShaRecView:OnAutoRec()
	self:OnClickBtn()
end

function BiShaRecView:OnDelayCountDownUpdate(elapse_time, total_time)
	if elapse_time >= total_time then
		self:OnAutoRec()
	end
	local left_time = total_time - elapse_time
	left_time = left_time > 0 and math.floor(left_time) or 0

	self.auto_equip_txt:setString(string.format("%d秒后自动领取", left_time))
end
