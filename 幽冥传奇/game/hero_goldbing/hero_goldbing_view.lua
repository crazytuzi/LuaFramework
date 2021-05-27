HeroGoldBingView = HeroGoldBingView or BaseClass(XuiBaseView)

function HeroGoldBingView:__init()
	self.config_tab = {
		-- {"common_ui_cfg", 1, {0}},
		{"hero_gold_ui_cfg", 2, {0}},
		-- {"common_ui_cfg", 2, {0}},
	}
	self.texture_path_list = {"res/xui/hero_gold.png","res/xui/charge.png"}
	self.title_img_path = ResPath.GetHeroGold("hero_gold_bing_title")
	self:SetModal(true)
end

function HeroGoldBingView:__delete()
end

function HeroGoldBingView:ReleaseCallBack()
	if self.soul_cell  then
		for k,v in ipairs(self.soul_cell) do
			v:DeleteMe()
		end
		self.soul_cell = nil
	end
	self.effec_1 = nil
	if self.achieve_evt then
		GlobalEventSystem:UnBind(self.achieve_evt)
		self.achieve_evt = nil
	end
	if self.play_effect ~= nil then 
		self.play_effect:setStop()
		self.play_effect = nil 
	end
end

function HeroGoldBingView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		XUI.AddClickEventListener(self.node_t_list.btn_close.node, BindTool.Bind(self.ReciveView, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_clo.node, BindTool.Bind(self.CloseView, self), true) 
		local cfg = HeroGoldBingData.Instance:GetEquipBossCfg()
		if not self.soul_cell then
			self.soul_cell = {}
			local ph = self.ph_list["ph_bing_cell"]
			for i,v in ipairs(cfg) do
				local cell = BaseCell.New()
				cell:SetPosition(ph.x+(i-1)*90, ph.y)
				cell:GetView():setAnchorPoint(0, 0)
				self.act_eff = RenderUnit.CreateEffect(7, self.node_t_list.layot_gold_bing.node, 201, nil, nil,  ph.x+(i-1)*90+43,  ph.y + 40)
				self.node_t_list.layot_gold_bing.node:addChild(cell:GetView(), 103)
				table.insert(self.soul_cell, cell)
				if v.type >0 then
					local virtual_item_id = ItemData.Instance:GetVirtualItemId(v.type)
					cell:SetData({item_id = virtual_item_id, num = v.count, is_bind = 0,strengthen_level= v.strong})
				else
					cell:SetData({item_id = v.id, num = v.count, is_bind = 0,strengthen_level= v.strong})
				end
			end
		end
		if not self.effec_1 then
			local ph = self.ph_list["current_weapen"]
			self.effec_1 = AnimateSprite:create()
			self.effec_1:setRotation(270)
			self.node_t_list.layot_gold_bing.node:addChild(self.effec_1,99)
			self.effec_1:setPosition(ph.x+115,ph.y+60)
			local path, name = ResPath.GetEffectAnimPath(401)
			self.effec_1:setAnimate(path, name, loop or COMMON_CONSTS.MAX_LOOPS, 0.17, false)
		end
		self.achieve_evt = GlobalEventSystem:Bind(HeroGoldEvent.HeroGoldBing, BindTool.Bind(self.UpdateData, self))
		self:UpdateData()
		self:CreatePlayEffct()
	end
end

function HeroGoldBingView:CreatePlayEffct()
	if self.play_effect == nil then
		self.play_effect = AnimateSprite:create()
		self.node_t_list.layot_gold_bing.node:addChild(self.play_effect, 998)
		self.play_effect:setPosition(136,210)
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(989)
		self.play_effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	end
 end

function HeroGoldBingView:ReciveView()
	local num,award = HeroGoldBingData.Instance:getChargeInfo()
	if num >=HeroGodWeaponRechargeConfig.yb and award ==0 then
		HeroGoldBingCtrl.Instance:ReqMoneyReq(1)
	else
		ViewManager.Instance:Open(ViewName.ChargePlatForm)
	end
end

function HeroGoldBingView:CloseView()
	self:Close()
end

function HeroGoldBingView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	HeroGoldBingCtrl.Instance:ReqMoneyReq(0)
end

function HeroGoldBingView:ShowIndexCallBack(index)
	self:Flush(index)
end

function HeroGoldBingView:UpdateData()
	local num,award = HeroGoldBingData.Instance:getChargeInfo()
	local activat = 0
	if num >=HeroGodWeaponRechargeConfig.yb and award ==0 then
		activat =1
	end
	if award <= 0 then
		self.node_t_list.btn_close.node:setTitleText(Language.HeroGold.LingQu)
	else
		self.node_t_list.btn_close.node:setTitleText(Language.Common.YiLingQu)
	end
	XUI.SetLayoutImgsGrey(self.node_t_list.btn_close.node,award>0, true)
end

function HeroGoldBingView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function HeroGoldBingView:OnFlush(param_t, index)

end
