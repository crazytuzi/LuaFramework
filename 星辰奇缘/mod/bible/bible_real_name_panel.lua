BibleRealNamePanel = BibleRealNamePanel or BaseClass(BasePanel)

function BibleRealNamePanel:__init(model, parent)
    self.model = model
    self.parent = parent

    self.resList = {
        {file = AssetConfig.bible_real_name_panel, type = AssetType.Main},
        {file = AssetConfig.wingsbookbg, type = AssetType.Dep},
        {file = AssetConfig.rolebgnew, type = AssetType.Dep},
    }

    self.powers = {7,9,10,5,8,4,2,1,6,3,7,9,10,5,8,4,2}
    self.parityBit = {"1","0","X","9","8","7","6","5","4","3","2"}

    self.floatCounter = 0

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function BibleRealNamePanel:__delete()
    self.OnHideEvent:Fire()
    if self.model.giftPreview ~= nil then
        self.model.giftPreview:DeleteMe()
        self.model.giftPreview = nil
    end
    self:AssetClearAll()
end

function BibleRealNamePanel:InitPanel()
    --Log.Error("BibleRealNamePanel:InitPanel")
    local model = self.model
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_real_name_panel))
    self.gameObject.name = "RealNamePanel"
    -- NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    self.BottomCon = self.transform:Find("MainPanel/BottomCon")
    self.BtnRealName = self.BottomCon:Find("BtnRealName"):GetComponent(Button)

    self.ItemName = self.BottomCon:Find("ItemName")
    self.InputFieldName = self.ItemName:Find("InputFieldName"):GetComponent(InputField)
    self.InputFieldName.contentType = 0
    self.InputFieldName.textComponent  =  self.ItemName:Find("InputFieldName"):FindChild("Text").gameObject:GetComponent(Text)
    self.InputFieldName.placeholder  =  self.ItemName:Find("InputFieldName"):FindChild("Placeholder").gameObject:GetComponent(Graphic)

    self.ItemPerson = self.BottomCon:Find("ItemPerson")
    self.InputFieldPerson = self.ItemPerson:Find("InputFieldPerson"):GetComponent(InputField)
    self.InputFieldPerson.textComponent  =  self.ItemPerson:Find("InputFieldPerson"):FindChild("Text").gameObject:GetComponent(Text)
    self.InputFieldPerson.placeholder  =  self.ItemPerson:Find("InputFieldPerson"):FindChild("Placeholder").gameObject:GetComponent(Graphic)

    self.BtnRealName.onClick:AddListener(function()
        local valid = self:ValidId(self.PersonStr)
        if valid then
            RoleManager:Send10031(self.NameStr, self.PersonStr)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("请输入正确的身份证号码"))
        end
    end)

    self.NameStr = ""
    self.PersonStr = ""
    self.InputFieldName.onEndEdit:AddListener(function(val)
        self.NameStr = val
        -- local totalLen = #StringHelper.ConvertStringTable(val)
        -- if totalLen > 1 then
        --     local prefix = StringHelper.ConvertStringTable(val)[1]
        --     self.InputFieldName.text = self:ConvertString(val, prefix, 1, totalLen)
        --     -- self.ItemName:Find("InputFieldName"):FindChild("Text"):GetComponent(Text).text = self:ConvertString(val, prefix, 1, totalLen)
        -- else
        --     self.InputFieldName.text = val
        --     -- self.ItemName:Find("InputFieldName"):FindChild("Text"):GetComponent(Text).text = val
        -- end
    end)


    self.InputFieldPerson.contentType = InputField.ContentType.Standard
    self.InputFieldPerson.onEndEdit:AddListener(function(val)
        self.PersonStr = val
        -- local totalLen = string.len(val)
        -- if totalLen > 4 then
        --     local prefix = string.sub(val, 1, 4)
        --     self.InputFieldPerson.text = self:ConvertString(val, prefix, 4, totalLen)
        --     -- self.ItemPerson:Find("InputFieldPerson"):FindChild("Text"):GetComponent(Text).text = self:ConvertString(val, prefix, 4, totalLen)
        -- else
        --     self.InputFieldPerson.text = val
        --     -- self.ItemPerson:Find("InputFieldPerson"):FindChild("Text"):GetComponent(Text).text = val
        -- end
    end)

    self.transform:Find("MainPanel/TopCon/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.transform:Find("MainPanel/TopCon/Bg1"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")
    self.transform:Find("MainPanel/TopCon/Icon"):GetComponent(Button).onClick:AddListener(function() self:ShowGifts() end)
    self.transform:Find("MainPanel/TopCon/Text").anchoredPosition = Vector2(93,13)
    self.transform:Find("MainPanel/TopCon/Text").sizeDelta = Vector2(332, 145)
    self.transform:Find("MainPanel/TopCon/Text"):GetComponent(Text).text = TI18N([[1.根据<color='#ffff00'>《网络游戏管理暂行办法》</color>，请登记本人实名信息
2.实名认证信息只能<color='#ffff00'>填写一次</color>，认证成功后<color='#ffff00'>无法修改</color>
3.认证成功后即可获得<color='#ffff00'>实名认证礼盒</color>]])

    self.iconTrans = self.transform:Find("MainPanel/TopCon/Icon")

    self:OnOpen()
