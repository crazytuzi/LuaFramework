
local ALIGN_CENTER = "align_center"
local ALIGN_LEFT = "align_left"
local ALIGN_RIGHT = "align_right"


-- 货币类型,对应shop_time_info表的price_type字段
local CURRENCY_TYPE = {
    SILVER = 1,
    GOLD = 2,
    JING_JI_CHANG = 3,
    MO_SHEN = 4,
    CHUANG_GUAN = 5,
    JIANG_HUN = 6, --将魂
    JUN_TUAN = 9,  --军团
    SHEN_HUN = 11, 
}

local CURRENCY_IMAGE = {
    [1] = "icon_mini_yingzi2.png",
    [2] = "icon_mini_yuanbao2.png",
    [3] = "icon_mini_shenwang.png", -- 声望
    [4] = "icon_mini_jiangzhang.png", --功勋
    [5] = "icon_mini_patajifen.png", --威名
    [6] = "icon_mini_hunyu.png", --将魂
    [9] = "icon_mini_juntuangongxian.png", --军团贡献
    [11] = "icon_juexingdaojushenhun.png",  --神魂 
}

local function getCurrencyImage(nType)
    nType = nType or 1
    return CURRENCY_IMAGE[nType] or CURRENCY_IMAGE[1]
end

local CURRENCY_IMAGE2 = {
    [1] = "icon_mini_yingzi.png",
    [2] = "icon_mini_yuanbao.png",
    [3] = "icon_mini_shenwang.png", -- 声望
    [4] = "icon_mini_jiangzhang.png", --功勋
    [5] = "icon_mini_patajifen.png", --威名
    [6] = "icon_mini_hunyu.png", --将魂
    [9] = "icon_mini_juntuangongxian.png", --军团贡献
    [11] = "icon_juexingdaojushenhun.png",  --神魂 
}

local function getCurrencyImage2(nType)
    nType = nType or 1
    return CURRENCY_IMAGE2[nType] or CURRENCY_IMAGE2[1]
end

local function getDiscountImagePath(szName)
    local szPath = "ui/text/txt/" .. szName .. ".png"
    return szPath
end

local PAGE = {
	PROB_DISCOUNT = 1,  -- 道具折扣
	RECHARGE_PRIVILEGE = 2, --充值优惠
	WELFACE = 3,  --全名福利
}

local function ConvertNumToCharacter3(num)
    -- 过亿了
    if num > math.pow(10,8) then
        return (num-num%math.pow(10,8))/math.pow(10,8) .. G_lang:get("LANG_YI")
    end
    if num >= math.pow(10,5) then
        return (num-num%math.pow(10,4))/math.pow(10,4) .. G_lang:get("LANG_WAN")
    end
    return num
end

local TOTAL_SCHEDULE = 100

local EffectNode = require "app.common.effects.EffectNode"
local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local TimePrivilegeConst = require("app.const.TimePrivilegeConst")
local TimePrivilegeAwardItem = require("app.scenes.timeprivilege.TimePrivilegeAwardItem")
local TimePrivilegeWarningLayer = require("app.scenes.timeprivilege.TimePrivilegeWarningLayer")


local TimePrivilegeMainLayer = class("TimePrivilegeMainLayer", UFCCSNormalLayer)

function TimePrivilegeMainLayer.create(...)
	return TimePrivilegeMainLayer.new("ui_layout/timeprivilege_MainLayer.json", nil, ...)
end

function TimePrivilegeMainLayer:ctor(json, param, ...)
	self.super.ctor(self, json, param, ...)

	self._nCurPage = PAGE.PROB_DISCOUNT

    self._tAwardList = {}

    -- 购买了优惠充值的人数
    self._peopleCount = 0
    self._numList = {self:getLabelByName("Label_num1"),self:getLabelByName("Label_num2"),
                        self:getLabelByName("Label_num3"),self:getLabelByName("Label_num4"),self:getLabelByName("Label_num5")}
    self._numList2 = {self:getLabelByName("Label_num1_0"),self:getLabelByName("Label_num2_0"),
                        self:getLabelByName("Label_num3_0"),self:getLabelByName("Label_num4_0"),self:getLabelByName("Label_num5_0")}
    for i = 1,5 do 
        self._numList[i]:createStroke(Colors.strokeBrown, 1)
    end
    for i = 1,5 do 
        self._numList2[i]:createStroke(Colors.strokeBrown, 1)
    end

    -- 买一个物品前的进度
    self._nPreSchedule = 0


	self:_initWidgets()
end

