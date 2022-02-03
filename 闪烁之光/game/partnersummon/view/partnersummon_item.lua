-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      召唤卡组单项
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
PartnerSummonItem = class("PartnerSummonItem",function ()
    return  ccui.Widget:create()
end)

PartnerSummonItem.HEIGHT = 224
PartnerSummonItem.WIDTH = 653

local role_vo = RoleController:getInstance():getRoleVo()
local string_format = string.format
local controller = PartnersummonController:getInstance()
local model = controller:getModel() 

function PartnerSummonItem:ctor(index)
    self.index = index or 0
    self.remain_free_num = 0
    self.remain_free_time = 0

    self.role_vo = RoleController:getInstance():getRoleVo()

    self.size = cc.size(PartnerSummonItem.WIDTH,PartnerSummonItem.HEIGHT)
    self:setContentSize(self.size)
    self:setAnchorPoint(cc.p(0,1))
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("partnersummon/partnersummon_item"))
    self:addChild(self.root_wnd)
    self.container = self.root_wnd:getChildByName("container")
    self.item_bg = self.container:getChildByName("item_bg")
    self.unlock_container = self.container:getChildByName("unlock_container")
    self.good = self.container:getChildByName("good")
    self.good_bg = self.container:getChildByName("good_bg")
    self.good_num_label = self.container:getChildByName("good_num_label")

    self.one_btn = createButton(self.unlock_container, TI18N("招募1次"), 155, 45, cc.size(187, 78), PathTool.getResFrame("partnersummon", "partnersummon_btn_2"),30)
    self.one_btn_bg = createImage(self.one_btn:getRoot(), PathTool.getResFrame("partnersummon","partnersummon_tag_bg"), self.one_btn:getContentSize().width/2,25,nil,true)
    self.one_btn_bg:setScale9Enabled(true)
    self.one_btn_bg:setCapInsets(cc.rect(8, 6, 1, 1))
    self.one_btn_bg:setContentSize(cc.size(130, 29))
    self.one_btn:setRichText(TI18N("<div fontColor=#ffffff fontsize=26 outline=2,#823705>招募1次</div>"))
    self.one_btn:setRichLabelPosition(45.5,73)
    self.one_btn.status = 0

    self.price_one_label = createRichLabel(20, 1, cc.p(0.5, 0.5), cc.p(self.one_btn_bg:getContentSize().width / 2, self.one_btn_bg:getContentSize().height / 2))
    self.price_one_label:setString("")
    self.one_btn_bg:addChild(self.price_one_label)
    -- 引导需要
    local button = self.one_btn:getButton()
    button:setName(string.format("guildsign_summon_%s_%s", self.index, 1))
    
    self.five_btn = createButton(self.unlock_container, TI18N("招募10次"), 510, 45, cc.size(187, 78), PathTool.getResFrame("partnersummon", "partnersummon_btn"),30)
    self.five_btn_bg = createImage(self.five_btn:getRoot(), PathTool.getResFrame("partnersummon","partnersummon_tag_bg"), self.five_btn:getContentSize().width/2,25,nil,true)
    self.five_btn_bg:setScale9Enabled(true)
    self.five_btn_bg:setCapInsets(cc.rect(8, 6, 1, 1))
    self.five_btn_bg:setContentSize(cc.size(130, 29))
    self.five_btn:setRichText(TI18N("<div fontColor=#ffffff fontsize=26 outline=2,#823705>招募10次</div>"))
    self.five_btn:setRichLabelPosition(45.5, 73)
    self.five_btn.status = 0 --0代表初始化,1代表免费,2代表金币,3代表道,4是兑换
    self.nine_zhe_icon = createSprite(PathTool.getResFrame("partnersummon", "txt_cn_partnersummon_1"), 190, 95, self.five_btn:getRoot())
    breatheShineAction3(self.nine_zhe_icon)
    self.nine_zhe_icon:setVisible(false)

    self.price_five_label = createRichLabel(18,1,cc.p(0.5,0.5),cc.p(self.five_btn_bg:getContentSize().width / 2,self.five_btn_bg:getContentSize().height / 2))
    self.price_five_label:setString("")
    self.five_btn_bg:addChild(self.price_five_label)

    self.free_time_label = createRichLabel(20,1,cc.p(0.5,0.5),cc.p(155,98))
    self.free_time_label:setString("")
    self.container:addChild(self.free_time_label)

    self:registerEvent()
