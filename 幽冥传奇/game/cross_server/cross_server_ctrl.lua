require("scripts/game/cross_server/cross_server_data")
-- require("scripts/game/cross_server/cross_server_view")

-- 跨服
CrossServerCtrl = CrossServerCtrl or BaseClass(BaseController)

function CrossServerCtrl:__init()
	if	CrossServerCtrl.Instance then
		ErrorLog("[CrossServerCtrl]:Attempt to create singleton twice!")
	end
	CrossServerCtrl.Instance = self

	self.boss_view = require("scripts/game/cross_server/cross_boss_view").New(ViewDef.CrossBoss)
	self.boss_reward_view = require("scripts/game/cross_server/cross_boss_reward_pre_view").New(ViewDef.BossRewardPreview)	
	-- self.battle_view = CrossServerView.New(ViewName.CrossBattle)
	self.data = CrossServerData.New()

	self:RegisterAllProtocals()
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainRoleInfo, self))

	RemindManager.Instance:RegisterCheckRemind(function ()
		return self.data:GetBrandRemind()
	end, RemindName.FreeCrossBrand)

	RemindManager.Instance:RegisterCheckRemind(function ()
		return self.data:GetCrossBossInfoRemind()
	end, RemindName.CrossBossInfo)
end

function CrossServerCtrl:__delete()
	CrossServerCtrl.Instance = nil
	
	self.boss_reward_view:DeleteMe()
	self.boss_reward_view = nil

	self.data:DeleteMe()
	self.data = nil

	if self.buy_tumo_alert then
		self.buy_tumo_alert:DeleteMe()
		self.buy_tumo_alert = nil
	end
end

function CrossServerCtrl:OpenRewardView(data)
	self.boss_reward_view:SetData(data)
	self.boss_reward_view:Open()
end

function CrossServerCtrl:RecvMainRoleInfo()
	for i,v in ipairs(CrossConfig.crossFBConfigList) do
		CrossServerCtrl.Instance.SendCrossServerCopyDataReq(v.FbId)
	end
	-- CrossServerCtrl.SentCrossTurnBrandReq(3)
	-- CrossServerCtrl.SentCrossEqInfoReq(1)
	-- CrossServerCtrl.SentCrossTurnBrandReq(0)
	-- CrossServerCtrl.SentNeedValSceneValReq(2)
end

function CrossServerCtrl:CheckMainuiTip()
	local num = RemindManager.Instance:GetRemind(RemindName.FreeCrossBrand)
	if num > 0 then
		GuideCtrl.Instance:OpenBrandRemindView()
	end
	MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.FREE_CROSSBRAND, num, function ()
		ViewManager.Instance:Open(ViewName.CrossBattle, TabIndex.crossbattle_brand)
	end)
end

function CrossServerCtrl.CrossServerPingbi()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Common.OnCrossServerTip)
		return true
	end
	return false
end

function CrossServerCtrl:BuyTumo()
	local left_times, cost, bug_val = CrossServerData.Instance:BuyTomoValueInfo()
	if left_times > 0 then
		self.buy_tumo_alert = self.buy_tumo_alert or Alert.New()
		self.buy_tumo_alert:SetShowCheckBox(false)
		self.buy_tumo_alert:SetLableString(string.format(Language.CrossServer.BuyTumoAlert, cost, bug_val))
		self.buy_tumo_alert:SetOkFunc(function()
			-- CrossServerCtrl.SentNeedValSceneValReq(1)
	  	end)
		self.buy_tumo_alert:Open()
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.CrossServer.BuyTumoNoTimes)
	end
end

function CrossServerCtrl:RegisterAllProtocals()
	self:RegisterProtocol(SCCrossServerState, "OnCrossServerState")
	self:RegisterProtocol(SCCrossServerAddress, "OnCrossServerAddress")
	self:RegisterProtocol(SCReturnOriginalServer, "OnReturnOriginalServer")
	self:RegisterProtocol(SCNeedValSceneInfo, "OnNeedValSceneInfo")
	self:RegisterProtocol(SCCrossEquipInfo, "OnCrossEquipInfo")
	self:RegisterProtocol(SCCrossBrandInfo, "OnCrossBrandInfo")
	-- self:RegisterProtocol(SCCrossServerEntrnceState, "OnCrossServerEntrnceState")
	self:RegisterProtocol(SCCrossServerCopyData, "OnCrossServerCopyData") -- 跨服副本数据
	-- self:RegisterProtocol(SCCrossServerPrayResult, "OnCrossServerPrayResult") -- 祈福结果
