KuafuGuildBattleScenePanle = KuafuGuildBattleScenePanle or BaseClass(BaseView)

local MAP_MAX_NUM = 6

-- 场景id对应Index
local MAP_INDEX_SCENE_ID = {
	[1450] = 1,		--缥缈皇城
	[1460] = 2,		--冰雪原
	[1461] = 3,		--焚炎谷
	[1462] = 4,		--神木林
	[1463] = 5,		--时之沙
	[1464] = 6,		--巨岩崖
}

function KuafuGuildBattleScenePanle:__init()
	self.active_close = false
	self.ui_config = {"uis/views/kuafuliujie_prefab","SceneMap"}
	self.view_layer = UiLayer.MainUIHigh
	self.item_list = {}
	self.change_scene_handle = nil
	self.fight_state_button_handle = nil
end

-- 销毁前调用
function KuafuGuildBattleScenePanle:ReleaseCallBack()
	if KuafuGuildBattleData.Instance then
		KuafuGuildBattleData.Instance:SetSceneMapState(true)
	end
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	for k,v in pairs(self.flag_group_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	self.flag_group_list = {}
	self.show_panel = nil
	self.map = nil
	self.move_obj = nil
	self.tween = nil

	GlobalEventSystem:UnBind(self.change_scene_handle)
	self.change_scene_handle = nil
	GlobalEventSystem:UnBind(self.fight_state_button_handle)
	self.fight_state_button_handle = nil
	GlobalEventSystem:UnBind(self.show_mode_list_event)
	self.show_mode_list_event = nil

end

function KuafuGuildBattleScenePanle:__delete()

end

-- 打开后调用
function KuafuGuildBattleScenePanle:OpenCallBack()
	self:ActionComplete()
	self.map_state = KuafuGuildBattleData.Instance:GetSceneMapState()
	self.show_panel:SetValue(true)
end

function KuafuGuildBattleScenePanle:LoadCallBack()
	self.item_list = {}
	for i = 1, MAP_MAX_NUM do
		self.item_list[i] = KuafuSceneItemRender.New(self:FindObj("item_" .. i))
	end

	self.flag_group_list = {}
	for i = 1, MAP_MAX_NUM do
		self.flag_group_list[i] = KuafuSceneFlagGroupRender.New(self:FindObj("flag_group_" .. i))
	end

	self.map = self:FindObj("Map")
	self.move_obj = self:FindObj("MoveObj")

	self.show_panel = self:FindVariable("ShowPanel")

	self:ListenEvent("OnClickOpen", BindTool.Bind(self.OnClickOpen, self))

	self.change_scene_handle = GlobalEventSystem:Bind(SceneEventType.SCENE_ALL_LOAD_COMPLETE, BindTool.Bind1(self.OnSceneChangeComplete, self))
	self.fight_state_button_handle = GlobalEventSystem:Bind(MainUIEventType.FIGHT_STATE_BUTTON, BindTool.Bind(self.CheckFightState, self))
	self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, BindTool.Bind(self.OnMainUIModeListChange, self))
end

function KuafuGuildBattleScenePanle:OnFlush()
	for i = 1, MAP_MAX_NUM do
		self.item_list[i]:SetData(i)
	end

	local flag_data = KuafuGuildBattleData.Instance:GetGuildBattleSceneMapInfo()
	if nil == flag_data then return end

	local flag_index = MAP_INDEX_SCENE_ID[flag_data.scene_id]
	if nil == flag_index then return end
	if self.flag_group_list[flag_index] then
		self.flag_group_list[flag_index]:SetFlagStatus(flag_data.occupy_list)
	end
end

function KuafuGuildBattleScenePanle:CheckFightState(is_on)
	if self.root_node then
		self.root_node:SetActive(not is_on)
	end
end

function KuafuGuildBattleScenePanle:OnSceneChangeComplete(is_on)
	self:Flush()
end

