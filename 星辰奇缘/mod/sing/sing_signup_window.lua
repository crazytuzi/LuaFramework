-- ----------------------------------
-- 好声音报名界面
-- hosr
-- 20160725
-- ----------------------------------

SingSignupWindow = SingSignupWindow or BaseClass(BaseWindow)

function SingSignupWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.sing_signup_window
    self.cacheMode = CacheMode.Destroy

    self.effectPath = string.format(AssetConfig.effect, 20118)
    self.effect = nil

    self.resList = {
        {file = AssetConfig.sing_singup, type = AssetType.Main},
        {file = AssetConfig.sing_res, type = AssetType.Dep},
        {file = self.effectPath, type = AssetType.Main},
    }

    self.OnOpenEvent:Add(function() self:OnOpen() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.timeId = nil
    self.count = 0

    self.tempDesc = ""
    self.isSongChange = false

    self.maxTime = 80

end

function SingSignupWindow:__delete()
    self.model.playCallback = nil
    self:StopTimeCount()

    if self.timeId ~= nil then
        LuaTimer.Delete(self.timeId)
        self.timeId = nil
    end

    if SingManager.Instance.songPlaying then
        self.model:StopSong()
    end

    if SingManager.Instance.songRecording then
        self.model:StopRecord()
    end
end

function SingSignupWindow:OnOpen()
    self.recording:SetActive(false)
    self:CheckLocal()
    self:UpdateState()
end

function SingSignupWindow:OnHide()
end

function SingSignupWindow:Close()
    if self.isSongChange or self.desc.text ~= self.tempDesc then
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.sureCallback = function() self.model:CloseSignup() end
        confirmData.content = string.format(TI18N("本次修改未提交，是否放弃修改?"))
        NoticeManager.Instance:ConfirmTips(confirmData)
    else
        self.model:CloseSignup()
    end
end

function SingSignupWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sing_singup))
    self.gameObject.name = "SingSignupWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.btn1Obj = self.transform:Find("Main/Button1").gameObject
    self.btn1 = self.btn1Obj:GetComponent(Button)
    self.btn1Txt = self.btn1Obj.transform:Find("Text"):GetComponent(Text)
    self.btn1Img = self.btn1Obj:GetComponent(Image)
    self.btn1Rect = self.btn1Obj:GetComponent(RectTransform)
    self.btn1.onClick:AddListener(function() self:BeginRecord() end)

    self.btn2Obj = self.transform:Find("Main/Button2").gameObject
    self.btn2 = self.btn2Obj:GetComponent(Button)
    self.btn2Txt = self.btn2Obj.transform:Find("Text"):GetComponent(Text)
    self.btn2Img = self.btn2Obj:GetComponent(Image)
    self.btn2Rect = self.btn2Obj:GetComponent(RectTransform)
    self.btn2.onClick:AddListener(function() self:SignUp() end)

    self.desc = self.transform:Find("Main/Desc/Desc"):GetComponent(InputField)
    self.desc.text = ""
    self.transform:Find("Main/Desc/Text"):GetComponent(Text).text = TI18N("一句话好声音")

    self.playBtn = self.transform:Find("Main/Option/PlayBtn"):GetComponent(Button)
    self.playIcon = self.transform:Find("Main/Option/PlayBtn/PlayBtn"):GetComponent(Image)
    self.slider = self.transform:Find("Main/Option/Slider"):GetComponent(Slider)
    self.sliderVal = self.transform:Find("Main/Option/Slider/Val"):GetComponent(Text)
    self.playBtn.onClick:AddListener(function() self:Play() end)

    self.state = self.transform:Find("Main/State"):GetComponent(Text)
    self.tips = MsgItemExt.New(self.transform:Find("Main/Tips"):GetComponent(Text), 358, 17)
    self.tips:SetData(TI18N("1.音频长度需要在<color='#00ff00'>20-80秒</color>范围\n2.报名需要消耗{assets_1,90000,100000}\n3.报名后可以<color='#00ff00'>重复修改</color>调整上传的音频"))

    self.recording = self.transform:Find("Main/Recording").gameObject
    self.recording:SetActive(false)
    self.recordTxt = self.recording.transform:Find("Text"):GetComponent(Text)
    self.recordTxt.text = "00:00"

    self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.effect.transform:SetParent(self.btn2Obj.transform)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect.transform.localScale = Vector3(1.1, 0.9, 1)
    self.effect.transform.localPosition = Vector3(-53, 25, -400)
    self.effect:SetActive(false)

    self:OnOpen()
end

-- 状态更新
function SingSignupWindow:UpdateState()
    self.state.text = ""
    self.isSongChange = false
    if SingManager.Instance.mySongId == 0 then
        -- 未提交过
        self.btn1Txt.text = TI18N("开始录音")
        self.btn2Txt.text = TI18N("上传报名")
        self.slider.value = 0
        self.sliderVal.text = TI18N("0秒")
        self.btn1Obj:SetActive(true)
        self.btn2Obj:SetActive(false)
        self.btn1Rect.anchoredPosition = Vector2(0, 41)
    else
        -- 提交过
        self.btn1Txt.text = TI18N("重新录音")
        self.btn2Txt.text = TI18N("确定修改")
        self.slider.value = 0
        self.sliderVal.text = string.format(TI18N("%s秒"), SingManager.Instance.mySongTime)
        self.maxTime = SingManager.Instance.mySongTime
        self.tempDesc = SingManager.Instance.mySongDesc
        self.desc.text = SingManager.Instance.mySongDesc
        self.btn1Rect.anchoredPosition = Vector2(-105, 41)
        self.btn2Rect.anchoredPosition = Vector2(105, 41)
        self.btn1Obj:SetActive(true)
        self.btn2Obj:SetActive(true)
    end
