-- @author 黄耀聪
-- @date 2016年7月6日
-- 攻略

StrategyModel = StrategyModel or BaseClass(BaseModel)

function StrategyModel:__init()
    self.mgr = StrategyManager.Instance
    self.brewModel = BibleBrewModel.New(self)
    self.type = 1

    self.dataType = {
        Fresh = 1,
        Equip = 2,
        Pet = 3,
        Challenge = 4,
    }
    self.tabData = {
        Fresh = {name = TI18N("新手成长"), icon = "Fresh", index = 1, key = 1},
        Equip = {name = TI18N("职业装备"), icon = "Equip", index = 2, key = 2},
        Pet = {name = TI18N("宠物培养"), icon = "Pet", index = 3, key = 3},
        Challenge = {name = TI18N("挑战攻略"), icon = "Challenge", index = 4, key = 4},
    }

    self.orderList = {
        [self.mgr.orderType.Default] = {{}, {}, {}, {}},
        [self.mgr.orderType.Time] = {{}, {}, {}, {}},
        [self.mgr.orderType.TimeUp] = {{}, {}, {}, {}},
        [self.mgr.orderType.Comment] = {{}, {}, {}, {}},
        [self.mgr.orderType.Cool] = {{}, {}, {}, {}},
    }

    self.myOrderList = {
        [self.mgr.orderType.Default] = {[0] = {}, [1] = {}},
        [self.mgr.orderType.Time] = {[0] = {}, [1] = {}},
        [self.mgr.orderType.TimeUp] = {[0] = {}, [1] = {}},
        [self.mgr.orderType.Comment] = {[0] = {}, [1] = {}},
        [self.mgr.orderType.Cool] = {[0] = {}, [1] = {}},
    }

    self.questionsTab = {}
    self.strategyTab = {[0] = {}, [1] = {}}
    self.itemNumPerTime = 10
end

function StrategyModel:__delete()
end

function StrategyModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = StrategyWindow.New(self)
    end
    self.mainWin:Open(args)
end

function StrategyModel:CloseWindow()
    if self.mainWin ~= nil then
        WindowManager.Instance:CloseWindow(self.mainWin)
        -- self.mainWin = nil
    end
end

function StrategyModel:DeleteWindow()
    if self.mainWin ~= nil then
        self.mainWin:DeleteMe()
        self.mainWin = nil
    end
end

function StrategyModel:SaveDraft()
    local roleData = RoleManager.Instance.RoleData
    local key = BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id, "strategy_draft")
    self.draftTab = self.draftTab or {}
    local str = BaseUtils.serialize(self.draftTab, nil, true, 0)
    PlayerPrefs.SetString(key, str)
end

function StrategyModel:ReadDraft()
    local roleData = RoleManager.Instance.RoleData
    local key = BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id, "strategy_draft")
    local str = PlayerPrefs.GetString(key)
    if str == nil or str == "" or str == "nil" then
        str = "{}"
    end
    self.draftTab = BaseUtils.unserialize(str)
    -- BaseUtils.dump(self.draftTab)
end

function StrategyModel:OpenUploadPanel(args)
    if self.uploadPanel == nil then
        self.uploadPanel = StrategyUploadPanel.New(self, self.mainWin.gameObject)
    end
    self.uploadPanel:Show(args)
end

function StrategyModel:CloseUpdatePanel(args)
    if self.uploadPanel ~= nil then
        self.uploadPanel:DeleteMe()
        self.uploadPanel = nil
    end
end

function StrategyModel:AskMyList(order, type, page)
    if self.myOrderList[order][type][page] == nil then
        self.mgr:send16600(order, type, page, self.itemNumPerTime)
        self.myOrderList[order][type][page] = self.myOrderList[order][type][page] or {order = order, type = type, page = page, list = {}}
    end
end

function StrategyModel:AskList(order, type, page)
    if self.orderList[order][type][page] == nil then
        self.mgr:send16603(order, type, page, self.itemNumPerTime)
        self.orderList[order][type][page] = self.orderList[order][type][page] or {order = order, type = type, page = page, list = {}}
    end
end

function StrategyModel:OpenTypePanel(args)
    if self.typePanel == nil and self.mainWin ~= nil then
        self.typePanel = StrategyUploadPanel.New(self, self.mainWin)
    end
    if self.typePanel ~= nil then
        self.typePanel:Show(args)
    end
end

function StrategyModel:CloseTypePanel()
    if self.typePanel ~= nil then
        self.typePanel:DeleteMe()
        self.typePanel = nil
    end
end

function StrategyModel:OpenQuestionPanel(args)
    if self.questionPanel == nil and self.mainWin ~= nil then
        self.questionPanel = StrategyQuestionPanel.New(self, self.mainWin)
    end
    if self.questionPanel ~= nil then
        self.questionPanel:Show(args)
    end
end

function StrategyModel:CloseQuestionPanel()
    if self.questionPanel ~= nil then
        self.questionPanel:DeleteMe()
        self.questionPanel = nil
    end
end

function StrategyModel:AskQuestion(id)
    if self.questionsTab[id] == nil then
        self.mgr:send16606(id)
    else
        self:OpenQuestionPanel(id)
    end
end

function StrategyModel:ClearMyList()
    self.myOrderList = {
        [self.mgr.orderType.Default] = {[0] = {}, [1] = {}},
        [self.mgr.orderType.Time] = {[0] = {}, [1] = {}},
        [self.mgr.orderType.TimeUp] = {[0] = {}, [1] = {}},
        [self.mgr.orderType.Comment] = {[0] = {}, [1] = {}},
        [self.mgr.orderType.Cool] = {[0] = {}, [1] = {}},
    }
end

function StrategyModel:ClearList()
    self.orderList = {
        [self.mgr.orderType.Default] = {{}, {}, {}, {}},
        [self.mgr.orderType.Time] = {{}, {}, {}, {}},
        [self.mgr.orderType.TimeUp] = {{}, {}, {}, {}},
        [self.mgr.orderType.Comment] = {{}, {}, {}, {}},
        [self.mgr.orderType.Cool] = {{}, {}, {}, {}},
    }
    self.strategyTab = {[0] = {}, [1] = {}}
end


function StrategyModel:ShareStrategy(panelType, channel, title_id, title)
    local sendData = string.format("{strategy_1, %s, %s}", tostring(title_id), tostring(title))
    if panelType == MsgEumn.ExtPanelType.Friend then
        FriendManager.Instance:SendMsg(channel.id, channel.platform, channel.zone_id, sendData)
    elseif panelType == MsgEumn.ExtPanelType.Chat then
        ChatManager.Instance:SendMsg(channel, sendData)
    end
end

