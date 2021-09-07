-- region *.lua
-- Date jia 2017-6-22
-- 此文件由[BabeLua]插件自动生成
-- 夏日任务奖励Item
-- endregion
SummerQuestRewardItem = SummerQuestRewardItem or BaseClass()
function SummerQuestRewardItem:__init(gameObject, model, parent)
    self.parent = parent
    self.model = model
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.ImgBack = self.transform:GetComponent(Image)
    self.ImgHasGet = self.transform:Find("ImgBox/ImgHasGet")
    self.ImgBack.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.ImgBox = self.transform:Find("ImgBox");
    self.BtnSelf = self.transform:Find("ImgBox"):GetComponent(Button);
    self.BtnSelf.onClick:AddListener(
    function()
        self:OnBtnClick();
    end )
    self.floatCounter = 0
    self.ImgNotify = self.transform:Find("ImgBox/Notify")
    self.localY = self.ImgBox.transform:GetComponent(RectTransform).localPosition.y
    self.achPointX = self.ImgBox.transform:GetComponent(RectTransform).localPosition.x
    self.ImgNotify.gameObject:SetActive(false)
    self.TmpData = nil
end

function SummerQuestRewardItem:SetData(data)
    local mySumPoint = CampBoxManager.Instance.SumPoint;
    self.TmpData = data
    self.isReward = CampBoxManager.Instance:ChecSumIsReward(self.TmpData.id)
    self.isCanReward = mySumPoint >= self.TmpData.need_score
    self.ImgNotify.gameObject:SetActive(self.isCanReward and not self.isReward)
    if not self.isReward and not CampBoxManager.Instance.isShowShake then
        CampBoxManager.Instance.isShowShake = true
        self:PlayShakeEffect(true)
    else
        self:PlayShakeEffect(false)
    end
    if self.isReward then
        self.ImgHasGet.gameObject:SetActive(true)
    else
        self.ImgHasGet.gameObject:SetActive(false)
    end
end
function SummerQuestRewardItem:__delete()
    if self.delateTimer ~= nil then
        LuaTimer.Delete(self.delateTimer)
        self.delateTimer = nil
    end
    if self.shakeID ~= nil then
        Tween.Instance:Cancel(self.shakeID)
        self.shakeID = nil
    end
    self.parent = nil
end

function SummerQuestRewardItem:OnBtnClick()
    -- 未达成是tips，达成时领奖
    if not self.isCanReward or self.isReward then
        local itemID = self.TmpData.item_reward[1][1];
        if itemID ~= nil and tonumber(itemID) ~= 0 then
            local base_data = BackpackManager.Instance:GetItemBase(itemID)
            local info = { itemData = base_data, gameObject = self.BtnSelf.gameObject, extra = { inbag = false, noqualitybg = true, nobutton = true } }
            TipsManager.Instance:ShowItem(info)
        end
    else
        CampBoxManager.Instance:Send10254(self.TmpData.id)
    end
end

function SummerQuestRewardItem:PlayShakeEffect(isShow)
    if self.delateTimer ~= nil then
        LuaTimer.Delete(self.delateTimer)
        self.delateTimer = nil
    end
    if self.shakeID ~= nil then
        Tween.Instance:Cancel(self.shakeID)
        self.shakeID = nil
    end
    if not isShow then
        self.floatCounter = 0
        self.ImgBox.transform:GetComponent(RectTransform).localPosition = Vector2(self.achPointX, self.localY)
        return
    end
    self.achPointY = self.localY
    if self.delateTimer ~= nil then
        LuaTimer.Delete(self.delateTimer)
        self.delateTimer = nil
    end
    self.achPointY = self.achPointY - 20
    self:FloatIcon()   
--    self.ImgBox.transform:GetComponent(RectTransform).localPosition = Vector2(self.achPointX, self.achPointY)
    
    self.shakeID = Tween.Instance:MoveLocalY(self.ImgBox.gameObject, self.achPointY + 20, 0.2,
    function()
        if self.shakeID ~= nil then
            Tween.Instance:Cancel(self.shakeID)
            self.shakeID = nil
        end
        self.achPointY = self.achPointY + 20
        self.delateTimer = LuaTimer.Add(0, 16, function() self:FloatIcon() end)
    end , LeanTweenType.linear).id
end
function SummerQuestRewardItem:FloatIcon()
    self.floatCounter = self.floatCounter + 1
    self.ImgBox.transform:GetComponent(RectTransform).localPosition = Vector2(self.achPointX, self.achPointY + 6 + 10 * math.sin(self.floatCounter * math.pi / 90 * 1.5))
end

function SummerQuestRewardItem:OnHide()
    if self.delateTimer ~= nil then
        LuaTimer.Delete(self.delateTimer)
        self.delateTimer = nil
    end
    if self.shakeID ~= nil then
        Tween.Instance:Cancel(self.shakeID)
        self.shakeID = nil
    end
    self.floatCounter = 0
    self.ImgBox.transform:GetComponent(RectTransform).localPosition = Vector2(self.achPointX, self.localY)
end