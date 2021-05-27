local OpenSerVeGiftTHView = OpenSerVeGiftTHView or BaseClass(SubView)
local ItemRender = ItemRender or BaseClass(BaseRender)

local res_id_is = {
	[1] = "时装",
	[2] = "幻武",
	[3] = "特戒",
	[4] = "红装",
}

local effect_id = {
	[1] = 312,
	[2] = 313,
	[3] = 314,
	[4] = 315,
}

function OpenSerVeGiftTHView:__init()
	self.texture_path_list[1] = 'res/xui/open_serve_gift.png'
	self.config_tab = {
		{"open_serve_gift_ui_cfg", 2, {0}},
	}
	self.item_list = nil

	OpenSerVeGiftTHView.Instance = self

	self.model = OpenSerVeGiftData.Instance
end

function OpenSerVeGiftTHView:ReleaseCallBack()
	for i,v in ipairs(self.delete_list) do
		v:DeleteMe()
	end
	self.delete_list = nil
end

function OpenSerVeGiftTHView:LoadCallBack(index, loaded_times)
	self.delete_list = {}

	self.award_list = self:CreateAwardItemList()
	table.insert(self.delete_list, self.award_list)

	self:CreateWuQiDisplay()
	self:CreateRoleDisplay()
	table.insert(self.delete_list, self.wuqi_dispaly)
	table.insert(self.delete_list, self.fashion_role_display)

	self.ring_effect = RenderUnit.CreateEffect(79, self.node_t_list.layout_TH_gift.node, 300, nil, nil, 240, 180)
	self.red_fashion_effect = RenderUnit.CreateEffect(312, self.node_t_list.layout_TH_gift.node, 300, nil, nil, 240, 200)

	self.stamp_img = XUI.CreateImageView(545, 102, ResPath.GetCommon("stamp_5"))
	self.node_t_list.layout_TH_gift.node:addChild(self.stamp_img, 300)
	self.stamp_img:setVisible(false)

	self.item_list = self:CreateItemList()
	self.item_list:SelectIndex(1)
	table.insert(self.delete_list, self.item_list)

	EventProxy.New(self.model, self):AddEventListener(OpenSerVeGiftData.TeHuiGitfInfoChange, BindTool.Bind(self.Flush, self))

	XUI.AddClickEventListener(self.node_t_list.btn_buy.node, function ()
		self.model:SendTHBuyReq()
	end)

	XUI.RichTextSetCenter(self.node_t_list.rich_need_gold.node)
	XUI.RichTextSetCenter(self.node_t_list.rich_buy_num.node)
end

function OpenSerVeGiftTHView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function OpenSerVeGiftTHView:ShowIndexCallBack(index)
	self:Flush()
end

function OpenSerVeGiftTHView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function OpenSerVeGiftTHView:OnFlush(param_t, index)
	self.item_list:SetDataList(self.model:GetTeHuiGitfListByCfg())
	self.item_list:SelectIndex(self.model:GetTHNextCanBuyIdx())
end

function OpenSerVeGiftTHView:CreateAwardItemList()
	local view = {}
	for i = 1, 6 do
		local ph = self.ph_list["ph_cell_" .. i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_TH_gift.node:addChild(cell:GetView(), 103)
		view[i] = cell
	end

	function view:DeleteMe()
		for k,v in ipairs(view) do
			if v.DeleteMe then v:DeleteMe() end
		end
	end

	function view:Update()
		for i,v in ipairs(OpenSerVeGiftData.Instance:GetAwardItemList()) do
			local cell_idx = 1
			if view[i] then
				view[i]:SetData(ItemData.FormatItemData(v))
			end
		end
	end

	return view
end

function OpenSerVeGiftTHView:CreateItemList()
	local ph = self.ph_list.ph_th_gift_list
	local list = ListView.New()
	list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal , ItemRender, nil, nil, self.ph_list.ph_th_item)
	list:SetSelectCallBack(BindTool.Bind(self.OnSelectItemCallback, self))
	list:SetItemsInterval(4)
	list:SetMargin(2)
	self.node_t_list.layout_TH_gift.node:addChild(list:GetView(), 300)


	return list
end

function OpenSerVeGiftTHView:OnSelectItemCallback(item, index)
	--数据改动
	self.model:SetGiftType(index)

	--界面刷新
	self:FlushItemShow()
