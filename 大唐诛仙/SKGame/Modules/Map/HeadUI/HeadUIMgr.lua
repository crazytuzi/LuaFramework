RegistModules("Map/HeadUI/HpBar")
RegistModules("Map/HeadUI/HpBarOther")
RegistModules("Map/HeadUI/MpBar")
RegistModules("Map/HeadUI/HeadCell")
RegistModules("Map/HeadUI/HeadName")

HeadUIMgr = BaseClass()
HeadUIMgr.Color={
	White = 1,	--白色
	Gray = 2,	--灰色
	Red = 3,	--红色
}
HeadUIMgr.ColorValue={
	[1] = "#ffffff",	--白色
	[2] = "#b1b1b1",	--灰色
	[3] = "#ff0000",	--红色
}

HeadUIMgr.DefaultDoorColor = "#19fff7"
HeadUIMgr.DefaultRoleColor = "#ffffff"
HeadUIMgr.DefaultNpcColor = "#fff60e"
HeadUIMgr.DefaultMonsterColor = "#ff2828"
HeadUIMgr.DefaultFamilyColor = "#f9c052"
HeadUIMgr.DefaultClanColor = "#3aa1f3"
HeadUIMgr.DefaultTitleColor = "#5be4f1"

HeadUIMgr.namebarShowTime = 30 -- 显示时间s
HeadUIMgr.cellCheckTime = 120 -- 帧数检查
function HeadUIMgr:__init()
	self.settingModel = SettingModel:GetInstance()
	self.max = 30
	self.pool = {} -- 缓存池的
	self.list = {} -- 已经加载的
	self.checking = false

	RenderMgr.CreateCoTimer(function ()
		self.checking = true
		if #self.pool > self.max then
			for i=#self.pool, self.max, -1 do
				local ui = table.remove(self.pool, i)
				if ui then ui:Destroy() end
				ui = nil
			end
		end
		self.checking = false
	end, 10, -1, "HeadUIMgr_GC")

	RenderMgr.CreateFrameRender(function ()
		for i=1, #self.list do
			local ui = self.list[i]
			if ui then 
				ui:Update()
				if ui ~= self.mainRole then
					if ui.type == 2 then
						ui:HideBar(ui.showState)
						ui.headName:SetVisible(true)
					else
						ui:HideBar(self.showBar)
						if ui.stageIcon then ui.stageIcon.visible = self.showBar end
						if ui.headName then ui.headName:SetVisible(self.showName) end
						if ui.familyName then ui.familyName:SetVisible(self.showName) end
						if ui.teamIcon then ui.teamIcon.visible = self.showName end
					end
				end
			end
		end
	end, 1, -1, "HeadUIMgr_Render") -- 每帧对已经可以显示的更新

	self:StartEvent()
end

function HeadUIMgr:UpdateShow()
	self:SetShowBar(self.settingModel:GetBool(4))
	self:SetShowName(self.settingModel:GetBool(5))
end

-- function HeadUIMgr:RefreshShow()
-- 	local showBar = self.showBar
-- 	local showName = self.showName
-- 	for i=1, #self.list do
-- 		local ui = self.list[i]
-- 		if ui and ui ~= self.mainRole then
-- 			if ui.type == 2 then
-- 				ui:HideBar(ui.showState)
-- 				ui.headName:SetVisible(true)
-- 			else
-- 				ui:HideBar(showBar)
-- 				if ui.stageIcon then ui.stageIcon.visible = showBar end
-- 				if ui.headName then ui.headName:SetVisible(showName) end
-- 				if ui.familyName then ui.familyName:SetVisible(showName) end
-- 				if ui.teamIcon then ui.teamIcon.visible = showName end
-- 			end
-- 		end
-- 	end
-- end

-- 控制血条显示
function HeadUIMgr:SetShowBar( isShow )
	if self.showBar == isShow then return end
	self.showBar = isShow
	for i=1, #self.list do
		local ui = self.list[i]
		if ui and ui ~= self.mainRole and ui.type ~= 2 then
			if ui then ui:HideBar(isShow) end
			if ui.stageIcon then ui.stageIcon.visible = isShow end
		end
	end
end

