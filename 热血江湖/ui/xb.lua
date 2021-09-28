-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_x_func = i3k_class("wnd_x_func", ui.wnd_base)

local LAYER_ZJMT2 = "ui/widgets/zjm2t"

function wnd_x_func:ctor()
	--self.scroll = {}
	self.isShowSheJiao = false
end

function wnd_x_func:configure()
	local widgets = self._layout.vars
	--self.scroll[1] = widgets.scroll2
	--self.scroll[2] = widgets.scroll3

	--self.checkin = self._layout.vars.sign_btn
	--self.dailyActivity = self._layout.vars.daily_activity --转盘暂留
	--self.auction = self._layout.vars.auction
	--self.email = self._layout.vars.email
	--self.task = self._layout.vars.task_btn
	--self.task:onClick(self,self.onTask)

	widgets.auction_btn:onClick(self, self.toAuction)
	--self.dailyActivity:onClick(self,self.onDailyActivity)
	self.role_point = widgets.role_point
	self.skill_point = widgets.skill_point
	self.weapon_point = widgets.weapon_point
	self.pet_point = widgets.pet_point
	self.streng_point = widgets.streng_point
	--self.clan_point = widgets.clan_point
	self.steed_point = widgets.steed_point
	self.empowerment_point = widgets.empowerment_point
	self.hideWeapon_red = widgets.hideWeapon_red
	self.feishengRed = widgets.feishengRed
	widgets.streng_btn:onClick(self, self.onStrengEquip)
	widgets.xinfa_btn:onClick(self, self.onXinFa)
	widgets.set_btn:onClick(self, self.onSet)
	widgets.shenBing_btn:onClick(self, self.onShenBing)
	widgets.toBangpai:onClick(self, self.toBangpaiCB)
	widgets.pet_btn:onClick(self, self.onSuiCong)
	widgets.my_firends_btn:onClick(self, self.onMyFirends)
	widgets.toSteed:onClick(self, self.toSteedSystem)
	widgets.ranklist_btn:onClick(self, self.onRankList)
	widgets.empowerment_btn:onClick(self, self.onEmpowerment)
	widgets.production_btn:onClick(self, self.onProduction)
	widgets.role_btn:onClick(self, self.onRole)
	self.faction_red = self._layout.vars.faction_red
	self.faction_red:hide()
	widgets.under_wearBtn:onClick(self, self.onUnderWear) --内甲
	widgets.under_wearBtn:hide()
	widgets.yinyuanBtn:onClick(self, self.onMarriageUI) --姻缘
	widgets.offlineBtn:onClick(self, self.onOffline)	-- 离线经验
	widgets.shejiaoBtn:onClick(self, self.onSheJiaoBtn) -- 师徒改为社交
	widgets.shituBtn:onClick(self, self.onMasterBtn)	--师徒
	widgets.jiebaiBtn:onClick(self, self.onSwornBtn)
	widgets.feisheng:onClick(self, self.onFeishengBtn)		--飞升
	widgets.arrayStone:onClick(self, self.onArrayStone) -- 阵法石
	widgets.martialSoulBtn:onClick(self, self.onMartialSoulBtn) --武魂
	widgets.baguaBtn:onClick(self,function()
		if g_i3k_game_context:GetLevel() < i3k_db_bagua_cfg.openLvl then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17123,i3k_db_bagua_cfg.openLvl))
			return
		end
		i3k_sbean.request_eightdiagram_sync_req()
	end)
	widgets.homeLandBtn:onClick(self, self.onHomeLand)
	widgets.hideWeaponBtn:onClick(self, self.onHideWeapon)
	widgets.huobanBtn:onClick(self, self.onHuoban)
	widgets.petEquipBtn:onClick(self, self.onPetEquip)

	self.martialSoulPoint = widgets.martialSoulPoint
	self.offlineRed = widgets.offlineRed
	self.friend_red = widgets.friend_red
	self.yinyuanRed = widgets.yinyuanRed
	self.friend_red2 = widgets.friend_red2
	self.petEquipPoint = widgets.petEquipPoint
	self.shejiao = widgets.shejiao
	self.shituBtn = widgets.shituBtn
	self.jiebaiBtn = widgets.jiebaiBtn
