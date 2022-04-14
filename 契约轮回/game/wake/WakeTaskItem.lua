WakeTaskItem = WakeTaskItem or class("WakeTaskItem",BaseItem)
local WakeTaskItem = WakeTaskItem

function WakeTaskItem:ctor(parent_node,layer)
	self.abName = "wake"
	self.assetName = "WakeTaskItem"
	self.layer = layer

	self.model = WakeModel:GetInstance()
	WakeTaskItem.super.Load(self)
end

function WakeTaskItem:dctor()
	if self.goodsitem then
		self.goodsitem:destroy()
		self.goodsitem = nil
	end
	if self.reddot then
		self.reddot:destroy()
		self.reddot = nil
	end
end

function WakeTaskItem:LoadCallBack()
	self.nodes = {
		"title", "icon", "btngoto", "finished","btnreward","desc",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()

	--self.progress = GetText(self.progress)
	self.title = GetText(self.title)
	--self.icon = GetImage(self.icon)
	--self.Scrollbar = self.Scrollbar:GetComponent('Scrollbar')
	self.desc = GetText(self.desc)

	self:UpdateView()
end

function WakeTaskItem:AddEvent()

	local function call_back(target,x,y)
		TaskModel:GetInstance():DoTask(self.id)
		self.model:Brocast(WakeEvent.DoTask)
	end
	AddClickEvent(self.btngoto.gameObject,call_back)

	local function call_back(target,x,y)
		TaskController:GetInstance():RequestTaskSubmit(self.id)
	end
	AddClickEvent(self.btnreward.gameObject,call_back)
end

function WakeTaskItem:SetData(id, status)
	self.id = id
	self.status = status
	if self.is_loaded then
		self:UpdateView()
	end
end

function WakeTaskItem:UpdateView()
	local task = Config.db_task[self.id]
	local task_title = task.name
	local goals = String2Table(task.goals)[1]
	local total_count = (goals[3]==0 and 1 or goals[3])
	local count_str = ""
	if self.model:GetTaskStatus(self.id) == 1 then
		--self.progress.text = total_count .. "/" .. total_count
		task_title = task_title
		count_str = "(" .. total_count .. "/" .. total_count .. ")"
		--self.Scrollbar.size = 1
		SetVisible(self.btngoto, false)
		SetVisible(self.finished, true)
		SetVisible(self.btnreward, false)
	else
		local role_task = TaskModel:GetInstance():GetTask(self.id)
		--if not role_task then return end
		if not role_task then
			task_title = task_title .. string.format("(Can be accepted at Lv.%s)", task.minlv)
			SetVisible(self.btngoto, false)
			SetVisible(self.finished, false)
			SetVisible(self.btnreward, false)
		elseif role_task.state == enum.TASK_STATE.TASK_STATE_FINISH then
			--self.progress.text = total_count .. "/" .. total_count
			task_title = task_title
			count_str = "<color=#3ab60e>(" .. total_count .. "/" .. total_count .. ")</color>"
			--self.Scrollbar.size = 1
			SetVisible(self.btngoto, false)
			SetVisible(self.finished, false)
			SetVisible(self.btnreward, true)
			if not self.reddot then
				self.reddot = RedDot(self.btnreward)
				SetLocalPosition(self.reddot.transform, 35, 14)
			end
			SetVisible(self.reddot, true)
		else
			--self.progress.text = role_task.count .. "/" .. total_count
			task_title = task_title
			count_str = "<color=#eb0000>(" .. role_task.count .. "/" .. total_count .. ")</color>"
			--self.Scrollbar.size = role_task.count/total_count
			SetVisible(self.btngoto, true)
			SetVisible(self.finished, false)
			SetVisible(self.btnreward, false)
		end
	end
	--self.desc.text = task.desc
	self:SetContent(task, count_str)
	self.title.text = task_title
	--[[local item = Config.db_wake_task_icon[self.id]
	if item.icon ~= "" then
		local res_tab = IconConfig[item.icon]
		res_tab = string.split(res_tab, ":")
	    local abName = res_tab[1]
	    local assetName = res_tab[2]
		lua_resMgr:SetImageTexture(self,self.icon, abName, assetName,true)
	elseif item.pic ~= "" then
		lua_resMgr:SetImageTexture(self,self.icon, "wake_image", item.pic,true)
	end--]]
	local gain = String2Table(task.gain)[1]
	if not self.goodsitem then
		self.goodsitem = GoodsIconSettorTwo(self.icon)
	end
	local param = {}
	param["item_id"] = gain[1]
	param["num"] = gain[2]
	param["bind"] = gain[3]
	param["can_click"] = true
	self.goodsitem:SetIcon(param)
end

function WakeTaskItem:SetContent(task, count_str)
    local cur_goal = String2Table(task.goals)[1]
    local content_str = ""
    local goal_type = cur_goal[1]
    local target_id = cur_goal[2]
    local target_count = cur_goal[3]
    local target_scene_id = cur_goal[4]
    local target_pos = nil
    -- 对话任务
    if goal_type == enum.EVENT.EVENT_TALK then
        local task_target = Config.db_npc[target_id]
        if task_target then
            content_str = string.format("Talk with <color=#248a00>%s</color>", task_target.name)
        end
        -- 打怪
    elseif goal_type == enum.EVENT.EVENT_CREEP then
        local task_target = Config.db_creep[target_id]
        if task_target then
            content_str = string.format("Defeat <color=#248a00>%s</color>", task_target.name)
        end
        -- 副本
    elseif goal_type == enum.EVENT.EVENT_DUNGE or goal_type == enum.EVENT.EVENT_DUNGE_ENTER or goal_type == enum.EVENT.EVENT_DUNGE_FLOOR then
        local name = enumName.SCENE_STYPE[target_id]
        if DungeonModel:GetInstance():CheckIsDailyOrNoviceDungeon(target_id) then
            local cf = Config.db_scene[target_scene_id]
            if cf then
                name = cf.name
            end
        end
        if target_count <= 0 then
            content_str = string.format("Clear<color=#248a00>%s</color>", name)
        else
            content_str = string.format("Clear<color=#248a00>%s stage%s</color>", name, ChineseNumber(target_count))
        end
        if goal_type == enum.EVENT.EVENT_DUNGE_FLOOR then
        	local floors = cur_goal[6]
        	local floor = 0
        	for _, v in pairs(floors) do
        		if v[1] == "floor" then
        			floor = v[2]
        		end
        	end
        	if floor > 0 then
        		content_str = string.format("Clear<color=#248a00>%s stage%s</color>", name, ChineseNumber(floor))
        	end
        end
        if target_id == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_PET then
        	local dungename = Config.db_dunge[target_scene_id].name
        	content_str = string.format("Clear<color=#248a00>%s%s</color>", name, dungename)
        end
        -- 采集
    elseif goal_type == enum.EVENT.EVENT_COLLECT then
        local task_target = Config.db_creep[target_id]
        if task_target then
            content_str = string.format("Collect<color=#248a00>%s</color>", task_target.name)
        end
    elseif goal_type == enum.EVENT.EVENT_ITEM then
    	local task_target = Config.db_item[target_id]
        if task_target then
            content_str = string.format("Collect %s", ColorUtil.GetHtmlStr(task_target.color, task_target.name))
        end
        -- 装备
    elseif goal_type == enum.EVENT.EVENT_EQUIP then
        content_str = task.desc
    else
        content_str = task.desc
    end

    self.desc.text = content_str .. count_str
end