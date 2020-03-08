local PrayPanel = Ui:CreateClass("PrayPanel");

PrayPanel.tbOnClick = 
{
    BtnPray = function (self)
        if not Pray:IsLevelEnough(me) then
            local szTip = string.format("您需要%d级才能参与祈福", Pray.PRAY_OPEN_LEVEL);
            me.CenterMsg(szTip);
            return;
        end

        if self.bPlaying then
            if self.bStopingAnimation then
                me.CenterMsg("请等待祈福结果");
            else
                self:StopAnimation();
            end
            return;
        end

        if Pray:IsEndWuxing() then
            me.CenterMsg("请先领取奖励")
            return;
        end

        local nDegree = DegreeCtrl:GetDegree(me, "Pray");
        if nDegree > 0 then
            RemoteServer.OnPrayRequest("DoPray"); 
            self:StartAnimation();
            return; 
        else
            QuickBuy:NotifyQuickBuy(me, "PrayTimes");
        end
    end,

    BtnReceive = function (self)
        if Pray:IsEndWuxing() then
            RemoteServer.OnPrayRequest("GainReward");
        end
    end
}

function PrayPanel:StartAnimation()
    self.bPlaying = true;
    self.pPanel:Button_SetText("BtnPray", "停止");
    self.pPanel:Button_SetEnabled("BtnPray", false);
    self.pPanel:PlayUiAnimation("PrayPanelConstance", false, true, {});
end

--校正到0度
function PrayPanel:AnimationAdapter(nSpeed, nTarAngle, nStartFrame, nStartAngle)
    nStartFrame = nStartFrame or 0;
    local rotate = self.pPanel:GetRotate("Pointer")
    local nCurAngle = nStartAngle or self:GetCurAngle();
    
    nTarAngle = nTarAngle or 360;
    local nFrame = ((nCurAngle - nTarAngle) / 360) * nSpeed;
    nFrame = math.ceil(nFrame);
    local szStart = string.format("{0,0,%d}", nCurAngle);
    local szEnd = string.format("{0,0,%d}", nTarAngle);
    local tbControls = {
        tostring(0 + nStartFrame),
        tostring(nFrame + nStartFrame),
        szStart,
        szEnd,
    }

    self.pPanel:PlayUiAnimation("PrayPanelAdapter", false, false, tbControls);
    return nFrame;
end

function PrayPanel:RecievePrayResult()
    self.pPanel:Button_SetEnabled("BtnPray", true);
end

function PrayPanel:StopAnimation()
    self.bStopingAnimation = true;
    self.pPanel:Button_SetText("BtnPray", "继续");
    self.pPanel:Button_SetEnabled("BtnPray", false);
    self.pPanel:StopUiAnimation("PrayPanelConstance");
    local rotate = self.pPanel:GetRotate("Pointer")
    local tbParam = {}
    local nCurAngle = self:GetCurAngle();
    
    local nWuxing = Pray:GetLastWuxing();
    local nTarAngle = self.tbWuxingAngle[nWuxing];
    -- 旋转若干圈
    local nTotalAngle = 360 * 4 + nCurAngle - nTarAngle
    --table.insert(tbParam, string.format("{0,0,%d}", nTotalAngle * 1 + nTarAngle))
    local nCount = 10;
    for i = 1, nCount do
    	table.insert(tbParam, string.format("{0,0,%d}", nTotalAngle * (nCount - i) / (nCount - 1) + nTarAngle))
    end
    
    self.pPanel:PlayUiAnimation("PrayPanelDeceleration", false, false, tbParam);
end


function PrayPanel:GetCurAngle()
    local rotate = self.pPanel:GetRotate("Pointer")
    local nCurAngle = rotate.eulerAngles.z;
    if nCurAngle < 0 then
        nCurAngle = 360 + nCurAngle;
    end

    return nCurAngle;
end

function PrayPanel:SetPointer()
    local nWuxing = Pray:GetLastWuxing();
    local nTarAngle = self.tbWuxingAngle[nWuxing];
    self.pPanel:ChangeRotate("Pointer", nTarAngle or 0)
end

function PrayPanel:OnAniEnd()
    self.bPlaying = false;
    self.bStopingAnimation = false;
    self:Update();
end

function PrayPanel:OnOpen()
    self.pPanel:Button_SetEnabled("BtnPray", true);
    self:Update();
end

