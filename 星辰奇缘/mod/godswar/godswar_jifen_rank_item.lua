-- ---------------------------------
-- 诸神之战 荣誉积分排行榜item
-- hosr
-- ---------------------------------
GodsWarJiFenRankItem = GodsWarJiFenRankItem or BaseClass()

function GodsWarJiFenRankItem:__init(gameObject, parent,parentAssetWrapper)
    self.gameObject = gameObject
    self.parent = parent
    self.assetWrapper = parentAssetWrapper

    self.captin = nil
    self.maxLev = 0
    self.maxFight = 0

    self:InitPanel()
end

function GodsWarJiFenRankItem:__delete()
    if self.headSlot ~= nil then
        self.headSlot:DeleteMe()
    end
end

function GodsWarJiFenRankItem:InitPanel()
    self.transform = self.gameObject.transform
    self.transformImg = self.gameObject.transform:GetComponent(Image)

    self.head = self.transform:Find("Head")
    self.name = self.transform:Find("Name"):GetComponent(Text)
    self.jiFen = self.transform:Find("JiFen"):GetComponent(Text)
    self.jiFenName = self.transform:Find("JiFenName"):GetComponent(Text)
    self.num = self.transform:Find("Num"):GetComponent(Text)
    self.numImage = self.transform:Find("NumImage"):GetComponent(Image)
    self.classes = self.transform:Find("Classes"):GetComponent(Text)
    self.headSlot = HeadSlot.New()
    NumberpadPanel.AddUIChild(self.head.transform, self.headSlot.gameObject)
    self.select = self.transform:Find("Select").gameObject

    self.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickSelf() end)
end

function GodsWarJiFenRankItem:update_my_self(data,i)
    self.data = data
    self.index = tonumber(i)
    self.num.text = i

    self.jiFen.text = self.data.gods_duel_score
    self.name.text = self.data.name
    local jiFenIndex =  #DataGodsDuel.data_name
    for i,v in ipairs(DataGodsDuel.data_name) do
        if self.data.gods_duel_score < v.jifen then
            jiFenIndex = i - 1
            break
        end
    end
    if jiFenIndex == 0 then
        jiFenIndex = 1
    end
    self.jiFenName.text = DataGodsDuel.data_name[jiFenIndex].jifen_name
    self.classes.text = KvData.classes_name[data.classes]
    if self.index == 1 or self.index == 2 or self.index == 3 then
        self.num.gameObject:SetActive(false)
        self.numImage.sprite =  self.assetWrapper:GetSprite(AssetConfig.godswartexture,"place_" .. self.index)
        self.numImage.gameObject:SetActive(true)

    else
        self.numImage.gameObject:SetActive(false)
        self.num.gameObject:SetActive(true)
    end



     local headData = {
        id = data.rid,
        platform = data.platform,
        zone_id = data.zone_id,
        sex = data.sex,
        classes = data.classes,
    }
    self.headSlot:SetAll(headData,{isSmall = true})
    if i%2 == 0 then
        self.transformImg.color = Color(154/255,198/255,241/255,1)
    else
        self.transformImg.color = Color(127/255,178/255,235/255,1)
    end
end

function GodsWarJiFenRankItem:Select(bool)
    self.select:SetActive(bool)
end

function GodsWarJiFenRankItem:ClickSelf()
    if self.parent ~= nil then
        self.parent:Select(self)
    end
end