-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: cloud 1206802428@qq.com(必填, 创建模块的人员)
-- @editor: 1206802428@qq.com(必填, 后续维护以及修改的人员)
-- @description:
--      背包的整体逻辑功能
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-02-05
-- --------------------------------------------------------------------
BackpackController = BackpackController or BaseClass(BaseController)

function BackpackController:config()
    self.model = BackpackModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function BackpackController:getModel()
    return self.model
end

function BackpackController:registerEvents()
    --[[if self.login_event_success == nil then
        self.login_event_success = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            self:sender10500()
            self:sender10501()
            -- self:sender10528()
        end)   
    end--]]
end

function BackpackController:registerProtocals()
    self:RegisterProtocal(10500, "handle10500")  --获取背包物品
    self:RegisterProtocal(10501, "handle10501")  --获取装备背包物品
    self:RegisterProtocal(10502, "handle10502")  --获取装备背包物品
    self:RegisterProtocal(10503, "handle10503")  --获取宠物背包物品
    self:RegisterProtocal(10510, "handle10510")  --增加物品通知
    self:RegisterProtocal(10511, "handle10511")  --删除物品通知
    self:RegisterProtocal(10512, "handle10512")  --刷新物品通知
    self:RegisterProtocal(10515, "handle10515")  --使用物品
    self:RegisterProtocal(10520, "handle10520")  --删除物品
    self:RegisterProtocal(10521, "handle10521")  --请求出售获得
    self:RegisterProtocal(10522, "handle10522")  --出售背包物品
    self:RegisterProtocal(10523, "handle10523")  --合成物品
    self:RegisterProtocal(10526, "handle10526")  --扩充存储空间的
    self:RegisterProtocal(10528, "handle10528")  --装备产出效率
    self:RegisterProtocal(10530, "handle10530")  --统一背包满
    self:RegisterProtocal(11008, "handle11008")  --背包碎片合成    
end

--==============================--
--desc:请求背包数据,再断线重连的时候也请求一次,防止互相顶号出现问题
--time:2017-07-03 02:19:19
--@return 
--==============================--
function BackpackController:sender10500()
    self:SendProtocal(10500,{})
end

--[[
    @desc: 请求装备背包物品
    author:{author}
    time:2018-05-08 17:33:01
    return
]]
function BackpackController:sender10501()
    self:SendProtocal(10501, {})
end

function BackpackController:handle10500(data)
    data.bag_code = BackPackConst.Bag_Code.BACKPACK
    self.model:initItemList(data)
end
function BackpackController:handle10501(data)
    data.bag_code = BackPackConst.Bag_Code.EQUIPS
    self.model:initItemList(data)
end
function BackpackController:handle10503(data)
    data.bag_code = BackPackConst.Bag_Code.PETBACKPACK
    self.model:initItemList(data)
end

-- 获取家园背包数据
function BackpackController:sender10502(  )
    self:SendProtocal(10502, {})
end

function BackpackController:handle10502( data )
    data.bag_code = BackPackConst.Bag_Code.HOME
    self.model:initItemList(data)
end

--==============================--
--desc:增加一个物品
--time:2017-07-03 02:20:37
--@data:
--@return 
--==============================--
function BackpackController:handle10510(data)
    self.model:addItemInBagCode(data)
end

--==============================--
--desc:删除
--time:2017-07-03 02:20:08
--@data:
--@return 
--==============================--
function BackpackController:handle10511(data)
    self.model:deleteBagItems(data)
end

--==============================--
--desc:刷新物品通知
--time:2017-07-03 02:22:06
--@data:
--@return 
--==============================--
function BackpackController:handle10512(data)
    self.model:updateBagItemsNum(data)
end

--==============================--
--desc:使用物品
--time:2017-07-03 02:24:49
--@id:
--@quantity:
--@args:
--@return 
--==============================--
function BackpackController:sender10515(id,quantity,args)
    local protocal ={}
    protocal.id = id
    protocal.quantity = quantity
    protocal.args = args or {}
    Debug.info(args )
    self:SendProtocal(10515,protocal)
end
function BackpackController:handle10515(data)
    message(data.msg)
    if data.flag == TRUE then
        self:openBatchUseItemView(false)
        self:closeGiftSelectPanel()
        GlobalEvent:getInstance():Fire(BackpackEvent.BACKPACK_USE_ITEM_EVENT, data)
    end
end

--==============================--
--desc:删除物品,主动删除(暂时是没有用的)
--time:2017-07-03 02:26:43
--@id:
--@bag_type:
--@return 
--==============================---
function BackpackController:sender10520(id,bag_type)
    local protocal ={}
    protocal.id =id
    protocal.storage = bag_type
    self:SendProtocal(10520,protocal)
