require("systool/priority_queue")

RenderBudget = RenderBudget or BaseClass()

function RenderBudget:__init()
	if RenderBudget.Instance then
		print_error("[RenderBudget] Attempt to create singleton twice!")
		return
	end
	self.budget = 6000
	self.cur_budget = 0
	RenderBudget.Instance = self
	self.payloads = QualityBudget(6000)
	self.render_budget_cfg = ConfigManager.Instance:GetAutoConfig("render_budget_auto")
end

function RenderBudget:__delete()
	RenderBudget.Instance = nil
end

function RenderBudget:SetBudgetByFps(fps)
	-- local budget = 0
	-- for i,v in ipairs(self.render_budget_cfg.budget_cfg) do
	-- 	if fps >= v.min_fps then
	-- 		budget = v.budget
	-- 	end
	-- end
	-- if self.budget ~= budget then
	-- 	self.budget = budget
	-- 	self.payloads:SetBudget(budget)
	-- end
end

function RenderBudget:SetBudget(value)
	-- self.payloads:SetBudget(value)
end

function RenderBudget:AddPayload(obj_type, part, enable, disable)
	-- if obj_type == 0 then return end
	-- local payload, priority = self:GetObjPayloadAndPriority(obj_type, part)
	-- if payload and priority then
	-- 	self.cur_budget = self.cur_budget + payload
	-- 	return self.payloads:AddPayload(priority, payload, enable, disable)
	-- end
end

function RenderBudget:GetObjPayloadAndPriority(obj_type, part)
	-- for k,v in pairs(self.render_budget_cfg.payloads_cfg) do
	-- 	if v.obj_type == obj_type and v.part == part then
	-- 		return v.payload, v.priority
	-- 	end
 -- 	end
end

function RenderBudget:RemovePayload(handle)
	-- if handle then
	-- 	self.payloads:RemovePayload(handle)
	-- end
end


function RenderBudget:IsInBudget(fps)
	-- local budget = 0
	-- for i,v in ipairs(self.render_budget_cfg.budget_cfg) do
	-- 	if fps >= v.min_fps then
	-- 		budget = v.budget
	-- 	end
	-- end
 -- 	return self.budget == budget
end
