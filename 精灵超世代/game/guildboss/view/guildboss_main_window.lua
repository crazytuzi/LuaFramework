-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      公会boss主窗体
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildBossMainWindow = GuildBossMainWindow or BaseClass(BaseView)

local controller = GuildbossController:getInstance()
local model = GuildbossController:getInstance():getModel()
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove

function GuildBossMainWindow:__init()
	self.win_type = WinType.Big
    self.is_full_screen = false
	self.layout_name = "guildboss/guildboss_main_window"
	self.monster_list = {}				-- 存储怪物相关显示数据的
	self.view_tag = ViewMgrTag.DIALOGUE_TAG 

	self._doubleRewardList = {}
	self._currentPassNum = {}
	self._doublePassNum = {}
	self.item_pool = {}
	self.item_list = {}
	self.rank_list = {}
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("guildboss", "guildboss"), type = ResourcesType.plist},
	} 
end 

function GuildBossMainWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())

	local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 1)
	local main_panel = main_container:getChildByName("main_panel")
	main_panel:getChildByName("win_title"):setString(TI18N("联盟副本"))
	main_panel:getChildByName("challenge_times_title"):setString(TI18N("剩余次数:"))
	main_panel:getChildByName("notice_desc"):setString(TI18N("点击选择将要挑战的BOSS"))
	main_panel:getChildByName("mail_notice"):setString(TI18N("击杀奖励通过邮件发放"))
	main_panel:getChildByName("dps_reward_title"):setString(TI18N("伤害\n奖励"))
	main_panel:getChildByName("kill_reward_title"):setString(TI18N("击杀\n奖励"))

	self.close_btn = main_panel:getChildByName("close_btn")
	self.explain_btn = main_panel:getChildByName("explain_btn")
	self.add_btn = main_panel:getChildByName("add_btn")

	self.rank_btn = main_panel:getChildByName("rank_btn")
	self.rank_btn:getChildByName("Text_3"):setString(TI18N("排行奖励"))

	self.challenge_btn = main_panel:getChildByName("challenge_btn")
	self.mopup_btn = main_panel:getChildByName("mopup_btn") 
	self.challenge_btn_label = self.challenge_btn:getChildByName("label")
	self.mopup_btn_label = self.mopup_btn:getChildByName("label")
	self.challenge_btn_label:setString(TI18N("挑战")) 
	self.mopup_btn_label:setString(TI18N("扫荡"))

	--集结
	self.muster_btn = main_panel:getChildByName("muster_btn")
	self.muster_btn_tips = self.muster_btn:getChildByName("label")
	--self.muster_btn_tips:setString(TI18N(""))

	self.musterImage = main_panel:getChildByName("musterImage")
	self.musterImage:setPositionY(self.muster_btn:getPositionY() - 43)
	self.musterImage:setVisible(false)
	self.muster_btn_label = self.musterImage:getChildByName("label")

	self._doubleReward = main_panel:getChildByName("doubleReward")
	self._doubleReward:setVisible(false)

	self.reset_time_value = createRichLabel(22,1,cc.p(0,0.5),cc.p(27,212))
	main_panel:addChild(self.reset_time_value)
	self.challenge_times_value = main_panel:getChildByName("challenge_times_value")			-- 挑战次数
	self.chapter_name = main_panel:getChildByName("chapter_name")							-- 第五章 荒野蛮灵
	self.chapter_boss_container = main_panel:getChildByName("chapter_boss_container")		--上面章节信息
	self.guild_boss_view = GuildBossPreviewWindow.new()
	self.chapter_boss_container:addChild(self.guild_boss_view)
	

	self.buff_container = main_panel:getChildByName("buff_container")						--buff_container
	self.buff_container_pos_x = self.buff_container:getPositionX() 
	self.buff_container_pos_y = self.buff_container:getPositionY() 
	self.buff_name = self.buff_container:getChildByName("buff_name")
	self.buff_name:setString("")
	self.buff_icon = self.buff_container:getChildByName("buff_icon")
	self.buff_acitive_label = createRichLabel(16,1,cc.p(0,0.5),cc.p(215,26),nil,nil)
	self.buff_container:addChild(self.buff_acitive_label)

	self.comfirm_btn = createButton(main_panel,TI18N("激活"), self.buff_container_pos_x + 200, self.buff_container_pos_y + 26 , cc.size(100, 44), PathTool.getResFrame("common", "common_1125"), 18)
	--self.comfirm_btn:enableOutline(Config.ColorData.data_color4[264], 2)
	self.comfirm_btn:setScale(0.9)
	self.comfirm_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			self:checkBuff()
		end
	end)


	main_panel:getChildByName("Text_1"):setString(TI18N("剩余购买次数："))
	self.remain_buy = main_panel:getChildByName("remain_buy")
	self.remain_buy:setString("")

	self.rank_container = main_panel:getChildByName("rank_container")
	--self.rank_info_btn = self.rank_container:getChildByName("rank_btn")
	--self.rank_btn_label = self.rank_btn:getChildByName("label")

	self.rank_info_btn = createRichLabel(18, cc.c4b(0x83,0xe7,0x73,0xff), cc.p(0.5, 0.5), cc.p(82, 16))
	self.rank_info_btn:setString(string_format("<div #1db116 href=xxx>%s</div>", TI18N("点击查看详情")))
	self.rank_info_btn:addTouchLinkListener(function(type, value, sender, pos)
		print("onClickRankBtn")

		self:onClickRankBtn()
	end, { "click", "href" })
	self.rank_container:addChild(self.rank_info_btn)

	self.bg = main_panel:getChildByName("bg")

	for i=1,1 do
		local object = {}
		object.container = main_panel:getChildByName("monster_container_"..i)				-- 点击容器
		object.model = object.container:getChildByName("monster_model")						-- 存放模型的节点
		object.pass_icon = object.container:getChildByName("pass_icon") 					-- 已击杀
		local res_id = PathTool.getTargetRes("guildboss/txt_guildboss",
		"txt_cn_guildboss_1002",false)
		loadSpriteTexture(object.pass_icon, res_id,LOADTEXT_TYPE)
		object.monster_name = object.container:getChildByName("monster_name") 				-- 怪物的名字
		object.progress_container = object.container:getChildByName("progress_container") 	-- 进度条容器，已击杀则不显示
		object.progress = object.progress_container:getChildByName("progress") 				-- 血量进度条
		object.hp_value = object.progress_container:getChildByName("hp_value") 				-- 血量百分比显示
		object.boss_icon = PlayerHead.new(PlayerHead.type.circle)
		object.boss_icon:setAnchorPoint(0.5, 0.5)
		object.boss_icon:setScale(0.65)
		object.boss_icon:setPosition(80,258)
		object.container:addChild(object.boss_icon)
		self.monster_conatiner = object
	end
	self.main_panel = main_panel
