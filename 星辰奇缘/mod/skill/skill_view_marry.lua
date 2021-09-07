-- 伴侣技能 没发现调用的地方，应该是已废弃
SkillView_Marry = SkillView_Marry or BaseClass(BasePanel)

function SkillView_Marry:__init(parent)
	self.parent = parent
    self.model = parent.model
    self.name = "SkillView_Marry"
    self.resList = {
        {file = AssetConfig.marryskill, type = AssetType.Main}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false

    ------------------------------------------------
    self.container = nil
    self.skillobject = nil
    self.scrollrect = nil

    self.skillitemlist = {}
    self.selectbtn = nil
    self.skilldata = nil
    self.select_skilldata = nil

    self.button = nil

    self.descIcon = nil
    ------------------------------------------------
    self._updateSkillItem = function()
        self:updateSkillItem()
    end
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function SkillView_Marry:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.marryskill))
    self.gameObject.name = "SkillView_Marry"
    self.gameObject.transform:SetParent(self.parent.mainTransform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform

    --------------------------------------------
    local transform = self.transform
    self.container = transform:FindChild("SkillBar/mask/Container").gameObject
    self.skillobject = self.container.transform:FindChild("SkillItem").gameObject

    self.scrollrect = transform:FindChild("SkillBar/mask"):GetComponent(ScrollRect)

    -- 按钮功能绑定
    self.button = transform:FindChild("InfoPanel/OkButton"):GetComponent(Button)
    self.button.onClick:AddListener(function() self:okbuttonclick() end)

	-- local btn
    -- btn = transform:FindChild("InfoPanel/OneKeyButton"):GetComponent(Button)
    -- btn.onClick:AddListener(function() self:onekeybuttonclick() end)

    -- self.descIcon = transform:FindChild("InfoPanel/DescIcon"):GetComponent(Button)
    -- self.descIcon.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.descIcon.gameObject
    --         , itemData = { TI18N("由于你当前技能等级小于服务器等级-10，学习技能消耗降低为原来的70%") }}) end)

    --------------------------------------------
    self.init = true
    self:OnShow()
    self:ClearMainAsset()
end

function SkillView_Marry:OnShow()
    self:addevents()
    self:updateSkillItem()
end

function SkillView_Marry:OnHide()
    self:removeevents()
end

function SkillView_Marry:addevents()
    SkillManager.Instance.OnUpdateMarrySkill:Add(self._updateSkillItem)
end

function SkillView_Marry:removeevents()
    SkillManager.Instance.OnUpdateMarrySkill:Remove(self._updateSkillItem)
end