end

--刷新展示UI 特效 获取的物品 购买次数 消耗元宝
function OpenSerVeGiftTHView:FlushItemShow()
	self.award_list:Update()

	--获取数据
	local data = {
		need_gold = self.model:GetBuyNeedGold(),
		curr_level = self.model:GetTeHuiGiftLevel(),
		max_level = self.model:GetGiftMaxLevel(),
		gift_type = self.model:GetTeHuiGiftType(),
		check_is_all_buy = function ()
			return self.model:GetTeHuiGiftLevel() == self.model:GetGiftMaxLevel()
		end,
	}

	RichTextUtil.ParseRichText(self.node_t_list.rich_need_gold.node, "消耗元宝: " .. data.need_gold, 19)
	RichTextUtil.ParseRichText(self.node_t_list.rich_buy_num.node, string.format("已购买次数: %s/%s", data.curr_level, data.max_level), 19)

	self.node_t_list.btn_buy.node:setVisible(not data.check_is_all_buy())
	self.node_t_list.rich_need_gold.node:setVisible(not data.check_is_all_buy())
	self.node_t_list.rich_buy_num.node:setVisible(not data.check_is_all_buy())

	--是否已全部购买
	self.stamp_img:setVisible(data.check_is_all_buy())

	--奖励预览 默认取第一件
	local awar_cfg_list = OpenSerVeGiftData.Instance:GetAwardItemList()
	if data.gift_type == 1 then
		OpenSerVeGiftTHView.Instance:FreshenPrview(awar_cfg_list[1].id)		--衣服
	elseif data.gift_type == 2 then
		OpenSerVeGiftTHView.Instance:FreshenWuQiPrview(awar_cfg_list[1].id) --武器
	end

	self.fashion_role_display:SetVisible(data.gift_type == 1)
	self.wuqi_dispaly:SetVisible(data.gift_type == 2)
	self.ring_effect:setVisible(data.gift_type == 3)
	self.red_fashion_effect:setVisible(data.gift_type == 4)
end

-------------------------------------------
--展示奖励 动画
function OpenSerVeGiftTHView:CreateRoleDisplay()
	self.fashion_role_display = RoleDisplay.New(self.node_t_list.layout_TH_gift.node, 100, false, true, true, false, false, false)
	self.fashion_role_display:SetPosition(220, 250)
	self.fashion_role_display:SetScale(1)

	local mainrole = Scene.Instance:GetMainRole()
	if nil ~= mainrole then
		self.fashion_role_display:Reset(mainrole)
	end
end

function OpenSerVeGiftTHView:FreshenPrview(id)
	local cfg = ItemData.Instance:GetItemConfig(id)
	if nil == cfg then return end
	local mainrole = Scene.Instance:GetMainRole()
	if nil ~= mainrole and self.fashion_role_display then
		self.fashion_role_display:PrivewReset(mainrole, {cloth_shape = cfg.shape})
	end
end

function OpenSerVeGiftTHView:CreateWuQiDisplay()
	self.wuqi_dispaly = ModelAnimate.New(ResPath.GetWuqiBigAnimPath, self.node_t_list.layout_TH_gift.node, GameMath.DirDown)
	self.wuqi_dispaly:SetZOrder(99)
	self.wuqi_dispaly:SetScale(0.8)
	self.wuqi_dispaly:SetAnimPosition(300, 150)
end


function OpenSerVeGiftTHView:FreshenWuQiPrview(id)
	local cfg = ItemData.Instance:GetItemConfig(id)
	if nil == cfg or nil == self.wuqi_dispaly then return end
	self.wuqi_dispaly:SetPathFunc(ResPath.GetWuqiBigAnimPath)
	self.wuqi_dispaly:Show(cfg.shape)
	CommonAction.ShowJumpAction(self.wuqi_dispaly:GetAnimNode(), 10)
end

-----------------------------------
--item render 特惠礼包顶部列表
function ItemRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.img_bg.node:loadTexture(ResPath.GetOpenSevGift("open_gift_render_bg_" .. self:GetIndex()))
	self.node_tree.img_word.node:loadTexture(ResPath.GetOpenSevGift("open_gift_render_word_" .. self:GetIndex()))
end

return OpenSerVeGiftTHView