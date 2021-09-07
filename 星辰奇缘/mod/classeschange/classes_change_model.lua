
ClassesChangeModel = ClassesChangeModel or BaseClass(BaseModel)

function ClassesChangeModel:__init()
	self.window = nil
	self.classesChangeSuccessWindow = nil
	self.gemChangeWindow = nil

	EventMgr.Instance:AddListener(event_name.change_classes_success, function(data) self:OpenClassesChangeSuccessWindow({data.classes}) end)

    self.IsChangedStone = false  --转换晶石的标志
    self.lastClass = 1  --上一职业

    self.Stonetype = {23824, 23825, 23826, 23827, 23828, 23835, 23829}
    
    self.talisman_list_change = {}
end

function ClassesChangeModel:__delete()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function ClassesChangeModel:OpenClassesChangeWindow(args)
    if self.window == nil then
        self.window = ClassesChangeWindow.New(self)
    end
    self.window:Open(args)
end

function ClassesChangeModel:CloseClassesChangeWindow()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function ClassesChangeModel:OpenClassesChangeSuccessWindow(args)
    if self.classesChangeSuccessWindow == nil then
        self.classesChangeSuccessWindow = ClassesChangeSuccessWindow.New(self)
        self.classesChangeSuccessWindow.callback = function()
        		self:CloseClassesChangeSuccessWindow()
    		end
    end
    self.classesChangeSuccessWindow:Show(args)
end

function ClassesChangeModel:CloseClassesChangeSuccessWindow()
    if self.classesChangeSuccessWindow ~= nil then
        self.classesChangeSuccessWindow:DeleteMe()
        self.classesChangeSuccessWindow = nil
    end
end

function ClassesChangeModel:OpenGemChangeWindow(args)
    if self.gemChangeWindow == nil then
        self.gemChangeWindow = GemChangeWindow.New(self)
    end
    self.gemChangeWindow:Open(args)
end

function ClassesChangeModel:CloseGemChangeWindow()
    if self.gemChangeWindow ~= nil then
        self.gemChangeWindow:DeleteMe()
        self.gemChangeWindow = nil
    end
end


function ClassesChangeModel:OpenTalismanChangeWindow(args)
    if self.talismanChangeWindow == nil then
        self.talismanChangeWindow = TalismanChangeWindow.New(self)
    end
    self.talismanChangeWindow:Open(args)
end

function ClassesChangeModel:CloseTalismanChangeWindow()
    if self.talismanChangeWindow ~= nil then
        self.talismanChangeWindow:DeleteMe()
        self.talismanChangeWindow = nil
    end
end



function ClassesChangeModel:GetGemChangeFree(data)
	if data == nil then
		return
	end
	local equipData = data.equipData
	local gemIndex = data.gemIndex
    -- BaseUtils.dump(data, "data")
	local free_mark = false
    for i=1,#equipData.extra do
        if (gemIndex == 110 and equipData.extra[i].name == BackpackEumn.ExtraName.gem_free_1)
        	or (gemIndex == 111 and equipData.extra[i].name == BackpackEumn.ExtraName.gem_free_2)
                or (gemIndex == 112 and equipData.extra[i].name == BackpackEumn.ExtraName.gem_free_3) then
            free_mark = true --可以转职免费重置
            break
        end
    end
	return free_mark
end

function ClassesChangeModel:GetClassesChangeDay()
	local times = RoleManager.Instance.RoleData.classes_modify_times
	local cooldowm = 7
	for i=1,#DataClassesModify.data_cooldowm do
		if times >= DataClassesModify.data_cooldowm[i].times then
			cooldowm = math.floor(DataClassesModify.data_cooldowm[i].colddown / 86400 + 0.5)
		end
	end
	return cooldowm
end

function ClassesChangeModel:SetTailsChangeData()
    self.talisman_list_change = self.talisman_list
    for i = 1, #self.talisman_list_change do
        self.talisman_list_change[i].canChangeList = {}
        self.talisman_list_change[i].canChange = 0
        for a,b in pairs(self.talisman_list_change[i].reset_list) do
            if b.reset_flag == 1 then
                table.insert(self.talisman_list_change[i].canChangeList,b.reset_base_id)
                self.talisman_list_change[i].canChange = 1
            end
        end
    end
end

function ClassesChangeModel:GetTailsbyId(id)
    local con_data = nil
    for i,v in pairs(self.talisman_list_change) do
        if v.id == id then
            con_data = v
            break
        end
    end
    return con_data
end