end

function GuildBossMainWindow:checkBuff()
	if self.base_info then
		if self.base_info.buff_lev >= tableLen(Config.GuildDunData.data_buff_data) then
			message(TI18N("buff已满级"))
			return 
		end
		local item = Config.GuildDunData.data_const["buff_item"].val
		local num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(item)
		local cost = Config.GuildDunData.data_const["buff_cost"].val
		local item_icon = Config.ItemData.data_get_data(item).icon
		local index_lev = math.min(self.base_info.buff_lev + 1, tableLen(Config.GuildDunData.data_buff_data))
		local desc = Config.GuildDunData.data_buff_data[index_lev].desc
		local str = ""
		local str_ =  ""
		if num > 0 then --如果存在道具
			if self.base_info.buff_lev == 0 then --表示没buff
				str = string.format(TI18N("是否使用<img src=%s visible=true scale=0.5 /><div fontColor=#289b14 fontsize= 24>%s</div><div fontColor=#3d5078>(拥有:</div><div fontColor=#289b14 fontsize= 24>%s</div><div fontColor=#3d5078>)激活全会伤害提升Buff\n</div>"),PathTool.getItemRes(item_icon),1,num)
    			str_ = str..string.format(TI18N("<div fontColor=#3d5078>(激活后效果为</div><div fontColor=#289b14 fontsize= 24>%s</div><div fontColor=#3d5078>)</div>"),desc)
			else
				str = string.format(TI18N("是否使用<img src=%s visible=true scale=0.5 /><div fontColor=#289b14 fontsize= 24>%s</div><div fontColor=#3d5078>(拥有:</div><div fontColor=#289b14 fontsize= 24>%s</div><div fontColor=#3d5078>)提升全会伤害提升Buff\n</div>"),PathTool.getItemRes(item_icon),1,num)
    			str_ = str..string.format(TI18N("<div fontColor=#3d5078>(激活后效果为</div><div fontColor=#289b14 fontsize= 24>%s</div><div fontColor=#3d5078>)</div>"),desc)
			end
		else
			if self.base_info.buff_lev == 0 then --表示没buff
				str = string.format(TI18N("是否消耗<img src=%s visible=true scale=0.5 /><div fontColor=#289b14 fontsize= 24>%s</div><div fontColor=#3d5078>激活全会伤害提升Buff\n</div>"),PathTool.getItemRes(Config.ItemData.data_assets_label2id.gold),cost,num)
				str_ = str..string.format(TI18N("<div fontColor=#3d5078>(激活后效果为</div><div fontColor=#289b14 fontsize= 24>%s</div><div fontColor=#3d5078>)</div>"),desc)
			else
				str = string.format(TI18N("是否消耗<img src=%s visible=true scale=0.5 /><div fontColor=#289b14 fontsize= 24>%s</div><div fontColor=#3d5078>提升全会伤害提升Buff\n</div>"),PathTool.getItemRes(Config.ItemData.data_assets_label2id.gold),cost,num)
				str_ = str..string.format(TI18N("<div fontColor=#3d5078>(激活后效果为</div><div fontColor=#289b14 fontsize= 24>%s</div><div fontColor=#3d5078>)</div>"),desc)
			end
		end
		local function fun()
			controller:send21305()
		end
		CommonAlert.show(str_, TI18N('确认'), fun, TI18N('取消'), nil, CommonAlert.type.rich, nil, nil, nil, true)
	end
end

function GuildBossMainWindow:onClickRankBtn()
	playButtonSound2()
	print("onClickRankBtn")
	local data
	if self.guild_boss_view then
		data = self.guild_boss_view:getCurSelect()
	end
	controller:openGuildbossRankRoleWindow(true,data)
end