-- 名字显示
function HeadUIMgr:SetShowName( isShow )
	if self.showName == isShow then return end
	self.showName = isShow
	for i=1, #self.list do
		local ui = self.list[i]
		if ui and ui ~= self.mainRole and ui.type ~= 2 then
			if ui.headName then ui.headName:SetVisible(isShow) end
			if ui.familyName then ui.familyName:SetVisible(isShow) end
			if ui.teamIcon then ui.teamIcon.visible = isShow end
		end
	end
end

-- code: HeadUIMgr.Color
function HeadUIMgr.GetNameColor(code)
	return HeadUIMgr.ColorValue[code]
end

function HeadUIMgr:Remove(ui) -- delete
	for i,v in ipairs(self.list) do
		if v == ui then
			table.remove(self.list, i)
			ui:Stop()
			if ui.type == 1 then -- 主角的
				self.mainRole = nil
			elseif ui.type == 2 then -- 怪物的
				ui.showState = false
			end
			ui:SetVisible(false)
			table.insert(self.pool, ui) -- end
			break
		end
	end
end

function HeadUIMgr:Create(type, sceneObj)
	local ui = nil
	if not self.checking then
		for i, v in ipairs(self.pool) do
			if v and v.type == type then
				ui = table.remove(self.pool, i)
				ui:SetVisible(false)
				break
			end
		end
	end

	if not ui then
		ui = HeadCell.New(type)
		ui:SetVisible(false)
	end
	
	if sceneObj and sceneObj.vo then
		table.insert(self.list, ui)
		ui:Start(sceneObj)
		if type == 1 then -- 主角的
			self.mainRole = ui
			ui:SetVisible(true)
			self.mainRole:SetVisible(true)
		else
			-- if self.mainRole ~= ui then
			-- 	ui:Show(true)
			-- end
		end
		if self.mainRole ~= ui then
			if ui.type == 2 then -- 怪物的
				ui.hpBar:SetVisible(false)
			else
				ui:HideBar(self.showBar)
			end
			if ui.stageIcon then ui.stageIcon.visible = self.showBar end
			if ui.headName then ui.headName:SetVisible(self.showName) end
			if ui.familyName then ui.familyName:SetVisible(self.showName) end
			if ui.teamIcon then ui.teamIcon.visible = self.showName end

		end
	end
	return ui
end
function HeadUIMgr:StartEvent()
	self.handler=GlobalDispatcher:AddEventListener(EventName.MAINROLE_WALKING, function ( data )
		self:WalkHandle(data)
	end)

	self.handler=self.settingModel:AddEventListener(StgConst.DATA_INITED, function ()
		self:UpdateShow()
	end)
end

function HeadUIMgr:RemoveEvent()
	self.settingModel:RemoveEventListener(self.showHandle)
	GlobalDispatcher:RemoveEventListener(self.handler)
end
function HeadUIMgr:WalkHandle( data )
	if data then
		if self.mainRole then
			self.mainRole:SetZorder(data.z)
		end
		for i=1, #self.list do
			local ui = self.list[i]
			if self.mainRole ~= ui then
				if ui and ui.follower then
					if not pcall(function () 
							-- if ui.type == 2 then -- 怪物的
							-- 	ui:Show(true)
							-- else 
							ui:Show(MapUtil.GetV3DistanceByXZ( data, ui.follower.position)<4)
							-- end
						end) then
						self:Remove(ui)
					end
				end
			end
		end
	end
end

function HeadUIMgr:GetUIByObj(sceneObj)
	for i,v in ipairs(self.list) do
		if v.data == sceneObj then return v end
	end
	return nil
end
function HeadUIMgr:Show(ui, bool)
	if ui then
		ui:show(bool)
	end
end
function HeadUIMgr:HideBar(ui, bool)
	if ui then
		ui:HideBar(bool)
	end
end
function HeadUIMgr:__delete()
	RenderMgr.Realse("HeadUIMgr_GC")
	RenderMgr.Realse("HeadUIMgr_Render")
	self:RemoveEvent()
	self.settingModel = nil
	self.pool = nil
	self.list = nil
	HeadUIMgr.inst = nil
end
function HeadUIMgr:StopRenderCo()
	RenderMgr.Realse("HeadUIMgr_Render")
end
function HeadUIMgr:GetInstance()
	if HeadUIMgr.inst == nil then
		HeadUIMgr.inst = HeadUIMgr.New()
	end
	return HeadUIMgr.inst
end