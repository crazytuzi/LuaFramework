CityPoolFightView = CityPoolFightView or BaseClass(XuiBaseView)

function CityPoolFightView:__init()
	self.def_index = 1
 	self.texture_path_list[1] = 'res/xui/city_pool_fight.png'
 	self.is_modal = true
 	self.is_async_load = false	
	self.config_tab = { --类dom模式,数组顺序决定渲染顺序
		{"city_pool_fight_ui_cfg", 1, {0}},
	}	
	self.title_img_path = ResPath.GetCityPoolFight("txt_word_3")
end

function CityPoolFightView:__delete()
	
end

function CityPoolFightView:ReleaseCallBack()
	if self.atk_guild_name_list then
		self.atk_guild_name_list:DeleteMe()
		self.atk_guild_name_list = nil
	end

	for k, v in pairs(self.award_cell_t) do
		v:DeleteMe()
		v = nil
	end

end

function CityPoolFightView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateGongchengListView()
		XUI.AddClickEventListener(self.node_t_list.btn_close.node, BindTool.Bind1(self.OnCloseHandler, self))
		XUI.AddClickEventListener(self.node_t_list.baoming_btn.node, BindTool.Bind(self.OnBaoMing, self))
		self.scroll_node = self.node_t_list.scroll_base_rules.node

		self.rich_content = XUI.CreateRichText(100, 4, 450, 0, false)
		self.scroll_node:addChild(self.rich_content, 100, 100)
	end

end

function CityPoolFightView:OpenCallBack()
	self:FlushRuleInfo()
	CityPoolFightCtrl.CityPoolFightGuildListReq()
end

function CityPoolFightView:CloseCallBack()

end

function CityPoolFightView:OnFlush(param_t, index)
	for k, v in pairs(param_t) do
		if k == "guild_name_list" then
			self:FlushGuildNameInfo()
		end
	end
	
end

function CityPoolFightView:ShowIndexCallBack(index)
	self:Flush(index)
end

function CityPoolFightView:CreateGongchengListView()
	if self.atk_guild_name_list == nil then
		local ph = self.ph_list.ph_gongcheng_name_list
		self.atk_guild_name_list = ListView.New()
		self.atk_guild_name_list:Create(ph.x, ph.y, ph.w, ph.h, nil, CityPoolFightGuildNameRender, nil, nil, self.ph_list.ph_gongcheng_name_item)
		self.node_t_list.layout_city_pool_fight_info.node:addChild(self.atk_guild_name_list:GetView(), 100)
		self.atk_guild_name_list:SetItemsInterval(5)
		self.atk_guild_name_list:SetJumpDirection(ListView.Top)
	end	
	self.award_cell_t = {}
	local show_awards = CityPoolFightData.GetShowAwards()
	for i = 1, 2 do
		local data = show_awards[i]
		local ph = self.ph_list["ph_conq_cell_" .. i]
		local award_cell = BaseCell.New()
		award_cell:SetPosition(ph.x, ph.y)
		self.node_t_list.layout_city_pool_fight_info.node:addChild(award_cell:GetView(), 90)
		self.award_cell_t[i] = award_cell
		award_cell:SetData(data)
	end
end	

function CityPoolFightView:FlushRuleInfo()
	local date_t = CityPoolFightData.GetNextOpenTimeDate() or {}
	local weekday = date_t and (date_t.weekday == 0 and 7 or date_t.weekday) or 3
	local content = string.format(Language.WangChengZhengBa.Rule_Content_2[1], date_t.month or "01", date_t.day or "01", Language.Common.CHNWeekDays[weekday])
	HtmlTextUtil.SetString(self.rich_content, content or "")
	self.rich_content:refreshView()

	local scroll_size = self.scroll_node:getContentSize()
	local inner_h = math.max(self.rich_content:getInnerContainerSize().height + 8, scroll_size.height)
	self.scroll_node:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
	self.rich_content:setPosition(scroll_size.width / 2, inner_h - 4)

	-- 默认跳到顶端
	self.scroll_node:getInnerContainer():setPositionY(scroll_size.height - inner_h)

	local date_str = CityPoolFightData.GetNextOpenTimeDateStr()
	self.node_t_list.lbl_atk_city_time.node:setString(date_str)
end

function CityPoolFightView:FlushGuildNameInfo()
	local data_list = CityPoolFightData.Instance:GetAtkGuildNameStrList()
	self.atk_guild_name_list:SetDataList(data_list)
	self.node_t_list.lbl_def_side.node:setString(CityPoolFightData.Instance:GetDefenceGuildName())
end

function CityPoolFightView:OnBaoMing()
	local guild_id = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GUILD_ID)
	if guild_id <= 0 then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.WangChengZhengBa.NotCanBaoMing)
		return
	end
	CityPoolFightCtrl.ApplyCityPoolFight()
	AudioManager.Instance:PlayClickBtnSoundEffect()
end	


function CityPoolFightView:OnCloseHandler()
	self:Close()
end


CityPoolFightGuildNameRender = CityPoolFightGuildNameRender or BaseClass(BaseRender)
function CityPoolFightGuildNameRender:__init()
	
end

function CityPoolFightGuildNameRender:__delete()
	
end

function CityPoolFightGuildNameRender:OnFlush()
	if self.data == nil then return end
	RichTextUtil.ParseRichText(self.node_tree.lbl_gongcheng_name_text.node, self.data.name, 22, COLOR3B.G_W2)	
end

-- 创建选中特效
function CityPoolFightGuildNameRender:CreateSelectEffect()

end