end

function PartnerSummonItem:registerEvent()
    if self.one_btn then
        self.one_btn:addTouchEventListener(function ( sender, event_type )
            -- 点击间隔
            if event_type == ccui.TouchEventType.ended then
                if self.one_btn.last_time and math.abs(GameNet:getInstance():getTimeFloat() - self.one_btn.last_time) < 0.5 then
                    return
                end
                self.one_btn.last_time = GameNet:getInstance():getTimeFloat()
                self:_onClickOneSummonBtn()
            end
        end)
    end

    if self.five_btn then
        self.five_btn:addTouchEventListener(function ( sender, event_type )
            -- 点击间隔
            if event_type == ccui.TouchEventType.ended then
                if self.five_btn.last_time and math.abs(GameNet:getInstance():getTimeFloat() - self.five_btn.last_time) < 0.5 then
                    return
                end
                self.five_btn.last_time = GameNet:getInstance():getTimeFloat()
                self:_onClickTenSummonBtn()
            end
        end)
    end

    -- 某一卡库数据更新
    if not self.update_summon_single_data_event then
        self.update_summon_single_data_event = GlobalEvent:getInstance():Bind(PartnersummonEvent.updateSummonSingleDataEvent,function(group_ids)
            if self.group_id and group_ids then
                for k,id in pairs(group_ids) do
                    if id == self.group_id then
                        local group_data = model:getSummonGroupDataByGroupId(self.group_id)
                        self:setData(self.index, group_data)
                        break
                    end
                end
            end
        end)
    end

    -- 道具数量更新
    if not self.update_add_good_event then
        self.update_add_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS,function(bag_code, data_list)
            self:refreshExchangeItemNum(bag_code,data_list)
        end)
    end
    if not self.update_delete_good_event then
        self.update_delete_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS,function(bag_code, data_list)
            self:refreshExchangeItemNum(bag_code,data_list)
        end)
    end
    if not self.update_modify_good_event then
        self.update_modify_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM,function(bag_code, data_list)
            self:refreshExchangeItemNum(bag_code,data_list)
        end)
    end

    if self.role_vo ~= nil then
        if self.role_assets_event == nil then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                if key == "friend_point" and self.group_id == PartnersummonConst.Summon_Type.Friend then
                    self.good_num_label:setString(value)
                end
            end)
        end
    end

    --召唤5星
    if not self.summon_must_star_event then
        self.summon_must_star_event = GlobalEvent:getInstance():Bind(PartnersummonEvent.SummonMustFiveStarEvent, function()
            if self.heightSummonFiveStar then
                self:heightSummonFiveStar()
            end
        end)
    end
end

-- 召唤一次
function PartnerSummonItem:_onClickOneSummonBtn(  )
    local max, count = HeroController:getInstance():getModel():getHeroMaxCount()
    if count >= max then
        local str = TI18N("英雄列表已满，可通过提升VIP等级或购买增加英雄携带数量，是否前往购买？")
        local call_back = function()
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.partner)
            controller:openPartnerSummonWindow(false)
        end
        CommonAlert.show(str, TI18N("前往"), call_back, TI18N("取消"), nil, CommonAlert.type.common)
        return
    end
    if self.one_btn.status ~= 0 and self.group_id then
        if self.one_btn.status == PartnersummonConst.Status.Free then --免费
            PartnersummonController:getInstance():send23201(self.group_id, 1, 1)
        elseif self.one_btn.status == PartnersummonConst.Status.special then --特殊道具抽奖
            PartnersummonController:getInstance():send23201(self.group_id, 1, 5)
        elseif self.one_btn.status == PartnersummonConst.Status.Item then --道具
            PartnersummonController:getInstance():send23201(self.group_id, 1, 4)
        elseif self.one_btn.status == PartnersummonConst.Status.Gold then  -- 钻石
            local num = self.info_data.exchange_once[1][2]
            local call_back = function ()
                PartnersummonController:getInstance():send23201(self.group_id, 1, 3)
            end
            local item_icon = Config.ItemData.data_get_data(self.info_data.item_once[1][1]).icon
            local item_icon_2 = Config.ItemData.data_get_data(self.info_data.exchange_once[1][1]).icon
            local val_str = Config.ItemData.data_get_data(self.info_data.exchange_once_gain[1][1]).name or ""
            local val_num = self.info_data.exchange_once_gain[1][2]
            local call_num = self.info_data.draw_list[1] or 1
            self:showAlert(num,item_icon_2,val_str,val_num,call_num,call_back)
        end
    end
