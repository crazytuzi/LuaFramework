GivepresentManager = GivepresentManager or BaseClass(BaseManager)
local product = {
{key = 21502,val = 1,weight = 100,classes = 1},
{key = 21500,val = 1,weight = 100,classes = 2},
{key = 21506,val = 1,weight = 100,classes = 3},
{key = 21508,val = 1,weight = 100,classes = 4},
{key = 21504,val = 1,weight = 100,classes = 5}}
function GivepresentManager:__init()
    if GivepresentManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    GivepresentManager.Instance = self
    self.model = GivePresentModule.New()
    self.playerList = {}
    self.BaseItemList = {}
    self.BaseGiftList = {}
    self.givehistoryList = {}
    self.diaowenList = {}
    self.listener = function()
        self.diaowenList = self:GetAllDiaowenList()
        self:LoadItemList()
        self:LoadGiftList()
        self:UpdateGiveHistory()
    end
    self:InitHandler()
    self.resList = {
        {file = "prefabs/effect/30068.unity3d", type = AssetType.Main},
    }
    self.MaxGiveNum = 5
end

function GivepresentManager:InitHandler()

    self:AddNetHandler(11841, self.On11841)
    self:AddNetHandler(11842, self.On11842)
    self:AddNetHandler(11843, self.On11843)
    self:AddNetHandler(11844, self.On11844)

    EventMgr.Instance:AddListener(event_name.self_loaded, self.listener)
    EventMgr.Instance:AddListener(event_name.role_level_change, function()
        self:LoadItemList()
        self:LoadGiftList()
        self:UpdateGiveHistory()
    end)
    EventMgr.Instance:AddListener(event_name.life_skill_update, self.listener)
end

--送物品
function GivepresentManager:Require11841(id, platform, zone_id, list)
    if not BaseUtils.IsTheSamePlatform(platform, zone_id) then
        NoticeManager.Instance:FloatTipsByString(TI18N("跨服暂不支持赠送道具"))
        return
    end
    local temp = {id = id, platform = platform, zone_id = zone_id, list = list }
    Connection.Instance:send(11841,  temp)
end

function GivepresentManager:On11841(data)
    BaseUtils.dump(data, "On11841")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        self.model:RefreshItemPanel()
        -- NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end
--送礼物
function GivepresentManager:Require11842(id, platform, zone_id, list, msg)
    -- if not BaseUtils.IsTheSamePlatform(platform, zone_id) then
    --     NoticeManager.Instance:FloatTipsByString("跨服暂不支持赠送礼物")
    --     return
    -- end
    if #list > 1 then
        for i,v in ipairs(list) do
            local item_msg = msg ~= nil and msg or self:GetMsg(v.base_id)
            Connection.Instance:send(11842, {id = id, platform = platform, zone_id = zone_id, list = {v}, msg = item_msg})
        end
    else
        local item_msg = msg ~= nil and msg or self:GetMsg(list[1].base_id)
        Connection.Instance:send(11842, {id = id, platform = platform, zone_id = zone_id, list = list, msg = item_msg})
    end
end

function GivepresentManager:On11842(data)
    BaseUtils.dump(data, "On11842")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        self.model:RefreshFriendShip()
    else
        -- NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end
--收到礼物（鲜花）
function GivepresentManager:Require11843()
    Connection.Instance:send(11843, {})
end

function GivepresentManager:On11843(data)
    BaseUtils.dump(data, "On11843")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.base_id == 20032 then
        self:Show999Effect()
    end
end

-- 礼物赠送记录
function GivepresentManager:Require11844()
    Connection.Instance:send(11844, {})
end

function GivepresentManager:On11844(data)
    -- BaseUtils.dump(data, "On11844")
    self.givehistoryList = {}
    for i,v in ipairs(data.list) do
        local uid = BaseUtils.Key( v.id,  v.platform, v.zone_id)
        if BaseUtils.isTheSameDay(v.time, BaseUtils.BASE_TIME) then
            self.givehistoryList[uid] = v
        else
            self.givehistoryList[uid] = nil
        end
    end

    self.model:RefreshItemNum()
end


