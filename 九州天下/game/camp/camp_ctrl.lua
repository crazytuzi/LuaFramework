require("game/camp/camp_data")
require("game/camp/camp_view")
require("game/camp/rests_view/camp_affairs_view")
require("game/camp/rests_view/camp_appoint_view")
require("game/camp/rests_view/camp_member_list_view")
require("game/camp/rests_view/camp_fuhuo_view")
require("game/camp/tips_alter_country_name_view")
require("game/camp/monster_siege_info_view")
require("game/camp/camp_change_view")
require("game/camp/camp_team_view")

CampCtrl = CampCtrl or BaseClass(BaseController)

function CampCtrl:__init()
	if CampCtrl.Instance ~= nil then
		print_error("[CampCtrl]error:create a singleton twice")
	end
	CampCtrl.Instance = self

	self.data = CampData.New()
	self.view = CampView.New(ViewName.Camp)										-- 国家面板
	self.affairs_view = CampAffairsView.New(ViewName.CampAffairs)				-- 内政面板
	self.appoint_view = CampAppointView.New(ViewName.CampAppoint)				-- 任命面板
	self.member_list_view = CampMemberListView.New(ViewName.CampMemberList)		-- 成员列表面板(禁言、内奸、解除)
	self.fuhuo_view = CampFuHuoView.New(ViewName.CampFuHuo)						-- 复活分配面板
	self.tips_alter_country_name_view = TipsAlterCountryName.New(ViewName.CampAlterName)		-- 修改国号面板
	self.monster_siege_info_view = MonsterSiegeInfoView.New(ViewName.MonsterSiegeInfoView) 	-- 怪物攻城副本信息界面
	self.change_view = CampChangeView.New(ViewName.CampChangeView)
	self.camp_team_view = CampTeamView.New(ViewName.CampTeamView)
 
	self:RegisterAllProtocols()
	RemindManager.Instance:Register(RemindName.CampInfo, BindTool.Bind(self.GetRedPointState, self))
	RemindManager.Instance:Register(RemindName.CampInternal, BindTool.Bind(self.GetRedPointState, self))
end

function CampCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.affairs_view then
		self.affairs_view:DeleteMe()
		self.affairs_view = nil
	end
	if self.appoint_view then
		self.appoint_view:DeleteMe()
		self.appoint_view = nil
	end
	if self.member_list_view then
		self.member_list_view:DeleteMe()
		self.member_list_view = nil
	end
	if self.fuhuo_view then
		self.fuhuo_view:DeleteMe()
		self.fuhuo_view = nil
	end
	if self.tips_alter_country_name_view then
		self.tips_alter_country_name_view:DeleteMe()
		self.tips_alter_country_name_view = nil
	end

	if self.monster_siege_info_view ~= nil then
		self.monster_siege_info_view:DeleteMe()
		self.monster_siege_info_view = nil
	end

	if self.change_view ~= nil then
		self.change_view:DeleteMe()
		self.change_view = nil
	end

	if self.camp_team_view ~= nil then
		self.camp_team_view:DeleteMe()
		self.camp_team_view = nil
	end

	CampCtrl.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.CampInfo)
	RemindManager.Instance:UnRegister(RemindName.CampInternal)
end

function CampCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCampInfo, "OnCampInfo")
	self:RegisterProtocol(SCCampMemInfo, "OnCampMemInfo")
	self:RegisterProtocol(SCCampCommonInfo, "OnCampCommonInfo")
	self:RegisterProtocol(SCCampRebornInfo, "OnCampRebornInfo")
	self:RegisterProtocol(SCGetRoleCampRankListAck, "OnGetRoleCampRankListAck")
	self:RegisterProtocol(SCCampSaleItemList, "OnCampSaleItemList")
	self:RegisterProtocol(SCCampSaleResultList, "OnCampSaleResultList")
	self:RegisterProtocol(SCCampRoleInfo, "OnCampRoleInfo")
	self:RegisterProtocol(SCCampSearchMemList, "OnCampSearchMemList")
	self:RegisterProtocol(SCCampYunbiaoStatus, "OnCampYunbiaoStatus")
	self:RegisterProtocol(SCSpecialParamChange, "OnSpecialParamChange")
	self:RegisterProtocol(SCCampQiyunTowerStatus, "OnCampQiyunTowerStatus")
	self:RegisterProtocol(SCCampQiyunBattleReport, "OnCampQiyunBattleReport")
	self:RegisterProtocol(SCQueryCampBuildReport, "OnQueryCampBuildReport")

	--怪物攻城
	self:RegisterProtocol(SCMonsterSiegeInfo, "OnSCMonsterSiegeInfo")
	self:RegisterProtocol(SCMonsterSiegeFbInfo, "OnSCMonsterSiegeFbInfo")
	self:RegisterProtocol(SCCampOtherInfo,"OnSCCampOtherInfo")

	self:RegisterProtocol(CSCampCommonOpera)
	self:RegisterProtocol(CSGetCampInfo)
	self:RegisterProtocol(CSQueryCampMemInfo)
	self:RegisterProtocol(CSCampPublishNotice)
	self:RegisterProtocol(CSCampSetRebornTimes)
	self:RegisterProtocol(CSGetRoleCampRankList)
	self:RegisterProtocol(CSCampTaskCommonOpera)
	self:RegisterProtocol(CSCampWarCommonOpera)
	self:RegisterProtocol(CSQueryCampBuildReport)


	--转阵营
	self:RegisterProtocol(CSRoleChangeCamp)
	self:RegisterProtocol(SCChangeCampInfo, "OnSCChangeCampInfo")
	self:RegisterProtocol(SCCampScoreInfo, "OnSCCampScoreInfo")
	
	--国家同盟
	self:RegisterProtocol(SCGetCampAllianceRankListAck, "OnGetCampAllianceRankList")
	self:RegisterProtocol(SCGuildYesterdayQiyunRankInfo, "OnYesterdayQiyunRankInfo")end

-- 请求建国日志信息
function CampCtrl:SendQueryCampBuildReportInfo()
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSQueryCampBuildReport)
	protocol_send:EncodeAndSend()
end

-- 返回建国日志信息
function CampCtrl:OnQueryCampBuildReport(protocol)
	self.data:SetQueryCampBuildReport(protocol)
end

-- 阵营(国家)信息
function CampCtrl:OnCampInfo(protocol)
	self.data:SetCampInfo(protocol)
	self:Flush("flush_camp_info_view")
	if self.fuhuo_view:IsOpen() then
		self.fuhuo_view:Flush()
	end
	local main_role = Scene.Instance:GetMainRole()
	main_role:ReloadUIName()
end

-- 阵营(国家)成员信息
function CampCtrl:OnCampMemInfo(protocol)
	self.data:SetCampMemInfo(protocol)
	self:Flush("flush_camp_member_view")
end

-- 通用信息
function CampCtrl:OnCampCommonInfo(protocol)
	if protocol.result_type == CAMP_RESULT_TYPE.RESULT_TYPE_ADD_REBORN_DAN then
		if protocol.param1 > 0 then
			TipsCtrl.Instance:ShowFloatingLabel(string.format(Language.SysRemind.AddCampFuHuoNum, protocol.param1))
		end
	elseif protocol.result_type == CAMP_RESULT_TYPE.RESULT_TYPE_NEIZHENG_BANZHUAN_OPEN then --搬砖的开启时间
		NationalWarfareData.Instance:SetCampBanZhuanEndTime(protocol.param3)
		--if protocol.param3 > TimeCtrl.Instance:GetServerTime() then
			--ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.BANZHUAN, ACTIVITY_STATUS.OPEN, protocol.param3, 0, 0, 0)
		--else
			--ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.BANZHUAN, ACTIVITY_STATUS.CLOSE, protocol.param3, 0, 0, 0)
			MainUICtrl.Instance:FlushView("banzhuan")
		--end
	elseif protocol.result_type == CAMP_RESULT_TYPE.RESULT_TYPE_DACHEN_DEFEND_SUCC then --大臣防御奖励
		NationalWarfareCtrl.Instance:DaChenRewardInfo()
	elseif protocol.result_type == CAMP_RESULT_TYPE.RESULT_TYPE_FLAG_DEFEND_SUCC then 	--国旗防御奖励
		NationalWarfareCtrl.Instance:GuoQiRewardInfo()
	elseif protocol.result_type == CAMP_RESULT_TYPE.RESULT_TYPE_NEIZHENG_YUNBIAO_OPEN then
		self.data:SetCampYunbiaoStatus(protocol.param3)
		MainUICtrl.Instance.view:Flush("double_escort")
	end
	self.data:SetCampCommonInfo(protocol)
	self:Flush()
