GodsWarWorShipModel = GodsWarWorShipModel or BaseClass(BaseModel)

function GodsWarWorShipModel:__init()
    self.win = nil
    self.plotNpcFormation = {baseid = 43091,x = 1822,y = 1738,unit_id = 8,battle_id = 8}
     self.plotInformation =
    {
        [1] = {baseid = 43082,x = 2021,y = 1700,unit_id = 1,battle_id = 1},
        [2] = {baseid = 43083,x = 1700,y = 1620,unit_id = 2,battle_id = 2},
        [3] = {baseid = 43084,x = 1665,y = 1459,unit_id = 3,battle_id = 3},
        [4] = {baseid = 43085,x = 1900,y = 1343,unit_id = 4,battle_id = 4},
        [5] = {baseid = 43086,x = 2222,y = 1339,unit_id = 5,battle_id = 5},
        [6] = {baseid = 43087,x = 2323,y = 1460,unit_id = 6,battle_id = 6},
        [7] = {baseid = 43088,x = 2260,y = 1700,unit_id = 7,battle_id = 7},
    }

    self.plotInformation2 =
    {
        [1] = {baseid = 43082,x = 2180 ,y = 1660,unit_id = 1,battle_id = 1},
        [2] = {baseid = 43083,x = 1900 ,y = 1660,unit_id = 2,battle_id = 2},
        [3] = {baseid = 43084,x = 1700 ,y = 1500,unit_id = 3,battle_id = 3},
        [4] = {baseid = 43085,x = 1900 ,y = 1340,unit_id = 4,battle_id = 4},
        [5] = {baseid = 43086,x = 2180 ,y = 1340,unit_id = 5,battle_id = 5},
        [6] = {baseid = 43088,x = 2380  ,y = 1500,unit_id = 6,battle_id = 6},
    }

    self.plotInformation3 =
    {
        [1] = {baseid = 43082,x = 2020,y = 1700,unit_id = 1,battle_id = 1},
        [2] = {baseid = 43083,x = 1700,y = 1540,unit_id = 2,battle_id = 2},
        [3] = {baseid = 43084,x = 1860,y = 1340,unit_id = 3,battle_id = 3},
        [4] = {baseid = 43085,x = 2220,y = 1340,unit_id = 4,battle_id = 4},
        [5] = {baseid = 43088,x = 2380,y = 1540,unit_id = 5,battle_id = 5},
    }

    self.vedioGroup = {
    [1] = {name = "新星组",minLev = 80,maxLev = 89},
    [2] = {name = "超凡组",minLev = 90,maxLev = 99},
    [3] = {name = "绝尘组",minLev = 100,maxLev = 106},
    [4] = {name = "登峰组",minLev = 107,maxLev = 115},
    [5] = {name = "王者组",minLev = 116,maxLev = 200},
    }

    self.audiencePoint =
     {{61,32},
   {63,34},
   {64,35},
   {64,41},
   {63,42},
   {60,45},
   {49,46},
   {37,41},
   {55,46},
   {43,46},
   {35,39},
   {34,38},
   {35,37},
   {37,35},
   {38,34},
   {40,32},
   {41,31},
   {44,30},
   {50,30},
   {56,30},
   {58,30},
   {60,31},
   {38,42},
   {40,44},
   {65,39},
   {62,44},
   {41,45},
   {66,37},
   {46,46},
   {52,46},
   {58,46},
   {47,30},
   {53,30}}
    self.audienceList = {}
    self.audienceMaxNumber = 60
    self.playGodsWarPlot = false
    self.isPalyGodsWarPlotEnd = true
    self.centerPosition = Vector2(2020,1600)

    self.GodWarChanllengeReadyStatus = 0 --未准备
end

function GodsWarWorShipModel:OpenWindow(args)
    if self.win == nil then
        self.win = GodsWarWorShipWindow.New(self)
    end

    self.win:Open(args)
end

function GodsWarWorShipModel:CloseWin()
    if self.win ~= nil then
        WindowManager.Instance:CloseWindow(self.win)
    end
end