function TimePrivilegeMainLayer:onLayerEnter()
	self:adapterWidgetHeight("Panel_content1", "Panel_checkbox", "", 0, 0)
    self:adapterWidgetHeight("Panel_content2", "Panel_checkbox", "", 90, 0)
    self:adapterWidgetHeight("Panel_content3", "Panel_checkbox", "", 90, 0)
    self:adapterWidgetHeight("Panel_list2", "Panel_others3", "", 10, 0)

    -- 进入界面，发送协议， 协议返回后，真正初始化界面
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TIME_PRIVILEGE_INIT_MAIN_LAYER, self._updateDiscountProbPage, self)
    -- 拉取全民奖励列表信息
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TIME_PRIVILEGE_GET_AWARD_INFO_SUCC, self._reloadListView, self)
    -- 成功领取全民奖励
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TIME_PRIVILEGE_GET_AWARD_SUCC, self._onGetAwardSucc, self)
    -- 成功拉到到物品列表
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_INFO, function(_, message)
        self:updateItems(message)
    end, self)
    -- 购买商品成功，刷新购买进度
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TIME_PRIVILEGE_BUY_GOODS_SUCC, self._onBuyGoodsSucc, self)


    -- 进界面拉协议
    G_HandlersManager.timePrivilegeHandler:sendShopTimeInfo()
    G_HandlersManager.shopHandler:sendShopInfo(SHOP_TYPE_TIME_PRIVILEGE)
    G_HandlersManager.timePrivilegeHandler:sendShopTimeRewardInfo()

    self:_addWeekRefreshTimer()

    G_Me.timePrivilegeData:setGoodsRefreshedMark(false)
    G_Me.timePrivilegeData:setEnterFunctionMark(true)
end

-- 每周一中午12点要刷新一下
function TimePrivilegeMainLayer:_addWeekRefreshTimer()
    if not self._tRefreshTimer then
        self._tRefreshTimer = G_GlobalFunc.addTimer(1, function()
            if G_Me.timePrivilegeData:needRefresh() then
                G_HandlersManager.timePrivilegeHandler:sendShopTimeInfo()
                G_HandlersManager.shopHandler:sendShopInfo(SHOP_TYPE_TIME_PRIVILEGE)
                G_HandlersManager.timePrivilegeHandler:sendShopTimeRewardInfo()
            end
        end)
    end
end

function TimePrivilegeMainLayer:onLayerExit()
	if self._tTimer then
        G_GlobalFunc.removeTimer(self._tTimer)
        self._tTimer = nil
    end

    if self._tRefreshTimer then
        G_GlobalFunc.removeTimer(self._tRefreshTimer)
        self._tRefreshTimer = nil
    end

    G_flyAttribute._clearFlyAttributes()
end

function TimePrivilegeMainLayer:_initWidgets()
    self:showWidgetByName("Panel_123_0", false)
    self:showWidgetByName("Panel_118", false)
	self:_initTabs()
	self:_switchPage(self._nCurPage)

    self:registerBtnClickEvent("Button_Back", function()
        uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
    end)

    self:registerBtnClickEvent("Button_Help", function()
        require("app.scenes.common.CommonHelpLayer").show({
            {title=G_lang:get("LANG_TIME_PRIVILEGE_HELP_TITLE1"), content=G_lang:get("LANG_TIME_PRIVILEGE_HELP_CONTENT1")},
            {title=G_lang:get("LANG_TIME_PRIVILEGE_HELP_TITLE2"), content=G_lang:get("LANG_TIME_PRIVILEGE_HELP_CONTENT2")},
            {title=G_lang:get("LANG_TIME_PRIVILEGE_HELP_TITLE3"), content=G_lang:get("LANG_TIME_PRIVILEGE_HELP_CONTENT3")},
        } )
    end)

    self:getLoadingBarByName("ProgressBar_Buy"):setPercent(0)
end

function TimePrivilegeMainLayer:_initTabs()
	self._tabs = require("app.common.tools.Tabs").new(2, self, self._checkedCallBack, self._uncheckedCallBack) 
    self._tabs:add("CheckBox_list1", self:getPanelByName("Panel_content1"), "Label_ProbDiscount") 
    self._tabs:add("CheckBox_list2", self:getPanelByName("Panel_content2"), "Label_RechargePrivilege") 
    self._tabs:add("CheckBox_list3", self:getPanelByName("Panel_content3"), "Label_Welfare") 

    self._tabs:checked("CheckBox_list" .. self._nCurPage)
end

function TimePrivilegeMainLayer:_checkedCallBack(szCheckBoxName)
	if szCheckBoxName == "CheckBox_list1" then
		self._nCurPage = PAGE.PROB_DISCOUNT
		self:_switchPage(self._nCurPage)
	elseif szCheckBoxName == "CheckBox_list2" then
		self._nCurPage = PAGE.RECHARGE_PRIVILEGE
		self:_switchPage(self._nCurPage)
	elseif szCheckBoxName == "CheckBox_list3" then
		self._nCurPage = PAGE.WELFACE
		self:_switchPage(self._nCurPage)
	end

    self:showWidgetByName("Button_RechargePrivilege", self._nCurPage ~= PAGE.RECHARGE_PRIVILEGE)
end