end

-- 召唤十次
function PartnerSummonItem:_onClickTenSummonBtn(  )
    local max, count = HeroController:getInstance():getModel():getHeroMaxCount()
    if count >= max then
        local str = TI18N("英雄列表已满，可通过提升VIP等级或购买增加英雄携带数量，是否前往购买？")
        local call_back = function()
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.partner)
            controller:openPartnerSummonWindow(false)
        end
        CommonAlert.show(str, TI18N("前往"), call_back, TI18N("取消"), nil, CommonAlert.type.common)
        return
    end
    if self.five_btn.status ~= 0 and self.info_data and self.group_id then
        if self.five_btn.status == PartnersummonConst.Status.special then --特殊道具
            PartnersummonController:getInstance():send23201(self.group_id, 10, 5)
        elseif self.five_btn.status == PartnersummonConst.Status.Item then --道具
            PartnersummonController:getInstance():send23201(self.group_id, 10, 4)
        elseif self.five_btn.status == PartnersummonConst.Status.Gold then -- 钻石
            local num = self.info_data.exchange_five[1][2]
            local call_back = function ()
                PartnersummonController:getInstance():send23201(self.group_id, 10, 3)
            end
            local item_icon = Config.ItemData.data_get_data(self.info_data.item_five[1][1]).icon
            local item_icon_2 = Config.ItemData.data_get_data(self.info_data.exchange_five[1][1]).icon
            local val_str = Config.ItemData.data_get_data(self.info_data.exchange_five_gain[1][1]).name or ""
            local val_num = self.info_data.exchange_five_gain[1][2]
            local call_num = self.info_data.draw_list[2] or 10
            self:showAlert(num,item_icon_2,val_str,val_num,call_num,call_back)
        end
    end
end

-- 刷新道具显示
function PartnerSummonItem:refreshExchangeItemNum( bag_code,data_list,is_friend_point )
    if is_friend_point and self.role_vo then
        local friend_point = self.role_vo.friend_point
        self.good_num_label:setString(friend_point)
    elseif bag_code == BackPackConst.Bag_Code.BACKPACK and self.info_data then
        local item_id = self.info_data.item_once[1][1] -- 单抽道具id
        local special_item_id = 0 -- 单抽特殊道具id
        if self.info_data.ext_item_once and self.info_data.ext_item_once[1] and self.info_data.ext_item_once[1][1] then
            special_item_id = self.info_data.ext_item_once[1][1]
        end
        for i,v in pairs(data_list) do 
            if v and v.base_id and (item_id == v.base_id or special_item_id == v.base_id) then 
                local count = BackpackController:getInstance():getModel():getBackPackItemNumByBid(item_id)
                self.good_num_label:setString(count)
                -- 高级召唤要根据数量判断按钮显示为钻石还是道具
                if self.group_id and self.group_id == PartnersummonConst.Summon_Type.Advanced then
                    self:updateSingleBtnStatus()
                    self:updateFiveBtnStatus()
                end
                break
            end
        end
    end
end

