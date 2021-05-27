--游戏引导 等级成长视图
GuideLevelUpView = GuideLevelUpView or BaseClass(BaseView)

GuideLevelUpView.IconList = {

---- 降妖除魔
	{
		res = "49",
	 	view_pos = nil, -- 图标打开类名（view_def查看), 如果需要传送NPC设为nil
	 	npc_id = 83,
	  	check_func = function ()
			return true
		end
	},
	
	-- 经验炼制
	{
		res = "51",      -- 图标id 
		view_pos = ViewDef.RefiningExp, 			-- 图标打开类名（view_def查看), 如果需要传送NPC设为nil
		check_func = function ()   		-- 是否判断该功能是否开启，true不判断
			--return true
			return GameCondMgr.Instance:GetValue("CondId64")   -- 条件（cond_def查找）
		end
	},	
	
	-- 试炼
	{
		res = "54",      -- 图标id 
		view_pos = ViewDef.Experiment.Trial, 			-- 图标打开类名（view_def查看), 如果需要传送NPC设为nil
		check_func = function ()   		-- 是否判断该功能是否开启，true不判断
			--return true
			return GameCondMgr.Instance:GetValue("CondId66")   -- 条件（cond_def查找）
		end
	},
	
---- 经验副本
	{
		res = "50",
	 	view_pos = ViewDef.Dungeon.Experience, -- 图标打开类名（view_def查看), 如果需要传送NPC设为nil
	 	npc_id = 80,
	  	check_func = function ()
			return GameCondMgr.Instance:GetValue("CondId69")
		end
	},		

	-- 经验炼制
	-- {
	-- 	res = "52",      -- 图标id 
	-- 	view_pos = ViewDef.MainBagView.ComspoePanel, 			-- 图标打开类名（view_def查看), 如果需要传送NPC设为nil
	-- 	check_func = function ()   		-- 是否判断该功能是否开启，true不判断
	-- 		--return true
	-- 		return GameCondMgr.Instance:GetValue("CondId126")   -- 条件（cond_def查找）
	-- 	end
	-- },
	
}

function GuideLevelUpView:__init()
	self.zorder = COMMON_CONSTS.PANEL_MAX_ZORDER
 
	self.config_tab = {
		{"use_to_create_ui_cfg", 1, {0},},
	}
	self.is_any_click_close = true	
	self.is_modal = true

	--keytest
	-- GlobalEventSystem:Bind(LayerEventType.KEYBOARD_RELEASED, function (key_code, event)
	-- 	if cc.KeyCode.KEY_T == key_code and event == cc.Handler.EVENT_KEYBOARD_PRESSED then
	-- 		ViewManager.Instance:OpenViewByDef(ViewDef.GuideLevelUp)
	-- 	end
	-- end)
end

function GuideLevelUpView:__delete()
end

function GuideLevelUpView:LoadCallBack()
	local pos_index = 0
	for i,v in ipairs(GuideLevelUpView.IconList) do
		if v.check_func and v.check_func() then
			pos_index = pos_index + 1
		-- 	local iocn = self:CreateIcon(v)
		-- 	pos_index = pos_index + 1
		-- 	local y = 200 + ((pos_index / 3 <= 1) and -10 or - 100)
		-- 	local x = (pos_index % 3 == 0 and 3 or pos_index % 3) * 120 + 145

		-- 	iocn:setPosition(x, y)
		end
	end
	local index = 0
	for k, v in pairs(GuideLevelUpView.IconList) do
		if v.check_func and v.check_func() then
			if pos_index == 1 then
				local iocn = self:CreateIcon(v)
				local y = 145
				local x = 395
				iocn:setPosition(x, y)
			elseif pos_index == 2 then
				local iocn = self:CreateIcon(v)
				index = index + 1 
				local y = 145
				local x = 265 + (index - 1) * 240
				iocn:setPosition(x, y)
			elseif pos_index == 3 then
				index = index + 1
				local iocn = self:CreateIcon(v)
				local y = 145
				local x = (index % 3 == 0 and 3 or index % 3) * 120 + 145

				iocn:setPosition(x, y)

			elseif pos_index > 3 then
				index = index + 1
				local iocn = self:CreateIcon(v)
				local y = 145
				local x = (index % 3 == 0 and 3 or index % 3) * 120 + 145

				iocn:setPosition(x, y)
			end
		end
	end
	self.node_t_list.layout_guide_level.node:setPositionY(200)
end

function GuideLevelUpView:CreateIcon(data)
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
			ViewManager.Instance:OpenViewByDef(data.view_pos)
		end
		self:Close()
	end, true)

	self.node_t_list.layout_guide_level.node:addChild(node, 300)
	return node
end

function GuideLevelUpView:CloseCallBack()
end
