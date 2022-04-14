--
-- @Author: LaoY
-- @Date:   2018-09-20 11:35:34
--
AwardItem = AwardItem or class("AwardItem", BaseWidget)
local this = AwardItem

function AwardItem:ctor(parent_node, builtin_layer)
    self.abName = "system"
    self.assetName = "AwardItem"

    AwardItem.super.Load(self)
end

function AwardItem:dctor()

end

function AwardItem:LoadCallBack()
    self.nodes = {
        "bg", "icon", "touch", "num", "selectedFrame", "text_bg", "starContain", "step", "canuse",
    }
    self:GetChildren(self.nodes)
    self.selectedFrame.gameObject:SetActive(false);
    local rectTra = self.gameObject:GetComponent('RectTransform')
    rectTra.anchoredPosition = Vector2(0, 0)

    self.canuse = GetText(self.canuse);
    SetGameObjectActive(self.canuse.gameObject, false);
    self.canuselocalPos = self.canuse.transform.localPosition;
    self:AddEvent()

    if self.lcallback then
        self.lcallback();
        self.lcallback = nil;
    end
end

function AwardItem:AddLoadCallBack(call_back)
    self.lcallback = call_back;
end

function AwardItem:AddEvent()

end

function AwardItem:SetConfig(vo)
    local vo_type = type(vo)
    if vo_type == "string" then
        vo = String2Table(vo)
    elseif vo_type ~= "table" then
        vo = { vo }
    end
    self:SetData(vo[1], vo[2])
end

function AwardItem:SetNeedData(itemId, need)

    self:RefreshItem(itemId)
    local num = BagModel:GetInstance():GetItemNumByItemID(itemId)

    if (num >= need) then
        self:SetNumText(string.format("<color=#00ff00>%s/%s</color>", GetShowNumber(num), GetShowNumber(need)))
    else
        self:SetNumText(string.format("<color=#ff0000>%s/%s</color>", GetShowNumber(num), GetShowNumber(need)))
    end
end

function AwardItem:SetData(db_id, number)
    self:RefreshItem(db_id)
    self:RefreshItemNum(number)
end

function AwardItem:RefreshItem(db_id)
    db_id = RoleInfoModel:GetInstance():GetItemId(db_id)
    self.db_id = db_id

    local config = Config.db_item[db_id]
    self.config = config
    if not self.config then
        return
    end

    self:UpdateIconImage(self.config.icon)
    self:UpdateQuality(self.config.color)

    local equipCfg = Config.db_equip[db_id]
    if equipCfg ~= nil then
        self:UpdateStar(equipCfg.star)
        self:UpdateStep(equipCfg.order)
    end

    RemoveClickEvent(self.touch.gameObject)
    if config.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then

    else

    end

    -- local function call_back()
    -- 	if itemConfig.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
    -- 		self.equipDetailView = EquipDetailViewOnly(self.parent_node)
    -- 	elseif itemConfig.type == enum.ITEM_TYPE.ITEM_TYPE_STONE then
    -- 		self.stoneDetailView = StoneDetailViewOnly(self.parent_node)
    -- 	else
    -- 		self.goodsDetailView = GoodsDetailViewOnly(self.parent_node)
    -- 	end
    -- end
    -- AddClickEvent(self.touch.gameObject,call_back)
end

function AwardItem:RefreshItemNum(number)
    self.number = number or 1
    if self.config.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP or self.config.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BEAST then
        self.number = ""
    end
    self:UpdateNum(self.number)
end

function AwardItem:ShowTips(parentNode)
    local itemConfig = Config.db_item[self.db_id]

    local puton_item = nil
    if itemConfig.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
        puton_item = BagModel.Instance:GetPutOn(self.db_id)
        if puton_item ~= nil then

            --_param
            --self_item 在背包的装备item
            --self_cfg 第1个参数的配置信息
            --puton_item 上身穿戴的装备item
            --puton_cfg 第3个参数的配置表信息
            --operate_param 操作参数
            --model 管理数据的model

            local _param = {}
            _param["self_cfg"] = BagModel.GetInstance():GetConfig(self.db_id)
            _param["puton_item"] = puton_item
            _param["puton_cfg"] = BagModel.GetInstance():GetConfig(puton_item.id)
            --_param["operate_param"] = param[2]
            _param["model"] = BagModel.GetInstance()
            local panel = lua_panelMgr:GetPanelOrCreate(EquipComparePanel)
            panel:Open(_param, parentNode);

        else

            --_param包含参数
            --cfg  该物品(装备)的配置(比较神兽装备配置，人物装备配置),不一定是itemConfig
            --p_item 服务器给的，服务器没给，只传cfg就好
            --model 管理该tip数据的实例
            --operate_param --操作参数

            local _param = {}
            _param["cfg"] = BagModel.GetInstance():GetConfig(self.db_id)
            --_param["p_item"] = item
            _param["model"] = BagModel.GetInstance()
            --_param["operate_param"] = self.operate_param

            self.equipDetailView = EquipTipView(parentNode or self.transform)
            self.equipDetailView:ShowTip(_param)
            if self.equipDetailView.transform and parentNode then
                SetParent(self.equipDetailView.transform, parentNode);
            end

        end
    else
        local _param = {}
        _param["cfg"] = Config.db_item[self.db_id]
        --_param["operate_param"] = param[2]
        self.goodsDetailView = GoodsTipView(parentNode or self.transform)
        self.goodsDetailView:ShowTip(_param)
        if self.goodsDetailView.transform and parentNode then
            SetParent(self.goodsDetailView.transform, parentNode);
        end

    end
