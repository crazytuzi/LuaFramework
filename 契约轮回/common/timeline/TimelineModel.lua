--
-- @Author: LaoY
-- @Date:   2019-12-06 16:50:36
--

--require("game.xx.xxx")

TimelineModel = TimelineModel or class("TimelineModel",Node)

function TimelineModel:ctor(abName,assetName)
	self.abName = abName
	self.assetName = assetName
	self.is_loaded = false

	self.global_position = nil
	self:Load()
end

function TimelineModel:dctor()
end

function TimelineModel:Load()
	local function call_back(objs)
		self:CreateObject(objs)
	end
	lua_resMgr:LoadPrefab(self,self.abName,self.assetName,call_back,nil, Constant.LoadResLevel.High)
end

function TimelineModel:CreateObject(objs)
	if self.is_dctored then
		return
	end
	local obj = objs[0]
	self.gameObject = newObject(obj)
    self.transform = self.gameObject.transform
    self.is_loaded = true

    local animator = self.gameObject:GetComponent("Animator")
	animator.cullingMode = UnityEngine.AnimatorCullingMode.AlwaysAnimate
	self.animator = animator


    if self.global_position ~= nil then
    	self:SetGlobalPosition(self.global_position.x,self.global_position.y,self.global_position.z)
    end

    if self.rotate ~= nil then
    	self:SetRotate(self.rotate.x,self.rotate.y,self.rotate.z)
    end

    if self.scale ~= nil then
    	self:SetLocalScale(self.scale.x,self.scale.y,self.scale.z)
    end

    if self.isVisible ~= nil then
    	self:SetVisible(self.isVisible)
    end
end

function TimelineModel:SetGlobalPosition(x,y,z)
	if not self.global_position then
		self.global_position = {x = x,y = y,z = z}
	else
		self.global_position.x = x
		self.global_position.y = y
		self.global_position.z = z
	end
	if self.is_loaded then
		SetGlobalPosition(self.transform,x,y,z)
	end
end

function TimelineModel:SetRotate(x,y,z)
	if not self.rotate then
		self.rotate = {x = x,y = y,z = z}
	else
		self.rotate.x = x
		self.rotate.y = y
		self.rotate.z = z
	end
	if self.is_loaded then
		SetRotation(self.transform,x,y,z)
	end
end

function TimelineModel:SetLocalScale(x,y,z)
	if not self.scale then
		self.scale = {x = x,y = y,z = z}
	else
		self.scale.x = x
		self.scale.y = y
		self.scale.z = z
	end
	if self.is_loaded then
		SetLocalScale(self.transform,x,y,z)
	end
end