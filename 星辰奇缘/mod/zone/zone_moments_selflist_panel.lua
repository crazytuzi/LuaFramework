-- 个人列表
-- @author hzf
-- @date 2016年7月29日,星期五

MomentsSelfListPanel = MomentsSelfListPanel or BaseClass()

function MomentsSelfListPanel:__init(go, Parent)
    self.Parent = Parent
    self.Mgr = ZoneManager.Instance
    self.gameObject = go
    self.ItemList = {}
    self.oldItemList = {}
    self.data = {}
    self.on_update_moments = function(data)
        self:OnMomentsChange(data)
    end
    self.on_update_comment = function(data)
        self:OnCommentUpdate(data)
    end
    self.on_update_like = function(data)
        self:OnLikeUpdate(data)
    end
    self:InitPanel()
end

function MomentsSelfListPanel:__delete()
    if self.ItemList ~= nil then
        for k,v in pairs(self.ItemList) do
            v:DeleteMe()
        end
    end
    self.ItemList = nil
    if self.oldItemList ~= nil then
        for k,v in pairs(self.oldItemList) do
            v:DeleteMe()
        end
    end
    self.oldItemList = nil
    self.Mgr.OnMomentsChange:RemoveListener(self.on_update_moments)
    self.Mgr.OnCommentsChange:RemoveListener(self.on_update_comment)
    self.Mgr.OnLikeChange:RemoveListener(self.on_update_like)
    -- self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    -- self:AssetClearAll()
end

function MomentsSelfListPanel:InitPanel()
    self.transform = self.gameObject.transform
    self.baseItem = self.transform:Find("Item").gameObject
    self.NomsgItem = self.transform:Find("Nomsg").gameObject
    self.baseItem:SetActive(false)
    self.Mgr.OnMomentsChange:AddListener(self.on_update_moments)
    self.Mgr.OnCommentsChange:AddListener(self.on_update_comment)
    self.Mgr.OnLikeChange:AddListener(self.on_update_like)
end

