-- 设置自动恢复药品

GuideAutoDrug = class("GuideAutoDrug", SequenceContent)

GuideAutoDrug.HpMedicine = 500020
GuideAutoDrug.MpMedicine = 500030

function GuideAutoDrug.GetSteps()
    return {
        GuideAutoDrug.A
        ,GuideAutoDrug.END
    };
end

-- 设置药品
function GuideAutoDrug.A(seq)
    local blSave = false;
    if (AutoFightManager.use_Drug_HP_id == nil) then
        AutoFightManager.use_Drug_HP_id = GuideAutoDrug.HpMedicine;
        blSave = true
    end
    if (AutoFightManager.use_Drug_MP_id == nil) then 
        AutoFightManager.use_Drug_MP_id = GuideAutoDrug.MpMedicine;
        blSave = true
    end
    if (blSave) then
        AutoFightManager.Save();
    end
    return nil;
end

function GuideAutoDrug.END(seq)
    return nil;
end