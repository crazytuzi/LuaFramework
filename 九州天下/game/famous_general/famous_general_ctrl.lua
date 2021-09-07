require("game/famous_general/famous_general_view")
require("game/famous_general/famous_general_data")
require("game/famous_general/general_content_render")
require("game/famous_general/combo_content_render")
require("game/famous_general/potential_content_render")
require("game/famous_general/setfight_content_render")
require("game/famous_general/famous_general_itemrender")
require("game/famous_general/general_chou_view")
require("game/famous_general/select_general_view")
require("game/famous_general/slot_uplevel_view")
require("game/famous_general/general_bianshen_effect")
require("game/famous_general/famous_general_attr_view")
require("game/famous_general/bone_content_render")
require("game/famous_general/taste_famous_general_view")

FamousGeneralCtrl = FamousGeneralCtrl or BaseClass(BaseController)

local FloatingTipsPos = {
	{x = 145, y = -125},
	{x = 315, y = -125},
	{x = 485, y = -125},
}

function FamousGeneralCtrl:__init()
	if FamousGeneralCtrl.Instance ~= nil then
		print_error("[FamousGeneralCtrl] attempt to create singleton twice!")
		return
	end
	FamousGeneralCtrl.Instance = self
	self.select_index = 0
	self.is_bianshen = false

	self:RegisterAllProtocols()

	self.view = FamousGeneralView.New(ViewName.FamousGeneralView)
	self.data = FamousGeneralData.New()
	self.select_view = SelectGeneralView.New(ViewName.GeneralSelectView)
	self.taste_famous_general_view = TasteFamousGeneralView.New(ViewName.TasteFamousGeneralView)
	self.slot_up_view = SlotUpLevelView.New(ViewName.SlotUpLevelView)
	self.effect_view = FamousGeneralEffect.New(ViewName.GeneralBianShenEffect)
	self.attr_tip_view = FamousGeneralAttrTipView.New()

	self.task_change = GlobalEventSystem:Bind(OtherEventType.TASK_CHANGE, BindTool.Bind(self.OnTaskChange, self))

	RemindManager.Instance:Register(RemindName.General_Info, BindTool.Bind(self.CheckGeneralItem, self, RemindName.General_Info))
	RemindManager.Instance:Register(RemindName.General_Wash, BindTool.Bind(self.CheckGeneralItem, self, RemindName.General_Wash))
	RemindManager.Instance:Register(RemindName.General_Fight, BindTool.Bind(self.CheckGeneralItem, self, RemindName.General_Fight))
	RemindManager.Instance:Register(RemindName.GeneralJiu, BindTool.Bind(self.CheckGeneralItem, self, RemindName.GeneralJiu))
	RemindManager.Instance:Register(RemindName.GeneralBone, BindTool.Bind(self.CheckGeneralItem, self, RemindName.GeneralBone))
end

function FamousGeneralCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	self.select_view:DeleteMe()
	self.select_view = nil

	self.slot_up_view:DeleteMe()
	self.slot_up_view = nil

	self.taste_famous_general_view:DeleteMe()
	self.taste_famous_general_view = nil

	if self.attr_tip_view ~= nil then
		self.attr_tip_view:DeleteMe()
		self.attr_tip_view = nil
	end

	if self.task_change then
		GlobalEventSystem:UnBind(self.task_change)
		self.task_change = nil
	end

	RemindManager.Instance:UnRegister(RemindName.General_Info)
	RemindManager.Instance:UnRegister(RemindName.General_Wash)
	RemindManager.Instance:UnRegister(RemindName.General_Fight)
	RemindManager.Instance:UnRegister(RemindName.GeneralJiu)
	RemindManager.Instance:UnRegister(RemindName.GeneralBone)
	FamousGeneralCtrl.Instance = nil
end

function FamousGeneralCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGreateSoldierItemInfo, "OnGreateSoldierItemInfo")
	self:RegisterProtocol(SCGreateSoldierOtherInfo, "OnGreateSoldierOtherInfo")
	self:RegisterProtocol(SCGreateSoldierSlotInfo, "OnGreateSoldierSlotInfo")

	self:RegisterProtocol(SCChineseZodiacAllInfo, "OnChineseZodiacAllInfo")
end

