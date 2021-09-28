MeiLiContentView = MeiLiContentView or BaseClass(BaseRender)

local FIX_SHOW_TIME = 8
local FIRST_PAGE_RANK_NUM = 5
local NORMAL_PAGE_RANK_NUM = 6

function MeiLiContentView:__init(instance)
	self.cur_type = -1
	self.cur_index = 0
	self.cur_page = 1
	self.parent_tab_index = 0

	self.toggle_cell_list = {}
	self.first_cell_list = {}
	self.cell_list = {}

	self.is_first_page = self:FindVariable("is_first_page")
	self.cur_page_value = self:FindVariable("cur_page")
	self.cur_page_value:SetValue(self.cur_page)
	self.my_rank = self:FindVariable("my_rank")
	self.cur_capability = self:FindVariable("cur_capability")
	self.last_day_capability = self:FindVariable("last_day_capability")
	self.col_name = self:FindVariable("col_name")
	self.rank_name = self:FindVariable("rank_name")
	self.title_img_res = self:FindVariable("title_img_res")
	self.col_name_img = self:FindVariable("col_name_img")
	self.top_rank_name = {}
	self.top_rank_value = {}
	self.top_rank_img_res = {}
	self.top_rank_custom_res = {}
	self.is_show_role_head = {}
	self.is_show_role_photo = {}
	self.top_rank_avatar_key = {}
	self.rank_image = {}
	self.rank_def_image = {}
	for i = 1, 3 do
		self.top_rank_name[i] = self:FindVariable("top_rank_name" .. i)
		self.top_rank_value[i] = self:FindVariable("top_rank_value" .. i)
		self.top_rank_img_res[i] = self:FindVariable("top_rank_img_res" .. i)
		self.top_rank_custom_res[i] = self:FindVariable("top_rank_custom_res" .. i)
		self.is_show_role_head[i] = self:FindVariable("is_show_role_head" .. i)
		self.is_show_role_photo[i] = self:FindVariable("is_show_role_photo" .. i)
		self.rank_image[i] = self:FindObj("TopImage" .. i)
		self.rank_def_image[i] = self:FindObj("TopDefImage" .. i)

		self:ListenEvent("OnCheckRole" .. i, BindTool.Bind(self.OnCheckRole, self, i))
		self:ListenEvent("OnSendFlower" .. i, BindTool.Bind(self.OnSendFlower, self, i))
	end

	self:ListenEvent("OnUpPage", BindTool.Bind(self.OnUpPage, self))
	self:ListenEvent("OnDownPage", BindTool.Bind(self.OnDownPage, self))
	self:ListenEvent("OpenNumBar", BindTool.Bind(self.OpenNumKeyPad, self))

	self.toggle_list_view = self:FindObj("ToggleListView")
	local toggle_list_delegate = self.toggle_list_view.list_simple_delegate
	toggle_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCellsToggle, self)
	toggle_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCellToggle, self)

	self.first_page_list_view = self:FindObj("FirstPageListView")
	local first_page_list_delegate = self.first_page_list_view.list_simple_delegate
	first_page_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCellsFirstPage, self)
	first_page_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCellFirstPage, self)

	self.rank_list_view = self:FindObj("PageListView")
	local rank_list_delegate = self.rank_list_view.list_simple_delegate
	rank_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	rank_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function MeiLiContentView:__delete()
	self.cur_type = -1
	self.cur_index = 0
	self.cur_page = 1
	self.parent_tab_index = 0

	for k,v in pairs(self.toggle_cell_list) do
		v:DeleteMe()
	end
	self.toggle_cell_list = {}

	for k,v in pairs(self.first_cell_list) do
		v:DeleteMe()
	end
	self.first_cell_list = {}

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	self.is_first_page = nil
	self.cur_page_value = nil
	self.my_rank = nil
	self.cur_capability = nil
	self.last_day_capability = nil

	self.top_rank_name = {}
	self.top_rank_value = {}
	self.top_rank_img_res = {}
	self.top_rank_custom_res = {}
	self.is_show_role_head = {}
	self.is_show_role_photo = {}
	self.top_rank_avatar_key = {}
	self.rank_image = {}
	self.rank_def_image = {}

	self:CancelTheQuest()
