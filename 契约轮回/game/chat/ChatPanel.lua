ChatPanel = ChatPanel or class("ChatPanel", BasePanel)
local ChatPanel = ChatPanel

function ChatPanel:ctor()
    self.abName = "chat"
    self.assetName = "ChatPanel"
    self.layer = "Bottom"

    self.globalEvents = {}
    self.events = {}
    self.item_list = {}
    self.bgRectTra = nil
    self.closeRectTra = nil
    self.crnt_channel = 1
    self.last_channel = 1
    self.is_exist_always = true
    self.model = ChatModel.GetInstance()
    self.btnMapChannel = {}                --按钮与频道映射
    self.panels = {}
    self.panelsCls = {}                    --保存类
    self.btnsSelect = {}

    self.bagBtns = {}
    self.bagViews = {}

    self.is_showing_deco = false
    self.role_update_list = self.role_update_list or {}

    local roleData = RoleInfoModel:GetInstance():GetMainRoleData()
    if PlatformManager:IsCN() then
        VoiceManager:GetInstance():SetGVoiceAppInfo(roleData.id)
    end
    BeastCtrl:GetInstance():RequestBeastList()
    BagController:GetInstance():RequestBagInfo(BagModel.beast)
end

function ChatPanel:LoadCallBack()
    self.nodes = {
        "inlineManager",
        "bg",
        "CloseBtn",
        "panelContain",
        "lock",
        "lock/no",
        "lock/yes",
        "btnContain/worldChatBtn",
        "btnContain/areaChatBtn",
        "btnContain/crossChatBtn",
        "btnContain/organizeChatBtn",
        "btnContain/teamChatBtn",
        "btnContain/unionChatBtn",
        "btnContain/privateChatBtn",
        "btnContain/systemChatBtn",
        "btnContain/worldChatBtn/worldSelect",
        "btnContain/areaChatBtn/areaSelect",
        "btnContain/crossChatBtn/crossSelect",
        "btnContain/organizeChatBtn/organizeSelect",
        "btnContain/teamChatBtn/teamSelect",
        "btnContain/unionChatBtn/unionSelect",
        "btnContain/privateChatBtn/privateSelect",
        "btnContain/systemChatBtn/systemSelect",

        "Buttom",

        --聊天气泡etc
        "btn_deco",
        "btn_deco/red_con",
    }

    self:GetChildren(self.nodes)
    self:AddEvent()

    --self.model.inlineManager = self.inlineManager
    --self.model.inlineManagerScp = self.transform:GetComponent("InlineManager")
    --self.model.inlineManagerScp:LoadEmoji("asset/chatemoji_asset","emoji",0,30)

    self.closeRectTra = self.CloseBtn:GetComponent('RectTransform')
    self.bgRectTra = self.bg:GetComponent('RectTransform')

    self.btnMapChannel[self.worldChatBtn] = 1
    self.btnMapChannel[self.areaChatBtn] = 2
    self.btnMapChannel[self.crossChatBtn] = 3
    self.btnMapChannel[self.organizeChatBtn] = 4
    self.btnMapChannel[self.teamChatBtn] = 5
    self.btnMapChannel[self.unionChatBtn] = 6
    self.btnMapChannel[self.privateChatBtn] = 99
    self.btnMapChannel[self.systemChatBtn] = 100

    self.btnsSelect[1] = self.worldSelect
    self.btnsSelect[2] = self.areaSelect
    self.btnsSelect[3] = self.crossSelect
    self.btnsSelect[4] = self.organizeSelect
    self.btnsSelect[5] = self.teamSelect
    self.btnsSelect[6] = self.unionSelect
    self.btnsSelect[99] = self.privateSelect
    self.btnsSelect[100] = self.systemSelect

    self.panelsCls[1] = WorldChatView
    self.panelsCls[2] = AreaChatView
    self.panelsCls[3] = CrossChatView
    self.panelsCls[4] = OrganizeChatView
    self.panelsCls[5] = TeamChatView
    self.panelsCls[6] = UnionChatView
    self.panelsCls[99] = PrivateChatView
    self.panelsCls[100] = SystemChatView

    self.is_load_cb = true
    self:SwitchPanel(self.model.openPanelChannel)

    SetAlignType(self.transform, bit.bor(AlignType.Left, AlignType.Null))
    local x, _ = GetLocalPosition(self.transform)
    self.to_x = x
    SetLocalPosition(self.transform, -700, 0, 0)
    self:CheckDecoShow()
