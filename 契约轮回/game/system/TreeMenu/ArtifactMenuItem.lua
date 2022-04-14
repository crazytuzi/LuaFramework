ArtifactMenuItem = ArtifactMenuItem or class("ArtifactMenuItem",BaseTreeOneMenu)
local GodMenuItem = ArtifactMenuItem

function ArtifactMenuItem:ctor(parent_node,layer,parent_cls_name,twoLvMenuCls)
    self.abName = "system"
    self.assetName = "ArtifactMenuItem"
    self.layer = layer
    --self.model = 2222222222222end:GetInstance()

    --self.twoLvMenuCls = BabyMenuSubItem
    --self.parent_cls_name = self.first_menu_item.parent_cls_name
    ArtifactMenuItem.super.Load(self)
end

function ArtifactMenuItem:dctor()
    if self.redPoint then
        self.redPoint:destroy()
    end
    self.redPoint = nil
end


function ArtifactMenuItem:LoadCallBack()
    self.nodes = {
        "redParent"
    }
    self:GetChildren(self.nodes)
    ArtifactMenuItem.super.LoadCallBack(self)
    self.ImageImg = GetImage(self.Image)
    self.sel_img_img = GetImage(self.sel_img)
    self.redPoint = RedDot(self.redParent, nil, RedDot.RedDotType.Nor)
    self.redPoint:SetPosition(-5, 14)
    if self.is_need_setData then
        lua_resMgr:SetImageTexture(self, self.ImageImg, "iconasset/icon_artifact", "artifact_t_"..self.data[1])
     --   lua_resMgr:SetImageTexture(self, self.sel_img_img, "system_image", "god_btn"..self.data[1])
    end
end


function ArtifactMenuItem:ReLayout()
    self.Content.sizeDelta = Vector2(0, self.menuHeight)
    self.Content.anchoredPosition = Vector2(0, 0 - 94)
end

function ArtifactMenuItem:LoadChildMenu()
    local typeId = self.data[1]
    for _, menuitem in pairs(self.menuitem_list) do
        menuitem:destroy()
    end
    self.menuitem_list = {}
    local subtypes = self.sub_data
    local count = #subtypes
    self.menuHeight = 0
    for i = 1, count do
        local item = subtypes[i]
        local menuitem = self.twoLvMenuCls(self.Content, nil, self)
        menuitem:SetData(typeId, item, self.select_sub_id, self.twoLvMenuSpan, i)
        table.insert(self.menuitem_list, menuitem)
        self.menuHeight = self.menuHeight + menuitem:GetHeight()
    end
    self.oldMenuHeight = self.menuHeight
    self:ReLayout()
end
function ArtifactMenuItem:SetRedPoint()
    local mType = self.data[1]
    local redPoints = ArtifactModel:GetInstance().equipRedPoints
    local upRedPoints = ArtifactModel:GetInstance().upRedPoints
    local flRedPoints = ArtifactModel:GetInstance().flRedPoints
    --logError(type,"tupe")
    --logError(Table2String(self.menuitem_list))
    local isRed = false
    for type, ids in pairs(redPoints) do
        if type == mType then
            for id, reds in pairs(ids) do
                if upRedPoints[type][id] == true then
                    isRed = true
                    break
                end
                if flRedPoints[type][id] == true then
                    isRed = true
                    break
                end
                for _, v in pairs(reds) do
                    if v == true then
                        isRed = true
                        break
                    end
                end
                --if upRedPoints[type][id] == true then
                --    isRed = true
                --end
            end
        end
    end
    self.redPoint:SetRedDotParam(isRed)
end

function ArtifactMenuItem:SetData(data, index, sub_data, select_sub_id, oneLvMenuSpan, twoLvMenuSpan)
    GodMenuItem.super.SetData(self,data, index, sub_data, select_sub_id, oneLvMenuSpan, twoLvMenuSpan)
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end
    lua_resMgr:SetImageTexture(self, self.ImageImg, "iconasset/icon_artifact", "artifact_t_"..self.data[1])
    self:UpdateArtInfo()
end

function ArtifactMenuItem:UpdateArtInfo()
    local isLock = ArtifactModel:GetInstance():IsArtiLock(self.data[1])
    if not isLock then
        self.MenuText:GetComponent('Text').text = self.data[2]
        ShaderManager:GetInstance():SetImageNormal(self.ImageImg);
    else
        self.MenuText:GetComponent('Text').text = ArtifactModel.desTab.unLock
        ShaderManager:GetInstance():SetImageGray(self.ImageImg);
    end
end

function ArtifactMenuItem:SelectedItem(index)
    if not self.selected then
        for _, menuitem in pairs(self.menuitem_list) do
            if menuitem then
                menuitem:destroy()
                menuitem = nil
            end
        end
        self.menuitem_list = {}
        local typeId = self.data[1]
        self.menuHeight = 0
        local subtypes = self.sub_data
        local count = #subtypes
        for i = 1, count do
            local item = subtypes[i]
            local menuitem = self.twoLvMenuCls(self.Content, nil, self)
            menuitem:SetData(typeId, item, nil, nil, i)
            table.insert(self.menuitem_list, menuitem)
            self.menuHeight = self.menuHeight + menuitem:GetHeight() + 10
        end
        self.oldMenuHeight = self.menuHeight
        self:ReLayout()
        --是不是感觉不太对,帮我改一下嘛
        if index and self.menuitem_list and self.menuitem_list[index] then
            self.menuitem_list[index]:Select(self.menuitem_list[index].data[1]);
        end
    end
    GlobalEvent:Brocast(CombineEvent.LeftFirstMenuClick .. self.parent_cls_name, self.index, self.selected)
end


