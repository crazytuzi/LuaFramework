GuideItem2 = GuideItem2 or class("GuideItem2",BaseItem)
local GuideItem2 = GuideItem2

function GuideItem2:ctor(parent_node,layer)
	self.abName = "guide"
	self.assetName = "GuideItem2"
	self.layer = layer
	if parent_node.parent:Find("layer/Top") then
		self.layer = "Top"
	end
	self.model = GuideModel:GetInstance()
	GuideItem2.super.Load(self)
	self.ps = {}
	self.clicked = false
	self.pos_x = 0
	self.pos_y = 0
	self.events = {}
end

function GuideItem2:dctor()
	if self.events then
		GlobalEvent:RemoveTabListener(self.events)
		self.events = nil
	end
	if self.schedule_id then
		GlobalSchedule:Stop(self.schedule_id)
	end
	if self.schedule_id2 then
		GlobalSchedule:Stop(self.schedule_id2)
	end
	if self.button_effect then
		self.button_effect:destroy()
		self.button_effect = nil
	end
	if self.npc_model then
		self.npc_model:destroy()
		self.npc_model = nil
	end
	self.ps = nil
	if self.wawa_com then
		self.wawa_com.texture = nil
	end
	if self.wawa2_com then
		self.wawa2_com.texture = nil
	end
	if self.Camera_com then
		self.Camera_com.targetTexture = nil
	end
	if self.Camera2_com then
		self.Camera2_com.targetTexture = nil
	end
	if self.render_texture then
		ReleseRenderTexture(self.render_texture)
		self.render_texture = nil
	end
end

function GuideItem2:LoadCallBack()
	self.nodes = {
		"bg/content","bg/tip","p1","p2","p3","p4","p5","p6","p7","p8",
		"bg2/content2","bg2/tip2", "bg", "bg2", "bg/wawa", "bg2/wawa2",
		"bg/wawa/Camera","bg2/wawa2/Camera2",
	}
	self:GetChildren(self.nodes)
	self.content = GetText(self.content)
	self.tip = GetText(self.tip)
	self.content2 = GetText(self.content2)
	self.tip2 = GetText(self.tip2)
	self.ps[1] = self.p1
	self.ps[2] = self.p2
	self.ps[3] = self.p3
	self.ps[4] = self.p4
	self.ps[5] = self.p5
	self.ps[6] = self.p6
	self.ps[7] = self.p7
	self.ps[8] = self.p8
	self:AddEvent()
	self.render_texture = CreateRenderTexture()
	self.wawa_com = self.wawa:GetComponent("RawImage")
	self.wawa2_com = self.wawa2:GetComponent("RawImage")
	self.Camera_com = self.Camera:GetComponent("Camera")
	self.Camera2_com = self.Camera2:GetComponent("Camera")
	self.wawa_com.texture = self.render_texture
	self.wawa2_com.texture = self.render_texture
	self.Camera_com.targetTexture = self.render_texture
	self.Camera2_com.targetTexture = self.render_texture
	self:UpdateView()
	self:SetOrderByParentMax()
	if self.model.step_index == 1 then
		SoundManager.GetInstance():PlayById(50)
	end
end

