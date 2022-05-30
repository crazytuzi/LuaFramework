-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
-- [文件功能:战斗人物管理模块]
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
BattleRole = BattleRole or BaseClass()

local _battle_model = BattleController:getInstance():getModel()

--战斗管理初始化
--@param data --战斗数据
--@combat_type --战斗类型
function BattleRole:__init(data, combat_type,current_wave, total_wave)
	if data == nil then return end
	self.combat_type 		= data.fight_type 				--战斗类型
	self.pos 				= data.pos 						--位置唯一id
	self.owner_id 			= data.owner_id 				--拥有者id
	self.owner_srv_id 		= data.owner_srv_id 			--拥有者服务器id
	self.object_type 		= data.object_type 				--单位类型
	self.object_id 			= data.object_id 				--角色id或伙伴怪物id
	self.object_name 		= data.object_name 				--名字
	self.object_bid 		= data.object_bid  				--怪物Bid
	self.star 				= data.star 					--宠物星数
	self.sex 				= data.sex 						--性别
	self.hp 				= data.hp 						--血量
	self.lev 				= data.lev 						--等级
	self.hp_max 			= data.hp_max 					--最大血量
	self.init_hp_max        = data.hp_max 					--初始化最大血量
	self.face_id 			= data.face_id 					--头像
	self.round 				= data.round   					--第几回合
	self.skills 			= data.skills 					--技能列表
	self.group 				= data.group 					--分组
	self.sex 				= data.sex  					--性别
	self.is_awake 			= data.is_awake  				--是否已死亡
	self.career 			= data.career  					--职业
	self.special_born  		= data.special_born
	self.extra_data 		= data.extra_data
	self.type				= data.object_type				--单位类型 单位类型 1 角色 2 伙伴 3 怪物 4:神器
	self.wait_act 			= 0 							--等待动作播放
	self.res 				= "" 							--资源
	self.anim_skill 		= nil
	self.anim_standby 		= nil
	self.buff_list 			= {}  							--buff列表
	self.buff_icon 			= {}  							--buff图标
	self.is_die 			= false  						--是否死亡
	self.countTime 			= 0  							--长按tips计算器时间
	self.temp_pos 			= 0 							--缓存集火目标位置
	self.is_needNeed 		= true
	self.is_leader 			= nil
	self.fight_round 		= current_wave
	self.total_round 		= total_wave
	self.is_change_status 	= false
	self.is_boss 			= FALSE
	self.model_scale 		= 1
	self.spine_scale 		= 1
	self.is_diablerelive 	= false
	self.fashion 			= self:getBattleRoleExtendData(data.extra_data,BattleRoleExtendType.FASHION)		-- 皮肤
	self.resonate 			= self:getBattleRoleExtendData(data.extra_data,BattleRoleExtendType.RESONATE)		-- 共鸣
	self.crystal 			= self:getBattleRoleExtendData(data.extra_data,BattleRoleExtendType.CRYSTAL)		-- 原力水晶
	self.camp_type 			= 0 							-- 阵营
	self.encircle_effect 	= ""							-- 10星环绕特效
	self.height 			= 0
	self.width				= 0
    self.hallows_val        = data.hallows_val
    self.hallows_max        = data.hallows_max
	self.tips_list 			= {}							-- buff名字
	self.sprites 			= data.sprites or {} 			-- 精灵信息

	self:initBattleRoleData(data)
	self:setGridPos(data)
	self:loadSpineRes()
end