function TimePrivilegeMainLayer:_switchPage(nPage)
    self:showWidgetByName("Panel_169", self._nCurPage == PAGE.RECHARGE_PRIVILEGE)

    local lableTips = self:getLabelByName("Label_GoodsChangeTip")
    local lableTips1 = self:getLabelByName("Label_GoodsChangeTip1")
	self:showWidgetByName("Panel_content" .. nPage, self._nCurPage == nPage)
	if nPage == PAGE.PROB_DISCOUNT then
        lableTips:setText(G_lang:get("LANG_TIME_PRIVILEGE_GOODS_REFRESH1"))
        lableTips:createStroke(Colors.strokeBrown, 1)
        lableTips1:setText(G_lang:get("LANG_TIME_PRIVILEGE_GOODS_REFRESH2"))
        lableTips1:createStroke(Colors.strokeBrown, 1)
	elseif nPage == PAGE.RECHARGE_PRIVILEGE then
        lableTips:setText("")
        lableTips1:setText("")
        self:_updateRechargePrivilegePage()
	elseif nPage == PAGE.WELFACE then
        lableTips:setText(G_lang:get("LANG_TIME_PRIVILEGE_AWARD_REFRESH1"))
        lableTips1:setText(G_lang:get("LANG_TIME_PRIVILEGE_AWARD_REFRESH2"))
        -- 拉取信息
        G_HandlersManager.timePrivilegeHandler:sendShopTimeRewardInfo()
	end

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        lableTips,
        lableTips1,
        }, "C")
    lableTips:setPositionXY(alignFunc(1))
    lableTips1:setPositionXY(alignFunc(2))
end

-- 3个页面都有的部分
function TimePrivilegeMainLayer:_initCommonPart()
    local nCurSchedule = G_Me.timePrivilegeData:getSchedule()

	CommonFunc._updateLabel(self, "Label_BuySchedule", {text=G_lang:get("LANG_TIME_PRIVILEGE_BUY_SCHEDULE"), stroke=Colors.strokeBrown})
    CommonFunc._updateLabel(self, "Label_Desc", {text=G_lang:get("LANG_TIME_PRIVILEGE_BUY_SCHEDULE_PRIVILEGE"), stroke=Colors.strokeBrown})
    CommonFunc._updateLabel(self, "Label_ScheduleValue", {text=nCurSchedule.."/"..TOTAL_SCHEDULE, stroke=Colors.strokeBrown})

    local scheduleBar = self:getLoadingBarByName("ProgressBar_Buy")
    if scheduleBar then
        scheduleBar:setPercent(nCurSchedule / TOTAL_SCHEDULE * 100)
    end

    self:registerBtnClickEvent("Button_RechargePrivilege", function(sender)
        local nSchedule = G_Me.timePrivilegeData:getSchedule()
        if nSchedule < 100 then
            G_MovingTip:showMovingTip(G_lang:get("LANG_TIME_PRIVILEGE_NOT_REACH_SCHEDULE_TIP"))
            return
        else
            self._nCurPage = PAGE.RECHARGE_PRIVILEGE
            self._tabs:checked("CheckBox_list" .. self._nCurPage)
        end
    end)
end

-- 更新折扣商店
function TimePrivilegeMainLayer:_updateDiscountProbPage()
	self:_initCommonPart()
    self:showWidgetByName("Panel_118", true)

    self:_updateRechargePrivilegePage()
end

