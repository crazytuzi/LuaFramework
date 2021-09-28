
YewaiGuajiView = YewaiGuajiView or BaseClass(BaseView)
function YewaiGuajiView:__init()
	self.ui_config = {"uis/views/yewaiguaji_prefab","YeWaiGuaJi"}
	self.full_screen = false
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
end

function YewaiGuajiView:__delete()

end

function YewaiGuajiView:LoadCallBack()
	self.map_chosen_item_list = {}
	self.desc = self:FindVariable("Desc")
	self:ListenEvent("Closen", BindTool.Bind(self.CloseView,self))
	for i=1,3 do
		local item = self:FindObj("MapChosenItem_"..i)
		self.map_chosen_item_list[i] = MapChosenItem.New(item)
		self.map_chosen_item_list[i]:SetIndex(i)
	end
end

function YewaiGuajiView:ReleaseCallBack()
	for i=1,3 do
		if self.map_chosen_item_list[i] ~= nil then
			self.map_chosen_item_list[i]:DeleteMe()
			self.map_chosen_item_list[i] = nil
		end		
	end

	self.desc = nil
end

function YewaiGuajiView:OpenCallBack()
	local guaji_list = YewaiGuajiData.Instance:GetGuaJiSceneIdList()
	YewaiGuajiCtrl.Instance:SendGuajiBossCountReq(guaji_list)
	local map_chosen_info = YewaiGuajiData.Instance:GetGuaJiPosList()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	local command_index = 0
	
	for i=1,3 do
		-- 获取等级范围
		local  map_level_list = {}
		local min_zhuangsheng = math.floor(map_chosen_info[i].min_level)
		table.insert(map_level_list, min_zhuangsheng)

		-- 赋值
		self.map_chosen_item_list[i]:SetIsban(i)
		local is_not_ban = self.map_chosen_item_list[i]:GetIsban()
		if is_not_ban then
			self.map_chosen_item_list[i]:SetMapLevel(map_level_list)
			self.map_chosen_item_list[i]:SetTitle()
			self.map_chosen_item_list[i]:SetStandardExp()
			self.map_chosen_item_list[i]:SetBlueNum()
			self.map_chosen_item_list[i]:SetPurpleNum()
			self.map_chosen_item_list[i]:SetMapImage()
			self.map_chosen_item_list[i]:SetEquipmentLevel()
			self.map_chosen_item_list[i]:SetTripleExpFlag()
			if my_level >= map_chosen_info[i].level_limit then 	
				command_index = i 
			end
		end
		self.map_chosen_item_list[i]:SetIsRecommend(false)
	end

	if command_index ~= 0 then
		self.map_chosen_item_list[command_index]:SetIsRecommend(true)
	end
	self:SetDesc()
end

function YewaiGuajiView:SetSceneBossCount()
	local boss_num_info = YewaiGuajiData.Instance:GetSceneBossInfo()
	for i = 1, GameEnum.GUAJI_SCENE_COUNT do
		local is_not_ban = self.map_chosen_item_list[i]:GetIsban()
		if is_not_ban then
			local num = boss_num_info[i] or 0
			self.map_chosen_item_list[i]:SetBossNum(num)
		end
	end
end

function YewaiGuajiView:OnFlush(param_t)
	
end

function YewaiGuajiView:SetDesc()
	local data = ActivityData.Instance:GetClockActivityByID(ACTIVITY_TYPE.ACTIVITY_TYPE_TRIPLE_GUAJI)
	if nil == data then
		return
	end

	self.desc:SetValue(string.format(Language.Common.YeWaiGuaJiDesc, data.open_time, data.end_time))
end

function YewaiGuajiView:CloseView()
	self:Close()
end

