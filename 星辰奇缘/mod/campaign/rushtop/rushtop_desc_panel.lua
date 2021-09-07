RushTopDescPanel = RushTopDescPanel or BaseClass(BaseTracePanel)

function RushTopDescPanel:__init(model)
    self.model = model
    self.Mgr = RushTopManager.Instance

    self.resList = {
        {file = AssetConfig.rushtopdescpanel, type = AssetType.Main},
        -- {file = AssetConfig.rushtop_texture, type = AssetType.Dep},
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function RushTopDescPanel:__delete()
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


function RushTopDescPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.rushtopdescpanel))
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(0, 0, 0)
    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:CloseMyPanel() end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:CloseMyPanel() end)
    self.main =  self.transform:Find("Main")

    local main = self.transform:Find("Main")

    self.iconloader = {}
    self.iconloader[1] = SingleIconLoader.New(main:Find("ScrollRect/Container/1/Image").gameObject)
    self.iconloader[1]:SetSprite(SingleIconType.MianUI, 379)
    self.iconloader[2] = SingleIconLoader.New(main:Find("ScrollRect/Container/2/Image").gameObject)
    self.iconloader[2]:SetSprite(SingleIconType.Item, 26013)
    self.iconloader[3] = SingleIconLoader.New(main:Find("ScrollRect/Container/3/Image").gameObject)
    self.iconloader[3]:SetSprite(SingleIconType.Item, 26014)
    self.iconloader[4] = SingleIconLoader.New(main:Find("ScrollRect/Container/4/Image").gameObject)
    self.iconloader[4]:SetSprite(SingleIconType.Item, 29088)

    main:Find("ScrollRect/Container/1/Text2"):GetComponent(Text).text = TI18N("1.在<color='#00ff00'>10秒</color>内作答，答对晋级、答错出局\n2.答对全部<color='#00ff00'>12题</color>即可平分奖池奖金")
    main:Find("ScrollRect/Container/2/Text2"):GetComponent(Text).text = TI18N("1.报名需要消耗一张<color='#00ff00'>入场券</color>\n2.入场券可通过活动及赠送获得")
    main:Find("ScrollRect/Container/3/Text2"):GetComponent(Text).text = TI18N("1.答题错误可使用<color='#00ff00'>复活卡</color>继续答题\n2.每局最多使用<color='#00ff00'>3张</color>，决胜题不能复活")
    main:Find("ScrollRect/Container/4/Text2"):GetComponent(Text).text = TI18N("1.赠送他人入场券，自己将获得<color='#00ff00'>复活卡</color>\n2.接受他人的入场券后，一段时间内赠送入场券将不能获得复活卡")




end


function RushTopDescPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function RushTopDescPanel:OnOpen()
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


function RushTopDescPanel:OnHide()
    self:RemoveListeners()
end

function RushTopDescPanel:RemoveListeners()

end

function RushTopDescPanel:AddListeners()
    self:RemoveListeners()

end

function RushTopDescPanel:SetData()

end

function RushTopDescPanel:CloseMyPanel()
    -- RectTransformUtility.ScreenPointToLocalPointInRectangle(canvas.transform as RectTransform, Camera.main.WorldToScreenPoint(obj.transform.position), canvas.worldCamera, out pos);
    if MainUIManager.Instance.mainuitracepanel ~= nil and MainUIManager.Instance.mainuitracepanel.rushTop ~= nil then
         if self.tweenIdY == nil then
                self.tweenIdY = Tween.Instance:MoveY(self.main.gameObject,MainUIManager.Instance.mainuitracepanel.rushTop.descButton.transform.position.y,0.34, function()  end,LeanTweenType.easeInQuad).id
            end

            if self.tweenIdX == nil then
                self.tweenIdX = Tween.Instance:MoveX(self.main.gameObject,MainUIManager.Instance.mainuitracepanel.rushTop.descButton.transform.position.x,0.34, function()  end,LeanTweenType.easeInQuad).id
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