-- 更新充值优惠界面
function TimePrivilegeMainLayer:_updateRechargePrivilegePage()
    local nRechargeId = G_Me.timePrivilegeData:getRechargeId()
    if nRechargeId ~= 0 then
        self:getPanelByName("Panel_ScheduleEnough"):setVisible(true)
        self:getPanelByName("Panel_ScheduleNotEnough"):setVisible(false)

        local tRechargeTmpl = shop_time_recharge_info.get(nRechargeId)
        assert(tRechargeTmpl)
        local nRechargeValue = tRechargeTmpl.recharge_size
        local nReturnGold = G_Me.timePrivilegeData:getExtraGold()

        CommonFunc._updateLabel(self, "Label_Recharge", {text=G_lang:get("LANG_TIME_PRIVILEGE_RECHARGE_PRICE"), stroke=Colors.strokeBrown})
        CommonFunc._updateLabel(self, "Label_RechargeValue", {text=G_lang:get("LANG_TIME_PRIVILEGE_RECHARGE_PRICE_NUM", {num=nRechargeValue}), stroke=Colors.strokeBrown})
        -- 额外返回元宝数
        CommonFunc._updateLabel(self, "Label_ReturnGold", {text=G_lang:get("LANG_TIME_PRIVILEGE_RETURN_GOLD"), stroke=Colors.strokeBrown})
        -- 元宝数量
        CommonFunc._updateLabel(self, "Label_ReturnGoldValue", {text=G_lang:get("LANG_TIME_PRIVILEGE_RETURN_GOLD_VALUE", {num=nReturnGold}), stroke=Colors.strokeBrown})
        -- 充值额度提示
        CommonFunc._updateLabel(self, "Label_RechargeTips", {text=G_lang:get("LANG_TIME_PRIVILEGE_RECHARGE_TIPS"),stroke=Colors.strokeBrown})
        -- 优惠截止时间
        CommonFunc._updateLabel(self, "Label_EndTime", {text=""})
        CommonFunc._updateLabel(self, "Label_EndTimeValue", {text=""})


        self:showWidgetByName("Button_recharge", true)
        self:showWidgetByName("Button_GoToBuy", false)

        local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
            self:getLabelByName('Label_Recharge'),
            self:getLabelByName('Label_RechargeValue'),
        }, "C")
        self:getLabelByName('Label_Recharge'):setPositionXY(alignFunc(1))
        self:getLabelByName('Label_RechargeValue'):setPositionXY(alignFunc(2))

        if not self._tTimer then
            self._tTimer = G_GlobalFunc.addTimer(1, function(dt)
                -- 剩余时间
                local nLeftTime = math.max(0, G_Me.timePrivilegeData:getFinishTime() - G_ServerTime:getTime())
                local nDay, nHour, nMin, nSec = G_ServerTime:getLeftTimeParts(G_Me.timePrivilegeData:getFinishTime())
                if nDay > 0 then
                    szTime = G_lang:get("LANG_TIME_DUNGEON_FORMAT_1",{dayValue=nDay, hourValue=nHour, minValue=nMin, secondValue=nSec})
                elseif nDay == 0 and nHour > 0 then
                    szTime = G_lang:get("LANG_TIME_DUNGEON_FORMAT_2",{hourValue=nHour, minValue=nMin, secondValue=nSec})
                elseif nDay == 0 and nHour == 0 then
                    szTime = G_lang:get("LANG_TIME_DUNGEON_FORMAT_3",{minValue=nMin, secondValue=nSec})
                end  
                CommonFunc._updateLabel(self, "Label_EndTime", {text=G_lang:get("LANG_TIME_PRIVILEGE_END_TIME"), stroke=Colors.strokeBrown})
                CommonFunc._updateLabel(self, "Label_EndTimeValue", {text=szTime, stroke=Colors.strokeBrown})

                local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
                    self:getLabelByName('Label_EndTime'),
                    self:getLabelByName('Label_EndTimeValue'),
                }, "C")
                self:getLabelByName('Label_EndTime'):setPositionXY(alignFunc(1))
                self:getLabelByName('Label_EndTimeValue'):setPositionXY(alignFunc(2))


                if nLeftTime == 0 then
                    if self._tTimer then
                        G_GlobalFunc.removeTimer(self._tTimer)
                        self._tTimer = nil
                    end
                    G_HandlersManager.timePrivilegeHandler:sendShopTimeInfo()
                end
            end)
        end

    else
        self:getPanelByName("Panel_ScheduleEnough"):setVisible(false)
        self:getPanelByName("Panel_ScheduleNotEnough"):setVisible(true)
        -- 未获得优惠资格
        CommonFunc._updateLabel(self, "Label_NoEligibility1", {text=G_lang:get("LANG_TIME_PRIVILEGE_NO_ELIGIBILIGY1"), stroke=Colors.strokeBrown})
        CommonFunc._updateLabel(self, "Label_NoEligibility2", {text=G_lang:get("LANG_TIME_PRIVILEGE_NO_ELIGIBILIGY2"), stroke=Colors.strokeBrown})
        CommonFunc._updateLabel(self, "Label_EndTimeValue", {text=""})

        self:showWidgetByName("Button_recharge", false)
        self:showWidgetByName("Button_GoToBuy", true)

        -- 时间不显示
        self:showWidgetByName("Panel_169", false)

        if self._tEff then
            self._tEff:removeFromParentAndCleanup(true)
            self._tEff = nil
        end

        if self._tTimer then
            G_GlobalFunc.removeTimer(self._tTimer)
            self._tTimer = nil
        end
    end

    CommonFunc._updateLabel(self, "Label_GirlSay", {text=G_lang:get("LANG_TIME_PRIVILEGE_GIRL_SAY")})

    self:registerBtnClickEvent("Button_recharge", handler(self, self._onOpenRechargeLayer))
    self:registerBtnClickEvent("Button_GoToBuy", handler(self, self._onBuyDiscountProp))

    self:_showRechargeTips()
end

-- 更新全民福利界面
function TimePrivilegeMainLayer:_updateWelfacePage()

end

function TimePrivilegeMainLayer:_showRechargeTips()
    local nRechargeId = G_Me.timePrivilegeData:getRechargeId()
    if nRechargeId ~= 0 then
        -- 红点
        self:showWidgetByName("Image_RechargeTips", true)
        -- 特效
        if not self._tEff then
            self._tEff = EffectNode.new("effect_around2", function(event, frameIndex) end)
            self._tEff:setScale(1.4)
            self:getButtonByName("Button_recharge"):addNode(self._tEff, 1)
            self._tEff:play()
        end
        -- 优惠充值上的特效
        if not self._tEff2 then
            self._tEff2 = EffectNode.new("effect_rechargeoffer", function(event, frameIndex) end)
            self._tEff2:setScale(1)
            self:getButtonByName("Button_RechargePrivilege"):addNode(self._tEff2, 1)
            self._tEff2:play()
        end

        if not self._tEff3 then
            self._tEff3 = EffectNode.new("effect_Buyprogress", function(event, frameIndex) end)
            self._tEff3:setScale(1)
            self:getImageViewByName("Image_BarBg"):addNode(self._tEff3, 1)
            self._tEff3:play()
        end
    else
        self:showWidgetByName("Image_RechargeTips", false)
        if self._tEff then
            self._tEff:removeFromParentAndCleanup(true)
            self._tEff = nil 
        end
        if self._tEff2 then
            self._tEff2:removeFromParentAndCleanup(true)
            self._tEff2 = nil 
        end
        if self._tEff3 then
            self._tEff3:removeFromParentAndCleanup(true)
            self._tEff3 = nil 
        end
    end
