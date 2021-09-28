require("game/goddess/goddess_data")
require("game/goddess/goddess_view")
require("game/goddess/goddess_gongming_up_view")
require("game/goddess/goddess_shengwu_skill_tip_view")
require("game/goddess/goddess_search_aura_view")
require("game/goddess/goddess_special_tip_view")
GoddessCtrl = GoddessCtrl or BaseClass(BaseController)

function GoddessCtrl:__init()
	if GoddessCtrl.Instance then
		print_error("[GoddessCtrl] Attemp to create a singleton twice !")
	end
	GoddessCtrl.Instance = self

	self.data = GoddessData.New()
	self.view = GoddessView.New(ViewName.Goddess)
	self.aura_search_view = GoddessSearchAuraView.New(ViewName.GoddessSearchAuraView)
	self.goddess_gongming_up_view = GoddessGongMingUpView.New()
	self.goddess_skill_tip_view = GoddessShengWuSkillView.New()
	self.goddess_special_model_view = GoddessSpecialTipView.New(ViewName.GoddessSpecialTipView)

	self:RegisterAllProtocols()
end

function GoddessCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.goddess_gongming_up_view:DeleteMe()
	self.goddess_gongming_up_view = nil

	self.goddess_skill_tip_view:DeleteMe()
	self.goddess_skill_tip_view = nil

	self.aura_search_view:DeleteMe()
	self.aura_search_view = nil

	if self.goddess_special_model_view ~= nil then
		self.goddess_special_model_view:DeleteMe()
		self.goddess_special_model_view = nil
	end

	self.data:DeleteMe()
	self.data = nil


	GoddessCtrl.Instance = nil
end

function GoddessCtrl:GetView()
	return self.view
end

function GoddessCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCAllXiannvInfo, "OnGoddessInfo")
	self:RegisterProtocol(SCXiannvInfo, "OnSCXiannvInfo")
	self:RegisterProtocol(SCXiannvViewChange, "OnSCXiannvViewChange")
	self:RegisterProtocol(SCXiannvShengwuMilingList, "OnSCXiannvShengwuMilingList")
	self:RegisterProtocol(SCXiannvShengwuChangeInfo, "OnSCXiannvShengwuChangeInfo")
	self:RegisterProtocol(SCXiannvShengwuChouExpList, "OnSCXiannvShengwuChouExpList")
	self:RegisterProtocol(SCXiannvShengwuChouExpResult, "OnSCXiannvShengwuChouExpResult")
end

