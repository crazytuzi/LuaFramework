local WangChengZhengBaRuleView = WangChengZhengBaRuleView or BaseClass(SubView)

function WangChengZhengBaRuleView:__init()
	self.texture_path_list[1] = 'res/xui/wangchengzhengba.png'
	self.config_tab = {
		{"wangchengzhengba_ui_cfg", 3, {0}},
	}
end

function WangChengZhengBaRuleView:__delete()
end

function WangChengZhengBaRuleView:LoadCallBack(index, loaded_times)
	self:CreateRuleContent()
end

function WangChengZhengBaRuleView:CreateRuleContent()
	-- local date_t = WangChengZhengBaData.GetNextOpenTimeDate() or {}
	-- local weekday = date_t and (date_t.weekday == 0 and 7 or date_t.weekday) or 2
	-- local txt = string.format(Language.WangChengZhengBa.Rule_Content[1], date_t.month or "01", date_t.day or "01", Language.Common.CHNWeekDays[weekday])
	-- local scroll_node = self.node_t_list.scroll_text_content.node

	-- local rich_content = XUI.CreateRichText(100, 10, 500, 0, false)
	-- rich_content:setVerticalSpace(8)
	-- scroll_node:addChild(rich_content, 100, 100)
	-- HtmlTextUtil.SetString(rich_content, txt or "")
	-- rich_content:refreshView()

	-- local scroll_size = scroll_node:getContentSize()
	-- local inner_h = math.max(rich_content:getInnerContainerSize().height + 20, scroll_size.height)
	-- scroll_node:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
	-- rich_content:setPosition(scroll_size.width / 2, inner_h - 10)

	-- -- 默认跳到顶端
	-- scroll_node:getInnerContainer():setPositionY(scroll_size.height - inner_h)

	-- 创建会长奖励
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local cfg = WangChengZhengBaData.Instance:GetShowConfig()
	local LeaderClothesId
	for k, v in pairs(cfg.LeaderPrivilege.sbkClothes.Clothes) do
		if v.sex == sex then
			LeaderClothesId = v.ClothesId
		end
	end
	local LeaderAwardFull = {}
	LeaderAwardFull[1] = ItemData.Instance:GetItemName(cfg.LeaderPrivilege.sbkTitle.Title.item_id)
	LeaderAwardFull[2] = ItemData.Instance:GetItemName(cfg.LeaderPrivilege.sbkWeapon.WeaponId)
	LeaderAwardFull[3] = ItemData.Instance:GetItemName(LeaderClothesId)

	leader_content = string.format(cfg.SbkTips.RuleTips.LeaderAward, LeaderAwardFull[1], cfg.LeaderPrivilege.sbkTitle.Title.item_id, LeaderAwardFull[2], cfg.LeaderPrivilege.sbkWeapon.WeaponId, LeaderAwardFull[3], LeaderClothesId)
	RichTextUtil.ParseRichText(self.node_t_list.rich_Leader.node, leader_content, 17, cc.c3b(0xA6, 0xA6, 0xA6))
	self.node_t_list.rich_Leader.node:setVerticalSpace(6)
end

function WangChengZhengBaRuleView:UpdateContent()
	
end

return WangChengZhengBaRuleView