end

function MeiLiContentView:CloseCallBack()
	self.top_rank_avatar_key = {}
end

function MeiLiContentView:OnFlush(param_list)
	for k,v in pairs(param_list) do
		if k == "change_tab" then
			self.parent_tab_index = v[1]
			if self.cur_type < 0 then
				if TabIndex.rank_content == self.parent_tab_index then
					self.cur_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_ALL
				elseif TabIndex.rank_meili == self.parent_tab_index then
					self.cur_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM
				end
			end

			RankCtrl.Instance:SendGetPersonRankListReq(self.cur_type)
		end
	end

	self:FlushRankPage()
end

function MeiLiContentView:FlushRankPage()
	if nil == self.is_first_page then
		return
	end

	self:FlushCommon()
	if 1 == self.cur_page then
		self.is_first_page:SetValue(true)
		self:FlushTopRank()
	else
		self.is_first_page:SetValue(false)
		self:FlushNormalRank()
	end

	self:FlushMyRankInfo()
end

function MeiLiContentView:FlushCommon()
	self.rank_name:SetValue(Language.Rank.RankTabName[self.cur_type])

	local title_id = TitleData.Instance:GetRankTitle(GameVoManager.Instance:GetMainRoleVo().sex, self.cur_type)
	local bundle, asset = ResPath.GetTitleIcon(title_id)
	self.title_img_res:SetAsset(bundle, asset)

	local col_name = RankData.Instance:GetRankTitleDes(self.cur_type)
	self.col_name:SetValue(col_name)
end

function MeiLiContentView:FlushTopRank()
	local rank_data_list = RankData.Instance:GetRankList(RANK_KIND.PERSON, self.cur_type)
	for i = 1, 3 do
		self.top_rank_name[i]:SetValue(rank_data_list[i] and rank_data_list[i].user_name or "")
		local rank_value = RankData.Instance:GetRankValue(RANK_KIND.PERSON, self.cur_type, i)
		local col_name,img = RankData.Instance:GetRankTitleDes(self.cur_type)
		self.top_rank_value[i]:SetValue(rank_data_list[i] and tonumber(rank_value) or "0")
		self.col_name_img:SetAsset("uis/views/rank/images_atlas",img)
		self.is_show_role_head[i]:SetValue(nil ~= rank_data_list[i])
		if rank_data_list[i] then
			self:FlushTopRankAvatar(rank_data_list[i], self.rank_image[i], self.rank_def_image[i], self.top_rank_img_res[i])
		end
	end

	GlobalTimerQuest:AddDelayTimer(function()
		self.first_page_list_view.scroller:ReloadData(0)
	end, 0)
end

function MeiLiContentView:FlushTopRankAvatar(rank_data, raw_img_obj, def_img_obj, def_img_assets)
	if nil == rank_data then return end

	CommonDataManager.SetAvatar(rank_data.user_id, raw_img_obj, def_img_obj, def_img_assets, rank_data.sex, rank_data.prof, true)
end

function MeiLiContentView:FlushNormalRank()
	GlobalTimerQuest:AddDelayTimer(function()
		self.rank_list_view.scroller:ReloadData(0)
	end, 0)
end

function MeiLiContentView:FlushMyRankInfo()
	local my_rank_info = nil
	local my_rank = 0
	local rank_data_list = RankData.Instance:GetRankList(RANK_KIND.PERSON, self.cur_type)
	for i, v in ipairs(rank_data_list) do
		if v.user_id == GameVoManager.Instance:GetMainRoleVo().role_id then
			my_rank_info = v
			my_rank = i
			break
		end
	end

	self.my_rank:SetValue(nil ~= my_rank_info and my_rank or Language.Rank.NoInRank)
	self.cur_capability:SetValue(RankData.Instance:GetMyPowerValue(self.cur_type))
	self.last_day_capability:SetValue("?")
