Npc =BaseClass(LivingThing)
local shixiang = "npc_shixiang"
function Npc:__init( vo )
	self.type = PuppetVo.Type.NPC
	self:SetVo(vo)
	self:InitEvent()
	self.animator = nil
	self.frame = 0
	self.randomNum = 0

end

function Npc:InitEvent()
end

function Npc:SetVo( vo )
	LivingThing.SetVo(self,vo)
end

function Npc:SetGameObject( go )
	if not go then return end
	self:NpcBehavior(go)
	LivingThing.SetGameObject(self, go)

	--self:InitHeadStateUI()
end
--更新npc切换动作和距离主角检测谈话
function Npc:Update()
	if not self.vo then return end
	--实时的检测
	local dt = Time.deltaTime
	self.frame = self.frame + dt
	if self.frame >= self.randomNum and self.animator then
		self.animator:Play("idle")
		self.frame = 0
	end
	LivingThing.Update(self, dt)
end

--生成随机参数
function Npc:TimeRandom(a,b )
	return math.random(a,b)*0.001
end

function Npc:NpcBehavior( go)
	local vo = self.vo
	if not vo then return end
	local animator = go:GetComponent("Animator")
	self.animator = animator
	self.randomNum = self:TimeRandom((vo.relaxTime[1]),(vo.relaxTime[2]))
	if self:IsShixiang() then
		self.changeBR = 3.6
		if vo.dressStyle == 1 then
			animator:Play("appear",0, 0.658)
		elseif vo.dressStyle == 2 then
			animator:Play("idle",0, 1)
		elseif vo.dressStyle == 3 then
			animator:Play("idle",0, 1)
		end
		animator.speed = 0
		destroyImmediate(go:GetComponent("NavMeshAgent"))
	end
end
function Npc:IsShixiang()
	return self.vo and self.vo.guid == shixiang
end

function Npc:InitHeadStateUI()
	if self.vo then
		local vo = self.vo
		if vo and vo.eid then
			if not TableIsEmpty(TaskModel:GetInstance():GetTaskListBySubmitNPC(vo.eid)) then
				self:SetHeadStateUI(2) --如果该npc有交付任务，则显示感叹号
			else
				self:SetHeadStateUI(0) --不显示任何状态
			end
		end
	end
end

function Npc:SetHeadStateUI(state)
	if state then
		ui = HeadUIMgr:GetInstance():Create(3, self)
		local isVisible = true
		if state == 0 then isVisible = false end
		ui:SetState(state)
		if ui then ui:Show(isVisible) end
	end
end
function Npc:__delete()
	self.animator = nil
end