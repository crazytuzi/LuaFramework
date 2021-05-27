RedPaperTipsPage = RedPaperTipsPage or BaseClass(XuiBaseView)

function RedPaperTipsPage:__init()
	self.can_penetrate = false
	self.is_any_click_close = true
	self.config_tab = {
						{"red_package_ui_cfg", 2, {0}}
					}

end

function RedPaperTipsPage:__delete()
	
end

function RedPaperTipsPage:ReleaseCallBack()
	
end

function RedPaperTipsPage:LoadCallBack(index, loaded_time)
	if loaded_time <= 1 then
		XUI.AddClickEventListener(self.node_t_list.btn_close.node, BindTool.Bind1(self.OnClose, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_recharge.node, BindTool.Bind1(self.OnRecharge, self))
	end
end

function RedPaperTipsPage:OnFlush(paramt,index)
	if paramt == 0 then return end
	for k, v in pairs(paramt) do
		if k == "param" then
			for k1, v1 in pairs(v) do
				-- local playername = Scene.Instance:GetMainRole():GetName()
				-- local txt_number = 1
				-- for k2, v2 in pairs(v1) do
				-- 	if playername == v2.player_name then
				-- 		txt_number = v2.rob_yb_number
				-- 	end
				-- end
				local content = string.format(Language.RedPaper.NoVipTips, v1)
				RichTextUtil.ParseRichText(self.node_t_list.txt_info.node, content or "", 24, COLOR3B.G_Y)
			end
		end
	end
end

function RedPaperTipsPage:ShowIndexCallBack(index)
	self:Flush(index)
end

function RedPaperTipsPage:CloseCallBack()
end

function RedPaperTipsPage:OnClose()
	self:Close()
end

function RedPaperTipsPage:OnRecharge()
	ViewManager.Instance:Open(ViewName.ChargePlatForm)
end



