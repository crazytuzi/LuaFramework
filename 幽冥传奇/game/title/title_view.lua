local TitleView = BaseClass(SubView)

function TitleView:__init()
	self.texture_path_list = {
		-- 'res/xui/zhuangban.png',
	}

	self.config_tab = {
		{"zhuangban_ui_cfg", 3, {0}},
	}

end

function TitleView:__delete()
end

function TitleView:ReleaseCallBack()
	if self.title_grid_list then
		self.title_grid_list:DeleteMe()
		self.title_grid_list = nil
	end

	self.fight_power_view = nil
	if self.role_data_lisntener_h and RoleData.Instance then
		RoleData.Instance:RemoveEventListener(self.role_data_lisntener_h)
	end
end

function TitleView:LoadCallBack(index, loaded_times)
	-- 人物属性改变回调
	self.role_data_lisntener_h = RoleData.Instance:AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))

	-- 创建称号列表
	self:CreateTitleList()

	-- 设置选中回调
	self.title_grid_list:SetSelectCallBack(BindTool.Bind(self.OnGridItemSelect, self))
	self:CreateLeftPanel()
end

function TitleView:ShowIndexCallBack()
	local data_list = TitleData.Instance:GetAllTitlelist()
	local new_t = {}
	for key, data in ipairs(data_list) do
		if not (TitleData.Instance:GetTitleActive(data.titleId) == 0 and (13 == data.titleId or 14 == data.titleId)) then
			table.insert(new_t, data)
		end
		data_list = new_t
	end
	
	self.title_grid_list:SetDataList(data_list)
	self.title_grid_list:SelectIndex(1)
end

function TitleView:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE then
		self:FlushTitleList()
	end
end

function TitleView:CreateLeftPanel()
	-- 创建title显示
	self.show_title = Title.New()
	self.show_title:GetView():setPosition(self.ph_list.ph_title_show.x, self.ph_list.ph_title_show.y)
	self.node_t_list.layout_chenghao.node:addChild(self.show_title:GetView(), 20)
	self.show_title:GetView():setScale(1.3)
	CommonAction.ShowJumpAction(self.show_title:GetView(), 10)
	-- 创建战斗力显示
	self.fight_power_view = FightPowerView.New(self.ph_list.ph_fight_power.x, self.ph_list.ph_fight_power.y, self.node_t_list.layout_chenghao.node, 99)
	self.fight_power_view:SetScale(0.8)
end

function TitleView:CreateTitleList()
	self.title_grid_list = ListView.New()
	local ph_grid = self.ph_list.ph_chenghao_item_list
	local grid_node = self.title_grid_list:Create(ph_grid.x, ph_grid.y, ph_grid.w, ph_grid.h, nil, TitleListRender, nil, nil, self.ph_list.ph_chenghao_item)
	self.node_t_list.layout_chenghao.node:addChild(self.title_grid_list:GetView(), 100)
	self.title_grid_list:SetMargin(2)
	self.title_grid_list:SetItemsInterval(2)
	self.title_grid_list:SetJumpDirection(ListView.Top)
end

function TitleView:FlushTitleList()
	local data_list = TitleData.Instance:GetAllTitlelist()
	local new_t = {}
	for key, data in ipairs(data_list) do
		if not (TitleData.Instance:GetTitleActive(data.titleId) == 0 and (13 == data.titleId or 14 == data.titleId)) then
			table.insert(new_t, data)
		end
		data_list = new_t
	end
	
	self.title_grid_list:SetDataList(data_list)
end

function TitleView:OnGridItemSelect(item, index)
	-- 创建属性列表
	local title_attr = TitleData.Instance.GetTitleAttrCfg(item.data.titleId)
	local content = RoleData.FormatAttrContent(title_attr)
	RichTextUtil.ParseRichText(self.node_t_list.rich_attr.node, content, 20)

	self.fight_power_view:SetNumber(CommonDataManager.GetAttrSetScore(title_attr))
	self.show_title:SetTitleId(item.data.titleId)
	-- local act_str_list = Split(item.data.desc, "%$value%$")
	-- for i, v in ipairs(act_str_list) do
	-- 	if item.data["param" .. i] and item.data["param" .. i] > 0 then
	-- 		act_str = act_str .. v .. item.data["param" .. i]
	-- 	else
	-- 		act_str = act_str .. v
	-- 	end
	-- end
	
	-- local over_times = TitleData.Instance:GetTitleOverTime(item.data.titleId)
	-- if over_times and over_times ~= - 1 then
	-- 	local secs = over_times
	-- 	if secs > 0 then
	-- 		local time_t = os.date("*t", secs)
	-- 		local time_format = string.format("{wordcolor;ff0000;%s}", Language.Tip.TimeTip)
	-- 		act_str = act_str .. "\n\n" .. Language.Role.TitleOverTime .. "\n" ..
	-- 					string.format(time_format, time_t.year, time_t.month, time_t.day, time_t.hour, time_t.min, time_t.sec)
	-- 	end
	-- end
	
	-- 获得条件
	local cond_str = TitleData.GetCond(item.data.titleId)
	local act_str = cond_str and "获得条件:" .. cond_str or ""

	RichTextUtil.ParseRichText(self.node_t_list.rich_acquire_condition.node, act_str, 20, COLOR3B.GOLD)
	XUI.RichTextSetCenter(self.node_t_list.rich_acquire_condition.node)
