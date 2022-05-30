-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
-- [文件功能：战斗结算失败界面]
-- <br/>Create: 2017-2-19
-- --------------------------------------------------------------------
BattleFailView = BattleFailView or BaseClass(BaseView)

function BattleFailView:__init(fight_type,result,data)
	self.result = result
	self.data = data
	self.x = 100
	self.role_vo = RoleController:getInstance():getRoleVo()
	self.fight_type = fight_type
	self.is_running = false
	self.layout_name = "battle/battle_fail_view"
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.win_type = WinType.Tips
	self.effect_list = {}
	self.res_list = {
		{ path = PathTool.getPlistImgForDownLoad("battlefail", "battlefail"), type = ResourcesType.plist },
	}
end

function BattleFailView:openRootWnd()
	--BaseView.open(self)
end
--初始化
function BattleFailView:open_callback()
	AudioManager:getInstance():playMusic(AudioManager.AUDIO_TYPE.BATTLE, "b_lose", false)

	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())
	self.source_container = self.root_wnd:getChildByName("container")
	--self.source_container:setScale(display.getMaxScale())
	self.title_container = self.source_container:getChildByName("title_container")
	self.title_width = self.title_container:getContentSize().width
	self.title_height = self.title_container:getContentSize().height
	
	self.source_container:runAction(cc.Sequence:create(cc.FadeIn:create(0.2),cc.CallFunc:create(function ()
		self:createButton()
		self.is_running = false
	end)))

	if self.fight_type == BattleConst.Fight_Type.Adventrue then
		local num = AdventureController:getInstance():getUiModel():getFightSkipCount()
		local str = string.format(TI18N("已连续挑战%s场"),num)
		createLabel(24, Config.ColorData.data_new_color4[12], nil, 360, 60, str,self.source_container, nil, cc.p(0.5,0.5))

	end

	self.fight_text = createLabel(24, Config.ColorData.data_new_color4[6], nil, 360, 410, "",self.source_container, nil, cc.p(0.5,0.5))

    local name = Config.BattleBgData.data_fight_name[self.fight_type]
    if name then
        self.fight_text:setString(TI18N("当前战斗：")..name)
    end

    self.comfirm_btn = createButton(self.source_container,TI18N("确定"), 620, 580, cc.size(162, 62), PathTool.getResFrame("common", "common_1017"), 24, Config.ColorData.data_color4[1])
    self.comfirm_btn:setPosition(self.source_container:getContentSize().width / 2 - 230, -80)
    self.comfirm_btn:setRichText(string.format(TI18N("<div fontColor=#ffffff fontsize=24 shadow=0,-2,2,%s>确定</div>"), Config.ColorData.data_new_color_str[3]))
    -- self.comfirm_btn:enableOutline(Config.ColorData.data_color4[264], 2)
    self.comfirm_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            BattleController:getInstance():openFailFinishView(false,self.fight_type)
        end
	end)

	-- self.comfirm_btn = createButton(self.source_container, TI18N("确定"),self.source_container:getContentSize().width/2,-80,cc.size(162, 62), PathTool.getResFrame("common", "common_1017"), 24)
	-- self.comfirm_btn:setRichText(TI18N("<div fontColor=#ffffff fontsize=24 outline=1,#6C2B00>确定</div>"))
	
	self.help_btn = createButton(self.source_container, TI18N("变强小助手"),self.source_container:getContentSize().width/2, -80,cc.size(162, 62), PathTool.getResFrame("common", "common_1017"), 24)
	self.help_btn:setRichText(string.format(TI18N("<div fontColor=#ffffff fontsize=24 shadow=0,-2,2,%s>变强小助手</div>"), Config.ColorData.data_new_color_str[3]))

	local back_limit_lv = Config.BattleBgData.data_back_limit[self.fight_type] or 0
	local role_vo = RoleController:getInstance():getRoleVo()
	if role_vo and back_limit_lv <= role_vo.lev then
		self.cancel_btn = createButton(self.source_container,TI18N("返回玩法"), 620, 580, cc.size(162, 62), PathTool.getResFrame("common", "common_1017"), 24, Config.ColorData.data_color4[1])
		self.cancel_btn:setPosition(self.source_container:getContentSize().width / 2 + 230, -80)
		self.cancel_btn:setRichText(string.format(TI18N("<div fontColor=#ffffff fontsize=24 shadow=0,-2,2,%s>返回玩法</div>"), Config.ColorData.data_new_color_str[3]))
		-- self.cancel_btn:enableOutline(Config.ColorData.data_color4[263], 2)
		self.cancel_btn:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				BattleResultReturnMgr:returnByFightType(self.fight_type) --先
				BattleController:getInstance():openFailFinishView(false,self.fight_type)
			end
		end)
	else
		self.help_btn:setPositionX(self.source_container:getContentSize().width / 2 + 230)
	end

	self.time_label = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(self.source_container:getContentSize().width / 2 + 5,20), nil, nil, 1000)
	self.time_label:setString(TI18N("10秒后关闭"))
	self.source_container:addChild(self.time_label)

	self.harm_btn = self.source_container:getChildByName("harm_btn")
	if self.data and (self.data.hurt_statistics or self.data.all_hurt_statistics) then
		self.harm_btn:setVisible(true)
	else
		self.harm_btn:setVisible(false)
	end
	self.harm_btn:getChildByName("harm_lab"):setString(TI18N("数据统计"))

	self:handleEffect(true)
	-- self:updateHelpBtn()
	self:updateBattleAgainBtn()
