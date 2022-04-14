-- 
-- @Author: LaoY
-- @Date:   2018-08-02 11:14:56
-- 
SceneObjectText = SceneObjectText or class("SceneObjectText", BaseWidget)

SceneObjectText.__cache_count = 30

function SceneObjectText:ctor()
    self.abName = "system"
    self.assetName = "SceneObjectText"
    self.parent_node = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneText)
    self.builtin_layer = LayerManager.BuiltinLayer.Default

    self.position = { x = 0, y = 0, z = 0 }
    self.top_icon_radius = 17.5
    self.angry_icon_radius = 14.5
    self.events = {}

    BaseWidget.Load(self)
end

function SceneObjectText:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.events = {}

    --destroy(self.gameObject)
    --self.gameObject = nil
    if self.blood then
        self.blood:destroy();
    end

    if self.countdowntext then
        self.countdowntext:destroy();
    end

    if self.boomText then
        self.boomText:destroy();
    end

    if self.buff_img and self.buff_img.gameObject then
        if not poolMgr:AddGameObject("system","EmptyImage",self.buff_img.gameObject) then
            destroy(self.buff_img.gameObject)
        end
        self.buff_img.gameObject = nil
    end
    self.buff_img = nil
end

function SceneObjectText:__reset()
    self.parent_node = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneText)
    SceneObjectText.super.__reset(self);
    self:HideBuffImage()

    self:SetVisible(true)
end

function SceneObjectText:LoadCallBack()
    self.nodes = {
        "name",
    }
    self:GetChildren(self.nodes)

    self.name_text = self.name:GetComponent('Text')
    self.text_outline = self.name:GetComponent('Outline')

    self:SetVisible(true)
    self:AddEvent();
end

function SceneObjectText:AddEvent()
    --self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.HandleSceneChange));
end

function SceneObjectText:SetName(name)
    --if name == "" then
    --    self:SetVisible(false)
    --    return
    --end
    self.name_text.text = name or "Monster"
    SetVisible(self.name_text, true)
    self:UpdateNamePos()
end
function SceneObjectText:ShowName(bool)
    bool = toBool(bool);
    SetGameObjectActive(self.name_text, false);
end

function SceneObjectText:UpdateNamePos()
    self.name_width = self.name_text.preferredWidth
    self.name_x = self.name_width * 0.5

    SetLocalPositionX(self.name, 0)
end

function SceneObjectText:SetColor(color, outline_color)
    if color then
        SetColor(self.name_text, color.r, color.g, color.b, color.a)
    end
    if outline_color then
        SetOutLineColor(self.text_outline, outline_color.r, outline_color.g, outline_color.b, outline_color.a)
    end
end

function SceneObjectText:SetGlobalPosition(x, y, z)
    self.position = { x = x, y = y, z = z }
    SetGlobalPosition(self.transform, x, y, z)
end

function SceneObjectText:SetBuffImage(abName, res)
    if not self.buff_img then
        local go = PreloadManager:GetInstance():CreateWidget("system", "EmptyImage")
        local transform = go.transform
        transform:SetParent(self.transform)
        SetLocalPosition(transform, 0, 50, 0)
        SetLocalScale(transform, 1, 1, 1)
        SetSizeDelta(transform, 50, 50)
        transform.name = "buff_img"
        local img = transform:GetComponent('Image')
        self.buff_img = { transform = transform, gameObject = go, img = img }
    end
    local function callBack(sprite)
        self.buff_img.img.sprite = sprite
        -- 算位置

    end
    SetVisible(self.buff_img.transform, true)
    lua_resMgr:SetImageTexture(self, self.buff_img.img, abName, res, false, callBack)
end

function SceneObjectText:HideBuffImage()
    if not self.is_dctored and self.buff_img then
        SetVisible(self.buff_img.transform, false)
    end
end

function SceneObjectText:SetGlobalPosition(x, y, z)
    self.position = { x = x, y = y, z = z }
    SetGlobalPosition(self.transform, x, y, z)
end
