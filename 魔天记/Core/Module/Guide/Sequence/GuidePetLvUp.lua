GuidePetLvUp = class("GuidePetLvUp", SequenceContent)

function GuidePetLvUp.GetSteps()
    return {
      	GuidePetLvUp.A
      	,GuideContent.OpenSysPanelEnd
      	,GuidePetLvUp.B
      	,GuidePetLvUp.DelayForPanel
      	,GuidePetLvUp.C
    };
end

--点击玩家头像
function GuidePetLvUp.A(seq)
	local msg = LanguageMgr.Get("guide/petLvUp/1")
	return GuideContent.OpenSysPanelStart(seq, msg);
end

--点击伙伴按钮
function GuidePetLvUp.B(seq)
	local msg = LanguageMgr.Get("guide/petLvUp/2")
	return GuideContent.OpenSysItem(seq, msg, "5", "UI_PetPanel", GuidePetLvUp.A);
end

function GuidePetLvUp.DelayForPanel(seq)
    return SequenceCommand.UI.PanelOpened("UI_PetPanel");
end

--点击经验道具
function GuidePetLvUp.C(seq)
	
	if seq.errorFlag then
        return nil;
    end

	if seq:GetCache("GuidePetLvUp3") == nil then
		local panel = PanelManager.GetPanelByType("UI_PetPanel");

		local trsBtn = panel:GetTransformByPath("trsContent/rightParent/trsInfo/trsActive/itemPhalanx/item_0_0/itemIcon");
		if trsBtn == nil then
		  seq:SetError();
		  return nil;
		end

		local msg = LanguageMgr.Get("guide/petLvUp/3");
		local effect = GuideTools.AddEffectAndTitleToGameObject(trsBtn, "ui_guide_1", msg, GuideTools.Pos.TOP_RIGHT, Vector3.New(0, 45, 0));

		seq:AddToCache("GuidePetLvUp3", effect);
	end

	seq:SetCacheDisplay("GuidePetLvUp3");

	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.PET_LVUP_CLICK);
	GuideContent.AddCloseFun(wait, "UI_PetPanel", function() 
		seq:RemoveCache("GuidePetLvUp3");
		seq:SkipAfterStep(GuidePetLvUp.A);
	end);

	return wait;
end