end
function BackpackController:handle10520(data)
    message(data.msg)
end

--==============================--
--desc:请求出售获得物品
--time:2017-07-03 02:27:54
--@storage:
--@args:
--@return 
--==============================--
function BackpackController:sender10521(storage,args)
    local protocal ={}
    protocal.storage = storage
    protocal.args = args
   self:SendProtocal(10521,protocal)
end

function BackpackController:handle10521(data)
    if data.items then
        -- 请求出售获得成功之后打开出售确认面板
        GlobalEvent:getInstance():Fire(BackpackEvent.BACKPACK_SELL_CONFIRM, data)
    end
end 

--==============================--
--desc:出售物品
--time:2017-07-03 02:27:54
--@storage:
--@args:
--@return 
--==============================--
function BackpackController:sender10522(storage,args)
    local protocal ={}
    protocal.storage = storage
    protocal.args = args
   self:SendProtocal(10522,protocal)
end

function BackpackController:handle10522(data)
	showAssetsMsg(data.msg)
	if data.flag == TRUE then
		if self.batch_use then
			self:openBatchUseItemView(false)
		end
		if self.sell_window then        -- 出售成功之后关闭出售面板
			self:openSellWindow(false)
        end
        self:closeGiftSelectPanel()
        GlobalEvent:getInstance():Fire(BackpackEvent.Sell_Goods_Success)
	end
end 

function BackpackController:sender10523(id,num)
     local protocal ={}
     protocal.id = id
     protocal.num = num
    self:SendProtocal(10523,protocal)
end
function BackpackController:handle10523(data)
    message(data.msg)
    if data.flag == 1 then
        GlobalEvent:getInstance():Fire(BackpackEvent.Compose_Goods_Success)
        TipsManager:getInstance():showBackPackCompTips(false)
    end
end

--[[
    @desc:请求存储空间扩充
    author:{author}
    time:2018-05-08 17:36:52
    --@type: 
    return
]]
function BackpackController:sender10526(type)
    local protocal = {}
    protocal.type = type
    self:SendProtocal(10526, protocal)
end
function BackpackController:handle10526(data)
    self.model:updateExpansionInfo(data)
end

--[[
    @desc:请求装备产出效率
    author:{author}
    time:2018-05-08 20:38:46
    return
]]
function BackpackController:sender10528()
    self:SendProtocal(10528, {})
end
function BackpackController:handle10528(data)
    self.model:setEquipsOutput(data.time)
    self.model:setExpOutput(data.minu_exp)
end

--装备满提示
function BackpackController:handle10530(data)
    local str = TI18N("背包已满，战斗将无法获得掉落的道具奖励，是否前往熔炼?")
    local function fun()
        MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.backpack,BackPackConst.item_tab_type.EQUIPS)
    end
    CommonAlert.show(str, TI18N("确认"), fun, TI18N("取消"), nil, CommonAlert.type.rich, nil, nil, nil, true)
end


--背包碎片合成
function BackpackController:sender11008(bid,num)
    local proto = {}
    proto.bid = bid
    proto.num = num
    self:SendProtocal(11008, proto)
end

function BackpackController:handle11008(data)
    GlobalEvent:getInstance():Fire(BackpackEvent.Compose_BackPack_Success)
    message(data.msg)
    TipsManager:getInstance():showBackPackCompTips(false)
    TipsManager:getInstance():showCompChooseTips(false)
    if data.result == 1 then
        local items = {}
        for i,v in pairs(data.partners) do
            local data = Config.PartnerData.data_partner_base[v.partner_bid] 
            items[i] = {}
            items[i].bid = v.partner_bid
            items[i].star = data.init_star
            items[i].camp_type = data.camp_type
            items[i].show_type = MainuiConst.item_exhibition_type.partner_type
        end
        MainuiController:getInstance():openGetItemView(true, items, 0)
    end
end


--==============================--
--desc:打开背包主界面
--time:2017-07-03 04:55:57
--@value:
--@return 
--==============================--
function BackpackController:openMainView(value, sub_type)
    if value == false then
        if self.back_pack ~= nil then
            self.back_pack:close()
            self.back_pack = nil
        end
        self.back_pack_open_type = sub_type
    else
        sub_type = sub_type or BackPackConst.item_tab_type.PROPS
        if self.back_pack == nil then
            self.back_pack = BackPackWindow.New(sub_type)
        end

        if self.back_pack and self.back_pack:isOpen() == false then
            self.back_pack:open()
        end
    end