end

-- 分配复活次数
function CampCtrl:OnCampRebornInfo(protocol)
	self.data:SetCampRebornInfo(protocol)
	if self.fuhuo_view:IsOpen() then
		self.fuhuo_view:Flush()
	end
end

-- 获取角色阵营排行榜
function CampCtrl:OnGetRoleCampRankListAck(protocol)
	self.data:SetGetRoleCampRankListAck(protocol)
	
end

-- 国家拍卖物品列表
function CampCtrl:OnCampSaleItemList(protocol)
	self.data:SetCampSaleItemList(protocol)
	self:Flush("flush_camp_auction_view")
	local reason_type = protocol.reason_type
	if CAMP_SALE_ITEM_LIST_TYPE.BUY_SUCC == reason_type then
		self:Flush("flush_camp_auction_list")
	end
end

-- 上架物品的售卖结果项
function CampCtrl:OnCampSaleResultList(protocol)
	self.data:SetCampSaleResultList(protocol)
	self:Flush("flush_camp_auction_view")
end

-- 角色的国家信息更变
function CampCtrl:OnCampRoleInfo(protocol)
	PlayerData.Instance:SetAttr("camp_post", protocol.camp_post)
	self.data:SetCampRoleInfo(protocol)
	self.affairs_view:Flush()
	self.view:Flush()
	self:Flush("flush_camp_info_view")

	if self.appoint_view:IsOpen() then
		self.appoint_view:Flush()
	end
	if self.member_list_view:IsOpen() then
		self.member_list_view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.CampInfo)
	RemindManager.Instance:Fire(RemindName.CampInternal)

	GlobalEventSystem:Fire(OtherEventType.CAMP_ROLE_INFO)
end

-- 查询玩家列表
function CampCtrl:OnCampSearchMemList(protocol)
	self.data:SetCampSearchMemList(protocol)
	if self.appoint_view:IsOpen() then
		self.appoint_view:Flush()
	end
	if self.member_list_view:IsOpen() then
		self.member_list_view:Flush()
	end
end

function CampCtrl:OnCampYunbiaoStatus(protocol)
	self.data:SetCampYunbiaoStatus(protocol.neizheng_yunbiao_end_time)
	MainUICtrl.Instance.view:Flush("double_escort")
end

-- 特殊参数改变（可用于形象改变广播）
function CampCtrl:OnSpecialParamChange(protocol)
	local obj = Scene.Instance:GetRoleByObjId(protocol.obj_id)
	if obj then
		if protocol.special_type == SPECIAL_TYPE.SPECIAL_TYPE_NEIJIAN then					-- 内奸
			obj:SetAttr("is_neijian", protocol.param1)
		elseif protocol.special_type == SPECIAL_TYPE.SPECIAL_TYPE_CITAN_COLOR then			-- 刺探颜色
			obj:SetAttr("citan_color", protocol.param1)
		elseif protocol.special_type == SPECIAL_TYPE.SPECIAL_TYPE_BANZHUAN_COLOR then		-- 搬砖颜色
			obj:SetAttr("banzhuan_color", protocol.param1)
		elseif protocol.special_type == SPECIAL_TYPE.SPECIAL_TYPE_BEAUTY then
			obj:SetAttr("beauty_used_seq", protocol.param1)
			obj:SetAttr("beauty_is_active_shenwu", protocol.param2)
		elseif protocol.special_type == SPECIAL_TYPE.SPECIAL_TYPE_BEAUTY_HUANHUA then
			obj:SetAttr("beauty_used_huanhua_seq", protocol.param1)
			obj:SetAttr("beauty_is_active_shenwu", protocol.param2)
		elseif protocol.special_type == SPECIAL_TYPE.SPECIAL_TYPE_HOLD_BEAUTY then
			MountCtrl.Instance:SendGoonMountReq(0)
			obj:SetAttr("hold_beauty_npcid", protocol.param1)
			GlobalEventSystem:Fire(OtherEventType.TASK_CHANGE, "hold_beauty")
		elseif protocol.special_type == SPECIAL_TYPE.SPECIAL_TYPE_JUNXIAN_LEVEL then
			obj:SetAttr("junxian_level", protocol.param1)
		elseif protocol.special_type == SPECIAL_TYPE.SPECIAL_TYPE_BABY then
			obj:SetAttr("set_baby_id", protocol.param1)
		end
	end
