FailedTip = FailedTip or BaseClass(XuiBaseView)

function FailedTip:__init()
	self.is_modal = true
	self.is_any_click_close = true
	self.texture_path_list[1] = "res/xui/strength_fb.png"
	self.texture_path_list[2] = "res/xui/fuben.png"
	self.config_tab  = {
							-- {"fuben_child_view_ui_cfg", 2, {0},},
							{"fuben_child_view_ui_cfg", 4, {0},},
						}
	self.page = nil 
	self.level = nil 
	self.count = nil 
end

function FailedTip:__delete()
	
end

function FailedTip:ReleaseCallBack()
	-- if self.reward_cell ~= nil then
	-- 	for i,v in ipairs(self.reward_cell) do
	-- 		v:DeleteMe()
	-- 	end
	-- 	self.reward_cell = {}
	-- end
end

function FailedTip:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		XUI.AddClickEventListener(self.node_t_list.layout_duanzhao.node, BindTool.Bind2(self.OnOpenEquipmentView, self))
		XUI.AddClickEventListener(self.node_t_list.layout_shenlu.node, BindTool.Bind2(self.OnOpenComposeView, self))
		XUI.AddClickEventListener(self.node_t_list.layout_zhanshen.node, BindTool.Bind2(self.OnOpenZhangjiangView, self))
	end
end

function FailedTip:OnFlush(paramt, index)
	for k,v in pairs(paramt) do
		if k == "all" then
			self.node_t_list.txt_desc.node:setVisible(false)
		elseif k == "CommonLose" then
			if v.key.activity_id == ActiveFbID.GuildShouWeiBoss then
				for i = 1, 3 do
					self.node_t_list["fail_star_"..i].node:setVisible(false)
				end
				self.node_t_list.txt_desc.node:setVisible(false)
			elseif v.key.activity_id == ActiveFbID.Trainer then
				self.node_t_list.txt_desc.node:setVisible(true)
				self.node_t_list.txt_desc.node:setString(string.format(Language.AllDayActivity.TrainerDesc, v.key.boss_hp_bar, "%"))
			end
		end
	end
end

function FailedTip:OpenCallBack()
end

function FailedTip:CloseCallBack()
end

function FailedTip:OnOpenEquipmentView()
	ViewManager.Instance:Open(ViewName.Equipment)
end

function FailedTip:OnOpenComposeView()
	ViewManager.Instance:Open(ViewName.Compose)
end

function FailedTip:OnOpenZhangjiangView()
	ViewManager.Instance:Open(ViewName.Zhanjiang)
end