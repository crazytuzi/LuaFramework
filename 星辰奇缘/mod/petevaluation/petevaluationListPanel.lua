PetEvaluationListPanel = PetEvaluationListPanel or BaseClass()


function PetEvaluationListPanel:__init(go,Parent,Bou)
    self.Parent = Parent
    self.gameObject = go
    self.ItemList = {}
    self.hotList = {}
    self.oldItemList = {}
    self.data = {}
     -- 根据刷新次数来获取数据列表
     -- 最末端的放置item的高度
    self.endHight = 0
     -- 记录热门以下插入的高度
    self.addHigth = 0
    self.refreshTimes = 1
    self.giveThumbsTimes = 0
    -- 计数
    self.total = 0
    -- 当前索引
    self.endIndex = 0
    self.hotEndIndex = 0
   self.hasThumbData = nil
    self:InitPanel()
    self.evaluationTarget = nil       -- 存放点赞和点踩的对象


end

function PetEvaluationListPanel:__delete()

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

    if self.oldItemList ~= nil then
        for k,v in pairs(self.oldItemList) do
            v:DeleteMe()
        end
    end
    self.oldItemList = nil

    if self.evaluationTarget ~= nil then
        self.evaluationTarget = nil
    end

    if self.hasThumbData ~= nil then
        self.hasThumbData = nil
    end
    

     if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
end


function PetEvaluationListPanel:InitPanel()
    self.transform = self.gameObject.transform

    self.noEvaluation = self.Parent.transform:Find("Main/MainPanel/NoEvaluation").gameObject
    self.noEvaluationText = self.noEvaluation.transform:Find("Text"):GetComponent(Text)
    self.noEvaluationText.text = string.format(TI18N("当前还没有玩家对此宠物/守护进行评论，快点击<color='#ffff00'>右上角</color>进行评论吧"))
    self.noEvaluation:SetActive(false)
    self.boundary = self.transform:Find("Boundary").gameObject
    self.boundary:SetActive(false)
    self.baseItem = self.transform:Find("Item").gameObject
    self.baseItem:SetActive(false)
    self.data = PetEvaluationManager.Instance:GetPetEvaluationData()
    self.hasThumbData = PetEvaluationManager.Instance:GetHasThumbDic()
    -- 第一次排列
    self:RefreshData(self.data)
end

-- function PetEvaluationListPanel:Hide()
--     self.refreshTimes =1
--     self.endHight = 0
--     self.endIndex = 0
-- end

-- 整个数据刷新
function PetEvaluationListPanel:RefreshData(data,msgtag)
    if BaseUtils.isnull(self.baseItem) then
        return
    end

    self.endIndex = 0
    self.refreshTimes =1
    self.endHight = 0
    self.total = 0
    self.data = data
    local hasnew = false

    self:CheckHasThumbs()
    self:SetHotList()
    -- self:SetHotList()

    local H = self.endHight
    self.addHigth = H


    for i=self.hotEndIndex + 1,#self.data do
        local old = self:GetOldItem(self.data[i].id)

        if old == nil then
            local go = GameObject.Instantiate(self.baseItem)
            go:SetActive(true)
            go.transform:SetParent(self.transform)
            go.transform.localScale = Vector3.one

            local Item = PetEvaluationItem.New(self,go,self.data[i])
            table.insert(self.ItemList,Item)
        else
            table.insert(self.ItemList,old)
            if old.gameObject ~= nil then
                old.gameObject:SetActive(true)
            end
        end
    end



    for i=1,#self.ItemList do
        self.ItemList[i].transform.anchoredPosition = Vector2(0,-H)
        H = H + self.ItemList[i].selfHeight+10
    end

    if #self.ItemList <=0 then
        self.boundary:SetActive(false)
    end



    self.transform.sizeDelta = Vector2(690,H)
    self.endHight = H
    self.endIndex = #self.ItemList
    self.transform.anchoredPosition = Vector2(0,0)
end

function PetEvaluationListPanel:CheckHasThumbs()
    for i1,v1 in ipairs(self.data) do
       for i2,v2 in ipairs(self.hasThumbData) do
            if v1.m_id == v2.m_id and v1.m_platform == v2.m_platform and v1.m_zone_id == v2.m_zone_id then
                v1.vote_type = v2.vote_type
                break
            end
       end
    end
