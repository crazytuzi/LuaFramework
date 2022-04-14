TeamMenuItem = TeamMenuItem or class("TeamMenuItem",BaseItem)
local TeamMenuItem = TeamMenuItem

function TeamMenuItem:ctor(parent_node,layer)
	self.abName = "team"
	self.assetName = "TeamMenuItem"
	self.layer = layer

	self.model = TeamModel:GetInstance()
	TeamMenuItem.super.Load(self)
end

function TeamMenuItem:dctor()
	if self.background then
		if not poolMgr:AddGameObject("system","EmptyImage",self.background) then
            destroy(self.background)
        end
        self.background = nil
    end
end

function TeamMenuItem:LoadCallBack()
	self.nodes = {
		"bg/kickout",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
	self:AddBackGroud()
	self:SetViewPosition()
end

function TeamMenuItem:AddEvent()
	local function call_back(target,x,y)
		local main_role_id = RoleInfoModel:GetInstance():GetMainRoleId()
		if self.model:IsCaptain(main_role_id) then
			TeamController:GetInstance():RequestKickout(self.data.role_id)
			self:Close()
		end
	end
	AddClickEvent(self.kickout.gameObject,call_back)
end

function TeamMenuItem:SetData(data)
	self.data = data
end

function TeamMenuItem:AddBackGroud()
	self.background = PreloadManager:GetInstance():CreateWidget("system","EmptyImage")
	self.background_transform = self.background.transform
	self.background_transform:SetParent(self.transform)
	self.background_transform:SetAsFirstSibling()
	self.background_img = self.background_transform:GetComponent('Image')
	SetSizeDelta(self.background_transform,3000,3000)
	SetColor(self.background_img,0.1,0.1,0.1,1)
	SetLocalPosition(self.background_img.transform,0,0,0)

	local function call_back()
		self:destroy()
	end

	AddClickEvent(self.background_transform.gameObject,call_back)
end

function TeamMenuItem:SetViewPosition()
	local UITransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.UI)
	self.transform:SetParent(UITransform)
	SetLocalPositionXY(self.transform, -(ScreenWidth / 2)+418, ScreenHeight / 2 - 243)
end