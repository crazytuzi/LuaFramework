-- 
-- @Author: LaoY
-- @Date:   2018-09-06 20:19:41
-- 
MainTaskItem = MainTaskItem or class("MainTaskItem", BaseItem)
local MainTaskItem = MainTaskItem

function MainTaskItem:ctor(parent_node, layer)
    self.abName = "main"
    self.assetName = "MainTaskItem"
    self.layer = layer

    self.model = TaskModel:GetInstance()
    self.model_event_list = {}

    MainTaskItem.super.Load(self)
end

function MainTaskItem:dctor()
    self:StopTime()
    self:DelEffect()

    if self.model_event_list then
        self.model:RemoveTabListener(self.model_event_list)
        self.model_event_list = {}
    end

    if self.icon_settor then
        self.icon_settor:destroy()
        self.icon_settor = nil
    end
end

function MainTaskItem:LoadCallBack()
    self.nodes = {
        "task_content", "task_name", "img_fly_icon", "img_bg",
        "iconContain", "img_sel", "text_state","img_task_ing","img_task_submit","img_task_finish",
    }
    self:GetChildren(self.nodes)
    -- self.task_line_name_txt = self.task_line_name:GetComponent('Text')
    self.task_name_component = self.task_name:GetComponent('Text')
  
    self.task_content_component = self.task_content:GetComponent('Text')

    SetSizeDeltaY(self.task_content,19)
    
    if self.img_sel_state ~= nil then
        self:SetSelState(self.img_sel_state)
    else
        self:SetSelState(false)
    end
    self.font_size = self.task_content_component.fontSize
    self.start_y = GetLocalPositionY(self.task_content)

    self.text_state_component = self.text_state:GetComponent('Text')

    self:AddEvent()
    if self.is_need_setData then
        self:SetData(self.data,self.stencilId,self.stencilType,self.index)
    end
end

