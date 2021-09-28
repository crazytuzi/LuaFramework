MapBg =BaseClass(LuaUI)

function MapBg:__init( ... )
	self.URL = "ui://rkrzdlw3elj8u";
	self:__property(...)
	self:Config()
end
function MapBg:SetProperty( ... )
	
end
function MapBg:Config()
	self.teamFlagList = {}
	self.meFlagList = {}
	self.handler=GlobalDispatcher:AddEventListener(EventName.Player_StopWorldNavigation, function ( data )
		self:StopWorldNavigation(data)
	end)

	self.mainPlayer = nil
	self.clickMapId = nil
end
function MapBg:Init()
	local cfg = GetCfgData("mapManger")
	for i=1,27 do
		-- self["btn0"..i] = MapBtn.Create(self["btn0"..i]) 
		self["btn"..i].data = WorldMapConst.MapId[i]
		local mapCfg =  cfg:Get(WorldMapConst.MapId[i].mapId)
		if mapCfg then 
			self["btn"..i]:GetChild("title").text = StringFormat("{0}",mapCfg.map_name)
			if mapCfg.pkModel==3 then --如果是对战地图，就增加对战图片
				local pkFlag = UIPackage.CreateObject("WorldMaps" , "WorldMapPkFlag")
				self["btn"..i]:AddChild(pkFlag)
				pkFlag:SetXY(-31,0)
			elseif mapCfg.pkModel == 4 then
				local pkFlag = UIPackage.CreateObject("WorldMaps" , "WorldMapQiecuoFlag")
				self["btn"..i]:AddChild(pkFlag)
				pkFlag:SetXY(-31,0)
			end
		end
		self["btn"..i].onClick:Add(function (e)
			self:OnClickMapBtn(e.sender.data.mapId)
		end)
	end
	self.clickFlag = UIPackage.CreateObject("WorldMaps" , "MapClickFlag")
	self.clickFlag.visible = false 
	
	for i=1,4 do -- 生成四个小旗子
		local teamerflag = UIPackage.CreateObject("WorldMaps" , "TeamFlag")
		table.insert(self.teamFlagList,teamerflag)
		teamerflag.data = {mapId = 0}
		teamerflag.visible = false
	end
	self:Refresh()
	self:SetTargetFlag()
end
function MapBg:Refresh()
	if self.teamerflag then -- 先初始化一下flag
		for i=1,#self.teamerflag do
			if self.teamerflag[i] then 
				self.teamerflag[i].data.mapId = 0
				self.teamerflag[i].visible = false
			end
		end
	end
	if self.meFlagList then
		for i,v in ipairs(self.meFlagList) do
			destroyUI(v)
		end
		self.meFlagList = {}
	end
	if self.flag then
		self.flag.visible = false
	end
	local members = ZDModel:GetInstance():GetMember()
	local meVo = SceneModel:GetInstance():GetMainPlayer()
	local meMapId = SceneModel:GetInstance().sceneId
	if members and next(members)then 
		local teamNum = 0
		for playerId,vo in pairs(members) do
			if vo then 
				teamNum = teamNum + 1
				local flagBtn = self:GetBtnByMapId(vo.mapId)
				if vo.playerId ~= meVo.playerId then 
					if flagBtn then
						local teamerflag = self.teamFlagList[teamNum]
						teamerflag.visible = true
						flagBtn:AddChild(teamerflag)
						if vo.captain then 
							teamerflag:GetChild("icon").url = UIPackage.GetItemURL("WorldMaps" , "teamLeader")
						else
							teamerflag:GetChild("icon").url = UIPackage.GetItemURL("WorldMaps" , "teamMember")
						end
						if self.teamFlagList then 
							local offset = 0
							for i=1,#self.teamFlagList do
								if self.teamFlagList[i].data.mapId == vo.mapId then 
									offset = offset + 1
								end
							end
							-- teamerflag:SetXY(50 + 30*offset, 45)
							teamerflag:SetXY(-15 + 30*offset, -26)
						end
						teamerflag.data.mapId = vo.mapId
					end
				else
					local meFlag = UIPackage.CreateObject("WorldMaps" , "MeFlag")
					local flagBtn = self:GetBtnByMapId(vo.mapId)
					-- if ZDModel:GetInstance():IsLeader() then
					-- 	meFlag:GetChild("icon").url = UIPackage.GetItemURL("WorldMaps" , "ownerPos")
					-- else
						if vo.captain then 
							meFlag:GetChild("icon").url = UIPackage.GetItemURL("WorldMaps" , "owerLeader")
						else
							meFlag:GetChild("icon").url = UIPackage.GetItemURL("WorldMaps" , "ownerMember")
						end
					-- end
					if flagBtn then 
						flagBtn:AddChild(meFlag)
						meFlag:SetXY(25, -26)
						table.insert(self.meFlagList,meFlag)
					end
				end
			end
		end
	else
		for i=1,27 do
			if self["btn"..i].data.mapId == meMapId then 
				if not self.flag then
					self.flag = UIPackage.CreateObject("WorldMaps" , "MeFlag")
				end
				self.flag.visible = true
				self["btn"..i]:AddChild(self.flag)
				self.flag:SetXY(25, -26)
				self.flag:GetChild("icon").url = UIPackage.GetItemURL("WorldMaps" , "ownerPos")
				break
			end
		end
	end
end

--根据mapid获取到对应的按钮
function MapBg:GetBtnByMapId(mapId)
	for i=1,27 do
		if self["btn"..i].data.mapId == mapId then 
			return self["btn"..i]
		end
	end
end