function MomentsSelfListPanel:RefreshData(data)
    if BaseUtils.isnull(self.baseItem) then
        return
    end
    -- BaseUtils.dump(data, "列表数据库咔咔咔咔咔")
    self.data = data
    self:ReCycle()
    table.sort(self.data.moments, function(a,b) return a.ctime > b.ctime end)
    local creatNum = 0
    for i,v in ipairs(self.data.moments) do
        local old = self:GetOldItem(v.m_id, v.m_platform, v.m_zone_id)
        if old == nil then
            local go = GameObject.Instantiate(self.baseItem)
            go:SetActive(true)
            go.transform:SetParent(self.transform)
            go.transform.localScale = Vector3.one
            local Item = ZoneMomentsSelfitem.New(self, go, v)
            Item:update_my_self(v)
            table.insert(self.ItemList, Item)
            creatNum = creatNum + 1
            if creatNum >= 30 then
                break
            end
        else
            table.insert(self.ItemList, old)
            old:update_my_self(v)
            if old.gameObject ~= nil then
                old.gameObject:SetActive(true)
            end
        end
    end
    self.NomsgItem:SetActive(#self.ItemList == 0)
    local H = 0
    for i,v in ipairs(self.ItemList) do
        v.transform.anchoredPosition = Vector2(0, -H)
        H = H + v.selfHeight
    end
    self.transform.sizeDelta = Vector2(508, H)
end

function MomentsSelfListPanel:GetItem(m_id, m_platform, m_zone_id)
    for i,v in ipairs(self.ItemList) do
        if v.data ~= nil and v.data.m_id == m_id and v.data.m_platform == m_platform and v.data.m_zone_id == m_zone_id then
            return v,i
        end
    end
    return nil
end

function MomentsSelfListPanel:ReLayout()
    table.sort(self.ItemList, function(a, b) return a.data.ctime > b.data.ctime end)
    local H = 0
    for i,v in ipairs(self.ItemList) do
        if not BaseUtils.isnull(v.transform) then
            v.transform.anchoredPosition = Vector2(0, -H)
            H = H + v.selfHeight+5
        end
    end
    self.transform.sizeDelta = Vector2(508, H)
end

function MomentsSelfListPanel:OnMomentsChange(data)
    if data.role_id == self.data.circle_id and data.platform == self.data.circle_platform and data.zone_id == self.data.circle_zone_id then
    else
        return
    end
    if data.type == 0 then
        local old = self:GetItem(data.m_id, data.m_platform, data.m_zone_id)
        if old ~= nil then
            old:update_my_self(data)
        else
            local go = GameObject.Instantiate(self.baseItem)
            go:SetActive(true)
            go.transform:SetParent(self.transform)
            go.transform.localScale = Vector3.one
            local Item = ZoneMomentsSelfitem.New(self, go, v)
            Item:update_my_self(data)
            table.insert(self.ItemList, Item)
        end
        self:ReLayout()
    else
        local old, index = self:GetItem(data.m_id, data.m_platform, data.m_zone_id)
        if old ~= nil then
            table.remove(self.ItemList, index)
            old:DeleteMe()
            self:ReLayout()
        end
    end
    self.NomsgItem:SetActive(#self.ItemList == 0)
end

function MomentsSelfListPanel:ShowOption(data, Position)
    self.Parent:ShowDetailOption(data, Position)
end

function MomentsSelfListPanel:OnCommentsOpt(data)
    self.Parent:OnCommentsOpt(data)
end

function MomentsSelfListPanel:OnCommentUpdate(data)
    if data.type == 0 then
        local old = self:GetItem(data.m_id, data.m_platform, data.m_zone_id)
        if old ~= nil then
            local ii = nil
            for i,v in ipairs(old.data.friend_comment) do
                if v.id == data.id then
                    ii = i
                end
            end
            if ii ~= nil then
                old.data.friend_comment[ii] = data
            else
                table.insert(old.data.friend_comment, data)
            end
            old:update_my_self(old.data)
            self:ReLayout()
        end
    else
        local old, index = self:GetItem(data.m_id, data.m_platform, data.m_zone_id)
        if old ~= nil then
            local ii = nil
            for i,v in ipairs(old.data.friend_comment) do
                if v.id == data.id then
                    ii = i
                end
            end
            if ii ~= nil then
                table.remove(old.data.friend_comment, ii)
            end
            old:update_my_self(old.data)
            self:ReLayout()
        end
    end
end

function MomentsSelfListPanel:OnLikeUpdate(data)
    if data.type == 0 then
        local old = self:GetItem(data.m_id, data.m_platform, data.m_zone_id)
        if old ~= nil then
            local ii = nil
            for i,v in ipairs(old.data.likes) do
                if v.liker_id == data.role_id or v.role_id == data.role_id then
                    ii = i
                end
            end
            if ii == nil then
                table.insert(old.data.likes, data)
            end
            old:update_my_self(old.data)
            self:ReLayout()
        end
    else
        local old = self:GetItem(data.m_id, data.m_platform, data.m_zone_id)
        if old ~= nil then
            local ii = nil
            for i,v in ipairs(old.data.likes) do
                if v.liker_id == data.role_id or v.role_id == data.role_id then
                    ii = i
                end
            end
            if ii ~= nil then
                local last = old.data.likes
                table.remove(last, ii)
                old.data.likes = last
            end
            old:update_my_self(old.data)
            self:ReLayout()
        end
    end
end

function MomentsSelfListPanel:OpenPhotoPreview(data)
    self.Parent:OpenPhotoPreview(data)
end

function MomentsSelfListPanel:Hide()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
end

function MomentsSelfListPanel:Show()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
    end
end

function MomentsSelfListPanel:OnScroll(Top, Bot)
    for i,v in ipairs(self.ItemList) do
        local ay = v.transform.anchoredPosition.y
        local sy = v.transform.sizeDelta.y
        if ay - sy > Top or ay < Bot then
            v.gameObject:SetActive(false)
        else
            v.gameObject:SetActive(true)
        end
    end
end

function MomentsSelfListPanel:GetOldItem(m_id, m_platform, m_zone_id)
    local item = nil
    local index  = nil
    for i,v in ipairs(self.oldItemList) do
        if v.data ~= nil and v.data.m_id == m_id and v.data.m_platform == m_platform and v.data.m_zone_id == m_zone_id then
            item = v
            index = i
            break
        end
    end
    if index ~= nil then
        table.remove(self.oldItemList, index)
    end
    return item, index
end

function MomentsSelfListPanel:ReCycle()
    for i,v in ipairs(self.ItemList) do
        if v.gameObject ~= nil then
            v.gameObject:SetActive(false)
        end
        table.insert(self.oldItemList, v)
    end
    self.ItemList = {}
end