function GuildBossMainWindow:updateMusterCoolTimeTicket()
	self.remainTime = self.remainTime - 1
	if self.remainTime <= 0 then
		self.musterImage:setVisible(false)
		--self.muster_btn_tips:setVisible(true)
		self.muster_btn_label:stopAllActions()
	end
	self.muster_btn_label:setString(string.format(TI18N("%s\n后可集结"),TimeTool.GetTimeFormat(self.remainTime)))
end
function GuildBossMainWindow:musterCoolCountTime(less_time)
	if tolua.isnull(self.muster_btn_label) then return end
	self.remainTime = less_time
	self.muster_btn_label:stopAllActions()
	if self.remainTime > 0 then
		self.musterImage:setVisible(true)
		self.muster_btn_label:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),
		cc.CallFunc:create(function()
			self.remainTime = self.remainTime - 1
			if self.remainTime <= 0 then
				self.musterImage:setVisible(false)
				--self.muster_btn_tips:setVisible(true)
				self.muster_btn_label:stopAllActions()
			else
				self.musterImage:setVisible(true)
				--self.muster_btn_tips:setVisible(false)
				self.muster_btn_label:setString(string.format(TI18N("%s\n后可集结"),TimeTool.GetTimeFormat(self.remainTime)))
			end
		end))))
		self:updateMusterCoolTimeTicket()
	else
		self.musterImage:setVisible(false)
		self.muster_btn_label:stopAllActions()
		--self.muster_btn_tips:setString(TI18N("集结号角"))
    end
end

function GuildBossMainWindow:register_event()
	self.role_vo = RoleController:getInstance():getRoleVo()
    if self.role_vo ~= nil then
        if self.role_assets_event == nil then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                if key == "position" then
                    -- print("公会职位发生变化......")
                end
            end)
        end 
    end


	if self.muster_btn then
		self.muster_btn:addTouchEventListener(function(sender, event_type)
			customClickAction(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				if self.role_vo.position == 1 or self.role_vo.position == 2 then
					local function fun()
						controller:send21323()
					end
					local str = string.format(TI18N("发出集结后将会提醒所有会友，且有1小时内不可再发出集结（全会），是否确定发出集结？"))
					CommonAlert.show(str,TI18N("确定"),fun,TI18N("取消"),nil,CommonAlert.type.common,nil,nil,24)
				else
					message(TI18N("只有会长、副会长可发出集结"))
				end
			end
		end)
	end
	if self._musterCoolTimeEvent == nil then
		self._musterCoolTimeEvent = GlobalEvent:getInstance():Bind(GuildbossEvent.MusterCoolTime, function(data)
			if self.role_vo.position == 1 or self.role_vo.position == 2 then
				self:musterCoolCountTime(data)
			else
				--self.muster_btn_tips:setString(TI18N("集结号角"))
			end
	    end)
	end

	if self._doubleTimeEvent == nil then
		self._doubleTimeEvent = GlobalEvent:getInstance():Bind(GuildbossEvent.BossActivityDoubleTime, function(data)
			self:doubleTimeAction(data)
		end)
	end
	if self.buff_container then
		self.buff_container:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playCloseSound()
				self:checkBuff()
			end
		end) 
	end
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openMainWindow(false)
		end
	end)
	self.close_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openMainWindow(false)
		end
	end) 

	registerButtonEventListener(self.explain_btn, function(param,sender, event_type)
        local config = Config.GuildDunData.data_const.game_rule
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
    end,true, 1)

	self.add_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			controller:requestBuyChallengeTimes(FALSE)
		end
	end)

	self.rank_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			local select_item
			if self.guild_boss_view then
				select_item = self.guild_boss_view:getCurSelect()
			end
			if select_item and select_item.data then
				controller:openGuildBossRankWindow(true, select_item.data)
			end
		end
	end) 
	--if self.rank_info_btn then
	--	self.rank_info_btn:addTouchEventListener(function(sender, event_type)
	--		customClickAction(sender, event_type)
	--		if event_type == ccui.TouchEventType.ended then
	--			playButtonSound2()
	--			local data
	--			if self.guild_boss_view then
	--				data = self.guild_boss_view:getCurSelect()
	--			end
	--			controller:openGuildbossRankRoleWindow(true,data)
	--		end
	--	end)
	--end

	self.challenge_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.cur_selected_object and self.cur_selected_object.config and self.base_info then
				if self.base_info.count > 0 then
					HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.GuildDun_AD, {boss_id = self.cur_selected_object.config.boss_id})
				else
					controller:requestBuyChallengeTimes(TRUE) 
				end 
			end
		end
	end)

	self.mopup_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.cur_selected_object and self.cur_selected_object.config and self.base_info then
				self:requestMopupMonster()
			end
		end
	end)
	-- 更新面板基础信息
	if self.update_baseinfo_event == nil then
		self.update_baseinfo_event = GlobalEvent:getInstance():Bind(GuildbossEvent.UpdateGuildDunBaseInfo, function()
			if self.guild_boss_view and not tolua.isnull(self.guild_boss_view) then
				-- self.guild_boss_view:updateData(true)
				self.guild_boss_view:updateScrollViewList()
			end
			self:updateDunBaseInfo()
		end)
	end
	if self.update_change_event == nil then
		self.update_change_event = GlobalEvent:getInstance():Bind(GuildbossEvent.UpdateChangeStatus,function (data)
			self:updateChangeStatus(data)
		end)
	end

	if self.update_rank_event == nil then
		self.update_rank_event = GlobalEvent:getInstance():Bind(GuildbossEvent.UpdateGuildDunRank,function ()
			local rank_list = controller:getModel():getRaknRoleTopThreeList()
			if rank_list and next(rank_list or {}) ~= nil then
				for i, v in ipairs(rank_list) do
					if not self.rank_list[i] then
						local item = self:createSingleRankItem(i,v)
						self.rank_container:addChild(item)
						self.rank_list[i] = item
					end
					local item = self.rank_list[i]
					if item then
						item:setPosition(0,164 - (i-1) * item:getContentSize().height)
						item.label:setString(v.name)
						if v.all_dps then
							item.value:setString(TI18N("伤害") .. MoneyTool.GetMoneyString(changeBtValueForBattle(v.all_dps), false))
						else
							item.value:setString("")
						end
					end
				end
			end
		end)
	end
	-- 更新当前剩余挑战次数
	if self.update_challenge_times_event == nil then
		self.update_challenge_times_event = GlobalEvent:getInstance():Bind(GuildbossEvent.UpdateGuildBossChallengeTimes, function(buy_type)
			if self.base_info ~= nil then
				self:remainBuyCount(self.base_info.buy_count)
				self.challenge_times_value:setString(self.base_info.count) 
			else
				local base_info = model:getBaseInfo()
				if base_info ~= nil then
					self:remainBuyCount(base_info.buy_count)
					self.challenge_times_value:setString(base_info.count) 
				end
			end
			-- 挑战购买的时候自动打开挑战界面
			if buy_type == TRUE then
				self:autoOpenChallengeWindow()
			end
		end)
	end

	-- 红点状态
	if self.update_red_status_event == nil then
		self.update_red_status_event = GlobalEvent:getInstance():Bind(GuildEvent.UpdateGuildRedStatus, function(type, status)
			self:updateSomeRedStatus(type, status)
		end)
	end 
