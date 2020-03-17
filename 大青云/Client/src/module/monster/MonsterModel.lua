_G.classlist['MonsterModel'] = 'MonsterModel'
_G.MonsterModel = MonsterModel or {
	AllNodes = {},
	StoryNodes = {}
}

MonsterModel.objName = 'MonsterModel'

function MonsterModel:DeleteAllMonster()
	self.AllNodes = {}
end

function MonsterModel:GetMonsterList()
	return self.AllNodes
end

function MonsterModel:AddMonster(monster)
	self.AllNodes[monster.cid] = monster
end

function MonsterModel:DeleteMonsterByCid(cid)
	self.AllNodes[cid] = nil
end

function MonsterModel:GetMonster(cid)
	return self.AllNodes[cid]
end

function MonsterModel:GetMonsterByTid(tid)
	for _, monster in pairs(self.AllNodes) do
		if monster:GetMonsterId() == tid then
			return monster
		end
	end
end

function MonsterModel:GetMonsterNum()
	local count = 0
	for _, v in pairs(self.AllNodes) do
		if v ~= nil then
			count = count + 1;
		end
	end
	return count
end

function MonsterModel:GetMonsterRadom()
	local randomNum = math.random(1,self:GetMonsterNum())

	local count = 0
	for _, v in pairs(self.AllNodes) do
		if v ~= nil then
			count = count + 1;
		end
		if count >= randomNum then
			if not v:IsHide() and v.monstersay and #v.monstersay >0 then
				local randomSay = math.random(1, #v.monstersay)
				return v, v.monstersay[randomSay]
			end
		end
	end
	return nil
end

-----------------------------------------剧情怪--------------------------------------------
function MonsterModel:DeleteAllStoryMonster()
	self.StoryNodes = {}
end

function MonsterModel:GetStoryMonsterList()
	return self.StoryNodes
end

function MonsterModel:AddStoryMonster(mid, monster)
	self.StoryNodes[mid] = monster
end

function MonsterModel:DeleteStoryMonster(mid)
	self.StoryNodes[mid] = nil
end

function MonsterModel:GetStoryMonster(mid)
	return self.StoryNodes[mid]
end

function MonsterModel:GetStoryMonsterNum()
	local count = 0
	for _, v in pairs(self.StoryNodes) do
		if v ~= nil then
			count = count + 1;
		end
	end
	return count
end