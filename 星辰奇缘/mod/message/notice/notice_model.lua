-- -----------------------------
-- 消息控制
-- hosr
-- -----------------------------
NoticeModel = NoticeModel or BaseClass(BaseModel)

function NoticeModel:__init()

    self.calculator = nil
    self.canvasPath = "prefabs/ui/notice/noticecanvas.unity3d"

    self.floatTips = NoticeFloatPanel.New(self)
    self.confirmTips = NoticeConfirmPanel.New(self)
    self.hearSay = NoticeBottomPanel.New(self)
    self.floatTxt = NoticeFloatTxtPanel.New(self)
    self.scrollTips = NoticeScrollPanel.New(self)
    self.flyTips = NoticeFlyPanel.New(self)
    self.connectionConfirmTips = ConnectionConfirmPanel.New(self) -- 断线重连专用
    self.updateConfirmTips = NoticeUpdatePanel.New(self)            -- 停服更新专用

    -- 快速使用
    self.autoUse = AutoUseItem.New()
    self.guildPublicity = PublicityItem.New() --公会宣读

    self.msgTab = {}

    self.show = false
end

function NoticeModel:PreLoad()
        --创建加载wrapper
    self.assetWrapper = AssetBatchWrapper.New()

    local func = function()
        if self.assetWrapper == nil then return end
        self.noticeCanvas = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.canvasPath))
        self.noticeCanvas.name = "NoticeCanvas"
        UIUtils.AddUIChild(ctx.CanvasContainer, self.noticeCanvas)
        self.noticeCanvas.transform.localPosition = Vector3(0, 0, -1500)
        self.calculator = MessageCalculator.New(self.noticeCanvas.transform:Find("MagicText").gameObject)

        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil

        self.floatTips:Show()
        self.confirmTips:Show()
        self.hearSay:Show()
        self.autoUse:Show()
        self.guildPublicity:Show()
        self.floatTxt:Show()
        self.scrollTips:Show()
        self.flyTips:Show()
        self.connectionConfirmTips:Show()
        self.updateConfirmTips:Show()
    end
    self.assetWrapper:LoadAssetBundle({{file = self.canvasPath, type = AssetType.Main}}, func)
end

function NoticeModel:__delete()
end

function NoticeModel:OnTick()
    if self.show then
        self:Show()
    end
end

function NoticeModel:Show()
    if #self.msgTab == 0 then
        return
    end

    local temp = self.msgTab
    self.msgTab = {}
    local maxLen = #temp
    local len = math.min(6, maxLen)
    local start = #temp
    local over = maxLen - len + 1
    for i = over, start do
        local msgData = temp[i]
        self.floatTips:AppendData(msgData, i)
    end
    temp = nil
    self.floatTips:MoveUp()
    self.show = false
end

-- 上浮提示,功能调用，自己组装成元素数据
function NoticeModel:FloatTipsByString(content)
    local msgData = MessageParser.GetMsgData(content)
    self:FloatTipsByData(msgData)
end

function NoticeModel:FloatTipsByData(msgData)
    -- self.floatTips:AppendData(msgData)
    self:AppendData(msgData)
end

function NoticeModel:BottomHearsay(msgData)
    self.hearSay:ShowMsg(msgData)
end

-- 确认框提示
function NoticeModel:ConfirmTips(confirmData)
    self.confirmTips:SetData(confirmData)
end

-- 断线重连确认框提示
function NoticeModel:ConnectionConfirmTips(confirmData)
    self.connectionConfirmTips:SetData(confirmData)
end

function NoticeModel:AppendData(msgData)
    self.show = true
    table.insert(self.msgTab, msgData)
end

function NoticeModel:FloatTxt(str)
    self.floatTxt:AppendData(str)
    if not self.floatTxt.showing then
        self.floatTxt:ShowMsg()
    end
end

function NoticeModel:FlyItemIcon(baseId, startPosition, endPosition, time, callBack)
    local itembase = BackpackManager.Instance:GetItemBase(baseId)
    local itemData = ItemData.New()
    itemData:SetBase(itembase)
    local icon = ItemSlot.New()
    icon:SetAll(itemData)
    icon.name = "FlyItemSlot"
    local fun = function()
            if callBack ~= nil then callBack() end
                if icon ~= nil then
                    icon:DeleteMe()
                    icon = nil
                end
                -- GameObject.Destroy(icon.gameObject)
            end
    self:FlyGameObject(icon.gameObject, startPosition, endPosition, time, fun)
end

function NoticeModel:FlyGameObject(gameObject, startPosition, endPosition, time, callBack)
    gameObject.transform:SetParent(self.noticeCanvas.transform)
    gameObject.transform.localScale = Vector3(1, 1, 1)
    gameObject.transform.localPosition = startPosition
    Tween.Instance:MoveLocal(gameObject, endPosition, time, callBack, nil)
end

function NoticeModel:Clean()
    if self.hearSay ~= nil then
        self.hearSay:Hiden()
    end
    if self.confirmTips ~= nil and NoticeManager.Instance.hideConfirmTips then
        self.confirmTips:Hiden()
    end
end

function NoticeModel:CloseConfrimTips()
    if self.confirmTips ~= nil and NoticeManager.Instance.hideConfirmTips then
        self.confirmTips:Hiden()
    end
end

function NoticeModel:ScrollTipsByData(data)
    self.scrollTips:AddContent(data)
end

function NoticeModel:UpdateTips(confirmData)
    self.updateConfirmTips:SetData(confirmData)
end

function NoticeModel:CloseUpdateTips()
    if self.updateConfirmTips ~= nil then
        self.updateConfirmTips:Hiden()
    end
end

-- 确认框提示
function NoticeModel:ConfirmCostTips(confirmData)
    if self.confirmCostTips == nil then 
        self.confirmCostTips = NoticeConfirmCostPanel.New(self)
    end
    self.confirmCostTips:Show(confirmData)
end

function NoticeModel:CloseConfrimCostTips()
    if self.confirmCostTips ~= nil then
        self.confirmCostTips:DeleteMe()
    end
    self.confirmCostTips = nil
end