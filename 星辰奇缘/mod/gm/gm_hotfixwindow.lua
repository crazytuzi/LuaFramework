
HotFixWindow = HotFixWindow or BaseClass(BaseWindow)

function HotFixWindow:__init(model)
    self.model = model
    self.name = "DemoLayoutWindow"
    -- 缓存
    self.cacheMode = CacheMode.Visible
    self.holdTime = BaseUtils.DefaultHoldTime()
    self.resList = {
        {file = AssetConfig.gm_hotfixwindow, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }
    self.indexList = {}
    self.indexname = {}
    self.selectgo = {}
    GmManager.Instance:GetModelTree()
end

function HotFixWindow:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    -- 卸载资源 非依赖资源可以在UI创建完就可以卸载
    self:AssetClearAll()
end

function HotFixWindow:InitPanel()
    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.gm_hotfixwindow))
    self.gameObject.name  =  "HotFixWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function()
        self.model:CloseHotFixWindow()
    end)
    self.conList = {}
    self.inputList = {}
    for i = 1, 4 do
       self.conList[i] = self.transform:Find("MainCon/Con"..tostring(i)
)       self.inputList[i] = self.transform:Find("MainCon/InputField" .. i):GetComponent(InputField)
       local j = i
       self.inputList[i].onValueChange:AddListener(function() self:OnTextChange(j) end)
    end
    self:InitList()
end

function HotFixWindow:InitList()
    self.item_list = {}
    self.item_con = {}
    self.item_con_last_y = {}
    self.single_item_height = {}
    self.scroll_con_height = {}
    self.setting_data = {}
    for i=1,4 do
        local list = self:GetData(i)
        self.item_list[i] = {}
        self.item_con[i] = self.conList[i]:Find("Layout")
        self.item_con_last_y[i] = self.item_con[i]:GetComponent(RectTransform).anchoredPosition.y
        self.single_item_height[i] = 51.2
        self.scroll_con_height[i] = self.conList[i]:GetComponent(RectTransform).sizeDelta.y
        for ii=1,13 do
            local go = self.item_con[i]:GetChild(ii-1).gameObject
            local item = HotFixItem.New(go, self, i)
            table.insert(self.item_list[i], item)
        end
        self.setting_data[i] = {
           item_list = self.item_list[i]--放了 item类对象的列表
           ,data_list = {} --数据列表
           ,item_con = self.item_con[i]  --item列表的父容器
           ,single_item_height = self.single_item_height[i] --一条item的高度
           ,item_con_last_y = self.item_con_last_y[i] --父容器改变时上一次的y坐标
           ,scroll_con_height = self.scroll_con_height[i]--显示区域的高度
           ,item_con_height = 0 --item列表的父容器高度
           ,scroll_change_count = 0 --父容器滚动累计改变值
           ,data_head_index = 0  --数据头指针
           ,data_tail_index = 0 --数据尾指针
           ,item_head_index = 0 --item列表头指针
           ,item_tail_index = 0 --item列表尾指针
        }
        -- self.vScroll[i] = self.conList[i]:GetComponent(ScrollRect)
        self.conList[i]:GetComponent(ScrollRect).onValueChanged:AddListener(function()
            BaseUtils.on_value_change(self.setting_data[i])
        end)
        self.setting_data[i].data_list = list
        BaseUtils.refresh_circular_list(self.setting_data[i])
    end
end

function HotFixWindow:GetData(lev,index)
    local sortfunc = function(a, b)
        if type(a.data) ~= "table" and type(b.data) ~= "table" then
            return string.byte(a.data) < string.byte(b.data)
        elseif type(a.data) ~= "table" then
            return false
        else
            return string.byte(a.name) < string.byte(b.name)
        end
    end
    local pos = nil
    if lev == 1 then
        local temp = {}
        for k,v in pairs(GmManager.Instance.modelTree) do
            pos = string.find(k, self.inputList[1].text)
            if pos == nil and v ~= nil and type(v) ~= "table" then
                pos = string.find(v, self.inputList[1].text)
            end
            if pos ~= nil then
                table.insert(temp, {name = k, data = v})
            end
        end
        table.sort(temp, sortfunc)
        return temp
    elseif lev == 2 then
        local temp = {}
        if self.indexname[1] ~= nil then
            for k,v in pairs(GmManager.Instance.modelTree[self.indexname[1]] or {}) do
                pos = string.find(k, self.inputList[2].text)
                if pos == nil and v ~= nil and type(v) ~= "table" then
                    pos = string.find(v, self.inputList[2].text)
                end
                if pos ~= nil then
                    table.insert(temp, {name = k, data = v})
                end
            end
        end
        table.sort(temp, sortfunc)
        return temp
    elseif lev == 3 then
        local temp = {}
        if self.indexname[1] ~= nil and self.indexname[2] ~= nil then
            for k,v in pairs((GmManager.Instance.modelTree[self.indexname[1]] or {})[self.indexname[2]] or {}) do
                pos = string.find(k, self.inputList[3].text)
                if pos == nil and v ~= nil and type(v) ~= "table" then
                    pos = string.find(v, self.inputList[3].text)
                end
                if pos ~= nil then
                    table.insert(temp, {name = k, data = v})
                end
            end
        end
        table.sort(temp, sortfunc)
        return temp
    elseif lev == 4 then
        local temp = {}
        if self.indexname[1] ~= nil and self.indexname[2] ~= nil and self.indexname[3] ~= nil then
            for k,v in pairs(((GmManager.Instance.modelTree[self.indexname[1]] or {})[self.indexname[2]] or {})[self.indexname[3]] or {}) do
                pos = string.find(k, self.inputList[4].text)
                if pos == nil and v ~= nil and type(v) ~= "table" then
                    pos = string.find(v, self.inputList[4].text)
                end
                if pos ~= nil then
                    table.insert(temp, {name = k, data = v})
                end
            end
        end
        table.sort(temp, sortfunc)
        return temp
    end
end

function HotFixWindow:RefreshList()
    for i=1,4 do
        local data = self:GetData(i)
        self.setting_data[i].data_list = data
        BaseUtils.refresh_circular_list(self.setting_data[i])
    end
end

function HotFixWindow:HotFix()
    local str = ""
    for i=1,4 do
        if i == 1 then
            str = self.indexname[i]
        else
            if self.indexname[i] ~= nil and i ~= 4 then
                str = str.."/"..self.indexname[i]
            else
                if i == 4 and self.indexname[i] ~= nil then
                    str = str.."/"..self.indexname[i]
                end
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = "是否热更：".. str.."如果该模块当前有实例存在则可能会无法热更\n(建议别乱点那些奇奇怪怪的模块，游戏崩了自己背锅)"
                data.sureLabel = "确定"
                data.cancelLabel = "取消"
                data.sureCallback = function()
                    -- if package.loaded[str] ~= nil then
                        package.loaded[str] = nil
                        require(str)
                        NoticeManager.Instance:FloatTipsByString("热更完成")
                    -- else
                    --     NoticeManager.Instance:FloatTipsByString(str.."未加载过该模块")
                    -- end
                end
                NoticeManager.Instance:ConfirmTips(data)
            end
        end
    end
end

function HotFixWindow:OnTextChange(index)
    self:RefreshList()
end
