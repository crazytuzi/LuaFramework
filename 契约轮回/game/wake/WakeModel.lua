WakeModel = WakeModel or class("WakeModel",BaseBagModel)
local WakeModel = WakeModel

function WakeModel:ctor()
	WakeModel.Instance = self
	self:Reset()
end

function WakeModel:Reset()
	self.wake_items = {}
	self.tasks = {}
	self.grid_id = 0
	self.step = 0

end

function WakeModel.GetInstance()
	if WakeModel.Instance == nil then
		WakeModel()
	end
	return WakeModel.Instance
end

--获取本职业的觉醒数据
function WakeModel:GetWakeItems()
	if table.isempty(self.wake_items) then
		local career = RoleInfoModel:GetInstance():GetRoleValue("career")
		for k, v in pairs(Config.db_wake) do
			if v.career == career and v.wake_times>0 then
				v.id = k
				table.insert(self.wake_items, v)
			end
		end
		local function sort_f(a, b)
			return a.wake_times < b.wake_times
		end
		table.sort(self.wake_items, sort_f)
	end
	return self.wake_items
end


function WakeModel:SetWakeStep(step)
	self.step = step
end

function WakeModel:GetWakeStep()
	return self.step
end

function WakeModel:UpdateWakeTasks(tasks)
	for id, count in pairs(tasks) do
		self.tasks[id] = count
	end
end

function WakeModel:GetWakeTasks()
	return self.tasks
end

function WakeModel:GetTaskStatus(task_id)
	return self.tasks[task_id]
end

function WakeModel:UpdateWakeGrid(grid_id)
	self.grid_id = grid_id
end

--获取默认key
function WakeModel:GetWakeKey()
	local wake_times = RoleInfoModel:GetInstance():GetRoleValue("wake")
	local career = RoleInfoModel:GetInstance():GetRoleValue("career")
	local key = career .. "@" .. wake_times + 1
	return key
end

function WakeModel:GetWakeNowKey()
	local wake_times = RoleInfoModel:GetInstance():GetRoleValue("wake")
	local career = RoleInfoModel:GetInstance():GetRoleValue("career")
	local key = career .. "@" .. wake_times
	return key
end

function WakeModel:GetShowTaskNum()
	local wake = RoleInfoModel:GetInstance():GetRoleValue("wake") or 0
	local step = self.step
	local key = string.format("%s@%s", wake, step)
	local item = Config.db_wake_step[key]
	if not item then
		return 1
	else
		return item.num
	end
end

--是否有已接觉醒任务
function WakeModel:IsHaveWakeTask()
	local wake = RoleInfoModel:GetInstance():GetRoleValue("wake") or 0
	local step = self.step
	local key = string.format("%s@%s", wake+1, step)
	local item = Config.db_wake_step[key]
	local flag = true
	local has_task = false
	if item then
		local tasks = String2Table(item.tasks)
		for i=1, #tasks do
			local task_id = tasks[i]
			local status = self.tasks[task_id] or 0
			if flag and status ~= 1 then
				flag = false
			end
			local task = TaskModel.GetInstance():GetTask(task_id)
			if task and (task.state == enum.TASK_STATE.TASK_STATE_ACCEPT or 
			task.state == enum.TASK_STATE.TASK_STATE_FINISH) then
				has_task = true
			end
		end
	else
		flag = false
	end
	local all_task_finish = flag
	if all_task_finish or has_task then
		return true
	end
	return false
end

function  WakeModel:IsHaveWakeBigTask()
	local tab = {60029,60030,60031,60032}
	for i = 1, #tab do
		local taskId = tab[i]
		local task = TaskModel.GetInstance():GetTask(taskId)
		if task and task.state == enum.TASK_STATE.TASK_STATE_ACCEPT  then
			return true
		end
	end
	return false
end

