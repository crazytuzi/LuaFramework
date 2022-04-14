--显示一长列item的通用tip
ComIconTipTwo = ComIconTipTwo or class("ComIconTipTwo",WindowPanel)

function ComIconTipTwo:ctor()
    self.abName = "system"
    self.assetName = "ComIconTipTwo"
    self.layer = "UI"

    self.panel_type = 4
    self.use_background = true  
    self.is_click_bg_close = true

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    self.goods_icon_items = {}  --item列表

    self.separate_frame_schedule_id = nil--分帧实例化的定时器id
end

function ComIconTipTwo:dctor()

    destroyTab(self.goods_icon_items,true)

    if self.separate_frame_schedule_id then
		GlobalSchedule:Stop(self.separate_frame_schedule_id)
		self.separate_frame_schedule_id = nil
    end
end

function ComIconTipTwo:LoadCallBack(  )
    self.nodes = {
        "scoroll_view_items/viewport_items/content_items","btn_cancel","txt_tip","btn_ok",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end
end

function ComIconTipTwo:InitUI(  )
    self.txt_tip = GetText(self.txt_tip)
end

function ComIconTipTwo:AddEvent(  )
    local function call_back(  )
        if self.data.ok_callback then
            self.data.ok_callback()
        end
    end
    AddClickEvent(self.btn_ok.gameObject,call_back)

    local function call_back(  )
        if self.data.cancel_callback then
            self.data.cancel_callback()
        else
            self:Close()
        end
    end
    AddClickEvent(self.btn_cancel.gameObject,call_back)
end

--data
--tip tip文本
--ok_callback 确定按钮回调
--cancel_callback 取消按钮回调 不传默认是关闭界面
--items 要显示的item列表 {{item_id,num,bind},{...}}
function ComIconTipTwo:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function ComIconTipTwo:UpdateView()
    self.need_update_view = false

    self.txt_tip.text = self.data.tip

    self:UpdateItems()
end

--刷新Items
function ComIconTipTwo:UpdateItems(  )
    if not self.data.items then
        return
    end

    local num  = #self.data.items
    if num <= 0 then
        return
    end

    local function op_call_back(cur_frame_count,cur_all_count)
        local item = self.data.items[cur_all_count]
        local param = {}
        param.item_id = item[1]
        param.num = item[2]
        param.bind = item[3]
        param.can_click = true
        param.size = {x = 65,y = 65}

        local icon = GoodsIconSettorTwo(self.content_items)
        icon:SetIcon(param)
        self.goods_icon_items[cur_all_count] = icon
    end

    local function all_frame_op_complete()
        self.separate_frame_schedule_id = nil
    end
    
    self.separate_frame_schedule_id = SeparateFrameUtil.SeparateFrameOperate(op_call_back,nil,1,num,nil,all_frame_op_complete)
end
