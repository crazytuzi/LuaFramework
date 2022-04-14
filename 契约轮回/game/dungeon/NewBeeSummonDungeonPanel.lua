NewBeeSummonDungeonPanel = NewBeeSummonDungeonPanel or class("NewBeeSummonDungeonPanel",NoviceDungeonPanel)
local NewBeeSummonDungeonPanel = NewBeeSummonDungeonPanel

function NewBeeSummonDungeonPanel:ctor()
	self.is_guided = false
end

function NewBeeSummonDungeonPanel:dctor()
	if self.mask_item then
		self.mask_item:destroy()
		self.mask_item = nil
	end
	self.parent_item = nil

	if self.guide_item then
		self.guide_item:destroy()
		self.guide_item = nil
	end

	if self.role_data_event then
		RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(self.role_data_event)
		self.role_data_event = nil
	end
end

function NewBeeSummonDungeonPanel:Open(data)
	NewBeeSummonDungeonPanel.super.Open(self, data)
end

function NewBeeSummonDungeonPanel:LoadCallBack()
	NewBeeSummonDungeonPanel.super.LoadCallBack(self)
end

function NewBeeSummonDungeonPanel:AddEvent()
	NewBeeSummonDungeonPanel.super.AddEvent(self)

	local mainpanel = lua_panelMgr:GetPanelOrCreate(MainUIView)
    self.parent_item = mainpanel.main_bottom_right.skill_list[9]
    if not self.mask_item then
    	self.mask_item = DungeonNewBeeSkillMaskItem(self.parent_item.transform)
    	SetGray(self.parent_item.skill_img, true)
    end

	--hp下降到20%以下时 触发释放宠物技能的指引
	local function call_back()
		local max_hp = RoleInfoModel:GetInstance():GetRoleValue("hpmax")
		local hp = RoleInfoModel:GetInstance():GetRoleValue("hp")
		if not self.is_guided and hp/max_hp <= 0.2 then
			self:StartGuide()
		end
		if self.is_guided then
			if hp == max_hp then
				--解除禁制战斗
				self:StartFight()
			end
		end
	end
	self.role_data_event = RoleInfoModel:GetInstance():GetMainRoleData():BindData("hp", call_back)
end

function NewBeeSummonDungeonPanel:RequseInfo()
    
end

function NewBeeSummonDungeonPanel:StartGuide()
	self.is_guided = true
	local panel_list = lua_panelMgr:GetPanelListByLayer(LayerManager.LayerNameList.UI)
	if not table.isempty(panel_list) then
		for panel, _ in pairs(panel_list) do
			panel:Close()
		end
	end
	--给boss加沉默buff,自己停止战斗
	self:StopFight()
	lua_panelMgr:GetPanelOrCreate(MainUIView).main_bottom_right:Switch(false)
	local function call_back()
		if self.mask_item then
			self.mask_item:destroy()
			self.mask_item = nil
			SetGray(self.parent_item.skill_img, false)
		end
		if not self.guide_item then
			self.guide_item = DungeonNewBeeGuideItem(self.parent_item.transform)
			local function click_callback()
				TargetClickCall(self.parent_item.skill_bg.gameObject)
			end
			self.guide_item:SetData(click_callback, self.parent_item.skill_bg.gameObject)
		end
	end
	GlobalSchedule:StartOnce(call_back, 1.5)
end

function NewBeeSummonDungeonPanel:StopFight()
	AutoFightManager.GetInstance():StopAutoFight()
	local monsters = SceneManager.GetInstance():GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_CREEP)
	for k, monster in pairs(monsters) do
		SceneControler:GetInstance():RequestAddBuff(220410003, monster.object_id)
	end
end

function NewBeeSummonDungeonPanel:StartFight()
	AutoFightManager.GetInstance():StartAutoFight()
	local monsters = SceneManager.GetInstance():GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_CREEP)
	for k, monster in pairs(monsters) do
		SceneControler:GetInstance():RequestDelBuff(220410003, monster.object_id)
	end
end
