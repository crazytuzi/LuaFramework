-- @author zgs
StoreModel = StoreModel or BaseClass(BaseModel)

function StoreModel:__init()
    self.gaWin = nil

    self.pet_nums = 0 --宠物仓库当前容量
    self.petlist = {} --宠物仓库数据列表
    self.lastFreeType = 0 --放生操作类型。 0表示服务端主动发(刷新存取操作), 1表示主动从仓库中放生，2表示主动从携带中放生

    self.storeType = BackpackEumn.StorageType.Store
end

function StoreModel:__delete()
    if self.gaWin then
        self.gaWin = nil
    end
end

function StoreModel:OpenWindow(args)
    if self.gaWin == nil then
        self.gaWin = StoreWindow.New(self)
    end
    self.gaWin:Open(args)
end

function StoreModel:CloseMain()
    WindowManager.Instance:CloseWindow(self.gaWin, true)
end
-- -----------------------------------------------------------
-- 道具仓库
-- -----------------------------------------------------------
--在仓库取一个空的格子
function StoreModel:GetEmptyGridPosInStore()
    local posTemp = 0
    for i=1,BackpackManager.Instance.volumeOfStorage do
        posTemp = i
        for k,v in pairs(BackpackManager.Instance.storeDic) do
            if i == v.pos then
                posTemp = 0
                break
            end
        end
        if posTemp ~= 0 then
            break
        end
    end
    return posTemp
end

--存入仓库
function StoreModel:InStore(item)
    if self.storeType == BackpackEumn.StorageType.Store then
        local posTemp = BackpackManager.Instance.storeModel:GetEmptyGridPosInStore()
        if posTemp ~= 0 then
            BackpackManager.Instance:Send10329({id = item.id,from_storage = BackpackEumn.StorageType.Backpack,storage = BackpackEumn.StorageType.Store,pos = posTemp})
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("仓库空间不足，请清理"))
        end
    elseif self.storeType == BackpackEumn.StorageType.HomeStore then
        local posTemp = BackpackManager.Instance.storeModel:GetEmptyGridPosInHomeStore()
        if posTemp ~= 0 then
            BackpackManager.Instance:Send10329({id = item.id,from_storage = BackpackEumn.StorageType.Backpack,storage = BackpackEumn.StorageType.HomeStore,pos = posTemp})
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("家园仓库空间不足，请清理"))
        end
    end
end

--仓库取出
function StoreModel:OutStore(item)
    if self.storeType == BackpackEumn.StorageType.Store then
        local posTemp = BackpackManager.Instance:GetNilPos()
        if posTemp ~= 0 then
            BackpackManager.Instance:Send10329({id = item.id,from_storage = BackpackEumn.StorageType.Store,storage = BackpackEumn.StorageType.Backpack,pos = posTemp})
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("背包空间不足，请清理"))
        end
    elseif self.storeType == BackpackEumn.StorageType.HomeStore then
        local posTemp = BackpackManager.Instance:GetNilPos()
        if posTemp ~= 0 then
            BackpackManager.Instance:Send10329({id = item.id,from_storage = BackpackEumn.StorageType.HomeStore,storage = BackpackEumn.StorageType.Backpack,pos = posTemp})
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("背包空间不足，请清理"))
        end
    end
end

--在仓库取一个空的格子
function StoreModel:GetEmptyGridPosInHomeStore()
    local posTemp = 0
    for i=1,BackpackManager.Instance.volumeOfHomeStorage do
        posTemp = i
        for k,v in pairs(BackpackManager.Instance.homeStoreDic) do
            if i == v.pos then
                posTemp = 0
                break
            end
        end
        if posTemp ~= 0 then
            break
        end
    end
    return posTemp
end

-- --存入家园仓库
-- function StoreModel:InHomeStore(item)
--     local posTemp = BackpackManager.Instance.storeModel:GetEmptyGridPosInHomeStore()
--     if posTemp ~= 0 then
--         BackpackManager.Instance:Send10329({id = item.id,from_storage = BackpackEumn.StorageType.Backpack,storage = BackpackEumn.StorageType.HomeStore,pos = posTemp})
--     else
--         NoticeManager.Instance:FloatTipsByString("家园仓库空间不足，请清理")
--     end
-- end