end

function TimePrivilegeMainLayer:_showAwardTips()
    local hasAward = G_Me.timePrivilegeData:hasUnclaimedAward()
    self:showWidgetByName("Image_AwardTips", hasAward)
end

function TimePrivilegeMainLayer:_initListView()
    if not self._tListView then
        local panel = self:getPanelByName("Panel_list2")
        assert(panel)
        self._tListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
        
        self._tListView:setCreateCellHandler(function(list, index)
            return TimePrivilegeAwardItem.new()
        end)

        self._tListView:setUpdateCellHandler(function(list, index, cell)
            local tTmpl = self._tAwardList[index + 1]
            cell:updateItem(tTmpl)
        end)

        self._tListView:initChildWithDataLength(shop_time_reward_info.getLength())

        self._tListView:setSpaceBorder(0, 80)
    end
end

function TimePrivilegeMainLayer:_initAwardData()
    local function contains(idList, nId)
        local isContains = false
        for key, val in pairs(idList) do
            local id = val
            if id == nId then
                isContains = true
            end
        end
        return isContains
    end

    local tAwardList = {}
    local tClaimedList = G_Me.timePrivilegeData:getClaimAwardList()
    for i=1, shop_time_reward_info.getLength() do
        local tTmpl = shop_time_reward_info.indexOf(i)
        local isContains = contains(tClaimedList, tTmpl.id)
        if isContains then
            tTmpl._nState = TimePrivilegeConst.CLAIM_STATE.CLAIMED
        else
            tTmpl._nState = TimePrivilegeConst.CLAIM_STATE.UNFINISH
        end

        table.insert(tAwardList, tTmpl)
    end
    local function sortFunc(tTmpl1, tTmpl2)
        if tTmpl1._nState ~= tTmpl2._nState then
            return tTmpl1._nState < tTmpl2._nState
        else
            return tTmpl1.id < tTmpl2.id
        end
    end
    table.sort(tAwardList, sortFunc)

    self._tAwardList = tAwardList
end

function TimePrivilegeMainLayer:_reloadListView()
   self._tAwardList = nil
   self:_initAwardData() 
   self:_initListView()
   local len = table.nums(self._tAwardList)
   self._tListView:reloadWithLength(len)

   -- 购买优惠充值的总人数
   self:_updateNumList()

   self:_showAwardTips()
end

function TimePrivilegeMainLayer:_onGetAwardSucc(data)
    -- 刷新列表
    G_HandlersManager.timePrivilegeHandler:sendShopTimeRewardInfo()
    -- 飞奖励
    local tDropList = {}
    for i, val in ipairs(data.awards) do
        local tAward = val
        local tDrop = {}
        tDrop.type = tAward.type
        tDrop.value = tAward.value
        tDrop.size = tAward.size
        table.insert(tDropList, tDrop)
    end
    local tGoodsPopWindowsLayer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(tDropList, function() end)
    self:addChild(tGoodsPopWindowsLayer)
    -- 红点
    self:_showAwardTips()
end

function TimePrivilegeMainLayer:_onOpenRechargeLayer(sender)
    -- 打开充值界面
    require("app.scenes.shop.recharge.RechargeLayer").show()  
end

function TimePrivilegeMainLayer:_onBuyDiscountProp(sender)
    self._nCurPage = PAGE.PROB_DISCOUNT
    self._tabs:checked("CheckBox_list" .. self._nCurPage)
end