function GuideItem2:AddEvent()
	local function call_back(target)
		if (self.click_node == target.transform or self.data.is_clear==1) and not self.clicked  then
			self.clicked = true
			self.model.step_index = self.model.step_index + 1
			GuideController:GetInstance():NextStep(self.data.delay)
		end
		GuideController:GetInstance():ClearStrongGuide()
	end
	self.events[#self.events+1] = GlobalEvent:AddListener(GuideEvent.OnClick, call_back)

	local function call_back(sceneid)
		local scenecfg = Config.db_scene[sceneid]
		local scene_type = String2Table(self.data.scene_type)
		if not table.isempty(scene_type) then
			if not table.containValue(scene_type, scenecfg.type) then
				self.model.step_index = self.model.step_index + 1
				GuideController:GetInstance():NextStep(self.data.delay)
			end
		end
	end
	self.events[#self.events+1] = GlobalEvent:AddListener(EventName.EndHandleTimeline, call_back)
end

--data:guide_step
function GuideItem2:SetData(data, node)
	self.data = data
	self.node = node
	if self.is_loaded then
		self:UpdateView()
	end
end

function GuideItem2:UpdateView()
	local res_type = tonumber(self.data.res_type)
	local _, order = GetParentOrderIndex(self.transform)
	for i=1, 8 do
		SetVisible(self.ps[i], i==res_type)
		if i==res_type then
			local effect = self.ps[i].transform:Find("effect_ui_jiantou")
			UIDepth.SetOrderIndex(effect.gameObject, false, order+1)
		end
	end
	if (res_type>=1 and res_type<=4) or res_type == 8 then
		SetVisible(self.bg, true)
		SetVisible(self.bg2, false)
		self.npc_model = UIModelManager.GetInstance():InitModel(enum.MODEL_TYPE.MODEL_TYPE_NPC, "model_NPC_61001", self.wawa, handler(self,self.LoadModelCallBack))
	else
		SetVisible(self.bg, false)
		SetVisible(self.bg2, true)
		self.npc_model = UIModelManager.GetInstance():InitModel(enum.MODEL_TYPE.MODEL_TYPE_NPC, "model_NPC_61001", self.wawa2, handler(self,self.LoadModelCallBack))
	end
	self.content.text = self.data.content
	self.content2.text = self.data.content
	self.click_node = self.node
	if self.data.click_child ~= "" then
		--self.click_node = self.node:GetChild(self.data.click_child_index-1)
		self.click_node = self.node.transform:Find(self.data.click_child)
	end
	--自动倒计时，点击
	if self.data.auto_click == 1 then
		SetVisible(self.tip, true)
		SetVisible(self.tip2, true)
		self.second = self.data.sec
		local message = "（Auto continue in <color=#ffcc00>%d Sec</color> later）"
		self.tip.text = string.format(message, self.second)
		self.tip2.text = string.format(message, self.second)
		local function count()
			self.second = self.second - 1
			self.tip.text = string.format(message, self.second)
			self.tip2.text = string.format(message, self.second)
			if IsGameObjectNull(self.click_node) then
				self.model.step_index = self.model.step_index + 1
				GuideController:GetInstance():NextStep(self.data.delay)
			end
			if self.second == 0 then
				GlobalSchedule:Stop(self.schedule_id)
				TargetClickCall(self.click_node.gameObject)
			end
		end
		self.schedule_id = GlobalSchedule:Start(count, 1.0)
	else
		SetVisible(self.tip, false)
		SetVisible(self.tip2, false)
	end
	local off_set = String2Table(self.data.off_set)
	local x,y = GetLocalPosition(self.node.transform)
	local p_x, p_y = GetLocalPosition(self.node.transform.parent)
	local pos_x = x+p_x+(off_set[1] or 0)
	local pos_y = y+p_y+(off_set[2] or 0)
	SetLocalPosition(self.transform, pos_x, pos_y, 0)
	local function SetPos()
		x, y = GetLocalPosition(self.node.transform)
		p_x, p_y = GetLocalPosition(self.node.transform.parent)
		pos_x = x+p_x+(off_set[1] or 0)
		pos_y = y+p_y+(off_set[2] or 0)
		if pos_x ~= self.pos_x or pos_y ~= self.pos_y then
			SetLocalPosition(self.transform, pos_x, pos_y, 0)
			self.pos_x = pos_x
			self.pos_y = pos_y
		end
	end
	self.pos_x = pos_x
	self.pos_y = pos_y
	self.schedule_id2 = GlobalSchedule:Start(SetPos, 0.5)
	TaskModel:GetInstance():PauseTask()
	if self.data.button_effect==1 then
		self.button_effect = GuideButton(self.node, "top")
	end

	--缩放
	if self.data.scale then
		SetLocalScale(self.transform,self.data.scale,self.data.scale,1)
	end
end

function GuideItem2:LoadModelCallBack( )
	SetLocalRotation(self.npc_model.transform,0,180,0)
    SetLocalPosition(self.npc_model.transform,4000,-92,147)
end