--==============================--
--desc:初始化单位数据
--time:2018-12-22 06:16:23
--@data:
--@return 
--==============================--
function BattleRole:initBattleRoleData(data)
	local base_data
	if data.object_type == BattleObjectType.Pet then --伙伴
        base_data = Config.PartnerData.data_partner_star(getNorKey(data.object_bid, data.star))
		if base_data then
			self.res = base_data.res_id
			self.encircle_effect = base_data.fight_effect 		-- 10星特效
		end
		local base_config = Config.PartnerData.data_partner_base[data.object_bid]
		if base_config then
			self.camp_type = base_config.camp_type or 0
		end
	elseif data.object_type == BattleObjectType.Unit then --怪物
		base_data = Config.UnitData.data_unit(data.object_bid)
		if base_data then
			self.res = base_data.body_id or self.res
			self.is_boss = base_data.sub_type or FALSE
			self.unit_is_boss = base_data.unit_is_boss or FALSE
			self.model_scale = base_data.model_size / 1000
			self.camp_type = base_data.camp_type or 0
			self.encircle_effect = base_data.fight_effect 		-- 10星特效
			if self.is_boss == TRUE then
				GlobalEvent:getInstance():Fire(BattleEvent.Battle_Boss_Hp_Event, {show_type = 1, head_icon = base_data.head_icon})
			end
		end
	elseif data.object_type == BattleObjectType.Hallows then --圣器
		-- data.star 为幻化id，不为0则表示该神器被幻化
		if data.star and Config.HallowsData.data_magic[data.star] then
			base_data = Config.HallowsData.data_magic[data.star]
		else
			base_data = Config.HallowsData.data_base[data.object_bid]
		end
		if base_data then
            self.res = base_data.c_res_id or self.res
            self.anim_skill = base_data.c_res_skill
            self.anim_standby = base_data.c_res_standby
			self.camp_type = base_data.camp_type or 0
			self.spine_scale = 0.5
		end		
	elseif data.object_type == BattleObjectType.Elfin then -- 精灵
		self.res = "H70000" -- 精灵固定一个透明的模型
		self.anim_standby = "action1"
	end
	-- 这里如果有时装,则特殊处理
	if self.fashion ~= 0 then
		local skin_config = Config.PartnerSkinData.data_skin_info[self.fashion]
		if skin_config then
			self.res = skin_config.res_id
            --self.encircle_effect ~= "" 表示 该宝可梦有10星以上..由策划决定
            if skin_config.fight_effect ~= "" and self.encircle_effect ~= "" then
                self.encircle_effect = skin_config.fight_effect
            end
		end
	end
	--初始化人物数据
	if base_data then
		self.height = base_data.height or 0
		self.width = base_data.width or 0
	end
	--缩放比例 在替换期间需要 --by lwc
    if Config.BattleActData.data_get_model_scale and data.object_type ~= BattleObjectType.Hallows then
        local scale = Config.BattleActData.data_get_model_scale[self.res] or 1000
        self.spine_scale = scale/1000
    end
end

function BattleRole:getFashionId()
	return self.fashion
end

--==============================--
--desc:加载模型资源,并且添加到场景中
--time:2018-12-22 06:08:03
--@return 
--==============================--
function BattleRole:loadSpineRes()
	if self.type ~= BattleObjectType.Role then
		local js_path, atlas_path, png_path, prefix
		if self.type == BattleObjectType.Hallows then
			js_path, atlas_path, png_path, prefix = PathTool.getSpineByNameV36(self.res, self.anim_standby, "res/spine/")
		else
			js_path, atlas_path, png_path, prefix = PathTool.getSpineByName(self.res, PlayerAction.battle_stand)
		end
		if display.isPrefixExist(prefix) then
			self:addToLayer()
		else
			-- local pixelformal = getPixelFormat(self.res)
			cc.Director:getInstance():getTextureCache():addImageAsync(png_path, function()
				self:addToLayer()
			end)
		end
	else
		self:addToLayer()
	end
end

