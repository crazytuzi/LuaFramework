-- 作者:jia
-- 4/28/2017 2:24:17 PM
-- 功能:套娃item
DollsRandomDollsItem = DollsRandomDollsItem or BaseClass(BasePanel)
function DollsRandomDollsItem:__init(parent,parentPanel)
    self.parent = parent
    self.parentPanel = parentPanel
    self.resList = {
        { file = AssetConfig.dollsrandomdollsitem, type = AssetType.Main }
        ,{ file = string.format(AssetConfig.effect, 20360), type = AssetType.Main }
        ,{ file = string.format(AssetConfig.effect, 20373), type = AssetType.Main }
        ,{ file = string.format(AssetConfig.effect, 20369), type = AssetType.Main }
    }
    self.hasInit = false
    self.dollsData = nil
    self.timer1 = nil
    self.timer2 = nil
    self.timer3 = nil
    self.timer4 = nil
    self.timer5 = nil
    self.tweenId = nil
    self.tweenId2 = nil
    self.shakeID1 = nil
    self.openBackFun = nil
    self.OnItemClick =
    function()
        self:OpenItem()
    end
end

function DollsRandomDollsItem:__delete()
    self.hasInit = false
    if self.scaleID ~= nil then
        Tween.Instance:Cancel(self.scaleID)
        self.scaleID = nil
    end
    if self.shakeID ~= nil then
        Tween.Instance:Cancel(self.shakeID)
        self.shakeID = nil
    end
    if self.timer1 ~= nil then
        LuaTimer.Delete(self.timer1)
        self.timer1 = nil
    end
    if self.timer2 ~= nil then
        LuaTimer.Delete(self.timer2)
        self.timer2 = nil
    end
    if self.timer3 ~= nil then
        LuaTimer.Delete(self.timer3)
        self.timer3 = nil
    end
    if self.timer4 ~= nil then
        LuaTimer.Delete(self.timer4)
        self.timer4 = nil
    end
    if self.timer5 ~= nil then
        LuaTimer.Delete(self.timer5)
        self.timer5 = nil
    end
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    if self.tweenId2 ~= nil then
        Tween.Instance:Cancel(self.tweenId2)
        self.tweenId2 = nil
    end
    if self.shakeID1 ~= nil then
        Tween.Instance:Cancel(self.shakeID1)
        self.shakeID1 = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function DollsRandomDollsItem:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.dollsrandomdollsitem))
    self.gameObject.name = "DollsRandomDollsItem"

    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.ImgItem = self.transform:Find("ImgItem")
    self.ImgDolls1 = self.transform:Find("ImgItem/ImgDolls1")
    self.ImgDolls2 = self.transform:Find("ImgItem/ImgDolls2")
    self.ImgTalk = self.transform:Find("ImgTalk")
    self.TxtTalk = self.transform:Find("ImgTalk/TxtTalk"):GetComponent(Text)
    self.MsgTalk = MsgItemExt.New(self.TxtTalk, 158)
    self.transform:GetComponent(Button).onClick:AddListener(self.OnItemClick)
    self.hasInit = true
    self:SetData(self.dollsData)
    self:PlayRefresh()
end
-- 初始化数据

function DollsRandomDollsItem:SetData(data)
    self.dollsData = data
    if not self.hasInit or self.dollsData == nil then
        return
    end
    self.ImgItem.gameObject:SetActive(self.dollsData.open == 0)
    self.ImgDolls1.gameObject:SetActive(self.dollsData.type == 1)
    self.ImgDolls2.gameObject:SetActive(self.dollsData.type == 2)
    if self.dollsData.type == 2 then
        if self.effect20369 == nil then
            self.effect20369 = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20369)))
            self.effect20369.transform:SetParent(self.ImgItem)
            self.effect20369.transform.localRotation = Quaternion.identity
            Utils.ChangeLayersRecursively(self.effect20369.transform, "UI")
            self.effect20369.transform.localScale = Vector3(1, 1, 1)
            self.effect20369.transform.localPosition = Vector3(0, 38, -400)
        end
        self.effect20369.gameObject:SetActive(true)
    else
        if self.effect20369 ~= nil then
            self.effect20369.gameObject:SetActive(false)
        end
    end
    self:DollsTalk()
end
-- 播放打开特效
-- backfun 特效播放完后回调
function DollsRandomDollsItem:PlayOpenEffect(backfun)
    if not self.hasInit or DollsRandomManager.Instance.isOpening then
        return
    end
    DollsRandomManager.Instance.isOpening = true
    self.ImgTalk.gameObject:SetActive(false)
    if self.openEffec ~= nil then
        GameObject.DestroyImmediate(self.openEffect.gameObject)
    end
    local effectId = 20373
    if DollsRandomManager.Instance.isAdvDolls then
        effectId = 20360
    end
    self.openEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, effectId)))
    self.openEffect.transform:SetParent(self.transform)
    self.openEffect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.openEffect.transform, "UI")
    self.openEffect.transform.localScale = Vector3(1, 1, 1)
    self.openEffect.transform.localPosition = Vector3(5, 0, -400)
    self.openEffect.gameObject:SetActive(true)
    if backfun ~= nil then
        self.openBackFun = backfun
    end
    self:StartTimer()
end

