-- 战斗录像
-- @author huangzefeng
-- @date 20160517
CombatLogSelfPanel = CombatLogSelfPanel or BaseClass(BasePanel)

function CombatLogSelfPanel:__init(Main)
    self.Main = Main
    self.name = "CombatLogSelfPanel"
    self.Mgr = CombatManager.Instance
    self.resList = {
        {file = AssetConfig.combatlog_panel, type = AssetType.Main}
        -- ,{file  =  AssetConfig.dropicon, type  =  AssetType.Dep}
    }
    self.hasinit = false
    self.updatekeep = function()
        self:RefreshKeepList()
    end
    self.updatecurr = function()
        self:RefreshCurrList()
    end
end


function CombatLogSelfPanel:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
    self:AssetClearAll()
    if self.ItemObjList ~= nil then
        for i,v in ipairs(self.ItemObjList) do
            v:DeleteMe()
        end
    end
    self.Mgr.OnCurrLogChange:RemoveAll()
    self.Mgr.OnKeepLogChange:RemoveAll()
end

function CombatLogSelfPanel:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.combatlog_panel))
    UIUtils.AddUIChild(self.Main.MainCon.gameObject, self.gameObject)
    self.gameObject.name = "CombatLogSelfPanel"
    self.transform = self.gameObject.transform

    self.tabCon = self.transform:Find("TabButtonGroup")
    self.tab_base = self.transform:Find("TabButtonGroup/Button").gameObject
    self.infoBtn = self.transform:Find("Con/TitleBar/Button")
    self.infoBtn:GetComponent(Button).onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.infoBtn.gameObject, itemData = {
            TI18N("1.收录最近<color='#ffff00'>20</color>场战斗的录像"),
            TI18N("2.点击录像名称可以<color='#ffff00'>分享</color>到聊天频道"),
            TI18N("3.点击<color='#ffff00'>收藏</color>，点击将喜爱的录像永久保留下来"),
            TI18N("4.最多同时收藏<color='#ffff00'>10</color>场战斗录像"),
            }})
        end)

    local secondtab = GameObject.Instantiate(self.tab_base)
    secondtab.transform:SetParent(self.tabCon)
    secondtab.transform.localScale = Vector3.one
    secondtab.transform.anchoredPosition = Vector2(100, -26)
    self.Main:SetTabBtn(self.tabCon:GetChild(0), TI18N("最近战斗"))
    self.Main:SetTabBtn(self.tabCon:GetChild(1), TI18N("录像收藏"))

    self.container = self.transform:Find("Con/List/Container")
    self.currindex = 1
    self.tabgroup = TabGroup.New(self.tabCon.gameObject, function (tab) self:OnTabChange(tab) end)
    self.hasinit = true
    self.Mgr.OnCurrLogChange:AddListener(self.updatecurr)
    self.Mgr.OnKeepLogChange:AddListener(self.updatekeep)
end

function CombatLogSelfPanel:OnTabChange(index)
    if index == 1 then
    elseif index == 2 then
    end
    self.currindex = index
    self:InitList(index)
end


function CombatLogSelfPanel:InitList(index)
    -- if self.ItemObjList == nil then
        self.ItemObjList = {}
        for i=1,10 do
            local go = self.container:GetChild(i-1).gameObject
            table.insert(self.ItemObjList, CombatLogItem.New(go, self, index))
        end
    -- end
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
        self.setting_data.data_list = self.Main.model.currList
    else
        self.setting_data.data_list = self.Main.model.keepList
    end
    self.transform:Find("Con/No").gameObject:SetActive(#self.setting_data.data_list < 1)
    BaseUtils.refresh_circular_list(self.setting_data)
end

function CombatLogSelfPanel:Update()
    self.setting_data.data_list = lis1
    BaseUtils.refresh_circular_list(self.setting_data)
end

function CombatLogSelfPanel:RefreshKeepList()
    -- if self.currindex == 2 then
        self:InitList(self.currindex)
    -- end
end
function CombatLogSelfPanel:RefreshCurrList()
    -- if self.currindex == 1 then
        self:InitList(self.currindex)
    -- end
end