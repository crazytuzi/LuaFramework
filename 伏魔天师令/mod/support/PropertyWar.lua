-- {人物战斗属性}
local PropertyWar = classGc(function(self)
    self.is_data      = 0 --是否有数据 false:没 true:有
    self.sp           = 0 --怒气
    self.hp           = 0 --气血值
    self.strong_att   = 0 --力量物理攻击
    self.strong_def   = 0 --力量物理防御值
    self.wreck        = 0 --破甲
    self.hit          = 0 --命中 -未见有人物
    self.dodge        = 0 --躲避 -未见有人物
    self.crit         = 0 --暴击
    self.crit_res     = 0 --抗暴
    self.bonus        = 0 --伤害率
    self.reduction    = 0 --免伤率
    self.funList      = {}

    self:initFunlist()
end)

function PropertyWar.clone(self)
    local cloneSelf = PropertyWar()
    for k,v in pairs(self) do
        cloneSelf[k]=v
    end
    return cloneSelf
end

function PropertyWar.initFunlist( self )
    self.funList[_G.Const.CONST_ATTR_SP]                 = self.setSp                --怒气
    self.funList[_G.Const.CONST_ATTR_HP]                 = self.setNowMaxHp          --气血值
    self.funList[_G.Const.CONST_ATTR_STRONG_ATT]         = self.setStrongAtt         --物攻
    self.funList[_G.Const.CONST_ATTR_STRONG_DEF]         = self.setStrongDef         --物防
    self.funList[_G.Const.CONST_ATTR_DEFEND_DOWN]        = self.setWreck             --破甲
    self.funList[_G.Const.CONST_ATTR_HIT]                = self.setHit               --命中 -未见有人物
    self.funList[_G.Const.CONST_ATTR_DODGE]              = self.setDodge             --躲避 -未见有人物
    self.funList[_G.Const.CONST_ATTR_CRIT]               = self.setCrit              --暴击
    self.funList[_G.Const.CONST_ATTR_RES_CRIT]           = self.setCritRes           --抗暴
    self.funList[_G.Const.CONST_ATTR_BONUS]              = self.setBonus             --伤害率
    self.funList[_G.Const.CONST_ATTR_REDUCTION]          = self.setReduction         --免伤率
end

-- {是否有数据 false:没 true:有}
function PropertyWar.getIsData(self)
    return self.is_data
end
function PropertyWar.setIsData(self, _isData)
    self.is_data = _isData
end

-- {怒气}
function PropertyWar.getSp(self)
    return self.sp
end
function PropertyWar.setSp(self, _sp)
    self.sp = _sp
end

-- {气血值}
function PropertyWar.getHp(self)
    return self.hp
end
function PropertyWar.setHp(self, _hp)
    self.hp = _hp
    if self : getMaxHp() == nil or self : getMaxHp() < _hp then
        self : setMaxHp( _hp )
    end
end
-- {最大气血值}
function PropertyWar.getMaxHp(self)
    return self.maxhp
end
function PropertyWar.setMaxHp(self, _hp)
    self.maxhp = _hp
end

function PropertyWar.getNowMaxHp(self)
    return self.nowMaxHp
end
function PropertyWar.setNowMaxHp(self, _hp)
    self.nowMaxHp = _hp
    self : setMaxHp(_hp)
    self : setHp(_hp)
end

-- {力量物理攻击}
function PropertyWar.getStrongAtt(self)
    return self.strong_att
end
function PropertyWar.setStrongAtt(self, _strongAtt)
    self.strong_att = _strongAtt
end

-- {力量物理防御值}
function PropertyWar.getStrongDef(self)
    return self.strong_def
end
function PropertyWar.setStrongDef(self, _strongDef)
    self.strong_def = _strongDef
end

-- {破甲值}
function PropertyWar.getWreck(self)
    return self.wreck
end
function PropertyWar.setWreck(self, _wreck)
    self.wreck = _wreck
end

-- {命中值}
function PropertyWar.getHit(self)
    return self.hit
end
function PropertyWar.setHit(self, _hit)
    self.hit = _hit
end

-- {躲避值}
function PropertyWar.getDodge(self)
    return self.dodge
end
function PropertyWar.setDodge(self, _dodge)
    self.dodge = _dodge
end

-- {暴击值}
function PropertyWar.getCrit(self)
    return self.crit
end
function PropertyWar.setCrit(self, _crit)
    self.crit = _crit
end

-- {抗暴值}
function PropertyWar.getCritRes(self)
    return self.crit_res
end
function PropertyWar.setCritRes(self, _critRes)
    self.crit_res = _critRes
end

-- {伤害率}
function PropertyWar.getBonus(self)
    return self.bonus
end
function PropertyWar.setBonus(self, _bonus)
    self.bonus = _bonus
end

-- {免伤率}
function PropertyWar.getReduction(self)
    return self.reduction
end
function PropertyWar.setReduction(self, _reduction)
    self.reduction = _reduction
end

-- {更新数据  根据类型}
function PropertyWar.updateProperty( self, _type, _value )
    local func=self.funList[_type]
    if func~=nil then
        func(self,_value)
    end
end

return PropertyWar
