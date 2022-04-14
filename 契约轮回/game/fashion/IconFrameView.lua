-- @Author: lwj
-- @Date:   2019-11-14 20:24:32 
-- @Last Modified time: 2019-11-14 20:24:35

IconFrameView = IconFrameView or class("IconFrameView", BaseDecorateView)
local IconFrameView = IconFrameView

function IconFrameView:ctor(parent_node, layer)
    self.abName = "fashion"
    self.assetName = "IconFrameView"
    self.layer = layer

    self.index = 11
    self.single_line_cout = 3
    self.single_item_height = 231

    self.model_event = {}
    self.star_list = {}
    self.btn_mode = 1
    self.cur_id = 0
    self.cost_tbl = {}
    self.ori_id = 110000
    self.model = FashionModel.GetInstance()
    IconFrameView.super.Load(self)
end
