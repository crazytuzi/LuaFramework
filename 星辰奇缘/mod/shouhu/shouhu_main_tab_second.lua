ShouhuMainTabSecond = ShouhuMainTabSecond or BaseClass(BasePanel)

function ShouhuMainTabSecond:__init(parent)
    self.parent = parent
    self.resList = {
        {file = AssetConfig.shouhu_main_tab2, type = AssetType.Main}
        , {file = AssetConfig.guard_head, type = AssetType.Dep}
    }
    self.starList = nil
    self.starGoList = nil
    self.starDataList = nil
    self.has_init = false
    return self
end

function ShouhuMainTabSecond:__delete()
    self:GuideEnd()
    if self.starList ~= nil then
        for k, v in pairs(self.starList) do
            v:Release()
        end
    end
    self.starList = nil
    self.starGoList = nil
    self.starDataList = nil
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self.has_init = false
    self:AssetClearAll()
end

function ShouhuMainTabSecond:InitPanel()
     -- 星阵tab

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shouhu_main_tab2))
    self.gameObject.name = "ShouhuMainTabSecond"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.mainObj, self.gameObject)

    self.xLeftCon = self.transform:FindChild("Con_right").gameObject

    self.has_init = true
    self:init_star_tactic() --初始化左侧
end

--星阵更新
function ShouhuMainTabSecond:update_star_tactic()
    if self.has_init == false then
        return
    end
    self:init_star_tactic()
end

-- 星阵左侧初始化逻辑
function ShouhuMainTabSecond:init_star_tactic()
    if self.starList  == nil then--初始化
        self.starList = {}
        self.starGoList = {}
        for i=1, 6 do
            local itemStar = self.xLeftCon.transform:FindChild(string.format("Item%s", i)).gameObject
            local item= ShouhuStarItem.New(self, itemStar, i)
            table.insert(self.starList, item)
            table.insert(self.starGoList, item.ImgHead) --保存碰撞体
        end
    end
    local curTactic =  self.parent.model.guard_tactic.liuMangXing
    self.parent.model.cur_tactic = curTactic

    self.starDataList = self.parent.model:get_star_cfg_data_list()

    local sort_lev = function(a, b)
        return a.act_pos < b.act_pos
    end
    table.sort( self.starDataList, sort_lev )

    for i=1, #self.starList do
        local item = self.starList[i]
        item:set_sh_tactics_data(self.starDataList[i])
        item:set_star_my_sh_data(self.parent.model:get_base_data_by_tactic(item.myData.act_pos))
    end

    self:GuideEnd()
    if ShouhuManager.Instance:CheckHelpGuide() then
        self.guideTimeId = LuaTimer.Add(200, function() self:Guide() end)
    end
end

function ShouhuMainTabSecond:Guide()
    if self.guideScript == nil then
        self.guideScript = GuideGuardHelp.New(self)
    end
    self.guideScript:Show()
end

function ShouhuMainTabSecond:GuideEnd()
    if self.guideTimeId ~= nil then
        LuaTimer.Delete(self.guideTimeId)
        self.guideTimeId = nil
    end

    if self.guideScript ~= nil then
        self.guideScript:DeleteMe()
        self.guideScript = nil
    end
end