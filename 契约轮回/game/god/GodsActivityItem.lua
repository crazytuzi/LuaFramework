---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Admin.
--- DateTime: 2019/11/12 20:14
GodsActivityItem = GodsActivityItem or class("GodsActivityItem", BaseCloneItem)
local GodsActivityItem = GodsActivityItem

function GodsActivityItem:ctor(parent_node, layer)


    self.model = GodModel.GetInstance()
    GodsActivityItem.super.Load(self)
end

function GodsActivityItem:dctor()
    if self.item then
        self.item:destroy()
    end
    if self.actBtn_red then
        self.actBtn_red:destroy()
    end
    self.actBtn_red = nil
end

function GodsActivityItem:LoadCallBack()
    self.nodes = {
      "pos","des","go","reward","havereward",
    }
    self:GetChildren(self.nodes)

    self.desTex = GetText(self.des)
    self.haveImg = GetImage(self.havereward)

    self.actBtn_red = RedDot(self.reward, nil, RedDot.RedDotType.Nor)
    self.actBtn_red:SetPosition(54, 16)
    self.actBtn_red:SetRedDotParam(true)

    SetGray(self.haveImg, true)
    self:AddEvent()
end

function GodsActivityItem:AddEvent()
    local function callback()
        GlobalEvent:Brocast(OperateEvent.REQUEST_GET_REWARD, 171100, self.config.id, self.config.level)
    end
    AddButtonEvent(self.reward.gameObject, callback)


    local function call_back()
        local s = String2Table(self.config.sundries)
        OpenLink(unpack(s[2][2]))

        self.panel:Close()
    end
   AddClickEvent(self.go.gameObject, call_back)

end

function GodsActivityItem:SetData(data, panel)
    self.panel = panel
end

function GodsActivityItem:UpdateView(data)
    self.config = self.model:GetDataById(data.id)
    self.data = data
    local c = String2Table(self.config.task)
    local count = 0
    if data.id == 9 then
        count = c[2]
        if data.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
            local str = string.format("<color=#eb0000>(%s/%s)</color>", data.count, count)
            self.desTex.text = self.config.desc .. str
        else
            local str = string.format("<color=#3ab60e>(%s/%s)</color>", count, count)
            self.desTex.text = self.config.desc .. str
        end
    else
        if c[1] and type(c[1]) == 'table' then
            count = c[1][2]
        else
            count = c[2] or c[1]
        end

        if data.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
            local str = string.format("<color=#eb0000>(%s/%s)</color>", data.count, count)
            self.desTex.text = self.config.desc .. str
        else
            local str = string.format("<color=#3ab60e>(%s/%s)</color>", count, count)
            self.desTex.text = self.config.desc .. str
        end
    end

  --[[  if data.id == 1 then
        if data.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
            self.desTex.text = self.config.desc .. "<color=#eb0000> (0/1)</color>"
        else
            self.desTex.text = self.config.desc .. "<color=#3ab60e> (1/1)</color>"
        end
    elseif data.id == 2 or data.id ==3 or data.id == 4 or data.id ==5 then
        local c = String2Table(self.config.task)[2]
        if data.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
            local str = string.format("<color=#eb0000>(%s/%s)</color>", data.count, c)
            self.desTex.text = self.config.desc .. str
        else
            local str = string.format("<color=#3ab60e>(%s/%s)</color>", c, c)
            self.desTex.text = self.config.desc .. str
        end
    elseif data.id == 6 or data.id == 9 or data.id == 7 then
        local c = String2Table(self.config.task)
        if data.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
            local str = string.format("<color=#eb0000>(%s/%s)</color>", data.count, c[1][2])
            self.desTex.text = self.config.desc .. str
        else
            local str = string.format("<color=#3ab60e>(%s/%s)</color>", c[1][2], c[1][2])
            self.desTex.text = self.config.desc .. str
        end
    elseif data.id == 8 then
        if data.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
            self.desTex.text = self.config.desc .. "<color=#eb0000> (0/1)</color>"
        else
            self.desTex.text = self.config.desc .. "<color=#3ab60e> (1/1)</color>"
        end
    else
        logError("没有相关配置表数据")
    end
--]]
    self:SetBtn(data.state)
    self:SetReward()
end

function GodsActivityItem:SetBtn(index)
    SetVisible(self.go.gameObject, index == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE)    -- 未完成
    SetVisible(self.reward.gameObject, index == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH)-- 已完成
    SetVisible(self.havereward.gameObject,index == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD) -- 已领取
end

function GodsActivityItem:SetReward()
    local rewa_tbl = String2Table(self.config.reward)[1]
    local param = {}
    local operate_param = {}
    param["item_id"] = rewa_tbl[1]
    param["model"] = self.model
    param["can_click"] = true
    param["operate_param"] = operate_param
    param["size"] = { x = 70, y = 70 }
    param["num"] = rewa_tbl[2]
    param["bind"] = rewa_tbl[3]
    if not self.item then
        self.item = GoodsIconSettorTwo(self.pos)
    end
    self.item:SetIcon(param)
end

