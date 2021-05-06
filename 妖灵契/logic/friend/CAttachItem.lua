local CAttachItem = class("CAttachItem", CBox)

function CAttachItem.ctor(self, obj)
    CBox.ctor(self, obj)
    
    self.m_ItemBG = self:NewUI(1, CSprite)
    self.m_HeadSprite = self:NewUI(2, CSprite)
    self.m_CountLabel = self:NewUI(3, CLabel)
    self.m_Type = nil
    self.m_Sid = nil
    self.m_Count = nil
    self.m_ItemBG:AddUIEvent("click", callback(self, "ItemCallBack"))
end

function CAttachItem.SetGroup(self, groupId)
    self.m_ItemBG:SetGroup(groupId)
end

function CAttachItem.SetBoxInfo(self, attach)
    self.m_Type = attach.type
    self.m_Sid = attach.sid
    self.m_Count = attach.val
    printc("CAttachItem.SetBoxInfo, type = " .. self.m_Type .. ", sid = " .. self.m_Sid .. ", count = " .. self.m_Count)

    -- 图标
    if self.m_Type == 1 then  -- 暂时只处理物品，以后会添加其它 type，如宠物
        local itemdata = DataTools.GetItemData(self.m_Sid)
        self.m_HeadSprite:SpriteItemShape(itemdata.icon)
    end

    -- 数量
    self.m_CountLabel:SetText(self.m_Count)
    if self.m_Count > 1 then
        self.m_CountLabel:SetActive(true)
    else
        self.m_CountLabel:SetActive(false)
    end
end

function CAttachItem.ItemCallBack(self)
    printc("CAttachItem.ItemCallBack, type = " .. self.m_Type .. ", sid = " .. self.m_Sid)
    if self.m_Type == 4 then
        g_NotifyCtrl:FloatMsg("这个是伙伴的附件")
        return
    end
    
    local args = {
        widget = self,
        side = enum.UIAnchor.Side.TopRight,
        offset = Vector2.New(-90, 10)
    }
    g_WindowTipCtrl:SetWindowItemTip(self.m_Sid, args)
end

return CAttachItem