-- --------------------------------------------------------------------
--
--
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      轮回播放战斗人物
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
BattleHookRole = BattleHookRole or BaseClass()
--战斗管理初始化
--@param data --战斗数据
--@combat_type --战斗类型
function BattleHookRole:__init(data,combat_map,time_scale,is_next_offset)
    if data == nil then
        return
    end
    self.combat_type = combat_map --战斗类型
    self.wait_act = 0 --等待动作播放
    self.type = data.object_type --类型
    self.object_type = data.object_type
    self.res = "" --资源
    self.group = data.group --分组
    self.is_die = false --是否死亡
    self.model_scale = 1
    self.spine_scale = 1
    self.hp = data.hp
    self.lev = 0
    self.hp_max = data.hp_max
    self.bid = data.bid
    self.object_bid = data.bid
    self.icon = data.icon or 5
    self.is_next_offset = is_next_offset
    self.time_scale = time_scale
    self.is_boss = false
    self.camp_type = 0 -- 阵营
	self.encircle_effect 	= ""		-- 10星环绕特效
    self.fashion = data.fashion or 0

    self:initBattleRoleData(data)
    self:setGridPos(data) 
    self:loadSpineRes()
end

---解析数据
function BattleHookRole:initBattleRoleData(data)
    local base_data
    if data.object_type == BattleObjectType.Pet then --伙伴
        base_data = Config.PartnerData.data_partner_star(getNorKey(data.bid, data.star))
        if base_data then
            self.res = base_data.res_id
            self.encircle_effect = base_data.fight_effect
        end
        local base_config = Config.PartnerData.data_partner_base[data.bid]
        if base_config then
            self.camp_type = base_config.camp_type or 0
        end
    elseif data.object_type == BattleObjectType.Unit then --怪物
        base_data = Config.UnitData.data_unit(data.bid)
        if base_data then
            self.res = base_data.body_id or self.res
            self.camp_type = base_data.camp_type or 0
            self.encircle_effect = base_data.fight_effect
			self.is_boss = base_data.sub_type or FALSE
            self.model_scale = base_data.model_size / 1000
        end
    end
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

    --缩放比例 在替换期间需要 --bylwc
    if Config.BattleActData.data_get_model_scale then
        local scale = Config.BattleActData.data_get_model_scale[self.res] or 1000
        self.spine_scale = scale/1000
    end
end

function BattleHookRole:getFashionId()
	return self.fashion
end

function BattleHookRole:loadSpineRes()
    if self.type ~= BattleObjectType.Role then
        local js_path, atlas_path, png_path, prefix = PathTool.getSpineByName(self.res, PlayerAction.run)
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

--设置角色格子位置
--[[	@data:位置信息
--]]
function BattleHookRole:setGridPos(data)
    self.pos = data.pos
    if self.group == BattleGroupTypeConf.TYPE_GROUP_ROLE then
        self.obj_type = BattleTypeConf.TYPE_ROLE
        self.grid_pos = SkillAct.newPos2Gird(self.combat_type, data.pos, true, self.group)
    else
        self.obj_type = BattleTypeConf.TYPE_ENEMY
        self.grid_pos = SkillAct.newPos2Gird(self.combat_type, data.pos, false, self.group)
    end
    self.grid_pos_back = deepCopy(self.grid_pos)
end

