-- --------------------------------------------------------------------
-- 竖版好友列表
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
FriendListPanel = class("FriendListPanel", function()
    return ccui.Widget:create()
end)

local model = FriendController:getInstance():getModel()

function FriendListPanel:ctor() 
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function FriendListPanel:config()
    self.ctrl = FriendController:getInstance()
    self.size = cc.size(720,800)
    self:setContentSize(self.size)
    self.item_list = {}
    self.is_del = false
end
function FriendListPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("friend/firend_list_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)

    self:addChild(self.root_wnd)
    
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    

    self.cost_panel = self.main_panel:getChildByName("cost_panel")
    self.cost_panel:setTouchEnabled(true)
    self.friend_point = self.cost_panel:getChildByName("num_label")

    --删除按钮
    self.btn_del = self.main_panel:getChildByName("btn_del")
    self.btn_del:setTitleText(TI18N("删除好友"))
    local title = self.btn_del:getTitleRenderer()   
    title:enableOutline(Config.ColorData.data_color4[278],2)
    --添加好友
    self.btn_add = self.main_panel:getChildByName("btn_add")
    self.btn_add:setTitleText(TI18N("添加好友"))
    local title = self.btn_add:getTitleRenderer()
    title:enableOutline(Config.ColorData.data_color4[278],2)
    --一键赠送

    self.btn_send = self.main_panel:getChildByName("btn_send")
    self.btn_send:setTitleText(TI18N("一键赠送"))
    local title = self.btn_send:getTitleRenderer()
    title:enableOutline(Config.ColorData.data_color4[277],2)
   
    self.num_label = createRichLabel(24, Config.ColorData.data_color4[277], cc.p(0,0), cc.p(495,100), 0, 0, 400)
    self.main_panel:addChild(self.num_label)
end


function FriendListPanel:setData(data)
    self.data = data
    local online_num, all_num = self.ctrl:getModel():getFriendOnlineAndTotal() 
    local str = string.format(TI18N("好友数：%s/%s"),all_num,100)
    self.num_label:setString(str)
    self:setFriendPoint()
end

--事件
function FriendListPanel:registerEvents()
    self.btn_del:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self:clickDelBtn()
        end
    end)
    self.btn_add:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self.ctrl:openFriendFindWindow(true)
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
    self.btn_send:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            if self.data == nil then return end
            playButtonSound2()
            self:onKeySend()
        end
    end) 
end

function FriendListPanel:clickDelBtn()
    self.is_del = not self.is_del
    if self.call_fun then 
        self:call_fun(self.is_del)
    end
    local str = TI18N("删除好友")
    if self.is_del == true then 
        str = TI18N("取消删除")
    end
    self.btn_del:setTitleText(str)
end

--一键赠送
function FriendListPanel:onKeySend( )
    local count = model:getFriendPresentCount() or 10
    if count == 0 then
        message(TI18N("今日赠送友情点已达上限!"))
        return
    end
    local list = {}
    for i,vo in ipairs(self.data) do
        if vo and vo.is_present == 0 then
            table.insert(list,{rid=vo.rid,srv_id = vo.srv_id})
        end
        if #list >= count then
            break
        end
    end
    self.ctrl:sender_13317(0,list)
end

function FriendListPanel:setCallFun(call_fun)
    self.call_fun =call_fun
end

function FriendListPanel:setFriendPoint()
    local role_vo = RoleController:getInstance():getRoleVo()
    local friend_point = role_vo.friend_point or 0
    self.friend_point:setString(friend_point)
end

function FriendListPanel:setVisibleStatus(bool)
    self:setVisible(bool)
    if bool == false then 
        self.is_del =false
        self.btn_del:setTitleText(TI18N("删除好友"))
    end
end



function FriendListPanel:DeleteMe()
  
end



