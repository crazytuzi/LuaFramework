-- 队伍成员
ZDMemCell = BaseClass(LuaUI)
function ZDMemCell:__init()
	self.ui = UIPackage.CreateObject("Team","ZDMemCell")
	self.modelConn = self.ui:GetChild("modelConn")
	self.txtName = self.ui:GetChild("txtName")
	self.txtLev = self.ui:GetChild("txtLev")
	self.txtMap = self.ui:GetChild("txtMap")
	self.iconCareer = self.ui:GetChild("iconCareer")
	self.iconCareer.visible = false

	self.bgOff = self.ui:GetChild("bgOff")
	self.txtOff = self.ui:GetChild("txtOff")
	self.offTeam = self.ui:GetChild("offTeam")

	self.labelPos = self.ui:GetChild("labelPos")
	self.leaderSign = self.ui:GetChild("leaderSign")
	self.btnAdd = self.ui:GetChild("btnAdd")
	self.iconTuteng = self.ui:GetChild("icon_tuteng")
	self.img_leveldi = self.ui:GetChild("img_leveldi")
	self.img_huawen = self.ui:GetChild("img_huawen")

	self.gameObject = nil

	self:InitEvent()
end

function ZDMemCell:InitEvent()
	self.ui.onClick:Add(function ()
		if self.data then
			local id = LoginModel:GetInstance():GetLoginRole().playerId
			if self.data.playerId ~= id then
				local data = {}
				data.playerId = self.data.playerId
				if ZDModel:GetInstance():IsLeader() then
					data.funcIds = {PlayerFunBtn.Type.CheckPlayerInfo,PlayerFunBtn.Type.Chat, PlayerFunBtn.Type.KickOffTeam, PlayerFunBtn.Type.TransferTeamLeader}
				else
					if self.data.captain then
						data.funcIds = {PlayerFunBtn.Type.CheckPlayerInfo, PlayerFunBtn.Type.Chat}
					else
						data.funcIds = {PlayerFunBtn.Type.CheckPlayerInfo, PlayerFunBtn.Type.Chat}
					end
				end
				if data.funcIds then
					table.insert(data.funcIds, PlayerFunBtn.Type.AddFriend)
					table.insert(data.funcIds, PlayerFunBtn.Type.EnterFamily)
				end
				GlobalDispatcher:DispatchEvent(EventName.ShowPlayerFuncPanel, data)
			end
		end
	end)
end

function ZDMemCell:Update(data)
	self.data = data
	if self.data then
		self.btnAdd.visible = false
		self.txtName.text = data.playerName
		self.txtLev.text = StringFormat("{0}级",data.level)
		self.labelPos.text="位置:"
		local info = GetCfgData("mapManger"):Get(data.mapId)
		if info then
			local name = info.map_name or ""
			local p1 = string.find(name, '\n')
			if p1 then
				name = string.sub(name, 1, p1 - 1)
			end
			self.txtMap.text = name
		else
			self.txtMap.text = "未知地图"
		end
		-- self.iconCareer.visible = true
		-- self.iconCareer.url = "Icon/Head/career_0"..data.career
		self.offTeam.visible = data.online == 0
		self.leaderSign.visible = data.captain == true
		self.modelConn.visible = true
		self.iconTuteng.visible = true
		self.img_leveldi.visible = true
		self.img_huawen.visible = true
		self:CreateModel()
	else
		self:Clear()
	end
end

function ZDMemCell:CreateModel()
	if self.data then
		if self.gameObject then
			destroyImmediate(self.gameObject)
		end
		self.gameObject = nil
		local cfg = GetCfgData("equipment"):Get(self.data.weaponStyle)
		local weaponEftId = 0 
		local weaponStyle = 0 
		if cfg then
			if cfg.rare == 4 or cfg.rare == 5 then --只有武器品质为4,5的武器需要加载光效
				weaponEftId = cfg.effect
			end
			weaponStyle = cfg.weaponStyle
		end
		CreateModel(function(go)
			if ToLuaIsNull(go) then return end
			self.gameObject = go
			go.transform.localScale = Vector3.New(200, 200, 200)
			go.transform.localPosition = Vector3.New(35, -46, 470)
			go.transform.localEulerAngles = Vector3.New(0, 180, 0)
			self.modelConn:SetNativeObject(GoWrapper.New(go)) -- ui 3d对象加入
		end, self.data.dressStyle, weaponStyle, self.data.wingStyle, weaponEftId)
	end
	
end

--旋转角色模型
function ZDMemCell:RotationPlayerModel()
	if self.touchId == -1 then
		local evt = context.data
		self.touchId = evt.touchId
		Stage.inst.onTouchMove:Add( self.onTouchMove, self )
		Stage.inst.onTouchEnd:Add( self.onTouchEnd, self )
	end
end
--touchmove
function ZDMemCell:onTouchMove(context)
	local evt = context.data
	if evt and self.touchId ~= -1 and evt.touchId == self.touchId then
		local evt = context.data
		if self.lastTouchX ~= 0 then
			local rotY = self.gameObject.transform.localEulerAngles.y - (evt.x - self.lastTouchX)
			self.gameObject.transform.localEulerAngles = Vector3.New(0, rotY, 0)
		end
	end
	self.lastTouchX = evt.x
end
--touchend
function ZDMemCell:onTouchEnd( context )
	local evt = context.data
	if evt and self.touchId ~= -1 and evt.touchId == self.touchId then
		self.touchId = -1
		self.lastTouchX = 0
		Stage.inst.onTouchMove:Remove(self.onTouchMove, self)
		Stage.inst.onTouchEnd:Remove(self.onTouchEnd,self)
	end
end

function ZDMemCell:Clear()
	self.btnAdd.visible = ZDModel:GetInstance():IsLeader()
	self.iconCareer.visible = false
	self.txtName.text = ""
	self.txtMap.text = ""
	self.txtLev.text = ""
	self.labelPos.text = ""
	self.leaderSign.visible = false
	self.offTeam.visible = false
	self.modelConn.visible = false
	self.iconTuteng.visible = false
	self.img_leveldi.visible = false
	self.img_huawen.visible = false
end
function ZDMemCell:SetAddCallback( cb )
	self.btnAdd.onClick:Add(function ()
		if cb then cb() end
	end)
end

function ZDMemCell:__delete()
	if self.gameObject then
		destroyImmediate(self.gameObject)
	end
	Stage.inst.onTouchMove:Remove(self.onTouchMove, self)
	Stage.inst.onTouchEnd:Remove(self.onTouchEnd,self)
	self.gameObject = nil
end