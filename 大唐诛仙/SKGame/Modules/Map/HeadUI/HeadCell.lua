HeadCell = BaseClass(LuaUI)
function HeadCell:__init(type)
	self.type = type
	self.data = nil -- 承载信息
	self.follower = nil -- 跟踪的对象 transform
	self.gameObject = nil
	self.visible = false
	self.ui = FairyGUI.GComponent.New()
	self.hpBar = nil
	self.mpBar = nil
	self.headName = nil

	self.name = ""
	self.level = 0
	self.title = nil
	self.nameColorCode = 1
	self.namePos = Vector2.zero
	self.offY = 2
	self.rootOffY = 0
	self.rootOffX = 0
	self.teamIcon=nil
	self.stateSign=nil
	self.showState = false -- 控制怪物的headcell显示
	self.layerW = layerMgr.WIDTH
	self.layerH = layerMgr.HEIGHT
	self.sceneCtrl = SceneModel:GetInstance()
	self._objsCacheList = {}
	self:SetType(type)
end

function HeadCell:SetType(type)
	local offY = self.offY

	if type == 1 then
		self.hpBar = self:CreateUI(HpBar)
		self.mpBar = self:CreateUI(MpBar)
		self.headName = self:CreateUI(HeadName)
		local hui = self.headName.ui
		local hw = hui.width
		local hh = hui.height
		self.hpBar.bg:SetSize(self.hpBar.bg.width, self.hpBar.bg.height+self.mpBar.ui.height+3)
		self.mpBar:SetXY(-self.mpBar.ui.width*0.5, 1)
		self.hpBar:SetXY(-self.hpBar.ui.width*0.5, -(self.mpBar.ui.height+3))
		self.headName:SetXY(-hw*0.5, -(self.hpBar.bg.y+hh+self.hpBar.bg.height-offY))
		self.headName:SetColor(HeadUIMgr.DefaultRoleColor)
		self.namePos = {x=self.headName:GetX(), y=self.headName:GetY()}
		self:SetVisible(true)
		self.visible = true
	elseif type == 2 or type == 4 then -- 他人|敌对
		self.headName = self:CreateUI(HeadName)
		local hui = self.headName.ui
		local hw = hui.width
		local hh = hui.height
		if type == 4 then
			self.hpBar = self:CreateUI(HpBar)
		else
			self.hpBar = self:CreateUI(HpBarOther)
		end
		self.hpBar:SetXY(-self.hpBar.ui.width*0.5, 0)
		self.headName:SetXY(-hw*0.5, -(self.hpBar.bg.y+hh+8-offY))
		self.headName:SetColor(HeadUIMgr.DefaultNpcColor)
		self:SetVisible(false)
		self.visible = false
		self.namePos = {x=self.headName:GetX(), y=self.headName:GetY()}
	elseif type == 3 or type == 5 then -- npc|传送门
		self.headName = self:CreateUI(HeadName)
		local hui = self.headName.ui
		local hw = hui.width
		local hh = hui.height
		self.headName:SetXY(-hw*0.5, offY)
		self.headName:SetColor(type == 3 and HeadUIMgr.DefaultMonsterColor or HeadUIMgr.DefaultDoorColor)
		self.namePos = {x=self.headName:GetX(), y=self.headName:GetY()}
		self:SetVisible(false)
		self.visible = false
	end
end

-- 设置家族称谓
function HeadCell:AddFamilyName(data)
	local name = data.title or ""
	local type = data.type or 0
	if type == 1 then -- 家族
		name = self:GetFamilyTitle(data)
	end
	if not self.familyName then
		self.familyName = self:CreateUI(HeadName)
	end
	self:UpdateFamilyName(name, HeadUIMgr.DefaultFamilyColor)
end

-- 获取家族称谓
function HeadCell:GetFamilyTitle( data )
	local sortId = data.sortId or 0
	if sortId == 0 then return end
	local name = data.title or ""
	local s
	if sortId >= 1 and sortId <= 3 then
		s = FamilyConst.Job[sortId]
	else
		s = FamilyConst.Job[4]
	end
	return name .." ".. s