end

function BattleFailView:updateHelpBtn(temp_max_dun_id)
	-- local data = BattleDramaController:getInstance():getModel():getDramaData()
	-- local max_dun_id = Config.FunctionData.data_base[MainuiConst.btn_index.assistant].activate[1][2]
	-- if data then
	-- 	local dungeon_max_dun_id = temp_max_dun_id or data.max_dun_id
	-- 	if dungeon_max_dun_id and dungeon_max_dun_id >= max_dun_id then
			-- self.help_btn:setVisible(true)
			-- self.help_btn:setPosition(self.source_container:getContentSize().width / 2 - 180,-80)
			-- self.comfirm_btn:setPosition(self.source_container:getContentSize().width / 2 + 180,-80)
	-- 	else
	-- 		self.comfirm_btn:setPosition(self.source_container:getContentSize().width / 2,-80)
	-- 	end
	-- end
end

-- 再次挑战
function BattleFailView:updateBattleAgainBtn(  )
	if self.fight_type == BattleConst.Fight_Type.Adventrue then
		if self.data.adventure_end_hp and self.data.adventure_end_hp > 0 then
			-- 剩余血量大于0，则显示剩余血量
			if not self.left_hp_txt then
				self.left_hp_txt = createRichLabel(22, Config.ColorData.data_new_color4[11], cc.p(0.5, 0.5), cc.p(self.source_container:getContentSize().width/2, 95))
				self.source_container:addChild(self.left_hp_txt)
			end
			self.left_hp_txt:setString(string.format(TI18N("出战宝可梦剩余血量为:<div fontColor=%s>%d%%</div>"), Config.ColorData.data_new_color_str[12], self.data.adventure_end_hp/10))

			-- 剩余血量大于一定值，则显示再次挑战按钮
			local appear_cfg = Config.AdventureData.data_adventure_const["botton_appear"]
			if self.data.room_id and appear_cfg and appear_cfg.val <= (self.data.adventure_end_hp/10) then
				if not self.battle_again_btn then
					self.battle_again_btn = createButton(self.source_container, TI18N("再次挑战"),self.source_container:getContentSize().width/2,-80,cc.size(162, 62), PathTool.getResFrame("common", "common_1017"), 24)
					self.battle_again_btn:setRichText(string.format(TI18N("<div fontColor=#ffffff fontsize=24 shadow=0,-2,2,%s>再次挑战</div>"), Config.ColorData.data_new_color_str[3]))
				end
			end
			self.help_btn:setPosition(self.source_container:getContentSize().width / 2 - 230,-80)
			self.comfirm_btn:setPosition(self.source_container:getContentSize().width / 2 + 230,-80)
			if self.cancel_btn then
				self.cancel_btn:setVisible(false)
			end
		end
	end
