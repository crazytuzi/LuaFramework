-------------------------------------------------------
module(..., package.seeall)

local require = require;
require("ui/ui_funcs")
local ui = require("ui/base");

-------------------------------------------------------
wnd_npc_dialogue = i3k_class("wnd_npc_dialogue", ui.wnd_base)


function wnd_npc_dialogue:ctor()
	self._npcID = nil
end

function wnd_npc_dialogue:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.dialogue = widgets.dialogue
	self.npcName = widgets.npcName
	self.btn_scroll = widgets.btn_scroll
end

function wnd_npc_dialogue:updateData(npcId,count, instanceID)
    self._npcID = npcId
	local data = i3k_db_npc[npcId]
	local fLvl = g_i3k_game_context:GetFameNpcDialogueLvl(data.fameLvl)
	self.dialogue:setText(data["desc"..fLvl])
	local npcModule = self._layout.vars.npcmodule
	local modelId = g_i3k_db.i3k_db_get_npc_modelID(npcId)
	if npcId == eExpTreeId then
		modelId = i3k_db_exptree_common.npcId
	end
	if modelId == 2006 or modelId == 134 or modelId == 31 or modelId == 32 or modelId == 2052 then
		local y = npcModule:getPositionY()
		npcModule:setPositionY(y*0.3)
	elseif modelId == 2018 then
		local y = npcModule:getPositionY()
		npcModule:setPositionY(y*-0.3)
	end
	
	--获取npc当前播放动作
	local action 
	if  npcId == i3k_db_new_festival_info.specialNpc then 
		action = g_i3k_game_context:GetSpecialNpcShowAction()
	end
	ui_set_hero_model(npcModule, modelId, nil, nil, nil, nil, action)
	
	self.npcName:setText(data.remarkName)
	self.btn_scroll:removeAllChildren()
	local LAYER_DB5T = "ui/widgets/db5t"
	if npcId ~= i3k_db_marry_rules.marryYueLaoId and npcId ~= i3k_db_marry_rules.marryTNID then --判断是否为月老
		local children = self.btn_scroll:addChildWithCount(LAYER_DB5T, 2, count)
		if data.FunctionID[1] == TASK_FUNCTION_EQUIP_TRANS then
			for i,v in ipairs(children) do
				v.vars.select1_btn:onClick(self,self.onEquipTrans, data.transFormId[i])
				v.vars.name:setText(i3k_db_equip_transform_cfg[data.transFormId[i]].functionName)
			end
		else
			for i,v in ipairs(children) do
				if data.FunctionID[i]==TASK_FUNCTION_TRANSFER then
					v.vars.select1_btn:onClick(self,self.onTransfer)
					v.vars.name:setText("转职")
				elseif data.FunctionID[i]==TASK_FUNCTION_TRANSFER_PRV then
					v.vars.select1_btn:onClick(self,self.onTransferPreview)
					v.vars.name:setText("转职预览")
				elseif data.FunctionID[i]==TASK_FUNCTION_GUTTERMAN then
					v.vars.select1_btn:onClick(self,self.onSale,data.exchangeId[1])
					v.vars.name:setText("货郎")
				elseif data.FunctionID[i]==TASK_FUNCTION_TRANSPORT then
					local escort_taskId = g_i3k_game_context:GetFactionEscortTaskId()
					if escort_taskId ~= 0 then
						v.vars.select1_btn:onClick(self,self.onTransport)
						v.vars.name:setText("帮派运镖")
					else
						v.vars.select1_btn:hide()
						count = count - 1
					end
				elseif data.FunctionID[i]== TASK_FUNCTION_MESSAGEBOARD then
					v.vars.select1_btn:onClick(self,self.onMessage)
					v.vars.name:setText("留言板")
				elseif data.FunctionID[i]== TASK_FUNCTION_NPCEXCHANGE then
					v.vars.select1_btn:onClick(self,self.onNpcExchange,{npcId = npcId,exchangeId = i3k_db_npc[npcId].exchangeId})
					v.vars.name:setText("兑换奖励")
				elseif data.FunctionID[i] == TASK_FUNCTION_MRG then
					if g_i3k_game_context:GetMarriageTaskOpen() == 0 then
						v.vars.select1_btn:onClick(self,self.onOpenMrgTask)
						v.vars.name:setText("开启任务")
					else
						v.vars.select1_btn:hide()
						count = count - 1
					end
				elseif data.FunctionID[i] == TASK_FUNCTION_HOTEL then
					v.vars.select1_btn:onClick(self,self.onHotelBtn)
					v.vars.name:setText("江湖客栈")
					local needLvl = i3k_db_treasure_base.other.needLvl
					local lvl = g_i3k_game_context:GetLevel()
					v.vars.select1_btn:setVisible(lvl >= needLvl)
				elseif data.FunctionID[i] == TASK_FUNCTION_GAMBLE then
					v.vars.select1_btn:onClick(self,self.onMFShopBtn, data.exchangeId[1])
					if data.exchangeId[1]>=3 then
						v.vars.name:setText("鸿运商城")
					else
						v.vars.name:setText("武勋商城")
					end

				elseif data.FunctionID[i] == TASK_FUNCTION_WEAPON_NPC then
					v.vars.select1_btn:onClick(self,self.onWeaponNPCBtn)
					v.vars.name:setText("进入天隙")
				elseif data.FunctionID[i] == TASK_FUNCTION_RIGHTHEART_NPC then
					if i == 1 then
						v.vars.select1_btn:onClick(self,self.onRightHeartNPCBtn)
						v.vars.name:setText("进入副本")
					else
						v.vars.select1_btn:onClick(self,function()
							if  g_i3k_game_context:GetLevel() < i3k_db_rightHeart.openlevel then
								return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19194,i3k_db_rightHeart.openlevel))
							end
							if not g_i3k_game_context:IamTeamLeader() and g_i3k_game_context:GetTeamId() ~= 0 then
								return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15191))
							end
							g_i3k_logic:OpenRightHeart()
						end)
						v.vars.name:setText("活动说明")
					end
				elseif data.FunctionID[i] == TASK_FUNCTION_FIGHT_NPC then
					local condition = g_i3k_game_context:GetFightNpcCondition()
					if npcId == g_i3k_game_context:GetFightNpcId() and condition == f_CONDITION_STATE_OPEN then
						v.vars.name:setText("来战")
						v.vars.select1_btn:onClick(self, self.onGotoFight)
					else
						v.vars.select1_btn:hide()
						count = count - 1
					end
				elseif data.FunctionID[i] == TASK_FUNCTION_FANXIAN then
					v.vars.select1_btn:onClick(self,self.onFanxianBtn)
					v.vars.name:setText("储值返还")
				elseif data.FunctionID[i] == TASK_FUNCTION_NPCTRANSFER then
					for _, j in pairs(i3k_db_npc_transfer) do
						if j.npcId == npcId then
							v.vars.name:setText(j.btnTxt)
							v.vars.select1_btn:onClick(self,self.onNpcTransferBtn, j)
							break
						end
					end
				elseif data.FunctionID[i] == TASK_FUNCTION_LEGEND then
					v.vars.name:setText("传世装备")
					v.vars.select1_btn:onClick(self, self.onMakeLegend)
				elseif data.FunctionID[i] == TASK_FUNCTION_DEFEND_ENTER then
					local cfg = g_i3k_db.i3k_db_get_defend_cfg_from_npcid(npcId)
					v.vars.name:setText(cfg.descName)
					v.vars.select1_btn:onClick(self, self.onDefendEnter, {cfg = cfg})
				elseif data.FunctionID[i] == TASK_FUNCTION_DEFEND_RANK then
					v.vars.name:setText("排行榜")
					v.vars.select1_btn:onClick(self, self.onQueryRank)
					v.vars.select1_btn:hide()
					count = count - 1
				elseif data.FunctionID[i] == TASK_FUNCTION_PRAY then
					local prayData = i3k_db_pray_activity[data.prayID]
					if g_i3k_checkIsInDateByStringTime(prayData.startTime, prayData.endTime) then
						v.vars.name:setText("祈福活动")
						v.vars.select1_btn:onClick(self, self.onPrayActivity, {prayData = prayData, npcName = data.remarkName, npcModule = modelId,} )
					else
						v.vars.select1_btn:hide()
					end
				elseif data.FunctionID[i] == TASK_FUNCTION_NPC_DUNGEON then
					local fbId
					for i,v in ipairs(i3k_db_NpcDungeon) do
						if v.npcId == npcId then
							fbId = i
						end
					end
					if fbId then
						v.vars.name:setText("进入副本")
						v.vars.select1_btn:onClick(self, self.onGotoNpcDungeon, {fbId  = fbId})
					end
				elseif data.FunctionID[i] == TASK_FUNCTION_EXP_TREE_SHAKE then
					v.vars.name:setText("赏花")

					v.vars.select1_btn:onClick(self, function ()
						if g_i3k_game_context:GetLevel() < i3k_db_exptree_common.levelLimit then
							g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(341,i3k_db_exptree_common.levelLimit))
							return
						end

						local curWachingTimes = g_i3k_game_context:getWatchingTimes()
						if curWachingTimes < i3k_db_exptree_common.shakeNum then
							i3k_sbean.request_exp_tree_get_drop_req(function (data)
								g_i3k_game_context:setWatchingTimes(curWachingTimes + 1)
								g_i3k_ui_mgr:OpenUI(eUIID_ExpTreeShake);
								g_i3k_ui_mgr:RefreshUI(eUIID_ExpTreeShake,data);
							end)
						else
							g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15500))
						end
					end)
				elseif data.FunctionID[i] == TASK_FUNCTION_EXP_TREE_WATER then
					if g_i3k_game_context:getExpTreeLevel() >= #i3k_db_exptree_level then
						v.vars.name:setText("丰收")
						v.vars.select1_btn:onClick(self, function ()
							if g_i3k_game_context:GetLevel() < i3k_db_exptree_common.levelLimit then
								g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(341,i3k_db_exptree_common.levelLimit))
								return
							end

							i3k_sbean.request_exp_tree_sync_req(function ()
								g_i3k_ui_mgr:OpenUI(eUIID_ExpTreeFlower);
								g_i3k_ui_mgr:RefreshUI(eUIID_ExpTreeFlower);
							end)
						end)
					else
						v.vars.name:setText("浇水")
						v.vars.select1_btn:onClick(self, function ()
							if g_i3k_game_context:GetLevel() < i3k_db_exptree_common.levelLimit then
								g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(341,i3k_db_exptree_common.levelLimit))
								return
							end

							i3k_sbean.request_exp_tree_sync_req(function ()
								g_i3k_ui_mgr:OpenUI(eUIID_ExpTreeWater);
								g_i3k_ui_mgr:RefreshUI(eUIID_ExpTreeWater);
							end)
						end)
					end
				elseif data.FunctionID[i] == TASK_FUNCTION_DESTROY_ITEM then
					v.vars.name:setText("道具销毁")
					v.vars.select1_btn:onClick(self, self.openDestroyItemUI)
				elseif data.FunctionID[i] == TASK_FUNCTION_EQUIP_SHARPEN then
					v.vars.name:setText("装备淬锋")
					v.vars.select1_btn:onClick(self, self.openEquipSharpenUI)
				elseif data.FunctionID[i] == TASK_FUNCTION_WOODENTRIPOD_REFINE then
					v.vars.name:setText("神木鼎")
					v.vars.select1_btn:onClick(self, self.openWoodenTripodUI)
				elseif data.FunctionID[i] == TASK_FUNCTION_SINGLE_DUNGEON then
					v.vars.name:setText("进入副本")
					for k, j in ipairs(i3k_db_NpcDungeon) do
						if j.npcId == npcId then
							if j.openType == 0 then
								v.vars.select1_btn:onClick(self, self.enterSingleDungeon, k)
							else
								v.vars.select1_btn:onClick(self, self.onGotoNpcDungeon, {fbId  = k})
							end
						end
					end
				elseif data.FunctionID[i] == TASK_FUNCTION_PRAY_WORDS then
					if g_i3k_checkIsInDateByStringTime(i3k_db_word_exchange_cfg.startTime, i3k_db_word_exchange_cfg.endTime) then
						v.vars.name:setText("祈福")
						v.vars.select1_btn:onClick(self, self.prayWords)
					else
						v.vars.select1_btn:hide()
					end
				elseif data.FunctionID[i] == TASK_FUNCTION_EXCHANGE_WORDS then
					if g_i3k_checkIsInDateByStringTime(i3k_db_word_exchange_cfg.startTime, i3k_db_word_exchange_cfg.endTime) then
						v.vars.name:setText("文字兑换")
						v.vars.select1_btn:onClick(self, self.openExchangeWordsUI)
					else
						v.vars.select1_btn:hide()
					end
				elseif data.FunctionID[i] == TASK_FUNCTION_FIND_MOONCAKE then
					 v.vars.name:setText("找你妹")
					v.vars.select1_btn:onClick(self, self.openFindMooncakeUI)
				elseif data.FunctionID[i] == TASK_FUNCTION_CHANGE_PRE then
					v.vars.name:setText("职业变更")
					v.vars.select1_btn:onClick(self, self.changePrf)
				elseif data.FunctionID[i] == TASK_FUNCTION_PET_RACE then
					local children = self.btn_scroll:addChildWithCount(LAYER_DB5T, 2, 2)
					for i,v in ipairs(children) do
						if i==1 then
							v.vars.name:setText("宠物竞赛")
							v.vars.select1_btn:onClick(self, self.openPetRaceUI)
						else
							v.vars.name:setText("龟龟商城")
							v.vars.select1_btn:onClick(self, self.openPetRaceStore)
						end
					end
				elseif data.FunctionID[i] == TASK_FUNCTION_SPRING_HELP then
					v.vars.name:setText("玩法规则")
					v.vars.select1_btn:onClick(self, function  ()
						g_i3k_ui_mgr:ShowHelp(i3k_get_string(3173, i3k_db_spring.common.weeklyEnter))
					end)
				elseif data.FunctionID[i] == TASK_FUNCTION_NATIONAL_RAISE_FLAG then
					if g_i3k_checkIsInDateByStringTime(i3k_db_national_activity_cfg.startTime, i3k_db_national_activity_cfg.endTime) then
						v.vars.name:setText("加油中国")
						v.vars.select1_btn:onClick(self, self.openRaiseFlagUI)
					else
						v.vars.select1_btn:hide()
					end
				elseif data.FunctionID[i] == TASK_FUNCTION_ENTER_SECT_ZONE then
					v.vars.name:setText("进入驻地")
					v.vars.select1_btn:onClick(self, self.onSectZoneEnter)
				elseif data.FunctionID[i] == TASK_FUNCTION_LEAVE_MAP_COPY then
					local desc = g_i3k_game_context:GetIsInHomeLandZone() and "离开家园" or "离开副本"
					v.vars.name:setText(desc)
					v.vars.select1_btn:onClick(self, self.onLeaveMapCopy)
				elseif data.FunctionID[i] == TASK_FUNCTION_SECT_ZONE_DONATE_RANK then
					v.vars.name:setText("驻地捐献榜单")
					v.vars.select1_btn:onClick(self, self.onSectZoneDonateRank)
				elseif data.FunctionID[i] == TASK_FUNCTION_SECT_ZONE_ACTIVITY then
					v.vars.name:setText("驻地伏魔")
					v.vars.select1_btn:onClick(self, self.onSectZoneBoss)
				elseif data.FunctionID[i] == TASK_FUNCTION_BID then
					v.vars.name:setText("拍卖行")
					v.vars.select1_btn:onClick(self, self.onOpenBidUI)
				elseif data.FunctionID[i] == TASK_BREAKSEAL_DONATE then
					v.vars.name:setText("百川剑界")
					v.vars.select1_btn:onClick(self, self.onOpenBreakSealUI, npcId)
				elseif data.FunctionID[i] == TASK_FUNCTION_CHRISTAMAS_WISH then
					if g_i3k_checkIsInDateByStringTime(i3k_db_christmas_wish_cfg.startTime, i3k_db_christmas_wish_cfg.endTime) then
						v.vars.name:setText("许愿")
						v.vars.select1_btn:onClick(self, self.openWishUI)
					else
						v.vars.select1_btn:hide()
					end
				elseif data.FunctionID[i] == TASK_FUNCTION_WISHES_LIST then
					if g_i3k_checkIsInDateByStringTime(i3k_db_christmas_wish_cfg.startTime, i3k_db_christmas_wish_cfg.endTime) then
						v.vars.name:setText("浏览")
						v.vars.select1_btn:onClick(self, self.openWishListUI)
					else
						v.vars.select1_btn:hide()
					end
				--elseif data.FunctionID[i] == TASK_FUNCTION_EQUIP_TRANS then
				--	v.vars.name:setText(i3k_get_string(1246))
				--	v.vars.select1_btn:onClick(self, self.onEquipTrans)
				elseif data.FunctionID[i] == TASK_FUNCTION_NEWYEAR_RED then
					local currTime = g_i3k_get_GMTtime(i3k_game_get_time())
					local isInDate = false
					for i,v in ipairs(i3k_db_newYear_red.gift) do
						if v.date + v.endTime > currTime and v.date + v.startTime < currTime then
							for _,id in ipairs(v.npcIds) do
								if id == npcId then
									isInDate = true
									break
								end
							end
							break
						end
					end
					if isInDate then
						v.vars.name:setText("不忘师恩")
						v.vars.select1_btn:onClick(self, self.getNewYearRed, npcId)
					else
						v.vars.select1_btn:hide()
					end
				elseif data.FunctionID[i] == TASK_FUNCTION_RIGHTHEART_FASTMATCH then --正义之心快速匹配
					v.vars.select1_btn:onClick(self,self.onRightHeartNPCBtn, g_RIGHTHEART_MATCH)
					v.vars.name:setText("快速匹配")
				elseif data.FunctionID[i] == TASK_FUNCTION_DEFEND_FASTMATCH then --守护副本快速匹配
					local cfg = g_i3k_db.i3k_db_get_defend_cfg_from_npcid(npcId)
					v.vars.select1_btn:onClick(self, self.onDefendEnter, {cfg = cfg, fastMatch = g_DEFEND_MATCH})
					v.vars.name:setText("快速匹配")
				elseif data.FunctionID[i] == TASK_FUNCTION_NPC_FASTMATCH then --NPC副本快速匹配
					local fbId
					for i,v in ipairs(i3k_db_NpcDungeon) do
						if v.npcId == npcId then
								fbId = i
						end
					end
					if fbId then
						v.vars.select1_btn:onClick(self, self.onGotoNpcDungeon, {fbId  = fbId, fastMatch = g_NPC_MATCH})
						v.vars.name:setText("快速匹配")
					end
				elseif data.FunctionID[i] == TASK_FUNCTION_EQUIP_TRANS_FROM_TO then
					v.vars.select1_btn:onClick(self, self.onEquipRecast)
					v.vars.name:setText("装备重铸")
				elseif data.FunctionID[i] == TASK_FUNCTION_FIVE_TRANS then
					v.vars.select1_btn:onClick(self, self.onFiveTrans)
					v.vars.name:setText("五转之路")
				elseif data.FunctionID[i] == TASK_FUNCTION_DESTINY_ROLL then
					v.vars.select1_btn:onClick(self, self.onDestinyRoll)
					v.vars.name:setText(i3k_get_string(1382))
				elseif data.FunctionID[i] == TASK_FUNCTION_SINGLE_CHALLENGE then
					v.vars.select1_btn:onClick(self, self.onSingleChallenge, data.exchangeId[1])
					v.vars.name:setText("宗门禁地")
				elseif data.FunctionID[i] == TASK_FUNCTION_FACTION_ASSIST then
					v.vars.select1_btn:onClick(self, self.onFactionAssist)
					v.vars.name:setText(i3k_get_string(1386))
				elseif data.FunctionID[i] == TASK_FUNCTION_POWER_REP_TASK then
					v.vars.select1_btn:onClick(self, self.onPowerRepTask)
					v.vars.name:setText(i3k_get_string(17251))--("势力声望接取")
				elseif data.FunctionID[i] == TASK_FUNCTION_POWER_REP_COMMIT then
					v.vars.select1_btn:onClick(self, self.onPowerRepCommit)
					v.vars.name:setText(i3k_get_string(17252))--("捐赠军需")
				elseif data.FunctionID[i] == TASK_FUNCTION_CREATE_HOMELAND then
					v.vars.select1_btn:onClick(self, self.onCreateHomeLand)
					v.vars.name:setText(g_i3k_game_context:GetHomeLandLevel() == 0 and "创建家园" or "进入家园")
				elseif data.FunctionID[i] == TASK_FUNCTION_CHESS_TASK then
					v.vars.select1_btn:onClick(self, self.onAcceptChessTask)
					v.vars.name:setText("珍珑棋局")
				elseif data.FunctionID[i] == TASK_FUNCTION_CHESS_TASK_DESCRIPTION then
					v.vars.select1_btn:onClick(self, self.onOpenChessDescription)
					v.vars.name:setText(i3k_get_string(17271))
				elseif data.FunctionID[i] == TASK_FUNCTION_NPC_DONATE then
					v.vars.select1_btn:onClick(self, self.onOpenNpcDonate)
					v.vars.name:setText("佛诞节")
				elseif data.FunctionID[i] == TASK_FUNCTION_POWER_REP_HUAJIAN or
					data.FunctionID[i] == TASK_FUNCTION_POWER_REP_SONGSHAN or
					data.FunctionID[i] == TASK_FUNCTION_POWER_REP_FUBO    or
					data.FunctionID[i] == TASK_FUNCTION_POWER_REP_HUKUO	or
					data.FunctionID[i] == TASK_FUNCTION_POWER_REP_YINGLUAN or
					data.FunctionID[i] == TASK_FUNCTION_POWER_REP_FURONG or
					data.FunctionID[i] == TASK_FUNCTION_POWER_TIGER or
					data.FunctionID[i] == TASK_FUNCTION_POWER_FOOD or
					data.FunctionID[i] == TASK_FUNCTION_POWER_HOME then
						v.vars.select1_btn:hide() -- 特殊逻辑，只显示头顶信息，点击npc对话不显示按钮
				elseif data.FunctionID[i] == TASK_FUNCTION_FRAME_SHOP then
					local openLevel = i3k_db_server_limit.breakSealCfg.limitLevel
					local roleLevel = g_i3k_game_context:GetLevel()
					if roleLevel >= openLevel then
						v.vars.select1_btn:show()
						v.vars.select1_btn:onClick(self, self.onOpenFramShop)
						v.vars.name:setText("武林商城")
					else
						v.vars.select1_btn:hide()
					end
				elseif data.FunctionID[i] == TASK_FUNCTION_FAMILY_DONATE then
					v.vars.select1_btn:show()
					v.vars.select1_btn:onClick(self, self.onOpenFamilyDonate)
					v.vars.name:setText(i3k_get_string(1444))
				elseif data.FunctionID[i] == TASK_FUNCTION_DEFENCE_WAR_TRANS then
					v.vars.select1_btn:show()
					v.vars.select1_btn:onClick(self, self.onDefenceWarTrans, npcId)
					v.vars.name:setText("城战传送")
				elseif data.FunctionID[i] == TASK_FUNCTION_DEFENCE_WAR_CAR then
					v.vars.select1_btn:show()
					v.vars.select1_btn:onClick(self, self.onDefenceWarBuyCar)
					v.vars.name:setText("购买工程车")
					local widgets = self._layout.vars
					widgets.des:setVisible(true)
					widgets.des:setText(i3k_get_string(5290, i3k_db_defenceWar_cfg.car.carCost))
				elseif data.FunctionID[i] == TASK_FUNCTION_HOMELAND_PRODUCE then
					v.vars.select1_btn:show()
					v.vars.select1_btn:onClick(self, self.onHomeLandProduce)
					v.vars.name:setText("家员生产")
				elseif data.FunctionID[i] == TASK_FUNCTION_HOMELAND_RELEASE then
					v.vars.select1_btn:show()
					v.vars.select1_btn:onClick(self, self.homeLandRelease)
					v.vars.name:setText("放生")
				elseif data.FunctionID[i] == TASK_FUNCTION_HOMELAND_RELEASE_RANK then
					v.vars.select1_btn:show()
					v.vars.select1_btn:onClick(self, self.homeLandReleaseRank)
					v.vars.name:setText("放生排行")
				elseif data.FunctionID[i] == TASK_FUNCTION_DEFENCE_WAR_REPAIR_TOWER then
					v.vars.select1_btn:show()
					v.vars.select1_btn:onClick(self, self.onDefenceWarRepairTower, instanceID)
					v.vars.name:setText("箭塔修复")
				elseif data.FunctionID[i] == TASK_FUNCTION_HOMELAND_ENTERHOUSE then
					v.vars.select1_btn:show()
					v.vars.select1_btn:onClick(self, self.homeLandEnterHouse)
					v.vars.name:setText("进入房屋")
				elseif data.FunctionID[i] == TASK_FUNCTION_ENTER_HOMELAND then
					v.vars.select1_btn:show()
					v.vars.select1_btn:onClick(self, self.enterHomeLand)
					v.vars.name:setText("进入家园")
				elseif data.FunctionID[i] == TASK_FUNCTION_PASS_EXAM_GIFT then
					v.vars.select1_btn:show()
					v.vars.select1_btn:onClick(self, self.onPassExamGift)
					v.vars.name:setText("登科有礼")
				elseif data.FunctionID[i] == TASK_FUNCTION_PET_DUNGEON then
					v.vars.select1_btn:show()
					v.vars.select1_btn:onClick(self, self.onPetDungeon, npcId)
					v.vars.name:setText(i3k_get_string(1506))
				elseif data.FunctionID[i] == TASK_FUNCTION_SWORN_FRIENDS then
					v.vars.select1_btn:show()
					v.vars.select1_btn:onClick(self, self.onSwornFriends)
					v.vars.name:setText(i3k_get_string(g_i3k_game_context:getSwornFriends() and 5412 or 5408))
				elseif data.FunctionID[i] == TASK_FUNCTION_REFRESH_RANKS then
					v.vars.select1_btn:show()
					v.vars.select1_btn:onClick(self, self.onRefreshRanks)
					v.vars.name:setText(i3k_get_string(5409))
				elseif data.FunctionID[i] == TASK_FUNCTION_BREAK_SWORN then
					v.vars.select1_btn:show()
					v.vars.select1_btn:onClick(self, self.onBreakSworn)
					v.vars.name:setText(i3k_get_string(5410))
				elseif data.FunctionID[i] == TASK_FUNCTION_KICK_SWORN_FRIENDS then
					v.vars.select1_btn:show()
					v.vars.select1_btn:onClick(self, self.onKickSwornFriends)
					v.vars.name:setText(i3k_get_string(5411))
				elseif data.FunctionID[i] == TASK_FUNCTION_SWORN_RULE then
					v.vars.select1_btn:show()
					v.vars.select1_btn:onClick(self, self.onSwornRule)
					v.vars.name:setText(i3k_get_string(5442))
				elseif data.FunctionID[i] == TASK_FUNCTION_FESTIVAL_LIMIT then
					v.vars.select1_btn:show()
					v.vars.select1_btn:onClick(self, self.onFestivalTask, data.exchangeId[1])
					v.vars.name:setText(i3k_get_string(i3k_db_festival_cfg[data.exchangeId[1]].btnString))
				elseif data.FunctionID[i] == TASK_FUNCTION_LING_QIAN then
					v.vars.name:setText(i3k_db_ling_qian[data.prayID].name)
					v.vars.select1_btn:show()
					v.vars.select1_btn:onClick(self, self.onLingQianTask, {prayID = data.prayID, moduleID =modelId, npcID = data.ID})
				elseif data.FunctionID[i] == TASK_FUNCTION_SHAKE_TREE then
					local actID = g_i3k_db.i3k_db_get_shake_tree_activityID()
					if actID then
						v.vars.name:setText("摇一摇")
						v.vars.select1_btn:onClick(self, self.openShakeTree, actID)
					else
						v.vars.select1_btn:hide()
					end
				elseif data.FunctionID[i] == TASK_FUNCTION_ROLE_FLYING then
					v.vars.name:setText(i3k_get_string(1686))
					v.vars.select1_btn:show()
					v.vars.select1_btn:onClick(self, self.onRoleFlying, data)
				elseif data.FunctionID[i] == TASK_FUNCTION_GEM_EXCHANGE then
					v.vars.name:setText(i3k_get_string(18076))
					v.vars.select1_btn:show()
					v.vars.select1_btn:onClick(self, self.onGemExchangeBt)
				elseif data.FunctionID[i] == TASK_FUNCTION_CITYWAY_EXP then
					v.vars.name:setText(i3k_get_string(5511))
					v.vars.select1_btn:show()
					v.vars.select1_btn:onClick(self, self.onCityWarExpBt)
				elseif data.FunctionID[i] == TASK_FUNCTION_FIVE_ELEMENTS then
					v.vars.select1_btn:onClick(self, self.onFiveElements)
					v.vars.name:setText("天化五行")
				elseif data.FunctionID[i] == TASK_FUNCTION_DETECTIVE then
					v.vars.select1_btn:onClick(self, self.onKnightlyDetective)
					v.vars.name:setText(i3k_get_string(18200))
				elseif data.FunctionID[i] == TASK_FUNCTION_CATCH_SPIRIT then
					v.vars.select1_btn:onClick(self, self.onCatchSpirit)
					v.vars.name:setText("学习驭灵术")
				elseif data.FunctionID[i] == TASK_FUNCTION_SPY_STORY then
					v.vars.select1_btn:onClick(self, self.onSpyStory)
					v.vars.name:setText("密探风云")
				elseif data.FunctionID[i] == TASK_FUNCTION_NEW_CAREER_TASK then
					v.vars.select1_btn:onClick(self, self.onOutCareerPractice, data.exchangeId[1])
					v.vars.name:setText(i3k_get_string(18503, i3k_db_generals[data.exchangeId[1]].name))

				elseif data.FunctionID[i] == TASK_SPRING_ROLL_MAIN then
					v.vars.select1_btn:onClick(self, self.onSpringRollMain, npcId)
					v.vars.name:setText(i3k_get_string(19047))
				elseif data.FunctionID[i] == TASK_SPRING_ROLL_BATTLE then
					if g_i3k_game_context:checkSpringRollOpen() and g_i3k_game_context:checkSpringRollNpc(npcId) then
						v.vars.select1_btn:onClick(self, self.onSpringRollBattle, npcId)
						v.vars.name:setText(i3k_get_string(19048))
					else
						v.vars.select1_btn:hide()
					end
				elseif data.FunctionID[i] == TASK_SPRING_ROLL_QUIZ then
					if g_i3k_game_context:checkSpringRollOpen() and g_i3k_game_context:checkSpringRollNpc(npcId) then
						v.vars.select1_btn:onClick(self, self.onSpringRollQuiz, npcId)
						v.vars.name:setText(i3k_get_string(19048))
					else
						v.vars.select1_btn:hide()
					end
				elseif data.FunctionID[i] == TASK_SPRING_ROLL_BUY then
					if g_i3k_game_context:checkSpringRollOpen() and g_i3k_game_context:checkSpringRollNpc(npcId) then
						v.vars.select1_btn:onClick(self, self.onSpringRollBuy, npcId)
						v.vars.name:setText(i3k_get_string(19048))
					else
						v.vars.select1_btn:hide()
					end
				elseif data.FunctionID[i] == TASK_FUNCTION_COOK then
					v.vars.select1_btn:onClick(self, self.onLinkageActivityCook)
					v.vars.name:setText("烹饪")
				elseif data.FunctionID[i] == TASK_NEW_FESTIVAL_ACCEPT then
					v.vars.select1_btn:onClick(self, self.onNewFestivalAccept)
					v.vars.name:setText(i3k_get_string(19003)) 
				elseif data.FunctionID[i] == TASK_NEW_FESTIVAL_COMMIT then
					v.vars.select1_btn:onClick(self, self.onNewFestivalCommit)
					v.vars.name:setText(i3k_get_string(19004))
				end
			end
		end
	else   ---1 尚未结婚 1 去游街<结束之前都不变> ，2 去宴席  0 已婚
		--g_i3k_game_context:selectEnderModel()   --先判断是否超过婚礼进行时 超过直接显示我要离婚按钮
		local step= g_i3k_game_context:getRecordSteps()
		if npcId == i3k_db_marry_rules.marryYueLaoId then
			local children = self.btn_scroll:addChildWithCount(LAYER_DB5T, 2, 3)
			for i,v in ipairs(children) do
				if i==1 then
					if step ~= -1 then
						v.vars.select1_btn:setTag(1000)
						v.vars.name:setText("我要离婚")
					else
						v.vars.select1_btn:setTag(999)
						v.vars.name:setText("我要结婚")
					end
				elseif i == 2 then
					v.vars.select1_btn:setTag(1003)
					v.vars.name:setText("结婚说明")
				else
					local marryType = g_i3k_game_context:getMarryType()
					--普通婚礼结婚，并且没有升级婚姻
					if step ~= -1 and marryType == 1 then
						v.vars.select1_btn:show()
						v.vars.select1_btn:setTag(1005)
						v.vars.name:setText("升级婚礼")
					else
						v.vars.select1_btn:hide()
					end
				end
				v.vars.select1_btn:onClick(self,self.onMarry)
			end
		elseif npcId == i3k_db_marry_rules.marryTNID then
			local marryBtnName = {[-1] = "我要结婚",[1]="开始游街",[2]="开始宴席",[0]="我要离婚"}
			local oTrue = (step == 1 or step == 2) and true
			local children = self.btn_scroll:addChildWithCount(LAYER_DB5T, 2, oTrue and 3 or 2)
			for i,v in ipairs(children) do
				if i ==1 then
					v.vars.select1_btn:setTag(1004)
					v.vars.select1_btn:onClick(self,self.onMarry)
					v.vars.name:setText("预约婚礼")
				elseif oTrue and i == 2 then
					v.vars.select1_btn:setTag(1000+step)
					v.vars.select1_btn:onClick(self,self.onMarry)
					v.vars.name:setText(marryBtnName[step])
				else
					v.vars.select1_btn:setTag(1003)
					v.vars.select1_btn:onClick(self,self.onMarry)
					v.vars.name:setText("结婚说明")
				end
			end
		end
	end

	self.btn_scroll:setVisible(count > 0)
	if count <= 0 then
		self._layout.vars.closebtn:onClick(self,self.onCloseUI)
	end
