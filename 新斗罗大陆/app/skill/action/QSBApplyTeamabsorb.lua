--
local QSBAction = import(".QSBAction")
local QSBApplyTeamabsorb = class("QSBApplyTeamabsorb", QSBAction)

-- {
-- 	CLASS = "action.QSBApplyTeamabsorb",
-- 	OPTIONS = {duration = 时间, effect_id = "特效id", effect_pos = {x = 300, y = 300}, attack_percent = 护盾攻击力百分比, hp_percent = 护盾血量百分比, decrease_hp_by_absorb_toal = 转伤害百分比}
-- }

function QSBApplyTeamabsorb:_execute(dt)
	if self._absorb_tbl == nil then
		local teammates = app.battle:getMyTeammates(self._attacker, false, true)
		local absorb_tbl = {absorb = 0}
		if self._options.attack_percent then
			absorb_tbl.absorb = absorb_tbl.absorb + self._options.attack_percent * self._attacker:getAttack()
		end

		for i, hero in ipairs(teammates) do
			absorb_tbl.absorb = absorb_tbl.absorb + hero:getMaxHp() * (self._options.hp_percent or 1)
			hero:setGroupAbsorb(absorb_tbl)
		end

		self._total_absorb = absorb_tbl.absorb
		self._teammates_applyed = teammates
		self._passed_time = 0
		self._absorb_tbl = absorb_tbl

		if self._options.effect_id and not IsServerSide then
			self._effect = app.scene:playSceneEffect(self._options.effect_id, self._options.effect_pos, false, true)
		end
	end

	if self._absorb_tbl and (self._absorb_tbl.absorb <= 1e-6 or self._passed_time > (self._options.duration or 5)) then
		if self._options.decrease_hp_by_absorb_toal and self._options.decrease_hp_by_absorb_toal > 0 then
			local enemies = app.battle:getMyEnemies(self._attacker)
			if #enemies > 0 then
				local pve_dmg = app.battle:isPVPMode() == false and self._options.pve_cofficient or 1
				local total_damage = self._total_absorb * self._options.decrease_hp_by_absorb_toal * self:getDragonModifier() * pve_dmg 
				local damage = math.min(total_damage/ #enemies, total_damage * (self._options.damage_limit_percent or 1))
				local override_damage = {
					damage = damage,
					tip = "-",
					hit_status = "hit"
				}
				for i, hero in ipairs(enemies) do
					self._attacker:hit(self._skill, hero, nil, override_damage, nil, true)
				end
			end
		end

		for i, hero in ipairs(self._teammates_applyed) do
			hero:removeGroupAbsorb(self._absorb_tbl)
		end
		self:removeAllEffect()
		self:finished()
	end

	self._passed_time = self._passed_time + dt
end

function QSBApplyTeamabsorb:removeAllEffect()
	if not IsServerSide or self._options.effect_id == nil then
		return
	end
	if self._effect then
		app.scene:removeEffectViews(self._effect)
	end
end

function QSBApplyTeamabsorb:_onCancel()
	self:_onRevert()
end

function QSBApplyTeamabsorb:_onRevert()
	if not IsServerSide then
		self:removeAllEffect()
		if self._teammates_applyed then
			for i, hero in ipairs(self._teammates_applyed) do
				hero:removeGroupAbsorb(self._absorb_tbl)
			end
		end
	end
end

return QSBApplyTeamabsorb