-- -------------------------
-- 加点推荐提示
-- hosr
-- -------------------------
AddPointTips = AddPointTips or BaseClass(BasePanel)

function AddPointTips:__init(mainPanel)
    self.mainPanel = mainPanel
    self.path = "prefabs/ui/addpoint/addpointtips.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main}
    }
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function AddPointTips:__delete()
   if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function AddPointTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "AddPointTips"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.mainPanel.gameObject, self.gameObject)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)

    self.desc1 = self.transform:Find("Main/Bottom/Desc1"):GetComponent(Text)
    self.desc2 = self.transform:Find("Main/Bottom/Desc2"):GetComponent(Text)
    self.desc3 = self.transform:Find("Main/Bottom/Desc3"):GetComponent(Text)

    self:OnShow()
end


    --,[101] = "力量"
    --,[102] = "体质"
    --,[103] = "智力"
    --,[104] = "敏捷"
    --,[105] = "耐力"
    -- "狂剑", "魔导", "战弓", "兽灵", "秘言"
function AddPointTips:OnShow()
    local role = RoleManager.Instance.RoleData
    if role.classes == 1 then
        self:RatioPoints({0,4,0,0,1})
        self.desc1.text = string.format(TI18N("<color='#00ff00'>4力量1耐力</color> 输出能力强，防御高，生存较强\n<color='#7eb9f7'><color='#7eb9f7'>当前等级分配:</color></color><color='#ffff00'>%s力量 %s耐力</color>"), self.extra[101], self.extra[105])

        self:RatioPoints({0,4,0,1,0})
        self.desc2.text = string.format(TI18N("<color='#00ff00'>4力量1敏捷</color> 输出能力强，出手速度快，先发制人\n<color='#7eb9f7'>当前等级分配:</color><color='#ffff00'>%s力量 %s敏捷</color>"), self.extra[101], self.extra[104])

        self:RatioPoints({0,5,0,0,0})
        self.desc3.text = string.format(TI18N("<color='#00ff00'>5力量</color> 输出能力极强，生存较弱\n<color='#7eb9f7'>当前等级分配:</color><color='#ffff00'>%s力量</color>"), self.extra[101])
    elseif role.classes == 2 then
        self:RatioPoints({0,0,4,0,1})
        self.desc1.text = string.format(TI18N("<color='#00ff00'>4智力1耐力</color> 输出能力强，防御高，克制物攻职业\n<color='#7eb9f7'>当前等级分配:</color><color='#ffff00'>%s智力 %s耐力</color>"), self.extra[103], self.extra[105])

        self:RatioPoints({1,0,4,0,0})
        self.desc2.text = string.format(TI18N("<color='#00ff00'>4智力1体质</color> 输出能力强，生命值高，全能型加点\n<color='#7eb9f7'>当前等级分配:</color><color='#ffff00'>%s智力 %s体质</color>"), self.extra[103], self.extra[102])

        self:RatioPoints({0,0,5,0,0})
        self.desc3.text = string.format(TI18N("<color='#00ff00'>5智力</color> 输出能力极强，生存较弱\n<color='#7eb9f7'>当前等级分配:</color><color='#ffff00'>%s智力</color>"), self.extra[103])
    elseif role.classes == 3 then
        self:RatioPoints({0,4,0,1,0})
        self.desc1.text = string.format(TI18N("<color='#00ff00'>4力量1敏捷</color> 输出能力强，出手速度快，生存弱\n<color='#7eb9f7'>当前等级分配:</color><color='#ffff00'>%s力量 %s敏捷</color>"), self.extra[101], self.extra[104])

        self:RatioPoints({1,4,0,0,0})
        self.desc2.text = string.format(TI18N("<color='#00ff00'>4力量1体质</color> 输出能力强，生命值高，全能型加点\n<color='#7eb9f7'>当前等级分配:</color><color='#ffff00'>%s力量 %s体质</color>"), self.extra[101], self.extra[102])

        self:RatioPoints({0,5,0,0,0})
        self.desc3.text = string.format(TI18N("<color='#00ff00'>5力量</color> 输出能力极强，生存较弱\n<color='#7eb9f7'>当前等级分配:</color><color='#ffff00'>%s力量</color>"), self.extra[101])
    elseif role.classes == 4 then
        self:RatioPoints({2,0,0,2,1})
        self.desc1.text = string.format(TI18N("<color='#00ff00'>2体质1耐力2敏捷</color> 出手速度快，生存能力强，适合控制\n<color='#7eb9f7'>当前等级分配:</color><color='#ffff00'>%s体质 %s耐力 %s敏捷</color>"), self.extra[102], self.extra[105], self.extra[104])

        self:RatioPoints({1,0,0,4,0})
        self.desc2.text = string.format(TI18N("<color='#00ff00'>4敏捷1体质</color> 出手速度极快，作为团队控制，PVP加点方案\n<color='#7eb9f7'>当前等级分配:</color><color='#ffff00'>%s敏捷 %s体质</color>"), self.extra[104], self.extra[102])

        self:RatioPoints({2,0,0,1,2})
        self.desc3.text = string.format(TI18N("<color='#00ff00'>2体2耐1敏</color> 生存能力强，全能型加点，适合团队辅助\n<color='#7eb9f7'>当前等级分配:</color><color='#ffff00'>%s体力 %s耐力 %s敏捷</color>"), self.extra[102], self.extra[105], self.extra[104])
    elseif role.classes == 5 then
        self:RatioPoints({2,0,0,2,1})
        self.desc1.text = string.format(TI18N("<color='#00ff00'>2体质1耐力2敏捷</color> 生存能力强，出手速度较快，控制辅助结合\n<color='#7eb9f7'>当前等级分配:</color><color='#ffff00'>%s体质 %s耐力 %s敏捷</color>"), self.extra[102], self.extra[105], self.extra[104])

        self:RatioPoints({1,0,0,3,1})
        self.desc2.text = string.format(TI18N("<color='#00ff00'>1体质1耐力3敏捷</color> 出手速度极快，作为团队控制，PVP加点方法\n<color='#7eb9f7'>当前等级分配:</color><color='#ffff00'>%s体质 %s耐力 %s敏捷</color>"), self.extra[102], self.extra[105], self.extra[104])

        self:RatioPoints({3,0,0,0,2})
        self.desc3.text = string.format(TI18N("<color='#00ff00'>3体质2耐力</color> 生存能力极强，适合团队辅助\n<color='#7eb9f7'>当前等级分配:</color><color='#ffff00'>%s体质 %s耐力</color>"), self.extra[102], self.extra[105])
    elseif role.classes == 6 then
        self:RatioPoints({0,0,4,0,1})
        self.desc1.text = string.format(TI18N("<color='#00ff00'>4智力1耐力</color> 输出能力强，防御高，克制物攻职业\n<color='#7eb9f7'>当前等级分配:</color><color='#ffff00'>%s智力 %s耐力</color>"), self.extra[103], self.extra[105])

        self:RatioPoints({1,0,4,0,0})
        self.desc2.text = string.format(TI18N("<color='#00ff00'>4智力1体质</color> 输出能力强，生命值高，全能型加点\n<color='#7eb9f7'>当前等级分配:</color><color='#ffff00'>%s智力 %s体质</color>"), self.extra[103], self.extra[102])

        self:RatioPoints({0,0,5,0,0})
        self.desc3.text = string.format(TI18N("<color='#00ff00'>5智力</color> 输出能力极强，生存较弱\n<color='#7eb9f7'>当前等级分配:</color><color='#ffff00'>%s智力</color>"), self.extra[103])
    elseif role.classes == 7 then
        self:RatioPoints({1,3,0,0,1})
        self.desc1.text = string.format(TI18N("<color='#00ff00'>3力量1体质1耐力</color>攻守兼备，伤害不俗，输出与辅助并重\n<color='#7eb9f7'>当前等级分配:</color><color='#ffff00'>%s力量 %s体质 %s耐力</color>"), self.extra[101], self.extra[102], self.extra[105])

        self:RatioPoints({1,3,0,1,0})
        self.desc2.text = string.format(TI18N("<color='#00ff00'>3力量1体质1敏捷</color>输出能力强，出手速度较快，PVP加点方法\n<color='#7eb9f7'>当前等级分配:</color><color='#ffff00'>%s力量 %s体质 %s敏捷</color>"), self.extra[101], self.extra[102], self.extra[104])

        self:RatioPoints({1,4,0,0,0})
        self.desc3.text = string.format(TI18N("<color='#00ff00'>4力量1体质</color>输出能力极强，兼备治疗，PVE加点方法\n<color='#7eb9f7'>当前等级分配:</color><color='#ffff00'>%s力量 %s体质</color>"), self.extra[101], self.extra[102])
    end
