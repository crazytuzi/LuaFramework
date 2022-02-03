-- --------------------------------------------------------------------
-- 自由移动场均净的角色
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
RoleScenePlayer = RoleScenePlayer or BaseClass(RoleSceneObj)

function RoleScenePlayer:__init(is_hero)
	self.is_hero = is_hero or false
    self.isRuning = false
    self.isNeedRun = false
	self.model_scale = 0.8

    --移动参数
    self.move_start_pos = cc.p(0,0)
    self.move_end_pos = cc.p(0,0)
    self.move_total_distance = 0 
    self.move_pass_distance = 0
    self.move_dir = cc.p(0,0)
    self.move_speed = 0

    self.dir_number = 0
    self.stepPost = 0
end

function RoleScenePlayer:setVo(value)
	RoleSceneObj.setVo(self, value)
    self.dir_number = self.vo.dir

	self:setModelScale(self.model_scale)
	self:initSpine()

	if not self.is_hero then
		self:registEvent()
		self:setVisible(not self.vo.hide_self)
	end
	
	if  RolesceneController:getInstance():getIsInChiefWar() then
		--首席有个分最高的buff
		self:changeBuffLooks()
		self:showHeroArrow()
		
		
	end
	local scene_id = RolesceneController:getInstance():getSceneID()
		if self.vo ~= nil then
			-- 设置状态的统一弄到initSpine里面设置
			if self.role_attr_change == nil then
				self.role_attr_change = self.vo:Bind(RolesceneEvent.UPDATE_ROLE_ATTRIBUTE, function( key, value )
					if key == "looks" then
						if RolesceneController:getInstance():getIsInChiefWar() then
							self:changeLooks()
							self:changeBuffLooks()
						end
					elseif key == "hide_self" then
						if not self.is_hero then
							self:setVisible(not value)
						end
					elseif key == "status" then 
						print("===============key=====value====",key,value)
						if RolesceneController:getInstance():getIsInChiefWar() then
							local bool = (value ==1) or false
							self:showBattleEffect(bool)
						end
					end
				end)
			end
		end
	-- end
end

--==============================--
--desc:改变形象
--time:2017-10-12 04:11:07
--@return 
--==============================--
function RoleScenePlayer:changeLooks()
	if self.vo == nil then return end
	local looks_vo = self.vo:getLooksByType(RoleSceneVo.lookstype.body)
	if looks_vo == nil then return end
	local val = looks_vo.looks_val 		-- 外观值,从伙伴配置表获取
	if val == nil or val == 0 then return end

	--有时装就不读伙伴表了，有时装读时装表
	local res_id 
	if looks_vo.looks_mode == 1 then 
		local fashion_to_config = Config.ClothesData.data_fashion_to_partner[val]
		if not fashion_to_config then return end
		if fashion_to_config and fashion_to_config[1] and fashion_to_config[1].partner_bid then
			local partner_bid = fashion_to_config[1].partner_bid
			local fashion_config = Config.ClothesData.data_clothes_data[partner_bid]
			if fashion_config and fashion_config[val] then 
				res_id =fashion_config[val].model or ""
			end
		end
	else
		local config = Config.PartnerData.data_partner[val]
		if config == nil then return end
		res_id =config.res_id or ""
	end
	if not res_id then return end
	if self.body_spine_name ~= nil and self.body_spine_name == res_id then return end
	self:playActionOnce(self.base_action_name,res_id)
end

--==============================--
--desc:增加buff形象
--time:2017-10-12 04:11:07
--@return 
--==============================--
function RoleScenePlayer:changeBuffLooks()
	if self.vo == nil then return end
	local looks_vo = self.vo:getLooksByType(RoleSceneVo.lookstype.buff)
	local role = RoleController:getInstance():getRoleVo()
	if looks_vo == nil or next(looks_vo) == nil then 
		if self.buff_effect then 
			self.buff_effect:runAction(cc.RemoveSelf:create(true))
			self.buff_effect = nil
		end
		self:showHeroArrow()
		return 
	end
	if not self.buff_effect then 
		if Config.ChiefWarData.data_chief_const and Config.ChiefWarData.data_chief_const["chief_mark"] and Config.ChiefWarData.data_chief_const["chief_mark"].val then
			local id= Config.ChiefWarData.data_chief_const["chief_mark"].val
			local effect_id = Config.EffectData.data_effect_info[id] or ""
			self.buff_effect = createEffectSpine( effect_id, cc.p(0,7), cc.p(0.5, 0.5), true,"action")
			self.topContainer:addChild(self.buff_effect,10)
		end
	end
	--更新下箭头的位置
	self:showHeroArrow()
end

function RoleScenePlayer:doMove(start_pos, end_pos)	
	if self.vo == nil then return end
	start_pos = start_pos or self.world_pos
	if start_pos.x == end_pos.x and  start_pos.y == end_pos.y then return end
	local tilePos = TileUtil.changeToTilePoint(end_pos)
	if Astar:getInstance():isBlock(tilePos.x, tilePos.y) then return end
	self:setWorldPos(start_pos)

    local speed_add = (1- (1-FPS_RATE)*0.5)
	self.move_speed = math.min(20, (self.mechine_speed + self.vo:getSpeed()) / speed_add)
	
	self.move_pass_distance = 0
	self.move_total_distance = 0
	self.move_start_pos = start_pos
	self.move_end_pos = end_pos
	self.dir_number, self.move_total_distance, self.move_dir = self:computeMoveInfo(end_pos)
	self.isNeedRun = true
	
	if self.dir_number ~= self.dir then
		self:setDir(self.dir_number)
	end    
	self:doRun()
