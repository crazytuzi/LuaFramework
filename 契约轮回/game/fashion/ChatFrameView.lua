-- @Author: lwj
-- @Date:   2019-11-15 17:39:07 
-- @Last Modified time: 2019-11-15 17:39:09

ChatFrameView = ChatFrameView or class("ChatFrameView", BaseDecorateView)
local ChatFrameView = ChatFrameView

function ChatFrameView:ctor(parent_node, layer)
    self.abName = "fashion"
    self.assetName = "IconFrameView"
    self.layer = layer

    self.index = 12
    self.single_line_cout = 3
    self.single_item_height = 231

    self.model_event = {}
    self.star_list = {}
    self.btn_mode = 1
    self.cur_id = 0
    self.cost_tbl = {}
    self.ori_id = 120000
    self.model = FashionModel.GetInstance()
    ChatFrameView.super.Load(self)
end