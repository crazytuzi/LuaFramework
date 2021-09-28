GuidePet = class("GuidePet", SequenceContent)

function GuidePet.GetSteps()
    return {
    	GuidePet.A0
      	,GuideContent.GuideSysPanelEnd
      	,GuidePet.A
      	,GuidePet.DelayForPanel
      	--,GuidePet.B
      	,GuidePet.C
      	,GuidePet.D
      	,GuidePet.E
    };
end

function GuidePet.A0(seq)
	return GuideContent.GuideSysPanelStart(seq, LanguageMgr.Get("guide/pet/1"))
end

--引导点击伙伴按钮
function GuidePet.A(seq)
	local msg = LanguageMgr.Get("guide/pet/2");
	return GuideContent.GuideSysItem(seq, msg, "5", "UI_PetPanel");
end

function GuidePet.DelayForPanel(seq)
    return SequenceCommand.UI.PanelOpened("UI_PetPanel");
end

--选中特定伙伴
function GuidePet.B(seq)
	
end

--点击出战按钮
function GuidePet.C(seq)
	local msg = LanguageMgr.Get("guide/pet/4");
	local panel = PanelManager.GetPanelByType("UI_PetPanel");
	local btn = panel:GetTransformByPath("trsContent/rightParent/trsInfo/trsActive/btnFight").gameObject;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.PET_FIGHT);
	return SequenceCommand.Guide.GuideClickUI(msg, btn, nil, wait, GuideTools.Pos.UP, Vector3.New(0, 50, 0), true);
end

--点击返回主界面
function GuidePet.D(seq)
	local msg = LanguageMgr.Get("guide/pet/5");
	local panel = PanelManager.GetPanelByType("UI_PetPanel");
	local btn = panel:GetTransformByPath("trsContent/btn_close").gameObject;
	local wait = SequenceCommand.UI.CloseBtnClick("UI_PetPanel");
	return SequenceCommand.Guide.GuideClickUI(msg, btn, nil, wait, GuideTools.Pos.RIGHT, Vector3.New(70, -13, 0), true);
end

function GuidePet.E(seq)
	ModuleManager.SendNotification(GuideNotes.CLOSE_GUIDE_CLICK);
	return nil;
end
