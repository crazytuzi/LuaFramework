local WiseEquipAttCtr = class("WiseEquipAttCtr")

function WiseEquipAttCtr:New()
    self = { };
    setmetatable(self, { __index = WiseEquipAttCtr });

    return self;
end


function WiseEquipAttCtr:Init(transform)

    self.transform = transform;

  
end

function WiseEquipAttCtr:SetData( selectEq)

   

end




function WiseEquipAttCtr:Show()
    self.transform.gameObject:SetActive(true);
end

function WiseEquipAttCtr:Hide()
    self.transform.gameObject:SetActive(false);
end

function WiseEquipAttCtr:Dispose()

    self.transform = nil;

end


return WiseEquipAttCtr;

