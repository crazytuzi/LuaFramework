-- --------------------------------------------------------------------
-- 竖版好友赠送友情点
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
FriendAwardPanel = class("FriendAwardPanel", function()
    return ccui.Widget:create()
end)

function FriendAwardPanel:ctor()  
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function FriendAwardPanel:config()
    self.ctrl = FriendController:getInstance()
    self.size = cc.size(720,800)
    self:setContentSize(self.size)
    self.item_list = {}
end
function FriendAwardPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("friend/friend_award_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    
    self.cost_panel = self.main_panel:getChildByName("cost_panel")
    self.friend_point = self.cost_panel:getChildByName("num_label")

    self.num_label = createRichLabel(20, cc.c4b(0x76,0x45,0x19,0xff), cc.p(0,0), cc.p(285,27), 0, 0, 400)
    self.main_panel:addChild(self.num_label)

    self.btn_send = self.main_panel:getChildByName("btn_send")
    self.btn_send:setTitleText(TI18N("一键领取"))
    local title = self.btn_send:getTitleRenderer()   
    --title:enableOutline(Config.ColorData.data_color4[264],2)
    title:enableShadow(Config.ColorData.data_new_color4[3],cc.size(0,-2),2)

end



function FriendAwardPanel:setData(data)
    self:setFriendPoint()
    if not data then return end
    self.data = data
    local num = 0
    if data and next(data) then
        for i,vo in ipairs(data) do
            if vo and vo.is_draw == 1 then
                num =num +1
            end
        end
    end
    local online_num, all_num = self.ctrl:getModel():getFriendOnlineAndTotal() 
    local str = string.format(TI18N("礼物数：%s"),num)
    self.num_label:setString(str)
end

--事件
function FriendAwardPanel:registerEvents()

    self.btn_send:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            local list = {}
            local array = self.ctrl:getModel():getArray()
            for i=1,array:GetSize() do 
                local vo = array:Get(i-1)
                if vo and vo.is_draw == 1 then 
                    table.insert(list,{rid=vo.rid,srv_id = vo.srv_id})
                end
            end
            self.ctrl:sender_13317(1,list)
        end
    end)

    self.cost_panel:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            local tips = TI18N("1、友情点通过好友赠送获得，每人每日最多可赠送10次，领取30次\n"..
                                "2、超过领取次数后继续领取只获得金币 \n"..
                                "3、向好友赠送友情点后自身也将获得金币")
            TipsManager:getInstance():showCommonTips(tips,cc.p(35,355))
        end
    end)
    
end

function FriendAwardPanel:setFriendPoint()
    local role_vo = RoleController:getInstance():getRoleVo()
    local friend_point = role_vo.friend_point or 0
    self.friend_point:setString(friend_point)
end
function FriendAwardPanel:setCallFun(call_fun)
    self.call_fun =call_fun
end
function FriendAwardPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end



function FriendAwardPanel:DeleteMe()
    
end



