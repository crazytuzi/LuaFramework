-- author:zzl
-- time:2016/11/18
-- 守护星阵加成提示

ShouhuWakeUpAttrTips  =  ShouhuWakeUpAttrTips or BaseClass(BasePanel)

function ShouhuWakeUpAttrTips:__init(model)
    self.name  =  "ShouhuWakeUpAttrTips"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.shouhu_wakeup_attr_tips, type  =  AssetType.Main}
        ,{file = AssetConfig.attr_icon, type = AssetType.Dep}
    }

    self.is_open = false
    return self
end

function ShouhuWakeUpAttrTips:__delete()
    self.is_open = false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function ShouhuWakeUpAttrTips:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shouhu_wakeup_attr_tips))
    self.gameObject:SetActive(false)
    self.gameObject.name = "ShouhuWakeUpAttrTips"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseShouhuWakeUpAttrTipsUI() end)

    self.MainCon = self.transform:FindChild("MainCon")
    self.TxtTitle = self.MainCon:FindChild("TitleCon"):FindChild("TxtTitle"):GetComponent(Text)
    local CloseBtn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseShouhuWakeUpAttrTipsUI() end)
    self.MidCon = self.MainCon:FindChild("MidCon")
    self.MaskCon = self.MidCon:FindChild("MaskCon")
    self.ScrollCon = self.MaskCon:FindChild("ScrollCon")
    self.Container = self.ScrollCon:FindChild("Container")
    self.AttrItem = self.Container:FindChild("AttrItem").gameObject

    self.BottomCon = self.MainCon:FindChild("BottomCon")
    self.TxtRecruitNum = self.BottomCon:FindChild("TxtRecruitNum"):GetComponent(Text)
    self.TxtScore = self.BottomCon:FindChild("TxtScore"):GetComponent(Text)
    self.BtnShare = self.BottomCon:FindChild("BtnShare"):GetComponent(Button)
    self.ShareCon = self.BottomCon:FindChild("ShareCon")
    self.BtnGuild = self.ShareCon:FindChild("BtnGuild"):GetComponent(Button)
    self.BtnWorld = self.ShareCon:FindChild("BtnWorld"):GetComponent(Button)

    self.showShare = false
    self.BtnShare.onClick:AddListener(function()
        self.showShare = not self.showShare
        self.ShareCon.gameObject:SetActive(self.showShare)
    end)

    self.BtnGuild.onClick:AddListener(function()
        if GuildManager.Instance.model:check_has_join_guild() then
            local role = RoleManager.Instance.RoleData
            local newStr = string.format("{guard_3,%s,%s,%s,%s}", role.id, role.zone_id, role.platform, role.name)
            ChatManager.Instance:Send10400(MsgEumn.ChatChannel.Guild, newStr)
            self.model:CloseShouhuWakeUpAttrTipsUI()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("尚未加入公会"))
        end
    end)
    self.BtnWorld.onClick:AddListener(function()
        local role = RoleManager.Instance.RoleData
            local newStr = string.format("{guard_3,%s,%s,%s,%s}", role.id, role.zone_id, role.platform, role.name)
            ChatManager.Instance:Send10400(MsgEumn.ChatChannel.World, newStr)
        self.model:CloseShouhuWakeUpAttrTipsUI()
    end)
    self.is_open = true

    if self.openArgs == nil then
        self.BtnShare.gameObject:SetActive(true)
        self:UpdateAttrList()
        self:UpdateBottomInfo()
    else
        self.BtnShare.gameObject:SetActive(false)
        self.TxtTitle.text = string.format("%s%s", self.openArgs.roleName, TI18N("的觉醒魂石"))
        ShouhuManager.Instance:request10917(self.openArgs.roleId, self.openArgs.platform, self.openArgs.zoneId)
    end
end

--根据协议返回更新显示内容
function ShouhuWakeUpAttrTips:UpdateWakeupAttrTips(data)
    if self.is_open == false then
        return
    end
    self.TxtRecruitNum.text = string.format(TI18N("已招募守护：<color='#00ffff'>%s</color>"), data.num)
    self.TxtScore.text = string.format(TI18N("守护评分：<color='#fffe9f'>%s</color>"), data.score)

    local list = {
        {name = 4, val = 0},
        {name = 6, val = 0},
        {name = 5, val = 0},
        {name = 7, val = 0},
        {name = 43, val = 0},
        {name = 3, val = 0},
        {name = 2, val = 0},
        {name = 1, val = 0}
    }

    for k, v in pairs(data.attrs) do
        for i = 1, #list do
            if list[i].name == v.name then
                list[i].val = list[i].val + v.val
            end
        end
    end

    local temp_sort = function(a,b)
        return a.name < b.name
    end
    table.sort(list, temp_sort)

    local index = 1
    for k, v in pairs(list) do
        local item = self:CreateAttrItem(index)
        self:SetAttrItem(item, v.name, v.val)
        index = index + 1
        item.gameObject:SetActive(true)
    end

    local len = index - 1
    local newH = 30*math.ceil(len/2)
    local rect = self.Container:GetComponent(RectTransform)
    rect.sizeDelta = Vector2(336, newH)
end

--初始化加成属性
function ShouhuWakeUpAttrTips:UpdateAttrList()
    local tempList = self.model:GetShouhuExtraList()
    local list = {}
    for k, v in pairs(tempList) do
        table.insert(list, {name = k, val  = v})
    end
    local temp_sort = function(a,b)
        return a.name < b.name
    end
    table.sort(list, temp_sort)

    local index = 1
    for i=1,#list do
        local data = list[i]
        local item = self:CreateAttrItem(index)
        self:SetAttrItem(item, data.name, data.val)
        index = index + 1
        item.gameObject:SetActive(true)
    end
    local len = index - 1
    local newH = 30*math.ceil(len/2)
    local rect = self.Container:GetComponent(RectTransform)
    rect.sizeDelta = Vector2(336, newH)
end

--设置底部已招募守护和守护评分
function ShouhuWakeUpAttrTips:UpdateBottomInfo()
    self.TxtRecruitNum.text = string.format(TI18N("已招募守护：<color='#00ffff'>%s</color>"), self.model:GetAllShouhuNum())
    self.TxtScore.text = string.format(TI18N("守护评分：<color='#fffe9f'>%s</color>"), self.model:GetAllShouhuScore())
end

--创建item
function ShouhuWakeUpAttrTips:CreateAttrItem(index)
    local item = {}
    item.gameObject = GameObject.Instantiate(self.AttrItem)
    item.transform = item.gameObject.transform
    item.transform:SetParent(self.AttrItem.transform.parent)
    item.transform.localScale = Vector3.one

    item.AttrTxt = item.transform:Find("AttrTxt"):GetComponent(Text)
    item.index = index

    local newX = index%2 ~= 0 and 19 or 187
    local newY = -30*((math.ceil(index / 2)-1))
    local rect = item.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(newX, newY)
    return item
end

--设置item数据
function ShouhuWakeUpAttrTips:SetAttrItem(item, key , val)
    item.transform:Find("ImgIcon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, string.format("AttrIcon%s", key))
    item.AttrTxt.text = string.format(TI18N("%s +%s"), KvData.attr_name[key], val)
end