end

function MeiLiContentView:GetCurRankTypeList()
	local rank_type_list = {}
	if TabIndex.rank_content == self.parent_tab_index then
		rank_type_list = RankData.Instance:GetRankTypeList()
	elseif TabIndex.rank_meili == self.parent_tab_index then
		rank_type_list = RankData.Instance:GetCharmRankTypeList()
	end

	return rank_type_list
end

function MeiLiContentView:GetNumberOfCellsToggle()
	return #self:GetCurRankTypeList()
end

function MeiLiContentView:RefreshCellToggle(cell, cell_index)
	local the_cell = self.toggle_cell_list[cell]
	if the_cell == nil then
		the_cell = RankTabItem.New(cell.gameObject, self)
		self.toggle_cell_list[cell] = the_cell
		the_cell:SetToggleGroup(self.toggle_list_view.toggle_group)
	end

	local rank_type_list = self:GetCurRankTypeList()
	the_cell:SetIndex(cell_index)
	the_cell:SetData(rank_type_list[cell_index + 1])
end

function MeiLiContentView:SetCurIndex(index)
	self.cur_index = index
end

function MeiLiContentView:GetCurIndex()
	return self.cur_index
end

function MeiLiContentView:GetFirstPageRankList()
	local rank_data_list = RankData.Instance:GetRankList(RANK_KIND.PERSON, self.cur_type)
	local first_page_rank_data_list = {}
	for i = 4, 5 do
		if nil == rank_data_list[i] then
			break
		end

		table.insert(first_page_rank_data_list, rank_data_list[i])
		first_page_rank_data_list[#first_page_rank_data_list].rank = i
	end
	return first_page_rank_data_list
end

function MeiLiContentView:GetNumberOfCellsFirstPage()
	local rank_data_list = self:GetFirstPageRankList()
	return #rank_data_list
end

function MeiLiContentView:RefreshCellFirstPage(cell, cell_index)
	local the_cell = self.first_cell_list[cell]
	if the_cell == nil then
		the_cell = RankCell.New(cell.gameObject, self)
		self.first_cell_list[cell] = the_cell
		--the_cell:SetToggleGroup(self.first_page_list_view.toggle_group)
	end

	local rank_data_list = self:GetFirstPageRankList()
	the_cell:SetRankType(self.cur_type)
	the_cell:SetIndex(cell_index)
	the_cell:SetData(rank_data_list[cell_index + 1])
end

function MeiLiContentView:GetPageRankList(page)
	if page <= 1 then
		return {}
	end

	local rank_data_list = RankData.Instance:GetRankList(RANK_KIND.PERSON, self.cur_type)
	local page_rank_data_list = {}
	local begin = FIRST_PAGE_RANK_NUM + (page - 2) * NORMAL_PAGE_RANK_NUM + 1
	for i = begin, begin + NORMAL_PAGE_RANK_NUM - 1 do
		if nil == rank_data_list[i] then
			break
		end
		table.insert(page_rank_data_list, rank_data_list[i])
		page_rank_data_list[#page_rank_data_list].rank = i
	end

	return page_rank_data_list
end

function MeiLiContentView:GetNumberOfCells()
	local rank_data_list = self:GetPageRankList(self.cur_page)
	return #rank_data_list
end

function MeiLiContentView:RefreshCell(cell, cell_index)
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = RankCell.New(cell.gameObject, self)
		self.cell_list[cell] = the_cell
		--the_cell:SetToggleGroup(self.rank_list_view.toggle_group)
	end

	local rank_data_list = self:GetPageRankList(self.cur_page)
	the_cell:SetRankType(self.cur_type)
	the_cell:SetIndex(cell_index)
	the_cell:SetData(rank_data_list[cell_index + 1])
end

function MeiLiContentView:SetCurType(rank_type)
	if rank_type ~= self.cur_type then
		self.cur_page = 1
		self.cur_page_value:SetValue(self.cur_page)
	end
	self.cur_type = rank_type
end

function MeiLiContentView:GetCurType()
	return self.cur_type
end

function MeiLiContentView:GerCurType()
	if self.cur_type == nil then
		return 0  --战力榜
	end
	return self.cur_type
end

function MeiLiContentView:OnCheckRole(index)
	local rank_data_list = RankData.Instance:GetRankList(RANK_KIND.PERSON, self.cur_type)
	local role_info = rank_data_list[index]
	if role_info == nil then
		return
	end
	local my_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if my_id == role_info.user_id then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.CanNoyCheckSelf)
		return
	end
	if nil ~= role_info then
		CheckData.Instance:SetCurrentUserId(role_info.user_id)
		CheckCtrl.Instance:SendQueryRoleInfoReq(role_info.user_id)
		ViewManager.Instance:Open(ViewName.CheckEquip)
	end
end

function MeiLiContentView:OnSendFlower(index)
	local rank_data_list = RankData.Instance:GetRankList(RANK_KIND.PERSON, self.cur_type) or {}
	local role_info = rank_data_list[index]
	if nil ~= role_info then
		local my_id = GameVoManager.Instance:GetMainRoleVo().role_id
		if my_id == role_info.user_id then
			TipsCtrl.Instance:ShowSystemMsg(Language.Common.CanNotSendFollwerToSelf)
			return
		end
		FlowersCtrl.Instance:SetFriendInfo(role_info)
		ViewManager.Instance:Open(ViewName.Flowers)
	end
end

function MeiLiContentView:OnUpPage()
	if self.cur_page <= 1 then
		return
	end

	self.cur_page = self.cur_page - 1
	self.cur_page_value:SetValue(self.cur_page)
	self:FlushRankPage()
end

function MeiLiContentView:OnDownPage()
	local max_page = 1
	local rank_data_list = RankData.Instance:GetRankList(RANK_KIND.PERSON, self.cur_type)
	if #rank_data_list > FIRST_PAGE_RANK_NUM then
		max_page = math.ceil((#rank_data_list - FIRST_PAGE_RANK_NUM) / NORMAL_PAGE_RANK_NUM + 1)
	end

	if self.cur_page >= max_page then
		return
	end

	self.cur_page = self.cur_page + 1
	self.cur_page_value:SetValue(self.cur_page)
	self:FlushRankPage()
end

function MeiLiContentView:OpenNumKeyPad()
	local open_func = function(page_num)
		self.cur_page = tonumber(page_num)
		if self.cur_page < 1 then self.cur_page = 1 end
		self.cur_page_value:SetValue(self.cur_page)
		self:FlushRankPage()
	end

	local close_func = function()
		self.cur_page_value:SetValue(self.cur_page)
		self:FlushRankPage()
	end

	local max_page = 1
	local rank_data_list = RankData.Instance:GetRankList(RANK_KIND.PERSON, self.cur_type)
	if #rank_data_list > FIRST_PAGE_RANK_NUM then
		max_page = math.ceil((#rank_data_list - FIRST_PAGE_RANK_NUM) / NORMAL_PAGE_RANK_NUM + 1)
	end

	TipsCtrl.Instance:OpenCommonInputView(self.cur_page, open_func, close_func, max_page)
end

function MeiLiContentView:SetCurRoleInfo(cur_rank_info)
	if self.cur_rank_info == nil then
		self.cur_rank_info = RankData.Instance:GetRankList(RANK_KIND.PERSON, self.cur_type)[1]
	else
		if cur_rank_info ~= nil then
			local vip_level = cur_rank_info.vip_level or 0
			vip_level = IS_AUDIT_VERSION and 0 or vip_level
			self.show_vip:SetValue(vip_level ~= 0)
			self.cur_rank_info = cur_rank_info
			if vip_level ~= 0 then
				local bundle, asset = ResPath.GetVipIcon("vip_level_" .. vip_level)
				self.vip_img:SetAsset(bundle, asset)
			end
		end
	end
end

function MeiLiContentView:GetCurRoleInfo()
	return self.cur_rank_info
end

--打开查看面板
function MeiLiContentView:OnOpenCheckClick()
	ViewManager.Instance:Open(ViewName.CheckEquip)
	self:CancelTheQuest()
end

--查看角色有变化时
function MeiLiContentView:RoleInfoChange(role_id)
	if self.cur_rank_info and self.cur_rank_info.user_id == role_id then
		self:SetModle()
	end
end

--没人进排行榜
function MeiLiContentView:CheckIsNoRank()
	if #RankData.Instance:GetRankList(RANK_KIND.PERSON, self.cur_type) == 0 then
		UIScene:DeleteModel(1)
		self.name_text:SetValue("")
		self.show_zhan_li:SetValue(false)
		self.show_vip:SetValue(false)
	end
end

function MeiLiContentView:SetModle()
	self:CancelTheQuest()
	local role_info = CheckData.Instance:GetRoleInfo()
	if role_info == nil then return end
	self.name_text:SetValue(CheckData.Instance:GetName(self.cur_type))
	UIScene:SetActionEnable(false)
	if self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT then
		self:SetMountModle()
		self:SetAnim()
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY then
		self:SetGoddessModel(true, true, DISPLAY_TYPE.XIAN_NV)
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG then
		self:SetGoddessModel(true, false, DISPLAY_TYPE.SHENGONG)
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI then
		self:SetGoddessModel(false, true, DISPLAY_TYPE.SHENYI)
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING then
		self:SetSpiritModle()
		self:SetAnim()
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT then
		self:SetMountModle()
		self:SetAnim()
	else
		local call_back = function(model, obj)
			if self.cur_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO then
				cfg = model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.ROLE_WING], WingData.Instance:GetWingModelResCfg(role_info.sex, role_info.prof), DISPLAY_PANEL.RANK)
			else
				-- cfg = ConfigManager.Instance:GetAutoConfig("model_display_parameter_auto").role_model[001001][DISPLAY_PANEL.RANK]
			end
			if obj then
				if cfg then
					obj.transform.localPosition = cfg.position
					obj.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
					obj.transform.localScale = cfg.scale
				else
					obj.transform.localPosition = Vector3(0, 0, 0)
					obj.transform.localRotation = Quaternion.Euler(0, 0, 0)
					obj.transform.localScale = Vector3(1, 1, 1)
				end
			end
		end
		if self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING then
			UIScene:SetRoleModelResInfo(role_info, 1, true, false, true, true)
			UIScene:SetActionEnable(false)
		elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO then
			UIScene:SetRoleModelResInfo(role_info, 1, true, true, false, true)
			UIScene:SetActionEnable(false)
		else
			UIScene:SetRoleModelResInfo(role_info)
			UIScene:SetActionEnable(true)
		end
		UIScene:SetModelLoadCallBack(call_back)
	end
end

function MeiLiContentView:SetMountModle()
	local role_info = CheckData.Instance:GetRoleInfo()
	local image_id = 0
	local res_id = nil
	if self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT then
		image_id = role_info.mount_info.used_imageid
		if image_id >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			local cfg = MountData.Instance:GetSpecialImagesCfg()[image_id - GameEnum.MOUNT_SPECIAL_IMA_ID]
			if cfg then
				res_id = cfg.res_id
			end
		else
			local cfg = MountData.Instance:GetMountImageCfg()[image_id]
			if cfg then
				res_id = cfg.res_id
			end
		end
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT then
		image_id = role_info.fight_mount_info.used_imageid
		if image_id >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			local cfg = FightMountData.Instance:GetSpecialImagesCfg()[image_id - GameEnum.MOUNT_SPECIAL_IMA_ID]
			if cfg then
				res_id = cfg.res_id
			end
		else
			local cfg = FightMountData.Instance:GetMountImageCfg()[image_id]
			if cfg then
				res_id = cfg.res_id
			end
		end
	end

	if res_id then
		local call_back = function(model, obj)
			local model_cfg = nil
			if self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT then
				model_cfg = model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.MOUNT], res_id, DISPLAY_PANEL.RANK)
			elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT then
				model_cfg = model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.FIGHT_MOUNT], res_id, DISPLAY_PANEL.RANK)
			end
			if obj then
				if model_cfg then
					obj.transform.localPosition = model_cfg.position
					obj.transform.localRotation = Quaternion.Euler(model_cfg.rotation.x, model_cfg.rotation.y, model_cfg.rotation.z)
					obj.transform.localScale = model_cfg.scale
				else
					obj.transform.localPosition = Vector3(0, 0, 0)
					obj.transform.localRotation = Quaternion.Euler(0, 0, 0)
					obj.transform.localScale = Vector3(1, 1, 1)
				end
			end
		end
		UIScene:SetModelLoadCallBack(call_back)
		local bundle, asset = {}
		if self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT then
			bundle, asset = ResPath.GetMountModel(res_id)
		elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHT_MOUNT then
			bundle, asset = ResPath.GetFightMountModel(res_id)
		end
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end
end

