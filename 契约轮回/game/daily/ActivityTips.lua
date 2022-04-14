-- @Author: lwj
-- @Date:   2019-01-18 16:25:10
-- @Last Modified time: 2019-01-18 16:25:12

ActivityTips = ActivityTips or class("ActivityTips", BasePanel)
local ActivityTips = ActivityTips

function ActivityTips:ctor()
    self.abName = "daily"
    self.assetName = "ActivityTips"
    self.layer = "UI"

    self.use_background = true
    self.click_bg_close = true
    self.iconList = {}
end

function ActivityTips:dctor()
    for i, v in pairs(self.iconList) do
        if v then
            v:destroy()
        end
    end
    self.iconList = {}
end

function ActivityTips:Open(id, parent_node)
    ActivityTips.super.Open(self)
    self.id = id
    self.parent_node = parent_node
end

function ActivityTips:LoadCallBack()
    self.nodes = {
        "times", "item_reward", "act_des", "act_reward", "lv_limit", "act_time", "icon", "name",
        "reward_scroll/Viewport/reward_content",
    }
    self:GetChildren(self.nodes)
    self.icon = GetImage(self.icon)
    self.times = GetText(self.times)
    self.name = GetText(self.name)
    self.act_time = GetText(self.act_time)
    self.lv_limit = GetText(self.lv_limit)
    self.act_des = GetText(self.act_des)
    self.act_reward = GetText(self.act_reward)
    self.viewRectTra = self.transform:GetComponent('RectTransform')
    self.icon_rect = self.icon:GetComponent('RectTransform')

    self:AddEvent()
    self:InitPanel()
    self:SetViewPosition()
end

function ActivityTips:AddEvent()
end

function ActivityTips:InitPanel()
    self.icon:SetNativeSize()
    local conData = Config.db_daily[self.id]
    lua_resMgr:SetImageTexture(self, self.icon, "iconasset/icon_daily", conData.pic, false, nil, false)
    local conTimes = conData.count
    local des = ""
    if conTimes == 0 then
        --无次数限制
        des = ConfigLanguage.Daily.UnlimitTimes
    else
        local curTimes = DailyModel.GetInstance():GetTaskInfoById(self.id)
        if not curTimes then
            curTimes = conTimes
        else
            curTimes = conTimes - curTimes.progress
        end
        des = curTimes .. "/" .. conTimes
    end
    self.times.text = ConfigLanguage.Daily.ActiveItemTimesHead .. des
    self.name.text = conData.name
    if conData.act_type == 1 then
        self.act_time.text = ConfigLanguage.Daily.AllDayOpen
    else
        local actData = Config.db_activity[conData.activity]
        local tbl = DailyModel.GetInstance():GetTimeTblByStr(actData.time)
        local len = #tbl
        local str = "Event Time:"
        for i = 1, len do
            local tail = ""
            if i ~= len then
                tail = "\n                  "
                if len == 3 then
                    tail = "\n               "
                end
            end

            str = str .. string.format("<color=#2fad25>%02d:%02d-%02d:%02d</color>", tbl[i][1][1], tbl[i][1][2], tbl[i][2][1], tbl[i][2][2]) .. tail
        end
        self.act_time.text = str
    end
    local lv = String2Table(conData.reqs)[1][2]
    lv = GetLevelShow(lv)
    self.lv_limit.text = string.format(ConfigLanguage.Daily.LimitLv, lv)
    self.act_des.text = "<color=#705e4e>" .. conData.desc .. "</color>"
    local actDes = tostring(conData.activation)
    if conData.activation == 0 then
        actDes = ConfigLanguage.Daily.NoActReward
    end
    self.act_reward.text = ConfigLanguage.Daily.SingleActReward .. '<color=#5ab74d>' .. actDes .. "</color>"
    local tbl = String2Table(conData.reward)
    for i = 1, #tbl do
        local param = {}
        local operate_param = {}
        param["cfg"] = Config.db_item[tbl[i][1]]
        param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 60, y = 60 }
        local goodsItem = GoodsIconSettorTwo(self.reward_content)
        goodsItem:SetIcon(param)
        table.insert(self.iconList, goodsItem)
    end
    self.parentRectTra = self.parent_node:GetComponent('RectTransform')
    SetSizeDelta(self.background_transform, 3000, 3000)
end

function ActivityTips:SetViewPosition()
    local parentWidth = 0
    local parentHeight = 0
    local spanX = 0
    local spanY = 0
    if self.parentRectTra.anchorMin.x == 0.5 then
        spanX = 10
        parentWidth = self.parentRectTra.sizeDelta.x / 2
        parentHeight = self.parentRectTra.sizeDelta.y / 2
    else
        parentWidth = self.parentRectTra.sizeDelta.x
        parentHeight = self.parentRectTra.sizeDelta.y
    end

    --local parentRectTra = self.parent_node:GetComponent('RectTransform')
    local pos = self.parent_node.position
    local x = ScreenWidth / 2 + pos.x * 100 + parentWidth
    local y = pos.y * 100 - ScreenHeight / 2 - parentHeight
    local UITransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.UI)
    self.transform:SetParent(UITransform)
    SetLocalScale(self.transform, 1, 1, 1)

    --判断是否超出右边界
    if ScreenWidth - (x + parentWidth + self.viewRectTra.sizeDelta.x) < 10 then
        --spanX = ScreenWidth - (x + self.viewRectTra.sizeDelta.x + self.btnWidth)
        if self.parentRectTra.anchorMin.x == 0.5 then
            x = x - self.viewRectTra.sizeDelta.x - parentWidth * 2 - 20
        else
            x = x - self.viewRectTra.sizeDelta.x - parentWidth
        end

    end

    if ScreenHeight + y - self.viewRectTra.sizeDelta.y < 10 then
        spanY = ScreenHeight + y - self.viewRectTra.sizeDelta.y - 10
    end

    self.viewRectTra.anchoredPosition = Vector2(x + spanX, y - spanY)
end

