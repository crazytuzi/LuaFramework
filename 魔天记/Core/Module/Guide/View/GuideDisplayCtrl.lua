GuideDisplayCtrl = class("GuideDisplayCtrl");

-- param : { msg = msg, posType = posType, offset = offset }
function GuideDisplayCtrl:ctor(transform, param)
    self.transform = transform;
    self.gameObject = transform.gameObject;
    self.param = param;
    self:Init();
end

function GuideDisplayCtrl:Init()
    local trsMsg = UIUtil.GetChildByName(self.transform, "Transform", "UI_GuideActMsg");
    if (trsMsg == nil) then
        trsMsg = UIUtil.GetUIGameObject(ResID.UI_GUIDEACTMSG).transform;
        UIUtil.AddChild(self.transform, trsMsg);
    end

    self._trsMsg = trsMsg;

    if trsMsg then
        self._icoMsgBg = UIUtil.GetChildByName(trsMsg, "UISprite", "bg");
        self._trsMsgHead = UIUtil.GetChildByName(trsMsg, "Transform", "icoHead");
        self._txtMsgContent = UIUtil.GetChildByName(trsMsg, "UILabel", "txt");
        local msgPanel = trsMsg.gameObject:GetComponent("UIPanel");
        if msgPanel then
            msgPanel.depth = PanelManager.GetMaxDepth()
        end

    end
    local widget = nil;
    if self.transform.parent then
        widget = self.transform.parent.gameObject:GetComponent("UIWidget");
    end
    if (widget) then
        local pivot = widget.pivotOffset;
        local pt = self.transform.localPosition;
        pt.x = pt.x +(0.5 - pivot.x) * widget.width;
        pt.y = pt.y +(0.5 - pivot.y) * widget.height;
        Util.SetLocalPos(self.transform, pt.x, pt.y, pt.z)

        --        self.transform.localPosition = pt;
    end
    GuideTools.SetMsgFrameDisplay(trsMsg, self.param);

    if trsMsg then
        self._initMsgBgWidth = self._icoMsgBg.width;
        self._initMsgHeadPos = self._trsMsgHead.localPosition;
    end
    
end

function GuideDisplayCtrl:SetEnable(v)
    if self.gameObject then
        self.gameObject:SetActive(v);
        if v then
            self:Play();
        end
    end
end

function GuideDisplayCtrl:Play()
    if self._trsMsg then
        self._minWidth = 150;
        self._chgWidth = self._initMsgBgWidth - self._minWidth;
        self._icoMsgBg.width = self._minWidth;

        self._headOrgPos = self._initMsgHeadPos;
        local ty = self.param.posType;
        if ty == GuideTools.Pos.LEFT or ty == GuideTools.Pos.TOP_LEFT or ty == GuideTools.Pos.BOTTOM_LEFT then
            self._isLeft = true;
            self._headPos = self._headOrgPos.x + self._chgWidth;
        else
            self._isLeft = false;
            self._headPos = self._headOrgPos.x - self._chgWidth;
        end
       
        Util.SetLocalPos(self._trsMsgHead, self._headPos, self._headOrgPos.y, self._headOrgPos.z)

        --        self._trsMsgHead.localPosition = Vector3.New(self._headPosX, self._headOrgPos.y, self._headOrgPos.z);

        self._txtMsgContent.gameObject:SetActive(false);
        self.doTween = LuaDOTween.DOFloat( function(val) self:OnFloat(val) end, 0, 1, 0.45);
    end
end

function GuideDisplayCtrl:OnFloat(val)
    self._icoMsgBg.width = val * self._chgWidth + self._minWidth;

    -- self._headPos.x = self._headPosX + val * self._chgWidth;
    -- self._trsMsgHead.localPosition = self._headPos;

    if val == 1 then
        self._txtMsgContent.gameObject:SetActive(true);
        Util.SetLocalPos(self._trsMsgHead, self._headOrgPos.x, self._headOrgPos.y, self._headOrgPos.z)

        --        self._trsMsgHead.localPosition = self._headOrgPos;
    else
        local pos = self._trsMsgHead.localPosition;
        if self._isLeft then
            pos.x = self._headPos - val * self._chgWidth;
        else
            pos.x = self._headPos + val * self._chgWidth;
        end
        Util.SetLocalPos(self._trsMsgHead, pos.x, pos.y, pos.z)
        --        self._trsMsgHead.localPosition = pos;
    end
end

function GuideDisplayCtrl:Dispose()
    Resourcer.Recycle(self.gameObject, false);
end
