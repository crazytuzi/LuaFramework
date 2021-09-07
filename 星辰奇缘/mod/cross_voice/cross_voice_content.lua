-- @author #pwj
-- @date 2018年6月8日,星期五

CrossVoiceContent = CrossVoiceContent or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject

function CrossVoiceContent:__init(model)
    self.model = model
    self.name = "CrossVoiceContent"
    --self.windowId = WindowConfig.WinID.CrossVoicecontent
    self.resList = {
        {file = AssetConfig.crossvoicecontent, type = AssetType.Main}
    }

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.SystemContent = {
        {"星辰奇缘两周年快乐！"}
        ,{"成长的路上，感谢有你的陪伴"}
        ,{"星辰奇缘两周年快乐！"}
        ,{"成长的路上，感谢有你的陪伴"}
        ,{"星辰奇缘两周年快乐！"}
        ,{"成长的路上，感谢有你的陪伴"}
    }
    --self.model.System_MsgList

    self.ItemList = {}
    self.OldItemList = {}
    self.selectIndex = 1
end

function CrossVoiceContent:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function CrossVoiceContent:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.crossvoicecontent))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("MainCon/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.Container = self.transform:Find("MainCon/FashionScrollRect/FashionContainer")
    self.luaBoxLayout = LuaGridLayout.New(self.Container, {column = 2, cellSizeX = 294, cellSizeY = 110, bordertop = 5, borderleft = 8})
    --self.luaBoxLayout = LuaBoxLayout.New(self.Container,{axis = BoxLayoutAxis.Y, cspacing = 2})
    self.Item = self.transform:Find("MainCon/FashionScrollRect/FashionContainer/Item").gameObject
    self.Item:SetActive(false)

    self.sureBtn = self.transform:Find("MainCon/SureBtn"):GetComponent(Button)
    self.sureBtn.onClick:AddListener(function() self:OnSureBtnClick() end)
end

function CrossVoiceContent:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function CrossVoiceContent:OnShow()
    self:AddListeners()
    if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        self.callback = self.openArgs[1]
    end
    self:SetData()
end

function CrossVoiceContent:OnHide()
    self:RemoveListeners()
end

function CrossVoiceContent:AddListeners()
    self:RemoveListeners()
end

function CrossVoiceContent:RemoveListeners()
end


function CrossVoiceContent:Close()
    self.model:CloseCrossVoiceContent()
end


function CrossVoiceContent:SetData()
    for i = 1,#self.model.System_MsgList do
        if self.ItemList[i] == nil then
            local item = {}
            item.gameObject = GameObject.Instantiate(self.Item)
            item.transform = item.gameObject.transform
            item.Btn = item.transform:GetComponent(Button)
            item.Btn.onClick:AddListener(function() self:OnItemClick(i) end)
            item.content = item.transform:Find("StatusText"):GetComponent(Text)
            item.Select = item.transform:Find("Select")
            self.ItemList[i] = item
            self.luaBoxLayout:AddCell(self.ItemList[i].gameObject)
        end

    end
    self.ItemList[1].Select.gameObject:SetActive(true)
    --BaseUtils.dump(self.model.System_MsgList,"self.SystemContent")
    for i,v in ipairs(self.ItemList) do
        self.ItemList[i].content.text = self.model.System_MsgList[i].context
    end
end

function CrossVoiceContent:OnItemClick(index)
    self.selectIndex = index
    for i,v in ipairs(self.ItemList) do
        if i == index then
            self.ItemList[i].Select.gameObject:SetActive(true)
        else
            self.ItemList[i].Select.gameObject:SetActive(false)
        end
    end
end

function CrossVoiceContent:OnSureBtnClick()
    if self.selectIndex > 0 and self.selectIndex <= #self.model.System_MsgList then
        if self.callback ~= nil then
            self.callback(self.model.System_MsgList[self.selectIndex].context)
            self:Close()
        end
    end
end



