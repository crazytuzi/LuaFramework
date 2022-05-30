--[[
    * 类注释写在这里-----------------
    * @author {AUTHOR}
    * <br/>Create: 2016-12-20
]]
MainuiModel = MainuiModel or BaseClass()

MainuiModel.DUN_ENTER_BIND_ID = {
    TitanTemple = 1,        --泰坦
    Meterial = 2,           --巨龙
    Trialtower = 3,         --试炼塔
    Equip = 4,              --装备副本
    Expedition = 5,         --远征
    OutsiderCrack = 6,         --异界裂缝
}

function MainuiModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
    
end

function MainuiModel:config()
    self.buff_list = {}
end

--存储战斗外buff列表
function MainuiModel:setExtendBuff(data)
    self.buff_list = data
end

--获取战斗外buff列表
function MainuiModel:getExtendBuff()
    return self.buff_list
end

function MainuiModel:__delete()
end