end	

-- 设置称号
function HeadCell:SetTitle( title )
	self.title = title
	self:UpdateName(nil, nil, title)
end
-- 更换hpbar(友方，敌人)
function HeadCell:SwitchHPBar(type)
	if self.hpBar then
		local pos = {x=self.hpBar:GetX(), y=self.hpBar:GetY()}
		self.type = type
		self.hpBar:RemoveFromParent()
	end
	self.hpBar = self:CreateUI(type == 2 and HpBarOther or HpBar)
	self.hpBar:SetXY(pos.x, pos.y)
end
-- 增加段位图标
function HeadCell:AddStageIcon( stage )
	if stage and stage ~= 0 and self.ui then
		if not self.stageIcon then
			self.stageIcon = UIPackage.CreateObject("Common" , "CustomSprite0")
			self.stageIcon:SetSize(40, 40)
			self.ui:AddChild(self.stageIcon)
		end
		self.stageIcon.icon = "Icon/Tianti/dwicon1"..stage
		if self.hpBar then
			if self.type == 1 then
				self.stageIcon:SetXY(-81, self.hpBar:GetY()-self.offY-13)
			else
				self.stageIcon:SetXY(-81, self.hpBar:GetY()-self.offY-16)
			end
		end
	else
		if self.stageIcon then
			self.stageIcon.icon = nil
		end
	end
end

-- 增加队长标识
function HeadCell:AddTeamLeaderSign(teamId)
	if self.ui and teamId and teamId ~= 0 then
		if not self.teamIcon then
			self.teamIcon = UIPackage.CreateObject("Common" , "CustomSprite0")
			self.teamIcon:SetSize(34, 30)
			self.ui:AddChild(self.teamIcon)
		end
		local urlLeader = UIPackage.GetItemURL("Common" , "teamLeaderSign")
		local urlMate = UIPackage.GetItemURL("Common", "teamMateSign")

		-- wuqi add 17/08/01
		if self.data and self.data.vo and self.data:IsHuman() then
			local tId = self.data.vo.teamId
			local playerId = self.data.vo.playerId
			local zdModel = ZDModel:GetInstance()
			if self.teamIcon then
				-- 非自己队伍则小旗子看不见
				if zdModel.teamId ~= tId then
					self.teamIcon.icon = nil
				else
					if zdModel:IsTeamMate(playerId) then
						-- 队长
						local id = LoginModel:GetInstance():GetLoginRole().playerId
						if zdModel:IsLeader() and playerId == id then
							self.teamIcon.icon = urlLeader
						elseif zdModel:GetLeaderId() == playerId then
							self.teamIcon.icon = urlLeader
						else
							-- 队友
							self.teamIcon.icon = urlMate
						end
					else
						self.teamIcon.icon = nil
					end
				end
			end
		end

		if self.headName then
			local title = self.headName.title
			if self.type == 1 then
				self.teamIcon:SetXY(title.x-50, title.y-title.textHeight-20)
			else
				self.teamIcon:SetXY(title.x-50, title.y-title.textHeight-10)
			end
		end
	else
		if self.teamIcon then
			self.teamIcon.icon = nil
		end
	end
end
-- 设置（NPC）状态标识
function HeadCell:SetState( state )
	if not self.stateSign then
		self.stateSign = UIPackage.CreateObject("Common" , "CustomSprite")
		self.stateSign:SetSize(28, 37)
		self.ui:AddChild(self.stateSign)
	end
	if state == 0 then
		self.stateSign.icon = nil
	else
		self.stateSign.icon = "Icon/Head/state"..state
	end
	if self.headName then
		self.stateSign:SetXY(-14, -(self.headName:GetY()+self.headName.ui.height+26-self.offY))
	end
end

