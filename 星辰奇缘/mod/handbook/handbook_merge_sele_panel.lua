
-- 面板下拉选择
HandBookMergeSelePanel = HandBookMergeSelePanel or BaseClass(BasePanel)

function HandBookMergeSelePanel:__init(model, parent)
	self.model = model
	self.parent = parent

    self.resList = {
        {file = AssetConfig.handbook_merge_select_panel, type = AssetType.Main},
    }
    self.btnType ={
        [101] = TI18N("力量+%s"),
        [102] = TI18N("体质+%s"),
        [103] = TI18N("智力+%s"),
        [104] = TI18N("敏捷+%s"),
        [105] = TI18N("耐力+%s")
    }
    self.btnList = { }
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function HandBookMergeSelePanel:OnShow()
    self:InitList(self.openArgs)
end

function HandBookMergeSelePanel:OnHide()
end

function HandBookMergeSelePanel:__delete()
end

function HandBookMergeSelePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.handbook_merge_select_panel))
    self.gameObject.name = "HandBookMergeSelePanel"
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    self.transform = self.gameObject.transform
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.Main = self.transform:Find("Main"):GetComponent(RectTransform)
    self.scroll = self.transform:Find("Main/scroll") 
    self.scroll_content = self.transform:Find("Main/scroll/scroll_content")
    self.btn = self.transform:Find("Main/scroll/scroll_content/btn_type").gameObject
    self.btn:SetActive(false)
    if self.layout == nil then
        self.layout = LuaBoxLayout.New(self.scroll_content, { axis = BoxLayoutAxis.Y, scrollRect = self.scroll, border = 2, cspacing = 7 })
    end
    self:OnShow()
end

function HandBookMergeSelePanel:InitList(args)
    local lev = args[1]  --等级
    local targetid = args[2]  --图鉴id
    local handbook_data = DataHandbook.data_base[targetid]
    local reallyNum = handbook_data["lev_num"..lev]
    for index, v in pairs(self.btnType) do
        if  self.btnList[index] == nil then
            self.btnList[index] = GameObject.Instantiate(self.btn)
            self.btnList[index]:SetActive(true)
            self.btnList[index].name = tostring(index)
            self.layout:AddCell(self.btnList[index])
            local txt = self.btnList[index].transform:Find("Text").gameObject:GetComponent(Text)
            txt.text = string.format(v, reallyNum)
            self.btnList[index]:GetComponent(Button).onClick:AddListener( function() self:Click(index, reallyNum) end)
        end
    end
    
    local sizeDelta = self.Main.sizeDelta
    local mheight = 5 * 44 + 5
    self.Main.sizeDelta = Vector2(sizeDelta.x, mheight)
end

function HandBookMergeSelePanel:Close()
	HandbookManager.Instance.model:CloseSelect()
end

function HandBookMergeSelePanel:Click(index, val)
    HandbookManager.Instance.onUpdateMergeselect:Fire(index, val)
	self:Close()
end