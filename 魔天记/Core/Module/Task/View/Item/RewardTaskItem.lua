require "Core.Module.Common.UIItem"

RewardTaskItem = UIItem:New();

function RewardTaskItem:_Init()
    local txts = UIUtil.GetComponentsInChildren(self.transform, "UILabel");
    self._txtTaskType = UIUtil.GetChildInComponents(txts, "txtTaskType");
    self._txtTaskDesc = UIUtil.GetChildInComponents(txts, "txtTaskDesc");
    self._txtAward1 = UIUtil.GetChildInComponents(txts, "txtAward1");
    self._txtAward2 = UIUtil.GetChildInComponents(txts, "txtAward2");

    local btns = UIUtil.GetComponentsInChildren(self.transform, "UIButton");
    self._btnAcc = UIUtil.GetChildInComponents(btns, "btnAcc");
    self._btnComit = UIUtil.GetChildInComponents(btns, "btnComit");
    self._btnCancel = UIUtil.GetChildInComponents(btns, "btnCancel");
    self._btnExp = UIUtil.GetChildInComponents(btns, "btnExp");
    self._btnGold = UIUtil.GetChildInComponents(btns, "btnGold");
    
    self._imgTaskColor = UIUtil.GetChildByName(self.transform, "UISprite", "imgTaskColor");
    self._imgTaskIco = UIUtil.GetChildByName(self.transform, "UISprite", "imgTaskIco");
    self._icoTaskStatus = UIUtil.GetChildByName(self.transform, "UISprite", "icoTaskStatus");

    self._icoItem1 = UIUtil.GetChildByName(self.gameObject, "UISprite", "imgAward1");
    self._icoItem2 = UIUtil.GetChildByName(self.gameObject, "UISprite", "imgAward2");

    --self._onClickBtn = function(go) self:_OnClick(self) end
    --UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

    self._onClickBtnAcc = function(go) self:_OnClickBtnAcc(self) end
    UIUtil.GetComponent(self._btnAcc, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAcc);   
    self._onClickBtnComit = function(go) self:_OnClickBtnComit(self) end
    UIUtil.GetComponent(self._btnComit, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnComit);
    self._onClickBtnCancel = function(go) self:_OnClickBtnCancel(self) end
    UIUtil.GetComponent(self._btnCancel, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnCancel);
    self._onClickBtnExp = function(go) self:_OnClickBtnExp(self) end
    UIUtil.GetComponent(self._btnExp, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnExp);
    self._onClickBtnGold = function(go) self:_OnClickBtnGold(self) end
    UIUtil.GetComponent(self._btnGold, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGold);

    self:UpdateItem(self.data);
end

function RewardTaskItem:_Dispose()

    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;
    
    UIUtil.GetComponent(self._btnAcc, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnAcc = nil;
    UIUtil.GetComponent(self._btnComit, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnComit = nil;
    UIUtil.GetComponent(self._btnCancel, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnCancel = nil;
    UIUtil.GetComponent(self._btnExp, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnExp = nil;
    UIUtil.GetComponent(self._btnGold, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnGold = nil;
end

function RewardTaskItem:UpdateItem(data)
    self.data = data;
    if data ~= nil then
        local config = data:GetConfig();

        self._imgTaskColor.spriteName = "color"..config.quality;
        self._imgTaskIco.spriteName = config.rewardIcon;

        self._showGoldRefresh = config.quality < 4;
        --[[
        local param = {
            a = config.a;
            b = config.b;
            c = config.c;
            x = data.param1;
            y = config.target_num;
        };]]
        self._txtTaskType.text = LanguageMgr.GetColor(config.quality, config.name);
        self._txtTaskDesc.text = LanguageMgr.GetColor("d", TaskUtils.GetTaskDesc(data, config));

        for i = 1, 2 do
            local tmp = string.split(config.reward[i], "_");
            local itemId = tonumber(tmp[1]);
            local num = tmp[2];

            local ico = self["_icoItem" .. i];
            if itemId > 0 then
                local cfg = ConfigManager.GetProductById(itemId);
                ProductManager.SetIconSprite(ico, cfg["icon_id"]);
                --                ico.mainTexture = UIUtil.GetTexture(EquipDataManager.GetItemTexturePath(cfg["icon_id"]));
            else
                ico.spriteName = ""
            end

            self["_txtAward" .. i].text = num;
        end

        self._icoTaskStatus.gameObject:SetActive(data.status == TaskConst.Status.FINISH);
        
        self:UpdateBtns(data.status);
    end
end

function RewardTaskItem:UpdateBtns(showType)
    if showType == TaskConst.Status.UNACCEPTABLE then
        self._btnAcc.gameObject:SetActive(true);
        self._btnComit.gameObject:SetActive(false);
        self._btnCancel.gameObject:SetActive(false);
        self._btnExp.gameObject:SetActive(false);
        self._btnGold.gameObject:SetActive(self._showGoldRefresh);
    elseif showType == TaskConst.Status.IMPLEMENTATION then
        self._btnAcc.gameObject:SetActive(false);
        self._btnComit.gameObject:SetActive(false);
        self._btnCancel.gameObject:SetActive(true);
        self._btnExp.gameObject:SetActive(false);
        self._btnGold.gameObject:SetActive(false);
    elseif showType == TaskConst.Status.FINISH then
        self._btnAcc.gameObject:SetActive(false);
        self._btnComit.gameObject:SetActive(true);
        self._btnCancel.gameObject:SetActive(false);
        self._btnExp.gameObject:SetActive(true);
        self._btnGold.gameObject:SetActive(false);
    end

end

function RewardTaskItem:_OnClickBtnAcc()
    TaskProxy.ReqTaskAccess(self.data.id);
    SequenceManager.TriggerEvent(SequenceEventType.Guide.REWARD_TASK_ACC);
end

function RewardTaskItem:_OnClickBtnComit()
    TaskProxy.ReqTaskFinish(self.data.id);
end

function RewardTaskItem:_OnClickBtnCancel()
    --TaskProxy.ReqTaskCancel(self.data.id);
    SequenceManager.TriggerEvent(SequenceEventType.Guide.REWARD_TASK_GO);
    self:_OnClick();
end

function RewardTaskItem:_OnClickBtnExp()
    TaskProxy.ReqTaskFinish(self.data.id, 1);
end

function RewardTaskItem:_OnClickBtnGold()
    MsgUtils.UseBDGoldConfirm(10, self, "task/reward/payGold", nil, RewardTaskItem._OnConfirmGoldRefresh, nil, taskId, "common/ok");
end

function RewardTaskItem:_OnConfirmGoldRefresh()
    TaskProxy.ReqGoldRefresh(self.data.id);
end

function RewardTaskItem:_OnClick()
    if self.data and self.data.status == TaskConst.Status.IMPLEMENTATION then
        TaskManager.Auto(self.data.id);
        MessageManager.Dispatch(TaskNotes, TaskNotes.TASK_REWARD_ITEM_DO, self.data.id);
    end
end