end

--切换Boss的时候
function GuildBossMainWindow:updateChangeStatus(data)
	if not data then return end
	local fid = 0
	local base_info = model:getBaseInfo()
	local object = self.monster_conatiner
	local hp_info = nil
	if data.status == FALSE then --进行中的
		fid = base_info.fid
		if base_info ~= nil and base_info.info ~= nil then
			-- 储存容器里面相关的boss模型
			local selected_type = 0
			for i, v in ipairs(base_info.info) do
				local boss_config = Config.GuildDunData.data_guildboss_list[v.boss_id]
				if boss_config then
					if object ~= nil then
						object.config = boss_config
						-- 更新血量
						hp_info = v
						
					end
				end
			end
			if base_info.combat_info then
				for i, v in ipairs(base_info.combat_info) do
					if object and object.config and v.boss_id == object.config.boss_id then
						object.dps = v.dps
					end
			
				end
			end 
		end
		self.buff_container:setVisible(true)
		self.comfirm_btn:setVisible(true)
	else
		fid = data.config.id
		object.config = data.config
		hp_info = {boss_id = data.config.boss_id ,hp = 0}
		object.dps = 0
		self.buff_container:setVisible(false)
		self.comfirm_btn:setVisible(false)

	end
	if fid then
		local chatpter_config = Config.GuildDunData.data_chapter_reward[fid]
		local config = Config.GuildDunData.data_guildboss_list[chatpter_config.show_id]
		if chatpter_config ~= nil then
			self.chapter_name:setString(chatpter_config.chapter_name .. ' ' .. chatpter_config.chapter_desc)
		end
		self:updateBg(config.bg_res)
	end
	if hp_info then
		self:updateMonsterHPStatus(object,hp_info)
	end
	if object then
		self:updateMonsterInfo(object) --更新模型
		self:updateSelectedBtnStatus()
	end
end

--排行榜单项
function GuildBossMainWindow:createSingleRankItem(i,data)
	local container = ccui.Layout:create()
	local size = cc.size(144, 44)

	container:setAnchorPoint(cc.p(0,1))
	container:setContentSize(size)

	local sp = createSprite(PathTool.getResFrame("common","common_rank_"..i), 10,size.height * 0.5,container)
	sp:setAnchorPoint(cc.p(0,0.5))
	--sp:setScale(0.6)
	container.sp = sp

	local label = createLabel(18, Config.ColorData.data_new_color4[15], cc.c4b(0x22,0x01,0x01,0xff), 38, 30, "", container, 2, cc.p(0,0.5))
	local value = createLabel(18, Config.ColorData.data_new_color4[15], cc.c4b(0x22,0x01,0x01,0xff), 38, 10, "", container, 2, cc.p(0,0.5))
	container.label = label
    container.value = value
	return  container
end

