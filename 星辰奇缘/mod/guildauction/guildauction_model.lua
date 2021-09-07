GuildAuctionModel = GuildAuctionModel or BaseClass(BaseModel)

function GuildAuctionModel:__init()
    self.window = nil

    self.targetData = nil

    self.questteam_loaded = false -- 任务追踪模块初始化完成
    self.quest_track = nil -- 突破任务的任务追踪项
    self.questData = nil -- 突破任务的任务追踪数据
    self.LocalPath = ctx.ResourcesPath.."/guildAuction/"
    if Application.platform == RuntimePlatform.WindowsPlayer then
        -- os.execute("mkdir \"" .. self.LocalPath.."\"")
        Utils.CreateDirectoryStatic(self.LocalPath)
    elseif Application.platform == RuntimePlatform.Android then
        if CSVersion.Version == "1.1.1" then
            -- 旧版本处理方法
            Utils():CreateDirectory(self.LocalPath)
        else
            Utils.CreateDirectoryStatic(self.LocalPath)
        end
    elseif Application.platform == RuntimePlatform.IPhonePlayer then
        if CSVersion.Version == "1.1.1" then
            -- 旧版本处理方法
            Utils():CreateDirectory(self.LocalPath)
        else
            Utils.CreateDirectoryStatic(self.LocalPath)
        end
    else
        os.execute("mkdir \"" .. self.LocalPath.."\"")
    end
    self.filter = {["set_id"] = {}, ["type"] = {}}
    -- EventMgr.Instance:AddListener(event_name.trace_quest_loaded, function() self.questteam_loaded = true self:UpdataQuest() end)
end

function GuildAuctionModel:__delete()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function GuildAuctionModel:OpenWindow(args)
    if self.window == nil then
        self.window = GuildAuctionWindow.New(self)
    end

    self.window:Open(args)
end

function GuildAuctionModel:CloseWindow()
    if self.window ~= nil then
        WindowManager.Instance:CloseWindow(self.window)
    end
end

function GuildAuctionModel:OpenPanel(args)
    if self.auctionpanel == nil then
        self.auctionpanel = GuildAuctionPanel.New(self)
    end
    self.auctionpanel:Show(args)
end

function GuildAuctionModel:ClosePanel(args)
    if self.auctionpanel ~= nil then
        self.auctionpanel:DeleteMe()
        self.auctionpanel = nil
    end
end


function GuildAuctionModel:InsertFilter(key, val)
    if self.filter[key] ~= nil then
        local oldkey = nil
        for k,v in pairs(self.filter[key]) do
            if v == val then
                oldkey = k
            end
        end
        if oldkey == nil then
            table.insert(self.filter[key], val)
        -- else
        --     table.remove(self.filter[key], oldkey)
            self:WriteFilter()
        end
    end
end


function GuildAuctionModel:RemoveFilter(key, val)
    if self.filter[key] ~= nil then
        local oldkey = nil
        for k,v in pairs(self.filter[key]) do
            if v == val then
                oldkey = k
            end
        end
        if oldkey ~= nil then
            table.remove(self.filter[key], oldkey)
            self:WriteFilter()
        end
    end
end

function GuildAuctionModel:HasFilter(key, val)
    if self.filter[key] ~= nil then
        local oldkey = nil
        for k,v in pairs(self.filter[key]) do
            if v == val or v == 0 then
                oldkey = k
            end
        end
        if oldkey == nil then
            return false
        else
            return true
        end
    end
    return false
end

function GuildAuctionModel:ReadFilter()
    local selfuid = BaseUtils.Key("_", RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
    self.filter = LocalSaveManager.Instance:getFile(selfuid, self.LocalPath)
    if self.filter == nil or next(self.filter) == nil then
        local setlist = {}
        table.insert(setlist, 0)
        for k,v in pairs(DataTalisman.data_set) do
            table.insert(setlist, k)
        end
        table.sort(setlist, function(a, b)
            return a < b
        end)
        self.filter = {
            ["set_id"] = setlist,
            ["type"] = {
                0,
                147,
                148,
                149,
                150
                }
        }
    end
    self.filter["type"] = nil
end

function GuildAuctionModel:WriteFilter()
    local selfuid = BaseUtils.Key("_", RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
    LocalSaveManager.Instance:writeFile(selfuid, self.filter, self.LocalPath)
end

function GuildAuctionModel:GetFilterStr()
    local str = ""
    local setnum = 0
    for k,v in pairs(self.filter["set_id"]) do
        setnum = setnum + 1
        if v == 0 then
            return TI18N("全部显示")
        else
            if str == "" then
                str = string.sub(DataTalisman.data_set[v].set_name, 1, 6)
            else
                if setnum <= 3 then
                    str = str.." "..string.sub(DataTalisman.data_set[v].set_name, 1, 6)
                end
            end
        end
    end
    if #self.filter["set_id"] > 3 then
        str = str.."..."
    end
    return str
end