-- 隐藏血条
function HeadCell:HideBar(barBool)
	if barBool and self.hpBar then
		self.hpBar:SetVisible(barBool)
		if self.mpBar then self.mpBar:SetVisible(barBool) end
		if barBool then
			if self.namePos then
				self.headName:SetXY(self.namePos.x, self.namePos.y)
			end
		else
			if self.namePos then
				self.headName:SetXY(-self.headName.ui.width*0.5, self.offY)
			end
		end
		self:UpdateFamilyName()
	end
end
function HeadCell:SetOffSet( offX, offY )
	self.rootOffX = offX or self.rootOffX
	self.rootoffY = offY or self.rootoffY
end
function HeadCell:SetNameSize( v )
	if not self.headName then return end
	local tf = self.headName.title.textFormat
	tf.size = v
	self.headName.title.textFormat = tf
end

function HeadCell:CreateUI( Model )
	local obj = Model.New()
	obj:AddTo(self.ui)
	table.insert(self._objsCacheList, obj)
	return obj
end
function HeadCell:InitEvent()
	if not self.handler then
		if self.data and self.data.vo then
			local vo = self.data.vo
			local changeHandle = function (key, value, pre)
				if not self.data then return end
				if key == "hp" then
					self:UpdateHp(value)
				elseif key == "mp" then
					self:UpdateMp(value)
				elseif key == "hpMax" then
					self:UpdateHp(nil, value)
				elseif key == "mpMax" then
					self:UpdateMp(nil, value)
				elseif key == "nameColor" then
					self.nameColorCode = value
					self:UpdateName(nil, value, nil)
				elseif key == "name" then
					self.name = value
					self:UpdateName(value, nil, nil)
				elseif key == "title" then
					self:SetTitle(value)
				elseif key == "stage" then
					self:AddStageIcon(value)
				elseif key == "level" then
					if self.data:IsHuman() then
						local name = StringFormat("{0} lv{1}", self.name, value)
						self:UpdateName(name, nil, nil)
					end
				end
			end
			self.handler=vo:AddEventListener(SceneConst.OBJ_UPDATE, changeHandle)
		end
	end
end
function HeadCell:StopEvent()
	if self.data and self.data.vo then
		self.data.vo:RemoveEventListener(self.handler)
	end
	self.handler = nil
end
function HeadCell:Start(sceneObj)
	self.data = sceneObj or self.data
	self.cam = Camera.main
	if self.data and self.data.vo then
		self.showTime = 0
		self.follower = self.data.transform
		self.gameObject = self.data.gameObject
		local vo = self.data.vo
		self:UpdateHp(vo.hp, vo.hpMax)
		self:UpdateMp(vo.mp, vo.mpMax)
		self.name = vo.name
		self.level = vo.level
		self.nameColorCode = vo.nameColor
		if sceneObj:IsHuman() then
			local name = StringFormat("{0} lv{1}", vo.name, vo.level)
			self:UpdateName(name, vo.nameColor, vo.title)
			local data = {}
			data.title = vo.familyName
			data.sortId = vo.familySortId
			data.type = 1
			self:AddFamilyName(data)
		else
			self:UpdateName(vo.name)
		end
		if self.InitEvent then
			self:StopEvent()
			self:InitEvent()
		end
		
		if sceneObj:IsMonster() then
			local br = sceneObj.changeBR or 1
			if br > 1.5 then
				self.rootoffY = sceneObj.bodyHeight - br*0.6
			elseif br >1.3 then
				self.rootoffY = sceneObj.bodyHeight - br*0.4
			else
				self.rootoffY = sceneObj.bodyHeight + 0.5
			end
			self.headName:SetColor(HeadUIMgr.DefaultMonsterColor)
		elseif sceneObj:IsNPC() then
			self.rootoffY = 2.5 -- sceneObj.bodyHeight + 0.4
			self.headName:SetColor(HeadUIMgr.DefaultNpcColor)
		else
			if self.sceneCtrl:IsCopy() or self.sceneCtrl:IsOutdoor() then
				self.rootoffY = 2.35
			else
				self.rootoffY = 2.25
			end
		end
		self.rootOffX = 100
	end
	self:AddTo(bottomLayer)