end

function wnd_npc_dialogue:transUI(euid)
	g_i3k_ui_mgr:OpenUI(euid)
	g_i3k_ui_mgr:RefreshUI(euid)
	g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
end

function wnd_npc_dialogue:onSale(sender,gid)
	--点击货郎
	g_i3k_logic:OpenCommonStoreUI(gid)
	g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
end

--帮派运镖
function wnd_npc_dialogue:onTransport(sender)
	i3k_sbean.escort_finish()
	g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
end

--点击留言板
function wnd_npc_dialogue:onMessage(sender)
	g_i3k_logic:OpenBillBoardUI()
end

-- npc物品兑换
function wnd_npc_dialogue:onNpcExchange(sender,tbl)
	npcId = tbl.npcId
	exchangeId = tbl.exchangeId
	if npcId == 18022 then
		g_i3k_ui_mgr:OpenUI(eUIID_DigitalCollection)
		g_i3k_ui_mgr:RefreshUI(eUIID_DigitalCollection, npcId, exchangeId)
	else
		g_i3k_logic:OpenNpcExchange(npcId,exchangeId)
	end
	g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
end

--点击月老
function wnd_npc_dialogue:onMarry(sender,npcId)
	local tag = sender:getTag() -1000
	local gotoMarry = {
	[-1] = function() --缔结姻缘
				if g_i3k_game_context:getLeaderToHandle() then
					g_i3k_game_context:setEnterProNum(3)
					g_i3k_logic:OpenMerryCreate()
					g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
				else
					g_i3k_ui_mgr:PopupTipMessage("结婚只有组队并且队长才能操作")
				end
			end,
	[1] = function() --去游街
			--g_i3k_game_context:setEnterProNum(3)
			--g_i3k_logic:OpenMarryWendding()
			--g_i3k_ui_mgr:PopupTipMessage("去游街")
			if g_i3k_game_context:GetTeamId() == 0 or g_i3k_game_context:GetTeamMemberCount() ~= 1 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3035))
			else
				local function func()
					i3k_sbean.beginToParade()
					g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
				end
				g_i3k_game_context:CheckMulHorse(func)
			end

		end,
	[2] = function() --去宴席
			--g_i3k_game_context:setEnterProNum(3)
			--g_i3k_logic:OpenMarryWendding()
			i3k_sbean.sendToBanquet()
			--g_i3k_ui_mgr:PopupTipMessage("去宴席")
			g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
		end,
	[0] = function() --去离婚
			g_i3k_game_context:setEnterProNum(3)
			g_i3k_logic:OpenMarried_lihun()
			g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
		end,
	[3] = function () --结婚说明
		g_i3k_game_context:setEnterProNum(1)
		g_i3k_logic:OpenMerryProInstructions()
		g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
	end,
	[4] = function () -- 预约婚礼
		g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
		i3k_sbean.sync_marriage_bespeak()
	end,
	[5] = function () -- 升级婚礼
		g_i3k_logic:OpenUpMarryStage()
	end
	}
	gotoMarry[tag]()
