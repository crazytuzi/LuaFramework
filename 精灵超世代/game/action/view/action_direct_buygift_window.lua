-- --------------------------------------------------------------------
--直购礼包
-- Create: 2018-09
-- -------------------------------------------------------------------- 
ActionDirectBuygiftWindow = ActionDirectBuygiftWindow or BaseClass(BaseView)
local action_controller = ActionController:getInstance()
function ActionDirectBuygiftWindow:__init( )
    self.item_list = {}
    self.is_full_screen = true
    self.buyGiftYuan = 1
    self.productID = nil
    self.productStr = nil
    self.hoild_id = nil
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.layout_name = "action/action_direct_buygift_window"    
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_57"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg","txt_cn_bigbg_21"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("welfare","welfare"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("welfaretab","welfaretab"), type = ResourcesType.plist}, 
    }
end

function ActionDirectBuygiftWindow:open_callback( )
	self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container)
    local title = self.main_container:getChildByName("title")
    local res = PathTool.getTargetRes("bigbg/action","action_direct_buygift",false,false)
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(title) then
                loadSpriteTexture(title,res,LOADTEXT_TYPE)
            end
        end,self.item_load)
    end

    self.main_container:getChildByName("Text_4"):setString(TI18N("空\n前\n优\n惠"))
    self.main_container:getChildByName("Text_2_0"):setString(TI18N("原价:"))
    self.main_container:getChildByName("Text_2_0_0"):setString(TI18N("现价:"))
    self.oldPrice = self.main_container:getChildByName("oldPrice")
    self.newPrice = self.main_container:getChildByName("newPrice")
    self.main_container:getChildByName("Text_2"):setString(TI18N("优惠结束倒计时:"))
    self.textTime = self.main_container:getChildByName("textTime")
    self.cancle = self.main_container:getChildByName("cancle")
    self.cancle:getChildByName("Text_10"):setString(TI18N("稍后考虑"))
    self.goto_btn = self.main_container:getChildByName("goto")
    self.goto_btn.label = self.goto_btn:getChildByName("Text_10_0"):setString(TI18N("立即购买"))

    self.goods = self.main_container:getChildByName("goods")
    self.goods:setScrollBarEnabled(false)
    
	self.close_btn = self.main_container:getChildByName("close_btn")
end

function ActionDirectBuygiftWindow:openRootWnd(bid)
    if bid then
        self.hoild_id = bid
        action_controller:cs16603(bid)
    end
end

--设置倒计时
function ActionDirectBuygiftWindow:setLessTime(less_time)
    if tolua.isnull(self.textTime) then return end
    self.textTime:stopAllActions()
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.textTime:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                self.textTime:stopAllActions()
            else
                self:setTimeFormatString(less_time)
            end
        end))))
    else
        self:setTimeFormatString(less_time)
    end
end
function ActionDirectBuygiftWindow:setTimeFormatString(time)
    if time > 0 then
        self.textTime:setString(TimeTool.GetTimeFormatDayIIIIIIII(time))
    else
        self.textTime:setString("")
    end
end

function ActionDirectBuygiftWindow:register_event( )
    if not self.update_directgift_event then
        self.update_directgift_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function (data)
            self._data = data
            if data.bid == self.hoild_id then
                if data.aim_list == nil or next(data.aim_list) == nil then
                    ActionController:getInstance():openDirectBuyGiftWin(false)
                    return 
                end

                self:setLessTime(data.remain_sec)
                local list = data.aim_list[1].item_list
                self.goods:setInnerContainerSize(cc.size((BackPackItem.Width*0.9+25)*tableLen(list), self.goods:getContentSize().height))
                for i, v in pairs(list) do
                    if not self.item_list[i] then
                        local item = BackPackItem.new(false, true, false, 0.9, false)
                        item:setAnchorPoint(0, 0.5)
                        self.goods:addChild(item)
                        self.item_list[i] = item
                    end
                    item = self.item_list[i]
                    if item then
                        item:setPosition((i - 1)*(BackPackItem.Width*0.9+25), 70)
                        item:setBaseData(v.bid, v.num)
                        item:setDefaultTip()
                    end
                end

                local old_price = keyfind('aim_args_key', ActionExtType.ActivityOldPrice, data.aim_list[1].aim_args) or 0
                local new_price = keyfind('aim_args_key', ActionExtType.ActivityCurrentPrice, data.aim_list[1].aim_args) or 0

                self.oldPrice:setString("￥"..old_price.aim_args_val)
                self.newPrice:setString("￥"..new_price.aim_args_val)
                self.buyGiftYuan = new_price.aim_args_val
                self.productID = data.aim_list[1].aim
                self.productStr = data.aim_list[1].aim_str

                if data.aim_list[1].status == 0 then
                    setChildUnEnabled(false, self.goto_btn, Config.ColorData.data_color4[1])
                    self.goto_btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
                    self.goto_btn:setTouchEnabled(true)
                elseif data.aim_list[1].status == 1 then
                    setChildUnEnabled(true, self.goto_btn, Config.ColorData.data_color4[1])
                    self.goto_btn:setTouchEnabled(false)
                    self.goto_btn.label:disableEffect(cc.LabelEffect.OUTLINE)
                end
            end
        end)
    end

    registerButtonEventListener(self.close_btn, function()
        ActionController:getInstance():openDirectBuyGiftWin(false)
    end ,false, 2)
    registerButtonEventListener(self.cancle, function()
        ActionController:getInstance():openDirectBuyGiftWin(false)
    end ,true, 2)

    registerButtonEventListener(self.goto_btn, function()
        local function call_back()
            if self.productID ~= nil and self.productStr ~= nil then
                sdkOnPay(self.buyGiftYuan, 1, self.productID, self.productStr)
            else
                message(TI18N("获取礼包信息出错"))
            end
        end
        local str = string.format("是否花费%d元，购买此礼包",self.buyGiftYuan)
        CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich,nil,nil,24)
    end ,true, 1)
end

function ActionDirectBuygiftWindow:close_callback()
    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil

    if self.item_list and next(self.item_list or {}) ~= nil then
        for i, v in ipairs(self.item_list) do
            if v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
    self.item_list = {}
    if self.update_directgift_event then
        self.update_directgift_event = GlobalEvent:getInstance():UnBind(self.update_directgift_event)
        self.update_directgift_event = nil
    end
    ActionController:getInstance():openDirectBuyGiftWin(false)
end
