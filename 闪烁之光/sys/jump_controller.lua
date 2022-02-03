--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-03-30 15:19:57
-- @description    : 
		-- 这里统一处理跳转
---------------------------------

JumpController = JumpController or BaseClass(BaseController)

function JumpController:config(  )
end

function JumpController:registerEvents(  )
end

-- 跳转
--[[
	evt_data[1]: 为跳转id
	evt_data[2]: 2及之后都为扩展参数
]]
function JumpController:jumpViewByEvtData( evt_data )
	if not evt_data or not evt_data[1] then return end
	local evt_id = tonumber(evt_data[1])
	if evt_id == 1 then 		-- 召唤
        MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.partnersummon)
        -- PartnersummonController:getInstance():openPartnerSummonWindow(true)
	elseif evt_id == 2 then 	-- 获取一个x星英雄
		if evt_data and next(evt_data) then
			local extra_type = evt_data[2]
            local extra_val = evt_data[3]
            if extra_type == "star" then
                if extra_val <= 5 then -- 小于等于5星打开召唤界面
                    PartnersummonController:getInstance():openPartnerSummonWindow(true)
                else  -- 大于5星打开融合界面
                    HeroController:getInstance():openHeroResetWindow(true, HeroConst.SacrificeType.eHeroFuse)
                end
            elseif extra_type == "lev" then -- 跳转到英雄界面
            	MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.partner)
            else
                PartnersummonController:getInstance():openPartnerSummonWindow(true)
            end
		else
			PartnersummonController:getInstance():openPartnerSummonWindow(true)
		end
	elseif evt_id == 3 then 	-- 竞技场
		MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.arena_call)
	elseif evt_id == 4 then 	-- 好友
		FriendController:getInstance():openFriendWindow(true, FriendConst.Type.MyFriend)
	elseif evt_id == 5 then 	-- 剧情副本
		MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.drama_scene)
	elseif evt_id == 6 then 	-- 精灵商店
		MallController:getInstance():openVarietyStoreWindows(true)
	elseif evt_id == 7 then 	-- VIP界面
		local tab_type = evt_data[2] or VIPTABCONST.CHARGE
        local sub_type = evt_data[3]
        VipController:getInstance():openVipMainWindow(true, tab_type, sub_type)
		--MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
	elseif evt_id == 8 then 	-- 背包
		local sub_type = evt_data[2]
		MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.backpack, sub_type)
	elseif evt_id == 9 then 	-- 聊天界面
		local channel = evt_data[2] or ChatConst.Channel.World
		ChatController:getInstance():openChatPanel(channel)
	elseif evt_id == 10 then 	-- 私聊
		ChatController:getInstance():openChatPanel(ChatConst.Channel.Friend,"friend")
	elseif evt_id == 11 then 	-- 快速作战
		BattleDramaController:getInstance():openDramBattleQuickView(true)
	elseif evt_id == 12 then 	-- 星命塔
		MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.startower)
	elseif evt_id == 13 then 	-- 公会捐献
		local role_vo = RoleController:getInstance():getRoleVo()
        if role_vo:isHasGuild() then
            GuildController:getInstance():openGuildDonateWindow(true)
        else
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.guild)
        end
	elseif evt_id == 14 then 	-- 公会
		MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.guild)
	elseif evt_id == 15 then 	-- 商城
		local mall_type = evt_data[2]
		local bid = evt_data[3]
		MallController:getInstance():openMallPanel(true, mall_type, bid)
	elseif evt_id == 16 then 	-- 变强
        local index = evt_data[2]
		StrongerController:getInstance():openMainWin(true, index)
	elseif evt_id == 17 then 	-- 历练
		MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.dungeonstone)
	elseif evt_id == 18 then 	-- 远航
		VoyageController:getInstance():openVoyageMainWindow(true)
	elseif evt_id == 19 then 	-- 英雄背包
		local sub_type = evt_data[2]
		MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.partner, sub_type)
	elseif evt_id == 20 then 	-- 神器界面
		MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.hallows)
	elseif evt_id == 21 then 	-- 公会战
		local is_open = GuildwarController:getInstance():checkIsCanOpenGuildWarWindow()
        if is_open == true then
            local guildwar_status = GuildwarController:getInstance():getModel():getGuildWarStatus()
            if guildwar_status == GuildwarConst.status.processing or 
                guildwar_status == GuildwarConst.status.settlement then
                MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.guildwar)
            else
                message(TI18N("公会战尚未开启"))
            end
        end
	elseif evt_id == 22 then 	-- 祭祀小屋
		HeroController:getInstance():openHeroResetWindow(true,HeroConst.SacrificeType.eHeroSacrifice)
	elseif evt_id == 23 then 	-- 融合祭坛
		HeroController:getInstance():openHeroResetWindow(true,HeroConst.SacrificeType.eHeroFuse)
	elseif evt_id == 24 then 	-- 先知殿
		local sub_type = evt_data[2]
		MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.seerpalace, sub_type)
	elseif evt_id == 25 then 	-- 远征
		-- MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.expedit_fight)
        PlanesafkController:getInstance():sender28601()
	elseif evt_id == 26 then 	-- 锻造屋
		local sub_type = evt_data[2] or ForgeHouseConst.Tab_Index.Equip
		MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.forge_house, sub_type)
	elseif evt_id == 27 then 	-- 星河神殿
		MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.primuswar)
	elseif evt_id == 28 then 	-- 精英大赛
		MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.eliteMatchWar)
	elseif evt_id == 29 then 	-- 跨服天梯
		MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.ladderwar)
	elseif evt_id == 30 then 	-- 布阵阵法
		HeroController:getInstance():openFormMainWindow(true)
	elseif evt_id == 31 then 	-- 公会副本
		local role_vo = RoleController:getInstance():getRoleVo()
        if role_vo:isHasGuild() then
            MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.GuildDun)
        else
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.guild)
        end
	elseif evt_id == 32 then 	-- 公会技能
		local role_vo = RoleController:getInstance():getRoleVo()
        if role_vo:isHasGuild() then
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.guild_skill)
            -- GuildskillController:getInstance():openGuildSkillMainWindow(true)
        else
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.guild)
        end
    elseif evt_id == 33 then 	-- 公会红包
    	local role_vo = RoleController:getInstance():getRoleVo()
        if role_vo:isHasGuild() then
            RedbagController:getInstance():openMainView(true)
        else
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.guild)
        end
    elseif evt_id == 34 then 	-- 神界冒险
    	MainuiController:changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.adventure)
    elseif evt_id == 35 then 	-- 点金
    	ExchangeController:getInstance():openExchangeMainView(true)
    elseif evt_id == 36 then 	-- 冠军赛
    	MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.champion_call)
    elseif evt_id == 37 then 	-- 天梯商店
    	local is_open = LadderController:getInstance():getModel():getLadderOpenStatus()
        if is_open then
            LadderController:getInstance():requestLadderMyBaseInfo()
            LadderController:getInstance():openLadderShopWindow(true)
        end
    elseif evt_id == 38 then 	-- 投资计划
    	WelfareController:getInstance():openMainWindow(true, ActionSpecialID.invest)
    elseif evt_id == 39 then 	-- 成长基金
    	WelfareController:getInstance():openMainWindow(true, ActionSpecialID.growfund)
    elseif evt_id == 40 then 	-- 探宝
    	ActionController:getInstance():openLuckyTreasureWin(true)
    elseif evt_id == 41 then 	-- 日常（任务或成就）
    	local sub_type = evt_data[2]
    	TaskController:getInstance():openTaskMainWindow(true, sub_type)
    elseif evt_id == 42 then 	-- 元素圣殿
    	MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.elementWar)
    elseif evt_id == 43 then 	-- 无尽试炼
    	MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.endless)
    elseif evt_id == 44 then --至尊月卡--集合
    	WelfareController:getInstance():openMainWindow(true,WelfareIcon.yueka)
    elseif evt_id == 45 then 	-- 限时召唤
    	local extend_data = evt_data[2]
    	MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.wonderful, extend_data)
	elseif evt_id == 46 then --剧情副本的通关奖励
		BattleDramaController:getInstance():openDramRewardView(true)
	elseif evt_id == 47 then -- 天界副本
		local max_chapter_id = evt_data[2]
		MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.HeavenWar, max_chapter_id)
    elseif evt_id == 48 then --天界祈祷
    	local sub_type = evt_data[2]
        HeavenController:getInstance():openHeavenMainWindow(true, nil,HeavenConst.Tab_Index.DialRecord,sub_type)
    elseif evt_id == 49 then --跨服竞技场
    	MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.CrossArenaWar)
    elseif evt_id == 50 then --跨服竞技场商城
    	CrossarenaController:getInstance():openCrossarenaShopWindow(true)
    elseif evt_id == 51 then --家园
    	MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.homeworld)
    elseif evt_id == 52 then  -- 跳转到最高矿脉层，如果矿脉没开，则跳转到冒险
    	if not AdventureController:getInstance():checkMaxMineLayerInfo() then
    		message(TI18N("冒险第十层可进入水晶秘境，采集珍贵晶石精炼神器"))
    		MainuiController:changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.adventure)
    	end
    elseif evt_id == 53 then -- 周冠军赛
        MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.CrossChampion)
    elseif evt_id == 54 then -- 提炼魔液''
        HeroController:getInstance():openHeroResonateExtractPanel(true)
    elseif evt_id == 55 then -- 共鸣石碑
        HeroController:getInstance():openHeroResonateWindow(true)
    elseif evt_id == 56 then --圣羽商店跳转到周福利
        local controller = WelfareController:getInstance()
        if controller.welfare_win and controller.welfare_win.tab_list[WelfareIcon.week] then
            controller.welfare_win:handleSelectedTab(controller.welfare_win.tab_list[WelfareIcon.week])
        end
    elseif evt_id == 57 then --先知豪礼
        local controller = ActionController:getInstance()
        local tab_vo = controller:getActionSubTabVo(ActionRankCommonType.recruit_luxury)
        if tab_vo then
            controller:openActionMainPanel(true, nil, tab_vo.bid) 
        else
            message(TI18N("该活动已结束"))
        end
    elseif evt_id == 58 then --召唤豪礼
        local controller = ActionController:getInstance()
        local tab_vo = controller:getActionSubTabVo(ActionRankCommonType.summon_luxury)
        if tab_vo then
            controller:openActionMainPanel(true, nil, tab_vo.bid) 
        else
            message(TI18N("该活动已结束"))
        end
    elseif evt_id == 59 then -- 冠军商店
        if CrosschampionController:getInstance():getModel():checkCrossChampionIsOpen() then
            CrosschampionController:getInstance():openCrosschampionShopWindow(true)
        end
    elseif evt_id == 60 then -- 精灵
        if ElfinController:getModel():checkElfinIsOpen() then
            local sub_type = evt_data[2]
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.partner, HeroConst.BagTab.eElfin, sub_type)
        end
    elseif evt_id == 61 then -- 家园商店
        local sub_type = evt_data[2]
        HomeworldController:getInstance():openHomeworldShopWindow(true, {index = sub_type})
    elseif evt_id == 62 then -- 公会秘境
        local role_vo = RoleController:getInstance():getRoleVo()
        if not role_vo then return end
        if role_vo:isHasGuild() then
            MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.GuildSecretArea)
        else
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.guild)
        end
    elseif evt_id == 63 then -- 公会宝库
        local role_vo = RoleController:getInstance():getRoleVo()
        if not role_vo then return end
        if role_vo:isHasGuild() then
            GuildmarketplaceController:getInstance():openGuildmarketplaceMainWindow(true)
        else
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.guild)
        end
        
    elseif evt_id == 64 then -- 花火大会
        if not PetardActionController:getInstance():getModel():checkPetardIsOpen() then
            message(TI18N("活动未开启"))
            return
        end
        local controller = ActionController:getInstance()
        local tab_vo = controller:getActionSubTabVo(ActionRankCommonType.petard)
        if tab_vo then
            controller:openActionMainPanel(true, MainuiConst.icon.festival, tab_vo.bid) 
        else
            message(TI18N("该活动已结束"))
        end
    elseif evt_id == 65 then -- 组队竞技场
        if ArenateamController:getInstance():getModel():checkArenaTeamIsOpen() then
             ArenateamController:getInstance():openArenateamMainWindow(true)
        end
    elseif evt_id == 66 then -- 306、圣夜奇境主活动界面
        if self:checkMonopolyIcon() then
            local extra_type = evt_data[2]
            MonopolyController:getInstance():openHolynightMainWindow(true, extra_type)
        end

    elseif evt_id == 67 then -- 巅峰冠军赛
        local is_open = ArenapeakchampionController:getInstance():getModel():checkPeakChampionIsOpen()
        if is_open then
            ArenapeakchampionController:getInstance():openArenapeakchampionMainWindow(true)
        end
    elseif evt_id == 68 then -- 位面
        -- PlanesController:getInstance():openPlanesMainWindow(true)
        PlanesafkController:getInstance():sender28601()
    elseif evt_id == 69 then -- 推荐码
        WelfareController:getInstance():openMainWindow(true, WelfareIcon.invicode)
    elseif evt_id == 70 then -- 年兽界面
        ActionyearmonsterController:getInstance():sender28204()
    elseif evt_id == 71 then -- 英魂商店
        local charge_cfg = Config.ChargeData.data_constant["open_lv"]
        local role_vo = RoleController:getInstance():getRoleVo()
        if not role_vo or not charge_cfg then return end
        if charge_cfg and role_vo and role_vo.lev < charge_cfg.val then
            message(TI18N("6级开启英魂商店"))
            return
        end
        local setting = {}
        setting.mall_type = MallConst.MallType.HeroSoulShop
        setting.item_id = 10005 -- 英魂之心
        setting.config = Config.ExchangeData.data_shop_exchage_herosoul
        setting.shop_name = TI18N("英魂商店")
        MallController:getInstance():openMallSingleShopPanel(true, setting)
    elseif evt_id == 72 then -- 每周特惠（福利）
        WelfareController:getInstance():openMainWindow(true, WelfareIcon.week)
    elseif evt_id == 73 then -- 专属订阅（福利）
        WelfareController:getInstance():openMainWindow(true, WelfareIcon.subscribe)
    elseif evt_id == 74 then --自选礼包
        local controller = ActionController:getInstance()
        local tab_vo = controller:getActionSubTabVo(ActionRankCommonType.grow_gift)
        if tab_vo then
            controller:openActionMainPanel(true, nil, tab_vo.bid) 
        else
            message(TI18N("该活动已结束"))
        end
    elseif evt_id == 75 then --巅峰冠军赛商店
        ArenapeakchampionController:getInstance():openArenapeakchampionShop()
    elseif evt_id == 76 then --多人竞技场
        if not ArenaManyPeopleController:getInstance():getModel():checkAMPIsOpen() then
            message(TI18N("活动未开启"))
            return
        end
        MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.AreanManyPeople)
	end
end

function JumpController:checkMonopolyIcon()
    local mainui_ctr = MainuiController:getInstance()
    --检查主界面 圣圣夜奇境的按钮是否存在..才跳转
    if mainui_ctr and mainui_ctr.mainui and mainui_ctr.mainui:checkIconIn(MainuiConst.icon.monopoly) then
        return true
    end
    message(TI18N("活动未开启或已结束"))
    return false
end

function JumpController:__delete(  )
end