end

-- 气运塔状态
function CampCtrl:OnCampQiyunTowerStatus(protocol)
	self.data:SetCampQiyunTowerStatus(protocol)
	self:Flush("flush_camp_fate_view")
	GlobalEventSystem:Fire(ObjectEventType.OBJ_MONSTER_CHANGE)
	-- 国家战事气运界面
	NationalWarfareCtrl.Instance:Flush("flush_qiyun_view")
	if GuildChatView.Instance:IsOpen() then
		GuildChatView.Instance:Flush("new_chat")
	end

	RemindManager.Instance:Fire(RemindName.CampWarQiYun)
end

-- 气运战报
function CampCtrl:OnCampQiyunBattleReport(protocol)
	self.data:SetCampQiyunBattleReport(protocol)
	self:Flush("flush_camp_fate_view")
end

-- 打开更改国号面板
function CampCtrl:ShowAlterCountryName(callback, item_id, current_name_value, need_money_value)
	self.tips_alter_country_name_view:SetCallBack(callback)
	self.tips_alter_country_name_view:SetItemId(item_id)
	self.tips_alter_country_name_view:SetConfig(current_name_value, need_money_value)
	self.tips_alter_country_name_view:Open()
	self.tips_alter_country_name_view:Flush()
end

-- 请求阵营(国家)信息
function CampCtrl:SendGetCampInfo()
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSGetCampInfo)
	protocol_send:EncodeAndSend()
end

-- 请求国民信息
function CampCtrl:SendQueryCampMemInfo(page, order_type)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSQueryCampMemInfo)
	protocol_send.page = page or 0
	protocol_send.order_type = order_type or CAMP_MEM_QUERY_ORDER_TYPE.CMQOT_DEFAULT
	protocol_send:EncodeAndSend()
end

-- 发布公告
function CampCtrl:SendCampPublishNotice(notice)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSCampPublishNotice)
	protocol_send.notice = notice or Language.Common.NoNotice
	protocol_send:EncodeAndSend()
end

-- 通用请求
function CampCtrl:SendCampCommonOpera(order_type, param1, param2, param3, param4_name, param5)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSCampCommonOpera)
	protocol_send.order_type = order_type or 0
	protocol_send.param1 = param1 or 0
	protocol_send.param2 = param2 or 0
	protocol_send.param3 = param3 or 0
	protocol_send.param4_name = param4_name or ""
	protocol_send.param5 = param5 or 0
	protocol_send:EncodeAndSend()
end

-- 分配复活次数
function CampCtrl:SendCampSetRebornTimes(king_reborn_times, officer_reborn_times, jingying_reborn_times, guomin_reborn_times)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSCampSetRebornTimes)
	protocol_send.king_reborn_times = king_reborn_times or 0
	protocol_send.officer_reborn_times = officer_reborn_times or 0
	protocol_send.jingying_reborn_times = jingying_reborn_times or 0
	protocol_send.guomin_reborn_times = guomin_reborn_times or 0
	protocol_send:EncodeAndSend()
end