end

--==============================--
--desc:设置背包中的装备标签满的状态
--time:2018-07-20 07:35:55
--@status:
--@return 
--==============================---
function BackpackController:setEquipBackPackStatus(status)
    if self.back_pack then
        self.back_pack:setEquipRedStatus(status)
    end
end

function BackpackController:getBackpackRoot()
    if self.back_pack then
        return self.back_pack.root_wnd
    end
end

function BackpackController:getBackpackSellRoot()
    if self.sell_window then
        return self.sell_window.root_wnd
    end
end

--[[
    @desc:打开出售物品界面展示
    author:{author}
    time:2018-05-21 15:02:23
    --@status:
	--@list: 
    return
]]
function BackpackController:openSellWindow(status, bag_code, list)
    if status == false then
        if self.sell_window ~= nil then
            self.sell_window:close()
            self.sell_window = nil
        end
    else
        bag_code = bag_code or BackPackConst.Bag_Code.BACKPACK
        if list == nil or next(list) == nil then return end
        if self.sell_window == nil then
            self.sell_window = BackPackSellWindow.New()
        end
        if self.sell_window:isOpen() == false then
            self.sell_window:open(bag_code, list)
        end
    end
end

--[[
    @desc:出售物品  
    author:lwc
    time:2018年11月29日
    return
]]
function BackpackController:openItemSellPanel(status, goods_vo, bag_code, open_type)
    if status == false then
        if self.item_sell_panel ~= nil then
            self.item_sell_panel:close()
            self.item_sell_panel = nil
        end
    else
        local bag_code = bag_code or BackPackConst.Bag_Code.BACKPACK
        local open_type = open_type or 1
        if self.item_sell_panel == nil then
            self.item_sell_panel = ItemSellPanel.New()
        end
        if self.item_sell_panel:isOpen() == false then
            self.item_sell_panel:open(goods_vo, bag_code, open_type)
        end
    end
end

-- 一键出售神装界面
function BackpackController:openQuickSellHolyWindow( status )
    if status == true then
        if not self.sell_holy_wnd then
            self.sell_holy_wnd = BackPackSellHolyWindow.New()
        end
        if self.sell_holy_wnd:isOpen() == false then
            self.sell_holy_wnd:open()
        end
    else
        if self.sell_holy_wnd then
            self.sell_holy_wnd:close()
            self.sell_holy_wnd = nil
        end
    end
end

-- 一键出售装备界面
function BackpackController:openQuickSellEquipWindow(status)
    if status == true then
        if not self.sell_equip_wnd then
            self.sell_equip_wnd = BackPackSellEquipWindow.New()
        end
        if self.sell_equip_wnd:isOpen() == false then
            self.sell_equip_wnd:open()
        end
    else
        if self.sell_equip_wnd then
            self.sell_equip_wnd:close()
            self.sell_equip_wnd = nil
        end
    end
end

-- 出售物品获得确认界面
function BackpackController:openSellConfirmWindow(status, callback, bag_code, is_show_tips, item_count)
    if status == false then
        if self.sell_confirm_window ~= nil then
            self.sell_confirm_window:close()
            self.sell_confirm_window = nil
        end
    else
        bag_code = bag_code or BackPackConst.Bag_Code.EQUIPS
        if self.sell_confirm_window == nil then
            self.sell_confirm_window = BackPackSellConfirmWindow.New()
        end
        if self.sell_confirm_window:isOpen() == false then
            self.sell_confirm_window:open(callback, bag_code, is_show_tips, item_count)
        end
    end
end

--==============================--
--desc:熔炼装备的拦截面板
--time:2018-07-30 07:24:37
--@status:
--@equip_list:
--@intercept_list:
--@return 
--==============================--
function BackpackController:openBackPackEquipInterceptWindow(status, equip_list, intercept_list)
    if status == false then
        if self.intercept_window ~= nil then
            self.intercept_window:close()
            self.intercept_window = nil
        end
    else
        if intercept_list == nil or next(intercept_list) == nil then
            self:openSellWindow(true, BackPackConst.Bag_Code.EQUIPS, equip_list) 
            return
        end
        if self.intercept_window == nil then
            self.intercept_window = BackPackEquipInterceptWindow.New()
        end
        self.intercept_window:open(equip_list , intercept_list)
    end
end

function BackpackController:getData(  )
    return self.model
end