end

function wnd_npc_dialogue:onTransfer(sender)
	local transfromLvl = g_i3k_game_context:GetTransformLvl()
	if transfromLvl == #i3k_db_zhuanzhi[1] then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(118))
	elseif transfromLvl == 1 then
		local index = math.floor(math.random(0,1))
		local UId = eUIID_Transfrom2
		if index == 0 then
			UId = eUIID_Transfrom3
		end
		self:transUI(UId)
	else
		self:transUI(eUIID_Transfrom1)
	end
end

function wnd_npc_dialogue:onOpenMrgTask(sender)
	local wife = g_i3k_game_context:GetTeamMembers()
	if g_i3k_game_context:GetTeamId() == 0 then
		return g_i3k_ui_mgr:PopupTipMessage("当前没有队伍")
	elseif g_i3k_game_context:GetTeamLeader() ~= g_i3k_game_context:GetRoleId() then
		return g_i3k_ui_mgr:PopupTipMessage("只有队长才能开启")
	elseif  #wife ~= 1 then
		return g_i3k_ui_mgr:PopupTipMessage("只能夫妻二人组队开启")
	elseif #wife == 1 and not g_i3k_game_context:checkIsLover(wife[1]) then
		return g_i3k_ui_mgr:PopupTipMessage("只能夫妻二人组队开启")
	end
	if i3k_get_MrgTaskFunction() == TASK_FUNCTION_MRG then
		i3k_sbean.mrgseriestask_openReq()
	else
		i3k_sbean.mrglooptask_openReq()
	end
	g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