end

function wnd_x_func:updateFactionRed(state)
	self.faction_red:setVisible(state)
end

function wnd_x_func:onPetEquip(sender)
	local isFirst = true
	g_i3k_logic:OpenPetEquipUI(nil, isFirst)
end

function wnd_x_func:onHuoban(sender)
	local cfg = i3k_db_partner_base.cfg
	local serverOpenTime =  g_i3k_get_GMTtime(i3k_game_get_server_open_time())
	local serverOpenDay = i3k_game_get_server_opened_days()
	if serverOpenTime > cfg.openServerTime and serverOpenDay <= cfg.needDays then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5488, cfg.needDays))
	end
	g_i3k_logic:OpenPartnerUI()
end

function wnd_x_func:onMasterBtn(sender)
	if g_i3k_game_context:GetLevel() < i3k_db_master_cfg.cfg.open_level then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15437, i3k_db_master_cfg.cfg.open_level))
		return
	end
	i3k_sbean.master_req_baseinfo("MAIN_UI")
end
function wnd_x_func:onSwornBtn(sender)--结拜入口
	g_i3k_logic:OpenSwornUI()
end
function wnd_x_func:onFeishengBtn()
	local fs = g_i3k_game_context:getFeishengInfo()
	if fs._isFeisheng then
		g_i3k_ui_mgr:OpenAndRefresh(eUIID_FeiSheng)
	end
end
function wnd_x_func:onSheJiaoBtn(sender)
	self.isShowSheJiao = not self.isShowSheJiao
	self.shejiao:setVisible(self.isShowSheJiao)
end

function wnd_x_func:onMartialSoulBtn(sender)
	g_i3k_logic:OpenMartialSoulUI()
end

function wnd_x_func:onHomeLand(sender)
	local tips = g_i3k_game_context:GetIsInFactionZone() and i3k_get_string(16613) or g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		return g_i3k_ui_mgr:PopupTipMessage(tips)
	end
	if g_i3k_game_context:GetHomeLandLevel() ~= 0 then
		i3k_sbean.homeland_sync(1)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_CreateHomeLandTips)
	end
end

function wnd_x_func:updateMartialSoulRed()
	local isWeaponSoulCanUp = g_i3k_game_context:IsWeaponSoulCanUp()
	local isShenDouRed = g_i3k_db.i3k_db_get_shen_dou_red()
	self.martialSoulPoint:setVisible(isWeaponSoulCanUp or isShenDouRed)
end

function wnd_x_func:onMarriageUI(sender)
	--未婚是显示尚未结婚界面
	--g_i3k_ui_mgr:PopupTipMessage("暂未开放")
	--g_i3k_game_context:selectEnderModel()--先判断是否超过婚礼进行时 超过直接进入夫妻姻缘界面
	local step = g_i3k_game_context:getRecordSteps() --1 ，结婚状态时间
	g_i3k_game_context:setEnterProNum(2)
	if step == -1 then
		g_i3k_logic:OpenUnmarried()
	else
		g_i3k_logic:OpenMarried_Yinyuan()
	end
end

function wnd_x_func:onRole(sender)
	g_i3k_logic:OpenRoleLyUI()
end

function wnd_x_func:onStrengEquip(sender)
	if g_i3k_game_context:isCanOpenEquipStreng() then
		g_i3k_logic:OpenStrengEquipUI()
	end
end

function wnd_x_func:onXinFa(sender)
	g_i3k_logic:OpenSkillLyUI()
end
--jxw 模拟内甲UI入口  --50级进入
function wnd_x_func:onUnderWear(sender)
	g_i3k_logic:enterUnderWearUI()
end

function wnd_x_func:onSet(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SetBlood)
end

function wnd_x_func:onMyFirends(sender)
	i3k_sbean.master_req_baseinfo("MAIN_UI", function()
		g_i3k_logic:OpenMyFriendsUI()
	end)
end

