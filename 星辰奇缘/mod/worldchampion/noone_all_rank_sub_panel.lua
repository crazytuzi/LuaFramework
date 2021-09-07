-- 天下第一武道会群雄排行面板
-- @author zgs
NoOneAllRankSubPanel = NoOneAllRankSubPanel or BaseClass(BasePanel)

function NoOneAllRankSubPanel:__init(model,parent)
    self.model = model
    self.parent = parent
    self.name = "NoOneAllRankSubPanel"

    self.resList = {
        {file = AssetConfig.worldchampionallranksubpanel, type = AssetType.Main}
        , {file = AssetConfig.glory_textures, type = AssetType.Dep}
        , {file = AssetConfig.open_server_textures, type = AssetType.Dep}
        ,{file = AssetConfig.no1inworld_textures, type = AssetType.Dep}
    }
    self.showType = 1
    self.subIndex = 1
    self.OnOpenEvent:AddListener(function()
        self:RequireData()
    end)

    self.no1world_rank_data_changeFun = function ()
        -- self:ChangeTab(self.showType)
        self:UpdatePanel()
    end
    EventMgr.Instance:AddListener(event_name.no1world_rank_data_change, self.no1world_rank_data_changeFun)

    self.effectCounter = 0
    self.effectShakeCounter = 0

    self.leftDataList = {
        [1] = {id = 1,name = TI18N("群雄榜"),spriteName = "rankicon",index = 1,isHaveArrow = true,
               subs = {[1] = {id = 1,index = 1,height = 45,label = TI18N("精锐组(70-79级)"),group = 70,callbackData = 1,groupid = 1,},
                       [2] = {id = 2,index = 2,height = 45,label = TI18N("骁勇组(80-89级)"),group = 80,callbackData = 2,groupid = 1,},
                       [3] = {id = 3,index = 3,height = 45,label = TI18N("英雄组(90-100级)"),group = 90,callbackData = 3,groupid = 1,},
                       [4] = {id = 4,index = 4,height = 45,label = TI18N("史诗组(突破95-99)"),group = 101,callbackData = 4,groupid = 1,},
                       [5] = {id = 5,index = 5,height = 45,label = TI18N("传说组(突破100-109)"),group = 106,callbackData = 5,groupid = 1,},
                       [6] = {id = 5,index = 5,height = 45,label = TI18N("至尊组(突破110-119)"),group = 116,callbackData = 6,groupid = 2,},
                       [7] = {id = 5,index = 5,height = 45,label = TI18N("神话组(突破120+)"),group = 126,callbackData = 7,groupid = 3,},
                      }
            },
        [2] = {id = 2,name = TI18N("本服榜"),spriteName = "bfb",index = 2,isHaveArrow = true,
               subs = {[1] = {id = 1,index = 1,height = 45,label = TI18N("精锐组(70-79级)"),group = 70,callbackData = 1,groupid = 2,},
                       [2] = {id = 2,index = 2,height = 45,label = TI18N("骁勇组(80-89级)"),group = 80,callbackData = 2,groupid = 2,},
                       [3] = {id = 3,index = 3,height = 45,label = TI18N("英雄组(90-100级)"),group = 90,callbackData = 3,groupid = 2,},
                       [4] = {id = 4,index = 4,height = 45,label = TI18N("史诗组(突破95-99)"),group = 101,callbackData = 4,groupid = 2,},
                       [5] = {id = 5,index = 5,height = 45,label = TI18N("传说组(突破100-109)"),group = 106,callbackData = 5,groupid = 2,},
                       [6] = {id = 5,index = 5,height = 45,label = TI18N("至尊组(突破110-119)"),group = 116,callbackData = 6,groupid = 2,},
                       [7] = {id = 5,index = 5,height = 45,label = TI18N("神话组(突破120+)"),group = 126,callbackData = 7,groupid = 2,},
                      }
            },
        [3] = {id = 3,name = TI18N("好友榜"),spriteName = "hyb",index = 3,isHaveArrow = false,},
        [4] = {id = 4,name = TI18N("名人堂"),spriteName = "mrt",index = 4,isHaveArrow = true,
               subs = {
                       -- [1] = {id = 1,index = 1,height = 45,label = "终极杀手",group = 1,callbackData = 1,groupid = 4,formName = "累计击杀数量",},
                       [1] = {id = 1,index = 1,height = 45,label = TI18N("胜者为王"),group = 2,callbackData = 1,groupid = 4,formName = TI18N("累计获胜场次"),},
                       -- [3] = {id = 3,index = 3,height = 45,label = "兢兢业业",group = 3,callbackData = 3,groupid = 4,formName = "累计参赛次数",},
                       [2] = {id = 2,index = 2,height = 45,label = TI18N("无所畏惧"),group = 4,callbackData = 2,groupid = 4,formName = TI18N("以弱胜强次数"),},
                       -- [5] = {id = 5,index = 5,height = 45,label = "屡败屡战",group = 5,callbackData = 5,groupid = 4,formName = "胜率最低",},
                       [3] = {id = 3,index = 3,height = 45,label = TI18N("不屈战神"),group = 6,callbackData = 3,groupid = 4,formName = TI18N("被复活次数"),},
                       [4] = {id = 4,index = 4,height = 45,label = TI18N("我是打手"),group = 7,callbackData = 4,groupid = 4,formName = TI18N("累计造成伤害(万)"),},
                       -- [8] = {id = 8,index = 8,height = 45,label = "我叫MT"  ,group = 8,callbackData = 8,groupid = 4,formName = "累计承受伤害",},
                       [5] = {id = 5,index = 5,height = 45,label = TI18N("酱油王"),group = 9,callbackData = 5,groupid = 4,formName = TI18N("0伤害场次"),},
                       [6] = {id = 6,index = 6,height = 45,label = TI18N("MVP榜"),group = 11,callbackData = 6,groupid = 4,formName = TI18N("MVP次数"),},
                       [7] = {id = 7,index = 7,height = 45,label = TI18N("超神"),group = 12,callbackData = 7,groupid = 4,formName = TI18N("超神次数"),},
                       [8] = {id = 8,index = 8,height = 45,label = TI18N("治愈之光"),group = 15,callbackData = 8,groupid = 4,formName = TI18N("获得次数"),},
                       [9] = {id = 9,index = 9,height = 45,label = TI18N("Hold住全场"),group = 16,callbackData = 9,groupid = 4,formName = TI18N("获得次数"),},
                       [10] = {id = 10,index = 10,height = 45,label = TI18N("杀人如麻"),group = 13,callbackData = 10,groupid = 4,formName = TI18N("获得次数"),},
                       [11] = {id = 11,index = 11,height = 45,label = TI18N("火力全开"),group = 14,callbackData = 11,groupid = 4,formName = TI18N("获得次数"),},
                      }
            },
    }
    self.leftDataSort = function (a,b)
        return a.type < b.type
    end
