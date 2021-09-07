ShouhuMainTabSkillItem = ShouhuMainTabSkillItem or BaseClass()

function ShouhuMainTabSkillItem:__init(parent, origin_item, data)
    self.parent = parent
    self.gameObject = origin_item
    self.gameObject = go
    self.skillIcon = self.gameObject.transform:FindChild("ImgSkill"):GetComponent(Image)
    self.ImgLock = self.gameObject.transform:FindChild("ImgLock"):GetComponent(Image)
    self.TxtActLev = self.gameObject.transform:FindChild("TxtActLev"):GetComponent(Text)
    self.TxtActLev.gameObject:SetActive(false)
    self.TxtName = self.gameObject.transform:FindChild("TxtName"):GetComponent(Text)

    self.gameObject:GetComponent(Button).onClick:AddListener(function() self:on_tips_skill() end)
end

function ShouhuMainTabSkillItem:Release()

end

function ShouhuMainTabSkillItem:InitPanel(_data)

end

--点击技能图标显示tips
function ShouhuMainTabFirst:on_tips_skill(g)
    -- local arg = {trans = g.transform, data = self.myBaseData, skilltype = slot_skill.skilltype.petskill}
    -- mod_tips.skill_tips(arg)
end

function ShouhuMainTabFirst:set_skill_item_data(item, data)
    self.myData = data
    -- self.myBaseData = self.parent.model:get_skill_base_data(self.myData.skill_id)
    self.TxtName.text = "" --self.myBaseData.name
    self.TxtName.gameObject:SetActive(false)
    self.TxtActLev.gameObject:SetActive(false)
    --显示是否已经激活
    if self.myData.hasGet == true then--已激活
        self.ImgLock.gameObject:SetActive(false)
        self.TxtName.color = Color.white
    else
        self.ImgLock.gameObject:SetActive(false)
        self.TxtActLev.text = string.format("%s%s", self.myData.act_lev, TI18N("级开启"))
        self.TxtName.color = Color.grey
    end
end
