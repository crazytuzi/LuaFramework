-- 作者:jia
-- 5/3/2017 3:44:58 PM
-- 功能:套哇打开特效面板

DollsRandomOpenPanel = DollsRandomOpenPanel or BaseClass(BasePanel)
function DollsRandomOpenPanel:__init(parent, callback)
    self.parent = parent
    self.callback = callback
    self.resList = {
        { file = AssetConfig.dollsrandomopenpanel, type = AssetType.Main }
        ,{ file = string.format(AssetConfig.effect, 20360), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime() }
        ,{ file = string.format(AssetConfig.effect, 20373), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime() }
        ,{ file = AssetConfig.may_textures, type = AssetType.Dep }
    }
    self.hasInit = false
end

function DollsRandomOpenPanel:__delete()
    if self.timer1 ~= nil then
        LuaTimer.Delete(self.timer1)
        self.timer1 = nil
    end
    if self.timer2 ~= nil then
        LuaTimer.Delete(self.timer2)
        self.timer2 = nil
    end
    if self.timer3 ~= nil then
        LuaTime.Delete(self.timer3)
        self.timer3 = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function DollsRandomOpenPanel:OnHide()

end

function DollsRandomOpenPanel:OnOpen()

end

function DollsRandomOpenPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.dollsrandomopenpanel))
    self.gameObject.name = "DollsRandomOpenPanel"

    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.main.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.Panel = self.transform:Find("Panel")
    self.Main = self.transform:Find("Main")
    self.DollsImg = self.transform:Find("Main/DollsImg"):GetComponent(Image)
    local effectId = 20373;
    if DollsRandomManager.Instance.isAdvDolls then
        effectId = 20360
    end
    self.maxHappyEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, effectId)))
    self.maxHappyEffect.transform:SetParent(self.Main)
    self.maxHappyEffect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.maxHappyEffect.transform, "UI")
    self.maxHappyEffect.transform.localScale = Vector3(1, 1, 1)
    self.maxHappyEffect.transform.localPosition = Vector3(5, -320, -400)
    self:StartTimer()
end

function DollsRandomOpenPanel:StartTimer()
    local imgStr = "dolls_item1";
    if DollsRandomManager.Instance.isAdvDolls then
        imgStr = "dolls_item2"
    end
    self.DollsImg.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, imgStr)
    self.DollsImg.gameObject:SetActive(true)
    if self.timer1 ~= nil then
        LuaTimer.Delete(self.timer1)
        self.timer1 = nil
    end
    if self.timer2 ~= nil then
        LuaTimer.Delete(self.timer2)
        self.timer2 = nil
    end
    self.timer1 = LuaTimer.Add(600,
    function()
        self.DollsImg.gameObject:SetActive(false)
        self.timer1 = nil
    end )
    self.timer2 = LuaTimer.Add(1500,
    function()
        self:DeleteMe()
        self.timer2 = nil
    end )

    self.timer3 = LuaTimer.Add(800,
    function()
        if self.timer3 ~= nil then
            LuaTimer.Delete(self.timer3)
            self.timer3 = nil
        end
        if self.callback ~= nil then
            self.callback()
            self.callback = nil
        end
    end )
end