--仙女信息同步
function GoddessCtrl:OnGoddessInfo(protocol)
	local flush_flag = false
	if self.data:GetHuanHuaId() ~= protocol.huanhua_id then
		flush_flag = true
	end
	self.data:OnGoddessInfo(protocol)
	local main_vo = Scene.Instance:GetMainRole()
	if main_vo and next(main_vo) then
		main_vo:SetAttr("xiannv_huanhua_id", protocol.huanhua_id)
	end

	if self.view:IsOpen() then
		local goddess_info_view = self.view:GetGoddessInfoView()
		if goddess_info_view then
			goddess_info_view:AllCellOnFlush()
			goddess_info_view:FlushGetWay()
			goddess_info_view:FlushCancelBtn()
			if flush_flag == true then
				self.view:SetModel()
			end
		end
		local camp_view = self.view:GetGoddessCampView()

		if camp_view then
			if camp_view:GetIsOpen() then
				camp_view:ReflushLineupView()
				camp_view:AllCellListOnFlush()
				camp_view:FlushShowShadow()
				RemindManager.Instance:Fire(RemindName.Goddess_Camp)
			end
		end

		local goddess_role_view = self.view:GetGoddessRoleView()
		if goddess_role_view then
			if goddess_info_view then
				local xiannv_id = goddess_info_view:GetCurrentXiannvID()
				local xian_nv_cfg = GoddessData.Instance:GetXianNvCfg(xiannv_id)
				local name = xian_nv_cfg.name
				local quality =ItemData.Instance:GetItemConfig(xian_nv_cfg.active_item).color
				goddess_role_view:OnFlush(name, quality, xiannv_id)

			end
		end
		self.view:UpdataShengWuView()
	end
	local huanhua_view = GoddessHuanHuaCtrl.Instance:GetView()
	if huanhua_view:IsOpen() and huanhua_view:IsLoaded() then
		GoddessHuanHuaCtrl.Instance:Flush()
	end
	local xiannv_huanhua_id = protocol.huanhua_id or -1
	local xiannv_id = protocol.pos_list[1]
	if xiannv_id >= 0 then
		local xiannv_name = GoddessData.Instance:GetXiannvName(xiannv_id)
		if xiannv_name == nil or xiannv_name == "" then
			local xiannv_cfg = GoddessData.Instance:GetXianNvCfg(xiannv_id)
			if xiannv_cfg then
				xiannv_name = xiannv_cfg.name
			end
		end

		if main_vo and next(main_vo) then
			main_vo:SetAttr("use_xiannv_id", xiannv_id)
			main_vo:SetAttr("xiannv_name", xiannv_name)
		end
	end
	self:FlushGoddessInfoView()


	--伙伴比拼，当战力达到10000时请求活动信息
	local is_get_reward = CompetitionActivityData.Instance:IsGetReward(TabIndex.goddess_info)
	local is_act_open = ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GODDES)
	local xiannv_list = self.data:GetXiannvActiveList()
	if nil ~= xiannv_list and nil ~= next(xiannv_list) and not is_get_reward and is_act_open then
		for k, v in pairs(xiannv_list) do
			local attr = GoddessData.Instance:GetXiannvAttr(v)
			if attr.power > GameEnum.BIPIN_POWER_COND then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GODDES, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			end
		end
	end

	self.goddess_special_model_view:Flush()


	RemindManager.Instance:Fire(RemindName.Goddess)
	RemindManager.Instance:Fire(RemindName.Goddess_HuanHua)
	RemindManager.Instance:Fire(RemindName.Goddess_ShengWu)
	RemindManager.Instance:Fire(RemindName.Goddess_GongMing_MiLing)
	RemindManager.Instance:Fire(RemindName.Goddess_GongMing_Grid)
end

function GoddessCtrl:GetGoddessInfoView()
	return self.view:GetGoddessInfoView()
end

function GoddessCtrl:GetGoddessCampView()
	return self.view:GetGoddessCampView()
end

function GoddessCtrl:GetGoddessShenGongView()
	return self.view:GetGoddessShenGongView()
end

function GoddessCtrl:GetGoddessShenyiView()
	return self.view:GetGoddessShenyiView()
end

function GoddessCtrl:GetGoddessShouhuView()
	return self.view:GetGoddessShouhuView()
end

function GoddessCtrl:GetRoleView()
	return self.view:GetGoddessRoleView()
end

--升级信息同步
function GoddessCtrl:OnSCXiannvInfo(protocol)
	self.data:OnXiannvInfo(protocol)
	if self.view:IsOpen() then
		self:PlayUpStarEffect()
		local goddess_info_view = self.view:GetGoddessInfoView()
		if goddess_info_view then
			goddess_info_view:AllCellOnFlush()
			goddess_info_view:FlushRightView()
			if protocol.xn_item.xn_level == GODDRESS_MAX_LEVEL then
				goddess_info_view:ActiveOrUgrageBtn(protocol.xn_item.xn_level)
			end
		end
	end

	--伙伴比拼，当战力达到10000时请求活动信息
	local is_get_reward = CompetitionActivityData.Instance:IsGetReward(TabIndex.goddess_info)
	local is_act_open = ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GODDES)
	local xiannv_list = self.data:GetXiannvActiveList()
	if nil ~= xiannv_list and nil ~= next(xiannv_list) and not is_get_reward and is_act_open then
		for k, v in pairs(xiannv_list) do
			local attr = GoddessData.Instance:GetXiannvAttr(v)
			if attr.power > GameEnum.BIPIN_POWER_COND then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GODDES, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			end
		end
	end

	RemindManager.Instance:Fire(RemindName.Goddess)
end

