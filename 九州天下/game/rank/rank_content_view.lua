RankContentView = RankContentView or BaseClass(BaseRender)

local FIX_SHOW_TIME = 8
local HIGHT_MAX = 623						--最大高度
local HIGHT_MIN = 503						--最小高度

-- 手风琴控件类型
RANK_TOGGLE_TYPE = {
	DENG_JI_BANG = 0, 						-- 等级榜
	ZHAN_LI_BANG = 1, 						-- 战力榜
	XING_XIANG_BANG = 2,					-- 形象榜
	RONG_YU_BANG = 3,	 					-- 荣誉榜
	SHE_JIAO_BANG = 4, 						-- 社交榜
	TE_SHU_SHUXING = 5,						-- 特殊属性榜
	JI_CHU_SHUXING = 6,						-- 基础属性榜
}
-- 手风琴控件Index
RANK_TOGGLE_INDEX = {
	SHOU_FENG_QING_1 = 1, 						-- 手风琴控件Index1
	SHOU_FENG_QING_2 = 2, 						-- 手风琴控件Index2
	SHOU_FENG_QING_3 = 3, 						-- 手风琴控件Index3
	SHOU_FENG_QING_4 = 4,	 					-- 手风琴控件Index4
	SHOU_FENG_QING_5 = 5,						-- 手风琴控件Index5
	SHOU_FENG_QING_6 = 6,						-- 手风琴控件Index6
	SHOU_FENG_QING_7 = 7,						-- 手风琴控件Index7
	SHOU_FENG_QING_8 = 8,						-- 手风琴控件Index8
}

function RankContentView:__init(instance)
	RankContentView.Instance = self
	self:ListenEvent("send_flower_click",BindTool.Bind(self.OnSendFlowerClick,self))
	self:ListenEvent("check_click",BindTool.Bind(self.OnOpenCheckClick,self))
	self.role_info_event = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfoChange, self))
	self.all_power_text = self:FindVariable("all_power_text")
	self.show_check_btn = self:FindVariable("show_check_btn")
	self.name_text = self:FindVariable("name_text")
	self.vip_img = self:FindVariable("vip_img")
	self.show_vip = self:FindVariable("show_vip")
	self.show_zhan_li = self:FindVariable("show_zhan_li")
	self.role_display = self:FindObj("role_display")
	self.mount_display = self:FindObj("MountDisplay")
	
	self.show_marry_rank = self:FindVariable("show_marry_rank")
	self.show_modle = self:FindVariable("show_modle")

	self.rank_num = self:FindVariable("Rank_Num")
	self.title = self:FindVariable("Title")
	self.man = self:FindVariable("Man")
	self.wife = self:FindVariable("Wife")
	self.ren_qi_zhi = self:FindVariable("RenQiZhi")
	self.rank_num_img = self:FindVariable("Rank_Num_Img")
	self.show_rank_nun_img = self:FindVariable("Show_Rank_Nun_Img")
	self.show_num = self:FindVariable("Show_Num")
	self.show_tuanzhang_name = self:FindVariable("Show_TuanZhang_Name")
	self.tuanzhang_name = self:FindVariable("TuanZhang_Name")
	self.guild_des = self:FindVariable("guild_des")
	self.show_my_marry_rank = self:FindVariable("ShowMyMarryRank")
	self.my_marry_rank_num = self:FindVariable("MyMarryRankNum")
	self.show_image_bg = self:FindVariable("show_iamge_bg")

	self.role_model_view = RoleModel.New()
	self.role_model_view:SetDisplay(self.role_display.ui3d_display)

	self.mount_model_view = RoleModel.New("rank_mount_view",300)
	self.mount_model_view:SetDisplay(self.mount_display.ui3d_display)

	self.cur_rank_info = nil
	self.cur_type = 0
	self.last_index = 999
	self.foot_parent = {}

	local ui_foot = self:FindObj("UI_Foot")
	local foot_camera = self:FindObj("FootCamera")
	self.foot_display = self:FindObj("foot_display")
	self.foot_parent = {}
	for i = 1, 3 do
		self.foot_parent[i] = self:FindObj("Foot_" .. i)
	end
	local camera = foot_camera:GetComponent(typeof(UnityEngine.Camera))
	if not IsNil(camera) then
		self.foot_display.ui3d_display:DisplayPerspectiveWithOffset(ui_foot.gameObject, Vector3(0, 0, 0), Vector3(0, 7, 1), Vector3(90, 0, 0))
	end
	-- self.foot_display.ui3d_display:Display(ui_foot.gameObject, camera)
	self.show_foot_camera = self:FindVariable("show_foot_camera")
	self.show_foot_camera:SetValue(false)
	self.show_role_camera = self:FindVariable("show_role_camera")
	self.show_mount_camera = self:FindVariable("show_mount_camera")
	self.show_mount_camera:SetValue(false)

	self.cell_list = {}
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.CellSizeDel = BindTool.Bind(self.GetCellSizeDel, self)
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.my_rank_cell = RankCell.New(self:FindObj("my_rank_cell"))
	-- self.my_marry_rank_cell = MarryRenQiZhiCell.New(self:FindObj("my_marry_rank"))
	self:MarryRankScroller()
end

function RankContentView:__delete()
	if self.role_model_view ~= nil then
		self.role_model_view:DeleteMe()
		self.role_model_view = nil
	end

	if self.mount_model_view ~= nil then
		self.mount_model_view:DeleteMe()
		self.mount_model_view = nil
	end

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	if self.my_rank_cell then
		self.my_rank_cell:DeleteMe()
		self.my_rank_cell = nil
	end

	-- if self.my_marry_rank_cell then
	-- 	self.my_marry_rank_cell:DeleteMe()
	-- 	self.my_marry_rank_cell = nil
	-- end
	
	if self.role_info_event then
		GlobalEventSystem:UnBind(self.role_info_event)
		self.role_info_event = nil
	end
	self.cur_rank_info = nil
	self.cur_type = 0
