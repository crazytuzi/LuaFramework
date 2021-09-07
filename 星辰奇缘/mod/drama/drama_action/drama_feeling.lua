--------------------------------
-- 剧情内心独白
-- lqg
-------------------------------
DramaFeeling = DramaFeeling or BaseClass(BaseDramaPanel)

function DramaFeeling:__init(callback)
    self.callback = callback
    self.transform = nil
    self.main = nil
    self.headimg = nil
    self.nametxt = nil
    self.context = nil
    self.nameobj = nil
    self.img_obj = nil

    self.isfade = false

    self.path = "prefabs/ui/drama/dramafeeling.unity3d"
    self.halfres = "textures/halflength.unity3d"

    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = self.halfres, type = AssetType.Dep},
    }

    self.delay = 0

    self.timeId = 0
end

function DramaFeeling:__delete()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.timeId = 0
end

function DramaFeeling:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject:SetActive(false)
    -- UIUtils.AddUIChild(DramaManager.Instance.model.dramaCanvas, self.gameObject)
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    self.mainObj = self.transform:Find("Main").gameObject
    self.mainTrans = self.mainObj.transform
    self.mainBtn = self.mainObj:GetComponent(Button)
    self.headimg = self.mainTrans:Find("HeadImg"):GetComponent(Image)
    self.nameobj = self.mainTrans:Find("Name").gameObject
    self.nametxt = self.mainTrans:Find("Name/Val"):GetComponent(Text)
    self.img_obj = self.mainTrans:Find("Name/Image"):GetComponent(Image)
    self.context = self.mainTrans:Find("Content"):GetComponent(Text)

    self.mainBtn.onClick:AddListener(function() self:Fade_out() end)
end

function DramaFeeling:OnInitCompleted()
    self:SetData(self.openArgs)
end

function DramaFeeling:SetData(action)
    local img = action.val
    local name = action.msg
    local content = action.ext_msg
    local time = action.time
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
    end
    self.delay = time
    self.mainObj.transform.localScale = Vector3.one * 0.5
    if img == 0 then
        img = string.format("half_%s%s", RoleManager.Instance.RoleData.classes, RoleManager.Instance.RoleData.sex)
        name = RoleManager.Instance.RoleData.name
    else
        img = string.format("half_%s", img)
    end
    self.headimg.sprite = self.assetWrapper:GetSprite(self.halfres, img)
    self.nameobj.transform.localPosition = Vector3(0, 32, 0)
    self.headimg.gameObject:SetActive(true)

    self.nametxt.text = name
    self.context.text = content
    self.headimg.color = Color(1, 1, 1, 1)
    self.img_obj.color = Color(1, 1, 1, 1)
    self.nametxt.color = Color(1, 1, 1, 1)
    self.context.color = Color(1, 1, 1, 1)
    self.gameObject:SetActive(true)
    self:Scale_big()
end

function DramaFeeling:Scale_big()
    Tween.Instance:Scale(self.mainObj, Vector3.one, 0.1, function() self:Scale_over() end)
end

function DramaFeeling:Scale_over()
    self.timeId = LuaTimer.Add(self.delay, function() self:Fade_out() end)
end

function DramaFeeling:Fade_out()
    if self.isfade then
        return
    end
    self.isfade = true
    Tween.Instance:Alpha(self.mainObj, 0, 0.3, function() self:Colorover() end)
end

function DramaFeeling:Colorover()
    self.mainObj:SetActive(false)
    if self.callback ~= nil then
        self.callback()
    end
end