end

function CrossServerCtrl:OnCrossTumoAddTime(protocol)
    self.data:SetCrossTumoAddTime(protocol)
end


function CrossServerCtrl:OnReturnOriginalServer(protocol)
	if not IS_ON_CROSSSERVER then
		return
	end

	local id = AdapterToLua:getInstance():getDataCache("CROSS_BEFORE_ID")
	local merge_id = AdapterToLua:getInstance():getDataCache("CROSS_BEFORE_MERGE_ID")
	if id and merge_id then
		AdapterToLua:getInstance():setDataCache("PRVE_SRVER_ID", id)
		AdapterToLua:getInstance():setDataCache("MERGE_ID", merge_id)
		AdapterToLua:getInstance():setDataCache("IS_RECONNECT_ING", "true")
		AdapterToLua:getInstance():setDataCache("CROSS_BEFORE_MERGE_ID", "")
		CrossServerCtrl.CrossBeforePrepare()
		ReStart()
	end
end

-- 下发跨服地址(255, 10)
function CrossServerCtrl:OnCrossServerAddress(protocol)
	local user_vo = GameVoManager.Instance:GetUserVo()
	local cs_info_t = {
		protocol.server_id,
		"cross_server",
		protocol.server_ip,
		protocol.server_port,
	}
	local cs_info_str = table.concat(cs_info_t, "##")

	Log("--->>>SET CROSS_SERVER_INFO:", cs_info_str)
	AdapterToLua:getInstance():setDataCache("CROSS_SERVER_INFO", cs_info_str)
	AdapterToLua:getInstance():setDataCache("CROSS_BEFORE_ID", user_vo.plat_server_id)
	AdapterToLua:getInstance():setDataCache("CROSS_BEFORE_MERGE_ID", user_vo.merge_id)
	AdapterToLua:getInstance():setDataCache("PRVE_SRVER_ID", protocol.server_id)
	AdapterToLua:getInstance():setDataCache("MERGE_ID", protocol.server_id)
	AdapterToLua:getInstance():setDataCache("IS_RECONNECT_ING", "true")
	self.CrossBeforePrepare(true)
	ReStart()
end

-- 跨服前处理
function CrossServerCtrl:CrossBeforePrepare(is_enter)
	TeamCtrl.Instance:OnRemoveTeammate({role_id = RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_ID)})
	ViewManager.Instance:CloseAllView()
	Scene.Instance:GetMainRole():StopMove()
end

function CrossServerCtrl:OnCrossServerState(protocol)
	-- self.data:SetCrossServerState(protocol.state)
end

-- 请求 进入跨服(144, 2)
function CrossServerCtrl.SentJoinCrossServerReq(cross_server_type, entrance_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSJoinCrossServerReq)
	protocol.cross_server_type = cross_server_type
	protocol.entrance_index = entrance_index
	protocol:EncodeAndSend()
end

-- 请求 退出跨服(144, 3)
function CrossServerCtrl.SentQuitCrossServerReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSQuitCrossServerReq)
	protocol:EncodeAndSend()
end

-- 请求 跨服装备 相关
function CrossServerCtrl.SentCrossEqInfoReq(opt_type, eq_pos, opt_type2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossEqInfoReq)
	protocol.opt_type = opt_type -- 操作类型 1获取装备信息, 2升阶/魔化
	protocol.eq_pos = eq_pos or 0 -- 部位 1吊坠 2护肩 3面甲 4护膝 5护心
	protocol.opt_type2 = opt_type2 or 0 -- 1升阶 2魔化
	protocol:EncodeAndSend()
end

