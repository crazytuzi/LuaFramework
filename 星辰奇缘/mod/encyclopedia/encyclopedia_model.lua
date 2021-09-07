-- @author hzf
-- @date 2016年7月6日,星期三

EncyclopediaModel = EncyclopediaModel or BaseClass(BaseModel)

function EncyclopediaModel:__init()
    self.Mgr = EncyclopediaManager.Instance
    self.treeBtn = {
        [1] = {name = TI18N("装备大全"), icon = "brew1", sub = {[1] = TI18N("装备图鉴"), [2] = TI18N("锻造与重铸"), [3] = TI18N("宝石与强化"), [4] = TI18N("精炼与其它")}}
        , [2] = {name = "技能大全", icon = "brew4", sub = {[1] = TI18N("职业技能"), [2] = TI18N("装备特效"), [3] = TI18N("翅膀技能"), [4] = TI18N("伴侣技能")}}
        , [3] = {name = "宠物大全", icon = "brew2", sub = {[1] = TI18N("来源与图鉴"), [2] = TI18N("升级与属性"), [3] = TI18N("洗髓与学习"), [4] = TI18N("进阶与其它")}}
        , [4] = {name = "宝物大全", icon = "brew6", sub = {[1] = TI18N("宝物大全")}}
        , [5] = {name = "守护大全", icon = "brew3", sub = {[1] = TI18N("相关介绍"), [2] = TI18N("守护图鉴")}}
        , [6] = {name = "翅膀大全", icon = "BackPack_WingIcon", sub = {[1] = TI18N("来源与图鉴"), [2] = TI18N("技能相关")}}
        , [7] = {name = "战斗大全", icon = "16", sub = {[1] = TI18N("战斗介绍"), [2] = TI18N("战斗药品")}}
        , [8] = {name = "坐骑大全", icon = "brew5", sub = {[1] = TI18N("坐骑图鉴"), [2] = TI18N("基本信息"), [3] = TI18N("升级与幻化"), [4] = TI18N("技能与契约")}}
    }
end

function EncyclopediaModel:__delete()
end

function EncyclopediaModel:OpenWindow(args)
    if self.mainWin == nil then
    end
    self.mainWin:Open(args)
end

function EncyclopediaModel:CloseWindow()
end


function EncyclopediaModel:GetTreeBtn()
    local lev = RoleManager.Instance.RoleData.lev
    if lev < 75 then
        self.treeBtn[3].sub[2] = TI18N("升级与属性")
    else
        self.treeBtn[3].sub[2] = TI18N("宠物附灵")
    end
    return self.treeBtn 
end