--
-- @Author: LaoY
-- @Date:   2018-12-08 11:15:10
--
TurnTableItem = TurnTableItem or class("TurnTableItem", BaseCloneItem)
local TurnTableItem = TurnTableItem

function TurnTableItem:ctor(obj, parent_node, layer, is_hide_light)
    self.is_hide_light = is_hide_light
    TurnTableItem.super.Load(self)
end

function TurnTableItem:dctor()
    if self.goods_item then
        self.goods_item:destroy()
        self.goods_item = nil
    end
end

function TurnTableItem:LoadCallBack()
    self.nodes = {
        "con", "img_light", "img_have_get"
    }
    self:GetChildren(self.nodes)
    self.img_light_component = self.img_light:GetComponent('Image')
    SetVisible(self.img_light, not self.is_hide_light)
    self.img_have_get_component = self.img_have_get:GetComponent('Image')

    SetSizeDelta(self.con, 76, 76)
    self.goods_item = GoodsIconSettorTwo(self.con)
    --self.goods_item:SetPosition(-0,0)

    self:SetHaveGetVisible(false)

    self:SetLightVisible(false)

    self:AddEvent()
end

function TurnTableItem:AddEvent()
end

function TurnTableItem:SetRadius(len, radius, light_radius)
    self.len = len
    self.radius = radius
    self.light_radius = light_radius
end

function TurnTableItem:SetLightVisible(flag)
    self.light_visible = toBool(flag)
    if flag and self.is_hide_light then
        SetVisible(self.img_light, false)
    else
        SetVisible(self.img_light, flag)
    end
end

function TurnTableItem:SetRes(abName, assetName)
    if not self.light_radius then
        return
    end
    if self.abName == abName and self.assetName == assetName then
        return
    end
    self.abName = abName
    self.assetName = assetName
    local function call_back(sprite)
        self.img_light_component.sprite = sprite
        -- self.img_light_component:SetNativeSize()
        self:UpdateLight()
        self:SetLightVisible(self.light_visible)
    end
    lua_resMgr:SetImageTexture(self, self.img_light_component, abName, assetName, false, call_back)
end

-- function TurnTableItem:SetHaveGetRes(abName,assetName)
-- 	if self.have_get_abName == abName and self.have_get_assetName == assetName then
-- 		return
-- 	end
-- 	self.have_get_abName = abName
-- 	self.have_get_assetName = assetName
-- 	lua_resMgr:SetImageTexture(self,self.img_have_get_component, abName, assetName,true,nil,false)
-- end

function TurnTableItem:SetHaveGetVisible(flag)
    SetVisible(self.img_have_get, flag)
end

function TurnTableItem:UpdateLight()
    if not self.light_radius then
        return
    end
    local angle = GetTurnTableAngle(self.index, self.len)
    SetRotate(self.img_light, 0, 0, angle)

    local l_x, l_y = GetTurnTablePos(self.index, self.len, self.light_radius)
    local x, y = self:GetPosition()
    SetLocalPosition(self.img_light, l_x - x, l_y - y)
end

function TurnTableItem:SetData(index, data)
    self.index = index
    self.data = data
    -- self:UpdateLight()

    local param = {}
    param["model"] = BagModel.GetInstance()
    param["item_id"] = data[1]
    param["num"] = data[2]
    param["bind"] = data[3]
    param["can_click"] = true
    self.goods_item:SetIcon(param)
    --self.goods_item:UpdateIconByItemIdClick(data[1],data[2],76)
end