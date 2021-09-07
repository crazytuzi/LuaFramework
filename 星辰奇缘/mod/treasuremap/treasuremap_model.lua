TreasuremapModel = TreasuremapModel or BaseClass(BaseModel)

function TreasuremapModel:__init()
    self.window = nil
    self.exchange_window = nil

	self.is_checking_treasuremap = false -- 正在检查坐标

	self.status = 0 --宝图状态:0:无,1:有普通奖励,2:有指南针
	self.gain_id = 0 -- 奖励序号
	self.time = nil --领取奖励时间
	self.item_list = {} --奖励列表

	self.compass_id = 0 --指南针id, 暂无作用
	self.compass_end_time = nil --指南针时间
	self.map_id = nil --地图id
	self.x = nil --x坐标
	self.y = nil --y坐标

    self.item_baseid = nil --藏宝图物品的baseid
	self.item_id = nil --藏宝图物品的背包id
	self.item_map_id = nil --藏宝图物品的地图id
	self.item_x = nil --藏宝图物品的x坐标
	self.item_y = nil --藏宝图物品的y坐标

	self.compass_object = nil
	self.timer = nil

    EventMgr.Instance:AddListener(event_name.scene_load, function() self:change_map() end)
end

function TreasuremapModel:__delete()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function TreasuremapModel:OpenWindow()
    if self.window == nil then
        self.window = TreasuremapView.New(self)
    end
    self.window:Open()
end

function TreasuremapModel:CloseWindow()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function TreasuremapModel:OpenExchangeWindow()
    if self.exchange_window == nil then
        self.exchange_window = TreasuremapExchangeView.New(self)
    end
    self.exchange_window:Open()
end

function TreasuremapModel:CloseExchangeWindow()
    if self.exchange_window ~= nil then
        self.exchange_window:DeleteMe()
        self.exchange_window = nil
    end
end

function TreasuremapModel:use_treasuremap(itemdata)
    if RoleManager.Instance.RoleData.lev < itemdata.lev then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ff0000'>%s级</color>才能使用<color='#cccccc'>%s</color>"), itemdata.lev, itemdata.name))
        return
    end

    if BackpackManager.Instance:GetCurrentGirdNum() <= 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("背包已满，请先整理背包"))
        return
    end

    self.item_map_id = nil
    self.item_x = nil
    self.item_y = nil
    self.item_id = itemdata.id
    self.item_baseid = itemdata.base_id
    for k,v in pairs(itemdata.extra) do
        if v.name == BackpackEumn.ExtraName.map_id then
            self.item_map_id = v.value
        elseif v.name == BackpackEumn.ExtraName.map_x then
            self.item_x = v.value
        elseif v.name == BackpackEumn.ExtraName.map_y then
            self.item_y = v.value
        end
    end

    if self.item_map_id ~= nil and self.item_x ~= nil and self.item_y ~= nil then
        if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
            local self_point = SceneManager.Instance.sceneElementsModel.self_view.gameObject.transform.position
            self_point = SceneManager.Instance.sceneModel:transport_big_pos(self_point.x, self_point.y)
        	if SceneManager.Instance:CurrentMapId() == self.item_map_id then
                local dis = BaseUtils.distance_byxy(self.item_x, self.item_y, self_point.x, self_point.y)
                if dis < 150 then
                    local item_id = self.item_id
                    local func = function()
                    	BackpackManager.Instance:Send10315(item_id, 1)
                        self.item_id = nil
                    end
	                SceneManager.Instance.sceneElementsModel.collection.callback = func
	                SceneManager.Instance.sceneElementsModel.collection:Show({msg = TI18N("挖宝中..."), time = 1000})

                    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(2)
                else
                    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                    SceneManager.Instance.sceneElementsModel:Self_AutoPath(self.item_map_id, nil, self.item_x, self.item_y, true)
                    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)

                    if not self.is_checking_treasuremap then
                        self:check_treasuremap()
                    end
                end
            else
                SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                SceneManager.Instance.sceneElementsModel:Self_AutoPath(self.item_map_id, nil, self.item_x, self.item_y, true)
                SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)

                if not self.is_checking_treasuremap then
                    self:check_treasuremap()
                end
            end
            TipsManager.Instance.model:Closetips()
            WindowManager.Instance:CloseWindowById(WindowConfig.WinID.backpack)
        end
    end