end

function RankContentView:LoadCallBack()
	self.list_panle = self:FindObj("list_view")
end

function RankContentView:OpenCallBack()
	self.show_marry_rank:SetValue(false)
	self.show_image_bg:SetValue(true)
	-- self.show_tuanzhang_name:SetValue(false)
end

function RankContentView:OnFlush()
	if self.last_index == self.cur_type then return end
	self.last_index = self.cur_type

	self:SetCurRoleInfo(RankData.Instance:GetRankList()[1])
	self:Reload()
	self:FlushMyRank()
	self:FlushShowZhanli()
	self:CheckIsNoRank()
end

function RankContentView:GetNumberOfCells()
	return #RankData.Instance:GetRankList()
end

function RankContentView:GetCellSizeDel(data_index)
	if self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_ALL_CHARM then
		data_index = data_index + 1
		if data_index == 1 then
			return 230
		else
			return 115
		end
	else
		return 115
	end
end

function RankContentView:RefreshCell(cell, cell_index)
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = RankCell.New(cell.gameObject, self)
		self.cell_list[cell] = the_cell
		the_cell:SetToggleGroup(self.list_view.toggle_group)
	end
	cell_index = cell_index + 1
	the_cell:SetRank(cell_index)
	the_cell:Flush()
end

function RankContentView:SetCurType(rank_type)
	local index, toggle_type = RankCtrl.Instance.view:GetToggleGroupIndex()
	self.show_marry_rank:SetValue( toggle_type == RANK_TOGGLE_TYPE.SHE_JIAO_BANG and index == RANK_TOGGLE_INDEX.SHOU_FENG_QING_4)
	self.show_image_bg:SetValue(not(toggle_type == RANK_TOGGLE_TYPE.SHE_JIAO_BANG and index == RANK_TOGGLE_INDEX.SHOU_FENG_QING_4))
	self.show_modle:SetValue(not(toggle_type == RANK_TOGGLE_TYPE.SHE_JIAO_BANG and index == RANK_TOGGLE_INDEX.SHOU_FENG_QING_4) and #RankData.Instance:GetRankList() ~= 0)
	-- self:SetTuanZhangMameValue()
	self.cur_type = rank_type
end

function RankContentView:GetCurType()
	return self.cur_type
end

function RankContentView:GerCurType()
	if self.cur_type == nil then
		return 0  --战力榜
	end
	return self.cur_type
end

function RankContentView:FlushShowZhanli()
	if nil == self.show_zhan_li then
		return
	end
	local rank_info = RankData.Instance:GetRankList()
	self.show_zhan_li:SetValue(self.cur_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_EQUIP_STRENGTH_LEVEL and self.cur_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_STONE_TOTAL_LEVEL and #rank_info ~= 0)
end

function RankContentView:SetCurRoleInfo(cur_rank_info)
	if self.cur_rank_info == nil then
		self.cur_rank_info = RankData.Instance:GetRankList()[1]
	else
		if cur_rank_info ~= nil then
			local vip_level = cur_rank_info.vip_level or 0
			vip_level = IS_AUDIT_VERSION and 0 or vip_level
			self.show_vip:SetValue(vip_level ~= 0)
			self.cur_rank_info = cur_rank_info
			if vip_level ~= 0 then
				local bundle, asset = ResPath.GetVipIcon("vip_level_" .. vip_level)
				-- self.vip_img:SetAsset(bundle, asset)
			end
		end
	end
end

function RankContentView:GetCurRoleInfo()
	return self.cur_rank_info
end

--送花
function RankContentView:OnSendFlowerClick()
	if self.cur_rank_info.user_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.CanNotSendFollwerToSelf)
		return
	end
	if not ScoietyData.Instance:GetSelectRoleIsOnline() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NotOnline)
		return
	end
	FlowersCtrl.Instance:SetFriendInfo(self.cur_rank_info)
	ViewManager.Instance:Open(ViewName.Flowers)
end

--打开查看面板
function RankContentView:OnOpenCheckClick()
	ViewManager.Instance:Open(ViewName.CheckEquip)
	self:CancelTheQuest()
end

--查看角色有变化时
function RankContentView:RoleInfoChange(role_id)
	if self.cur_rank_info and (self.cur_rank_info.user_id == role_id) or (self.cur_rank_info.tuan_zhang_uid == role_id) then
		self:SetModle()
		self:SetTuanZhangMameValue()
	end
end

--没人进排行榜
function RankContentView:CheckIsNoRank()
	if #RankData.Instance:GetRankList() == 0 then
		-- UIScene:DeleteModel(1)
		self.name_text:SetValue("")
		self.show_zhan_li:SetValue(false)
		self.show_vip:SetValue(false)
		self.show_modle:SetValue(false)
	else
		self.show_modle:SetValue(true)
	end
end

function RankContentView:FlushMarryMyRank()
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local marry_rank_info,index = RankData.Instance:GetMyMarryRank()
	if marry_rank_info and index and next(marry_rank_info) then
		if index == 1 then
			self.title:SetValue(RankData.Instance:GetTitleName(RankData.Instance:GetCurTitleCfg(index)))
		else
			self.title:SetValue(RankData.Instance:GetTitleName(RankData.Instance:GetCurTitleCfg(index)))
		end
		self.man:SetValue(marry_rank_info.name_1)
		self.wife:SetValue(marry_rank_info.name_2)
		self.ren_qi_zhi:SetValue(marry_rank_info.rank_value)
		self.show_rank_nun_img:SetValue(index <= 3)
		self.show_num:SetValue(index > 3)
		if index <= 3 then 
			local bundle, asset = ResPath.GetRankIcon(index)
			self.rank_num_img:SetAsset(bundle, asset)
		else
			self.my_marry_rank_num:SetValue(index)
		end
		self.show_my_marry_rank:SetValue(true)
	else
		self.show_my_marry_rank:SetValue(false)
	end
