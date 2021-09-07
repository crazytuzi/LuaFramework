DanmakuItem = DanmakuItem or BaseClass()

function DanmakuItem:__init(model)
    self.model = model
    local item,index = self.model:GetItem()
    if item == nil then
        return
    end
    self.transform = item.transform
    -- UIUtils.AddUIChild(self.container, item)
    item.transform:SetParent(self.model.container.transform)
    item.transform.localScale = Vector3(1, 1, 1)
    local y = self.model:GetTunnel() * 30
    item.transform.localPosition = Vector3((480+338), y, 0)
    -- local r = Random.Range(1,  255)/255
    -- local g = Random.Range(1,  255)/255
    -- local b = Random.Range(1,  255)/255
    -- local h = Random.Range(1,  360)
    -- local rgbval = BaseUtils.HSB2RGB(h, 0.9, 0.75)
    local pos = item.transform.localPosition
    -- item.transform:GetComponent(Text).color = Color(r, g, b)
    self.transform:Find("Text"):GetComponent(Text).color = self:GetColor()
    self.transform:Find("Text"):GetComponent(Text).fontSize = Random.Range(22, 30)
    self.gameObject = item
    self.gameObject:SetActive(true)
end

function DanmakuItem:__delete()
    if self.transform == nil then
        return
    end
    self.model.itemPool[tonumber(self.gameObject.name)].using = false
    self.gameObject:SetActive(false)
end

function DanmakuItem:SetMsg(msg, type)
    if self.transform == nil then
        return
    end
    if type == 1 then
        local y = self.model:GetTunnel(1) * 30
        self.transform.localPosition = Vector3((480+338), y, 0)
        self.transform:Find("Text"):GetComponent(Text).fontSize = 17
        self.transform:Find("Bg").gameObject:SetActive(true)
        msg = string.gsub(msg, "{%l-_%d.-,(.-)}", "<color='#23f0f7'>%1</color>")
        self.transform:Find("Text"):GetComponent(Text).text = tostring(msg)
        self.transform:Find("Bg").sizeDelta = Vector2(self.transform:Find("Text"):GetComponent(Text).preferredWidth+102, 88)
    else
        self.transform:Find("Bg").gameObject:SetActive(false)
        self.transform:Find("Text"):GetComponent(Text).text = tostring(msg)
    end
end

function DanmakuItem:GetColor()
    local list = {
    [1] = {r = 255, g = 131, b = 242},
    [2] = {r = 255, g = 255, b = 255},
    [3] = {r = 248, g = 252, b = 147},
    [4] = {r = 148, g = 255, b = 151},
    [5] = {r = 107, g = 250, b = 255},
    [6] = {r = 120, g = 199, b = 255},
    [7] = {r = 255, g = 204, b = 94},
    }
    local index = Random.Range(1, 7)
    return Color(list[index].r/255, list[index].g/255, list[index].b/255)
end