--
-- @Author: LaoY
-- @Date:   2019-12-27 15:40:41
--

EvenKill = EvenKill or class("EvenKill",BasePanel)

function EvenKill:ctor()
	self.abName = "machinearmor_scene"
	self.assetName = "EvenKill"
	self.layer = LayerManager.LayerNameList.Bottom

	self.use_background = false
	self.change_scene_close = false
end

function EvenKill:dctor()
	self:StopAction()
	self.action = nil
	if self.global_event_list then
		GlobalEvent:RemoveTabListener(self.global_event_list)
		self.global_event_list = {}
	end
end

function EvenKill:Open( )
	EvenKill.super.Open(self)
end

function EvenKill:LoadCallBack()
	self.nodes = {
		"con/text_num",
	}
	self:GetChildren(self.nodes)
	self.text_num_component = self.text_num:GetComponent('Text')
	self.start_x,self.start_y = GetLocalPosition(self.text_num)
	SetAlignType(self.transform, bit.bor(AlignType.Bottom, AlignType.Right))

	self:AddEvent()
end

function EvenKill:AddEvent()
	local function call_back()
		self:UpdateView()
	end
	-- self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(SceneEvent.KILL_MONSTER, call_back)
end

function EvenKill:OpenCallBack()
	self:UpdateView()
end

function EvenKill:UpdateView()
	if not self.text_num then
		return
	end
	self.text_num_component.text = MainModel:GetInstance().mecha_morph_even_kill
	self:StartAction()
end

function EvenKill:StartAction()
	if self.action and not self.action:isDone() then
		return
	end
	local time_1 = 0.08
	local time_2 = 0.13
	local scale = 3.0
	local offset_x = scale * 30 + 40
	local action = cc.Spawn(cc.ScaleTo(time_1,3.0),cc.MoveTo(time_1,self.start_x + offset_x,self.start_y + 140))
	action = cc.Sequence(action,
		cc.Spawn(cc.ScaleTo(time_2,1),cc.MoveTo(time_2,self.start_x,self.start_y)))
	self.action = action
	cc.ActionManager:GetInstance():addAction(action,self.text_num)
end

function EvenKill:StopAction()
	cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.text_num)
end

function EvenKill:CloseCallBack()
end

function EvenKill:ClosePanel()
	self:Close()
end