end

function wnd_npc_dialogue:onHotelBtn(sender)
	i3k_sbean.sync_hostel()
	-- g_i3k_ui_mgr:OpenUI(eUIID_NpcHotel)
	g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
end

function wnd_npc_dialogue:createRoom(creRoom_fun)
	local fun = function()
		local room = g_i3k_game_context:IsInRoom()
		if room then
			if room.type == gRoom_Dungeon or room.type == gRoom_TOWER_DEFENCE then
				local fun = (function(ok)
					if ok then
						i3k_sbean.mroom_self()
					end
				end)
				g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(48), fun)
				return
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(392))
				return
			end
		end
		if g_i3k_game_context:getMatchState() ~= 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(142))
			return
		end
		creRoom_fun()
	end
	g_i3k_game_context:CheckMulHorse(fun)
end

function wnd_npc_dialogue:onRightHeartNPCBtn(sender, fastMatch)
	if  g_i3k_game_context:GetLevel() < i3k_db_rightHeart.openlevel then
		return g_i3k_ui_mgr:PopupTipMessage(string.format("正义之心需要达到%d%s",i3k_db_rightHeart.openlevel,"级"))
	end
	-- if not g_i3k_game_context:IamTeamLeader() and g_i3k_game_context:GetTeamId() ~= 0 then
	-- 	return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15191))
	-- end
	if fastMatch then
		if  g_i3k_game_context:getRightHeartNowHadEnterTimes() <= 0 then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15188))
		end
	end
	local function crr( )
		if fastMatch then
			i3k_sbean.globalmap_join_request(fastMatch, 0)
		else
			i3k_sbean.mroom_create(0)
		end
	end
	self:createRoom(crr)