function FamousGeneralCtrl:OnTaskChange(task_event_type, task_id)
	local bs_type = 0
	if task_event_type == "accepted_add" then
		bs_type = 1
	elseif task_event_type == "completed_add" then
		bs_type = 2
	end
	local cfg = self.data:GetExperienceCfg(bs_type, task_id)
	if cfg and next(cfg) then
		self:OpenTasteFamousGeneralView(cfg.bs_id or 0)
		TaskCtrl.Instance:CancelTask()
	end
end

function FamousGeneralCtrl:Flush(param_t)
	self.view:Flush(param_t)
end

-- 名将请求
function FamousGeneralCtrl:SendRequest(req_type, param_1, param_2, param_3)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGreateSoldierOpera)
	protocol.req_type = req_type or 0
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol.param_3 = param_3 or 0
	protocol:EncodeAndSend()
end

-- 名将信息
function FamousGeneralCtrl:OnGreateSoldierItemInfo(protocol)
	self.data:SetGreateSoldierItemInfo(protocol)
	self.view:Flush("all", {"list_data"})
	for k,v in pairs(RemindGroud[RemindName.General]) do
		RemindManager.Instance:Fire(v)
	end	
end

--  名将其他信息
function FamousGeneralCtrl:OnGreateSoldierOtherInfo(protocol)
	self.data:SetGreateSoldierOtherInfo(protocol)	
	self.view:Flush()
	if protocol.cur_used_seq ~= -1 and not self.is_bianshen then
		self.is_bianshen = true
		self:ShowBianShen()
		MainUICtrl.Instance:FlushView("check_skill")
	end
	MainUICtrl.Instance:FlushView("flush_bianshen_cd")
	MainUICtrl.Instance:FlushView("general_bianshen", {"skill"})
end

-- 设置当前为变身状态
function FamousGeneralCtrl:SetBianShenState()
	self.is_bianshen = false
end

-- 名将将位信息
function FamousGeneralCtrl:OnGreateSoldierSlotInfo(protocol)
	self.data:SetGreateSoldierSlotInfo(protocol)
	self.view:Flush("flush_setfight_view")
	MainUICtrl.Instance:FlushView("check_skill")
	if self.slot_up_view:IsOpen() then
		self.slot_up_view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.General_Fight)
end

-- 名将槽位升级
function FamousGeneralCtrl:OnGreateSoldierUpLevel(result)
	if self.slot_up_view:IsOpen() then
		if result == 0 then
			--self.slot_up_view:StopOnClickUpLevel()
			return
		end
		self.slot_up_view:UpData()
	end
end

function FamousGeneralCtrl:OpenSelectView(chose_seq)
	self.select_view:SetChoseSeq(chose_seq)
	self.select_view:Open()
	--self.taste_famous_general_view:SetBianShenID(4)
end

-- 打开名将体验面板
function FamousGeneralCtrl:OpenTasteFamousGeneralView(bs_id)
	self.taste_famous_general_view:SetBianShenID(bs_id)
end

function FamousGeneralCtrl:OpenSlotUpView(solt_seq)
	self.slot_up_view:SetSlotSeq(solt_seq)
	self.slot_up_view:Open()
end

function FamousGeneralCtrl:CheckGeneralItem(remind_type)
	local falg = 0
	local general_cfg = FamousGeneralData.Instance:GeneralInfoCfg()
	local other_cfg = FamousGeneralData.Instance:GetOtherCfg()
	if remind_type == RemindName.General_Info then 		--名将信息
		for k,v in pairs(general_cfg) do
			local cur_info = FamousGeneralData.Instance:GetGeneralSingleInfoBySeq(v.seq)
			if ItemData.Instance:GetItemNumIsEnough(v.item_id, 1) and cur_info and cur_info.level < other_cfg.max_level then
				falg = 1
			end
		end

	elseif remind_type == RemindName.General_Wash then
		for k,v in pairs(general_cfg) do				--名将潜能
			local cur_info = FamousGeneralData.Instance:GetGeneralSingleInfoBySeq(v.seq)
			if cur_info and cur_info.level > 0 and ItemData.Instance:GetItemNumIsEnough(v.wash_attr_item_id, 1) then
				local wash_point_limit = FamousGeneralData.Instance:GetWashPointLimitByIndexAndLevel(v.seq + 1, cur_info.level)
				if cur_info.wash_attr_points then
					local check_num = 0
					for k1,v1 in pairs(cur_info.wash_attr_points) do
						if v1 >= wash_point_limit[FamousGeneralData.PotentialLimit[k1 + 1]] then
							check_num = check_num + 1
						end
					end

					if check_num < 3 then
						falg = 1
					end
				end
			end
		end

	elseif remind_type == RemindName.General_Fight then 			--名将点将
		local solt_info = FamousGeneralData.Instance:GetslotInfo()
		local level = GameVoManager.Instance:GetMainRoleVo().level
		for k,v in pairs(solt_info) do
			local solt_cfg = FamousGeneralData.Instance:GetSlotLevelCfg(v.level, v.place) or {}
			local need_level = FamousGeneralData.Instance:GetSoldierCfg(v.place).need_level
			if need_level and level > need_level and v.item_seq == -1 and FamousGeneralData.Instance:CheckGeneralPoolHasActive() or ItemData.Instance:GetItemNumIsEnough(solt_cfg.item_id, 1) then
				falg = 1
			end			
		end
	elseif remind_type == RemindName.GeneralJiu then   --名将请酒
		local open_flag = OpenFunData.Instance:CheckIsHide("famousgeneralview_chou_jiang")
		if ItemData.Instance:GetItemNumIsEnough(other_cfg.draw_1_item_id, 1) and open_flag then
			falg = 1
		end
	elseif remind_type == RemindName.GeneralBone then   --名将根骨
		local is_reach = self.data:CheckGeneralBoneUprise()
		if is_reach then
			falg = 1
		end
	end
	return falg