end

function RankContentView:SetModle()
	self:CancelTheQuest()
	local role_info = CheckData.Instance:GetRoleInfo()
	if role_info == nil then return end
	if self.cur_type == LOCAL_RANK_GUILD_TYPE.GUILD_LOCAL_RANK_TYPE_GUILD_KILL_NUM 
		or self.cur_type == LOCAL_RANK_GUILD_TYPE.GUILD_LOCAL_LOCAL_RANK_TYPE_CAPABILITY_CAMP_1
		or self.cur_type == LOCAL_RANK_GUILD_TYPE.GUILD_LOCAL_LOCAL_RANK_TYPE_CAPABILITY_CAMP_2
		or self.cur_type == LOCAL_RANK_GUILD_TYPE.GUILD_LOCAL_LOCAL_RANK_TYPE_CAPABILITY_CAMP_3 then
		local guild_rank_info = RankData.Instance:GetGuildRankInfo()[RANK_INDEX] 
		if next(guild_rank_info) then
			self.tuanzhang_name:SetValue(guild_rank_info.tuan_zhang_name)
			self.guild_des:SetValue(Language.Rank.GuildTuanZhang)
		end
	end
	self.role_model_view:ClearModel()
	self.role_model_view:ResetDisplayPositionAndRotation()
	self.show_role_camera:SetValue(self.cur_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG and self.cur_type ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT )
	self.show_foot_camera:SetValue(self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG)
	self.show_mount_camera:SetValue(self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT)
	if self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT then
		self:SetMountModle(role_info)
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING then
		self.role_model_view:SetDisplayPositionAndRotation("rank_wing_panel")
		self:SetWingModle(role_info)
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO then
		self:SetHaloModle(role_info)
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_FAZHEN then
		self.role_model_view:SetDisplayPositionAndRotation("rank_fazhen_panel")
		self:SetFaZhenModle(role_info)
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JL_HALO then
		self:SetBeautyHaloModle(role_info)
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JL_FAZHEN then
		self.role_model_view:SetDisplayPositionAndRotation("rank_halidom_panel")
		self:SetHalidomModle(role_info)
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI then
		self:SetMantleModle(role_info)
	elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG then
		self:SetFootModle(role_info)
	else
		self.role_model_view:SetModelResInfo(role_info, false, false, false, false, true)
		self.role_model_view:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.ROLE], tonumber(120 ..role_info.prof .. "001"), DISPLAY_PANEL.RANK_ROLE_MODEL)
	end
end

function RankContentView:SetTuanZhangMameValue()
	local index, toggle_type = RankCtrl.Instance.view:GetToggleGroupIndex()
	local guild_rank_list = RankData.Instance:GetGuildRankInfo()
	if CheckData.Instance:GetName(self.cur_type) then
		if (toggle_type == RANK_TOGGLE_TYPE.RONG_YU_BANG and index == RANK_TOGGLE_INDEX.SHOU_FENG_QING_3) 
		or (toggle_type == RANK_TOGGLE_TYPE.RONG_YU_BANG and index == RANK_TOGGLE_INDEX.SHOU_FENG_QING_4) then
			self.name_text:SetValue(Language.Rank.GuildTuanZhangName .. CheckData.Instance:GetName(self.cur_type))
		else
			self.name_text:SetValue(CheckData.Instance:GetName(self.cur_type))
		end
	end
end

--改变列表长度
function RankContentView:ChangePanelHeightMin()
	local panel_Width = self.list_panle.rect.rect.width
	self.list_panle.rect.sizeDelta = Vector2(panel_Width, HIGHT_MIN)
	-- self.list_panle.transform.localPosition = Vector3(0, 58, 0)
end

--改变列表长度
function RankContentView:ChangePanelHeightMax()
	local panel_Width = self.list_panle.rect.rect.width
	self.list_panle.rect.sizeDelta = Vector2(panel_Width, HIGHT_MAX)
	-- self.list_panle.transform.localPosition = Vector3(0, 0, 0)
end

function RankContentView:SetMountModle(role_info)
	local image_id = 0
	local image_cfg = {}
	image_id = role_info.mount_info.used_imageid
	if image_id >= GameEnum.MOUNT_SPECIAL_IMA_ID then
		image_cfg = MountData.Instance:GetSpecialImagesCfg()[image_id - GameEnum.MOUNT_SPECIAL_IMA_ID]
	else
		image_cfg = MountData.Instance:GetMountImageCfg(image_id)
	end

	if image_cfg and image_cfg.res_id then
		-- self.role_model_view:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.MOUNT], image_cfg.res_id)
		self.mount_model_view:SetMainAsset(ResPath.GetMountModel(image_cfg.res_id))
		local cfg = self.role_model_view:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.MOUNT], image_cfg.res_id, DISPLAY_PANEL.RANK_ADVANCE_MODEL)
		self.mount_model_view:SetTransform(cfg)
	end
end

function RankContentView:SetWingModle(role_info)
	local image_id = 0
	local image_cfg = {}
	image_id = role_info.wing_info.used_imageid
	if image_id >= COMMON_CONSTS.SPECIAL_IMAGE_OFFSET then
		image_cfg = WingData.Instance:GetSpecialImageCfg(image_id - COMMON_CONSTS.SPECIAL_IMAGE_OFFSET)
	else
		image_cfg = WingData.Instance:GetWingImageCfg(image_id)
	end

	if image_cfg and image_cfg.res_id then
		local bundle, asset = ResPath.GetWingModel(image_cfg.res_id)	
		self.role_model_view:SetMainAsset(bundle, asset, function ()
		end)
		local cfg = self.role_model_view:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.WING], image_cfg.res_id, DISPLAY_PANEL.RANK_ADVANCE_MODEL)
		self.role_model_view:SetTransform(cfg)
	end