function GuildBossMainWindow:requestMopupMonster()
	if self.base_info == nil then return end
	local base_info = self.base_info
	if base_info.count > 0 then
		local msg = string_format(TI18N("确定按照上次挑战的伤害量<div fontcolor=#249003>%s</div>扫荡一次吗？"), self.cur_selected_object.dps)
		CommonAlert.show(msg,TI18N("确定"),function() 
			controller:requestMopupMonster(self.cur_selected_object.config.boss_id)
		end,TI18N("取消"),nil,CommonAlert.type.rich)
	else
		local buy_next_num = base_info.buy_count + 1
    	local buy_config = Config.GuildDunData.data_buy_count[buy_next_num]
		if buy_config == nil then
            message(TI18N("当前没有扫荡次数，且购买次数已到达本日上限！"))
		else
			local role_vo = RoleController:getInstance():getRoleVo()
			if role_vo then
				if role_vo.vip_lev < buy_config.vip_lev then 
					local msg = string_format(TI18N("挑战次数不足，提升至<div fontcolor='#289b14'>vip%s</div>，可增加<div fontcolor='#289b14'>1</div>点次数购买上限！"), buy_config.vip_lev)
					CommonAlert.show(msg,TI18N("我要提升"),function() 
						VipController:getInstance():openVipMainWindow(true,VIPTABCONST.CHARGE)
					end,TI18N("取消"),nil, CommonAlert.type.rich )
				else
					local cost = buy_config.expend
					if cost == nil or #cost < 2 then return end
					local item_config = Config.ItemData.data_get_data(cost[1])
					if item_config then
						local msg = string_format(TI18N("挑战次数不足，是否花费 <img src=%s visible=true scale=0.5 />%s 购买<div fontcolor='#289b14'>1</div>点挑战次数并扫荡？\n(扫荡根据上次的伤害量<div fontcolor=#249003>%s</div>进行结算)"), PathTool.getItemRes(item_config.icon), cost[2], self.cur_selected_object.dps) 
						CommonAlert.show(msg, TI18N("确定"), function()
							controller:requestMopupMonster(self.cur_selected_object.config.boss_id) 
						end, TI18N("取消"), nil, CommonAlert.type.rich)
					end
				end
			end
		end
	end
end

--==============================--
--desc:打开面板的请求
--time:2018-06-09 03:42:57
--@return 
--==============================--
function GuildBossMainWindow:openRootWnd()
	-- 基础信息，服务端要求没次打开面板的时候都请求一下
	controller:requestGuildDunBaseInfo()
	ActivityController:getInstance():setFirstComeGuild(false)
	-- 设置初始红点
	self:updateSomeRedStatus()
	if ActivityController:getInstance():getBossActivityDoubleTime() == true then
		self._doubleReward:setVisible(true)
	end
end


--设置buff倒计时
function GuildBossMainWindow:updateBuffTime(time)
    if time and time then
        self.buff_second = time
        if self.buff_second <= 0 then
            self:clearBuffTimeTicket()
        else
            if self.buff_time_ticket == nil then
                self.buff_time_ticket =GlobalTimeTicket:getInstance():add(function()
                    self:updateBuffTimeTicket()
                end,1)
            end
            self:updateBuffTimeTicket()
        end
    end
end

function GuildBossMainWindow:clearBuffTimeTicket()
    if self.buff_time_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.buff_time_ticket)
        self.buff_time_ticket = nil
    end
end

function GuildBossMainWindow:updateBuffTimeTicket()
    self.buff_second = self.buff_second - 1
    if self.buff_second <= 0 then
        self:clearBuffTimeTicket()
	end
	self.buff_acitive_label:setString(string_format(TI18N('<div fontcolor=#35ff14>(%s后失效)</div>'), TimeTool.GetTimeFormat(self.buff_second)))
	local x = self.buff_acitive_label:getPositionX()
	local size = self.comfirm_btn:getContentSize()
	self.comfirm_btn:setPositionX(self.buff_container_pos_x + x + self.buff_acitive_label:getSize().width + size.width * 0.5 + 10)		
end

--==============================--
--desc:打开窗体的时候，设置重置剩余时间
--time:2018-06-09 04:37:07
--@return 
--==============================--
function GuildBossMainWindow:updateResetTime(time)
	-- self.left_second = time
	-- if self.left_second <= 0 then
	-- 	self:clearTimeTicket()
	-- else
	-- 	if self.time_ticket == nil then
	-- 		self.time_ticket = GlobalTimeTicket:getInstance():add(function() 
	-- 			self:updateTimeTicket()
	-- 		end, 1)
	-- 	end
	-- 	self:updateTimeTicket()
	-- end
end

function GuildBossMainWindow:clearTimeTicket()
	-- if self.time_ticket ~= nil then
	-- 	GlobalTimeTicket:getInstance():remove(self.time_ticket)
	-- 	self.time_ticket = nil
	-- end 
end

function GuildBossMainWindow:updateTimeTicket()
	-- self.left_second = self.left_second - 1
	-- if self.left_second <= 0 then
	-- 	self:clearTimeTicket()
	-- end
	-- self.reset_time_value:setString(string_format(TI18N('<div fontcolor=#35ff14>%s</div>后重置副本'), TimeTool.GetTimeFormatDayIV(self.left_second)))
end

--==============================--
--desc:挑战购买次数的时候自动打开面板
--time:2018-07-09 07:50:35
--@return 
--==============================--
function GuildBossMainWindow:autoOpenChallengeWindow()
	if self.cur_selected_object and self.cur_selected_object.config and self.base_info then
		if self.base_info.count > 0 then
			HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.GuildDun_AD, {boss_id = self.cur_selected_object.config.boss_id})
		end 
	end
end