end

function ChatPanel:dctor()
    if self.update_deco_rd_event_id then
        GlobalEvent:RemoveListener(self.update_deco_rd_event_id)
        self.update_deco_rd_event_id = nil
    end
    if self.update_dec_show_event_id then
        GlobalEvent:RemoveListener(self.update_dec_show_event_id)
        self.update_dec_show_event_id = nil
    end
    if self.deco_red_dot then
        self.deco_red_dot:destroy()
        self.deco_red_dot = nil
    end
    if not table.isempty(self.role_update_list) then
        for _, event_id in pairs(self.role_update_list) do
            RoleInfoModel.GetInstance():GetMainRoleData():RemoveListener(event_id)
        end
        self.role_update_list = nil
    end

    if self.time_id then
        GlobalSchedule:Stop(self.time_id)
    end

    for i, v in pairs(self.panels) do
        v:destroy()
    end

    self.panels = {}

    for i, v in pairs(self.events) do
        self.model:RemoveListener(v)
    end

    for i, v in pairs(self.globalEvents) do
        GlobalEvent:RemoveListener(v)
    end
    self.globalEvents = {}

    if self.buttomView ~= nil then
        self.buttomView:destroy()
    end
    lua_panelMgr.single_panel_list[self.__cname] = nil
end

function ChatPanel:Open()
    ChatPanel.super.Open(self)
end

function ChatPanel:StartAction()
    if self.time_id ~= nil then
        GlobalSchedule:Stop(self.time_id)
    end
    local function step()
        local delayaction = cc.DelayTime(0.03)
        local moveAction = cc.MoveTo(0.1, self.to_x, 0, 0)
        local action = cc.Sequence(delayaction, moveAction)
        cc.ActionManager:GetInstance():addAction(action, self.transform)
        self.transform:SetAsLastSibling()
    end
    self.time_id = GlobalSchedule:StartOnce(step, 0.01)

    if self.is_load_cb then
        self:SwitchPanel(self.model.openPanelChannel)
    end
end

function ChatPanel:OnDisable()
    ChatPanel.super.OnDisable(self)
end

