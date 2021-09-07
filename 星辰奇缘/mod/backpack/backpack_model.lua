-- --------------------------------
-- 主界面控制器
-- 只操作主界面空壳,切换到具体子界面再交付给子界面的控制器处理
-- hosr
-- --------------------------------
BackpackModel = BackpackModel or BaseClass(BaseModel)

function BackpackModel:__init()
    self.mainWindow = nil
    self.index = 0
    self.currentModel = nil

    self.expandPanel = nil

    self.newItemTab = {}

    self.quickBackpackWindow = nil

    self.isInit = false
    self:Init()
end

function BackpackModel:__delete()
    self:Destroy()
end

function BackpackModel:Destroy()
    self.isInit = false
    self.index = 0
    self.currentModel = nil
    if self.itemModel ~= nil then
        self.itemModel:DeleteMe()
        self.itemModel = nil
    end
    if self.infoModel ~= nil then
        self.infoModel:DeleteMe()
        self.infoModel = nil
    end
    -- wingModel 不要销毁啊，其它功能要用到啊
    if self.wingModel ~= nil then
        self.wingModel:Close()
        -- self.wingModel:DeleteMe()
    --     self.wingModel = nil
    end
    -- self.modelList = nil
end

function BackpackModel:Init()
    self.isInit = true
    if self.itemModel == nil then
        self.itemModel = BackpackItemModel.New(self)
    end
    if self.infoModel == nil then
        self.infoModel = BackpackInfoModel.New(self)
    end
    if self.wingModel == nil then
        self.wingModel = BackpackWingModel.New(self)
    end

    -- self.modelList = {
    --     [1] = self.itemModel,
    --     [2] = self.infoModel,
    --     [3] = self.wingModel
    -- }
end

function BackpackModel:OpenMain(args)
    if not self.isInit then
        self:Init()
    end
    if self.mainWindow == nil then
        self.mainWindow = BackpackWindow.New(self)
    end
    self.mainWindow:Open(args)
end

function BackpackModel:CloseMain()
    self.wingModel:RemoveListener()
    if self.mainWindow ~= nil then
        WindowManager.Instance:CloseWindow(self.mainWindow)
    end
end

function BackpackModel:DeleteMain()
    if self.mainWindow ~= nil then
        self.mainWindow:DeleteMe()
        self.mainWindow = nil
    end
end

function BackpackModel:OpenExpand()
    if BackpackManager.Instance.volumeOfItem >= 125 then
        NoticeManager.Instance:FloatTipsByString(TI18N("背包扩展已达到上限，不能继续扩展了哟~{face_1,22}"))
        return
    end

    local needData = DataItem.data_expand[BackpackManager.Instance.openedCount]
    if needData == nil then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("通过扩展包裹增加的背包已经到达上限，可使用<color='#ffff00'>“背包扩充卷轴”</color>扩展背包<color='#ffff00'>（商城-充值返利中领取）</color>")
        data.sureLabel = TI18N("前往查看")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function () WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3,2}) end
        NoticeManager.Instance:ConfirmTips(data)
        return
    end
    if self.expandPanel == nil then
        self.expandPanel = BackpackExpandPanel.New()
    end
    self.expandPanel:Show()
end

function BackpackModel:CloseExpand()
    if self.expandPanel ~= nil then
        self.expandPanel:DeleteMe()
        self.expandPanel = nil
    end
end

--  缓存显示
function BackpackModel:Show()
end

-- 缓存隐藏
function BackpackModel:Hide()
    -- for i,v in ipairs(self.modelList) do
    --     v:OnHide()
    -- end
    if self.itemModel ~= nil then
        self.itemModel:OnHide()
    end
    if self.infoModel ~= nil then
        self.infoModel:OnHide()
    end
    if self.wingModel ~= nil then
        self.wingModel:OnHide()
        if self.isWingGuide then
            QuestManager.Instance.autoRun = true
            QuestManager.Instance:DoMain()
            self.isWingGuide = false
        end
    end
end

