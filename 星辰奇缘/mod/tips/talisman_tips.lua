TalismanTips = TalismanTips or BaseClass(BaseTips)

function TalismanTips:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.talisman_tips, type = AssetType.Main},
        {file = AssetConfig.talisman_textures, type = AssetType.Dep},
        {file = AssetConfig.talisman_set, type = AssetType.Dep},
    }

    self.isShowDrop = false
    self.updateCall = function() self:UnRealUpdate() end

    self.OnHideEvent:Add(function() self:RemoveTime() end)
    self.guideEffect = nil
end

function TalismanTips:__delete()
     if self.guideEffect ~= nil then
        self.guideEffect:DeleteMe()
        self.guideEffect = nil
    end
    self.OnHideEvent:Fire()
end

function TalismanTips:RemoveTime()
     if self.guideEffect ~= nil then
        self.guideEffect:SetActive(false)
    end
    TipsManager.Instance.updateCall = nil
end

function TalismanTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.talisman_tips))
    self.gameObject.name = "TalismanTips"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.model.tipsCanvas.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.leftDrop = TalismanTipsDrop.New(self.model, self.gameObject, self.assetWrapper)
    self.rightDrop = TalismanTipsDrop.New(self.model, self.transform:Find("Drop").gameObject, self.assetWrapper)
end

function TalismanTips:UpdateInfo(data, extra)
    if data == nil then return end
    
    self.data = data

    -- BaseUtils.dump(data, "data")

    local talismanModel = TalismanManager.Instance.model
    local planData = nil
    self.nobutton = (extra ~= nil and extra.nobutton or false)
    if data ~= nil then
        if data.id ~= nil and data.id > 0 then
            if not self.nobutton then
                planData = talismanModel.itemDic[(talismanModel.planList[talismanModel.use_plan or 1][TalismanEumn.TypeProto[DataTalisman.data_get[talismanModel.itemDic[data.id].base_id].type]] or {}).id or 0]
            end
        elseif data.base_id ~= nil and data.base_id > 0 then
            planData = talismanModel.itemDic[(talismanModel.planList[talismanModel.use_plan or 1][TalismanEumn.TypeProto[DataTalisman.data_get[data.base_id].type]] or {}).id or 0]
        end
    end

    self.isShowDrop = (planData ~= nil and planData.id ~= data.id)

    if self.isShowDrop then
        self.leftDrop:UpdateInfo(planData, extra)
        self.rightDrop:UpdateInfo(data, extra)
        self.rightDrop.gameObject:SetActive(true)
    else
        self.leftDrop:UpdateInfo(data, extra)
        self.rightDrop.gameObject:SetActive(false)
    end

    self:RePosition()
    TipsManager.Instance.updateCall = self.updateCall
    self:CheckGuidePoint()
end

function TalismanTips:RePosition()
    local width = 960
    local height = 960 * ctx.ScreenHeight / ctx.ScreenWidth
    if self.isShowDrop == true then
        self.transform.anchoredPosition = Vector2(width / 2 - self.transform.sizeDelta.x, (height - self.transform.sizeDelta.y) / 2)

        self.model.xregion = {["min"] = self.transform.anchoredPosition.x, ["max"] = self.transform.anchoredPosition.x + self.transform.sizeDelta.x * 2}
        self.model.yregion = {["min"] = self.transform.anchoredPosition.y, ["max"] = self.transform.anchoredPosition.y + self.transform.sizeDelta.y}
    else
        self.transform.anchoredPosition = Vector2((width - self.transform.sizeDelta.x) / 2, (height - self.transform.sizeDelta.y) / 2)

        self.model.xregion = {["min"] = self.transform.anchoredPosition.x, ["max"] = self.transform.anchoredPosition.x + self.transform.sizeDelta.x}
        self.model.yregion = {["min"] = self.transform.anchoredPosition.y, ["max"] = self.transform.anchoredPosition.y + self.transform.sizeDelta.y}
    end
end

function TalismanTips:UnRealUpdate()
    if Input.touchCount > 0 and Input.GetTouch(0).phase == TouchPhase.Began then
        local v2 = Input.GetTouch(0).position
        if self.model:Checkvalidregion(v2.x, v2.y) == false then
            self.model:Closetips()
        end
    end

    if Input.GetMouseButtonDown(0) then
        local v2 = Input.mousePosition
        if self.model:Checkvalidregion(v2.x, v2.y) == false then
            self.model:Closetips()
        end
    end
end

function TalismanTips:CheckGuidePoint()
    -- if self.leftDrop ~= nil  and self.rightDrop ~= nil then
    --     if TipsManager.Instance.model.isCheckPoint ~= nil and TipsManager.Instance.model.isCheckPoint == true then
    --         local isShow = false
    --         for k,v in pairs(self.leftDrop.buttonList) do
    --             print(v.btnText.text .. "每一个装备名字")
    --             if v.btnText.text == "装 备" then
    --                 isShow = true
    --                 TipsManager.Instance:ShowGuide({gameObject = v.gameObject, data = TI18N("点击强化装备"), forward = TipsEumn.Forward.Left})
    --                 TipsManager.Instance.model.guideTipsNew.transform:SetSiblingIndex(self.gameObject.transform.parent.childCount - 1)
    --                 TipsManager.Instance.updateCall = TipsManager.Instance.model.talismanTips.updateCall
    --                 self:RePosition()
    --                  if self.guideEffect ~= nil then
    --                     self.guideEffect.transform:SetParent(v.transform)
    --                     self.guideEffect.transform.localScale = Vector3(0.8,0.8,1)
    --                     self.guideEffect.transform.localPosition = Vector3(64,-26,-600)
    --                     self.guideEffect.transform.localRotation = Quaternion.identity
    --                     self.guideEffect:SetActive(true)
    --                 end

    --                 if self.guideEffect == nil then
    --                     self.guideEffect = BibleRewardPanel.ShowEffect(20104,v.transform,Vector3(0.8,0.8,1), Vector3(64,-26,-600))
    --                 end
    --                 self.guideEffect:SetActive(true)
    --                 break
    --             end
    --         end

    --         if isShow == false then
    --           for k,v in pairs(self.rightDrop.buttonList) do
    --                 if v.btnText.text == "装 备" then
    --                     TipsManager.Instance:ShowGuide({gameObject = v.gameObject, data = TI18N("点击强化装备"), forward = TipsEumn.Forward.Left})
    --                     TipsManager.Instance.model.guideTipsNew.transform:SetSiblingIndex(self.gameObject.transform.parent.childCount - 1)
    --                      if self.guideEffect ~= nil then
    --                         self.guideEffect.transform:SetParent(v.transform)
    --                         self.guideEffect.transform.localScale = Vector3(0.8,0.8,1)
    --                         self.guideEffect.transform.localPosition = Vector3(64,-26,-600)
    --                         self.guideEffect.transform.localRotation = Quaternion.identity
    --                         self.guideEffect:SetActive(true)
    --                     end
    --                     if self.guideEffect == nil then
    --                         self.guideEffect = BibleRewardPanel.ShowEffect(20104,v.transform,Vector3(0.8,0.8,1), Vector3(64,-26,-600))
    --                     end
    --                     self.guideEffect:SetActive(true)
    --                     break
    --                 end
    --             end
    --         end
    --     end
    -- end
end

function TalismanTips:HideGuideEffect()
    -- if self.guideEffect ~= nil then
    --     self.guideEffect:SetActive(false)
    -- end
end