end

function wnd_npc_dialogue:GetTime(time)
	local hour =math.modf(time/(60*60))
	local minite = math.modf((time - hour*60*60)/60)
	return string.format("%.2d:%.2d",hour,minite)
end

function wnd_npc_dialogue:onGotoNpcDungeon(sender, data)
	local fastMatch = data.fastMatch
	local id = data.fbId
	local nd = i3k_db_NpcDungeon[id]
	if g_i3k_game_context:GetLevel() < nd.openLevel then
		return g_i3k_ui_mgr:PopupTipMessage(string.format("需要达到%d级",nd.openLevel))
	end

	if fastMatch and g_i3k_game_context:getNpcDungeonEnterTimes(id) >= nd.joinCnt then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1309))
	end
	local isInDate = g_i3k_checkIsInDate(nd.openDate, nd.closeDate)

	local weekday = g_i3k_get_week(g_i3k_get_day(i3k_game_get_time()))
	local is_open = false
	local openDay = nd.openDay
	local justiceHeartMapID = i3k_db_common.wipe.justiceHeartMapID
	for key, val in ipairs(justiceHeartMapID) do
		if (id == val) then
			openDay = g_i3k_db.i3k_db_get_justiceHeart_info(id)
		end
	end
	for i , v in ipairs(openDay) do
		if v == weekday then
			is_open = true
			break
		end
	end

	local nowTime = i3k_game_get_time()%86400
	local isNow = nowTime >= nd.startTime and nowTime <= nd.finishTime

	if not isInDate or not is_open or not isNow then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15417))
	end
	local function crr( )
		if fastMatch then
			i3k_sbean.globalmap_join_request(fastMatch, id)
		else
			i3k_sbean.mroom_create(id,gRoom_NPC_MAP)
		end
	end
	self:createRoom(crr)
	self:onCloseUI()
end

function wnd_npc_dialogue:onEquipRecast(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_EquipTransFromTo)
	g_i3k_ui_mgr:RefreshUI(eUIID_EquipTransFromTo)
	self:onCloseUI()
end

-- 五转之路
function wnd_npc_dialogue:onFiveTrans(sender)
	g_i3k_logic:OpenFiveTransUI()
end

-- 天命轮
function wnd_npc_dialogue:onDestinyRoll(sender)
	local fiveTrans = g_i3k_game_context:getFiveTrans()
	local roleLvl = g_i3k_game_context:GetLevel()
	local transform = g_i3k_game_context:GetTransformLvl()
	if(roleLvl < g_i3k_db.i3k_db_get_five_trans_level_requre()) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1377,g_i3k_db.i3k_db_get_five_trans_level_requre()))
	elseif(transform == 0 or fiveTrans.level < i3k_db_five_trans_other.destinyNeedState) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1383, i3k_db_five_trans[i3k_db_five_trans_other.destinyNeedState].name))
	else
		g_i3k_ui_mgr:OpenUI(eUIID_DestinyRoll)
		g_i3k_ui_mgr:RefreshUI(eUIID_DestinyRoll)
	end
end

-- 单人闯关
function wnd_npc_dialogue:onSingleChallenge(sender, id)
	local roleLvl = g_i3k_game_context:GetLevel()
	if not id then
		return
	end
	local cfg = i3k_db_single_challenge_cfg[id]
	if cfg then
		if roleLvl < cfg.needLvl then
			g_i3k_ui_mgr:PopupTipMessage(string.format("等级达到%s级开启", cfg.needLvl))
			return
		end

		local isInDate = g_i3k_checkIsInDate(cfg.startDate, cfg.endDate)

		local weekday = g_i3k_get_week(g_i3k_get_day(i3k_game_get_time()))
		local is_open = false
		for _, v in ipairs(cfg.openDay) do
			if v == weekday then
				is_open = true
				break
			end
		end

		local nowTime = i3k_game_get_time()%86400
		local isNow = nowTime >= cfg.startTime and nowTime <= cfg.endTime

		if not isInDate or not is_open or not isNow then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15417))
		end

		i3k_sbean.single_explore_sync(id)
	end
	self:onCloseUI()
end

function wnd_npc_dialogue:onFiveElements(sender)
	if g_i3k_game_context:GetLevel() < i3k_db_five_elements.openLevel then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(60))
	end
	if not g_i3k_db.i3k_db_get_five_element_can_enter() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(778))
	end
		g_i3k_ui_mgr:OpenUI(eUIID_FiveElements)
		g_i3k_ui_mgr:RefreshUI(eUIID_FiveElements)
	end

-- 帮派助战
function wnd_npc_dialogue:onFactionAssist(sender)
	if not g_i3k_game_context:GetIsOwnFactionZone() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16627))
	end
	if g_i3k_db.i3k_db_is_faction_assist_open() then
		i3k_sbean.sect_assist_sync(g_FACTION_ASSIST)
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("离线助战需角色%s级并且帮派%s级开启", i3k_db_faction_assist.needPlayerLvl, i3k_db_faction_assist.needFactionLvl))
	end
end

-- 势力声望接取任务
function wnd_npc_dialogue:onPowerRepTask(sender)
	local npcID = self._npcID
	local powerSide = g_i3k_db.i3k_db_power_rep_get_type_by_npcid(npcID)
	local levelReq = i3k_db_power_reputation[powerSide].openLevel
	local roleLevel = g_i3k_game_context:GetLevel()
	if levelReq > roleLevel then
		g_i3k_ui_mgr:PopupTipMessage("大侠等到"..levelReq.."级再来找我吧")
		return
	end

	local taskGroupID = g_i3k_db.i3k_db_power_rep_get_task_groupID(npcID)
	local info = g_i3k_game_context:getPowerRep()
	local state = info.tasks[taskGroupID].state  -- 接取1， 0未接取，2完成，3领过奖了
	local checkTab =
	{
		[1] = i3k_get_string(17266), --"已经接取了任务，请到任务栏查看任务",
		[2] = i3k_get_string(17267), --"已经完成任务，请点击左侧任务列表领取奖励",
		[3] = i3k_get_string(17268), --"已经领取了奖励，明日任务刷新再来接取任务",
	}
	if checkTab[state] then
		g_i3k_ui_mgr:PopupTipMessage(checkTab[state])
		return
	end

	g_i3k_ui_mgr:OpenUI(eUIID_PowerReputationTask)
	g_i3k_ui_mgr:RefreshUI(eUIID_PowerReputationTask, npcID)
	self:onCloseUI()
end
-- 势力声望提交道具
function wnd_npc_dialogue:onPowerRepCommit(sender)
	local powerSide = g_i3k_db.i3k_db_power_rep_get_type_by_npcid(self._npcID)
	local levelReq = i3k_db_power_reputation[powerSide].openLevel
	local roleLevel = g_i3k_game_context:GetLevel()
	if levelReq > roleLevel then
		g_i3k_ui_mgr:PopupTipMessage("大侠等到"..levelReq.."级再来找我吧")
		return
	end

	g_i3k_ui_mgr:OpenUI(eUIID_PowerReputationCommit)
	g_i3k_ui_mgr:RefreshUI(eUIID_PowerReputationCommit, self._npcID)
	self:onCloseUI()
end

function wnd_npc_dialogue:onCreateHomeLand(sender)
	if g_i3k_game_context:GetHomeLandLevel() == 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_HomeLandCreate)
		g_i3k_ui_mgr:RefreshUI(eUIID_HomeLandCreate)
	else
		local func = function ()
			g_i3k_game_context:gotoPlayerHomeLand(g_i3k_game_context:GetRoleId())
		end
		g_i3k_game_context:CheckMulHorse(func)
	end
	self:onCloseUI()
end

function wnd_npc_dialogue:onOpenNpcDonate(sender)
	i3k_sbean.sync_doante_info()
	self:onCloseUI()
end

function wnd_npc_dialogue:onOpenFramShop(sender)
	local data = i3k_sbean.fame_shopsync_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.fame_shopsync_res.getName())

	self:onCloseUI()
end

function wnd_npc_dialogue:onWeaponNPCBtn(sender)
	-- if g_i3k_game_context:GetSelectWeapon() ~= 6 then
		-- return g_i3k_ui_mgr:PopupTipMessage("您不满足进入条件")
	-- end
	local select_weapon = g_i3k_game_context:GetSelectWeapon()
	local has_tianxi_unique = false
	local cfg = nil
	local is_open = g_i3k_game_context:GetShenBingUniqueSkillData(select_weapon)
	if is_open then
		for k,v in pairs(i3k_db_shen_bing_unique_skill[select_weapon]) do
			if v.uniqueSkillType == 13 then
				has_tianxi_unique = true
				cfg = v
				break
			end
		end
	end
	if has_tianxi_unique and cfg then
		local curparameters = cfg.parameters
		if g_i3k_game_context:isMaxWeaponStar(g_i3k_game_context:GetSelectWeapon()) then
			curparameters = cfg.manparameters
		end
		if curparameters[1] <= g_i3k_game_context:getWeaponNpcEnterTimes()  then
			g_i3k_ui_mgr:PopupTipMessage("今日进入天隙次数已用尽")
		else
			local function func1()
				local str = string.format("是否进入天隙？\n本日还可进入%d次",(curparameters[1] - g_i3k_game_context:getWeaponNpcEnterTimes()))
				local fun = function(isOk)
					if isOk then
						i3k_sbean.weaponmap_start()
					end
				end
				g_i3k_ui_mgr:ShowCustomMessageBox2("进入", "取消", str, fun)
			end
			g_i3k_game_context:CheckMulHorse(func1)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("只有持有玄武破天弓，并解锁天隙才能进入")
	end
end

function wnd_npc_dialogue:onMFShopBtn(sender, shopId)
	local bw = g_i3k_game_context:GetTransformBWtype()
	local cfg = i3k_db_martialFeat_Shop[shopId]
	if not cfg then
		return
	end
	-- if bw == 0 then
	-- 	return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15177))
	if (bw == 0 or bw == g_justice_League) and cfg.bwtype == g_evil_League then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15176))
	elseif (bw == 0 or bw == g_evil_League) and cfg.bwtype == g_justice_League then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15175))
	end

	local bean = i3k_sbean.feat_gambleshopsync_req.new()
	bean.shopId = shopId
	i3k_game_send_str_cmd(bean, "feat_gambleshopsync_res")
	self:onCloseUI()
