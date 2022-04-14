-- @Author: lwj
-- @Date:   2019-03-02 11:30:49
-- @Last Modified time: 2019-02-15 19:31:16

CandyChatView = CandyChatView or class("CandyChatView", BaseChatView)
local CandyChatView = CandyChatView

function CandyChatView:ctor(parent_node, layer)
    self.abName = "candy"
    self.assetName = "CandyChatView"
    self.layer = layer

    self.channel = ChatModel.AreaChannel
    self.model = CandyChatModel.GetInstance()
    CandyChatView.super.Load(self)
end

function CandyChatView:dctor()
    if self.cd.fillAmount > 0 then
        GlobalEvent:Brocast(CandyEvent.ContinueCdCountDown, self.cd.fillAmount)
    end
    self:StopMySchedule()
    if self.handle_chat_info_event_id then
        GlobalEvent:RemoveListener(self.handle_chat_info_event_id)
        self.handle_chat_info_event_id = nil
    end
    --for i, v in pairs(self.model.) do
    --
    --end
end

function CandyChatView:LoadCallBack()
    self.nodes = {
        "bottom/btn_dice",
        "bottom/mask",
        "bottom/mask/cd",
        "bottom/mask/cd_text",
        "bottom/TextInput/Placeholder",
    }
    self:GetChildren(self.nodes)
    self.cd = GetImage(self.cd)
    self.cd_text = GetText(self.cd_text)
    self.dice_img = GetImage(self.btn_dice)
    self.text_holder = GetText(self.Placeholder)
    CandyChatView.super.LoadCallBack(self)

    local remain = CandyController.GetInstance().remain_cd
    if remain and remain > 0 then
        self.cd.fillAmount = remain
        self:InCdFunct(remain)
    end
end

function CandyChatView:AddEvent()
    CandyChatView.super.AddEvent(self)
    local function call_back()
        --if not self.hadSend then
        -- 游戏开始会设置随机种子，这里不需要再设置
        -- math.randomseed(os.time())
        local num = math.random(6)

        ChatController.GetInstance():RequestSendChat(self.channel, 0, string.format("X%sX", num), self.sendGoods)

        --[[self.hadSend = true
        local function call_back()
            self.hadSend = false
        end
        GlobalSchedule:StartOnce(call_back, 5)--]]
        --end
        self:InCdFunct()
    end
    AddClickEvent(self.btn_dice.gameObject, call_back)

    local function call_back()
        Notify.ShowText("The dice is warming up now, please try again later!")
    end
    AddClickEvent(self.mask.gameObject, call_back)

    local function callback()
        self.text_holder.enabled = false
    end
    AddClickEvent(self.InputText.gameObject, callback)

    self.handle_chat_info_event_id = GlobalEvent:AddListener(ChatEvent.ChatGoodsInfo, handler(self, self.DealChatGoodsInfo))
end
function CandyChatView:CreateChatItem(chatMsg)
    local settor = nil
    if chatMsg.sender.id == self.roleInfoModel:GetMainRoleId() then
        settor = CandyChatItem(self.Content, "UI")
        self.InputText.text = ""
        self.sendMsg = ""
    else
        settor = CandyChatOtherItem(self.Content, "UI")
    end
    table.insert(self.model:GetChannelItemsByChannel(chatMsg.channel_id), settor)
    settor:SetInfo(chatMsg, self.scrollRect)

    self.settors = self.model:GetChannelItemsByChannel(chatMsg.channel_id)
end

function CandyChatView:InCdFunct(remain)
    SetVisible(self.mask, true)
    if not remain then
        self.cd.fillAmount = 1
    end
    self:StopMySchedule()
    self.schedule = GlobalSchedule.StartFun(handler(self, self.BeginningCD), 0.1, -1)
end

function CandyChatView:BeginningCD()
    if self.cd.fillAmount > 0 then
        self.cd.fillAmount = self.cd.fillAmount - CandyModel.GetInstance().per_move
        self.cd_text.text = math.floor(self.cd.fillAmount * 60)
    else
        self:StopMySchedule()
        SetVisible(self.mask, false)
    end
end

function CandyChatView:LoadItems()
    local msgs = ChatModel.GetInstance().msg_list_by_channel[self.channel] or {}
    for i, v in pairs(msgs) do
        v.isHadSended = true
        self:ReceiveMessage(v)
    end
    GlobalEvent:Brocast(ChatEvent.CheckHaveUnRead, self.channel)
end

function CandyChatView:StopMySchedule()
    if self.schedule then
        GlobalSchedule:Stop(self.schedule)
        self.schedule = nil
    end
end

function CandyChatView:DealChatGoodsInfo(goodsInfo)
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

    if Config.db_item[goodsInfo.id].type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP or Config.db_item[goodsInfo.id].type ==
            enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BEAST then
        local tipView = EquipTipView(UITransform)
        tipView:ShowTip(param)
    else
        local tipView = GoodsTipView(UITransform)
        tipView:ShowTip(param)
    end
end

function CandyChatView:ReceiveMessage(chatMsg)
    if chatMsg.channel_id == self.channel then
        self.sendMsg = ""
        self.sendGoods = {}
        self.sendGoodsPos = {}
        self:CheckDeleteChat()
        self:CreateChatItem(chatMsg)
        --local chat_panel = lua_panelMgr:GetPanel(CandyChatView)
        --if chat_panel and chat_panel.isShow then
        chatMsg.is_read = true
        --end
    end
end