end

--停止移动
function RoleScenePlayer:stopMove()
    if not self.isRuning then return end
	self.isRuning = false
	self.isNeedRun  = false
	self:doStand()
	if self.is_hero then
		local pos = self:getWorldPos()
		if pos == nil then return end
		RolesceneController:getInstance():move(pos,self.dir)
	end
end

function RoleScenePlayer:computeMoveInfo(end_pos)
    local cur_start_pos = cc.p(self.world_pos.x, self.world_pos.y)
    local cur_end_pos = end_pos
	local state_move_dir = cc.pSub(cur_end_pos, cur_start_pos)
	local distance = cc.pGetLength(state_move_dir)
	state_move_dir = cc.pNormalize(state_move_dir)
	local dir_number = GameMath.GetDirectionNumberHV(state_move_dir)
	if RolesceneController:getInstance():getIsInChiefWar() == true then
		dir_number = GameMath.GetDirectionNumberHVII(state_move_dir)
	end
 	return dir_number, distance, state_move_dir
end

function RoleScenePlayer:update(dt, step)
	if self.isNeedRun then
		self:step(dt)
    end
	SceneObj.update(self,dt)
	self:updateNamePos()
end

function RoleScenePlayer:step( dt )
	if self.vo == nil then return end
	if self.move_pass_distance >= self.move_total_distance then
		self.move_pass_distance = 0

		local pos = cc.p(self.move_end_pos.x, self.move_end_pos.y)
		self.isRuning = false
		self.isNeedRun  = false
		self:doStand()

		if self.is_hero then
			RolesceneController:getInstance():move(self.move_end_pos, self.dir)
			GlobalEvent:getInstance():Fire(SceneEvent.SCENE_WALKEND, pos)
			self.stepPost = 0
		end
	else
		self.move_pass_distance = math.min(self.move_pass_distance + self.move_speed, self.move_total_distance)
		local mov_dir = cc.pMul(self.move_dir, self.move_pass_distance) 
		local now_pos = cc.p(self.move_start_pos.x, self.move_start_pos.y)
		now_pos = cc.pAdd(now_pos, mov_dir)
        now_pos.x = now_pos.x
        now_pos.y = now_pos.y
		self:setWorldPos(now_pos)
		self.isRuning = true
		if self.is_hero then
            self.stepPost = self.stepPost + 1
			if MapUtil.isOnRange( self.move_end_pos, now_pos, self.move_speed ) then --拐点
				-- GlobalEvent:getInstance():Fire(SceneEvent.SCENE_WALKING, now_pos)
				GlobalEvent:getInstance():Fire(SceneEvent.SCENE_WALKNEXT, now_pos)
                RolesceneController:getInstance():move(self.world_pos, self.dir)
            else

				-- if self.stepPost % 42 == 0 then
	            --     RolesceneController:getInstance():move(self.world_pos, self.dir)
				-- end
                local pass_distance = math.floor(self.move_pass_distance) + self.move_speed
                if pass_distance % 51 < self.move_speed then
	                RolesceneController:getInstance():move(self.world_pos, self.dir)
                    -- GlobalEvent:getInstance():Fire(SceneEvent.SCENE_WALKING, now_pos)
                end
                -- if SceneModel:getInstance():isOnTeam() then
                --     if pass_distance % 100 < self.move_speed then
                --         SceneController:getInstance():move(self.world_pos, self.dir)
                --     end
	            --[[else]]if pass_distance % 100 < self.move_speed then
	                -- RolesceneController:getInstance():move(self.world_pos, self.dir)
	            end
			end
		end
	    local speed_add = (1- (1-FPS_RATE)*0.5)
		self.move_speed = math.min(20, (self.mechine_speed + self.vo:getSpeed()) / speed_add)
	end
end
--创建自身角色箭头
function RoleScenePlayer:showHeroArrow()
	--自己要显示个箭头
	local role_vo = RoleController:getInstance():getRoleVo()
	if role_vo.rid == self.vo.rid and role_vo.srv_id == self.vo.srv_id then 
		if not self.arrow_effect then 
			local effect_id = Config.EffectData.data_effect_info[122] or ""
			self.arrow_effect = createEffectSpine( effect_id, cc.p(0,65), cc.p(0.5, 0.5), true,"action")
			self.topContainer:addChild(self.arrow_effect,10)
		end
	end
	
	if self.buff_effect and not tolua.isnull(self.buff_effect) then 
		if self.arrow_effect and not tolua.isnull(self.arrow_effect) then 
			self.arrow_effect:setPosition(cc.p(0,65))
		end
	else 
		if self.arrow_effect and not tolua.isnull(self.arrow_effect) then 
			self.arrow_effect:setPosition(cc.p(0,27))
		end
	end
end
--==============================--
--desc:注册事件
--time:2017-10-12 04:24:22
--@return 
--==============================--
function RoleScenePlayer:registEvent()
	self.main_container:setTouchEnabled(true)
	self.main_container:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			self:clickHandler()
		end
	end)

end

function RoleScenePlayer:clickHandler()
	if self.is_hero then return end
	GlobalEvent:getInstance():Fire(SceneEvent.SCENE_PLAYER_CLICK, self.vo)
end

function RoleScenePlayer:__delete()
	self.dir_number = 0
    if self.vo ~= nil then
		if self.role_attr_change ~= nil then
			self.vo:UnBind(self.role_attr_change)
			self.role_attr_change = nil
		end
	end

end