end

function AwardItem:AddClickTips(parentNode)
    RemoveClickEvent(self.touch.gameObject);
    local call_back = function()
        self:ShowTips(parentNode)
    end
    AddButtonEvent(self.touch.gameObject, call_back)
end

function AwardItem:UpdateStep(step)
    self.step:GetComponent('Text').text = step .. "j"
end

function AwardItem:UpdateStar(star)
    SetVisible(self.starContain, true)
    local startCount = self.starContain.childCount
    for i = 0, startCount - 1 do
        if i < star then
            SetVisible(self.starContain:GetChild(i), true)
        else
            SetVisible(self.starContain:GetChild(i), false)
        end
    end
end

function AwardItem:UpdateIconImage(icon)
    icon = icon or self.config.icon
    local abName = GoodIconUtil.GetInstance():GetABNameById(icon)
    if abName == self.abName and icon == self.iconName then
        return
    end
    local iconImg = self.icon:GetComponent('Image')

    self.abName = abName
    self.iconName = icon
    abName = "iconasset/" .. abName
    --local call_back = function()
    --    --self:SetIconGray(self.isGray);
    --    self.isGray = nil;
    --end
    lua_resMgr:SetImageTexture(self, iconImg, abName, tostring(icon), true)
end

--更新品质
function AwardItem:UpdateQuality(quality)
    if quality == self.quality then
        return
    end
    self.quality = quality
    local qualityImg = self.bg:GetComponent('Image')
    lua_resMgr:SetImageTexture(self, qualityImg, "common_image", "com_icon_bg_" .. quality, true)
end

function AwardItem:UpdateNum(num)
    if num ~= "" and num > 0 then
        num = GetShowNumber(num);
        self.num:GetComponent('Text').text = num
    else
        self.num:GetComponent('Text').text = "";
    end
    --local str = num > 1 and tostring(num) or ""

    --if string.isempty(str) then
    --    self.text_bg.gameObject:SetActive(false);
    --else
    --    self.text_bg.gameObject:SetActive(true);
    --end
end

function AwardItem:UpdateNum0(num)
    if num > 0 then
        num = GetShowNumber(num);
        self.num:GetComponent('Text').text = num
    else
        self.num:GetComponent('Text').text = "0"
    end
end

function AwardItem:ShowTextBg(bool)
    bool = toBool(bool);
    self.text_bg.gameObject:SetActive(bool);
end

function AwardItem:SetNumText(str)
    self.num:GetComponent('Text').text = str;
end
function AwardItem:SetTextColor(color)
    self.num:GetComponent('Text').color = color;
end

function AwardItem:SetIsSelected(bool)
    bool = bool or false;
    if self.selectedFrame then
        self.selectedFrame.gameObject:SetActive(bool);
    end
end
function AwardItem:GetIsSelected()
    if self.selectedFrame then
        return self.selectedFrame.gameObject.activeSelf;
    end
    return false;
end

function AwardItem:GetConfig()
    if self.config then
        return self.config
    end
end

function AwardItem:ShowCanUse(num)
    self.iscanusenum = num;
    self.canuse.text = "u" .. num;
    SetGameObjectActive(self.canuse.transform, true);
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.canuse.transform)
    --self.canuse.transform.localPosition = Vector3();
    local localPos = self.canuselocalPos;--self.canuse.transform.localPosition;

    local moveAction = cc.MoveTo(0.5, localPos.x, localPos.y - 3, localPos.z)
    local moveAction1 = cc.MoveTo(0.5, localPos.x, localPos.y + 3, localPos.z)
    local action = cc.Sequence(moveAction, moveAction1)
    local action2 = cc.RepeatForever(action)
    cc.ActionManager:GetInstance():addAction(action2, self.canuse.transform);
end

function AwardItem:HideCanUse()
    self.iscanusenum = nil;
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.canuse.transform);
    SetGameObjectActive(self.canuse.transform, false);
end

function AwardItem:SetIconGray(bool)
    local iconImg = GetImage(self.icon.gameObject);
    local qualityImg = self.bg:GetComponent('Image')
    if iconImg then
        if toBool(bool) then
            ShaderManager:GetInstance():SetImageGray(iconImg);
        else
            ShaderManager:GetInstance():SetImageNormal(iconImg);
        end
    end
    if qualityImg then
        if toBool(bool) then
            ShaderManager:GetInstance():SetImageGray(qualityImg);
        else
            ShaderManager:GetInstance():SetImageNormal(qualityImg);
        end
    end
end