-- 请求角色阵营排行信息
function CampCtrl:SendGetRoleCampRankList(rank_type, ignore_camp_post)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSGetRoleCampRankList)
	protocol_send.rank_type = rank_type or 0
	protocol_send.ignore_camp_post = ignore_camp_post or 0
	protocol_send:EncodeAndSend()
end

-- 请求查询玩家信息
function CampCtrl:SendCampAppointSearchUser(search_type, name)
	search_type = search_type or 0
	name = name or ""
	self:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_SEARCH_USER, search_type, 0, 0, name)
end

function CampCtrl:SendCampWarCommonOpera(opera_type, param1, param2, param3)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSCampWarCommonOpera)
	protocol_send.opera_type = opera_type or 0
	protocol_send.param1 = param1 or 0
	protocol_send.param2 = param2 or 0
	protocol_send.param3 = param3 or 0
	protocol_send:EncodeAndSend()
end

function CampCtrl:SendCampTaskCommonOpera(opera_type, param1, param2, param3)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSCampTaskCommonOpera)
	protocol_send.opera_type = opera_type or 0
	protocol_send.param1 = param1 or 0
	protocol_send.param2 = param2 or 0
	protocol_send.param3 = param3 or 0
	protocol_send:EncodeAndSend()
end

-- 刷新View方法
function CampCtrl:Flush(key, value_t)
	if self.view then
		self.view:Flush(key, value_t)
	end
end

function CampCtrl:GetRedPointState()
	 CampData.Instance:CheckRedPoint()
	 local num = math.max(CampData.Instance:GetDayCounterList(CAMP_AFFAIRS_TYPE.GUOMINFULI), CampData.Instance:GetDayCounterList(CAMP_AFFAIRS_TYPE.GUANYUANFULI))
	 return num
end

--怪物攻城----------------------------------------
function CampCtrl:OnSCMonsterSiegeInfo(protocol)
	self.data:SetMonsterSiegeInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush("flush_camp_build_view", {act_status = protocol.act_status})
	end 
end

function CampCtrl:OnSCMonsterSiegeFbInfo(protocol)
	self.data:SetMonsterSiegeFbInfo(protocol)
	if self.monster_siege_info_view:IsOpen() then
		self.monster_siege_info_view:Flush()
	end

	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function CampCtrl:OnSCCampOtherInfo(protocol)
	self.data:SetCampOtherInfo(protocol)
end

function CampCtrl:CloseView()
	if self.view:IsOpen() then
		self.view:Close()
	end
end

function CampCtrl:CloseMonsterSiegeInfo()
	if self.monster_siege_info_view:IsOpen() then
		self.monster_siege_info_view:Close()
	end
end


--------转阵营-------------
-- 请求转换阵营
function CampCtrl:SendChangeCamp(camp)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSRoleChangeCamp)
	protocol_send.camp = camp or 0
	protocol_send:EncodeAndSend()
end

function CampCtrl:OnSCChangeCampInfo(protocol)
	local obj = Scene.Instance:GetRoleByObjId(protocol.obj_id)
	if obj ~= nil then
		obj:SetAttr("change_camp", protocol.camp)
	end
end

function CampCtrl:OnSCCampScoreInfo(protocol)
	self.data:SetCampScoreInfo(protocol)
	
	if self.change_view ~= nil and self.change_view:IsOpen() then
		self.change_view:Flush()
	end
end

-----------国家同盟-------------------
-- 排行信息
function CampCtrl:OnGetCampAllianceRankList(protocol)
	self.data:SetCampAllianceRankList(protocol)
	if self.camp_team_view:IsOpen() then
		self.camp_team_view:Flush("rank")
		self.camp_team_view:Flush("reward")
	end
end

-- 奖励信息
function CampCtrl:OnYesterdayQiyunRankInfo(protocol)
	self.data:SetYesterdayQiyunRankInfo(protocol)
	if self.camp_team_view:IsOpen() then
		self.camp_team_view:Flush("reward")
	end
	RemindManager.Instance:Fire(RemindName.CampTeam)
end