--添加战任务到场景
function BattleHookRole:addToLayer()
    if BattleController:getInstance():getCtrlBattleScene() == nil then
        return
    end
    local map_layer = BattleController:getInstance():getMapLayer()
    if map_layer == nil then
        return
    end
    local screen_pos = gridPosToScreenPos(self.grid_pos) or cc.p(0, 0)
    local temp_group = self.group
    local anima_name = PlayerAction.run
    if MAKELIFEBETTER == true then
        anima_name = PlayerAction.battle_stand
        if self.group == 2 then
            anima_name = PlayerAction.run
        end
    end

    self.spine_renderer = SpineRenderer.New(screen_pos, self.res, self.model_scale, true, PlayerAction.run, self.career, temp_group, self.type, self.is_boss, nil,self.spine_scale)
    
    self.spine_renderer.stand = anima_name
    self.spine_renderer:addToLayer(map_layer)
    self.spine_renderer.res = self.res
    self.spine_renderer.obj_type = self.obj_type
    self.spine_renderer.grid_pos = self.grid_pos
    self.spine_renderer.grid_pos_back = self.grid_pos_back
    self.spine_renderer.is_friend = self.group == BattleController:getInstance():getNormalModel():getGroup()
    self.spine_renderer.type = self.type
    self.spine_renderer.is_finish_action = false --是否完成动作
    self.spine_renderer.is_first_enter = false
    self.spine_renderer.group = self.group
    self.spine_renderer.is_die = self.is_die

    -- 创建10星特效
	self.spine_renderer:createEncircleEffect(self.encircle_effect)

    local model_x_fix, model_y_fix = 0, 0
    self.height = nil
    local config = Config.SkillData.data_get_model_data[self.res] or Config.SkillData.data_get_model_data["0"]
    if config then
        self.height = config.model_height
    end
    self.spine_renderer.model_x_fix = model_x_fix
    self.spine_renderer.model_y_fix = model_y_fix
    self.spine_renderer:reverse(self.obj_type)
    self.spine_renderer.root:setOpacity(0)
    local zorder =  SCREEN_HEIGHT - gridPosToScreenPos(self.grid_pos).y
    if self.group == 2 then
        zorder = BattleRoleZorder[self.group][self.pos - GIRD_POS_OFFSET]
    else
        zorder = BattleRoleZorder[self.group][self.pos]
    end
    self.spine_renderer.zorder = zorder
    self.spine_renderer.root:setLocalZOrder(zorder)
    self.width = 100
    self.touch_layer = ccui.Layout:create()
    self.touch_layer:setContentSize(self.width, self.height)
    self.spine_renderer.root:addChild(self.touch_layer)
    self.touch_layer:setAnchorPoint(cc.p(1, 0))
    self.touch_layer:setTouchEnabled(true)
    if self.group == 2 then
    end

    local tag_name = "role_" .. self.pos
    if self.group == BattleGroupTypeConf.TYPE_GROUP_ENEMY then
        tag_name = "enemy_" .. self.pos
    end
    self.touch_layer:setName(tag_name)
    self:updateRole()
    if BattleController:getInstance():getIsNoramalBattle() then
        self:showEnterAction()
    end
end

function BattleHookRole:clearNextActTimer()
    if self.next_ack_mon_timer ~= nil then
        GlobalTimeTicket:getInstance():remove(self.next_ack_mon_timer)
        self.next_ack_mon_timer = nil
    end
end

function BattleHookRole:clearNextCallTimer()
    if self.next_call_mon_timer ~= nil then
        GlobalTimeTicket:getInstance():remove(self.next_call_mon_timer)
        self.next_call_mon_timer = nil
    end
end

--- 进场动作,如果是敌方,就是播报的触发点和下一波怪的产生点
function BattleHookRole:showEnterAction()
    if tolua.isnull(self.spine_renderer.root) then
        return;
    end
    if not BattleController:getInstance():getIsNoramalBattle() then 
        return
    end

    --出场效果
    local fade = cc.FadeIn:create(0.5)
    if self.group == 1 then         -- 己方
        self.spine_renderer.root:runAction(fade)
    else
        self:clearNextActTimer()
        self:clearNextCallTimer()
        local start_point_x = SCREEN_WIDTH * 1.1 --开始位置
        if self.is_next_offset == true then
            start_point_x = SCREEN_WIDTH * 1.2
        end
        local final_point_x = gridPosToScreenPos(NormalPosGridRight[1]).x --终点位置
        local offset_x = final_point_x - start_point_x  --需要移动的距离
        self.spine_renderer.root:setPositionX(start_point_x)
        local time = BattleController:getInstance():getActTime("new_hook_move_time") --移动时间
        local move_by = cc.MoveBy:create(time, cc.p(offset_x, 0))
        self.spine_renderer.root:runAction(cc.Spawn:create(move_by, fade))

        -- 下一波怪物
        -- print("WTF___try__nextMon____")
        local next_time = BattleController:getInstance():getActTime("new_hook_next_mon_time")
        if self.next_call_mon_timer == nil then
            self.next_call_mon_timer = GlobalTimeTicket:getInstance():add(function() 
                if BattleController:getInstance():getIsNoramalBattle() then
                    -- print("WTF__nextMon_____111")
                    BattleController:getInstance():getNormalModel():updateNextRoundData(BattleLoop2.next_target_type_pos)
                end
                self:clearNextCallTimer()
            end,next_time, 0)
        end

        -- 准备播报
        local act_time = BattleController:getInstance():getActTime("new_hook_act_mon_time") - BattleController:getInstance():getNormalModel():getFinalMoveTime()
        if self.next_ack_mon_timer == nil then
            self.next_ack_mon_timer = GlobalTimeTicket:getInstance():add(function() 
                if BattleController:getInstance():getIsNoramalBattle() then
                    local skill_plays_data = BattleLoop2.play(self.pos) --获取播报
                    if skill_plays_data then
                        local skill_plays_list = BattleController:getInstance():getNormalModel():getSkillPlayData(skill_plays_data.actor) --是否已经存在该施法者的播报
                        if next(skill_plays_list or {}) == nil then
                            BattleController:getInstance():getNormalModel():handleSkillPlayData(skill_plays_data)
                        end
                        BattleController:getInstance():getNormalModel():updateActorPlaysList(skill_plays_data)
                    end
                end
                self:clearNextActTimer()
            end, act_time, 0)
        end
    end
end

