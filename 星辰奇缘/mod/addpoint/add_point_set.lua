-- -----------------------
-- 加点设置界面
-- hosr
-- -----------------------
AddPointSet = AddPointSet or BaseClass()

function AddPointSet:__init(gameObject, main)
    self.main = main
    self.auto_txt = {}
    self.auto_points = {}
    self.maxSetPoint = 5
    self.saveCall = nil
    self.gameObject = gameObject
    self:InitPanel()
    self.type = AddPointEumn.Type.Role
end

function AddPointSet:__delete()
    self.auto_txt = nil
    self.auto_points = nil
    self.saveCall = nil
end

function AddPointSet:InitPanel()
    self.transform = self.gameObject.transform
    -- self.gameObject:GetComponent(Button).onClick:AddListener(function() self:Close() end)
    local main = self.transform:Find("Main").gameObject.transform
    main:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    main:Find("SureButton"):GetComponent(Button).onClick:AddListener(function() self:Sure() end)
    main:Find("CancelButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    local func = function(trans, _index)
        local index = _index
        self.auto_txt[index] = trans:Find("Value"):GetComponent(Text)
        trans:Find("MinusButton"):GetComponent(Button).onClick:AddListener(function() self:SetMinus(index) end)
        trans:Find("PlusButton"):GetComponent(Button).onClick:AddListener(function() self:SetPlus(index) end)
    end

    local container = main:Find("Option").gameObject.transform
    func(container:Find("Corporeity").gameObject.transform, 1)
    func(container:Find("Force").gameObject.transform, 2)
    func(container:Find("Brains").gameObject.transform, 3)
    func(container:Find("Agile").gameObject.transform, 4)
    func(container:Find("Endurance").gameObject.transform, 5)

    self.gameObject:SetActive(false)
end

function AddPointSet:Close()
    self:Hide()
end

function AddPointSet:Sure()
    self.main:SureSetting(self.auto_points)
    self:Close()
end

function AddPointSet:UpdateInfo()
    if self.type == AddPointEumn.Type.Role then
        local role = RoleManager.Instance.RoleData
        -- BaseUtils.dump(role, "role")


        local option = nil
        for i=1,#RoleManager.Instance.RoleData.plan_data do
            if RoleManager.Instance.RoleData.plan_data[i].index == RoleManager.Instance.RoleData.valid_plan then
                option = RoleManager.Instance.RoleData.plan_data[i]
                break
            end
        end

        if option == nil then
            --空方案
            option = {}
            option.constitution = 0
            option.strength = 0
            option.magic = 0
            option.agility = 0
            option.endurance = 0
            option.pre_con = 0
            option.pre_str = 0
            option.pre_magic = 0
            option.pre_agi = 0
            option.pre_end = 0
        end

        self.auto_points = {option.pre_con, option.pre_str, option.pre_magic, option.pre_agi, option.pre_end}
    elseif self.type == AddPointEumn.Type.Pet then
        local petData = self.main.openArgs[2]
        self.auto_points = {petData.pre_con or 0, petData.pre_str or 0, petData.pre_mag or 0, petData.pre_agi or 0, petData.pre_end or 0}
    elseif self.type == AddPointEumn.Type.Child then
        local childData = self.main.openArgs[2]
        self.auto_points = {childData.pre_con or 0, childData.pre_str or 0, childData.pre_mag or 0, childData.pre_agi or 0, childData.pre_end or 0}
    end
    for index,val in ipairs(self.auto_points) do
        self.auto_txt[index].text = tostring(val)
    end
end

--设置界面减1
function AddPointSet:SetMinus(index)
    if self.auto_points[index] > 0 then
        self.auto_points[index] = self.auto_points[index] - 1
    end
    self.auto_txt[index].text = tostring(self.auto_points[index])
end

--设置界面加1
function AddPointSet:SetPlus(index)
    local count = 0
    for i,v in ipairs(self.auto_points) do
        count = count + v
    end
    if count >= self.maxSetPoint then
        return
    end

    if self.auto_points[index] < self.maxSetPoint then
        self.auto_points[index] = self.auto_points[index] + 1
    end
    self.auto_txt[index].text = tostring(self.auto_points[index])
end

function AddPointSet:Show(type)
    self.type = type
    self:UpdateInfo()
    self.gameObject:SetActive(true)
end

function AddPointSet:Hide()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
end