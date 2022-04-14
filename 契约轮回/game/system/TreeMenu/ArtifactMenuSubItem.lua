ArtifactMenuSubItem = ArtifactMenuSubItem or class("ArtifactMenuSubItem",BaseTreeTwoMenu)
local ArtifactMenuSubItem = ArtifactMenuSubItem

function ArtifactMenuSubItem:ctor(parent_node,layer,first_menu_item)
    self.abName = "system"
    self.assetName = "ArtifactMenuSubItem"
    --self.layer = layer
    self.index = 1
    self.events = {}
    self.layer = layer
    self.first_menu_item = first_menu_item
    ArtifactMenuSubItem.super.Load(self)
end

function ArtifactMenuSubItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.redPoint then
        self.redPoint:destroy()
        self.redPoint = nil
    end
end

function ArtifactMenuSubItem:LoadCallBack()
    self.nodes = {
        "redParent",
    }
    self:GetChildren(self.nodes)
    ArtifactMenuSubItem.super.LoadCallBack(self)
    self.ImageImg = GetImage(self.Image)
    self.redPoint = RedDot(self.redParent, nil, RedDot.RedDotType.Nor)
    self.redPoint:SetPosition(-11, 0)
    if self.is_need_setData then
        lua_resMgr:SetImageTexture(self, self.ImageImg, "iconasset/icon_artifact", tostring(self.data[1]))
        --   lua_resMgr:SetImageTexture(self, self.sel_img_img, "system_image", "god_btn"..self.data[1])
    end
end
--
function ArtifactMenuSubItem:AddEvent()
    ArtifactMenuSubItem.super.AddEvent(self)

    --self.events[#self.events + 1]  = GlobalEvent:AddListener(MountEvent.MORPH_UPSTAR_DATA,handler(self,self.HandleUpStarData))
    --self.events[#self.events + 1]  = GlobalEvent:AddListener(MountEvent.MOUNT_CHANGE_FIGURE,handler(self,self.HandleChangeFigure))
end
--
function ArtifactMenuSubItem:SetData(first_menu_id,data, select_sub_id,menuSpan, index)
    ArtifactMenuSubItem.super.SetData(self,first_menu_id,data, select_sub_id,menuSpan)
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end
    lua_resMgr:SetImageTexture(self, self.ImageImg, "iconasset/icon_artifact", tostring(self.data[1]))
    --self.group = first_menu_id
    --self.godId = data[1]
    --self.figureId = MountModel:GetInstance().pb_data[enum.TRAIN.TRAIN_GOD].used_id
    --self:UpdateInfo()
    self:SetRedPoint()
end


function ArtifactMenuSubItem:SetRedPoint()
    local redPoints = ArtifactModel:GetInstance().equipRedPoints
    local upRedPoints = ArtifactModel:GetInstance().upRedPoints
    local flRedPoints = ArtifactModel:GetInstance().flRedPoints
    local artId = self.data[1]

    local isRed = false
    for type, ids in pairs(redPoints) do
        for id, reds in pairs(ids) do
            if id == artId then
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
            end
        end
    end
    self.redPoint:SetRedDotParam(isRed)
end