--==============================--
--desc:协议返回用于更新基础信息
--time:2018-06-09 03:40:24
--@return 
--==============================--
function GuildBossMainWindow:updateDunBaseInfo()
	self.base_info = model:getBaseInfo()
	local base_info = self.base_info
	if base_info ~= nil and base_info.info ~= nil then
		self:remainBuyCount(base_info.buy_count)
		-- 储存容器里面相关的boss模型
		local selected_type = 0
		for i,v in ipairs(base_info.info) do
			local boss_config = Config.GuildDunData.data_guildboss_list[v.boss_id]
			if boss_config then
				local object = self.monster_conatiner
				if object ~= nil then
					object.config = boss_config 
					-- 更新血量
					self:updateMonsterHPStatus(object, v)
				end
			end
		end
		-- 储存dps
		if base_info.combat_info then
			for i, v in ipairs(self.base_info.combat_info) do
				if self.monster_conatiner and self.monster_conatiner.config and v.boss_id == self.monster_conatiner.config.boss_id then
					self.monster_conatiner.dps = v.dps
				end
			end
		end 

		-- 设置基础信息显示
		self.challenge_times_value:setString(base_info.count)
		if self.cur_fid ~= base_info.fid then
			self.cur_fid = base_info.fid
			local chatpter_config = Config.GuildDunData.data_chapter_reward[base_info.fid]
			if chatpter_config ~= nil then
				if self.monster_conatiner and self.monster_conatiner.boss_icon then
					local config = Config.GuildDunData.data_guildboss_list[chatpter_config.show_id]
					if config then
						self.monster_conatiner.boss_icon:setHeadRes(config.head_icon)
						self:updateBg(config.bg_res)
					end
				end
				self.chapter_name:setString(chatpter_config.chapter_name.." "..chatpter_config.chapter_desc)

				-- 这里设置挑战奖励吧
				self:updateFillRewardsItems(chatpter_config.dps_awrard, chatpter_config.award, chatpter_config.guild_exp)
			end
		end
		-- 延迟创建模型
		delayRun(self.main_panel, 8 / display.DEFAULT_FPS, function() 
			self:updateMonsterInfo(self.monster_conatiner)
		end)
		self:selecetMonsterContainer()

		if base_info ~= nil and base_info.buff_end_time ~= 0 then
			local buff_config = Config.GuildDunData.data_buff_data[base_info.buff_lev]
			if buff_config then
				self.buff_name:setString(buff_config.desc)
				local x = self.buff_name:getSize().width + self.buff_name:getPositionX() + 10
				self.buff_acitive_label:setPositionX(x)
			end
			if base_info.buff_lev >= tableLen(Config.GuildDunData.data_buff_data) then
				--满级了
				self.comfirm_btn:setGrayAndUnClick(true, false)
				local btn_lab = self.comfirm_btn:getLabel()
				if btn_lab then
					btn_lab:disableEffect(cc.LabelEffect.OUTLINE)
				end
			end

			setChildUnEnabled(false,self.buff_container)
			self:updateBuffTime(base_info.buff_end_time)
			self.buff_container:setVisible(true)
			self.comfirm_btn:setVisible(true)
		else
			setChildUnEnabled(true,self.buff_container)
			self.buff_name:setString(Config.GuildDunData.data_const["des_nobuff"].desc)
			-- self.buff_acitive_label:setPositionX(self.buff_name:getSize().width + self.buff_name:getPositionX() + 10)
			-- self.buff_acitive_label:setString(TI18N("<div fontcolor=#ff5858>(未激活)</div>"))
			self.buff_acitive_label:setString("")

			local size = self.comfirm_btn:getContentSize()
			self.comfirm_btn:setPositionX(self.buff_container_pos_x + self.buff_name:getSize().width + self.buff_name:getPositionX() + size.width * 0.5 + 10)
		end
		-- 设置每天重置时间
		self:updateResetTime(base_info.ref_time)
	end
end
--剩余购买次数
function GuildBossMainWindow:remainBuyCount(count)
	local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo == nil then return end
	count = count or 0
	if self.remain_buy then
		local num = 0
		--获取当前最高次数
		local length = Config.GuildDunData.data_buy_count_length
		local buy_config = Config.GuildDunData.data_buy_count[length]
		if buy_config then
			num = buy_config.count - count
		end
		self.remain_buy:setString(num)
	end
end

function GuildBossMainWindow:updateBg(image)
	local res_id = PathTool.getPlistImgForDownLoad("bigbg/guildboss",image)
	if self.res_id ~= res_id then
		self.res_id = res_id
		self.item_load = createResourcesLoad(self.res_id, ResourcesType.single, function()
			if not tolua.isnull(self.bg) then
				loadSpriteTexture(self.bg, self.res_id, LOADTEXT_TYPE)
			end
		end, self.item_load)
	end
end
--==============================--
--desc:创建模型,根据config
--time:2018-06-26 11:12:37
--@object:
--@return 
--==============================--
function GuildBossMainWindow:updateMonsterInfo(object)
	if object == nil or object.config == nil then return end
	local config = object.config

	-- 怪物模型方面，只有id不同才做处理
	if object.boss_id ~= config.boss_id then
		object.boss_id = config.boss_id
		
		-- 设置模型
		object.monster_name:setString(config.item_name)

		-- 清除掉之前的模型
		if object.spine then
			object.spine:DeleteMe()
			object.spine = nil
		end
		object.spine = BaseRole.new(BaseRole.type.unit, config.combat_id)
		object.spine:setAnimation(0, PlayerAction.show, true)
		object.spine:setCascade(true)
		object.spine:setPosition(90,110)
		object.spine:setAnchorPoint(cc.p(0.5, 0))
		object.model:addChild(object.spine)
	end
