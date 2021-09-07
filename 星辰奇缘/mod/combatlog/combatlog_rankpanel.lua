-- 战斗录像
-- @author huangzefeng
-- @date 20160517
CombatLogRankPanel = CombatLogRankPanel or BaseClass(BasePanel)

function CombatLogRankPanel:__init(Main)
    self.Main = Main
    self.name = "CombatLogRankPanel"
    self.Mgr = CombatManager.Instance
    self.resList = {
        {file = AssetConfig.combatlog_panel2, type = AssetType.Main}
        ,{file  =  AssetConfig.attr_icon, type  =  AssetType.Dep}
    }
    self.hasinit = false
    self.updatefunc = function ()
        self:RefreshKeepList()
    end
end


function CombatLogRankPanel:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
    self:AssetClearAll()
    if self.ItemObjList ~= nil then
        for i,v in ipairs(self.ItemObjList) do
            v:DeleteMe()
        end
    end
    self.Mgr.OnGoodLogChange:RemoveAll()
end

function CombatLogRankPanel:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.combatlog_panel2))
    UIUtils.AddUIChild(self.Main.MainCon.gameObject, self.gameObject)
    self.gameObject.name = "CombatLogRankPanel"
    self.transform = self.gameObject.transform

    self.tabCon = self.transform:Find("MaskScroll/TabButtonGroup")
    self.tab_base = self.transform:Find("MaskScroll/TabButtonGroup/Button").gameObject
    self.container = self.transform:Find("Con/List/Container")
    self.infoBtn = self.transform:Find("Con/TitleBar/Button")
    self.infoBtn.gameObject:SetActive(false)
    -- self.infoBtn:GetComponent(Button).onClick:AddListener(function()
    --     TipsManager.Instance:ShowText({gameObject = self.infoBtn.gameObject, itemData = {
    --         TI18N("1.收录最近<color='#ffff00'>20</color>场战斗的录像"),
    --         TI18N("2.点击录像名称可以<color='#ffff00'>分享</color>到聊天频道"),
    --         TI18N("3.点击<color='#ffff00'>收藏</color>，点击将喜爱的录像永久保留下来"),
    --         TI18N("4.最多同时收藏<color='#ffff00'>10</color>场战斗录像"),
    --         }})
    --     end)

    for i=1,7 do
        local secondtab = GameObject.Instantiate(self.tab_base)
        secondtab.transform:SetParent(self.tabCon)
        secondtab.transform.localScale = Vector3.one
        secondtab.transform.anchoredPosition = Vector2(100*i, -26)
    end
    self.Main:SetTabBtn(self.tabCon:GetChild(0), TI18N("全 部"))
    self.Main:SetTabBtn(self.tabCon:GetChild(1), TI18N("竞技场"))
    self.Main:SetTabBtn(self.tabCon:GetChild(2), TI18N("段位赛"))
    self.Main:SetTabBtn(self.tabCon:GetChild(3), TI18N("公会战"))
    self.Main:SetTabBtn(self.tabCon:GetChild(4), TI18N("公会英雄"))
    self.Main:SetTabBtn(self.tabCon:GetChild(5), TI18N("荣耀战场"))
    self.Main:SetTabBtn(self.tabCon:GetChild(6), TI18N("武道会"))
    self.Main:SetTabBtn(self.tabCon:GetChild(7), TI18N("冠军联赛"))
    self.tabgroup = TabGroup.New(self.tabCon.gameObject, function (tab) self:OnTabChange(tab) end, {notAutoSelect = true})
    self.hasinit = true
    self.Mgr.OnGoodLogChange:AddListener(self.updatefunc)
    if self.openArgs == nil then
        self.tabgroup:ChangeTab(1)
    else
        self.tabgroup:ChangeTab(self.openArgs)
    end
end

function CombatLogRankPanel:OnTabChange(index)
    if index == 1 then

    elseif index == 2 then

    end
    self.currindex = index
    self:InitList(index)
end

function CombatLogRankPanel:InitList(index)
    if self.ItemObjList == nil then
        self.ItemObjList = {}
        for i=1,10 do
            local go = self.container:GetChild(i-1).gameObject
            table.insert(self.ItemObjList, CombatLogItem2.New(go, self, 3))
        end
    end
    self.item_con_last_y = self.container.anchoredPosition.y
    self.single_item_height = 52
    self.scroll_con_height = 361

    self.setting_data = {
       item_list = self.ItemObjList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container  --item列表的父容器
       ,single_item_height = self.single_item_height --一条item的高度
       ,item_con_last_y = self.item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.vScroll = self.container.parent:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    if index == 1 then
        self.setting_data.data_list = self.Main.model.goodList
    elseif index == 2 then
        self.setting_data.data_list = self.Main.model:GettypeList(100)
    elseif index == 3 then
        self.setting_data.data_list = self.Main.model:GettypeList(102)
    elseif index == 4 then
        self.setting_data.data_list = self.Main.model:GettypeList(105)
    elseif index == 5 then
        self.setting_data.data_list = self.Main.model:GettypeList(106)
    elseif index == 6 then
        self.setting_data.data_list = self.Main.model:GettypeList(107)
    elseif index == 7 then
        self.setting_data.data_list = self.Main.model:GettypeList(40)
    elseif index == 8 then
        self.setting_data.data_list = self.Main.model:GettypeList(108)
    end
    self.transform:Find("Con/No").gameObject:SetActive(#self.setting_data.data_list < 1)
    BaseUtils.refresh_circular_list(self.setting_data)
end

function CombatLogRankPanel:Update()
    -- body
end

function CombatLogRankPanel:RefreshKeepList()
    -- if self.currindex == 2 then
        self:InitList(self.currindex)
    -- end
end