function wnd_x_func:onShenBing(sender)
	g_i3k_logic:OpenShenBingUI()
	i3k_sbean.shen_bing_open_syncUniqueSkillSp()
end

function wnd_x_func:onHideWeapon(sender)
	g_i3k_logic:OpenHideWeaponUI()
end

function wnd_x_func:onSuiCong(sender)
	g_i3k_logic:OpenPetUI()
end

function wnd_x_func:toBangpaiCB(sender)
	local data = i3k_sbean.sect_sync_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.sect_sync_res.getName())
end

function wnd_x_func:toSteedSystem(sender)
	g_i3k_logic:OpenSteedUI()
end

function wnd_x_func:onRankList(sender)
	local cur_level = g_i3k_game_context:GetLevel()
	if cur_level >= i3k_db_rank_list[1].level then
		g_i3k_logic:OpenRankListUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(482,i3k_db_rank_list[1].level))
	end

end

function wnd_x_func:onEmpowerment(sender)
	i3k_sbean.goto_expcoin_sync()
end

function wnd_x_func:onProduction()

	g_i3k_logic:OpenFactionProduction()
end

--[[馈赠
function wnd_x_func:onDailyActivity(sender)
	local cur_level = g_i3k_game_context:GetLevel()
	if cur_level >= i3k_db_lucky_wheel.needLvl then
		g_i3k_logic:OpenDailyActivityUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(358,i3k_db_lucky_wheel.needLvl))
	end

end]]

function wnd_x_func:toAuction(sender)
	local openDay = i3k_game_get_server_open_day()
	local nowDay = g_i3k_get_day(i3k_game_get_time())
	local needLevel = i3k_db_common.aboutAuction.needLevel
	local hero = i3k_game_get_player_hero()
	if hero._lvl<needLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(242, needLevel))
	--elseif nowDay-openDay<i3k_db_common.aboutAuction.coolDay then
		--local str = string.format("%s", "服务器开服3天内不允许进入寄售行")
		--g_i3k_ui_mgr:PopupTipMessage(str)
	else
		local callback = function (itemType)
			g_i3k_ui_mgr:RefreshUI(eUIID_Auction, itemType)
		end
		i3k_sbean.sync_auction(1, "", 1, 2, 0, 0, 0, callback)
	end
end

function wnd_x_func:updateRoleNotice()
	self.role_point:setVisible(g_i3k_game_context:checkXinjueRedpoint())
end

function wnd_x_func:updateStrengNotice()
	self.streng_point:setVisible(g_i3k_game_context:canBetterEquip())
end

function wnd_x_func:updateSkillNotice()
	self.skill_point:setVisible(g_i3k_game_context:canBetterSkillOrSpirit())
end

function wnd_x_func:updateWeaponNotice()
	self.weapon_point:setVisible(g_i3k_game_context:canBetterWeapon())
end

function wnd_x_func:updatePetNotice()
	self.pet_point:setVisible(g_i3k_game_context:canBetterPet())
end

function wnd_x_func:updateSteedNotice()
	self.steed_point:setVisible(g_i3k_game_context:canBetterSteed() or g_i3k_game_context:canAddBook() or g_i3k_game_context:getIsShowSteedFightRed())
	--return g_i3k_game_context:canBetterSteed()
end

function wnd_x_func:updateEmpowermentNotice()
	self.empowerment_point:setVisible(g_i3k_game_context:redPointForAllCheats() or g_i3k_game_context:redPointForBooks() or g_i3k_game_context:qiankunRedPoints() or g_i3k_game_context:isShowCunWnRed())
	--return g_i3k_game_context:redPointForAllCheats() or g_i3k_game_context:redPointForBooks()
end

-- 师徒入口红点
function wnd_x_func:updateMasterNotice()
	self._layout.vars.masterRedPoint2:setVisible(g_i3k_game_context:getMasterRedPoint())
end
-- 结拜入口红点
function wnd_x_func:updateSwornReddot()
	local sworn = g_i3k_game_context
	local red = false
	if sworn then
		red = sworn.push
	end
	self._layout.vars.friend_red3:setVisible(red)
	return red
end