end

--==============================--
--desc:选中指定的怪物节点
--time:2018-06-14 05:27:05
--@type:
--@return 
--==============================--
function GuildBossMainWindow:selecetMonsterContainer(type)
	self.cur_selected_object = self.monster_conatiner
	self:updateSelectedBtnStatus() 
end

--==============================--
--desc:更新选中对象的按钮状态
--time:2018-06-14 07:24:54
--@return 
--==============================--
function GuildBossMainWindow:updateSelectedBtnStatus()
	if self.cur_selected_object == nil then return end
	if self.cur_selected_object.hp == nil or self.cur_selected_object.dps == nil then return end
	
	if self.cur_selected_object.hp == 0 then -- 已经被击杀了
		self.challenge_btn:setTouchEnabled(false)
		setChildUnEnabled(true, self.challenge_btn)
		self.challenge_btn_label:disableEffect()

		self.mopup_btn:setTouchEnabled(false)
		setChildUnEnabled(true, self.mopup_btn)
		self.mopup_btn_label:disableEffect() 
	else
		if self.cur_selected_object.dps == 0 then		-- 没有挑战过，不可以扫荡
			self.mopup_btn:setTouchEnabled(false)
			self.mopup_btn_label:disableEffect() 
			setChildUnEnabled(true, self.mopup_btn)

			self.challenge_btn:setTouchEnabled(true)
			self.challenge_btn_label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
			--self.challenge_btn_label:enableOutline(Config.ColorData.data_color4[264],2)
			setChildUnEnabled(false, self.challenge_btn)
		else
			self.mopup_btn:setTouchEnabled(true)
			--self.mopup_btn_label:enableOutline(Config.ColorData.data_color4[264],2)
			self.mopup_btn_label:enableShadow(Config.ColorData.data_new_color4[3],cc.size(0, -2),2)

			setChildUnEnabled(false, self.mopup_btn)

			self.challenge_btn:setTouchEnabled(true)
			self.challenge_btn_label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)

			--self.challenge_btn_label:enableOutline(Config.ColorData.data_color4[264],2)
			setChildUnEnabled(false, self.challenge_btn)
			--self.mopup_btn_label:enableOutline(Config.ColorData.data_color4[263],2)
		end
	end
end

--==============================--
--desc:更新血条
--time:2018-06-26 11:07:36
--@object:
--@info:
--@return 
--==============================--
function GuildBossMainWindow:updateMonsterHPStatus(object, info)
	if object == nil or info == nil or object.config == nil then return end
	if info.hp <= 0 then
		self:doubleTimeAction(false)
	else
		if ActivityController:getInstance():getBossActivityDoubleTime() == true then
			self:doubleTimeAction(true)
		end
	end
	-- 设置血量
	local config = object.config
	local percent = math.ceil(100 * info.hp / config.hp)
	object.hp_value:setString(percent .. "%")
	object.progress:setPercent(percent)
	object.hp = info.hp
	object.pass_icon:setVisible(info.hp == 0)
	object.boss_icon:setVisible(info.hp ~= 0)
	object.monster_name:setVisible(info.hp ~= 0)
	object.progress_container:setVisible(info.hp ~= 0) 
end

function GuildBossMainWindow:doubleTimeAction(_bool)
	if _bool == false then
		self._doubleReward:setVisible(_bool)
		self._doubleReward:stopAllActions()
		if next(self._doubleRewardList) ~= nil then
			for i,v in pairs(self._doubleRewardList) do
				v:setSpecialColor()
	      		v:setSpecialNum(self._currentPassNum[i])
	      		v:setDoubleIcon(false)
			end
		end
		return
	end
	self._doubleReward:setVisible(_bool)
	local seq = cc.Sequence:create(cc.FadeOut:create(1.0),cc.FadeIn:create(1.0),cc.DelayTime:create(0.3))
	self._doubleReward:runAction(cc.RepeatForever:create(seq))

	if next(self._doubleRewardList) ~= nil then
		for i,v in pairs(self._doubleRewardList) do
	      	v:setSpecialColor(true)
	      	v:setSpecialNum(self._doublePassNum[i])
	      	v:setDoubleIcon(true)
		end
	end
end