--由上级ui调用，非MainPanel回调
function PrayPanel:OnClose()
    if self.bPlaying then
        self.pPanel:StopUiAnimation("PrayPanelConstance")
        self:SetPointer()
        self.bPlaying = false
    end
    if self.bStopingAnimation then
        self.pPanel:StopUiAnimation("PrayPanelDeceleration")
        self:SetPointer()
        self.bStopingAnimation = false
    end
end

PrayPanel.tbWuxingChar = { "金", "木", "水", "火", "土"};
PrayPanel.tbWuxingAngle = {62, 350, 278, 206, 134};
PrayPanel.tbWuxingRadian = {"HLforJin", "HLforMu", "HLfoeShui", "HLfoeHuo", "HLfoeTu"};

PrayPanel.tbWuxingWordCom = {"Jin", "Mu", "Shui", "Huo", "Tu"};
PrayPanel.tbWuxingWordSpriteNormal = {"jin1", "mu1", "shui1", "huo1", "tu1"};
PrayPanel.tbWuxingWordSpriteLight = {"jin2", "mu2", "shui2", "huo2", "tu2"};

function PrayPanel:GetWuxingDesc(szWuxing)
    local nLen = string.len(szWuxing);
    local szDesc = ""
    for i = 1, nLen do
        local szElem = string.sub(szWuxing, i, i);
        local nElem = tonumber(szElem);
        if nElem then
            szDesc = szDesc .. self.tbWuxingChar[nElem];
        end
    end

    return szDesc;
end

function PrayPanel:Update()
    local szWuxing = Pray:GetWuxing();
    local tbSetting = Pray:GetSetting(szWuxing);

    --按钮
    if self.bPlaying then
        self.pPanel:Button_SetText("BtnPray", "停止");
    else
        if Pray:IsNullWuxing() then
            self.pPanel:Button_SetText("BtnPray", "开始祈福"); 
        else
            self.pPanel:Button_SetText("BtnPray", "继续");
            self.pPanel:Button_SetEnabled("BtnPray", not self.bStopingAnimation)
        end
    end
    self.pPanel:SetActive("BtnReceive", Pray:IsEndWuxing())
    self.pPanel:SetActive("BtnPray", not Pray:IsEndWuxing())
    
    --罗盘
    local nWuxing = Pray:GetLastWuxing();
    for i = 1, 5 do
        local szRadian = self.tbWuxingRadian[i];
        self.pPanel:SetActive(szRadian, i == nWuxing);

        local szWordSprite;
        if i == nWuxing then
            szWordSprite = self.tbWuxingWordSpriteLight[i];
        else
            szWordSprite = self.tbWuxingWordSpriteNormal[i];
        end

        local szWordCom = self.tbWuxingWordCom[i];
        self.pPanel:Sprite_SetSprite(szWordCom, szWordSprite);
    end

    --文字提示
    self.pPanel:Label_SetText("TxtResult", self:GetWuxingDesc(szWuxing) or "无");
    self.pPanel:Label_SetText("Arrangement", tbSetting.szArrangement or "");
    self.pPanel:Label_SetText("Explain", tbSetting.szExplain or "");

    --技能buff奖励
    local nSkiillId, nSkillLevel, nSkillTime = Pray:GetBuffRewards(pPlayer);
    if nSkiillId then
        self.itemframe1:SetSkill(nSkiillId, nSkillLevel);
        self.itemframe1.fnClick = self.itemframe1.DefaultClick;
    else
        self.itemframe1:Clear();
    end

    --物品奖励
    local tbRewards = Pray:GetItemRewards();
    local tbReward = tbRewards[1];
    local itemframeObj = self["itemframe2"];
    if tbReward then
        local szType, nTemplateId, nCount = tbReward.szType, tbReward.nTemplateId, tbReward.nCount;
        if nTemplateId ~= 0 then
            itemframeObj:SetItemByTemplate(nTemplateId, nCount, me.nFaction);
        else
            itemframeObj:SetDigitalItem(szType, nCount);
        end
        itemframeObj.fnClick = itemframeObj.DefaultClick;
    else
        itemframeObj:Clear();
    end
end

function PrayPanel:DoAnimationEvent(nState)
    if nState == 1 then
        self:StartAnimation();
    elseif nState == 2 then
        self:RecievePrayResult();
    else
        Log("Error in PrayPanel:DoAnimationEvent. Unknow state", nState);
    end
end

function PrayPanel:OnSyncResponse()
    if not self.bPlaying then
        self:Update();
    end
end