function MeiLiContentView:SetGoddessModel(ignore_wing, ignore_weapon, display_type)
	local attr = CheckData.Instance:UpdateAttrView()
	local goddess_data = GoddessData.Instance
	local info = {}
	info.is_goddess = true
	info.role_res_id = -1
	info.wing_res_id = -1
	info.weapon_res_id = -1

	local goddess_huanhua_id = attr.xiannv_attr.huanhua_id

	if goddess_huanhua_id > 0 then
		info.role_res_id = goddess_data:GetXianNvHuanHuaCfg(goddess_huanhua_id).resid
	else
		local goddess_id = attr.xiannv_attr.pos_list[1]
		if goddess_id == -1 then
			goddess_id = 0
		end
		info.role_res_id = goddess_data:GetXianNvCfg(goddess_id).resid
	end

	if not ignore_weapon then
		if attr.shengong_attr.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			info.weapon_res_id = ShengongData.Instance:GetSpecialImagesCfg()[attr.shengong_attr.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID].res_id
		else
			info.weapon_res_id = ShengongData.Instance:GetShengongImageCfg()[attr.shengong_attr.used_imageid].res_id
		end
	end

	if not ignore_wing then
		if attr.shenyi_attr.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			info.wing_res_id = ShenyiData.Instance:GetSpecialImagesCfg()[attr.shenyi_attr.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID].res_id
		else
			info.wing_res_id = ShenyiData.Instance:GetShenyiImageCfg()[attr.shenyi_attr.used_imageid].res_id
		end
	end
	local call_back = function(model, obj)
		local cfg = nil
		if display_type == DISPLAY_TYPE.SHENGONG then
			-- cfg = ConfigManager.Instance:GetAutoConfig("model_display_parameter_auto").shengong_model[001001][DISPLAY_PANEL.RANK]
		elseif display_type == DISPLAY_TYPE.SHENYI then
			-- cfg = ConfigManager.Instance:GetAutoConfig("model_display_parameter_auto").shenyi_model[001001][DISPLAY_PANEL.RANK]
		elseif display_type == DISPLAY_TYPE.XIAN_NV then
			cfg = model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[display_type], info.role_res_id, DISPLAY_PANEL.RANK)
		end
		if obj then
			if cfg then
				obj.transform.localPosition = cfg.position
				obj.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
				obj.transform.localScale = cfg.scale
			else
				obj.transform.localPosition = Vector3(0, 0, 0)
				obj.transform.localRotation = Quaternion.Euler(0, 0, 0)
				obj.transform.localScale = Vector3(1, 1, 1)
			end
		end
		if self.cur_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG and self.cur_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI then
			self:CalToShowAnim(true)
		elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI then
			self:CalToShowAnim(true, true)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)
	UIScene:ResetLocalPostion()
	UIScene:SetGoddessModelResInfo(info)
