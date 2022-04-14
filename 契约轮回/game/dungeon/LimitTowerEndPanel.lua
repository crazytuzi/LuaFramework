---
--- Created by  Administrator
--- DateTime: 2019/11/2 15:39
---
LimitTowerEndPanel = LimitTowerEndPanel or class("LimitTowerEndPanel", BasePanel)
local this = LimitTowerEndPanel

function LimitTowerEndPanel:ctor(parent_node, parent_panel)
    self.abName = "dungeon";
    self.image_ab = "dungeon_image";
    self.assetName = "LimitTowerEndPanel"
    self.layer = "UI"

    self.model = DungeonModel.GetInstance()
    self.events = {};
    self.schedules = {};
end

function LimitTowerEndPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.enditem then
        self.enditem:destroy();
    end

    if self.event_id_1 then
        self.model:RemoveListener(self.event_id_1)
        self.event_id_1 = nil
    end

    destroyTab(self.items);
end

function LimitTowerEndPanel:Open(data)
    self.data = data;
    WindowPanel.Open(self)
end


function LimitTowerEndPanel:LoadCallBack()
    self.nodes = {
        "win","lose", "win/winLabels","win/jingyan","win/awardCon","zhandoujiangli",
    }
    self:GetChildren(self.nodes)
    self.jingyan = GetText(self.jingyan)
    self:InitUI()
    self:AddEvent()
end

function LimitTowerEndPanel:InitUI()
    self.data["IsCancelAutoSchedule"] = true;
    self.enditem = DungeonEndItem(self.transform, self.data);
    self.enditem.sure_format = "Next stage";
    if self.data then
        -- 成功界面
        if self.data.isClear == true then
            self.win.gameObject:SetActive(true);
            self.lose.gameObject:SetActive(false);
            SetVisible(self.zhandoujiangli,true)
            self.enditem:ShowStars(true);
            if self.data.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_LIMITTOWER then

                if self.data.reward then
                    if self.data.reward[90010002] then
                        self.jingyan.text = tostring(self.data.reward[90010012]);
                    else
                        self.jingyan.text = tostring(0);
                    end
                    --物品图标
                    local index = 1;
                    destroyTab(self.items);
                    self.items = {};
                    for k, v in pairs(self.data.reward) do
                        if k ~= 90010012 then
                            local param = {}
                            param["item_id"] = k
                            param["num"] = v
                            param["model"] = BagModel:GetInstance()
                            param["can_click"] = true

                          --  if self.itemicon == nil then
                                self.items[index]  = GoodsIconSettorTwo(self.awardCon)
                           -- end
                            self.items[index]:SetIcon(param)
                            index = index + 1;

                            --local item = AwardItem(self.awardCon);
                            --item:SetData(k, v);
                            --item:AddClickTips(self.transform);
                            --self.items[index] = item;
                            --index = index + 1;
                        end
                    end

                else
                    self.jingyan.text = tostring(0);
                end




              --  self.winLabels.gameObject:SetActive(true);

                -- 还有没有打完的要继续
                local HandleClickSure = function()
                    --local data = self.model.dungeon_info_list[self.data.stype]
                    --if not data then
                    --    return
                    --end
                    local cfg = Config.db_yunying_dunge_limit_tower[self.data.floor + 1]
                    if cfg.assist == 1 then
                        local function ok_func()
                            DungeonCtrl:GetInstance():RequestEnterDungeon(self.data.stype, self.data.floor + 1,self.data.id)
                        end
                        Dialog.ShowTwo("Tip","You may ask for assistance in the next stage, Solo it?","Confirm",ok_func)
                    else
                        DungeonCtrl:GetInstance():RequestEnterDungeon(self.data.stype, self.data.floor + 1,self.data.id)
                    end

                end
                local firstFinishFun = function()
                    SceneControler:GetInstance():RequestSceneLeave();
                    self:Close();
                end
                self.enditem.close_format = "Close (%s)";
                self.enditem:SetAutoCloseCallBack(firstFinishFun);
                if not TeamModel:GetInstance():GetTeamInfo()  then
                    if Config.db_yunying_dunge_limit_tower[self.data.floor + 1] then
                        self.enditem:ShowSureBtn(HandleClickSure);
                        self.enditem:SetAutoCloseCallBack(firstFinishFun);
                    end
                else
                    if TeamModel:GetInstance():GetMyTeamMemberNum() == 1 then
                        if Config.db_yunying_dunge_limit_tower[self.data.floor + 1] then
                            self.enditem:ShowSureBtn(HandleClickSure);
                            self.enditem:SetAutoCloseCallBack(firstFinishFun);
                        end
                    end
                end
            end
            --if Config.db_yunying_dunge_limit_tower[self.data.floor + 1] then
            --    self.enditem:ShowSureBtn(HandleClickSure);
            --    self.enditem:SetAutoCloseCallBack(HandleClickSure);
            --end
            -- 失败界面
        else
            self.win.gameObject:SetActive(false);
            SetVisible(self.zhandoujiangli,false)
            self.lose.gameObject:SetActive(true);
            --if self.data.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_MAGICTOWER then
            --    if self.data.reward then
            --        if self.data.reward[90010012] then
            --            self.jingyan_defeat.text = tostring(self.data.reward[90010012]);
            --        else
            --            self.jingyan_defeat.text = tostring(0);
            --        end
            --    end
            --else
            --    self.jingyan_defeat.text = tostring(0);
            --end
        end
    end
    local time = 10;
    local dungeTab = Config.db_dunge[SceneManager:GetInstance():GetSceneId()];
    if dungeTab then
        time = dungeTab.exit_cd;
    end
    time = time or 10;
    self.enditem:StartAutoClose(time);
end

function LimitTowerEndPanel:AddEvent()
    local call_back = function()
        SceneControler:GetInstance():RequestSceneLeave();
        self:Close();
    end

    self.enditem:SetCloseCallBack(call_back);


    local function call_back()
        self:Close()
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.LEAVE_DUNGEON_SCENE, call_back)
    self.event_id_1 = self.model:AddListener(DungeonEvent.ResEnterDungeonInfo, call_back)
end