end

--超过规定长度的转成*
function BibleRealNamePanel:ConvertString(val, prefix, limitLen, totalLen)
    for i = 1, totalLen - limitLen do
        prefix = string.format("%s*", prefix)
    end
    return prefix
end


--检查身份证号码合法性
function BibleRealNamePanel:ValidId(id)
    if id == "" then
        return false
    end
    local valid = false
    if string.len(id) == 15 then --检查长度15的身份证号码
         valid = self:ValidId15(id)
    elseif string.len(id) == 18 then --检查长度18的身份证号码
         valid = self:ValidId18(id)
    end
    return valid
end

--校验18位的身份证号码
function BibleRealNamePanel:ValidId18(id)
    local num = string.sub(id, 1, 18)
    local lastNum = string.sub(id, 18, 18) -- id.substr(17)
    local power = 0
    for i = 1, 17 do --加权
        local tempNum = tonumber(string.sub(num, i, i))
        power = power + tonumber(tempNum) * tonumber(self.powers[i])
    end
    --取模
    local mod = tonumber(power) % 11 + 1
    if self.parityBit[mod] == lastNum then
        return true
    end
    return false
end


--校验15位的身份证号码
function BibleRealNamePanel:ValidId15(id)
    --110105710923582
    --校验年份位
    local year = string.sub(id, 7, 8) --id.substr(6,2)
    local month = string.sub(id, 9, 10) --id.substr(8,2)
    local day = string.sub(id, 11, 12) --id.substr(10,2)
    local headYear = tonumber(string.sub(year, 1, 1))
    local tailYear = tonumber(string.sub(year, 2, 2))
    local headMonth = tonumber(string.sub(month, 1, 1))
    local tailMonth = tonumber(string.sub(month, 2, 2))
    local headDay = tonumber(string.sub(day, 1, 1))
    local tailDay = tonumber(string.sub(day, 2, 2))
    if (headYear == 0 and tailYear == 0) or (headYear == 9 and tailYear > 0) then
        --校验年
        return false
    end
    if (headMonth == 0 and tailMonth == 0) or (headMonth == 1 and tailYear > 2) or headMonth > 1 then
        --校验月
        return false
    end
    if (headDay == 0 and tailDay == 0) or (headDay == 3 and tailDay > 1) or headDay > 3 then
        --校验日
        return false
    end
    return true
end

function BibleRealNamePanel:ShowGifts(datalist)
    -- if self.model.giftPreview == nil then
    --     self.model.giftPreview = GfitPreview.New(self.model.bibleWin)
    -- end
    -- self.model.giftPreview:Show({reward = datalist, autoMain = true, text = TI18N("")})

    NoticeManager.Instance:FloatTipsByString(TI18N("完成实名认证即可获得<color='#ffff00'>实名认证礼盒</color>哦{face_1,3}"))
end

function BibleRealNamePanel:OnOpen()
    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 16, function() self:FloatIcon() end)
    end
end

function BibleRealNamePanel:FloatIcon()
    self.floatCounter = self.floatCounter + 1
    self.iconTrans.anchoredPosition = Vector2(-176, 6 + 10 * math.sin(self.floatCounter * math.pi / 90 * 1.5))
end

function BibleRealNamePanel:OnHide()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end