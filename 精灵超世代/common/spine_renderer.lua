--
-- Author: mengjiabin
-- Date: 2016-12-20 20:03:44
--
SpineRenderer = SpineRenderer or BaseClass()
local size = cc.Director:getInstance():getVisibleSize()
local table_insert = table.insert
local table_remove = table.remove

--@ spine_scale2 仅模型的缩放比例 (替换大资源时间段用) --by lwc
function SpineRenderer:__init(screen_pos, spine_name, scale, is_async, anima_name, career, group, spine_type, is_boss, unit_is_boss, spine_scale2)
	local spine_scale = BattleController:getInstance():getModel():getBattleSpineScale()
	self.scale = scale or spine_scale or 1
    self.spine_scale2 = spine_scale2 or 1
	self.is_ScaleX = 1
	self.spine_type = spine_type
	self.rev_value = 1
	self.active = true
	self.hit = false
	self.id = autoId()
	self.screen_pos = screen_pos
	self.action_name = ""					-- 缓存上一个动作名字
	self.action_res = ""					-- 缓存上一个动作资源

	self.is_in_action = false
	self.cache_act_list = {}

	-- 根节点
	self.root = cc.NodeGrid:create()
	self.root:setCascadeOpacityEnabled(true)
	self.root:setPosition(screen_pos)
	self.root:setAnchorPoint(0.5, 0.5)

	-- 模型节点
	self.spine_root = ccui.Widget:create()
	self.spine_root:setCascadeOpacityEnabled(true)
	self.spine_root:setAnchorPoint(0.5, 0.5)
    self.spine_root:setScale(self.spine_scale2)

	-- 血条节点
	self.hp_root = ccui.Widget:create()
	self.hp_root:setCascadeOpacityEnabled(true)

	-- 上层特效节点
	self.top_effect_root = ccui.Widget:create()
	self.top_effect_root:setCascadeOpacityEnabled(true)
	self.top_effect_root:setAnchorPoint(0.5, 0.5)

	-- 下层特效节点
	self.bottom_effect_root = ccui.Widget:create()
	self.bottom_effect_root:setCascadeOpacityEnabled(true)
	self.bottom_effect_root:setAnchorPoint(0.5, 0.5)

	self.buff_list_item = {}				-- buff当前显示对象
	self.buff_pool_item = {}				-- buff当前缓存池
	self.buff_id_to_icon = {}				-- buff的id对应的资源key
	self.buff_list_data = {}				-- buff的真实数据,key是资源id

	self.is_boss = is_boss
	self.effect_list = {}
	self.career = career
	self.height = 0
	self.buff_icon_height = 0
	self.isRun = false
	self.is_call_ready = false
	self.body_spine_name = spine_name		-- 当前资源名
	self.base_action_name = anima_name		-- 初始化动作名
	self.group = group
	self.dir = 2
	self.role_num = 0
	self.ui_hp_width = nil
	self.ui_boss_width = nil
	self.tiem_scale = 2
	self.unit_is_boss = unit_is_boss or 0
	self.passive_skill_list = {}
	self.passive_skill_pool = {}

	if spine_name ~= nil and self.spine_type ~= BattleObjectType.Elfin then
		self:removeBody()
        self.spine = createArmature(spine_name, anima_name)
		self.spine:setAnchorPoint(0.5, 0)
		self.spine:setAnimation(0, anima_name, true)
		self.spine_root:addChild(self.spine)
		if self.spine_type == BattleObjectType.Hallows then
			self.spine:setLocalZOrder(1)
		end
	end
	self.root:addChild(self.bottom_effect_root, 1)
	self.root:addChild(self.spine_root, 2)
	self.root:addChild(self.hp_root,3)
	self.root:addChild(self.top_effect_root, 99)
	
	self.root:setScale(self.scale)
	self.role_height = 120 * self.scale       -- 身高180
	self.is_init = false
    self:createHallowsStage()
    --self:createElfinList() -- 解锁了才显示精灵
end

function SpineRenderer:showSpineModel(visible)
	self.spine_root:setVisible(visible)
	self.hp_root:setVisible(visible)
	self.top_effect_root:setVisible(visible)
	self.bottom_effect_root:setVisible(visible)
end

function SpineRenderer:setVisible(visible)
	self.root:setVisible(visible)
end

--- 处理鬼魂状态
function SpineRenderer:handleGuiHunStatus(status)
	if status == true then
		if self.ghost == nil then
			self.ghost = createSpineByName("H69001", PlayerAction.battle_stand, self.root)
			self.ghost:setAnimation(0, PlayerAction.battle_stand, true)
			self.ghost:setScaleX(self.rev_value)
			self.ghost:setPositionY(self.role_height * 0.5)
		end
	else
		if not tolua.isnull(self.ghost) then
			self.ghost:removeFromParent()
			self.ghost = nil
		end
	end
end