--更新人物
function BattleHookRole:updateRole()
    if not self.spine_renderer or tolua.isnull(self.spine_renderer.root) then
        return
    end
    BattleController:getInstance():getNormalModel():roleReady(self)
    self.spine_renderer:setupUI(self.group, self.lev, self.camp_type)
    if self.group == BattleGroupTypeConf.TYPE_GROUP_ENEMY then
        local per = math.min(math.max(100 * self.hp / self.hp_max, 0), 100)
        self.spine_renderer:setHpPercent(per)
    end
end


function BattleHookRole:setMoveTime(time)
    self.move_time = time
end
--人物跑动
function BattleHookRole:doMove(start_pos, end_pos, start_camera_pos, end_camera_pos)
    if not self.spine_renderer or tolua.isnull(self.spine_renderer.root) then
        return
    end
    self.spine_renderer:doMove(start_pos, end_pos, start_camera_pos, end_camera_pos)
end

function BattleHookRole:resetZOrder()
    if not self.spine_renderer or tolua.isnull(self.spine_renderer.root) then
        return
    end
    local pos = gridPosToScreenPos(self.grid_pos)
    local zorer = self.spine_renderer.zorder or SCREEN_HEIGHT - pos.y
    self.spine_renderer.root:setLocalZOrder(zorer)
end
--角色死亡
function BattleHookRole:died()
    if not self.spine_renderer or tolua.isnull(self.spine_renderer.root) then
        return
    end
    self.spine_renderer.is_die = true
    if self.is_die then
        return
    end
    self.is_die = true
    local function callDeath()
        if self.is_die == true then
            self.spine_renderer.root:runAction(
                cc.Sequence:create(
                    cc.CallFunc:create(function ()
                        self:assetJumpTo()
                    end),
                    cc.DelayTime:create(BattleController:getInstance():getActTime("delay_die_act")),
                    cc.Spawn:create(
                        cc.Blink:create(0.5, 2),
                        cc.FadeOut:create(0.25),
                        cc.CallFunc:create(
                            function()
                                if self.spine_renderer.is_die == true then
                                    self:showUI(false)
                                end
                            end
                        )
                    ),
                    cc.DelayTime:create(BattleController:getInstance():getActTime("delay_die_next_mon")),
                    cc.CallFunc:create(
                        function()
                            self.spine_renderer.root:setVisible(false)
                            BattleController:getInstance():getNormalModel():playEnd(self.pos)
                        end
                    ),
                    cc.CallFunc:create(function ()
                            if  BattleController:getInstance():getIsNoramalBattle() then
                                -- print("WTF__nextMon_____222")
                                BattleController:getInstance():getNormalModel():updateNextRoundData(BattleLoop2.next_target_type_kill)
                            end
                        end
                    )
                )
            )
        end
    end
    SkillAct.clearAllEffect(self.spine_renderer)
    local callback = function()
        local setDieAnima = function()
            if not tolua.isnull(self.spine_renderer.root) then
                if self.is_die then
                    callDeath()
                end
            end
        end
        if not tolua.isnull(self.spine_renderer.root) then
            setDieAnima()
        end
    end
    callback()
end

--- 假战斗模型做兼容处理
function BattleHookRole:reTryChangeSpine()
end

function BattleHookRole:assetJumpTo()
    if self.group ~= 2 then return end
    if self.spine_renderer == nil or self.spine_renderer.root == nil then return end
    local node_root_pos = self.spine_renderer.root:convertToWorldSpace(cc.p(0, 0))
    BattleDramaController:getInstance():playResourceCollect(node_root_pos.x, node_root_pos.y + self.height*0.5)
end


--用于设置死亡时角色UI的显示
function BattleHookRole:showUI(bool)
    if not tolua.isnull(self.spine_renderer.ui_hp) and not tolua.isnull(self.spine_renderer.ui_hp2) then --
        if not tolua.isnull(self.spine_renderer.ui_hp:getParent()) then
            self.spine_renderer.ui_hp:getParent():runAction(cc.RemoveSelf:create())
            self.spine_renderer.ui_hp = nil
        end
        if not tolua.isnull(self.spine_renderer.ui_hp2:getParent()) then
            self.spine_renderer.ui_hp2:getParent():runAction(cc.RemoveSelf:create())
            self.spine_renderer.ui_hp2 = nil
        end
    end
end

function BattleHookRole:exitdeleteRole()
    if not self.spine_renderer or tolua.isnull(self.spine_renderer.root) then return end
    if self.is_boss == TRUE then
        if not tolua.isnull(self.spine_renderer.hp_root) then
            self.spine_renderer.hp_root:removeAllChildren()
            self.spine_renderer.hp_root:removeFromParent()
        end
    end
	doStopAllActions(self.spine_renderer.root)
    self:clearNextActTimer()
    self:clearNextCallTimer()
    self.spine_renderer:DeleteMe()
end
