FashionTitleTipView = FashionTitleTipView or BaseClass(BaseView)
function FashionTitleTipView:__init()
	-- self.title_img_path = ResPath.GetWord("word_role")
	self:SetModal(true)
	--self.can_penetrate = true											-- 点击事件是否可穿透											-- 是否模态
	self.is_any_click_close = true										
	self.texture_path_list = {
	}

	--new_fashion_ui_cfg
	self.config_tab = {
		
		{"itemtip_ui_cfg", 16, {0}},
	}

	
	self.role_title = nil
	self.title_id = nil
end

function FashionTitleTipView:__delete()
end

function FashionTitleTipView:ReleaseCallBack()
	
	if self.role_title then
		self.role_title:DeleteMe()
		self.role_title = nil
	end

	if self.fight_power_view then
		self.fight_power_view:DeleteMe()
		self.fight_power_view = nil	
	end

	
end

function FashionTitleTipView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		if nil == self.role_title then
			local ph = self.ph_list.ph_title 
			self.role_title = Title.New()
			self.role_title:GetView():setPosition(ph.x + 130, ph.y + 20)
			self.node_t_list.layout_title_show.node:addChild(self.role_title:GetView(), 100)
			self.role_title:SetScale(1)
			CommonAction.ShowJumpAction(self.role_title:GetView(), 10)
		end
		self.fight_power_view = FightPowerView.New(170, 10, self.node_t_list.layout_power.node, 11, false)
		self.fight_power_view:SetScale(1)
		--self.fight_power_view:GetView():setVisible(false)
	end
end

function FashionTitleTipView:CreateTitle()
	
	
end

function FashionTitleTipView:SetDataId(title_id)
	if title_id then
		self.title_id = title_id
		
	
		self:Flush(index)
	end
end


function FashionTitleTipView:OpenCallBack()
		
end

function FashionTitleTipView:ShowIndexCallBack(index)
	self:Flush(index)
end

function FashionTitleTipView:OnFlush(param_t, index)
	if (self.title_id) then

		if self.role_title then
			self.role_title:SetTitleId(self.title_id)
		end
		local title_attr = TitleData.Instance.GetTitleAttrCfg(self.title_id)
		local content = RoleData.FormatAttrContent(title_attr)
		--RichTextUtil.ParseRichText(self.node_t_list.rich_attr.node, content, 20)

		self.fight_power_view:SetNumber(CommonDataManager.GetAttrSetScore(title_attr))



		local cond_str = TitleData.GetCond(self.title_id)
		local act_str = cond_str and "获得条件:" .. cond_str or ""

		local normal_attrs, special_attr =  RoleData.Instance:GetSpecailAttr(title_attr)

		local text1 = string.format("{color;%s;%s}", "dcb73d", "基础属性：") .. "\n" .. RoleData.FormatAttrContent(normal_attrs).."\n"

		local text2 =  #special_attr > 0 and string.format("{image;%s}",ResPath.GetCommon("line_08")) .."\n".. string.format("{color;%s;%s}", "dcb73d", "特殊属性：") .. "\n" .. RoleData.FormatAttrContent(special_attr).."\n" or ""
		--local title_attr = TitleData.Instance.GetTitleAttrCfg(item.data.titleId)
		
		local content = text1 .. text2 .. string.format("{image;%s}",ResPath.GetCommon("line_08")).."\n" .. act_str
		RichTextUtil.ParseRichText(self.node_t_list.rich_text.node, content, 20)
		--XUI.RichTextSetCenter(self.node_t_list.rich_text.node)
		XUI.SetRichTextVerticalSpace(self.node_t_list.rich_text.node, 5)
	end
	
end



