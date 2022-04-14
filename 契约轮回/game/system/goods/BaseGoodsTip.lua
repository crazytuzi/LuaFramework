--
-- @Author: chk
-- @Date:   2019-01-15 17:38:54
--
BaseGoodsTip = BaseGoodsTip or class("BaseGoodsTip", BaseWidget)
local BaseGoodsTip = BaseGoodsTip

function BaseGoodsTip:ctor(parent_node, layer)
    -- self.abName = "111111111111111"
    -- self.assetName = "BaseGoodsTip"
    self.layer = layer

    self.events = {}
    self:InitData()
    SetLocalScale(self.transform, 1, 1, 1)
end

function BaseGoodsTip:dctor()
    if self.iconStor ~= nil then
        self.iconStor:destroy()
		self.iconStor = nil
    end

    for i, v in pairs(self.btnSettors) do
        v:destroy()
    end

    for i, v in pairs(self.atts) do
        v:destroy()
    end

    for i, v in pairs(self.events) do
        GlobalEvent:RemoveListener(v)
    end

    if self.jumpItemSettor ~= nil then
        self.jumpItemSettor:destroy()
    end

    self.model = nil;
end

function BaseGoodsTip:LoadCallBack()
    self.nodes = {
        "mask",
        "bg",
        "q_bg",
        "fram",
        "nameTxt",
        "icon",
        "lv/lvText",
        "lv/lvValue",
        "type/typeValue",
        "ScrollView",
        "ScrollView/Viewport/Content",

        "btnContain",
        "btnContain/exchangeBtn",
        "btnContain/batchExchangeBtn",
        "btnContain/useBtn",
        "btnContain/sellBtn",
        "btnContain/storeBtn",
        "btnContain/takeOutBtn",
        "btnContain/destroyBtn",
        "btnContain/upShelfBtn",
        "btns",
        "valueTemp",
    }
    self:GetChildren(self.nodes)
    self:GetRectTransform()

    SetLocalScale(self.transform, 1, 1, 1)
    --self:AddEvent()
    self.auto_order_count = 15
    -- 最大值加15可能超出每个界面之间的间隔，每个界面间隔是20
    self:SetOrderByParentMax()
end

function BaseGoodsTip:AddEvent()
    self:AddClickCloseBtn()
end

function BaseGoodsTip:SetData(data)

end

--判断是否在Tip内
--isCall 是不是外部调用
function BaseGoodsTip:OnTouchenBengin(x, y, isCall)
    --local pos = self.transform.position
    --local bg_x = DesignResolutionWidth / 2 + pos.x * 100
    --local bg_y = pos.y * 100 + DesignResolutionWidth / 2
    --
    --local xw = bg_x + self.bgRectTra.sizeDelta.x
    --local yw = bg_y - self.bgRectTra.sizeDelta.y



    local isInViewBG = false
    local isInOperateBtn = false

    isInViewBG = LayerManager:UIRectangleContainsScreenPoint(self.bgRectTra, x, y)

    if (self.btnSettors) then
        for _, v in ipairs(self.btnSettors) do
            if (LayerManager:UIRectangleContainsScreenPoint(v.transform, x, y)) then
                isInOperateBtn = true
                break
            end
        end
    end

    --if x >= bg_x and  x <= xw and yw <= y and bg_y >= y  then
    --   isInViewBG = true
    --end
    --
    --if self.operate_param ~= nil then
    --    local num = table.nums(self.operate_param)
    --    local btnContainPos = self.btnContain.position
    --    local btnContain_x = DesignResolutionWidth / 2 + btnContainPos.x * 100
    --    local btnContain_y = DesignResolutionWidth / 2 + btnContainPos.y * 100
    --    local btnContain_xw = btnContain_x + 100
    --    local btnContain_yw = btnContain_y + 55 * num + 2 * (num - 1)
    --
    --    if x >= btnContain_x and x <= btnContain_xw and  btnContain_y <= y and btnContain_yw >= y then
    --        isInOperateBtn = true
    --    end
    --end

    if (isCall) then
        return isInViewBG or isInOperateBtn
    else
        if not isInViewBG and not isInOperateBtn then
            self:destroy()
        end
    end


end

function BaseGoodsTip:AddClickCloseBtn()
    if self.click_bg_close then
        local tcher = self.gameObject:AddComponent(typeof(Toucher))
        tcher:SetClickEvent(handler(self, self.OnTouchenBengin))
    end
end