end

function BattleFailView:createButton()
	self.desc_fail_label = createRichLabel(20, Config.ColorData.data_new_color4[1], cc.p(0.5,0.5), cc.p(SCREEN_WIDTH/2,345), 15)
	self.desc_fail_label:setString(string.format(TI18N("<div outline=2,%s>     失败，不要气馁，\n可通过以下方式提升实力！</div>"), Config.ColorData.data_new_color_str[6]))
	self.source_container:addChild(self.desc_fail_label)
	local btn_list = {}
	local base_data = BattleDramaController:getInstance():getModel():getDramaData()

	if Config.BattleActData.data_get_fail_data and base_data then
		local max_dun_id = base_data.max_dun_id
		for i, v in ipairs(Config.BattleActData.data_get_fail_data) do
			if v.open_dungeon <= max_dun_id then
				table.insert(btn_list,v)
			end
		end
	end
	if self.items_list == nil then
		self.items_list = {}
	end
	self:clearItems()
	local start_x = 110
	local offset_x = 65
	local con_size = cc.size(105, 100)
	local len = math.min(4, #btn_list)
	local size = self.source_container:getContentSize()
	for i = 1, len do
		local config  = btn_list[i]
		if config then
			if not self.items_list[i] then
				self.items_list[i] = {}
				local container = ccui.Layout:create()
				container:setContentSize(con_size) 
				container:setAnchorPoint(cc.p(0.5,0.5))
				self.source_container:addChild(container)

				local btn = CustomButton.New(container, PathTool.getResFrame("battlefail", config.icon),nil,nil,LOADTEXT_TYPE_PLIST)
				btn:setPosition(con_size.width/2, con_size.height/2)
				local label = createRichLabel(22, cc.c3b(255, 238, 209), cc.p(0.5, 0), cc.p(con_size.width/2, 0))
				container:addChild(label)
				label:setString(string.format("<div fontcolor=ffeed1 outline=2,#301407>%s</div>", config.icon_name))
				container.btn = btn
				container.label = label
				self.items_list[i] = container
			end
			local pos_x = start_x + (i-1)*(con_size.width+offset_x)
			self.items_list[i]:setPosition(pos_x, size.height/2-40)
			local go_btn = self.items_list[i].btn
			local btn_label = self.items_list[i].label
			if go_btn then
				go_btn:setVisible(true)
				go_btn:addTouchEventListener(function(sender, event_type)
					if event_type == ccui.TouchEventType.ended then
						self:openPanelByConfig(config)
						self:close()
					end
				end)
			end
			if btn_label then
				btn_label:setString(string.format("<div fontcolor=ffeed1 outline=2,#301407>%s</div>", config.icon_name))
			end
		end
	end
	self:updateTimer()
end

function BattleFailView:updateTimer()
    local time = 10
    local call_back = function()
        time = time - 1
        local new_time = math.ceil(time)
        local str = new_time .. TI18N('秒后关闭')
        if self.time_label and not tolua.isnull(self.time_label) then
            self.time_label:setString(str)
        end
        if new_time <= 0 then
            BattleController:getInstance():openFailFinishView(false, self.fight_type)
        end
    end
    GlobalTimeTicket:getInstance():add(call_back, 1, 0, 'fail_result_timer' .. self.fight_type)
end


function BattleFailView:handleEffect(status)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
	else
		if not tolua.isnull(self.title_container) and self.play_effect == nil then
			self.play_effect = createEffectSpine(PathTool.getEffectRes(104), cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, PlayerAction.action)
			self.title_container:addChild(self.play_effect, 1)
		end
	end
end

function BattleFailView:register_event()
	if self.help_btn then
		self.help_btn:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				BattleController:getInstance():openFailFinishView(false, self.fight_type)
				StrongerController:getInstance():openMainWin(true)
			end
		end)
	end
	if self.battle_again_btn then
		self.battle_again_btn:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				self:_onClickBattleAgainBtn()
			end
		end)
	end
	registerButtonEventListener(self.harm_btn, handler(self, self._onClickHarmBtn), true)
