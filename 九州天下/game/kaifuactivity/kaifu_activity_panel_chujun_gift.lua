KaifuActivityPanelChuJunGift = KaifuActivityPanelChuJunGift or BaseClass(BaseRender)

local MODEL_CFG = {
	[1] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(0.7, 0.7, 0.7),
	},
	[2] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(0.8, 0.8, 0.8),
	},
	[3] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(0.7, 0.7, 0.7),
	},
}
function KaifuActivityPanelChuJunGift:__init(instance)
	self.cell_list = {}
	self.model_view = {}
	self.item_cell_list = {}
end

function KaifuActivityPanelChuJunGift:LoadCallBack()
	self.role_id_list = {}
	self.chujun_list = {}
	self.item_list = {}
	self.role_name = {}									--諸君名字
	self.role_info_list = {}

	self.is_chujun = self:FindVariable("is_chujun")
	self.time_desc = self:FindVariable("time_desc")
	self.desc_1 = self:FindVariable("desc_1")
	self.desc_2 = self:FindVariable("desc_2")
	self.zhaoji_level = self:FindVariable("zhaoji_level")
	self.zhaoji_cd = self:FindVariable("zhaoji_cd")
	self.show_zhaoji_cd = self:FindVariable("show_zhaoji_cd")
	self.zhaoji_btn = self:FindObj("zhaoji_btn")

	self.leftBarList = {}
	for i = 1, 4 do
		self.leftBarList[i] = {}
		self.leftBarList[i].select_btn = PermissionItem.New(self:FindObj("select_btn_" .. i))
		self.leftBarList[i].list = self:FindObj("list_" .. i)
		self:ListenEvent("select_btn_" .. i ,BindTool.Bind(self.OnClickSelect, self, i))
	end

	self.title_asset = {}
	self.has_chujun = {}
	self.display = {}
	for i = 1, 3 do
		self.title_asset[i] = self:FindVariable("title_asset_" .. i)
		self.has_chujun[i] = self:FindVariable("has_chujun_" .. i)
		self.role_name[i] = self:FindVariable("role" .. i .. "_name")

		self.display[i] = self:FindObj("display" .. i)
		self.model_view[i] = RoleModel.New()
		self.model_view[i]:SetDisplay(self.display[i].ui3d_display)
	end

	self.task_list = self:FindObj("task_list")
	self.task_list_view_delegate = self.task_list.list_simple_delegate
	self.task_list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.task_list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self:ListenEvent("OnClickJingXuan", BindTool.Bind(self.OnClickJingXuan, self))
	self:ListenEvent("OnClickZhaoJi", BindTool.Bind(self.OnClickZhaoJi, self))
	self:ListenEvent("OnClickDescTip", BindTool.Bind(self.OnClickDescTip, self))
	--self.role_info = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfo, self))

	self.timer_quest = GlobalTimerQuest:AddRunQuest(function() self:TimerCallback() end, 1)
	self.zhaoji_time_quest = GlobalTimerQuest:AddRunQuest(function() self:ZhaoJiTimerCallback() end, 1)

	self:UpdateList()
end

function KaifuActivityPanelChuJunGift:__delete()
	for k, v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end

	self.cell_list = {}

	for k,v in pairs(self.model_view) do
		if v ~= nil then
			v:DeleteMe()
		end
	end
	self.model_view = {}

	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	if self.zhaoji_time_quest then
		GlobalTimerQuest:CancelQuest(self.zhaoji_time_quest)
		self.zhaoji_time_quest = nil
	end

	-- if self.role_info then
	-- 	GlobalEventSystem:UnBind(self.role_info)
	-- 	self.role_info = nil
	-- end

	for _,v in pairs(self.item_cell_list) do
		if v[1] then
			v[1]:DeleteMe()
		end
	end
	self.item_cell_list = {}

	if self.leftBarList then
		for k,v in pairs(self.leftBarList) do
			if v.select_btn then
				v.select_btn:DeleteMe()
			end
		end
		self.leftBarList = {}
	end
end