end

-- 称号ItemRender
TitleListRender = TitleListRender or BaseClass(BaseRender)
function TitleListRender:__init()
	
end

function TitleListRender:__delete()
	if self.title then
		self.title:DeleteMe()
		self.title = nil
	end
end

function TitleListRender:CreateChild()
	BaseRender.CreateChild(self)
end

function TitleListRender:OnFlush()

	-- 创建Title
	if nil == self.title then
		local size = self.view:getContentSize()
		self.title = Title.New()
		self.title:GetView():setPosition(size.width / 4, size.height / 2)
		self.view:addChild(self.title:GetView(), 100)
		self.title:SetScale(0.8)
	end
	self.title:SetTitleId(self.data.titleId)

	-- 按钮
	local head_title = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE)
	local title_1 = bit:_and(head_title, 0x000000ff)
	local title_2 = bit:_rshift(bit:_and(head_title, 0x0000ff00), 8)
	-- local item = BagData.Instance:GetItem(item_id)
	local item = BagData.Instance:GetItem(TITLE_CLIENT_CONFIG[self.data.titleId].item_id)
	XUI.AddClickEventListener(self.node_tree.btn_peidai.node, BindTool.Bind(self.OnClickTitleBtn, self))
	self.node_tree.btn_peidai.node:setVisible(TitleData.Instance:GetTitleActive(self.data.titleId) == 1 or nil ~= item)
	self.node_tree.btn_peidai.node:setTitleText(((self.data.titleId == title_1 or self.data.titleId == title_2) and "脱  下") or (TitleData.Instance:GetTitleActive(self.data.titleId) == 1 and "佩  戴") or (nil ~= item and "激  活") or "")
	self.node_tree.btn_peidai.node:setTitleFontName(COMMON_CONSTS.FONT)
	self.node_tree.btn_peidai.node:setTitleFontSize(22)
	self.node_tree.btn_peidai.node:setTitleColor(COLOR3B.G_W2)
	self.title:MakeGray(TitleData.Instance:GetTitleActive(self.data.titleId) == 0)

	--有效期显示
	local is_validity = TitleData.Instance.GetTitleValidity(self.data.titleId)
	local validity_text = (is_validity == 1 and "永久" or "临时")
	local content = string.format("{wordcolor;%s;有效期:}", COLORSTR.GOLD)
	RichTextUtil.ParseRichText(self.node_tree.rich_youxiaoqi.node, content, 18)
	XUI.RichTextAddText(self.node_tree.rich_youxiaoqi.node, validity_text, nil, is_validity == 1 and 18 or 22, is_validity == 1 and COLOR3B.GOLD or COLOR3B.G_W2)

	self.node_tree.lbl_weihuode.node:setString((TitleData.Instance:GetTitleActive(self.data.titleId) == 0 and nil == item) and "未获得" or "")
	self.node_tree.lbl_weihuode.node:setColor(COLOR3B.G_W)
end

function TitleListRender:OnClickPeiDai()
end

 -- 点击按钮
function TitleListRender:OnClickTitleBtn()
	-- 持宝人称号不能取消佩戴
	if StdActivityCfg[DAILY_ACTIVITY_TYPE.DUO_BAO_QI_BING].titleId == self.data.titleId then return end
	-- if TitleData.Instance:GetTitleActive(self.data.titleId) == 0 then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Role.NoActTitle)
	-- 	return
	-- end
	local item = BagData.Instance:GetItem(TITLE_CLIENT_CONFIG[self.data.titleId].item_id)
	if TitleData.Instance:GetTitleActive(self.data.titleId) == 0 and nil ~= item then
		BagCtrl.Instance:SendUseItem(item.series, 0, 1)
	else
		local head_title = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE)
		local title_1 = bit:_and(head_title, 0x000000ff)
		local title_2 = bit:_rshift(bit:_and(head_title, 0x0000ff00), 8)
		if self.data.titleId == title_1 or self.data.titleId == title_2 then
			if title_1 == self.data.titleId then
				title_1 = 0
			elseif title_2 == self.data.titleId then
				title_2 = 0
			else
				return
			end
		else
			if title_1 == 0 then
				title_1 = self.data.titleId
			else
				title_2 = self.data.titleId
			end
		end
		TitleCtrl.SendTitleReq(title_1, title_2)
	end
end

-- 创建选中特效
function TitleListRender:CreateSelectEffect()
	local size =self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_109"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end

return TitleView