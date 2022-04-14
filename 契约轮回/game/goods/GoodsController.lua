--
-- @Author: chk
-- @Date:   2018-08-30 17:31:33
--

require('game.goods.RequireGoods')

--物品操作相关
GoodsController = GoodsController or class("GoodsController", BaseController)
local GoodsController = GoodsController

local check_handle = {}
local function check_afk_equip(itemid, num, callback)
    return SettingModel:GetInstance():CheckUseEquip(itemid, num, callback)
end
check_handle[enum.ITEM_STYPE.ITEM_STYPE_AFK] = check_afk_equip

local function check_title_handle(itemid, num, callback)
    local is_empty = TitleModel.GetInstance():IsTitleListEmpty()
    if is_empty then
        TitleController:GetInstance():RequestActivateTitle(itemid)
    else
        local cf = String2Table(Config.db_item[itemid].jump)
        OpenLink(unpack(cf))
        --TempOpenLink(unpack(cf))
    end
end
check_handle[enum.ITEM_STYPE.ITEM_STYPE_TITLE] = check_title_handle

local function check_expcard_equip(itemid, num, callback)
    local main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
    local bo, value, buff_id = main_role_data:IsAddExp1Buff()
    local cfg_item = Config.db_item[itemid]
    local buff_id2 = tonumber(cfg_item.effect)
    if bo and buff_id ~= buff_id2 then
        local group1 = Config.db_buff[buff_id].group
        local group2 = Config.db_buff[buff_id2].group
        if group1 == group2 then
            local message = string.format("EXP potion already activated.Use<color=#%s>%s</color> to Switch？", ColorUtil.GetColor(cfg_item.color), cfg_item.name)
            Dialog.ShowTwo("Tip", message, "Confirm", callback, nil, "Cancel")
        else
            callback()
        end
    else
        callback()
    end
end
check_handle[enum.ITEM_STYPE.ITEM_STYPE_EXP_CARD] = check_expcard_equip

local function Guild_Rename(itemid, num)
    local role = RoleInfoModel.GetInstance():GetMainRoleData()
    if role.guild ~= "0" then
        -- 有公会
        local myPost = FactionModel:GetInstance():SetSelfCadre()
        print2(myPost)
        if myPost == enum.GUILD_POST.GUILD_POST_CHIEF then
            --会长
            lua_panelMgr:GetPanelOrCreate(FactionRenamePanel):Open()
        else
            Notify.ShowText("You don't have the access to change guild name")
        end
    else
        Notify.ShowText("You didn't join any guild yet!")
    end

end
check_handle[enum.ITEM_STYPE.ITEM_STYPE_GUILD_CARD] = Guild_Rename

local function Role_Rename(itemid, num)
	
	lua_panelMgr:GetPanelOrCreate(RoleReNamePanel):Open(1)
end

check_handle[enum.ITEM_STYPE.ITEM_STYPE_CHARACTER_CARD] = Role_Rename

function GoodsController:ctor()
    GoodsController.Instance = self

    self.crntCheckItemUid = nil                   --请求当前物品信息的
    self.model = GoodsModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function GoodsController:dctor()
end

function GoodsController:GetInstance()
    if not GoodsController.Instance then
        GoodsController.new()
    end
    return GoodsController.Instance
end

--打开宝石详细面板
function GoodsController:OpenStoneDetailPanel(goodsItem)
    self.model.goodsItem = goodsItem
    lua_panelMgr:GetPanelOrCreate(StoneDetailPanel):Open()
end

function GoodsController:OpenGoodsDetailPanel(goodsItem, parent)
    self.model.goodsItem = goodsItem
    lua_panelMgr:GetPanelOrCreate(GoodsDetailPanel):Open()
end

function GoodsController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1102_item_pb"
    self:RegisterProtocal(proto.ITEM_DETAIL, self.HandleItemInfo)
    self:RegisterProtocal(proto.ITEM_USE, self.HandleUseItem)
    self:RegisterProtocal(proto.ITEM_CHUCK, self.handleChuckItem)
    self:RegisterProtocal(proto.ITEM_SELL, self.HandleSellItems)
    self:RegisterProtocal(proto.ITEM_STORE, self.HandleStore)
    self:RegisterProtocal(proto.ITEM_FETCH, self.HandleTaktOut)
    self:RegisterProtocal(proto.ITEM_QUERY, self.HandleQueryDropped)

    --礼包
end

function GoodsController:AddEvents()
    -- --请求基本信息
    -- local function ON_REQ_BASE_INFO()
    -- self:RequestLoginVerify()
    -- end
    -- self.model:AddListener(GoodsModel.REQ_BASE_INFO, ON_REQ_BASE_INFO)
end

-- overwrite
function GoodsController:GameStart()

end


--请求道具(装备)详细信息
--查看背包物品 pos=BagID, id=uid
--查看装备     pos=1, id=SlotID
function GoodsController:RequestItemInfo(pos, id)
    local pb = self:GetPbObject("m_item_detail_tos")
    pb.pos = pos
    pb.id = id
    self:WriteMsg(proto.ITEM_DETAIL, pb)
end

--道具(装备)详细信息返回
function GoodsController:HandleItemInfo()
    local data = self:ReadMsg("m_item_detail_toc")
    local item = Config.db_item[data.item.id]
    if item.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then

    end

    print("装备信息返回:")
    GlobalEvent:Brocast(GoodsEvent.GoodsDetail, data.item)
end