--==============================--
--desc:判断一个物品来源是否激活,因为剧情副本或者装备副本可能存在未激活,以及活动的也可能未激活
--time:2017-07-29 05:42:01
--@config:
--@return 
--==============================--
function BackpackController:checkItemSoureIsOpenByConfig(config)
    if config.evt_type == BackPackConst.item_source_type.evt_partner_call then
        return true
    elseif config.evt_type == BackPackConst.item_source_type.evt_mall_buy then
        return self:checkShopIsOpen(config.extend[1])
    elseif config.evt_type == BackPackConst.item_source_type.evt_activity then
        return self:checkActivityIsOpen(config.extend[1])
    elseif config.evt_type == BackPackConst.item_source_type.evt_dun_chapter then
        if config.extend[1] == 0 and  config.extend[2] == 0 then 
            return true
        end
        return self:checkDungeonChapterIsOpen(config.extend[1], config.extend[2])
    else
        return true
    end
end

--==============================--
--desc:判断商城,或者某个具体标签是否开启
--time:2017-07-29 05:46:42
--@type:
--@return 
--==============================--
function BackpackController:checkShopIsOpen(type)
    return true
end

--==============================--
--desc:检测一个活动是否开启
--time:2017-07-29 05:47:48
--@bid:
--@return 
--==============================--
function BackpackController:checkActivityIsOpen(bid)
    return true
end

--==============================--
--desc:检测一个章节副本是否开启
--time:2017-07-29 05:48:48
--@id:
--@dun_id:
--@return 
--==============================--
function BackpackController:checkDungeonChapterIsOpen(id, dun_id)
    local model = DungeonController:getInstance():getModel()
    local chapter_vo = model:getChapterWithId(id)
    if chapter_vo == nil then 
        return false
    else
        if dun_id == 0 then
            if chapter_vo.status == DUNGEON_CHAPTER_STATUS.LOCK then 
                return false
            else
                return true
            end
        else
            if chapter_vo.dun_list == nil or chapter_vo.dun_list[dun_id] == nil or chapter_vo.dun_list[dun_id].status == nil then
                return false
            else
                return true
            end
        end
    end
end

--关卡是否已通关
function BackpackController:checkDungeonChapterIsPass(id, dun_id)
    local model = DungeonController:getInstance():getModel()
    local chapter_vo = model:getChapterWithId(id)
    if chapter_vo == nil then 
        return false
    else
        if dun_id == 0 then
            if chapter_vo.status == DUNGEON_CHAPTER_STATUS.LOCK then 
                return false
            else
				for _, v in pairs(chapter_vo.dun_list or {}) do
				    if v.status == 0 then
						return true
					end
				end
                return false
            end
        else
            if chapter_vo.dun_list == nil or chapter_vo.dun_list[dun_id] == nil or chapter_vo.dun_list[dun_id].status == nil or chapter_vo.dun_list[dun_id].status == 1 then
                return false
            else
                return true
            end
        end
    end
end
--==============================--
--desc:判断该物品来源是否有任何一个开启的
--time:2017-07-29 04:41:02
--@id:
--@return 
--==============================--
function BackpackController:checkItemSoureIsOpen(id)
    local config = Config.ItemData.data_get_data(id)
    if config == nil or config.source == nil or next(config.source) == nil then 
        return false
    else
        for i,v in ipairs(config.source) do
            local source_config = Config.SourceData.data_source_data[v]
            if self:checkItemSoureIsOpenByConfig(source_config) == true then
                return true
            end
        end
        return false
    end
end

function BackpackController:openGiftSelectPanel(gift_vo)
    if self.gift_panel == nil then
        self.gift_panel = GiftSelectPanel.New()
    end
    if self.gift_panel and self.gift_panel:isOpen() == false then
        self.gift_panel:open(gift_vo)
    end
end
function BackpackController:closeGiftSelectPanel()
    if self.gift_panel ~= nil then
        self.gift_panel:close()
        self.gift_panel = nil
    end
end
--==============================--
--desc:获取物品来源用于引导
--time:2017-08-04 03:52:20
--@return 
--==============================--
function BackpackController:getItemSourceRoot()
    if self.source_view then
        return self.source_view.root_wnd
    end
end

--==============================--
--desc:直接跳转到指定的来源处
--count:剧情或者地下城时 1：扫荡一次；大于1扫完
--time:2017-07-06 11:45:19
--@data:
--@return 
--==============================--
function BackpackController:gotoItemSourceTarget(data, bid, need_num, count)
end