end

function TreasuremapModel:change_map()
    if self.map_id ~= nil and self.map_id ~= 0 then
        MainUIManager.Instance:OpenTreasuremapCompassView()
    else
        MainUIManager.Instance:CloseTreasuremapCompassView()
    end

    if not self.is_checking_treasuremap then
        self:check_treasuremap()
    end
end

function TreasuremapModel:check_treasuremap()
    -- print("check_treasuremap")
    self.is_checking_treasuremap = false
    if SceneManager.Instance.sceneElementsModel.self_view ~= nil
        and not BaseUtils.is_null(SceneManager.Instance.sceneElementsModel.self_view.gameObject) then
        local self_point = SceneManager.Instance.sceneElementsModel.self_view.gameObject.transform.position
        self_point = SceneManager.Instance.sceneModel:transport_big_pos(self_point.x, self_point.y)
        if SceneManager.Instance:CurrentMapId() == self.item_map_id then -- 藏宝图
            local dis = BaseUtils.distance_byxy(self.item_x, self.item_y, self_point.x, self_point.y)
            if dis < 150 then
                local itemdata = BackpackManager.Instance:GetItemById(self.item_id)
				if itemdata ~= nil and not NoticeManager.Instance.model.autoUse.showing then
                    local autoUseData = self.autoUseData
                    if autoUseData == nil or autoUseData.inChain ~= true then
                        autoUseData = AutoUseData.New()
                        self.autoUseData = autoUseData
                    end
                    autoUseData.callback = function()
                        SceneManager.Instance.sceneElementsModel.self_view:StopMoveTo()
                        QuestManager.Instance.model.lastType = 0
                        LuaTimer.Add(50, function () self:use_treasuremap(itemdata)  end)
                    end
                    autoUseData.title = TI18N("使用物品")
					autoUseData.itemData = itemdata
                    NoticeManager.Instance:AutoUse(autoUseData)
                end
            elseif dis < 800 then
                if not self.is_checking_treasuremap then
                    self.is_checking_treasuremap = true
                    LuaTimer.Add(250, function () self:check_treasuremap() end)
                end
            elseif dis < 1500 then
                if not self.is_checking_treasuremap then
                    self.is_checking_treasuremap = true
                    LuaTimer.Add(500, function () self:check_treasuremap() end)
                end
            else
                if not self.is_checking_treasuremap then
                    self.is_checking_treasuremap = true
                    LuaTimer.Add(1000, function () self:check_treasuremap() end)
                end
            end
        elseif SceneManager.Instance:CurrentMapId() == self.map_id then -- 指南针
            local angle = BaseUtils.get_angle_byxy(self_point.x, self_point.y, self.x, self.y)
            local dis = BaseUtils.distance_byxy(self.x, self.y, self_point.x, self_point.y)
            if dis < 150 then
                if not self.is_checking_treasuremap then
                    self.is_checking_treasuremap = true
                    LuaTimer.Add(100, function () self:check_treasuremap() end)
                end
            elseif dis < 800 then
                if not self.is_checking_treasuremap then
                    self.is_checking_treasuremap = true
                    LuaTimer.Add(300, function () self:check_treasuremap() end)
                end
            elseif dis < 1500 then
                if not self.is_checking_treasuremap then
                    self.is_checking_treasuremap = true
                    LuaTimer.Add(500, function () self:check_treasuremap() end)
                end
            else
                if not self.is_checking_treasuremap then
                    self.is_checking_treasuremap = true
                    -- ctx:InvokeDelay(self.check_treasuremap, 1)
                    LuaTimer.Add(1000, function () self:check_treasuremap() end)
                end
            end
            EventMgr.Instance:Fire(event_name.treasuremap_compass_update, angle, dis)
        else
            if (self.item_map_id ~= nil and self.item_map_id ~= 0) or (self.map_id ~= nil and self.map_id ~= 0) then
    	        if not self.is_checking_treasuremap then
    	            self.is_checking_treasuremap = true
    	            LuaTimer.Add(1000, function () self:check_treasuremap() end)
    	        end
            end
        end
    else
        if (self.item_map_id ~= nil and self.item_map_id ~= 0) or (self.map_id ~= nil and self.map_id ~= 0) then
            if not self.is_checking_treasuremap then
                self.is_checking_treasuremap = true
                LuaTimer.Add(1000, function () self:check_treasuremap() end)
            end
        end
    end