end

function BattleFailView:_onClickHarmBtn( )
	if self.data and next(self.data) ~= nil then
		if self.data.hurt_statistics then
			local setting = {}
        	setting.fight_type = self.fight_type
			BattleController:getInstance():openBattleHarmInfoView(true, self.data, setting)
		elseif self.data.all_hurt_statistics and self.fight_type == BattleConst.Fight_Type.HeavenWar then -- 天界副本战败
			table.sort( self.data.all_hurt_statistics, function(a, b) return a.type < b.type end)
	        local role_vo = RoleController:getInstance():getRoleVo()
	        local atk_name = role_vo.name
	        local is_boss = HeavenController:getInstance():getModel():getCustomsIsBossType(self.data.id, self.data.order_id)
	        for i,v in ipairs(self.data.all_hurt_statistics) do
	            if is_boss then
	                v.atk_name  = string.format("%s(队伍%s)",atk_name, v.a_round)
	                v.target_role_name  = string.format("%s(队伍%s)",v.target_role_name, v.b_round)
	            else
	                v.atk_name  = atk_name
	            end
	        end
	        BattleController:getInstance():openBattleHarmInfoView(true, self.data.all_hurt_statistics)
		end
	end
end

function BattleFailView:_onClickBattleAgainBtn(  )
	if self.fight_type == BattleConst.Fight_Type.Adventrue and self.data.room_id then
		local ext_list = {}
		for k,v in pairs(self.data.ext_list) do
			local object = {}
			object.type = v.ext_type
			object.val = v.ext_val
			table.insert(ext_list, object)
		end
		AdventureController:getInstance():send20620(self.data.room_id, AdventureEvenHandleType.handle, ext_list)
	end
	BattleController:getInstance():openFailFinishView(false,self.fight_type)
end

function BattleFailView:clearItems()
	if self.items_list then
		for k, v in pairs(self.items_list) do
			if v.btn and v.label and(not tolua.isnull(v.label)) then
				v.btn:setVisible(false)
				v.label:setVisible(false)
			end
		end
	end
end
function BattleFailView:openPanelByConfig(config)
	if config.val_key == BattleConst.JumpType.Summon then
		StrongerController:getInstance():clickCallBack(120)
	elseif config.val_key == BattleConst.JumpType.HeroBag then
		StrongerController:getInstance():clickCallBack(200)
	elseif config.val_key == BattleConst.JumpType.Forge then
		StrongerController:getInstance():clickCallBack(154)
	elseif config.val_key == BattleConst.JumpType.Hallows then
		StrongerController:getInstance():clickCallBack(201)
	end
end

function BattleFailView:close_callback()
	-- 联盟战战败有奖励需要展示
	if self.fight_type == BattleConst.Fight_Type.GuildWar and self.data and self.data.item_rewards then
		local items = {}
        for i,v in pairs(self.data.item_rewards) do
            items[i] = {}
            items[i].bid = v.bid
            items[i].num = v.num
        end
        MainuiController:getInstance():openGetItemView(true, items, 0, {is_backpack = true})
	end

	BattleController:getInstance():openFailFinishView(false, self.fight_type)
	GlobalTimeTicket:getInstance():remove('fail_result_timer' .. self.fight_type)
	GlobalEvent:getInstance():Fire(BattleEvent.CLOSE_RESULT_VIEW,self.fight_type)

	self:handleEffect(false)
	if BattleController:getInstance():getModel():getBattleScene() and BattleController:getInstance():getIsSameBattleType(self.fight_type) then
		local data = {combat_type = self.fight_type,result = self.result}
		BattleController:getInstance():getModel():result(data, self.is_leave_self)
	end
end