--==============================--
--desc:添加单位到场景中去
--time:2018-07-26 09:50:25
--@return 
--==============================--
function BattleRole:addToLayer()
	if _battle_model == nil or _battle_model:getBattleScene() == nil then return end
	local map_layer = BattleController:getInstance():getMapLayer()
	if tolua.isnull(map_layer) then return end

	local is_reconnet = BattleController:getInstance():getModel():getReconnectStatus()
	local screen_pos = gridPosToScreenPos(self.grid_pos) or cc.p(0, 0)
	local temp_group = BattleController:getInstance():getModel():checkGroup(self.group)
	local anima_name = self.anim_standby or PlayerAction.battle_stand
	
	self.spine_renderer = SpineRenderer.New(screen_pos, self.res, self.model_scale, true, anima_name, self.career, temp_group, self.type, self.is_boss, self.unit_is_boss, self.spine_scale)
	self.spine_renderer:addToLayer(map_layer)

	self.spine_renderer.stand = anima_name
	self.spine_renderer.res = self.res
	self.spine_renderer.obj_type = self.obj_type
	self.spine_renderer.grid_pos = self.grid_pos
	self.spine_renderer.grid_pos_back = self.grid_pos_back
	self.spine_renderer.is_friend = self.group == BattleController:getInstance():getModel():getGroup()
	self.spine_renderer.type = self.type
	self.spine_renderer.bid = self.owner_srv_id
	self.spine_renderer.career = self.career
	self.spine_renderer.group = BattleController:getInstance():getModel():checkGroup(self.group)
	self.spine_renderer.sex = self.sex
	self.spine_renderer.is_die = self.is_die
	self.spine_renderer.is_change_status = self.is_change_status
	self.spine_renderer.is_finish_action = false 						--是否完成动作
	self.screen_pos = screen_pos	 									--保存当前位置

	-- 创建10星特效,后面延迟创建
	if self.spine_renderer.createEncircleEffect then
		self.spine_renderer:createEncircleEffect(self.encircle_effect)
	end

	local model_x_fix, model_y_fix = 0, 0
	self.height = 0
	local config = Config.SkillData.data_get_model_data[self.res] or Config.SkillData.data_get_model_data["0"]
	if config then
		self.height = config.model_height
	end
	self.spine_renderer.model_x_fix = model_x_fix
	self.spine_renderer.model_y_fix = model_y_fix
	self.spine_renderer:reverse(self.obj_type)
	
	local zorder = SCREEN_HEIGHT - screen_pos.y
	local zorder_pos = 1
	if self.pos == 31 or self.pos == 32 then
        zorder_pos = 10
    elseif self.pos == 41 or self.pos == 42 then
    	zorder_pos = 11
	elseif self.group == 2 then --如果是敌方阵型，这里需要减掉5
		zorder_pos =(self.pos - GIRD_POS_OFFSET) or 1
	else
		zorder_pos = zorder_pos or 1
	end
	zorder_pos = math.max(1, zorder_pos)
	if self.group == 2 and BattleRoleZorder[self.group] and BattleRoleZorder[self.group][zorder_pos] then
		zorder = BattleRoleZorder[self.group][zorder_pos]
	else
		if BattleRoleZorder[self.group] and BattleRoleZorder[self.group][zorder_pos] then
			zorder = BattleRoleZorder[self.group][zorder_pos]
		end
	end
	self.zorder = zorder
	self.spine_renderer.zorder = zorder
	self.spine_renderer.root:setLocalZOrder(zorder)
	self.width = 100
	self:updateRole(true)
	self.spine_renderer:showSpineModel(false)

    if self.type == BattleObjectType.Hallows then
        self.spine_renderer:setHallowsRound(self.hallows_val, self.hallows_max)
    elseif self.type == BattleObjectType.Elfin then
    	self.spine_renderer:showElfinSkillIcon(self.sprites, self.skills)
    end
	if self.hp <= 0 then
		self:died(true)
	elseif self.special_born == true then --召唤出来的伙伴
		self.spine_renderer:showSpineModel(true)
		self.spine_renderer:showEffect(true)
	end
	if not self.special_born then
		if BattleConst.canDoBattle(self.combat_type) then
			if is_reconnet then	
				if self.hp > 0 then
					self:showRecEnterAction()
				end
			else
				if BattleController:getInstance():getActTime("is_diff_enter") == TRUE then
					if BattleController:getInstance():getModel():changeGroup(self.group) == 1 then
						if self.hp > 0 then
							self:showEnterAction()
						end
					end
				else
					if self.hp > 0 then
						self:showEnterAction()
					end
				end
			end
		end
	end