end

function RankContentView:SetHaloModle(role_info)
	local image_id = 0
	local image_cfg = {}
	image_id = role_info.halo_info.used_imageid
	if image_id >= COMMON_CONSTS.SPECIAL_IMAGE_OFFSET then
		image_cfg = HaloData.Instance:GetSpecialImageCfg(image_id - COMMON_CONSTS.SPECIAL_IMAGE_OFFSET)
	else
		image_cfg = HaloData.Instance:GetHaloImageCfg(image_id)
	end

	if image_cfg and image_cfg.res_id then
		local cfg = self.role_model_view:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.HALO], image_cfg.res_id, DISPLAY_PANEL.RANK_ADVANCE_MODEL)
		self.role_model_view:SetTransform(cfg)
		self.role_model_view:SetRoleResid(tonumber(120 ..role_info.prof .. "001"))
		self.role_model_view:SetHaloResid(image_cfg.res_id)
	end
end

function RankContentView:SetFaZhenModle(role_info)
	local image_id = 0
	local image_cfg = {}
	image_id = role_info.fazhen_info.used_imageid
	if image_id >= COMMON_CONSTS.SPECIAL_IMAGE_OFFSET then
		image_cfg = FaZhenData.Instance:GetSpecialImageCfg(image_id - COMMON_CONSTS.SPECIAL_IMAGE_OFFSET)
	else
		image_cfg = FaZhenData.Instance:GetMountImageCfg(image_id)
	end

	if image_cfg and image_cfg.res_id then
		self.role_model_view:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.FAZHEN], image_cfg.res_id, DISPLAY_PANEL.RANK_ADVANCE_MODEL)
		self.role_model_view:SetMainAsset(ResPath.GetFaZhenModel(image_cfg.res_id))
	end
end

function RankContentView:SetBeautyHaloModle(role_info)
	local image_id = 0
	local image_cfg = {}
	image_id = role_info.spirit_halo_info.used_imageid
	if image_id >= COMMON_CONSTS.SPECIAL_IMAGE_OFFSET then
		image_cfg = BeautyHaloData.Instance:GetSpecialImageCfg(image_id - COMMON_CONSTS.SPECIAL_IMAGE_OFFSET)
	else
		image_cfg = BeautyHaloData.Instance:GetImageListInfo(image_id)
	end

	if image_cfg and image_cfg.res_id then
		local cfg = self.role_model_view:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SPIRIT_HALO], image_cfg.res_id, DISPLAY_PANEL.RANK_ADVANCE_MODEL)
		self.role_model_view:SetTransform(cfg)
		local beauty_seq = role_info.beauty_info.img_id or 0
		local beautt_cfg = BeautyData.Instance:GetBeautyActiveInfo(beauty_seq) or {}
		local res_id = beautt_cfg.model or 11101
		local bundle, asset = ResPath.GetGoddessNotLModel(res_id)
		self.role_model_view:SetMainAsset(bundle, asset)
		self.role_model_view:SetHaloResid(image_cfg.res_id, true)
	end
end

function RankContentView:SetHalidomModle(role_info)
	local image_id = 0
	local image_cfg = {}
	image_id = role_info.spirit_fazhen_info.used_imageid
	if image_id >= COMMON_CONSTS.SPECIAL_IMAGE_OFFSET then
		image_cfg = HalidomData.Instance:GetSpecialImageCfg(image_id - COMMON_CONSTS.SPECIAL_IMAGE_OFFSET)
	else
		image_cfg = HalidomData.Instance:GetImageCfg(image_id)
	end

	if image_cfg and image_cfg.res_id then
		self.role_model_view:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.ZHIBAO], image_cfg.res_id, DISPLAY_PANEL.RANK_ADVANCE_MODEL)
		self.role_model_view:SetMainAsset(ResPath.GetBaoJuModel(image_cfg.res_id))
	end
end

function RankContentView:SetMantleModle(role_info)
	local image_id = 0
	local image_cfg = {}
	image_id = role_info.shenyi_info.used_imageid
	if image_id >= COMMON_CONSTS.SPECIAL_IMAGE_OFFSET then
		image_cfg = ShenyiData.Instance:GetSpecialImageCfg(image_id - COMMON_CONSTS.SPECIAL_IMAGE_OFFSET)
	else
		image_cfg = ShenyiData.Instance:GetShenyiImageCfg(image_id)
	end

	if image_cfg and image_cfg.res_id then
		local cfg = self.role_model_view:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.MANTLE], image_cfg.res_id, DISPLAY_PANEL.RANK_ADVANCE_MODEL)
		self.role_model_view:SetTransform(cfg)
		self.role_model_view:SetRoleResid(tonumber(120 ..role_info.prof .. "001"))
		self.role_model_view:SetMantleResid(image_cfg.res_id)
	end
end