end

function MeiLiContentView:SetSpiritModle()
	local huanhua_id = self.cur_rank_info.flexible_int
	local spirit_id = self.cur_rank_info.flexible_ll
	if huanhua_id < 0 then
		spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(spirit_id)
	else
		spirit_cfg = SpiritData.Instance:GetSpecialSpiritImageCfg(huanhua_id)
	end

	if spirit_cfg ~= nil then
		local call_back = function(model, obj)
			local cfg = model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SPIRIT], spirit_cfg.res_id, DISPLAY_PANEL.RANK)
			if obj then
				if cfg then
					obj.transform.localPosition = cfg.position
					obj.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
					obj.transform.localScale = cfg.scale
				else
					obj.transform.localPosition = Vector3(0, 0, 0)
					obj.transform.localRotation = Quaternion.Euler(0, 0, 0)
					obj.transform.localScale = Vector3(1, 1, 1)
				end
			end
			-- model:SetTrigger("rest")
		end
		UIScene:SetModelLoadCallBack(call_back)
		bundle, asset = ResPath.GetSpiritModel(spirit_cfg.res_id)
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end
end

function MeiLiContentView:CancelTheQuest()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.time_quest_2 then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
		self.time_quest_2 = nil
	end
end

function MeiLiContentView:SetAnim()
	self.timer = FIX_SHOW_TIME
	self:CancelTheQuest()
	if UIScene.role_model then
		local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			self.timer = self.timer - UnityEngine.Time.deltaTime
			if self.timer <= 0 then
				if part then
					if self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT then
						part:SetTrigger("rest")
					elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY or self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI then
						local count = math.random(1, 4)
						part:SetTrigger(GoddessData.Instance:GetShowTriggerName(count))
					elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING then
						part:SetTrigger("rest")
					end
				end
				self.timer = FIX_SHOW_TIME
			end
		end, 0)
	end
