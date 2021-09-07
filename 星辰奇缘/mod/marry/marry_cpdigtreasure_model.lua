CpDigTreasureModel = CpDigTreasureModel or BaseClass(BaseModel)

function CpDigTreasureModel:__init()
    self.item_map_id = nil
    self.item_x = nil
    self.item_y = nil
    self.item_id = nil

    self.itemdata = nil

    self.moveEndCbFun = function ()
        self:MoveEndCallBack()
    end
end

function CpDigTreasureModel:__delete()

end


function CpDigTreasureModel:use_treasuremap(itemdata)
    -- BaseUtils.dump(itemdata,"CpDigTreasureModel:use_treasuremap(itemdata)")
    if RoleManager.Instance.RoleData.lev < itemdata.lev then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ff0000'>%s级</color>才能使用<color='#cccccc'>%s</color>"), itemdata.lev, itemdata.name))
        return
    end
    if TeamManager.Instance:HasTeam() == false then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s与一名异性好友组队才可使用"), itemdata.name))
        return
    end
    local isCp = false
    local isFriend = false --是否是好支
    local isIsomerism = false --是否是异性
    if TeamManager.Instance.teamNumber == 2 then
        local myData = RoleManager.Instance.RoleData
        for key, value in pairs(TeamManager.Instance.memberTab) do
            -- value.rid, value.platform, value.zone_id
             if myData.lover_id == value.rid and myData.lover_platform == value.platform and myData.lover_zone_id == value.zone_id then
                isCp = true
                break
             end
        end
        for key, value in pairs(TeamManager.Instance.memberTab) do
            -- value.rid, value.platform, value.zone_id
            -- FriendManager.Instance:IsFriend(data.id, data.platform, data.zone_id)
             if FriendManager.Instance:IsFriend(value.rid, value.platform, value.zone_id) == true then
                isFriend = true
             end
             if myData.sex ~= value.sex then
                isIsomerism = true
             end
             if isFriend == true and isIsomerism == true then
                break
             end
        end
    elseif TeamManager.Instance.teamNumber > 2 then
        NoticeManager.Instance:FloatTipsByString(TI18N("队伍中存在第三者，不能让其他人知道你们二人之间的小秘密哦"))
        return
    end
    -- if isCp == false then
    --     NoticeManager.Instance:FloatTipsByString("需要与你的伴侣组队才可使用同心宝藏")
    --     return
    -- end

    if isFriend == false then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("需要异性好友才能挖掘%s哦"), itemdata.name))
        return
    end

    if isIsomerism == false then
        NoticeManager.Instance:FloatTipsByString(TI18N("需要组上你异性好友才能开启"))
        return
    end

    if TeamManager.Instance:IsSelfCaptin() == false then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("只能由队长使用%s哦"), itemdata.name))
        return
    end

    if BackpackManager.Instance:GetCurrentGirdNum() <= 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("背包已满，请先整理背包"))
        return
    end
    self.itemdata = itemdata
    -- BaseUtils.dump(itemdata,"itemdata")
    self.item_map_id = nil
    self.item_x = nil
    self.item_y = nil
    self.item_id = itemdata.id
    for k,v in pairs(itemdata.extra) do
        if v.name == BackpackEumn.ExtraName.map_id then
            self.item_map_id = v.value
        elseif v.name == BackpackEumn.ExtraName.map_x then
            self.item_x = v.value
        elseif v.name == BackpackEumn.ExtraName.map_y then
            self.item_y = v.value
        end
    end

    if self.item_map_id ~= nil and self.item_x ~= nil and self.item_y ~= nil then
        if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
            local self_point = SceneManager.Instance.sceneElementsModel.self_view.gameObject.transform.position
            self_point = SceneManager.Instance.sceneModel:transport_big_pos(self_point.x, self_point.y)
            if SceneManager.Instance:CurrentMapId() == self.item_map_id then
                local dis = BaseUtils.distance_byxy(self.item_x, self.item_y, self_point.x, self_point.y)
                if dis < 150 then
                    TipsManager.Instance.model:Closetips()
                    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.backpack)
                    local itemdataTemp = BackpackManager.Instance:GetItemById(self.item_id)
                    -- print(self.item_id)
                    -- print(itemdataTemp)
                    -- print(NoticeManager.Instance.model.autoUse.showing)
                    if itemdataTemp ~= nil and not NoticeManager.Instance.model.autoUse.showing then
                        local autoUseData = AutoUseData.New()
                        autoUseData.callback = function()
                            SceneManager.Instance.sceneElementsModel.self_view:StopMoveTo()
                            QuestManager.Instance.model.lastType = 0
                            LuaTimer.Add(50, function ()
                                local func = function()
                                    BackpackManager.Instance:Send10315(self.item_id, 1)
                                    self.item_id = nil
                                end
                                SceneManager.Instance.sceneElementsModel.collection.callback = func
                                SceneManager.Instance.sceneElementsModel.collection:Show({msg = TI18N("挖宝中..."), time = 2000})

                                SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                                SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(2)
                            end)
                        end
                        autoUseData.itemData = itemdataTemp
                        NoticeManager.Instance:GuildPublicity(autoUseData)
                    end
                else
                    TipsManager.Instance.model:Closetips()
                    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.backpack)
                    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                    SceneManager.Instance.sceneElementsModel:Self_AutoPath(self.item_map_id, nil, self.item_x, self.item_y, true,self.moveEndCbFun)
                    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)

                    -- if not self.is_checking_treasuremap then
                    --     self:check_treasuremap()
                    -- end
                end
            else
                TipsManager.Instance.model:Closetips()
                WindowManager.Instance:CloseWindowById(WindowConfig.WinID.backpack)
                SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                SceneManager.Instance.sceneElementsModel:Self_AutoPath(self.item_map_id, nil, self.item_x, self.item_y, true,self.moveEndCbFun)
                SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)

                -- if not self.is_checking_treasuremap then
                --     self:check_treasuremap()
                -- end
            end
        end
    end
end

function CpDigTreasureModel:CheckMoveToNext()
    local item_list = BackpackManager.Instance:GetItemByBaseid(29143)
    if #item_list > 0 then
        -- BaseUtils.dump(item_list[1],"BaseUtils.dump(item_list[1])")
        LuaTimer.Add(1000, function() self:use_treasuremap(item_list[1]) end)
        return
    end
end

function CpDigTreasureModel:MoveEndCallBack()
    self:use_treasuremap(self.itemdata)
end