function RankContentView:SetFootModle(role_info)
	local image_id = 0
	local image_cfg = {}
	image_id = role_info.shengong_info.used_imageid
	if image_id >= COMMON_CONSTS.SPECIAL_IMAGE_OFFSET then
		image_cfg = ShengongData.Instance:GetSpecialImageCfg(image_id - COMMON_CONSTS.SPECIAL_IMAGE_OFFSET)
	else
		image_cfg = ShengongData.Instance:GetShengongImageCfg(image_id)
	end
	if image_cfg and image_cfg.res_id then
		for i = 1, 3 do
			local bundle, asset = ResPath.GetFootEffec("Foot_" .. image_cfg.res_id)
			PrefabPool.Instance:Load(AssetID(bundle, asset), function (prefab)
				if nil == prefab then
					return
				end
				if self.foot_parent[i] then
					local parent_transform = self.foot_parent[i].transform
					for j = 0, parent_transform.childCount - 1 do
						GameObject.Destroy(parent_transform:GetChild(j).gameObject)
					end
					local obj = GameObject.Instantiate(prefab)
					local obj_transform = obj.transform
					obj_transform:SetParent(parent_transform, false)
					PrefabPool.Instance:Free(prefab)
				end
			end)
		end
	end
end

-- 结婚人气榜Item
function RankContentView:MarryRankScroller()
	self.marry_list = {}
	self.marry_renqizhi = self:FindObj("marry_renqizhi")
	local delegate = self.marry_renqizhi.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #RankData.Instance:GetMarryRankInfo()
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index)
		data_index = data_index + 1
		local target_cell = self.marry_list[cell]
		if nil == target_cell then
			self.marry_list[cell] =  MarryRenQiZhiCell.New(cell.gameObject)
			target_cell = self.marry_list[cell]
			target_cell.mother_view = self
		end
		local data = RankData.Instance:GetMarryRankInfo()
		local cell_data = data[data_index]
		cell_data.data_index = data_index
		target_cell:SetIndex(data_index)
		target_cell:SetData(cell_data)
	end
end

function RankContentView:CancelTheQuest()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.time_quest_2 then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
		self.time_quest_2 = nil
	end
end

function RankContentView:SetAnim()
	self.timer = FIX_SHOW_TIME
	self:CancelTheQuest()
	-- if UIScene.role_model then
		-- local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
		-- self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		-- 	self.timer = self.timer - UnityEngine.Time.deltaTime
		-- 	if self.timer <= 0 then
		-- 		if part then
		-- 			if self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT then
		-- 				part:SetTrigger("rest")
		-- 			elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_XIANNV_CAPABILITY or self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI then
		-- 				local count = math.random(1, 4)
		-- 				part:SetTrigger(GoddessData.Instance:GetShowTriggerName(count))
		-- 			elseif self.cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JINGLING then
		-- 				part:SetTrigger("rest")
		-- 			end
		-- 		end
		-- 		self.timer = FIX_SHOW_TIME
		-- 	end
		-- end, 0)
	-- end
end

function RankContentView:PlayAnim(is_change_tab)
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
			-- if UIScene.role_model then
			-- 	local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
			-- 	if part then
			-- 		part:SetTrigger(GoddessData.Instance:GetShowTriggerName(count))
			-- 		count = count + 1
			-- 	end
			-- 	timer = GameEnum.GODDESS_ANIM_SHORT_TIME
			-- 	is_change_tab = false
			-- 	if count == 5 then
			-- 		GlobalTimerQuest:CancelQuest(self.time_quest_2)
			-- 		self.time_quest_2 = nil
			-- 		self:CalToShowAnim(nil, true)
			-- 	end
			-- end
		end
	end, 0)
end

function RankContentView:CalToShowAnim(is_change_tab, is_shenyi)
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


function RankContentView:Reload()
	if self.list_view.scroller then
		self.list_view.scroller:ReloadData(0)
	end
end

function RankContentView:SetZhanliText(show_zhanli_value)
	if show_zhanli_value ~= nil then
		self.all_power_text:SetValue(show_zhanli_value)
	end
end

function RankContentView:SetHighLighFalse()
	for k,v in pairs(self.cell_list) do
		v:SetHighLigh(false)
	end
end

function RankContentView:FlushMyRank()
	self.my_rank_cell:FlushMyRank()
end

function RankContentView:SetShowCheck(is_show)
	self.show_check_btn:SetValue(is_show)
end
----------------------------------------------------
----------------------每条记录----------------------
----------------------------------------------------
RankCell = RankCell or BaseClass(BaseCell)

function RankCell:__init(instance, parent)
	self.parent = parent
	self.rank = 0
	self.show_img_1 = self:FindVariable("show_img_1")
	self.show_img_2 = self:FindVariable("show_img_2")
	self.show_img_3 = self:FindVariable("show_img_3")
	self.name_text = self:FindVariable("name_text")
	self.rank_text = self:FindVariable("rank_text")
	self.rank_img = self:FindVariable("rank_img")
	self.rank_value_text = self:FindVariable("rank_value_text")
	self.rank_title_text = self:FindVariable("rank_title_text")
	self.show_hard = self:FindVariable("show_hard")
	self.show_hl = self:FindVariable("show_hl")
	self.vip_img = self:FindVariable("vip_img")
	self.image_obj = self:FindObj("image_obj")
	self.raw_image_obj = self:FindObj("raw_image_obj")
	self.show_my_rank = self:FindVariable("show_my_rank")
	self.show_name = self:FindVariable("show_name")
	self.guild_name = self:FindVariable("guild_name")
	self.camp = self:FindVariable("camp")
	self.show_camp = self:FindVariable("show_camp")
	self.show_guild_name = self:FindVariable("show_guild_name")
	self.show_campguild_name = self:FindVariable("show_campguild_name")

	self:ListenEvent("Click", BindTool.Bind(self.ToggleClick, self))
	self:ListenEvent("head_click", BindTool.Bind(self.HeadClick, self))

	self.title_img = self:FindVariable("title_img")
	self.text1 = self:FindVariable("text1")
	self.show_img_4 = self:FindVariable("show_img_4")
	self.title_zhanli = self:FindVariable("title_zhanli")
end

function RankCell:__delete()
	self.parent = nil
end

function RankCell:SetRank(rank)
	self.rank = rank
