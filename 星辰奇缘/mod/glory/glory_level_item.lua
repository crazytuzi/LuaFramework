-- @author 黄耀聪
-- @date 2017年6月22日, 星期四

GloryLevelItem = GloryLevelItem or BaseClass()

function GloryLevelItem:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper

    self.transform = gameObject.transform

    local t = self.transform

    self.iconImage = t:Find("Icon"):GetComponent(Image)
    self.select = t:Find("Icon/Select").gameObject
    self.selectImage = self.select:GetComponent(Image)
    self.numberContainer = t:Find("NumContainer")
    self.levelBg = t:Find("LevelBg")
    self.levelBgImage = self.levelBg:GetComponent(Image)

    self.select:SetActive(false)

    self.digitList = {
        self.numberContainer:GetChild(0):GetComponent(Image),
        self.numberContainer:GetChild(1):GetComponent(Image),
        self.numberContainer:GetChild(2):GetComponent(Image),
    }

    self.digitLayout = LuaBoxLayout.New(self.numberContainer, {axis = BoxLayoutAxis.X, cspacing = 0, border = 0})

    self.clickCallback = nil

    self.iconImage.gameObject:GetComponent(Button).onClick:AddListener(function() self:OnClick() end)
end

function GloryLevelItem:__delete()
    if self.digitList ~= nil then
        for _,v in pairs(self.digitList) do
            if v ~= nil then
                v.sprite = nil
            end
        end
    end
    if self.digitLayout ~= nil then
        self.digitLayout:DeleteMe()
        self.digitLayout = nil
    end
    self.model.selectLevelObj = nil
    self.clickCallback = nil
    self.assetWrapper = nil
    self.gameObject = nil
    self.model = nil
end

function GloryLevelItem:update_my_self(data, index)
    self.data = data

    -- 数字显示
    local tab = {}
    local num = data.lev
    while num > 0 do
        table.insert(tab, 1, tostring(num % 10))
        num = math.floor(num / 10)
    end
    if #tab == 0 then
        tab[1] = "0"
    end
    self.digitLayout:ReSet()
    for i,v in ipairs(tab) do
        if self.digitList[i] == nil then
            local obj = GameObject.Instantiate(self.digitList[1].gameObject)
            self.digitList[i] = obj:GetComponent(Image)
        end
        local sprite = self.assetWrapper:GetTextures(AssetConfig.minnumber_1, v)
        self.digitList[i].sprite = sprite
        self.digitList[i].transform.sizeDelta = sprite.textureRect.size
        self.digitLayout:AddCell(self.digitList[i].gameObject)
    end
    for i=#tab+1,#self.digitList do
        self.digitList[i].gameObject:SetActive(false)
    end
    self.levelBg.sizeDelta = Vector2(44 + self.digitLayout.panelRect.sizeDelta.x, 24)
end

function GloryLevelItem:SetData(data, index)
    self:update_my_self(data, index)
end

function GloryLevelItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function GloryLevelItem:SetAlpha(alpha)
    self.selectImage.color = Color(1, 1, 1, alpha)
    self.iconImage.color = Color(1, 1, 1, alpha)
    self.levelBgImage.color = Color(1, 1, 1, alpha)
    for _,v in pairs(self.digitList) do
        v.color = Color(1, 1, 1, alpha)
    end
end

function GloryLevelItem:OnClick()
    if self.model.selectLevelObj ~= nil then
        self.model.selectLevelObj:SetActive(false)
    end
    self.select:SetActive(true)
    self.model.selectLevelObj = self.select
    self.model.selectLevelData = self.data

    if self.clickCallback ~= nil then
        self.clickCallback(self.data.lev)
    end
end