end
function HeadCell:UpdateName(name, nameColor, title)
	if self.headName then
		if self.data and self.data.vo and self.data:IsHuman() then
			local c = self:CreatePlayerName(nameColor, name, title)
			self.headName:SetName(c)
		else
			if name then
				self.name = name
				self.headName:SetName(name)
			end
			if nameColor then
				self.nameColorCode = nameColor
				self.headName:SetColor(HeadUIMgr.GetNameColor(nameColor))
			end
		end
		if self.data and self.data.vo and self.data.IsHuman and self.data:IsHuman() then
			self:AddTeamLeaderSign(self.data.vo.teamId)
		end
	end
end
function HeadCell:UpdateFamilyName( name, color )
	if self.familyName then
		if name then
			self.familyName:SetName(name)
		end
		if color then
			self.familyName:SetColor(color)
		end
		self.familyName:SetXY(self.namePos.x, self.namePos.y-28)
	end
end
function HeadCell:CreatePlayerName(nameColor, name, title)
	name = name or self.name or ""
	title = title or self.title or ""
	if title ~= "" then
		name = " "..name
	end
	nameColor = nameColor or self.nameColorCode or 1
	return StringFormat("[color={0}]{1}[/color][color={2}]{3}[/color]", HeadUIMgr.DefaultTitleColor, title, HeadUIMgr.GetNameColor(nameColor), name or "")
end
function HeadCell:UpdateHp(value, max)
	if self.hpBar then
		if value then
			self.hpBar:SetValue(value)
		end
		if max then
			self.hpBar:SetMax(max)
		end
	end
end
function HeadCell:UpdateMp(value, max)
	if self.mpBar then
		if value then
			self.mpBar:SetValue(value)
		end
		if max then
			self.mpBar:SetMax(max)
		end
	end
end
function HeadCell:Stop()
	self.follower = nil
	if self.type ~= 1 then -- 主角不变，一直是显示的
		self:Show(false)
	end
	self:StopEvent()
	self:RemoveFromParent()
	self.data = nil
	self.gameObject = nil
	self.name = nil
	self.title = nil
	self.nameColorCode = nil
	if self.stateSign then
		destroyUI( self.stateSign )
	end
	self.stateSign = nil
	if self.stageIcon then
		destroyUI( self.stageIcon )
	end
	self.stageIcon = nil

	self.cam = nil
end
function HeadCell:__delete()
	self:Stop()
	if self._objsCacheList then
		for i,v in ipairs(self._objsCacheList) do
			v:Destroy()
		end
		self._objsCacheList = nil
	end
	self.data = nil
	self.type = nil
end

function HeadCell:Update()
	if self.visible and not ToLuaIsNull(self.cam) and self.follower then
		local viewportPoint = self.cam:WorldToViewportPoint(self.follower.position + self.follower.up*self.rootoffY)
		self.ui:SetXY(self.layerW*viewportPoint.x, self.layerH - self.layerH*viewportPoint.y)
	end
end
function HeadCell:Show(v)
	if v == self.visible then
		return
	end
	self:SetVisible(v)
	if v then
		self.cam = Camera.main
		local vo = self.data.vo
		if vo then
			self:UpdateHp(vo.hp, vo.hpMax)
			self:UpdateMp(vo.mp, vo.mpMax)
			self.name = vo.name
			self.nameColorCode = vo.nameColor
			if self.data:IsHuman() then
				local name = StringFormat("{0} lv{1}", vo.name, vo.level)
				self:UpdateName(name, vo.nameColor, vo.title)
				local data = {}
				data.title = vo.familyName
				data.sortId = vo.familySortId
				local name = self:GetFamilyTitle(data)
				self:UpdateFamilyName(name)
			else
				self:UpdateName(vo.name)
			end
		end
		self:InitEvent()
		self:Update()
	else
		self:StopEvent()
	end
	self.visible = v
end
function HeadCell:SetVisible(bool)
	-- LuaUI.SetVisible(self, bool)
	if not bool then
		self.ui:SetXY(-10000,-10000)
	end
end