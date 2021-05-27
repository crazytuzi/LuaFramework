FuBenShiMuSaoZhuView = FuBenShiMuSaoZhuView or BaseClass(XuiBaseView)

function FuBenShiMuSaoZhuView:__init()
	self.texture_path_list[1] = 'res/xui/fuben.png'
	self.config_tab = {
		{"fuben_view_ui_cfg", 1, {0}},
	}
	self:SetModal(false)
	self.can_penetrate = true
	--self.arrow_root = nil
	self.item_data_change_back = BindTool.Bind1(self.ItemDataChangeCallback,self)
end

function FuBenShiMuSaoZhuView:__delete()
end

function FuBenShiMuSaoZhuView:ReleaseCallBack()

	if self.number_rade_1 then
		self.number_rade_1:DeleteMe()
		self.number_rade_1 = nil
	end	

	if self.number_rade_2 then
		self.number_rade_2:DeleteMe()
		self.number_rade_2 = nil
	end	

	if self.toggle_guaji then
		GlobalEventSystem:UnBind(self.toggle_guaji)
		self.toggle_guaji = nil 
	end

	self.effec = nil 
	self.effec_1 = nil 
	self.effec_2 = nil 

	ClientCommonButtonDic[CommonButtonType.SMSZ_FLUSH_MONSTER_BTN] = nil
	ClientCommonButtonDic[CommonButtonType.SMSZ_BUILD_TD_BTN] = nil
	ClientCommonButtonDic[CommonButtonType.SMSZ_BUY_JIANHUANG_BTN] = nil
end