function BaseGoodsTip:AddOperateBtns()
    for i, v in pairs(self.operate_param or {}) do
        self.btnSettors[#self.btnSettors + 1] = GoodsOperateBtnSettor(self.btns)
        self.btnSettors[#self.btnSettors]:SetData(v)
    end
end

function BaseGoodsTip:CloseTipView()
    self:destroy()
end

function BaseGoodsTip:GetRectTransform()
    self.viewRectTra = self.transform:GetComponent('RectTransform')
    self.contentRectTra = self.Content:GetComponent('RectTransform')
    self.bgRectTra = self.bg:GetComponent('RectTransform')
    self.scrollViewRectTra = self.ScrollView:GetComponent('RectTransform')
    --self.attContainRectTra = self.Content:GetComponent('RectTransform')
    self.parentRectTra = self.parent_node:GetComponent('RectTransform')
    self.valueTempTxt = self.valueTemp:GetComponent('Text')

    SetLocalPosition(self.transform, -10000, 0)
    --self.viewRectTra.anchoredPosition = Vector2(-10000,0)
end

function BaseGoodsTip:DelItem(bagId, uid)
    if self.uid == uid then
        self:destroy()
    end
end

function BaseGoodsTip:DealContentHeight()
	if self.height < self.minScrollViewHeight then
		return self.minScrollViewHeight
	end
	
	if self.height > self.maxScrollViewHeight then
		return self.maxScrollViewHeight
	end
	
	return self.height	
end

function BaseGoodsTip:DealCreateAttEnd()
	SetSizeDeltaY(self.contentRectTra, self.height)
	
	local srollViewY = self:DealContentHeight()
	SetSizeDeltaY(self.scrollViewRectTra, srollViewY)
	
    --self.contentRectTra.sizeDelta = Vector2(self.contentRectTra.sizeDelta.x,)
    --if self.contentRectTra.sizeDelta.y > self.minScrollViewHeight and self.contentRectTra.sizeDelta.y < self.maxScrollViewHeight then
        --self.scrollViewRectTra.sizeDelta = Vector2(self.scrollViewRectTra.sizeDelta.x, self.height)
    --elseif self.height >= self.maxScrollViewHeight then
        --self.scrollViewRectTra.sizeDelta = Vector2(self.scrollViewRectTra.sizeDelta.x, self.maxScrollViewHeight)
    --else
        --self.scrollViewRectTra.sizeDelta = Vector2(self.scrollViewRectTra.sizeDelta.x, self.minScrollViewHeight)
    --end

    local y = srollViewY + self.addValueTemp
    if y > self.maxViewHeight then
        y = self.maxViewHeight
    end
    self.viewRectTra.sizeDelta = Vector2(self.viewRectTra.sizeDelta.x, y)
    self.bgRectTra.sizeDelta = self.viewRectTra.sizeDelta
end

function BaseGoodsTip:InitData()
    --self.model = GoodsModel:GetInstance()
    self.goodsItem = nil
    self.btnWidth = 0
    self.maxScrollViewHeight = 371
    self.maxViewHeight = 550
    self.minScrollViewHeight = 60
    --self.maxViewHeight = 535
    self.addValueTemp = 140
    self.scrollViewRectTra = nil
    --self.attContainRectTra = nil
    self.bgRectTra = nil
    self.viewRectTra = nil
    self.parentRectTra = nil
    self.events = {}
    self.iconStor = nil
    self.need_load_end = nil
    self.click_bg_close = true
    self.atts = {}
    self.btnSettors = {}        -- 操作，比如出售之类的
    self.jumpSettors = {}

    self.height = 0
end

--param包含参数
--item_id item配置表的id
--cfg  该物品(装备)的配置(比较神兽装备配置，人物装备配置),不一定是itemConfig
--p_item 服务器给的，服务器没给，只传cfg就好
--model 管理该tip数据的实例
--operate_param --操作参数
function BaseGoodsTip:ShowTip(param)
    self.cfg = param["cfg"]

    if param["item_id"] ~= nil then
        self.item_cfg = Config.db_item[param["item_id"]]

        if self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
            self.cfg = Config.db_equip[param["item_id"]]
        elseif self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BEAST then
            self.cfg = Config.db_beast_equip[param["item_id"]]
        else
            self.cfg = self.cfg or Config.db_item[param["item_id"]]
        end
    end

    self.item_cfg = Config.db_item[self.cfg.id]
    self.goods_item = param["p_item"]
    self.operate_param = param["operate_param"]
    self.model = param["model"]
    self.uid = self.goods_item ~= nil and self.goods_item.uid or nil
    self.item_id = self.item_cfg.id

    self.reddot_tab = param["reddot_tab"]  --操作按钮红点状态表
    if type(self.operate_param) then
        self:AddOperateBtns()
    end
    self:UpdateOpretionBtnReddot()

    self:SetQualityBg(self.item_cfg.color)
    self:SetName(self.item_cfg.name, self.item_cfg.color)
    self:SetIcon(self.cfg.id, param["p_item"], param["bind"])

    SetVisible(self.btnContain.gameObject, false)
    self:DealCreateAttEnd()
    SetLocalPositionZ(self.transform, 0)
    SetAnchoredPosition(self.transform, 0, 0)
end

function BaseGoodsTip:SetQualityBg(quality)
    local qualityImg = self.q_bg:GetComponent('Image')
    lua_resMgr:SetImageTexture(self, qualityImg, "equip_image", "equip_q_bg_" .. quality, true)
end

function BaseGoodsTip:SetName(name, quality)
    local suite_name = ""
    local cast_name = ""
    if self.goods_item then
        if not table.isempty(self.goods_item.equip.suite) then
            local suite_id = next(self.goods_item.equip.suite)
            local suitecfg = EquipSuitModel:GetInstance():GetEquipSuite(suite_id)
            suite_name = string.format("[%s]", Config.db_equip_suite_level[suitecfg.level].name)
        end
        if self.goods_item.equip.cast > 0 then
            local key = string.format("%s@%s", Config.db_equip[self.item_id].slot, self.goods_item.equip.cast)
            cast_name = string.format("%s·", Config.db_equip_cast[key].name)
        end
    end
    self.nameTxt:GetComponent('Text').text = suite_name .. cast_name .. name
end

function BaseGoodsTip:SetDes(des)
    if des ~= "\n" and not string.isempty(des) then
        self.valueTempTxt.text = des

        local att = { title = ConfigLanguage.Goods.Des, info = des, posY = self.height, itemHeight = self.valueTempTxt.preferredHeight + 25 + 20 }
        self.atts[#self.atts + 1] = GoodsAttrItemSettor(self.Content)
        self.atts[#self.atts]:UpdatInfo(att)

        self.height = self.height + self.valueTempTxt.preferredHeight + 25 + 20
    end
end

--跳转
function BaseGoodsTip:SetJump(jump, icon)
    if not string.isempty(jump) and jump ~= "{}" then
        local height = 110
        self.jumpItemSettor = GoodsJumpItemSettor(self.Content)
        self.jumpItemSettor:CreateJumpItems(jump, self.height, icon)

        self.height = self.height + height
    end
end

function BaseGoodsTip:SetIcon(itemId, p_item, bind)
    local param = {}
    param["model"] = BagModel.GetInstance()
    param["item_id"] = itemId
    param["size"] = { x = 72, y = 72 }
    param["p_item"] = p_item
    param["bind"] = bind

    if self.iconStor == nil then
        self.iconStor = GoodsIconSettorTwo(self.icon)
    end

    self.iconStor:SetIcon(param)

    --GoodIconUtil.Instance:CreateIcon(self, self.icon:GetComponent('Image'), icon, true)
    --SetVisible(self.icon.gameObject, true)
end

--设置位置 在子类中调用
function BaseGoodsTip:SetViewPosition()
    local localScale = GetLocalScale(self.transform)
    local parentWidth = 0
    local parentHeight = 0
    local spanX = 0
    local spanY = 0

    local pos = self.parent_node.position

    if self.parentRectTra.anchorMin.x == 0.5 then
        --spanX = 10
        parentWidth = self.parentRectTra.sizeDelta.x / 2 * localScale
        parentHeight = self.parentRectTra.sizeDelta.y / 2 * localScale

        pos.x = pos.x + parentWidth * 0.008
        pos.y = pos.y + parentHeight * 0.01
    else
        parentWidth = self.parentRectTra.sizeDelta.x
        parentHeight = self.parentRectTra.sizeDelta.y
    end

    --local parentRectTra = self.parent_node:GetComponent('RectTransform')

    local x = ScreenWidth / 2 + pos.x * 100 + parentWidth
    local y = pos.y * 100 - ScreenHeight / 2 - parentHeight
    local UITransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.UI)
    self.transform:SetParent(UITransform)
    SetLocalScale(self.transform, 1, 1, 1)


    --判断是否超出右边界
    if ScreenWidth - (x + parentWidth + self.viewRectTra.sizeDelta.x) < self.btnWidth + 10 then
        --spanX = ScreenWidth - (x + self.viewRectTra.sizeDelta.x + self.btnWidth)
        if self.parentRectTra.anchorMin.x == 0.5 then
            x = ScreenWidth - self.viewRectTra.sizeDelta.x - parentWidth * 2 - self.btnWidth - 20
        else
            x = ScreenWidth - parentWidth - self.viewRectTra.sizeDelta.x - self.btnWidth - 40
        end
    end

    if x < 100 then
        x = 100
    end

    if ScreenHeight + y - self.viewRectTra.sizeDelta.y < 10 then
        spanY = ScreenHeight + y - self.viewRectTra.sizeDelta.y - 10
    end

    self.viewRectTra.anchoredPosition = Vector2(x + spanX, y - spanY)
end

--刷新操作按钮红点
function BaseGoodsTip:UpdateOpretionBtnReddot()
    if not self.reddot_tab then
        return
    end

    for i,v in ipairs(self.btnSettors) do
        if self.reddot_tab[v.btnName] ~= nil then
            --需要修改这个按钮的红点状态
            v:UpdateReddot(self.reddot_tab[v.btnName])
        end
    end
end




