-- @Author: lwj
-- @Date:   2019-01-05 10:27:19
-- @Last Modified time: 2019-01-05 10:27:22

BookTaskItem = BookTaskItem or class("BookTaskItem", BaseItem)
local BookTaskItem = BookTaskItem

function BookTaskItem:ctor(parent_node, layer)
    self.abName = "book"
    self.assetName = "BookTaskItem"
    self.layer = layer

    self.model = BookModel:GetInstance()
    BaseItem.Load(self)
end

function BookTaskItem:dctor()
    self:DestroyIcon()
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

function BookTaskItem:LoadCallBack()
    self.nodes = {
        "des", "icon", "btn_Get", "stateFlag",
        "goalContent/linkText",
        "red_con",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)
    self.stateFlag = GetImage(self.stateFlag)
    self.linkText = GetLinkText(self.linkText);

    self:AddEvent()
    self:UpdateView()
end

function BookTaskItem:AddEvent()
    local function call_back()
        self.model.isGettingReward = true
        self.model:Brocast(BookEvent.GetTaskReward, self.data.id)
    end
    AddButtonEvent(self.btn_Get.gameObject, call_back)

    self.linkText:AddClickListener(handler(self, self.HandleLinkClick));
end

function BookTaskItem:SetData(data)
    self.data = self.model:GetTaskData(data)
    self.conData = Config.db_target_task[data]
    if self.is_loaded then
        self:UpdateView()
    end
end

function BookTaskItem:UpdateView()
    self.linkText.text = ""
    local des = self.conData.name
    --local finish = self.data.finished
    local type = self.conData.type
    local valueTab = String2Table(self.conData.goals)
    self.panelTab = String2Table(self.conData.link)
    local bossName = ""
    local headDes = ""
    local panelName = ""
    if type == 6 then
        --属性提升
        local xVal = valueTab[1][2]
        local role_value = RoleInfoModel.GetInstance():GetMainRoleData():GetAttr(valueTab[1][1])
        self.des.text = string.gsub(des, "x", xVal, 1) .. " （" .. role_value .. '/' .. xVal .. '）'
    elseif type == 7 then
        --穿戴装备
        local temp = string.gsub(des, "x", valueTab[1][2], 1)
        local con_id = valueTab[1][3]
        self.des.text = string.gsub(temp, "x", enumName.COLOR[con_id], 1)
    elseif type == 8 then
        --首领
        self.des.text = des
        local bossTab = String2Table(self.conData.goals)

        local colorStr = ""
        local splitStr = ""
        for i = 1, #bossTab do
            local sinBossName = Config.db_boss[bossTab[i][1]].name
            colorStr = "<color=#" .. ConfigLanguage.Book.HadNotFinished .. ">"
            if i == #bossTab then
                splitStr = ""
            else
                splitStr = "、"
            end
            local isGet = false
            if self.data then
                for ii, vv in pairs(self.data.finished) do
                    if bossTab[i][1] == vv then
                        colorStr = "<color=#" .. ConfigLanguage.Book.HadFinished .. ">"
                        isGet = true
                        break
                    end
                end
            end
            if isGet then
                bossName = bossName .. colorStr .. sinBossName .. splitStr .. "</color>"
            else
                bossName = bossName .. colorStr .. "<a href=boss_" .. bossTab[i][1] .. ">" .. sinBossName .. "</a>" .. splitStr .. "</color>"
            end
        end
    elseif type == 9 then
        --激活套装
        self.des.text = string.gsub(des, "x", valueTab[1][2], 1)
    else
        --剩余
        self.des.text = des
    end

    --页面跳转
    if self.conData.link ~= "{}" then
        local colorStr = ""
        local splitStr = ""
        local name_cf = String2Table(self.conData.panel_name)
        for i = 1, #self.panelTab do
            --local linkTab = GetOpenLink(self.panelTab[i][1], self.panelTab[i][2])
            --local singlePanelName = linkTab.name
            local singlePanelName = name_cf[i]
            colorStr = "<color=#23FF0C>"
            if i == #self.panelTab then
                splitStr = ""
            else
                splitStr = "、"
            end
            panelName = panelName .. colorStr .. "<a href=panel_" .. i .. ">" .. singlePanelName .. "</a>" .. splitStr .. "</color>"
        end
    end

    headDes = self.conData.desc
    self.linkText.text = headDes .. bossName .. panelName

    --进度提示区分
    if type ~= 6 and type ~= 8 then
        self:SetNormalTail()
    end

    --icon往后
    self:DestroyIcon()
    local gainTbl = String2Table(self.conData.gain)[1]
    local param = {}
    param["model"] = self.model
    param["item_id"] = gainTbl[1]
    param["num"] = gainTbl[2]
    param["size"] = { x = 76, y = 76 }
    param["can_click"] = true
    self.iconItem = GoodsIconSettorTwo(self.icon)
    self.iconItem:SetIcon(param)
    --self.iconItem:UpdateIconByItemIdClick(gainTbl[1], gainTbl[2], { x = 94, y = 94 })

    if self.data and self.data.status == 1 then
        SetVisible(self.btn_Get, true)
        SetVisible(self.stateFlag, false)
    else
        SetVisible(self.btn_Get, false)
        SetVisible(self.stateFlag, true)
        local status = (self.data and self.data.status or 0)
        lua_resMgr:SetImageTexture(self, self.stateFlag, "book_image", ConfigLanguage.Book.BookFlagHead .. tostring(status), false, nil, false)
    end
    self:SetRedDot(self.model:IsHaveTaskRD(self.conData.id))
end

--点击事件
function BookTaskItem:HandleLinkClick(str)
    local strTab = string.split(str, "_")
    if strTab and #strTab > 1 then
        if strTab[1] == "panel" then
            local pTab = self.panelTab[tonumber(strTab[2])]
            OpenLink(unpack(pTab))
        elseif strTab[1] == "boss" then
            local curSceneId = SceneManager.GetInstance():GetSceneId()
            local sceneid = Config.db_boss[tonumber(strTab[2])].scene
            self.model.coord = String2Table(Config.db_boss[tonumber(strTab[2])].coord);
            if sceneid ~= curSceneId then
                SceneControler:GetInstance():RequestSceneChange(sceneid, enum.SCENE_CHANGE.SCENE_CHANGE_BOSS, { x = self.model.coord[1], y = self.model.coord[2] }, nil, 0);
            else
                self.model:Brocast(BookEvent.HandleBossSceneChange, nil, true)
            end
        end
    end
end

--设置任务描述后缀
function BookTaskItem:SetNormalTail()
    local result = 0
    local index = String2Table(self.conData.goals)[1][3]
    if self.data then
        if self.data.status >= 1 then
            result = index
        else
            result = self.data.finished[1]
        end
    end

    self.des.text = self.des.text .. " （" .. result .. '/' ..index.. '）'
end

function BookTaskItem:DestroyIcon()
    if self.iconItem then
        self.iconItem:destroy()
    end
    self.iconItem = nil
end

function BookTaskItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    if isShow == nil then
        isShow = false
    end
    self.red_dot:SetRedDotParam(isShow)
end