end

function wnd_npc_dialogue:onFanxianBtn()
	g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
	i3k_sbean.query_reward()
end

function wnd_npc_dialogue:onNpcTransferBtn(sender,dataTrans,isOk)
    local npcId = self._npcID
	if npcId == 60011 and not isOk then
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(3135), function  (isOk)
			if isOk then
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_NpcDialogue,"onNpcTransferBtn",sender,dataTrans,true)
			end
		end)
		return
	end
    g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
    local itemCnt = g_i3k_game_context:GetCommonItemCanUseCount(dataTrans.needItemID)
    if dataTrans.needItemID > 0 and itemCnt < dataTrans.needItemCount then
        local tip = ""
        if itemCnt > 0 then
            tip = i3k_get_string(15360, dataTrans.needItemCount)
        else
            tip = i3k_get_string(15361, dataTrans.needItemCount, g_i3k_db.i3k_db_get_common_item_name(dataTrans.needItemID))
        end
        g_i3k_ui_mgr:PopupTipMessage(tip)
        return
    end
    for _,v in ipairs(dataTrans.conditions) do
        if v.conditonType == 1 and v.conditionValue > g_i3k_game_context:GetVipLevel() then
            g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15362, v.conditionValue))
            return
        elseif v.conditonType == 2 and v.conditionValue > g_i3k_game_context:GetLevel() then
            g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15363, v.conditionValue))
            return
        end
    end
    if npcId == 60012 then
		local room = g_i3k_game_context:IsInRoom()
		if room or g_i3k_game_context:getMatchState() ~= 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3179))
			return
		end
        --特殊处理温泉NPC传送功能
        local springConfig = i3k_db_spring.common
        local springTime = i3k_db_spring.openTime
        local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
        local year = os.date("%Y", timeStamp )
        local month = os.date("%m", timeStamp )
        local day = os.date("%d", timeStamp)
        local date = os.date("*t", timeStamp)
        local isOpen = false
        for k,v in ipairs(springConfig.openday) do
            if date.wday - 1 == v then
                isOpen = true
                break
            end
        end
        local isInTime = false
        if isOpen then
            for k,v in ipairs(springTime) do
                local startTime = string.split(v.startTime,":")
                local openTime = os.time({year = year, month = month, day = day, hour = startTime[1], min = startTime[2], sec = startTime[3]})
                local closeTime = openTime + v.durTime
                if timeStamp >= openTime and timeStamp <= closeTime then
                    isInTime = true
                    break
                end
            end
        end

        if not isOpen or not isInTime then
            g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3133))
            return
        end
		if g_i3k_game_context:IsOnHugMode() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17039))
			return
		end
    end

    if dataTrans.needItemID > 0 and dataTrans.needItemCount > 0 then
        local function func1()
            local fun = function(isOk)
                if isOk then
                    i3k_sbean.npc_transfrom(dataTrans.id)
                end
            end
            g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(15375, dataTrans.needItemCount, g_i3k_db.i3k_db_get_common_item_name(dataTrans.needItemID)), fun)
        end
        g_i3k_game_context:CheckMulHorse(func1)
    else
        g_i3k_game_context:CheckMulHorse(function()
            i3k_sbean.npc_transfrom(dataTrans.id)
        end)
    end
end

function wnd_npc_dialogue:onPrayActivity( sender, prayData )
	g_i3k_ui_mgr:OpenUI(eUIID_PrayActivity)
	g_i3k_ui_mgr:RefreshUI(eUIID_PrayActivity, prayData)
	self:onCloseUI()
end

function wnd_npc_dialogue:onTransferPreview(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_TransferPreview)
	g_i3k_ui_mgr:RefreshUI(eUIID_TransferPreview)
	self:onCloseUI()
end

function wnd_npc_dialogue:onGotoFight(sender)
	local fightNpcInfo = g_i3k_game_context:GetFightNpcInfo()
	local nowTime = i3k_game_get_time()
	if fightNpcInfo.coolTime >= nowTime then
		g_i3k_ui_mgr:PopupTipMessage("冷却时间未到，请稍后挑战")
		return
	end

	local room = g_i3k_game_context:IsInRoom()
	if room or g_i3k_game_context:getMatchState() ~= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(392))
		return
	end

	local function func()
		i3k_sbean.fightnpc_start()
	end
	g_i3k_game_context:CheckMulHorse(func)
end

function wnd_npc_dialogue:onMakeLegend(sender)
	local bageSize = g_i3k_game_context:GetBagSize()
	local useSize = g_i3k_game_context:GetBagUseCell()

	if bageSize - useSize < 2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1426))
		return
	end

	i3k_sbean.legend_sync()
end

function wnd_npc_dialogue:openPetRaceUI(sender)
	g_i3k_logic:openPetRaceUI()
end

function wnd_npc_dialogue:openPetRaceStore(sender)
	g_i3k_logic:openPetRaceStore()
end

function wnd_npc_dialogue:onDefendEnter(sender, data)
	local cfg = data.cfg
	local fastMatch = data.fastMatch
	if g_i3k_game_context:GetLevel() < cfg.needLevel then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15418, cfg.needLevel))
	end

	local isOpenDay = i3k_get_is_in_open_day(cfg.openDay)
	local nowTime = i3k_game_get_time()
	local isInTime = nowTime >= g_i3k_get_day_time(cfg.openTime) and nowTime <= g_i3k_get_day_time(cfg.openTime + cfg.leftTime)
	local isInDate = g_i3k_checkIsInDate(cfg.openDate, cfg.closeDate)
	if not isOpenDay or not isInTime or not isInDate then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15417))
	end

	if fastMatch and not g_i3k_game_context:getTowerDefenceIsCanEnter(cfg.mapID) then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(71))
	end

	local function callBack( )
		if fastMatch then
			i3k_sbean.globalmap_join_request(fastMatch, cfg.mapID)
		else
			i3k_sbean.mroom_create(cfg.mapID, gRoom_TOWER_DEFENCE)
		end
	end
	self:createRoom(callBack)
end

function wnd_npc_dialogue:onQueryRank(sender)
	--TODO zhang 发协议
	g_i3k_ui_mgr:PopupTipMessage("查看排行榜")

end

function wnd_npc_dialogue:openDestroyItemUI( )
	g_i3k_ui_mgr:OpenUI(eUIID_DestroyItem)
	g_i3k_ui_mgr:RefreshUI(eUIID_DestroyItem)
end

function wnd_npc_dialogue:openEquipSharpenUI()
	g_i3k_logic:openEquipSharpenUI()
end

function wnd_npc_dialogue:openWoodenTripodUI()
	local flag = false
	for i, v in pairs(i3k_db_woodenTripod) do
		if g_i3k_game_context:GetCommonItemCanUseCount(i) > 0 then
			flag = true
		end
	end

	if g_i3k_game_context:GetLevel() < i3k_db_woodenTripod_cfg.openLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3205, i3k_db_woodenTripod_cfg.openLevel))
	elseif flag then
		i3k_sbean.woodenTripodOpen()
    else
	    g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3201))
	end
end

function wnd_npc_dialogue:openFindMooncakeUI()

end

-- explain 伙伴功能开启后,回归功能废弃
function wnd_npc_dialogue:enterSingleDungeon(sender, id)
	if g_i3k_game_context:GetPartnerBindTime() == 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_HuoBanCopy)
		g_i3k_ui_mgr:RefreshUI(eUIID_HuoBanCopy, id)
	else
		if g_i3k_game_context:IsInRoom() or g_i3k_game_context:getMatchState() ~= 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(142))
			return
		end
		local cfg = i3k_db_NpcDungeon[id]
		local roleLvl = g_i3k_game_context:GetLevel()
		if roleLvl < cfg.openLevel or (cfg.maxLvl and roleLvl > cfg.maxLvl) then
		 	return g_i3k_ui_mgr:PopupTipMessage("等级不符合要求")
		end

		local nd = i3k_db_NpcDungeon[id]
		local isInDate = g_i3k_checkIsInDate(nd.openDate, nd.closeDate)
		local is_open = i3k_get_activity_is_open(nd.openDay)
		local nowTime = i3k_game_get_time()%86400
		local isNow = nowTime >= nd.startTime and nowTime <= nd.finishTime
		if not isInDate or not is_open or not isNow then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15417))
		end

		local function func()
			i3k_sbean.single_npc_map_start(id)
		end
		g_i3k_game_context:CheckMulHorse(func)
	end
	self:onCloseUI()
end

function wnd_npc_dialogue:prayWords()
	local roleLvl = g_i3k_game_context:GetLevel()
	local needLvl = i3k_db_word_exchange_cfg.open_need_lvl
	if roleLvl >= needLvl then
		i3k_sbean.pray_words_req()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15572))
	end
	self:onCloseUI()
end

function wnd_npc_dialogue:openExchangeWordsUI()
	local roleLvl = g_i3k_game_context:GetLevel()
	local needLvl = i3k_db_word_exchange_cfg.open_need_lvl
	if roleLvl >= needLvl then
		i3k_sbean.open_exchange_words_req()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15572))
	end
	self:onCloseUI()
end

function wnd_npc_dialogue:openRaiseFlagUI()
	local roleLvl = g_i3k_game_context:GetLevel()
	local needLvl = i3k_db_national_activity_cfg.open_need_lvl
	if roleLvl >= needLvl then
		local isDownFlag = false
		local isUpFlag = true
		i3k_sbean.sync_national_activity(isDownFlag, isUpFlag)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15572))
	end
	self:onCloseUI()
end

-- 进入帮派驻地
function wnd_npc_dialogue:onSectZoneEnter(sender)
	local cfg = i3k_db_faction_dragon
	local isOpenDay = i3k_get_is_in_open_day(cfg.dragonCfg.openDay)
	if not isOpenDay or not i3k_get_is_in_open_time(cfg.treasureOpenTime) then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15417))
	end
	if g_i3k_game_context:GetFactionSectId() == 0 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16765))
	end
	i3k_sbean.sect_zone_list()
