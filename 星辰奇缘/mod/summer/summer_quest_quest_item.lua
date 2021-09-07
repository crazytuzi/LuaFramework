-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
-- 夏日任务，任务item
-- endregion
SummerQuestQuestItem = SummerQuestQuestItem or BaseClass()
function SummerQuestQuestItem:__init(origin_item, model, index, assetWrapper)
    self.model = model
    self.index = index
    self.QuestData = nil
    self.assetWrapper = assetWrapper
    self.gameObject = GameObject.Instantiate(origin_item)
    self.transform = self.gameObject.transform
    self.transform:SetParent(origin_item.transform.parent)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.gameObject:SetActive(true)

    self.ImgBack = self.transform:Find("Bg"):GetComponent(Image)
    self.BtnReward = self.transform:Find("BtnReward"):GetComponent(Button)
    self.TxtReward = self.transform:Find("BtnReward/Text"):GetComponent(Text)
    self.ImgBtnReward = self.transform:Find("BtnReward"):GetComponent(Image)

    self.BtnReward.onClick:AddListener(
    function()
        self:OnRewardHandler()
    end )
    self.BtnRewardEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20053)))
    self.BtnRewardEffect.transform:SetParent(self.BtnReward.transform)
    self.BtnRewardEffect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.BtnRewardEffect.transform, "UI")
    --            self.BtnRewardEffect.transform.localScale = Vector3.one
    --            self.BtnRewardEffect.transform.localPosition = Vector3.zero
    self.BtnRewardEffect.transform.localScale = Vector3(1.75, 0.65, 1)
    self.BtnRewardEffect.transform.localPosition = Vector3(-54, -14, -400)
    self.TxtDesc = self.transform:Find("Desc"):GetComponent(Text)
    self.TxtPoint = self.transform:Find("TxtPoint"):GetComponent(Text)
    self.MsgDesc = MsgItemExt.New(self.TxtPoint, 120)
    self.TxtProgress = self.transform:Find("TxtProgress"):GetComponent(Text)
    self.TxtTitle = self.transform:Find("Title/Text"):GetComponent(Text)
    self.ImgIcon = self.transform:Find("ImgIcon"):GetComponent(Image)
    self.ImgEnd = self.transform:Find("ImgEnd")

    local newX =(self.index - 1) * 165
    local rect = self.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(newX, 0)
end

function SummerQuestQuestItem:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
end


function SummerQuestQuestItem:SetData(data)
    self.QuestData = data

    local proStr;
    if self.QuestData.finish == QuestEumn.TaskStatus.End then
        self.TxtReward.text = TI18N("已领取")
        self.BtnRewardEffect:SetActive(false)
        self.ImgBtnReward.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.TxtReward.color = ColorHelper.ButtonColorDic.DefaultButton4
        self.ImgEnd.gameObject:SetActive(true)
        self.BtnReward.gameObject:SetActive(false)
        proStr = TI18N("<color='#249015'>任务已完成</color>");
    elseif self.QuestData.finish == QuestEumn.TaskStatus.Doing then
        local doneNum = 0
        local maxNum = 0;
        if self.QuestData.progress_ser ~= nil then
            local len_ser = #self.QuestData.progress_ser;
            local pro = self.QuestData.progress_ser[len_ser];
            if pro ~= nil then
                doneNum = pro.value
                maxNum = pro.target_val
            end
        end
        self.TxtReward.text = TI18N("前 往")
        self.ImgBtnReward.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.TxtReward.color = ColorHelper.ButtonColorDic.DefaultButton3
        self.BtnRewardEffect:SetActive(false)
        proStr = string.format("<color='#249015'>%s/%s</color>", doneNum, maxNum)
        self.ImgEnd.gameObject:SetActive(false)
        self.BtnReward.gameObject:SetActive(true)
    elseif self.QuestData.finish == QuestEumn.TaskStatus.Finish then
        proStr = TI18N("<color='#249015'>已完成</color>");
        self.ImgBtnReward.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.TxtReward.text = TI18N("领 奖")
        self.TxtReward.color = ColorHelper.ButtonColorDic.DefaultButton3
        self.BtnRewardEffect:SetActive(true)
        self.BtnReward.gameObject:SetActive(true)
    end
    local len = #self.QuestData.progress;
    local descStr = self.QuestData.progress[len].desc
    descStr = StringHelper.MatchBetweenSymbols(descStr, "%[", "%]")[1];
    self.TxtDesc.text = descStr
    local pointStr = string.format(TI18N("获得积分：<color='#2a9021'>%s</color>{assets_2, %s}"), self.QuestData.sum_point, KvData.assets.sum_point)
    self.MsgDesc:SetData(pointStr);
    self.TxtTitle.text = self.QuestData.name
    self.TxtProgress.text = proStr
    self.ImgIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.dailyicon, self.QuestData.sum_icon)
end

function SummerQuestQuestItem:OnRewardHandler()
    if self.QuestData.finish == QuestEumn.TaskStatus.End then
        return
    end
    if self.QuestData.finish == QuestEumn.TaskStatus.Doing then
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.campbox_main_window)
        if self.QuestData.id == 83640 then
            WindowManager.Instance:CloseWindowById(WindowConfig.WinID.campaign_uniwin)
        end
        QuestManager.Instance:DoQuest(self.QuestData)
    elseif self.QuestData.finish == QuestEumn.TaskStatus.Finish then
        QuestManager.Instance:Send10206(self.QuestData.id)
    end
end

function SummerQuestQuestItem:ShowBtnEffect(bool)
    self.BtnRewardEffect:SetActive(self.QuestData.finish == QuestEumn.TaskStatus.Finish  and bool)
end
