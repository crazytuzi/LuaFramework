TemplesView = TemplesView or BaseClass(BaseView)

function TemplesView:__init()
	self.title_img_path = ResPath.GetWord("word_shenhao")
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list = {
		'res/xui/temples.png'
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
		{"temples_ui_cfg", 1, {0}},
	}
	
	-- require("scripts/game/temples/name").New(ViewDef.Temples.name)
end

function TemplesView:ReleaseCallBack()
	if self.drop_list then
		self.drop_list:DeleteMe()
		self.drop_list = nil
	end

	if self.alert_view then
		self.alert_view:DeleteMe()
		self.alert_view = nil
	end
end

function TemplesView:LoadCallBack(index, loaded_times)
	self.select_idx = 1
	self.data = TemplesData.Instance				--数据
	-- TemplesData.Instance:AddEventListener(TemplesData.INFO_CHANGE, BindTool.Bind(self.OnDataChange, self))

	self.drop_list = self:CreateItemList()

	--购买提示
	self.alert_view = Alert.New()
	self.alert_view:SetOkFunc(function () TemplesCtrl.SendTemplesReq(1)  end)
	self.alert_view:SetShowCheckBox(true)


	self.txt_buy_link = RichTextUtil.CreateLinkText(Language.CrossLand.BuyCount, 20, COLOR3B.GREEN)
	self.txt_buy_link:setPosition(self.ph_list.ph_link.x, self.ph_list.ph_link.y)
	self.node_t_list.layout_temples.node:addChild(self.txt_buy_link, 99)
	XUI.AddClickEventListener(self.txt_buy_link,  function() 
		self.alert_view:Open()
		local cfg_num = CrossHallofGodCfg.consumeYB[TemplesData.Instance:GetBuyTimes() + 1]
		self.alert_view:SetLableString(string.format(Language.CrossLand.buyDesc, cfg_num or CrossHallofGodCfg.consumeYB[TemplesData.Instance:GetBuyTimes()]))
	end, true)

	self.node_t_list.txt_explain.node:setString(CrossHallofGodCfg.explain)
	self.node_t_list.txt_level.node:setString(CrossHallofGodCfg.level)
	self.node_t_list.txt_time.node:setString(CrossHallofGodCfg.openTime)

	TemplesCtrl.SendTemplesReq(2)
	XUI.AddClickEventListener(self.node_t_list.layout_1.node,  BindTool.Bind(self.OnSelectTemple, self, 1), false)
	XUI.AddClickEventListener(self.node_t_list.layout_2.node,  BindTool.Bind(self.OnSelectTemple, self, 2), false)
	XUI.AddClickEventListener(self.node_t_list.layout_3.node,  BindTool.Bind(self.OnSelectTemple, self, 3), false)
	XUI.AddClickEventListener(self.node_t_list.layout_4.node,  BindTool.Bind(self.OnSelectTemple, self, 4), false)
	XUI.AddClickEventListener(self.node_t_list.btn_challenge.node,  BindTool.Bind(self.OnChallenge, self))
	XUI.AddClickEventListener(self.node_t_list.btn_ques3.node,  BindTool.Bind(self.OpenTips, self), true)
end


function TemplesView:OpenTips( ... )
	DescTip.Instance:SetContent(Language.DescTip.ShenHaodianContent, Language.DescTip.ShenHaodianTitle)
end

function TemplesView:CreateItemList()
	local ph = self.ph_list.ph_drop_items
	local list = ListView.New()
	list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal , BaseCell, nil, nil, self.ph_list.ph_item_cell1)
	list:SetItemsInterval(4)
	list:SetMargin(2)
	list:SetJumpDirection(ListView.Top)
	self.node_t_list.layout_temples.node:addChild(list:GetView(), 99)
	return list
end

function TemplesView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function TemplesView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function TemplesView:OnDataChange(vo)
end

function TemplesView:ShowIndexCallBack()
	self:Flush()
end

function TemplesView:OnFlush(param_list, index)
	for k, v in pairs(param_list) do

		self.node_t_list.txt_boss_info.node:setString(CrossHallofGodCfg.sceneId[self.select_idx].monsterInfo)
		self.node_t_list.txt_power.node:setString(CrossHallofGodCfg.sceneId[self.select_idx].power)
		if v.count then
			self.node_t_list.txt_count.node:setString(string.format(Language.CrossLand.LeftCount, v.count))
		end
		self.node_t_list.img_1.node:setVisible(1 == self.select_idx)
		self.node_t_list.img_2.node:setVisible(2 == self.select_idx)
		self.node_t_list.img_3.node:setVisible(3 == self.select_idx)
		self.node_t_list.img_4.node:setVisible(4 == self.select_idx)
		self.drop_list:SetDataList(CrossHallofGodCfg.dropGoodsShow[self.select_idx])
	end
end

function TemplesView:OnSelectTemple(idx)
	self.select_idx = idx
	self:Flush()
end

function TemplesView:OnChallenge()
	CrossServerCtrl.SentJoinCrossServerReq(6, self.select_idx)
end

