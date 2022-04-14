-- @Author: lwj
-- @Date:   2019-06-03 16:52:24
-- @Last Modified time: 2019-06-03 16:52:26

InvestItem = InvestItem or class("InvestItem", BaseCloneItem)
local InvestItem = InvestItem

function InvestItem:ctor(parent_node, layer)
    InvestItem.super.Load(self)
end

function InvestItem:dctor()
    if self.itemIcon then
        self.itemIcon:destroy()
        self.itemIcon = nil
    end
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

function InvestItem:LoadCallBack()
    self.model = VipModel.GetInstance()
    self.nodes = {
        "icon_con", "money", "tip", "btn_fetch/btn_text", "des", "money_icon", "bg", "btn_fetch", "tag",
        "btn_fetch/red_con",
    }
    self:GetChildren(self.nodes)
    self.money_icon = GetImage(self.money_icon)
    self.money = GetText(self.money)
    self.des = GetText(self.des)
    self.tip = GetText(self.tip)
    self.tag = GetImage(self.tag)

    self:SetRedDot(true)
    self:AddEvent()
end

function InvestItem:AddEvent()
    local function callback()
        self.model:Brocast(VipEvent.FetchIncestReward, self.data.id)
    end
    AddButtonEvent(self.btn_fetch.gameObject, callback)
end

function InvestItem:SetData(data, ser_data)
    self.data = data
    self.ser_data = ser_data
    self:UpdateView()
end

function InvestItem:UpdateView()
    local rewa_tbl = String2Table(self.data.reward)
    local cur_num = rewa_tbl[1][2]
    local cur_tip = self.data.desc

    GoodIconUtil.GetInstance():CreateIcon(self, self.money_icon, rewa_tbl[1][1], true)
    self.des.text = self.data.text

    if self.model:IsInvested() then
        --是否投资过
        --投资过
        local cur_grade = self.model:GetInvestGrade()
        if self.data.grade == cur_grade then
            --是当前投资的档位
            if self.ser_data then
                --有领取记录
                if self.ser_data.state == 1 then
                    --可领
                    self:ShowBtn()
                    local bgold = self.ser_data.bgold
                    if bgold < rewa_tbl[1][2] then
                        --补差额
                        cur_num = bgold
                        cur_tip = ConfigLanguage.Vip.CanReFetch
                    end
                elseif self.ser_data.state == 2 then
                    --已领
                    self:ShowTag()
                    lua_resMgr:SetImageTexture(self, self.tag, "common_image", "img_have_received_1", true, nil, false)
                end
            else
                --没记录：未领取过
                local cur_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
                if self.data.level <= cur_lv then
                    --可以领取
                    self:ShowBtn()
                else
                    --等级不足
                    self:ShowTag()
                    lua_resMgr:SetImageTexture(self, self.tag, "common_image", "img_have_notReached", true, nil, false)
                end
            end
        else
            --高档位
            self:ShowTag()
            lua_resMgr:SetImageTexture(self, self.tag, "common_image", "img_have_notReached", true, nil, false)

            --追加投资前
            local info = self.model:IsSameLineRewarded(self.data.line)
            if info then
                --已领取
                cur_num = cur_num - info.bgold
                cur_tip = ConfigLanguage.Vip.CanReFetch
            end
        end
    else
        --未投资
        self:ShowTag()
        lua_resMgr:SetImageTexture(self, self.tag, "common_image", "img_have_notReached", true, nil, false)
    end

    local param = {}
    local operate_param = {}
    param["item_id"] = rewa_tbl[1][1]
    param["model"] = self.model
    param["can_click"] = true
    param["operate_param"] = operate_param
    param["size"] = { x = 76, y = 76 }
    if self.itemIcon then
        self.itemIcon:destroy()
        self.itemIcon = nil
    end
    self.itemIcon = GoodsIconSettorTwo(self.icon_con)
    self.itemIcon:SetIcon(param)

    self.money.text = cur_num
    self.tip.text = cur_tip
end

function InvestItem:ShowBtn()
    SetVisible(self.btn_fetch, true)
    SetVisible(self.tag, false)
end
function InvestItem:ShowTag()
    SetVisible(self.btn_fetch, false)
    SetVisible(self.tag, true)
end
function InvestItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end