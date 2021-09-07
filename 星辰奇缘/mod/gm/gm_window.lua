GmWindow = GmWindow or BaseClass(BaseWindow)

function GmWindow:__init(model)
    self.model = model
    self.name = "DemoLayoutWindow"
    self.windowid = WindowConfig.WinID.ui_gm
    -- 缓存
    self.cacheMode = CacheMode.Visible
    self.holdTime = BaseUtils.DefaultHoldTime()
    self.resList = {
        {file = AssetConfig.gm_window, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }

    self.closeBut = nil

    self.typeContainer = nil
    self.typeCloner = nil
    self.cmdContainer = nil
    self.cmdCloner = nil

    self.typeGrid = nil
    self.cmdGrid = nil

    self.list = GmManager.Instance.list

    self.gmDataList = {
        {"gm 设等级 22","gm 设等级 42","gm 设等级 62"},
        {"gm 查看开服时间","gm 0点更新","gm 5点更新"},
        {"gm 变神器","gm 限时返利 14","gm 下线"},
        {"gm 公会战匹配","gm 公会战","gm 公会精英战"},
        {"gm 捉迷藏下阶段","gm 广播捉迷藏","gm 公会精英战"},
    }
    self.itemDic = {}
    self.isShowHisPanel = false
    GmManager.Instance:LoadHistory()
    if #GmManager.Instance.gmDataList > 0 then
        self.gmDataList = GmManager.Instance.gmDataList
    end
end

function GmWindow:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    if self.typeGrid == nil then
        self.typeGrid:DeleteMe()
        self.typeGrid = nil
    end
    if self.cmdGrid == nil then
        self.cmdGrid:DeleteMe()
        self.cmdGrid = nil
    end
    -- 卸载资源 非依赖资源可以在UI创建完就可以卸载
    self:AssetClearAll()
end

function GmWindow:InitPanel()
    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.gm_window))
    self.gameObject.name  =  "GmWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.closeBut = self.gameObject.transform:FindChild("Window/Close").gameObject
    self.closeBut:GetComponent(Button).onClick:AddListener(function() self:OnCloseButtonClick() end)

    self.typeContainer = self.gameObject.transform:FindChild("Window/TypePanel/Container").gameObject
    self.typeCloner = self.typeContainer.transform:FindChild("Cloner").gameObject
    self.cmdContainer = self.gameObject.transform:FindChild("Window/CmdPanel/Container").gameObject
    self.cmdCloner = self.cmdContainer.transform:FindChild("Cloner").gameObject
    self.memoryPanel = self.transform:Find("Window/CmdPanel/MemoryPanel")

    local setting = {
        column = 6
        ,bordertop = 5
        ,cspacing = 5
        ,rspacing = 5
        ,cellSizeX = 104.5
        ,cellSizeY = 31.5
    }
    self.typeGrid = LuaGridLayout.New(self.typeContainer, setting)

    setting = {
        column = 3
        ,bordertop = 5
        ,borderleft = 10
        ,cspacing = 5
        ,rspacing = 5
        ,cellSizeX = 201.8
        ,cellSizeY = 43.3
    }
    self.cmdGrid = LuaGridLayout.New(self.cmdContainer, setting)

    self:InitTypePanel()

    self.consolePanel = self.gameObject.transform:FindChild("Window/ConsolePanel").gameObject
    self.consoleInputField = self.consolePanel.transform:FindChild("Cloner/InputField").gameObject:GetComponent(InputField)
    self.hisPanel = self.consolePanel.transform:FindChild("HistoryPanel").gameObject
    local layoutContainer = self.hisPanel.transform:Find("ScrollPanel/Grid")
    self.layout_1 = LuaBoxLayout.New(layoutContainer.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 2})
    self.item = layoutContainer:Find("Item").gameObject
    self.item:SetActive(false)
    self.hisPanel:SetActive(false)
    self.isShowHisPanel = false
    -- self.consoleInputField.onEndEdit:AddListener(function()
    --         gm_cmd.run(self.consoleInputField.text)
    --         -- self.consoleInputField.text = ""
    --     end)
    self.consolePanel.transform:FindChild("Cloner/Submit"):GetComponent(Button).onClick:AddListener(
        function()
            gm_cmd.run(self.consoleInputField.text)
            -- self.consoleInputField.text = ""
            self:CheckNeedAdd(self.consoleInputField.text)
        end
    )
    self.consolePanel.transform:FindChild("Cloner/More"):GetComponent(Button).onClick:AddListener(
        function()
            if self.isShowHisPanel == false then
                self.isShowHisPanel = true
                self.hisPanel:SetActive(true)
                self:UpdateHisPanel()
            else
                self.isShowHisPanel = false
                self.hisPanel:SetActive(false)
            end
        end
    )
    self.consolePanel.transform:FindChild("Cloner/Hot"):GetComponent(Button).onClick:AddListener(function()
        GmManager.Instance.model:OpenHotFixWindow()
    end)
