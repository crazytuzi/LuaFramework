NpcshopModel = NpcshopModel or BaseClass(BaseModel)

function NpcshopModel:__init()
    self.npcshopWin = nil
end

-- function NpcshopModel:OpenWindow(args)
--     self.openArgs = args
--     self.npcshopWin:Open()
-- end

function NpcshopModel:__delete()
    if self.npcshopWin ~= nil then
        self.npcshopWin:DeleteMe()
        self.npcshopWin = nil
    end
end

function NpcshopModel:LoadData(datatype)
    if datatype == 1 then
        if self.medicineData == nil then
            self.medicineData = {}
            for _,v in pairs(DataNpcShop.data_medicine_shop) do
                table.insert(self.medicineData, v)
            end
        end
    elseif datatype == 3 then
        if self.contestmedicineData == nil then
            self.contestmedicineData = {}
            for _,v in pairs(DataNpcShop.data_contestmedicine_shop) do
                table.insert(self.contestmedicineData, v)
            end
        end
    elseif datatype == 2 then
        self.eqmData = self.eqmData or {}
        for k,v in pairs(self.eqmData) do
            self.eqmData[k] = nil
        end
        local role_classes = RoleManager.Instance.RoleData.classes
        local eqmData = DataNpcShop.data_eqm_shop
        for k,v in pairs(eqmData) do
            if v.classes == role_classes or v.classes == 0 then
                table.insert(self.eqmData, v)
            end
        end
    end
end

function NpcshopModel:OpenWindow(args)
    self.openArgs = args
    self:LoadData(args[1])
    if self.npcshopWin == nil then
        self.npcshopWin = NpcshopWindow.New(self)
    end
    self.npcshopWin:Open(args)
end

function NpcshopModel:RoleAssetsListener()
    if self.npcshopWin ~= nil then
        self.npcshopWin:RoleAssetsListener()
    end
end

function NpcshopModel:GetDataList()
    if self.openArgs[1] == 1 then
        return self.medicineData
    elseif self.openArgs[1] == 3 then
        return self.contestmedicineData
    else
        local datalist = {}
        if self.openArgs[2] == nil then
            return self.eqmData
        end
        for _,v in pairs(self.eqmData) do
            if v.group == self.openArgs[2] then
                table.insert(datalist, v)
            end
        end
        return datalist
    end
end