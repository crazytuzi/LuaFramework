
KuafuGuildBattleScenePanle = KuafuGuildBattleScenePanle or BaseClass(BaseView)

function KuafuGuildBattleScenePanle:__init()
	self.active_close = false
	self.ui_config = {"uis/views/kuafuliujie", "SceneMap"}

	self.item_list = {}
end

-- 销毁前调用
function KuafuGuildBattleScenePanle:ReleaseCallBack()
	self.btn_open = nil

	if self.change_scene_handle then
		GlobalEventSystem:UnBind(self.change_scene_handle)
		self.change_scene_handle = nil
	end

	if self.fight_state_button_handle then
		GlobalEventSystem:UnBind(self.fight_state_button_handle)
		self.fight_state_button_handle = nil
	end
end

function KuafuGuildBattleScenePanle:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

-- 打开后调用
function KuafuGuildBattleScenePanle:OpenCallBack()
	self:ActionComplete()
end

function KuafuGuildBattleScenePanle:LoadCallBack()
	self.item_list = {}
	for i = 1, 8 do
		self.item_list[i] = KuafuSceneItemRender.New(self:FindObj("item_" .. i))	
	end
	self.btn_open = self:FindObj("BtnOpen")

	self:ListenEvent("OnClickOpen", BindTool.Bind(self.OnClickOpen, self))

	self.change_scene_handle = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind(self.OnSceneChangeComplete, self))
	self.fight_state_button_handle = GlobalEventSystem:Bind(MainUIEventType.FIGHT_STATE_BUTTON, BindTool.Bind(self.CheckFightState, self))
end

function KuafuGuildBattleScenePanle:OnFlush()
	if self.item_list and next(self.item_list) then
		for i = 1, 8 do
			self.item_list[i]:SetData(i)
		end
	end
end

function KuafuGuildBattleScenePanle:CheckFightState(is_on)
	if self.root_node then
		self.root_node:SetActive(not is_on)
	end
end

function KuafuGuildBattleScenePanle:OnSceneChangeComplete(old_scene, new_scene)
	self:Flush()
end

function KuafuGuildBattleScenePanle:OnClickOpen()
	local rotate = self.btn_open.toggle.isOn and 45 or 0
		self.rotate_tween = self.btn_open.transform:DOLocalRotate(
		Vector3(0, 0, rotate), 0.5, DG.Tweening.RotateMode.FastBeyond360)

		-- self.rotate_tween:OnComplete(BindTool.Bind(self.ActionComplete, self))
end

function KuafuGuildBattleScenePanle:ActionComplete()
	if self.rotate_tween then
		self.rotate_tween:Pause()
		self.rotate_tween = nil
	end
	local rotate = self.btn_open.toggle.isOn and 45 or 0
	self.btn_open.transform.localRotation = Quaternion.Euler(0, 0, rotate)
end

-------------------------------------------------------------------------------------------
KuafuSceneItemRender = KuafuSceneItemRender or BaseClass(BaseRender)
function KuafuSceneItemRender:__init()
	self.num = self:FindVariable("num")
	self.map_name = self:FindVariable("map_name")
	self.is_at_scene = self:FindVariable("is_at_scene")
	self:ListenEvent("UpXunluState",BindTool.Bind(self.UpXunluState, self))
end

function KuafuSceneItemRender:__delete()
end

function KuafuSceneItemRender:OnFlush()
	--local guild_num = KuafuGuildBattleData.Instance:GetCurGuildNum(self.index - 1)
	--self.num:SetValue(guild_num)
	if self.index then
		local map_info = KuafuGuildBattleData.Instance:GetMapInfo(self.index - 1)
		self.is_at_scene:SetValue(map_info.scene_id == Scene.Instance:GetSceneId())
		self.map_name:SetValue(map_info.scene_name)
	end
end

function KuafuSceneItemRender:SetData(data)
	if data then
		self.index = data
		self:Flush()
	end
end

function KuafuSceneItemRender:UpXunluState()
	if self.index then
		local map_info = KuafuGuildBattleData.Instance:GetMapInfo(self.index - 1)
		if nil ~= map_info then
			GuajiCtrl.Instance:StopGuaji()
			GuajiCtrl.Instance:ClearAllOperate()
			MoveCache.end_type = MoveEndType.Auto
			GuajiCtrl.Instance:MoveToScenePos(map_info.scene_id, map_info.relive_pos_x, map_info.relive_pos_y)
		end
	end
end