end

function SingSignupWindow:BeginRecord()
    if not SingManager.Instance.songRecording then
        -- if SingManager.Instance.mySongId ~= 0 then
            self.isSongChange = true
        -- end
        self.count = 0
        self.maxTime = 80
        self:UpdateSlider()
        self.recording:SetActive(true)
        self:TimeCount()
        self.btn1Txt.text = TI18N("完成录音")
        self.model:StartRecord()
        self.playIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.sing_res, "SingStopBtn")
    else
        self:StopRecord()
    end
end

function SingSignupWindow:StopRecord()
    self.state.text = TI18N("录音处理中")
    self.playIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.sing_res, "SingPlayBtn")
    self.recording:SetActive(false)
    self:StopTimeCount()
    self.btn1Txt.text = TI18N("开始录音")
    self.model:StopRecord()
    self.count = 0

    self.maxTime = self.model.recordTime
    if self.model.recordTime == 0 then
        self.maxTime = SingManager.Instance.mySongTime
    end

    self.sliderVal.text = string.format(TI18N("%s秒"), self.maxTime)
    self.slider.value = 0

    self.state.text = ""
    if self.model.recordTime < 20 then
        self.isSongChange = false
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("当前音频时长为%s秒，音频长度需要在<color=#00ff00>20-80秒</color>范围"), self.model.recordTime))
        return
    end

    if SingManager.Instance.mySongId == 0 then
        self.btn1Rect.anchoredPosition = Vector2(-105, 41)
        self.btn2Rect.anchoredPosition = Vector2(105, 41)
        self.btn1Obj:SetActive(true)
        self.btn2Obj:SetActive(true)
        self.btn1Txt.text = TI18N("重新录音")
        self.btn2Txt.text = TI18N("上传报名")
        self.effect:SetActive(true)
    end
end

function SingSignupWindow:SignUp()
    if SingManager.Instance.mySongId == 0 then
        if SingManager.Instance.mySongClip == nil then
            NoticeManager.Instance:FloatTipsByString(TI18N("请先进行录音~"))
            return
        end

        if self.desc.text == "" then
            NoticeManager.Instance:FloatTipsByString(TI18N("请先填写声音简介才能进行上传哦~"))
            return
        end

        -- 第一次提交
        if self.model.recordTime < 20 then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("当前音频时长为%s秒，音频长度需要在<color=#00ff00>20-80秒</color>范围"), self.model.recordTime))
            return
        end

        self.state.text = TI18N("上传中")
        SingManager.Instance:Send16800(self.desc.text, SingManager.Instance.mySongSpx, self.model.recordTime)
    else

        if not self.isSongChange and self.desc.text == self.tempDesc then
            NoticeManager.Instance:FloatTipsByString(TI18N("内容没有变化"))
            return
        end

        if self.desc.text ~= self.tempDesc then
            -- 更新简介
            self.tempDesc = self.desc.text
            SingManager.Instance:Send16805(self.desc.text)
        end

        if self.isSongChange then
            -- 更新音频
            self.isSongChange = false

            if self.model.recordTime < 20 then
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("当前音频时长为%s秒，音频长度需要在<color=#00ff00>20-80秒</color>范围"), self.model.recordTime))
                return
            end

            self.state.text = TI18N("上传中")
            SingManager.Instance:Send16804(SingManager.Instance.mySongSpx, self.model.recordTime)
        end
    end
end

--- 播放
function SingSignupWindow:Play()
    if Application.platform ~= RuntimePlatform.IPhonePlayer and Application.platform ~= RuntimePlatform.Android then
        NoticeManager.Instance:FloatTipsByString(TI18N("该平台不支持播放~"))
        return
    end

    if SingManager.Instance.mySongClip == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("不存在音频文件~"))
        return
    end
    if SingManager.Instance.songPlaying then
        self.playIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.sing_res, "SingPlayBtn")
        self:StopTimeCount()
        self.model:StopSong()
    else
        self.playIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.sing_res, "SingStopBtn")
        self:TimeCount()
        self.model:PlayClip(SingManager.Instance.mySongClip)
    end
end

function SingSignupWindow:StopTimeCount()
    if self.timeId ~= nil then
        LuaTimer.Delete(self.timeId)
        self.timeId = nil
    end
    self.count = 0
end

function SingSignupWindow:TimeCount()
    self:StopTimeCount()
    self.timeId = LuaTimer.Add(0, 1000, function() self:Loop() end)
end

function SingSignupWindow:Loop()
    self.count = self.count + 1
    self:UpdateSlider()
end

function SingSignupWindow:UpdateSlider()
    self.recordTxt.text = string.format(TI18N("剩余%s秒"), self.maxTime - self.count)
    self.sliderVal.text = string.format(TI18N("%s秒"), self.count)
    self.slider.value = self.count / self.maxTime
    if self.slider.value >= 1 then
        self:StopRecord()
    end
end

function SingSignupWindow:CheckLocal()
    local dat = RoleManager.Instance.RoleData
    local key = string.format("%s_%s_%s", dat.id, dat.platform, dat.zone_id)
    local cacheData = SingManager.Instance.cached[key]
    if cacheData ~= nil then
        if cacheData.clip == nil then
            if cacheData.file ~= nil then
                SingManager.Instance.mySongClip = self.model:GetLocal(cacheData.file)
            end
        else
            SingManager.Instance.mySongClip = cacheData.clip
        end
        SingManager.Instance.mySongUpdate = cacheData.update_time
    end
end