--社交目前只有师徒和结拜
function wnd_x_func:updateSocialRedPoint()
	self._layout.vars.masterRedPoint:setVisible(g_i3k_game_context:getMasterRedPoint() or
		self:updateSwornReddot())
end

local btnTab = {
	empowerment_btn 	= i3k_db_experience_args.args.hideLvl,
	ranklist_btn 		= 0, -- i3k_db_common.functionOpen.rankLiskOpenLvl,
	-- auction_btn 		= i3k_db_common.functionOpen.auctionOpenLvl, -- 寄售行图标改为总显示
	under_wearBtn 		= i3k_db_under_wear_alone.underWearShowLvl,
	offlineBtn 			= 0, -- i3k_db_offline_exp.fairyOpenLvl,
	shejiaoBtn			= 0, -- i3k_db_master_cfg.cfg.icon_show_level, -- 师徒改为总是显示
	martialSoulBtn		= i3k_db_martial_soul_cfg.showLvl,
	baguaBtn			= i3k_db_bagua_cfg.showLvl,
	hideWeaponBtn		= i3k_db_anqi_common.showLevel,
	homeLandBtn			= 20, -- i3k_db_home_land_base.baseCfg.openLvl,
	huobanBtn           = 20, -- i3k_db_huoban_base.openLvl
	petEquipBtn         = i3k_db_pet_equips_cfg.showLvl,
}

function wnd_x_func:updateIsShowBtn()
	for k,v in pairs(btnTab) do
		self._layout.vars[tostring(k)]:show()
		if g_i3k_game_context:GetLevel() < v then
			self._layout.vars[tostring(k)]:hide()
		end
	end
end

function wnd_x_func:refresh()
	self:updateRoleNotice()
	self:updateIsShowBtn()
	self:updateStrengNotice()
	self:updateSkillNotice()
	self:updateWeaponNotice()
	self:updatePetNotice()
	self:updateSteedNotice()
	self:updateEmpowermentNotice()
	self:updateFactionRed(g_i3k_game_context:getApplyMsg() or g_i3k_game_context:getFighGroupApplysStatus())
	self:updateOfflineRed()
	self:updateFriendRed()
	self:updateMasterNotice()
	self:updateYinyuanRed()
	self:updateMartialSoulRed()
	self:updateHideWeaponNotice()
	self:updateHuobanNotice()
	self:updatePetEquipNotice()
	self:updateSocialRedPoint()
	self:updateFeishengReddot()
	self:updateFlyingRedPoint()
	self:updateArrayStoneEntry()
	self:updateArrayStoneRed()
	--self:updateScroll()
end
function wnd_x_func:updateFeishengReddot()
	local fs = g_i3k_game_context:getFeishengInfo()
	self._layout.vars.feisheng:setVisible(fs._isFeisheng)
end

function wnd_x_func:updatePetEquipNotice()
	local isShowRed = g_i3k_game_context:TestPetEquipRedPoint()
	self.petEquipPoint:setVisible(isShowRed)
end

function wnd_x_func:updateHuobanNotice()
	local isShowGiftRed =  g_i3k_game_context:TestHuobanRedPoint()
	self.friend_red2:setVisible(isShowGiftRed)
end


function wnd_x_func:onOffline(sender)
	g_i3k_logic:OpenOfflineExpUI()
end

function wnd_x_func:updateOfflineRed()
	local info = g_i3k_game_context:GetOfflineExpData();
	local isShowGiftRed = g_i3k_game_context:testNotice(g_NOTICE_TYPE_CAN_REWARD_WIZARD_GIFT);
	local pushMinTime = i3k_db_offline_exp.pushMinTime
	local isShowRed = isShowGiftRed or info.accTimeTotal ~= 0;
	self.offlineRed:setVisible(isShowRed)
end

function wnd_x_func:updateFriendRed()
	self.friend_red:setVisible(g_i3k_game_context:IsUpdateLuckStart() or g_i3k_game_context:GetCrossFriendRed())
end