--==============================--
--desc:播放被动技能效果
--time:2018-12-03 10:08:57
--@msg:
--@callback:
--@return 
--==============================--
function SpineRenderer:playPassiveSkillName(msg, callback)
	if tolua.isnull(self.root) then return end
	local skill_item = nil
	if self.play_delaytime == nil then
		self.play_delaytime = 0
	end
	local delay_time = (self.play_delaytime % 3) * 0.3
	local delay = cc.DelayTime:create(delay_time)
	self.play_delaytime = self.play_delaytime + 1
	if #self.passive_skill_pool > 0 then
		skill_item  = table_remove(self.passive_skill_pool, 1)
	else
		skill_item = createSprite(PathTool.getResFrame("battle", "battle_buff_name_bg"), 0, self.role_height*0.5, self.root, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 99) 
		skill_item:setCascadeOpacityEnabled(true) 
		local tips = createLabel(20, 217, 218, skill_item:getContentSize().width / 2, skill_item:getContentSize().height / 2, "", skill_item, nil, cc.p(0.5, 0.5))
		skill_item:setOpacity(100)
		skill_item:setVisible(false)
		skill_item:setScale(0.6)
		skill_item.msg = tips
	end
	doStopAllActions(skill_item)
	skill_item.msg:setString(msg);
	skill_item:setPosition(0, self.role_height*0.5)
	table_insert(self.passive_skill_list, skill_item);

	local call_back_fun = cc.CallFunc:create(function() 
		callback()
	end)
	local moveBy1 = cc.MoveBy:create(0.4, cc.p(0, 50))
	local moveBy2 = cc.MoveBy:create(1.1, cc.p(0, 75));
	local over_fun = cc.CallFunc:create(function()
		if not tolua.isnull(self.root) then
			for i,v in ipairs(self.passive_skill_list) do
				if v == skill_item then
					table_insert(self.passive_skill_pool, skill_item);
					table_remove(self.passive_skill_list, i);
					skill_item:setVisible(false)
					if self.play_delaytime and self.play_delaytime > 0 then
						self.play_delaytime = self.play_delaytime - 1
					end
					break
				end
			end
		end
	end)
	skill_item:runAction(cc.Sequence:create(delay, cc.CallFunc:create(function()
			skill_item:setVisible(true)
		end),  call_back_fun, cc.Spawn:create(cc.ScaleTo:create(0.4, 1.2), moveBy1, cc.FadeIn:create(0.4)),
			cc.Spawn:create(cc.ScaleTo:create(1.1, 0.9), cc.FadeTo:create(1.1, 100), moveBy2),
			cc.FadeOut:create(0.2), over_fun
		)
	)
end

--- SpineRenderer:createHallowsStage 创建神器单位的台子
function SpineRenderer:createHallowsStage()
	if self.spine_type ~= BattleObjectType.Hallows then return end
    self.hallows_round_info = createCSBNote(PathTool.getTargetCSB("battle/battle_hallow_node"))
    self.hallows_round_info:setScale(0.8)
    self.root:addChild(self.hallows_round_info)
    self.hallows_round_info:setPosition(0, 0)
    self.hallows_round_info:setAnchorPoint(0.5, 0)
    self.hallows_round_info:setVisible(true)

    local container = self.hallows_round_info:getChildByName("container")
    local progress_res = PathTool.getResFrame("battle", "battle_10040")
    if self.group == BattleGroupTypeConf.TYPE_GROUP_ENEMY then
    	--progress_res = PathTool.getResFrame("battle", "battle_10036")
    end
    self.hallows_progress = cc.ProgressTimer:create(createSprite(progress_res, 110, 105, nil, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST))
    self.hallows_progress:setMidpoint(cc.p(0, 0))
    self.hallows_progress:setBarChangeRate(cc.p(0, 1))
    self.hallows_progress:setPosition(10, 18)
    self.hallows_progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    if self.group == BattleGroupTypeConf.TYPE_GROUP_ENEMY then
    	--self.hallows_progress:setScaleX(-1)
    end
    container:addChild(self.hallows_progress)
end

--- SpineRenderer:showHallowsState 显示神器当前状态包括回合数
-- @param flag Describe the parameter
function SpineRenderer:showHallowsState(flag)
    if self.hallows_round_info then
        self.hallows_round_info:setVisible(flag)
    end
    if self.hallows_progress and flag then
        self:setHallowsRound(0)
    end
end

--- SpineRenderer:setHallowsRound 更新神器的回合数
-- @param round     Describe the parameter
-- @param max_round Describe the parameter
function SpineRenderer:setHallowsRound(round, max_round) 
    if not self.hallows_round_max then
        self.hallows_round_max = max_round or 3
    end
    if not self.hallows_progress then return end
    --self.hallows_progress:setPercentage(((round or 0) * 100 / self.hallows_round_max) )
    -- 由于进度为不规则形状，这里进度不能按照真实百分比计算。只能写死
    round = round or 0
    local percent = 0
    if round == 1 then
    	percent = 17.8
    elseif round == 2 then
    	percent = 53.4
    elseif round == 3 then
    	percent = 100
    end
    self.hallows_progress:setPercentage(percent)
end

