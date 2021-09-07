-- --------------------------
-- 下拉列表处理脚本
-- 1、切换选中不选择资源
-- 2、回调切换下标
-- 3、显示红点
-- hzf
-- --------------------------
DropDownList = DropDownList or BaseClass()

-- -----------------------------------
-- 参数说明
-- gameObject 初始化传人规定格式的对象
-- callback 切换时回调通知
-- notAutoSelect 初始化完了是否自动选中第一个 默认自动选中
-- setting = {notAutoSelect, noCheckRepeat, openLevel}
-- UI结构：
-- --最外层检测点击区域按钮Button 覆盖整个屏幕的透明按钮
-- ------ 主按钮MainButton Button
-- ------ 箭头Image
-- ------ 文本Text
-- ------ 下拉列表 List
-- ----------按钮1 Button
-- ----------按钮2 Button
-- ----------..... Button
-- ----------按钮n Button
-- -----------------------------------
function DropDownList:__init(gameObject, callback, setting)
    self.gameObject = gameObject
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.callback = callback
    self.buttonTab = {}
    self.currentIndex = 0

    setting = setting or {}
    self.notAutoSelect = setting.notAutoSelect
    self.noCheckRepeat = setting.noCheckRepeat
    self.defaultindex = setting.defaultindex or nil

    -- ---------------------------------------------------------
    --- 需要用到开服等级处理的要另外设置一下参数
    -- 每个按钮的等级 {1,2,4,5}
    self.openLevel = setting.openLevel or {}
----------------------------------------

    self:Init()
end

-- -----------------------------------------------
-- 如果按等级开放的，一定要在销毁时调用移除事件
-- -----------------------------------------------
function DropDownList:__delete()
    self:Clean()
end

function DropDownList:Clean()
    --EventMgr.Instance:RemoveListener(event_name.role_level_change, self.listener)
    self.gameObject = nil
    self.transform = nil
    self.rect = nil
    self.callback = nil
    self.listener = nil
end

function DropDownList:Init()
    self.transform = self.gameObject.transform
    self.bgBtn = self.transform:GetComponent(Button)
    self.bgImg = self.transform:GetComponent(Image)
    self.MainBtn = self.transform:Find("MainButton"):GetComponent(Button)
    self.list = self.transform:Find("List")
    self.bgBtn.enabled = false
    self.bgImg.enabled = false
    self.list.gameObject:SetActive(false)
    self.bgBtn.onClick:AddListener(function()
        self.bgBtn.enabled = false
        self.bgImg.enabled = false
        self.list.gameObject:SetActive(false)
    end)
    self.MainBtn.onClick:AddListener(function()
        if self.bgBtn.enabled == true then
            self.bgBtn.enabled = false
            self.bgImg.enabled = false
            self.list.gameObject:SetActive(false)
        else
            self.bgBtn.enabled = true
            self.bgImg.enabled = true
            self.list.gameObject:SetActive(true)
        end
    end)
    self.showText = self.transform:Find("Text"):GetComponent(Text)
    self.arrow = self.transform:Find("Image"):GetComponent(Image)
    self.ListCon = self.list:Find("MaskScroll/ListCon")
    local childcount = self.list:Find("MaskScroll/ListCon").childCount
    for i = 1, childcount do
        local index = i
        local tab = {}
        local obj = self.ListCon:GetChild(i - 1).gameObject
        obj:GetComponent(Button).onClick:AddListener(function() self:ChangeTab(index) end)
        local transform = obj.transform
        tab["gameObject"] = obj
        tab["transform"] = transform
        tab["rect"] = obj:GetComponent(RectTransform)
        tab["Text"] = transform:Find("I18NText"):GetComponent(Text)
        table.insert(self.buttonTab, tab)
    end
    -- if #self.openLevel > 0 then
    --     self:Layout()
    --     EventMgr.Instance:AddListener(event_name.role_level_change, self.listener)
    -- end

    if not self.notAutoSelect and self.defaultindex == nil then
        self:ChangeTab(1)
    elseif self.defaultindex ~= nil then
        self:ChangeTab(self.defaultindex)
    end
end

function DropDownList:ChangeTab(index, special)
    local isrepeat = false
    if self.currentIndex == index then

    end

    local tab = nil
    -- if self.currentIndex ~= 0 then
    --     -- self:UnSelect(self.currentIndex)
    -- end
    if self.showText == nil or self.buttonTab[index] == nil then
        return
    end

    self.showText.text = self.buttonTab[index]["Text"].text
    self.currentIndex = index
    self.bgBtn.enabled = false
    self.bgImg.enabled = false
    self.list.gameObject:SetActive(false)
    -- self:Select(self.currentIndex)

    -- -- 点击就把红点去掉
    -- self:ShowRed(self.currentIndex, false)

    if not isrepeat and self.callback ~= nil then
        self.callback(index, special)
    end
end

-- function DropDownList:Select(index)
--     local tab = self.buttonTab[index]
--     if tab ~= nil then
--         tab["normal"]:SetActive(false)
--         tab["select"]:SetActive(true)
--     end
-- end

-- function DropDownList:UnSelect(index)
--     local tab = self.buttonTab[index]
--     if tab ~= nil then
--         tab["select"]:SetActive(false)
--         tab["normal"]:SetActive(true)
--     end
-- end

-- 控制是否显示红点
function DropDownList:ShowRed(index, bool)
    if self.buttonTab[index]["red"] ~= nil then
        self.buttonTab[index]["red"]:SetActive(bool)
    end
end

-- 修改某个标签文字
function DropDownList:ResetText(index, str)
    if self.buttonTab[index]["text"] ~= nil then
       self.buttonTab[index]["text"].text = str
   end
end

function DropDownList:OnLevelUp()
    if BaseUtils.is_null(self.gameObject) then
        self:Clean()
        return
    end
    if #self.openLevel > 0 then
        self:Layout()
    end
end

-- 按等级显示同时排序
function DropDownList:Layout()
    self.rect.pivot = Vector2(0, 1)

    local count = 0
    local roleLev = RoleManager.Instance.RoleData.lev
    for i,tab in ipairs(self.buttonTab) do
        local lev = self.openLevel[i] or 0
        if roleLev >= lev then
            tab["gameObject"]:SetActive(true)
            tab["rect"].offsetMin = Vector2(0,1)
            tab["rect"].offsetMax = Vector2(0,1)
            tab["rect"].sizeDelta = Vector2(self.perWidth, self.perHeight)
            if self.isVertical then
                tab["transform"].localPosition = Vector3(0, -count * (self.perHeight + self.spacing) - self.perHeight / 2, 0)
            else
                tab["transform"].localPosition = Vector3(count * (self.perWidth + self.spacing) + self.perWidth / 2, 0, 0)
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