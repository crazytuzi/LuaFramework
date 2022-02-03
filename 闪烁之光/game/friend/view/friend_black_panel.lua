-- --------------------------------------------------------------------
-- 竖版好友黑名单
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
FriendBlackPanel = class("FriendBlackPanel", function()
    return ccui.Widget:create()
end)

function FriendBlackPanel:ctor()  
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function FriendBlackPanel:config()
    self.ctrl = FriendController:getInstance()
    self.size = cc.size(720,800)
    self:setContentSize(self.size)
    self.item_list = {}
end
function FriendBlackPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("friend/friend_black_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    
   
    self.num_label = createRichLabel(24, cc.c4b(0x76,0x45,0x19,0xff), cc.p(1,0), cc.p(670,12), 0, 0, 400)
    self.main_panel:addChild(self.num_label)
   
end

function FriendBlackPanel:setData(data)
    if not data then return end
    self.data = data

    local online_num, all_num = self.ctrl:getModel():getBlackListOnlineAndTotal() 
    local str = string.format(TI18N("黑名单数：%s/%s"),all_num,50)
    self.num_label:setString(str)
end

--事件
function FriendBlackPanel:registerEvents()
    
end
function FriendBlackPanel:setCallFun(call_fun)
    self.call_fun =call_fun
end
function FriendBlackPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end



function FriendBlackPanel:DeleteMe()
    
end