function KaifuActivityPanelChuJunGift:UpdateList()
	local cfg = KaifuActivityData.Instance:GetChujunGiftDesCfg()
	self.item_list = {}
	self.item_cell_list = {}

	for i = 1, 4 do
		self.leftBarList[i].select_btn:SetActive(true)
		self.leftBarList[i].select_btn:SetData(cfg[i])
		self:LoadCell(i)
	end
end

function KaifuActivityPanelChuJunGift:RoleInfo(role_id, protocol)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	for k, v in pairs(self.role_id_list) do
		if v == role_id then return end
	end

	if vo.camp == protocol.camp_id then
		if self.model_view[2] then
			self.model_view[2]:SetModelResInfo(protocol, false, true, false, false, true)
			local job_cfgs = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
			local role_job = job_cfgs[protocol.prof]
			local role_res_id = role_job["model" .. protocol.sex]
 			self.model_view[2]:SetTransform(MODEL_CFG[2])
			self.chujun_list[2] = true
			self.role_name[2]:SetValue(protocol.role_name)
		end
	else
		if not self.chujun_list[1] then
			self.model_view[1]:SetModelResInfo(protocol, false, true, false, false, true)
			local job_cfgs = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
			local role_job = job_cfgs[protocol.prof]
			local role_res_id = role_job["model" .. protocol.sex]
 			self.model_view[1]:SetTransform(MODEL_CFG[1])
			self.chujun_list[1] = true
			self.role_name[1]:SetValue(protocol.role_name)
		elseif not self.chujun_list[3] then
			self.model_view[3]:SetModelResInfo(protocol, false, true, false, false, true)
			local job_cfgs = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
			local role_job = job_cfgs[protocol.prof]
			local role_res_id = role_job["model" .. protocol.sex]
 			self.model_view[3]:SetTransform(MODEL_CFG[3])
			self.chujun_list[3] = true
			self.role_name[3]:SetValue(protocol.role_name)
		end
	end

	-- local vo = GameVoManager.Instance:GetMainRoleVo()
	self.is_chujun:SetValue(self.chujun_list[2] or false)

	self:FlushDesc()
end

function KaifuActivityPanelChuJunGift:OnClickSelect(index)
end

