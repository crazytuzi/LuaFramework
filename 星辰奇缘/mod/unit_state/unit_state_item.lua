-- --------------------------------
-- 场景活动单位存活情况,每条数据
-- hosr
-- --------------------------------

UnitStateItem = UnitStateItem or BaseClass()

function UnitStateItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self:InitPanel()
end

function UnitStateItem:__delete()
end

function UnitStateItem:InitPanel()
	self.transform = self.gameObject.transform
	self.name = self.transform:Find("Name"):GetComponent(Text)
	self.desc = self.transform:Find("Desc"):GetComponent(Text)
	self.transform:Find("Button"):GetComponent(Button).onClick:AddListener(function() self:ClickButton() end)
end

function UnitStateItem:ClickButton()
	if self.data == nil then
		return
	end
	if	RoleManager.Instance.RoleData.cross_type == 1  then
		-- NoticeManager.Instance:FloatTipsByString("此活动只在原服生效,请先回到原服")
		local confirmData = NoticeConfirmData.New()
		confirmData.type = ConfirmData.Style.Normal
		-- confirmData.sureSecond = -1
		-- confirmData.cancelSecond = 180
		confirmData.sureLabel = TI18N("返回原服")
		confirmData.cancelLabel = TI18N("取消")
		-- RoleManager.Instance.jump_over_call = function()
		--     self:ClickButton()
		-- end
		confirmData.sureCallback = SceneManager.Instance.quitCenter
		confirmData.content = string.format(TI18N("请<color='#ffff00'>返回原服</color>再前往参与"))
		NoticeManager.Instance:ConfirmTips(confirmData)
		return
	end

	if self.data.type == UnitStateEumn.Type.Star then
		UnitStateManager.Instance.model:FindStar(self.data.mapid)
	elseif self.data.type == UnitStateEumn.Type.Boss then
        local id_battle_id = BaseUtils.get_unique_npcid(self.data.id, 3)
        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
        SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
        SceneManager.Instance.sceneElementsModel:Self_AutoPath(self.data.map_id, id_battle_id, nil, nil, true)
	elseif self.data.type == UnitStateEumn.Type.Robber then
		UnitStateManager.Instance.model:FindRobber()
	elseif self.data.type == UnitStateEumn.Type.Fox then
		UnitStateManager.Instance.model:FindFox(self.data.mapid)
	elseif self.data.type == UnitStateEumn.Type.Cold then
		UnitStateManager.Instance.model:FindCold(self.data[1].map_id,self.data,self.count)
	elseif self.data.type == UnitStateEumn.Type.StarTrial then
		UnitStateManager.Instance.model:FindStarTrial(self.data.mapid)
	elseif self.data.type == UnitStateEumn.Type.MoonStar then
		UnitStateManager.Instance.model:FindMoonStar(self.data.mapid)
	end

	self.parent:Close()
end

function UnitStateItem:update_my_self(data,count)
	self.count = #data
	self.index = index
	self.data = data
	if data.type == UnitStateEumn.Type.Star then
		self.name.text = DataMap.data_list[data.mapid].name
		self.desc.text = string.format("%s/%s", #data.stars, data.num)
	elseif data.type == UnitStateEumn.Type.Boss then
		local cfg_data = DataBoss.data_base[data.id]
		self.name.text = DataUnit.data_unit[data.id].name
		self.desc.text = string.format(TI18N("挑战等级(%s级)"), cfg_data.lev)
	elseif data.type == UnitStateEumn.Type.Robber then
		self.name.text = TI18N("公会领地")
		self.desc.text = string.format("%s/%s", data.left_num, data.num)
	elseif data.type == UnitStateEumn.Type.Fox then
		self.name.text = DataMap.data_list[data.mapid].name
		self.desc.text = string.format("数量: %s", #data.camp_unit)
	elseif data.type == UnitStateEumn.Type.Cold then
		self.name.text = DataMap.data_list[data[1].map_id].name
		self.desc.text = string.format("数量: %s",self.count)
	elseif data.type == UnitStateEumn.Type.StarTrial then
		self.name.text = DataMap.data_list[data.mapid].name
		self.desc.text = string.format("数量: %s",self.count)
	elseif data.type == UnitStateEumn.Type.MoonStar then
		self.name.text = DataMap.data_list[data.mapid].name
		self.desc.text = string.format("数量: %s",self.count)
	end
end