function CrossServerCtrl:OnCrossEquipInfo(protocol)
	if protocol.result == 0 then
		-- 1 获取装备信息 2 升阶魔化
		local reason = 1
		if protocol.opt_type == 1 then
			reason = 1
		elseif protocol.opt_type == 2 then
			reason = 2
		end
		self.data:SetCrossEquipData(protocol.equip_info_list, reason)

		self.battle_view:Flush(TabIndex.crossbattle_equip)
		-- RemindManager.Instance:DoRemind(RemindName.CrossEquipCanUp)
	end
end

-- function CrossServerCtrl.SentNeedValSceneValReq(opt_type)
-- 	local protocol = ProtocolPool.Instance:GetProtocol(CSNeedValSceneValReq)
-- 	protocol.opt_type = opt_type
-- 	protocol:EncodeAndSend()
-- end

function CrossServerCtrl:OnNeedValSceneInfo(protocol)
	self.data:SetSceneValInfo(protocol)
	self.battle_view:Flush(TabIndex.crossbattle_entrance)

	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic.UpdateTaskGuideData then
		scene_logic:UpdateTaskGuideData()
	end
end

-- 请求 翻牌
function CrossServerCtrl.SentCrossTurnBrandReq(opt_type, brand_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossTurnBrandReq)
	protocol.opt_type = opt_type -- 0 面板数据 , >0 翻牌索引
	protocol.brand_index = brand_index -- 0 面板数据 , >0 翻牌索引
	protocol:EncodeAndSend()
end

function CrossServerCtrl:OnCrossBrandInfo(protocol)
	-- self.data:SetFlopInfo(protocol)
	self.data:SetBrandInfo(protocol)
	RemindManager.Instance:DoRemind(RemindName.FreeCrossBrand)
	-- if protocol.opt_type > 0
	-- 	and protocol.brands_data[protocol.opt_type]
	-- 	and protocol.brands_data[protocol.opt_type].item_index > 0 then
	-- 	local brand_index = protocol.opt_type
	-- 	self.battle_view:Flush(TabIndex.crossbattle_brand, "turn_one_brand", {brand_index = brand_index})
	-- else
	-- 	self.battle_view:Flush(TabIndex.crossbattle_brand)
	-- end

	-- CrossServerCtrl.Instance:CheckMainuiTip()
end

function CrossServerCtrl.SendCrossServerEntranceStateReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossServerEntranceStateReq)
	protocol:EncodeAndSend()
end

function CrossServerCtrl:OnCrossServerEntrnceState(protocol)
	self.data:SetEntranceState(protocol.entrance_state)
	-- RemindManager.Instance:DoRemind(RemindName.CrossBattleIsOpen)
end

----------跨服场景数据列表----------

-- 接收"跨服副本"数据 请求(26, 86)
function CrossServerCtrl:OnCrossServerCopyData(protocol)
	self.data:SetCopyData(protocol)
	RemindManager.Instance:DoRemind(RemindName.CrossBossInfo)
	if IS_ON_CROSSSERVER then
		BossData.Instance:SetSceneBossList(protocol.boss_list)
	end
end

-- 请求"跨服副本"数据 返回(26, 86)
function CrossServerCtrl.SendCrossServerCopyDataReq(copy_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossServerCopyData)
	protocol.copy_id = copy_id -- 跨服副本id
	protocol:EncodeAndSend()
end

----------end----------

----------跨服场景数据列表----------

-- -- 返回祈福结果 请求(144, 13)
-- function CrossServerCtrl:OnCrossServerPrayResult(protocol)
-- 	self.data:SetPrayData(protocol)
-- end

-- 发送祈福请求 烈焰返回(144, 13) 龙魂
function CrossServerCtrl.SendCrossServerPrayReq(fuben_index, pray_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossServerPrayReq)
	protocol.fuben_index = fuben_index -- 副本索引 1 烈焰  2 龙魂
	protocol.pray_type = pray_type -- 祈福类型 1 免费祈福  2 元宝祈福
	protocol:EncodeAndSend()
end

----------end----------

