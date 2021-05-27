
TitleTipsView = TitleTipsView or BaseClass(XuiBaseView)
function TitleTipsView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)
	
	self.def_index = 1
	
	self.config_tab = {
		{"role_ui_cfg", 10, {0}},
	}
end

function TitleTipsView:__delete()
end

function TitleTipsView:ReleaseCallBack()
	
end

function TitleTipsView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		-- self:CreateTopTitle(Language.WaBao.WabaoName, nil, content_size.height - 53)
		self.title = Title.New()
		local size = self.node_t_list.layout_title_tips.node:getContentSize()
		self.title:GetView():setPosition(cc.p(size.width / 2, size.height - 90))
		self.node_t_list.layout_title_tips.node:addChild(self.title:GetView(), 100)
		self.node_t_list.rich_title_attr.node:setVerticalSpace(10)

		self.node_t_list.layout_tips_top.node:setAnchorPoint(0, 1)
		self.node_t_list.layout_tips_down.node:setAnchorPoint(0, 1)
	end
end

function TitleTipsView:SetDataOpen(data)
	self.data = data
	self:Open()
end

function TitleTipsView:ShowIndexCallBack(index)
	self:Flush(index)
end

function TitleTipsView:OpenCallBack()
end

function TitleTipsView:CloseCallBack()
end


function TitleTipsView:OnFlush(param_t, index)
	self.title:SetTitleId(self.data.titleId)
	self.node_t_list.lbl_view_name.node:setString(Language.Role.TitleTipsName[self.data.titleType])
	local attr_str = RoleData.FormatAttrContent(self.data.staitcAttrs, {prof_ignore = - 1})
	RichTextUtil.ParseRichText(self.node_t_list.rich_title_attr.node, attr_str)
	local change_data = TitleData.Instance:GetTitleParam(self.data.paramType)
	local act_str = ""
	local act_str_list = Split(self.data.desc, "%$value%$")
	for i, v in ipairs(act_str_list) do
		if self.data["param" .. i] and self.data["param" .. i] > 0 then
			-- if i == 1 and self.data["param" .. 2] and self.data["param" .. 2] > 0 
			-- 	or self.data.titleId == 5 
			-- 	or self.data.titleId == 13
			-- 	or self.data.titleId == 6 then
			act_str = act_str .. v .. self.data["param" .. i]
			-- else
-- 	local show_count = math.min(change_data, self.data["param" .. i])
-- 	act_str = act_str .. v .. show_count .. "/" ..self.data["param" .. i]
-- end
		else
			act_str = act_str .. v
		end
	end
	
	local over_times = TitleData.Instance:GetTitleOverTime(self.data.titleId)
	if over_times and over_times ~= - 1 then
		local secs = over_times
		if secs > 0 then
			local time_t = os.date("*t", secs)
			local time_format = string.format("{wordcolor;ff0000;%s}", Language.Tip.TimeTip)
			act_str = act_str .. "\n\n" .. Language.Role.TitleOverTime .. "\n" ..
						string.format(time_format, time_t.year, time_t.month, time_t.day, time_t.hour, time_t.min, time_t.sec)
		end
	end
	
	RichTextUtil.ParseRichText(self.node_t_list.rich_title_active.node, act_str)
	self:UpdateHeight()
end

function TitleTipsView:UpdateHeight()
	self.node_t_list.rich_title_attr.node:refreshView()
	local attr_h = self.node_t_list.rich_title_attr.node:getInnerContainerSize().height
	self.node_t_list.rich_title_active.node:refreshView()
	local active_h = self.node_t_list.rich_title_active.node:getInnerContainerSize().height
	self.title:GetView():setPositionY(active_h + attr_h + 380 - 90)
	local all_h = 280 + active_h + attr_h
	self.node_t_list.img9_bg.node:setContentWH(376, all_h)
	self.node_t_list.img9_bg.node:setPositionY(all_h / 2)

	self.node_t_list.layout_tips_top.node:setPosition(5, all_h - 5)
	self.node_t_list.layout_tips_down.node:setPosition(12, all_h - attr_h - 180)
	self.title:GetView():setPositionY(all_h - 90)
	self.root_node:setContentWH(self.root_node:getContentSize().width, all_h)
end
