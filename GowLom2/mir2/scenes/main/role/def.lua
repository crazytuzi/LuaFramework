local def = {}

table.merge(def, import(".def.weapon"))
table.merge(def, import(".def.hp"))
table.merge(def, import(".def.state"))

def.humFrame = 600
def.size = {
	w = 50,
	h = 85
}
def.speed = {
	fast = 0.2,
	attack = 0.9,
	spell = 0.4,
	rush = 0.3,
	rushKung = 0.3,
	normal = 0.6
}
def.state = {}
def.dir = {
	leftUp = 7,
	rightUp = 1,
	left = 6,
	up = 0,
	leftBottom = 5,
	rightBottom = 3,
	bottom = 4,
	right = 2,
	_0 = {
		0,
		-1
	},
	_1 = {
		1,
		-1
	},
	_2 = {
		1,
		0
	},
	_3 = {
		1,
		1
	},
	_4 = {
		0,
		1
	},
	_5 = {
		-1,
		1
	},
	_6 = {
		-1,
		0
	},
	_7 = {
		-1,
		-1
	}
}
def.namecolorcnt = 9
def.namecolors = {
	249,
	216,
	250,
	252,
	253,
	255,
	152,
	149,
	70
}
def.config = {
	dress = json.decode(res.getfile("config/dress.txt")),
	weapon = json.decode(res.getfile("config/weapon.txt"))
}
def.dress = function (dressid)
	return def.config.dress[tostring(dressid)] or {}
end
def.weapon = function (weapon)
	return def.config.weapon[tostring(weapon)] or {}
end
def.hair = function (feature)
	if feature.get(feature, "sex") == 0 then
		local hairs = {
			{
				"hair",
				0
			},
			{
				"hair",
				4
			},
			{
				"hair2",
				6
			},
			{
				"hair2",
				7
			}
		}
		local ret = hairs[feature.get(feature, "hair") + 1] or {
			"hair",
			0
		}

		return unpack(ret)
	else
		local hairs = {
			{
				"hair",
				3
			},
			{
				"hair",
				5
			},
			{
				"hair2",
				6
			},
			{
				"hair2",
				7
			}
		}
		local ret = hairs[feature.get(feature, "hair") + 1] or {
			"hair",
			0
		}

		return unpack(ret)
	end

	return 
end
def.getMoveDir = function (destx, desty, x, y)
	local offX = x - destx
	local offY = y - desty
	local angle = math.atan(offY/offX)

	if angle <= math.pi/8 and -math.pi/8 < angle then
		if 0 < offX then
			return def.dir.right
		else
			return def.dir.left
		end
	elseif angle < (math.pi*3)/8 and math.pi/8 < angle then
		if 0 < offX then
			return def.dir.rightBottom
		else
			return def.dir.leftUp
		end
	elseif offX == 0 or (math.pi*3)/8 <= angle or angle < (-math.pi*3)/8 then
		if 0 < offY then
			return def.dir.bottom
		elseif offY == 0 then
			return 
		else
			return def.dir.up
		end
	elseif angle <= -math.pi/8 and (-math.pi*3)/8 < angle then
		if offY < 0 then
			return def.dir.rightUp
		else
			return def.dir.leftBottom
		end
	end

	return def.dir.bottom
end
def.getAttackDir = function (destx, desty, x, y)
	local disx = math.abs(x - destx)
	local disy = math.abs(y - desty)
	local dir = nil

	if disx <= 1 then
		dir = (y < desty and def.dir.up) or def.dir.bottom
	elseif x < destx then
		if disy <= 1 then
			dir = def.dir.left
		elseif y < desty then
			dir = def.dir.leftUp
		else
			dir = def.dir.leftBottom
		end
	elseif destx < x then
		if disy <= 1 then
			dir = def.dir.right
		elseif y < desty then
			dir = def.dir.rightUp
		else
			dir = def.dir.rightBottom
		end
	end

	return dir
end

return def