end

-- function TreasuremapModel:open_dialog(data)
--     local unit_data = data_treasure.data_unit[string.format("%s_%s", mod_scene_manager.mapid, data.baseid)]
--     if unit_data == nil then
--         print(string.format("怪物不存在于封妖表", data.baseid))
--         return
--     end

--     local button_text = string.format("废话少说，看打(%s级妖怪)", unit_data.lev)

--     local args = utils.copytab(data_unit.data_unit[data.baseid])
--     args.id = data.baseid
--     args.name = data.name
--     args.buttons = {
--             {button_id = 10, button_args = {battleid = data.battleid, id = data.id}, button_desc = button_text, button_show = "[]"}
--             ,{button_id = 999, button_args = {}, button_desc = "饶他一命", button_show = "[]"}
--         }
--     -- args.isrole = true
--     -- args.looks = data.looks
--     -- args.sex = data.sex
--     -- args.classes = data.classes
--     mod_dialog.open(data, { base = args })
-- end

-- function TreasuremapModel:dialog_button_click(args)
--     if mod_team.has_team() then
--         if #mod_team.team.members < 3 then
--             mod_notify.open_confirm_win(TI18N("这只妖怪比较凶猛，当前<color='#ffff00'>队伍人数不足3人</color>，是否要进入战斗吗？")
--                 , TI18N("提示"), function() mod_scene_elements_manager.send10100(args.battleid, args.id) end, 0
--                 , TI18N("进入"), TI18N("取消"))
--         else
--             mod_scene_elements_manager.send10100(args.battleid, args.id)
--         end
--     else
--         mod_notify.open_confirm_win(TI18N("这只妖怪比较凶猛，当前<color='#ffff00'>队伍人数不足3人</color>，是否要进入战斗吗？")
--             , TI18N("提示"), function() mod_scene_elements_manager.send10100(args.battleid, args.id) end, 0
--             , TI18N("进入"), TI18N("取消"))
--     end
-- end

function TreasuremapModel:On13600(data)
	self.status = data.status
	self.gain_id = data.gain_id
	self.time = data.time
	self.item_list = data.table
	local sortfun = function(a,b)
	    return a.id < b.id
	end
	table.sort(self.item_list, sortfun)

	self.compass_id = data.compass_id
	self.compass_end_time = data.compass_end_time
	self.map_id = data.map_id
	self.x = data.x
	self.y = data.y

	self.item_map_id = nil
	self.item_x = nil
	self.item_y = nil
	self.item_id = nil

	if self.status == 1 then
		-- windows.open_window(windows.panel.treasuremapwindow)
		-- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.treasuremapwindow)
        TreasuremapManager.Instance:Send13601() -- 关闭界面领取奖励

        -- 如果奖励类型是 1:道具 4:封妖，则使用背包剩余的藏宝图
        if BackpackManager.Instance:GetCurrentGirdNum() > 0 then
            for i = 1, #self.item_list do
                local data = self.item_list[i]
                if self.gain_id == data.id then
                    -- print(string.format("挖到的奖励是 %s", data.type))
                    if data.type == 1 or data.type == 4 then
                        local item_list = nil
                        if self.item_baseid ~= nil then
                            item_list = BackpackManager.Instance:GetItemByBaseid(self.item_baseid)
                            if #item_list > 0 then
                                LuaTimer.Add(1000, function() self:use_treasuremap(item_list[1]) end)
                                return
                            end
                        end

                        item_list = BackpackManager.Instance:GetItemByBaseid(20052)
                        if #item_list > 0 then
                            LuaTimer.Add(1000, function() self:use_treasuremap(item_list[1]) end)
                            return
                        end

                        item_list = BackpackManager.Instance:GetItemByBaseid(20053)
                        if #item_list > 0 then
                            LuaTimer.Add(1000, function() self:use_treasuremap(item_list[1]) end)
                            return
                        end
                    end
                    return
                end
            end
        end
	end

	if self.status == 2 then
	    MainUIManager.Instance:OpenTreasuremapCompassView()
        if not self.is_checking_treasuremap then
            self:check_treasuremap()
        end
	else
	    MainUIManager.Instance:CloseTreasuremapCompassView()
	end
end