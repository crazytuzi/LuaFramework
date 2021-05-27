TaskEquipGuideView = TaskEquipGuideView or BaseClass(BaseView)

function TaskEquipGuideView:__init( ... )
	self:SetBgOpacity(200)
	self:SetModal(true)
	self.is_any_click_close = true	
	self.texture_path_list = {
		"res/xui/task_ui.png",
		
	}
	self.config_tab = {
		--{"common_ui_cfg", 1, {0}},
		{"use_to_create_ui_cfg", 1, {0}},
		--{"team_ui_cfg", 2, {0}},
		--{"common_ui_cfg", 2, {0}},
	}
end

function TaskEquipGuideView:__delete( ... )
	-- body
end

function TaskEquipGuideView:ReleaseCallBack( ... )

end

function TaskEquipGuideView:LoadCallBack( ... )
	-- XUI.AddClickEventListener(self.node_t_list.btn_enter.node, BindTool.Bind1(self.EnterFuben, self), true)
	local pos_index = 0
	for i,v in ipairs(ClientYinDaiIconList) do
		if GameCondMgr.Instance:GetValue(v.check_func) then
			local bool = true
			if v.is_need_Info then
				bool = not ChargeRewardData.Instance:GetFirstChargeIsAllGet()
			end
			if bool then
				local iocn = self:CreateIcon(v)
				pos_index = pos_index + 1
				local y = 200 + ((math.ceil(pos_index / 3) <= 1) and -50 or -100)
				local x = (pos_index % 3 == 0 and 3 or pos_index % 3) * 120 + 145

				iocn:setPosition(x, y)
			end
		end
	end
end


function TaskEquipGuideView:OpenCallBack()

end

function TaskEquipGuideView:ShowIndexCallBack(index)
	self:Flush(index)
end

function TaskEquipGuideView:CloseCallBack(...)
	
end




function TaskEquipGuideView:OnFlush(param_list, index)

	for k, v in pairs(param_list) do
		if k == "param1" then
			
		end
	end
end


function TaskEquipGuideView:CreateIcon(data)
	local node = XUI.CreateLayout(0, 0, 100, 100)

	local img_bg = XUI.CreateImageView(0, 0, ResPath.GetMainui(string.format("icon_bg", data.res)))
	local img_icon = XUI.CreateImageView(0, 0, ResPath.GetMainui(string.format("icon_%s_img", data.res)))
	node:addChild(img_bg, 1)
	node:addChild(img_icon, 2)

	-- if type(tonumber(data.res)) == "number" then 
	-- 	local img_word = XUI.CreateImageView(0, -35, ResPath.GetMainui(string.format("icon_%s_word", data.res)))
	-- 	node:addChild(img_word, 3)
	-- end

	XUI.AddClickEventListener(img_icon, function ()
		if data.view_pos == nil then
			Scene.SendQuicklyTransportReqByNpcId(data.npc_id)
		else
			ViewManager.Instance:OpenViewByStr(data.view_pos)
		end
		self:Close()
	end, true)

	self.node_t_list.layout_guide_level.node:addChild(node, 300)
	return node
end


function TaskEquipGuideView:OnFlushCd()
	
end

