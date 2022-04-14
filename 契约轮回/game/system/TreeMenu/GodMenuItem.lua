GodMenuItem = GodMenuItem or class("GodMenuItem",BaseTreeOneMenu)
local GodMenuItem = GodMenuItem

function GodMenuItem:ctor(parent_node,layer,parent_cls_name,twoLvMenuCls)
    self.abName = "system"
    self.assetName = "GodMenuItem"
    self.layer = layer
    --self.model = 2222222222222end:GetInstance()

    --self.twoLvMenuCls = BabyMenuSubItem
    --self.parent_cls_name = self.first_menu_item.parent_cls_name
    GodMenuItem.super.Load(self)
end

function GodMenuItem:dctor()
    if self.redPoint then
        self.redPoint:destroy()
    end
    self.redPoint = nil
end


function GodMenuItem:LoadCallBack()
    self.nodes = {
        "redParent"
    }
    self:GetChildren(self.nodes)
    GodMenuItem.super.LoadCallBack(self)
    self.ImageImg = GetImage(self.Image)
    self.sel_img_img = GetImage(self.sel_img)
    self.redPoint = RedDot(self.redParent, nil, RedDot.RedDotType.Nor)
    self.redPoint:SetPosition(0, 0)
    if self.is_need_setData then
        lua_resMgr:SetImageTexture(self, self.ImageImg, "system_image", "god_btn"..self.data[1])
        lua_resMgr:SetImageTexture(self, self.sel_img_img, "system_image", "god_btn"..self.data[1])
      --  lua_resMgr:SetImageTexture(self, self.ImageImg, "system_image", tostring(GodModel.ButtonName[self.data.id]), true, nil, false)
    end
   -- lua_resMgr:SetImageTexture(self, self.ImageImg, "system_image", tostring(GodModel.ButtonName[self.data.id]), true, nil, false)
end

function GodMenuItem:SetRedPoint()
    local color = self.data[1]
    local redPoints = GodModel:GetInstance().starRedPoints
    local isRed = false
    for id, reds in pairs(redPoints) do
        for i, v in pairs(reds) do
            if v == true and id == color then
                isRed = true
                break
            end
        end
    end
    self.redPoint:SetRedDotParam(isRed)
end

function GodMenuItem:SetData(data, index, sub_data, select_sub_id, oneLvMenuSpan, twoLvMenuSpan)
    GodMenuItem.super.SetData(self,data, index, sub_data, select_sub_id, oneLvMenuSpan, twoLvMenuSpan)
    local id = data[1]
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end
    if id ~= 6 then
        lua_resMgr:SetImageTexture(self, self.ImageImg, "system_image", "god_btn"..id)
        lua_resMgr:SetImageTexture(self, self.sel_img_img, "system_image", "god_btn"..id)
    end
   -- lua_resMgr:SetImageTexture(self, self.ImageImg, "system_image", "god_btn"..self.data[1])
   -- lua_resMgr:SetImageTexture(self, self.sel_img_img, "system_image", "god_btn"..self.data[1])
end