-------------------------
function GivepresentManager:OpenGiveWin(data)
    if data == nil then
        data = {}
        -- self.model:OpenMainWin()
        -- return
    end
    self.targetData = data
    if self.targetData.id == nil then
        self.targetData.id = self.targetData.roleid
    end
    if self.targetData.zone_id == nil then
        self.targetData.zone_id = self.targetData.zoneid
    end
    self.playerList = {}
    -- self.playerList = FriendManager.Instance.online_friend_List
    local templist = {}
    for i,v in ipairs(FriendManager.Instance.online_friend_List) do
        table.insert(templist, v)
    end
    if data.platform ~= nil and FriendManager.Instance:IsFriend(data.id, data.platform, data.zone_id) then
        local index = nil
        for i,v in ipairs(templist) do
            if v.id == data.id and v.platform == data.platform and v.zone_id == data.zone_id then
                index = i
            end
        end
        local temp = templist[1]
        if temp ~= nil and index ~= nil then
            templist[1] = templist[index]
            templist[index] = temp
        else
            table.insert(templist, 1, self.targetData)
        end
    elseif data.platform ~= nil then
        self.targetData.online = 1
        table.insert(templist, 1, self.targetData)
    end
    self.playerList = templist
    self.model:OpenMainWin(data.index)
end
--更新送礼记录
function GivepresentManager:UpdateGiveHistory()
    self:Require11844()
end
--获取可送礼次数
function GivepresentManager:GetTimesOfGive(id, platform, zone_id)
    local num = 0
    local uid = BaseUtils.Key( id,  platform, zone_id)
    if self.givehistoryList[uid] ~= nil then
        num = self.givehistoryList[uid].num
    end
    return num
end

function GivepresentManager:LoadItemList()
    self.BaseItemList = {}
    local currid = SkillManager.Instance.model:get_diaowen_classes_produce()
    for i,v in ipairs(DataFriend.data_gift) do
        if v.item_id ~= currid and v.type == 0 then
            table.insert(self.BaseItemList, v.item_id)
        end
    end

end

function GivepresentManager:LoadGiftList()
    local temp = {}
    self.BaseGiftList = {}
    -- table.insert(temp, diaowenID)
    for i,v in ipairs(DataFriend.data_gift) do
        if i>51 and v.type == 1 then
            table.insert(temp, v.item_id)
        end
    end
    self.BaseGiftList = temp
end

function GivepresentManager:GetHasItemList()

    local diaowenID = 0
    local My_diaowenID = SkillManager.Instance.model:get_diaowen_classes_produce()
    local diaowennum = self:GetUnbindDiaowenCount()
    local templist = {}
    -- if diaowenID ~= nil then
        table.insert(templist, {base_id = diaowenID, num = diaowennum})
    -- end
    for i,v in ipairs(self.BaseItemList) do
        if v ~= My_diaowenID then
            local num = BackpackManager.Instance:GetUnbindItemCount(v)
            local mList = BackpackManager.Instance:GetUnbindItemByBaseid(v)
            -- BaseUtils.dump(mList, "数据")
            if #mList > 0 and mList[1].step > 0 then
                for i,v in ipairs(mList) do
                    table.insert(templist, {base_id = v.id, num = v.quantity, data = v})
                end
            else
                if num > 0 then
                    table.insert(templist, {base_id = v, num = num})
                end
            end
        end
    end
    return templist
end

function GivepresentManager:GetUnbindDiaowenCount()
    local hasdiaowenList = {}
    local count = 0
    for i,v in ipairs(self.diaowenList) do
        local num = BackpackManager.Instance:GetUnbindItemCount(v)
        table.insert(hasdiaowenList, {base_id = v, num = num})
        count = count + num
    end
    self.hasdiaowenList = hasdiaowenList
    return count
end

function GivepresentManager:GetAllDiaowenList()
    local diaowenList = {}
    local currid = SkillManager.Instance.model:get_diaowen_classes_produce()
    for i=1,12 do
        local data = DataSkillLife.data_diao_wen[string.format("10007_%s", tostring(i*10))]
        for ii,v in ipairs(data.product) do
            if v.classes == RoleManager.Instance.RoleData.classes and v.key == currid then
                table.insert(diaowenList, v.key)
            end
        end
    end
    return diaowenList
end

function GivepresentManager:GetHasGiftList()
    local templist = {}
    for i,v in ipairs(self.BaseGiftList) do
        local num = BackpackManager.Instance:GetUnbindItemCount(v)
        if num > 0 then
            table.insert(templist, {base_id = v, num = num})
        end
    end
    return templist
end

