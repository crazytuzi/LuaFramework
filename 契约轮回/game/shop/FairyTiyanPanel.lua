FairyTiyanPanel = FairyTiyanPanel or class("FairyTiyanPanel",BasePanel)
local FairyTiyanPanel = FairyTiyanPanel


local fairy_id = 11020147

function FairyTiyanPanel:ctor()
	self.abName = "shop"
	self.assetName = "FairyTiyanPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true

	--self.model = 2222222222222end:GetInstance()
end

function FairyTiyanPanel:dctor()
end

function FairyTiyanPanel:Open( )
	FairyTiyanPanel.super.Open(self)
end

function FairyTiyanPanel:LoadCallBack()
	self.nodes = {
		"myspirite","btn_ok","btn_close","myspirite/Camera",
	}
	self:GetChildren(self.nodes)
	self.render_texture = CreateRenderTexture()
	self.myspirite_com = self.myspirite:GetComponent("RawImage")
	self.Camera_com = self.Camera:GetComponent("Camera")
	self.myspirite_com.texture = self.render_texture
	self.Camera_com.targetTexture = self.render_texture
	self:AddEvent()

	local function call_back()
		self:UseFairy()
		self:Close()
	end
	GlobalSchedule:StartOnce(call_back, 10)
	self.effect = UIEffect(self.btn_ok, 10121)
end

function FairyTiyanPanel:AddEvent()

	local function call_back(target,x,y)
		self:UseFairy()
		self:Close()
	end
	AddClickEvent(self.btn_ok.gameObject,call_back)

	local function call_back(target,x,y)
		self:UseFairy()
		self:Close()
	end
	AddClickEvent(self.btn_close.gameObject,call_back)
end

function FairyTiyanPanel:OpenCallBack()
	self:UpdateView()
end

function FairyTiyanPanel:UpdateView( )
	local model_id = Config.db_fairy[fairy_id].resource
	self.monster_model = UIFairyModel(self.myspirite, model_id, handler(self,self.HandleCreepLoaded))
end

function FairyTiyanPanel:HandleCreepLoaded( ... )
	SetLocalRotation(self.monster_model.transform,0,173,0)
    SetLocalPosition(self.monster_model.transform,2152,-129,227)
end

function FairyTiyanPanel:CloseCallBack(  )
	if self.monster_model then
		self.monster_model:destroy()
	end
	if self.myspirite_com then
		self.myspirite_com.texture = nil
	end
	if self.Camera_com then
		self.Camera_com.targetTexture = nil
	end
	if self.render_texture then
		ReleseRenderTexture(self.render_texture)
		self.render_texture = nil
	end
	if self.effect then
		self.effect:destroy()
		self.effect = nil
	end
end

function FairyTiyanPanel:UseFairy()
	local uid = BagModel:GetInstance():GetUidByItemID(fairy_id)
	if uid then
		EquipController:GetInstance():RequestPutOnEquip(uid)
	else
		--Notify.ShowText("没有精灵")
	end
end