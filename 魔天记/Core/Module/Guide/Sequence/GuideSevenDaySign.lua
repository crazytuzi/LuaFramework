GuideSevenDaySign = class("GuideSevenDaySign", SequenceContent)

function GuideSevenDaySign.GetSteps()
    return {
      	GuideSevenDaySign.A
      	,GuideContent.OpenActPanelEnd
      	,GuideSevenDaySign.B
        ,GuideSevenDaySign.DelayForPanel
      	,GuideSevenDaySign.C
        ,GuideSevenDaySign.D
    };
end
--点开活动列表
function GuideSevenDaySign.A(seq)
	local msg = LanguageMgr.Get("guide/sevenDay/1");
	return GuideContent.OpenActPanelStart(seq, msg);
end

--点击福利按钮
function GuideSevenDaySign.B(seq)
	local msg = LanguageMgr.Get("guide/sevenDay/2");
	return GuideContent.OpenActItem(seq, msg, "54", "UI_SignInPanel", GuideSevenDaySign.A);
end

function GuideSevenDaySign.DelayForPanel(seq)
    return SequenceCommand.UI.PanelOpened("UI_SignInPanel");
end

--点击7天福利
function GuideSevenDaySign.C(seq)
  
  if seq.errorFlag then
    return nil;
  end

  if seq:GetCache("guideSevenDayTab") == nil then
    local panel = PanelManager.GetPanelByType("UI_SignInPanel");

    if panel == nil then
      seq:SetError();
      return nil;
    end

    local listTr = panel:GetTransformByPath("trsContent/phalanx");
    local trsItem = UIUtil.GetChildByName(listTr.gameObject, "5");
    if trsItem == nil then
      seq:SetError();
      return nil;
    end

    local msg = LanguageMgr.Get("guide/sevenDay/3");
    local effect = GuideTools.AddEffectAndTitleToGameObject(trsItem, "ui_guide_1", msg, GuideTools.Pos.RIGHT, Vector3.New(100, 0 ,0));

    seq:AddToCache("guideSevenDayTab", effect);
  end

  seq:SetCacheDisplay("guideSevenDayTab");

  local filter = function(idx) return idx == 5 end;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.SIGNIN_TAB_CHG, nil, filter);

  GuideContent.AddCloseFun(wait, "UI_SignInPanel", function() 
    seq:RemoveCache("guideSevenDayTab");
    seq:SkipAfterStep(GuideSevenDaySign.A);
  end);
  return wait;
end
--点击签到
function GuideSevenDaySign.D(seq)

  if seq.errorFlag then
    return nil;
  end

  if seq:GetCache("guideClickBtn") == nil then
    local panel = PanelManager.GetPanelByType("UI_SignInPanel");

    if panel == nil then
      seq:SetError();
      return nil;
    end

    local trsBtn = panel:GetTransformByPath("trsContent/trsLogin7Reward/bottomPanel/btnGetLogin7Award");
    if trsBtn == nil or trsBtn.gameObject.activeSelf == false then
      seq:SetError();
      return nil;
    end
    local msg = LanguageMgr.Get("guide/sevenDay/4");
    local effect = GuideTools.AddEffectAndTitleToGameObject(trsBtn, "ui_guide_1", msg, GuideTools.Pos.UP, Vector3.New(0, 50 ,0));

    seq:AddToCache("guideClickBtn", effect);
  end

  seq:SetCacheDisplay("guideClickBtn");

  local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.SIGNIN_SEVENDAY_GETAWARD);

  wait:AddEvent(SequenceEvent.Create(SequenceEventType.Guide.SIGNIN_TAB_CHG, nil, function(idx) return idx~= 5 end, function() seq:RemoveCache("guideClickBtn"); seq:SkipAfterStep(GuideSevenDaySign.C); end));
  
  GuideContent.AddCloseFun(wait, "UI_SignInPanel", function() 
    seq:RemoveCache("guideSevenDayTab");
    seq:RemoveCache("guideClickBtn");
    seq:SkipAfterStep(GuideSevenDaySign.A); 
  end);
  
  return wait;
end