end

function wnd_npc_dialogue:onLeaveMapCopy(sender)
	local func = function ()
		i3k_sbean.mapcopy_leave()
	end
	g_i3k_game_context:CheckMulHorse(func)
end

function wnd_npc_dialogue:onSectZoneDonateRank(sender)
	if not g_i3k_game_context:GetIsOwnFactionZone() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16627))
	end
	i3k_sbean.sect_zone_build_rank()
end

function wnd_npc_dialogue:onSectZoneBoss(sender)
	if not g_i3k_game_context:GetIsOwnFactionZone() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16627))
	end
	i3k_sbean.request_sect_zone_sync_boss_req()
end

function wnd_npc_dialogue:onOpenBidUI(sender)
	g_i3k_logic:OpenBidUI()
end

function wnd_npc_dialogue:onOpenBreakSealUI(sender, npcId)
	local date = os.date("%Y-%m-%d", i3k_db_server_limit.breakSealCfg.openDay)
	local hour = math.modf(i3k_db_server_limit.breakSealCfg.openTime/3600)
	if not g_i3k_db.g_i3k_db.i3k_db_check_breakSeal_date() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16898, date))
	elseif not g_i3k_db.i3k_db_check_breakSeal_time() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17292, hour .. ":00"))
	elseif g_i3k_game_context:GetLevel() < i3k_db_server_limit.breakSealCfg.limitLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16883, i3k_db_server_limit.breakSealCfg.limitLevel))
	else
	    i3k_sbean.breakSeal_start(npcId)
	end
end

function wnd_npc_dialogue:openWishUI()
	local roleLvl = g_i3k_game_context:GetLevel()
	local needLvl = i3k_db_christmas_wish_cfg.open_need_lvl
	if roleLvl >= needLvl then
		i3k_sbean.christmas_cards_sync()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16939, needLvl))
	end
	self:onCloseUI()
end

function wnd_npc_dialogue:openWishListUI()
	local roleLvl = g_i3k_game_context:GetLevel()
	local needLvl = i3k_db_christmas_wish_cfg.open_need_lvl
	if roleLvl >= needLvl then
		i3k_sbean.christmas_cards_get_list()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16939, needLvl))
	end
	self:onCloseUI()
end

function wnd_npc_dialogue:onEquipTrans(sender, groupId)
	if g_i3k_game_context:GetLevel() < i3k_db_common.functionOpen.equipTransLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1250, i3k_db_common.functionOpen.equipTransLvl))
	elseif g_i3k_game_context:GetBagIsFull() then
		g_i3k_ui_mgr:PopupTipMessage("背包已满，请先清理背包")
	else
		g_i3k_ui_mgr:OpenUI(eUIID_EquipTransform)
		g_i3k_ui_mgr:RefreshUI(eUIID_EquipTransform, groupId)
	end
	self:onCloseUI()
end

function wnd_npc_dialogue:onAcceptChessTask(sender)
	local chess = g_i3k_game_context:getChessTask()
	if g_i3k_game_context:GetLevel() < i3k_db_chess_board_cfg.needLvl then
		g_i3k_ui_mgr:PopupTipMessage("等级不足")
	elseif not g_i3k_db.i3k_db_is_in_chess_task_time() then
		g_i3k_ui_mgr:PopupTipMessage("不在开启时间内")
	elseif not (chess and chess.loopLvl == 1 and chess.curTaskID == 0) then
		g_i3k_ui_mgr:PopupTipMessage("不可重复接取")
	else
		g_i3k_ui_mgr:OpenUI(eUIID_ChessTaskAccept)
		g_i3k_ui_mgr:RefreshUI(eUIID_ChessTaskAccept)
	end
	self:onCloseUI()
end

function wnd_npc_dialogue:onOpenChessDescription(sender)
	if g_i3k_game_context:GetLevel() < i3k_db_chess_board_cfg.needLvl then
		g_i3k_ui_mgr:PopupTipMessage("等级不足")
	else
		i3k_sbean.chess_game_rank_get()
	end
	self:onCloseUI()
end

function wnd_npc_dialogue:refresh(npcId,count, instanceID)
	self:updateData(npcId,count, instanceID)
end

function wnd_npc_dialogue:changePrf()
	if g_i3k_game_context:GetTransformLvl() < i3k_db_common.changeProfession.transformLvl then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1047, i3k_db_common.changeProfession.transformLvl))
	end

	local fightTeamInfo = g_i3k_game_context:getFightTeamInfo()
	if fightTeamInfo and fightTeamInfo.id ~= 0 and g_i3k_game_context:getFightTeamEndTime() >= i3k_game_get_time()  then
		return g_i3k_ui_mgr:PopupTipMessage("您是武道会战队成员，无法进行职业变更")
	end
	if not g_i3k_game_context:isCanTransform() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18531))
	end
	g_i3k_ui_mgr:OpenUI(eUIID_TransferPreview)
	g_i3k_ui_mgr:RefreshUI(eUIID_TransferPreview,true)
end

function wnd_npc_dialogue:getNewYearRed(sender, npcId)
	for i,v in ipairs(g_i3k_game_context:getNewYearRedGetNpcid()) do
		if npcId == v then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17474))
		end
	end
	g_i3k_ui_mgr:OpenUI(eUIID_NewYearRedEnvelope)
	g_i3k_ui_mgr:RefreshUI(eUIID_NewYearRedEnvelope,npcId)
	self:onCloseUI()
end

function wnd_npc_dialogue:onOpenFamilyDonate()
	local playerlevel = g_i3k_game_context:GetLevel()
	local familylevel = g_i3k_game_context:getSectFactionLevel()
	local needPlayerLevel = i3k_db_basicdonateInfo.openPlayerLevel
	local needFamilyLevel = i3k_db_basicdonateInfo.openFamilyLevel

	if playerlevel < needPlayerLevel or familylevel < needFamilyLevel then
		g_i3k_ui_mgr:PopupTipMessage(string.format("帮派等级达到%d级且个人等级达到%d级开启帮派互助", needFamilyLevel, needPlayerLevel))
		return
	end

	g_i3k_logic:OpenFamilyDonateUI()
end

function wnd_npc_dialogue:onDefenceWarTrans(sender, npcID)
	g_i3k_logic:OpenDefenceWarTrans(npcID)
end

function wnd_npc_dialogue:onDefenceWarBuyCar(sender)
	i3k_sbean.city_war_Buy_Car()
end

function wnd_npc_dialogue:onHomeLandProduce(sender)
	if g_i3k_game_context:GetLevel() < i3k_db_home_land_base.produceCfg.needLvl then
		g_i3k_ui_mgr:PopupTipMessage("等级不足")
	else
		g_i3k_ui_mgr:OpenUI(eUIID_HomeLandProduce)
		g_i3k_ui_mgr:RefreshUI(eUIID_HomeLandProduce)
		self:onCloseUI()
	end
end

function wnd_npc_dialogue:homeLandRelease()
	local cur_level = g_i3k_game_context:GetLevel()
	local need_level = i3k_db_common.homelandReleaseInfo.openlevle

	if cur_level >= need_level then
		g_i3k_logic:OpenHomeLandReleaseUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17391, need_level))
	end

end

function wnd_npc_dialogue:homeLandReleaseRank()
	local cur_level = g_i3k_game_context:GetLevel()
	local need_level = i3k_db_rank_list[g_RANKLIST_HOMELAND_RELEASE].level

	if cur_level >= need_level then
		g_i3k_logic:OpenHomelandReleaseRankListUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17392, need_level))
	end
end

function wnd_npc_dialogue:onDefenceWarRepairTower(sender, guiID)
	local instanceID = not guiID and 0 or -guiID
	i3k_sbean.defenceWarRepairTower(instanceID)
end

function wnd_npc_dialogue:homeLandEnterHouse(sender)
	local data = g_i3k_game_context:getHomelandMapData()
	if (data.houseLevel or 0) > 0 then
		local func = function ()
			i3k_sbean.house_enter()
		end
		g_i3k_game_context:CheckMulHorse(func)
		self:onCloseUI()
	else
		if g_i3k_game_context:isInMyHomeLand() then
			local callback = function (isOk)
				if isOk then
					g_i3k_logic:OpenHomeLandHouseUI()
				end
			end
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(5340), callback)
		else
			g_i3k_ui_mgr:PopupTipMessage("房屋未解锁")
		end
	end
end

function wnd_npc_dialogue:enterHomeLand(sender)
	local houseData = g_i3k_game_context:getHomeLandHouseInfo()
	local func = function ()
		i3k_sbean.homeland_enter(houseData.roleId)
	end
	g_i3k_game_context:CheckMulHorse(func)
end

function wnd_npc_dialogue:onPassExamGift(sender)
	local lvl = g_i3k_game_context:GetLevel()
	local needLvl = i3k_db_pass_exam_gift_cfg.needLvl
	if lvl < needLvl then
		return g_i3k_ui_mgr:PopupTipMessage(string.format("达到%s级可参加此活动", needLvl))
	end

	local curTime = g_i3k_get_GMTtime(i3k_game_get_time())
	if curTime < i3k_db_pass_exam_gift_cfg.startTime or curTime > i3k_db_pass_exam_gift_cfg.endTime then
		return g_i3k_ui_mgr:PopupTipMessage("当前不在活动时间")
	end
	i3k_sbean.admission_sync_info(true)
	self:onCloseUI()
end

function wnd_npc_dialogue:onPetDungeon(sender, npcID)
	if g_i3k_game_context:isCompleteAllPetDungeonTasks() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1507, i3k_db_PetDungeonBase.taskCount))
		return
	end
	
	local taskID = g_i3k_db.i3k_db_get_TaskID_By_NpcID(npcID)
	local info = g_i3k_game_context:getPetDungeonInfo()
	
	local state = g_i3k_game_context:petDungeonIsFinish(taskID) and 3 or 0  -- 可接取0，接取1，完成2 提交3，
	
	if state == 0 then
		state = g_i3k_game_context:getPetDungeonTaskState(taskID)
	end
	
	local checkTab =
	{
		[1] = i3k_get_string(1515),--"i3k_get_string(17266),
		[2] = i3k_get_string(1516), 
		[3] = i3k_get_string(1517),
	}
	
	if checkTab[state] then
		g_i3k_ui_mgr:PopupTipMessage(checkTab[state])
		return
	end

	g_i3k_ui_mgr:OpenUI(eUIID_PetDungeonReceiveTask)
	g_i3k_ui_mgr:RefreshUI(eUIID_PetDungeonReceiveTask, npcID)
	self:onCloseUI()
