-- ---------------------------------
-- 技能格子
-- ljh
-- ---------------------------------
SkillSlot = SkillSlot or BaseClass()

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color

function SkillSlot:__init(gameObject)
    self.prefab_path = AssetConfig.slot_skill
    self.NotAlpha = Color(1,1,1,1)
    self.Alpha = Color(1,1,1,0)

    self:Create(gameObject)

    self.lockCallback = function() self:ClickLock() end
    self.lockFunc = nil
    self.addFunc = nil
    self.changeSkillFunc = nil

    self.skillData = nil
    -- 不需要tips
    self.noTips = false

    self.loadList = BaseUtils.create_queue()
    self.last_resList = {}
    self.assetWrapper_loading = false

    if ctx.IsDebug then
        ZTest.SkillSlotTab[tostring(self)] = self
        self.trace = debug.traceback()
    end
end

function SkillSlot:__delete()
    if ctx.IsDebug then
        ZTest.SkillSlotTab[tostring(self)] = nil
    end

    if self.skillIconLoader ~= nil then
        self.skillIconLoader:DeleteMe()
    end

    self.skillImg = nil
    self.gameObject = nil
    self.skillData = nil

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
end

-- --------------------------------------
-- 创建一个预设
-- 如果在New的时候传人预设gameObject,这里就不会去instantiate
-- --------------------------------------
function SkillSlot:Create(gameObject)
    if self.gameObject == nil then
        if gameObject == nil then
            -- gameObject = GameObject.Instantiate(SkillManager.Instance:GetPrefab(self.prefab_path))
            gameObject = GameObject.Instantiate(PreloadManager.Instance:GetMainAsset(self.prefab_path))
            gameObject.name = "SkillSlot"
        end

        self.gameObject = gameObject
        self.transform = self.gameObject.transform
        self.bgImg = self.gameObject:GetComponent(Image)
        self.nameTxt = self.transform:Find("Name"):GetComponent(Text)
        self.skillImg = self.transform:Find("SkillImg"):GetComponent(Image)
        self.levTxt = self.transform:Find("Lev"):GetComponent(Text)
        self.lockBtn = self.transform:Find("Lock"):GetComponent(Button)
        self.selectObj = self.transform:Find("SelectImg").gameObject
        self.stateObj = self.transform:Find("State").gameObject
        self.labelObj = self.transform:Find("Label").gameObject
        self.labelText = self.transform:Find("Label/Text"):GetComponent(Text)
        self.breakObj = self.transform:Find("Break").gameObject
        self.breakText = self.transform:Find("Break/Text"):GetComponent(Text)
        self.skillLock = self.transform:Find("SkillLock").gameObject
        self.petSkillAddImg = self.transform:Find("PetSkillAddImg").gameObject
        self.petSkillAddTxt = self.transform:Find("PetSkillAddImg/Text"):GetComponent(Text)
        self.petSkillAddTxt.transform.anchoredPosition = Vector2(4.2, -5.6)
        self.petSkillAddImg.transform.sizeDelta = Vector2(23.6, 18.9)

        self.changeSkillBtn = self.transform:Find("ChangeSkill"):GetComponent(Button)

        self.skillIconLoader = SingleIconLoader.New(self.transform:Find("SkillImg").gameObject)

        if self.transform:Find("NoOpen") ~= nil then
            self.noOpen = self.transform:Find("NoOpen").gameObject
            self.noOpenDesc = self.transform:Find("NoOpen/Text"):GetComponent(Text)
            self.noOpen:SetActive(false)
        end

        if self.transform:Find("ChildState") ~= nil then
            self.childState = self.transform:Find("ChildState").gameObject
            self.childState:GetComponent(RectTransform).anchoredPosition = Vector2(-12, 22, 0)
        end

        self.lockBtn.onClick:AddListener(function() self:ClickLock() end)
        self.changeSkillBtn.onClick:AddListener(function() self:ClickChangeSkill() end)

        self.button = self.gameObject:GetComponent(Button)
        self.button.onClick:AddListener(function() self:ClickSelf() end)
    end
end