end

function GmWindow:CheckNeedAdd(txt)
    local isNeed = true
    for i,v in ipairs(self.gmDataList) do
        for j,value in ipairs(v) do
            if value == txt then
                isNeed = false
                break
            end
        end
        if isNeed == false then
            break
        end
    end
    if isNeed == true then
        if #self.gmDataList[1] == 3 then
            local newData = {}
            table.insert(newData,self.consoleInputField.text)
            table.insert(self.gmDataList,1,newData)
        else
            table.insert(self.gmDataList[1],self.consoleInputField.text)
        end
        if #self.gmDataList > 10 then
            local temp = {}
            for i = #self.gmDataList-9, #self.gmDataList do
                table.insert(temp, self.gmDataList[i])
            end
            GmManager.Instance:SaveHistory(temp)
        else
            GmManager.Instance:SaveHistory(self.gmDataList)
        end
        if self.isShowHisPanel == true then
            self:UpdateHisPanel()
        end
    end
end

function GmWindow:UpdateHisPanel()
    for i,v in pairs(self.itemDic) do
        if v.thisObj ~= nil then
            GameObject.DestroyImmediate(v.thisObj)
        end
    end
    self.layout_1:ReSet()
    self.itemDic = {}
    for i,v in pairs(self.gmDataList) do
        local itemTemp = self.itemDic[i]
        if itemTemp == nil then
            local obj = GameObject.Instantiate(self.item)
            obj.name = tostring(i)

            local itemTable = {
                index = i,
                thisObj = obj,
                btn_1 = obj.transform:Find("Btn_1"):GetComponent(Button),
                txt_1 = obj.transform:Find("Btn_1/Text"):GetComponent(Text),
                btn_2 = obj.transform:Find("Btn_2"):GetComponent(Button),
                txt_2 = obj.transform:Find("Btn_2/Text"):GetComponent(Text),
                btn_3 = obj.transform:Find("Btn_3"):GetComponent(Button),
                txt_3 = obj.transform:Find("Btn_3/Text"):GetComponent(Text),
            }
            self.layout_1:AddCell(obj)

            self.itemDic[i] = itemTable
            itemTemp = itemTable
            itemTemp.btn_1.onClick:AddListener(
                function()
                    gm_cmd.run(itemTemp.txt_1.text)
                end
            )
            itemTemp.btn_2.onClick:AddListener(
                function()
                    gm_cmd.run(itemTemp.txt_2.text)
                end
            )
            itemTemp.btn_3.onClick:AddListener(
                function()
                    gm_cmd.run(itemTemp.txt_3.text)
                end
            )
        end
        itemTemp.thisObj:SetActive(true)
        itemTemp.value = v
        self:updateItemBtn(itemTemp)
    end
end

function GmWindow:updateItemBtn(item)
    if item.value[1] ~= nil then
        item.btn_1.gameObject:SetActive(true)
        item.txt_1.text = item.value[1]
    else
        item.btn_1.gameObject:SetActive(false)
    end
    if item.value[2] ~= nil then
        item.btn_2.gameObject:SetActive(true)
        item.txt_2.text = item.value[2]
    else
        item.btn_2.gameObject:SetActive(false)
    end
    if item.value[3] ~= nil then
        item.btn_3.gameObject:SetActive(true)
        item.txt_3.text = item.value[3]
    else
        item.btn_3.gameObject:SetActive(false)
    end
end