function KuafuGuildBattleScenePanle:OnClickOpen()
	if self.map == nil or self.move_obj == nil then
		return
	end
	self.map_state = not self.map_state
	KuafuGuildBattleData.Instance:SetSceneMapState(self.map_state)

	local move_w = self.map.transform:GetComponent(typeof(UnityEngine.RectTransform)).rect.width or 0
	local move_dis = self.map_state and -1 or 1
	local start_x = self.move_obj.transform.localPosition.x
	local move_value = start_x + move_dis * move_w

	self.tween = self.move_obj.transform:DOLocalMoveX(move_value, 0.5)
	self.tween:SetEase(DG.Tweening.Ease.Linear)

	-- local rotate = self.btn_open.toggle.isOn and 45 or 0
	-- 	self.rotate_tween = self.btn_open.transform:DOLocalRotate(
	-- 	Vector3(0, 0, rotate), 0.5, DG.Tweening.RotateMode.FastBeyond360)

		-- self.rotate_tween:OnComplete(BindTool.Bind(self.ActionComplete, self))
end

function KuafuGuildBattleScenePanle:ActionComplete()
	if self.tween then
		self.tween:Pause()
		self.tween = nil
	end

	-- local rotate = self.btn_open.toggle.isOn and 45 or 0
	-- self.btn_open.transform.localRotation = Quaternion.Euler(0, 0, rotate)
end

function KuafuGuildBattleScenePanle:OnMainUIModeListChange(is_show)
	self.show_panel:SetValue(is_show)
end

-------------------------------------------------------------------------------------------
KuafuSceneItemRender = KuafuSceneItemRender or BaseClass(BaseRender)
function KuafuSceneItemRender:__init()
	self.num = self:FindVariable("num")
	self.map_name = self:FindVariable("map_name")
	self.is_at_scene = self:FindVariable("is_at_scene")
	self:ListenEvent("UpXunluState",BindTool.Bind(self.UpXunluState, self))
	self.index = 1
end

function KuafuSceneItemRender:__delete()
end

function KuafuSceneItemRender:OnFlush()
	--local guild_num = KuafuGuildBattleData.Instance:GetCurGuildNum(self.index - 1)
	--self.num:SetValue(guild_num)

	local map_info = KuafuGuildBattleData.Instance:GetMapInfo(self.index - 1)
	self.is_at_scene:SetValue(map_info.scene_id == Scene.Instance:GetSceneId())

	local scene_cfg = ConfigManager.Instance:GetSceneConfig(map_info.scene_id)
	if nil ~= scene_cfg then
		self.map_name:SetValue(scene_cfg.name)
	end
end

function KuafuSceneItemRender:SetData(data)
	self.index = data
	self:Flush()
end

function KuafuSceneItemRender:UpXunluState()
	local map_info = KuafuGuildBattleData.Instance:GetMapInfo(self.index - 1)
	if nil ~= map_info and nil ~= map_info.scene_id then
		GuajiCtrl.Instance:StopGuaji()
		GuajiCtrl.Instance:ClearAllOperate()

		local scene_id = Scene.Instance:GetSceneId()
		if scene_id == map_info.scene_id then
			GuajiCtrl.Instance:MoveToScenePos(map_info.scene_id, map_info.relive_pos_x, map_info.relive_pos_y)
		else
			KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_GOTO_SCENE, map_info.city_index)
		end
	end
end

---------------------------------------------------------------------------
KuafuSceneFlagGroupRender = KuafuSceneFlagGroupRender or BaseClass(BaseRender)

function KuafuSceneFlagGroupRender:__init()
	self.flag_group = {}
	for i = 1, 3 do
		self.flag_group[i] = self:FindVariable("IsShowFlag" .. i)
	end
end

function KuafuSceneFlagGroupRender:__delete()
end

function KuafuSceneFlagGroupRender:SetFlagStatus(occupy_list)
	if nil == occupy_list then return end
	local guild_name = GameVoManager.Instance:GetMainRoleVo().guild_name
	for k,v in pairs(occupy_list) do
		if self.flag_group[k] then
			self.flag_group[k]:SetValue(guild_name == v.guild_name)
		end
	end
end