function PartnerSummonItem:showAlert(num,item_icon_2,val_str,val_num,call_num,call_back)
    if self.alert then
        self.alert:close()
        self.alert = nil
    end

    local cancle_callback = function ()
        if self.alert then
            self.alert:close()
            self.alert = nil
        end
    end
    local have_sum = RoleController:getInstance():getRoleVo().gold + RoleController:getInstance():getRoleVo().red_gold
    local str = string.format(TI18N("是否使用<img src=%s visible=true scale=0.3 /><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>(拥有:</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>)\n</div>"),PathTool.getItemRes(item_icon_2),num,have_sum)
    local str_ = str..string.format(TI18N("<div fontColor=#764519>购买</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519></div><div fontColor=#d95014 fontsize= 26>%s</div><div fontColor=#764519>(同时附赠</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>次招募)</div>"),val_num,val_str,call_num)
    if not self.alert then
        self.alert = CommonAlert.show(str_, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
    end
end

function PartnerSummonItem:setData(i,data)
    if data then
        self.index = i
        self.info_data = data.info_data or {}
        self.proto_data = data.proto_data or {}
        self.group_id = data.group_id

        -- 背景
        local res_id = PathTool.getPlistImgForDownLoad("bigbg/partnersummon", self.info_data.card_bg_res)
        if self.res_id ~= res_id then
            self.res_id = res_id
            self.item_load = createResourcesLoad(self.res_id, ResourcesType.single, function()
                if not tolua.isnull(self.item_bg) then
                    loadSpriteTexture(self.item_bg, self.res_id, LOADTEXT_TYPE)
                end
            end, self.item_load)
        end

        -- 道具相关
        if self.group_id == PartnersummonConst.Summon_Type.Friend and self.role_vo then
            local friend_point = self.role_vo.friend_point
            self.good_num_label:setString(friend_point)
        end
        local image_name = PartnersummonConst.Good_Bg[self.group_id]
        if image_name then
            local good_bg_res = PathTool.getResFrame("partnersummon",image_name)
            self.good_bg:loadTexture(good_bg_res, LOADTEXT_TYPE_PLIST)
        end
        if self.info_data then
            local one_icon_item = self.info_data.item_once[1][1]
            if one_icon_item then
                local item_icon = Config.ItemData.data_get_data(one_icon_item).icon
                self.good:loadTexture(PathTool.getItemRes(item_icon), LOADTEXT_TYPE)
                if self.group_id ~= PartnersummonConst.Summon_Type.Friend then
                    local count = BackpackController:getInstance():getModel():getBackPackItemNumByBid(one_icon_item)
                    self.good_num_label:setString(count)
                end
            end
        end

        --特殊显示
        self:heightSummonFiveStar()

        -- 九折折扣图标
        self.nine_zhe_icon:setVisible(self.group_id == PartnersummonConst.Summon_Type.Advanced)
        self:updateSingleBtnStatus()
        self:updateFiveBtnStatus()
    end
end
--高级召唤特殊显示
function PartnerSummonItem:heightSummonFiveStar()
    if not self.group_id then return end
    if self.group_id ~= PartnersummonConst.Summon_Type.Advanced then
        return
    end
    local num = model:getFiveStarHeroIsOut()
    if num == 0 then
        if self.remain_star_num then
            self.remain_star_num:DeleteMe()
            self.remain_star_num = nil
        end
        if self.star_num then
            self.star_num:DeleteMe()
            self.star_num = nil
        end
        if self.five_star then
            self.five_star:setVisible(false)
        end

        if not self.special_label then
            self.special_label = createRichLabel(22, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0, 0.5), cc.p(25, 146))
            self.container:addChild(self.special_label)
        end
        self.special_label:setString(TI18N("<div fontcolor=#ffffff fontsize=22 outline=2,#8f1c00>随机召唤1个或10个3~5星英雄</div>"))
    else
        if self.special_label then
            self.special_label:setVisible(false)
        end
        if not self.five_star then
            self.five_star = createSprite(PathTool.getResFrame("partnersummon", "txt_cn_partnersummon_300"), 7, 139, self.container,cc.p(0,0.5))
        end 
        if not self.remain_star_num then
            self.remain_star_num = CommonNum.new(31, self.five_star, 1, 5, cc.p(0.5, 0.5))
            self.remain_star_num:setPosition(45, 36)
        end
        self.remain_star_num:setNum(num)

        if not self.star_num then
            self.star_num = CommonNum.new(31, self.five_star, 1, 5, cc.p(0.5, 0.5))
            self.star_num:setPosition(231, 36)
        end
        self.star_num:setNum(5)
    end
end

function PartnerSummonItem:getValueByKey(data,key)
    local val = 0
    data = data or {}
    for i, v in pairs(data.draw_list or {}) do
        if v.times == 1 and v.kv_list then
            for _,kv in pairs(v.kv_list) do
                if kv.key == key then
                    val = kv.val
                end
            end
            break
        end
    end
    return val
end