-- 创建精灵显示
function SpineRenderer:createElfinList(  )
	if self.spine_type ~= BattleObjectType.Elfin then return end
    self.elfin_node = createCSBNote(PathTool.getTargetCSB("battle/battle_elfin_node"))
    if not self.elfin_node then return end
    self.elfin_node:setScale(0.8)
    self.spine_root:addChild(self.elfin_node)
    self.elfin_node:setPosition(-5, 3)
    self.elfin_node:setAnchorPoint(0.5, 0)
    self.elfin_node:setVisible(true)

    local container = self.elfin_node:getChildByName("container")

    local elfin_is_open = ElfinController:getInstance():getModel():checkElfinIsOpen(true)
    self.elfin_list = {}
    for i=1,4 do
    	local elfin_object = {}
    	local elfin_panel = container:getChildByName("elfin_" .. i)

    	if not elfin_is_open then
    		registerButtonEventListener(elfin_panel, handler(self, self.onClickElfinIcon), true)
    	end

    	elfin_object.elfin_panel = elfin_panel
    	elfin_object.mask_icon = elfin_panel:getChildByName("mask_icon")
    	elfin_object.effect_icon = elfin_panel:getChildByName("effect_icon")
    	elfin_object.effect_icon:setVisible(false)
    	elfin_object.cd_time_txt = elfin_panel:getChildByName("cd_time_txt")
    	elfin_object.lock_txt = elfin_panel:getChildByName("lock_txt")
    	elfin_object.lock_txt:setString(TI18N("锁"))
    	--local icon_k = elfin_panel:getChildByName("icon_k")
    	--icon_k:setLocalZOrder(2)
    	table_insert(self.elfin_list, elfin_object)
    	if self.rev_value then
    		elfin_object.cd_time_txt:setScaleX(self.rev_value)
    		elfin_object.lock_txt:setScaleX(self.rev_value)
    	end
    	elfin_object.mask_icon:setLocalZOrder(2)
    	elfin_object.cd_time_txt:setLocalZOrder(2)
    	elfin_object.lock_txt:setLocalZOrder(2)
    	elfin_object.mask_icon:setVisible(false)
    	elfin_object.cd_time_txt:setVisible(false)
    	elfin_object.lock_txt:setVisible(true)
    end
end

-- 点击精灵图标
function SpineRenderer:onClickElfinIcon(  )
	ElfinController:getInstance():getModel():checkElfinIsOpen()
end

-- 显示精灵的技能图标
function SpineRenderer:showElfinSkillIcon( data, skills )
	if not self.elfin_node then
		self:createElfinList()
	end
	self.elfin_node:setVisible(true)
	if not self.elfin_list then return end
	self.all_elfin_data = data or {}
	if next(self.all_elfin_data) ~= nil then
		for i=1,4 do
			local elfin_object = self.elfin_list[i]
            -- local lock_item_bid = ElfinController:getInstance():getModel():getElfinItemByPos(i)
			local elfin_data = self:getElfinDataByPos(i)
			if elfin_data then
                local item_bid = elfin_data.item_bid or 0
				if item_bid == 0 then -- 解锁了，但是未布置精灵
					if elfin_object.clipNode then
						elfin_object.clipNode:setVisible(false)
					end
			    	elfin_object.mask_icon:setVisible(false)
			    	elfin_object.cd_time_txt:setVisible(false)
			    	elfin_object.lock_txt:setVisible(false)
				else
					local elfin_cfg = Config.SpriteData.data_elfin_data(item_bid)
					if elfin_cfg and elfin_cfg.skill then
						local skill_cfg = Config.SkillData.data_get_skill(elfin_cfg.skill)
						if skill_cfg then
							elfin_object.skill_bid = elfin_cfg.skill -- 记录一下技能bid,用于更新技能cd时间
							local skill_res = PathTool.getSkillRes(skill_cfg.icon)
							if not elfin_object.clipNode then
								elfin_object.mask_bg = createSprite(PathTool.getResFrame("battle", "battle_10043"), 29, 29.5, nil, cc.p(0.5, 0.5))
								elfin_object.clipNode = cc.ClippingNode:create(elfin_object.mask_bg)
								elfin_object.clipNode:setAnchorPoint(cc.p(0.5,0.5))
								elfin_object.clipNode:setContentSize(cc.size(58, 59))
								elfin_object.clipNode:setCascadeOpacityEnabled(true)
								elfin_object.clipNode:setPosition(29, 29.5)
								elfin_object.clipNode:setAlphaThreshold(0)
								elfin_object.elfin_panel:addChild(elfin_object.clipNode, 1)
								
								elfin_object.elfin_icon = createImage(elfin_object.clipNode, skill_res, 29, 29.5, cc.p(0.5, 0.5), false)
								elfin_object.elfin_icon:setScale(0.45)
							elseif elfin_object.elfin_icon then
								elfin_object.elfin_icon:loadTexture(skill_res, LOADTEXT_TYPE)
							end
						end
					end

					if elfin_object.clipNode then
						elfin_object.clipNode:setVisible(true)
					end
			    	elfin_object.mask_icon:setVisible(false)
			    	elfin_object.cd_time_txt:setVisible(true)
			    	elfin_object.cd_time_txt:setString("")
			    	elfin_object.lock_txt:setVisible(false)
				end
			else -- 未解锁
				if elfin_object.clipNode then
					elfin_object.clipNode:setVisible(false)
				end
		    	elfin_object.mask_icon:setVisible(false)
		    	elfin_object.cd_time_txt:setVisible(false)
		    	elfin_object.lock_txt:setVisible(true)
			end
		end

		if skills then
			self:updateElfinSkillState(skills)
		end
	else -- 全都未解锁
		if self.elfin_node then
			self.elfin_node:setVisible(false)
		end
		-- for k,elfin_object in pairs(self.elfin_list) do
		-- 	if elfin_object.clipNode then
		-- 		elfin_object.clipNode:setVisible(false)
		-- 	end
	    -- 	elfin_object.mask_icon:setVisible(false)
	    -- 	elfin_object.cd_time_txt:setVisible(false)
	    -- 	elfin_object.lock_txt:setVisible(true)
		-- end
	end
end