end

function wnd_npc_dialogue:onSwornFriends(sender)
	if g_i3k_game_context:GetLevel() < i3k_db_sworn_system.openLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5378, i3k_db_sworn_system.openLvl))
		return
	end
	local teamMember = g_i3k_game_context:GetAllTeamMembers()
	if next(teamMember) then
		if g_i3k_game_context:getSwornFriends() then
			if g_i3k_game_context:IamTeamLeader() then
				i3k_sbean.sworn_add_role()
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5427))
			end
		else
			if g_i3k_game_context:IamTeamLeader() then
				i3k_sbean.create_sworn_start()
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5425))
			end
		end
		self:onCloseUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5413))
	end
end
function wnd_npc_dialogue:onRefreshRanks(sender)
	if not g_i3k_game_context:getSwornFriends() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5424))
		return
	end
	local callback = function(data, roleData)
		g_i3k_ui_mgr:OpenUI(eUIID_SwornDate)
		g_i3k_ui_mgr:RefreshUI(eUIID_SwornDate, 0, data)
		self:onCloseUI()
	end
	i3k_sbean.sworn_sync(callback)
end
function wnd_npc_dialogue:onBreakSworn(sender)
	if g_i3k_game_context:getSwornFriends() then
		local callback = function(isOk)
			if isOk then
				i3k_sbean.sworn_leave()
				self:onCloseUI()
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(5406), callback)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5424))
	end
end
function wnd_npc_dialogue:onKickSwornFriends(sender)
	if not g_i3k_game_context:getSwornFriends() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5424))
		return
	end
	local teamMember = g_i3k_game_context:GetAllTeamMembers()
	if next(teamMember) then
		if g_i3k_game_context:IamTeamLeader() then
			local callback = function(data, roleData)
				if table.nums(data.roles) <= 2 then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5383))
				else
					g_i3k_ui_mgr:OpenUI(eUIID_SwornKick)
					g_i3k_ui_mgr:RefreshUI(eUIID_SwornKick, data)
				end
			end
			i3k_sbean.sworn_sync(callback)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5435))
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5398))
	end
end
function wnd_npc_dialogue:onSwornRule(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(5441, i3k_db_sworn_system.openLvl))
end

function wnd_npc_dialogue:onFestivalTask(sender, id)
	g_i3k_ui_mgr:OpenUI(eUIID_FestivalLimitTask)
	g_i3k_ui_mgr:RefreshUI(eUIID_FestivalLimitTask, id)
	self:onCloseUI()
end

function wnd_npc_dialogue:onLingQianTask(sender, info)
	local cfg = i3k_db_ling_qian[info.prayID]
	if g_i3k_game_context:GetLevel() < cfg.levelLimit then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5460, cfg.levelLimit))
	else
		g_i3k_ui_mgr:OpenUI(eUIID_LingQianQiFuDialog)
		g_i3k_ui_mgr:RefreshUI(eUIID_LingQianQiFuDialog, info)
		self:onCloseUI()
	end
end

function wnd_npc_dialogue:openShakeTree(sender, actID)
	local cfg = i3k_db_shake_tree[actID]
	local lvl = g_i3k_game_context:GetLevel()
	local openLvl = cfg.openLvl
	if lvl < openLvl then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1602, cfg.actName, openLvl))
	end
	if not g_i3k_checkIsInDateByTimeStampTime(cfg.startTime, cfg.endTime) then
		return g_i3k_ui_mgr:PopupTipMessage("当前不在活动时间")
	end
	if g_i3k_game_context:GetScheduleInfo().activity < cfg.needActivePoint then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17804, cfg.needActivePoint))
	end
	i3k_sbean.money_tree_open(actID)
	self:onCloseUI()
end

function wnd_npc_dialogue:onRoleFlying(sender, npcData)
	local flying = i3k_db_role_flying[npcData.exchangeId[1]]
	if g_i3k_game_context:GetLevel() < flying.openLvl or g_i3k_game_context:GetTransformLvl() < flying.needTransLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1685, flying.openLvl, flying.needTransLvl))
	else
		local flyingData = g_i3k_game_context:getRoleFlyingData()
		if flyingData and flyingData[1] then
			local onMission = false
			for k, v in pairs(flyingData) do
				if v.isOpen ~= 1 then
				g_i3k_ui_mgr:OpenUI(eUIID_RoleFlying)
					g_i3k_ui_mgr:RefreshUI(eUIID_RoleFlying, k)
					onMission = true
					self:onCloseUI()
					break
				end
			end
			if not onMission then
				g_i3k_logic:OpenMainUI(function()
					g_i3k_ui_mgr:OpenUI(eUIID_FeiSheng)
					g_i3k_ui_mgr:RefreshUI(eUIID_FeiSheng)
				end)
			end
		else
			i3k_sbean.soaring_task_open(npcData.exchangeId[1])
			self:onCloseUI()
		end
	end
end
function wnd_npc_dialogue:onGemExchangeBt(sender)
	g_i3k_logic:OpenGemExchangeUI()
	self:onCloseUI()
end
function wnd_npc_dialogue:onCityWarExpBt(sender)
	local callback = function()
		g_i3k_logic:OpenCityWarExpUI()
		g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
	end
	i3k_sbean.defenceWarInfo(callback)
end

function wnd_npc_dialogue:onKnightlyDetective(sender)
	g_i3k_logic:OpenKnightlyDetectiveUI()
	self:onCloseUI()
end
function wnd_npc_dialogue:onCatchSpirit(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_LearnCatchSpiritSkills)
	g_i3k_ui_mgr:RefreshUI(eUIID_LearnCatchSpiritSkills, self._npcID)
	self:onCloseUI()
end
function wnd_npc_dialogue:onSpyStory(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
	g_i3k_logic:OpenSpyStoryUI()
end

function wnd_npc_dialogue:onOutCareerPractice(sender, careerId)
	local cfg = i3k_db_wzClassLand[careerId]
	if g_i3k_game_context:GetLevel() < cfg.needRoleLevel or g_i3k_game_context:GetTransformLvl() < cfg.needChangeLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18504, cfg.needRoleLevel, cfg.needChangeLevel))
	else
		g_i3k_ui_mgr:OpenUI(eUIID_OutCareerPractice)
		g_i3k_ui_mgr:RefreshUI(eUIID_OutCareerPractice, careerId)
		self:onCloseUI()
	end
end


function wnd_npc_dialogue:onSpringRollMain(sender, npcID)
	local lvl = g_i3k_game_context:GetLevel()
	if lvl < i3k_db_spring_roll.baseConfig.openLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19045, i3k_db_spring_roll.baseConfig.openLevel))
		return
	end
	if g_i3k_game_context:checkSpringRollOpen() then
		i3k_sbean.spring_lantern_sync(OPEN_SPRING_ROLL_MAIN, npcID)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19046))
	end
end

function wnd_npc_dialogue:onSpringRollBattle(sender, npcID)
	local lvl = g_i3k_game_context:GetLevel()
	if lvl < i3k_db_spring_roll.baseConfig.openLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19045, i3k_db_spring_roll.baseConfig.openLevel))
		return
	end
	i3k_sbean.spring_lantern_sync(OPEN_SPRING_ROLL_BATTLE, npcID)
end

function wnd_npc_dialogue:onSpringRollQuiz(sender, npcID)
	local lvl = g_i3k_game_context:GetLevel()
	if lvl < i3k_db_spring_roll.baseConfig.openLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19045, i3k_db_spring_roll.baseConfig.openLevel))
		return
	end
	i3k_sbean.spring_lantern_sync(OPEN_SPRING_ROLL_QUIZ, npcID)
end

function wnd_npc_dialogue:onSpringRollBuy(sender, npcID)
	local lvl = g_i3k_game_context:GetLevel()
	if lvl < i3k_db_spring_roll.baseConfig.openLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19045, i3k_db_spring_roll.baseConfig.openLevel))
		return
	end
	i3k_sbean.spring_lantern_sync(OPEN_SPRING_ROLL_BUY, npcID)
end

function wnd_npc_dialogue:onNewFestivalAccept(sender)
	if not g_i3k_db.i3k_db_is_in_new_festival_task() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19078))
		return
	end
	local npcID = self._npcID
	local levelReq = i3k_db_new_festival_info.openLevel
	local roleLevel = g_i3k_game_context:GetLevel()
	
	if levelReq > roleLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18996,levelReq))
		return
	end

	
	local info = g_i3k_game_context:getNewFestival_task(npcID)
	if info then 
		local state = info.state  -- 接取1， 0未接取，2完成，3领过奖了
		local checkTab =
		{
			[1] = i3k_get_string(18997), --"已经接取了任务，请到任务栏查看任务",
			[2] = i3k_get_string(18995), --"已经完成任务，请点击左侧任务列表领取奖励",
			[3] = i3k_get_string(19028), --"已经领取了奖励，明日任务刷新再来接取任务",
		}
		if checkTab[state] then
			g_i3k_ui_mgr:PopupTipMessage(checkTab[state])
			return
		end
		g_i3k_ui_mgr:OpenUI(eUIID_FestivalTaskAccept)
		g_i3k_ui_mgr:RefreshUI(eUIID_FestivalTaskAccept, npcID)
	else
		i3k_sbean.new_festival_time_limi_task_take(npcID)
	end
	self:onCloseUI()

end

function wnd_npc_dialogue:onNewFestivalCommit(sender)
	if not g_i3k_db.i3k_db_is_in_new_festival_task() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19078))
		return
	end

	local levelReq = i3k_db_new_festival_info.openLevel
	local roleLevel = g_i3k_game_context:GetLevel()
	if levelReq > roleLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18996,levelReq))
		return
	end

	i3k_sbean.new_festival_activity_sync_req(true)
	
	self:onCloseUI()
end

function wnd_create(layout, ...)
	local wnd = wnd_npc_dialogue.new()
	wnd:create(layout, ...)
	return wnd
end