function TimePrivilegeMainLayer:updateItems(message)
    -- 更新每一项的数据
    for i=1, #message.id do
        
        local marketId = message.id[i]
        
        -- 获取商品数据
        local mi = shop_time_info.get(marketId)
        assert(mi, "Could not find the market item with id: "..marketId)

        local goods = G_Goods.convert(mi.type, mi.value, mi.size)

        -- 商品名称 Label_Item_Name_1
        CommonFunc._updateLabel(self, "Label_Item_Name_"..i, {text=goods.name, stroke=Colors.strokeBrown, color=Colors.qualityColors[goods.quality]})

        -- 数量
        CommonFunc._updateLabel(self, "Label_item_amount"..i, {text="x"..G_GlobalFunc.ConvertNumToCharacter3(mi.size), stroke=Colors.strokeBrown, color=Colors.darkColors.DESCRIPTION})
        
        -- 商品icon
        CommonFunc._updateImageView(self, "ImageView_head"..i, {texture=goods.icon, texType=UI_TEX_TYPE_LOCAL})

        -- 头像现在需要响应事件用来显示详情
        self:getImageViewByName("ImageView_head"..i):setTouchEnabled(true)

        self:registerWidgetClickEvent("ImageView_head"..i, function()
            require("app.scenes.common.dropinfo.DropInfo").show(mi.type, mi.value)
        end)
        
        -- 背景
        CommonFunc._updateImageView(self, "ImageView_bg"..i, {texture=G_Path.getEquipIconBack(goods.quality), texType=UI_TEX_TYPE_PLIST})
        
        -- 商品品质框
        CommonFunc._updateImageView(self, "ImageView_headframe"..i, {texture=G_Path.getEquipColorImage(goods.quality,goods.type), texType=UI_TEX_TYPE_PLIST})
        
        -- 优惠
        local discount = mi.discount
        if discount == "0" then
            -- 不打折
            CommonFunc._updateImageView(self, "Image_discount"..i, {visible=false})
            self:showWidgetByName("Image_RedLine"..i, false)
        else
            self:showWidgetByName("Image_RedLine"..i, true)
            CommonFunc._updateImageView(self, "Image_discount"..i, {texture=getDiscountImagePath(discount), texType=UI_TEX_TYPE_LOCAL, visible=true})
        end

        local oriPrice = mi.pre_value
        local newPrice = mi.price_value
        local money = self:_getCurrencyCount(mi.price_type)

        local currencyIcon = getCurrencyImage(mi.price_type)
        CommonFunc._updateImageView(self, "Image_Gold"..i, {texture=currencyIcon, texType=UI_TEX_TYPE_PLIST})

        -- 原价格
        CommonFunc._updateLabel(self, "Label_Item_OrigPrice_"..i, {text=G_lang:get("LANG_TIME_PRIVILEGE_ORIGINAL_PRICE"), color=Colors.lightColors.DESCRIPTION})
        local imgCurrency = self:getImageViewByName("Image_Currency"..i)
        local currencyIcon2 = getCurrencyImage2(mi.price_type)
        imgCurrency:loadTexture(currencyIcon2, UI_TEX_TYPE_PLIST)

        CommonFunc._updateLabel(self, "Label_Item_OrigPriceNum_"..i, {text=ConvertNumToCharacter3(oriPrice), color=Colors.lightColors.DESCRIPTION})

        -- 现价格
        CommonFunc._updateLabel(self, "Label_Glod"..i, {text=ConvertNumToCharacter3(newPrice), color=money >= newPrice and Colors.lightColors.TITLE_01 or Colors.lightColors.TIPS_01, stroke=Colors.strokeBrown})
        -- 

        -- 按钮状态
        CommonFunc._updateImageView(self, "ImageView_got"..i, {visible=message.num[i] ~= 0})
        self:getButtonByName("Button_buy"..i):setTouchEnabled(message.num[i] == 0)

        CommonFunc._updateImageView(self, "Image_Gold"..i, {visible=message.num[i] == 0})
        CommonFunc._updateLabel(self, "Label_Glod"..i, {visible=message.num[i] == 0})
        

        local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
            self:getImageViewByName('Image_Gold'..i),
            self:getLabelByName('Label_Glod'..i),
        }, "C")
        self:getImageViewByName('Image_Gold'..i):setPositionXY(alignFunc(1))
        self:getLabelByName('Label_Glod'..i):setPositionXY(alignFunc(2))


        local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
            self:getLabelByName('Label_Item_OrigPrice_'..i),
            self:getImageViewByName('Image_Currency'..i),
            self:getLabelByName('Label_Item_OrigPriceNum_'..i),
        }, "C")
        self:getLabelByName('Label_Item_OrigPrice_'..i):setPositionXY(alignFunc(1))
        self:getImageViewByName('Image_Currency'..i):setPositionXY(alignFunc(2))
        self:getLabelByName('Label_Item_OrigPriceNum_'..i):setPositionXY(alignFunc(3))


        
        self:registerBtnClickEvent("Button_buy"..i, function(sender)
            local function _onBuyResultEvent(_, data)
                if data.ret == NetMsg_ERROR.RET_OK then
                    local goods = G_Goods.convert(mi.type, mi.value)
                    G_flyAttribute.addNormalText(G_lang:get("LANG_TIME_PRIVILEGE_BUY_SUCCESS_DESC1"), Colors.getColor(5))
                    G_flyAttribute.doAddRichtext(G_lang:get("LANG_TIME_PRIVILEGE_BUY_SUCCESS_DESC2", {color=Colors.getRichTextValue(Colors.getColor(goods.quality)), name=goods.name}))
                    G_flyAttribute.play()

                    -- 开启按钮响应
                    self:getButtonByName("Button_buy"..data.index):setEnabled(true)
                    self:getButtonByName("Button_buy"..data.index):setTouchEnabled(false)
                    
                    message.num[data.index] = 1
                    
                    self:updateItems(message)
                    
                else
                    MessageBoxEx.showOkMessage(G_lang:get("LANG_TIPS"), G_NetMsgError.getMsg(data.ret).msg)
                end
                uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_SHOP_ITEM_BUY_RESULT) 
            end


            local function yesCallback()
                local CheckFunc = require "app.scenes.common.CheckFunc"
                local result, errorMsg = CheckFunc.checkBagFullByType(mi.type)

                if result then
                    return
                end

                self._nPreSchedule = G_Me.timePrivilegeData:getSchedule()

                if mi.price_type == CURRENCY_TYPE.GOLD then
                    -- 价格不足以购买则返回
                    if money < newPrice then
                        require("app.scenes.shop.GoldNotEnoughDialog").show()
                        return
                    end
                else
                    local nCurrencyCount = self:_getCurrencyCount(mi.price_type)
                    if nCurrencyCount < newPrice then
                        local szTip = self:getCurrencyNotEnoughTip(mi.price_type)
                        G_MovingTip:showMovingTip(szTip)
                        return
                    end
                end

                -- 用元宝购买要提示
                if mi.price_type == CURRENCY_TYPE.GOLD then
                    -- 元宝购买提示
                    self:getButtonByName("Button_buy" .. i):setEnabled(false)
                    local layer = require("app.scenes.common.CommonGoldConfirmLayer").create(goods, newPrice, function(_layer)
                        
                        _layer:animationToClose()
                        -- 发送购买按钮
                        G_HandlersManager.shopHandler:sendBuyItem(SHOP_TYPE_TIME_PRIVILEGE, message.id[i], 1, i)
                        -- 关闭按钮避免连续点击出错
                        self:getButtonByName("Button_buy"..i):setEnabled(false)
                        
                        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_ITEM_BUY_RESULT, _onBuyResultEvent, self)
                    end, function()
                        -- cancel回调 
                        self:getButtonByName("Button_buy" .. i):setEnabled(true)
                    end)
                    
                    uf_sceneManager:getCurScene():addChild(layer)
                
                else
                    -- 使用将魂，神魂等购买
                    -- 发送购买按钮
                    G_HandlersManager.shopHandler:sendBuyItem(SHOP_TYPE_TIME_PRIVILEGE, message.id[i], 1, i)

                    -- 关闭按钮避免连续点击出错
                    self:getButtonByName("Button_buy"..i):setEnabled(false)
                
                    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_ITEM_BUY_RESULT, _onBuyResultEvent, self)
                end
            end

            local function noCallback()
                self:getButtonByName("Button_buy"..i):setEnabled(true)
            end

            -- 判断有没有生成限时优惠订单
            local nSchedule = G_Me.timePrivilegeData:getSchedule()
            if nSchedule == TOTAL_SCHEDULE then
                local tLayer = TimePrivilegeWarningLayer.create(G_lang:get("LANG_TIME_PRIVILEGE_BUY_WARNING"), yesCallback, noCallback)
                if tLayer then
                    uf_sceneManager:getCurScene():addChild(tLayer)
                end
                return
            end
            
            yesCallback()

        end)
    end

    self:showWidgetByName("Panel_123_0", true)
