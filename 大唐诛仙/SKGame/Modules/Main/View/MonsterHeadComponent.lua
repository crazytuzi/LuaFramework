MonsterHeadComponent =BaseClass(LuaUI)

function MonsterHeadComponent:__init( ... )
	self.URL = "ui://0042gnitgvm85g";
	self:__property(...)
	self:Config()
end

function MonsterHeadComponent:SetProperty( ... )
	 
end

function MonsterHeadComponent:Config()
	self.hp = 0
end

function MonsterHeadComponent:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Main","MonsterHeadComponent");

	self.buffList = self.ui:GetChild("buffList")
	self.bar = self.ui:GetChild("bar")
	self.progressLifeSlowly = self.ui:GetChild("progressLifeSlowly")
	self.progressLife = self.ui:GetChild("progressLife")
	self.name = self.ui:GetChild("name")
	self.buffDescPanel = self.ui:GetChild("buffDescPanel")
end

function MonsterHeadComponent:InitMonInfo( monVo )
	if monVo then
		self.guid = monVo.guid
		self.hp = monVo.hp or monVo.hpMax

		self.progressLife.value = monVo.hp or monVo.hpMax
		self.progressLife.max = monVo.hpMax

		self.progressLifeSlowly.value = monVo.hp or monVo.hpMax
		self.progressLifeSlowly.max = monVo.hpMax

		self.name.text = StringFormat("{0}(等级{1})", monVo.name, monVo.level)

		self:IniBuffContainer()
	end
end

function MonsterHeadComponent:IniBuffContainer()
	if self.buffUIManager then
		self.buffUIManager:Destroy()
		self.buffUIManager = nil
	end

	if not self.buffUIManager then
		self.buffUIManager = BuffUIManager.New(self.buffList, self.guid, self.buffDescPanel, false)
	end
end

function MonsterHeadComponent:RefreshMonInfo(monVo)
	if monVo then	
		self:ResetBossBuffUIManager(monVo.guid)
		self.name.text = StringFormat("{0}(等级{1})",monVo.name,monVo.level)
	
		if monVo.hp == monVo.hpMax then 
			self.progressLife.value = monVo.hpMax
			self.progressLifeSlowly.value = monVo.hpMax
		else
			local start1 = math.floor(self.hp)
			local end1 = math.floor(monVo.hp)
			if end1 < 0 then 
				end1 = 0 
			end

			if end1 <= 0 then
				if SceneModel:GetInstance().sceneId >= 2001 and SceneModel:GetInstance().sceneId <= 2009 then
					WorldMapModel:GetInstance().isRemoveBoss = true
				end
			end
			
			TweenUtils.TweenFloat(start1, end1, 0, function (value)
				if monVo.hp == 0 then
					value = 0
				end
				self.progressLife.value = value
			end)

			local start2 = self.hp
			local end2 = monVo.hp
			if end2 < 0 then end2 = 0 end
			TweenUtils.TweenFloat(start2, end2, 0.8, function (value)
				if monVo.hp == 0 then
					value = 0
				end
				self.progressLifeSlowly.value = value
			end)
		end
		self.progressLife.max = monVo.hpMax
		self.progressLifeSlowly.max = monVo.hpMax
	end
	self.hp = monVo.hp
end
function MonsterHeadComponent:ResetBossBuffUIManager(bossId)
	if self.bBuffUIManager and bossId ~= self.bBuffUIManager.holderId then
		self.bBuffUIManager:Destroy()
		self.bBuffUIManager = nil
	end
	if not self.bBuffUIManager then
		local holderId = bossId
	end
end

function MonsterHeadComponent.Create( ui, ...)
	return MonsterHeadComponent.New(ui, "#", {...})
end

function MonsterHeadComponent:__delete()
	if self.buffUIManager then
		self.buffUIManager:Destroy()
	end

	self.buffList = nil
	self.bar = nil
	self.progressLifeSlowly = nil
	self.progressLife = nil
	self.name = nil
	self.hp = 0
end