function DollsRandomDollsItem:StartTimer()
    self.ImgItem.gameObject:SetActive(true)
    if self.timer3 ~= nil then
        LuaTimer.Delete(self.timer3)
        self.timer3 = nil
    end
    if self.timer4 ~= nil then
        LuaTimer.Delete(self.timer4)
        self.timer4 = nil
    end
    self.timer3 = LuaTimer.Add(600,
    function()
        self.ImgItem.gameObject:SetActive(false)
        self.timer3 = nil
    end )
    self.timer4 = LuaTimer.Add(800,
    function()
        self.timer4 = nil
        self.openEffect.gameObject:SetActive(false)
        if self.openBackFun ~= nil then
            self.openBackFun()
        end
    end )
end

-- 播放刷新特效
function DollsRandomDollsItem:PlayRefresh()
    if not self.hasInit or self.dollsData == nil then
        return
    end
    self.ImgTalk.gameObject:SetActive(false)
    self.ImgItem.gameObject:SetActive(false)
    if self.dollsData.open == 1 then
        return
    end
    local delateTime = self.dollsData.pos * 100
    LuaTimer.Add(delateTime, function()
        self:StartRefresh()
    end )
end

-- 播放精灵套娃提示语
function DollsRandomDollsItem:DollsTalk()
    if not self.hasInit or self.dollsData == nil then
        return
    end
    self.ImgTalk.gameObject:SetActive(false)
    if self.timer1 ~= nil then
        LuaTimer.Delete(self.timer1)
    end
    if self.timer2 ~= nil then
        LuaTimer.Delete(self.timer2)
    end
    if self.dollsData.open == 1 then
        return
    end
    if self.dollsData.type == 2 then
        local ranIndex = math.random(#DataCampDoll.data_dolls_talk_list)
        local talkStr = DataCampDoll.data_dolls_talk_list[ranIndex].talk_str
        self.MsgTalk:SetData(talkStr)
        self.ImgTalk.gameObject:SetActive(true)
        self.timer1 = LuaTimer.Add(5000,
        function()
            self.timer1 = nil
            self.ImgTalk.gameObject:SetActive(false)
        end )
        self.timer2 = LuaTimer.Add(15000,
        function()
            self.timer2 = nil
            self:DollsTalk()
        end )
    end
end
-- 开启套娃
function DollsRandomDollsItem:OpenItem()

    if self.dollsData == nil then
        return
    end
    if not self.hasInit then
        return
    end
    if self.dollsData.open == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("这个已经被打开了哦{face_1,3}"))
        return
    end
    local num = BackpackManager.Instance:GetItemCount(self.parentPanel.ItemKeyId)
    local base_data = DataItem.data_get[self.parentPanel.ItemKeyId]
    if num < 1 then
        local info = { itemData = base_data, gameObject = self.gameObject }
        local msg = string.format(TI18N("%s不足，无法打开哦"), ColorHelper.color_item_name(base_data.quality, base_data.name))
        NoticeManager.Instance:FloatTipsByString(msg)
        TipsManager.Instance:ShowItem(info)
        return
    end
    DollsRandomManager.Instance:OpenDolls(1, self.dollsData.pos)
end
-- 开始刷新特效
function DollsRandomDollsItem:StartRefresh()
    if not self.hasInit then
        return
    end
    self.ImgItem.gameObject:SetActive(true)
    self.ImgItem:GetComponent(RectTransform).localPosition = Vector2(0, 150)
    self.ImgItem:GetComponent(RectTransform).localScale = Vector2(0.5, 0.5)

    if self.shakeID ~= nil then
        Tween.Instance:Cancel(self.shakeID)
        self.shakeID = nil
    end
    if self.scaleID ~= nil then
        Tween.Instance:Cancel(self.scaleID)
        self.scaleID = nil
    end
    self.scaleID = Tween.Instance:Scale(self.ImgItem.gameObject, Vector3(1, 1, 1), 0.5,
    function()
        if self.scaleID ~= nil then
            Tween.Instance:Cancel(self.scaleID)
            self.scaleID = nil
        end
    end , LeanTweenType.easeOutBounce).id

    self.shakeID = Tween.Instance:MoveLocalY(self.ImgItem.gameObject, -48, 0.5,
    function()
        if self.shakeID ~= nil then
            Tween.Instance:Cancel(self.shakeID)
            self.shakeID = nil
        end
    end , LeanTweenType.easeOutBounce).id
end

function DollsRandomDollsItem:StartShake()
    if not self.hasInit then
        return
    end
    if self.timer5 ~= nil then
        LuaTimer.Delete(self.timer5)
        self.timer5 = nil
    end
    self.ImgItem.localRotation = Quaternion.identity
    self.ImgItem:Rotate(Vector3(0, 0, -10))
    self.timer5 = LuaTimer.Add(800,
    function()
        self.tweenId2 = Tween.Instance:RotateZ(self.ImgItem.gameObject, 0, 0.15, nil, LeanTweenType.linear).id
        if self.tweenId ~= nil then
            Tween.Instance:Cancel(self.tweenId)
            self.tweenId = nil
        end
    end )
    self:FloatIcon()
end

function DollsRandomDollsItem:FloatIcon()
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    self.tweenId = Tween.Instance:Rotate(self.ImgItem.gameObject, Vector3(0, 0, 10), 0.18, nil, LeanTweenType.linear):setLoopPingPong().id
end