end
-- 处理最热的表
function PetEvaluationListPanel:SetHotList()
    self.hotEndIndex = 0
    local H = 5

    local length =2
    local index = 0
    if #self.data<length then
        index = #self.data
    else
        index =length
    end

    for i=1,index do
        local go = GameObject.Instantiate(self.baseItem)
        go:SetActive(true)
        go.transform:Find("Icon").gameObject:SetActive(true)
        go.transform:SetParent(self.transform)
        go.transform.localScale = Vector3.one

        local Item = PetEvaluationItem.New(self,go,self.data[i])
        table.insert(self.hotList,Item)
    end

    for i,v in ipairs(self.hotList) do
        v.transform.anchoredPosition = Vector2(0,-H)
        H = H + v.selfHeight+10
    end

    self.boundary:SetActive(true)
    self.boundary.transform.anchoredPosition = Vector2(0,-H)
    H = H +self.boundary.transform.sizeDelta.y + 10
    self.hotEndIndex = index

    if index <= 0 then
            self.noEvaluation:SetActive(true)
    else
           self.noEvaluation:SetActive(false)
    end
    self.endHight = H
end

-- 重置
function PetEvaluationListPanel:ReCycle()
    for i,v in ipairs(self.ItemList) do
        if v.gameObject ~= nil then
            v.gameObject:SetActive(false)
        end
        table.insert(self.oldItemList, v)
    end

    for i,v in ipairs(self.hotList) do
        if v.gameObject ~= nil then
            v.gameObject:SetActive(false)
            v.transform:Find("Icon").gameObject:SetActive(false)
        end
        table.insert(self.oldItemList, v)
    end

    self.ItemList = {}
    self.hotList = {}
end

function PetEvaluationListPanel:GetOldItem(m_id)
    local item = nil
    local index = nil
    for i,v in ipairs(self.oldItemList) do
        if v.data ~= nil and v.data.m_id == m_id then
            item = v
            index = i
            break
        end
    end

    if index ~= nil then
        table.remove(self.oldItemList, index)
    end
    return item
end

function PetEvaluationListPanel:OnScroll(Top,Bot)
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

-- 下拉刷新(针对一次性给的全表)
function PetEvaluationListPanel:UpdateRefresh(data)
    self.data = data
    if  #self.data <= 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("没有更多内容了"))
        return
    end

    self:CheckHasThumbs()

    local length =10
    local index = 0
    if #self.data<length then
        index = #self.data
    else
        index =length
    end

    for i=1,index do
        local old = self:GetOldItem(self.data[i].id)
        if old == nil then
            local go = GameObject.Instantiate(self.baseItem)
            go:SetActive(true)
            go.transform:SetParent(self.transform)
            go.transform.localScale = Vector3.one

            local Item = PetEvaluationItem.New(self,go,self.data[i])
            table.insert(self.ItemList,Item)
        else
            table.insert(self.ItemList,old)
            if old.gameObject ~= nil then
                old.gameObject:SetActive(true)
            end
        end

         self.total = self.total + 1
         local H = self.endHight
         self.ItemList[self.endIndex + i].transform.anchoredPosition = Vector2(0,-H)
         H = H + self.ItemList[self.endIndex + i].selfHeight +10
         self.endHight = H

     end
     self.transform.anchoredPosition = Vector2(0,self.transform.sizeDelta.y -100)
     self.transform.sizeDelta = Vector2(690,self.endHight)
     self.endIndex = self.endIndex +index
end

-- 处理评论逻辑处理
function PetEvaluationListPanel:AddMyEvaluation(data,specialIds)
      self.noEvaluation:SetActive(false)
      local go = GameObject.Instantiate(self.baseItem)
      go:SetActive(true)
      go.transform:SetParent(self.transform)
      go.transform.localScale = Vector3.one

      local Item = PetEvaluationItem.New(self,go,data,specialIds)
      Item.transform.anchoredPosition = Vector2(0,-self.addHigth)

      local H =Item.transform.sizeDelta.y + 10
      for i,v in ipairs(self.ItemList) do
          v.transform.anchoredPosition = Vector2(0,v.transform.anchoredPosition.y - H)
      end

      table.insert(self.ItemList,1,Item)
      self.endHight = self.endHight + H
      self.endIndex = self.endIndex + 1
      self.transform.sizeDelta = Vector2(690,self.endHight)
      self.transform.anchoredPosition = Vector2(0,self.addHigth)
      self.boundary:SetActive(true)
end

function PetEvaluationListPanel:AddHasThumbList(data)
    table.insert(self.hasThumbData,data)
end