function SkillSlot:ClickSelf()
    if self.skillData == nil then
        return
    end
    if self.click_self_call_back ~= nil then
        self.click_self_call_back() --执行点击自己回调
    end

    if not self.noTips then
        if self.type == Skilltype.petskill then
            self.extra = self.extra or {}
            self.extra.source = self.stateObj.activeSelf
            self.extra.isBreak = self.breakObj.activeSelf
            TipsManager.Instance:ShowSkill(self)
        elseif self.type == Skilltype.shouhuskill then
            TipsManager.Instance:ShowSkill(self)
        elseif self.type == Skilltype.roleskill then
            TipsManager.Instance:ShowSkill(self, self.extra)
        elseif self.type == Skilltype.rideskill then
            TipsManager.Instance:ShowSkill(self)
        elseif self.type == Skilltype.wingskill then
            TipsManager.Instance:ShowSkill(self)
        elseif self.type == Skilltype.endlessskill then
            TipsManager.Instance:ShowSkill(self)
        elseif self.type == Skilltype.swornskill then
            TipsManager.Instance:ShowSkill(self)
        else
            TipsManager.Instance:ShowSkill(self)
        end
        -- if self.itemData.type == BackpackEumn.ItemType.petattrgem or self.itemData.type == BackpackEumn.ItemType.petskillgem then
        --     TipsManager.Instance:ShowPetEquip(self)
        -- else
        --     if BackpackManager.Instance:IsEquip(self.itemData.type) then
        --         TipsManager.Instance:ShowEquip(self)
        --     else
        --         TipsManager.Instance:ShowItem(self)
        --     end
        -- end
    end
end

function SkillSlot:Default()
    self:ShowBg(true)
    self:ShowName(false)
    self:ShowLevel(false)
    self:ShowSelect(false)
    self:ShowState(false)
    self:ShowLock(false)
    self:ShowImg(false)
    self:ShowLabel(false, "")
    self:ShowBreak(false, "")
    self:ShowSkillLock(false)
    self:ShowOnOpen(false)
    self:ShowChildState(false)
    self:ShowPetSkillAddImg(false)

    self.nameTxt.text = ""
    self.levTxt.text = ""
    self.lockFunc = nil
    self.changeSkillFunc = nil
end

-- --------------------------------
-- 设置所有
-- 调用这个方法就会把所有参数的设成默认值
-- 建议创建的时候调用一次，然后之后的修改调用单个方法来修改
-- 参数格式说明:
-- type = 技能类型 Skilltype
-- info = 技能数据
-- extra = 扩展参数
-- --------------------------------
function SkillSlot:SetAll(_type, info, extra)
    self.extra = extra
    self.skillData = info
    self.type = _type
    self:Default()
    if info ~= nil then
        self:SetImg(info.icon, extra)

        if self.type == Skilltype.roletalent then
            self:SetName(info.name)
            self:SetLev(info.lev)
        end
        if self.type == Skilltype.roleskill then
            self:SetName(info.name)
            self:ShowLevel(false)
        end
        if self.type == Skilltype.rideskill then
            self:SetName(info.name)
            self:SetLev(info.lev)
        end
        if self.type == Skilltype.roletalent then
            -- self:ShowName(false)
            self:ShowLevel(false)
        end
        if self.type == Skilltype.petskill then
            self:ShowPetSkillAddImg(info.step == 3)
        end
    end
end

-- ------------------------------------
-- 设置技能图标
-- ------------------------------------
function SkillSlot:SetImg(icon, extra)
    icon = tonumber(icon)

    self.skillIconLoader:SetSprite(SingleIconType.SkillIcon, icon)
    self:ShowImg(true)
    self:ShowBg(false)
end

-- ------------------------------------
-- 设置技能名称
-- ------------------------------------
function SkillSlot:SetName(name)
    self.nameTxt.text = tostring(name)
    self.nameTxt.gameObject:SetActive(true)
end

-- ------------------------------------
-- 设置技能等级
-- ------------------------------------
function SkillSlot:SetLev(lev)
    self.levTxt.text = string.format("Lv.%s", lev)
    self.levTxt.gameObject:SetActive(true)
end

-- -----------------------------------
-- 设置点击锁回调
-- -----------------------------------
function SkillSlot:SetLockCallback(func)
    self.lockFunc = func
end

-- -----------------------------------
-- 设置点击选择/转换技能按钮回调
-- -----------------------------------
function SkillSlot:SetChangeSkillCallback(func)
    self.changeSkillFunc = func
end

-- -----------------------------------
-- 设置点击回调
-- -----------------------------------
function SkillSlot:SetSelectSelfCallback(func)
    self.click_self_call_back = func
end

-- ===================================================================
-- 以下显示隐藏设置
-- ===================================================================
-- -----------------------------
-- 是否显示技能等级
-- -----------------------------
function SkillSlot:ShowName(bool)
    self.nameTxt.gameObject:SetActive(bool)
end
-- -----------------------------
-- 是否显示技能等级
-- -----------------------------
function SkillSlot:ShowLevel(bool)
    self.levTxt.gameObject:SetActive(bool)
