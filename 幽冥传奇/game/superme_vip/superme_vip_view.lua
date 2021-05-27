SuperMeView = SuperMeView or BaseClass(XuiBaseView)
function SuperMeView:__init()
	self:SetModal(true)
	self.texture_path_list = {"res/xui/vip.png", "res/xui/invest_plan.png"}
	self.config_tab = {
			{"common_ui_cfg", 5, {0}},
			{"common_ui_cfg", 1, {0}},
			{"common_ui_cfg", 2, {0}},
			{"vip_ui_cfg", 2, {0}},
		}
	self.title_img_path = ResPath.GetVipResPath("title_super_me")
end

function SuperMeView:__delete()

end	

function SuperMeView:ReleaseCallBack()
	if self.play_effect ~= nil then
		self.play_effect:setStop()
		self.play_effect = nil 
	end
end

function SuperMeView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		XUI.AddClickEventListener(self.node_t_list.btn_superme.node, BindTool.Bind(self.OnPrayBindGoldClicked, self), true)
		for i=1,3 do
			XUI.AddClickEventListener(self.node_t_list["img_"..i].node, BindTool.Bind(self.OnBindGoldCTab, self,i), true)
		end
		self:OnBindGoldCTab(1)
		RichTextUtil.ParseRichText(self.node_t_list.txt_rich.node, Language.SuperMe.TxtRich, 24)
		-- XUI.SetRichTextVerticalSpace(self.node_t_list.txt_rich.node, 2)
	end
end

function SuperMeView:OnClose()
	self:Close()
end

function SuperMeView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self:OnBindGoldCTab(1)
end

function SuperMeView:OnPrayBindGoldClicked()
	if PrivilegeData.Instance:GetPrilivegeFirst()>=1 then
		SuperMeVipCtrl.Instance:OpenSuperMeReq()
	else
		ViewManager.Instance:Open(ViewName.ChargePlatForm)
	end
end

function SuperMeView:OnBindGoldCTab(type)
	if type ~= 1 then
		if type == 2 then
			ViewManager.Instance:Open(ViewName.Privilege)
		elseif type == 3 then
			ViewManager.Instance:Open(ViewName.Vip)
		end
		self:Close()
	end
end

function SuperMeView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function SuperMeView:ShowIndexCallBack(index)
	self:Flush(index)
end

function SuperMeView:OnFlush(param_list, index)
	local open_days =  OtherData.Instance:GetRoleCreatDay()
	
	self.node_t_list.level1.node:setVisible(open_days <= 2)
	self.node_t_list.img_level.node:setVisible(open_days > 2)
	self.node_t_list.txt_num1.node:setVisible(open_days<=2)
	local my_money = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_DRAW_GOLD_COUNT)
	self.node_t_list.txt_num1.node:setString(string.format(Language.SuperMe.chargeInfo, math.floor(my_money/500)))
	for i=1,2 do
		self.node_t_list["remind_flag"..i].node:setVisible(PrivilegeData.Instance:GetPrilivegeFirst()>=1)
	end

	self.node_t_list.btn_superme.node:setTitleText(Language.SuperMe.Txts1)
	
	for k,v in pairs(param_list) do
		if k == "recycle_success" then
			local ph = self.ph_list.ph_img_1
			self:SetShowPlayEff(72,ph.x,ph.y)
			XUI.SetLayoutImgsGrey(self.node_t_list.btn_superme.node, RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SUPER_VIP) >0 , true)
			if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SUPER_VIP) >0 then
				self.node_t_list.btn_superme.node:setTitleText(Language.Role.HadActive)
			end
		end
	end
end

function SuperMeView:SetShowPlayEff(effct_id, x, y)
	if self.play_effect == nil then
		self.play_effect = AnimateSprite:create()
		self.node_t_list.layout_superme.node:addChild(self.play_effect,999)
	end	
	self.play_effect:setPosition(x, y)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effct_id)
	self.play_effect:setAnimate(anim_path, anim_name, 1, 0.15, false)
end