function MapBg:OnClickMapBtn(mapId)
	SceneController:GetInstance():GetScene():StopAutoFight(true)
	self.clickMapId = mapId
	self.mainPlayer = SceneController:GetInstance():GetScene():GetMainPlayer()
	RenderMgr.Add(function () self:OnClickMapBtnHandler() end, "MapBg:OnClickMapBtn")
end

function MapBg:OnClickMapBtnHandler()
	if self.mainPlayer == nil then
		RenderMgr.Realse("MapBg:OnClickMapBtn")
		return
	end
	if self.mainPlayer:IsLock() then 
		return
	else
		RenderMgr.Realse("MapBg:OnClickMapBtn")
	end

	local curMapId = SceneModel:GetInstance().sceneId
	if curMapId == self.clickMapId then 
		WorldMapModel:GetInstance():DispatchEvent(WorldMapConst.ClosePanel)
		return 
	end
	if self.clickMapId == 1001 then --如果需要回到主城（点击的是主城），就直接进入回城
		GlobalDispatcher:DispatchEvent(EventName.StopCollect)
		GlobalDispatcher:DispatchEvent(EventName.StartReturnMainCity)
		WorldMapModel:GetInstance():DispatchEvent(WorldMapConst.ClosePanel)
		return
	end
	if curMapId ~= 1001 then
		local isCrossMainCity = WorldMapConst.GetPath(curMapId, self.clickMapId)
		if isCrossMainCity then -- 如果需要经过主城，就直接用回城先回主城
			if SceneController:GetInstance():GetScene() then
				if self.mainPlayer then
					if self.mainPlayer:IsDie() then return end
					self.mainPlayer:StopMove()
				end
			end
			GlobalDispatcher:DispatchEvent(EventName.StopCollect)
			GlobalDispatcher:DispatchEvent(EventName.StartReturnMainCity)
			SceneModel:GetInstance().worldMapId = self.clickMapId -- 直接设置玩家的目标点
			self.clickFlag.visible = false 
			self:SetTargetFlag()
			WorldMapModel:GetInstance():DispatchEvent(WorldMapConst.ClosePanel)
			return
		end
	end
	self.clickFlag.visible = false 
	if SceneController:GetInstance():GetScene() then 
		if self.mainPlayer:IsDie() then return end
		self.mainPlayer:SetWorldNavigation(self.clickMapId,nil, false, true)
		self:SetTargetFlag()
	end
	WorldMapModel:GetInstance():DispatchEvent(WorldMapConst.ClosePanel)

	self.mainPlayer = nil
	self.clickMapId = nil
end

function MapBg:SetTargetFlag()
	self.clickFlag.visible = false 
	local playerVo = SceneModel:GetInstance():GetMainPlayer()
	if playerVo then 
		if SceneModel:GetInstance().worldMapId ~= 0 then 
			for i=1,#WorldMapConst.MapId do
				if WorldMapConst.MapId[i].mapId == SceneModel:GetInstance().worldMapId then 
					self.clickFlag.visible = true 
					self["btn"..i]:AddChild(self.clickFlag)
					self.clickFlag:SetXY(25, 30)
				end
			end
		end
	end
end

function MapBg:StopWorldNavigation()
	self.clickFlag.visible = false 
end

function MapBg:GetTransPath()
	self.list = {}
	self.cfg = GetCfgData("transfer")
end
function MapBg:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("WorldMaps","MapBg");

	self.bg = self.ui:GetChild("bg")
	self.btn1 = self.ui:GetChild("btn1")
	self.btn2 = self.ui:GetChild("btn2")
	self.btn3 = self.ui:GetChild("btn3")
	self.btn4 = self.ui:GetChild("btn4")
	self.btn5 = self.ui:GetChild("btn5")
	self.btn6 = self.ui:GetChild("btn6")
	self.btn7 = self.ui:GetChild("btn7")
	self.btn8 = self.ui:GetChild("btn8")
	self.btn9 = self.ui:GetChild("btn9")
	self.btn10 = self.ui:GetChild("btn10")
	self.btn11 = self.ui:GetChild("btn11")
	self.btn12 = self.ui:GetChild("btn12")
	self.btn13 = self.ui:GetChild("btn13")
	self.btn14 = self.ui:GetChild("btn14")
	self.btn15 = self.ui:GetChild("btn15")
	self.btn16 = self.ui:GetChild("btn16")
	self.btn17 = self.ui:GetChild("btn17")
	self.btn18 = self.ui:GetChild("btn18")
	self.btn19 = self.ui:GetChild("btn19")
	self.btn20 = self.ui:GetChild("btn20")
	self.btn21 = self.ui:GetChild("btn21")
	self.btn22 = self.ui:GetChild("btn22")
	self.btn23 = self.ui:GetChild("btn23")
	self.btn24 = self.ui:GetChild("btn24")
	self.btn25 = self.ui:GetChild("btn25")
	self.btn26 = self.ui:GetChild("btn26")
	self.btn27 = self.ui:GetChild("btn27")
end
function MapBg.Create( ui, ...)
	return MapBg.New(ui, "#", {...})
end
function MapBg:__delete()
	if self.teamerflag then 
		for k,v in pairs( self.teamerflag) do
			if v then
				destroyUI( v )
				self.teamerflag[k]= nil
			end
		end
	end
	if self.clickFlag then 
		destroyUI( self.clickFlag )
	end
	self.clickFlag = nil
	self.teamerflag = nil
	GlobalDispatcher:RemoveEventListener(self.handler)
	if self.teamFlagList then
		for k,v in pairs( self.teamFlagList) do
			if v then
				destroyUI( v )
			end
		end
		self.teamFlagList = nil
	end
end