end

function MeiLiContentView:PlayAnim(is_change_tab)
	local is_change_tab = is_change_tab
	if self.time_quest_2 then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
		self.time_quest_2 = nil
	end
	local timer = GameEnum.GODDESS_ANIM_SHORT_TIME
	local count = 1
	self.time_quest_2 = GlobalTimerQuest:AddRunQuest(function()
		timer = timer - UnityEngine.Time.deltaTime
		if timer <= 0 or is_change_tab == true then
			if UIScene.role_model then
				local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
				if part then
					part:SetTrigger(GoddessData.Instance:GetShowTriggerName(count))
					count = count + 1
				end
				timer = GameEnum.GODDESS_ANIM_SHORT_TIME
				is_change_tab = false
				if count == 5 then
					GlobalTimerQuest:CancelQuest(self.time_quest_2)
					self.time_quest_2 = nil
					self:CalToShowAnim(nil, true)
				end
			end
		end
	end, 0)
end

function MeiLiContentView:CalToShowAnim(is_change_tab, is_shenyi)
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	local timer = GameEnum.GODDESS_ANIM_LONG_TIME
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer = timer - UnityEngine.Time.deltaTime
		if timer <= 0 or is_change_tab == true then
			if is_change_tab then
				local func = function()
					self:PlayAnim(is_change_tab)
					is_change_tab = false
					timer = GameEnum.GODDESS_ANIM_LONG_TIME
					GlobalTimerQuest:CancelQuest(self.time_quest)
				end
				if is_shenyi then
					if timer <= 6 then
						func()
					end
				else
					func()
				end
			else
				self:PlayAnim(is_change_tab)
				is_change_tab = false
				timer = GameEnum.GODDESS_ANIM_LONG_TIME
				GlobalTimerQuest:CancelQuest(self.time_quest)
			end
		end
	end, 0)
end


function MeiLiContentView:Reload()
	if self.rank_list_view.scroller then
		self.rank_list_view.scroller:ReloadData(0)
	end
end

function MeiLiContentView:SetZhanliText(show_zhanli_value)
	if show_zhanli_value ~= nil then
		self.all_power_text:SetValue(show_zhanli_value)
	end
end

function MeiLiContentView:SetShowCheck(is_show)
	self.show_check_btn:SetValue(is_show)
end