-- 更新精灵技能CD时间
function SpineRenderer:updateElfinSkillState( data )
	if not self.elfin_node then
		self:createElfinList()
	end
	self.elfin_node:setVisible(true)
	if not self.elfin_list then return end
	data = data or {}
	for _,v in pairs(data) do
		local skill_bid = v.skill_bid
		local end_round = v.end_round
		for k,elfin_object in pairs(self.elfin_list) do
			if elfin_object.skill_bid == skill_bid then
				local cur_round = BattleController:getInstance():getModel():getFightActionCount()
				local cd_round = end_round - cur_round
				if cd_round <= 0 then -- 无CD时间，当前回合播放
					elfin_object.mask_icon:setVisible(false)
		    		elfin_object.cd_time_txt:setVisible(false)
				else
					elfin_object.cd_time_txt:setString(cd_round)
					elfin_object.mask_icon:setVisible(true)
		    		elfin_object.cd_time_txt:setVisible(true)
				end
				break
			end
		end
	end
end

-- 根据技能id显示对应精灵技能的播放效果
function SpineRenderer:showElfinSkillIconAni( skill_bid )
	if not self.elfin_node then
		self:createElfinList()
	end
	self.elfin_node:setVisible(true)
	if not self.elfin_list then
		return
	end
	local is_have = false
	for k,elfin_object in pairs(self.elfin_list) do
		if elfin_object.skill_bid == skill_bid then
			is_have = true
			elfin_object.effect_icon:setVisible(true)
			local sequence = cc.Sequence:create(cc.FadeOut:create(0.3), cc.FadeIn:create(0.3))
			elfin_object.effect_icon:runAction(cc.RepeatForever:create(sequence))
			local act_1 = cc.DelayTime:create(2)
			local act_2 = cc.CallFunc:create(function (  )
				elfin_object.effect_icon:stopAllActions()
				elfin_object.effect_icon:setVisible(false)
			end)
			elfin_object.elfin_panel:runAction(cc.Sequence:create(act_1, act_2))
			break
		end
	end
end

-- 根据位置获取精灵数据
function SpineRenderer:getElfinDataByPos( pos )
	if not self.all_elfin_data then return end
	for k,v in pairs(self.all_elfin_data) do
		if v.pos == pos then
			return v
		end
	end
end

function SpineRenderer:setColor(r, g, b)
	if self.spine then
		self.spine:setColor(cc.c3b(r, g, b))
	end
end

function SpineRenderer:setOpacity(opacity)
	self.spine_root:setOpacity(opacity)
end

