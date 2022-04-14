--
-- @Author: chk
-- @Date:   2018-08-22 10:56:43

--设置背包装备的信息
BagEquipSettor = BagEquipSettor or class("BagEquipSettor", BaseBagGoodsSettor)
local BagEquipSettor = BagEquipSettor

BagEquipSettor.__cache_count=50
function BagEquipSettor:ctor(parent_node, layer)

    self.abName = "system"
    self.assetName = "EquipItem"
    self.layer = layer

    self.role_update_list = {}
    self.stepLbl = nil
    BagEquipSettor.super.Load(self)
end

function BagEquipSettor:dctor()

    if self.role_update_list then
        for _, event_id in pairs(self.role_update_list) do
            RoleInfoModel.GetInstance():GetMainRoleData():RemoveListener(event_id)
        end
        self.role_update_list = nil
    end


end

function BagEquipSettor:LoadCallBack()
    self.nodes = {
        "upPowerTip",
        "downPowerTip",
        "notCantPutPutOn",
        "stepTxt",
    }

    self:GetChildren(self.nodes)
    self.stepLbl = self.stepTxt:GetComponent('Text')

    BagEquipSettor.super.LoadCallBack(self)

end

function BagEquipSettor:AddEvent()
    BagEquipSettor.super.AddEvent(self)

    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(EquipEvent.PutOnEquipSucess, handler(self, self.DealPutOnEquipSucess))

    if self.bag == BagModel.bagId then
        local function call_back()

            if self.model:GetEquipCanPutOn(self.cfg.id) and not self.model:IsExpire(self.outTime) then
                SetVisible(self.notCantPutPutOn.gameObject, false)
            else
                SetVisible(self.notCantPutPutOn.gameObject, true)
            end
        end

        self.role_update_list[#self.role_update_list + 1] = RoleInfoModel:GetInstance():GetMainRoleData():BindData("wake", call_back)
    end
end


--function BagEquipSettor:ClickEvent( )
--	BagEquipSettor.super.ClickEvent(self)
--
--	--GoodsController.GetInstance():RequestItemInfo(self.bag,self.uid)
--end

function BagEquipSettor:DealPutOnEquipSucess()
    self:UpdateFightPowerTip()
end

function BagEquipSettor:SetData(data)

end

--param  p_item
function BagEquipSettor:UpdateInfo(param)
    BagEquipSettor.super.UpdateInfo(self, param)

    if self.is_loaded then
        --local equipConfig = Config.db_equip[self.id]
        self:UpdateNum(param.bag, param.uid, nil)
        self:UpdateStar(param.bag, self.cfg.star or 0)
        self:UpdateFightPowerTip()
        self:UpdateStep(param);

        self:UpdateSize(param.cellSize);
    end
end

function BagEquipSettor:UpdateInfoNoClick(param)
    self:UpdateInfo(param)

    RemoveClickEvent(self.touch.gameObject)
end
--更新战力上升下降提示
function BagEquipSettor:UpdateFightPowerTip()
    local item = self.model:GetItemByUid(self.uid)
    --local roleData = RoleInfoModel.GetInstance():GetMainRoleData()
    local equipConfig = self.cfg
    local up = 1
    local putOnedEquip = self.model:GetPutOn(self.cfg.id)
    if item ~= nil and putOnedEquip ~= nil then
        if putOnedEquip.score < item.score then
            up = 1
        elseif putOnedEquip.score > item.score then
            up = -1
        else
            up = 0
        end
    end

    if up == 1 then
        SetVisible(self.upPowerTip, true)
        SetVisible(self.downPowerTip, false)

    elseif up == -1 then
        SetVisible(self.upPowerTip, false)
        SetVisible(self.downPowerTip, true)
    else
        SetVisible(self.upPowerTip, false)
        SetVisible(self.downPowerTip, false)
    end


    --local careers = string.split(equipConfig.career or "",",")
    --local canPutOn = false
    --for i, v in pairs(careers) do
    --	if tonumber(v) == roleData.career then
    --		canPutOn = true
    --		break
    --	end
    --end


    if self.model:GetEquipCanPutOn(self.cfg.id) and not self.model:IsExpire(self.outTime) then
        SetVisible(self.notCantPutPutOn, false)
    else
        SetVisible(self.notCantPutPutOn, true)
        SetVisible(self.upPowerTip, false)
        SetVisible(self.downPowerTip, false)
    end
end

function BagEquipSettor:UpdateStep(param)
    if param.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BEAST or param.type == enum.ITEM_TYPE.ITEM_TYPE_TOTEMS_EQUIP then
        if param["itemBase"] then
            if param["itemBase"].extra > 1 then
                self:UpdateBeastStep(self.uid, "+" .. param["itemBase"].extra);
            else
                self:UpdateBeastStep(self.uid, "");
            end
        elseif param["get_item_cb"] and param["uid"] then
            local sitem = param["get_item_cb"](param["uid"])
            if sitem and type(sitem) == "table"  then
                if sitem.extra > 1 then
                    self:UpdateBeastStep(self.uid, "+" .. sitem.extra)
                else
                    self:UpdateBeastStep(self.uid, "");
                end
            else
                self:UpdateBeastStep(self.uid, "");
            end
            --elseif param["get_item_cb"] and param["itemBase"] then
            --    self:UpdateBeastStep(self.uid, "+" .. param["itemBase"].extra)
        else
            self:UpdateBeastStep(self.uid, "");
        end

    else
        self:UpdateNormalStep(self.uid, param.stype ~= enum.ITEM_STYPE.ITEM_STYPE_FAIRY and self.cfg.order or 0)
    end
end

function BagEquipSettor:UpdateNormalStep(uid, step)
    if self.uid == uid then
        if step == 0 then
            self.stepLbl.text = ""
        else
            self.stepLbl.text = "T"..tostring(step)
        end

    end
end

function BagEquipSettor:UpdateBeastStep(uid, str)
    if self.uid == uid then
        self.stepLbl.text = str
    end
end

function BagEquipSettor:UpdateStar(bagId, star)
    if self.bag ~= bagId then
        return
    end

    local startCount = self.starContain.childCount
    for i = 0, startCount - 1 do
        if i < star then
            SetVisible(self.starContain:GetChild(tostring(i)), true)
        else
            SetVisible(self.starContain:GetChild(tostring(i)), false)
        end

    end
end

function BagEquipSettor:UpdateSize(size)
    if not size then
        return
    end
    local w = (type(size) == "table" and size.x or size)
    SetSizeDelta(self.transform, w, w)
end