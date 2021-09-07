CanyonDescPanel = CanyonDescPanel or BaseClass(BaseTracePanel)

function CanyonDescPanel:__init(model)
    self.model = model

    self.resList = {
        {file = AssetConfig.canyon_desc_panel, type = AssetType.Main},
        {file = AssetConfig.guildleague_texture, type = AssetType.Dep},
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function CanyonDescPanel:__delete()
    self.OnHideEvent:Fire()
    if self.tweenIdX ~= nil then
        Tween.Instance:Cancel(self.tweenIdX)
        self.tweenIdX = nil
    end

    if self.tweenIdY ~= nil then
        Tween.Instance:Cancel(self.tweenIdY)
        self.tweenIdY = nil
    end

    if self.tweenScalerId ~= nil then
        Tween.Instance:Cancel(self.tweenScalerId)
        self.tweenScalerId = nil
    end

    if self.delayTimerId ~= nil then
        LuaTimer.Delete(self.delayTimerId)
        self.delayTimerId = nil
    end

    for k,v in pairs(self.iconloader) do
        v:DeleteMe()
        v = nil
    end
    self.iconloader = {}
end


function CanyonDescPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.canyon_desc_panel))
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(0, 0, 0)
    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:CloseMyPanel() end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:CloseMyPanel() end)
    self.main =  self.transform:Find("Main")

    local main = self.transform:Find("Main")

    self.iconloader = {}
    -- self.iconloader[1] = SingleIconLoader.New(main:Find("ScrollRect/Container/1/Image").gameObject)
    -- self.iconloader[2] = SingleIconLoader.New(main:Find("ScrollRect/Container/2/Image").gameObject)
    -- self.iconloader[3] = SingleIconLoader.New(main:Find("ScrollRect/Container/3/Image").gameObject)
    -- self.iconloader[4] = SingleIconLoader.New(main:Find("ScrollRect/Container/4/Image").gameObject)

    main:Find("ScrollRect/Container/1/Text2"):GetComponent(Text).text = TI18N("1.摧毁敌方<color='#7FFF00'>3</color>座水晶塔则<color='#7FFF00'>全胜</color>\n2.队伍<color='#7FFF00'>人数越多</color>，对水晶塔的<color='#7FFF00'>伤害越高</color>\n3.敌方阵营人数为<color='#7FFF00'>0</color>时，也可提前获胜")
    main:Find("ScrollRect/Container/2/Text2"):GetComponent(Text).text = TI18N("1.攻击敌方水晶塔，可减少敌方水晶塔的<color='#7FFF00'>生命值</color>\n2.若遇到敌方拦截，将进入<color='#7FFF00'>战斗</color>")
    main:Find("ScrollRect/Container/3/Text2"):GetComponent(Text).text = TI18N("防守己方水晶塔，若遇敌方攻塔，进入<color='#7FFF00'>战斗</color>拦截")
    main:Find("ScrollRect/Container/4/Text2"):GetComponent(Text).text = TI18N("1.战场大炮开启时，双方可进行<color='#7FFF00'>抢夺</color>\n2.成功开启战场大炮，将对敌方水晶塔造成<color='#7FFF00'>大量伤害</color>")

end


function CanyonDescPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function CanyonDescPanel:OnOpen()
    self:AddListeners()
    if self.tweenIdX ~= nil then
        Tween.Instance:Cancel(self.tweenIdX)
        self.tweenIdX = nil
    end

    if self.tweenIdY ~= nil then
        Tween.Instance:Cancel(self.tweenIdY)
        self.tweenIdY = nil
    end

    if self.tweenScalerId ~= nil then
        Tween.Instance:Cancel(self.tweenScalerId)
        self.tweenScalerId = nil
    end

    if self.delayTimerId ~= nil then
        LuaTimer.Delete(self.delayTimerId)
        self.delayTimerId = nil
    end

    self.main.transform.localScale = Vector3(1,1,1)
    self.main.transform.anchoredPosition3D = Vector3(0,-9,0)
    self:SetData()
end


function CanyonDescPanel:OnHide()
    self:RemoveListeners()
end

function CanyonDescPanel:RemoveListeners()

end

function CanyonDescPanel:AddListeners()
    self:RemoveListeners()

end

function CanyonDescPanel:SetData()

end

function CanyonDescPanel:CloseMyPanel()
    -- RectTransformUtility.ScreenPointToLocalPointInRectangle(canvas.transform as RectTransform, Camera.main.WorldToScreenPoint(obj.transform.position), canvas.worldCamera, out pos);
    if MainUIManager.Instance.mainuitracepanel ~= nil and MainUIManager.Instance.mainuitracepanel.canyon ~= nil then
         if self.tweenIdY == nil then
                self.tweenIdY = Tween.Instance:MoveY(self.main.gameObject,MainUIManager.Instance.mainuitracepanel.canyon.RuleUpButton.transform.position.y,0.34, function()  end,LeanTweenType.easeInQuad).id
            end

            if self.tweenIdX == nil then
                self.tweenIdX = Tween.Instance:MoveX(self.main.gameObject,MainUIManager.Instance.mainuitracepanel.canyon.RuleUpButton.transform.position.x,0.34, function()  end,LeanTweenType.easeInQuad).id
            end

            if self.tweenScalerId == nil then
                self.tweenScalerId = Tween.Instance:Scale(self.main.gameObject, Vector3(0,0,0),0.34, function()  end, LeanTweenType.easeInQuad).id
            end

            if self.delayTimerId == nil then
                self.delayTimerId  = LuaTimer.Add(380,function() self.model:CloseDescPanel() end)
            end
    else
            self.model:CloseDescPanel()
    end

end





