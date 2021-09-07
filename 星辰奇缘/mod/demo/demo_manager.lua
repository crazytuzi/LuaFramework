-- demo
DemoManager = DemoManager or BaseClass(BaseManager)

function DemoManager:__init()
    if DemoManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    DemoManager.Instance = self;
    self:InitHandler()

    self.demoModel = DemoModel.New()
end

function DemoManager:__delete()
    self.demoModel:DeleteMe()
    self.demoModel = nil
end

function DemoManager:InitHandler()
    self:AddNetHandler(90010, self.On90010)
    self:AddNetHandler(90020, self.On90020)
end

function DemoManager:TestLuaBehaviour()
    local go = GameObject("TestLuaBehaviour")
    local behaviore = go:AddComponent(LuaBehaviourBase)
    behaviore:SetClass("DemoBehaviour")

end

function DemoManager:On90010(data)
    -- 做点别的
end

function DemoManager:On90020(data)
    -- 做点别的
end

-- function DemoManager:InitMainUI()
    -- self.demoModel:InitMainUI()
-- end

function DemoManager:DoTest()
    self.demoModel:InitMainUI()
end

function DemoManager:OpenPoolWindow()
    self.demoModel:OpenPoolWindow()
end

function DemoManager:OpenLayoutWindow()
    self.demoModel:OpenLayoutWindow()
end

function DemoManager:OpenPageWindow()
    self.demoModel:OpenPageWindow()
end

function DemoManager:OpenPreviewWindow()
    self.demoModel:OpenPreviewWindow()
end

function DemoManager:StartPrase()
    local gg = _G
    local result = {}
    self:Prase_G(gg, result)
    local final = {}
    for k,v in pairs(result) do
        table.insert(final, {key = k, Refnum = v})
    end
    table.sort( final, function(a,b) return a.Refnum > b.Refnum end )
    local file = io.open("C:\\Users\\Administrator\\Desktop\\logg.txt","w")
    for k,v in ipairs(final) do
        file:write(string.format("name: %s   Refnum: %s\n", tostring(v.key), tostring(v.Refnum)))

    end
    file:write("==============\n")
    print("读写完了；额")
    file:close()
end

function DemoManager:Prase_G(tab, result)
    for k,v in pairs(tab) do
        if type(v) == "table" and result[k] == nil then
            result[k] = 1
            self:Prase_G(v, result)
        elseif type(v) == "table" and result[k] ~= nil then
            result[k] = result[k] + 1
        end
    end
end
