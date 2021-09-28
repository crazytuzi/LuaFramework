require "Core.Module.Common.Panel"

NewFeaturePanel = Panel:New();
-- NewFeaturePanel.SHOWTIME = 1;
NewFeaturePanel.ANIMTIME = 1;

function NewFeaturePanel:IsFixDepth()
    return true;
end

function NewFeaturePanel:IsPopup()
    return false;
end

function NewFeaturePanel:IsOverMainUI()
    return true;
end


function NewFeaturePanel:GetUIOpenSoundName( )
    return ""
end

function NewFeaturePanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function NewFeaturePanel:_InitReference()
    self._txtDesc = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtDesc");
    self._icoFeature = UIUtil.GetChildByName(self._trsContent, "UISprite", "icoFeature");
    self._iconPos = self._icoFeature.transform.localPosition;

    self._effect = UIUtil.GetUIEffect("ui_newfeature", self._icoFeature.transform, self._icoFeature, -1);
    --self._effect = UIUtil.GetChildByName(self._icoFeature, "Transform", "ui_newfeature");
    --UIUtil.AddEffectAnchor(self._effect.gameObject, -1);
    if self._effect then
        self._effect.gameObject:SetActive(false);
    end

    UpdateBeat:Add(self.OnUpdate, self)
end

function NewFeaturePanel:_InitListener()

end

function NewFeaturePanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function NewFeaturePanel:_DisposeReference()
    UpdateBeat:Remove(self.OnUpdate, self)

    if self._effect then
        Resourcer.Recycle(self._effect.gameObject, false)
        self._effect = nil;
    end
    
end

function NewFeaturePanel:_DisposeListener()

end

function NewFeaturePanel:ShowFeature(data)
    self.data = data;
    self:UpdateDisplay();
end

function NewFeaturePanel:UpdateDisplay()
    self._display = true;

    LuaDOTween.DOKill(self._icoFeature.transform, false);

    self._trsMask.gameObject:SetActive(true);
    self._txtDesc.gameObject:SetActive(true);
    self._txtDesc.text = self.data.tipLabel;
    Util.SetLocalPos(self._icoFeature, self._iconPos.x, self._iconPos.y, self._iconPos.z)

    -- self._icoFeature.transform.localPosition = self._iconPos;
    self._icoFeature.spriteName = self.data.icon;
    self._icoFeature:MakePixelPerfect();
    self._icoFeature.transform.localScale = Vector3.one * 1.5;

    if self._effect then
        self._effect.gameObject:SetActive(true);
    end

    -- self._showTime = NewFeaturePanel.SHOWTIME;
    -- self._showTips = true;
end

function NewFeaturePanel:_OnClickMask()
    if self._display then
        self._display = false;
        self:ShowEnd();
    end
end

function NewFeaturePanel:OnUpdate()
    --[[
	if self._showTips then
		if self._showTime > 0 then
			self._showTime = self._showTime - Timer.deltaTime;
		else
			self._showTips = false;
			self:ShowEnd();
		end
	end
	]]
    if self._waitToClose then
        if self._closeTime > 0 then
            self._closeTime = self._closeTime - Timer.deltaTime;
        else
            self._waitToClose = false;
            self:DoClose();
        end
    end
end

function NewFeaturePanel:ShowEnd()
    self._trsMask.gameObject:SetActive(false);
    self._txtDesc.gameObject:SetActive(false);

    if self.data.tipsPos == 0 then
        self:DelayClose();
    else
        local panel = PanelManager.GetPanelByType("UI_MainUIPanel");
        local trsIcon = nil;
        if self.data.tipsPos > 0 then
            local id = self.data.tipsPos;
            --local sysListGo = panel:GetTransformByPath("UI_SysPanel/trsSys/sysPhalanx").gameObject;
            trsIcon = GuideContent.GetSysItem(id);
            if trsIcon == nil then
                --如果是飞到活动， 在副本中则直接关闭
                if InstanceDataManager.IsInInstance() then
                    self:DelayClose();
                    return;
                end

                trsIcon = GuideContent._GetActItem1(id);
                if trsIcon then
                    trsIcon = UIUtil.GetChildByName(trsIcon.gameObject, "icon");
                end
                panel:SetActDisplay(MainUIPanel.Mode.SHOW);
            else
                panel:SetDisplay(MainUIPanel.Mode.SHOW);
            end

        else
            if self.data.type == 1 then
                trsIcon = panel:GetTransformByPath("UI_HeroHeadPanel/trsContent/imgIcon");
            else
                --如果是飞到活动， 在副本中则直接关闭
                if InstanceDataManager.IsInInstance() then
                    self:DelayClose();
                    return;
                end
                trsIcon = panel:GetTransformByPath("UI_SysPanel/togAct");
            end
        end


        if trsIcon == nil then
            -- log("[FF0000]can't find trsIcon[-]")
            self:DelayClose();
            return;
        end

        local targetPos = self._trsContent.transform:InverseTransformPoint(trsIcon.position);

        local t = NewFeaturePanel.ANIMTIME;
        local comfun = function() self:DoMoveEnd() end;
        LuaDOTween.OnComplete(LuaDOTween.DOLocalMove(self._icoFeature.transform, targetPos, t), comfun);
    end
end

function NewFeaturePanel:DelayClose()
    self._waitToClose = true;
    self._closeTime = NewFeaturePanel.ANIMTIME;
end

function NewFeaturePanel:DoMoveEnd()
    self:DoClose();
end

function NewFeaturePanel:DoClose()
    ModuleManager.SendNotification(MessageNotes.CLOSE_NEW_SYS_TIP);
end