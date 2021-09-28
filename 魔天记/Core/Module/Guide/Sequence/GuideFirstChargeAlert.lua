GuideFirstChargeAlert = class("GuideFirstChargeAlert", SequenceContent)

function GuideFirstChargeAlert.GetSteps()
    return {
      	GuideFirstChargeAlert.A
    };
end

--引导自动任务
function GuideFirstChargeAlert.A(seq)
    if not SystemManager.IsOpen(SystemConst.Id.FIRSTRECHARGEAWARD) then return end
	ModuleManager.SendNotification(FirstRechargeAwardNotes.OPEN_FIRSTRECHARG_ALERT_PANEL)
	return nil
end