function ChatPanel:AddEvent()
    self.update_deco_rd_event_id = GlobalEvent:AddListener(FashionEvent.AddDecoRD, handler(self, self.SetDecoRD))
    --只是聊天这边用的事件
    self.update_dec_show_event_id = GlobalEvent:AddListener(FashionEvent.ChangeChatDecoRD, handler(self, self.SetDecoRD))

    --聊天气泡
    local function callback()
        lua_panelMgr:GetPanelOrCreate(DecoratePanel):Open()
    end
    AddButtonEvent(self.btn_deco.gameObject, callback)
    self.role_update_list[#self.role_update_list + 1] = RoleInfoModel.GetInstance():GetMainRoleData():BindData("level", handler(self, self.CheckDecoShow))

    if PlatformManager:IsCN() then
        VoiceManager:GetInstance():ApplyMessageKey()
    end

    local function call_back(target, x, y)
        --世界频道
        self:SwitchPanel(self.btnMapChannel[self.worldChatBtn])
    end
    AddClickEvent(self.worldChatBtn.gameObject, call_back)

    local function call_back(target, x, y)
        --地区频道
        self:SwitchPanel(self.btnMapChannel[self.areaChatBtn])
    end
    AddClickEvent(self.areaChatBtn.gameObject, call_back)

    local function call_back(target, x, y)
        --跨服频道
        self:SwitchPanel(self.btnMapChannel[self.crossChatBtn])
    end
    AddClickEvent(self.crossChatBtn.gameObject, call_back)

    local function call_back(target, x, y)
        --组队频道
        self:SwitchPanel(self.btnMapChannel[self.organizeChatBtn])
    end
    AddClickEvent(self.organizeChatBtn.gameObject, call_back)

    local function call_back(target, x, y)
        --队伍频道
        self:SwitchPanel(self.btnMapChannel[self.teamChatBtn])
    end
    AddClickEvent(self.teamChatBtn.gameObject, call_back)

    local function call_back(target, x, y)
        --队伍频道
        self:SwitchPanel(self.btnMapChannel[self.teamChatBtn])
    end
    AddClickEvent(self.teamChatBtn.gameObject, call_back)

    local function call_back(target, x, y)
        --仙盟频道
        self:SwitchPanel(self.btnMapChannel[self.unionChatBtn])
    end
    AddClickEvent(self.unionChatBtn.gameObject, call_back)

    local function call_back(target, x, y)
        --私聊频道
        self:SwitchPanel(self.btnMapChannel[self.privateChatBtn])
    end
    AddClickEvent(self.privateChatBtn.gameObject, call_back)

    local function call_back(target, x, y)
        --私聊频道
        self:SwitchPanel(self.btnMapChannel[self.systemChatBtn])
    end
    AddClickEvent(self.systemChatBtn.gameObject, call_back)


    --[[local function call_back(target,x,y)                          --锁屏操作
        self.model.isLockScreen = not self.model.isLockScreen
        SetVisible(self.yes.gameObject,self.model.isLockScreen)
        SetVisible(self.no.gameObject, not self.model.isLockScreen)
    end
    AddClickEvent(self.lock.gameObject,call_back)--]]



    local function call_back(target, x, y)
        --关闭

        --self:Close()
        local action = cc.MoveTo(0.1, -700, 0, 0)
        local function on_end_callback()
            self:Close()
            GlobalEvent:Brocast(ChatEvent.CloseChatPanel)
        end
        local end_action = cc.CallFunc(on_end_callback)
        action = self:ComboAction(action, end_action)

        cc.ActionManager:GetInstance():addAction(action, self.transform)
    end
    AddClickEvent(self.CloseBtn.gameObject, call_back)

    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(ChatEvent.ChatGoodsInfo, handler(self, self.DealChatGoodsInfo))
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(ChatEvent.OpenEmojiView, handler(self, self.DealOpenEmojiView))
    --self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd,handler(self,self.DealChangeSceneEnd))
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(GoodsEvent.QueryDroppedEvent, handler(self, self.DealChatGoodsInfo))
    local function call_back()
        self:destroy()
    end
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(EventName.GameReset, call_back)

    local function call_back()
        local function call_back2(...)
            self:SetOrderByParentMax()
        end
        GlobalSchedule:StartOnce(call_back2, 0.5)
    end
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back)
end

function ChatPanel:CheckDecoShow()
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    SetVisible(self.btn_deco, lv >= 90)
end

function ChatPanel:ComboAction(action1, action2)
    if action1 and action2 then
        return cc.Sequence(action1, action2)
    elseif not action1 then
        return action2
    elseif not action2 then
        return action1
    end
end

function ChatPanel:DealChangeSceneEnd(...)
    if self.gameObject.activeInHierarchy then
        local param = { ... }
        if param[1] == self.model.targetSceneId then
            local targetX = tonumber(self.model.mapPositionTbl[1]) * SceneConstant.BlockSize.w
            local targetY = tonumber(self.model.mapPositionTbl[2]) * SceneConstant.BlockSize.h
            OperationManager.GetInstance():TryMoveToPosition(param[1], nil, Vector2(targetX, targetY))
        end
    end
end