end

function TimePrivilegeMainLayer:_getCurrencyCount(nCurrencyType)
    local nCurCount = 0
    if nCurrencyType == CURRENCY_TYPE.SILVER then
        nCurCount = G_Me.userData.money
    elseif nCurrencyType == CURRENCY_TYPE.GOLD then
        nCurCount = G_Me.userData.gold
    elseif nCurrencyType == CURRENCY_TYPE.JING_JI_CHANG then
        nCurCount = G_Me.userData.prestige
    elseif nCurrencyType == CURRENCY_TYPE.MO_SHEN then
        nCurCount = G_Me.userData.medal
    elseif nCurrencyType == CURRENCY_TYPE.CHUANG_GUAN then
        nCurCount = G_Me.userData.tower_score
    elseif nCurrencyType == CURRENCY_TYPE.JIANG_HUN then
        nCurCount = G_Me.userData.essence
    elseif nCurrencyType == CURRENCY_TYPE.JUN_TUAN then
        nCurCount = G_Me.userData.corp_point
    elseif nCurrencyType == CURRENCY_TYPE.SHEN_HUN then
        nCurCount = G_Me.userData.god_soul
    end

    return nCurCount
end

function TimePrivilegeMainLayer:getCurrencyNotEnoughTip(nCurrencyType)
    local szTip = ""
    if nCurrencyType == CURRENCY_TYPE.SILVER then
        szTip = G_lang:get("LANG_SILVER")
    elseif nCurrencyType == CURRENCY_TYPE.GOLD then
        szTip = G_lang:get("LANG_GOLDEN")
    elseif nCurrencyType == CURRENCY_TYPE.JING_JI_CHANG then
        szTip = G_lang:get("LANG_GOODS_SHENG_WANG")
    elseif nCurrencyType == CURRENCY_TYPE.MO_SHEN then
        szTip = G_lang:get("LANG_GOODS_JIANG_ZHANG")
    elseif nCurrencyType == CURRENCY_TYPE.CHUANG_GUAN then
        szTip = G_lang:get("LANG_GOODS_ZHAN_GONG")
    elseif nCurrencyType == CURRENCY_TYPE.JIANG_HUN then
        szTip = G_lang:get("LANG_GOODS_JIANG_HUN")
    elseif nCurrencyType == CURRENCY_TYPE.JUN_TUAN then
        szTip = G_lang:get("LANG_GOODS_CORP_DISTRIBUTION")
    elseif nCurrencyType == CURRENCY_TYPE.SHEN_HUN then
        szTip = G_lang:get("LANG_GOODS_SHENHUN")
    end

    szTip = G_lang:get("LANG_TIME_PRIVILEGE_CURRENCY_NOT_ENOUGH", {name=szTip})

    return szTip