function wnd_x_func:updateYinyuanRed()
	self.yinyuanRed:setVisible(g_i3k_game_context:marryTitleRed() or g_i3k_game_context:checkRoleFestivalGIftsRedPoint() or g_i3k_game_context:GetNoticeState(g_NOTICE_TYPE_MARRY_ACHIEVEMENT))
end

function wnd_x_func:updateHideWeaponNotice()
	self.hideWeapon_red:setVisible(g_i3k_game_context:CanHaveHideWeaponBetter())
end
function wnd_x_func:updateFlyingRedPoint()
	local flyingLevel = g_i3k_game_context:getFlyingLevel()
	local level_limit = 6
	if flyingLevel < level_limit then
		self.feishengRed:setVisible(false)
		return
	end
	local canSharpen = g_i3k_game_context:isFlyingSharpenHaveRedPoint()
	local canTrans = g_i3k_game_context:isFlyingTransHaveRedPoint()
	self.feishengRed:setVisible(canSharpen or canTrans)
end
function wnd_x_func:updateArrayStoneEntry()
	self._layout.vars.arrayStone:setVisible(g_i3k_game_context:GetLevel() >= i3k_db_array_stone_common.showLvl)
end
function wnd_x_func:onArrayStone(sender)
	if g_i3k_game_context:GetLevel() >= i3k_db_array_stone_common.openLvl then
		g_i3k_ui_mgr:OpenUI(eUIID_ArrayStone)
		g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStone)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18400, i3k_db_array_stone_common.openLvl))
	end
end
function wnd_x_func:updateArrayStoneRed()
	self._layout.vars.arrayStoneRed:setVisible(g_i3k_game_context:getArrayStoneRedPointShow())
end

function wnd_x_func:onShow()

end

function wnd_x_func:onHide()

end


--[[
function wnd_x_func:updateScroll()
	local ironLine = {{2069, 2065, 2067, 2068}, {2070, 2381, 2071}} --隐藏历练2068  --隐藏排行榜2070，拍卖行2381

	local useItemBtnTbl =
	{
		[2069] = wnd_x_func.onMyFirends,
		[2065] = wnd_x_func.toBangpaiCB,
		[2067] = wnd_x_func.toSteedSystem,
		[2068] = wnd_x_func.onEmpowerment,
		[2070] = wnd_x_func.onRankList,
		[2381] = wnd_x_func.toAuction,
		[2071] = wnd_x_func.onSet,
	}

	local useItemPointTbl =
	{
		[2067] = wnd_x_func.updateSteedNotice,
		[2068] = wnd_x_func.updateEmpowermentNotice,
	}
	local useItemTypeTbl = {}
	for i=1, 2 do
		local deletekey = {}
		for k,v in ipairs(ironLine[i]) do
			if v == 2068 then
				if g_i3k_game_context:GetLevel() < i3k_db_experience_args.args.hideLvl then
					table.insert(deletekey, k)
				end
			elseif v == 2070 then
				if g_i3k_game_context:GetLevel() < RANK_LIST_HIDELEVEL then
					table.insert(deletekey, k)
				end
			elseif v == 2381 then
				if g_i3k_game_context:GetLevel() < AUCTION_HIDELEVEL then
					table.insert(deletekey, k)
				end
			end
		end
		for k = #deletekey, 1, -1 do
			if deletekey[k] then
				table.remove(ironLine[i], deletekey[k])
			end
		end
	end
	for i=1, 2 do
		self.scroll[i]:removeAllChildren()
		for k,v in ipairs(ironLine[i]) do
			local _layer = require(LAYER_ZJMT2)()
			local widget = _layer.vars
			widget.btn:setImage(g_i3k_db.i3k_db_get_icon_path(v), "")
			widget.btn:onClick(self, useItemBtnTbl[v])
			widget.point:setVisible(false)
			local isShow = useItemPointTbl[v] and useItemPointTbl[v] or false
			if isShow and isShow(self) then
				widget.point:setVisible(true)
			end
			self.scroll[i]:addItem(_layer)
		end
		self.scroll[i]:stateToNoSlip()
	end

end
]]
function wnd_create(layout)
	local wnd = wnd_x_func.new()
	wnd:create(layout)
	return wnd;
end