--直接扫荡
function BackpackController:directorySwap(data, bid, need_num, count)
    if not data then return end
    if data.evt_type ~= BackPackConst.item_source_type.evt_dun_chapter then return end
    if #data.extend < 2 then return end

	local lack_num = 1
	if count > 1 then
		local has_num = self:getModel():getBackPackItemNumByBid(bid)
		lack_num = need_num - has_num
	else
	end

    local dun_id = data.extend[2]
    if dun_id ~= 0 then
		if count > 1 then
			DungeonController:getInstance():requestQuickSwap(dun_id, lack_num, bid, need_num)
		else
			DungeonController:getInstance():requestSwapDungeon(dun_id, 1, bid, need_num)
		end
    else
		local chapter_id = data.extend[1]
		if chapter_id then
			DungeonController:getInstance():requestQuickSwap(chapter_id, lack_num, bid, need_num)
		end
    end
end

--==============================--
--desc:打开批量使用物品窗口
--time:2017-07-05 03:36:15
--@item:必须是物品真是数据
--@type:出售或者使用
--@select_vo :自选礼包点击批量使用要传选中的物品id列表过来
--@return 
--==============================--
function BackpackController:openBatchUseItemView(status, item, type,select_vo)
    if status == false then
        if self.batch_use ~= nil then
            self.batch_use:close()
            self.batch_use = nil
        end
    else
        if item == nil or item.config == nil then return end
        if self.batch_use == nil then
            self.batch_use = BackPackBatchView.New(BackpackController:getInstance())
        end
        if self.batch_use and self.batch_use:isOpen() == false then
            self.batch_use:open(item, type,select_vo)
        end
    end
end

--==============================--
--desc:打开物品合成界面
--time:2018-07-12 11:59:27
--@status:
--@data:
--@return 
--==============================--
function BackpackController:openBackPackComposeWindow(status, data)
    if status == false then
        if self.compose_window ~= nil then
            self.compose_window:close()
            self.compose_window = nil
        end
    else
        if self.compose_window == nil then
            self.compose_window = BackPackComposeWindow.New(data)
        end
        if self.compose_window and self.compose_window:isOpen() == false then
            self.compose_window:open()
        end
    end
end


--==============================--
--desc:打开物品来源
--time:2018-07-04 03:30:47
--@status:
--@data:
--@extend_data:配置表配置的一些扩展来源,需要特殊粗粒的,默认是不显示扩展参数包含某一类型的时候,才显示 {"evt_league_help", true} 这种格式
--@item_list:需求的物品列表,包含了 {bid= k, need_num = treasure.need_num}
--@return 
--==============================--
function BackpackController:openTipsSource( status, data, extend_data, item_list )
    if status then
        -- 这里做一个特殊处理,如果是突破引导的时候,指定id的不出这个...
        local guide_config = GuideController:getInstance():getGuideConfig() 
        -- 这个引导的时候不要谈弹出来
        --if guide_config and guide_config.id == GuideConst.special_id.break_guide then return end

        if type(data) == "number" then
            data = Config.ItemData.data_get_data(data)
        end
        if data == nil then return end
        
        extend_data = extend_data or {}

        if not self.tips_source  then
            self.tips_source = TipsSource.New()
        end
        self.tips_source:open(data, extend_data, item_list)
    else
        if self.tips_source then 
            self.tips_source:close()
            self.tips_source = nil
        end
    end
end

--==============================--
--desc:打开只显示来源的界面 --by lwc
--time:2018-07-04 03:30:47
--@status:
--@data:
--@extend_data:配置表配置的一些扩展来源,需要特殊粗粒的,默认是不显示扩展参数包含某一类型的时候,才显示 {"evt_league_help", true} 这种格式
--@item_list:需求的物品列表,包含了 {bid= k, need_num = treasure.need_num}
--@return 
--==============================--
function BackpackController:openTipsOnlySource( status, data, extend_data, item_list )
    if status then
        -- -- 这里做一个特殊处理,如果是突破引导的时候,指定id的不出这个...
        -- local guide_config = GuideController:getInstance():getGuideConfig() 
        -- -- 这个引导的时候不要谈弹出来
        -- --if guide_config and guide_config.id == GuideConst.special_id.break_guide then return end

        -- if type(data) == "number" then
        --     data = Config.ItemData.data_get_data(data)
        -- end
        if data == nil then return end
        extend_data = extend_data or {}

        if not self.tips_only_source  then
            self.tips_only_source = TipsOnlySource.New()
        end
        self.tips_only_source:open(data, extend_data, item_list)
    else
        if self.tips_only_source then 
            self.tips_only_source:close()
            self.tips_only_source = nil
        end
    end
end

--==============================--
--desc:引导需要
--time:2018-07-24 09:20:15
--@return 
--==============================--
function BackpackController:getItemTipsSourceRoot()
    if self.tips_source then
        return self.tips_source.root_wnd
    end