--是否有变强
function WakeModel:IsCanStrong()
	local wake = RoleInfoModel:GetInstance():GetRoleValue("wake") or 0
    local level = RoleInfoModel:GetInstance():GetMainRoleLevel() or 0
    local career = RoleInfoModel:GetInstance():GetRoleValue("career") or 0
    local key = career .. "@" .. (wake + 1)
    local next_wake_item = Config.db_wake[key]
    local show_reddot = false
    if next_wake_item then
        local open_level = next_wake_item.open_level
        if level >= open_level and OpenTipModel.GetInstance():IsOpenSystem(600, 1) then
            if (wake < 3 and level >= next_wake_item.level and self:IsHaveWakeTask()) then
                show_reddot = true
            elseif wake == 3 or wake == 4 or wake == 5 then
            	if (wake == 3 and level >= 350) or (wake == 4 and level >= 500) or (wake == 5 and level >= 600)   then
	                local grid_id = self.grid_id
	                local next_grid_id = grid_id + 1
	                local wake_grid = Config.db_wake_grid[next_grid_id]
	                if wake_grid then
	                    local have_exp = RoleInfoModel:GetInstance():GetRoleValue("exp")
	                    local cost = String2Table(wake_grid.cost)[1]
	                    local item_id = cost[1]
	                    local item_num = cost[2]
	                    local item = Config.db_item[item_id]
	                    local have_num = BagController:GetInstance():GetItemListNum(item_id)
						local cost_exp = String2Table(wake_grid.cost_exp)
						if cost_exp and # cost_exp > 0 then
							cost_exp = cost_exp[1][2]
							if have_exp >= cost_exp or item_num <= have_num then
								show_reddot = true
							end
						else
							if item_num <= have_num then
								show_reddot = true
							end
						end
						
	                    
					end
					local wake5step = self:GetWakeStep2(5)
					local wake6step = self:GetWakeStep2(6)
					if  (wake == 3 and self.grid_id >= 12) 
						or (wake == 4 and wake5step == 1 and level >= 520  and self.grid_id == 27)  --五觉一阶段中 等级满足 激活完第一阶段最后一个格子 可以进行下一个阶段
						or (wake == 4 and wake5step == 2 and level >= 540  and self.grid_id == 47)	--五觉二阶段中 等级满足 激活完第二阶段最后一个格子 可以完成觉醒
						
						--六觉
						or (wake == 5 and wake6step == 1 and level >= 610  and self.grid_id == 72)  --可进入六觉二阶段
						or (wake == 5 and wake6step == 2 and level >= 620  and self.grid_id == 102) --可进入六觉三阶段
						or (wake == 5 and wake6step == 3 and level >= 630  and self.grid_id == 137) --可完成六觉
						then
	                    show_reddot = true
					end
					

	            end
            end
        end
    end
    return show_reddot
end

function WakeModel:IsMainHaveRedDot()
	local cur_step = self:GetWakeStep()
	local wake = RoleInfoModel:GetInstance():GetRoleValue("wake") or 0
	if wake >= 3 then
		return false
	end
	local key2 = wake+1 .. "@" .. cur_step
	local wakestep = Config.db_wake_step[key2]
	if wakestep then
		local step_task_ids = String2Table(wakestep.tasks)
		local tasks = self:GetWakeTasks()
		local flag = true
		for k, id in ipairs(step_task_ids) do
			local status = tasks[id] or 0
			local role_task = TaskModel:GetInstance():GetTask(id)
			if role_task and role_task.state == enum.TASK_STATE.TASK_STATE_FINISH then
				return true
			end
			if flag and status ~= 1 then
				flag = false
			end
		end
		return flag
	end
	return false
end

--设置五觉阶段
function WakeModel:SetWake5Step(step)
	self:SetWakeStep2(5,step)
end

--获取五觉阶段
function WakeModel:GetWake5Step()
	return  self:GetWakeStep2(5)
end

--设置觉醒阶段（五次觉醒后用）
function WakeModel:SetWakeStep2(count,step)
	local main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
	local wake_step_key = "wake".. count .."step_"..main_role_data.uid
	CacheManager.GetInstance():SetInt(wake_step_key,step)
end

--获取觉醒阶段（五次觉醒后用）
function WakeModel:GetWakeStep2(count)
	
	local main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
	local wake_step_key = "wake".. count .."step_"..main_role_data.uid

	local step = CacheManager.GetInstance():GetInt(wake_step_key,1)
	return step
end