--请求使用道具
function GoodsController:RequestUseItem(uid, num, args)
    local item_id = BagModel:GetInstance():GetItemIdByUid(uid)
    local gift_config = self.model:GetGiftConfig(item_id)
    if gift_config then
        local cost = String2Table(gift_config.cost)
        if gift_config.type == enum.GIFT_TYPE.GIFT_TYPE_GOLD_Multiple then
            lua_panelMgr:OpenPanel(GiftMulPanel, item_id, uid, num)
        elseif cost and cost[1] and cost[1] > 0 then
            lua_panelMgr:OpenPanel(GiftBuyPanel, item_id, uid, num)
        elseif gift_config.type == enum.GIFT_TYPE.GIFT_TYPE_SELECT then
            lua_panelMgr:OpenPanel(GiftSelectPanel, item_id, uid, num)
        else
            self:RequestUseGoods(uid, num, args)
        end
    else
        self:RequestUseGoods(uid, num, args)
    end
end

--[[
	@author LaoY
	@des	
	@param3 args 	额外参数，可以不填
--]]
function GoodsController:RequestUseGoods(uid, num, args)
    local pb = self:GetPbObject("m_item_use_tos")
    pb.uid = uid
    pb.num = num

    local function callback()
        if not table.isempty(args) then
            local len = #args
            for i = 1, len do
                pb.args:append(args[i])
            end
        end
        self:WriteMsg(proto.ITEM_USE, pb)
    end
    local itemid = BagModel:GetInstance():GetItemIdByUid(uid)
    local cf = Config.db_item[itemid]
    if not cf then
        logError("不存在该道具的配置，道具id为：", itemid)
        return
    end
    local SType = cf.stype
    local check_fun = check_handle[SType]
    if check_fun then
        if not check_fun(itemid, num, callback) then
            return
        end
    end
    callback()
end

function GoodsController:HandleUseItem()
    local data = self:ReadMsg("m_item_use_toc")

    SoundManager:GetInstance():PlayById(45)

    -- 打开礼包界面
    local gift_config = self.model:GetGiftConfig(data.id)
    if gift_config then
        GlobalEvent:Brocast(GoodsEvent.UseGiftSuccess, data.id)
    end
    if gift_config and gift_config.settlement == 1 and not table.isempty(data.items) then
        local item_id
        for id, v in pairs(data.items) do
            local cf = Config.db_item[id]
            if cf and cf.type ~= enum.ITEM_TYPE.ITEM_TYPE_MONEY then
                item_id = id
                break
            end
        end
        if item_id then
            local cf = Config.db_magic_card[item_id]
            if cf then
                lua_panelMgr:OpenPanel(GiftRewardMaigcPanel, data.id, data.items)
            else
                lua_panelMgr:OpenPanel(GiftRewardNorPanel, data.id, data.items)
            end
        end
    end
    GlobalEvent:Brocast(GoodsEvent.UseItemSuccess, data.id)
    Chkprint('--LaoY GoodsController.lua,line 128--')
    dump(data, "data")
end

--请求丢弃道具
function GoodsController:RequestChuckItem(uid, num)
    local pb = self:GetPbObject("m_item_chuck_tos")
    pb.uid = uid
    pb.num = num
    self:WriteMsg(proto.ITEM_CHUCK, pb)
end

function GoodsController:handleChuckItem()
    local data = self:ReadMsg("m_item_chuck_toc")

    GlobalEvent:Brocast(GoodsEvent.Destroy, data)
end

--请求出售道具
function GoodsController:RequestSellItems(param)
    local pb = self:GetPbObject("m_item_sell_tos")

    for k, v in pairs(param) do
        local item = pb.items:add()
        item.key = v.key
        item.value = v.value
    end

    self:WriteMsg(proto.ITEM_SELL, pb)
end

function GoodsController:HandleSellItems()
    local data = self:ReadMsg("m_item_sell_toc")
    BagModel.Instance:UpdateItemsBySell(data.cost)
    GlobalEvent:Brocast(GoodsEvent.SellItems)
end

--请求存储物品
function GoodsController:RequestStoreItem(uid, num)
    local pb = self:GetPbObject("m_item_store_tos")
    pb.uid = uid
    pb.num = num
    self:WriteMsg(proto.ITEM_STORE, pb)
end

function GoodsController:HandleStore()
    local data = self:ReadMsg("m_item_store_toc")
    -- data.uid
    -- data.num
end

--从仓库取回
function GoodsController:RequestTakeOut(uid, num)
    local pb = self:GetPbObject("m_item_fetch_tos")
    pb.uid = uid
    pb.num = num
    self:WriteMsg(proto.ITEM_FETCH, pb)
end

function GoodsController:HandleTaktOut()
    local data = self:ReadMsg("m_item_fetch_toc")

end


----请求基本信息
--function LoginController:RequestLoginVerify()
-- local pb = self:GetPbObject("m_login_verify_tos")
-- self:WriteMsg(proto.LOGIN_VERIFY,pb)
--end

----服务的返回信息
--function GoodsController:HandleLoginVerify(  )
-- local data = self:ReadMsg("m_login_verify_toc")
--end


---查询：掉落物品的详细信息
function GoodsController:RequestQueryDropped(cache_id)
    local pb = self:GetPbObject("m_item_query_tos")
    pb.id = cache_id
    self:WriteMsg(proto.ITEM_QUERY, pb)
end

---返回：询掉落物品的详细信息
function GoodsController:HandleQueryDropped()
    local data = self:ReadMsg("m_item_query_toc")
    if (data and data.item) then
        GlobalEvent:Brocast(GoodsEvent.QueryDroppedEvent, data.item)
    end
end