function GoddessCtrl:OnSCXiannvViewChange(protocol)
	local obj = Scene.Instance:GetRoleByObjId(protocol.obj_id)
	if obj then
		if obj:IsMainRole() then
			GoddessData.Instance:OnSCXiannvViewChange(protocol)
		end

		local xiannv_huanhua_id = protocol.huanhua_id
		local name = ""
		local goddess_obj = obj:GetGoddessObj()
		if goddess_obj ~= nil then
			if xiannv_huanhua_id >= 0 then
				goddess_obj:SetAttr("xiannv_huanhua_id", xiannv_huanhua_id)
				if protocol.xiannv_name == "" then
					name = GoddessData.Instance:GetXianNvHuanHuaCfg(xiannv_huanhua_id).name
				else
					name = protocol.xiannv_name
				end
				goddess_obj:SetAttr("xiannv_name", name)
			else
				goddess_obj:SetAttr("xiannv_name", protocol.xiannv_name)
				goddess_obj:SetAttr("use_xiannv_id", protocol.use_xiannv_id)
			end
		end
		if protocol.use_xiannv_id > 0 and goddess_obj == nil then
			obj:SetAttr("xiannv_name", protocol.xiannv_name)
			obj:SetAttr("use_xiannv_id", protocol.use_xiannv_id)
		end
	end
end

--请求仙女激活
function GoddessCtrl:SendCSXiannvActiveReq(id, item_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvActiveReq)
	send_protocol.xiannv_id = id
	send_protocol.item_index = ItemData.Instance:GetItemIndex(item_id)
	send_protocol:EncodeAndSend()
end

--请求仙女升级
function GoddessCtrl:SendCSXiannvUpLevelReq(id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvUpLevelReq)
	send_protocol.xiannv_id = id
	send_protocol.auto_buy = 1
	send_protocol:EncodeAndSend()
end

--请求仙女出战
function GoddessCtrl:SendCSXiannvCall(pos_list)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvCall)
	send_protocol.pos_list = pos_list
	send_protocol:EncodeAndSend()
end

--请求仙女重命名
function GoddessCtrl:SendCSXiannvRename(xiannv_id,name)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvRename)
	send_protocol.xiannv_id = xiannv_id
	send_protocol.new_name = name
	send_protocol:EncodeAndSend()
end

--请求仙女激活幻化
function GoddessCtrl:SendXiannvActiveHuanhua(xiannv_id,item_index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvActiveHuanhua)
	send_protocol.xiannv_id = xiannv_id
	send_protocol.item_index = item_index
	send_protocol:EncodeAndSend()
end

--请求改变幻化形象
function GoddessCtrl:SentXiannvImageReq(huanhua_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvImageReq)
	send_protocol.huanhua_id = huanhua_id
	send_protocol:EncodeAndSend()
end

--请求幻化形象升级
function GoddessCtrl:SentXiannvHuanHuaUpLevelReq(huanhua_id,auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvHuanHuaUpLevelReq)
	send_protocol.huanhua_id = huanhua_id
	send_protocol.auto_buy = auto_buy
	send_protocol:EncodeAndSend()
end

--请求改变幻化形象
function GoddessCtrl:SentXiannvImageReq(huanhua_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvImageReq)
	send_protocol.huanhua_id = huanhua_id
	send_protocol:EncodeAndSend()
end

--请求加资质
function GoddessCtrl:SentXiannvAddZizhiReq(xiannv_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvAddZizhiReq)
	send_protocol.xiannv_id = xiannv_id
	send_protocol.auto_buy = 0
	send_protocol:EncodeAndSend()
end

--请求购买特殊伙伴形象(直接激活)
function GoddessCtrl:SentSpecialXiannvOperaReq(opera_type,special_xiannv_id,param)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSSpecialXiannvOperaReq)
	send_protocol.opera_type = opera_type
	send_protocol.special_xiannv_id = special_xiannv_id
	send_protocol.param = param
	send_protocol:EncodeAndSend()
end

--请求购买称号
function GoddessCtrl:SentXiannvSmallTargetOperaReq(opera_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvSmallTargetOperaReq)
	send_protocol.opera_type = opera_type
	send_protocol:EncodeAndSend()
end

function GoddessCtrl:FlushView(param_list)
	if self.view and self.view:IsOpen() then
		self.view:Flush(param_list)
	end