-- 更新技能列表 Mark
function SkillView_Marry:updateSkillItem()
	local skilllist = self.model.marry_skill

    local skillitem
    local data

    for i = 1, #skilllist do
        data = skilllist[i]
        skillitem = self.skillitemlist[i]

        if skillitem == nil then
            local item = GameObject.Instantiate(self.skillobject)
            item:SetActive(true)
            item.transform:SetParent(self.container.transform)
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            local fun = function() self:onskillitemclick(item) end
            item:GetComponent(Button).onClick:AddListener(fun)
            self.skillitemlist[i] = item
            skillitem = item
        end
        skillitem.transform:FindChild("NotifyPoint").gameObject:SetActive(false)

        local marryskill
        if data.lev == 0 then
            marryskill = self.model:getmarryskilldata(data.id, 1)
            if marryskill ~= nil then
                skillitem.name = tostring(marryskill.id)

                skillitem.transform:FindChild("SkillIcon"):GetComponent(Image).sprite
                    = self.assetWrapper:GetSprite(AssetConfig.skillIcon_roleother, tostring(marryskill.icon))
                skillitem.transform:FindChild("NameText"):GetComponent(Text).text = marryskill.name
                skillitem.transform:FindChild("DescText"):GetComponent(Text).text = marryskill.about

                local roleData = RoleManager.Instance.RoleData
                if marryskill.love_var <= roleData.love and marryskill.intimacy <= FriendManager.Instance:GetIntimacy(roleData.lover_id, roleData.lover_platform, roleData.lover_zone_id) then
                    skillitem.transform:FindChild("LVText"):GetComponent(Text).text = TI18N("<color='#ffff00'>可激活</color>")
                    skillitem.transform:FindChild("NotifyPoint").gameObject:SetActive(true)
                else
                    skillitem.transform:FindChild("LVText"):GetComponent(Text).text = TI18N("<color='#ff0000'>未激活</color>")
                    skillitem.transform:FindChild("NotifyPoint").gameObject:SetActive(false)
                end
                skillitem.transform:FindChild("SkillIcon"):GetComponent(Image).color = Color.grey
            end
        else
            marryskill = self.model:getmarryskilldata(data.id, data.lev)
            if marryskill ~= nil then
                skillitem.name = tostring(marryskill.id)

                skillitem.transform:FindChild("SkillIcon"):GetComponent(Image).sprite
                    = self.assetWrapper:GetSprite(AssetConfig.skillIcon_roleother, tostring(marryskill.icon))
                skillitem.transform:FindChild("NameText"):GetComponent(Text).text = marryskill.name

                skillitem.transform:FindChild("LVText"):GetComponent(Text).text =  ""--string.format("Lv.%s", data.lev)
                skillitem.transform:FindChild("DescText"):GetComponent(Text).text = marryskill.about
                skillitem.transform:FindChild("SkillIcon"):GetComponent(Image).color = Color.white
            end
        end
        if nil ~= self.skilldata and self.skilldata.id == data.id then self.selectbtn = skillitem end
    end

    for i = #skilllist + 1, #self.skillitemlist do
        skillitem = self.skillitemlist[i]
        skilltem:SetActive(false)
    end

    if #skilllist > 0 then
        if self.selectbtn == nil then
            self:onskillitemclick(self.skillitemlist[1])
        else
            self:onskillitemclick(self.selectbtn)
        end
    end
end

-- 选中技能 Mark
function SkillView_Marry:onskillitemclick(item)
	self.select_skilldata = self.model:getmarryskill(item.name)

    if self.select_skilldata.lev == 0 then
        self.skilldata = self.model:getmarryskilldata(item.name, 1)
    else
        self.skilldata = self.model:getmarryskilldata(item.name, self.select_skilldata.lev)
    end

    self:updateSkill()

    if self.selectbtn ~= nil then self.selectbtn.transform:FindChild("Select").gameObject:SetActive(false) end
    item.transform:FindChild("Select").gameObject:SetActive(true)
    self.selectbtn = item
end

-- 更新技能信息 Mark
function SkillView_Marry:updateSkill()
    local skilldata = self.skilldata
    local transform = self.transform

    if nil == skilldata then return end
    local info_panel = transform:FindChild("InfoPanel").gameObject
    info_panel.transform:FindChild("Icon"):GetComponent(Image).sprite
                    = self.assetWrapper:GetSprite(AssetConfig.skillIcon_roleother, tostring(skilldata.icon))

    info_panel.transform:FindChild("NameText"):GetComponent(Text).text = skilldata.name --.."  LV."..skilldata.lev

    info_panel.transform:FindChild("DescText"):GetComponent(Text).text = skilldata.desc

    info_panel.transform:FindChild("DescText1"):GetComponent(Text).text = skilldata.condition
    info_panel.transform:FindChild("DescText2"):GetComponent(Text).text = skilldata.desc2
    info_panel.transform:FindChild("DescText3"):GetComponent(Text).text = skilldata.location
    info_panel.transform:FindChild("DescText4"):GetComponent(Text).text = string.format(TI18N("%s魔法"), tostring(skilldata.cost_mp))
    info_panel.transform:FindChild("DescText5"):GetComponent(Text).text = string.format(TI18N("%s回合"), tostring(skilldata.cooldown))

    info_panel.transform:FindChild("Desc"):GetComponent(Text).text = skilldata.lev_desc

   	if self.select_skilldata.lev == 0 then
   		self.button.gameObject:SetActive(true)
   		info_panel.transform:FindChild("ActiveText").gameObject:SetActive(false)
   	else
   		self.button.gameObject:SetActive(false)
   		info_panel.transform:FindChild("ActiveText").gameObject:SetActive(true)
   	end
end

function SkillView_Marry:okbuttonclick()
	SceneManager.Instance.sceneElementsModel:Self_PathToTarget("44_1")
	self.parent:OnClickClose()
end