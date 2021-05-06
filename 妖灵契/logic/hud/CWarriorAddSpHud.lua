local CWarriorAddSpHud = class("CWarriorAddSpHud", CAsyncHud)
CWarriorAddSpHud.EFFECT_PATH = "Effect/UI/ui_eff_1158/Prefabs/ui_eff_1158_mange_huo_03.prefab"

function CWarriorAddSpHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/WarriorAddSpHud.prefab", cb, true)
end

function CWarriorAddSpHud.OnCreateHud(self)
	self.m_TargetPos = nil
	self:Recycle()
end

function CWarriorAddSpHud.InitTargetPos(self)
	local oView = CWarMainView:GetView()
	if oView then
		local oTarget = oView.m_RB.m_SpSlider
		self.m_TargetPos = oTarget:GetPos()
	end
	return self.m_TargetPos
end

--一个火焰代表半格怒气（目前效果最小单位为半格）
--举例：绿狸用了加怒技能加了一格怒气，从绿狸身上飘2个火焰到怒气条位置
function CWarriorAddSpHud.ShowWarAddSpEffect(self, iSp)
	if not self.m_TargetPos then
		self:InitTargetPos()
	end
	if self.m_TargetPos then
		local idx = 0
		local function update()
			if Utils.IsNil(self) then
				return
			end
			idx = idx + 1
			if idx <= iSp then
				CEffect.New(CWarriorAddSpHud.EFFECT_PATH, nil, true, callback(self, "OnLoadDone"))
				return true
			end
			return false
		end
		self.m_EffectTimer = Utils.AddTimer(update, 0.5, 0)
	end
end

function CWarriorAddSpHud.OnLoadDone(self, oEffect)
	if oEffect then
		oEffect:SetParent(self.m_Transform)
		oEffect:SetLocalPos(Vector3.zero)
		local tween = DOTween.DOMove(oEffect.m_Transform, self.m_TargetPos, 1.5)						
		DOTween.SetEase(tween, enum.DOTween.Ease.InOutQuad)
		DOTween.OnComplete(tween, function ()
			oEffect:Destroy()
		end)
	end
end

function CWarriorAddSpHud.Recycle(self)

end

return CWarriorAddSpHud