function FuBenShiMuSaoZhuView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		XUI.SetButtonEnabled(self.node_t_list.layout_funben_1.layout_eara.btn_flush_monster.node, true)
		self.number_rade_1 = self:CreateNumBar(110, 150, 30, 29)
		self.node_t_list.layout_funben_1.layout_eara.layout_buy_1.node:addChild(self.number_rade_1:GetView(),999)
		self.number_rade_2 = self:CreateNumBar(110, 150, 30, 29)
		self.node_t_list.layout_funben_1.layout_eara.layout_buy_2.node:addChild(self.number_rade_2:GetView(),999)
		self.node_t_list.layout_funben_1.layout_eara.layout_buy_1.btn_buy_1.node:addClickEventListener(BindTool.Bind(self.AddBuyTime1, self))
		self.node_t_list.layout_funben_1.layout_eara.layout_buy_2.btn_buy_2.node:addClickEventListener(BindTool.Bind(self.AddBuyTime2, self))
		self.node_t_list.layout_funben_1.layout_eara.btn_flush_monster.node:addClickEventListener(BindTool.Bind(self.FlushMonster, self))
		self.node_t_list.layout_funben_1.layout_eara.btn_key_palce.node:addClickEventListener(BindTool.Bind(self.Keyplacement, self))
		XUI.AddClickEventListener(self.node_t_list.layout_funben_1.layout_eara.layout_buy_1.img_bg_1.node, BindTool.Bind2(self.BuyTime1, self))
		XUI.AddClickEventListener(self.node_t_list.layout_funben_1.layout_eara.layout_buy_2.img_bg_2.node, BindTool.Bind2(self.BuyTime2, self))
		self.effec = RenderUnit.CreateEffect(10, self.node_t_list.layout_funben_1.layout_eara.layout_buy_1.btn_buy_1.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
		self.effec:setScaleX(0.55)
		self.effec:setScaleY(0.9)
		self.effec_1 = RenderUnit.CreateEffect(10, self.node_t_list.layout_funben_1.layout_eara.layout_buy_2.btn_buy_2.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
		self.effec_1:setScaleX(0.55)
		self.effec_1:setScaleY(0.9)
		self.effec_2 = RenderUnit.CreateEffect(8, self.node_t_list.layout_funben_1.layout_eara.btn_key_palce.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
		
		self.toggle_guaji = GlobalEventSystem:Bind(OtherEventType.GUAJI_TYPE_CHANGE, BindTool.Bind(self.OnGuajiTypeChange, self))
		local size = self.node_t_list.layout_funben_1.layout_eara.node:getContentSize()
		self.img_fight = XUI.CreateImageView(size.width,  size.height/2, ResPath.GetSkillIcon("auto_fight"), true)
		self.img_fight:setAnchorPoint(1, 0.5)
		self.node_t_list.layout_funben_1.layout_eara.node:addChild(self.img_fight, 999)
		XUI.AddClickEventListener(self.img_fight, BindTool.Bind(self.OnClickAutoFight, self))
		self.node_t_list.layout_funben_1.layout_eara.node:setAnchorPoint(1, 0)

		local pos = self.node_t_list.layout_funben_1.node:convertToNodeSpace(cc.p(HandleRenderUnit:GetWidth(),0))
		self.node_t_list.layout_funben_1.layout_eara.node:setPosition(pos.x-40, 10)

		ClientCommonButtonDic[CommonButtonType.SMSZ_FLUSH_MONSTER_BTN] = self.node_t_list.layout_funben_1.layout_eara.btn_flush_monster.node
		ClientCommonButtonDic[CommonButtonType.SMSZ_BUILD_TD_BTN] = self.node_t_list.layout_funben_1.layout_eara.btn_key_palce.node
		ClientCommonButtonDic[CommonButtonType.SMSZ_BUY_JIANHUANG_BTN] = self.node_t_list.layout_funben_1.layout_eara.layout_buy_2.btn_buy_2
	end
end

-- function FuBenShiMuSaoZhuView:FlushArrow(btn)
-- 	if nil == self.arrow_root then
-- 		self.arrow_root = cc.Node:create()
-- 		self.node_t_list.layout_funben_1.node:addChild(self.arrow_root, 200)
-- 		self.arrow_node = cc.Node:create()
-- 		self.arrow_root:addChild(self.arrow_node)
-- 		self.arrow_frame = XButton:create(ResPath.GetGuide("arrow_frame"), ResPath.GetGuide("arrow_frame"), "")
-- 		self.arrow_frame:setTitleFontSize(25)
-- 		self.arrow_frame:setTouchEnabled(false)
-- 		self.arrow_frame:setTitleText(Language.Task.GuideTextFangzhi)
-- 		self.arrow_node:addChild(self.arrow_frame)
-- 		self.arrow_frame:setTitleFontName(COMMON_CONSTS.FONT)
-- 		local label = self.arrow_frame:getTitleLabel()
-- 		if label then
-- 			label:setColor(COLOR3B.G_Y)
-- 			label:enableOutline(cc.c4b(0, 0, 0, 100), 1.5)
-- 		end
-- 		self.arrow_point = XUI.CreateImageView(0, 0, ResPath.GetGuide("arrow_point"))
-- 		self.arrow_point:setAnchorPoint(0.5, 0.5)
-- 		self.arrow_node:addChild(self.arrow_point)
-- 	else
-- 		self.arrow_root:setVisible(true)
-- 	end

-- 	self.arrow_point:setRotation(-90)
-- 	self.arrow_frame:setAnchorPoint(0.5, 0)
-- 	self.arrow_frame:setPosition(0, 8)
-- 	local move1 = cc.MoveTo:create(0.5, cc.p(0, 10))
-- 	local move2 = cc.MoveTo:create(0.5, cc.p(0, 0))
-- 	local action = cc.RepeatForever:create(cc.Sequence:create(move1, move2))
-- 	self.arrow_node:stopAllActions()
-- 	self.arrow_node:runAction(action)

-- 	local x, y = btn:getPosition(200,0)
-- 	local size = btn:getContentSize()
-- 	self.arrow_root:setPosition(x + size.height * 15 + 40, y + size.height * 4 - 20)
-- end	

function FuBenShiMuSaoZhuView:OpenCallBack()
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_change_back)
end

function FuBenShiMuSaoZhuView:CloseCallBack()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_change_back)
end

function FuBenShiMuSaoZhuView:ItemDataChangeCallback()
	self:Flush()
end

function FuBenShiMuSaoZhuView:ShowIndexCallBack(index)
	XUI.SetButtonEnabled(self.node_t_list.layout_funben_1.layout_eara.btn_flush_monster.node, true)
	self:Flush()
end

function FuBenShiMuSaoZhuView:OnFlush(param_t, index)
	local num_1, num_2 = FubenData.Instance:GetRemainItem()
	local rest_can_setup_num = FubenData.Instance:GetRestSetupItemNum()
	self.number_rade_1:SetNumber(num_1)
	self.number_rade_2:SetNumber(num_2)
	if self.effec and self.effec_1 then
		self.effec:setVisible((num_1 + num_2) < rest_can_setup_num and rest_can_setup_num > 0)
		self.effec_1:setVisible((num_1 + num_2) < rest_can_setup_num and rest_can_setup_num > 0)
	end
	if self.effec_2 then
		self.effec_2:setVisible((num_1 > 0 or num_2 > 0))
	end

	local consume_data = FubenData.Instance:GetConsume()
	local num = consume_data[1].consume/10000
	local txt_1 = string.format(Language.Fuben.Buy_Money, num)
	local txt_2 = string.format(Language.Fuben.Buy_Bind_Gold,consume_data[2].consume)
	self.node_t_list.layout_funben_1.layout_eara.layout_buy_1.btn_buy_1.node:setTitleText(txt_1)
	self.node_t_list.layout_funben_1.layout_eara.layout_buy_2.btn_buy_2.node:setTitleText(txt_2)
	local id_1 = consume_data[1].monster_id
	local id_2 = consume_data[2].monster_id
	local cfg_1 = ConfigManager.Instance:GetMonsterConfig(id_1)
	local cfg_2 = ConfigManager.Instance:GetMonsterConfig(id_2)
	self.node_t_list.layout_funben_1.layout_eara.layout_buy_1.txt_name_1.node:setString(cfg_1.name)
	self.node_t_list.layout_funben_1.layout_eara.layout_buy_2.txt_name_2.node:setString(cfg_2.name)

end

function FuBenShiMuSaoZhuView:CreateNumBar(x, y, w, h)
	local number_bar = NumberBar.New()
	number_bar:SetRootPath(ResPath.GetMainuiRoot() .. "num_")
	number_bar:SetPosition(x, y)
	number_bar:SetContentSize(w, h)
	number_bar:SetSpace(-2)
	return number_bar
end

function FuBenShiMuSaoZhuView:AddBuyTime1()
	FubenCtrl.AddBuyTimes(1)
end

function FuBenShiMuSaoZhuView:AddBuyTime2()
	FubenCtrl.AddBuyTimes(2)
end

function FuBenShiMuSaoZhuView:FlushMonster()
	FubenCtrl.FlushMonster()
	XUI.SetButtonEnabled(self.node_t_list.layout_funben_1.layout_eara.btn_flush_monster.node, false)
end

function FuBenShiMuSaoZhuView:BuyTime1() 
	--self.arrow_root:setVisible(false)
	FubenCtrl.BuyItem(1)
end

function FuBenShiMuSaoZhuView:BuyTime2() 
	FubenCtrl.BuyItem(2)
end

function FuBenShiMuSaoZhuView:OnClickAutoFight()
	local mainRole = Scene.Instance:GetMainRole()
	if mainRole:GetIsAutoFight() then
		mainRole:SetIsAutoFight(false)
	else
		mainRole:CalNearAutoPoint()
		mainRole:SetIsAutoFight(true)
	end	
end

function FuBenShiMuSaoZhuView:OnGuajiTypeChange(guaji_type)
	local mainRole = Scene.Instance:GetMainRole()
	if mainRole:GetIsAutoFight() then
		self.img_fight:loadTexture(ResPath.GetSkillIcon("auto_fight_cancel"))
	else
		self.img_fight:loadTexture(ResPath.GetSkillIcon("auto_fight"))
	end	
end

function FuBenShiMuSaoZhuView:Keyplacement()
	--self.arrow_root:setVisible(false)
	FubenCtrl.KeyPlacement()
end