end

-- ------------------------------
-- 是否显示选中状态
-- ------------------------------
function SkillSlot:ShowSelect(bool)
    self.selectObj:SetActive(bool)
end

-- ------------------------------
-- 是否显示符字
-- ------------------------------
function SkillSlot:ShowState(bool)
    self.stateObj:SetActive(bool)
end

-- ------------------------------
-- 是否显示img
-- ------------------------------
function SkillSlot:ShowImg(bool)
    self.skillImg.gameObject:SetActive(bool)
end

-- -----------------------------
-- 是否显示背景
-- -----------------------------
function SkillSlot:ShowBg(bool)
    if bool then
        self.bgImg.color = self.NotAlpha
    else
        self.bgImg.color = self.Alpha
    end
end

-- ------------------------------
-- 是否显示锁
-- ------------------------------
function SkillSlot:ShowLock(bool)
    self.lockBtn.gameObject:SetActive(bool)
end

-- ------------------------------
-- 是否显示label
-- ------------------------------
function SkillSlot:ShowLabel(bool, text, imgName)
    self.labelObj.gameObject:SetActive(bool)
    if bool and text ~= nil then
        self.labelText.text = text
    end
    if bool and imgName ~= nil then
        self.labelObj:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, imgName)
    end
end

-- ------------------------------
-- 是否显示突破
-- ------------------------------
function SkillSlot:ShowBreak(bool, text)
    self.breakObj.gameObject:SetActive(bool)
    if bool and text ~= nil then
        self.breakText.text = text
    end
end

-- ------------------------------
-- 是否显示技能锁
-- ------------------------------
function SkillSlot:ShowSkillLock(bool)
    self.skillLock.gameObject:SetActive(bool)
end

-- ------------------------------
-- 是否显示技能+1
-- ------------------------------
function SkillSlot:ShowPetSkillAddImg(bool)
    self.petSkillAddImg.gameObject:SetActive(bool)
end

-- ------------------------------
-- 是否技能选择/转换按钮
-- ------------------------------
function SkillSlot:ShowChangeSkill(bool)
    self.changeSkillBtn.gameObject:SetActive(bool)
end

-- ------------------------------
-- 设置技能图标变灰
-- ------------------------------
function SkillSlot:SetGrey(bool)
    BaseUtils.SetGrey(self.skillImg, bool)
end

-- -----------------------
-- 设置不要tips
-- -----------------------
function SkillSlot:SetNotips(btn_state)
    self.noTips = true
    if btn_state == nil then
        self.button.enabled = false
    else
        self.button.enabled = btn_state
    end
end

function SkillSlot:ClickLock()
    if self.lockFunc ~= nil then
        self.lockFunc()
    end
end

function SkillSlot:ClickChangeSkill()
    if self.changeSkillFunc ~= nil then
        self.changeSkillFunc()
    end
end

function SkillSlot:ShowOnOpen(bool, desc)
    if bool then
        if self.noOpen ~= nil then
            self.noOpen:SetActive(true)
        end
        if self.noOpenDesc ~= nil then
            self.noOpenDesc.text = desc
        end
    else
        if self.noOpen ~= nil then
            self.noOpen:SetActive(false)
        end
        if self.noOpenDesc ~= nil then
            self.noOpenDesc.text = desc
        end
    end
end

function SkillSlot:ShowChildState(bool)
    if self.childState ~= nil then
        self.childState:SetActive(bool)
    end
end

-- -----------------------
-- 资源加载
-- -----------------------
function SkillSlot:LoadAssetBundleBatch(resList, OnCompleted)
    if self.assetWrapper_loading == false then
        if self.assetWrapper ~= nil then
            self.assetWrapper:DeleteMe()
            self.assetWrapper = nil
        end
        self.assetWrapper = AssetBatchWrapper.New()
        local callback = function()
            OnCompleted()
            self:OnResLoadCompleted()
        end
        self.last_resList = BaseUtils.copytab(resList)
        self.assetWrapper_loading = true
        self.assetWrapper:LoadAssetBundle(resList, callback)
    else
        BaseUtils.enqueue(self.loadList, { resList = resList, OnCompleted = OnCompleted })
    end
end


-- -----------------------
-- 资源加载完成，加载下一波资源
-- -----------------------
function SkillSlot:OnResLoadCompleted()
    self.assetWrapper_loading = false

    if self.gameObject == nil then return end

    local loadData = BaseUtils.dequeue(self.loadList)
    if loadData ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
        self:LoadAssetBundleBatch(loadData.resList, loadData.OnCompleted)
    end
end
