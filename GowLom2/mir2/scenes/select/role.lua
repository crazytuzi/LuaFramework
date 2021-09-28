local function getBeginID(work, sex, unselect)
	return work*40 + math.max(0, sex - 1)*120 + ((unselect and 20) or 0)
end

local role = class("role", function ()
	return display.newNode()
end)

table.merge(scene, {})

role.ctor = function (self, work, sex, state)
	local posy = 170
	local posx = 0
	local posOff = {
		{
			posx,
			posy + 10
		},
		{
			posx,
			posy + 20
		},
		{
			posx,
			posy
		},
		{
			posx,
			posy
		},
		{
			posx + 5,
			posy
		},
		{
			posx + 10,
			posy
		}
	}
	local anchorIndex = work + (sex - 1)*3
	local beginid = getBeginID(work, sex, state)
	self.sprite = res.get("chrsel", beginid):addto(self):pos(posOff[anchorIndex][1], posOff[anchorIndex][2])
	self.work = work
	self.sex = sex
	self.effect = nil

	return 
end
role.setState = function (self, state)
	if state == "new" then
		self.sprite:opacity(0):fadeIn(0.5):run(cc.CallFunc:create(function ()
			self:setState("normal")

			return 
		end))
	elseif state == "normal" then
		local beginid = getBeginID(self.work, self.sex)

		self.sprite.run(slot3, cc.RepeatForever:create(cc.Animate:create(res.getani("chrsel", beginid, beginid + 15, 0.15))))
	elseif state == "stone" then
		local beginid = getBeginID(self.work, self.sex, true)
		local tex = res.gettex("chrsel", beginid)

		self.sprite:setTex(tex)
	elseif state == "selected" then
		self.sprite:stopAllActions()

		local beginid = getBeginID(self.work, self.sex, true)

		self.sprite:runs({
			cc.Animate:create(res.getani("chrsel", beginid, beginid + 12, 0.1)),
			cc.CallFunc:create(function ()
				self:setState("normal")

				return 
			end)
		})

		self.effect = m2spr.new("chrsel", 4, {
			blend = true
		})

		self.effect.spr.addto(slot3, self):pos(15, 175)
		self.effect:playAni("chrsel", 4, 14, 0.1, true, nil, true, function ()
			self.effect:removeSelf()

			self.effect = nil

			return 
		end)
	elseif state == "unselected" then
		if self.effect then
			self.effect.removeSelf(slot2)

			self.effect = nil
		end

		self.sprite:stopAllActions()

		local beginid = getBeginID(self.work, self.sex, true)
		local animation = res.getani("chrsel", beginid, beginid + 12, 0.1, nil, true)

		self.sprite:runs({
			cc.Animate:create(animation),
			cc.CallFunc:create(function ()
				self:setState("stone")

				return 
			end)
		})
	end

	return self
end

return role
