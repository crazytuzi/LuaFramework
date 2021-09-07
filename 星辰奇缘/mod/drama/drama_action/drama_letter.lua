-------------------------------
-- 剧情飞信效果
-- lqg
--------------------------------
DramaLetter = DramaLetter or BaseClass(BaseDramaPanel)

function DramaLetter:__init(callback)
    self.callback = callback
    self.contents = {
        TI18N("诸位学员："),
        TI18N("守护盖亚大陆的<color='#f410a1'>星辰石</color>即将陆续现世，关乎大陆生死存亡"),
        TI18N("若有机缘遇见，千万不容错过"),
        TI18N("肖恩教授")
    }

    self.flystr = "prefabs/effect/20012.unity3d"
    self.fly = nil
    self.delay = 3
    self.uistr = "prefabs/ui/drama/dramaletter.unity3d"
    self.ui = nil
    self.fingerstr = "prefabs/effect/20089.unity3d"
    self.finger = nil

    self.bgimg = nil
    self.bg = nil
    self.txt0 = nil
    self.txt1 = nil
    self.txt2 = nil
    self.txt3 = nil
    self.container = nil
    self.script = nil
    self.mask_obj = nil

    self.txt_table = nil
    self.txt_step = 0

    self.step = 0
    self.timeId = 0

    self.stones = nil
    self.slot_step = 0

    self.resList = {
        {file = self.uistr, type = AssetType.Main}
        ,{file = self.flystr, type = AssetType.Main}
        ,{file = self.fingerstr, type = AssetType.Main}
    }

    self.OneByOne = DramaOneByOne.New()
end

function DramaLetter:__delete()
    -- print("dramaletter:__delete")
    self.fly:SetActive(false)
    GameObject.Destroy(self.fly)
    GameObject.Destroy(self.finger)
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    if self.OneByOne ~= nil then
        self.OneByOne:DeleteMe()
        self.OneByOne = nil
    end
end

function DramaLetter:InitPanel()
    self.fly = GameObject.Instantiate(self:GetPrefab(self.flystr))
    self.fly:SetActive(false)
    local transform = self.fly.transform
    -- transform:SetParent(DramaManager.Instance.model.dramaCanvas.transform)
    transform.localScale = Vector3.one
    transform.localPosition = Vector3.zero

    self.finger = GameObject.Instantiate(self:GetPrefab(self.fingerstr))
    self.finger:SetActive(false)
    transform = self.finger.transform
    transform:SetParent(DramaManager.Instance.model.dramaCanvas.transform)
    transform.localScale = Vector3.one
    transform.localPosition = Vector3.zero

    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.uistr))
    self.gameObject:SetActive(false)
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(DramaManager.Instance.model.dramaCanvas, self.gameObject)
    self.panelBtn = self.gameObject:GetComponent(Button)
    self.mainObj = self.transform:Find("Main").gameObject
    local transform = self.mainObj.transform
    transform.localScale = Vector3.one * 0.5

    self.txt0 = transform:Find("Text0"):GetComponent(Text)
    self.txt1 = transform:Find("Text1"):GetComponent(Text)
    self.txt2 = transform:Find("Text2"):GetComponent(Text)
    self.txt3 = transform:Find("Text3"):GetComponent(Text)
    self.slot1 = transform:Find("Slots/Slot1").gameObject
    self.slotImg1 = self.slot1.transform:Find("Image"):GetComponent(Image)
    self.slot2 = transform:Find("Slots/Slot2").gameObject
    self.slotImg2 = self.slot2.transform:Find("Image"):GetComponent(Image)
    self.slot3 = transform:Find("Slots/Slot3").gameObject
    self.slotImg3 = self.slot3.transform:Find("Image"):GetComponent(Image)

    self.slot1.transform.localScale = Vector3.one * 2.5
    self.slot2.transform.localScale = Vector3.one * 2.5
    self.slot3.transform.localScale = Vector3.one * 2.5

    self.mainObj:SetActive(false)
    self.slot1:SetActive(false)
    self.slot2:SetActive(false)
    self.slot3:SetActive(false)

    self:ClearMainAsset()
end

function DramaLetter:OnInitCompleted()
    self:Begin()
end

function DramaLetter:Click()
    DramaManager.Instance.model.dramaMask:BlackPanel(false)
    self.gameObject:SetActive(false)
    self.finger:SetActive(false)
    self.fly:SetActive(false)
    if self.callback ~= nil then
        self.callback()
    end
end

function DramaLetter:Begin()
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
    end
    self.step = self.step + 1
    if self.step == 1 then
        DramaManager.Instance.model:ShowJump(false)
        DramaManager.Instance.model.dramaMask:BlackPanelVal(0.5)
        self.fly:SetActive(true)
        self.timeId = LuaTimer.Add(3000, function() self:Begin() end)
    elseif self.step == 2 then
        self:ScaleBg()
    elseif self.step == 3 then
        self.txt_step = 0
        self:Input_txt1()
    elseif self.step == 4 then
        self.stones = nil
        self.slot_step = 0
        self:Duangduangduang()
    elseif self.step == 5 then
        self.txt_step = 0
        self:Input_txt2()
    else
        self.step = 0
        self.finger.transform.localPosition = Vector3(200, -200, -10)
        self.finger:SetActive(true)
        self.panelBtn.onClick:AddListener(function() self:Click() end)
    end
end

function DramaLetter:ScaleBg()
    self.fly:SetActive(false)
    self.mainObj:SetActive(true)
    Tween.Instance:Scale(self.mainObj, Vector3.one, 1, function() self:Begin() end, LeanTweenType.easeOutElastic)
end

function DramaLetter:Input_txt1()
    self.txt_table = {self.txt0, self.txt1}
    if self.txt_step == #self.txt_table then
        self.txt_step = 0
        self:Begin()
    else
        self.txt_step = self.txt_step + 1
        self.OneByOne.callback = function() self:Input_txt1() end
        self.OneByOne:Show(self.txt_table[self.txt_step], self.contents[self.txt_step])
    end
end

function DramaLetter:Input_txt2()
    self.txt_table = {self.txt2, self.txt3}
    if self.txt_step == #self.txt_table then
        self.txt_step = 0
        self:Begin()
    else
        self.txt_step = self.txt_step + 1
        self.OneByOne.callback = function() self:Input_txt2() end
        self.OneByOne:Show(self.txt_table[self.txt_step], self.contents[self.txt_step + 2])
    end
end

function DramaLetter:Duangduangduang()
    self.stones = {self.slot1, self.slot2, self.slot3}
    self:Duang_begin()
end

function DramaLetter:Duang_begin()
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
    end
    if self.slot_step == #self.stones then
        self.stones = nil
        self.slot_step = 0
        self:Begin()
    else
        self.slot_step = self.slot_step + 1
        local slot = self.stones[self.slot_step]
        slot:SetActive(true)
        Tween.Instance:Scale(slot, Vector3.one, 0.4, function() self:Duang_end() end, LeanTweenType.easeOutElastic)
    end
end

function DramaLetter:Duang_end()
    -- mod_drama.shake_camera (2, 20, false, true)
    self.timeId = LuaTimer.Add(0.3, function() self:Duang_begin(0) end)
end