end

function AddPointTips:OnHide()
    self.mainPanel.slider:CheckGuideAddPoint()
end
function AddPointTips:EquipPoints()
    -- 取到身上装备的扩展属性
    --,[101] = "力量"
    --,[102] = "体质"
    --,[103] = "智力"
    --,[104] = "敏捷"
    --,[105] = "耐力"
    local equips = BackpackManager.Instance.equipDic
    for _,equip in pairs(equips) do
        for _,v in ipairs(equip.attr) do
            if v.type == GlobalEumn.ItemAttrType.extra then
                self.extra[v.name] = self.extra[v.name] + v.val
            end
        end
    end
end

function AddPointTips:RatioPoints(__set_points)
    local role = RoleManager.Instance.RoleData
    local point = role.lev * 5 + role:ExtraPoint()

    local perPoint = 5
    local ratio = math.floor(point / perPoint)
    local lesspoint = point % perPoint

    local func = function(index)
        local base = __set_points[index] * ratio
        if lesspoint > 0 then
            if lesspoint > __set_points[index] then
                base = base + __set_points[index]
            else
                base = base + lesspoint
            end
            lesspoint = lesspoint - __set_points[index]
        end
        return base,lesspoint
    end

    local corporeity = 0
    local force = 0
    local brains = 0
    local agile = 0
    local endurance = 0

    corporeity, lesspoint = func(1)
    force, lesspoint = func(2)
    brains, lesspoint = func(3)
    agile, lesspoint = func(4)
    endurance, lesspoint = func(5)

    self.extra = {
        [101] = role.lev,
        [102] = role.lev,
        [103] = role.lev,
        [104] = role.lev,
        [105] = role.lev,
    }

    self.extra[102] = self.extra[102] + corporeity
    self.extra[101] = self.extra[101] + force
    self.extra[103] = self.extra[103] + brains
    self.extra[104] = self.extra[104] + agile
    self.extra[105] = self.extra[105] + endurance

    self:EquipPoints()
end
