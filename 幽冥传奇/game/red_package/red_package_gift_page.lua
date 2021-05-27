RedPaperGiftPage = RedPaperGiftPage or BaseClass(XuiBaseView)

function RedPaperGiftPage:__init()
	self.can_penetrate = false
	self.is_any_click_close = true
	self.config_tab = {
						{"red_package_ui_cfg", 3, {0}}
					}

end

function RedPaperGiftPage:__delete()
	
end

function RedPaperGiftPage:ReleaseCallBack()
	
end

function RedPaperGiftPage:LoadCallBack(index, loaded_time)
	if loaded_time <= 1 then
		self:CreateTitle()
		local title_id = NationwideRedPacketsConfig.RankAwards[1].awardTitleId
		self.title:SetTitleId(title_id)
		XUI.AddClickEventListener(self.node_t_list.btn_close.node, BindTool.Bind1(self.OnClose, self), true)
		local cfg = TitleData.GetHeadTitleConfig(title_id)
		self.node_t_list.txt_name.node:setString(cfg.titleName)
		local staitcAttrs = TitleData.Instance:GetSelectTitleAttr(title_id)
		local title_attrs = RoleData.FormatRoleAttrStr(staitcAttrs)
		local attr_cnt = #title_attrs
		for i,v in ipairs(title_attrs) do
			if attr_cnt <= 3 then
				self.node_t_list["txt_attr_name_c_" .. i].node:setString(v.type_str .. "：")
				self.node_t_list["txt_attr_value_c_" .. i].node:setString(v.value_str)
			else
				self.node_t_list["txt_attr_name_" .. i].node:setString(v.type_str .. "：")
				self.node_t_list["txt_attr_value_" .. i].node:setString(v.value_str)
			end
		end
		-- XUI.AddClickEventListener(self.node_t_list.btn_recharge.node, BindTool.Bind1(self.OnRecharge, self))
	end
end

function RedPaperGiftPage:OnFlush(paramt,index)
	-- if not paramt then return end
	-- for k, v in pairs(paramt) do
	-- 	if k == "param" then
	-- 		local content = string.format(Language.RedPaper.NoVipTips, 100)
	-- 		RichTextUtil.ParseRichText(self.node_t_list.txt_info.node, content or "", 24, COLOR3B.G_Y)
	-- 	end
	-- end
end

function RedPaperGiftPage:CreateTitle()
	self.title = Title.New()
	self.title:GetView():setPosition(cc.p(210, 260))
	self.node_t_list.layout_gift.node:addChild(self.title:GetView(), 100)
end

function RedPaperGiftPage:ShowIndexCallBack(index)
	self:Flush(index)
end

function RedPaperGiftPage:CloseCallBack()
end

function RedPaperGiftPage:OnClose()
	self:Close()
end

function RedPaperGiftPage:OnRecharge()
end