-- -------------------------
-- 切换标签处理
-- -------------------------
function BackpackModel:SwitchTab(index)
    if index == 3 then
        if WingsManager.Instance.grade == nil then
            NoticeManager.Instance:FloatTipsByString(TI18N("重新连接中，请稍候"))
            WingsManager.Instance:Send11600()
            return
        end
    end
    if self.index ~= index then
        if self.currentModel ~= nil then
            self.currentModel:Hiden()
        end
    end
    if index == 1 then
        self.currentModel = self.itemModel
    elseif index == 2 then
        self.currentModel = self.infoModel
    elseif index == 3 then
        self.currentModel = self.wingModel

    end
    if index == 4 then
        -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.strategy_window)
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.talisman_window)
        return
    end
    self.index = index
    if self.currentModel ~= nil then
        self.currentModel:Show()
    end
end

-- ----------------------------
-- 打开加点
-- ----------------------------
function BackpackModel:OpenAddPoint()
    AddPointManager.Instance:Open({1})
end

function BackpackModel:OnLevelChange()
    local list = {}
    BackpackManager.Instance.autoUseTab = BackpackManager.Instance.autoUseTab or {}
    for _,v in ipairs(BackpackManager.Instance.autoList) do
        local newItem = v
        if RoleManager.Instance.RoleData.lev >= newItem.lev then
            local autoData = BackpackManager.Instance.autoUseTab[newItem.base_id]
            if autoData == nil or autoData.inChain ~= true then
                autoData = AutoUseData.New()
                BackpackManager.Instance.autoUseTab[newItem.base_id] = nil
            end

            autoData.callback = function() BackpackManager.Instance:Use(newItem.id, newItem.quantity, newItem.base_id) end
            autoData.itemData = newItem
            NoticeManager.Instance:AutoUse(autoData)
        else
            if BackpackManager.Instance.autoUseTab[newItem.base_id] ~= nil then
                BackpackManager.Instance.autoUseTab[newItem.base_id]:DeleteMe()
                BackpackManager.Instance.autoUseTab[newItem.base_id] = nil
            end
            table.insert(list, newItem)
        end
    end
    BackpackManager.Instance.autoList = list
end

function BackpackModel:OpenInfoWindow(args)
    self:OpenMain({2})
end

function BackpackModel:OpenInfoHonorWindow(args)
    if self.infoHonorWin == nil then
        self.infoHonorWin = InfoHonorWindow.New(self)
    end
    self.infoHonorWin:Open(args)
end

function BackpackModel:OpenGiftShow(args)
    if self.giftShow ~= nil then
        self.giftShow:Close()
    end
    if self.giftShow == nil then
        self.giftShow = BackpackGiftShow.New(self)
    end
    self.giftShow:Show(args)
end

function BackpackModel:CloseGiftShow()
    -- if self.giftShow ~= nil then
    --     self.giftShow:DeleteMe()
    --     self.giftShow = nil
    -- end
    if self.giftShow ~= nil then
        self.giftShow:DeleteMe()
        self.giftShow = nil
    end
end

function BackpackModel:OpenQuickBackpackWindow(args)
    if self.quickBackpackWindow == nil then
        self.quickBackpackWindow = QuickBackpackWindow.New(self)
    end
    self.quickBackpackWindow:Show(args)
end

function BackpackModel:CloseQuickBackpackWindow()
    if self.quickBackpackWindow ~= nil then
        self.quickBackpackWindow:DeleteMe()
        self.quickBackpackWindow = nil
    end
end

function BackpackModel:ShowWingGuide()
    if self.mainWindow ~= nil then
        self.isWingGuide = true
        self.mainWindow:ShowCloseGuide()
    end
end
--关闭选择礼包界面
function BackpackModel:CloseSelectGiftPanel()
    if self.selectgiftPanel ~= nil then
        self.selectgiftPanel:DeleteMe()
        self.selectgiftPanel = nil
    end
end
--打开选择礼包界面
function BackpackModel:OpenSelectGiftPanel(args)
    if self.selectgiftPanel == nil then
        self.selectgiftPanel = BackPackSelectGiftPanel.New(self.mainWindow.gameObject)
    end
    self.selectgiftPanel:Show(args)
end
