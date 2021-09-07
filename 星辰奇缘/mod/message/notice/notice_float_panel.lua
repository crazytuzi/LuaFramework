-- ----------------------------
-- 上浮提示
-- hosr
-- ----------------------------
NoticeFloatPanel = NoticeFloatPanel or BaseClass(BasePanel)

function NoticeFloatPanel:__init(model)
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

    self.isInit = false
end

function NoticeFloatPanel:__delete()
end

function NoticeFloatPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject:SetActive(false)
    self.gameObject.name = "NoticeFloatPanel"
    self.transform = self.gameObject.transform
    for i = 1, self.MaxCount do
        local item = NoticeFloatItem.New(self.transform:GetChild(i - 1))
        item.id = i
        table.insert(self.itemList, item)
    end

    UIUtils.AddUIChild(self.model.noticeCanvas, self.gameObject)
    self:ClearMainAsset()
    self.isInit = true
end

-- -----------------------------------------------------------------------------
-- 规则说明:
-- 1.界面上最多显示6条
-- 2.每条信息的活动是1.7s持续显示时间，0.3s渐隐消失(没有缓动往上飘)
-- 3.新的直接把旧的往上顶，最后一条直接干掉，轮回到第一条用
-- 4.每条最大宽度 480， 最小宽度240
-- -----------------------------------------------------------------------------
function NoticeFloatPanel:OnTick()
end

function NoticeFloatPanel:GetOrder()
    self.step = self.step + 1
    if self.step > 6 then
        self.step = 1
    end
    return self.step
end

function NoticeFloatPanel:AppendData(msgData)
    if not self.isInit then
        return
    end

    local order = self:GetOrder()
    local noticeFloatItem = self.itemList[order]
    noticeFloatItem:SetData(msgData)

    local delIndex = 0
    for i,v in ipairs(self.orderList) do
        if v == noticeFloatItem then
            delIndex = i
            break
        end
    end
    if delIndex ~= 0 then
        table.remove(self.orderList, delIndex)
    end

    table.insert(self.orderList, 1, noticeFloatItem)
end

-- 把旧的往上挤
function NoticeFloatPanel:MoveUp()
    local h = 0
    for i,noticeFloatItem in ipairs(self.orderList) do
        if noticeFloatItem.showing == true then
            noticeFloatItem:MoveUp(h)
            h = h + noticeFloatItem.height
        end
    end
end
