TopItem = TopItem or BaseClass()

-- local product = {
-- {key = 21508,val = 1,weight = 100,classes = 1},
-- {key = 21500,val = 1,weight = 100,classes = 2},
-- {key = 21506,val = 1,weight = 100,classes = 3},
-- {key = 21508,val = 1,weight = 100,classes = 4},
-- {key = 21504,val = 1,weight = 100,classes = 5}}

function TopItem:__init(gameObject, index, main)
    self.baseproduct = DataSkillLife.data_diao_wen["10007_10"].product
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.giveMgr = GivepresentManager.Instance
    self.assetWrapper = main.assetWrapper
    self.main = main
    self.index = index
    self:RefreshData()
end

function TopItem:RefreshData()
    self.data = self.main.topItemList[self.index]
    local item = self.transform
    local diaowenID = SkillManager.Instance.model:get_diaowen_classes_produce()
    item:GetComponent(Button).onClick:RemoveAllListeners()
    if self.data ~= nil then
        -- print(self.index)
        if self.data.data ~= nil and self.data.data.step > 0 then
            -- local basdata = DataItem.data_get[self.data.base_id]
            -- if self.data.base_id == 0 then
            --     basdata = DataItem.data_get[diaowenID]
            -- end
            item:Find("LvImg").gameObject:SetActive(true)
            item:Find("LvImg/Text"):GetComponent(Text).text = "Lv."..tostring(self.data.data.step)
        else
            item:Find("LvImg").gameObject:SetActive(false)
        end
        if self.data.base_id ~= 0 then
            self.main:GetIcon(item:Find("Icon").gameObject, self.data.base_id, self.data.data)
            item:Find("NumImg/NumText"):GetComponent(Text).text = tostring(self.data.num)
            item:GetComponent(Button).onClick:AddListener(function() self:Onclick() end)
        else
            if diaowenID == nil then
                item:Find("ClickImg/Text"):GetComponent(Text).text = TI18N("点击学习")
                item:GetComponent(Button).onClick:AddListener(function() self:Onclick(true) end)
            else
                item:Find("ClickImg/Text"):GetComponent(Text).text = TI18N("点击制作")
                item:GetComponent(Button).onClick:AddListener(function() self:Onclick() end)
            end
            local key = 1
            for i,v in ipairs(self.baseproduct) do
                if v.classes == RoleManager.Instance.RoleData.classes then
                    key = v.key
                end
            end
            self.main:GetIcon(item:Find("Icon").gameObject, key, self.data.data)
            item:Find("NumImg/NumText"):GetComponent(Text).text = tostring(self.data.num)

        end
    else
        item:Find("LvImg").gameObject:SetActive(false)
    end
    item:Find("Icon").gameObject:SetActive(self.data ~= nil)
    -- item:Find("ClickImg").gameObject:SetActive(self.data ~= nil and self.data.num <= 0 and self.index == 1)
    item:Find("ClickImg").gameObject:SetActive(false)
    item:Find("NumImg").gameObject:SetActive((self.data ~= nil and self.data.base_id ~= 0) or (self.data ~= nil and self.data.base_id == 0 and self.data.num>0))
end

function TopItem:Onclick(learn)
    if learn then
        SkillManager.Instance.model:OpenSkillWindow({3})
        return
    end
    if self.main.maxNum - self.main.itemSelect_num <= 0 and (self.giveMgr:IsLimited(self.data.base_id) or self.data.base_id == 0 or (self.data.data ~= nil and self.giveMgr:IsLimited(self.data.data.base_id))) then
        NoticeManager.Instance:FloatTipsByString(TI18N("今天赠送次数已满"))
        return
    end
    if self.data.num>0 then
        self.main:AddToBotItem(self.data.base_id, 1, self.data.data)
    elseif self.index == 1  and self.data.base_id == 0 then
        self.main:MakeDiaowen()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("没有更多了"))
    end
end