end

function GoddessCtrl:FlushGoddessInfoView()
	if self.view:IsOpen() then
		self.view:FlushGoddessInfoView()
	end
end

function GoddessCtrl:FlushShengongModel()
	if self.view:IsOpen() then
		self.view:FlushShengongModel()
	end
end

function GoddessCtrl:FlushShenyiModel()
	if self.view:IsOpen() then
		self.view:FlushShenyiModel()
	end
end

function GoddessCtrl:ShengongUpGradeResult(result)
	self.view:ShengongUpGradeResult(result)
end

function GoddessCtrl:ShenyiUpGradeResult(result)
	self.view:ShenyiUpGradeResult(result)
end


function GoddessCtrl:OnSCXiannvShengwuChouExpList(protocol)
	self.data:SetXiannvShengwuChouExpList(protocol)
	self.view:UpdataShengWuView()
end

function GoddessCtrl:OnSCXiannvShengwuChouExpResult(protocol)
	self.data:SetXiannvShengwuChouExpResult(protocol)
	self.view:ShowShengWuViewFly()
end

--请求女神圣器请求协议
function GoddessCtrl:SentCSXiannvShengwuReqReq(req_type, param1, param2, param3)
	if req_type == nil then
		return
	end
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvShengwuReq)
	send_protocol.req_type = req_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol:EncodeAndSend()
end

-- 打开共鸣升级面板
function GoddessCtrl:OpenGoddessGongMingUpView(param1)
	self.goddess_gongming_up_view:SetGridId(param1)
	self.goddess_gongming_up_view:Open()
end

-- 打开技能显示面板
function GoddessCtrl:OpenGoddessSkillTipView(param1)
	self.goddess_skill_tip_view:SetShengWuId(param1)
	self.goddess_skill_tip_view:Open()
end

function GoddessCtrl:OnSCXiannvShengwuMilingList(protocol)
	self.data:SetXiannvShengwuMilingList(protocol)
	self.aura_search_view:Flush("miling_list",protocol.miling_list)
end

function GoddessCtrl:OnSCXiannvShengwuChangeInfo(protocol)
	RemindManager.Instance:Fire(RemindName.Goddess_ShengWu)
	RemindManager.Instance:Fire(RemindName.Goddess_GongMing_MiLing)
	RemindManager.Instance:Fire(RemindName.Goddess_GongMing_Grid)
	if protocol.notify_type == GODDESS_NOTIFY_TYPE.UNFETCH_EXP then
		self.data:SetHadUsedFreeTimes(protocol)
		self.data:SetShengWuLingYeValue(protocol.param4)
		self.view:UpdataGongMingGrid()
		-- if self.goddess_gongming_up_view:IsOpen() then
		-- 	self.goddess_gongming_up_view:Flush()
		-- end
		-- self.view:Flush("miling_change")
		local value = self.data:GetLingYeChange()
		if value > 0 then
			value = ToColorStr(value, TEXT_COLOR.GREEN)
			TipsFloatingManager.Instance:ShowFloatingTips(string.format(Language.Goddess.GetLingYeTip, value))
		end

		if self.goddess_gongming_up_view:IsOpen() then
			self.goddess_gongming_up_view:Flush()
		end

		self:FlushShengWuRed()
	elseif protocol.notify_type == GODDESS_NOTIFY_TYPE.SHENGWU_INFO then
		self.data:SetXiannvScShengWuIconAttr(protocol)
		self.view:UpdataShengWuView()
	elseif protocol.notify_type == GODDESS_NOTIFY_TYPE.GRID_INFO then
		self.data:SetXiannvShengwuGridLevel(protocol)
		self.view:UpdataGongMingGrid()
		-- self.view:UpdataShengWuView()
	end
end

function GoddessCtrl:FlushShengWuRed()
	self.view:Flush("shengwu_red")
end

function GoddessCtrl:ResetEff()
	if self.aura_search_view:IsOpen() then
		self.aura_search_view:Flush("reset_eff")
	end
end

function GoddessCtrl:PlayUpStarEffect()
	if self.view:IsOpen() and self.view:IsLoaded() then
		self.view:PlayUpStarEffect()
	end
end