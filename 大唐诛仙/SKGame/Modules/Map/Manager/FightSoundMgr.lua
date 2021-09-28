FightSoundMgr =BaseClass()
function FightSoundMgr:__init(career)
	self.career = career
	self.cfg = GetCfgData( "newroleDefaultvalue" ):Get(self.career)
	self.attackAudio = self.cfg.attackAudio
	self.hurtAudio = self.cfg.hurtAudio
	self.deadAudio = self.cfg.deadAudio
	self.hitOnAudio = self.cfg.hitOnAudio
end

--攻击
function FightSoundMgr:Attack()
	if not self.attackAudio then return end
	if math.random(2) == 1 then
		soundMgr:PlayEffect(tostring(self.attackAudio))
	end
end

--受击
function FightSoundMgr:Hurt()
	if not self.hurtAudio then return end
	soundMgr:PlayEffect(tostring(self.hurtAudio))
end

--死亡
function FightSoundMgr:Dead()
	if not self.deadAudio then return end
	soundMgr:PlayEffect(tostring(self.deadAudio))
end

--命中
function FightSoundMgr:hitOn()
	if not self.hitOnAudio then return end
	soundMgr:PlayEffect(tostring(self.hitOnAudio))
end

function FightSoundMgr:__delete()
	self.attackAudio = nil
	self.hurtAudio = nil
	self.deadAudio = nil
	self.hitOnAudio = nil
end