end

--==============================--
--desc:同步单位信息
--time:2018-12-22 06:19:16
--@data:
--@data_vo:
--@return 
--==============================--
function BattleRole:updataNextBattleRole(data, data_vo)
	self.hp = data.hp 						--血量
	self.hp_max = data.hp_max 				--最大血量
	self.owner_id = data.owner_id 			--拥有者id
	self.owner_srv_id = data.owner_srv_id 	--拥有者服务器id
	self.object_type = data.object_type 	--单位类型
	self.object_id = data.object_id 		--角色id或伙伴怪物id
	self.object_name = data.object_name 	--名字
	self.object_bid = data.object_bid  		--怪物Bid
	self.sex = data.sex 					--性别
	self.lev = data.lev 					--等级
	self.round = data.round   				--第几回合
	self.type = data.object_type or 1		--类型
	--下波更新清空玩家Buff图标和列表
	if self.spine_renderer then
		self.spine_renderer:cleanAllBuffIcon(self.buff_list)
	end
	SkillAct.clearAllEffect(self.spine_renderer)
	self.buff_list = {}  --buff列表
	self.buff_icon = {}  --buff图标
	self.pos = data.pos
	self.group = data.group --分组
	self.career = data.career  --职业
	self.spine_renderer:setVisible(true)
	if data_vo then
		self.combat_type = data_vo.combat_type
		self.fight_round = data_vo.current_wave or BattleController:getInstance():getModel():getFightRound()
		self.total_round = data_vo.total_wave
	end
	if self.hp <= 0 then
		self:died()
	end
	if not self.spine_renderer or tolua.isnull(self.spine_renderer.root) then return end
	self.spine_renderer:reConnectUpdate(self.hp, self.hp_max)
	if self.is_boss == TRUE then
		--如果是boss 需要更新一下信息 --by lwc
		GlobalEvent:getInstance():Fire(BattleEvent.Battle_Boss_Hp_Event, {show_type = 2, battle_role = self})
	end
	
	if self.group == BattleGroupTypeConf.TYPE_GROUP_ROLE then
		BattleController:getInstance():getModel():getBattleScene():MapMovescheduleUpdate()
	end
end

--==============================--
--desc:设置战斗站位
--time:2018-12-22 06:14:36
--@data:
--@return 
--==============================--
function BattleRole:setGridPos(data)
	self.pos = data.pos
	if BattleController:getInstance():getModel():changeGroup(data.group)  == BattleGroupTypeConf.TYPE_GROUP_ROLE then
		self.obj_type = BattleTypeConf.TYPE_ROLE
		self.grid_pos = SkillAct.newPos2Gird(self.combat_type, data.pos, true,self.group)
	else
		self.obj_type = BattleTypeConf.TYPE_ENEMY
		self.grid_pos = SkillAct.newPos2Gird(self.combat_type, data.pos, false, self.group)
	end
	self.grid_pos_back = deepCopy(self.grid_pos)
end

--获取人物额外数据
function BattleRole:getBattleRoleExtendData(data,key)
	local extra_id = 0
	if next(data or {}) ~= nil then
		for i,v in pairs(data) do
			if key == v.extra_key then --1是光环
				extra_id = v.extra_value
				break
			end
		end
	end
	return extra_id
end

--- BattleRole:showRecEnterAction 断线重连时候的进场动作
function BattleRole:showRecEnterAction()
	if not tolua.isnull(self.spine_renderer.root) then
		self.spine_renderer:showSpineModel(false)
		if self.hp > 0 then
			self.spine_renderer:showSpineModel(true)
			BattleController:getInstance():getModel():addReConnectReadySum(self.object_type)
		end
	end
end