end

--==============================--
--desc:跳转物品来源的
--time:2018-07-30 10:12:26
--@evt_type:
--@extend:
--@bid:需求物品
--@need_item_list:需求的物品列表
--@return 
--==============================--
function BackpackController:gotoItemSources(evt_type, extend, bid, need_item_list)
    if evt_type == nil or extend == nil then return end

    if evt_type == "evt_partner_call" then --召唤
        JumpController:getInstance():jumpViewByEvtData({1})
    elseif evt_type == "evt_mall_buy" then --商城
        if extend[1] then
            JumpController:getInstance():jumpViewByEvtData({15, extend[1], bid})
        end
        --MallController:getInstance():setNeedBid(bid)
    elseif evt_type == "evt_vip" then -- vip
        JumpController:getInstance():jumpViewByEvtData({7, VIPTABCONST.VIP, extend[1]})
    elseif evt_type == "evt_boss" then --个人BOSS挑战

    elseif evt_type == "evt_world_boss" then --世界boss
    
    elseif evt_type == "evt_tower" then --星命塔
        JumpController:getInstance():jumpViewByEvtData({12})
    elseif evt_type == "evt_divination" then --占卜
        AuguryController:getInstance():openMainView(true)
    elseif evt_type == "evt_dun_chapter" then --剧情副本
        JumpController:getInstance():jumpViewByEvtData({5})
    elseif evt_type == "evt_gold_market" then --金币市场

    elseif evt_type == "evt_silver_market" then --银币市场
    
    elseif evt_type == "evt_arena" then -- 竞技场挑战
        JumpController:getInstance():jumpViewByEvtData({3})
    elseif evt_type == "evt_arena_box" then --竞技场宝箱
        JumpController:getInstance():jumpViewByEvtData({3})
    elseif evt_type == "evt_bag_eqm" then --装备背包
        JumpController:getInstance():jumpViewByEvtData({8, BackPackConst.item_tab_type.EQUIPS})
    elseif evt_type == "evt_bag_partner" then --英雄背包
        JumpController:getInstance():jumpViewByEvtData({8, BackPackConst.item_tab_type.HERO})
    elseif evt_type == "evt_dun_stone" then --宝石副本
        JumpController:getInstance():jumpViewByEvtData({17})
    elseif evt_type == "evt_bag_star_life" then --特殊背包
        JumpController:getInstance():jumpViewByEvtData({8, BackPackConst.item_tab_type.SPECIAL})
    elseif evt_type == "evt_friend" then --好友
        JumpController:getInstance():jumpViewByEvtData({4})
    elseif evt_type == "evt_league" then --公会
        JumpController:getInstance():jumpViewByEvtData({14})
    elseif evt_type == "evt_league_dungeon" then --公会副本
        JumpController:getInstance():jumpViewByEvtData({31})
    elseif evt_type == "evt_league_donate" then --公会捐献
        JumpController:getInstance():jumpViewByEvtData({13})
    elseif evt_type == "evt_league_sail" then --公会远航
        JumpController:getInstance():jumpViewByEvtData({18})
    elseif evt_type == "evt_league_skill" then --公会技能
        JumpController:getInstance():jumpViewByEvtData({32})
    elseif evt_type == "evt_league_shop" then --公会商店
        JumpController:getInstance():jumpViewByEvtData({15, MallConst.MallType.UnionShop})
    elseif evt_type == "evt_league_redpacket" then --公会红包
        JumpController:getInstance():jumpViewByEvtData({33})
    elseif evt_type == "evt_league_war" then --公会战
        JumpController:getInstance():jumpViewByEvtData({21})
    elseif evt_type == "evt_god_world" then --神界冒险
        JumpController:getInstance():jumpViewByEvtData({34})
    elseif evt_type == "evt_league_help" then --帮内求助
        --GuildvoyageController:getInstance():seekHelpInGuild(bid)
    elseif evt_type == "evt_exchange" then -- 兑换
        JumpController:getInstance():jumpViewByEvtData({35})
    elseif evt_type == "evt_arena_champion" then -- 冠军赛
        JumpController:getInstance():jumpViewByEvtData({36})
    elseif evt_type == "evt_endless" then -- 无尽试炼
        JumpController:getInstance():jumpViewByEvtData({43})
    elseif evt_type == "evt_partner_power" then -- 神将召唤
        PartnersummonController:getInstance():openGodPartnerSummonView(true)
    elseif evt_type == "evt_hero" then -- 神将召唤
    elseif evt_type == "evt_pet" then --萌宠
        MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.Escort)
    elseif evt_type == "evt_shengqi" then -- 圣器
        JumpController:getInstance():jumpViewByEvtData({20})
    elseif evt_type == "evt_xingming" then --星命
        JumpController:getInstance():jumpViewByEvtData({12})
    elseif evt_type == "evt_primus" then
        PrimusController:getInstance():openPrimusMainWindow(true)
    elseif evt_type == "evt_skyladder" then
        JumpController:getInstance():jumpViewByEvtData({29})
    elseif evt_type == "evt_skyshop" then
        JumpController:getInstance():jumpViewByEvtData({37})
    elseif evt_type == "evt_change" then --充值
        JumpController:getInstance():jumpViewByEvtData({7})
    elseif evt_type == "evt_yueke" then --月卡
        -- WelfareController:getInstance():openMainWindow(true, WelfareIcon.yueka)
    elseif evt_type == "evt_invest" then --投资计划
        JumpController:getInstance():jumpViewByEvtData({38})
    elseif evt_type == "evt_growfund" then --成长资金
        JumpController:getInstance():jumpViewByEvtData({39})
    elseif evt_type == "evt_partner" then --打开英雄界面
        JumpController:getInstance():jumpViewByEvtData({19})
    elseif evt_type == "evt_partner_gemstone" then --打开宝石界面

    elseif evt_type == "evt_lucky_treasure" or evt_type == "evt_treasure" then --打开幸运探宝
        JumpController:getInstance():jumpViewByEvtData({40})
    elseif evt_type == "evt_recruit_high" then --先知召唤 先知殿
        JumpController:getInstance():jumpViewByEvtData({24, SeerpalaceConst.Tab_Index.Summon})
    elseif evt_type == "evt_hero_conversion" then --先知召唤 英雄转换
        JumpController:getInstance():jumpViewByEvtData({24, SeerpalaceConst.Tab_Index.Change})
    elseif evt_type == "evt_partner_synthesis" then --融合祭坛
        JumpController:getInstance():jumpViewByEvtData({23})
    elseif evt_type == "evt_partner_decompose" then --祭祀小屋
        JumpController:getInstance():jumpViewByEvtData({22})
    elseif evt_type == "evt_partner_eqm_synthesis" then --锻造屋
        JumpController:getInstance():jumpViewByEvtData({26})
    elseif evt_type == "evt_expedition" then --英雄远征
        JumpController:getInstance():jumpViewByEvtData({25})
    elseif evt_type == "evt_grocery_store" then -- 杂货店
        JumpController:getInstance():jumpViewByEvtData({6})
    elseif evt_type == "evt_daily_quest" then -- 日常任务进度宝箱获得！
        JumpController:getInstance():jumpViewByEvtData({41})
    elseif evt_type == "evt_achievement" then -- 完成成就任务获得！
        JumpController:getInstance():jumpViewByEvtData({41, TaskConst.type.feat})
    elseif evt_type == "evt_rune_synthesis" then
        JumpController:getInstance():jumpViewByEvtData({26, ForgeHouseConst.Tab_Index.Artifact})
    elseif evt_type == "evt_skillshop" then
        JumpController:getInstance():jumpViewByEvtData({15, MallConst.MallType.SkillShop})
    elseif evt_type == "evt_eliteshop" then 
        JumpController:getInstance():jumpViewByEvtData({15, MallConst.MallType.EliteShop})
    elseif evt_type == "evt_elitematch" then --精英赛
        JumpController:getInstance():jumpViewByEvtData({28})
    elseif evt_type == "evt_element_temple" then -- 元素圣殿
        JumpController:getInstance():jumpViewByEvtData({42})
    elseif evt_type == "evt_dungeon_heaven" then -- 天界副本
        JumpController:getInstance():jumpViewByEvtData({47})
    elseif evt_type == "evt_dungeon_heaven_inside" then -- 天界副本(打开最新章节)
        local max_chapter_id = HeavenController:getInstance():getModel():getOpenMaxChapterId()
        JumpController:getInstance():jumpViewByEvtData({47, max_chapter_id})
        -- HeavenController:getInstance():openHeavenDialWindow(false)
    elseif evt_type == "evt_arena_cluster" then -- 跨服竞技场
        JumpController:getInstance():jumpViewByEvtData({49})
    elseif evt_type == "evt_mall_competition" then -- 跨服竞技场商店
        JumpController:getInstance():jumpViewByEvtData({50})
    elseif evt_type == "evt_home" then -- 家园
        JumpController:getInstance():jumpViewByEvtData({51})
    elseif evt_type == "evt_veins_competition" then  -- 矿脉
        JumpController:getInstance():jumpViewByEvtData({52})
    elseif evt_type == "evt_cluster_champion" then  -- 周冠军赛
        JumpController:getInstance():jumpViewByEvtData({53})
    elseif evt_type == "evt_experience_alchemy" then  -- 魔液炼金
        JumpController:getInstance():jumpViewByEvtData({54})
    elseif evt_type == "evt_resonate" then  -- 共鸣石碑
        JumpController:getInstance():jumpViewByEvtData({55})
    elseif evt_type == "evt_gift_feather" then  -- 周礼包
        JumpController:getInstance():jumpViewByEvtData({56})
    elseif evt_type == "evt_festival_feather" then --先知豪礼
        JumpController:getInstance():jumpViewByEvtData({57})
    elseif evt_type == "evt_summon_feather" then --召唤豪礼
        JumpController:getInstance():jumpViewByEvtData({58})
    elseif evt_type == "evt_mall_cluster_champion" then -- 冠军商店
        JumpController:getInstance():jumpViewByEvtData({59})
    elseif evt_type == "evt_elfin" then -- 精灵
        JumpController:getInstance():jumpViewByEvtData({60})
    elseif evt_type == "evt_bag_elfin" then --精灵背包
        JumpController:getInstance():jumpViewByEvtData({8, BackPackConst.item_tab_type.ELFIN})
    elseif evt_type == "evt_privilege" then -- 特权商城
        JumpController:getInstance():jumpViewByEvtData({7, VIPTABCONST.PRIVILEGE})
    elseif evt_type == "evt_dialy_gift" then -- 每日礼包
        JumpController:getInstance():jumpViewByEvtData({7, VIPTABCONST.DAILY_GIFT})
    elseif evt_type == "evt_weekly_gift" then -- 每周特惠（福利界面）
        JumpController:getInstance():jumpViewByEvtData({72})
    elseif evt_type == "evt_home_shop_random" then -- 家园随机商店
        JumpController:getInstance():jumpViewByEvtData({61, 3})
    elseif evt_type == "evt_home_shop_travel" then -- 家园出行商店
        JumpController:getInstance():jumpViewByEvtData({61, 2})
    elseif evt_type == "evt_home_shop_furniture" then -- 家园随机商店
        JumpController:getInstance():jumpViewByEvtData({61, 1})
    elseif evt_type == "evt_league_secret_area" then -- 公会秘境
        JumpController:getInstance():jumpViewByEvtData({62})
    elseif evt_type == "evt_league_marketplace" then -- 公会宝库
        JumpController:getInstance():jumpViewByEvtData({63})
    elseif evt_type == "evt_arena_team" then -- 组队竞技场
        JumpController:getInstance():jumpViewByEvtData({65})
    elseif evt_type == "evt_arena_peak_champion" then -- 巅峰竞技场
        JumpController:getInstance():jumpViewByEvtData({67})
    elseif evt_type == "evt_monopoly" then -- 圣夜奇境主活动界面
        JumpController:getInstance():jumpViewByEvtData({66})
    elseif evt_type == "evt_monopoly_boss" then -- 圣夜奇境_boos
        JumpController:getInstance():jumpViewByEvtData({66, MonopolyConst.Sub_Type.Boss})
    elseif evt_type == "evt_monopoly_1" then -- 301、魔女之森的地图界面
        JumpController:getInstance():jumpViewByEvtData({66, MonopolyConst.Sub_Type.Step_1})
    elseif evt_type == "evt_monopoly_2" then -- 302、蔷薇庭院的地图界面
        JumpController:getInstance():jumpViewByEvtData({66, MonopolyConst.Sub_Type.Step_2})
    elseif evt_type == "evt_monopoly_3" then -- 303、魔王之城的地图界面
        JumpController:getInstance():jumpViewByEvtData({66, MonopolyConst.Sub_Type.Step_3})
    elseif evt_type == "evt_monopoly_4" then -- 304、时之隙间的地图界面
        JumpController:getInstance():jumpViewByEvtData({66, MonopolyConst.Sub_Type.Step_4})
    elseif evt_type == "evt_grow_gift" then -- 成长自选
        JumpController:getInstance():jumpViewByEvtData({74})
    elseif evt_type == "evt_subscribe" then  -- 专属订阅
        JumpController:getInstance():jumpViewByEvtData({73})
    elseif evt_type == "evt_peak_mall_buy" then  -- 巅峰冠军赛商店
        JumpController:getInstance():jumpViewByEvtData({75})
    else
        print("error_source_evt_type===>>", evt_type)
    end
end

function BackpackController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end