end

function RankCell:OnFlush()
	self.root_node.gameObject:SetActive(true)
	self.show_img_3:SetValue(false)
	self.root_node.toggle.isOn = false
	local rank_info = RankData.Instance:GetRankList()[self.rank]
	if rank_info == nil then
		self.root_node.gameObject:SetActive(false)
		return
	end

	if self.parent:GerCurType() == PERSON_RANK_TYPE.PERSON_RANK_TYPE_ALL_CHARM then
		if self.rank > 1 then
			-- self.show_img_4:SetValue(false)
		else
			local title_id = TitleData.Instance:GetMeiliTitle(rank_info.sex)
			local bundle, asset = ResPath.GetTitleIcon(title_id)
			self.title_img:SetAsset(bundle, asset)
			local title_cfg = TitleData.Instance:GetTitleCfg(title_id)
			self.title_zhanli:SetValue(CommonDataManager.GetCapabilityCalculation(title_cfg))
			-- self.show_img_4:SetValue(true)
		end
	else
		-- self.show_img_4:SetValue(false)
	end
	self:FlushRankInfo()
	self:SetHead()
end

function RankCell:FlushMyRank()
	local rank_data = RankData.Instance
	local rank_view = RankCtrl.Instance:GetRankView():GetRankContentView()
	local cur_type = rank_view:GerCurType()
	local my_guild_name = GameVoManager.Instance:GetMainRoleVo().guild_name
	self.rank = rank_data:GetMyInfoList(cur_type)
	self.guild_rank = RankData.Instance:GetGuildMyNumRank()

	if self.rank == -1 then --100名以外
		local game_role = GameVoManager.Instance:GetMainRoleVo()
		self.show_img_3:SetValue(true)
		self.show_img_2:SetValue(false)
		self.show_img_1:SetValue(false)
		self.name_text:SetValue(game_role.role_name)
		self.rank_title_text:SetValue(rank_data:GetRankTitleDes(cur_type))
		self.rank_value_text:SetValue(tostring(rank_data:GetMyPowerValue(cur_type)))
		self.show_my_rank:SetValue(false)
	else
		self.show_img_3:SetValue(false)
		self.show_img_2:SetValue(true)
		local rank_info = rank_data:GetRankList()[self.rank]
		if rank_info == nil then
			return
		end
		self.rank_value_text:SetValue(tostring(rank_data:GetMyPowerValue(cur_type)))
		self:FlushRankInfo()
		self.show_my_rank:SetValue(next(rank_info) ~= nil)
	end

	self:SetHead()
	local game_role = GameVoManager.Instance:GetMainRoleVo()
	local rank_info = rank_data.Instance:GetRankList()
	local my_guild_info = RankData.Instance:GetGuildMyInfoList()
	local index, toggle_type = RankCtrl.Instance.view:GetToggleGroupIndex()
	self.camp:SetValue(CampData.Instance:GetCampNameByCampType(game_role.camp, true, true, true))
	if rank_info and next(rank_info) then
		if toggle_type == 1 and index ~= 1 then
			self.show_my_rank:SetValue(game_role.prof == rank_info[1].prof)
		end
	end

	if (toggle_type == RANK_TOGGLE_TYPE.RONG_YU_BANG and index == RANK_TOGGLE_INDEX.SHOU_FENG_QING_3) 
	or (toggle_type == RANK_TOGGLE_TYPE.RONG_YU_BANG and index == RANK_TOGGLE_INDEX.SHOU_FENG_QING_4) then
		self.show_my_rank:SetValue(self.guild_rank ~= -1)
		if my_guild_info then
			self.rank_value_text:SetValue(tostring(my_guild_info.rank_value))
			self.guild_name:SetValue(my_guild_info.guild_name)
		end

		self.show_img_1:SetValue(self.guild_rank <= 3)
		self.show_img_2:SetValue(self.guild_rank > 3)
		self.show_img_3:SetValue(self.guild_rank == -1)
		self.rank_text:SetValue(self.guild_rank)
		if self.guild_rank <= 3 and self.guild_rank ~= -1 then
			local bundle, asset = ResPath.GetRankIcon(self.guild_rank)
			self.rank_img:SetAsset(bundle, asset)
		end
	end

	local is_show_camp = RankData.Instance:GetMyRankData(toggle_type,index)
	self.show_camp:SetValue(is_show_camp.show_camp)
	self.show_name:SetValue(is_show_camp.show_name_text)
	self.show_guild_name:SetValue(is_show_camp.show_guild_name)
	self.show_campguild_name:SetValue(is_show_camp.show_campguild_name)

	if (toggle_type == RANK_TOGGLE_TYPE.RONG_YU_BANG and index == RANK_TOGGLE_INDEX.SHOU_FENG_QING_3) 
	or (toggle_type == RANK_TOGGLE_TYPE.RONG_YU_BANG and index == RANK_TOGGLE_INDEX.SHOU_FENG_QING_4) then
		if self.guild_rank == -1 then
			RankCtrl.Instance:ChangePanelHeightMax()
		else
			RankCtrl.Instance:ChangePanelHeightMin()
		end
	else
		if self.rank == -1 then
			RankCtrl.Instance:ChangePanelHeightMax()
		else
			RankCtrl.Instance:ChangePanelHeightMin()
		end
	end
end