--- SpineRenderer:setupUI 初始化战斗单位节点附属的一些ui
-- @param group       战斗单位的组
-- @param lev         等级
-- @param camp_type   阵营
-- @param setting
-- setting.crystal  原力水晶上阵英雄的等级 标志 是否原力水晶英雄 0:表示不是  >0 : 表示是     
function SpineRenderer:setupUI(group, lev, camp_type, setting)
	local shadow_scale = 1
	local lev =  lev or 0
	local height = self.role_height + 20
    local setting = setting or {}
    local crystal = setting.crystal or 0
	self.height = height
	self.model_x_fix = self.model_x_fix
	self.model_y_fix = self.model_y_fix
	
	-- if self.shadow == nil and self.spine_type ~= BattleObjectType.Hallows and self.spine_type ~= BattleObjectType.Elfin then
	-- 	self.shadow = createSprite(PathTool.getResFrame("common", "common_30009"), 0, 0, self.spine_root, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, -2)
	-- 	self.shadow:setScaleX(shadow_scale)
	-- end
	
	if not BattleController:getInstance():getIsNoramalBattle() or group == BattleGroupTypeConf.TYPE_GROUP_ENEMY then
		if self.ui_hp == nil and self.spine_type ~= BattleObjectType.Hallows and self.spine_type ~= BattleObjectType.Elfin then
			self.is_init = true

			self:updateNormalHpUI(self.hp_root,59,6,group)	
			self.hp_root:setPosition(0, height + 6)

			if self.is_boss == TRUE then
				self:showBossEffect(true)
			else
				self:showBossEffect(false)
			end
			-- 真战斗才需要显示这个
			if not BattleController:getInstance():getIsNoramalBattle() then
				local res = PathTool.getResFrame('battle', 'battle_lev_bg')
				local career_bg = createSprite(res,-18,8, self.hp_root, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
				career_bg:setCascadeOpacityEnabled(true)

				local type_frame = createSprite(PathTool.getHeroCampTypeIcon(camp_type),5,12, career_bg, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 3)
				type_frame:setScale(0.45)

				local lev_label = createWithSystemFont(lev,DEFAULT_FONT, 14)
				lev_label:setPosition(21, 15)
				lev_label:enableOutline(Config.ColorData.data_color4[2], 1)
				lev_label:setAnchorPoint(cc.p(0, 0.5))
                if crystal > 0  then
                    lev_label:setTextColor(cc.c4b(0x4B,0xFF,0xE8))
                end
				career_bg:addChild(lev_label, 99)
			end
		end
	end
end

--- 共鸣标志
function SpineRenderer:updateResonate(status)
	if status == TRUE then
		if self.resonate_icon == nil then
			self.resonate_icon = createSprite(PathTool.getResFrame("common", "common_2037"), 7, 11, self.hp_root, cc.p(0.5,0.5), LOADTEXT_TYPE_PLIST)
		end
	else
		if self.resonate_icon then
			self.resonate_icon:removeFromParent()
			self.resonate_icon = nil
		end
	end
end

--- 设置脚底光环,现在只针对BOSS有效
function SpineRenderer:showBossEffect(enable)
    if not tolua.isnull(self.boss_effect) then
        self.boss_effect:setVisible(false)
        self.boss_effect:removeFromParent()
        self.boss_effect = nil
    end
    if enable == true then
        local spine_tmp = createSpineByName(Config.EffectData.data_effect_info[244])
        self.boss_effect = spine_tmp
        self.boss_effect:setAnimation(0, PlayerAction.action, true)
        if self.height then
            spine_tmp:setPosition(0, 0)
        end
        spine_tmp:setVisible(enable)
        self.spine_root:addChild(spine_tmp, -1)
    end
end

function SpineRenderer:updateNormalHpUI(parent,width,height,group)
	if parent then
		local scale = 1
		if self.ui_hp_width then
			scale = width / self.ui_hp_width
		end

		local res = PathTool.getResFrame("battle", "battle_hp")
		if BattleController:getInstance():getModel():changeGroup(group) == BattleGroupTypeConf.TYPE_GROUP_ENEMY and BattleController:getInstance():getIsNoramalBattle() then
			res = PathTool.getResFrame("battle", "battle_enemy_bg")
		end
		local frame_res = PathTool.getResFrame("battle", "battle_hp_bg")
		local hp_frame = createScale9Sprite(frame_res, 0, 1, LOADTEXT_TYPE_PLIST, parent)
		hp_frame:setCapInsets(cc.rect(3, 4, 1, 1))
		hp_frame:setContentSize(cc.size(61, 8))
		self.ui_hp = ccui.LoadingBar:create()
		self.ui_hp:setCascadeOpacityEnabled(true)
		self.ui_hp:setScale9Enabled(true)
		self.ui_hp:setScaleX(scale)
		self.ui_hp:setAnchorPoint(cc.p(0, 0.5))
		self.ui_hp:setPosition(-30,1)
		self.ui_hp:setContentSize(cc.size(width,height))
		self.ui_hp:setCapInsets(cc.rect(2, 3, 1, 1))
		self.ui_hp:loadTexture(res, LOADTEXT_TYPE_PLIST)
		parent:addChild(self.ui_hp,3)
		
		self.ui_hp2 = cc.ProgressTimer:create(createSprite(PathTool.getResFrame("battle", "battle_injury_hp"), 0, 0, nil, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST))
		self.ui_hp2:setPosition(-30,1)
		self.ui_hp2:setOpacity(255)
		self.ui_hp2:setPercentage(100)
		self.ui_hp2:setScaleX(scale)
		self.ui_hp2:setType(cc.PROGRESS_TIMER_TYPE_BAR)
		self.ui_hp2:setBarChangeRate(cc.p(1, 0))
		self.ui_hp2:setAnchorPoint(cc.p(0,0.5))
		self.ui_hp2:setMidpoint(cc.p(0, 0))
		parent:addChild(self.ui_hp2,2)

		if BattleController:getInstance():getIsNoramalBattle() then
			self.ui_hp:setScale(scale * -1)
			self.ui_hp:setPosition(30, 1)
			self.ui_hp2:setScaleX(scale * -1)
			self.ui_hp2:setPosition(30, 1)
		end
		self.ui_hp:setName("hp_bar")
	end
end

function SpineRenderer:playFontMessage(msg, delay, is_png, parent, height_fix)
	height_fix = height_fix or 0
	local msg_word
	if is_png then
		msg_word = createSprite(msg)
	else
		msg_word = createWithSystemFont(msg, DEFAULT_FONT, 36)
	end
	local function deleteMsg()
		if not tolua.isnull(msg_word) then
			msg_word:setVisible(false)
			msg_word:runAction(cc.RemoveSelf:create())
		end
	end
	if not tolua.isnull(msg_word) then
		msg_word:setOpacity(0)
		if not is_png then
			msg_word:setColor(Config.ColorData.data_color3[227])
			msg_word:enableOutline(Config.ColorData.data_color3[228], 2)
			msg_word:setScale(0.6)
		end
		local fadeIn = cc.FadeIn:create(0.2)
		local move = cc.MoveBy:create(0.5, cc.p(0, 32))
		local hide = cc.Hide:create()
		if parent then
			parent:addChild(msg_word, BATTLE_VIEW_TOP)
			local pos = cc.p(self.root:getPosition())
			msg_word:setPosition(pos.x, pos.y + self.role_height + 10 + height_fix)
		else
			msg_word:setPosition(0, self.role_height + 10 + height_fix)
			self.spine_root:addChild(msg_word, 2)
		end
		local sp = cc.Spawn:create(move, fadeIn)
		if delay ~= nil then
			msg_word:runAction(cc.Sequence:create(cc.DelayTime:create(delay), sp, hide, cc.CallFunc:create(deleteMsg)))
		else
			msg_word:runAction(cc.Sequence:create(sp, hide, cc.CallFunc:create(deleteMsg)))
		end
	end
end

function SpineRenderer:reConnectUpdate(hp, hp_max)
	local per = math.min(math.max(100 * hp / hp_max, 0), 100)
	self:setHpPercent(per)
end

--==============================--
--desc:创建buff图标
--time:2018-12-19 10:02:45
--@return 
--==============================--
function SpineRenderer:createBuffItem(partner)
	local object = nil
	if #self.buff_pool_item > 0 then
		object = table.remove( self.buff_pool_item, 1)
		object.num = 0
		object.path = ""
	else
		local icon = createSprite(nil, 0, 0, partner, cc.p(0.5,0.5), nil, 5) 
		icon:setCascadeOpacityEnabled(true)

		local label = createLabel(14, Config.ColorData.data_color4[1], nil, 17, -2, 0, icon)
		label:setAnchorPoint(1, 0)
		label:enableOutline(Config.ColorData.data_color4[2], 1)
		object = {}
		object.icon = icon
		object.label = label
		object.path = ""
	end
	object.icon:setVisible(true)
	return object
end

--更新buff
function SpineRenderer:updataBuffList(data_list, object_name)
	if data_list == nil then return end
	local table_insert = table.insert
	self.buff_id_to_icon = {}
	self.buff_list_data = {}

	local temp_group_list = {} -- 用来标识组别
	for i,v in pairs(data_list) do
		local buff_cfg = Config.SkillData.data_get_buff[v.bid]
		if buff_cfg and buff_cfg.icon ~= nil and buff_cfg.icon ~= 0 then
			local res_id  = buff_cfg.icon
			if self.buff_list_data[res_id] == nil then
				self.buff_list_data[res_id] = {res_id=res_id, num=0, list={}}
			end
			if self.buff_list_data[res_id].num == 0 or (buff_cfg.join_type and buff_cfg.join_type ~= 3) then  -- buff类型不为覆盖共存，则必定+1
				self.buff_list_data[res_id].num = self.buff_list_data[res_id].num + 1
				if buff_cfg.group then
					temp_group_list[buff_cfg.group] = true
				end
			elseif buff_cfg.join_type and buff_cfg.join_type == 3 and buff_cfg.group and not temp_group_list[buff_cfg.group] then -- buff类型为覆盖共存，那么判断它所在的组是否加过1，加过则无需+1
				temp_group_list[buff_cfg.group] = true
				self.buff_list_data[res_id].num = self.buff_list_data[res_id].num + 1
			end
			table_insert(self.buff_list_data[res_id].list, v.id)			-- 储存buff唯一id,用于移除掉
			-- 对应的唯一id隐射icon
			self.buff_id_to_icon[v.id] = res_id
		end
	end
	local list = {}
	for k,v in pairs(self.buff_list_data) do
		table_insert(list, v)
	end
	table.sort(list,function(a,b)
		return  a.res_id < b.res_id
	end)

	local length = math.min(4, #list)
	for i = 1, length do
		local data = list[i]		-- res_id, num
		if data then
			local buff_object = self.buff_list_item[data.res_id]
			if buff_object == nil then
				buff_object = self:createBuffItem(self.hp_root) -- 这里有问题了.
				self.buff_list_item[data.res_id] = buff_object
			end
			buff_object.label:setString(data.num)			-- 显示相同buff的个数
			buff_object.icon:setPosition(-20 + ((i - 1)%3) * 22, -14-22 * math.floor((i-1)/3))

			local buff_icon_id = data.res_id
			local buff_path = PathTool.getBuffRes(buff_icon_id)
			if buff_object.path ~= buff_path then
				buff_object.path = buff_path 
				loadSpriteTexture(buff_object.icon, buff_path, LOADTEXT_TYPE) 	-- 加载特效资源
			end
		end
	end
end

--==============================--
--desc:移除指定的buff
--time:2018-12-19 10:39:17
--@buff_id:
--@return 
--==============================--
function SpineRenderer:removeBuffIcon(buff_id)
	if buff_id == nil then return end
	local res_id = self.buff_id_to_icon[buff_id]
	if res_id == nil then return end
	local buff_object = self.buff_list_item[res_id]
	if buff_object == nil then return end

	local buff_data = self.buff_list_data[res_id]
	if buff_data == nil then return end
	for i,v in ipairs(buff_data.list) do
		if v == buff_id then
			buff_data.num = buff_data.num - 1
			table.remove(buff_data.list, i)
			break
		end
	end
	if buff_data.num <= 0 then
		table.insert( self.buff_pool_item, buff_object )
		buff_object.icon:setVisible(false)
		self.buff_list_item[res_id] = nil
	else
		buff_object.label:setString(buff_data.num)
	end
end

--==============================--
--desc:清楚所有的目标
--time:2018-12-19 10:39:31
--@buff_list:
--@return 
--==============================--
function SpineRenderer:cleanAllBuffIcon()
	local table_insert = table.insert
	for k,v in pairs(self.buff_list_item) do
		if v.icon then
			v.icon:setVisible(false)
		end
		table_insert(self.buff_pool_item, v)
	end
	self.buff_list_item = {}
end

--设置血量
function SpineRenderer:setHpPercent(percent, is_init)
	if tolua.isnull(self.ui_hp) or tolua.isnull(self.ui_hp2) then return end
	self.ui_hp:setPercent(percent)
    if self.is_boss == TRUE then
        GlobalEvent:getInstance():Fire(BattleEvent.Battle_Boss_Hp_Event, {show_type = 3, percent = percent})
    end
	if self.ui_hp2:getPercentage() <= percent then
		self.ui_hp2:stopAllActions()
		self.ui_hp2:setPercentage(percent)
	else
		if is_init then
			self.ui_hp2:stopAllActions()
			self.ui_hp2:setPercentage(percent)
		else
			-- 当前动作目标血量值与percent一致，则忽略
			if self.target_percent and self.target_percent == percent then return end
			local act_time = BattleController:getInstance():getActTime("hp_effect_time")
			if (self.ui_hp2:getPercentage()-percent) >= 60 then -- 进度变化过大，则时间写死0.3秒
				act_time = 0.3
			end
			local act = cc.ProgressTo:create(act_time, percent)
			local call_back = function (  )
				self.target_percent = nil
			end
			self.target_percent = percent
			self.ui_hp2:stopAllActions()
			self.ui_hp2:runAction(cc.Sequence:create(act, cc.CallFunc:create(call_back)))
		end
	end
end

function SpineRenderer:showHpRoot(bool)
	if bool then
		if not tolua.isnull(self.hp_root) then
			self.hp_root:setVisible(true)
		end
		-- if not tolua.isnull(self.shadow) then
		-- 	self.shadow:setVisible(true)
		-- end
		if self.buff_list_item then	
			for _, v in pairs(self.buff_list_item) do
				if v.icon then
					v.icon:setVisible(true)
				end
			end
		end
	else
		if not tolua.isnull(self.hp_root) then
			self.hp_root:setVisible(false)
		end
		-- if not tolua.isnull(self.shadow) then
		-- 	self.shadow:setVisible(false)
		-- end
		if self.buff_list_item then	
			for _, v in pairs(self.buff_list_item) do
				if v and v.icon then
					v.icon:setVisible(false)
				end
			end
		end
	end
end

function SpineRenderer:setPosByGrid(grid_pos)
	local pos = gridPosToScreenPos(grid_pos)
	if not tolua.isnull(self.root) then
		self.root:setPosition(pos)
	end
end

function SpineRenderer:getPosition()
	return cc.p(self.root:getPosition())
end

function SpineRenderer:doRun()
	if self.isRun then return end
	self.isRun = true
	self:playActionOnce(PlayerAction.run)
end

function SpineRenderer:doStand(is_normal_battle)
	if not self.isRun then
		return
	end
	self.isRun = false
	self:playActionOnce(PlayerAction.battle_stand)
	if not is_normal_battle then
		BattleController:getInstance():getModel():addReadySum()
	else
		BattleController:getInstance():getNormalModel():addReadyNum()
	end
end

--- SpineRenderer:playActionOnce 改变模型或者动作
-- @param action_name 动作名
-- @param body_spine  模型资源名
function SpineRenderer:playActionOnce(action_name, body_spine)
	-- 这里应该有特殊判断,如果有坐骑的话,动作应该切换成 PlayerAction.sit
	action_name = action_name or PlayerAction.battle_stand --or   
	self.base_action_name = action_name
	self:_createSpineByName(action_name, body_spine or self.body_spine_name)
end

--[[	创建骨骼部分
	@desc 非角色类的模型,如果资源id一样不创建,角色类的模型,
]]
function SpineRenderer:_createSpineByName(action_name, body_spine)
	if body_spine ~= nil and body_spine ~= " " then
		self:createBody(body_spine, action_name)
	end
end

function SpineRenderer:createBody(spine_name, action)
	self:removeBody()
	self.body_spine_name = spine_name
	self.body_action_name = action
	self.spine = self:createSpine(self.body_spine_name, self.body_action_name,true)
	if not tolua.isnull(self.spine) then
		self.spine_root:addChild(self.spine)
	end
	if self.spine_type == BattleObjectType.Hallows then
		self.spine:setLocalZOrder(1)
	end
end

--统一创建模型了,方便做管理
function SpineRenderer:createSpine(spine_name,action_name,is_loop)
	local spine = createArmature(spine_name,action_name)
	if not tolua.isnull(spine) then
		spine:setAnimation(0, action_name, is_loop)
		-- spine:setToSetupPose()
	end
	return  spine
end

function SpineRenderer:createEncircleEffect(spine_name)
	if spine_name == nil or spine_name == "" then return end
	if self.encircle_effect_path == spine_name then return end
	if tolua.isnull(self.spine_root) then return end

	self.encircle_effect_path = spine_name
	if self.encircle_effect then
		self.encircle_effect:removeFromParent()
		self.encircle_effect = nil
	end
	self.encircle_effect = createSpineByName(spine_name) 
	self.encircle_effect:setAnimation(0, PlayerAction.action, true)
	self.spine_root:addChild(self.encircle_effect, 2)
    if self.spine_scale2 < 1 then
        self.encircle_effect:setScale(1/self.spine_scale2)
    end
end

function SpineRenderer:removeBody()
	if not tolua.isnull(self.spine) then
		self.spine:setVisible(false)
		self.spine:clearTracks()
		self.spine:removeFromParent()
	end
	self.spine = nil
	self.body_action_name = nil
	self.spine_body_name = nil
end

function SpineRenderer:addToLayer(layer, zOrder)
	if tolua.isnull(layer) or tolua.isnull(self.root) then return end
	local size = cc.Director:getInstance():getWinSize()
	if zOrder == nil then
		local screen_pos = cc.p(self.root:getPosition())
		layer:addChild(self.root, size.height - screen_pos.y)
	else
		layer:addChild(self.root, zOrder)
	end
end

function SpineRenderer:reverse(rev)
	if tolua.isnull(self.spine_root) then return end
	rev = rev or - 1
	if self.rev_value == rev then return end
	self.rev_value = rev
	self.spine_root:setScaleX(rev * self.spine_scale2)

	-- 如果是精灵的话,因为本身已经反转了
	if self.elfin_list and next(self.elfin_list) ~= nil then
		for k,object in pairs(self.elfin_list) do
    		object.cd_time_txt:setScaleX(rev)
    		object.lock_txt:setScaleX(rev)
		end
	end
end

--scale 放大倍数
--time1,2 放大和缩回所用时间，单位秒数
function SpineRenderer:setScale(scale, time1, time2, time3)
	-- body
	local scale_act = cc.ScaleTo:create(time1 / 2, scale)
	local delay = cc.DelayTime:create(time2)
	local scale_back = cc.ScaleTo:create(time3 / 2, self.scale)
	self:runAction(cc.Sequence:create(scale_act, delay, scale_back))
end

function SpineRenderer:release(bool, type)
	local time = (type == 0) and 0.1 or 0.5
	local fadeout
	if bool then
		fadeout = cc.Sequence:create(cc.CallFunc:create(function()
			if self.spine then
				self.spine:runAction(cc.FadeOut:create(time))
			end
		end),cc.DelayTime:create(time))
	end

	if not tolua.isnull(self.root) then
		self.root:runAction(cc.Sequence:create(fadeout,cc.CallFunc:create(function()
			if self.spine then
				self.spine:setVisible(false)
				self.spine:clearTracks()
				self.spine:removeFromParent()
			end
			self.spine_root:setVisible(false)
			self.spine_root:removeAllChildren()
			self.root:setVisible(false)
			if self.root:getParent() then
				self.root:removeFromParent()
			end
			self.root:removeAllChildren()
		end)))
	end
end

function SpineRenderer:realrelease(bool)
	if bool then
		if not tolua.isnull(self.spine_root) then
			self.spine_root:runAction(cc.FadeOut:create(0.5))
		end
	end
end

function SpineRenderer:playSkillDeath()
	self.root:setVisible(false)
end

-- 设灰度
function SpineRenderer:setBlack(enable)
	if not BattleController:getInstance():isInFight() then return end
	if self.is_die then return end
	local color1 = color1 or cc.c3b(128, 128, 128)
	local color2 = color2 or cc.c3b(255, 255, 255)
	if enable then
		self.black_type = "setBlack"
		for _, v in pairs(self.spine_root:getChildren()) do
			v:setColor(color1)
		end
	else
		self.black_type = nil
		for _, v in pairs(self.spine_root:getChildren()) do
			v:setColor(color2)
		end
	end	
end

-- 设灰度，更黑
function SpineRenderer:setBlack2(enable)
	if not BattleController:getInstance():isInFight() then return end
	if self.is_die then return end
	if enable then
		self.black_type = "setBlack2"
		self.root:setVisible(false)
	elseif not self.is_die then
		self.black_type = nil
		self.root:setVisible(true)
	end
end

--死亡变灰，现在消失弃用.
function SpineRenderer:setBlackDie(enable)
	if not BattleController:getInstance():isInFight() then return end
	local color1 = cc.c3b(110, 110, 110)
	local color2 = cc.c3b(255, 255, 255)
	if enable then
		self.black_type = "setBlackDie"
		for _, v in pairs(self.spine_root:getChildren()) do
			v:setColor(color1)
		end
	else
		self.black_type = nil
		for _, v in pairs(self.spine_root:getChildren()) do
			v:setColor(color2)
		end
	end	
end

--用于出场播放特效
function SpineRenderer:showEffect(enable)
	if not tolua.isnull(self.role_effect) then
		self.role_effect:setVisible(false)
		self.role_effect:removeFromParent()

		self.role_effect = nil
	end
	if enable == true then
		local spine_tmp = createSpineByName(Config.EffectData.data_effect_info[109])
		self.role_effect = spine_tmp
		self.role_effect:setAnimation(0, PlayerAction.action, false)
		if self.height then
			spine_tmp:setPosition(0, 0)
		end
		spine_tmp:setVisible(enable)
		self.spine_root:addChild(spine_tmp)
	end
end

--用于选择目标的特效播放
function SpineRenderer:showTargetEffect(enable)
end

function SpineRenderer:getSpineName()
	return self.spine_name
end

function SpineRenderer:addChild(...)
	if not tolua.isnull(self.spine_root) and self.spine_root then
		self.spine_root:addChild(...)
	end
end

function SpineRenderer:setActionName(action_name, action_res)
	self.action_name = action_name
	self.action_res = (action_res == nil) and action_name or action_res;
end

function SpineRenderer:getActionName()
	return self.action_name
end 

function SpineRenderer:getActionRes()
	return self.action_res
end

--==============================--
--desc:播放动作的统一入口
--time:2019-01-19 11:57:21
--@act:
--@return 
--==============================--
function SpineRenderer:runAction(act)
	if act == nil then return end
	if not tolua.isnull(self.root) then
		self.root:runAction(act) 
	end
end

function SpineRenderer:__delete()
	for i,v in ipairs(self.passive_skill_list) do
		doStopAllActions(v)
	end
	self.passive_skill_list = nil
	for i,v in ipairs(self.passive_skill_pool) do
		doStopAllActions(v)
	end
	self.passive_skill_pool = nil
	doStopAllActions(self.root)

	if  not tolua.isnull(self.shadow) then
		self.shadow:removeFromParent()
		self.shadow = nil
	end
	if not tolua.isnull(self.role_effect) then
		self.role_effect:removeFromParent()
		self.role_effect = nil
	end
	if not tolua.isnull(self.boss_effect) then
		self.boss_effect:removeFromParent()
		self.boss_effect = nil
	end
	if not tolua.isnull(self.spine) then
		self.spine:setVisible(false)
		self.spine:clearTracks()
		self.spine:removeFromParent()
	end
    if self.hallows_stage then
        self.hallows_stage:removeFromParent()
        self.hallows_stage = nil
    end
	self.spine = nil
	self.ui_hp = nil
	self.ui_hp2 = nil
	self.buff_list_item = nil
	self.skill_button = {}
	self.skill_type_list = {}
	if not tolua.isnull(self.spine_root) then
		self.spine_root:removeAllChildren()
	end
	if not tolua.isnull(self.root) then
		self.root:removeAllChildren()
	end
	if self.root:getParent() then
		self.root:removeFromParent()
	end
end