function GodsWarWorShipModel:OpenDamakuSetting()
    if self.damakuSetting == nil then
        self.damakuSetting = GodsWarCloseDanmu.New(self, TipsManager.Instance.model.tipsCanvas)
    end
    self.damakuSetting:Show()
end

function GodsWarWorShipModel:CloseDamakuSetting()
    if self.damakuSetting ~= nil then
        self.damakuSetting:DeleteMe()
        self.damakuSetting = nil
    end
end

function GodsWarWorShipModel:OpenGodsWarWorShipIcon()
    if self.godsWarWorShipIcon == nil then
        self.godsWarWorShipIcon = GodsWarWorShipIcon.New(self)
    end
    self.godsWarWorShipIcon:Show()
end

function GodsWarWorShipModel:CloseGodsWarWorShipIcon()
    if self.godsWarWorShipIcon ~= nil then
        self.godsWarWorShipIcon:DeleteMe()
        self.godsWarWorShipIcon = nil
    end
end

-- 播放冠军仪式的剧情
function GodsWarWorShipModel:BeginGodsWarWorShipPlot()
    if GodsWarWorShipManager.Instance.plotIsCompelete == false then
        return
    end
    local npcList = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
    local activeMsg1 = string.format("我们<color='#ffff00'>%s战队</color>最强",GodsWarWorShipManager.Instance.godsWarWorShipData[#GodsWarWorShipManager.Instance.godsWarWorShipData].name)
    local activeMsg2 = string.format("<color='#ffff00'>%s战队</color>最强",GodsWarWorShipManager.Instance.godsWarWorShipData[#GodsWarWorShipManager.Instance.godsWarWorShipData].name)

    self.unitIndex = 9
    local startIndex = 13
    self:ApplyAudience()

    local npcPlotList = nil
    if GodsWarWorShipManager.Instance.godsWarWorShipData ~= nil and GodsWarWorShipManager.Instance.godsWarWorShipData[GodsWarWorShipManager.Instance.nowChampionTeams].members ~= nil then
        npcPlotList = GodsWarWorShipManager.Instance.godsWarWorShipData[GodsWarWorShipManager.Instance.nowChampionTeams].members
    end
    -- BaseUtils.GetShowActionId(self.current_classes, self.current_sex)
    self.dramaList = {
        self.audienceDramaList
        ,{type = DramaEumn.ActionType.Cameramoveto, x = self.plotNpcFormation.x, y = self.plotNpcFormation.y, time = 1000}
        , {type = DramaEumn.ActionType.Animationplaypoint, x = self.plotNpcFormation.x, y = self.plotNpcFormation.y, res_id = 30019}
        , {type = DramaEumn.ActionType.Plotunitcreate, unit_id = self.plotNpcFormation.unit_id, battle_id = self.plotNpcFormation.battle_id, unit_base_id = self.plotNpcFormation.baseid, msg = self.plotNpcFormation.name, mapid = 53011, x = self.plotNpcFormation.x, y = self.plotNpcFormation.y,time = 600}
        , {type = DramaEumn.ActionType.WaitClient, val = 1200}
        ,{type = DramaEumn.ActionType.Unittalkbubble,unit_id = self.plotNpcFormation.unit_id,battle_id = self.plotNpcFormation.battle_id,msg = "大家好，我是智慧王福波斯，也是本次诸神颁奖典礼的司仪",time = 1000,isUnit = true}
        ,{type = DramaEumn.ActionType.WaitClient, val = 1500}
        ,{type = DramaEumn.ActionType.Unittalkbubble,unit_id = self.plotNpcFormation.unit_id,battle_id = self.plotNpcFormation.battle_id,msg = "接下来我要宣布本届诸神的<color='#ffff00'>冠军</color>得主",time = 1000,isUnit = true}
        , {type = DramaEumn.ActionType.WaitClient, val = 1500}
        ,{type = DramaEumn.ActionType.Unittalkbubble,unit_id = self.plotNpcFormation.unit_id,battle_id = self.plotNpcFormation.battle_id,msg = string.format("<color='#ffff00'>%s</color>战队",GodsWarWorShipManager.Instance.godsWarWorShipData[#GodsWarWorShipManager.Instance.godsWarWorShipData].name),time = 1000,isUnit = true}
        , {type = DramaEumn.ActionType.WaitClient, val = 1500}
        ,{type = DramaEumn.ActionType.CustomMultiaction,val = {
            {type = DramaEumn.ActionType.Unittalkbubble,unit_id = self.plotNpcFormation.unit_id,battle_id = self.plotNpcFormation.battle_id,msg = "接下来我们欢迎<color='#ffff00'>王者登场</color>",time = 1000,isUnit = true}
            ,{type = DramaEumn.ActionType.Actunit,unit_id = self.plotNpcFormation.unit_id,battle_id = self.plotNpcFormation.battle_id,msg = "Idle1",x = self.plotNpcFormation.x, y = self.plotNpcFormation.y,ext_val = 2000}
            }
        }
        , {type = DramaEumn.ActionType.WaitClient, val = 2500}


        ,{type = DramaEumn.ActionType.Cameramoveto, x = self.centerPosition.x, y = self.centerPosition.y - 200, time = 200}
        ,{type = DramaEumn.ActionType.Unittalkbubble,unit_id = npcPlotList[#GodsWarWorShipManager.Instance.godsWarWorShipData[GodsWarWorShipManager.Instance.nowChampionTeams].members].unit_id,battle_id = npcPlotList[#GodsWarWorShipManager.Instance.godsWarWorShipData[GodsWarWorShipManager.Instance.nowChampionTeams].members].battle_id,msg = "很荣幸能成为本次诸神的冠军",time = 1000,isUnit = true}
        ,{type = DramaEumn.ActionType.WaitClient, val = 1500}
        ,{type = DramaEumn.ActionType.Unittalkbubble,unit_id = npcPlotList[#GodsWarWorShipManager.Instance.godsWarWorShipData[GodsWarWorShipManager.Instance.nowChampionTeams].members].unit_id,battle_id = npcPlotList[#GodsWarWorShipManager.Instance.godsWarWorShipData[GodsWarWorShipManager.Instance.nowChampionTeams].members].battle_id,msg = "感谢一起奋斗的队友，令人尊敬的对手",time = 1000,isUnit = true}
        ,{type = DramaEumn.ActionType.WaitClient, val = 1500}
        ,{type = DramaEumn.ActionType.Unittalkbubble,unit_id = npcPlotList[#GodsWarWorShipManager.Instance.godsWarWorShipData[GodsWarWorShipManager.Instance.nowChampionTeams].members].unit_id,battle_id = npcPlotList[#GodsWarWorShipManager.Instance.godsWarWorShipData[GodsWarWorShipManager.Instance.nowChampionTeams].members].battle_id,msg = "最后我还想说",time = 1000,isUnit = true}
        ,{type = DramaEumn.ActionType.WaitClient, val = 1500}
        ,{type = DramaEumn.ActionType.Unittalkbubble,unit_id = npcPlotList[#GodsWarWorShipManager.Instance.godsWarWorShipData[GodsWarWorShipManager.Instance.nowChampionTeams].members].unit_id,battle_id = npcPlotList[#GodsWarWorShipManager.Instance.godsWarWorShipData[GodsWarWorShipManager.Instance.nowChampionTeams].members].battle_id,msg = activeMsg1,time = 1000,isUnit = true}
        ,{type = DramaEumn.ActionType.WaitClient, val = 1500}

         , {type = DramaEumn.ActionType.WaitClient, val = 2000}


        ,{type = DramaEumn.ActionType.Cameramoveto, x = self.plotNpcFormation.x, y = self.plotNpcFormation.y, time = 300}
        ,{type = DramaEumn.ActionType.Unittalkbubble,unit_id = self.plotNpcFormation.unit_id,battle_id = self.plotNpcFormation.battle_id,msg = "大家鼓掌，接下来冠军会<color='#ffff00'>撒下奖励</color>，大家快去抢吧",time = 2000,isUnit = true}
        , {type = DramaEumn.ActionType.Animationplaypoint, x = self.plotNpcFormation.x, y = self.plotNpcFormation.y + 60,z = 0,res_id = 30218}
        , {type = DramaEumn.ActionType.WaitClient, val = 3000}

        , {type = DramaEumn.ActionType.Camerareset, time = 1000}
        , {type = DramaEumn.ActionType.Plotunitdel, unit_id = 1}
        , {type = DramaEumn.ActionType.Plotunitdel, unit_id = 2}
        , {type = DramaEumn.ActionType.Plotunitdel, unit_id = 3}
        , {type = DramaEumn.ActionType.Plotunitdel, unit_id = 4}
        , {type = DramaEumn.ActionType.Plotunitdel, unit_id = 5}
        , {type = DramaEumn.ActionType.Plotunitdel, unit_id = 6}
        , {type = DramaEumn.ActionType.Plotunitdel, unit_id = 7}
        , {type = DramaEumn.ActionType.Plotunitdel, unit_id = 8}
        ,self.audienceDeleteDramaList
        , {type = DramaEumn.ActionType.Endplot, callback = function() self:EndPlot() end}
    }


    if GodsWarWorShipManager.Instance.godsWarWorShipData ~= nil and GodsWarWorShipManager.Instance.godsWarWorShipData[GodsWarWorShipManager.Instance.nowChampionTeams].members ~= nil then
       for i=1,#GodsWarWorShipManager.Instance.godsWarWorShipData[GodsWarWorShipManager.Instance.nowChampionTeams].members do
            local plotData = {type = DramaEumn.ActionType.Cameramoveto, x = npcPlotList[i].x, y = npcPlotList[i].y, time = 200}
            table.insert(self.dramaList,startIndex,plotData)
            startIndex = startIndex + 1
            plotData = {type = DramaEumn.ActionType.Animationplaypoint, x = npcPlotList[i].x, y = npcPlotList[i].y, res_id = 30019}
            table.insert(self.dramaList,startIndex,plotData)
            startIndex = startIndex + 1
            plotData = {type = DramaEumn.ActionType.Plotunitcreate, unit_id = npcPlotList[i].unit_id, battle_id = npcPlotList[i].battle_id, unit_base_id = npcPlotList[i].baseid, msg = npcPlotList[i].name, mapid = 53011, x = npcPlotList[i].x, y = npcPlotList[i].y,sex = npcPlotList[i].sex,classes = npcPlotList[i].classes,looks = npcPlotList[i].looks,time = 600}
            table.insert(self.dramaList,startIndex,plotData)
            startIndex = startIndex + 1

            plotData ={type = DramaEumn.ActionType.WaitClient, val = 1000}
            table.insert(self.dramaList,startIndex,plotData)
            startIndex = startIndex + 1
            plotData = {type = DramaEumn.ActionType.CustomMultiaction,val = {
                {type = DramaEumn.ActionType.Unittalkbubble,unit_id = npcPlotList[i].unit_id,battle_id = npcPlotList[i].battle_id,msg = npcPlotList[i].name,time = 4000,isUnit = true}
                ,{type = DramaEumn.ActionType.Actunit,unit_id = npcPlotList[i].unit_id,battle_id = npcPlotList[i].battle_id,msg = tostring(BaseUtils.GetShowActionId(npcPlotList[i].classes, npcPlotList[i].sex)),x = npcPlotList[1].x, y = npcPlotList[1].y,ext_val = 4000}
                }
            }
            table.insert(self.dramaList,startIndex,plotData)
            startIndex = startIndex + 1
            plotData = {type = DramaEumn.ActionType.WaitClient, val = 4000}
            table.insert(self.dramaList,startIndex,plotData)
            startIndex = startIndex + 1
        end
        local myPlotData = {type = DramaEumn.ActionType.CustomMultiaction,val = {}}
        for i=1,#GodsWarWorShipManager.Instance.godsWarWorShipData[GodsWarWorShipManager.Instance.nowChampionTeams].members - 1 do
                table.insert(myPlotData.val,{type = DramaEumn.ActionType.Unittalkbubble,unit_id = npcPlotList[i].unit_id,battle_id = npcPlotList[i].battle_id,msg = activeMsg2,time = 1500,isUnit = true})
        end
        table.insert(self.dramaList,startIndex + 9,myPlotData)
    end

    -- BaseUtils.dump(self.dramaList,"ksjfskljfkl")
    self.playGodsWarPlot = true
    self.isPalyGodsWarPlotEnd = false
    DramaManagerCli.Instance:ExquisiteShelf(self.dramaList)

    self.playGodsWarPlot = false
    GodsWarWorShipManager.Instance:Send17949()
    self:BeginPlot()
end

function GodsWarWorShipModel:ClearPlot()
    if self.audienceDeleteDramaList == nil then
        self.audienceDeleteDramaList =  {type = DramaEumn.ActionType.Plotunitdel, unit_id = 8}
    end
    -- if self.audienceDeleteDramaList ~= nil then
            local dramaList = {
            {type = DramaEumn.ActionType.Plotunitdel, unit_id = 1}
            , {type = DramaEumn.ActionType.Plotunitdel, unit_id = 2}
            , {type = DramaEumn.ActionType.Plotunitdel, unit_id = 3}
            , {type = DramaEumn.ActionType.Plotunitdel, unit_id = 4}
            , {type = DramaEumn.ActionType.Plotunitdel, unit_id = 5}
            , {type = DramaEumn.ActionType.Plotunitdel, unit_id = 6}
            , {type = DramaEumn.ActionType.Plotunitdel, unit_id = 7}
            , {type = DramaEumn.ActionType.Plotunitdel, unit_id = 8}
            ,self.audienceDeleteDramaList
            , {type = DramaEumn.ActionType.Endplot, callback = function() self:EndPlot() end}
        }
        DramaManagerCli.Instance:ExquisiteShelf(dramaList)

end

function GodsWarWorShipModel:EndPlot()
    self.isPalyGodsWarPlotEnd = true

    if MainUIManager.Instance.mainuitracepanel ~= nil then
        MainUIManager.Instance.mainuitracepanel:TweenShow()
    end
    -- SceneManager.Instance.sceneElementsModel:Show_Npc(true)
    -- SceneManager.Instance.sceneElementsModel:Show_OtherRole(true)
    -- SceneManager.Instance.sceneElementsModel:Show_Self(true)
    self:SetMove(true)

end

function GodsWarWorShipModel:SetMove(bool)
    SceneManager.Instance.sceneElementsModel:Set_isovercontroll(bool == true)
    -- SceneManager.Instance.sceneElementsModel.isovercontroll = (bool == true)
end

function GodsWarWorShipModel:BeginPlot()

    if MainUIManager.Instance.mainuitracepanel ~= nil then
        MainUIManager.Instance.mainuitracepanel:TweenHiden()
    end
    TipsManager.Instance.model:Closetips()
    MainUIManager.Instance:HideDialog()
    DramaManager.Instance.model.plotPlaying = true
    NoticeManager.Instance:HideAutoUse()
    DramaManager.Instance.model:HideOtherUI()
    SceneManager.Instance.sceneElementsModel:Show_Npc(false)
    SceneManager.Instance.sceneElementsModel:Show_OtherRole(false)
    SceneManager.Instance.sceneElementsModel:Show_Self(false)
    LuaTimer.Add(800, function() self:SetMove(false) end)

end

function GodsWarWorShipModel:ApplyAudience()
    self.audienceList = {}
    local maxNumber = #self.audiencePoint
    local nowNumber = 0
    for k,v in pairs(SceneManager.Instance.sceneElementsModel.RoleView_List) do
        if nowNumber < maxNumber then
            if v.data.unittype == SceneConstData.unittype_role then
                table.insert(self.audienceList,v.data)
                nowNumber = nowNumber + 1
            end
        else
            break
        end
    end
    if nowNumber < maxNumber then
        for k,v in pairs(SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List) do
            if nowNumber < maxNumber then
                if v.unittype == SceneConstData.unittype_role then
                    table.insert(self.audienceList,v)
                    nowNumber = nowNumber + 1
                end
            else
                break
            end
        end
    end
    -- print("sdkljfsdkljfsdkljfksdjfkl")
    -- print(#DataMap.active_region[53011])
    self.audienceDramaList = {type = DramaEumn.ActionType.CustomMultiaction,val = {}}

    self.audienceDeleteDramaList = {type = DramaEumn.ActionType.CustomMultiaction,val = {}}
    local mapPostiionIndex = 1
    --11
    for k,v in pairs(self.audienceList) do
        local gx = self.audiencePoint[mapPostiionIndex][1] * ctx.sceneManager.Map.GridWidth
        local gy = self.audiencePoint[mapPostiionIndex][2] * ctx.sceneManager.Map.GridWidth
        -- print("噜啦啦啦啦啦啦啦啦")
        -- print(gx)
        -- print(gy)
        -- local bigTran = SceneManager.Instance.sceneModel:transport_big_pos(gx,gy)
        -- BaseUtils.dump(bigTran)
        -- self.audienceDramaList = {type = DramaEumn.ActionType.Plotunitcreate, unit_id = self.unitIndex, battle_id = self.unitIndex, unit_base_id = v.baseid, msg = v.name, mapid = 53011, x = self.audiencePoint[1][1], y = self.audiencePoint[1][2],sex = v.sex,classes = v.classes,looks = v.looks,type = 1,time = 600}
         local smallPostion = SceneManager.Instance.sceneModel:transport_small_pos(gx,gy)
         local dx = self.centerPosition.x - gx
        local dy =  (-self.centerPosition.y) -  (-gy)
        local angle = 360 *(math.atan2(dy, dx)/ (2*math.pi))
        angle = ((270 + 360) - (angle + 720) % 360) % 360
        local small = 360
        local dirIndex = -1
        -- print(angle)
        for k,v in pairs(SceneConstData.UnitFaceToIndex) do

            if math.abs(angle - (v + 720)%360) < small then
                dirIndex = k
                small = angle - (v + 720)%360
            end
        end
        local myLooks = BaseUtils.copytab(v.looks)
        for k,v in pairs(myLooks) do
            if v.looks_type == SceneConstData.looktype_ride then
                table.remove(myLooks,k)
            end
        end
         table.insert(self.audienceDramaList.val,{type = DramaEumn.ActionType.Plotunitcreate, unit_id = self.unitIndex, battle_id = self.unitIndex, unit_base_id = 61005, msg = v.name, mapid = 53011, x = gx, y = gy,sex = v.sex,classes = v.classes,looks = myLooks,type = 1,val = dirIndex - 1,time = 600})
         table.insert(self.audienceDeleteDramaList.val,{type = DramaEumn.ActionType.Plotunitdel, unit_id = self.unitIndex})
         v.unitIndex = self.unitIndex
        mapPostiionIndex = mapPostiionIndex + 1
        self.unitIndex = self.unitIndex + 1
    end

end

function GodsWarWorShipModel:OpenVedioWindow(args)
    if self.vedioWin == nil then
        self.vedioWin = GodsWarWorShipVideoWindow.New(self)
    end

    self.vedioWin:Open(args)

end

function GodsWarWorShipModel:CloseVedioWindow(args)
    if self.vedioWin ~= nil then
        WindowManager.Instance:CloseWindow(self.vedioWin)
    end
end



function GodsWarWorShipModel:OpenSettlePanel(args)
    if self.settlePanel == nil then
        self.settlePanel = GodsWarChallengeSettlementPanel.New(self)
    end
    self.settlePanel:Show(args)
end

function GodsWarWorShipModel:CloseSettlePanel()
    if self.settlePanel ~= nil then
        self.settlePanel:DeleteMe()
        self.settlePanel = nil
    end
end

--检查自己是否为膜拜冠军队伍
function GodsWarWorShipModel:CheckMyselfChampaign()
    self.isChampion = false
    local roleData = RoleManager.Instance.RoleData
    local memberData = GodsWarWorShipManager.Instance.godsWarWorShipData[GodsWarWorShipManager.Instance.nowChampionTeams]
    if memberData ~= nil and next(memberData.members) ~= nil then
        for i,v in pairs(memberData.members) do
            if roleData.id == v.rid and roleData.platform == v.platfrom and roleData.zone_id == v.zone_id then
                self.isChampion = true
                break
            end
        end
    end
    -- BaseUtils.dump(GodsWarWorShipManager.Instance.godsWarWorShipData,"GodsWarWorShipManager.Instance.godsWarWorShipData")
    -- BaseUtils.dump(roleData)
    -- print(self.isChampion == false)

end

