-- ----------------------------------------------------------
-- UI - 真心话大冒险
-- ----------------------------------------------------------
TruthordareEditorWindow = TruthordareEditorWindow or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function TruthordareEditorWindow:__init(model)
    self.model = model
    self.name = "TruthordareEditorWindow"

    self.resList = {
        {file = AssetConfig.truthordareeditorpanel, type = AssetType.Main}
        , {file = AssetConfig.truthordare_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	self.mainTransform = nil

	------------------------------------------------

    self.currentIndex = 0
    self.container_item_list = {}

    self.questionslen = 30
    self.appendTab = {}
	------------------------------------------------
	self.tabGroup = nil
	self.tabGroupObj = nil

    self._Update = function(mark) 
        if mark then 
            self:Update() 
        end 
    end

    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function TruthordareEditorWindow:__delete()
    self:OnHide()

    if self.chatExtPanel ~= nil then
        self.chatExtPanel:DeleteMe()
        self.chatExtPanel = nil
    end

    self:AssetClearAll()
end

function TruthordareEditorWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.truthordareeditorpanel))
    self.gameObject.name = "TruthordareEditorWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")
    self.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

	self.tabGroupObj = self.mainTransform:FindChild("TabButtonGroup")    --侧边栏

    local tabGroupSetting = {
        notAutoSelect = true,
        noCheckRepeat = true,
        -- openLevel = {0, 0},
        perWidth = 196,
        perHeight = 56,
        spacing = 30,
    }
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end, tabGroupSetting)

    self.panel = self.mainTransform:FindChild("Panel")
    self.container = self.mainTransform:FindChild("Panel/Mask/Container")
    self.container_vScroll =  self.panel.transform:FindChild("Mask"):GetComponent(ScrollRect)
    self.container_vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.container_setting_data)
    end)
    self.containerItem = self.panel.transform:FindChild("Item").gameObject
    self.containerItem:SetActive(true)
    for i=1, 7 do
        local go = GameObject.Instantiate(self.containerItem)
        go.transform:SetParent(self.container)
        go.transform.localScale = Vector3.one
        go.transform.localPosition = Vector3.zero

        local item = TruthordareQuestionsItem.New(go, self)
        table.insert(self.container_item_list, item)
    end
    self.containerItem:SetActive(false)

    self.container_single_item_height = self.containerItem.transform:GetComponent(RectTransform).sizeDelta.y
    self.container_scroll_con_height = self.panel.transform:FindChild("Mask"):GetComponent(RectTransform).sizeDelta.y
    self.container_item_con_last_y = self.container:GetComponent(RectTransform).anchoredPosition.y

    self.container_setting_data = {
       item_list = self.container_item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container  --item列表的父容器
       ,single_item_height = self.container_single_item_height --一条item的高度
       ,item_con_last_y = self.container_item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.container_scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.addButton = self.mainTransform:FindChild("AddButton"):GetComponent(Button)
    self.addButton.onClick:AddListener(function() self:AddButtonClick() end)

    self.editorPanel = self.transform:FindChild("EditorPanel")
    self.editorPanel:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self.editorPanel.gameObject:SetActive(false) end)
    self.editorPanel:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self.editorPanel.gameObject:SetActive(false) end)
    self.editorPanel.gameObject:SetActive(false)
    self.editorPanel:Find("Panel"):GetComponent(RectTransform).sizeDelta = Vector2(5000, 5000)

    self.I18NOpText = self.editorPanel:Find("Main/I18NOpText"):GetComponent(Text)
    self.I18NLimitText = self.editorPanel:Find("Main/I18NLimitText"):GetComponent(Text)
    self.InputField = self.editorPanel:Find("Main/InputField"):GetComponent(InputField)
    self.InputField.onValueChange:AddListener(function (val) self:OnMsgChange(val) end)
    self.InputFieldText = self.editorPanel:Find("Main/InputField/Text"):GetComponent(Text)
    self.InputPlaceHolder = self.editorPanel:Find("Main/InputField/I18NPlaceholder"):GetComponent(Text)
    self.InputField.textComponent = self.InputFieldText

    self.FcaeButton = self.editorPanel:Find("Main/FcaeButton"):GetComponent(Button)
    self.FcaeButton.onClick:AddListener(function() self:ClickMore() end)
    self.SendButton = self.editorPanel:Find("Main/SendButton"):GetComponent(Button)
    self.SendButton.onClick:AddListener(function() self:OnSend() end)
    self.AtButton = self.editorPanel:Find("Main/AtButton"):GetComponent(Button)
    self.AtButton.onClick:AddListener(function() self:OnAt() end)

    self.OnHideEvent:AddListener(function() self.previewComposite:Hide() end)
    self.OnOpenEvent:AddListener(function() self.previewComposite:Show() end)
    ----------------------------

    self.tabGroup:ChangeTab(1)
    self:OnShow()
    self:ClearMainAsset()
end

function TruthordareEditorWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function TruthordareEditorWindow:OnShow()
    self:Update()
    TruthordareManager.Instance:Send19525()
    TruthordareManager.Instance.model.question_ver = nil

    TruthordareManager.Instance.OnQuestionInfoUpdate:Remove(self._Update)
    TruthordareManager.Instance.OnQuestionInfoUpdate:Add(self._Update)
end

function TruthordareEditorWindow:OnHide()
    TruthordareManager.Instance.OnQuestionInfoUpdate:Remove(self._Update)