function MainTaskItem:AddEvent()
    local function fly_call_back(target, x, y)
        -- Notify.ShowText("小飞鞋功能尚未开放")
        -- if not self.target_pos then
        -- 	return
        -- end
        -- SceneControler:GetInstance():UseFlyShoeToPos(self.target_scene_id,self.target_pos.x,self.target_pos.y)
        if self.data.state == enum.TASK_STATE.TASK_STATE_TRIGGER then
            self.model:Brocast(TaskEvent.ReqTaskAccept, self.data.id)
        elseif self.data.state == enum.TASK_STATE.TASK_STATE_ACCEPT then
            if self.config.type == enum.TASK_TYPE.TASK_TYPE_SIDE and (self.goal_type == enum.EVENT.EVENT_EQUIP or self.goal_type == enum.EVENT.EVENT_COMPOSE) then
                local cur_goal = self.cur_goal
                local list = self:GetMainTaskTipList()
                lua_panelMgr:OpenPanel(MainTaskTipPanel,list)
                --lua_panelMgr:GetPanelOrCreate(TaskTipPanel):Open()
                return
            end
            self.model:DoTask(self.data.id, true)
        elseif self.data.state == enum.TASK_STATE.TASK_STATE_FINISH then
            self.model:FinishTask(self.data.id)
        end

        if self.call_back then
            self.call_back(self)
        end
    end
    AddClickEvent(self.img_fly_icon.gameObject, fly_call_back)

    local function call_back(target, x, y)
        if self.data.task_type == enum.TASK_TYPE.TASK_TYPE_ESCORT then
            FactionEscortModel:GetInstance():GoNpc()
            if self.call_back then
                self.call_back(self)
            end
            return
        end

        if not self.config or not self.data then
            return
        end
        -- do
        --     lua_panelMgr:OpenPanel(MainTaskTipPanel)
        --     return
        -- end

        if self.config.type == enum.TASK_TYPE.TASK_TYPE_MAIN and self.data.state == enum.TASK_STATE.TASK_STATE_COMING then
            --主线
            --lua_panelMgr:OpenPanel(MainTaskTipPanel)
            lua_panelMgr:GetPanelOrCreate(TaskTipPanel):Open()
            return
        end

        -- local viplv = RoleInfoModel:GetInstance():GetRoleValue("viplv")
        -- if viplv and viplv >= 1 then
        --     fly_call_back()
        --     return
        -- end

        if self.data.state == enum.TASK_STATE.TASK_STATE_TRIGGER then
            self.model:Brocast(TaskEvent.ReqTaskAccept, self.data.id)
        elseif self.data.state == enum.TASK_STATE.TASK_STATE_ACCEPT then
            if self.config.type == enum.TASK_TYPE.TASK_TYPE_SIDE and (self.goal_type == enum.EVENT.EVENT_EQUIP or self.goal_type == enum.EVENT.EVENT_COMPOSE) then
                local cur_goal = self.cur_goal
                local list = self:GetMainTaskTipList()
                lua_panelMgr:OpenPanel(MainTaskTipPanel,list)
                --lua_panelMgr:GetPanelOrCreate(TaskTipPanel):Open()
                return
            end
            self.model:DoTask(self.data.id)
        elseif self.data.state == enum.TASK_STATE.TASK_STATE_FINISH then
            self.model:FinishTask(self.data.id)
        end
        if self.call_back then
            self.call_back(self)
        end
    end
    AddClickEvent(self.img_bg.gameObject, call_back)

    local function call_back(task_id, data)
        if self.data and self.data.id == task_id then
            self:SetData(data)
        end
    end
    self.model_event_list[#self.model_event_list + 1] = TaskModel:GetInstance():AddListener(TaskEvent.AccTaskAccept, call_back)

    local function call_back(task_id, data)
        if not self.data then
            return
        end
        self:SetSelState(self.data.id == task_id)
    end
    self.model_event_list[#self.model_event_list + 1] = TaskModel:GetInstance():AddListener(TaskEvent.DoTask, call_back)
end

function MainTaskItem:SetCallBack(call_back)
    self.call_back = call_back
end

function MainTaskItem:GetMainTaskTipList()
    local link_list = self:GetLinkList()
    if not link_list then
        return
    end
    local t = {}
    local len = #link_list
    for i=1,len do
        local link = link_list[i]
        local cf = GetOpenLink(link[1],link[2]) 
        t[#t+1] = {text = cf.name , param = link}
    end
    return t
end

function MainTaskItem:GetLinkList()
    local params = self.cur_goal[6]
    if not params then
        return nil
    end
    for k,v in pairs(params) do
        if v[1] == "link" then
            return v[2]
        end
    end
    return nil
end

function MainTaskItem:SetSelState(state)
    if not self.is_loaded then
        return
    end
    if self.img_sel_state == state then
        return
    end
    self.img_sel_state = state
    SetVisible(self.img_sel, state)
end

function MainTaskItem:AddEffect()
    if not self.effect then
        self.effect = UIEffect(self.transform, 10504, false)
        --self.effect:SetOrderIndex(99)

        if (self.useStencil) then
            self.effect:SetConfig({ useStencil = true, stencilId = self.stencilId, stencilType = self.stencilType ,scale = {x= 1.4,y=1,z=1}})
        end
    end
end

function MainTaskItem:DelEffect()
    if self.effect then
        self.effect:destroy()
        self.effect = nil
    end
end

function MainTaskItem:SetData(data, stencilId, stencilType,index)
    if self.data and data.id ~= self.data.id then
        self.config = nil
        self.goals = nil
    end
    self.data = data
    self.index = index
    if (stencilId and stencilType) then
        if (self.effect) then
            self.effect:SetConfig({ useStencil = true, stencilId = stencilId, stencilType = stencilType })
        else
            self.useStencil = true
            self.stencilId = stencilId
            self.stencilType = stencilType
        end
    end

    if not self.data then
        return
    end
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end
    if self.index == 1 then
        self:AddEffect()
    end
    if self.data.task_type == enum.TASK_TYPE.TASK_TYPE_ESCORT then
        self.task_name_component.text = self.data.title
        self.task_content_component.text = self.data.des
        if self.index ~= 1 then
            self:DelEffect()
        end

        self:StopTime()

        SetLocalPositionX(self.task_name, -95)
        SetLocalPositionX(self.task_content, -95)
        if self.icon_settor then
            self.icon_settor:SetVisible(false)
        end
        SetVisible(self.img_fly_icon, false)
        local state_str = "<color=#5ae2ff>In progress</color>"
        self.text_state_component.text = state_str
        SetVisible(self.img_task_ing,true)
        SetVisible(self.img_task_finish,false)
        SetVisible(self.img_task_submit,false)
        return
    end
    self.config = self.config or Config.db_task[self.data.id]
    if not self.config then

        --这两句需要放进来 否则会引发频繁的UI Rebuild
        self.task_name_component.text = ""
        self.task_content_component.text = ""

        return
    end

    -- if not self.goals then
    -- 	self.goals = String2Table(self.config.goals) or {}
    -- end
    self.goals = self.data.goals
    self:StopTime()
    self:SetContent()
    if self.config.type == enum.TASK_TYPE.TASK_TYPE_TIME then
        --限时
        local function step()
            self:SetContent()
        end
        self.time_id = GlobalSchedule:Start(step, 1.0)
    end

    local state_str = "<color=#5ae2ff>In progress</color>"
    -- local state_str = "<color=#5ae2ff>进行中</color>"
   -- TASK_TYPE_MAIN

    local show_task_state = self.img_task_ing
    if self.goals and self.goals[1][1] == 2 then
        state_str = "<color=#7dff5a>Tradable</color>"
        show_task_state = self.img_task_submit
        if self.config.type == enum.TASK_TYPE.TASK_TYPE_MAIN  then
            if self.data.state == enum.TASK_STATE.TASK_STATE_COMING then
                state_str = "<color=#5ae2ff>In progress</color>"
                show_task_state = self.img_task_ing
            end
        end
    end
    local lv = RoleInfoModel:GetInstance():GetMainRoleLevel() or 0
    if self.data.state == enum.TASK_STATE.TASK_STATE_FINISH then
        state_str = "<color=#7dff5a>Done</color>"
        show_task_state = self.img_task_finish
        self:AddEffect()
    elseif self.config.type == enum.TASK_TYPE.TASK_TYPE_MAIN and lv <= 160 then
        if self.data.state ~= enum.TASK_STATE.TASK_STATE_COMING then
            self:AddEffect()
        else
            if self.index ~= 1 then
                self:DelEffect()
            end
        end
    else
        if self.index ~= 1 then
            self:DelEffect()
        end
    end

    self.text_state_component.text = state_str
    SetVisible(self.img_task_ing,show_task_state == self.img_task_ing)
    SetVisible(self.img_task_submit,show_task_state == self.img_task_submit)
    SetVisible(self.img_task_finish,show_task_state == self.img_task_finish)

    local type_name = enumName.TASK_TYPE[self.config.type]
    local color = self:TaskNameColor()
    -- self.task_line_name_txt.text = string.format("<color=#%s>%s</color>",color,type_name or "")
    --local name_str = string.format("<color=#%s>%s%s</color>",color,type_name and "[" .. type_name .. "]" or "",self.config.name)
    local name_str = string.format("<color=#%s>[%s]%s</color>", color, type_name, self.config.name)
    if self.config.type == enum.TASK_TYPE.TASK_TYPE_SIDE and (self.goal_type == enum.EVENT.EVENT_EQUIP or self.goal_type == enum.EVENT.EVENT_COMPOSE) then
        name_str = string.format("<color=#%s>[%s]%s</color>", color, "Equip", self.config.name)
    elseif self.config.type == enum.TASK_TYPE.TASK_TYPE_DAILY then
        --主线
        local server_pb = self.model:GetLoopDaily()
        if server_pb then
            local loop_config = Config.db_task[server_pb.id]
            -- local cur_goal = String2Table(loop_config.goals)[1] or {}
            local cur_goal = server_pb.goals[1]
            name_str = string.format("<color=#%s>[%s]Loop Quest(%s/%s)</color>", color, type_name, server_pb.count + 1, (cur_goal[3] or 20))
        end
    elseif self.config.type == enum.TASK_TYPE.TASK_TYPE_GUILD then
        --主线
        local server_pb = self.model:GetLoopGuild()
        if server_pb then
            local loop_config = Config.db_task[server_pb.id]
            -- local cur_goal = String2Table(loop_config.goals)[1] or {}
            local cur_goal = server_pb.goals[1]
            name_str = string.format("<color=#%s>[%s]Guild Token(%s/%s)</color>", color, type_name, server_pb.count + 1, (cur_goal[3] or 20))

            Yzprint('--LaoY MainTaskItem.lua,line 252--', server_pb)
            Yzdump(server_pb, "server_pb")
        end
    end
    self.task_name_component.text = name_str
    self:SetIcon(self.config)
    self:PlayEffect()
end

function MainTaskItem:TaskNameColor()
    local color = "ffe25a"
    if self.config.type == enum.TASK_TYPE.TASK_TYPE_MAIN then
        --主线
        color = "ffe25a"
    elseif self.config.type == enum.TASK_TYPE.TASK_TYPE_TIME then
        --限时
        -- color = ColorUtil.GetColor(ColorUtil.ColorType.Pink)
        color = "ff6eec"
    elseif self.config.type == enum.TASK_TYPE.TASK_TYPE_SIDE then
        --支线
        -- color = ColorUtil.GetColor(ColorUtil.ColorType.Green)
        color = "53f057"
    elseif self.config.type == enum.TASK_TYPE.TASK_TYPE_REIN then
        --觉醒
        color = "ff6eec"
    end
    return color
end

function MainTaskItem:SetContent()
    if not self.goals or not self.data then
        self:StopTime()
        return
    end
    local cur_prog = self.data.prog >= #self.goals and #self.goals or self.data.prog + 1
    local cur_goal = self.goals[cur_prog]
    if self.data.task_type == enum.TASK_TYPE.TASK_TYPE_DAILY or self.data.task_type == enum.TASK_TYPE.TASK_TYPE_GUILD then
        cur_goal = self.goals[1]
    end
    if not cur_goal then
        self:StopTime()
        return
    end
	if self.config.type == enum.TASK_TYPE.TASK_TYPE_REIN then
		Yzprint('--LaoY MainTaskItem.lua,line 354--',data)
	end
    local content_str = ""
    local goal_type = cur_goal[1]
    local target_id = cur_goal[2]
    local target_count = cur_goal[3]
    local target_scene_id = cur_goal[4]
    local target_pos = nil
    self.cur_goal = cur_goal
    self.goal_type = goal_type
	
	if self.data.id == 55201 then
		print("-------")
	end
    -- 升级
    if goal_type == enum.EVENT.EVENT_LEVEL then
        local lv = RoleInfoModel:GetInstance():GetMainRoleLevel()
        local color = "e63232"
        if lv >= target_count then
            color = "53f057"
            lv = target_count
        end
        content_str = string.format("Lv reaches(<color=#%s>%s</color>/%s)", color, lv, target_count)
    elseif self.config.type == enum.TASK_TYPE.TASK_TYPE_SIDE and (self.goal_type == enum.EVENT.EVENT_EQUIP or self.goal_type == enum.EVENT.EVENT_COMPOSE or 
			self.goal_type == enum.EVENT.EVENT_EQUIP_STRENGTH) then
        local color = "e63232"
        if self.data.count >= target_count then
            color = "53f057"
        end
        content_str = string.format("%s(<color=#%s>%s</color>/%s)", self.config.desc, color, self.data.count, target_count)
    elseif self.config.type == enum.TASK_TYPE.TASK_TYPE_SIDE and goal_type ~= enum.EVENT.EVENT_CREEP then
        if goal_type == enum.EVENT.EVENT_DUNGE_ENTER or goal_type == enum.EVENT.EVENT_LIVENESS then --10 25
            local color = "e63232"
            if self.data.count >= target_count then
                color = "53f057"
            end
            content_str = string.format("%s(<color=#%s>%s</color>/%s)", self.config.desc, color, self.data.count, target_count)
        else
            content_str = string.format("<color=#fffefe>%s</color>", self.config.desc)
        end
    elseif self.config.type == enum.TASK_TYPE.TASK_TYPE_SIDE and goal_type == enum.EVENT.EVENT_CREEP then
        if not string.isNilOrEmpty(self.config.desc) then
            local color = "e63232"
            if self.data.count >= target_count then
                color = "53f057"
            end
            content_str = string.format("%s(<color=#%s>%s</color>/%s)", self.config.desc, color, self.data.count, target_count)
        else
            if target_id == 3 then
                local level
                local boss_type
                local params = cur_goal[6]
                if params then
                    for k, v in pairs(params) do
                        if v[1] == "level" then
                            level = v[2]
                        elseif v[1] == "boss_type" then
                            boss_type = v[2]
                        end
                    end
                end
                -- 需要根据等级获取蛮荒boss的id
                local link_target_id
                if boss_type and level then
                    target_id = DungeonModel:GetInstance():GetBossIDByTypeLevel(boss_type, level)
                end
            end
            local task_target = Config.db_creep[target_id]

            if task_target then
                local color = "e63232"
                if self.data.count >= target_count then
                    color = "53f057"
                end
                content_str = string.format("<color=#fffefe>defeat<color=#53f057>%s</color>(<color=#%s>%s</color>/%s)</color>", task_target.name, color, self.data.count, target_count)
            end
            local pos = SceneConfigManager:GetInstance():GetNpcPosition(target_scene_id, target_id)
            if pos then
                target_pos = pos
            end

        end
	elseif self.config.type == enum.TASK_TYPE.TASK_TYPE_ACTIVE then
		local color = "e63232"
		if self.data.count >= target_count then
			color = "53f057"
		end
		content_str = string.format("%s(<color=#%s>%s</color>/%s)",self.config.desc,color,self.data.count,target_count)
        -- 对话任务
    elseif goal_type == enum.EVENT.EVENT_TALK then
        local task_target = Config.db_npc[target_id]
        if task_target then
            content_str = string.format("<color=#fffefe>Talk with <color=#53f057>%s</color>.</color>", task_target.name)
        end
        local pos = SceneConfigManager:GetInstance():GetNpcPosition(target_scene_id, target_id)
        if pos then
            target_pos = pos
        end
        -- 打怪
    elseif self.config.type ~= enum.TASK_TYPE.TASK_TYPE_SIDE and goal_type == enum.EVENT.EVENT_CREEP then
        if target_id == 3 then
            local level
            local boss_type
            local params = cur_goal[6]
            if params then
                for k, v in pairs(params) do
                    if v[1] == "level" then
                        level = v[2]
                    elseif v[1] == "boss_type" then
                        boss_type = v[2]
                    end
                end
            end
                -- 需要根据等级获取蛮荒boss的id
            local link_target_id
            if boss_type and level then
                target_id = DungeonModel:GetInstance():GetBossIDByTypeLevel(boss_type, level)
            end
        end
        local task_target = Config.db_creep[target_id]

        if task_target then
            local color = "e63232"
            if self.data.count >= target_count then
                color = "53f057"
            end
            content_str = string.format("<color=#fffefe>defeat<color=#53f057>%s</color>(<color=#%s>%s</color>/%s)</color>", task_target.name, color, self.data.count, target_count)
        end
        local pos = SceneConfigManager:GetInstance():GetNpcPosition(target_scene_id, target_id)
        if pos then
            target_pos = pos
        end


        -- 副本
    elseif goal_type == enum.EVENT.EVENT_DUNGE or goal_type == enum.EVENT.EVENT_DUNGE_ENTER or goal_type == enum.EVENT.EVENT_DUNGE_FLOOR then
        --content_str = string.format("<color=#fffefe>%s</color>",self.config.desc)
        local dunongeId = TaskModel:GetInstance():GetGoalValue(cur_goal[6],"dunge")
        local name = enumName.SCENE_STYPE[target_id]
        if dunongeId then
            local cf = Config.db_dunge[dunongeId]
            if cf then
                name = cf.name
            end
        elseif DungeonModel:GetInstance():CheckIsDailyOrNoviceDungeon(target_id) then
            local cf = Config.db_scene[target_scene_id]
            if cf then
                name = cf.name
            end
        end
        local count = target_count
        if goal_type == enum.EVENT.EVENT_DUNGE_FLOOR then
            count = TaskModel:GetInstance():GetGoalValue(cur_goal[6],"floor") or target_count
        end
        if count <= 0 or goal_type ~= enum.EVENT.EVENT_DUNGE_FLOOR then
            content_str = string.format("Clear <color=#53f057>%s</color>", name)
        else

            local color = "e63232"
            local show_count = self.data.count
            if self.data.count >= count then
                color = "53f057"
                show_count = count
            end
            content_str = string.format("Clear <color=#53f057>Stage %s %s</color>", name, ChineseNumber(count))
            -- content_str = string.format("通关<color=#53f057>%s</color>(<color=#%s>%s</color>/%s)", name,color,show_count,count)
        end

        -- 采集
    elseif goal_type == enum.EVENT.EVENT_COLLECT then
        local task_target = Config.db_creep[target_id]
        if task_target then
            local color = "e63232"
            if self.data.count >= target_count then
                color = "53f057"
            end
            content_str = string.format("<color=#fffefe>Collect <color=#53f057>%s</color> (<color=#%s>%s</color>/%s)</color>", task_target.name, color, self.data.count, target_count)
        end
        local pos = SceneConfigManager:GetInstance():GetCreepPosition(target_scene_id, target_id)
        if pos then
            target_pos = pos
        end
        --收集道具
    elseif goal_type == enum.EVENT.EVENT_ITEM then
        local task_target = Config.db_item[target_id]
        if task_target then
            local color = "e63232"
            if self.data.count >= target_count then
                color = "53f057"
            end
            content_str = string.format("Collect %s(<color=#%s>%s</color>/%s)", ColorUtil.GetHtmlStr(task_target.color, task_target.name), color, self.data.count, target_count)
        end
        -- 装备
    elseif goal_type == enum.EVENT.EVENT_EQUIP then
        -- content_str = "升级装备"
        content_str = string.format("<color=#fffefe>%s</color>", self.config.desc)
    else
        content_str = string.format("<color=#fffefe>%s</color>", self.config.desc)
    end

    local name_color = ""
    if self.config.type == enum.TASK_TYPE.TASK_TYPE_MAIN then
        --主线
        if self.data.state == enum.TASK_STATE.TASK_STATE_COMING then
            -- content_str = string.format("等级%s可以接",self.config.minlv)
            local lv, is_under_top = GetLevelShow(self.config.minlv)
            local str = "Can be accepted at Lv.%s"
            if not is_under_top then
                str = "Can be accepted at Lv.%s"
            end
            content_str = ColorUtil.GetHtmlStr(ColorUtil.ColorType.Red, string.format(str, lv))
        end
    elseif self.config.type == enum.TASK_TYPE.TASK_TYPE_SIDE then
        --支线

    elseif self.config.type == enum.TASK_TYPE.TASK_TYPE_REIN then
        --转生

    elseif self.config.type == enum.TASK_TYPE.TASK_TYPE_TIME then
        --限时
        local cur_time = os.time()
        local str = TimeManager:GetInstance():GetLastTimeStr(cur_time, self.data.etime)
        if cur_time >= self.data.etime then
            str = "Quest ended"
            self:StopTime()
        end
        content_str = string.format("%s\n%s", str, content_str)
    elseif self.config.type == enum.TASK_TYPE.TASK_TYPE_DAILY then
        --日常

    elseif self.config.type == enum.TASK_TYPE.TASK_TYPE_GUILD then
        --公会

    end

    self.target_scene_id = target_scene_id
    self.target_pos = target_pos
    self.task_content_component.text = content_str
    -- local y = self.start_y + ((self.task_content_component.preferredHeight/self.font_size) - 1) * 13
    -- SetLocalPositionY(self.task_content,y)
end

function MainTaskItem:PlayEffect()
    -- if not self.effect then
    -- 	local effect = UIEffect(self.transform, "effect_ui_renwulan", false, self.layer)
    --     effect:SetConfig({is_loop = true})
    --     effect:SetPosition(70,-10)
    --     self.effect = effect
    -- end
end

function MainTaskItem:SetIcon(taskCfg)
    local gainTbl = String2Table(taskCfg.gain) or {}
    local count = ""
    for i, v in pairs(gainTbl) do
        if v[1] == taskCfg.show then
            count = v[2] .. ""
        end
    end
    local x = -48
    if taskCfg.jump == 1 then
        if self.icon_settor then
            self.icon_settor:SetVisible(false)
        end
        SetVisible(self.img_fly_icon, true)
    elseif taskCfg.show ~=0 and Config.db_item[taskCfg.show] ~= nil then
        if not self.icon_settor then
            self.icon_settor = GoodsIconSettorTwo(self.iconContain)
            self.icon_settor:UpdateSize(54)
        end
        self.icon_settor:SetData(taskCfg.show, count)
        self.icon_settor:SetVisible(true)
        SetVisible(self.img_fly_icon, false)
    else
        if self.icon_settor then
            self.icon_settor:SetVisible(false)
        end
        SetVisible(self.img_fly_icon, false)
        x = -95
    end

    SetLocalPositionX(self.task_name, x)
    SetLocalPositionX(self.task_content, x)
end
function MainTaskItem:StopTime()
    if self.time_id then
        GlobalSchedule:Stop(self.time_id)
    end
end