-- @author ###
-- @date 2018年4月28日,星期六

StatusSendTwoYearPanel = StatusSendTwoYearPanel or BaseClass(BasePanel)

function StatusSendTwoYearPanel:__init(model, parent)
    self.Mgr = ZoneManager.Instance
    self.model = model
    self.parent = parent
    self.name = "StatusSendTwoYearPanel"
    self.appendTab = {}

    self.resList = {
        {file = AssetConfig.statusSendtyPanel, type = AssetType.Main}
        ,{file = AssetConfig.anniversary_flower, type = AssetType.Main}
        ,{file  =  AssetConfig.zone_textures, type  =  AssetType.Dep}   --后续记得删掉
        ,{file = AssetConfig.anniversary_textures, type = AssetType.Dep}
    }
    self.photos = {}
    self.thumbphotos = {}
    self.mentions = {}
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.LuaTimerId = {}
end

function StatusSendTwoYearPanel:__delete()
    if self.chatExtPanel ~= nil then
        self.chatExtPanel:DeleteMe()
    end
    if self.photoeditor ~= nil then
        self.photoeditor:DeleteMe()
    end
    if self.friendPanel ~= nil then
        self.friendPanel:DeleteMe()
    end
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function StatusSendTwoYearPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.statusSendtyPanel))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function()  end)
    self.mainTrans = self.transform:Find("Main")
    --self.mainTrans.gameObject:SetActive(false)
    self.Decorate = self.transform:Find("Decorate")
    local bg = GameObject.Instantiate(self:GetPrefab(AssetConfig.anniversary_flower))
    UIUtils.AddBigbg(self.transform:Find("Decorate2"), bg)
    self.CloseButton = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function() AnniversaryTyManager.Instance.guideCompleted:Fire() self:Hiden() end)
    self.I18NLimitText = self.transform:Find("Main/I18NLimitText"):GetComponent(Text)
    self.InputField = self.transform:Find("Main/InputField"):GetComponent(InputField)
    self.InputFieldText = self.transform:Find("Main/InputField/Text"):GetComponent(Text)
    self.InputField.textComponent = self.InputFieldText
    self.anniNotice = self.transform:Find("Notice")
    self.anniNotice.gameObject:SetActive(false)
end

function StatusSendTwoYearPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function StatusSendTwoYearPanel:OnOpen()
    if self.openArgs ~= nil and #self.openArgs > 0 then
        if self.openArgs[1] == 1 then   --引导
            self.mainTrans.anchoredPosition = Vector2(-11, 41)
            self:PlayEffect()
        end
    end
end

function StatusSendTwoYearPanel:OnHide()
    if self.EffecttimerId ~= nil then
        LuaTimer.Delete(self.EffecttimerId)
        self.EffecttimerId = nil
    end
    if self.LuaTimerId ~= nil then
        for i,v in pairs(self.LuaTimerId) do
            LuaTimer.Delete(v)
            v = nil
        end
        self.LuaTimerId = nil
    end
end

function StatusSendTwoYearPanel:AppendInput(str)
    self.InputField.text = self.InputField.text .. str
end


function StatusSendTwoYearPanel:ClearAllMsg()
    self.ClearButton.gameObject:SetActive(false)
    self.InputField.text = ""
    self.appendTab = {}
    self.mentions = {}
end


function StatusSendTwoYearPanel:PlayEffect()
    --播特效

    self.LuaTimerId[1] = LuaTimer.Add(100,function()
        if self.PhotoEffect == nil then
            --照片特效
            local fun = function(effectView)
                local effectObject = effectView.gameObject
                effectObject.transform:SetParent(self.Decorate)
                effectObject.transform.localScale = Vector3(0.76, 0.76, 1)
                effectObject.transform.localPosition = Vector3(12.81, 3.14, -400)
                effectObject.transform.localRotation = Quaternion.identity
                Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            end
            self.PhotoEffect = BaseEffectView.New({effectId = 20482, time = nil, callback = fun})
        else
            self.PhotoEffect:SetActive(true)
        end
    end)
    --手指点击周年庆
    --self.TweenId = Tween.Instance:Scale(self.mainTrans.gameObject, Vector3(1,1,1), 0.8, function()  end)
    self.LuaTimerId[6] = LuaTimer.Add(4000,function()
       if self.AnniBtnEffect == nil then
          local fun = function(effectView)
                local effectObject = effectView.gameObject
                effectObject.transform:SetParent(self.Decorate)
                effectObject.transform.localScale = Vector3(1, 1, 1)
                effectObject.transform.localPosition = Vector3(-5, -24, -400)
                effectObject.transform.localRotation = Quaternion.identity
                Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            end
            self.AnniBtnEffect = BaseEffectView.New({effectId = 20483, time = nil, callback = fun})
        else
            self.AnniBtnEffect:SetActive(true)
        end
    end)


   self.LuaTimerId[2] = LuaTimer.Add(6000,function()
       self:AppendInput("#周年庆#")
   end)
   self.LuaTimerId[3] = LuaTimer.Add(7500,function()
       self:AppendInput("星辰奇缘2周年快乐！成长的路上，感谢有你的陪伴；往后的故事，还想继续与你书写！")
   end)

    --发表按钮
    self.LuaTimerId[6] = LuaTimer.Add(10000,function()
        if self.SendBtnEffect == nil then
           local fun = function(effectView)
               local effectObject = effectView.gameObject
               effectObject.transform:SetParent(self.Decorate)
               effectObject.transform.localScale = Vector3(1, 1, 1)
               effectObject.transform.localPosition = Vector3(118, -24, -400)
               effectObject.transform.localRotation = Quaternion.identity
               Utils.ChangeLayersRecursively(effectObject.transform, "UI")
           end
           self.SendBtnEffect = BaseEffectView.New({effectId = 20483, time = nil, callback = fun})
        else
           self.SendBtnEffect:SetActive(true)
        end
    end)
   --延时多久关闭面板
   self.EffecttimerId = LuaTimer.Add(13000, function() AnniversaryTyManager.Instance.guideCompleted:Fire() self:Hiden() end)
end