function GmWindow:InitTypePanel()
    for key, _ in pairs(self.list) do
        local cell = GameObject.Instantiate(self.typeCloner)
        cell.transform:FindChild("Text"):GetComponent(Text).text = key
        cell:GetComponent(Button).onClick:AddListener(function() self:OnTypeButClick(key) end)
        self.typeGrid:AddCell(cell)
    end
    local cell = GameObject.Instantiate(self.typeCloner)
    cell.transform:FindChild("Text"):GetComponent(Text).text = TI18N("内存信息")
    cell:GetComponent(Button).onClick:AddListener(function() self:OpenMemoryInfo(key) end)
    self.typeGrid:AddCell(cell)
end

function GmWindow:OnCloseButtonClick()
    self.model:CloseGmWindow()
end

function GmWindow:OnTypeButClick(key)
    self.memoryPanel.gameObject:SetActive(false)
    self.cmdContainer:SetActive(true)
    self.cmdGrid:Clear()
    local list = self.list[key]
    if list ~= nil then
        for _, data in ipairs(list) do
            local cell = GameObject.Instantiate(self.cmdCloner)
            cell.transform:FindChild("Text"):GetComponent(Text).text = data.desc
            local inputField = cell.transform:FindChild("InputField").gameObject
            -- local text = inputField.transform:FindChild("Text"):GetComponent(Text)
            local text = inputField.transform:GetComponent(InputField)
            local hasParam = true
            if string.find(data.command,"{param}") == nil then
                inputField:SetActive(false)
                hasParam = false
            end
            cell.transform:FindChild("Submit"):GetComponent(Button).onClick:AddListener(function() self:onCmdButClick(data, text, hasParam) end)
            self.cmdGrid:AddCell(cell)
        end
    end
end

function GmWindow:onCmdButClick(data, text, hasParam)
    local cmd = nil
    local param = text.text
    if hasParam then
        cmd = string.gsub(data.command, "{param}", param)
    else
        cmd = data.command
    end
    if cmd == "glory" then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.glory_window, {})
        return
    end
    if string.find(data.command,"gm") == nil then
        gm_cmd.run(data.command)
        return
    end
    local cmds = self:split(cmd, ";")
    for _, data in pairs(cmds) do
        data = string.sub(data, 3, -1)
        Connection.Instance:send(9900, {cmd = data})
    end
end

function GmWindow:split(_str,split_char)
    if #_str == o then
        return
    end
    if _str == split_char then
        return _str
    end

    local sub_str_tab = {}
    while (true) do
        local pos = string.find(_str, split_char);
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = _str;
            break;
        end
        local sub_str = string.sub(_str, 1, pos - 1);
        sub_str_tab[#sub_str_tab + 1] = sub_str;
        _str = string.sub(_str, pos + 1, #_str);
    end
    return sub_str_tab;
end

function GmWindow:OpenMemoryInfo()
    collectgarbage("collect")
    collectgarbage("collect")
    self.memoryPanel.gameObject:SetActive(true)
    self.cmdContainer:SetActive(false)
    local kbSize = 1024*1024
    local num = 0
    local newnum = 0
    for k,v in pairs(MemoryCheckTable) do
        num = num + 1
        if v.time > 3 then
            newnum = newnum + 1
        end
    end
    self.memoryPanel:Find("unityTotalReservedMemory"):GetComponent(Text).text = string.format("UnityTotalReservedMemory: %sM", tostring(Profiler.GetTotalReservedMemory()/kbSize))
    self.memoryPanel:Find("unityTotalAllocatedMem"):GetComponent(Text).text = string.format("UnityTotalAllocatedMem: %sM", tostring(Profiler.GetTotalAllocatedMemory()/kbSize))
    self.memoryPanel:Find("unityUnusedReservedMemory"):GetComponent(Text).text = string.format("UnityUnusedReservedMemory: %sM", tostring(Profiler.GetTotalUnusedReservedMemory()/kbSize))
    self.memoryPanel:Find("MonoHeapSize"):GetComponent(Text).text = string.format("MonoHeapSize: %sM", tostring(Profiler.GetMonoHeapSize()/kbSize))
    self.memoryPanel:Find("MonoUsedHeapSize"):GetComponent(Text).text = string.format("LuaMemory: %.1f M, 视图类数量：%s(非初始化常驻：%s)", math.ceil(collectgarbage("count"))/1024, num, newnum)
end
