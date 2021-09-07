-- 作者:jia
-- 3/24/2017 3:02:47 PM
-- 功能:诸神之战选择赛季下拉

GodsWarSelectSeasonPanel = GodsWarSelectSeasonPanel or BaseClass(BasePanel)
function GodsWarSelectSeasonPanel:__init(parent)
    self.parent = parent
    self.resList = {
        { file = AssetConfig.godswarselectseasonpanel, type = AssetType.Main }
    }
    -- self.OnOpenEvent:Add(function() self:OnOpen() end)
    -- self.OnHideEvent:Add(function() self:OnHide() end)
    self.hasInit = false
    self.btnseasons = { }
end

function GodsWarSelectSeasonPanel:__delete()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function GodsWarSelectSeasonPanel:OnHide()

end

function GodsWarSelectSeasonPanel:OnOpen()

end

function GodsWarSelectSeasonPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarselectseasonpanel))
    self.gameObject.name = "GodsWarSelectSeasonPanel"
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)

    self.transform = self.gameObject.transform
    self.Panel = self.transform:Find("Panel")
    self.Main = self.transform:Find("Main"):GetComponent(RectTransform)
    self.scroll = self.transform:Find("Main/scroll")
    self.scroll_content = self.transform:Find("Main/scroll/scroll_content")
    self.btn_season = self.transform:Find("Main/scroll/scroll_content/btn_season").gameObject
    self.transform = self.gameObject.transform
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener( function() self:Close() end)

    if self.layout == nil then
        self.layout = LuaBoxLayout.New(self.scroll_content, { axis = BoxLayoutAxis.Y, border = 2 })
    end
    self:InitSeasonList(GodsWarManager.Instance.season - 1)
end

function GodsWarSelectSeasonPanel:Close()
    GodsWarManager.Instance.model:CloseSelect()
end

function GodsWarSelectSeasonPanel:InitSeasonList(seasonNum)
    seasonNum = seasonNum or 4
    if seasonNum <= 0 then
        seasonNum = 1
    end
    -- 下拉列表过滤的届数
    local unShowList = GodsWarManager.Instance.unShowList
    for index = seasonNum, 1, -1 do
        if not self:IsInUnShowList(index) then
        if  self.btnseasons[index] == nil then
            self.btnseasons[index] = GameObject.Instantiate(self.btn_season)
            -- self.btnseasons[index]:SetActive(true)
            self.btnseasons[index].name = tostring(index)
            self.layout:AddCell(self.btnseasons[index])
            local txt = self.btnseasons[index].transform:Find("Text").gameObject:GetComponent(Text)
            txt.text = string.format(TI18N("第%s赛季"), index)
            self.btnseasons[index]:GetComponent(Button).onClick:AddListener( function() self:Click(index) end)
        end
        end
    end
    if seasonNum - #unShowList < 4 then
        local sizeDelta = self.Main.sizeDelta
        local mheight = sizeDelta.y -(4 - seasonNum + #unShowList) * 40
        self.Main.sizeDelta = Vector2(sizeDelta.x, mheight)
        self.scroll.sizeDelta = Vector2(sizeDelta.x, mheight-20)
    end
end
function GodsWarSelectSeasonPanel:Click(index)
    EventMgr.Instance:Fire(event_name.godswar_his_select_seasom_update, index)
    self:Close()
end

function GodsWarSelectSeasonPanel:IsInUnShowList(value)
    local  res = false
    local  lsit = GodsWarManager.Instance.unShowList
    for _,v in ipairs(lsit) do
        if v == value then
         res = true
        end
    end
    return res
end