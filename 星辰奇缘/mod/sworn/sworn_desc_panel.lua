-- @author 黄耀聪
-- @date 2016年10月25日

SwornDescPanel = SwornDescPanel or BaseClass(BasePanel)

function SwornDescPanel:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper

    self.name = "SwornDescPanel"
    self.mgr = SwornManager.Instance
    self.descString = "冒险的旅途并非一帆风顺，结伴同行能战胜更多的风浪，也只有通过<color='#00ff00'>结拜试炼</color>才能取得结拜资格:\n1.试炼战斗中需要结拜者<color='#00ff00'>相互配合</color>，宠物和守护都不能出战\n2.默契的配合、主动地付出，是你们<color='#00ff00'>战胜困难</color>的利刃\n3.结拜试炼可在规定时间内<color='#00ff00'>重复挑战</color>"
    -- self.descString = TI18N("1.结拜需<color='#249015'>2-5名好友组队</color>，等级<color='#249015'>≥50级</color>，每两人之间<color='#249015'>亲密度≥300</color>\n2.通过结拜试炼（战斗）考验后，可获得结拜资格\n3.规定的时间内，确定长幼排序、签订结拜契约后即可完成结拜\n4.结拜后仍可接纳新成员，但每人最多拥有一组结拜关系")

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SwornDescPanel:__delete()
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.bigbgImage ~= nil then
        self.bigbgImage.sprite = nil
    end
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    self.OnHideEvent:Fire()
end

function SwornDescPanel:InitPanel()
    local t = self.gameObject.transform
    self.transform = t

    self.bigbgImage = t:Find("BigBg"):GetComponent(Image)
    if self.bigbgImage == nil then
        self.bigbgImage = t:Find("BigBg").gameObject:AddComponent(Image)
    end
    self.bigbgImage .sprite = self.assetWrapper:GetSprite(AssetConfig.ridebg, "RideBg")
    self.descExt = MsgItemExt.New(t:Find("Scroll/Container"):GetComponent(Text), 283, 16, 23)
    self.descExt:SetData(self.descString)
    self.button = t:Find("Button"):GetComponent(Button)
    self.preview = t:Find("Preview").gameObject
    self.timeText = t:Find("Time/Bg/Text"):GetComponent(Text)

    self.button.onClick:AddListener(function() self:OnClick() end)
end

function SwornDescPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SwornDescPanel:OnOpen()
    self:RemoveListeners()
    self:UpdatePreview()

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 1000, function() self:OnTick() end)
    end
end

function SwornDescPanel:OnHide()
    self:RemoveListeners()
    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function SwornDescPanel:RemoveListeners()
end

function SwornDescPanel:OnClick()
    if TeamManager.Instance:IsSelfCaptin() then
        self.mgr:send17708()
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.sworn_progress_window)
    else
        NoticeManager.Instance:FloatTipsByString("等待队长开始试炼吧{face_1,33}")
    end
end

function SwornDescPanel:UpdatePreview()
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "SwornRole"
        ,orthographicSize = 1.0
        ,width = 400
        ,height = 600
        ,offsetY = -0.3
        ,offsetX = 0
    }
    local llooks = {}
    local BaseData = DataUnit.data_unit[73040]
    local modelData = {type = PreViewType.Npc, skinId = BaseData.skin, modelId = BaseData.res, animationId = BaseData.animation_id, scale = 1}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
    self.previewComp:Show()
end

function SwornDescPanel:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.preview:SetActive(true)
end

function SwornDescPanel:OnTick()
    local swornData = self.model.swornData or {}
    local timeout = swornData.timeout or BaseUtils.BASE_TIME

    local m = nil
    local s = nil
    local _ = nil
    
    if timeout - BaseUtils.BASE_TIME <= 0 then
    else
        _,_,m,s = BaseUtils.time_gap_to_timer(timeout - BaseUtils.BASE_TIME)
        if m > 9 then
            if s > 9 then
                self.timeText.text = string.format("%s:%s", tostring(m), tostring(s))
            else
                self.timeText.text = string.format("%s:0%s", tostring(m), tostring(s))
            end
        else
            if s > 9 then
                self.timeText.text = string.format("0%s:%s", tostring(m), tostring(s))
            else
                self.timeText.text = string.format("0%s:0%s", tostring(m), tostring(s))
            end
        end
    end
end