function RankCell:ToggleClick(is_click)
	RANK_INDEX = self.rank    -- 这里用了全局变量，没时间弄了，以后优化
	if is_click then
		self.parent:SetHighLighFalse()
		local rank_view = RankCtrl.Instance:GetRankView():GetRankContentView()
		local rank_info = RankData.Instance:GetRankList()[self.rank]
		local index, toggle_type = RankCtrl.Instance.view:GetToggleGroupIndex()
		if (toggle_type == RANK_TOGGLE_TYPE.RONG_YU_BANG and index == RANK_TOGGLE_INDEX.SHOU_FENG_QING_3) 
		or (toggle_type == RANK_TOGGLE_TYPE.RONG_YU_BANG and index == RANK_TOGGLE_INDEX.SHOU_FENG_QING_4) then
			local guild_info = RankData.Instance:GetGuildRankInfo()
			if guild_info then
				local rank = guild_info[self.rank]
				if rank then
					CheckData.Instance:SetCurrentUserId(rank.tuan_zhang_uid)
					CheckCtrl.Instance:SendQueryRoleInfoReq(rank.tuan_zhang_uid)
				end							
			end
		else
			CheckData.Instance:SetCurrentUserId(rank_info.user_id)
			CheckCtrl.Instance:SendQueryRoleInfoReq(rank_info.user_id)
		end
		local cur_type = rank_view:GerCurType()
		if cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WEEK_CHARM_MALE
			or cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WEEK_CHARM_FEMALE
			or cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAMP_KILL_NUM
			or cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAMP_DEAD_NUM
			 -- or cur_type == RANK_GUILD_TYPE.GUILD_RANK_TYPE_GUILD_KILL_NUM
			or cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LEVEL 
			or cur_type == RANK_TOGGLE_TYPE.DENG_JI_BANG 
			or cur_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_MINGZHONG
			or cur_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_SHANBI
			or cur_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_BAOJI
			or cur_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_JIANREN
			or cur_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_ICE_MASTER
			or cur_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_FIRE_MASTER
			or cur_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_THUNDER_MASTER
			or cur_type == BiPIN_RANK_TYPE.PERSON_RANK_TYPE_POISON_MASTER then   
			rank_view:SetZhanliText(rank_info.flexible_ll)
		elseif cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CHARM
			or cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_MOUNT
			or cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WING
			or cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_HALO
			or cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_FAZHEN
			or cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JL_HALO
			or cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_CAPABILITY_JL_FAZHEN
			or cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENYI
			or cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_SHENGONG then
			rank_view:SetZhanliText(rank_info.rank_value)
		elseif cur_type == LOCAL_RANK_GUILD_TYPE.GUILD_LOCAL_RANK_TYPE_GUILD_KILL_NUM 
			or cur_type == LOCAL_RANK_GUILD_TYPE.GUILD_LOCAL_RANK_TYPE_CAPABILITY_CAMP_1
			or cur_type == LOCAL_RANK_GUILD_TYPE.GUILD_LOCAL_RANK_TYPE_CAPABILITY_CAMP_2
			or cur_type == LOCAL_RANK_GUILD_TYPE.GUILD_LOCAL_RANK_TYPE_CAPABILITY_CAMP_3 then
			local guild_info = RankData.Instance:GetGuildRankInfo()[self.rank]
			if guild_info then
				if next(guild_info) then
					rank_view:SetZhanliText(guild_info.tuan_zhang_capability)
				end
			end
		else
			rank_view:SetZhanliText(rank_info.rank_value)
		end

		rank_view:SetCurRoleInfo(rank_info)
		self.show_hl:SetValue(true)
		self.parent:SetShowCheck(not (rank_info.user_id == GameVoManager.Instance:GetMainRoleVo().role_id))
	end
end

function RankCell:HeadClick()
	local rank_info = RankData.Instance:GetRankList()[self.rank]
	if rank_info.user_id ~= GameVoManager.Instance:GetMainRoleVo().role_id then
		ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, rank_info.user_name)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.CanNoyCheckSelf)
	end
end

function RankCell:SetHighLigh(is_hl)
	self.show_hl:SetValue(is_hl)
end

function RankCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function RankCell:FlushRankInfo()
	local rank_view = RankCtrl.Instance:GetRankView():GetRankContentView()
	local rank_data = RankData.Instance
	local rank_info = rank_data.Instance:GetRankList()[self.rank]
	local index, toggle_type = RankCtrl.Instance.view:GetToggleGroupIndex()
	local cur_type = rank_view:GerCurType()
	local rank_value = rank_data:GetRankValue(self.rank)
	local zhan_li = CommonDataManager.ConverNum(rank_info.rank_value)
	local type_rank_value = RankData.Instance:GetRankPowerValue(cur_type,self.rank)
	self.rank_title_text:SetValue(rank_data:GetRankTitleDes(cur_type))
	self.rank_value_text:SetValue(tostring(type_rank_value))
	self.camp:SetValue(CampData.Instance:GetCampNameByCampType(rank_info.camp, true, true, true))
	self.name_text:SetValue(rank_info.user_name)
	if rank_info.guild_name then
		self.guild_name:SetValue(rank_info.guild_name)
	end

	local is_show_camp = RankData.Instance:GetMyRankData(toggle_type,index)
	self.show_camp:SetValue(is_show_camp.show_camp)
	self.show_name:SetValue(is_show_camp.show_name_text)
	self.show_guild_name:SetValue(is_show_camp.show_guild_name)
	self.show_campguild_name:SetValue(is_show_camp.show_campguild_name)

	if self.rank <= 3 then
		self.show_img_1:SetValue(true)
		self.show_img_2:SetValue(false)
		local bundle, asset = ResPath.GetRankIcon(self.rank)
		self.rank_img:SetAsset(bundle, asset)
	else
		self.rank_text:SetValue(self.rank)
		self.show_img_1:SetValue(false)
		self.show_img_2:SetValue(true)
	end

	--vip
 	-- if rank_info.vip_level > 0 then
	 -- 	self.vip_img:SetAsset(ResPath.GetVipLevelIcon(rank_info.vip_level))
  --   end
	if rank_view:GetCurRoleInfo() == nil then
		return
	end

	if (toggle_type == RANK_TOGGLE_TYPE.RONG_YU_BANG and index == RANK_TOGGLE_INDEX.SHOU_FENG_QING_3) 
	or (toggle_type == RANK_TOGGLE_TYPE.RONG_YU_BANG and index == RANK_TOGGLE_INDEX.SHOU_FENG_QING_4) then
		if rank_view:GetCurRoleInfo().tuan_zhang_uid == rank_info.tuan_zhang_uid then
			if self.root_node.toggle ~= nil then
				self.show_hl:SetValue(true)
				self.root_node.toggle.isOn = true
				if not self.root_node.toggle.isActiveAndEnabled then
					self:ToggleClick(true)
				end
			end
		else
			if self.root_node.toggle ~= nil then
				self.show_hl:SetValue(false)
				self.root_node.toggle.isOn = false
			end
		end
	else
		if rank_view:GetCurRoleInfo().user_id == rank_info.user_id then
			if self.root_node.toggle ~= nil then
				self.show_hl:SetValue(true)
				self.root_node.toggle.isOn = true
				if not self.root_node.toggle.isActiveAndEnabled then
					self:ToggleClick(true)
				end
			end
		else
			if self.root_node.toggle ~= nil then
				self.show_hl:SetValue(false)
				self.root_node.toggle.isOn = false
			end
		end
	end