--- BattleRole:showEnterAction 真实战斗的进场动作
function BattleRole:showEnterAction()
	self.spine_renderer:showSpineModel(true)
    if self.type == BattleObjectType.Hallows or self.type == BattleObjectType.Elfin then 
		-- BattleController:getInstance():getModel():addReadySum()
        return 
    end
	-- 初始创建的单位,如果就是死亡的话,还是会继续创建,只是不可见
	if self.hp <= 0 then
		self.spine_renderer:showSpineModel(false)
	end

	if not tolua.isnull(self.spine_renderer.root) and not BattleController:getInstance():getModel():getReconnectStatus() then
		if not self.spine_renderer.is_finish_action then
			if BattleConst.canDoBattle(self.combat_type) then
				local offset_x ,time = SCREEN_WIDTH/4 ,BattleController:getInstance():getActTime("real_battle_enter_time")

				self.spine_renderer.is_finish_action = true
				BattleController:getInstance():getCtrlBattleScene():setMoveMapStatus(false)
				local pos = cc.p(self.screen_pos.x, self.screen_pos.y)
				self.spine_renderer:doRun()
				if BattleController:getInstance():getModel():changeGroup(self.group)== 2 then
					pos.x = pos.x + offset_x
					self.spine_renderer:reverse(self.obj_type)
				else
					pos.x = pos.x - offset_x
				end
				if not tolua.isnull(self.spine_renderer.root) then
					self.spine_renderer.root:setPosition(pos)
				end
				
				local move = cc.MoveBy:create(time, cc.p(offset_x, 0))
				if BattleController:getInstance():getModel():changeGroup(self.group)== 2 then
					move = cc.MoveBy:create(time, cc.p(-offset_x, 0))
				end

				self.spine_renderer:runAction(cc.Sequence:create(move, cc.CallFunc:create(function()
					self.spine_renderer:doStand()
					self.spine_renderer:reverse(self.obj_type)
					if not tolua.isnull(self.spine_renderer.root) then
						self.spine_renderer.root:setPosition(self.screen_pos.x, self.screen_pos.y)
						self.spine_renderer:showEffect(false)
					end
				end)))
			end
		end
	end
end

--更新人物
function BattleRole:updateRole(is_init)
	if not BattleController:getInstance():getModel():isFinish() then
		if not self.spine_renderer or tolua.isnull(self.spine_renderer.root) then return end
		local r = cc.size(0, 0)
		if self.spine_renderer.spine and not tolua.isnull(self.spine_renderer.spine) then
			self.spine_renderer.spine:update(0)
			r = self.spine_renderer.spine:getBoundingBox()
		end
		self.width = self.width or math.max(r.width, 50) -- 取大小失败时位置异常
		self.height = self.height or math.max(r.height, 100)
		self.spine_renderer.role_height = self.height--* self.spine_renderer.scale -- 把模型的缩放尺寸也算进去
		self.spine_renderer.role_width = self.width
		if not self.is_die then
			self.spine_renderer:setupUI(self.group, self.lev, self.camp_type, {crystal = self.crystal})
		end
		self.spine_renderer:updateResonate(self.resonate) -- 设置共鸣
		local per = math.min(math.max(100 * self.hp / self.hp_max, 0), 100)
		self.spine_renderer:setHpPercent(per, is_init)
		if self.is_boss == TRUE then
			--如果是boss 需要更新一下信息 --by lwc
			GlobalEvent:getInstance():Fire(BattleEvent.Battle_Boss_Hp_Event, {show_type = 2, battle_role = self})
		end
		BattleController:getInstance():getModel():roleReady(self)
	end
end

--人物跑动
function BattleRole:doMove(start_pos, end_pos, start_camera_pos, end_camera_pos)
	if not self.spine_renderer or tolua.isnull(self.spine_renderer.root) then return end
	self.spine_renderer:doMove(start_pos, end_pos, start_camera_pos, end_camera_pos)
end

-- 重置深度值.用于层级的
function BattleRole:resetZOrder()
	if not self.spine_renderer or tolua.isnull(self.spine_renderer.root) then return end
	if self.init_zorder == nil then
		local zorder = SCREEN_HEIGHT - gridPosToScreenPos(self.grid_pos).y
		if self.pos == 31 or self.pos == 32 then
			zorder = BattleRoleZorder[self.group][10]
		elseif self.pos == 41 or self.pos == 42 then
			zorder = BattleRoleZorder[self.group][11]
		elseif self.group == 2 then
			zorder = BattleRoleZorder[self.group][self.pos - GIRD_POS_OFFSET]
		else
			zorder = BattleRoleZorder[self.group][self.pos]
		end
		self.init_zorder = zorder
	end
	self.spine_renderer.root:setLocalZOrder(self.init_zorder)