end

function FamousGeneralCtrl:OpenAttrView()
	self.attr_tip_view:Open()
end

function FamousGeneralCtrl:ShowBianShen(cur_use_imageid)
	local prefab = PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "PaintingEffect")
	local obj = GameObject.Instantiate(prefab)	
	local obj_transform = obj.transform
	obj_transform:SetParent(UIRoot, false)

	local tab = obj:GetComponent(typeof(UIVariableTable))
	local animator = obj:GetComponent(typeof(UnityEngine.Animator))
	local raw_image = tab:FindVariable("ShowBG")
	raw_image_left = tab:FindVariable("ShowBGLeft")
	if cur_use_imageid then
		local ues_seq = FamousGeneralData.Instance:GetSeqByImageId(cur_use_imageid)
		local bundle, asset = ResPath.GetRawImage("BianShen_" .. ues_seq)
		raw_image:SetAsset(bundle, asset)
		bundle, asset = ResPath.GetRawImage("effect_left")
		raw_image_left:SetAsset(bundle, asset)
		animator:ListenEvent("EffectStop", function ()
		GameObject.Destroy(obj)
		end)
	else
		local use_seq = FamousGeneralData.Instance:GetCurUseSeq()
		local bundle, asset = ResPath.GetRawImage("BianShen_" .. use_seq)
		raw_image:SetAsset(bundle, asset)
		bundle, asset = ResPath.GetRawImage("effect_left")
		raw_image_left:SetAsset(bundle, asset)
		animator:ListenEvent("EffectStop", function ()
		GameObject.Destroy(obj)
		end)
	end
end

------------------根骨--------------------

function FamousGeneralCtrl:OnChineseZodiacAllInfo(protocol)
	self.data:SetShengXiaoAllInfo(protocol)
	self.view:Flush("flush_bone_view")
end

function FamousGeneralCtrl:SendTianxiangReq(info_type, param1, param2, param3, param4, param5)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSTianxiangReq)
	send_protocol.info_type = info_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol.param4 = param4 or 0
	send_protocol.param5 = param5 or 0
	send_protocol:EncodeAndSend()
end

function FamousGeneralCtrl:OnSoldierWashOptResult(result)
	if 0 == result then
		self.view:Flush("stopuplevel")
	 	return 
	end
	self.view:Flush("uplevel")
	local index = self:GetCurSelectIndex()
	local last_info = self.data:GetLastWashPointInfoBySeq()
	local cur_info = self.data:GetGeneralSingleInfoBySeq(index)
	for i=0, 2 do
		self["var_" .. i] = cur_info.wash_attr_points[i] - last_info.wash_attr_points[i]
		if 0 ~= self["var_" .. i] then
			local msg = ToColorStr("+" .. self["var_" .. i], TEXT_COLOR.GREEN)
			local floating_view = TipsFloatingView.New()
			floating_view:Show(msg, FloatingTipsPos[i + 1].x, FloatingTipsPos[i + 1].y, nil, nil, nil, nil, true)
		end
	end
end

function FamousGeneralCtrl:SetCurSelectIndex(index)
	self.select_index = index
end

function FamousGeneralCtrl:GetCurSelectIndex()
	if self.select_index then
		return self.select_index
	end
end