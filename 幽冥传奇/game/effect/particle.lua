------------------------------------------------------
--特效粒子
--@author bzw
------------------------------------------------------

Particle = Particle or BaseClass()
function Particle:__init()
	self.move_speed = 0								-- 移动速度
	self.move_type = nil							-- 运动方式
	self.move_param_1 = 5
	self.move_param_2 = 3			

	self.rotation = 0								-- 当前角度
	self.rotation_speed = 0							-- 角度旋转速度
	self.act_name = nil

	self.scale = 1 									-- 当前缩放系数
		
	self.move_rect = nil							-- 移动区域
	self.is_auto_destory = true 					-- 是否自行销毁
	self.lief_cycle = 0 							-- 生存周期（0，无限存在）
	
	self.pos_x = 0									-- 当前位置x
	self.pos_y = 0									-- 当前位置y
	self.is_moveing = false							-- 是否在移动中
	self.lief_end_callback = nil					-- 生命结束时回调

	self.particle_id = nil
	self.particle_name = nil

	self.sprite = AnimateSprite:create()
	self.sprite:retain()							-- 保持引用

	self.delay_line_end = nil
end

function Particle:__delete()
	self:ClearDelayLifeEnd()
	self.sprite:release()
	self.lief_end_callback = nil
end

function Particle:GetParticleName()
	return self.particle_name
end

function Particle:SetParticleName(particle_name)
	self.particle_name = particle_name
end

function Particle:GetParticleId(particle_id)
	return self.particle_id
end

function Particle:SetParticleId(particle_id)
	self.particle_id = particle_id
end


--设置粒子自身动画
function Particle:SetAnimation(anim_path, anim_name, loops)
	loops = loops or 1
	if loops >= 10 then loops = COMMON_CONSTS.MAX_LOOPS end
	self.sprite:setAnimate(anim_path, anim_name, loops, 0.1, false)

	self:ClearDelayLifeEnd()
	self.delay_line_end = GlobalTimerQuest:AddDelayTimer(BindTool.Bind1(self.LiefEnd, self), 10)
end

--设置粒子纹理
function Particle:SetTexture(path)
	local sprite_frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(path)
	self.sprite:setSpriteFrame(sprite_frame)
end

--设置移动区域，超出将销毁
function Particle:SetMoveRect(rect)
	self.move_rect = rect
end

--设置是否自行销毁
function Particle:SetIsAutoDestory(is_auto_destory)
	self.is_auto_destory = is_auto_destory

	if is_auto_destory then
		ParticleEffectSys.Instance:AddFreeParticle(self)
	end
end

--设置角度
function Particle:SetRotation(rotation)
	self.rotation = rotation
	self.sprite:setRotation(rotation)
end

--设置缩放系数
function Particle:SetScale(scale)
	self.sprite:setScale(scale)
end

--设置透明度
function Particle:SetOpacity(opacity)
	self.sprite:setOpacity(opacity)
end

--设置运动方式
function Particle:SetMoveType(move_type, move_param)
	self.move_type = move_type
	if move_param ~= nil then
		self.move_param_1 = move_param.param1
		self.move_param_2 = move_param.param2
	end
	self.move_param = move_param
end

--设置角度速度
function Particle:SetRotationSpeed(rotation_speed)
	self.rotation_speed = rotation_speed
end

--设置移动速度
function Particle:SetMoveSpeed(move_speed)
	self.move_speed = move_speed 
end

function Particle:SetParticleActName(act_name)
	self.act_name = act_name
end

--设置生命到时回调
function Particle:SetLiefEndCallback(lief_end_callback)
	self.lief_end_callback = lief_end_callback
end

--返回粒子实体
function Particle:GetSprite()
	return self.sprite
end

--被发射时调用
function Particle:Emited(pos_x, pos_y)
	self.pos_x = pos_x
	self.pos_y = pos_y
	self.sprite:setPosition(self.pos_x, self.pos_y)
	
	self.sprite:stopAllActions()
	if self.act_name ~= nil then
		local act = CCActionEdit.Instance:CreateCCAction(self.act_name)
		if act ~= nil then
			self.sprite:runAction(act)
		end
	end
	
	self:StartMove()
end

--开始移动
function Particle:StartMove()
	if self.is_moveing then
		return
	end

	self.is_moveing = true
	Runner.Instance:AddRunObj(self, 1)
end

--停止移动
function Particle:StopMove()
	if not self.is_moveing then
		return
	end

	self.is_moveing = false
	Runner.Instance:RemoveRunObj(self)
end

--生命结束
function Particle:LiefEnd()
	self:ClearDelayLifeEnd()
	self.sprite:setStop()
	self.sprite:stopAllActions()
	self.sprite:removeFromParent()

	if self.lief_end_callback then
		self.lief_end_callback(self)
	end

	if self.is_auto_destory then
		self:Destory()

		ParticleEffectSys.Instance:RemoveFreeParticle(self)
	end
end

function Particle:KillForever()
	self:SetIsAutoDestory(false)
	self:SetLiefEndCallback(nil)
	self:StopMove()
	self:LiefEnd()
end

function Particle:ClearDelayLifeEnd()
	if self.delay_line_end then
		GlobalTimerQuest:CancelQuest(self.delay_line_end)
		self.delay_line_end = nil
	end
end

--销毁粒子
function Particle:Destory()
	self:DeleteMe()
end

function Particle:Update(now_time, elapse_time)
	if not self.is_moveing then
		return
	end

	if self.move_type == "sinx_line" then
		self.pos_x = self.pos_x + self.move_param_1 * math.sin(self.pos_y / self.move_param_2)
		self.pos_y = self.pos_y + self.move_speed
		self.sprite:setPosition(self.pos_x, self.pos_y)
	end

	if self.move_type == "liney" then
		self.pos_y = self.pos_y + self.move_speed
		self.sprite:setPosition(self.pos_x, self.pos_y)
	end
	if self.pos_y < self.move_rect.y and self.move_speed < 0 then
		self:StopMove()
		self:LiefEnd()
	end
	if self.pos_y > self.move_rect.height and self.move_speed > 0 then
		self:StopMove()
		self:LiefEnd()
	end
end