------------------------------------------------------------------------
MapChosenItem = MapChosenItem or BaseClass(BaseCell)
function MapChosenItem:__init()
	self.title = self:FindVariable("title")
	self.map_level_list = {}
	for i = 1,2 do
		self.map_level_list[i] = self:FindVariable("map_level_" .. i)
	end
	self.is_recommend = self:FindVariable("is_recommend")
	self.is_not_ban = self:FindVariable("is_not_ban")
	self.btn_text = self:FindVariable("btn")
	self.level_limit = self:FindVariable("level_limit")
	self.map_img = self:FindVariable("map_img")
	self.is_not_img = self:FindVariable("is_not_img")
	self.tuijian_img = self:FindVariable("tuijian_img")
	self.standard_exp = self:FindVariable("standard_exp")
	self.blue_num = self:FindVariable("blue_num")
	self.purple_num = self:FindVariable("purple_num")
	self.equipment_level = self:FindVariable("equipment_level")
	self.boss_num = self:FindVariable("boss_num")
	self.triple_exp_flag = self:FindVariable("triple_exp_flag")
	self:ListenEvent("GoGuaji",BindTool.Bind(self.GoGuaji,self))
	self.is_ban = false
	self.tuijian_img:SetAsset("uis/views/yewaiguaji/images_atlas","tuijian")
end

function MapChosenItem:__delete()
	self.title = nil
	self.map_level = nil
	self.is_recommend = nil
	self.is_not_ban = nil
	self.index = nil
	self.equipment_level = nil
	self.boss_num = nil
end

function MapChosenItem:SetTitle()
	local scene_name = YewaiGuajiData.Instance:GetGuaJiSceneName(self.index, self.guaiwuIndex)
	self.title:SetValue(scene_name)
end

function MapChosenItem:SetIndex(index)
	self.index = index
	self.guaiwuIndex = YewaiGuajiData.Instance:GetGuaiwuIndex(index)
end

function MapChosenItem:SetMapLevel(value)
	self.map_level_list[1]:SetValue(PlayerData.GetLevelString(value[1]))
end

function MapChosenItem:SetLevelLimit()
	local x = YewaiGuajiData.Instance:GetMapLevelLimit(self.index)
	self.level_limit:SetValue(PlayerData.GetLevelString(x))
end

function MapChosenItem:SetStandardExp()
	local exp = YewaiGuajiData.Instance:GetStanderdExp(self.index, self.guaiwuIndex)
	self.standard_exp:SetValue(math.floor(exp / 10000 + 0.5))
end

function MapChosenItem:SetBlueNum()
	local num = YewaiGuajiData.Instance:GetEquipNum(self.index, self.guaiwuIndex)
	self.blue_num:SetValue(num)
end

function MapChosenItem:SetPurpleNum()
	local temp, num = YewaiGuajiData.Instance:GetEquipNum(self.index, self.guaiwuIndex)
	self.purple_num:SetValue(num)
end

function MapChosenItem:SetMapImage()
	local value = YewaiGuajiData.Instance:GetMap(self.index)
	local bundle, asset =  ResPath.GetYewaiGuajiMap(value)
	self.map_img:SetAsset(bundle,asset)
end

function MapChosenItem:SetIsban()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	local map_level_limit = YewaiGuajiData.Instance:GetMapLevelLimit(self.index)

	if(my_level < map_level_limit) then
		self.is_not_ban:SetValue(false)
		self.is_ban = false
		self:SetLevelLimit()
	else
		self.is_not_ban:SetValue(true)
		self.is_ban = true
	end
	self:SetMapImage()
	self.is_not_img:SetValue(true)
end	

function MapChosenItem:GetIsban()
	return self.is_ban
end

function MapChosenItem:SetIsRecommend(value)
	self.is_recommend:SetValue(value)
end

function MapChosenItem:SetEquipmentLevel()
	local value = YewaiGuajiData.Instance:GetEquipmentLevel(self.index, self.guaiwuIndex)
	self.equipment_level:SetValue(CommonDataManager.GetDaXie(value))
end

function MapChosenItem:SetBossNum(num)
	local num = num or 0
	self.boss_num:SetValue(num)
end

function MapChosenItem:SetTripleExpFlag()
	local flag = YewaiGuajiData.Instance:GetTripleExpFlag()
	self.triple_exp_flag:SetValue(flag)
end

-- 点击挂机按钮
function MapChosenItem:GoGuaji()
	local guaji_pos = YewaiGuajiData.Instance:GetGuajiPos(self.index, self.guaiwuIndex)
	YewaiGuajiData.Instance:SetGuaJiSceneId(guaji_pos[1])
	KuafuGuildBattleCtrl.Instance:CSReqMonsterGeneraterList(guaji_pos[1])
	YewaiGuajiCtrl.Instance:GoGuaji(guaji_pos[1],guaji_pos[2],guaji_pos[3])
end