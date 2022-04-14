--
-- @Author: LaoY
-- @Date:   2019-03-27 10:46:05
--
--require("game.xx.xxx")

SceneShootEffect = SceneShootEffect or class("SceneShootEffect",SceneEffect)

function SceneShootEffect:ctor(parent,abName,effect_type,cls)
	self.position = {x = 0,y = 0}
	EffectManager:GetInstance():AddSceneEffect(self.parent,self)
end

function SceneShootEffect:dctor()
	self:StopAction()
end

function SceneShootEffect:LoadCallBack()
	SceneShootEffect.super.LoadCallBack(self)
	-- start action
	if not self.config then
		return
	end

	-- self:StartAction()
end

function SceneShootEffect:StartAction()
	self:StopAction()
	local start_pos = self.config.start_pos
	local end_pos = self.config.pos
	local time = 1.0
	local action = cc.MoveTo(time,end_pos.x,end_pos.y)
	local function call_end()
		self:destroy()
	end
	action = cc.Sequence(action,cc.DelayTime(0),cc.CallFunc(call_end))
	cc.ActionManager:GetInstance():addAction(action,self)
end

function SceneShootEffect:StopAction()
	cc.ActionManager:GetInstance():removeAllActionsFromTarget(self)
end

function SceneShootEffect:SetPosition(x, y)
	if self.is_need_setconfig then
		SceneShootEffect.super.SetPosition(0,0)
		return
	end
	self.position = self.position or {x = 0,y = 0}
	self.position.x = x
	self.position.y = y

	if not self.transform then
		return
	end

	local z = self.position.z or LayerManager:GetInstance():GetSceneObjectDepth(y)
	SetGlobalPosition(self.transform, x / SceneConstant.PixelsPerUnit, y / SceneConstant.PixelsPerUnit, z)
end

function SceneShootEffect:GetPosition()
    return self.position
end

function SceneShootEffect:SetConfig(config)
	SceneShootEffect.super.SetConfig(config)
	if not self.is_need_setconfig then

	end
end