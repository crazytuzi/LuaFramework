Door = BaseClass(Thing)


function Door:__init( vo )
	self.type = PuppetVo.Type.Door
	self:SetVo(vo)
	self.view = SceneController:GetInstance():GetScene()
	self.frame = 1
	self.isEnter = false
	self.handler=GlobalDispatcher:AddEventListener(EventName.MAINROLE_STOPWALK, function ()
		local scene = self.view -- 自动战斗时，不给传送
		if scene then
			local autoFight = scene:GetAutoFightCtr()
			if autoFight:IsAutoFighting() then
				return
			end
		end
		self:OnRoleStop()
	end)
end

function Door:OnRoleStop()
	local delay = 0.3 -- 延迟传送
	if not self.view then return end
	if self.view:GetMainPlayer() == nil then return end
	local player = self.view:GetMainPlayer()
	local pos = Vector3.DistanceEx(player:GetPosition(),self.vo.position)
	--到达传送门 
	if pos <= 2 then
		if self.isEnter == false then 
			self.isEnter = true
			if self.vo.toScene == 321 then
				-- FBController:GetInstance():OpenFBPanel()
			else
				local function callback()
					self:GetWayByType(self.vo.mode)
				end
				local scene = self.view
				if scene:GetMainPlayer() then
					scene:GetMainPlayer().autoFight:Stop()
					RenderMgr.CreateCoTimer(callback, delay, 1, "Door_delay"..tostring(self))
				end
			end
		else
			if self.vo.toScene == 321 then
				-- FBController:GetInstance():OpenFBPanel()
			end
		end
	else
		self.isEnter = false
	end
end

function Door:SetVo(vo)
	Thing.SetVo(self, vo)
	self.effectId = EffectMgr.AddToPos( "chuansong", vo.position, nil, nil, nil, nil, function (id)
		self:SetGameObject(EffectMgr.GetEffectById(id))
	end)
end
function Door:SetGameObject( gameObject )
	if not gameObject then return end
	Thing.SetGameObject(self, gameObject)
	
end

function Door:GetWayByType( pType )
	if pType == self.vo.mode then --定点传送 --入侵传送
		local mainPlayer = SceneModel:GetInstance():GetMainPlayer()
		if not mainPlayer.die then
			SceneController:GetInstance():C_EnterScene(self.vo.toScene,self.vo.eid)
		end
	end
end

-- 清理
function Door:__delete()
	RenderMgr.Realse("Door_delay"..tostring(self))
	if self.vo then
		self.vo:Destroy()
	end
	GlobalDispatcher:RemoveEventListener(self.handler)
	EffectMgr.RealseEffect(self.effectId)
	self.vo = nil
end
