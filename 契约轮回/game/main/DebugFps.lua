--
-- @Author: LaoY
-- @Date:   2019-02-13 17:57:18
--

DebugFps = DebugFps or class("DebugFps",BasePanel)

function DebugFps:ctor()
	self.abName = "main"
	self.assetName = "DebugFps"
	self.layer = "Top"

	self.use_background = false
	self.change_scene_close = true
	self.use_open_sound = false
	
	self.targetFrameRate = Application.targetFrameRate

	self.frameCount = 0
	self.deltaTime = 0
	
	--DEBUG信息 不用屏蔽
	if self.open_login_scene_event_id then
		GlobalEvent:RemoveListener(self.open_login_scene_event_id)
		self.open_login_scene_event_id = nil
	end
end

function DebugFps:dctor()
	self:StopTime()
	UpdateBeat:Remove(self.Update)
end

function DebugFps:Open( )
	DebugFps.super.Open(self)
end

function DebugFps:LoadCallBack()
	self.nodes = {
		"text","con","con/btn_out","con/btn_show","con/btn_out/btn_out_text","con/btn_show/btn_show_text",
	}
	self:GetChildren(self.nodes)

	self.text_component = self.text:GetComponent('Text')
	self.btn_out_text_component = self.btn_out_text:GetComponent('Text')
	self.btn_show_text_component = self.btn_show_text:GetComponent('Text')

	if AppConfig.DebugRef then
		self.btn_out_text_component.text = "Export quote"
		self.btn_show_text_component.text = "GC"
	else
		self.btn_out_text_component.text = "Export packs"
		self.btn_show_text_component.text = "Print packs"
	end

	SetAlignType(self.transform, bit.bor(AlignType.Left, AlignType.Bottom))

	self:AddEvent()

	self:SetConVisible(false)
	UpdateBeat:Add(self.Update,self,1,1)
end

function DebugFps:AddEvent()
	local function call_back(target,x,y)
		self:SetConVisible(not self.con_visible)
	end
	AddClickEvent(self.text.gameObject,call_back)

	local function call_back(target,x,y)
		if AppConfig.DebugRef then
			DebugManager:DebugObjectRef()
		else
			resMgr:OutPutFilterFileList()
			Notify.ShowText("Exported")
		end
	end
	AddClickEvent(self.btn_out.gameObject,call_back)

	local function call_back(target,x,y)
		if AppConfig.DebugRef then
			DebugManager:GC()
		else
			DebugManager:GetInstance():DebugFilterAll()
		end
	end
	AddClickEvent(self.btn_show.gameObject,call_back)
end

function DebugFps:SetConVisible(flag)
	flag = toBool(flag)
	if self.con_visible == flag then
		return
	end
	self.con_visible = flag
	SetVisible(self.con,self.con_visible)
end

function DebugFps:OpenCallBack()
	self:UpdateView()
end

function DebugFps:UpdateView( )
end

function DebugFps:Update(deltaTime)
	self.frameCount = self.frameCount + 1
	self.deltaTime = self.deltaTime + deltaTime
	if self.deltaTime > 0.3 then
		local str = string.format("FPS:<color=#%s>%.2f</color>/%s,LuaM：%s",ColorUtil.GetColor(ColorUtil.ColorType.WhiteYellow),self.frameCount/self.deltaTime,Application.targetFrameRate,GetLuaMemory())
		self.text_component.text = str
		self.frameCount = 0
		self.deltaTime = 0
	end
end

function DebugFps:StartTime()
	self:StopTime()
	local function step()

		-- local str = string.format("FPS:<color=#%s>%.2f</color>/%s",ColorUtil.GetColor(ColorUtil.ColorType.WhiteYellow),Time.frameCount/Time.time,self.targetFrameRate)
	end
	self.time_id = GlobalSchedule:Start(step,0.1)
end

function DebugFps:StopTime()
	if self.time_id then
		GlobalSchedule:Stop(self.time_id)
		self.time_id = nil
	end
end

function DebugFps:CloseCallBack(  )

end