function KaifuActivityPanelChuJunGift:LoadCell(index)
	local cfg = KaifuActivityData.Instance:GetChujunGiftDesCfg()
	if cfg and cfg[index] then
		self.item_cell_list[index] = {}
		PrefabPool.Instance:Load(AssetID("uis/views/kaifuactivity_prefab", "PermissionDescItem"), function(prefab)
			if prefab then
				local obj = GameObject.Instantiate(prefab)
				PrefabPool.Instance:Free(prefab)
				
				local obj_transform = obj.transform
				obj_transform:SetParent(self.leftBarList[index].list.transform, false)
				local item_cell = PermissionDescItem.New(obj)
				if cfg ~= nil and index ~= nil and cfg[index] ~= nil then
					item_cell:SetData(cfg[index])
				end
				self.item_list[#self.item_list + 1] = obj_transform
				if index ~= nil and self.item_cell_list[index] ~= nil then
					self.item_cell_list[index][1] = item_cell
				end
			end
		end)
	end
end

function KaifuActivityPanelChuJunGift:GetNumberOfCells()
	return #KaifuActivityData.Instance:GetChujunTaskList()
end

function KaifuActivityPanelChuJunGift:RefreshView(cell, data_index)
	data_index = data_index + 1

	local task_cell = self.cell_list[cell]
	if task_cell == nil then
		task_cell = ChuJunTaskItemCell.New(cell.gameObject)
		self.cell_list[cell] = task_cell
	end
	local data = KaifuActivityData.Instance:GetChujunTaskList()
	task_cell:SetData(data[data_index])
	task_cell:SetIndex(data_index)
end

function KaifuActivityPanelChuJunGift:SetCurTyoe(cur_type)
	self.cur_type = cur_type
end

function KaifuActivityPanelChuJunGift:OnFlush()
	local activity_type = self.cur_type
	self.activity_type = activity_type or self.activity_type

	local list = KaifuActivityData.Instance:GetChujunIdList()
	for k, v in pairs(list) do
		if v ~= 0 then
			CheckCtrl.Instance:SendQueryRoleInfoReq(v)
		end
	end

	self:FlushDisplayPanel()
	self.task_list.scroller:ReloadData(0)
	self:FlushDesc()
	self:ZhaoJiTimerCallback()
end


function KaifuActivityPanelChuJunGift:FlushDisplayPanel()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local chujun_info = KaifuActivityData.Instance:GetChujunGiftInfo()
	local flag_index = 0
	for i = 1, 3 do
		if vo.camp == i then
			local bundle, asset = ResPath.GetKaiFuActivityRes("my_camp_" .. i)
			self.has_chujun[2]:SetValue(chujun_info.crown_prince_info_list[i].uid ~= 0)
			self.title_asset[2]:SetAsset(bundle, asset)
			flag_index = i
		end
	end

	local list = {}
	for i = 1, 3 do
		if i ~= flag_index then
			table.insert(list, i)
		end
	end

	local bundle, asset = ResPath.GetKaiFuActivityRes("camp_name_" .. list[1])
	self.has_chujun[1]:SetValue(chujun_info.crown_prince_info_list[list[1]].uid ~= 0)
	self.title_asset[1]:SetAsset(bundle, asset)
	local bundle, asset = ResPath.GetKaiFuActivityRes("camp_name_" .. list[2])
	self.has_chujun[3]:SetValue(chujun_info.crown_prince_info_list[list[2]].uid ~= 0)
	self.title_asset[3]:SetAsset(bundle, asset)
end

function KaifuActivityPanelChuJunGift:FlushDesc()
	local cfg = KaifuActivityData.Instance:GetChujunGiftCfg()
	local camp_cfg = CampData.Instance:GetCampOtherCfg()
	if self.chujun_list[2] then
		self.desc_1:SetValue(Language.ChuJunGift.Desc1)
	else
		self.desc_1:SetValue(Language.ChuJunGift.XuWeiYiDai)
	end
	self.desc_2:SetValue(string.format(Language.ChuJunGift.Desc2, cfg.compete_level_limit))
	self.zhaoji_level:SetValue(string.format(Language.ChuJunGift.ZhaoJiDesc, camp_cfg.receive_call_level_limit))
end

function KaifuActivityPanelChuJunGift:OnClickJingXuan()
	local ok_fun = function ()
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHUJUN_GIFT, RA_CHUJUN_GIFT_REQ_TYPE.RA_CHUJUN_GIFT_REQ_TYPE_COMPETE)
	end
	local cfg = KaifuActivityData.Instance:GetChujunGiftCfg()
	TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, string.format(Language.ChuJunGift.JingXuanChuJun, cfg.compete_need_gold))
end

function KaifuActivityPanelChuJunGift:OnClickZhaoJi()
	local ok_fun = function ()
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHUJUN_GIFT, RA_CHUJUN_GIFT_REQ_TYPE.RA_CHUJUN_GIFT_REQ_TYPE_MUSTER)
	end

	local cfg = KaifuActivityData.Instance:GetChujunGiftCfg()
	if UnityEngine.PlayerPrefs.GetInt("show_zhaojiChunjun") == 1 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHUJUN_GIFT, RA_CHUJUN_GIFT_REQ_TYPE.RA_CHUJUN_GIFT_REQ_TYPE_MUSTER)
	else
		TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, string.format(Language.ChuJunGift.SpendGold,cfg.muster_need_gold), nil, nil, true,false, "show_zhaojiChunjun")
	end
end

function KaifuActivityPanelChuJunGift:OnClickDescTip()
	TipsCtrl.Instance:ShowHelpTipView(197)
end

function KaifuActivityPanelChuJunGift:TimerCallback()
	local data = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHUJUN_GIFT)
	if data then
		local time_desc = TimeUtil.FormatSecond2Str(data.next_time - TimeCtrl.Instance:GetServerTime())
		local str = string.format(Language.ChuJunGift.LeftTimeDesc, time_desc)
		self.time_desc:SetValue(str)
	end
end