-- 单抽按钮
function PartnerSummonItem:updateSingleBtnStatus()
    if self.proto_data and self.info_data and self.group_id then
        local one_icon_item = self.info_data.item_once[1][1] --单抽道具ID
        local one_special_icon_item
        if self.info_data.ext_item_once and self.info_data.ext_item_once[1] and self.info_data.ext_item_once[1][1] then
            one_special_icon_item = self.info_data.ext_item_once[1][1]
        end
        local one_icon_num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(one_icon_item) --单抽拥有的道具数量
        local one_icon_special_num = (one_special_icon_item and BackpackController:getInstance():getModel():getBackPackItemNumByBid(one_special_icon_item)) or 0 --单抽拥有特殊道具数量
        -- 可以免费刷新的次数
        self.remain_free_num = self:getValueByKey(self.proto_data, PartnersummonConst.Recruit_Key.Free_Count)
        -- 下次免费刷新时间
        self.remain_free_time = self:getValueByKey(self.proto_data, PartnersummonConst.Recruit_Key.Free_Time)

        if self.remain_free_num > 0 then
            self.one_btn.status = PartnersummonConst.Status.Free
            self.price_one_label:setString(TI18N("<div fontColor=#ffffff fontsize=20>免费召唤</div>"))
        else
            local need_num = self.info_data.draw_list[1] or 1
            -- 只有高级召唤且道具不足时才显示兑换道具
            if one_icon_special_num < need_num and one_icon_num < need_num and self.group_id == PartnersummonConst.Summon_Type.Advanced then
                self.one_btn.status = PartnersummonConst.Status.Gold
                local bid = self.info_data.exchange_once[1][1]
                local num = self.info_data.exchange_once[1][2]
                if bid and Config.ItemData.data_get_data(bid) then
                    local item_icon = Config.ItemData.data_get_data(bid).icon
                    local color = 1
                    self.price_one_label:setString(string.format(TI18N("<img src=%s visible=true scale=0.3 /> <div fontColor=%s fontsize=20> %s  </div>"), PathTool.getItemRes(item_icon), tranformC3bTostr(color), num))
                end
            elseif one_icon_special_num >= need_num then
                self.one_btn.status = PartnersummonConst.Status.special
                local bid = self.info_data.ext_item_once[1][1]
                local num = self.info_data.ext_item_once[1][2]
                if bid and Config.ItemData.data_get_data(bid) then
                    local item_icon = Config.ItemData.data_get_data(bid).icon
                    self.price_one_label:setString(string.format(TI18N("<img src=%s visible=true scale=0.35 /> <div fontColor=#ffffff fontsize=20> %s</div>"), PathTool.getItemRes(item_icon), num))
                end
            else
                self.one_btn.status = PartnersummonConst.Status.Item
                local bid = self.info_data.item_once[1][1]
                local num = self.info_data.item_once[1][2]
                if bid and Config.ItemData.data_get_data(bid) then
                    local item_icon = Config.ItemData.data_get_data(bid).icon
                    self.price_one_label:setString(string.format(TI18N("<img src=%s visible=true scale=0.35 /> <div fontColor=#ffffff fontsize=20> %s</div>"), PathTool.getItemRes(item_icon), num))
                end
            end
            self:openSummonFreeTimer(true)
        end
    end
end

-- 十连抽按钮
function PartnerSummonItem:updateFiveBtnStatus()
    if self.group_id and self.info_data then
        local ten_icon_item = self.info_data.item_five[1][1]
        local ten_special_icon_item
        if self.info_data.ext_item_five and self.info_data.ext_item_five[1] and self.info_data.ext_item_five[1][1] then
            ten_special_icon_item = self.info_data.ext_item_five[1][1]
        end
        local ten_icon_num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(ten_icon_item)
        local ten_icon_special_num = (ten_special_icon_item and BackpackController:getInstance():getModel():getBackPackItemNumByBid(ten_special_icon_item)) or 0 --单抽拥有特殊道具数量
        local need_num = self.info_data.draw_list[2] or 10

        local str = ""
        if ten_icon_special_num < need_num and ten_icon_num < need_num and self.group_id == PartnersummonConst.Summon_Type.Advanced then
            self.five_btn.status = PartnersummonConst.Status.Gold
            local bid = self.info_data.exchange_five[1][1]
            local num = self.info_data.exchange_five[1][2]
            if Config.ItemData.data_get_data(bid) then
                local item_icon = Config.ItemData.data_get_data(bid).icon
                local color = 1
                str = string.format(TI18N("<img src=%s visible=true scale=0.3 /> <div fontColor=%s fontsize=20> %s  </div>"), PathTool.getItemRes(item_icon), tranformC3bTostr(color), num)
            end
        elseif ten_icon_special_num >= need_num then
            self.five_btn.status = PartnersummonConst.Status.special
            local bid = self.info_data.ext_item_five[1][1]
            local num = self.info_data.ext_item_five[1][2]
            if Config.ItemData.data_get_data(bid) then
                local item_icon = Config.ItemData.data_get_data(bid).icon
                str = string.format(TI18N("<img src=%s visible=true scale=0.35 /> <div fontColor=#ffffff fontsize=20>%s</div>"), PathTool.getItemRes(item_icon), num)
            end
        else
            self.five_btn.status = PartnersummonConst.Status.Item
            local bid = self.info_data.item_five[1][1]
            local num = self.info_data.item_five[1][2]
            if Config.ItemData.data_get_data(bid) then
                local item_icon = Config.ItemData.data_get_data(bid).icon
                str = string.format(TI18N("<img src=%s visible=true scale=0.35 /> <div fontColor=#ffffff fontsize=20>%s</div>"), PathTool.getItemRes(item_icon), num)
            end
        end
        self.price_five_label:setString(str)
    end