end

--角色死亡
--force:如果创建的时候就是死亡的,就不需要播放死亡动作了.避免一闪一闪
function BattleRole:died(force)
	if not self.spine_renderer or tolua.isnull(self.spine_renderer.root) then return end
	if self.is_die then return end
	self.spine_renderer.is_die = true
	self.is_die = true

	if not force then
		local delayTime = cc.DelayTime:create(BattleController:getInstance():getActTime("delay_die_act"))
		local blink = cc.Blink:create(0.2, 2)
		local callFunc = cc.CallFunc:create(function()
			if self.spine_renderer.is_die == true then
				-- self:showUI(false)
				self.spine_renderer:showSpineModel(false)
			else
				self:relive()
			end
		end)
		self.spine_renderer:runAction(cc.Sequence:create(delayTime, blink, callFunc))
	else
		-- self:showUI(false)
		self.spine_renderer:showSpineModel(false)
	end
	self:removeRoleEffect()
end

--变成鬼魂状态
function BattleRole:changeToGuiHun(status)
	if status == true then
		self.is_in_ghost = true
		self.spine_renderer:handleGuiHunStatus(true)
	else
		self.is_in_ghost = false
		self.spine_renderer:handleGuiHunStatus(false)
	end
end

--复活
function BattleRole:relive()
	if not self.spine_renderer or tolua.isnull(self.spine_renderer.root) then return end
	-- 存在鬼魂状态,直接移除鬼魂
	self:changeToGuiHun(false)

	self.is_die = false
	self.spine_renderer.is_die = false
	self.spine_renderer.grid_pos = self.grid_pos
	self.spine_renderer:setPosByGrid(self.grid_pos)

	-- 如果死亡的时候进入战斗,但是在过程中又被复活起来了之后,需要创建血条部分的
	if self.spine_renderer.hp_root == nil then
		self.spine_renderer:setupUI(self.group, self.lev, self.camp_type, {crystal = self.crystal})
	-- else
	-- 	self:showUI(true)
	end
	local per = math.min(math.max(100 * self.hp / self.hp_max, 0), 100)
	self.spine_renderer:setHpPercent(per)
	self.spine_renderer:showSpineModel(true)
	if self.is_boss == TRUE then
		--如果是boss 需要更新一下信息 --by lwc
		GlobalEvent:getInstance():Fire(BattleEvent.Battle_Boss_Hp_Event, {show_type = 2, battle_role = self})
	end

	SkillAct.setAnimation(self.spine_renderer, self.spine_renderer.stand, true, nil, nil)
end

--- BattleRole:removeRoleEffect 移除角色的特效包括buff
function BattleRole:removeRoleEffect()
	SkillAct.clearAllEffect(self.spine_renderer)
	for _, buff in pairs(self.buff_list) do
		self.spine_renderer:removeBuffIcon(buff.id)
		local config = Config.SkillData.data_get_buff[buff.bid]
		if config and config.group == 3211 then
			self.is_diablerelive = true
		end
	end
	self.buff_list = {}
	self.buff_icon = {}
end

--- BattleRole:doDied 马上死亡.不需要播放死亡动作
function BattleRole:doDied()
	if not self.spine_renderer or tolua.isnull(self.spine_renderer.root) then return end
	if self.is_die then return end
	self.spine_renderer.is_die = true
	self.is_die = true
	self:removeRoleEffect()
	self.spine_renderer:showSpineModel(false)
end

--用于设置死亡时角色UI的显示
function BattleRole:showUI(bool)
end

--禁止复活
function BattleRole:isDisableReLieve()
	-- body
end