function ChatPanel:DealChatGoodsInfo(goodsInfo)
    if not self.gameObject.activeInHierarchy then
        return
    end

    --param包含参数
    --cfg  该物品(装备)的配置(比较神兽装备配置，人物装备配置),不一定是itemConfig
    --p_item 服务器给的，服务器没给，只传cfg就好
    --model 管理该tip数据的实例
    --operate_param --操作参数

    local param = {}
    --local code, infoTbl = pcall(loadstring(string.format("do local _=%s return _ end", goodsInfo)))
    local bagId = BagModel.Instance:GetBagIdByUid(goodsInfo.uid)
    local UITransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.UI)
    param["item_id"] = goodsInfo.id
    param["p_item"] = goodsInfo
    if enum.ITEM_STYPE.ITEM_STYPE_WEAPON <= goodsInfo.uid and enum.ITEM_STYPE.ITEM_STYPE_LOCK >= goodsInfo.uid then
        param["model"] = BagModel.Instance
    elseif bagId == BagModel.bagId or bagId == BagModel.wareHouseId then
        param["model"] = BagModel.Instance
    elseif bagId == BagModel.beast then
        param["model"] = BeastModel.Instance
    else
        param["model"] = BagModel.Instance
    end

    local goodConfig = Config.db_item[goodsInfo.id]
    if goodConfig.tip_type == 1 then
        local _param = {}
        _param["cfg"] = cfg
        self.tipview = FashionTipView(self.transform)
        self.tipview:ShowTip(_param)
        return
    elseif goodConfig.tip_type == 11 or goodConfig.tip_type == 12 then
        local _param = {}
        _param["cfg"] = goodConfig
        self.tipview = FrameTipView(self.transform)
        self.tipview:ShowTip(_param)
        return
    elseif goodConfig.tip_type == 13 then
        local _param = {}
        _param["cfg"] = goodConfig
        self.tipview = MagicTipView(self.transform)
        self.tipview:ShowTip(_param)
        return
    end

    if goodConfig.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP or goodConfig.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BEAST then
        local tipView = EquipTipView(UITransform)
        tipView:ShowTip(param)
    elseif goodConfig.type == enum.ITEM_TYPE.ITEM_TYPE_MISC and goodConfig.stype == enum.ITEM_STYPE.ITEM_STYPE_PET then
        local pos = self.transform.position
        local view = PetShowTipView()
        view:SetData(goodsInfo, PetModel.TipType.PetEgg, pos)
    elseif goodConfig.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_MECHA then
        local view = MachineArmorTipView(UITransform)
        view:ShowTip(param)
    else
        local tipView = GoodsTipView(UITransform)
        tipView:ShowTip(param)
    end
end

function ChatPanel:DealOpenEmojiView(show)
    if not self.gameObject.activeInHierarchy then
        return
    end

    if self.buttomView == nil then
        self.buttomView = ChatButtomView(self.Buttom)
    end

    if not show then
        self.buttomView:destroy()
        self.buttomView = nil
    end

end

function ChatPanel:OpenCallBack()
    self:StartAction()

    --装饰界面红点检查
    local is_show_deco_rd = FashionModel.GetInstance():CheckIsShowSideRedDot(11) or FashionModel.GetInstance():CheckIsShowSideRedDot(12)
    self:SetDecoRD(is_show_deco_rd)
end

function ChatPanel:CloseCallBack()
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.transform)
end

function ChatPanel:SwitchPanel(channel)
    self.crnt_channel = channel
    if self.btnsSelect[self.last_channel] ~= nil then
        SetVisible(self.btnsSelect[self.last_channel], false)
    end

    if self.panels[self.last_channel] ~= nil then
        self.panels[self.last_channel]:SetVisible(false)
    end

    if self.panels[channel] == nil then
        self.panels[channel] = self.panelsCls[channel](self.panelContain, "UI")
        self.panels[channel]:SetTransformName(tostring(self.panelsCls[channel].__cname))
    end

    SetVisible(self.btnsSelect[channel], true)
    self.panels[channel]:SetVisible(true)

    self.last_channel = channel
end

function ChatPanel:SetDecoRD(isShow)
    if not self.deco_red_dot then
        self.deco_red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.deco_red_dot:SetPosition(0, 0)
    self.deco_red_dot:SetRedDotParam(isShow)
end