function GivepresentManager:SendItemToPlayer(id, platform, zone_id, list)
    if list == nil or next(list) == nil then
        return
    end
    local locallist = BaseUtils.copytab(list)
    local diaowenID = SkillManager.Instance.model:get_diaowen_classes_produce()
    local templist = {}
    for i, v in ipairs(locallist) do
        if v.base_id ~= 0 and v.data == nil then
            local clist = BackpackManager.Instance:GetUnbindItemByBaseid(v.base_id)
            local neednum = BaseUtils.copytab(v.num)
            local insertnum = 0
            -- BaseUtils.dump(clist,"ddddd物品列表")
            for _,item in ipairs(clist) do
                if item.quantity + insertnum > neednum and insertnum < neednum then
                    table.insert(templist,{id = item.id, num = neednum - insertnum})
                    insertnum = neednum
                elseif insertnum < neednum then
                    table.insert(templist,{id = item.id, num = item.quantity})
                    insertnum = insertnum + item.quantity
                end
            end
        elseif v.data ~= nil then
            table.insert(templist,{id = v.base_id, num = v.num})
        else
            -- local clist = BackpackManager.Instance:GetUnbindItemByBaseid(diaowenID)
            local clist = self:GetAllDiaowenList()
            local neednum = v.num
            local insertnum = 0
            for _,itemid in ipairs(clist) do
                local itemlist = BackpackManager.Instance:GetUnbindItemByBaseid(itemid)
                for _,item in ipairs(itemlist) do
                    if item.quantity + insertnum > neednum and insertnum < neednum then
                        table.insert(templist,{id = item.id, num = neednum - insertnum})
                        insertnum = neednum
                    elseif insertnum < neednum then
                        table.insert(templist,{id = item.id, num = item.quantity})
                        insertnum = insertnum + item.quantity
                    end
                end
            end


            if neednum > insertnum then
                local percost = SkillManager.Instance.model:get_diaowen_producing_cost()
                local maxenergy = RoleManager.Instance.RoleData.energy
                local needmake = neednum - insertnum
                for i=1, needmake do
                    SkillManager.Instance:Send10816(10007, diaowenID)
                end
                -- return self:SendItemToPlayer(id, platform, zone_id, list)
            end
        end
    end
    -- BaseUtils.dump(list,"决定的物品列表")
    -- BaseUtils.dump(templist,"发送的物品列表")
    self:Require11841(id, platform, zone_id, templist)
end

function GivepresentManager:Show999Effect()
    if self.assetWrapper == nil and self.EffectgameObject == nil then
        self.assetWrapper = AssetBatchWrapper.New()
    elseif self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
        Log.Error("[Error]assetWrapper不可以重复使用 at GivepresentManager")
    end
    -- BaseUtils.dump(resources)
    if self.EffectgameObject ~= nil then
        self:OnEffectLoaded()
    end
    if self.assetWrapper ~= nil then
        self.assetWrapper:LoadAssetBundle(self.resList, function () self:OnEffectLoaded() end)
    end
end

function GivepresentManager:OnEffectLoaded()
    if self.EffectgameObject == nil then
        local prefab = self.assetWrapper:GetMainAsset("prefabs/effect/30068.unity3d")
        self.EffectgameObject = GameObject.Instantiate(prefab)
    end
    local hideeffect = function()
        if self.EffectgameObject ~= nil then
            self.EffectgameObject.gameObject:SetActive(false)
        end
    end
    if self.timer == nil then
        -- UIUtils.AddUIChild(ctx.CanvasContainer, self.EffectgameObject)
        self.EffectgameObject.gameObject.transform:SetParent(ctx.CanvasContainer.transform)
        Utils.ChangeLayersRecursively(self.EffectgameObject.gameObject.transform, "UI")
        self.EffectgameObject.gameObject:SetActive(true)
        self.timer = LuaTimer.Add(10000, hideeffect)
    else
        LuaTimer.Delete(self.timer)
        self.timer = LuaTimer.Add(10000, hideeffect)
        -- UIUtils.AddUIChild(ctx.CanvasContainer, self.EffectgameObject)
        self.EffectgameObject.gameObject.transform:SetParent(ctx.CanvasContainer.transform)
        Utils.ChangeLayersRecursively(self.EffectgameObject.gameObject.transform, "UI")
        self.EffectgameObject.gameObject:SetActive(true)
    end
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
end

function GivepresentManager:GetMsg(id)
    for k,v in pairs(DataFriend.data_gift) do
        if v.item_id == id then
            if v.msg ~= "" then
                return v.msg
            end
        end
    end
    return TI18N("最美的花送给最美的你！")
end

function GivepresentManager:Isdiaowen(id)
    for i=1,10 do
        local data = DataSkillLife.data_diao_wen[string.format("10007_%s", tostring(i*10))]
        for ii,v in ipairs(data.product) do
            if v.key == id then
                return true
            end
        end
    end
    return false
end

function GivepresentManager:IsLimited(id)
    for i,v in ipairs(DataFriend.data_gift) do
        if id == v.item_id then
            return v.received_limit == 1
        end
    end
    return false
end