-- --仓库家园取出
-- function StoreModel:OutHomeStore(item)
--     local posTemp = BackpackManager.Instance:GetNilPos()
--     if posTemp ~= 0 then
--         BackpackManager.Instance:Send10329({id = item.id,from_storage = BackpackEumn.StorageType.HomeStore,storage = BackpackEumn.StorageType.Backpack,pos = posTemp})
--     else
--         NoticeManager.Instance:FloatTipsByString("背包空间不足，请清理")
--     end
-- end
-- -----------------------------------------------------------
-- 宠物仓库
-- -----------------------------------------------------------
--仓库宠物数据
function StoreModel:On10528(data)
    -- BaseUtils.dump(data,"on10528")
    self.pet_nums = data.pet_nums
    self.petlist = data.pet_list
    for i = 1, #self.petlist do
        self.petlist[i] = self:updatepetbasedata(self.petlist[i])
        -- self.petlist[i] = PetManager.Instance.model:pet_grade_attr(self.petlist[i])
    end

    -- EventMgr.Instance:Fire(event_name.petstore_update)

end

function StoreModel:getpet_byid(idTemp)
    local id = tonumber(idTemp)
    for i=1, #self.petlist do
        if self.petlist[i].id == id then
            return self.petlist[i] , i
        end
    end
    return nil , 0
end

function StoreModel:updatepetbasedata(data)
    local basedata = DataPet.data_pet[data.base_id]
    if basedata ~= nil then
        data.base = basedata
    end
    return data
end
--存宠物
function StoreModel:On10529(data)
    -- BaseUtils.dump(data,"on10529")
    -- if data.result == 0 then
    --     NoticeManager.Instance:FloatTipsByString(data.msg)
    -- end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
--取宠物
function StoreModel:On10530(data)
    BaseUtils.dump(data,"on10530")
    -- if data.result == 0 then
    --     NoticeManager.Instance:FloatTipsByString(data.msg)
    -- end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
--仓库新增宠物
function StoreModel:On10531(data)
    -- BaseUtils.dump(data,"on10531")
    local petlist = data.pet_list
    for i = 1, #petlist do
        petlist[i] = self:updatepetbasedata(petlist[i])
        -- petlist[i] = PetManager.Instance.model:pet_grade_attr(petlist[i])
        table.insert(self.petlist, petlist[i])
    end
    EventMgr.Instance:Fire(event_name.petstore_update)
end
--放生相关
function StoreModel:On10532(data)
    -- BaseUtils.dump(data,"on10532")
    if data.result == 0 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    else
        -- Log.Error(self.lastFreeType)
        --放生（删除）
        if self.lastFreeType == 0 then --存取刷新

        elseif self.lastFreeType == 1 then --从仓库中放生
            self.lastFreeType = 0
            local petData2 ,index2 = self:getpet_byid(data.id)
            if petData2 ~= nil then
                table.remove(self.petlist,index2)
                EventMgr.Instance:Fire(event_name.petstore_update) --仓库中删除宠物
            end
        elseif self.lastFreeType == 2 then --从携带中放生
            self.lastFreeType = 0
            local petData ,index = PetManager.Instance.model:getpet_byid(data.id)
            if PetManager.Instance ~= nil and PetManager.Instance.model ~= nil and petData ~= nil then
                table.remove(PetManager.Instance.model.petlist,index)
                EventMgr.Instance:Fire(event_name.pet_update) --携带中删除宠物
            end
        end
    end
end

function StoreModel:On10533(data)
    -- BaseUtils.dump(data,"on10533")
    if data.result == 0 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    else
        --增加仓库宠物格子成功
        self.pet_nums = data.pet_nums
        EventMgr.Instance:Fire(event_name.petstore_update)
    end
end