end

-- 开启下次免费CD倒计时
function PartnerSummonItem:openSummonFreeTimer( status )
    if status == true then
        self.left_time = self.remain_free_time - GameNet:getInstance():getTime()

        if not self.free_time_label or tolua.isnull(self.free_time_label) then
            if self.summon_timer ~= nil then
                GlobalTimeTicket:getInstance():remove(self.summon_timer)
                self.summon_timer = nil
            end
            return
        end

        if self.left_time > 0 then
            self.free_time_label:setVisible(true)
            self.free_time_label:setString(string.format(TI18N("<div  fontColor=#35ff14 outline=2,#000000 >%s</div><div fontColor=#ffffff outline=2,#000000>后免费</div>"), TimeTool.GetTimeFormat(self.left_time)))
            
            if not self.summon_timer then
                self.summon_timer = GlobalTimeTicket:getInstance():add(function()
                    if self.remain_free_time and (self.remain_free_time - GameNet:getInstance():getTime()) > 0 then
                        self.left_time = self.remain_free_time - GameNet:getInstance():getTime()
                        self.free_time_label:setVisible(true)
                        self.free_time_label:setString(string.format(TI18N("<div  fontColor=#35ff14 outline=2,#000000 >%s</div><div fontColor=#ffffff outline=2,#000000>后免费</div>"), TimeTool.GetTimeFormat(self.left_time)))
                    else
                        self.free_time_label:setVisible(false)
                        GlobalTimeTicket:getInstance():remove(self.summon_timer)
                        self.summon_timer = nil
                    end
                end, 1)
            end
        else
            self.free_time_label:setVisible(false)
            if self.summon_timer ~= nil then
                GlobalTimeTicket:getInstance():remove(self.summon_timer)
                self.summon_timer = nil
            end
        end
    else
        if self.summon_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.summon_timer)
            self.summon_timer = nil
        end
    end
end

--删掉的时候关闭
function PartnerSummonItem:DeleteMe()
    if self.remain_star_num then
        self.remain_star_num:DeleteMe()
        self.remain_star_num = nil
    end
    if self.star_num then
        self.star_num:DeleteMe()
        self.star_num = nil
    end

    doStopAllActions(self.nine_zhe_icon)
    self:openSummonFreeTimer(false)
    if self.item_load then
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
    end
    if self.update_summon_single_data_event then
        GlobalEvent:getInstance():UnBind(self.update_summon_single_data_event)
        self.update_summon_single_data_event = nil
    end
    if self.update_add_good_event then
        GlobalEvent:getInstance():UnBind(self.update_add_good_event)
        self.update_add_good_event = nil
    end
    if self.update_delete_good_event then
        GlobalEvent:getInstance():UnBind(self.update_delete_good_event)
        self.update_delete_good_event = nil
    end
    if self.update_modify_good_event then
        GlobalEvent:getInstance():UnBind(self.update_modify_good_event)
        self.update_modify_good_event = nil
    end

    if self.summon_must_star_event then
        GlobalEvent:getInstance():UnBind(self.summon_must_star_event)
        self.summon_must_star_event = nil
    end
        
    self:removeAllChildren()
    self:removeFromParent()
end
