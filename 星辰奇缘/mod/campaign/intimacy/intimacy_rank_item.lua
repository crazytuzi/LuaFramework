-- region *.lua
-- Date 加 2017-5-16
-- 此文件由[BabeLua]插件自动生成
-- 亲密度排行榜头像显示item
-- endregion
IntimacyRankItem = IntimacyRankItem or BaseClass()
function IntimacyRankItem:__init(origin_item, _index, rankType)
    self.index = _index
    self.gameObject = GameObject.Instantiate(origin_item)
    self.transform = self.gameObject.transform
    self.transform:SetParent(origin_item.transform.parent)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.gameObject:SetActive(true)

    self.rankType = rankType

    self.chr_name1 = self.transform:Find("Character1/chr_name"):GetComponent(Text)
    self.chr_name2 = self.transform:Find("Character2/chr_name"):GetComponent(Text)
    self.chr_name1.text = TI18N("虚位以待")
    self.chr_name2.text = TI18N("虚位以待")
    self.headicon1 = self.transform:Find("Character1/HeadCon")
    self.headicon2 = self.transform:Find("Character2/HeadCon")

    self.default1 = self.transform:Find("Character1/chr_icon")
    self.default2 = self.transform:Find("Character2/chr_icon")

    self.headSlot1 = HeadSlot.New()
    self.headSlot2 = HeadSlot.New()

    self.headSlot1:SetRectParent(self.headicon1.gameObject)
    self.headSlot2:SetRectParent(self.headicon2.gameObject)

    self.ImgRankIndex = self.transform:Find("ImgRank/ImgRankIndex"):GetComponent(Image)
    self.ImgRankBg =  self.transform:Find("ImgRank"):GetComponent(Image)
    local newX = 0;
    if self.index == 1 then
        newX = 275
    elseif self.index == 2 then
        newX = 100
    else
        newX = 450
    end
    self.transform:GetComponent(RectTransform).anchoredPosition = Vector2(newX, -40)
    self.hasInit = false
    self.headslots = nil
    self.rankData = nil
end

function IntimacyRankItem:__delete()
    if self.headSlot1 ~= nil then
        self.headSlot1:DeleteMe()
        self.headSlot1 = nil
    end
    if self.headSlot2 ~= nil then
        self.headSlot2:DeleteMe()
        self.headSlot2 = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
end
--            TipsManager.Instance:ShowPlayer({id = data_cpy.role_id, zone_id = data_cpy.zone_id, platform = data_cpy.platform, sex = data_cpy.sex, classes = data_cpy.classes, name = data_cpy.name, guild = data_cpy.desc, lev = data.lev})

function IntimacyRankItem:SetData(data)
    self.rankData = data
    if self.rankType == nil then 
        self.rankType = WorldLevManager.Instance.CurRankType
    end

    --data为空也必须处理位置
    if self.rankType == CampaignEumn.CampaignRankType.Intimacy then
        self.transform:Find("Character2").gameObject:SetActive(true)
        self.transform:Find("ImgFlower").gameObject:SetActive(true)
        self.transform:Find("Character1"):GetComponent(RectTransform).anchoredPosition = Vector2(-40, 13)
    elseif self.rankType == CampaignEumn.CampaignRankType.ConSume then
        self.transform:Find("Character2").gameObject:SetActive(false)
        self.transform:Find("ImgFlower").gameObject:SetActive(false)
        self.transform:Find("Character1"):GetComponent(RectTransform).anchoredPosition = Vector2(0, 13)
        self.transform:Find("Character1/Image"):GetComponent(RectTransform).anchoredPosition = Vector2(0, -50)
        self.transform:Find("Character1/chr_name"):GetComponent(RectTransform).anchoredPosition = Vector2(0, -50)
        self.transform:Find("ImgRank"):GetComponent(RectTransform).anchoredPosition = Vector2(0, -68)
    else
        self.transform:Find("Character2").gameObject:SetActive(false)
        self.transform:Find("ImgFlower").gameObject:SetActive(false)
        self.transform:Find("Character1"):GetComponent(RectTransform).anchoredPosition = Vector2(0, 13)
    end

    if self.rankData == nil then
        self.default1.gameObject:SetActive(true)
        self.default2.gameObject:SetActive(true)
        return
    end
    self.default1.gameObject:SetActive(false)
    self.default2.gameObject:SetActive(false)
    local data1 = { };
    local data2 = { };

    data1.sex = self.rankData.sex
    data1.classes = self.rankData.classes
    data1.name = self.rankData.name
    data1.id = self.rankData.role_id
    data1.platform = self.rankData.platform
    data1.zone_id = self.rankData.zone_id
    data1.lev = self.rankData.lev
    self.headSlot1:SetAll(data1, {
        isSmall = true,
        clickCallback =
        function()
            TipsManager.Instance:ShowPlayer( { id = data1.id, zone_id = data1.zone_id, platform = data1.platform, sex = data1.sex, classes = data1.classes, name = data1.name, lev = data1.lev })
        end
    } )
    self.chr_name1.text = data1.name

    data2.sex = self.rankData.sex2
    data2.classes = self.rankData.classes2
    data2.name = self.rankData.name2
    data2.id = self.rankData.role_id2
    data2.platform = self.rankData.platform2
    data2.zone_id = self.rankData.zone_id2
    data2.lev = self.rankData.lev2
    self.headSlot2:SetAll(data2, {
        isSmall = true,
        clickCallback =
        function()
            TipsManager.Instance:ShowPlayer( { id = data2.id, zone_id = data2.zone_id, platform = data2.platform, sex = data2.sex, classes = data2.classes, name = data2.name, lev = data2.lev })
        end
    } )
    self.chr_name2.text = data2.name
    

    --头像信息后处理
    if self.rankType == CampaignEumn.CampaignRankType.ConSume then
        self.headSlot1.isActiveFrame = true
        self.headSlot1.setting.myCallBack = function(info) 
            info = info or {}
            info[5] = 50020   --累消排行榜活动头像框50020
            self.headSlot1:SetPurePortrait(info)
        end
        
        local info = PortraitManager.Instance:GetInfos(self.rankData.role_id, self.rankData.platform, self.rankData.zone_id) or {}
        info[5] = 50020 
        self.headSlot1:SetPurePortrait(info)
    end
end
