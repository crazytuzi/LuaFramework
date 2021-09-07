GmManager = GmManager or BaseClass(BaseManager)

function GmManager:__init()
    if GmManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    GmManager.Instance = self;

    self.list = {}
    self:InitData()
    self.gmDataList = {}
    self.model = GmModel.New()
    self.modelTree = nil

    self.caton = false
end

function GmManager:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end

function GmManager:InitData()
    local originData = DataGm.data_data
    for _, data in ipairs(originData) do
        if self.list[data.type] ~= nil then
            table.insert(self.list[data.type], data)
        else
            self.list[data.type] = {data}
        end
    end
end

function GmManager:OpenGmWindow()
    self.model:OpenGmWindow()
end

function GmManager:CloseGmWindow()
    self.model:CloseGmWindow()
end

function GmManager:LoadHistory()
    if IS_DEBUG then
        local data = LocalSaveManager.Instance:getFile("game_manager")
        if data ~= nil then
            self.gmDataList = data
        end
    end
end

function GmManager:SaveHistory(data)
    if IS_DEBUG then
        LocalSaveManager.Instance:writeFile("game_manager", data)
    end
end

function GmManager:InsertModel(thetable, path)
    local subname = string.match(path, "(.-)/")
    if subname then
        local subpath = string.gsub(path, subname.."/", "")
        if thetable[subname] == nil then
            thetable[subname] = {}
        end
        return self:InsertModel(thetable[subname], subpath)
    else
        table.insert(thetable, path)
    end
end

function GmManager:CheckPath(path)
    if
        string.find(path,"mod/") ~= nil or
        string.find(path,"base/") ~= nil or
        string.find(path,"config/") ~= nil or
        string.find(path,"data/") ~= nil or
        string.find(path,"util/") ~= nil or
        string.find(path,"game_lua_start") ~= nil or
        string.find(path,"gm_cmd") ~= nil
        then
        return true
    else
        return false
    end
end

function GmManager:GetModelTree()
    self.modelTree = {}
    self.textCnt = 0
    self.localLuaFileList = {}
    local temp = {}
    local luaFile = {}
    local otherFile = {}
    local index = 0
    for path, v in pairs(package.loaded) do
        table.insert(temp, path)
        if self:CheckPath(path) == true then
            table.insert(luaFile,path)
        else
            table.insert(otherFile,path)
        end
    end
    table.sort(luaFile)

    for i,v in ipairs(luaFile) do
        if string.find(v, "/data_") ~= nil then
            self.localLuaFileList[v] = "data/lua/"..string.sub(v, 6)..".lua"
        else
            self.localLuaFileList[v] = "lua/"..v..".lua"
        end
    end

    for i,path in ipairs(temp) do
        self:InsertModel(self.modelTree, path)
    end
end

function GmManager:FixedUpdate()
    if self.caton then
        self.model:DoCaton()    
    end
end

function GmManager:HotUpdate()
    print("-------热更开始------")
    if self.modelTree == nil then
        self:GetModelTree()
    end

    HotUpdate.GetInstance():CheckFilesWitchNeedUpdate(self.localLuaFileList)
    print("-------热更结束------")

end

function GmManager:DoHotUpdate(strList)
    local list = StringHelper.Split(strList, "|")
    for i,v in ipairs(list) do
        print("热更文件====="..v..".lua")
        package.loaded[v] = nil
        require(v)
    end
end
