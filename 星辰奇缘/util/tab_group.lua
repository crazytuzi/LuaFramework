-- --------------------------
-- 标签帮助处理脚本
-- 1、切换选中不选择资源
-- 2、回调切换下标
-- 3、显示红点
-- hosr
-- --------------------------
TabGroup = TabGroup or BaseClass()

-- -----------------------------------
-- 参数说明
-- gameObject 初始化传人规定格式的标签切换对象
-- callback 切换时回调通知
-- notAutoSelect 初始化完了是否自动选中第一个 默认自动选中
-- setting = {notAutoSelect, noCheckRepeat, openLevel, perWidth, perHeight, isVertical, spacing}
-- -----------------------------------
function TabGroup:__init(gameObject, callback, setting)
    self.gameObject = gameObject
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.callback = callback
    self.buttonTab = {}
    self.currentIndex = 0

    setting = setting or {}
    self.notAutoSelect = setting.notAutoSelect
    self.noCheckRepeat = setting.noCheckRepeat

    self.listener = function() self:OnLevelUp() end

    -- ---------------------------------------------------------
    --- 需要用到开服等级处理的要另外设置一下参数
    -- 每个按钮的等级 {1,2,4,5}
    self.openLevel = setting.openLevel or {}
    -- 等级上限,超过不显示
    self.levelLimit = setting.levelLimit or {}
    -- 显示选中
    self.cannotSelect = setting.cannotSelect or {}
    -- 按钮尺寸，排版用(不用等级处理的不用传,也不管你怎么排)
    self.perWidth = setting.perWidth or 0
    self.perHeight = setting.perHeight or 0
    self.offsetWidth = setting.offsetWidth or self.perWidth
    self.offsetHeight = setting.offsetHeight or self.perHeight
    -- 垂直
    self.isVertical = setting.isVertical
    self.spacing = setting.spacing or 3
    -- --------------------------------------------------------

    self:Init()
end

-- -----------------------------------------------
-- 如果按等级开放的，一定要在销毁时调用移除事件
-- -----------------------------------------------
function TabGroup:__delete()
    self:Clean()
end

function TabGroup:Clean()
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.listener)
    self.gameObject = nil
    self.transform = nil
    self.rect = nil
    self.callback = nil
    self.listener = nil
end

function TabGroup:Init()
    self.transform = self.gameObject.transform
    self.buttonTab = {}
    local childcount = self.transform.childCount
    for i = 1, childcount do
        local index = i
        local tab = {}
        local obj = self.transform:GetChild(i - 1).gameObject
        obj:GetComponent(Button).onClick:AddListener(function() self:ChangeTab(index) end)
        local transform = obj.transform
        tab["gameObject"] = obj
        tab["transform"] = transform
        tab["rect"] = obj:GetComponent(RectTransform)
        tab["normal"] = transform:Find("Normal").gameObject
        tab["select"] = transform:Find("Select").gameObject
        tab["normal"]:SetActive(true)
        tab["select"]:SetActive(false)
        local red_transform = transform:Find("NotifyPoint")
        if red_transform ~= nil then
            tab["red"] = red_transform.gameObject
        end
        local text_transform = transform:Find("Text")
        if text_transform ~= nil then
            tab["text"] = text_transform:GetComponent(Text)
        end
        if transform:Find("Normal/Text") ~= nil then
            tab["normalTxt"] = transform:Find("Normal/Text"):GetComponent(Text)
        end
        if transform:Find("Select/Text") ~= nil then
            tab["selectTxt"] = transform:Find("Select/Text"):GetComponent(Text)
        end

        table.insert(self.buttonTab, tab)
    end

    if #self.openLevel > 0 then
        self:Layout()
        EventMgr.Instance:AddListener(event_name.role_level_change, self.listener)
    end

    if not self.notAutoSelect then
        self:ChangeTab(1)
    end
end

function TabGroup:ChangeTab(index, special)
    if not self.noCheckRepeat and self.currentIndex == index then
        return
    end

    if not self.cannotSelect[index] then
        if self.currentIndex ~= 0 then
            self:UnSelect(self.currentIndex)
        end

        self.currentIndex = index
        self:Select(self.currentIndex)
    end

    -- -- 点击就把红点去掉
    -- self:ShowRed(self.currentIndex, false)

    if self.callback ~= nil then
        self.callback(index, special)
    end
end

function TabGroup:Select(index)
    local tab = self.buttonTab[index]
    if tab ~= nil then
        tab["normal"]:SetActive(false)
        tab["select"]:SetActive(true)
    end
end

function TabGroup:UnSelect(index)
    local tab = self.buttonTab[index]
    if tab ~= nil then
        tab["select"]:SetActive(false)
        tab["normal"]:SetActive(true)
    end
end

-- 控制是否显示红点
function TabGroup:ShowRed(index, bool)
    if self.buttonTab[index] ~= nil and self.buttonTab[index]["red"] ~= nil then
        self.buttonTab[index]["red"]:SetActive(bool)
    end
end

-- 修改某个标签文字
function TabGroup:ResetText(index, str)
    if self.buttonTab[index]["text"] ~= nil then
       self.buttonTab[index]["text"].text = str
   end
end

function TabGroup:OnLevelUp()
    if BaseUtils.is_null(self.gameObject) then
        self:Clean()
        return
    end
    if #self.openLevel > 0 then
        self:Layout()
    end
end

-- 按等级显示同时排序
function TabGroup:Layout()
    self.rect.pivot = Vector2(0, 1)

    local count = 0
    local roleLev = RoleManager.Instance.RoleData.lev
    for i,tab in ipairs(self.buttonTab) do
        local lev = self.openLevel[i] or 0
        local limit = self.levelLimit[i] or 0
        if roleLev >= lev and (limit == 0 or (limit ~= 0 and roleLev <= limit)) then
            tab["gameObject"]:SetActive(true)
            tab["rect"].offsetMin = Vector2(0,1)
            tab["rect"].offsetMax = Vector2(0,1)
            tab["rect"].sizeDelta = Vector2(self.perWidth, self.perHeight)
            if self.isVertical then
                tab["transform"].localPosition = Vector3(0, -count * (self.perHeight + self.spacing) - self.offsetHeight / 2, 0)
            else
                tab["transform"].localPosition = Vector3(count * (self.perWidth + self.spacing) + self.offsetWidth / 2, 0, 0)
            end
            count = count + 1
        else
            tab["gameObject"]:SetActive(false)
        end
    end
    if self.isVertical then
        self.rect.sizeDelta = Vector2(self.perWidth, count * (self.perHeight + self.spacing))
    else
        self.rect.sizeDelta = Vector2(count * self.perWidth, (self.perHeight + self.spacing))
    end
end

function TabGroup:UpdateSetting(setting)
    --- 需要用到开服等级处理的要另外设置一下参数
    -- 每个按钮的等级 {1,2,4,5}
    self.openLevel = setting.openLevel or {}
    -- 等级上限,超过不显示
    self.levelLimit = setting.levelLimit or {}
    -- 按钮尺寸，排版用(不用等级处理的不用传,也不管你怎么排)
    self.perWidth = setting.perWidth or 0
    self.perHeight = setting.perHeight or 0
    self.offsetWidth = setting.offsetWidth or self.perWidth
    self.offsetHeight = setting.offsetHeight or self.perHeight
    -- 垂直
    self.isVertical = setting.isVertical
    self.spacing = setting.spacing or 3
end