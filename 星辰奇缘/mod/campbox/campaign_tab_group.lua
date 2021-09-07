
CampaignTabGroup = CampaignTabGroup or BaseClass()
-- setting = {notAutoSelect, noCheckRepeat, openLevel, perWidth, perHeight, isVertical, spacing}
function CampaignTabGroup:__init(gameObject,buttonTab,callback,setting)
    self.gameObject = gameObject
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.callback = callback
    self.buttonTab = buttonTab
    self.indexButtonTab = {}
    self.currentIndex = 0

    self.notAutoSelect = setting.notAutoSelect

    self.perWidth = setting.perWidth or 0
    self.perHeight = setting.perHeight or 0
    self.offsetWidth = setting.offsetWidth or self.perWidth
    self.offsetHeight = setting.offsetHeight or self.perHeight

    --垂直
    self.isVertical = setting.isVertical
    self.spacing = setting.spacing or 3

    self:Init()

end


function CampaignTabGroup:Init()

    self.transform = self.gameObject.transform

    local length = 1
    for k,v in pairs(self.buttonTab) do
        v.obj:GetComponent(Button).onClick:AddListener(function() self:ChangeTab(k) end)
        local transform = v.obj.transform
        v.transform = transform

        v.rect = v.obj:GetComponent(RectTransform)

        v.normal = transform:Find("Normal").gameObject
        v.select = transform:Find("Select").gameObject
        v.normal:SetActive(true)
        v.select:SetActive(false)
        local red_transform = transform:Find("NotifyPoint")

        if red_transform ~= nil then
            v.red = red_transform.gameObject
        end

        local text_transform = transform:Find("Text")
        if text_transform ~= nil then
            v.text = text_transform:GetComponent(Text)
        end

        if transform:Find("Select/Text") ~= nil then
            v.selectTxt = transform:Find("Select/Text"):GetComponent(Text)
        end

        if transform:Find("Normal/Text") ~= nil then
            v.normalTxt = transform:Find("Normal/Text"):GetComponent(Text)
        end


    end

    self:Layout()

    self.num = self.indexButtonTab[1].campaignId
end

function CampaignTabGroup:ChangeTab(index)
    if self.currentIndex == index then
        return
    end

    if self.currentIndex ~= 0 then
        self:UnSelect(self.currentIndex)
    end

    self.currentIndex = index
    self:Select(self.currentIndex)

    if self.callback ~= nil then
        self.callback(index,special)
    end



end


function CampaignTabGroup:Select(index)
    local tab = self.buttonTab[index]
    if tab ~= nil then
        tab.normal:SetActive(false)
        tab.select:SetActive(true)
    end
end



function CampaignTabGroup:UnSelect(index)
    local tab = self.buttonTab[index]
    if tab ~= nil then
        tab.select:SetActive(false)
        tab.normal:SetActive(true)
    end
end


function CampaignTabGroup:ShowRed(index,bool)
    if self.buttonTab[index].red ~= nil then
        self.buttonTab[index].red :SetActive(bool)
    end
end


function CampaignTabGroup:ResetText(index,str)
    if self.buttonTab[index].text ~= nil then
        self.buttonTab[index].text = str
    end
end

function CampaignTabGroup:Layout()


    self.rect.pivot = Vector2(0,1)

    for k,v in pairs(self.buttonTab) do
        if v.active == true then
            table.insert(self.indexButtonTab,v)
            v.obj:SetActive(true)
        else
            v.obj:SetActive(false)
        end
    end



    if #self.indexButtonTab > 1 then
          table.sort(self.indexButtonTab,function(a,b)
               if a.index ~= b.index then
                    return a.index < b.index
                else
                    return false
                end
            end)
    end


    for i,v in ipairs(self.indexButtonTab) do
        if self.isVertical then
            v.transform.localPosition = - Vector3(0, (i - 1) * (self.perHeight + self.spacing) - self.offsetHeight / 2, 0)
        else
            v.transform.localPosition = Vector3((i - 1) * (self.perWidth + self.spacing) + self.offsetWidth / 2, 0, 0)
        end
    end


    if self.isVertical then
        self.rect.sizeDelta = Vector2(self.perWidth,#self.indexButtonTab * (self.perHeight + self.spacing))
    else
        self.rect.sizeDelta = Vector2(#self.indexButtonTab * self.perWidth, (self.perHeight + self.spacing))
    end
end