function KaifuActivityPanelChuJunGift:ZhaoJiTimerCallback()
	local chujun_info = KaifuActivityData.Instance:GetChujunGiftInfo()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if chujun_info and chujun_info.muster_timestamp_list then
		local vo = GameVoManager.Instance:GetMainRoleVo()
		local uid = chujun_info.crown_prince_info_list[vo.camp].uid
		-- 判断是否储君
		if uid ~= vo.role_id then
			self.show_zhaoji_cd:SetValue(false)
			self.zhaoji_btn.button.interactable = false
			self.zhaoji_btn.grayscale.GrayScale = 255
		else
			local left_time = chujun_info.muster_timestamp_list[vo.camp] - TimeCtrl.Instance:GetServerTime()
			if left_time <= 0 then
				self.zhaoji_btn.button.interactable = true
				self.zhaoji_btn.grayscale.GrayScale = 0
			else 
				local time_desc = TimeUtil.FormatSecond2Str(left_time)
				if left_time < 1 then
					self.show_zhaoji_cd:SetValue(false)
				else
					self.show_zhaoji_cd:SetValue(true)
				end
				self.zhaoji_cd:SetValue(time_desc)
				self.zhaoji_btn.button.interactable = false
				self.zhaoji_btn.grayscale.GrayScale = 255
			end
		end
	end
end

-----------------PermissionItem----------------------------------
PermissionItem = PermissionItem or BaseClass(BaseCell)
function PermissionItem:__init(instance)
	self.name = self:FindVariable("name")
end

function PermissionItem:__delete()
	-- body
end

function PermissionItem:OnFlush()
	if nil == self.data or nil == next(self.data) then return end
	self.name:SetAsset(ResPath.GetKaiFuActivityRes("name_" .. self.data.seq))
end

-----------------PermissionDescItem-------------------------------
PermissionDescItem = PermissionDescItem or BaseClass(BaseCell)
function PermissionDescItem:__init(instance)
	self.desc = self:FindVariable("desc")
end

function PermissionDescItem:__delete()
	-- body
end

function PermissionDescItem:OnFlush()
	if nil == self.data or nil == next(self.data) then return end
	self.desc:SetValue(self.data.des)
end

----------------------ChuJunTaskItemCell------------------------------
ChuJunTaskItemCell = ChuJunTaskItemCell or BaseClass(BaseCell)

function ChuJunTaskItemCell:__init()
	self.task_name = self:FindVariable("task_name")
	self.can_fetch = self:FindVariable("can_fetch")
	self.fetch_text = self:FindVariable("fetch_text")
	self.reward_btn = self:FindObj("reward_btn")
	self.reward_cell = ItemCell.New()
	self.reward_cell:SetInstanceParent(self:FindObj("reward_item"))
	self:ListenEvent("OnClickReward", BindTool.Bind(self.OnClickReward, self))


	local chujun_info = KaifuActivityData.Instance:GetChujunGiftInfo()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if chujun_info and chujun_info.muster_timestamp_list then
		local vo = GameVoManager.Instance:GetMainRoleVo()
		self.uid = vo.role_id
		self.chujun_uid = chujun_info.crown_prince_info_list[vo.camp].uid
	end
end

function ChuJunTaskItemCell:__delete()
	if self.reward_cell then
		self.reward_cell:DeleteMe()
		self.reward_cell = nil
	end
end

function ChuJunTaskItemCell:OnClickReward()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHUJUN_GIFT, RA_CHUJUN_GIFT_REQ_TYPE.RA_CHUJUN_GIFT_REQ_TYPE_FETCHT_REWARD, self.index - 1)
end

function ChuJunTaskItemCell:OnFlush()
	if nil == self.data or nil == next(self.data) then return end
	self.task_name:SetValue(self.data.desc)
	if self.data.is_finish_task == 1 and self.uid == self.chujun_uid then
		self.reward_btn.button.interactable = self.data.is_fetch_reward == 0
	else
		self.reward_btn.button.interactable = false
	end
	self.fetch_text:SetValue(self.data.is_fetch_reward == 1 and ToColorStr(Language.Common.YiLingQu, COLOR.WHITE) or Language.Common.LingQu)
	self.reward_cell:SetData({item_id = 65533, num = self.data.gold_num, is_bind = 0})
end
