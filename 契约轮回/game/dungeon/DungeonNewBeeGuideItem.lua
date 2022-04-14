DungeonNewBeeGuideItem = DungeonNewBeeGuideItem or class("DungeonNewBeeGuideItem",BaseItem)
local DungeonNewBeeGuideItem = DungeonNewBeeGuideItem

function DungeonNewBeeGuideItem:ctor(parent_node,layer)
	self.abName = "dungeon"
	self.assetName = "DungeonNewBeeGuideItem"
	self.layer = layer

	--self.model = 2222222222222end:GetInstance()
	DungeonNewBeeGuideItem.super.Load(self)
end

function DungeonNewBeeGuideItem:dctor()
	if self.schedule_id then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end
	if self.event_id then
		GlobalEvent:RemoveListener(self.event_id)
		self.event_id = nil
	end
	if self.npc_model then
		self.npc_model:destroy()
		self.npc_model = nil
	end
	self.click_node = nil
	self.call_back_func = nil
	if self.wawa_com then
		self.wawa_com.texture = nil
	end
	if self.Camera_com then
		self.Camera_com.targetTexture = nil
	end
	if self.render_texture then
		ReleseRenderTexture(self.render_texture)
		self.render_texture = nil
	end
end

function DungeonNewBeeGuideItem:LoadCallBack()
	self.nodes = {
		"bg/tip","bg/wawa","click_bg","p1","bg/wawa/Camera","bg","bg/content",
	}
	self:GetChildren(self.nodes)
	self.tip = GetText(self.tip)
	self.conTex = GetText(self.content)
	self.render_texture = CreateRenderTexture()
	self.wawa_com = self.wawa:GetComponent("RawImage")
	self.Camera_com = self.Camera:GetComponent("Camera")
	self.wawa_com.texture = self.render_texture
	self.Camera_com.targetTexture = self.render_texture
	self:AddEvent()

	self:UpdateView()
	if self.is_other then
		self:SetOtherPosition()
		self.conTex.text = self.str
	end
end

function DungeonNewBeeGuideItem:AddEvent()
	local function call_back(target)
		if self.click_node == target then
			self:destroy()
		end
	end
	self.event_id = GlobalEvent:AddListener(GuideEvent.OnClick, call_back)

	local function call_back(target,x,y)
		if self.call_back_func then
			self.call_back_func()
		end
		if self.is_other then
			self:destroy()
		end
	end
	AddClickEvent(self.click_bg.gameObject,call_back)
end


function DungeonNewBeeGuideItem:SetData(data, click_node, is_other, str,pos)
	self.call_back_func = data
	self.click_node = click_node
	self.is_other = is_other
	self.str = str or ""
	self.pos = pos
end

function DungeonNewBeeGuideItem:UpdateView()
	local second = 9
	local function call_back()
		second = second - 1
		self.tip.text = string.format("(Auto tapping in %s sec)", second)
		if second == 0 then
			if self.call_back_func then
				self.call_back_func()
			end
			GlobalSchedule:Stop(self.schedule_id)
			self.schedule_id = nil
			self:destroy()
		end
	end
	self.schedule_id = GlobalSchedule:Start(call_back, 1.0)
	if not self.npc_model then
		self.npc_model = UIModelManager.GetInstance():InitModel(enum.MODEL_TYPE.MODEL_TYPE_NPC, "model_NPC_61001", self.wawa, handler(self,self.LoadModelCallBack))
    end
    local top = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.Top)
    self.transform:SetParent(top)
    local effect = self.p1.transform:Find("effect_ui_jiantou")
	UIDepth.SetOrderIndex(effect.gameObject, false, 1002)
end

function DungeonNewBeeGuideItem:LoadModelCallBack( )
	SetLocalRotation(self.npc_model.transform,0,180,0)
    SetLocalPosition(self.npc_model.transform,5000,-92,147)
end

function DungeonNewBeeGuideItem:SetOtherPosition()
	SetLocalPositionY(self.bg,-150)
	SetLocalPositionY(self.p1,-75)
	SetLocalRotation(self.p1,0,0, -135)

	if self.pos then
		SetLocalPosition(self.transform,self.pos.x,self.pos.y,self.pos.z)
	end
end