end


function NoOneAllRankSubPanel:RequireData()
    self.showType = 1
    self.subIndex = 1
    if self.openArgs ~= nil then
        if self.openArgs[1] ~= nil then
            self.showType = tonumber(self.openArgs[1])
        end
        if self.openArgs[2] ~= nil then
            self.subIndex = tonumber(self.openArgs[2])
        end
    end
    if self.showType == 3 then
        WorldChampionManager.Instance:Require16416(self.showType,0)
    elseif self.showType == 4 then
        if self.ZoneToggle.isOn == true then
            WorldChampionManager.Instance:Require16418(self.leftDataList[self.showType].subs[self.subIndex].group, 1)
        else
            WorldChampionManager.Instance:Require16418(self.leftDataList[self.showType].subs[self.subIndex].group, 0)
        end
    else
        WorldChampionManager.Instance:Require16416(self.showType,self.leftDataList[self.showType].subs[self.subIndex].group)
    end
end

function NoOneAllRankSubPanel:OnInitCompleted()
    self.showType = 1
    self.subIndex = 1
    if self.openArgs ~= nil then
        if self.openArgs[1] ~= nil then
            self.showType = tonumber(self.openArgs[1])
        end
        if self.openArgs[2] ~= nil then
            self.subIndex = tonumber(self.openArgs[2])
        end
    end
    print(self.showType.."&&&&"..self.subIndex)
    self.tree:ClickMain(self.showType, self.subIndex)
end

function NoOneAllRankSubPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.no1world_rank_data_change, self.no1world_rank_data_changeFun)
    -- self.model.guildfightSetTimePanel = nil
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    -- self.model.guild_fight_givebox_panel = nil
    self.model = nil
end

function NoOneAllRankSubPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionallranksubpanel))
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.gameObject.name = "NoOneAllRankSubPanel"
    self.transform = self.gameObject.transform

    self.leftContainer = self.transform:Find("ScrollPanel/Container").gameObject
    self.baseItem = self.transform:Find("ScrollPanel/Container/BaseItem").gameObject
    self.tree = TreeButton.New(self.leftContainer, self.baseItem, function(index) self:ChangeSubTab(index) end, function(index) self:ChangeTab(index) end)
    --self.tree.canRepeat = false

    local infoTab = {}
    local c = 1
    for index,v in ipairs(self.leftDataList) do
        if index ~= "count" then
            if infoTab[c] == nil then infoTab[c] = {height = 60, subs = {}, type = v.id, datalist = {}} c = c + 1 end
            local main = infoTab[c - 1]
            -- main.datalist = v.sub
            if v.subs ~= nil then
                main.subs = v.subs
            end
            main.isHaveArrow = v.isHaveArrow
            main.label = v.name
            main.sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures, v.spriteName)
        end
    end
    self.treeInfo = infoTab
    table.sort(self.treeInfo, self.leftDataSort)
    -- BaseUtils.dump(self.treeInfo,"$$$$$$$$$$$$$$$$$$$$$")
    self.tree:SetData(self.treeInfo)

    self.rankText = self.transform:Find("Personal/Rank"):GetComponent(Text) --我的排名
    self.levText = self.transform:Find("Personal/Score"):GetComponent(Text) --级别
    self.Desc = self.transform:Find("Personal/Desc")
    self.ZoneToggle = self.transform:Find("Personal/Toggle"):GetComponent(Toggle)
    self.ZoneToggle.onValueChanged:AddListener(function()
        self:OnToggleChange()
    end)
    self.boxName = self.transform:Find("Personal/BoxName"):GetComponent(Text) --级别

    self.noneObj = self.transform:Find("Panel4/Panel/Nothing").gameObject
    self.noneObj:SetActive(false)

    self.showTitleText = self.transform:Find("Panel4/PanelTitle/Title4/Text"):GetComponent(Text)
    self.scroll_con = self.transform:Find("Panel4/Panel")
    self.layoutContainer = self.transform:Find("Panel4/Panel/Container")
    self.scroll = self.transform:Find("Panel4/Panel"):GetComponent(RectTransform)
    self.memberLayout = LuaBoxLayout.New(self.layoutContainer.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4})--,scrollRect = self.scroll})
    -- self.memberItem = self.layoutContainer:Find("Cloner").gameObject
    -- self.memberItem:SetActive(false)


    -- self.item_con = self.scroll_con:FindChild("Container")
    self.item_con_last_y = self.layoutContainer:GetComponent(RectTransform).anchoredPosition.y
    self.vScroll = self.scroll_con:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.item_list = {}
    for i=1,15 do
        -- local obj = GameObject.Instantiate(self.memberItem)
        -- obj.name = tostring(i)
        -- self.memberLayout:AddCell(obj)
        -- local item = GuildFightBoxMenberItem.New(obj,self)
        -- table.insert(self.item_list, item)

        local obj = self.layoutContainer:Find("Cloner_"..i).gameObject
        -- self.memberLayout:AddCell(obj)
        local item = NoOneRankItem.New(obj,self)
        table.insert(self.item_list, item)
    end

    self.single_item_height = self.item_list[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.scroll_con_height = self.scroll_con:GetComponent(RectTransform).sizeDelta.y
    self.setting_data = {
       item_list = self.item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.layoutContainer  --item列表的父容器
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

    self.bottomDesc = self.transform:Find("Desc"):GetComponent(Text)
    -- self.bottomRightSA = self.transform:Find("SelectArea").gameObject
    -- self.bottomRightSA:SetActive(false)
    -- self.toggleBottom = self.transform:Find("SelectArea/Toggle"):GetComponent(Toggle)
    -- self.toggleBottom.isOn = false
    -- self.toggleBottom.onValueChanged:AddListener(function (status)
    --     if status == true then
    --         self.showType = 2
    --         WorldChampionManager.Instance:Require16416(2)
    --     else
    --         self.showType = 1
    --         WorldChampionManager.Instance:Require16416(1)
    --     end
    -- end)
end

-- function NoOneAllRankSubPanel:ShakeGameObject(bool)
--     local maxTime = 6280
--     self.effectCounter = (self.effectCounter + 40) % maxTime
--     self.effectShakeCounter = (self.effectShakeCounter + 2) % 100
--     if bool == true and self.effectShakeCounter >= 30 then
--         LuaTimer.Delete(self.shakeTimerId)
--         self.shakeTimerId = 0
--         self.treasureRect.rotation = Quaternion.Euler(0, 0, 0)
--         return
--     end
--     local status = 1
--     if self.effectShakeCounter > 30 then status = 0 end
--     local diff = math.sin(self.effectCounter / 20)
--     self.treasureRect.rotation = Quaternion.Euler(0, 0, diff * status * 5)
-- end

function NoOneAllRankSubPanel:getLevDesc()
    return string.format(TI18N("赛季结算宝箱：<color='#ffff00'>%s宝箱</color>"), DataTournament.data_list[WorldChampionManager.Instance.rankData.season_rank_lev].name)
end

function NoOneAllRankSubPanel:onClickShowReward()
    -- 显示宝箱物品
end

function NoOneAllRankSubPanel:ChangeTab(index)
    self.showType = index
    -- print("NoOneAllRankSubPanel:ChangeTab(index) =self.showType= "..self.showType)
    if self.showType == 3 then
        WorldChampionManager.Instance:Require16416(self.showType,0)
    end
end

function NoOneAllRankSubPanel:ChangeSubTab(index)
    self.subIndex = index
    -- print("NoOneAllRankSubPanel:ChangeSubTab(index) =self.showType= "..self.showType)
    -- print("NoOneAllRankSubPanel:ChangeSubTab(index) =self.subIndex= "..self.subIndex)
    if self.showType == 4 then
        if self.ZoneToggle.isOn == true then
            WorldChampionManager.Instance:Require16418(self.leftDataList[self.showType].subs[self.subIndex].group, 1)
        else
            WorldChampionManager.Instance:Require16418(self.leftDataList[self.showType].subs[self.subIndex].group, 0)
        end
        -- WorldChampionManager.Instance:Require16418(self.leftDataList[self.showType].subs[self.subIndex].group)
    elseif self.leftDataList[self.showType].subs ~= nil and #self.leftDataList[self.showType].subs > 0 then
        WorldChampionManager.Instance:Require16416(self.showType,self.leftDataList[self.showType].subs[self.subIndex].group)
    end
end

function NoOneAllRankSubPanel:OnToggleChange()
    self:ChangeSubTab(self.subIndex)
end

function NoOneAllRankSubPanel:UpdatePanel()
    self.levText.text = DataTournament.data_list[WorldChampionManager.Instance.rankData.rank_lev].name
    self.boxName.text = string.format(TI18N("%s级宝箱"), tostring(WorldChampionManager.Instance.rankData.season_rank_lev))
    self.levText.gameObject:SetActive(self.showType < 4)
    self.Desc.gameObject:SetActive(self.showType < 4)
    self.ZoneToggle.gameObject:SetActive(not (self.showType < 4))
    if self.showType < 4 then
        self.showTitleText.text = TI18N("头衔")
        local sortFun = function(a, b)
            if a.rank_lev > b.rank_lev then
                return true
            elseif a.rank_lev < b.rank_lev then
                return false
            else
                if a.rank_point > b.rank_point then
                    return true
                elseif a.rank_point < b.rank_point then
                    return false
                else
                    if a.rid < b.rid then
                        return true
                    else
                        return false
                    end
                end
            end
        end
        local groupTemp = 0
        if self.leftDataList ~= nil and self.leftDataList[self.showType].subs ~= nil then
            groupTemp = self.leftDataList[self.showType].subs[self.subIndex].group
        end
        table.sort(WorldChampionManager.Instance.rankList[self.showType][groupTemp].rank, sortFun)

        self.rankText.text = TI18N("暂未上榜")
        local roleData = RoleManager.Instance.RoleData
        for i,v in ipairs(WorldChampionManager.Instance.rankList[self.showType][groupTemp].rank) do
            if roleData.id == v.rid and roleData.platform == v.platform and roleData.zone_id == v.zone_id then
                self.rankText.text = string.format(TI18N("我的排名: %s"),tostring(i))
                break
            end
        end

        self:UpdateList(WorldChampionManager.Instance.rankList[self.showType][groupTemp].rank)

        if #WorldChampionManager.Instance.rankList[self.showType][groupTemp].rank > 0 then
            self.noneObj:SetActive(false)
        else
            self.noneObj:SetActive(true)
        end
    else
        local range = 0
        if self.ZoneToggle.isOn == true then
            range = 1
        end
        local groupTemp = self.leftDataList[self.showType].subs[self.subIndex].group
        local Key = string.format("%s%s", groupTemp, range)
        self.showTitleText.text = self.leftDataList[self.showType].subs[self.subIndex].formName
        local sortFun = function(a, b)
            if a.val1 > b.val1 then
                return true
            elseif a.val1 < b.val1 then
                return false
            else
                return a.rid < b.rid
            end
        end
        table.sort(WorldChampionManager.Instance.famousList[Key].rank, sortFun)

        self.rankText.text = TI18N("暂未上榜")
        local roleData = RoleManager.Instance.RoleData
        for i,v in ipairs(WorldChampionManager.Instance.famousList[Key].rank) do
            if roleData.id == v.rid and roleData.platform == v.platform and roleData.zone_id == v.zone_id then
                self.rankText.text = string.format(TI18N("我的排名: %s"),tostring(i))
                break
            end
        end
        self:UpdateList(WorldChampionManager.Instance.famousList[Key].rank)

        if #WorldChampionManager.Instance.famousList[Key].rank > 0 then
            self.noneObj:SetActive(false)
        else
            self.noneObj:SetActive(true)
        end
    end
end

function NoOneAllRankSubPanel:UpdateList(dataList)
    self.setting_data.data_list = dataList

    BaseUtils.refresh_circular_list(self.setting_data)

end
