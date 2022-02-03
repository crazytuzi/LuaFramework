--[[
   场景npc
   @author cloud
   @date 2016.12.20
--]]
Npc = Npc or BaseClass(SceneObj)
function Npc:__init()

    self.move_start_pos = cc.p(0,0)
    self.move_end_pos = cc.p(0,0)
    self.move_total_distance = 0 
    self.move_pass_distance = 0
    self.move_dir = cc.p(0,0)
    self.move_speed = 6
    self.dir_number = 0 
    
    self.isRuning = false
    self.isNeedRun = false

    self.isTalking = false -- 正在说话

    self.imgNameH = 0 -- 45
    self.showImgName = false
end


-- 重写设置VO
function Npc:setVo( value )
	SceneObj.setVo(self, value)
	self.dir_number = value.dir==0 and 6 or value.dir
	local vo = self.vo
	
	self:setBattleStatus(self.vo.status)
	if self.update_self_event == nil then
		if self.vo ~= nil then
			self.update_self_event = self.vo:Bind(SceneEvent.UPDATE_UNIT_ATTRIBUTE, function(key, value)
				if key == "status" then
					self:setBattleStatus(self.vo.status)
				end
			end)
		end
	end
end

function Npc:setBattleStatus(status)
	if status == 0 then
		if self.fightEffect ~= nil then
            self.fightEffect:runAction(cc.RemoveSelf:create())
			self.fightEffect = nil
		end
	elseif status == 1 then
		local effect_id = PathTool.getEffectRes(196)
		if self.fightEffect == nil then
			self.fightEffect = createEffectSpine(effect_id, cc.p(0, 0), cc.p(0.5, 0), true)
			self.topContainer:addChild(self.fightEffect)
		end
	end
	self:updateEffectPos()
end

function Npc:registEvent()
end

function Npc:clickHandler()

end

function Npc:update()
	SceneObj.update(self)
	self:updateNamePos()
	if self.isNeedRun then
		self.move_pass_distance = self.move_pass_distance + self.move_speed
		if self.move_pass_distance >= self.move_total_distance then
			self.move_pass_distance = 0
			self:setWorldPos(cc.p(self.move_end_pos.x, self.move_end_pos.y))
			self.isRuning = false
			self.isNeedRun  = false
			self:doStand()
		else
			local mov_dir = cc.pMul(self.move_dir, self.move_pass_distance) 
			local now_pos = cc.p(self.move_start_pos.x, self.move_start_pos.y)
			now_pos = cc.pAdd(now_pos, mov_dir)
			self:setWorldPos(now_pos)
			self.isRuning = true
		end
	end
end

--==============================--
--desc:计算这次移动的朝向
--time:2017-09-12 10:35:07
--@end_pos:
--@start_pos:
--@return 
--==============================--
function Npc:computeMoveInfo(end_pos, start_pos)
    local cur_start_pos = cc.p(self.world_pos.x, self.world_pos.y)
    local cur_end_pos = end_pos
	local state_move_dir = cc.pSub(cur_end_pos, cur_start_pos)
	local distance = cc.pGetLength(state_move_dir)
	state_move_dir = cc.pNormalize(state_move_dir)
 	local dir_number = GameMath.GetDirectionNumberHV(state_move_dir, self.dir_number)
 	return dir_number, distance, state_move_dir
end

--==============================--
--desc:设置这一次的移动的起点个重点,默认是当前起点
--time:2017-09-12 10:34:42
--@start_pos:
--@end_pos:
--@return 
--==============================--
function Npc:doMove(start_pos, end_pos)
	if start_pos == nil then
		start_pos = self.world_pos
	end
	if start_pos.x == end_pos.x and  start_pos.y == end_pos.y then return end
	self.move_pass_distance = 0
	self.move_total_distance = 0
	self.move_start_pos = start_pos
	self.move_end_pos = end_pos
	self.dir_number, self.move_total_distance, self.move_dir = self:computeMoveInfo(end_pos)
	self.isNeedRun = true
	self:setDir(self.dir_number)
	if not self.isRuning then
		self:doRun()
	end
end

function Npc:__delete()
	if self.update_self_event ~= nil and self.vo ~= nil then
		self.vo:UnBind(self.update_self_event)
		self.update_self_event = nil
	end
	self.isTalking = nil
	self.move_start_pos = nil
	self.move_end_pos = nil
	self.move_total_distance = nil
	self.move_pass_distance = nil
	self.move_dir = nil
	self.move_speed = nil
	self.dir_number = nil
	self.isRuning = nil
	self.isNeedRun = nil
	self.mission_effect = nil
end

-- 自动说话状态
function Npc:setTalkingState( bool )
	if self.boxHeight< 50 then
		return
	end
	if bool and self.isTalking then
		return
	end
	self.isTalking = bool
	if self.isTalking then
		local content_list = Config.UnitData.data_unit(self.vo.base_id).talk
		if content_list and #content_list >0 then
			 local ra = math.random(1,#content_list)			
			StoryView:showBubble(5, 1, self.vo.id,self.vo.battle_id, content_list[ra], nil, nil)
		end
	end
end

-- 自动说话状态
function Npc:getTalkingState()
	return self.isTalking
end

--更新名字位置
function Npc:updateNamePos()
	SceneObj.updateNamePos(self)
	if self.mission_effect then
		self.mission_effect:setPosition(cc.p(self.topContainer:getContentSize().width/2, 10))
		if StoryCtrl:getInstance():getData():isStoryState() then
			self.mission_effect:setVisible(false)
		else
			self.mission_effect:setVisible(true)
		end
	end
end

-- 设置特殊npc 头顶类型名字
function Npc:addImgName( bid )
	if Config.NpcHeadRes ~= nil then
		local path = PathTool.getNPCRes( Config.NpcHeadRes[bid] )
		if path then
			self:addTopObj( path, true)
			self.imgNameH = 35
		end
	end
end

-- 位置稍微小一点不要遮住人
function Npc:setZOrder(value)
    self.node:setLocalZOrder(value-30)
end