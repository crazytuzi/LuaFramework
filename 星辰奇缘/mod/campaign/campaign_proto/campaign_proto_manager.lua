-- @author hze
-- @date #2019/05/28#

CampaignProtoManager = CampaignProtoManager or BaseClass(BaseManager)

function CampaignProtoManager:__init()
    if CampaignProtoManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    CampaignProtoManager.Instance = self
    self.model = CampaignProtoModel.New()


    self.LuckyTreeTag = "LUCKYTREETAG"

    self:InitHandler()
    
    self.luckytreeUpdateEvent = EventLib.New()
    self.lucktreeGetEvent = EventLib.New()

    self.updateWarOrderEvent = EventLib.New()   --战令活动数据事件
    self.updateWarOrderQuestEvent = EventLib.New()   --战令任务数据事件
    self.updateWarOrderHasGetEvent = EventLib.New()   --战令任务数据事件

    self.updateCustomGiftEvent = EventLib.New()   --定制礼包刷新事件

    self.updatePrayTreasureEvent = EventLib.New()   --祈愿活动信息刷新事件
    self.getPrayTreasureRewardEvent = EventLib.New()   --祈愿获得奖励事件
end

function CampaignProtoManager:InitHandler()
    self:AddNetHandler(20482, self.On20482)
    self:AddNetHandler(20483, self.On20483)
    self:AddNetHandler(20484, self.On20484)

    self:AddNetHandler(20485, self.On20485)
    self:AddNetHandler(20487, self.On20487)
    self:AddNetHandler(20488, self.On20488)
    self:AddNetHandler(20489, self.On20489)
    self:AddNetHandler(20490, self.On20490)
    self:AddNetHandler(10261, self.On10261)
    self:AddNetHandler(20495, self.On20495)

    self:AddNetHandler(20491, self.On20491)
    self:AddNetHandler(20492, self.On20492)
    
    self:AddNetHandler(21200, self.On21200)
    self:AddNetHandler(21201, self.On21201)
    self:AddNetHandler(21202, self.On21202)
    self:AddNetHandler(21203, self.On21203)
end

function CampaignProtoManager:RequestInitData()
    self:Send20482()
    self:Send20485()
    self:Send20495()
    self:Send10261()
    self:Send20491()
    self:Send21200()
end

---------------------------- 协议部分 ------------------------------
-- 请求幸运树数据
function CampaignProtoManager:Send20482()
	-- print("发送20482协议")
   self:Send(20482,{})
end

function CampaignProtoManager:On20482(data)
    -- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20482</color>"))
    self.model:SetLuckyTreeData(data)
	self.luckytreeUpdateEvent:Fire()
end

function CampaignProtoManager:Send20483()
	-- print("发送20483协议")
   self:Send(20483,{})
end

function CampaignProtoManager:On20483(data)
	-- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20483</color>"))
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.item_id ~= nil and data.item_id ~= 0 then 
        self.lucktreeGetEvent:Fire(data.item_id)
    end
end

function CampaignProtoManager:Send20484(data)
	-- print("发送20484协议")
   self:Send(20484,{})
end

function CampaignProtoManager:On20484(data)
    -- BaseUtils.dump(data,TI18N("<color=#FF0000>接收20484</color>"))
    self.model.getItemMark = true
end

-------------------战令活动------------------
--战令活动数据
function CampaignProtoManager:Send20485()
    print("发送20485协议")
    self:Send(20485, {})
end

function CampaignProtoManager:On20485(data)
    BaseUtils.dump(data,TI18N("<color=#FF0000>接收20485</color>"))
    self.model.warOrderData = data

    local flag = false
    for i ,v in ipairs(data.token_info) do
        if v.id == 2 then
            flag = true
        end
    end
    self.model.highLevelWarStatus = flag
    
    self.updateWarOrderEvent:Fire()
end

--领取战令周宝箱
function CampaignProtoManager:Send20487()
    print("发送20487协议")
    self:Send(20487, {})
end

function CampaignProtoManager:On20487(data)
    BaseUtils.dump(data,TI18N("<color=#FF0000>接收20487</color>"))
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--购买等级
function CampaignProtoManager:Send20488(id)
    print("发送20488协议")
    self:Send(20488, {id = id})
end

function CampaignProtoManager:On20488(data)
    BaseUtils.dump(data,TI18N("<color=#FF0000>接收20488</color>"))
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--领取战令等级奖励
function CampaignProtoManager:Send20489(id, lev)
    print("发送20489协议")
    self:Send(20489, {id = id , lev = lev})
end

function CampaignProtoManager:On20489(data)
    BaseUtils.dump(data,TI18N("<color=#FF0000>接收20489</color>"))
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--一键领取
function CampaignProtoManager:Send20490()
    print("发送20490协议")
    self:Send(20490, {})
end

function CampaignProtoManager:On20490(data)
    BaseUtils.dump(data,TI18N("<color=#FF0000>接收20490</color>"))
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--战令任务信息
function CampaignProtoManager:Send10261()
    print("发送10261协议")
    self:Send(10261, {})
end

function CampaignProtoManager:On10261(data)
    BaseUtils.dump(data, TI18N("<color=#FF0000>接收10261</color>"))
    self.model:UpdateWarOrderQuestData(data)
    self.updateWarOrderQuestEvent:Fire()
end

--战令领取信息
function CampaignProtoManager:Send20495()
    print("发送20495协议")
    self:Send(20495, {})
end

function CampaignProtoManager:On20495(data)
    BaseUtils.dump(data, TI18N("<color=#FF0000>接收20495</color>"))
    self.model.warOrderHasGet = data
    self.updateWarOrderHasGetEvent:Fire()
end

-------------------定制礼包------------------
--获取礼包定制信息
function CampaignProtoManager:Send20491()
    print("发送20491协议")
    self:Send(20491, {})
end

function CampaignProtoManager:On20491(data)
    BaseUtils.dump(data, TI18N("<color=#FF0000>接收20491</color>"))
    self.model:UpdateCustomGiftData(data)
    self.updateCustomGiftEvent:Fire()
end

--礼包定制购买
function CampaignProtoManager:Send20492(gift_id, item_ids)
    print("发送20492协议")
    self:Send(20492, {gift_id = gift_id, item_ids = item_ids})
end

function CampaignProtoManager:On20492(data)
    BaseUtils.dump(data, TI18N("<color=#FF0000>接收20492</color>"))
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


-------------------祈愿活动------------------
--活动信息
function CampaignProtoManager:Send21200()
    self:Send(21200, {})
end

function CampaignProtoManager:On21200(data)
    self.model:CampPrayInfo(data)
    self.updatePrayTreasureEvent:Fire()
end

--选择奖池
function CampaignProtoManager:Send21201(choose_items)
    self:Send(21201, {choose_items = choose_items})
end

function CampaignProtoManager:On21201(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        --选择奖池成功，跳回主界面
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.praytreasurewindow, {index = 1})
    end
end

--抽奖
function CampaignProtoManager:Send21202(mode)
    self:Send(21202, {mode = mode})
end

function CampaignProtoManager:On21202(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 0 then
        data.id = -1
    end
    self.getPrayTreasureRewardEvent:Fire(data.id)
end

--领取抽奖物品
function CampaignProtoManager:Send21203()
    self:Send(21203, {})
end

function CampaignProtoManager:On21203(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 and not self.model.prayTreasureMode then
        local item_list = {}
        for i, v in ipairs(data.gain) do
            table.insert(item_list, {base_id = v.item_id, num = v.count} )
        end
        BackpackManager.Instance.mainModel:OpenGiftShow({item_list = item_list})
    end
end


