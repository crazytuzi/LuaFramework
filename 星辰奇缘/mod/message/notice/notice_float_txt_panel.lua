-- ------------------------------
-- 文字上浮
-- hosr
-- ------------------------------
NoticeFloatTxtPanel = NoticeFloatTxtPanel or BaseClass(BasePanel)

function NoticeFloatTxtPanel:__init(model)
    self.model = model
    self.path = AssetConfig.notice_float_panel

    -- 第二字体现在不用了，安卓直接把第一字体改为静态，ios就独立用动态
    -- if Application.platform == RuntimePlatform.Android
    --     or Application.platform == RuntimePlatform.WindowsEditor
    --     or Application.platform == RuntimePlatform.WindowsPlayer
    --     then
    --     self.path = AssetConfig.notice_float_panel_android
    -- end

    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = "textures/ui/talkbubble.unity3d", type = AssetType.Dep},
    }

    self.OnOpenEvent:Add(function() self:Go() end)

    self.MaxCount = 6
    self.MinWidth = 240
    self.MaxWidth = 480

    self.step = 0
    self.itemList = {}
    self.orderList = {}

    self.showing = false
    self.showList = {}
    self.currentTime = 0
    self.noticeFloatItem = nil
end

function NoticeFloatTxtPanel:__delete()
end

function NoticeFloatTxtPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject:SetActive(false)
    self.gameObject.name = "NoticeFloatTxtPanel"
    self.transform = self.gameObject.transform
    for i = 1, self.MaxCount do
        local item = NoticeFloatTxtItem.New(self.transform:GetChild(i - 1))
        item.id = i
        item.callback = function() self:ShowMsg() end
        table.insert(self.itemList, item)
    end

    UIUtils.AddUIChild(self.model.noticeCanvas, self.gameObject)
    self:ClearMainAsset()
end

-- -----------------------------------------------------------------------------
-- 规则说明:
-- 1.界面上最多显示6条
-- 2.每条信息的活动是1.7s持续显示时间，0.3s渐隐消失(没有缓动往上飘)
-- 3.新的直接把旧的往上顶，最后一条直接干掉，轮回到第一条用
-- 4.每条最大宽度 480， 最小宽度240
-- -----------------------------------------------------------------------------
function NoticeFloatTxtPanel:OnTick()
end

function NoticeFloatTxtPanel:GetOrder()
    self.step = self.step + 1
    if self.step > 6 then
        self.step = 1
    end
    return self.step
end

function NoticeFloatTxtPanel:AppendData(str)
    local time = BaseUtils.BASE_TIME
    table.insert(self.showList, str)
    if self.showing and #self.showList > 6 then
        -- 出现异常
        self:ErrorDeal()
    end
end

function NoticeFloatTxtPanel:ShowMsg()
    if #self.showList == 0 then
        self.showing = false
        self.currentTime = 0
        self.noticeFloatItem = nil
        return
    end
    self.showing = true
    local str = table.remove(self.showList, 1)
    local order = self:GetOrder()
    self.noticeFloatItem = self.itemList[order]
    self.noticeFloatItem:SetData(str)
end

function NoticeFloatTxtPanel:ErrorDeal()
    -- 异常处理，把当前的干掉，后面的继续
    Log.Debug("================ 飘字异常处理 ===============")
    if self.noticeFloatItem ~= nil then
        self.noticeFloatItem:ForceEnd()
        self.noticeFloatItem = nil
    end
    self:ShowMsg()
end