end


function TimePrivilegeMainLayer:_onBuyGoodsSucc()
    -- 更新购买进度
    local nCurSchedule = G_Me.timePrivilegeData:getSchedule()
    local scheduleBar = self:getLoadingBarByName("ProgressBar_Buy")

    -- 加进度+N飞字
    local nOffset = nCurSchedule - self._nPreSchedule
    if nOffset ~= 0 then
        G_flyAttribute.doAddRichtext(G_lang:get("LANG_TIME_PRIVILEGE_ADD_SCHEDULE_ACTION1", {color=Colors.getRichTextValue(Colors.getColor(2)), num=nOffset}),
            30, nil, Colors.strokeBrown, self:getImageViewByName("Image_BarBg"))

        local function scheduleBarAction()
            if G_SceneObserver:getSceneName() == "TimePrivilegeMainScene" then
                CommonFunc._updateLabel(self, "Label_ScheduleValue", {text=nCurSchedule.."/"..TOTAL_SCHEDULE, stroke=Colors.strokeBrown})
                scheduleBar:runToPercent(nCurSchedule, 0.2)
                if nCurSchedule == 100 then
                    self:_showRechargeTips()
                end
            end
        end

        if self.callAfterDelayTime then
            self:callAfterDelayTime(2, nil, scheduleBarAction)
        end
    else
        G_flyAttribute.doAddRichtext(G_lang:get("LANG_TIME_PRIVILEGE_ADD_SCHEDULE_ACTION1", {color=Colors.getRichTextValue(Colors.getColor(2)), num=nOffset}),
            30, nil, Colors.strokeBrown, nil)
    end
end

function TimePrivilegeMainLayer:_updateNumList()
    self:_numAnimeStart()
end

function TimePrivilegeMainLayer:_getDust()
    local num = G_Me.timePrivilegeData:getRechargeCount()
    if num > 99999 then
        num = 99999
    end
    return num
end

function TimePrivilegeMainLayer:_numAnimeStart()
    local num = self:_getDust()
    self:_numListAnime(self._peopleCount,num,function ( )
        self._peopleCount = num
        if self._peopleCount < self:_getDust() then
            self:_numAnimeStart()
        end
    end)
end

function TimePrivilegeMainLayer:_numListAnime(num1,num2,callback)
    if self._anime then
        return
    end
    if num1 == num2 then
        return
    end
    self._anime = true
    local count = 0
    local list1 = self:_setNum1(num1)
    local list2 = self:_setNum2(num2)
    for i = 1, 5 do
        if list1[i] ~= list2[i] then
            count = count + 1
            self:_runAni(i,function ( )
                count = count - 1
                if count == 0 then
                    self._anime = false
                    callback()
                end
            end)
        end
    end 
end

function TimePrivilegeMainLayer:_setNum1(num1)
    local num = num1
    local num5 = num%10
    num = math.floor(num/10)

    local num4 = num%10
    num = math.floor(num/10)

    local num3 = num%10
    num = math.floor(num/10)

    local num2 = num%10
    local num1 = math.floor(num/10)

    self._numList[1]:setText(num1)
    self._numList[2]:setText(num2)
    self._numList[3]:setText(num3)
    self._numList[4]:setText(num4)
    self._numList[5]:setText(num5)
    return {num1,num2,num3,num4,num5}
end

function TimePrivilegeMainLayer:_setNum2(num2)
    local num = num2
    local num5 = num%10
    num = math.floor(num/10)

    local num4 = num%10
    num = math.floor(num/10)

    local num3 = num%10
    num = math.floor(num/10)

    local num2 = num%10
    local num1 = math.floor(num/10)
    self._numList2[1]:setText(num1)
    self._numList2[2]:setText(num2)
    self._numList2[3]:setText(num3)
    self._numList2[4]:setText(num4)
    self._numList2[5]:setText(num5)
    return {num1,num2,num3,num4,num5}
end

function TimePrivilegeMainLayer:_runAni(index,callback)
    local label1 = self._numList[index]
    local label2 = self._numList2[index]
    local delay = 0.5
    local ease1 = CCEaseIn:create(CCMoveBy:create(delay, ccp(0, -71)), delay)
    local ease2 = CCEaseIn:create(CCMoveBy:create(delay, ccp(0, -71)), delay)
    label1:runAction(CCSequence:createWithTwoActions(ease1, CCCallFunc:create(function()
        local posx,posy = label1:getPosition() 
        label1:setPosition(ccp(posx,posy+142))
        self._numList[index] = label2
        self._numList2[index] = label1
        callback()
        end)))
    label2:runAction(ease2)
end



return TimePrivilegeMainLayer