--设置黑屏1
function BattleRole:setBlack(enable)
	if self.is_die then return end
	if not self.spine_renderer or tolua.isnull(self.spine_renderer.root) then return end
	self.spine_renderer:setBlack(enable)
end

--设置黑屏2
function BattleRole:setBlack2(enable)
	if self.is_die then return end
	if not self.spine_renderer or tolua.isnull(self.spine_renderer.root) then return end
	self.spine_renderer:setBlack2(enable,0)
end

--- BattleRole:changeSpine 变出处理,后续会用到
-- @param bool       是否变身
-- @param spine      变身资源
-- @param anima_name 变身动作资源
function BattleRole:changeSpine(bool, spine, anima_name)
	if not self.spine_renderer or tolua.isnull(self.spine_renderer.root) then return end

	-- 如果是在播放动作过程中,切换模型这个时候不处理
	if bool and self.spine_renderer.in_animation == true then
		self.change_spine_res = spine
		self.change_spine_action = anima_name
		return
	end

	if bool then
		self.spine_renderer.is_change_status = true
		self.spine_renderer.buff_spine = spine
	else
		self.spine_renderer.is_change_status = false
		self.spine_renderer.buff_spine = nil
	end
	spine = spine or self.res	
	anima_name = anima_name or PlayerAction.battle_stand
	if spine ~= "" and spine ~= nil then
		if not tolua.isnull(self.spine_renderer.spine) then
			self.spine_renderer.spine:runAction(cc.RemoveSelf:create(true))
		end
		local spine_tmp = nil
		spine_tmp = createSpineByName(spine, anima_name)
		self.spine_renderer.spine = spine_tmp
		self.spine_renderer:setActionName(anima_name)
		self.spine_renderer:reverse(self.spine_renderer.obj_type)
		self.spine_renderer:addChild(spine_tmp)
		if self.spine_renderer.spine then
			self.spine_renderer.spine:setAnimation(0, anima_name, true)
			-- self.spine_renderer.spine:setToSetupPose()
		end
		local function animationCompleteFunc(event) 
			if  self.spine_renderer:getActionName() ~= PlayerAction.battle_stand then
				self:changeSpine(true, spine, PlayerAction.battle_stand)
			end
		end
		self.spine_renderer.spine:registerSpineEventHandler(animationCompleteFunc, sp.EventType.ANIMATION_COMPLETE)
	end
end

-- 动作播放完成之后,尝试切换模型
function BattleRole:reTryChangeSpine()
	if self.change_spine_res and self.change_spine_action then
		self:changeSpine(true, self.change_spine_res, self.change_spine_action)
		self.change_spine_action = nil
		self.change_spine_res = nil
	end
end

function BattleRole:exitdeleteRole()
	if not self.spine_renderer or tolua.isnull(self.spine_renderer.root) then return end
	if self.is_boss == TRUE then
		if not tolua.isnull(self.spine_renderer.hp_root) then
			self.spine_renderer.hp_root:removeAllChildren()
			self.spine_renderer.hp_root:removeFromParent()
		end
	end
	self.spine_renderer:DeleteMe()
end

--隐身buff改变透明度
function BattleRole:setOpacity(bool,opacity)
	if not self.spine_renderer or tolua.isnull(self.spine_renderer.root) then return end
	if bool then
		self.spine_renderer:setOpacity(opacity)
	else	
		self.spine_renderer:setOpacity(255)
	end
end

function BattleRole:setHaloEffectZOrder(status)
	if not self.spine_renderer or tolua.isnull(self.spine_renderer.halo_effect) then return end
	if status == true then
		self.spine_renderer.halo_effect:setOpacity(50)
	else
		self.spine_renderer.halo_effect:setOpacity(255)
	end
end

function BattleRole:removeBuffTipsList()
	if self.tips_list == nil then return end
	local tolua_isnull = tolua.isnull
	for k,v in pairs(self.tips_list) do
		if not tolua_isnull(v.sp) then
			doStopAllActions(v.sp)
			v.sp:removeFromParent()
		end
	end
	self.tips_list = {}
end
