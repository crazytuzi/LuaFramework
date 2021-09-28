GuideFirstCharge = class("GuideFirstCharge", SequenceContent)

function GuideFirstCharge.GetSteps()
    return {
      	GuideFirstCharge.A
    };
end

--引导自动任务
function GuideFirstCharge.A(seq)
    --Warning(tostring(SystemManager.IsOpen(SystemConst.Id.FIRSTRECHARGEAWARD) ))
    if not SystemManager.IsOpen(SystemConst.Id.FIRSTRECHARGEAWARD) then return end
	ModuleManager.SendNotification(FirstRechargeAwardNotes.OPEN_FIRSTRECHARGEAWARDPANEL)
	return nil
end
