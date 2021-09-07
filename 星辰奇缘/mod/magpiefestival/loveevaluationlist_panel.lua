LoveEvaluationListPanel = LoveEvaluationListPanel or BaseClass()


function LoveEvaluationListPanel:__init(go,Parent,asset)
    self.assetWrapper = asset
    self.Parent = Parent
    self.gameObject = go
    self.ItemList = {}
    self.hotList = {}
    self.data = nil
    self.endHight = 0
    self.addHigth = 0
    self.endIndex = 0
    self.hotEndIndex = 0
    self:InitPanel()
    self.endHight = 0


end

function LoveEvaluationListPanel:__delete()

    if self.ItemList ~= nil then
        for k,v in pairs(self.ItemList) do
            v:DeleteMe()
        end
    end
    self.ItemList = nil

    if self.hotList ~= nil then
        for k,v in pairs(self.hotList) do
            v:DeleteMe()
        end
    end
    self.hotList = nil

     if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
end


function LoveEvaluationListPanel:InitPanel()
    self.transform = self.gameObject.transform

    self.noEvaluation = self.Parent.transform:Find("Main/MainPanel/NoEvaluation").gameObject
    self.noEvaluationText = self.noEvaluation.transform:Find("Text"):GetComponent(Text)
    self.noEvaluationText.text = string.format(TI18N("当前还没有玩家对此宠物/守护进行评论，快点击<color='#ffff00'>右上角</color>进行评论吧"))
    self.noEvaluation:SetActive(false)
    self.baseItem = self.transform:Find("Item").gameObject
    self.baseItem:SetActive(false)
end

-- 整个数据刷新
function LoveEvaluationListPanel:RefreshData(data)
    self.transform.anchoredPosition = Vector2(self.transform.anchoredPosition.x,0)
    self.data = data.list
    if BaseUtils.isnull(self.baseItem) then
        return
    end

    local H = 0
    self.addHigth = H

    BaseUtils.dump(self.data,'canshusdfsd')
    for i=1,#self.data do
        if self.ItemList[i] == nil then
            local go = GameObject.Instantiate(self.baseItem)
            go:SetActive(true)
            go.transform:SetParent(self.transform)
            go.transform.localScale = Vector3.one

            local item = LoveEvaluationItem.New(self,go,self.assetWrapper)
            self.ItemList[i] = item
        end
        BaseUtils.dump(self.data[i],i)
        self.ItemList[i]:SetData(self.data[i])
    end



    for i=1,#self.ItemList do
        self.ItemList[i].transform.anchoredPosition = Vector2(0,-H)
        H = H + self.ItemList[i].selfHeight+10
    end


    self.transform.sizeDelta = Vector2(690,H)
    self.endHight = H
    self.endIndex = #self.ItemList
    self.transform.anchoredPosition = Vector2(0,0)
end




function LoveEvaluationListPanel:OnScroll(Top,Bot)
    for i,v in ipairs(self.ItemList) do
        local ay = v.transform.anchoredPosition.y
        local sy = v.transform.sizeDelta.y

        if ay-sy>Top or ay < Bot then
            v.gameObject:SetActive(false)
        else
            v.gameObject:SetActive(true)
        end
    end

    for i,v in ipairs(self.hotList) do
        local ay = v.transform.anchoredPosition.y
        local sy = v.transform.sizeDelta.y

        if ay-sy>Top or ay < Bot then
            v.gameObject:SetActive(false)
        else
            v.gameObject:SetActive(true)
        end
    end
end

