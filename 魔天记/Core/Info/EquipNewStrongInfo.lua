require "Core.Info.BaseAttrInfo";
EquipNewStrongInfo = class("EquipNewStrongInfo", BaseAttrInfo); 

function EquipNewStrongInfo:New()
    self = { };
    setmetatable(self, { __index = EquipNewStrongInfo });
    self:_InitProperty()
    return self
end
 local property = {
        'hp_max',
        'hp_max_per',    
        'phy_att',
        -- 'mag_att',
        'phy_def',
        -- 'mag_def',
        'hit',
        'eva',
        'crit',
        'tough',
        'fatal',
        'block',        
		'att_dmg_rate',       
        'phy_att_per',
        -- 'mag_att_per',
        'dmg_rate'
    }

function EquipNewStrongInfo:GetProperty()
    return property
end 