end

function TruthordareEditorWindow:ChangeTab(index)
    if index ~= self.currentIndex then
        self:Update()
        TruthordareManager.Instance:Send19525()
        TruthordareManager.Instance.model.question_ver = nil

        -- self.container.localPosition = Vector3.zero    
        self.container:GetComponent(RectTransform).anchoredPosition = Vector2.zero
    end
    self.currentIndex = index
end

function TruthordareEditorWindow:Update()
    local datalist = TruthordareManager.Instance.model:GetQuestionList(self.currentIndex)
    -- local datalist = { { id = 1 }, { id = 2 }, { id = 3 }, { id = 4 }, { id = 5 }, { id = 6 }, { id = 7 }, { id = 8 } }

    self.toggleList = {}
    for i, v in ipairs(datalist) do 
        self.toggleList[v.id] = v.is_choose
    end

    self.container_setting_data.data_list = datalist
    BaseUtils.refresh_circular_list(self.container_setting_data)
end

function TruthordareEditorWindow:AddButtonClick()
    self.editorPanel.gameObject:SetActive(true)
    if self.currentIndex == 1 then
        self.I18NOpText.text = TI18N("新增真心话内容")
        self.InputPlaceHolder.text = TI18N("<color='#AE9E71'>向幸运儿问出ta喜欢的人，ta不为人知的秘密......</color>")
    else
        self.I18NOpText.text = TI18N("新增大冒险内容")
        self.InputPlaceHolder.text = TI18N("<color='#AE9E71'>让幸运儿表白、唱歌、或是恶搞幸运儿......</color>")
    end
end

function TruthordareEditorWindow:OnItemButtonClick(go)
    local id = tonumber(go.name)
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("是否要删除该题目？")
    data.sureLabel = TI18N("确认删除")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function() TruthordareManager.Instance:Send19514(self.currentIndex, id) end
    NoticeManager.Instance:ConfirmTips(data)
end

function TruthordareEditorWindow:OnItemToggleChange(go, on)
    local id = tonumber(go.name)
    -- print("-----")
    -- print(id)
    -- print(on)

    local flag = 0
    if on then
        flag = 1
    end
    if self.toggleList[id] ~= flag then
        TruthordareManager.Instance:Send19516(self.currentIndex, id, flag)
    end
end

function TruthordareEditorWindow:OnMsgChange(val)
    local len = string.utf8len(val)
    if len <= self.questionslen then
        self.I18NLimitText.text = string.format(TI18N("(还能输入%s个字)"), tostring(self.questionslen-len))
    else
        self.I18NLimitText.text = TI18N("<color='#ff0000'>内容超过长度限制</color>")
    end
end

function TruthordareEditorWindow:ClickMore()
    if self.chatExtPanel == nil then
        self.chatExtPanel = ChatExtMainPanel.New(self, MsgEumn.ExtPanelType.Other, {parent = self, sendcallback = function() self:OnSend() end},nil,false)
    end
    self.chatExtPanel:Show()
end

function TruthordareEditorWindow:AppendInputElement(element)
    -- 其他：同类只有一个，如果是自己，则过滤掉
    local delIndex = 0
    local srcStr = ""
    if element.type ~= nil then
        for i,has in ipairs(self.appendTab) do
            if has.type == element.type and element.type ~= MsgEumn.AppendElementType.Face then
                delIndex = i
                srcStr = has.matchString
            end
        end
    end

    local nowStr = self.InputField.text
    if delIndex ~= 0 then
        table.remove(self.appendTab, delIndex)
        table.insert(self.appendTab, delIndex, element)
        local repStr = element.matchString
        nowStr = string.gsub(nowStr, srcStr, repStr, 1)
    else
        nowStr = nowStr .. element.showString
        table.insert(self.appendTab, element)
    end
    self.InputField.text = nowStr
end

function TruthordareEditorWindow:OnSend()
    local msg = self.InputField.text
    if msg == "" then
        NoticeManager.Instance:FloatTipsByString(TI18N("快输入挑战内容吧，小心坑自己哟{face_1,10}"))
        return
    end

    local msg, cnt = string.gsub(msg, "『@随机一人』", "@1")
    if cnt > 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("暂时只能<color='#25EEF6'>@随机一人</color>一次哦{face_1,22}"))
        return
    end

    local len = string.len(msg)
    local len2 = string.utf8len(msg)
    if len2 > self.questionslen then
        NoticeManager.Instance:FloatTipsByString(TI18N("消息长度超过限制，请修改"))
        return
    end

    for i,v in ipairs(self.appendTab) do
        local newSendStr = v.sendString
        if v.type == MsgEumn.AppendElementType.Face then
            newSendStr = string.format("{face_1,%s}", v.data)
        end
        msg = string.gsub(msg, v.matchString, newSendStr, 1)

        if i == 3 then -- 限制只能用3个表情，多于3个不处理，直接发送#xx
            break
        end
    end
    
    TruthordareManager.Instance:Send19513(self.currentIndex, msg)
    self.editorPanel.gameObject:SetActive(false)
end

function TruthordareEditorWindow:OnAt()
    local strResult, cnt = string.gsub(self.InputField.text, "『@随机一人』", "@1")
    if cnt == 0 then
        self.InputField.text = self.InputField.text..TI18N("『@随机一人』")
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("暂时只能<color='#25EEF6'>@随机一人</color>一次哦{face_1,22}"))
    end
end