end

function RankCell:SetHead()
	local rank_data = RankData.Instance
	local rank_info = rank_data:GetRankList()[self.rank]

	local user_id = 0
	local avatar_key_big = 0
	local avatar_key_small = 0
	local prof = 0
	local sex = 0
	if rank_info then
		user_id = rank_info.user_id
		avatar_key_big = rank_info.avatar_key_big
		avatar_key_small = rank_info.avatar_key_small
		prof = rank_info.prof or 0
		sex = rank_info.sex
	else
		local vo = GameVoManager.Instance:GetMainRoleVo()
		user_id = vo.role_id
		avatar_key_big = vo.avatar_key_big
		avatar_key_small = vo.avatar_key_small
		prof = vo.prof
		sex = vo.sex
	end
	AvatarManager.Instance:SetAvatarKey(user_id, avatar_key_big, avatar_key_small)
	local avatar_path_small = AvatarManager.Instance:GetAvatarKey(user_id)
	if AvatarManager.Instance:isDefaultImg(user_id) == 0 or avatar_path_small == 0 then
		self.image_obj.gameObject:SetActive(true)
		self.raw_image_obj.gameObject:SetActive(false)
			local bundle, asset = AvatarManager.GetDefAvatar(prof, false, sex)
			if asset ~= 0 then
				self.image_obj.image:LoadSprite(bundle, asset)
			end
	else
		local function callback(path)
			if IsNil(self.image_obj.gameObject) or IsNil(self.raw_image_obj.gameObject) then
				return
			end
			if path == nil then
				path = AvatarManager.GetFilePath(user_id, false)
			end
			self.raw_image_obj.raw_image:LoadSprite(path, function ()
				self.image_obj.gameObject:SetActive(false)
				self.raw_image_obj.gameObject:SetActive(true)
			end)
		end
		AvatarManager.Instance:GetAvatar(user_id, true, callback)
	end
	local index, toggle_type = RankCtrl.Instance.view:GetToggleGroupIndex()
	if (toggle_type == RANK_TOGGLE_TYPE.RONG_YU_BANG and index == RANK_TOGGLE_INDEX.SHOU_FENG_QING_3) 
	or (toggle_type == RANK_TOGGLE_TYPE.RONG_YU_BANG and index == RANK_TOGGLE_INDEX.SHOU_FENG_QING_4) then
		self.show_hard:SetValue(false)
	else
		self.show_hard:SetValue(true)
	end
end


---------------------------------------------------------------
--结婚人气排行榜Item

MarryRenQiZhiCell = MarryRenQiZhiCell or BaseClass(BaseCell)

function MarryRenQiZhiCell:__init()
	self.rank_num = self:FindVariable("Rank_Num")
	self.title = self:FindVariable("Title")
	self.man = self:FindVariable("Man")
	self.wife = self:FindVariable("Wife")
	self.ren_qi_zhi = self:FindVariable("RenQiZhi")
	self.rank_num_img = self:FindVariable("Rank_Num_Img")
	self.show_rank_nun_img = self:FindVariable("Show_Rank_Nun_Img")
	self.show_num = self:FindVariable("Show_Num")
	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function MarryRenQiZhiCell:__delete()

end

function MarryRenQiZhiCell:SetIndex(index)
	self.cell_index = index
end

function MarryRenQiZhiCell:ClickItem()
	RankCtrl.Instance:RankMarryTipOpen()
	RankCtrl.Instance:SetOtherHead(self.data)
end

function MarryRenQiZhiCell:OnFlush()
	if self.data == nil then return end
	self.rank_num:SetValue(self.cell_index)
	if self.cell_index == 1 then
		self.title:SetValue(RankData.Instance:GetTitleName(RankData.Instance:GetCurTitleCfg(self.cell_index)))
	else
		self.title:SetValue(RankData.Instance:GetTitleName(RankData.Instance:GetCurTitleCfg(self.cell_index)))
	end
	
	self.man:SetValue(self.data.name_1)
	self.wife:SetValue(self.data.name_2)
	self.ren_qi_zhi:SetValue(self.data.rank_value)
	self.show_rank_nun_img:SetValue(self.cell_index <= 3)
	self.show_num:SetValue(self.cell_index > 3)
	if self.cell_index <= 3 then 
		local bundle, asset = ResPath.GetRankIcon(self.cell_index)
		self.rank_num_img:SetAsset(bundle, asset)
	end
end