--==============================--
--desc:设置物品奖励
--time:2018-06-15 09:41:53
--@dps_award:伤害奖励列表
--@fixed_award:固定奖励列表
--@guild_award:公会贡献特殊
--@return 
--==============================--
function GuildBossMainWindow:updateFillRewardsItems(dps_award, fixed_award, guild_award)
	dps_award = dps_award or {}
	fixed_award = fixed_award or {}

	local _fixed_award = DeepCopy(fixed_award)
	guild_award = guild_award or 0
	table_insert(_fixed_award, {Config.ItemData.data_assets_label2id.guild_exp, guild_award})

	for i, item in ipairs(self.item_list) do
		item:setVisible(false)
		table_insert(self.item_pool, item)
	end
	self.item_list = {}

	local item_config = nil
	local index = 1
	local backpack_item = nil
	local _x, _y = 0,120
	local scale = 0.8
	local desc
	-- 设置伤害奖励
	for i,v in ipairs(dps_award) do
		if #self.item_pool == 0 then
			backpack_item = BackPackItem.new(false, true, false, scale, false) 
			self.main_panel:addChild(backpack_item)
		else
			backpack_item = table_remove(self.item_pool, 1)
			backpack_item:setVisible(true)
		end
		_x = 120 + (index-1)*(BackPackItem.Width*scale+14) + BackPackItem.Width*scale*0.5
		backpack_item:setDefaultTip()

		-- backpack_item:setDoubleIcon(true)

		backpack_item:setPosition(_x, _y)
		backpack_item:setBaseData(v[1], 0)
		if v[2] >= 1000 then
			desc = string_format("%sK", math.floor(v[2] * 0.001))
		else
			desc = v[2]
		end
		if v[3] then
			if v[3] >= 1000 then
				desc = string_format("%s", desc)
			else
				desc = string_format("%s", desc) 
			end
		end
		backpack_item:setSpecialNum(desc)
		backpack_item:setSpecialColor()
		self._currentPassNum[i] = desc

		if not self._doubleRewardList[i] then
			self._doubleRewardList[i] = backpack_item
			local doubleDesc
			if v[2]*2 >= 1000 then
				doubleDesc = string_format("%sK", math.floor(v[2]*2 * 0.001))
			else
				doubleDesc = v[2]*2
			end
			if v[3] then
				if v[3]*2 >= 1000 then
					doubleDesc = string_format("%s", doubleDesc)
				else
					doubleDesc = string_format("%s", doubleDesc)
				end
			end
			self._doublePassNum[i] = doubleDesc
		end

		table_insert(self.item_list, backpack_item)
		index = index + 1
	end
	if ActivityController:getInstance():getBossActivityDoubleTime() == true then
		self:doubleTimeAction(true)
	end
	-- 设置击杀奖励
	index = 1
	for i,v in ipairs(_fixed_award) do
		if type(v) == "table" and v[1] and v[2] then
			if #self.item_pool == 0 then
				backpack_item = BackPackItem.new(false, true, false, scale, false) 
				self.main_panel:addChild(backpack_item)
			else
				backpack_item = table_remove(self.item_pool, 1)
				backpack_item:setVisible(true)
			end
			_x = 415 + (index-1)*(BackPackItem.Width*scale+14) + BackPackItem.Width*scale*0.5
			backpack_item:setDefaultTip()
			backpack_item:setPosition(_x, _y)
			backpack_item:setBaseData(v[1], v[2])

			table_insert(self.item_list, backpack_item)
			index = index + 1
		end
	end
end

--==============================--
--desc:更新红点
--time:2018-06-15 04:20:17
--@type:
--@return 
--==============================--
function GuildBossMainWindow:updateSomeRedStatus(type, status)
	local red_status = false
	if type == nil then
	else
		if type == GuildConst.red_index.boss_times then -- 挑战次数
		end
	end
end

function GuildBossMainWindow:getType(index)
	if index == 1 then
		return GuildBossConst.type.physics
	else
		return GuildBossConst.type.magic
	end
end

function GuildBossMainWindow:close_callback()
	if next(self._doubleRewardList) ~= nil then
		for i, item in ipairs(self._doubleRewardList) do
			if item.DeleteMe then
				item:DeleteMe()
			end
		end
		self._doubleRewardList = nil
	end

	self:clearTimeTicket()
	self:clearBuffTimeTicket()
	if self.item_load then
		self.item_load:DeleteMe()
		self.item_load = nil
	end
	for i,object in ipairs(self.monster_list) do
		if object.spine then
			object.spine:DeleteMe()
			object.spine = nil
		end
	end
	self.monster_list = nil

	for k, item in pairs(self.item_list) do
		if item.DeleteMe then
			item:DeleteMe()
		end
	end
	self.item_list =  nil

	for i,item in ipairs(self.item_pool) do
		item:DeleteMe()
	end
	if self.guild_boss_view and not tolua.isnull(self.guild_boss_view) then
		self.guild_boss_view:DeleteMe()
	end
	self.item_pool = nil

	if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
        self.role_vo = nil
    end


	if self.update_baseinfo_event ~= nil then
		GlobalEvent:getInstance():UnBind(self.update_baseinfo_event)
		self.update_baseinfo_event = nil
	end
	if self.update_challenge_times_event then
		GlobalEvent:getInstance():UnBind(self.update_challenge_times_event)
		self.update_challenge_times_event = nil
	end
	if self.update_red_status_event then
		GlobalEvent:getInstance():UnBind(self.update_red_status_event)
		self.update_red_status_event = nil
	end
	if self.update_change_event then
		GlobalEvent:getInstance():UnBind(self.update_change_event)
		self.update_change_event = nil
	end
	if self.update_rank_event then
		GlobalEvent:getInstance():UnBind(self.update_rank_event)
		self.update_rank_event = nil
	end
	if self._musterCoolTimeEvent then
		GlobalEvent:getInstance():UnBind(self._musterCoolTimeEvent)
		self._musterCoolTimeEvent = nil
	end
	if self._doubleTimeEvent then
		GlobalEvent:getInstance():UnBind(self._doubleTimeEvent)
		self._doubleTimeEvent = nil
	end
    controller:openMainWindow(false)
end
