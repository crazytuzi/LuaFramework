
--  幸运儿面板下拉选择


TruthordareLuckydorPanel = TruthordareLuckydorPanel or BaseClass(BasePanel)

function TruthordareLuckydorPanel:__init(model, parent)
	self.model = model
	self.parent = parent

    self.resList = {
        {file = AssetConfig.truthordareagendaselepanel, type = AssetType.Main},
    }
    self.btnType ={
        [1] = TI18N("显示全部"),
        [2] = TI18N("显示当天"),
        [3] = TI18N("显示本周"),
        [4] = TI18N("显示上周")
    }
    self.btnList = { }
end

function TruthordareLuckydorPanel:__delete()
end

function TruthordareLuckydorPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.truthordareagendaselepanel))
    self.gameObject.name = "TruthordareLuckydorPanel"
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    self.transform = self.gameObject.transform
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.Main = self.transform:Find("Main"):GetComponent(RectTransform)
    self.scroll = self.transform:Find("Main/scroll") 
    self.scroll_content = self.transform:Find("Main/scroll/scroll_content")
    self.btn = self.transform:Find("Main/scroll/scroll_content/btn_type").gameObject
    self.btn:SetActive(false)
    if self.layout == nil then
        self.layout = LuaBoxLayout.New(self.scroll_content, { axis = BoxLayoutAxis.Y, scrollRect = self.scroll, border = 2 })
    end
    self:InitList()
end

function TruthordareLuckydorPanel:InitList()

    for index, v in ipairs(self.btnType) do
        if  self.btnList[index] == nil then
            self.btnList[index] = GameObject.Instantiate(self.btn)
            self.btnList[index]:SetActive(true)
            self.btnList[index].name = tostring(index)
            self.layout:AddCell(self.btnList[index])
            local txt = self.btnList[index].transform:Find("Text").gameObject:GetComponent(Text)
            txt.text = v
            self.btnList[index]:GetComponent(Button).onClick:AddListener( function() self:Click(index) end)
        end
    end
    
    local sizeDelta = self.Main.sizeDelta
    local mheight = 26 + (#self.btnType) * 44
    self.Main.sizeDelta = Vector2(sizeDelta.x, mheight)
end

function TruthordareLuckydorPanel:Close()
	TruthordareManager.Instance.model:CloseSelect()
end

function TruthordareLuckydorPanel:Click(index)
    TruthordareManager.Instance.OnluckydorSelectUpdate:Fire(index)
	--EventMgr.Instance:Fire(event_name.godswar_select_update, index)
	self:Close()
end